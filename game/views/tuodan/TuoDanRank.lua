--
-- Author: 
-- Date: 2018-10-31 11:35:00
--

local TuoDanRank = class("TuoDanRank", base.BaseView)

function TuoDanRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale 
end

function TuoDanRank:initView()
    local closeBtn = self.view:GetChild("n29")
    self:setCloseBtn(closeBtn)
    self.actCountDownText = self.view:GetChild("n27")
    self.myRankText = self.view:GetChild("n24")
    self.totalRechargeText = self.view:GetChild("n25")
    local ruleBtn = self.view:GetChild("n31")
    ruleBtn.onClick:Add(self.ruleBtnClick,self)
    local marryBtn = self.view:GetChild("n22")
    marryBtn.onClick:Add(self.btnOnClick,self)
    local rechargeBtn = self.view:GetChild("n23")
    rechargeBtn.onClick:Add(self.btnOnClick,self)
    local rewardBtn = self.view:GetChild("n28")
    rewardBtn.onClick:Add(self.btnOnClick,self)

    self.rankList = self.view:GetChild("n16")
    self.rankList.itemRenderer = function (index,obj)
        self:setRankData(index,obj)
    end 
    self.rankList.numItems = 0
    self.rankList:SetVirtual()

    self.modle_man = self.view:GetChild("n30")
    self.modle_women = self.view:GetChild("n37")
end

--[[
变量名：lastTime    说明：剩余时间
变量名：myRank  说明：我的排名
变量名：myCz    说明：我的充值
变量名：rankInfos   说明：排名信息
--]]
function TuoDanRank:setData(data)
    self.data = data
    -- printt("情侣充值排行榜>>>",data)
    -- printt("排名信息>>>",data.rankInfos)
    self.actCountDown = data.lastTime
    self.totalRechargeText.text = data.myCz 
    self.awardConf = conf.ActivityConf:getLoversAward()
    local minRechargeCount = conf.ActivityConf:getHolidayGlobal("qlcz_min_value") -- 情侣充值最低上榜充值
    if data.myCz < minRechargeCount then
        self.myRankText.text = "未上榜"
    else
        if data.myRank <= 10 then
            if data.myRank == 0 and data.myCz >= minRechargeCount then
                self.myRankText.text = language.xianzhuangrank07     
            else
                self.myRankText.text = data.myRank
            end 
        elseif data.myRank > 10 then
            self.myRankText.text = language.xianzhuangrank07
        end
    end
    -- TODO


    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.rankList.numItems = 10

    self:initModle()
end

function TuoDanRank:initModle()
    -- local petId = conf.ActivityConf:getHolidayGlobal("marry_huoban_id")
    -- local confdata = conf.HuobanConf:getSkinsData(petId)

    local manId = conf.ActivityConf:getHolidayGlobal("qlcz_man_modle")
    local womenId = conf.ActivityConf:getHolidayGlobal("qlcz_women_modle")

    -- local petModelId = confdata.modle_id
    local model_man = self:addModel(manId[1],self.modle_man)
    model_man:setSkins(manId[1], manId[2])
    model_man:setScale(SkinsScale[Skins.huoban])
    model_man:setRotationXYZ(0,166,0)
    model_man:setPosition(74,-362,435)

    local model_women = self:addModel(womenId[1],self.modle_women)
    model_women:setSkins(womenId[1], womenId[2])
    model_women:setScale(SkinsScale[Skins.huoban])
    model_women:setRotationXYZ(0,166,0)
    model_women:setPosition(74,-362,435)
end

-- {coupleName=,roleId=1011000220100000121,quota=10000,rank=1,coupleId=0,roleName=S2.乌明诚}
function TuoDanRank:setRankData(index,obj)
    if not self.data then return end
    local rankInfo = self.data.rankInfos[index+1]
    local rank = obj:GetChild("n6")
    local manName = obj:GetChild("n0")
    local womanName = obj:GetChild("n1")    
    local totalRecharge = obj:GetChild("n2")
    local c1 = obj:GetController("c1")
    local kuaFuIcon = obj:GetChild("n8")
    rank.text = index + 1
    if index <= 3 then
        c1.selectedIndex = index
    else
        c1.selectedIndex = 3        
    end
    if rankInfo then
        manName.text = rankInfo.roleName
        womanName.text = rankInfo.coupleName        
        totalRecharge.text = rankInfo.quota
        local uId = string.sub(rankInfo.roleId,1,3)
        kuaFuIcon.visible = cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(rankInfo.roleId) > 10000
        -- local uId1 = string.sub(rankInfo.coupleId,1,3)
        -- kuaFuIcon.visible = cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId1) and tonumber(rankInfo.coupleId) > 10000
    else
        manName.text = language.shenqirank05
        womanName.text = language.shenqirank05
        totalRecharge.text = language.marryRank04
    end
end

function TuoDanRank:ruleBtnClick()
    GOpenRuleView(1154)
end

function TuoDanRank:btnOnClick(context)
    local btn = context.sender
    if btn.name == "n22" then
        mgr.ViewMgr:openView2(ViewName.MarryMainView,{index = 1})
        self:closeView()
        return
    elseif btn.name == "n23" then
        GOpenView({id = 1042})
        self:closeView()
        return
    elseif btn.name == "n28" then
        -- 奖励列表
        -- printt(awardData)
        mgr.ViewMgr:openView2(ViewName.TuoDanAward,{awardData = self.awardConf})
    end
end

function TuoDanRank:onTimer()
    if not self.data then return end
    self.actCountDown = math.max(self.actCountDown - 1,0)
    if self.actCountDown <= 0 then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
        self:closeView()
        return
    end
    if self.actCountDown >= 86400 then
        self.actCountDownText.text = mgr.TextMgr:getTextColorStr(GGetTimeData3(self.actCountDown),7) 
    else
        self.actCountDownText.text = mgr.TextMgr:getTextColorStr(GGetTimeData4(self.actCountDown),7) 
    end
end

return TuoDanRank