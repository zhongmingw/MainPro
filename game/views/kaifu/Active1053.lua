--
-- Author: Your Name
-- Date: 2017-11-16 18:57:56
--
--集字活动
local Active1053 = class("Active1053",import("game.base.Ref"))

function Active1053:ctor(param)
    self.view = param
    self:initView()
end

function Active1053:initView()
    self.listView = self.view:GetChild("n3")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.leftTimeTxt = self.view:GetChild("n4")
    self.actDecTxt = self.view:GetChild("n2")
    local textData = {
            {text = language.kaifu68[1],color = 12},
            {text = language.kaifu68[2],color = 9},
    }
    self.actDecTxt.text = mgr.TextMgr:getTextByTable(textData)
end
--cache.PackCache:getPackDataById(id,isCount,isBind)
function Active1053:celldata( index,obj )
    local data = self.confData[index + 1]
    for i=6,16 do
        obj:GetChild("n"..i).visible = false
    end
    if data then
        --花费
        for i=1,#data.cost do
            obj:GetChild("n"..(5+i)).visible = true
            local mId = data.cost[i][1]
            local itemData = cache.PackCache:getPackDataById(mId,true,true)
            -- printt("道具数量",itemData)
            itemData.index = 0
            GSetItemData(obj:GetChild("n"..(5+i)), itemData, true)
        end
        --加号
        if #data.cost-1 > 0 then
            for i=1,#data.cost-1 do
                obj:GetChild("n"..(11+i)).visible = true
                obj:GetChild("n"..(11+i)).url = UIPackage.GetItemURL("kaifu" , "jizihuodong006")
            end
        end
        --等于号
        obj:GetChild("n"..(11 + #data.cost)).visible = true
        obj:GetChild("n"..(11 + #data.cost)).url = UIPackage.GetItemURL("kaifu" , "jizihuodong007")
        --奖励
        for i=#data.cost+1,#data.cost+#data.awards do
            -- print("奖励",#data.awards + #data.cost - i)
            obj:GetChild("n"..(5+i)).visible = true
            local mId = data.awards[#data.awards + #data.cost - i + 1][1]
            local amount = data.awards[#data.awards + #data.cost - i + 1][2]
            local itemData = {mid = mId,amount = amount,bind = 1}
            GSetItemData(obj:GetChild("n"..(5+i)), itemData, true)
        end
        local maxCount = data.max_count
        if maxCount then
            obj:GetChild("n19").text = mgr.TextMgr:getTextColorStr(language.kaifu67,9) .. mgr.TextMgr:getTextColorStr(self.data.leftCountMap[data.id],14)
        else
            obj:GetChild("n19").text = mgr.TextMgr:getTextColorStr(language.kaifu67,9) .. mgr.TextMgr:getTextColorStr(language.wangcai09,7)
        end
        local getBtn = obj:GetChild("n18")
        getBtn.data = data
        getBtn.onClick:Add(self.onClickGet,self)
        --按钮红点
        local flag = true
        if not self.data.leftCountMap[data.id] then
            flag = true
        else
            if self.data.leftCountMap[data.id] > 0 then
                flag = true
            else
                flag = false
            end
        end
        for k,v in pairs(data.cost) do
            local itemData = cache.PackCache:getPackDataById(v[1],true,true)
            if itemData.amount < v[2] then
                flag = false
                break
            end
        end
        -- print("是否可兑换",flag,data.id,self.data.leftCountMap[data.id])
        if flag then
            getBtn:GetChild("red").visible = true
        else
            getBtn:GetChild("red").visible = false
        end
    end
end

function Active1053:onClickGet( context )
    local data = context.sender.data
    local cfgId = data.id
    local flag = true
    if not self.data.leftCountMap[cfgId] then
        flag = true
    else
        if self.data.leftCountMap[cfgId] > 0 then
            flag = true
        else
            flag = false
        end
    end
    for k,v in pairs(data.cost) do
        local itemData = cache.PackCache:getPackDataById(v[1],true,true)
        if itemData.amount < v[2] then
            flag = false
            break
        end
    end
    if flag then
        proxy.ActivityProxy:sendMsg(1030151,{reqType = 2,cfgId = cfgId})
    else
        if self.data.leftCountMap[cfgId] and self.data.leftCountMap[cfgId] > 0 then
            GComAlter(language.kaifu72)
        else
            GComAlter(language.kaifu71)
        end
    end
end

function Active1053:onTimer()
    -- body
    if self.data then
        if self.lastTime > 0 then
            self.lastTime = self.lastTime - 1
            self.leftTimeTxt.text = GGetTimeData2(self.lastTime)
        end
    end
end

function Active1053:add5030151(data)
    self.data = data
    self.lastTime = data.lastTime
    self.leftTimeTxt.text = GGetTimeData2(self.lastTime)
    self.confData = conf.ActivityConf:getWoedCollectionData()
    self.listView.numItems = #self.confData
end 

return Active1053