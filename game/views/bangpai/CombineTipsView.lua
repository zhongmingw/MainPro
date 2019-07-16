--
-- Author: Your Name
-- Date: 2018-07-07 16:45:32
--

local CombineTipsView = class("CombineTipsView", base.BaseView)

function CombineTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function CombineTipsView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onClickRefuse,self)
    self.refuseBtn = self.view:GetChild("n1")
    self.refuseBtn.onClick:Add(self.onClickRefuse,self)
    self.agreeBtn = self.view:GetChild("n2")
    self.agreeBtn.onClick:Add(self.onClickAgree,self)
    self.decTxt = self.view:GetChild("n4")
    self.timeTxt = self.view:GetChild("n6")
end

-- 变量名：gangId  说明：合入仙盟id
-- 变量名：gangName    说明：仙盟名
-- 变量名：gangAdminName   说明：盟主名
-- 变量名：acceptType  说明：0:合入请求 1:同意 2:拒绝
function CombineTipsView:initData(data)
    local gangName = data.gangName
    local gangAdminName = data.gangAdminName
    local textData = clone(language.bangpai198)
    textData[1].text = string.format(textData[1].text,gangAdminName)
    textData[3].text = string.format(textData[3].text,gangName)
    self.decTxt.text = mgr.TextMgr:getTextByTable(textData)
    self.gangId = data.gangId

    self.timesNum = 30
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.timer = self:addTimer(1, -1,handler(self, self.onTimer))
    self.timeTxt.text = string.format(language.bangpai200,self.timesNum)
end

function CombineTipsView:onTimer()
    if self.timesNum > 0 then
        self.timesNum = self.timesNum - 1
        self.timeTxt.text = string.format(language.bangpai200,self.timesNum)
    else
        self:onClickRefuse()
    end
end

function CombineTipsView:onClickRefuse()
    proxy.BangPaiProxy:sendMsg(1250701,{reqType = 2,gangId = self.gangId})
    self:closeView()
end

function CombineTipsView:onClickAgree()
    proxy.BangPaiProxy:sendMsg(1250701,{reqType = 1,gangId = self.gangId})    
    self:closeView()
end

return CombineTipsView