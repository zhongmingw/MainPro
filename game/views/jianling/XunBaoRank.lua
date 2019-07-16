--
-- Author: 
-- Date: 2018-07-16 20:55:58
--

local XunBaoRank = class("XunBaoRank",import("game.base.Ref"))

function XunBaoRank:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function XunBaoRank:initPanel()
    self.view = self.mParent.view:GetChild("n4")

    self.leftTime = self.view:GetChild("n9")  --倒计时
    self.leftTime.text = ""

    self.title = self.view:GetChild("n10")
    self.title.text = ""

    self.myRank = self.view:GetChild("n11")
    self.myRank.text = ""
    --奖励列表
    self.awardList = self.view:GetChild("n4")
    self.awardList.numItems = 0
    self.awardList.itemRenderer = function(index,obj)
        self:cellAwardData(index, obj)
    end
    self.awardList:SetVirtual()
    --rank列表
    self.rankList = self.view:GetChild("n16")
    self.rankList.numItems = 0
    self.rankList.itemRenderer = function(index,obj)
        self:cellRankData(index, obj)
    end
    self.rankList:SetVirtual()
    self.icon = self.view:GetChild("n18")
    local goXunbao = self.view:GetChild("n7")
    goXunbao.onClick:Add(self.onClickXunBao,self)

  
end

function XunBaoRank:cellAwardData(index,obj)
    local data = self.awardConfData[index+1]
    local c1 = obj:GetController("c1")
    if index <3 then
        c1.selectedIndex = index
    else
        c1.selectedIndex = 3
         
        if self.data.msgId == 5030418 then
            print(obj:GetChild("n6").text )
            obj:GetChild("n6").text = ""
            obj:GetChild("n8").url = UIPackage.GetItemURL("jianling" , "jianlingchushi_024")
        else

            obj:GetChild("n8").url = nil
        end
    end
    if data then
        local list = obj:GetChild("n7")
        GSetAwards(list, data.awards)
    end
end

function XunBaoRank:cellRankData(index,obj)
    local data = self.data.rankInfos[index+1]
    local c1 = obj:GetController("c1")
    if index <= 3 then
        c1.selectedIndex = index
    else
        c1.selectedIndex = 3
    end
    local rank = obj:GetChild("n6")
    local name = obj:GetChild("n0")
    local time = obj:GetChild("n2")
    
    rank.text = index+1
    if data then
        if self.data.msgId == 5030215 then
             name.text = data.roleName
            time.text = data.times
        elseif self.data.msgId == 5030418 then
            name.text = data.name
            time.text = data.power
        end
        local roleId = data.roleId --玩家id
        local uId = string.sub(roleId,1,3)
       obj:GetChild("n9").visible = false
    if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(roleId) > 10000 and self.data.msgId ~= 5030418 then
       obj:GetChild("n9").visible = true
    end
    else
        obj:GetChild("n9").visible = false
        name.text = language.flower08
        time.text = ""
    end
end

function XunBaoRank:setData(data)
    self.data = data
    printt("剑灵寻宝排行",data)
    local actData = cache.ActivityCache:get5030111()
  
    if data.msgId==5030215 then
        self.awardConfData = conf.ActivityConf:getJianLingRankAward()
        self.icon.url = UIPackage.GetItemURL("jianling" , "jianlingchushi_016")

    elseif  data.msgId==5030418 then
        self.awardConfData = conf.ActivityConf:getJianLingRankAward1()
        self.icon.url = UIPackage.GetItemURL("jianling" , "jianlingchushi_023")

    end
    
    self.awardList.numItems = #self.awardConfData
    local rankLimit = conf.ActivityConf:getHolidayGlobal("jianling_find_rank_min")--最低上榜次数条件
    local rankLimitPower = conf.ActivityConf:getHolidayGlobal("jianling_find_rank_min_power")--最低上榜战力条件
    local rankSize = conf.ActivityConf:getHolidayGlobal("jianling_find_rank_size")--上榜人数
    local rankSize1 = conf.ActivityConf:getHolidayGlobal("jianling_find_rank_merge_size")--上榜人数(合服)

    if data.msgId == 5030215 then
        if data.myTimes < rankLimit then
            self.title.text = ""
            self.myRank.text = string.format(language.jianLingBorn01, tonumber(rankLimit)-tonumber(data.myTimes))
        else
            self.title.text = language.jianLingBorn03
            if data.myRank > rankSize or data.myRank == 0 then
                self.myRank.text = string.format(language.jianLingBorn02,tonumber(rankSize))
            else
                self.myRank.text = string.format(language.flower06,tonumber(data.myRank))
            end
        end
        self.rankList.numItems = rankSize
    elseif data.msgId == 5030418 then
        if data.myPower < rankLimitPower then --未上榜
            self.title.text = ""
            self.myRank.text = string.format(language.jianLingBorn06, tonumber(rankLimitPower)-tonumber(data.myPower))
        else
            self.title.text = language.jianLingBorn03
            if data.myRank > rankSize1 or data.myRank == 0 then
         
                self.myRank.text = string.format(language.jianLingBorn02,tonumber(rankSize1))
            else
                self.myRank.text = string.format(language.flower06,tonumber(data.myRank))
            end
        end

        self.rankList.numItems = rankSize1
    end

end

function XunBaoRank:onTimer()
    if self.data and self.data.lastTime then
        if self.data.lastTime > 86400 then 
            self.leftTime.text = GTotimeString7(self.data.lastTime)
        else
            self.leftTime.text = GTotimeString2(self.data.lastTime)
        end
        if self.data.lastTime <= 0 then
            self.mParent:onBtnClose()
        end
        self.data.lastTime = self.data.lastTime-1
    end
end

function XunBaoRank:onClickXunBao()
    GOpenView({id = 1267})
end
return XunBaoRank