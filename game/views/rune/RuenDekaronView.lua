--
-- Author: 
-- Date: 2018-03-06 20:04:37
--

local RuenDekaronView = class("RuenDekaronView", base.BaseView)

local Time = 5
local maxLen = 6
local effectId = 4020105--特效id

function RuenDekaronView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function RuenDekaronView:initData(data)
    if self.effect then--出现特效
        self:removeUIEffect(self.effect)
        self.effect = nil
    end
    mgr.SoundMgr:playSound(Audios[1])
    self.oldTime = os.time()
    self.effect = self:addEffect(effectId, self.view:GetChild("n9"))
    self.mData = data.items
    self.listView.numItems = 0
    self.time = Time
    self:onTimer()
    self.listView.numItems = #data.items
    if self.myTimer then
        self:removeTimer(self.myTimer)
        self.myTimer = nil 
    end
    self.myTimer = self:addTimer(1, -1, handler(self, self.onTimer))

    local index = data.index or 0
    local desc = ""
    local icon = ""
    if index == 0 then--没有合成石
        self.c1.selectedIndex = 1
    else--有合成石
        self.c1.selectedIndex = 0
    end
    self.view:GetChild("n10").text = language.rune28
    self.view:GetChild("n12").text = data.spNum or 0

    local times = data.times or 0
    self.view:GetChild("n13").text = language.rune27
    local stone = times * conf.RuneConf:getFuwenGlobal("fuwen_finding_got_stone")
    local view = mgr.ViewMgr:get(ViewName.XunBaoView)
    if view then 
        if view:getTowerMaxLevel() < conf.RuneConf:getFuwenGlobal("fuwen_double_pass") then
            stone = 0
            self.c1.selectedIndex = 3
        end
    end
    self.view:GetChild("n15").text = stone
end

function RuenDekaronView:initView()
    self.c1 = self.view:GetController("c1")
    self.listView = self.view:GetChild("n3")
    -- self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.timeText = self.view:GetChild("n5")
    local closeBtn = self.view:GetChild("n4")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.blackView.onClick:Add(self.onClickClose,self)
end

function RuenDekaronView:cellData(index, obj)
    local data = self.mData[index + 1]
    obj:GetController("c1").selectedIndex = 2
    obj.icon = mgr.ItemMgr:getItemIconUrlByMid(data.mid)
end
--关闭倒计时
function RuenDekaronView:onTimer()
    self.timeText.text = string.format(language.fuben11, self.time)
    self.time = self.time - 1
    if self.time <= 0 then
        self:onClickClose()
    end
end

function RuenDekaronView:onClickClose()
    self:closeView()
end

return RuenDekaronView