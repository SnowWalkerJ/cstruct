import pkgutil
from . import types
from .serialize import Serializable, SerializableAttribute
__version__ = pkgutil.get_data('cstruct', 'VERSION')
if not isinstance(__version__, str):
    __version__ = __version__.decode('utf8')
