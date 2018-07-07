import unittest
from cstruct import Serializable, SerializableAttribute as SA
from cstruct.types import uint


class A(Serializable):
    a = SA("a", int)
    b = SA("b", uint)
    c = SA("c", float)


class B(Serializable):
    a = SA("a", A)
    b = SA("b", str)

class SerializerTestCase(unittest.TestCase):
    def test_serializable(self):
        input = A(a=1, b=2, c=1.1)
        buff = input.serialize()
        output = A.deserialize(buff)
        self.assertEqual(input.a, output.a)
        self.assertEqual(input.b, output.b)
        self.assertEqual(input.c, output.c)

    def test_recursive_serializable(self):
        inputA = A(a=1, b=2, c=1.1)
        inputB = B(a=inputA, b="cstruct")
        buff = inputB.serialize()
        outputB = B.deserialize(buff)
        outputA = outputB.a
        self.assertEqual(inputA.a, outputA.a)
        self.assertEqual(inputA.b, outputA.b)
        self.assertEqual(inputA.c, outputA.c)
        self.assertEqual(inputB.b, outputB.b)
