import pprint

# language by language regex for finding what functions have already been defined

from babelapi.lang.lang import TargetLanguage
from babelapi.data_type import (
    Boolean,
    Float32,
    Float64,
    Int32,
    Int64,
    List,
    String,
    Timestamp,
    UInt32,
    UInt64,
)

class SwiftTargetLanguage(TargetLanguage):

    _language_short_name = 'swift'

    def get_supported_extensions(self):
        return ('.swift', )

    _type_table = {
        Boolean: 'Bool',
        Float32: 'Float',
        Float64: 'Double',
        Int32: 'Int32',
        Int64: 'Int64',
        List: 'Array<Any>',
        String: 'String',
        Timestamp: 'NSDate',
        UInt32: 'Uint32',
        UInt64: 'UInt64',
    }

    def format_type(self, data_type):
        return SwiftTargetLanguage._type_table.get(data_type.__class__, self.format_class(data_type.name))

    # currently only used for representations of base types (bools, numbers, ...)
    def format_obj(self, o):
        assert not isinstance(o, dict), "Bad argument to format_obj: pprint's dict formatting is not valid Swift."

        if o is True:
            return 'true'
        if o is False:
            return 'false'
        return pprint.pformat(o, width=1)

    def _format_camelcase(self, name, lower_first=True):
        words = [word.capitalize() for word in self.split_words(name)]
        if lower_first:
            words[0] = words[0].lower()
        return ''.join(words)

    def format_variable(self, name):
        return self._format_camelcase(name)

    def format_class(self, name):
        return self._format_camelcase(name, lower_first=False)

    def format_method(self, name):
        return self._format_camelcase(name)
