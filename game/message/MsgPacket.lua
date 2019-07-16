local MsgPacket     = class("MsgPacket")
local MessageDef    = import(".MessageDef")
local ByteArray     = import(".ByteArray")

function MsgPacket:ctor()
  self.msgBuf = MsgPacket.cBA()
end

function MsgPacket.cBA()
  return ByteArray.new()
end

local function checkSum(val_len)
  return (val_len * 5) + 7
end

function MsgPacket.createPacket(msgId,data)
  local buf = MsgPacket.cBA()
  -- buf:writeInt8(0)                            --格式
  buf:writeInt32(msgId)                       --消息号
  buf:writeInt32(os.time()) 
  MessageDef[msgId]:create(data):encode(buf)  --写入数据
  buf:writeInt32(1)                           --验证位在C#
  return buf:getBuf()
end

function MsgPacket:testtt(msgId,data)
  return MessageDef[msgId]:create(data)
end



--用table.getn()或者#方法取不到长度时，请用此方法试试
local function tableSize(ttable)
  local size = 0
  if (ttable == nil or type(ttable) ~= "table") then
    return 0
  end
  for k, v in pairs(ttable) do
    size = size + 1
  end
  return size
end



function MsgPacket:splitPacket(byteString)
    if not byteString then
        print("byteString 为空")
        return 
    end
    self.msgBuf:setBuf(byteString)
    --消息变量
    local result = {}
    local mid = self.msgBuf:readInt32()            --消息号
    local ste = self.msgBuf:readInt32()            --状态码
    result = MessageDef[mid]:create():decode(self.msgBuf)--得到单条消息内容
    result.msgId  = mid --默认会霸占msgId跟status字段
    result.status = ste
    -- gfunc.log("接受数据成功>>>", result)
    --gfunc.log(result)
    return result
end


return MsgPacket