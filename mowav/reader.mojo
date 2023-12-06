from .sign import Byte4Tensor, Byte2Tensor

alias si8 = DType.int8
alias ui8 = DType.uint8

struct file_byte_reader:
    var current_index: Int
    var file : FileHandle

    fn __init__(inout self, path:String) raises:
        self.file = open(path, "rb")
        self.current_index = 0

    fn read_text(inout self, num_bytes: Int) raises -> String:
        let bytes = self.file.read_bytes(num_bytes)
        self.current_index += num_bytes
        return Byte4Tensor(bytes).get_text()

    fn read_number(inout self, num_bytes: Int) raises -> Int:
        let bytes = self.file.read_bytes(num_bytes)
        self.current_index += num_bytes
        return Byte4Tensor(bytes).get_number()

    fn read_number2(inout self, num_bytes: Int) raises -> String:
        let bytes = self.file.read_bytes(num_bytes)
        self.current_index += num_bytes
        # print(Byte4Tensor(bytes)[3]/128*-1 + Byte4Tensor(bytes)[2]/(128*128) + Byte4Tensor(bytes)[1]/(128*128*128) + Byte4Tensor(bytes)[0]/(128*128*128*128) + 1)
        # print(Byte4Tensor(bytes)[3])
        # print(Byte4Tensor(bytes)[2])
        # print(Byte4Tensor(bytes)[1])
        # print(Byte4Tensor(bytes)[0])
        return Byte4Tensor(bytes).get_number()

    fn read_str(inout self, num_bytes: Int) raises -> String:
        let bytes = self.file.read_bytes(num_bytes)
        self.current_index += num_bytes
        return Byte4Tensor(bytes).__str__()
    
    fn read_none(inout self, num_bytes: Int) raises:
        let file = self.file.read_bytes(num_bytes)
        self.current_index += num_bytes
    
    fn read_byte_one(inout self) raises -> Int:
        let bytes = self.file.read_bytes(1)
        self.current_index += 1
        return decode_single_byte(bytes)

fn decode_single_byte(data: Tensor[si8]) -> Int:
    if data[0] >= 0:
        return int(data[0])
    else:
        return 256+int(data[0])