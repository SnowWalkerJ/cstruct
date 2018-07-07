include "constants.pxi"

IF USE_LONG == 1:
    ctypedef long IntType
    ctypedef unsigned long UIntType
ELSE:
    ctypedef int IntType
    ctypedef unsigned int UIntType

IF USE_DOUBLE == 1:
    ctypedef double FloatType
ELSE:
    ctypedef float FloatType