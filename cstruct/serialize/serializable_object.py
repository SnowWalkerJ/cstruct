from operator import itemgetter
import warnings
from .serializable_attribute import SerializableAttribute
from ..io import BytesReader, BytesWriter


class SerializableMeta(type):
    def __new__(cls, name, parent, members):
        mappings = []
        for member, attribute in members.items():
            if isinstance(attribute, SerializableAttribute):
                mappings.append((member, attribute.type_))
        members['mappings'] = sorted(mappings)
        init_func = members.get('__init__')

        def init(self, *args, **kwargs):
            for key, _ in mappings:
                setattr(self, "_{}".format(key), kwargs.pop(key, None))
            if init_func:
                init_func(self, *args, **kwargs)

        members['__init__'] = init
        new_class = super(SerializableMeta, cls).__new__(cls, name, parent, members)
        return new_class


class Serializable(metaclass=SerializableMeta):
    def serialize(self) -> bytes:
        writer = BytesWriter()
        for name, type_ in self.mappings:
            value = getattr(self, name)
            writer.write(value, type_)
        return writer.build()

    @classmethod
    def deserialize(cls, buffer):
        if isinstance(buffer, bytes):
            buffer = BytesReader(buffer)
        elif isinstance(buffer, BytesReader):
            pass
        else:
            raise TypeError("Can only deserialize from bytes or cstruct.io.BytesReader")
        members = {}
        for name, type_ in cls.mappings:
            members[name] = buffer.read(type_)
        return cls(**members)

    def dump(self, filename):
        with open(filename, "wb") as f:
            f.write(self.serialize())

    @classmethod
    def load(cls, filename):
        with open(filename, "rb") as f:
            buf = f.read()
        return cls.deserialize(buf)
