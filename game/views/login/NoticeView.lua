--
-- Author: Your Name
-- Date: 2017-06-10 15:59:05
--

local NoticeView = class("NoticeView", base.BaseView)

function NoticeView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function NoticeView:initView()
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n2")
    closeBtn.onClick:Add(self.onCloseView,self)

    local sureBtn = self.view:GetChild("n13")
    sureBtn.onClick:Add(self.onCloseView,self)

    self.taskPanel = self.view:GetChild("n11")
end

function NoticeView:initData(data)
    local textTab = self.taskPanel:GetChild("n0")
    local content = data.content
    local title = data.title
    textTab.text = content 

    self:setTime()  
end

function NoticeView:setTime()
    local curTime = os.time()
    UPlayerPrefs.SetInt("Notice", curTime)
end

function NoticeView:onCloseView()
    -- body
    self:closeView()
end

return NoticeView