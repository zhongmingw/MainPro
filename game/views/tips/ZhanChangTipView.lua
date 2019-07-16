--
-- Author: 
-- Date: 2017-06-16 11:34:47
--

local ZhanChangTipView = class("ZhanChangTipView", base.BaseView)

function ZhanChangTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function ZhanChangTipView:initData(modelId)
    self:setData(modelId)
end

function ZhanChangTipView:initView()
    local closeBtn = self.view:GetChild("n4")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.titleText = self.view:GetChild("n9")
    self.icon = self.view:GetChild("n11")
    self.descText = self.view:GetChild("n7")
    local btn = self.view:GetChild("n3")
    btn.onClick:Add(self.onClickBtn,self)
end

function ZhanChangTipView:setData(modelId)
    self.modelId = modelId
    
    local confData = conf.ActivityShowConf:getActDataById(modelId)
    self.titleText.text = confData.name
    self.icon.url = ResPath.iconRes(confData.tipicon)
    
    self.descText.text = language.tips08[modelId]
end

function ZhanChangTipView:onClickBtn()
    if self.modelId and self.modelId > 0 then
        if self.modelId == 1116 or self.modelId == 1112 or self.modelId == 1126 then--全民修炼、浪漫姻缘、三倍刷怪 跳转活动大厅
            GOpenView({id = 1105,childIndex = self.modelId})
        else
            GOpenView({id = self.modelId})
        end
    end
    self:onClickClose()
end

function ZhanChangTipView:onClickClose()
    local zhanChangMod = cache.PlayerCache:getZhanChangMod()
    if zhanChangMod then
        self:setData(zhanChangMod)
    else
        self:closeView()
    end-- body
end

return ZhanChangTipView