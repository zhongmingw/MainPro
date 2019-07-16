local QiBingUpStarView = class("QiBingUpStarView", base.BaseView)

function QiBingUpStarView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function QiBingUpStarView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    local panel = self.view:GetChild("n1")
    self.attrControl = panel:GetController("c1")
    self.animation = panel:GetTransition("t0")

    -- local helpBtn = panel:GetChild("n32")
    -- helpBtn.onClick:Add(self.onClickHelpBtn, self)

    self.upStarBtn = panel:GetChild("n27")
    self.upStarBtn.onClick:Add(self.onClickUpStarBtn, self)

    self.modelPanel = panel:GetChild("n51")

    self.fightPower = panel:GetChild("n58")

    self.costItem = panel:GetChild("n31")
    self.costLabel = panel:GetChild("n45")

    local starGroup = panel:GetChild("n56")
    self.starControl = starGroup:GetController("c1")

    --强化升星属性列表
    self.attrList = {}
    for i = 1, 4 do
        local key = panel:GetChild("n" .. (i + 99))
        local curValue = panel:GetChild("n" .. (i + 109))
        local nextValue = panel:GetChild("n" .. (i + 119))
        table.insert(self.attrList, {key = key, curValue = curValue, nextValue = nextValue})
    end
end

function QiBingUpStarView:initData(data)
    self.data = data.data
    local confData = conf.QiBingConf:getQiBingDataById(self.data.id)
    self.fightPower.text = self.data.power
    local modelId = confData.modelId
    self.shenqi = self:addEffect(modelId, self.modelPanel)
    if nil ~= self.shenqi then
        self.shenqi.Scale = Vector3.New(confData.scale, confData.scale, confData.scale)
        local rotation = confData.rota
        self.shenqi.LocalRotation = Vector3.New(rotation[1], rotation[2], rotation[3])
        local pos = confData.pos
        self.shenqi.LocalPosition = Vector3.New(pos[1], pos[2], pos[3] - 150)
        self.animation:Play()
    end

    self:initShengxingPanel()
end

--升星
function QiBingUpStarView:initShengxingPanel()
    local sxLev = self.data.sxLev
    local id = self.data.id
    local confData = conf.QiBingConf:getSxDataByLv(sxLev, id)
    local nextConf = conf.QiBingConf:getSxDataByLv(sxLev + 1, id)
    self.starControl.selectedIndex = sxLev

    local attrCfg = nil
    local nextAttrCfg = nil
    local sxData = GConfDataSort(confData)--当前升星属性
    local nextsxData = GConfDataSort(nextConf)--下阶段升星属性
    self.attrControl.selectedIndex = nil ~= nextConf and 1 or 0

    for k, v in pairs(self.attrList) do
        attrCfg = sxData[k]
        if nil ~= attrCfg then
            v.key.text = conf.RedPointConf:getProName(attrCfg[1])
            v.curValue.text = attrCfg[2]
            if nil ~= nextConf then
                nextAttrCfg = nextsxData[k]
                v.nextValue.text = nextAttrCfg and nextAttrCfg[2]
            end
        end
    end

    if nil == nextConf then
        return
    end

    local costMid = confData.cost_item
                    and confData.cost_item[1][1]
                    or nextConf.cost_item[1][1]

    local costAmount = confData.cost_item
                    and confData.cost_item[1][2]
                    or nextConf.cost_item[1][2]
    local info = {mid = costMid,amount = costAmount,bind = 1}
    GSetItemData(self.costItem, info, true)
    local myCount = cache.PackCache:getPackDataById(costMid).amount
    local textData = {
            {text = myCount,color = 7},
            {text = "/"..costAmount,color = 7},
    }
    if costAmount > myCount then
        textData[1].color = 14
    end
    self.costLabel.text = mgr.TextMgr:getTextByTable(textData)
end

function QiBingUpStarView:onClickUpStarBtn()
    local confData = conf.QiBingConf:getSxDataByLv(self.data.sxLev, self.data.id)
    local nextData = conf.QiBingConf:getSxDataByLv(self.data.sxLev + 1, self.data.id)
    if nextData then
        local costMid = confData.cost_item[1][1]
        local costAmount = confData.cost_item[1][2]
        local myCount = cache.PackCache:getPackDataById(costMid).amount
        if myCount >= costAmount then
            proxy.QiBingProxy:sendUpStar(self.data.id)
        else
            GComAlter(language.shenqi08)
        end
    else
        GComAlter(language.zuoqi12_1)
    end
end

--升星刷新
function QiBingUpStarView:refreshSx(data)
    self:initShengxingPanel()
end

--规则
-- function QiBingUpStarView:onClickHelpBtn()
--     GOpenRuleView(1169)
-- end

return QiBingUpStarView