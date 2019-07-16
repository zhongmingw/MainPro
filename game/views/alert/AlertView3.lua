--
-- Author: ohf
-- Date: 2017-01-11 10:38:51
--
--恭喜获得弹窗
local AlertView3 = class("AlertView3", base.BaseView)

local Time = 5
local maxLen = 6
local effectId = 4020105--特效id

function AlertView3:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function AlertView3:initData()
    if self.effect then--出现特效
        self:removeUIEffect(self.effect)
        self.effect = nil
    end
    mgr.SoundMgr:playSound(Audios[1])
    self.oldTime = os.time()
    self.effect = self:addEffect(effectId, self.view:GetChild("n1"))
end

function AlertView3:initView()
    local panel = self.view:GetChild("n0")
    self.listView = panel:GetChild("n3")
    self.c1 = panel:GetController("c1")
    -- self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.timeText = panel:GetChild("n4")
    self.timeText2 = panel:GetChild("n6")
    local closeBtn = panel:GetChild("n5")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.blackView.onClick:Add(self.onClickClose,self)
end

function AlertView3:setData(items,isOk)
    self.mData = items
    self.listView.numItems = 0
    self.time = Time
    self:onTimer2()
    self.listView.numItems = #items
    if self.myTimer2 then
        self:removeTimer(self.myTimer2)
        self.myTimer2 = nil 
    end
    if isOk then
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0
    end
    self.myTimer2 = self:addTimer(1, -1, handler(self, self.onTimer2))

end

function AlertView3:cellData(index, obj)
    local data = self.mData[index + 1]
    local item = obj:GetChild("n0")
    GSetItemData(item,data)
end

--出現动作
function AlertView3:setAction()
    if self.num > #self.mData then
        return
    end
    local obj = self.listView:GetChildAt(self.num - 1)
    local item = obj:GetChild("n0")
    UTransition.TweenMove2(item, Vector2.New(0, 0), 0.2, true, function()
        self.num  = self.num  + 1
        self:setAction()
    end)
end
--关闭倒计时
function AlertView3:onTimer2()
    self.timeText.text = string.format(language.fuben11, self.time)
    self.timeText2.text = self.timeText.text
    self.time = self.time - 1
    if self.time <= 0 then
        self:onClickClose()
    end
end

function AlertView3:releaseTimer1()
    if self.myTimer1 then
        self:removeTimer(self.myTimer1)
        self.myTimer1 = nil
    end
end

function AlertView3:onClickClose()
    -- local confEffectData = conf.EffectConf:getEffectById(effectId)
    -- local confTime = confEffectData and confEffectData.durition_time or 0
    local time = os.time() - self.oldTime
    if time >= 0.24 then
        self:releaseTimer1()
        if self.myTimer2 then
            self:removeTimer(self.myTimer2)
            self.myTimer2 = nil
        end
        self:closeView()
    end
end

return AlertView3