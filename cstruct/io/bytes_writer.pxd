include "../pxi/types.pxi"


cdef class BytesWriter:
    cdef list stack
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
