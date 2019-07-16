--
-- Author: 
-- Date: 2017-10-24 11:49:01
--
--经验药水
local ExpdrugTipView = class("ExpdrugTipView", base.BaseView)

function ExpdrugTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function ExpdrugTipView:initView()
    local closeBtn = self.view:GetChild("n1"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.view:GetChild("n3").text = language.fuben161
    self.listView = self.view:GetChild("n4")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
end

function ExpdrugTipView:initData()
    self.items = conf.FubenConf:getValue("fam_exp_buy_cost")
    self.listView.numItems = #self.items
end
--{{221011051,1,1},{221011052,1,1}},
function ExpdrugTipView:cellData(index,obj)
    local data = self.items[index + 1]
    local itemObj = obj:GetChild("n0")
    local mId = data[1]
    local itemData = {mid = mId,amount = data[2],bind = data[3]}
    GSetItemData(itemObj,itemData,true)
    obj:GetChild("n1").text = conf.ItemConf:getName(data[1])
    local btn = obj:GetChild("n3")
    local packData = cache.PackCache:getPackDataById(mId)
    local buffId = conf.ItemConf:getArgsType2(mId) or 0
    local buff = mgr.BuffMgr:getBuffByModelId(buffId,cache.PlayerCache:getRoleId())
    if buff then
        btn.title = language.pack43
    else
        if packData.amount > 0 then
            btn.title = language.pack03
        else
            btn.title = language.pack42
        end
    end
    btn.data = {isInPack = isInPack, packData = packData}
    btn.onClick:Add(self.onClickUse,self)
end

function ExpdrugTipView:onClickUse(context)
    local btn = context.sender
    local data = btn.data
    local packData = data.packData
    if btn.title == language.pack43 then
        GComAlter(language.fuben199)
        return
    end
    if packData.amount > 0 then
        local params = {
            index = packData.index,--背包的位置
            amount = 1,--使用数量
            ext_arg = 0,
        }
        proxy.PackProxy:sendUsePro(params)
    else
        local formview = conf.ItemConf:getFormview(packData.mid)
        if formview then
            local t = formview[1]
            GOpenView({id = t[1],childIndex = t[2]})
        end
    end
    -- self:closeView()
end

return ExpdrugTipView