from typing import List
from time import time
import random
import pickle
from cstruct.types import uint
from cstruct import Serializable, SerializableAttribute as SA

data = {
    "a": -42,
    "b": 123456789000,
    "c": 3.1415926535,
    "d": [1000000000000, 99999999999999, 0, 1]
}


class CStruct(Serializable):
    a = SA(int)
    b = SA(uint)
    c = SA(float)
    d = SA(List[uint])


class Struct:
    def __init__(self, a, b, c, d):
        self.a = a
        self.b = b
        self.c = c
        self.d = d


def timeit(func, times, args=(), kwargs={}):
    start = time()
    for _ in range(times):
        func(*args, **kwargs)
    end = time()
    return end - start


def dumps_with_cstruct():
    s = CStruct(**data)
    return timeit(s.serialize, times=1000)


def dumps_with_pickle():
    s = Struct(**data)
    return timeit(pickle.dumps, times=1000, args=(s, ))

data_cstruct = CStruct(**data).serialize()
def loads_with_cstruct():
    return timeit(CStruct.deserialize, times=1000, args=(data_cstruct, ))

data_pickle = pickle.dumps(Struct(**data))
def loads_with_pickle():
    return timeit(pickle.loads, times=1000, args=(data_pickle, ))


if __name__ == "__main__":
    print("dumps with cstruct:{:0.2f}µs".format(dumps_with_cstruct() * 1000))
    print("dumps with pickle:{:0.2f}µs".format(dumps_with_pickle() * 1000))

    print("loads with cstruct:{:0.2f}µs".format(loads_with_cstruct() * 1000))
    print("loads with pickle:{:0.2f}µs".format(loads_with_pickle() * 1000))

    print("cstruct space:", len(data_cstruct))
    print("pickle space:", len(data_pickle))
