--
-- Author: 
-- Date: 2018-07-30 14:36:16
--

local ShenBiActive = class("ShenBiActive", base.BaseView)

local ShengJieRank = import(".ShengJieRank")--升阶排行
local ShengJieReturn = import(".ShengJieReturn")--升阶返还

local Modules = {1288,1289}

local GoIndex = {
    [1288] = 0,
    [1289] = 1,
}

function ShenBiActive:ctor()
    ShenBiActive.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ShenBiActive:initView()
    local closeBtn =  self.view:GetChild("n0"):GetChild("n7")
    closeBtn.onClick:Add(self.onBtnClose,self)

    self.c1 = self.view:GetController("c1")

    self.shengJieRank = ShengJieRank.new(self)
    self.shengJieReturn = ShengJieReturn.new(self)
    
    self.btnList = {}
    self.btnPos = {}

    for i=1,2 do  
        local btn = self.view:GetChild("n"..i)
        btn.data = i - 1
        btn.onClick:Add(self.onSendMsg,self)
        table.insert(self.btnList, btn)
        table.insert(self.btnPos, btn.y)
    end
end

function ShenBiActive:initData(data)
    local moduleId = data.moduleId or 1288
    self.c1.selectedIndex = GoIndex[moduleId]
    self:checkSeeBtn()
end

function ShenBiActive:checkSeeBtn()
    local data = cache.ActivityCache:get5030111()
    if data.acts[5004] and data.acts[5004] == 1 then
        self.btnList[1].visible = true
    else
        self.btnList[1].visible = false
    end
    if data.acts[3077] and data.acts[3077] == 1 then
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
            v.selected  = true
            break
        end
    end
    if self.c1.selectedIndex == 0 then
        proxy.ActivityProxy:sendMsg(1030226)
    elseif self.c1.selectedIndex == 1 then
        proxy.ActivityProxy:sendMsg(1030227,{reqType = 0,cid = 0})
    end
end

function ShenBiActive:onSendMsg(context)
    local data = context.sender.data
    if data == 0 then
        proxy.ActivityProxy:sendMsg(1030226)
    elseif data == 1 then
        proxy.ActivityProxy:sendMsg(1030227,{reqType = 0,cid = 0})
    end
end

function ShenBiActive:refreshRed()
    local var = cache.PlayerCache:getRedPointById(20195)
    local redImg = self.view:GetChild("n2"):GetChild("n5")
    if var > 0 then
        redImg.visible = true
    else
        redImg.visible = false
    end
end

function ShenBiActive:addMsgCallBack(data)
    self:refreshRed()
    if self.c1.selectedIndex == 0 and data.msgId == 5030226 then
        self:updateRank(data)
    elseif self.c1.selectedIndex == 1 and data.msgId == 5030227 then
        self:updateReturn(data)
    end
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end
--进阶排行
function ShenBiActive:updateRank(data)
    self.shengJieRank:setData(data)
end
--进阶返还
function ShenBiActive:updateReturn(data)
    self.shengJieReturn:setData(data)
end

function ShenBiActive:onTimer()
    if self.shengJieRank then
        self.shengJieRank:onTimer()
    end
    if self.shengJieReturn then
        self.shengJieReturn:onTimer()
    end
end


function ShenBiActive:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end


function ShenBiActive:onBtnClose()
    self:releaseTimer()
    self:closeView()
end


return ShenBiActive