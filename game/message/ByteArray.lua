local ByteArray = class("ByteArray")

function ByteArray:ctor()
    self.buf = ByteBuffer.New()
end

function ByteArray:getBuf()
    return self.buf
end
function ByteArray:setBuf(buf)
    if self.buf then
        self.buf = nil
    end
    self.buf = buf
end

function ByteArray:readDouble()
    return self.buf:ReadDouble()
end
function ByteArray:writeDouble(double)
    self.buf:WriteDouble(double)
end

--byte -128~127
function ByteArray:readInt8()
    return self.buf:ReadByte()
end
-- -128~127
function ByteArray:writeInt8(byte)
    self.buf:WriteByte(byte)
end


function ByteArray:readInt16()
    return self.buf:ReadShort()
end

function ByteArray:writeInt16(short)
    self.buf:WriteShort(short)
end

function ByteArray:readInt32()
    return self.buf:ReadInt()
end

function ByteArray:writeInt32(int)
    self.buf:WriteInt(int)
end


function ByteArray:readInt64()
    return tostring(self.buf:ReadInt64())
end

function ByteArray:writeInt64(v)
    self.buf:WriteInt64(int64.new(v))
end

function ByteArray:readString()
    return self.buf:ReadString()
end

function ByteArray:writeString(string)
    self.buf:WriteString(string)
end

function ByteArray:WriteLuaNumber(v) 
    self.buf:WriteInt64(v)
end

function ByteArray:readLuaNumber()
    return self.buf:ReadInt64()
end

return ByteArray