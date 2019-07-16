--
-- Author: 
-- Date: 2018-10-08 21:14:20
--

local JianShenEquipRank = import(".JianShenEquipRank")
local JianShenEquipReturn = import(".JianShenEquipReturn")

local JianShenMain = class("JianShenMain", base.BaseView)

function JianShenMain:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
end

local MoudleId = {1363,1364}
local GoIndex = {
    [1363] = 0,
    [1364] = 1,
}

function JianShenMain:initView()
    local closeBtn = self.view:GetChild("n5")
    closeBtn.onClick:Add(self.onBtnClose,self)
    self.c1 = self.view:GetController("c1")
    self.btnList = {}
    for i = 9,10 do
        local btn = self.view:GetChild("n"..i)
        btn.data = i - 9
        btn.onClick:Add(self.btnClick,self)
        table.insert(self.btnList,btn)
    end
    local btnTitle1 = self.btnList[1]:GetChild("title")
    btnTitle1.text = language.jianshen2
    local btnTitle2 = self.btnList[2]:GetChild("title")
    btnTitle2.text = language.jianshen3

    self.JianShenEquipRank = JianShenEquipRank.new(self)
    self.JianShenEquipReturn = JianShenEquipReturn.new(self)

end

function JianShenMain:initData(data)
    self:releaseTimer()
    if not self.actTimer then
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    local moudleId = data.moduleId or 1363
    self.c1.selectedIndex = GoIndex[moudleId]
    self:setBtnState()
end

function JianShenMain:setBtnState()
    local actData = cache.ActivityCache:get5030111()
    -- 剑神排行
    if actData.acts[5013] and actData.acts[5013] == 1 then
        self.btnList[1].visible = true
    else
        self.btnList[1].visible = false
        self.btnList[2].y = self.btnList[1].y
    end
    -- 剑神返还
    if actData.acts[1166] and actData.acts[1166] == 1 then
        self.btnList[2].visible = true
    else
        self.btnList[2].visible = false        
    end

    for k,v in pairs(self.btnList) do
        if v.visible then
            v.selected = true
            break
        end
    end

    if self.c1.selectedIndex == 0 then
        proxy.ActivityProxy:sendMsg(1030253)
    elseif self.c1.selectedIndex == 1 then     
        proxy.ActivityProxy:sendMsg(1030633,{reqType = 0,cid = 0})
    end
end

function JianShenMain:setData(data)
    self:refreshRed()
    if self.c1.selectedIndex == 0 and data.msgId == 5030253 then
        self.JianShenEquipRank:setData(data)
    elseif self.c1.selectedIndex == 1 and data.msgId == 5030633 then
        self.JianShenEquipReturn:setData(data)
    end
end

function JianShenMain:refreshRed()
    local var = cache.PlayerCache:getRedPointById(30219)
    local redImg = self.view:GetChild("n10"):GetChild("red")
    if var > 0 then
        redImg.visible = true
    else
        redImg.visible = false
    end
end

function JianShenMain:btnClick(context)
    local btn = context.sender
    local btnData = btn.data
    if btnData == 0 then
        proxy.ActivityProxy:sendMsg(1030253)
    elseif btnData == 1 then
        proxy.ActivityProxy:sendMsg(1030633,{reqType = 0,cid = 0})
    end
end

function JianShenMain:onTimer()
    if self.JianShenEquipRank then
        self.JianShenEquipRank:onTimer()
    end
    if self.JianShenEquipReturn then
        self.JianShenEquipReturn:onTimer()
    end
end

function JianShenMain:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function JianShenMain:onBtnClose()
    self:releaseTimer()
    self:closeView()
end

return JianShenMain