--
-- Author: 
-- Date: 2017-07-25 10:54:05
--

local MarryKaiFuRank = class("MarryKaiFuRank", base.BaseView)

function MarryKaiFuRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function MarryKaiFuRank:initData()
    -- body
    print("marry initData~~~")
    proxy.MarryProxy:sendMsg(1390301,{page = 1})
end

function MarryKaiFuRank:initView()
    local btnClose = self.view:GetChild("n17")
    btnClose.onClick:Add(self.onBtnClose,self)
    --今天结婚人次
    self.marryCout = self.view:GetChild("n29")
    self.marryCout.text = ""
    --排行信息
    self.listView = self.view:GetChild("n12")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    local dec1 = self.view:GetChild("n9")
    dec1.text = language.kuafu80

    local dec1 = self.view:GetChild("n10")
    dec1.text = language.kuafu81

    self.myrank = self.view:GetChild("n13")

    --右边
    local  dec1 = self.view:GetChild("n31")
    dec1.text = mgr.TextMgr:getTextByTable(language.kuafu82)

    self.listreward = self.view:GetChild("n37")
    self.listreward:SetVirtual()
    self.listreward.itemRenderer = function(index,obj)
        self:cellrewarddata(index, obj)
    end
    self.listreward.numItems = 0

    self:initReward()

    --剩余倒计时
    self.labtimer = self.view:GetChild("n15")
    self.labtimer.text = ""

    --前往结婚
    local btnMarry = self.view:GetChild("n4")
    btnMarry.onClick:Add(self.onGoMarry,self)
end

function MarryKaiFuRank:setData(data_)

end

function MarryKaiFuRank:cellrewarddata(index, obj)
    -- body
    local data = self.reward.awards[index+1]
    local _t = {mid =data[1],amount=data[2],bind = data[3]}
    GSetItemData(obj,_t,true)
end
--排名奖励
function MarryKaiFuRank:initReward()
    -- body
    self.reward = conf.MarryConf:getRankRewardById(1)
    self.listreward.numItems = #self.reward.awards 
end

function MarryKaiFuRank:celldata(index, obj)
    -- body
    if index + 1 >=  self.listView.numItems then
        if self.data.page < self.data.pageSum then
            --请求下一页
            proxy.MarryProxy:sendMsg(1390301,{page = self.data.page+1})
        end
    end

    local data = self.data.rankingInfo[index+1]
    local rank = obj:GetChild("n1")
    local name1 = obj:GetChild("n3")
    local name2 = obj:GetChild("n5")
    rank.text = data.ranking
    name1.text = data.firstName
    name2.text = data.secondName
end



function MarryKaiFuRank:onBtnClose()
    -- body
    self:closeView()
end
function MarryKaiFuRank:onTimer()
    -- body
    if not self.data then
        return
    end

    self.data.dayLeftTime = self.data.dayLeftTime - 1
    if self.data.dayLeftTime < 0 and not self.requst then
        self.data.dayLeftTime = 0
        self.requst = true
        self.labtimer.text = ""

        proxy.MarryProxy:sendMsg(1390301,{page = 1})
        return
    end
    if self.data.dayLeftTime < 0 then
        self.data.dayLeftTime = 0
    end
    
    self.labtimer.text = string.format(language.kuafu79,GTotimeString(self.data.dayLeftTime))
end

function MarryKaiFuRank:onGoMarry()
    -- body
    if mgr.FubenMgr:checkScene() then
        GComAlter(language.gonggong41)
        return
    end
    
    mgr.TaskMgr:setCurTaskId(9003)
    mgr.TaskMgr.mState = 2
    mgr.TaskMgr:resumeTask()

end


function MarryKaiFuRank:add5390301(data)
    -- body
    if data.page == 1 then
        self.data = {}
        self.data.dayLeftTime = data.dayLeftTime
        self.data.myRanking = data.myRanking
        self.data.marrySize = data.marrySize
        self.data.page = data.page
        self.data.pageSum = data.pageSum
        self.data.rankingInfo = data.rankingInfo
    else
        if not self.data then
            self.data = {}
            self.data.rankingInfo = {}
        end
        self.data.dayLeftTime = data.dayLeftTime
        self.data.myRanking = data.myRanking
        self.data.marrySize = data.marrySize
        self.data.page = data.page
        self.data.pageSum = data.pageSum
        for k , v in pairs(data.rankingInfo) do
            table.insert(self.data.rankingInfo,v)
        end
    end

    --开始设置信息
    --结婚人次
    local _t = clone(language.kuafu84)
    _t[2].text = string.format(_t[2].text,self.data.marrySize)
    self.marryCout.text = mgr.TextMgr:getTextByTable(_t)

    --排名信息
    self.listView.numItems = #self.data.rankingInfo

    if data.myRanking > 0 then
        self.myrank.text = string.format(language.kuafu83,tostring(data.myRanking) )
    else
        self.myrank.text = string.format(language.kuafu83,language.kuafu50)
    end

    if self.tiemer then
        self:removeTimer(self.tiemer)
    end
    self:onTimer()
    self.tiemer = self:addTimer(1, -1, handler(self,self.onTimer))
end

return MarryKaiFuRank