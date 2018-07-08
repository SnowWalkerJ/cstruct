include "../pxi/types.pxi"


cdef class BytesWriter:
    cdef char* ptr
    cdef size_t p
    cdef int _write(self, void*, size_t) nogil
    cdef void write_char(self, char)
    cdef void write_int(self, long long)
    cdef void write_uint(self, unsigned long long)
    cdef void write_size_t(self, size_t)
    cdef void write_float(self, FloatType)
    cdef void write_bytes(self, bytes)
    cdef void write_str(self, str)
    cdef void write_list_int(self, list)
    cdef void write_list_uint(self, list)
    cdef void write_list_float(self, list)
    cpdef bytes build(self)
