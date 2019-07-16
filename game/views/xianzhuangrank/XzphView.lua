--
-- Author: 
-- Date: 2018-09-06 10:02:49
--

local XzphView = class("XzphView", base.BaseView)

function XzphView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.openTween = ViewOpenTween.scale
end

function XzphView:initView()
    --关闭按钮
    local closeBtn = self.view:GetChild("n32")
    self:setCloseBtn(closeBtn)
    --获取仙装按钮
    self.getBtn = self.view:GetChild("n21")
    self.getBtn.onClick:Add(self.btnClick,self)
    --活动介绍按钮
    self.infoBtn = self.view:GetChild("n31")
    self.infoBtn.onClick:Add(self.btnClick,self)
    --奖励列表
    self.awardList = self.view:GetChild("n13")
    self.awardList.numItems = 0
    self.awardList.itemRenderer = function (index,obj)
        self:cellAwardData(index,obj)
    end
    self.awardList:SetVirtual()
    --排行列表
    self.rankList = self.view:GetChild("n26")
    self.rankList.numItems = 0
    self.rankList.itemRenderer = function (index,obj)
        self:cellRankData(index,obj)
    end
    self.rankList:SetVirtual()
    --活动倒计时文本
    self.actCountDownText = self.view:GetChild("n34")
    --名次文本
    self.rankText = self.view:GetChild("n35")

    local str1 = self.view:GetChild("n12")--活动结束后将奖励通过邮件发送
    str1.text = language.xianzhuangrank01
    local str2 = self.view:GetChild("n23")--活动倒计时
    str2.text = language.xianzhuangrank02
    local str3 = self.view:GetChild("n24")--我的名次
    str3.text = language.xianzhuangrank03
    local str4 = self.view:GetChild("n28")--名次
    str4.text = language.xianzhuangrank04
    local str5 = self.view:GetChild("n29")--仙主
    str5.text = language.xianzhuangrank05
    local str6 = self.view:GetChild("n30")--总战力
    str6.text = language.xianzhuangrank06
end

function XzphView:initData()
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1,-1,handler(self, self.onTimer))
    end
end

function XzphView:onTimer()
    if not self.data then return end
    self.actLeftTime = math.max(self.actLeftTime - 1,0)
    if self.actLeftTime <= 0 then
        self:releaseTimer()
        self:closeView()
        return
    end
    if self.actLeftTime > 86400 then
        self.actCountDownText.text = GTotimeString7(self.actLeftTime)
    else
        self.actCountDownText.text = GTotimeString(self.actLeftTime)
    end
end

function XzphView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function XzphView:setData(data)
    self.data = data
    self.actLeftTime = data.lastTime
    self.awardConf = conf.ActivityConf:getXzphAward()
    self.awardList.numItems = #self.awardConf
    local mRank = self.data.myRank
    self.rankConf = conf.ActivityConf:getHolidayGlobal("xian_equip_min_value")
    self.maxItemNumsConf = conf.ActivityConf:getHolidayGlobal("xian_equip_max_rank")
    self.rankList.numItems = self.maxItemNumsConf
    --print(self.data.myRank,self.data.myPower)
    if self.data.myPower < self.rankConf then
        self.rankText.text = string.format(language.xianzhuangrank08,self.rankConf)
    else
        if mRank <= 10 then
            if mRank == 0 then
                if self.data.myPower >= self.rankConf then
                    self.rankText.text = language.xianzhuangrank07
                else
                    self.rankText.text = string.format(language.xianzhuangrank08,self.rankConf)
                end
                
            else
                self.rankText.text = mRank
            end 
        elseif mRank > 10 then
            self.rankText.text = language.xianzhuangrank07
        end
    end
end

function XzphView:btnClick(context)
    if not self.data then return end
    local data = context.sender
    if data.name == "n21" then
        GOpenView({id = 1324})
    elseif data.name == "n31" then
        GOpenRuleView(1137)
    end
end

function XzphView:cellAwardData(index,obj)
    local awardObj = self.awardConf[index+1]
    local awards = obj:GetChild("n2")
    local text = obj:GetChild("n3")
    if awardObj.id == 1 then
        text.text = string.format(language.kaifu12,awardObj.id)
    elseif awardObj.id == 2  or awardObj.id == 3 then
        text.text = string.format(language.kaifu11,awardObj.rank[1],awardObj.rank[2])
    else
        text.text = mgr.TextMgr:getTextColorStr(language.rechargeRank15,7)
    end
    awards.itemRenderer = function (_index,_obj)
        local item = awardObj.awards[_index+1]
        GSetItemData(_obj,{mid = item[1],amount = item[2],bind = item[3]},true)
    end
    awards.numItems = #awardObj.awards
end

function XzphView:cellRankData(index,obj)
    if not self.data then return end
    local rankObj = self.data.rankInfos[index+1]
    local c1 = obj:GetController("c1")
    c1.selectedIndex = 3
    local rank = obj:GetChild("n4")
    local name = obj:GetChild("n5")
    local power = obj:GetChild("n6")
    local kuaFuIcon = obj:GetChild("n7")
    local mRank = self.data.myRank
    if index <= 3 then 
        c1.selectedIndex = index
    else
        c1.selectedIndex = 3
    end
    if rankObj then
        rank.text = rankObj.rank
        name.text = rankObj.name
        power.text = rankObj.power
        local uId = string.sub(rankObj.roleId,1,3)
        kuaFuIcon.visible = cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(rankObj.roleId) > 10000
    else
        rank.text = index + 1
        name.text = language.rank03
        power.text = "0"
        kuaFuIcon.visible = false
    end
end

return XzphView