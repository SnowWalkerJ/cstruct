include "../pxi/types.pxi"


cdef class BytesWriter:
    cdef void* ptr
    cdef size_t p
    cdef int _write(self, void*, size_t) except -1
    cpdef void write_char(self, char)
    cpdef void write_int(self, IntType)
    cpdef void write_uint(self, UIntType)
    cpdef void write_size_t(self, size_t)
    cpdef void write_float(self, FloatType)
    cpdef void write_bytes(self, bytes)
    cpdef void write_str(self, str)
    cpdef void write_list_int(self, list)
    cpdef void write_list_uint(self, list)
    cpdef void write_list_float(self, list)
    cpdef bytes build(self)
