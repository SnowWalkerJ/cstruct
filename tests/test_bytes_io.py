import unittest
from cstruct.io.bytes_writer import BytesWriter
from cstruct.io.bytes_reader import BytesReader


class BytesIOTestCase(unittest.TestCase):
    def __run_test(self, method, data):
        writer = BytesWriter()
        for item in data:
            getattr(writer, "write_{}".format(method))(item)
        buff = writer.build()

        reader = BytesReader(buff)
        output = []
        while not reader.empty():
            output.append(getattr(reader, "read_{}".format(method))())
        self.assertListEqual(data, output)

    def __run_test_list(self, method, data):
        writer = BytesWriter()
        getattr(writer, "write_list_{}".format(method))(data)
        buff = writer.build()

        reader = BytesReader(buff)
        output = getattr(reader, "read_list_{}".format(method))()
        self.assertListEqual(data, output)

    def test_int(self):
        data = [0, 10, 999999999, -10, -999999999]
        self.__run_test("int", data)

    def test_uint(self):
        data = [0, 10, 999999999999]
        self.__run_test("uint", data)

    def test_float(self):
        data = [0.0, 10.999999, 999999999.123546860, -10.12873654, -999999999.18977465, 3.1415926535, -3.1415926535]
        self.__run_test("float", data)

    def test_str(self):
        data = ["", "whoami", "whoami"*1000, "我是谁"]
        self.__run_test("str", data)

    def test_list_int(self):
        data = [0, 10, 999999999, -10, -999999999]
        self.__run_test_list("int", data)

    def test_list_uint(self):
        data = [0, 10, 999999999999]
        self.__run_test_list("uint", data)

    def test_list_float(self):
        data = [0.0, 10.999999, 999999999.123546860, -10.12873654, -999999999.18977465, 3.1415926535, -3.1415926535]
        self.__run_test_list("float", data)
