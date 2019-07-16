--
-- Author: 
-- Date: 2018-11-05 22:28:37
--

local QiMenDunJiaMain = class("QiMenDunJiaMain", base.BaseView)
local QMDJ1001 = import(".QMDJ1001")--战力排行
local QMDJ1002 = import(".QMDJ1002")--寻宝返还

local table = table
local pairs = pairs
local Modules = {1383,1384}
local GoIndex = {
    [1383] = 0,
    [1384] = 1,
}

function QiMenDunJiaMain:ctor()
    QiMenDunJiaMain.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end



function QiMenDunJiaMain:initView()
    self.window = self.view:GetChild("n0")
    local closeBtn =  self.window:GetChild("n17")
    closeBtn.onClick:Add(self.onBtnClose,self)

    local ruleBtn = self.view:GetChild("n15")
    ruleBtn.onClick:Add(self.onClickRule,self)
    self.c1 = self.view:GetController("c1")
    -- self.c1.onChanged:Add(self.onController,self)

    self.QMDJ1001 = QMDJ1001.new(self)
    self.QMDJ1002 = QMDJ1002.new(self)
    
    self.btnList = {}
    self.btnPos = {}
    for i=2,3 do  
        local btn = self.view:GetChild("n"..i)
        btn.data = i - 2
        btn.onClick:Add(self.onSendMsg,self)
        table.insert(self.btnList, btn)
        table.insert(self.btnPos, btn.y)
    end
end

function QiMenDunJiaMain:initData(data)
    local moduleId = data.moduleId or 1383
    self.c1.selectedIndex = GoIndex[moduleId]
    self:checkSeeBtn()
    self:refreshRed()
    
end


function QiMenDunJiaMain:checkSeeBtn()
    local data = cache.ActivityCache:get5030111()
    if data.acts[5015] and data.acts[5015] == 1 then
        self.btnList[1].visible = true
    else
        self.btnList[1].visible = false
    end
    if data.acts[1178] and data.acts[1178] == 1 then
        self.btnList[2].visible = true
    else
        self.btnList[2].visible = false
    end
    --设置按钮位置
    local index = 1
    for k,v in pairs(self.btnList) do
        if v.visible then
            v.y = self.btnPos[index]
            index = index + 1
        end
    end
    --选中第一个页签
    for k,v in pairs(self.btnList) do
        if v.visible then
            -- self.c1.selectedIndex = k - 1
            v.selected  = true
            break
        end
    end
    -- self:onController()
    if self.c1.selectedIndex == 0 then
        proxy.ActivityProxy:sendMsg(1030649)
    elseif self.c1.selectedIndex == 1 then
        proxy.ActivityProxy:sendMsg(1030648,{reqType = 0,cid = 0})
    end

    -- mgr.ModuleMgr:setModuleVisible(Modules,self.btnList,self.btnPos)
end

function QiMenDunJiaMain:setData(data_)

end

function QiMenDunJiaMain:onSendMsg(context)
    local data = context.sender.data
    if data == 0 then
        proxy.ActivityProxy:sendMsg(1030649)
    elseif data == 1 then
        proxy.ActivityProxy:sendMsg(1030648,{reqType = 0,cid = 0})
    end
end


function QiMenDunJiaMain:addMsgCallBack(data)
    self:refreshRed()
    if self.c1.selectedIndex == 0 and data.msgId == 5030649 then
        self:updateRank(data)
    elseif self.c1.selectedIndex == 1 and data.msgId == 5030648 then
        self:updateReturn(data)
    end
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function QiMenDunJiaMain:refreshRed()
    local var = cache.PlayerCache:getRedPointById(30226)
    local redImg = self.view:GetChild("n3"):GetChild("red")
    if var > 0 then
        redImg.visible = true
    else
        redImg.visible = false
    end
end
--战力排行
function QiMenDunJiaMain:updateRank(data)
    self.QMDJ1001:setData(data)
end
--寻宝返还
function QiMenDunJiaMain:updateReturn(data)
    self.QMDJ1002:setData(data)
end

function QiMenDunJiaMain:onTimer()
    if self.QMDJ1001 then
        self.QMDJ1001:onTimer()
    end
    if self.QMDJ1002 then
        self.QMDJ1002:onTimer()
    end
end


function QiMenDunJiaMain:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end


function QiMenDunJiaMain:onClickRule()
    GOpenRuleView(1158)
end


function QiMenDunJiaMain:onBtnClose()
    self:releaseTimer()
    self:closeView()
end

return QiMenDunJiaMain