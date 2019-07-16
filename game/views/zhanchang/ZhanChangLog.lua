--
-- Author: ohf
-- Date: 2017-05-04 10:38:51
--
--战场日志
local ZhanChangLog = class("ZhanChangLog", base.BaseView)

local lessALl = 1--大减
local addAll = 2--大加
local less = 3--小减
local add = 4--小加

function ZhanChangLog:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ZhanChangLog:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n10")
    self.listView.itemRenderer = function(index,obj)
        self:cellRankData(index, obj)
    end
    self.listView.numItems = 0

    self.topDesc3 = self.view:GetChild("n6")

    self.rankText = self.view:GetChild("n17")
    self.rankText.text = "1/1"
    local leftBtn1 = self.view:GetChild("n14")
    leftBtn1.data = lessALl
    leftBtn1.onClick:Add(self.onClickUpdate,self)
    local rightBtn1 = self.view:GetChild("n13")
    rightBtn1.data = addAll
    rightBtn1.onClick:Add(self.onClickUpdate,self)
    local leftBtn2 = self.view:GetChild("n16")
    leftBtn2.data = less
    leftBtn2.onClick:Add(self.onClickUpdate,self)
    local rightBtn2 = self.view:GetChild("n15")
    rightBtn2.data = add
    rightBtn2.onClick:Add(self.onClickUpdate,self)
    self.desc = self.view:GetChild("n18")
    self.desc.text = language.gonggong49
end

function ZhanChangLog:initData(data)
    
end

function ZhanChangLog:setData(data)
    printt(data)
    self.mData = data
    self.logs = {}
    self.sumPage = self.mData.sumPage
    if data.msgId == 5350102 then--问鼎日志
        self.logs = self.mData.wenDingLogs
        self.topDesc3.text = language.wending21
        table.sort(self.logs, function(a,b)
            return a.ranking < b.ranking
        end)
        self.sumPage = self.mData.sumPage
    elseif data.msgId == 5420102 then--仙魔战日志
        self.logs = self.mData.logs
        table.sort(self.logs, function(a,b)
            return a.rank < b.rank
        end)
        self.topDesc3.text = language.xianmoWar11
        self.sumPage = self.mData.pageSum
    end
    local len = #self.logs
    if self.sumPage <= 0 then
        self.sumPage = 1
    end
    self.rankText.text = self.mData.page.."/"..self.sumPage
    if len <= 0 then
        self.desc.visible = true
    else
        self.desc.visible = false
    end
    self.listView.numItems = len
    if len > 0 then
        self.listView:ScrollToView(0)
    end
end

function ZhanChangLog:cellRankData(index,cell)
    local data = self.logs[index + 1]
    local icon = cell:GetChild("n1")
    local rankText = cell:GetChild("n2")
    local rank = data.ranking--排名
    local name = data.name--名字
    local msg3Text = data.maxFloor
    local killNum = data.killNum--击杀数量
    local maxEvenKill = data.maxEvenKill--最大连杀数量
    local roleId = data.roleId --玩家id
    local uId = string.sub(roleId,1,3)
    cell:GetChild("n9").visible = false
    if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(roleId) > 10000 then
       cell:GetChild("n9").visible = true
    end
    if self.mData.msgId == 5350102 then--问鼎日志
        rank = data.ranking
        name = data.name
        msg3Text = data.maxFloor
        killNum = data.killNum
        maxEvenKill = data.maxEvenKill
    elseif self.mData.msgId == 5420102 then--仙魔战日志
        rank = data.rank
        name = data.roleName
        local campNames = conf.XianMoConf:getValue("camp_name")
        msg3Text = campNames[data.campId]
        killNum = data.killCount
        maxEvenKill = data.maxConKillCount
    end
    if rank <= #UIItemRes.zhangchang01 then
        rankText.visible = false
        icon.url = UIItemRes.zhangchang01[rank]
        icon.visible = true
    else
        icon.visible = false
        rankText.visible = true
    end
    rankText.text = rank
    local nameText = cell:GetChild("n3")
    nameText.text = name
    local maxText = cell:GetChild("n4")
    maxText.text = msg3Text
    local killText = cell:GetChild("n5")
    killText.text = killNum
    local maxKillText = cell:GetChild("n6")
    maxKillText.text = maxEvenKill
    local scoreText = cell:GetChild("n7")
    scoreText.text = data.score--积分
end

function ZhanChangLog:onClickUpdate(context)
    if not self.mData then return end
    local btn = context.sender
    local index = btn.data
    local page = self.mData.page
    if index == lessALl then
        page = 1
    elseif index == addAll then
        page = self.sumPage
    elseif index == less then
        page = page - 1
    elseif index == add then
        page = page + 1
    end
    if page < 1 then
        page = 1
        GComAlter(language.gonggong47)
        return
    elseif page > self.sumPage then
        page = self.sumPage
        GComAlter(language.gonggong48)
        return
    end
    if self.mData.msgId == 5350102 then--问鼎日志
         proxy.WenDingProxy:send(1350102,{page = page})
    elseif self.mData.msgId == 5420102 then--仙魔战日志
        proxy.XianMoProxy:send(1420102,{page = page})
    end
end

return ZhanChangLog