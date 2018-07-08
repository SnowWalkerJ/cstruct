from typing import List
import unittest
from cstruct import Serializable, SerializableAttribute as SA
from cstruct.types import uint


class A(Serializable):
    a = SA(int)
    b = SA(uint)
    c = SA(float)


class B(Serializable):
    a = SA(A)
    b = SA(str)
    c = SA(List[int])

class SerializerTestCase(unittest.TestCase):
    def test_serializable(self):
        input = A(a=1, b=2, c=1.1)
        buff = input.serialize()
        output = A.deserialize(buff)
        self.assertEqual(input.a, output.a)
        self.assertEqual(input.b, output.b)
        self.assertAlmostEqual(input.c, output.c)

    def test_recursive_serializable(self):
        inputA = A(a=1, b=2, c=1.1)
        inputB = B(a=inputA, b="cstruct", c=[0, 1, -1])
        buff = inputB.serialize()
        outputB = B.deserialize(buff)
        outputA = outputB.a
        self.assertEqual(inputA.a, outputA.a)
        self.assertEqual(inputA.b, outputA.b)
        self.assertAlmostEqual(inputA.c, outputA.c)
        self.assertEqual(inputB.b, outputB.b)
        self.assertListEqual(inputB.c, outputB.c)
