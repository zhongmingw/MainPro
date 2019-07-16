--
-- Author: 
-- Date: 2019-01-08 11:21:06
--

local Bx1004 = class("Bx1004",import("game.base.Ref"))

function Bx1004:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end


function Bx1004:onTimer()
    -- body
    if not self.data then return end
end

function Bx1004:addMsgCallBack(data)
    -- body
    self.data = data
    self.taskInfoData = conf.BingXueConf:getTaskInfoData()
    --对已完成的任务进行排序（完成的/id小的后排）
    table.sort(self.taskInfoData,function( a,b )
        -- body
        local completeTaskNum1 = self.data.taskInfo[a.id] and self.data.taskInfo[a.id] or 0
        local completeTaskNum2 = self.data.taskInfo[b.id] and self.data.taskInfo[b.id] or 0
        local aisover = completeTaskNum1>=a.count and 1 or 0
        local bisover = completeTaskNum2>=b.count and 1 or 0
        if aisover ~=  bisover then
            return aisover < bisover
        else
            return a.id < b.id
        end
    end)
    self.taskList.numItems = #self.taskInfoData
    self.taskAwardData = conf.BingXueConf:getTaskAward()
    local maxScore =0
    local curScore = self.data.score and self.data.score or 0
    self.currentScore.text = curScore
    for i=1,5 do
        self.giftItemList[i].numItems =#self.taskAwardData[i].items
        self.targetScore[i].text =string.format(language.bxHdxs01,self.taskAwardData[i].score)
        maxScore = maxScore>self.taskAwardData[i].score and maxScore or self.taskAwardData[i].score

        if curScore >= self.taskAwardData[i].score then
            if self.data.gotSigns[self.taskAwardData[i].id] then--已经领取过
                --print("领取标识"..self.data.gotSigns[self.taskAwardData[i].id])
                self.targetScoreController[i].selectedIndex =0
                self.giftController[i].selectedIndex =1
                self.targetRed[i].visible =false
            else--未领取
                self.targetScoreController[i].selectedIndex =1
                --self.giftController[i].selectedIndex =1
                self.targetBtn[i].data = {cid = self.taskAwardData[i].id,index = i}
                print(self.targetRed[i].visible)
                self.targetRed[i].visible =true
                print(self.targetRed[i].visible)
                self.targetBtn[i].onClick:Add(self.onClickGet,self)
            end
        end
    end
    if not self.fillTimer then--当路线没有在跑时
        self.roadSchedule = curScore/maxScore--当前道路进度（根据填充比例）
        local currentFill = cache.ActivityCache:getBingXueFillAmount()
        if not currentFill then
            cache.ActivityCache:setBingXueFillAmount(self.roadSchedule)--从服务器设置当前的路线覆盖值
            currentFill= cache.ActivityCache:getBingXueFillAmount()
        end 
        self.road.fillAmount =currentFill
        --print("当前图片填充"..self.road.fillAmount.."当前进度"..self.roadSchedule)
        if self.roadSchedule>self.road.fillAmount then
            self.fillTimer=mgr.TimerMgr:addTimer(0.05,-1,function()
                self.road.fillAmount = self.road.fillAmount+0.005
                if self.road.fillAmount>=self.roadSchedule then
                    self.road.fillAmount = self.roadSchedule
                    cache.ActivityCache:setBingXueFillAmount(self.roadSchedule)--记录最后一次的路线覆盖值
                    self:removeTimer()
                    return
                end
            end,"fillTimer")
        end
    end
end

function Bx1004:onClickGet(context)
    -- body
    local data = context.sender.data
    proxy.BingXueProxy:sendMsg(1030699,{reqType = 1,cid = data.cid})
    self.giftController[data.index].selectedIndex =1
end

function Bx1004:removeTimer()
    -- body
    if self.fillTimer then
        mgr.TimerMgr:removeTimer(self.fillTimer)
    end
    self.fillTimer = nil 
end

function Bx1004:initView()
    -- body
    self.road = self.view:GetChild("n1")
    self.taskList =self.view:GetChild("n12")
    self.taskList.numItems = 0
    self.taskList.itemRenderer = function (index,obj)
        self:taskData(index, obj)
    end
    self.taskList:SetVirtual()
    self.currentScore =self.view:GetChild("n22")
    self.giftItemList ={}--礼物列表集合
    self.targetScore ={}--目标分数集合
    self.targetBtn ={}--目标分数上的按钮
    self.targetRed ={}--目标分数按钮上的红点
    self.giftController ={}--控制器集合
    self.targetScoreController = {}--目标分数控制器集合
    for i=30,26,-1 do
        table.insert(self.targetScore,self.view:GetChild("n"..i):GetChild("n24"))
        table.insert(self.targetBtn,self.view:GetChild("n"..i):GetChild("n23"))
        table.insert(self.targetRed,self.view:GetChild("n"..i):GetChild("red"))
        table.insert(self.targetScoreController,self.view:GetChild("n"..i):GetController("c1"))
    end
    --从下往上由小至大
    for i=7,11 do
        table.insert(self.giftItemList,self.view:GetChild("n"..i):GetChild("n6"))
        table.insert(self.giftController,self.view:GetChild("n"..i):GetController("c1"))
        local j = i-6
        self.giftItemList[j].itemRenderer = function(index,obj)
             self:giftItemData(index, obj, j)
        end
        --self.giftItemList[j]:SetVirtual()
    end
end

function Bx1004:taskData( index,obj)
    local data = self.taskInfoData[index+1]
    local icon = obj:GetChild("n20")

    icon.url = "ui://bingxue/"..data.icon
    obj:GetChild("n14").text =string.format(data.name,data.count,data.count*data.score)
    local completeTaskNum = self.data.taskInfo[data.id] and self.data.taskInfo[data.id] or 0
    obj:GetChild("n16").text = string.format(language.bxHdbs01,completeTaskNum,data.count) 
    local goTaskBtn = obj:GetChild("n19")
    if completeTaskNum < data.count then
        goTaskBtn:GetController("c1").selectedIndex = 0
        goTaskBtn.data = {skipId = data.skipId}
        goTaskBtn.onClick:Add(self.onClickGoTask,self)
    end
    if completeTaskNum == data.count then
        goTaskBtn:GetController("c1").selectedIndex = 2
        goTaskBtn:RemoveEventListeners()
    end
end

function Bx1004:giftItemData( index,obj,j )
    -- body
    local data = self.taskAwardData[j]
    local itemInfo = {mid = data.items[index+1][1],amount = data.items[index+1][2],bind = data.items[index+1][3]}
    --printt("礼物列表集合：",itemInfo)
    GSetItemData(obj, itemInfo, true)
end

function Bx1004:onClickGoTask(context)
    -- body
    local data = context.sender.data
    GOpenView({id = data.skipId})
end

return Bx1004