--
-- Author: EVE 
-- Date: 2017-08-01 20:15:06
--

local Active1020 = class("Active1020", base.BaseView)

function Active1020:ctor(param)
    self.view = param
    self:initView()
end

function Active1020:initView()
    self.activeOverTime = self.view:GetChild("n9")  --活动结算时间
    self.activeOverTime.text = ""
    self.activeShowTime = self.view:GetChild("n2")   --展示时间
    self.oursScore = self.view:GetChild("n10")  --我的仙盟分数
    self.oursScore.text = ""
    self.ranking = self.view:GetChild("n11")  --我的仙盟排行
    self.ranking.text = ""
    self.listRewardView = self.view:GetChild("n12") --仙盟排行奖励
    self:initListRewardView()
    local btnRankingListView = self.view:GetChild("n7") --仙盟排行弹窗
    btnRankingListView.onClick:Add(self.onRankingView, self)
end

function Active1020:initListRewardView()
    self.listRewardView.numItems = 0
    self.listRewardView.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.listRewardView:SetVirtual()
end

function Active1020:itemData(index, obj)
    local data = self.cellConf[index+1]
    local newData = self.rankingInfos[index+1]  

    local ranking = obj:GetChild("n5")   --排名
    if data.ranking[1] == data.ranking[2] then 
        ranking.text = data.ranking[1]
    else
        ranking.text = data.ranking[1] .. "-" .. data.ranking[2]
    end

    local GangName = obj:GetChild("n11")
    GangName.text = newData and newData.gangName or language.gangRanking03

    local score = obj:GetChild("n12")
    score.text = (newData and newData.score or "0")..language.gangRanking01

    for i=1,4 do    --奖励
        local reward = obj:GetChild("n".. i)
        local infoReward = nil
        if i <= 2 then 
            if data.monstor_awards[i] then
                local mId = data.monstor_awards[i][1]
                local number = data.monstor_awards[i][2]
                local bind = data.monstor_awards[i][3]
                infoReward = {mid=mId,amount=number,bind=bind}
                GSetItemData(reward,infoReward,true) 
            else
                reward.visible = false
            end
            -- printt(infoReward)
        else
            if data.member_awards[i-2] then
                local mId = data.member_awards[i-2][1]
                local number = data.member_awards[i-2][2]
                local bind = data.member_awards[i-2][3]
                infoReward = {mid=mId,amount=number,bind=bind}
                GSetItemData(reward,infoReward,true) 
            else
                reward.visible = false
            end
        end
    end
end

function Active1020:setCurId(id)
    -- body
    self.id = id
end

function Active1020:onTimer()
    -- body
    -- plog("你是猪!")
    if self.data then
        self.data.lastTime = self.data.lastTime-1
        self.activeOverTime.text = GGetTimeData2(self.data.lastTime)
        if self.data.lastTime <= 0 then 
            proxy.ActivityProxy:sendMsg(1030126)
        end 
    end 
end

function Active1020:setOpenDay( day )  --蛋蛋用
    -- body
    -- self.c1.selectedIndex = day - 1 
end

function Active1020:onRankingView()
    local view = mgr.ViewMgr:get(ViewName.RankingTips)
    if not view then 
        mgr.ViewMgr:openView2(ViewName.RankingTips, self.data)
    end 
end

function Active1020:add5030126(data)
    -- printt(data)
    -- plog("~~~~~~~~~~~~~~~~~~~~~~~~~~~33333333333")
    self.data = data
    self.rankingInfos = self.data.rankingInfos

    self.oursScore.text = self.data.myGangScore .. language.gangRanking01   --积分
    self.ranking.text = self.data.myGangRank

    if self.data.showTime == 1 then 
        self.activeShowTime.text = language.gangRanking02
    end 

    self.cellConf = conf.ActivityConf:getGangRankReward()
    table.sort(self.cellConf,function(a,b)
        return a.id < b.id
    end)
    self.listRewardView.numItems = #self.cellConf
end 



return Active1020