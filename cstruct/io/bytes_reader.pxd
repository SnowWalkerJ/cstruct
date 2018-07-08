include "../pxi/types.pxi"


cdef class BytesReader:
    cdef void* buff
    cdef size_t pos
    cdef size_t length
    cdef bint empty(self)
    cdef void* _read(self, size_t)
    cdef char read_char(self)
    cdef long long read_int(self)
    cdef unsigned long long read_uint(self)
    cdef size_t read_size_t(self)
    cdef FloatType read_float(self)
    cdef str read_str(self)
    cdef bytes read_bytes(self)
    cdef list read_list_int(self)
    cdef list read_list_uint(self)
    cdef list read_list_float(self)
    cpdef object read(self, object)
