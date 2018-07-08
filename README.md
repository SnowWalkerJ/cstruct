# cstruct

## Introduction

In language `C` you can directly write a struct into a binary file with:

```C
FILE* fp = fopen("data.bin", "wb");
write(fp, &data, sizeof(data));
fclose(fp);
```

In Python we can similarly achieve this with `pickle`. However, to support the dynamic feature of Python, `pickle` has to add overheads like the type of the data being pickled.

`cstruct` helps you fastly construct C-like struct types, whose instances can be encoded to and recovered from binary data.

## Installation

```bash
git clone git@github.com:SnowWalkerJ/cstruct.git
python setup.py install
```

## Usage

### Simple structures

```python
from cstruct import Serializable, SerializableAttribute as SA

class Struct(Serializable):
    # SerializableAttribute(name, type, readonly=False)
    a = SA(int)
    b = SA(float)
    c = SA(str)

# create an object
origin = Struct(a=1, b=-3.1415, c="hello, world")
# serialize into bytes
buff = origin.serialize()
# deserialize from bytes
recovered = Struct.deserialize(buff)
print(recovered.a, recovered.b, recovered.c)
```

### More complex types

```python
from typing import List
from cstruct import Serializable, SerializableAttribute as SA
from cstruct.types import uint

class ComplexOne(Serializable):
    # You can define composed types like List[int] or List[List[float]]
    a = SA(List[int])
    # Type can be a Serializable subclass
    b = SA(Struct)
    # uint type will be encoded as unsigned long
    c = SA(uint)
```

## How it works

We use Cython to turn the values into C-format and then into bytes with type conversion.

A typical example of turning int to bytes is like:

```cython
cpdef bytes encode_int(self, long value):
    cdef bytes data = (<char*>(&value))[:sizeof(long)]
    return data
```

Since the `Serializable` class keeps track of variable names and types, we don't have to keep these information in serialized data like `pickle` does.

## Where you do and do not want cstruct

### Where you do want cstruct

- your struct has static types
- your struct is relatively small
  - data buffer is 128K bytes at most
- space efficiency is more important than time efficiency

### Where you do not want cstruct

- dynamic types (as cstruct rely on type to handle data)
- large data, as data get larger, the disadvantage of overhead of pickle gets smaller
- large array, numpy is probably a better option
- sensitive to time efficiency (as shown in benchmark, it's awkwardly more then 2x slower than pickle)

## Which types can be serialized

- all primitive types(int, float, uint, str, bytes)
- `Serializable` subclass with serializable members
- if type `M` can be serialized, so can `List[M]`

## Benchmark

For details, see [benchmark.py](./benchmark.py)

### Time efficiency

|      | pickle | cstruct |
|:----:|:------:|:-------:|
|read  | 2.06 µs| 4.67 µs |
|write | 3.39 µs| 7.11 µs |

### Space efficiency

|        | pickle | cstruct |
|:------:|:------:|:-------:|
| case 1 | 110    | 41      |

