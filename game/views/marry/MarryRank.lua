--
-- Author: 
-- Date: 2018-07-06 12:00:49
--

local MarryRank = class("MarryRank", base.BaseView)

function MarryRank:ctor()
    MarryRank.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function MarryRank:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n5")
    closeBtn.onClick:Add(self.onBtnClose,self)
    local bg = self.view:GetChild("n0"):GetChild("n0")
    bg.url = UIItemRes.marryRankBg

    local dec1 = self.view:GetChild("n1")
    dec1.text = language.marryRank01

    local dec2 = self.view:GetChild("n11")
    dec2.text = language.marryRank02

    local dec3 = self.view:GetChild("n13")
    dec3.text = language.marryRank03

    local dec4 = self.view:GetChild("n27")
    self.minHot = conf.ActivityConf:getHolidayGlobal("wedding_hotdegree_rank_limit")
    dec4.text = string.format(language.marryRank07,tonumber(self.minHot))

    self.lastTime = self.view:GetChild("n2")
    self.lastTime.text = ""

    self.myRankTxt = self.view:GetChild("n12")
    self.myRankTxt.text = ""

    self.myHotTxt = self.view:GetChild("n14")
    self.myHotTxt.text = ""

    local ruleBtn = self.view:GetChild("n26")  
    ruleBtn.onClick:Add(self.onClickRule,self)

    -- local goMarryBtn = self.view:GetChild("n3")  
    -- goMarryBtn.onClick:Add(self.goMarry,self)

    -- local hunLiBtn = self.view:GetChild("n5")  
    -- hunLiBtn.onClick:Add(self.goHunLi,self)

    local awardBtn = self.view:GetChild("n7")  
    awardBtn.onClick:Add(self.onClickAward,self)

    self.petPanel = self.view:GetChild("n9")


end

function MarryRank:initData()
    self.rankList = self.view:GetChild("n10")
    self.rankList.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.rankList:SetVirtual()
    local img = self.view:GetChild("n6")
    local hunLiBtn = self.view:GetChild("n5")  

    local coupleName = cache.PlayerCache:getCoupleName()
    if coupleName == "" then
        hunLiBtn.data = 1
        img.url = UIPackage.GetItemURL("marry" , "hunlipaihengbang_009")--前往结婚
    else
        hunLiBtn.data = 2
        img.url = UIPackage.GetItemURL("marry" , "hunlipaihengbang_010")--举办婚礼
    end
    hunLiBtn.onClick:Add(self.onClickHunLi,self)
    self:initModel()
end

function MarryRank:cellData(index,obj)
    local data = self.data.rankInfos[index+1]
    local boyName = obj:GetChild("n0")
    local gilrName = obj:GetChild("n1")
    local score = obj:GetChild("n2")
    local rank = obj:GetChild("n3")
    local c1 = obj:GetController("c1")
    local rank = obj:GetChild("n6")
    rank.text = index+1
    if index <= 3 then
        c1.selectedIndex = index
    else
        c1.selectedIndex = 3
    end
    if data then 
        boyName.text = data.firstName
        gilrName.text = data.secondName
        score.text = data.value


    else
        boyName.text = language.shenqirank05
        gilrName.text = language.shenqirank05
        score.text = language.marryRank04
    end
end

function MarryRank:initModel()
    local petId = conf.ActivityConf:getHolidayGlobal("marry_huoban_id")
    local confdata = conf.HuobanConf:getSkinsData(petId)
    if not confdata then 
        plog("@策划 伙伴配置里面没有",petId)
        return
    else
        local petModelId = confdata.modle_id
        local modelObj = self:addModel(petModelId,self.petPanel)
        modelObj:setScale(SkinsScale[Skins.huoban])
        modelObj:setRotationXYZ(0,166,0)
        modelObj:setPosition(53,-328,430)
    end
end
--前往结婚
function MarryRank:goMarry()
    -- body
    if mgr.FubenMgr:checkScene() then
        GComAlter(language.gonggong41)
        return
    end
    local mainTaskId = cache.TaskCache:getCurMainId()
    -- print("当前主线任务id>>>>>>>>>",mainTaskId)
    if mainTaskId <= 1014 and mainTaskId ~= 0 then
        GComAlter(language.task20)
        return
    end
    
    mgr.TaskMgr:setCurTaskId(9003)
    mgr.TaskMgr.mState = 2
    mgr.TaskMgr:resumeTask()
end
--预约婚礼
function MarryRank:goHunLi()
    local coupleName = cache.PlayerCache:getCoupleName()
    if coupleName and coupleName ~= "" then
        proxy.MarryProxy:sendMsg(1390302,{reqType = 0})
    else
        GComAlter(language.marryiage32)
    end
end

function MarryRank:onClickHunLi(context)
    local data = context.sender.data
    if data == 1 then--前往结婚
        self:goMarry()
    elseif data == 2 then--预约婚礼
        self:goHunLi()
    end
end

function MarryRank:onClickAward()
    mgr.ViewMgr:openView2(ViewName.MarryRankAward,{actId = self.data.actId})

end

function MarryRank:setData(data)
    self.data = data
    printt("婚礼排行",data)
    self.actId = data.actId
    self.time = data.lastTime
    local str = ""
    if tonumber(data.myRank) == 0 and  tonumber(data.myHotValue) > self.minHot then
        str = language.marryRank06--10名以后
    elseif tonumber(data.myRank) == 0 then
        str = language.marryRank05 --未上榜
    else
        str = data.myRank
    end
    self.myRankTxt.text = str
    self.myHotTxt.text = data.myHotValue
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

    local limt = conf.ActivityConf:getHolidayGlobal("marry_rank_people_limt")
    self.rankList.numItems = limt
end

function MarryRank:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:onBtnClose()
    end

    self.time = self.time - 1
end


function MarryRank:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function MarryRank:onClickRule()
    GOpenRuleView(1097)
end

function MarryRank:onBtnClose()
    self:releaseTimer()
    self:closeView()
end

return MarryRank