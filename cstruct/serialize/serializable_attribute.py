class SerializableAttribute:
    __slots__ = ['name', 'type_', 'readonly', 'serializer']

    def __init__(self, name, type_, readonly=False):
        self.name = name
        self.type_ = type_
        self.readonly = readonly

    def __get__(self, obj, objtype=None):
        if obj is None:
            return self
        return getattr(obj, "_{}".format(self.name))

    def __set__(self, obj, value):
        if self.readonly:
            raise TypeError("Attribute {} is read only".format(self.name))
        setattr(obj, "_{}".format(self.name), value)
