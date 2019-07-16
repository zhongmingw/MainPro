--
-- Author: 
-- Date: 2018-07-23 16:51:13
--

local PetOpenPos = class("PetOpenPos", base.BaseView)

function PetOpenPos:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function PetOpenPos:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    self.dec1 = self.view:GetChild("n3")
    self.dec1.text = ""

    local dec1 = self.view:GetChild("n4") 
    dec1.text = language.pet52

    local btnplus = self.view:GetChild("n7")
    btnplus.onClick:Add(self.onPlus,self)

    self.icon = self.view:GetChild("n11")
    self.costlab = self.view:GetChild("n10")

    local btnSure = self.view:GetChild("n2")
    btnSure.onClick:Add(self.onSure,self)

    local btnSure = self.view:GetChild("n1")
    btnSure.onClick:Add(self.onCancel,self)

    self.dec2 = self.view:GetChild("n12")
end

function PetOpenPos:initData(data)
    self.data = data 
    
    self.opencount = 3
    local number = 0
    for k ,v in pairs(self.data.opencount) do
        number = number + 1
        if conf.PetConf:getOpenCost(k%1000).cost then
            self.opencount = self.opencount + 1
        end
    end
    self.condata = conf.PetConf:getOpenCost(self.opencount+1)

    --当前开启的助阵位置所需要的宠物信息
    local condata = conf.PetConf:getPetPosCondi(1000+self.data.pos)
    local quality = language.gonggong110[condata.need_color]
    local textData = clone(language.pet69)
    textData[2].text = string.format(textData[2].text,quality,condata.need_lev)
    self.dec2.text = mgr.TextMgr:getTextByTable(textData)
    --print("self.data.opencount+1"..self.data.opencount+1)

    local mid = self.condata.cost[1][1]
    local src = conf.ItemConf:getSrc(mid)
    local iconUrl = ResPath.iconRes(tostring(src))
    self.icon.url = iconUrl

    local str = ""
    local packdata = cache.PackCache:getPackDataById(mid)
    if self.condata.cost[1][2] > packdata.amount then
        str = str .. mgr.TextMgr:getTextColorStr(packdata.amount, 14)
    else
        str = str .. packdata.amount
    end
    str = str.."/"..self.condata.cost[1][2]
    self.costlab.text = str

    self.dec1.text = language.pet53 .. mgr.TextMgr:getTextColorStr(number, 14).."/" .. mgr.TextMgr:getTextColorStr(8, 7)
end

function PetOpenPos:onPlus()
    -- body
    if not self.data then
        return
    end
    local t = {
        mid =  self.condata.cost[1][1]
    }
    GSeeLocalItem(t)
end

function PetOpenPos:onSure()
    -- body
    if not self.data then
        return
    end

    local param = {}
    param.pos = 1000 + self.data.pos

    proxy.PetProxy:sendMsg(1490202,param)
    self:closeView()
end

function PetOpenPos:onCancel()
    -- body
    self:closeView()
end

return PetOpenPos