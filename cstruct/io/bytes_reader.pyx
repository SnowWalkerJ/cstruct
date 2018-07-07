include "../pxi/constants.pxi"
from typing import List
from ..constants cimport *
from ..types import uint
from cpython cimport array
import array


cdef class BytesReader:
    def __cinit__(self, bytes buff):
        self.pos = 0
        self.buff = buff
        self.length = len(buff)

    cpdef bint empty(self):
        return self.pos >= self.length

    cpdef bytes _read(self, size_t size):
        cdef bytes data = self.buff[self.pos:self.pos+size]
        self.pos += size
        return data

    cpdef IntType read_int(self):
        cdef bytes data = self._read(SIZE_INT)
        cdef IntType * ptr = <IntType*><char*> data
        return ptr[0]

    cpdef UIntType read_uint(self):
        cdef bytes data = self._read(SIZE_UINT)
        cdef UIntType * ptr = <UIntType*><char*> data
        return ptr[0]

    cpdef size_t read_size_t(self):
        cdef bytes data = self._read(sizeof(size_t))
        cdef size_t * ptr = <size_t*><char*> data
        return ptr[0]

    cpdef FloatType read_float(self):
        cdef bytes data = self._read(SIZE_FLOAT)
        cdef FloatType * ptr = <FloatType*><char*> data
        return ptr[0]

    cpdef str read_str(self):
        return self.read_bytes().decode()

    cpdef bytes read_bytes(self):
        cdef size_t size = self.read_size_t()
        cdef bytes data = self._read(size)
        return data

    cpdef list read_list_int(self):
        cdef size_t size = self.read_size_t()
        cdef bytes data = self._read(size*SIZE_INT)
        cdef char* ptr = <char*>data
        cdef array.array arr = array.array(ARR_INT_FMT, [])
        array.extend_buffer(arr, ptr, size)
        return list(arr)

    cpdef list read_list_uint(self):
        cdef size_t size = self.read_size_t()
        cdef bytes data = self._read(size*SIZE_UINT)
        cdef char* ptr = <char*>data
        cdef array.array arr = array.array(ARR_UINT_FMT, [])
        array.extend_buffer(arr, ptr, size)
        return list(arr)

    cpdef list read_list_float(self):
        cdef size_t size = self.read_size_t()
        cdef bytes data = self._read(size*SIZE_FLOAT)
        cdef char* ptr = <char*>data
        cdef array.array arr = array.array(ARR_FLOAT_FMT, [])
        array.extend_buffer(arr, ptr, size)
        return list(arr)

    cpdef object read(self, object type_):
        if type_ == int:
            return self.read_int()
        elif type_ == float:
            return self.read_float()
        elif type_ == uint:
            return self.read_uint()
        elif type_ == str:
            return self.read_str()
        elif type_ == bytes:
            return self.read_bytes()
        elif type_ == List[int]:
            return self.read_list_int()
        elif type_ == List[uint]:
            return self.read_list_uint()
        elif type_ == List[float]:
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
        elif hasattr(type_, "deserialize"):    # Duck-type for issubcliass(type_, Serializable)
            return getattr(type_, "deserialize")(self)
        else:
            raise TypeError("Can only deserialize primitives and Serializable objects")
