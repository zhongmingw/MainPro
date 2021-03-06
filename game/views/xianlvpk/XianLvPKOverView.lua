--
-- Author: 
-- Date: 2018-07-24 15:41:38
--

local XianLvPKOverView = class("XianLvPKOverView", base.BaseView)

function XianLvPKOverView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function XianLvPKOverView:initView()
    self.resultIcon = self.view:GetChild("n5")
    self.myTeamList = self.view:GetChild("n3")
    self.myTeamList.numItems = 0
    self.myTeamList.itemRenderer = function (index,obj)
        self:myTeamCell(index,obj)
    end
    self.myTeamList:SetVirtual()
    self.enemyList = self.view:GetChild("n4")
    self.enemyList.numItems = 0
    self.enemyList.itemRenderer = function (index,obj)
        self:enemyCell(index,obj)
    end
    self.enemyList:SetVirtual()
    local closeBtn = self.view:GetChild("n6")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.timeDecTxt = self.view:GetChild("n7")
end

-- 1   int64   变量名: roleId 说明: 角色id
-- 2   string  变量名: roleName   说明: 角色名字
-- 3   string  变量名: teamName   说明: 战队名字
-- 4   int32   变量名: lev    说明: 等级
-- 5   int32   变量名: power  说明: 战力
-- 6   int8    变量名: mvp    说明: 1:表示mvp 0:不是mvp
-- 7   int32   变量名: teamId 说明: 队伍id
function XianLvPKOverView:myTeamCell(index,obj)
    local data = self.myTeamInfo[index+1]
    if data then
        local mvpIcon = obj:GetChild("n5")
        local nameTxt = obj:GetChild("n0")
        local teamNameTxt = obj:GetChild("n1")
        local powerTxt = obj:GetChild("n2")
        local lvTxt = obj:GetChild("n3")
        local winNum = obj:GetChild("n4")
        if data.mvp == 1 then
            mvpIcon.visible = true
            if self.data.win == 1 then
                mvpIcon.url = UIPackage.GetItemURL("xianlvpk","kuafupaiweisai_010")
            else
                mvpIcon.url = UIPackage.GetItemURL("xianlvpk","kuafupaiweisai_009")
            end
        else
            mvpIcon.visible = false
        end
        nameTxt.text = data.roleName
        teamNameTxt.text = data.teamName
        powerTxt.text = data.power
        lvTxt.text = data.lev
        winNum.text = data.winCount
    end
end

function XianLvPKOverView:enemyCell(index,obj)
    local data = self.enemyInfo[index+1]
    if data then
        local mvpIcon = obj:GetChild("n5")
        local nameTxt = obj:GetChild("n0")
        local teamNameTxt = obj:GetChild("n1")
        local powerTxt = obj:GetChild("n2")
        local lvTxt = obj:GetChild("n3")
        local winNum = obj:GetChild("n4")
        if data.mvp == 1 then
            mvpIcon.visible = true
            if self.data.win == 1 then
                mvpIcon.url = UIPackage.GetItemURL("xianlvpk","kuafupaiweisai_009")
            else
                mvpIcon.url = UIPackage.GetItemURL("xianlvpk","kuafupaiweisai_010")
            end
        else
            mvpIcon.visible = false
        end
        nameTxt.text = data.roleName
        teamNameTxt.text = data.teamName
        powerTxt.text = data.power
        lvTxt.text = data.lev
        winNum.text = data.winCount
    end
end

-- 变量名：win 说明：1:胜利 2:失败
-- 变量名：clacInfos   说明：结算成员信息
-- 变量名：myTeamId    说明：我的队伍id
function XianLvPKOverView:initData(data)
    self.data = data
    self.myTeamInfo = {}
    self.enemyInfo = {}
    for k,v in pairs(data.clacInfos) do
        if data.myTeamId == v.teamId then
            table.insert(self.myTeamInfo,v)
        else
            table.insert(self.enemyInfo,v)
        end
    end
    if data.win == 1 then
        self.resultIcon.url = UIPackage.GetItemURL("_imgfonts","xianmengzhengba_044")
    else
        self.resultIcon.url = UIPackage.GetItemURL("_imgfonts","xianmengzhengba_046")
    end
    self.myTeamList.numItems = #self.myTeamInfo
    self.enemyList.numItems = #self.enemyInfo
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil 
    end
    self.timesNum = 10
    self.timeDecTxt.text = string.format(language.fuben11,self.timesNum)
    self.timer = self:addTimer(1, -1, handler(self,self.timerClick))
end

function XianLvPKOverView:timerClick()
    if self.timesNum > 0 then
        self.timesNum = self.timesNum - 1
        self.timeDecTxt.text = string.format(language.fuben11,self.timesNum)
    else
        self:onClickClose()
    end
end

function XianLvPKOverView:onClickClose()
    print("退出副本。。。。")
    mgr.FubenMgr:quitFuben()
    self:closeView()
end

return XianLvPKOverView