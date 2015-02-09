import pprint

# This file defines *stylistic* choices for Swift
# (ie, that class names are UpperCamelCase and that variables are lowerCamelCase)

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

    is_list_type,
)

class SwiftTargetLanguage(TargetLanguage):

    _language_short_name = 'swift'

    def get_supported_extensions(self):
        return ('.swift', )

    def format_obj(self, o):
        assert not isinstance(o, dict), "Only use for base type literals"
        if o is True:
            return 'true'
        if o is False:
            return 'false'
        if o is None:
            return 'nil'
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
