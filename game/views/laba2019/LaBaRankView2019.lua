--
-- Author: 
-- Date: 2019-01-03 17:21:09
--

local LaBaRankView2019 = class("LaBaRankView2019", base.BaseView)

function LaBaRankView2019:ctor()
    LaBaRankView2019.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function LaBaRankView2019:initView()
    local closeBtn =self.view:GetChild("n23")
    self:setCloseBtn(closeBtn)

    local ruleBtn = self.view:GetChild("n13")
    ruleBtn.onClick:Add(self.onClickRule,self)
    --活动倒计时
    self.timeText = self.view:GetChild("n10")
    --排名
    self.rankText =self.view:GetChild("n11")
    --超越上名所需元宝
    self.needYbText =self.view:GetChild("n12")
    self.model = self.view:GetChild("n24")
    self.rankList= self.view:GetChild("n4")
    self.awardList= self.view:GetChild("n8")
    self:initRankList()
    self:initAwardList()
end


function LaBaRankView2019:initData()
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self:setModel()
    self.rankList:ScrollToView(0,false)
    self.awardList:ScrollToView(0,false)
end

function LaBaRankView2019:initRankList(  )
    -- body
    self.rankList.itemRenderer=function(index, obj)
        self:cellData(index,obj)
    end
    self.rankList:SetVirtual()
    self.rankList.numItems=0
end

function LaBaRankView2019:cellData(index, obj)
    -- body
    local data =self.data.rankingInfos[index+1]
    local rankText = obj:GetChild("n1")
    local nameText = obj:GetChild("n2")
    local c1 = obj:GetController("c1")
    if data then 
        rankText.text = data.ranking
        if self.data.mine.ranking == 1 then 
            nameText.text = data.roleName
        else
            if data.ranking == 1 then 
                nameText.text = language.labaRank06
            else
                nameText.text = data.roleName
            end
        end
        if data.ranking <= 3 and data.ranking ~=0 then 
            c1.selectedIndex = data.ranking
        else
            c1.selectedIndex = 0
        end
    else
        rankText.text = index + 1
        nameText.text = language.rank03
        if index < 3 then 
            c1.selectedIndex = index + 1
        else
            c1.selectedIndex = 0
        end
    end
end

function LaBaRankView2019:initAwardList(  )
    -- body
    self.awardList.itemRenderer=function(index, obj)
        self:cellAwardData(index,obj)
    end
    self.awardList:SetVirtual()
    self.awardList.numItems=0
end

function LaBaRankView2019:cellAwardData(index, obj)
    -- body
    local data = self.giftData[index+1]
    local awardList = obj:GetChild("n0")
    local title = obj:GetChild("n1")
    if data then 
        GSetAwards(awardList, data.items)
        local temp = ""
        if data.ranking[1] == data.ranking[2] then 
            temp = language.labaRank03
        else
            temp = language.labaRank02
        end
        title.text = string.format(temp,data.ranking[1],data.ranking[2])
    end
end

function LaBaRankView2019:onClickRule()
    GOpenRuleView(1171)
end

--获得指定名次的积分信息
function LaBaRankView2019:getMoneyByNum(num)
    -- body
    for k,v in pairs(self.data.rankingInfos) do
        if v.ranking and v.ranking ==num then
            return v.money
        end
    end
end

function LaBaRankView2019:setData(data)
    self.data= data
    local maxRank=conf.LaBaConf2019:getValue("lb_rank_max")
    self.rankList.numItems = maxRank--  #self.data.rankingInfos > maxRank and #self.data.rankingInfos or maxRank
    --当前排名
    local str =""
    if data.mine.ranking == 0 or data.mine.ranking>maxRank then 
        str = language.labaRank05
    else
        str = string.format(language.laba2019Rank04,data.mine.ranking)
    end
    self.rankText.text =str
    --元宝差距
    local leftYb = data.before - data.mine.money
    -- print(" data.mine.ranking", data.mine.ranking)
    if  data.mine.ranking == 0 then 
        self.needYbText.visible = false
    else
        if data.mine.ranking>maxRank then--排名大于排行榜最末名次名
            leftYb = self:getMoneyByNum(maxRank)-data.mine.money
            self.needYbText.text = string.format(language.laba2019Rank01,maxRank,leftYb+1)
        end
        if data.mine.ranking ==1 then--第一名
            if self:getMoneyByNum(2) then
                leftYb = data.mine.money-self:getMoneyByNum(2)
                self.needYbText.text = string.format(language.laba2019Rank03,leftYb+1)
            else
                leftYb = data.mine.money
                self.needYbText.text = string.format(language.laba2019Rank05)
            end
            
        elseif data.mine.ranking <=maxRank then--20名内
            self.needYbText.text = string.format(language.laba2019Rank02,leftYb+1)
        end
        self.needYbText.visible = true 
    end
    if not self.timer then
        self:timeTick()
        self.timer = self:addTimer(1, -1, handler(self,self.timeTick))
    end

    local sex = cache.PlayerCache:getSex()
    self.rankData = conf.ActivityConf:getRank2019GiftBySex(sex)
    --清空礼物列表
    self.giftData=nil
    self.giftData={}
    -- local currentFlag=0
    -- local lastFlag=0
    -- local openDay = cache.ActivityCache:getLoopDay()--获取开服天数
    -- for i=1,#self.rankData,1 do
    --     if openDay<=self.rankData[i].day[2] then
    --         currentFlag=self.rankData[i].day[2]
    --         if lastFlag~=0 and lastFlag~=currentFlag then
    --             self.awardList.numItems =#self.giftData
    --             return
    --         end
    --         self.giftData[i]=self.rankData[i]
    --         lastFlag=currentFlag
    --     end
    --     if flag~=0 and flag ~=self.rankData[i].day[2] then
    --     end
    -- end
    --根据前缀来获取礼物列表
    for i=#self.rankData,1,-1 do
        --print("礼物前缀："..math.floor(self.rankData[i].id/10000))
        --print(data.cid)
        if math.floor(self.rankData[i].id/10000) == data.cid then
            table.insert(self.giftData,1,self.rankData[i])
        end
    end
    self.awardList.numItems = #self.giftData
    --self.awardList.numItems = #self.rankData
end


function LaBaRankView2019:timeTick()
    local nowTime = mgr.NetMgr:getServerTime()
    local endTime = self.data.actEndTime
    local leftTimes = endTime - nowTime
    -- local str1 = GToTimeString8(nowTime)
    -- print("现在时间",str1)
    if leftTimes > 86400 then 
        self.timeText.text = GTotimeString7(leftTimes)
    else
        self.timeText.text = GTotimeString2(leftTimes)
    end
    if leftTimes <= 0 then 
        -- local timeTab = os.date("*t",nowTime)
        -- local nowSec = timeTab.hour * 3600 + timeTab.min * 60 + timeTab.sec
        -- local showLeftTiem = 86400 - nowSec
        -- if showLeftTiem <= 0 then 
        --     showLeftTiem = 0
        --     self:closeView()
        -- end
        self:closeView()
        --self.timeText.text = GTotimeString2(showLeftTiem)
    end
end

function LaBaRankView2019:closeRankView()

end

function LaBaRankView2019:setModel()
    local sex = cache.PlayerCache:getSex()
    local modelId =4040918    --厨神模型TODO
    -- if sex ~= 1 then 
    --     modelId = 3010406
    -- end
    local effect = self:addEffect(modelId,self.model)
    effect.LocalPosition = Vector3.New(-10.5,-270.7,8)
    effect.Scale = Vector3.New(50,50,50)
    effect.LocalRotation = Vector3.New(1.25,0,0)
    --modelObj:setSkins(modelId, 3020406)
    --modelObj:setScale(220) --TODO
    -- modelObj:setRotationXYZ(0,166,0)
    -- modelObj:setPosition(0,-300,100)

end

return LaBaRankView2019