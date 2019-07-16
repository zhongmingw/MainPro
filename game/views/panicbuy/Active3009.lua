--
-- Author: 
-- Date: 2017-08-01 11:07:56
--

local Active3009 = class("Active3009",import("game.base.Ref"))
--获取配置
local opent = {
    1006,1007,1008,1009,1010
}
--技能最大等级
local maxlv = 9
function Active3009:ctor(mParent,panelObj)
    self.mParent = mParent
    self.panelObj = panelObj
    self:initPanel()
end

function Active3009:initPanel()
    -- body
    local btnCz = self.panelObj:GetChild("n4")
    btnCz.title = language.thqg06
    btnCz.onClick:Add(self.onClickCz,self)

    local dec1 = self.panelObj:GetChild("n5")
    dec1.text = language.thqg07

    self.labtimer = self.panelObj:GetChild("n7")
    self.labtimer.text = ""

    local dec2 = self.panelObj:GetChild("n6")
    dec2.text = language.thqg08

    self.money = self.panelObj:GetChild("title1")
    self.money.text = ""

    self.btnlist = {}
    for i = 10,14 do
        local btn = self.panelObj:GetChild("n"..i)
        btn.data = i - 9
        btn.title = language.thqg10[btn.data]
        btn.onClick:Add(self.onSelect,self)
        table.insert(self.btnlist,btn)
    end

    self.listView = self.panelObj:GetChild("n9")
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0

    self.c1 = self.panelObj:GetController("c1")
end

function Active3009:onTimer()
    -- body
    if not self.data then
        return
    end  

    self.data.lastTime = self.data.lastTime - 1 
    if self.data.lastTime <= 0 then
        self.labtimer.text = language.thqg16
        return
    end

    self.labtimer.text = GGetTimeData2(self.data.lastTime) 
end


function Active3009:celldata(index, obj)
    -- body
    local data = self.confData[index+1]
    local dec1 = obj:GetChild("n2")
    dec1.text = language.thqg11
    local dec1 = obj:GetChild("n3")
    dec1.text = language.thqg12
    local dec1 = obj:GetChild("n4")
    dec1.text = language.thqg13
    local dec1 = obj:GetChild("n13")
    dec1.text = language.thqg14

    local c1 = obj:GetController("c1")
    local itemObj = obj:GetChild("n1")
    local oldprice = obj:GetChild("n9")
    local nowprice = obj:GetChild("n11")
    local labcout = obj:GetChild("n5")

    local btnbuy = obj:GetChild("n12")
    btnbuy.data = data
    btnbuy.onClick:Add(self.onBtnBuy,self)

    local _pack = cache.PackCache:getPackDataById(data.buy_item[1])
    if self.need[data.buy_item[1]] and self.need[data.buy_item[1]] > _pack.amount then
        c1.selectedIndex = 9
    else
        c1.selectedIndex = data.ze - 1
    end

    local t = {mid = data.buy_item[1],amount = data.buy_item[2],bind = data.buy_item[3] }
    GSetItemData(itemObj,t,true)

    oldprice.text = data.old_price
    nowprice.text = data.price


    local var = data.limit_count
    if self.data.buyList[data.id] then
        var = var - self.data.buyList[data.id]
    end
    labcout.text = var
end

function Active3009:onSelect(context)
    -- body
    local data = context.sender.data
    self:sendMsg(data) 
end

function Active3009:onBtnBuy(context)
    -- body
    if not self.data then
        return
    end
    -- if not self.canBuy then
    --     GComAlter(language.thqg17)
    --     return
    -- end

    local data = context.sender.data
    local var = data.limit_count
    if self.data.buyList[data.id] then
        var = var - self.data.buyList[data.id]
    end
    if var <= 0 then
        GComAlter(language.thqg15)
        return
    end
    if self.data.lastTime <= 0 then
        GComAlter(language.thqg16)
        return
    end
    local param = {}
    param.reqType = 1
    param.itemId = data.id
    param.moduleId = self.data.moduleId
    proxy.ActivityProxy:sendMsg(1030143,param)
end

function Active3009:onClickCz()
    -- body
    GOpenView({id = 1042})
end

function Active3009:setVisible(flag)
    -- body
    self.panelObj.visible = flag

    for k ,v in pairs(opent) do
        local btn = self.btnlist[k] 
        btn.enabled = mgr.ModuleMgr:CheckView(v)
    end
end

function Active3009:sendMsg(id)
    -- body
    local param = {}
    param.reqType = 0
    param.itemId = 0
    if not id or not opent[id]  then
        param.moduleId = opent[1]
        if self.btnlist[1].enabled then 
            self.c1.selectedIndex = 1
        end
    else
        param.moduleId = opent[id]
    end
    proxy.ActivityProxy:sendMsg(1030143,param)


end

function Active3009:findNeed()
    -- body
    local t = {[1006] = 0,[1007] = 1,[1008] = 2,[1009] = 4 , [1010] = 3}
    local index = t[self.data.moduleId]
    local condata 
    if index ~= 0 then
        condata = conf.HuobanConf:getLeftData(index)
    else
        condata = conf.HuobanConf:getHuobanSkill()
    end

    self.need = {}
    --plog(index,index)
    --printt("condata",condata)
    for k ,v in pairs(condata) do
        local skillLv = self.data.skillMap[v.id] or 0
        for i = skillLv , maxlv do
            local data = conf.HuobanConf:getSkillLevData(v.id,i,index)
            if data and data.cost_items then
                self.need[data.cost_items[1][1]] = data.cost_items[1][2]
            end
        end
    end
end

function Active3009:add5030142( data )
    -- body
    self.data = data
    self.money.text = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if data.reqType == 0 then
        --获取对应配置
        self.confData = conf.ActivityConf:getPartnerSkillSale(data.moduleId)
        --检索需要的道具
        self:findNeed()
        --
        --是否可购买
        -- if mgr.ModuleMgr:CheckView(data.moduleId) then
        --     self.canBuy = true
        -- else
        --     self.canBuy = false
        -- end
        self.listView.numItems = #self.confData 
        if self.listView.numItems > 0 then
            self.listView:ScrollToView(0,false)
        end
    else
        self.listView:RefreshVirtualList()
        GOpenAlert3(data.items)
    end
end



return Active3009