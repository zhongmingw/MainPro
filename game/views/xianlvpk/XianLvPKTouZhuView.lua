--
-- Author: 
-- Date: 2018-07-24 16:00:29
--

local XianLvPKTouZhuView = class("XianLvPKTouZhuView", base.BaseView)

function XianLvPKTouZhuView:ctor()
    XianLvPKTouZhuView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function XianLvPKTouZhuView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n4")
    self:setCloseBtn(closeBtn)
    --标题
    self.title = self.view:GetChild("n5")
    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")
    local dec1 = self.view:GetChild("n19")
    dec1.text = language.xianlv12
    local dec2 = self.view:GetChild("n20")
    local back = conf.XianLvConf:getValue("stake_back_mul")
    dec2.text = string.format(language.xianlv13,tonumber(back)) 

    local stakeLimit = conf.XianLvConf:getValue("stake_limit")
    local dec3 = self.view:GetChild("n21")
    dec3.text = language.xianlv14
    dec3.text = string.format(language.xianlv14,stakeLimit[2])

    self.inPutText = self.view:GetChild("n25")
    self.isTouZhuText = self.view:GetChild("n30")
    local toZhuBtn = self.view:GetChild("n28")
    toZhuBtn.onClick:Add(self.goToZhu,self)

    self.teamInfo = {}
    local team1 = self.view:GetChild("n6")--这个是个单选btn
    team1.onClick:Add(self.onChoseTeam,self)
    local team2 = self.view:GetChild("n16")
    team2.onClick:Add(self.onChoseTeam,self)
    table.insert(self.teamInfo,team1)
    table.insert(self.teamInfo,team2)

end
--[[vsTeams:
1   string  变量名: teamName   说明: 队伍名字
2   int32   变量名: power  说明: 队伍总战力
3   int32   变量名: teamId 说明: 队伍id
4   int32   变量名: winCount   说明: 胜场
5   int32   变量名: loseCount  说明: 负场]]

--[[
结构体描述：仙侣pk押注信息
结构体名：XlpkStakeInfo
备注：备注：
1   int32   变量名: stakeMoney 说明: 已押注的金钱数额
2   int32   变量名: group  说明: 组id
3   int32   变量名: stakeTeamId    说明: 已押注的队伍id]]
function XianLvPKTouZhuView:initData(data)
    self.data = data
    self.teamId = nil
    self.inPutText.text = ""
    local isStakeTeamId --已押注的队伍
    local vsTeams = data.vsTeams and data.vsTeams 
    self.group = data.group and data.group
   
    --队伍id列表
    local vsTeamIdList = {}
    for k,v in pairs(vsTeams) do
        local teamId = v.teamId
        table.insert(vsTeamIdList,teamId)
    end

    local cacheStakeInfo = cache.XianLvCache:getStakeInfo()
    printt("压住信息",cacheStakeInfo)
    local stakeInfo = {}
    for k,v in pairs(cacheStakeInfo) do
        if data.group == v.group then
            for _,j in pairs(vsTeamIdList) do
                if v.stakeTeamId == j then
                    table.insert(stakeInfo,v)
                end
            end
        end
    end
    if #stakeInfo == 0 then--没有有押注
        self.c2.selectedIndex = 0
        isStakeTeamId = nil
        
        local serverTime =  data.nowTime
        local timeTab = os.date("*t",serverTime)
        local hour = tonumber(timeTab.hour)
        local min = tonumber(timeTab.min)
        local sec = tonumber(timeTab.sec)
        --当前时间秒数
        print(hour,min,sec)
        local nowTime = hour*3600 + min*60 + sec
        local beginTime = data.beginTime and data.beginTime or 0
        -- print("开始时间",beginTime,"现在时间",nowTime)
        if data.curDay == 1 then
            self.c1.selectedIndex = 0
        else
            if nowTime > beginTime then
                self.c1.selectedIndex = 2--不可投注
            else
                self.c1.selectedIndex = 0
            end
        end
    else
        self.c1.selectedIndex = 1
        for k,v in pairs(stakeInfo) do
            self.isTouZhuText.text = v.stakeMoney
            isStakeTeamId = v.stakeTeamId
        end
    end
    -- printt("队伍信息",vsTeams)
    for k,v in pairs(vsTeams) do
        local teamName = self.teamInfo[k]:GetChild("n11")
        teamName.text = v.teamName
        local power = self.teamInfo[k]:GetChild("n12")
        power.text = v.power
        local result = self.teamInfo[k]:GetChild("n13")
        result.text = string.format(language.xianlv29,v.winCount,v.loseCount)
        self.teamInfo[k].data = {teamId = v.teamId}
        if self.c1.selectedIndex == 0 then
            self.c2.selectedIndex = 0
            -- self.teamInfo[k].touchable = true
        else
            if isStakeTeamId and isStakeTeamId == v.teamId then
                self.teamInfo[k].selected = true
                -- self.teamInfo[k].touchable = false
            else
                self.teamInfo[k].selected = false
            end
            -- if not isStakeTeamId then
            --     self.teamInfo[k].touchable = true
            -- else
            --     self.teamInfo[k].touchable = false
            -- end
        end
    end
end

function XianLvPKTouZhuView:setData(data)

end

function XianLvPKTouZhuView:onChoseTeam(context)
    local data = context.sender.data
    self.teamId = data.teamId
end

function XianLvPKTouZhuView:goToZhu()
    local stakeLimit = conf.XianLvConf:getValue("stake_limit")

    local stakeMoney = string.trim(self.inPutText.text)
    if not self.teamId then
        GComAlter(language.xianlv30)
        return
    end
    if stakeMoney == "" then
        GComAlter(language.xianlv31)
        return
    elseif tonumber(stakeMoney) <= 0 then
        GComAlter(language.xianlv32)
        return
    elseif tonumber(stakeMoney) > stakeLimit[2] then
        GComAlter(language.xianlv14_01)
        return
    end
    if not self.group then
        print("没有组id>>>>@前端")
        return
    end
    print("teamId",self.teamId,"group",self.group,"stakeMoney",stakeMoney)
    local msgId
    if self.data.msgId == 5540101 then
        msgId = 1540105
    elseif self.data.msgId == 5540201 then
        msgId = 1540205
    end
    proxy.XianLvProxy:sendMsg(msgId,{teamId = self.teamId,group = self.group,stakeMoney = tonumber(stakeMoney)})
end

return XianLvPKTouZhuView