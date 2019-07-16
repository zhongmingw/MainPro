--
-- Author: 
-- Date: 2018-07-30 14:38:57
--

local ShengJieRank = class("ShengJieRank",import("game.base.Ref"))

function ShengJieRank:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ShengJieRank:initPanel()
    self.view = self.mParent.view:GetChild("n3")

    self.leftTime = self.view:GetChild("n5")
    self.leftTime.text = ""

    self.view:GetChild("n1").text = language.sbqt05

    -- self.title = self.view:GetChild("n23")
    -- self.title.text = ""

    local ruleTxt = self.view:GetChild("n15")
    ruleTxt.text = language.sbqt06

    self.myRank = self.view:GetChild("n24")

    --奖励列表
    self.awardList = self.view:GetChild("n2")
    self.awardList.numItems = 0
    self.awardList.itemRenderer = function(index,obj)
        self:cellAwardData(index, obj)
    end
    self.awardList:SetVirtual()
    --rank列表
    self.rankList = self.view:GetChild("n9")
    self.rankList.numItems = 0
    self.rankList.itemRenderer = function(index,obj)
        self:cellRankData(index, obj)
    end
    self.rankList:SetVirtual()
    local goJinJie = self.view:GetChild("n3")
    goJinJie.onClick:Add(self.onClickJinJie,self)

    self.awardConfData = conf.ActivityConf:getShenBiRankAward()
    self.awardList.numItems = #self.awardConfData


    local chengHaoIcon = self.view:GetChild("n22")
    local chenghaoId = conf.ActivityConf:getHolidayGlobal("sbqt_rank_titleid")
    local confdata = conf.RoleConf:getTitleData(chenghaoId)
    if not confdata then
        plog("@策划 称号配置里面没有",chenghaoId)
    else
        chengHaoIcon.url = UIPackage.GetItemURL("head" , tostring(confdata.scr))
    end   
end

function ShengJieRank:cellAwardData(index,obj)
    local data = self.awardConfData[index+1]
    local rankTxt = obj:GetChild("n6")
    if data then
        local str = ""
        if data.rank[1]~=data.rank[2] then
            str = string.format(language.sbqt08,data.rank[1],data.rank[2])
        else
            str = string.format(language.kaifu12,data.rank[1])
        end
        rankTxt.text = str
        local list = obj:GetChild("n7")
        GSetAwards(list, data.awards)
    end
end

function ShengJieRank:cellRankData(index,obj)
    local data = self.data.rankInfos[index+1]
    local c1 = obj:GetController("c1")
    if index <= 3 then
        c1.selectedIndex = index
    else
        c1.selectedIndex = 3
    end
    local rank = obj:GetChild("n6")
    local name = obj:GetChild("n0")
    local power = obj:GetChild("n2")
    rank.text = index+1
    if data then
        name.text = data.name
        power.text = data.power
        local selfRoleId = cache.PlayerCache:getRoleId()
        if selfRoleId == roleId then
            obj:GetChild("n7").visible = false
        end
        local roleId= data.roleId
        local uId = string.sub(roleId,1,3)
        if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(roleId) > 10000 then
           obj:GetChild("n7").visible = true
        else
           obj:GetChild("n7").visible = false
        end
    else
        obj:GetChild("n7").visible = false
        name.text = language.flower08
        power.text = ""
    end
end

function ShengJieRank:setData(data)
    self.data = data
    printt("升阶排行",data)
    local rankLimit = conf.ActivityConf:getHolidayGlobal("sbqt_rank_min")--最低上榜条件
    local rankSize = conf.ActivityConf:getHolidayGlobal("sbqt_rank_size")--上榜人数
    local str = ""
    if data.jie < rankLimit then
        str = ""
        self.myRank.text = str.. string.format(language.sbqt01, tonumber(rankLimit)-tonumber(data.jie))
    else
        str = language.sbqt02
        if data.myRank > rankSize or data.myRank == 0 then
            self.myRank.text = str..language.sbqt03
        else
            self.myRank.text = str..string.format(language.flower06,tonumber(data.myRank))
        end
    end
    self.rankList.numItems = rankSize
end


function ShengJieRank:onTimer()
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


function ShengJieRank:onClickJinJie()
    if not mgr.ModuleMgr:CheckView(1287) then
        GComAlter(language.sbqt07)
        return
    end
    GOpenView({id = 1287})
end



return ShengJieRank