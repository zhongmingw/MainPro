--
-- Author: 
-- Date: 2018-01-11 17:31:32
--

local LabaRankView = class("LabaRankView", base.BaseView)

function LabaRankView:ctor()
    LabaRankView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function LabaRankView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n5")
    self:setCloseBtn(closeBtn)
    local ruleBtn = self.view:GetChild("n11")  
    ruleBtn.onClick:Add(self.onClickRule,self)
    --活动倒计时
    self.timeTitle = self.view:GetChild("n4")
    self.timeTxt = self.view:GetChild("n5")
    --排名
    self.rankTxt = self.view:GetChild("n6")
    --距离上一名所需元宝
    self.needYb = self.view:GetChild("n7")

    self.model = self.view:GetChild("n2")


    self.rankList = self.view:GetChild("n1")
    self.awardList = self.view:GetChild("n3")
    self:initRankList()
    self:initAwardList()
end
function LabaRankView:initRankList()
    self.rankList.itemRenderer =function(index,obj)
        self:cellData(index,obj)
    end
    self.rankList:SetVirtual()
    self.rankList.numItems = 0
end
function LabaRankView:initAwardList()
    self.awardList.itemRenderer =function(index,obj)
        self:cellAwardData(index,obj)
    end
    self.awardList:SetVirtual()
    self.awardList.numItems = 0
end

function LabaRankView:cellData(index,obj)
    local data = self.data.rankingInfos[index+1]
    local rankTxt = obj:GetChild("n1")
    local nameTxt = obj:GetChild("n2")
    local c1 = obj:GetController("c1")
    if data then 
        rankTxt.text = data.ranking
        if self.data.mine.ranking == 1 then 
            nameTxt.text = data.roleName
        else
            if data.ranking == 1 then 
                nameTxt.text = language.labaRank06
            else
                nameTxt.text = data.roleName
            end
        end
        if data.ranking <= 3 and data.ranking ~=0 then 
            c1.selectedIndex = data.ranking
        else
            c1.selectedIndex = 0
        end
    else
        rankTxt.text = index + 1
        nameTxt.text = language.rank03
        if index < 3 then 
            c1.selectedIndex = index + 1
        else
            c1.selectedIndex = 0
        end
    end
end

function LabaRankView:cellAwardData(index,obj)
    local data = self.rankData[index+1]
    local awardList = obj:GetChild("n0")
    local title = obj:GetChild("n1")
    if data then 
        GSetAwards(awardList, data.awards)
        local temp = ""
        if data.ranking[1] == data.ranking[2] then 
            temp = language.labaRank03
        else
            temp = language.labaRank02
        end
        title.text = string.format(temp,data.ranking[1],data.ranking[2])
    end
end

function LabaRankView:initData()
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self:setModel()
    self.rankList:ScrollToView(0,false)
    self.awardList:ScrollToView(0,false)
    
end

function LabaRankView:onClickRule()
    GOpenRuleView(1078)
end
function LabaRankView:setData(data)
    self.data = data
    -- printt("消费排行",data.rankingInfos)
    self.rankList.numItems = #self.data.rankingInfos > 7 and #self.data.rankingInfos or 7
    --个人排名
    local str = ""
    if data.mine.ranking == 0 then 
        str = language.labaRank05
    else
        str = string.format(language.labaRank01,data.mine.ranking)
    end
    self.rankTxt.text = str
    --元宝差距
    local leftYb = data.before - data.mine.money
    -- print(" data.mine.ranking", data.mine.ranking)
    if data.mine.ranking == 1 or data.mine.ranking == 0 then 
        self.needYb.visible = false
    else
        self.needYb.visible = true 
        self.needYb.text = string.format(language.labaRank04,leftYb+1)
    end
    if not self.timer then
        self:timeTick()
        self.timer = self:addTimer(1, -1, handler(self,self.timeTick))
    end

    local sex = cache.PlayerCache:getSex()
    self.rankData = conf.ActivityConf:getRankGiftBySex(sex)
    self.awardList.numItems = #self.rankData
end
function LabaRankView:timeTick()
    local nowTime = mgr.NetMgr:getServerTime()
    local endTime = self.data.actEndTime -7200
    local leftTimes = endTime - nowTime
    -- local str1 = GToTimeString8(nowTime)
    -- print("现在时间",str1)
    if leftTimes > 86400 then 
        self.timeTxt.text = GTotimeString7(leftTimes)
    else
        self.timeTxt.text = GTotimeString2(leftTimes)
    end
    if leftTimes <= 0 then 
        local timeTab = os.date("*t",nowTime)
        local nowSec = timeTab.hour * 3600 + timeTab.min * 60 + timeTab.sec
        local showLeftTiem = 86400 - nowSec
        self.timeTitle.text = language.labaRank07
        if showLeftTiem <= 0 then 
            showLeftTiem = 0
        end
        self.timeTxt.text = GTotimeString2(showLeftTiem)
    end
end
function LabaRankView:setModel()
    local sex = cache.PlayerCache:getSex()
    local modelId =3010306    --厨神模型TODO
    if sex ~= 1 then 
        modelId = 3010406
    end
    local modelObj = self:addModel(modelId,self.model)
    modelObj:setSkins(modelId, 3020406)
    modelObj:setScale(220) --TODO
    modelObj:setRotationXYZ(0,166,0)
    modelObj:setPosition(0,-300,100)

end



return LabaRankView
