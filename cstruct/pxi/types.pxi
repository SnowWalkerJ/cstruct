include "constants.pxi"

IF USE_DOUBLE == 1:
    ctypedef double FloatType
ELSE:
    ctypedef float FloatType