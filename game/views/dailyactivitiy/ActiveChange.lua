--
-- Author: 
-- Date: 2018-06-25 17:31:10
--超值兑换

local ActiveChange = class("ActiveChange",import("game.base.Ref"))

function ActiveChange:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId
    self:initPanel()
end

function ActiveChange:initPanel()
    local panelObj = self.mParent:getPanelObj(self.moduleId)
    local decTxt = panelObj:GetChild("n4")
    decTxt.text = language.dailyactive01
    
    self.lastTime = panelObj:GetChild("n5")
    local chargeBtn = panelObj:GetChild("n3")
    chargeBtn.onClick:Add(self.onCharge,self)

    self.listView = panelObj:GetChild("n6")
    self.listView.numItems = 0
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
   
end

function ActiveChange:setData(data)
    self.data = data
    printt("兑换~~~~",data)
    self.time = data and data.actLeftSec
    if self.moduleId  == 1236 then  
        self.typeData = conf.ActivityConf:getChangeTypeData(data.curId)
        local type = self.typeData.type
        self.confData = conf.ActivityConf:getChangeInfoByType(type)
    elseif self.moduleId == 1244 then 
        self.typeData = conf.ActivityConf:getChangeTypeData2(data.curId)
        local type2 = self.typeData.type
        self.confData = conf.ActivityConf:getChangeInfoByType2(type2)
    end
   
    self.listView.numItems = #self.confData
end

function ActiveChange:cellData(index,obj)
    local data = self.confData[index+1]
    if data then 
        local awardList = obj:GetChild("n13")
        GSetAwards(awardList, data.item)
        
        local title = obj:GetChild("n1")
        title.text = string.format(language.dailyactive05,language.dailyactive04[index+1])
        
        local oldPrice = obj:GetChild("n7")
        oldPrice.text = data.old_price

        local newprice = obj:GetChild("n8")
        newprice.text = data.exch_money[2]
        
        local exchtime = obj:GetChild("n11")
        local exchNum = self.data.exchInfos[data.id] or 0
        exchtime.text = exchNum.. "/"..data.exch_max
        local getBtn = obj:GetChild("n12")
        getBtn.data = data
        getBtn.onClick:Add(self.getAwards,self)
        if exchNum >= data.exch_max then 
            getBtn.grayed = true
        else
            getBtn.grayed = false
        end
        
    end
end

function ActiveChange:getAwards(context)
    local data = context.sender.data
    local exchNum = self.data.exchInfos[data.id] or 0
    if exchNum >= data.exch_max then 
        GComAlter(language.dailyactive07)
        return
    end
    if data.limit_con[1] == 0 then --不限制
        self:judgeYb(data)
    else
        local isXianZun = cache.PlayerCache:VipIsActivate(data.limit_con[2])
        if isXianZun then 
            self:judgeYb(data)
        else
            GComAlter(string.format(language.dailyactive06,language.dailyactive04[data.limit_con[2]+1]))
        end
    end
end

function ActiveChange:judgeYb(data)
    -- body
    local needYb = data.exch_money[2]
    local goldData = cache.PackCache:getPackDataById(PackMid.gold)
    if goldData.amount < needYb then 
        GComAlter(language.gonggong18)
        GGoVipTequan(0)
        self.mParent:onBtnClose()
    else
        if self.moduleId  == 1236 then  
            proxy.ActivityProxy:sendMsg(1030406,{reqType = 1,cfgId = data.id,num = 1})
        elseif self.moduleId == 1244 then 
            proxy.ActivityProxy:sendMsg(1030408,{reqType = 1,cfgId = data.id,num = 1})
        end
    end
end

function ActiveChange:onTimer()
    if self.time then 
        if tonumber(self.time) > 86400 then 
            self.lastTime.text = GTotimeString7(self.time)
        else
            self.lastTime.text = GTotimeString(self.time)
        end
        if self.time <= 0 then
            if self.moduleId  == 1236 then  
                proxy.ActivityProxy:sendMsg(1030406,{reqType = 0,cfgId = 0,num = 0})
            elseif self.moduleId == 1244 then 
                proxy.ActivityProxy:sendMsg(1030408,{reqType = 0,cfgId = 0,num = 0})
            end
            return
        end
        self.time = self.time - 1
    end
end

function ActiveChange:onCharge()
    GGoVipTequan(0)
end
return ActiveChange