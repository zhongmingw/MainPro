--
-- Author: 
-- Date: 2017-11-28 20:42:53
--
--连胜奖励
local WinAwardsView = class("WinAwardsView", base.BaseView)

function WinAwardsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function WinAwardsView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n2")--奖励
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0

    self.winCountText = self.view:GetChild("n3")--连胜次数
end

function WinAwardsView:initData(data)
    proxy.XmhdProxy:send(1360204,{reqType = 0,roleId = 0})
end

function WinAwardsView:addMsgCallBack(data)
    self.mData = data
    self.winCountText.text = language.xmhd10..mgr.TextMgr:getTextColorStr(data.winTimes, 7)
    local num = table.nums(conf.XmhdConf:getXmMoreWins())
    self.maxCount = num
    self.listView.numItems = num
end

function WinAwardsView:cellData(index, obj)
    local confData = conf.XmhdConf:getXmMoreWin(index + 2)
    if confData then
        local id = confData.id or 1
        obj:GetChild("n4").text = string.format(language.xmhd11, id)
        local awards = confData.awards or {}
        local listView = obj:GetChild("n2")
        listView.itemRenderer = function(index,itemObj)
            local award = awards[index + 1]
            local itemData = {mid = award[1], amount = award[2], bind = award[3]}
            GSetItemData(itemObj, itemData, true)
        end
        listView.numItems = #awards

        local btn = obj:GetChild("n3")
        btn.onClick:Add(self.onClickFp,self)
        local isFlag = false
        if self.mData.winTimes == id then
            isFlag = true
        elseif self.mData.winTimes > self.maxCount and id >= self.maxCount then
            isFlag = true
        end
        if isFlag then
            btn.visible = true
            local fpMap = self.mData.fpMap or {}
            local state = fpMap[id]
            if state and state > 0 then
                if state == 1 then--已分配
                    btn.icon = UIItemRes.xmhd02[2]
                elseif state == 2 then--已错过
                    btn.icon = UIItemRes.xmhd02[1]
                end
                btn.enabled = false
            else
                btn.icon = UIItemRes.xmhd02[1]
                btn.enabled = true
            end
        else
            btn.visible = false
        end
    end
end

function WinAwardsView:onClickFp(context)
    local job = cache.PlayerCache:getGangJob()
    if job ~= 4 then
        GComAlter(language.xmhd30)
        return
    end
    local data = {func = function(roleId)
        proxy.XmhdProxy:send(1360204,{reqType = 1,roleId = roleId})
    end}
    mgr.ViewMgr:openView2(ViewName.ChooseTipView, data)
end

return WinAwardsView