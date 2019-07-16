--
-- Author: 
-- Date: 2018-07-17 15:38:50
--
local pairs = pairs
local dian = mgr.TextMgr:getImg(UIItemRes.dian01)
local JianLingSuitTips = class("JianLingSuitTips", base.BaseView)

function JianLingSuitTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function JianLingSuitTips:initView()

    self:setCloseBtn(self.view:GetChild("n4"):GetChild("n2"))

    self.listView = self.view:GetChild("n7")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function JianLingSuitTips:initData(data)
    -- body
    printt("套装",data)
    self.data = {}
    for k ,v in pairs(data.activeSuits) do
        self.data[v] = 1
    end
    
    local partdata = cache.PackCache:getJianLingquipData(Pack.JianLing)
    --计算套装件数
    self._t = {}
    for k,v in pairs(partdata) do
        local confdata = conf.ItemConf:getItem(v.mid)
        if not self._t[confdata.color] then
            self._t[confdata.color] = {}
        end
      
        table.insert(self._t[confdata.color],v)
    end

    self.confdata = conf.WuxingConf:getSuit()
    table.sort(self.confdata,function(a,b)
        -- body
        return a.id < b.id
    end)

    self.listView.numItems = #self.confdata
    self.listView.scrollPane:ScrollTop()
end

function JianLingSuitTips:getCount(color,star)
    -- body
    local count = 0
    for k ,v in pairs(self._t) do 
        if k >= color then
            for i , j in pairs(v) do
                if mgr.ItemMgr:getColorBNum(j) >= star then
                    count = count + 1
                end
            end
        end
    end
    return count
end

function JianLingSuitTips:celldata(index, obj)
    -- body
    local data = self.confdata[index + 1]

    local txt = obj:GetChild("n0")

    local color = tonumber(string.sub(tostring(data.id),2,3)) 
    local star = tonumber(string.sub(tostring(data.id),4,5))
    --print("color="..color,"star="..star)
    local str = string.format(language.awaken59,language.gonggong110[color],language.gonggong21[star] )
    --激活条件 是否激活
    if self.data[data.id] then
        str = str .. mgr.TextMgr:getTextColorStr(language.awaken60, 7)
    else
        str = str .. mgr.TextMgr:getTextColorStr(language.awaken61, 14)
    end
    str = str .. "\n"

    --当前
    str = str .. language.awaken62 .. "  "
    local count = self:getCount(color,star)
    if count >= data.equip_num then
        str = str .. mgr.TextMgr:getTextColorStr(count , 7)
    else
        str = str .. mgr.TextMgr:getTextColorStr(count , 14)
    end
    str = str .. mgr.TextMgr:getTextColorStr("/"..data.equip_num , 7)
    str = str .. "\n"

    --属性加成
    str = str .. language.awaken63
    str = str .. "\n"

    local t = GConfDataSort(data)
    local __str = ""
    local number = #t
    for k ,v in pairs(t) do
        local cc = conf.RedPointConf:getProName(v[1])..GProPrecnt(v[1],v[2])
        __str = __str .. "       " .. dian .."  ".. mgr.TextMgr:getTextColorStr(cc, 9)
        if k ~= number then
            __str = __str .. "\n"
        end
    end
    str = str .. __str .. "\n"

    txt.text = str
end

function JianLingSuitTips:setData(data_)

end

return JianLingSuitTips