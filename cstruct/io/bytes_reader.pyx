include "../pxi/constants.pxi"
from libc.stdlib cimport malloc, free
from libc.string cimport memcpy
from typing import List
from ..types import uint
from cpython cimport array
import array


cdef class BytesReader:
    def __cinit__(self, bytes buff):
        self.pos = 0
        self.length = len(buff)
        self.buff = malloc(self.length * sizeof(char))
        memcpy(self.buff, <char*>buff, self.length*sizeof(char))

    cdef bint empty(self):
        return self.pos >= self.length

    cdef void* _read(self, size_t size):
        cdef void* p = <char*>self.buff + self.pos
        self.pos += size
        return p

    cdef char read_char(self):
        return (<char*>self._read(sizeof(char)))[0]

    cdef long long read_int(self):
        cdef long long result = 0
        cdef char size = self.read_char()
        cdef char negative = size & 0b10000
        size &= 0b1111
        cdef char* begin = <char*>&result
        cdef void* p = self._read(size*sizeof(char))
        memcpy(begin, p, size)
        if negative:
            result = - result
        return result

    cdef unsigned long long read_uint(self):
        cdef unsigned long long result = 0
        cdef char size = self.read_char()
        cdef char* begin = <char*>&result
        cdef void* p = self._read(size*sizeof(char))
        memcpy(begin, p, size)
        return result

    cdef size_t read_size_t(self):
        return (<size_t*>self._read(sizeof(size_t)))[0]

    cdef FloatType read_float(self):
        return (<FloatType*>self._read(sizeof(FloatType)))[0]

    cdef str read_str(self):
        return self.read_bytes().decode()

    cdef bytes read_bytes(self):
        cdef size_t size = self.read_size_t()
        cdef bytes data = (<char*>self._read(size*sizeof(char)))[:size]
        return data

    cdef list read_list_int(self):
        cdef size_t size = self.read_size_t(), i
        cdef list result = []
        cdef long long value
        for i in range(size):
            value = self.read_int()
            result.append(value)
        return result

    cdef list read_list_uint(self):
        cdef size_t size = self.read_size_t(), i
        cdef list result = []
        cdef unsigned long long value
        for i in range(size):
            value = self.read_uint()
            result.append(value)
        return result

    cdef list read_list_float(self):
        cdef size_t size = self.read_size_t(), item_size = sizeof(FloatType)
        cdef void* ptr = self._read(size*item_size)
        cdef array.array arr = array.array(ARR_FLOAT_FMT, [])
        array.extend_buffer(arr, <char*>ptr, size)
        return arr.tolist()

    cpdef object read(self, object type_):
        if type_ is int:
            return self.read_int()
        elif type_ is float:
            return self.read_float()
        elif type_ is uint:
            return self.read_uint()
        elif type_ is str:
            return self.read_str()
        elif type_ is bytes:
            return self.read_bytes()
        elif type_ is List[int]:
            return self.read_list_int()
        elif type_ is List[uint]:
            return self.read_list_uint()
        elif type_ is List[float]:
            return self.read_list_float()
        elif issubclass(type_, List):
            size = self.read_size_t()
            if not type_.__args__:
                raise TypeError("Must specify element type for list")
            item_type = type_.__args__[0]
            output = []
            for i in range(size):
                value = self.read(item_type)
                output.append(value)
            return output
        elif hasattr(type_, "deserialize"):    # Duck-type for issubclass(type_, Serializable)
            return type_.deserialize(self)
        else:
            raise TypeError("Can only deserialize primitives and Serializable objects")

    def __dealloc__(self):
        free(self.buff)
