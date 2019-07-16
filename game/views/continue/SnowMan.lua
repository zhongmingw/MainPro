--
-- Author: 
-- Date: 2018-10-29 17:23:55
--

local SnowMan = class("SnowMan", base.BaseView)

function SnowMan:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale 
end

function SnowMan:initView()
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.actCountDownText = self.view:GetChild("n7")
    self.oneCostText = self.view:GetChild("n17")
    self.getAllBtn = self.view:GetChild("n13")
    self.getAllBtn.onClick:Add(self.btnOnClick,self)

    self.awardList = self.view:GetChild("n8")
    self.awardList.itemRenderer = function (index,obj) 
        self:setAwardData(index,obj)
    end
    self.awardList.numItems = 0
    self.awardList:SetVirtual()

    self.recordList = self.view:GetChild("n18")
    self.recordList.itemRenderer = function (index,obj) 
        self:setRecordData(index,obj)
    end
    self.recordList.numItems = 0
    self.recordList:SetVirtual()

    self.snowManList = {}
    for i = 20,27 do
        local snowMan = self.view:GetChild("n"..i)
        snowMan.data = i - 19
        table.insert(self.snowManList,snowMan)
        snowMan.onClick:Add(self.snowManClick,self)
    end    
end

--[[
变量名：reqType 说明：0：显示 1：抽一次 2：抽完
变量名：site    说明：位置（1-8）
变量名：items   说明：获得的奖励
变量名：leftTime    说明：活动剩余时间
变量名：siteDataId  说明：已经抽取的位置对应获得的奖励id
变量名：logs    说明：日志记录
--]]
function SnowMan:setData(data)
    self.data = data
    GOpenAlert3(data.items)
    -- printt("日志记录>>>",data.logs)
    -- print(data.site)
    -- printt("获得的奖励id>>>",data.dataIds)
    self.actCountDown = data.leftTime
    self.confData = conf.ActivityConf:getSnowManAward()
    self.allConfData = conf.ActivityConf:getAllSnowManAward()
    -- printt(self.allConfData)
    self.oneCostConf = conf.ActivityConf:getValue("snowman_cost") -- 寻找一次消耗
    self.oneCostText.text = self.oneCostConf[2]
    self.awardList.numItems = #self.confData
    self.recordList.numItems = #data.logs

    if #data.siteDataId == 0 then
        for k,v in pairs(self.snowManList) do
            -- 雪人状态复原
            v:GetChild("icon").url = UIPackage.GetItemURL("continue","zhenjiaxueren_005")
            v.touchable = true
        end
    end

    for k,v in pairs(data.siteDataId) do
        -- print(k,v)
        for i,j in pairs(self.allConfData) do
            if j.id == v and j.type == 2 then
                self.snowManList[k]:GetChild("icon").url = UIPackage.GetItemURL("continue","zhenjiaxueren_007")
                self.snowManList[k].touchable = false
                break
            elseif j.id == v and j.type == 1 then
                self.snowManList[k]:GetChild("icon").url = UIPackage.GetItemURL("continue","zhenjiaxueren_006")
                self.snowManList[k].touchable = false
                break
            end
        end
    end

    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self,self.onTimer))
    end
end

function SnowMan:setAwardData(index,obj)
    local awardData = self.confData[index+1].items
    local itemData = {}
    if awardData then
        itemData.mid = awardData[1]
        itemData.amount = awardData[2]
        itemData.bind = awardData[3]
        GSetItemData(obj, itemData, true)
    end
end

function SnowMan:setRecordData(index,obj)
    if not self.data then return end
    local recordIndex = index + 1
    if self.data.logs then
        local recordData = self.data.logs[recordIndex]
        local splitData = string.split(recordData,ChatHerts.SYSTEMPRO)
        local itemName = conf.ItemConf:getName(splitData[2])
        local table = {
                {text = splitData[1],color = 7},
                {text = language.snowMan01,color = 6},                
                {text = itemName,color = 7},
                {text = splitData[3],color = 7},
            }
        local recordText = mgr.TextMgr:getTextByTable(table)
        local recordItem = obj:GetChild("n0")
        recordItem.text = recordText
    end
end

function SnowMan:snowManClick(context)
    local btn = context.sender
    local data = btn.data
    -- print("抽到的雪人>>>",data)
    local ingots = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if ingots > 0 then
        proxy.ActivityProxy:sendMsg(1030646,{reqType = 1,site = data})
    else
        GOpenView({id = 1042})
        self:closeView()
        return
    end
end

function SnowMan:btnOnClick()
    proxy.ActivityProxy:sendMsg(1030646,{reqType = 2})
end

-- 判断奖励的类型
function SnowMan:setFlag(dataId)
    local flag = false
    print(dataId)
    for k,v in pairs(self.allConfData) do
        if v.id == dataId and v.type == 2 then -- 高级奖励
            flag = true
        elseif v.id == dataId and v.type == 1 then -- 低级奖励
            flag = false
        end
    end
    return flag
end

function SnowMan:onTimer()
    if not self.data then return end
    self.actCountDown = math.max(self.actCountDown - 1,0)
    if self.actCountDown <= 0 then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
        self:closeView()
        return
    end
    if self.actCountDown >= 86400 then
        self.actCountDownText.text = mgr.TextMgr:getTextColorStr(GGetTimeData3(self.actCountDown),7) 
    else
        self.actCountDownText.text = mgr.TextMgr:getTextColorStr(GGetTimeData4(self.actCountDown),7)   
    end
end

return SnowMan