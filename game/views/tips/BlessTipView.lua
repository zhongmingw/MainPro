--
-- Author: 
-- Date: 2017-06-16 10:52:39
--
--祝福值提示
local BlessTipView = class("BlessTipView", base.BaseView)

function BlessTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function BlessTipView:initData(data)
    self:releaseTimer()
    self:setData(data)
end

function BlessTipView:initView()
    self:setCloseBtn(self.view:GetChild("n4"))
    self.view:GetChild("n5").text = language.tips09
    self.descText = self.view:GetChild("n7")
    self.timeText = self.view:GetChild("n8")
    local btn = self.view:GetChild("n3")
    btn.onClick:Add(self.onClickBtn,self)
end

function BlessTipView:setData(data)
    self.moduleId = data and data.moduleId or 0
    local confData = conf.SysConf:getModuleById(data.moduleId)
    local moduleName = confData and confData.name
    local str1 = mgr.TextMgr:getTextColorStr("["..moduleName.."]", 6)
    local str2 = mgr.TextMgr:getTextColorStr(language.tips10, 7)
    local str3 = mgr.TextMgr:getTextColorStr("（"..data.bless.."）", 15)
    self.descText.text = str1..str2..str3
    if not self.tipTimer then
        self.time = data.time
        self:onTimer()
        self.tipTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function BlessTipView:releaseTimer()
    if self.tipTimer then
        self:removeTimer(self.tipTimer)
        self.tipTimer = nil
    end
end

function BlessTipView:onTimer()
    local time = 24*3600 - (mgr.NetMgr:getServerTime() - self.time)
    self.timeText.text = language.buff02..GTotimeString(time)
    if time <= 0 then
        self:releaseTimer()
        self:closeView()
        return
    end
end

function BlessTipView:onClickBtn()
    GOpenView({id = self.moduleId,childIndex = 1})
    self:closeView()
end

return BlessTipView