--
-- Author: 
-- Date: 2017-07-27 14:55:26
--

local MakeDekaron = class("MakeDekaron", base.BaseView)

local DekaronTime = 5
local maxLen = 6
local effectId = 4020105--特效id
--打造结算弹窗
function MakeDekaron:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function MakeDekaron:initData(data)
    if self.effect then--出现特效
        self:removeUIEffect(self.effect)
        self.effect = nil
    end
    if data.suc == 1 then
        mgr.SoundMgr:playSound(Audios[1])
        self.oldTime = Time.getTime()
        self.effect = self:addEffect(effectId, self.view:GetChild("n1"))
        self.makeDesc.visible = false
        self:setGrayedPanel(false)
    else
        self.oldTime = 0
        self.makeDesc.visible = true
        self.makeDesc.text = language.forging44..(data.sucRate / 100).."%"
        self:setGrayedPanel(true)
    end
    self.titleIcon.url = UIPackage.GetItemURL("forging" , UIItemRes.makeDekaron[data.suc])
    self:setData(data.items)
end

function MakeDekaron:initView()
    local panel = self.view:GetChild("n0")
    self.panel = panel
    self.listView = panel:GetChild("n3")
    -- self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.titleIcon = panel:GetChild("n6")
    self.makeDesc = panel:GetChild("n5")
    self.timeText = panel:GetChild("n4")
    self.blackView.onClick:Add(self.onClickClose,self)
end

function MakeDekaron:setGrayedPanel(grayed)
    for i = 0 , self.panel.numChildren-1 do 
        local var = self.panel:GetChildAt(i)
        if var and var.name ~= "n3" then
            var.grayed = grayed
        end
    end
end

function MakeDekaron:setData(items)
    self.mData = items
    self.listView.numItems = #items
    if not self.myTimer then
        self.time = DekaronTime
        self:onTimer()
        self.myTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function MakeDekaron:cellData(index, obj)
    local data = self.mData[index + 1]
    local item = obj:GetChild("n0")
    GSetItemData(item,data)
end

function MakeDekaron:releaseTimer()
    if self.myTimer then
        self:removeTimer(self.myTimer)
        self.myTimer = nil
    end
end
--关闭倒计时
function MakeDekaron:onTimer()
    self.timeText.text = string.format(language.fuben11, self.time)
    if self.time <= 0 then
        self:onClickClose()
    end
    self.time = self.time - 1
end

function MakeDekaron:onClickClose()
    local time = Time.getTime() - self.oldTime
    if time >= 0.24 then
        self:releaseTimer()
        self:closeView()
    end
end

return MakeDekaron