--
-- Author: 
-- Date: 2017-05-10 11:55:16
--

local TaskSHView = class("TaskSHView", base.BaseView)

function TaskSHView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function TaskSHView:initData(data)
    -- body
    self.data = data
    self.width = 0

    self:setData()
end

function TaskSHView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onCloseView,self)

    self.btnGet = self.view:GetChild("n1")
    self.btnGet.onClick:Add(self.onGetCall,self)

    self.listView = self.view:GetChild("n3")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    self.btnxm = self.view:GetChild("n10")
    self.btnxm.title = language.task11[4]
    self.btnxm.onClick:Add(self.onBangPai,self)

    self:initDec()
end

function TaskSHView:initDec()
    -- body
    self.view:GetChild("n4").text = language.task08
    self.view:GetChild("n5").text = language.task09
    self.view:GetChild("n8").text = language.task10
    --收集什么东西
    self.dec1 = self.view:GetChild("n6")
    self.dec1.text = ""
    --哪里产出
    self.dec2 = self.view:GetChild("n7")
    local textData = {
        {text=language.task11[1],color = 6},
        {text=language.task11[2],color = 7},
        {text=language.task11[3],color = 6},
        {text=language.task11[4],color = 7},
        {text=language.task11[5],color = 6},
        {text=language.task11[6],color = 7},
        {text=language.task11[7],color = 6},
    }
    self.dec2.text = mgr.TextMgr:getTextByTable(textData)

    
end

function TaskSHView:setData()
    self.reward = conf.TaskConf:getTaskById(self.data.taskId)
    --printt(self.reward)
    --plog("self.data.taskId",self.data.taskId)
    self.listView.numItems = #self.reward.finish_items
    --收集
    local str = ""

    local confData = self.reward
    self.canget = true

    local getMidAmout = {}
    for k , v in pairs(confData.conditions) do
        str = str .. mgr.TextMgr:getColorNameByMid(v[1])
        local itemData = cache.PackCache:getPackDataById(v[1])

        local duce = getMidAmout[v[1]] or 0

        local left = math.max(0,(itemData.amount - duce))
        if v[2]> left  then --不满足
            self.canget = false
            str = str .. mgr.TextMgr:getQualityStr1("(",1)
            str = str .. mgr.TextMgr:getTextColorStr(left,14)
            str = str .. mgr.TextMgr:getQualityStr1("/"..v[2]..")",1)
        else
            local var = "("..v[2].."/"..v[2]..")"
            str = str .. mgr.TextMgr:getTextColorStr(var,7)
        end

        if not getMidAmout[v[1]] then
            getMidAmout[v[1]] = v[2]
        else
            getMidAmout[v[1]] = getMidAmout[v[1]] + v[2]
        end

        if k~=#confData.conditions then
            str = str .."\n"
        end
    end
    self.dec1.text = str

    if self.canget then
        self.btnGet.enabled = true
    else
        self.btnGet.enabled = false
    end
end

function TaskSHView:celldata(index,obj)
    -- body
    local data = self.reward.finish_items[index+1]
    local t = {mid = data[1],amount=data[2]}
    GSetItemData(obj,t,true)
    --动态居中
    -- self.width = obj.actualWidth + self.width
    -- if index + 1 == self.listView.numItems then
    --     self.listView.viewWidth = self.width
    -- else
    --     self.width = self.width + self.listView.columnGap
    -- end
end

function TaskSHView:onGetCall()
    -- body--领取
    if not self.data then
        return
    end
    proxy.TaskProxy:send(1050402,{taskId = self.data.taskId})
    self:onCloseView()
end

function TaskSHView:onBangPai( ... )
    -- body
    if not self.data then
        return
    end

    if cache.PlayerCache:getGangId().."" ~= "0" then
        GOpenView({id = 1015 })
    else
        GComAlter(language.chatGuild)
    end
end

function TaskSHView:onCloseView()
    -- body
    self:closeView()
end

return TaskSHView