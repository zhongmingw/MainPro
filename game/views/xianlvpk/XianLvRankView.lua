--
-- Author: 
-- Date: 2018-07-24 14:44:08
--

local XianLvRankView = class("XianLvRankView", base.BaseView)

function XianLvRankView:ctor()
    XianLvRankView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function XianLvRankView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    self.listView = self.view:GetChild("n8")

    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    -- self.listView.onClickItem:Add(self.onClickList,self) 
    self.listView:SetVirtual()

    self.myRank = self.view:GetChild("n36")
    self.myRank.text = ""
end
local RankByType = {
    [0] = {},
    [1] = {},
    [2] = {},
}

function XianLvRankView:setData(data)
    -- printt("排行榜信息",data)
    self.data = data
    self.c1.selectedIndex = data.reqType
    
    self.rankList ={}
    if data.reqType == 0 then--只有海选需要分页
        local page = data.page
        if self.mData and page and page > 1 then
            if data and self.mData.page < page and data.rankList then
                self.mData.page = page
                self.mData.pageSum = data.pageSum
                for _,v in pairs(data.rankList) do
                    table.insert(self.mData.rankList, v)
                end
            end
        else
            self.mData = {}
            self.mData.page = data.page
            self.mData.pageSum = data.pageSum
            self.mData.rankList = data.rankList
        end
        self.rankList = self.mData.rankList

    else
        self.rankList = data.rankList
    end
    self.listView.numItems = #self.rankList

    if data.myRank == 0 then
        self.myRank.text = language.rank04
    else
        self.myRank.text = string.format(language.kaifu12,data.myRank)
    end
end

function XianLvRankView:initData(data)
    self.msgId = data and data.msgId
end

function XianLvRankView:onController()
    local page = 1
    if self.c1.selectedIndex == 0 then
        page = 1
    else
        page = 0
    end
    -- print("reqType",self.c1.selectedIndex,"page",page)
    self.listView:ScrollToView(0,false)
    local msgId
    if self.msgId == 5540101 then
        msgId = 1540103
    elseif self.msgId == 5540201 then
        msgId = 1540203
    end
    proxy.XianLvProxy:sendMsg(msgId,{reqType = self.c1.selectedIndex,page = page})
end

function XianLvRankView:cellData(index, obj)
    if self.c1.selectedIndex == 0 then
        if index + 1 >= self.listView.numItems then
            if not self.rankList then
                return
            end
            if self.mData.page < self.mData.pageSum then 
                local msgId
                if self.msgId == 5540101 then
                    msgId = 1540103
                elseif self.msgId == 5540201 then
                    msgId = 1540203
                end
                proxy.XianLvProxy:send(msgId,{reqType = self.c1.selectedIndex,page = self.mData.page + 1})
            end
        end
    end
    local data = self.rankList[index+1]
    local c1 = obj:GetController("c1")
    local c2 = obj:GetController("c2")--位置控制
    local rank = obj:GetChild("n2")
    local teamName = obj:GetChild("n3")
    local power = obj:GetChild("n5")
    local winNum = obj:GetChild("n8")
    c2.selectedIndex = self.data.reqType == 0 and 0 or 1
    

    c1.selectedIndex = index < 3 and index or 3 
    if data then
        obj.data = data.teamId
        teamName.text = data.teamName
        power.text = data.power
        if self.data.reqType == 0 then
            rank.text = data.rank
        else 
            if data.rank == 0 then
                c1.selectedIndex = 3
                rank.text = "暂无"
            else
                rank.text = data.rank
            end
        end
        if self.c1.selectedIndex == 0 then--参与场数
           winNum.text = data.winCount
        end
    end
    obj.onClick:Add(self.seeTeamInfo,self)
end

function XianLvRankView:seeTeamInfo(context)
    local teamId = context.sender.data
    -- print("队伍id",teamId)
    local msgId
    if self.msgId == 5540101 then
        msgId = 1540108
    elseif self.msgId == 5540201 then
        msgId = 1540208
    end
    mgr.ViewMgr:openView(ViewName.TeamInfoView,function ()
        proxy.XianLvProxy:sendMsg(msgId,{teamId = teamId})
    end)
end

return XianLvRankView