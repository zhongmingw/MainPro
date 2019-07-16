--
-- Author: 
-- Date: 2018-12-10 14:37:31
--兑换

local ShengDan1005 = class("ShengDan1005",import("game.base.Ref"))

function ShengDan1005:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function ShengDan1005:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)
    self.timeTxt = panelObj:GetChild("n4")
    self.timeTxt.text = ""
    
    local decTxt = panelObj:GetChild("n5")
    decTxt.text = language.shengdan03

    self.listView = panelObj:GetChild("n6")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()


end

function ShengDan1005:setData(data)
    -- printt("兑换",data)
    self.data = data
    self.confData = conf.ShengDanConf:getExchageAward()
    self.listView.numItems = #self.confData
    self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)
end

function ShengDan1005:onTimer()

end


function ShengDan1005:cellData(index,obj )
    local data = self.confData[index+1]
    if data then
        local itemObj = obj:GetChild("n1")
        local itemName = obj:GetChild("n2")
        local numTxt = obj:GetChild("n5")
        local getCount = obj:GetChild("n8")
        local getBtn = obj:GetChild("n6")
        local c1 = getBtn:GetController("c1")
        local icon = obj:GetChild("n4")
        local src = conf.ItemConf:getSrc(data.cost[1][1])
        local iconUrl = ResPath.iconRes(tostring(src))
        icon.url = iconUrl
        local name = conf.ItemConf:getName(data.items[1][1])
        itemName.text = name

        local itemInfo = {mid = data.items[1][1],amount = data.items[1][2],bind = data.items[1][3]}
        GSetItemData(itemObj, itemInfo, true)

        local needMid = data.cost[1][1]
        local needAmount = data.cost[1][2]
        local hasAmount = cache.PackCache:getPackDataById(needMid).amount
        local color = hasAmount >= needAmount and 10 or 14
        local textData = {
            {text = hasAmount,color = color},
            {text = "/"..needAmount,color = 10},
        }
        numTxt.text = mgr.TextMgr:getTextByTable(textData)
        local hasTimes = self.data.canExchangeTimes[data.id]
        getCount.text = hasTimes.."次"

        local flag = false--是否可兑换
        if hasAmount >= needAmount and hasTimes > 0 then
            flag = true
        end

        if flag then
            c1.selectedIndex = 0
        else
            c1.selectedIndex = 1
        end

        getBtn.data = {cid = data.id,flag = flag}
        getBtn.onClick:Add(self.onClickGet,self)
    end
end

function ShengDan1005:onClickGet( context )
    local data = context.sender.data
    if data.flag then
        proxy.ShengDanProxy:sendMsg(1030673,{reqType = 1,cid = data.cid})
    else
        if self.data.canExchangeTimes[data.cid] > 0 then
            GComAlter(language.gonggong11)
        else
            GComAlter(language.dailyactive07)
        end
    end
end

return ShengDan1005