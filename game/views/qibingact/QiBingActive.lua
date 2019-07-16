--
-- Author: 
-- Date: 2018-12-27 16:03:09
--奇兵

local QiBingActive = class("QiBingActive", base.BaseView)

local QB1001 = import(".QB1001")--战力排行
local QB1002 = import(".QB1002")--寻宝返还
local table = table
local pairs = pairs
local Modules = {1439,1440}
local GoIndex = {
    [1439] = 0,
    [1440] = 1,
}

function QiBingActive:ctor()
    QiBingActive.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function QiBingActive:initView()
    self.window = self.view:GetChild("n0")
    local closeBtn =  self.window:GetChild("n17")
    closeBtn.onClick:Add(self.onBtnClose,self)

    local ruleBtn = self.view:GetChild("n15")
    ruleBtn.onClick:Add(self.onClickRule,self)
    self.c1 = self.view:GetController("c1")
    -- self.c1.onChanged:Add(self.onController,self)

    self.QB1001 = QB1001.new(self)
    self.QB1002 = QB1002.new(self)
    
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

function QiBingActive:initData(data)
    local moduleId = data.moduleId or 1439
    self.c1.selectedIndex = GoIndex[moduleId]
    self:checkSeeBtn()
    self:refreshRed()
    
end

function QiBingActive:checkSeeBtn()
    local data = cache.ActivityCache:get5030111()
    if data.acts[5016] and data.acts[5016] == 1 then
        self.btnList[1].visible = true
    else
        self.btnList[1].visible = false
    end
    if data.acts[1216] and data.acts[1216] == 1 then
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
        proxy.ActivityProxy:sendMsg(1030687)
    elseif self.c1.selectedIndex == 1 then
        proxy.ActivityProxy:sendMsg(1030686,{reqType = 0,cid = 0})
    end

    -- mgr.ModuleMgr:setModuleVisible(Modules,self.btnList,self.btnPos)
end

function QiBingActive:setData(data_)

end

function QiBingActive:onSendMsg(context)
    local data = context.sender.data
    if data == 0 then
        proxy.ActivityProxy:sendMsg(1030687)
    elseif data == 1 then
        proxy.ActivityProxy:sendMsg(1030686,{reqType = 0,cid = 0})
    end
end


function QiBingActive:addMsgCallBack(data)
    self:refreshRed()
    if self.c1.selectedIndex == 0 and data.msgId == 5030687 then
        self:updateRank(data)
    elseif self.c1.selectedIndex == 1 and data.msgId == 5030686 then
        self:updateReturn(data)
    end
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function QiBingActive:refreshRed()
    local var = cache.PlayerCache:getRedPointById(30252)
    local redImg = self.view:GetChild("n3"):GetChild("red")
    if var > 0 then
        redImg.visible = true
    else
        redImg.visible = false
    end
end
--战力排行
function QiBingActive:updateRank(data)
    self.QB1001:setData(data)
end
--寻宝返还
function QiBingActive:updateReturn(data)
    self.QB1002:setData(data)
end

function QiBingActive:onTimer()
    if self.QB1001 then
        self.QB1001:onTimer()
    end
    if self.QB1002 then
        self.QB1002:onTimer()
    end
end


function QiBingActive:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end


function QiBingActive:onClickRule()
    GOpenRuleView(1170)
end


function QiBingActive:onBtnClose()
    self:releaseTimer()
    self:closeView()
end

return QiBingActive