--
-- Author: ohf
-- Date: 2017-01-13 11:38:17
--
--多文本管理
local TextMgr = class("TextMgr")

function TextMgr:ctor()
    
end
--道具名字
function TextMgr:getColorNameByMid(mId,amount)  
    -- print(conf.ItemConf:getName(mId))
    local name = self:getQualityStr1(conf.ItemConf:getName(mId),conf.ItemConf:getQuality(mId))
    if amount and amount > 1 then
        return name..self:getQualityStr1(amount,conf.ItemConf:getQuality(mId))
    else
        return self:getQualityStr1(conf.ItemConf:getName(mId),conf.ItemConf:getQuality(mId))
    end
end

--颜色文字 超链接格式clickHerf=&roleid&id&index&数量& 没有就等于"="
function TextMgr:getTextColorStr( str,color,clickHerf )
    if clickHerf then--是否有点击发送
        return "[color="..TextColors[color].."]".."<a href="..clickHerf..">"..str.."</a>".."[/color]"
    else
        if not str then
            print("TextMgr:getTextColorStr 使用错误",debug.traceback(""))
        end
        return "[color="..TextColors[color].."]"..tostring(str).."[/color]"
    end
end

--颜色文字 超链接格式clickHerf=&roleid&id&index&数量& 没有就等于"="
function TextMgr:getTextColorStrByRGB( str,color,clickHerf )


    if clickHerf then--是否有点击发送
        return "[color="..color.."]".."<a href="..clickHerf..">"..str.."</a>".."[/color]"
    else
        return "[color="..color.."]"..str.."[/color]"
    end
end

--品质颜色文字1
function TextMgr:getQualityStr1( str,color,clickHerf )
    if clickHerf then--是否有点击发送
        return "[color="..Quality1[color].."]".."<a href="..clickHerf..">"..str.."</a>".."[/color]"
    else
        return "[color="..Quality1[color].."]"..str.."[/color]"
    end
end

--品质颜色文字2
function TextMgr:getQualityStr2( str,color,clickHerf )
    if clickHerf then--是否有点击发送
        return "[color="..Quality2[color].."]".."<a href="..clickHerf..">"..str.."</a>".."[/color]"
    else
        return "[color="..Quality2[color].."]"..str.."[/color]"
    end
end
--品质颜色文字3(只为武炼符文品质色)
function TextMgr:getQualityStr3( str,color,clickHerf )
    if clickHerf then--是否有点击发送
        return "[color="..Quality3[color].."]".."<a href="..clickHerf..">"..str.."</a>".."[/color]"
    else
        return "[color="..Quality3[color].."]"..str.."[/color]"
    end
end
--极品属性颜色
function TextMgr:getQualityAtti( str,color,clickHerf )
    if clickHerf then--是否有点击发送
        return "[color="..QualityAtti[color].."]".."<a href="..clickHerf..">"..str.."</a>".."[/color]"
    else
        return "[color="..QualityAtti[color].."]"..str.."[/color]"
    end
end

--设置超链接跳转字
function TextMgr:getHerfStr(str,color,id)
    local s = "<a href='"..id..",1,1'>"..str.."</a>"
    return "[color="..TextColors[color].."]"..s.."[/color]"
end
--表情文字(1-24)
function TextMgr:getPhiz(id)
    local path = ResPath.phizRes(id) -- UIPackage.GetItemURL("_icons" , )
    if path then
        return "<img src="..path.." width='33' height='33'/>"
    else
        return "#"..id 
    end    
end

--图片
function TextMgr:getImg(url,width,height)
    -- body
    if not url or url == "" then
        return ""
    end

    local format = "<img src="..url
    if width  then
        format = format .. " width="..width
    end

    if height then
        format = format .. " height="..height
    end

    format = format .. " />"
    return format
end
--
function TextMgr:getTextByTable(param)
    -- body
    if not param then
        return ""
    elseif type(param)~="table" then
        return ""
    end
    local text = ""
    for k ,v in pairs(param) do 
        --plog(v.color,v.text)
        if v.text then
            if not v.color then
                text = text .. text
            else
                if v.quality then
                    text = text .. self:getQualityStr1(v.text,tonumber(v.quality))
                else
                    text = text .. self:getTextColorStr(v.text,tonumber(v.color))
                end
            end
        elseif v.url then
            text = text .. self:getImg(v.url,v.width,v.height)
            
        end
    end
    return text
end

--解析有道具的文字
function TextMgr:getProsText(strText,roleId)
    local proSymbol = ChatHerts.PROINFOHERT
    local list = {} 
    local str = ""
    local i = 0
    local t = {}
    while true do
        i = string.find(strText, proSymbol, i+1)
        if i == nil or #t >= 7 then break end
        table.insert(t, i)
    end
    -- printt("等级>>>>>>>>>>>",t)
    for k,v in pairs(t) do
        local t2 = t[k + 1]
        if t2 and t2 - v <= 1 then
            return strText
        end
    end
    if #t < 6 then
        return strText
    end
    if not t[2] or #t <= 0 then
        return strText
    end
    -- @612044000@200008@1@10110192@9822,1799@12@
    local id = string.sub(strText, t[1] + 1,t[2] - 1)
    local index = string.sub(strText, t[2] + 1,t[3] - 1)
    local amount = string.sub(strText, t[3] + 1,t[4] - 1)
    local sendMainSrvId = string.sub(strText, t[4] + 1,t[5] - 1)
    local colorStr = string.sub(strText, t[5] + 1,t[6] - 1)
    local level = string.sub(strText, t[6] + 1,t[7] - 1)
    -- print("当前等级>>>>",level)
    local name = conf.ItemConf:getName(id)
    local color = conf.ItemConf:getQuality(id)
    local roleId = roleId or cache.PlayerCache:getRoleId()
    if name and color then
        local herfText = "[<a href="..proSymbol..roleId..proSymbol..id..proSymbol..index..proSymbol..amount..proSymbol..sendMainSrvId..proSymbol..colorStr..proSymbol..level..proSymbol..">"..name.."</a>]"
        local colorText = "[color="..Quality1[color].."]"..herfText.."[/color]"

        local text = string.gsub(strText,string.sub(strText, t[1],t[7]),"")
        str = str..colorText..text--给道具文字赋予超链接
        return str
    else
        -- plog("给道具文字赋予超链接")
        return strText
    end
end

---逐个字拆
function TextMgr:splitStr(str,filterFormat)
    --return str
    local str_table = {}
    local str2 = str or ""
    for unchar in string.gfind(str2,"[%z\1-\127\194-\244][\128-\191]*") do   
        table.insert(str_table,unchar) 
        --newlen = newlen + 1
        --newstr = newstr .. unchar .. filterFormat
    end
    local newstr =""
    for k, v in pairs(str_table) do 
        newstr = newstr..v
        if k ~= #str_table then
            newstr = newstr..filterFormat
           
        end
    end
    return newstr
end

function TextMgr:getPetText(str)
    -- body
    local _rstr = ""
    local ss = string.split(str,"=")
    if #ss <= 1 then
        return str
    end

    if ss[1] == ChatHerts.PETHERTCHAT then --宠物信息
        --print(ss[2])
        local _t = string.split(ss[2],",")
        --printt(",....",_t[1])
        local confdata = conf.PetConf:getPetItem(_t[1])
        --printt("confdata",confdata)
        if confdata then
            _rstr = "[<a href="..str..">"..(_t[5] or "").."</a>]"
            _rstr = "[color="..Quality1[confdata.color or 1].."]".._rstr.."[/color]"
        end
    end
    --print(_rstr,"_rstr")
    return _rstr
end

return TextMgr