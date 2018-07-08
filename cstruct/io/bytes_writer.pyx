include "../pxi/constants.pxi"
from typing import List
from cpython cimport array, PyList_GET_SIZE, PyList_GET_ITEM
from libc.stdlib cimport malloc, free
from libc.string cimport memcpy
import array
from ..types import uint


cdef class BytesWriter:
    def __cinit__(self):
        self.ptr = <char*>malloc(MAX_BYTES)
        self.p = 0

    cdef int _write(self, void* addr, size_t size) nogil:
        if self.p + size > MAX_BYTES:
            return -1
        memcpy(self.ptr + self.p, <char*>addr, size)
        self.p += size
        return 0
    
    cdef void write_char(self, char value):
        cdef size_t item_size = sizeof(char)
        
        self.ptr[self.p] = value
        self.p += item_size
        # self._write(&value, item_size)

    cdef void write_int(self, long long value):
        cdef char size = sizeof(long long), i
        cdef char* begin = <char*>&value
        cdef char c
        cdef bint negative = value < 0
        if negative:
            value = -value
        for i in range(size):
            c = begin[size-i-1]
            if c:
                break
        size -= i
        if negative:
            size |= 0b10000
        self.write_char(size)
        self._write(begin, size & 0b1111)

    cdef void write_uint(self, unsigned long long value):
        cdef char size = sizeof(unsigned long long), i
        cdef char* begin = <char*>&value
        cdef char c
        for i in range(size):
            c = begin[size-i-1]
            if c:
                break
        self.write_char(<char>(size-i))
        self._write(begin, size-i)

    cdef void write_size_t(self, size_t value):
        cdef size_t item_size = sizeof(size_t)
        self._write(&value, item_size)

    cdef void write_float(self, FloatType value):
        cdef size_t item_size = sizeof(FloatType)
        self._write(&value, item_size)

    cdef void write_bytes(self, bytes value):
        cdef size_t size = len(value)
        self.write_size_t(size)
        cdef char* data = <char*> value
        self._write(data, size * sizeof(char))

    cdef void write_str(self, str value):
        self.write_bytes(value.encode())

    cdef void write_list_int(self, list value):
        """
        one byte of flag (long or int) and four bytes (size_t) for length
        """
        cdef size_t size = len(value)
        self.write_size_t(size)
        for item in value:
            self.write_int(item)

    cdef void write_list_uint(self, list value):
        cdef size_t size = len(value)
        self.write_size_t(size)
        for item in value:
            self.write_uint(item)

    cdef void write_list_float(self, list value):
        cdef size_t size = len(value)
        self.write_size_t(size)
        cdef array.array arr = array.array(ARR_FLOAT_FMT, value)
        cdef size_t item_size = sizeof(FloatType)
        self._write(arr.data.as_voidptr, size * item_size)

    def write(self, object value, object type_):
        if type_ is int:
            self.write_int(value)
        elif type_ is float:
            self.write_float(value)
        elif type_ is uint:
            self.write_uint(value)
        elif type_ is str:
            self.write_str(value)
        elif type_ is bytes:
            self.write_bytes(value)
        elif type_ is List[int]:
            self.write_list_int(value)
        elif type_ is List[uint]:
            self.write_list_uint(value)
        elif type_ is List[float]:
            self.write_list_float(value)
        elif issubclass(type_, List):
            if not type_.__args__:
                raise TypeError("Must specify element type for list")
            size = PyList_GET_SIZE(value)
            self.write_size_t(size)
            item_type = type_.__args__[0]
            for i in range(size):
                item = value[i]
                self.write(item, item_type)
        elif hasattr(type_, "serialize"):    # Duck-type for issubcliass(type_, Serializable)
            value.serialize(self)
        else:
            raise TypeError("Can only serialize primitives and Serializable objects")

    cpdef bytes build(self):
        cdef bytes data = self.ptr[:self.p]
        return data

    def __dealloc__(self):
        free(self.ptr)
