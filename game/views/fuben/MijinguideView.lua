--
-- Author: 
-- Date: 2018-04-09 16:25:22
--

local MijinguideView = class("MijinguideView", base.BaseView)

function MijinguideView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function MijinguideView:initData(data)
    -- body
    local view = mgr.ViewMgr:get(ViewName.FubenView)
    if view and view.modelId == 1132 and view.panelSingle then
        --秘境秘境界面打开了
        --mgr.ViewMgr:openView2(ViewName.MijinguideView, view.panelSingle)
        local btn = view.panelSingle:getComByName("n14")
        if btn and btn.parent then
            self.xy = btn.parent:LocalToGlobal(btn.xy)

            self.btnnext.xy = self.view:GlobalToLocal(self.xy)
        else
            self:closeView()
            return
        end

        
    end

    --self.fuben1032 = data
    
    self.t0:Play()
end

function MijinguideView:initView()
    local btnclose = self.view:GetChild("n4")
    self:setCloseBtn(btnclose)

    self.btnnext = self.view:GetChild("n5")
    self.btnnext.onClick:Add(self.onBtnCall,self)

    self.t0 = self.view:GetChild("n7"):GetTransition("t0")

    local text = self.view:GetChild("n3")
    text.text = mgr.TextMgr:getTextByTable(language.guide10)
end

function MijinguideView:onBtnCall()
    -- body
    local view = mgr.ViewMgr:get(ViewName.FubenView)
    if view and view.modelId == 1132 and view.panelSingle then
        view.panelSingle:onFightCall()
    end
    --self.fuben1032
end

function MijinguideView:setData(data_)

end

return MijinguideView