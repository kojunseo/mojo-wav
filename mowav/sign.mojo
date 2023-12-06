alias si8 = DType.int8
alias ui8 = DType.uint8
# 0 ~ 31 : non-printable mark
alias non_printable_mark = VariadicList("<NULL>", "<SOH>", "<STX>", "<ETX>", "<EOT>", "<ENQ>", "<ACK>", "<BEL>", "<BS>", "<HT>", "<LF>", "<VT>", "<FF>", "<CR>", "<SO>", "<SI>", "<DLE>", "<DC1>", "<DC2>", "<DC3>", "<DC4>", "<NAK>", "<SYN>", "<ETB>", "<CAN>", "<EM>", "<SUB>", "<ESC>", "<FS>", "<GS>", "<RS>", "<US>")
# 32 ~ 126 : printable mark
alias positive_printable_mark = VariadicList(" ", "!", '"', "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?", "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "<BS>", "]", "^", "_", "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~", "<DEL>")
# 127 ~ 255 : negative printable mark
alias negative_printable_mark = VariadicList("€", "<unused>", "‚", "ƒ", "„", "…", "†", "‡", "ˆ", "‰", "Š", "‹", "Œ", "<unused>", "Ž", "<unused>", "<unused>", "‘", "’", "“", "”", "•", "–", "—", "˜", "™", "š", "›", "œ", "<unused>", "ž", "Ÿ", "<unused>", "¡", "¢", "£", "¤", "¥", "¦", "§", "¨", "©", "ª", "«", "¬", "<unused>", "®", "¯", "°", "±", "²", "³", "´", "µ", "¶", "·", "¸", "¹", "º", "»", "¼", "½", "¾", "¿", "À", "Á", "Â", "Ã", "Ä", "Å", "Æ", "Ç", "È", "É", "Ê", "Ë", "Ì", "Í", "Î", "Ï", "Ð", "Ñ", "Ò", "Ó", "Ô", "Õ", "Ö", "×", "Ø", "Ù", "Ú", "Û", "Ü", "Ý")


fn construct_str2(id1:Int, id2: Int) -> String:
    var out: String = ""
    if id1 < 32:
        out += non_printable_mark[id1]
    elif id1 < 127:
        out += positive_printable_mark[id1 - 32]
    else:
        out += negative_printable_mark[id1 * -1]
    
    if id2 < 32:
        out += non_printable_mark[id2]
    elif id2 < 127:
        out += positive_printable_mark[id2 - 32]
    else:
        out += negative_printable_mark[id2 * -1]
    return out


fn construct_str4(id1:Int, id2: Int, id3: Int, id4: Int) -> String:
    var out: String = ""
    if id1 < 32:
        out += non_printable_mark[id1]
    elif id1 < 127:
        out += positive_printable_mark[id1 - 32]
    else:
        out += negative_printable_mark[id1 * -1]
    
    if id2 < 32:
        out += non_printable_mark[id2]
    elif id2 < 127:
        out += positive_printable_mark[id2 - 32]
    else:
        out += negative_printable_mark[id2 * -1]
    
    if id3 < 32:
        out += non_printable_mark[id3]
    elif id3 < 127:
        out += positive_printable_mark[id3 - 32]
    else:
        out += negative_printable_mark[id3 * -1]
    
    if id4 < 32:
        out += non_printable_mark[id4]
    elif id4 < 127:
        out += positive_printable_mark[id4 - 32]
    else:
        out += negative_printable_mark[id4 * -1]
    return out

struct Byte4Tensor:
    var id1: Int
    var id2: Int
    var id3: Int
    var id4: Int
    var data_to_string: String
    var data_to_number: Int
    var flag: Bool
        
    fn __init__(inout self, data:Tensor[si8]):
        self.flag = False
        if data[0] >= 0:
            self.id1 = int(data[0])
        else:
            self.flag = True
            self.id1 = 256+int(data[0])
        
        if data[1] >= 0:
            self.id2 = int(data[1])
        else:
            self.flag = True
            self.id2 = 256+int(data[1])
        
        if data[2] >= 0:
            self.id3 = int(data[2])
        else:
            self.flag = True
            self.id3 = 256+int(data[2])
        
        if data[3] >= 0:
            self.id4 = int(data[3])
        else:
            self.flag = True
            self.id4 = 256+int(data[3])
        
        if self.flag:
            self.data_to_string = "Not a Character"
            self.data_to_number = 16777216* self.id4 + 65536 * self.id3 + 256 * self.id2 + self.id1
        else:
            self.data_to_string = construct_str4(self.id1, self.id2, self.id3, self.id4)
            self.data_to_number = 16777216* self.id4 + 65536 * self.id3 + 256 * self.id2 + self.id1


    fn __getitem__(self, index: Int) raises -> Int:
        if index == 0:
            return self.id1
        elif index == 1:
            return self.id2
        elif index == 2:
            return self.id3
        elif index == 3:
            return self.id4
        else:
            raise Error("Index out of range")
    

    fn __setitem__(inout self, index: Int, value: Int) raises:
        if index == 0:
            self.id1 = value
        elif index == 1:
            self.id2 = value
        elif index == 2:
            self.id3 = value
        elif index == 3:
            self.id4 = value
        else:
            raise Error("Index out of range")
    
    fn __str__(self) -> String:
        return "B4T[" + str(self.id1) + ", " + str(self.id2) + ", " + str(self.id3) + ", " + str(self.id4) + "]"

    fn get_text(self) -> String:
        return self.data_to_string
    
    fn get_number(self) -> Int:
        return self.data_to_number
    
    # fn get_number2(self) -> Int:
    #     let id1: Int = self.id1 if self.id1 >= 128 else self.id1 - 256
    #     let id2: Int = self.id2 if self.id2 >= 128 else self.id2 - 256
    #     let id3: Int = self.id3 if self.id3 >= 128 else self.id3 - 256
    #     let id4: Int = self.id4 if self.id4 >= 128 else self.id4 - 256
    #     print(id1, id2, id3, id4)
    #     return 16777216* id4 + 65536 * id3 + 256 * id2 + id1
        # return


struct Byte2Tensor:
    var id1: Int
    var id2: Int
    var data_to_string: String
    var data_to_number: Int
    var flag: Bool

    fn __init__(inout self, data:Tensor[si8]):
        self.flag = False
        if data[0] >= 0:
            self.id1 = int(data[0])
        else:
            self.flag = True
            self.id1 = 256+int(data[0])
        
        if data[1] >= 0:
            self.id2 = int(data[1])
        else:
            self.flag = True
            self.id2 = 256+int(data[1])

        if self.flag:
            self.data_to_string = "Not a Character"
            self.data_to_number = 256 * self.id2 + self.id1
        else:
            self.data_to_string = construct_str2(self.id1, self.id2)
            self.data_to_number = 256 * self.id2 + self.id1
    
    fn __getitem__(self, index: Int) raises -> Int:
        if index == 0:
            return self.id1
        elif index == 1:
            return self.id2
        else:
            raise Error("Index out of range")
    
    fn get_text(self) -> String:
        return self.data_to_string
    
    fn get_number(self) -> Int:
        return self.data_to_number

    fn __setitem__(inout self, index: Int, value: Int) raises:
        if index == 0:
            self.id1 = value
        elif index == 1:
            self.id2 = value
        else:
            raise Error("Index out of range")

    fn __str__(self) -> String:
        return "B2T<[" + str(self.id1) + ", " + str(self.id2) + "]>"

