from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from .reader import file_byte_reader, decode_single_byte
from pathlib import Path


struct AudioSpec:
    var format_tag: Int
    var num_channels: Int
    var fs: Int
    var bytes_per_second: Int
    var block_align: Int
    var bit_depths: Int

    fn __init__(inout self, format_tag: Int, num_channels: Int, fs: Int, bytes_per_second: Int, block_align: Int, bit_depths: Int):
        self.format_tag = format_tag
        self.num_channels = num_channels
        self.fs = fs
        self.bytes_per_second = bytes_per_second
        self.block_align = block_align
        self.bit_depths = bit_depths

    fn __str__(self) -> String:
        return "Sample Rate: " + str(self.fs)


fn _read_fmt_chunk(inout file: file_byte_reader) raises -> AudioSpec:
    let size_of_fmt = file.read_number(4)
    var bytes_read = 0
    if size_of_fmt < 16:
        raise Error("Size of fmt chunk is not 16 bytes long.")
    
    let format_tag = file.read_number(2)
    let num_channels = file.read_number(2)
    let fs = file.read_number(4)
    let bytes_per_second = file.read_number(4)
    let block_align = file.read_number(2)
    let bit_depths = file.read_number(2)
    bytes_read += 16

    if format_tag != 1 and format_tag != 3:
        raise Error("This file is not PCM or IEEE float format. Only PCM, IEEE format is supported.")
    
    if size_of_fmt > bytes_read:
        file.read_none(size_of_fmt - bytes_read)
    return AudioSpec(format_tag, num_channels, fs, bytes_per_second, block_align, bit_depths)


fn _skip_unknown_chunk(inout file: file_byte_reader) raises:
    let chunk_size = file.read_number(4)
    file.read_none(chunk_size)


fn _read_data_chunk(inout file: file_byte_reader, audio_info:AudioSpec, is_big_endian:Bool) raises:
    let chunk_size = file.read_number(4)
    
    let fmt = ">" if is_big_endian else "<"

    let bytes_per_sample:Int = audio_info.block_align // audio_info.num_channels
    let n_samples:Int = chunk_size // bytes_per_sample
    if audio_info.format_tag == 1: # PCM
        if audio_info.bit_depths >= 1 and audio_info.bit_depths <=8:
            let dtype = "u1"
        elif bytes_per_sample == 3 or bytes_per_sample == 5 or bytes_per_sample == 6 or bytes_per_sample == 7:
            let dtype = "V1"
        elif audio_info.bit_depths <= 64:
            let dtype = str(fmt)+"i"+str(bytes_per_sample)
        else:
            raise Error("Unspported bit depths. the WAV file has "+ str(audio_info.bit_depths) + " bits per sample.")

    elif audio_info.format_tag == 3: # IEEE float
        if audio_info.bit_depths == 32 or audio_info.bit_depths == 64:
            let dtype = "f"+str(bytes_per_sample)
        else:
            raise Error("Unspported bit depths. the WAV file has "+ str(audio_info.bit_depths) + " bits per sample.")

    else:
        raise Error("This file is not PCM or IEEE float format. Only PCM, IEEE format is supported.")
    
    ## TODO: Make Audio to a Tensor
    # file.read_number(4) -> can be used to read a single sample

        


fn read_audio(path: String) raises:
    var file = file_byte_reader(path)

    let str1:String = file.read_text(4)
    if str1 != "RIFF" and str1 != "RIFX":
        raise Error("This file is not RIFF or RIFX format. It is not supported.")

    let is_big_endian:Bool = False if str1 == "RIFF" else True

    let filesize:Int = file.read_number(4) + 8
    let audio_format:String = file.read_text(4)

    var data_chunk_recieved = False
    var fmt_chunk_recieved = False
    var chunk_id:String = ""

    while file.current_index < filesize:
        chunk_id = file.read_text(4)
        if chunk_id != "fmt ":
            _skip_unknown_chunk(file)
        else:
            break
    
    if file.current_index >= filesize:
        raise Error("fmt chunk is not found.")

    fmt_chunk_recieved = True
    let audiospec = _read_fmt_chunk(file)
    print("format_tag: ", audiospec.format_tag)
    print("num_channels: ", audiospec.num_channels)
    print("fs: ", audiospec.fs)
    print("bytes_per_second: ", audiospec.bytes_per_second)
    print("block_align: ", audiospec.block_align)
    print("bit_depths: ", audiospec.bit_depths)

    while file.current_index < filesize:
        let chunk_id = file.read_text(4)
        if len(chunk_id) != 4:
            raise Error("Chunk ID must be 4 bytes long.")
        if chunk_id == "fact":
            _skip_unknown_chunk(file)
        elif chunk_id == "LIST":
            _skip_unknown_chunk(file)
        elif chunk_id == "JUNK":
            _skip_unknown_chunk(file)
        elif chunk_id == "Fake":
            _skip_unknown_chunk(file)
        elif chunk_id == "data":
            data_chunk_recieved = True
            # let audio = _read_data_chunk(file, audiospec)
            _read_data_chunk(file, audiospec, is_big_endian)
            break
        else:
            print("Unknown chunk ID: " + chunk_id+ ". Skipping chunk.")
            _skip_unknown_chunk(file)

        


    
    