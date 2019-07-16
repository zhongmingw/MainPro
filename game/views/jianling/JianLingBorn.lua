--
-- Author: 
-- Date: 2018-07-16 20:51:44
--

local JianLingBorn = class("JianLingBorn", base.BaseView)

local XunBaoRank = import(".XunBaoRank")--寻宝排行
local XunBaoReturn = import(".XunBaoReturn")--寻宝返还

local Modules = {1269,1270}

local GoIndex = {
    [1269] = 0,
    [1270] = 1,
}
function JianLingBorn:ctor()
    JianLingBorn.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function JianLingBorn:initView()
    self.window = self.view:GetChild("n0")
    local closeBtn =  self.window:GetChild("n5")
    closeBtn.onClick:Add(self.onBtnClose,self)

    local ruleBtn = self.view:GetChild("n15")
    ruleBtn.onClick:Add(self.onClickRule,self)
    self.c1 = self.view:GetController("c1")
    -- self.c1.onChanged:Add(self.onController,self)

    self.xunBaoRank = XunBaoRank.new(self)
    self.xunBaoReturn = XunBaoReturn.new(self)
    
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

function JianLingBorn:initData(data)
    local moduleId = data.moduleId or 1269
    self.c1.selectedIndex = GoIndex[moduleId]
    self:checkSeeBtn()
    self:setPictureSize()
end

function JianLingBorn:checkSeeBtn()
    local data = cache.ActivityCache:get5030111()
    if (data.acts[5001] and data.acts[5001] == 1) or (data.acts[1190] and data.acts[1190] == 1) then
        self.btnList[1].visible = true
    else
        self.btnList[1].visible = false
    end
    if (data.acts[3067] and data.acts[3067] == 1) or (data.acts[1188] and data.acts[1188] == 1) then
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
        if data.acts[5001] and data.acts[5001] == 1 then
            proxy.ActivityProxy:sendMsg(1030215)
        elseif  data.acts[1190] and data.acts[1190] == 1 then
            proxy.ActivityProxy:sendMsg(1030418)
        end
    elseif self.c1.selectedIndex == 1 then
        if data.acts[3067] and data.acts[3067] == 1 then
              proxy.ActivityProxy:sendMsg(1030216,{reqType = 0,cid = 0})
        elseif  data.acts[1188] and data.acts[1188] == 1 then
            proxy.ActivityProxy:sendMsg(1030416,{reqType = 0,cid = 0})  
        end
      
    end

    -- mgr.ModuleMgr:setModuleVisible(Modules,self.btnList,self.btnPos)
end

function JianLingBorn:onSendMsg(context)
    local data = cache.ActivityCache:get5030111()
    local data1 = context.sender.data
    
    if data1 == 0 then
        if data.acts[5001] and data.acts[5001] == 1 then
            proxy.ActivityProxy:sendMsg(1030215)
        elseif  data.acts[1190] and data.acts[1190] == 1 then
            proxy.ActivityProxy:sendMsg(1030418)
        end
    elseif data1 == 1 then
        if data.acts[3067] and data.acts[3067] == 1 then
              proxy.ActivityProxy:sendMsg(1030216,{reqType = 0,cid = 0})
        elseif  data.acts[1188] and data.acts[1188] == 1 then
            proxy.ActivityProxy:sendMsg(1030416,{reqType = 0,cid = 0})  
        end
    end
end

-- function JianLingBorn:onController()
--     if self.c1.selectedIndex == 0 then
--         proxy.ActivityProxy:sendMsg(1030215)
--     elseif self.c1.selectedIndex == 1 then
--         proxy.ActivityProxy:sendMsg(1030216,{reqType = 0,cid = 0})
--     end
-- end

function JianLingBorn:refreshRed()
    local var = cache.PlayerCache:getRedPointById(20188)
    local redImg = self.view:GetChild("n3"):GetChild("n7")
    if var > 0 then
        redImg.visible = true
    else
        redImg.visible = false
    end
end

--设置界面按钮背景图片尺寸
function JianLingBorn:setPictureSize()
    local trueNum = 0
    for k,v in pairs(self.btnList) do
        if v.visible then 
            trueNum = trueNum + 1
        end
    end
    if trueNum > 1 then 
        self.window:GetChild("n2").height = 183 + ((trueNum-1) * 125)
    else
        self.window:GetChild("n2").height = 183
    end
end



function JianLingBorn:addMsgCallBack(data)
    self:refreshRed()
    if (self.c1.selectedIndex == 0 and data.msgId == 5030215) or(self.c1.selectedIndex == 0 and data.msgId == 5030418)  then

        self:updateRank(data)
    elseif (self.c1.selectedIndex == 1 and data.msgId == 5030216) or(self.c1.selectedIndex == 1 and data.msgId == 5030416)  then
        self:updateReturn(data)
    end
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end
--寻宝排行
function JianLingBorn:updateRank(data)

    self.xunBaoRank:setData(data)
end
--寻宝返还
function JianLingBorn:updateReturn(data)

    self.xunBaoReturn:setData(data)
end

function JianLingBorn:onTimer()
    if self.xunBaoRank then
        self.xunBaoRank:onTimer()
    end
    if self.xunBaoReturn then
        self.xunBaoReturn:onTimer()
    end
end


function JianLingBorn:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function JianLingBorn:onClickRule()
    local data = cache.ActivityCache:get5030111()
    if (data.acts[5001] and data.acts[5001] == 1) or (data.acts[3067] and data.acts[3067] == 1)  then
        GOpenRuleView(1103)

    end
    if  (data.acts[1190] and data.acts[1190] == 1) or (data.acts[1188] and data.acts[1188] == 1) then
        GOpenRuleView(1163)
    end
end

function JianLingBorn:onBtnClose()
    self:releaseTimer()
    self:closeView()
end

return JianLingBorn