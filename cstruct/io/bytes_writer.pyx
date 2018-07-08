include "../pxi/constants.pxi"
from typing import List
from cpython cimport array
from libc.stdlib cimport malloc, free, memcpy
import array
from ..constants cimport *
from ..types import uint


cdef class BytesWriter:
    def __cinit__(self):
        self.ptr = malloc(MAX_BYTES)
        self.p = 0

    cdef int _write(self, void* addr, size_t size): except -1
        if self.p + size > MAX_BYTES:
            return -1
        memcpy(self.ptr + self.p, addr, size)
        self.p += size
        return 0
    
    cpdef void write_int(self, char value):
        cdef size_t item_size = sizeof(char)
        self._write(&value, item_size)

    cpdef void write_int(self, IntType value):
        cdef size_t item_size = sizeof(IntType)
        self._write &value, item_size)

    cpdef void write_uint(self, UIntType value):
        cdef size_t item_size = sizeof(UIntType)
        self._write(&value, item_size)

    cpdef void write_size_t(self, size_t value):
        cdef size_t item_size = sizeof(size_t)
        self._write(&value, item_size)

    cpdef void write_float(self, FloatType value):
        cdef size_t item_size = sizeof(FloatType)
        self._write(&value, item_size)

    cpdef void write_bytes(self, bytes value):
        cdef size_t size = len(value)
        self.write_size_t(size)
        cdef char* data = <char*> value
        self._write(&value, size * sizeof(char))

    cpdef void write_str(self, str value):
        self.write_bytes(value.encode())

    cpdef void write_list_int(self, list value):
        """
        one byte of flag (long or int) and four bytes (size_t) for length
        """
        cdef size_t size = len(value)
        self.write_size_t(size)
        cdef char flag
        cdef str fmt
        cdef size_t item_size
        if max(map(abs, value)) < (1 << (sizeof(int)*8-1)):
            flag = 0
            fmt = "i"
            item_size = sizeof(int)
        else:
            flag = 1
            fmt = "l"
            item_size = sizeof(long)
        self.write_char(flag)
        cdef array.array arr = array.array(fmt, value)
        self._write(arr.data.as_voidptr, size * item_size)

    cpdef void write_list_uint(self, list value):
        cdef size_t size = len(value)
        self.write_size_t(size)
        cdef char flag
        cdef str fmt
        cdef size_t item_size
        if max(value) < (1 << (sizeof(unsigned int)*8)):
            flag = 0
            fmt = "I"
            item_size = sizeof(unsigned int)
        else:
            flag = 1
            fmt = "L"
            item_size = sizeof(unsigned long)
        self.write_char(flag)
        cdef array.array arr = array.array(fmt, value)
        self._write(arr.data.as_voidptr, size * item_size)

    cpdef void write_list_float(self, list value):
        cdef size_t size = len(value)
        self.write_size_t(size)
        cdef array.array arr = array.array(ARR_FLOAT_FMT, value)
        cdef size_t item_size = sizeof(FloatType)
        self._write(arr.data.as_voidptr, size * item_size)

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
        cdef bytes data = (<char*>self.ptr)[:self.p]
        return data

    def __dealloc__(self):
        free(self.ptr)
