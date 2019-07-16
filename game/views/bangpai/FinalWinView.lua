--
-- Author: 
-- Date: 2017-11-28 20:45:07
--
--连胜终结
local FinalWinView = class("FinalWinView", base.BaseView)

function FinalWinView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function FinalWinView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    local panel = self.view:GetChild("n1")
    panel:GetChild("n0").text = language.xmhd01
    panel:GetChild("n1").text = language.xmhd02
    panel:GetChild("n2").text = language.xmhd03
    self.awardsText = self.view:GetChild("n2")
    self.awardsText.text = language.xmhd06
    self.buffText = panel:GetChild("n3")
    self.buffText.text = string.format(language.xmhd33, "")
    panel:GetChild("n4").text = language.xmhd04
    panel:GetChild("n5").text = language.xmhd05
    self.view:GetChild("n2").text = language.xmhd06
    self.awardsListView = self.view:GetChild("n3")
    self.awardsListView:SetVirtual()
    self.awardsListView.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end

    local finalBtn = self.view:GetChild("n4")
    self.finalBtn = finalBtn
    finalBtn.onClick:Add(self.onClickFinal, self)
    self.awardsText.visible = false
    self.finalBtn.visible = false
end

function FinalWinView:initData(data)
    self.killFp = data.killFp
    proxy.XmhdProxy:send(1360204,{reqType = 0,roleId = 0})
end

function FinalWinView:addMsgCallBack(data)
    self.mData = data
    if data.endFp == 1 then
        self.finalBtn.enabled = false
        self.finalBtn.icon = UIItemRes.xmhd02[2]
    else
        self.finalBtn.enabled = true
        self.finalBtn.icon = UIItemRes.xmhd02[1]
    end
    -- printt(data)
    local id = data.winTimes
    local max = table.nums(conf.XmhdConf:getXmMoreWins())
    if data.winTimes > max then
        id = max
    end
    local confData = conf.XmhdConf:getXmMoreWin(id)
    local buffId = confData and confData.buff_id or 0
    local buffData = conf.BuffConf:getBuffConf(buffId)
    if buffData then--当前buff
        self.buffText.text = string.format(language.xmhd33, buffData.desc)
    else
        self.buffText.text = string.format(language.xmhd33, language.juese04)
    end
    local confData = conf.XmhdConf:getXmWinEndAward(data.endWinTimes)
    self.awards = confData and confData.awards or {}
    if #self.awards <= 0 then
        self.awardsText.visible = false
        self.finalBtn.visible = false
    else
        self.awardsText.visible = true
        self.finalBtn.visible = true
    end
    if self.killFp == 0 then
        self.finalBtn.visible = false
    end
    self.awardsListView.numItems = #self.awards
end

function FinalWinView:cellAwardsData(index, obj)
    local award = self.awards[index + 1]
    local itemData = {mid = award[1], amount = award[2], bind = award[3]}
    GSetItemData(obj, itemData, true)
end

function FinalWinView:onClickFinal()
    local job = cache.PlayerCache:getGangJob()
    if job ~= 4 then
        GComAlter(language.xmhd30)
        return
    end
    local data = {func = function(roleId)
        proxy.XmhdProxy:send(1360204,{reqType = 2,roleId = roleId})
    end}
    mgr.ViewMgr:openView2(ViewName.ChooseTipView, data)
end

return FinalWinView