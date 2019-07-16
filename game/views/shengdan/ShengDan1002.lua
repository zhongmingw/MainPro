--
-- Author: 
-- Date: 2018-12-10 14:37:31
--宝树

local ShengDan1002 = class("ShengDan1002",import("game.base.Ref"))

function ShengDan1002:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end

function ShengDan1002:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)
    --倒计时
    self.leftTimeTxt = panelObj:GetChild("n12")
    --当前积分
    self.curScore = panelObj:GetChild("n9")
    --任务列表
    self.listView = panelObj:GetChild("n10")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    --奖励列表
    self.awardList = panelObj:GetChild("n18")
    self.awardList.numItems = 0
    self.awardList.itemRenderer = function (index,obj)
        self:cellAwardData(index, obj)
    end
end

function ShengDan1002:setData(data)
    self.data = data
    if data.reqType == 1 then
        GOpenAlert3(data.items)
    end
    
    self.awardConf = conf.ShengDanConf:getTaskAward()
    self.awardList.numItems = #self.awardConf

    self.confData = conf.ShengDanConf:getTaskInfo()
    self.listView.numItems = #self.confData

    self.curScore.text = data.score
    self.leftTime = data.leftTime
    self.leftTimeTxt.text = GGetTimeData2(self.leftTime)

end

function ShengDan1002:onTimer()
    if not self.data then return end
    if self.leftTime then
        self.leftTime = self.leftTime - 1
        self.leftTimeTxt.text = GGetTimeData2(self.leftTime)
        if self.leftTime <= 0 then
            self.mParent:closeView()
        end
    end
end

function ShengDan1002:cellData(index,obj)
    local desc = obj:GetChild("n3")
    local icon = obj:GetChild("n6")
    local c1 = obj:GetController("c1")
    local goBtn = obj:GetChild("n5")
    goBtn:GetChild("red").visible = false
    local times = obj:GetChild("n4")--次数
    local data = self.confData[index+1]
    if data then
        local sumScore = tonumber(data.count)*tonumber(data.score)
        desc.text = string.format(data.name,tonumber(data.count),sumScore)
        icon.url = ResPath.iconRes(data.icon)
        local finishTime = self.data.taskInfo[data.id] or 0
        local color = finishTime >= tonumber(data.count) and 10 or 3
        times.text = mgr.TextMgr:getTextColorStr(finishTime,color).."/"..data.count
        goBtn.data = data.skipId or 0

        goBtn.onClick:Add(self.onClickGoBtn,self)
        c1.selectedIndex = finishTime >= tonumber(data.count) and 1 or 0
    end
end

function ShengDan1002:cellAwardData(index,obj)
    local c1 = obj:GetController("c1")
    local getBtn = obj:GetChild("n15")
    local score = obj:GetChild("n13")--次数
    local data = self.awardConf[index+1]
    if data then
        score.text = mgr.TextMgr:getTextColorStr(data.score, 10).."分"
        getBtn.data = data.id
        getBtn.onClick:Add(self.onClickGetBtn,self)
        GSetAwards(obj:GetChild("n16"),data.items)
        if self.data.gotSigns[data.id] then
            c1.selectedIndex = 1--已领取
        else
            if self.data.score >= data.score then
                c1.selectedIndex = 0--可领取
            else
                c1.selectedIndex = 2--未完成
            end
        end
    end
end

function ShengDan1002:onClickGetBtn(context)
    local btn = context.sender
    local data = btn.data
    proxy.ShengDanProxy:sendMsg(1030671,{reqType = 1,cid = data})

end

function ShengDan1002:onClickGoBtn(context)
    local skipId = context.sender.data
    GOpenView({id = skipId})
end


return ShengDan1002