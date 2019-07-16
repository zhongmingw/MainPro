--
-- Author: 
-- Date: 2017-09-04 16:25:26
--
--种树流程
local TreeExplainView = class("TreeExplainView", base.BaseView)

function TreeExplainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function TreeExplainView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    for i=1,4 do
        local panel = self.view:GetChild("n"..i)
        panel.title = language.kuafu147[i]
    end
end

function TreeExplainView:setData(data)

end

return TreeExplainView