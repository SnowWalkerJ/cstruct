include "../pxi/constants.pxi"
from typing import List
from cpython cimport array
import array
from ..constants cimport *
from ..types import uint


cdef class BytesWriter:
    def __cinit__(self):
        self.stack = []

    cpdef void write_int(self, IntType value):
        cdef bytes data = (<char*>(&value))[:SIZE_INT]
        self.stack.append(data)

    cpdef void write_uint(self, UIntType value):
        cdef bytes data = (<char*>(&value))[:SIZE_UINT]
        self.stack.append(data)

    cpdef void write_size_t(self, size_t value):
        cdef bytes data = (<char*>(&value))[:sizeof(size_t)]
        self.stack.append(data)

    cpdef void write_float(self, FloatType value):
        cdef bytes data = (<char*>(&value))[:SIZE_FLOAT]
        self.stack.append(data)

    cpdef void write_bytes(self, bytes value):
        cdef size_t size = len(value)
        self.write_size_t(size)
        self.stack.append(value)

    cpdef void write_str(self, str value):
        self.write_bytes(value.encode())

    cpdef void write_list_int(self, list value):
        cdef size_t size = len(value)
        self.write_size_t(size)
        cdef array.array arr = array.array(ARR_INT_FMT, value)
        cdef bytes data = arr.data.as_chars[:SIZE_INT * size]
        self.stack.append(data)

    cpdef void write_list_uint(self, list value):
        cdef size_t size = len(value)
        self.write_size_t(size)
        cdef array.array arr = array.array(ARR_UINT_FMT, value)
        cdef bytes data = arr.data.as_chars[:SIZE_UINT * size]
        self.stack.append(data)

    cpdef void write_list_float(self, list value):
        cdef size_t size = len(value)
        self.write_size_t(size)
        cdef array.array arr = array.array(ARR_FLOAT_FMT, value)
        cdef bytes data = arr.data.as_chars[:SIZE_FLOAT * size]
        self.stack.append(data)

    def write(self, object value, object type_):
        if type_ == int:
            self.write_int(value)
        elif type_ == float:
            self.write_float(value)
        elif type_ == uint:
            self.write_uint(value)
        elif type_ == str:
            self.write_str(value)
        elif type_ == bytes:
            self.write_bytes(value)
        elif type_ == List[int]:
            self.write_list_int(value)
        elif type_ == List[uint]:
            self.write_list_uint(value)
        elif type_ == List[float]:
            self.write_list_float(value)
        elif issubclass(type_, List):
            size = len(value)
            self.write_size_t(size)
            if not type_.__args__:
                raise TypeError("Must specify element type for list")
            item_type = type_.__args__[0]
            for item in value:
                self.write(item, item_type)
        elif hasattr(type_, "serialize"):    # Duck-type for issubcliass(type_, Serializable)
            self.stack.append(value.serialize())
        else:
            raise TypeError("Can only serialize primitives and Serializable objects")

    cpdef bytes build(self):
        return <bytes>(b"".join(self.stack))
