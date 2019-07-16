--
-- Author: 
-- Date: 2017-12-12 11:03:01
--

local PanelXmzb = class("PanelXmzb")

function PanelXmzb:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function PanelXmzb:initPanel()
    local panelObj = self.mParent.view:GetChild("n55")
    local awards = conf.XmhdConf:getValue("xianmeng_awards_yl")
    local listView = panelObj:GetChild("n10")
    listView:SetVirtual()
    listView.itemRenderer = function(index,obj)
        local award = awards[index + 1]
        local itemData = {mid = award[1],amount = award[2],bind = award[3]}
        GSetItemData(obj, itemData, true)
    end
    listView.numItems = #awards

    self.bg = panelObj:GetChild("n3")

    local ruleBtn = panelObj:GetChild("n6")
    ruleBtn.onClick:Add(self.onClickRule,self)
    local btn = panelObj:GetChild("n7")
    self.selectBtn = btn
    btn.onClick:Add(self.onClickSelect,self)
end

function PanelXmzb:setData()
    if self.bg.url and self.bg.url ~= "" then
        return
    end
    self.imgPath = UIItemRes.zhanchang.."xianmengzhengba_057"
    --self.bg.url = self.imgPath
    self.mParent:setLoaderUrl(self.bg,self.imgPath)
    local redNum = cache.PlayerCache:getRedPointById(attConst.A20133)
    local visible = false
    if redNum > 0 then
        visible = true
    end
    self.selectBtn:GetChild("red").visible = visible
end

function PanelXmzb:onClickRule()
    GOpenRuleView(1066)
end

function PanelXmzb:onClickSelect()
    GOpenView({id = 1139})
end

function PanelXmzb:clear()
    self.bg.url = nil
end


return PanelXmzb