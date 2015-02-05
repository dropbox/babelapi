import os
import shutil

from babelapi.generator.generator import CodeGeneratorMonolingual
from contextlib import contextmanager

from babelapi.data_type import (
    DataType,
    is_any_type,
    is_binary_type,
    is_boolean_type,
    is_composite_type,
    is_integer_type,
    is_list_type,
    is_null_type,
    is_string_type,
    is_struct_type,
    is_symbol_type,
    is_timestamp_type,
    is_union_type,
)

from babelapi.lang.swift import SwiftTargetLanguage

base = """
/* Autogenerated. Do not edit. */
import Foundation

"""

class SwiftGenerator(CodeGeneratorMonolingual):
    lang = SwiftTargetLanguage()

    def generate(self):
        cur_folder = os.path.dirname(__file__)
        self._logger.info('Copying babel_serializers.swift to output folder')
        shutil.copy(os.path.join(cur_folder, 'babel_serializers.swift'),
                    self.target_folder_path)

        for namespace in self.api.namespaces.values():
            with self.output_to_relative_path('{}.swift'.format(namespace.name)):
                self._generate_base_namespace_module(namespace)


    def _generate_base_namespace_module(self, namespace):
        self.emit(base)

        with self.block('public class {}'.format(self.lang.format_class(namespace.name))):
            for data_type in namespace.linearize_data_types():
                if is_struct_type(data_type):
                    self._generate_struct_class(namespace, data_type)
                elif is_union_type(data_type):
                    self._generate_union_type(namespace, data_type)
#            else:
#                raise TypeError('Cannot handle type %r' % type(data_type))
#        for route in namespace.routes:
#            self._generate_route_class(namespace, route)

    # generation helper methods

    @contextmanager
    def function_block(self, func, args, return_type=None):
        self.emit_line('{}'.format(func), trailing_newline=False)
        self._generate_func_arg_list(args, compact=True)
        if return_type is not None:
            self.emit(' -> {}'.format(return_type))
        with self.block(header=''):
            yield

    @contextmanager
    def class_block(self, thing, protocols=None):
        protocols = protocols or []
        extensions = []

        if isinstance(thing, DataType):
            name = self.class_data_type(thing)
            if thing.super_type:
                extensions.append(self.class_data_type(thing.super_type))
        elif isinstance(thing, basestring):
            name = thing
        else:
            raise TypeError("trying to generate class block for unknown type %r" % thing)

        extensions.extend(protocols)

        extend_suffix = ': {}'.format(', '.join(extensions)) if extensions else ''

        with self.block('public class {}{}'.format(name, extend_suffix)):
            yield


    @contextmanager
    def serializer_block(self, data_type):
        class_name = self.class_data_type(data_type)
        with self.class_block(class_name+'Serializer', protocols=['JSONSerializer']):
            with self.function_block('func serialize',
                                     args=['value : {}'.format(class_name)],
                                     return_type='String'):
                yield


    def class_data_type(self, data_type):
        return self.lang.format_class(data_type.name)

    def _var_from_field(self, field):
        return '{}: {}{}'.format(self.lang.format_variable(field.name),
                                    self.lang.format_type(field.data_type),
                                    '?' if field.optional else '')


    def _generate_struct_class_init_method(self, data_type):
        args = []
        for field in data_type.all_fields:
            arg = self._var_from_field(field)
            if field.has_default:
                arg += ' = {}'.format(self.lang.format_obj(field.default))
            args.append(arg)

        with self.function_block('public init', args):
            for field in data_type.fields:
                v = self.lang.format_variable(field.name)
                self.emit_line('self.{} = {}'.format(v, v))

            if data_type.super_type:
                self.emit_line('super.init', trailing_newline=False)
                self._generate_func_arg_list(['{}: {}'.format(self.lang.format_variable(f.name),
                                                              self.lang.format_variable(f.name))
                                              for f in data_type.super_type.fields])
                self.emit_empty_line()

    def _dump_static_json(self, field, arg):
        return '\\"{}\\": \({}Serializer.serialize({}))'.format(
            field.name,
            self.lang.format_variable(field.name),
            arg
        )

    def _generate_serializer_for_field(self, field):
        if is_list_type(field.data_type):
            serializer = '{}(elementSerializer: {}())'.format(
                self.lang.format_serializer_type(field.data_type),
                self.lang.format_serializer_type(field.data_type.data_type),
            )
        elif is_composite_type(field.data_type):
            serializer = '{}()'.format(self.lang.format_serializer_type(field.data_type))
        else:
            serializer = 'Serialization._{}'.format(self.lang.format_serializer_type(field.data_type))

        self.emit_line('let {}Serializer = {}'.format(self.lang.format_variable(field.name), serializer))

    def _generate_struct_class_serializer(self, data_type):
        with self.serializer_block(data_type):
            output = []
            for field in data_type.fields:
                self._generate_serializer_for_field(field)
                val = 'value.{}'.format(self.lang.format_variable(field.name))
                if field.optional:
                    val += '!'
                output.append(self._dump_static_json(field, val))

            self.emit_line('return "{{{}}}"'.format(', '.join(output)))

    def _generate_struct_class(self, namespace, data_type):
        with self.class_block(data_type):
            for field in data_type.fields:
                self.emit_line('public var {}'.format(self._var_from_field(field)))

            self._generate_struct_class_init_method(data_type)

        self._generate_struct_class_serializer(data_type)

    def _format_tag_type(self, namespace, data_type):
        if is_symbol_type(data_type) or is_any_type(data_type):
            return ''
        else:
            return '({})'.format(self.lang.format_type(data_type, namespace))

    def _generate_union_type(self, namespace, data_type):
        with self.block('public enum {}'.format(self.class_data_type(data_type))):
            for field in data_type.fields:
                typ = self._format_tag_type(namespace, field.data_type)
                self.emit_line('case {}{}'.format(self.lang.format_class(field.name),
                                                  typ))

        self._generate_union_serializer(data_type)

    def _generate_union_serializer(self, data_type):
        class_name = self.class_data_type(data_type)
        with self.block('class {}Serializer: JSONSerializer'.format(class_name)):
            with self.block('func serialize(value: {}) -> String'.format(class_name)):
                with self.block('switch value'):
                    for field in data_type.fields:
                        case = '.{}'.format(self.lang.format_class(field.name))
                        if is_symbol_type(field.data_type) or is_any_type(field.data_type):
                            ret = '\\"{}\\"'.format(field.name)
                        else:
                            case += '(let arg)'
                            ret = '{'+self._dump_static_json(field, 'arg')+'}'
                        self.emit_line('case {}:'.format(case))
                        with self.indent():
                            if not is_symbol_type(field.data_type) and not is_any_type(field.data_type):
                                self._generate_serializer_for_field(field)
                            self.emit_line('return "{}"'.format(ret))

