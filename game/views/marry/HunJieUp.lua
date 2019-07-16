--
-- Author: 
-- Date: 2018-08-13 14:49:44
--

local HunJieUp = class("HunJieUp",import("game.base.Ref"))

function HunJieUp:ctor(mParent)
    self.mParent = mParent
    self.view = self.mParent.view:GetChild("n14")
    self:initView()
end

function HunJieUp:initView()
    -- body
    self.name1 = self.view:GetChild("n47")
    self.iconjie1 = self.view:GetChild("n35")
    self.icon1 = self.view:GetChild("n94")

    self.name2 = self.view:GetChild("n50")
    self.iconjie2 = self.view:GetChild("n37")
    self.icon2 = self.view:GetChild("n95")

    self.icon3 = self.view:GetChild("n88")
    self.icon4 = self.view:GetChild("n92") 
    self.cupname1 = self.view:GetChild("n89") 
    self.cupname2 = self.view:GetChild("n93") 

    self.listpro = self.view:GetChild("n500")
    self.listpro.itemRenderer = function(index,obj)
        self:cellprodata(index, obj)
    end
    self.listpro.numItems = 0

    self.xing = self.view:GetChild("n51"):GetController("c1")
    self.itemObj = self.view:GetChild("n46")
    self.itemName = self.view:GetChild("n470")
    self.itemneed = self.view:GetChild("n48")
    self.btnPlus = self.view:GetChild("n49")
    self.btnPlus.onClick:Add(self.onBtnClickCallBack,self)

    self.btnjie = self.view:GetChild("n59")
    self.btnjie.title = language.hunjie01
    self.btnjie.onClick:Add(self.onBtnClickCallBack,self)

    self.backto = self.view:GetChild("n96")
    self.backto.onClick:Add(self.onBtnClickCallBack,self)
end


function HunJieUp:cellprodata(index, obj)
    -- body
    local data = self.protable[index+1]

    local dec = obj:GetChild("n0")
    local decvalue = obj:GetChild("n1")
    local more = obj:GetChild("n2")

    local key = data[1]
    local value = data[2]

    dec.text = conf.RedPointConf:getProName(key)
    decvalue.text = GProPrecnt(key,value)

    if self.nextcondata["att_"..key] then
        local var = self.nextcondata["att_"..key] - value
        if var > 0 then
            --isUp.visible = true
            more.text = "+"..GProPrecnt(key,var) --var
        else
            more.text = ""
        end
    else
        more.text = ""
    end
end

function HunJieUp:onBtnClickCallBack(context)
    -- body
    if not self.data then
        return
    end
    local btn = context.sender
    local data = btn.data 

    if btn.name == "n49" then
        local param = {}
        param.mId = data
        GGoBuyItem(param)
    elseif "n59" == btn.name then
        proxy.MarryProxy:sendMsg(1390202)
    elseif "n96" == btn.name then
        self.mParent:BackTo()
    end
end

function HunJieUp:setVisible(falg)
    -- body
    self.view.visible = falg
end

function HunJieUp:initleft(index)
    -- body
    if not index then
        index = 1
    elseif index < 1 then
        index = 1
    end
    local condata = conf.MarryConf:getRingItemByJie(index)
    self.name1.text = condata.name
    self.iconjie1.url  = UIItemRes.jieshu[index]
    --self.icon1.url = "ui://marry/"..condata.icon
    self.icon3.url = "ui://marry/"..condata.icon1
    --self.cupname1.text = cache.PlayerCache:getCoupleName()
    --self:setCoupName()
    self:setModel(condata.icon,self.icon1)
end

function HunJieUp:setCoupName()
    -- body
     local str = cache.PlayerCache:getCoupleName()
    if str == "" then
        str = language.hunjie02
    end
    if cache.PlayerCache:getSex() == 1 then
        str = str .. language.hunjie03
    else
        str = str .. language.hunjie04
    end
    self.cupname1.text = str
    self.cupname2.text = str
end

function HunJieUp:initright(index)
    -- body
    if not index then
        index = 1
    elseif index < 1 then
        index = 1
    end
    local condata = conf.MarryConf:getRingItemByJie(index)
    self.name2.text = condata.name
    self.iconjie2.url  = UIItemRes.jieshu[index]
    --self.icon2.url = "ui://marry/"..condata.icon
    self.icon4.url = "ui://marry/"..condata.icon1
    --self.cupname2.text = cache.PlayerCache:getCoupleName()
    --self:setCoupName()
    self:setModel(condata.icon,self.icon2)
end

function HunJieUp:setModel( id,panel )
    -- body
    if panel.data then
        self.mParent:removeUIEffect(self.effect)
        panel.data = nil 
    end

    panel.data = self.mParent:addEffect(id, panel)
    panel.data.Scale = Vector3.New(100,100,100)
    panel.data.LocalPosition = Vector3(180,-226,500)
end

function HunJieUp:addMsgCallBack(data)
    -- body
    if 5390201 == data.msgId then
        self.data = data 
    elseif 5390202 == data.msgId then  
        self.data.ringLev = data.ringLev
    end

    if self.view.visible then
        if not cache.MarryCache:getIsNext() then
            self.mParent:BackTo()
            return
        end
    else
        if not cache.MarryCache:getIsNext() then
            return
        end
    end
    self:setCoupName()
    self.max = conf.MarryConf:getValue("endjie") 
    self.condata = conf.MarryConf:getRingItem(self.data.ringLev)
    self.nextcondata = conf.MarryConf:getRingItem(self.data.ringLev+1)
    
    self:initleft(self.condata.step)
    self:initright(self.condata.step+1)

    self.protable = GConfDataSort(self.condata)
    self.listpro.numItems = #self.protable

    if self.condata.star == 0 then
        self.xing.selectedIndex = 0
    else
        if 5390201 == data.msgId then
            self.xing.selectedIndex = self.condata.star + 10
        else
            self.xing.selectedIndex = self.condata.star
        end
    end

    local t = {}
    t.mid = self.condata.item_cost[1]
    t.amount = 1
    t.isquan = true
    self.btnPlus.data = t.mid
    self.itemName.text = mgr.TextMgr:getColorNameByMid(t.mid)
    local packdata = cache.PackCache:getPackDataById(t.mid)
    local ss = ""
    if packdata.amount >= self.condata.item_cost[2] then
        ss = mgr.TextMgr:getTextColorStr(packdata.amount, 7)
        self.btnjie:GetChild("red").visible = true
    else
        ss = mgr.TextMgr:getTextColorStr(packdata.amount, 14)
        self.btnjie:GetChild("red").visible = false
    end
    ss = ss .. "/"..mgr.TextMgr:getTextColorStr(self.condata.item_cost[2], 7)
    self.itemneed.text = ss
    GSetItemData(self.itemObj, t,true)
end

return HunJieUp