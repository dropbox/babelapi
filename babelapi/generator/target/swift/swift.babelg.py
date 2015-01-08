from babelapi.generator.generator import CodeGeneratorMonolingual

from babelapi.data_type import (
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


class SwiftGenerator(CodeGeneratorMonolingual):
    lang = SwiftTargetLanguage()

    def generate(self):
        for namespace in self.api.namespaces.values():
            with self.output_to_relative_path('{}.swift'.format(namespace.name)):
                self._generate_base_namespace_module(namespace)


    def _generate_base_namespace_module(self, namespace):
        #self.emit(base)

        for data_type in namespace.linearize_data_types():
            if is_struct_type(data_type):
                self._generate_struct_class(data_type)
            elif is_union_type(data_type):
                self._generate_union_type(data_type)
#            else:
#                raise TypeError('Cannot handle type %r' % type(data_type))
#        for route in namespace.routes:
#            self._generate_route_class(namespace, route)


    def _class_name_for_data_type(self, data_type):
        return self.lang.format_class(data_type.name)

    def _class_declaration_for_data_type(self, data_type):
        if data_type.super_type:
            extends = ': {}'.format(self._class_name_for_data_type(data_type.super_type))
        else:
            extends = ''
        name = self._class_name_for_data_type(data_type) + extends
        return 'public class {}'.format(name)

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

        self.emit_line('public init', trailing_newline=False)
        self._generate_func_arg_list(args, compact=True)
        with self.block(header=''):
            for field in data_type.fields:
                v = self.lang.format_variable(field.name)
                self.emit_line('self.{} = {}'.format(v, v))

            if data_type.super_type:
                self.emit_line('super.init', trailing_newline=False)
                self._generate_func_arg_list(['{}: {}'.format(self.lang.format_variable(f.name),
                                                              self.lang.format_variable(f.name))
                                              for f in data_type.super_type.fields])
                self.emit_empty_line()

    def _generate_struct_class(self, data_type):
        with self.block(self._class_declaration_for_data_type(data_type)):
            for field in data_type.fields:
                self.emit_line('public var {}'.format(self._var_from_field(field)))

            self._generate_struct_class_init_method(data_type)

    def _generate_union_type(self, data_type):
        with self.block('enum {}'.format(self._class_name_for_data_type(data_type))):
            for field in data_type.fields:
                if is_symbol_type(field.data_type):
                    typ = ''
                else:
                    typ = '({})'.format(self.lang.format_type(field.data_type))
                self.emit_line('case {}{}'.format(self.lang.format_class(field.name),
                                                  typ))

