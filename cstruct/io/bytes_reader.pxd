include "../pxi/types.pxi"


cdef class BytesReader:
    cdef bytes buff
    cdef size_t pos
    cdef size_t length
    cpdef bint empty(self)
    cpdef bytes _read(self, size_t size)
    cpdef IntType read_int(self)
    cpdef UIntType read_uint(self)
    cpdef size_t read_size_t(self)
    cpdef FloatType read_float(self)
    cpdef str read_str(self)
    cpdef bytes read_bytes(self)
    cpdef list read_list_int(self)
    cpdef list read_list_uint(self)
    cpdef list read_list_float(self)
    cpdef object read(self, object)
