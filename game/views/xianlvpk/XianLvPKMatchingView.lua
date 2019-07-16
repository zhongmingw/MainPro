--
-- Author: 
-- Date: 2018-07-24 17:06:48
--

local XianLvPKMatchingView = class("XianLvPKMatchingView", base.BaseView)

function XianLvPKMatchingView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end
function XianLvPKMatchingView:initView()
    self.text = self.view:GetChild("n0")
    local cancelBtn = self.view:GetChild("n3")
    cancelBtn.onClick:Add(self.onClickCancel,self)
end

function XianLvPKMatchingView:onClickCancel()
    proxy.XianLvProxy:sendMsg(self.msgId,{reqType = 2})
end

function XianLvPKMatchingView:onTiemr()
    self.num = self.num + 1
    self.text.text = self.num
    if self.num > 60 then
        if self.timer then
            mgr.TimerMgr:removeTimer(self.timer)
            self.timer = nil
        end
        proxy.XianLvProxy:sendMsg(self.msgId,{reqType = 2})
        self:closeView()
    end
end

function XianLvPKMatchingView:initData(data)
    self.type = data and data.type--1:跨服2：全服
    self.msgId = self.type == 1 and 1540107 or 1540207
    self.num = 0
    self.text.text = self.num
    self.timer = self:addTimer(1,-1,handler(self,self.onTiemr))
end

return XianLvPKMatchingView