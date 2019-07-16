--
-- Author: 
-- Date: 2018-04-09 16:52:28
--

local WorldBossExplainView = class("WorldBossExplainView", base.BaseView)

function WorldBossExplainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function WorldBossExplainView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    closeBtn.onClick:Add(self.onCloseView,self)
    for i=1,2 do
        local panel = self.view:GetChild("n"..i)
        panel.title = language.fuben220[i]
    end
end

function WorldBossExplainView:initData(data)
    self.data = data
end
function WorldBossExplainView:onCloseView()
    if self.data.cancel then
        self.data.cancel()
    end
    self:closeView()
end

return WorldBossExplainView