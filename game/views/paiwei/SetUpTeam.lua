--
-- Author: Your Name
-- Date: 2018-01-10 21:29:49
--

local SetUpTeam = class("SetUpTeam", base.BaseView)

function SetUpTeam:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true 
end

function SetUpTeam:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.icon = self.view:GetChild("n8")
    self.name = self.view:GetChild("n14")
    self.changeIconBtn = self.view:GetChild("n10")
    self.changeIconBtn.onClick:Add(self.onClickChangeIcon,self)
    self.costIcon = self.view:GetChild("n9")
    self.costTxt = self.view:GetChild("n15")
    self.creatTeamBtn = self.view:GetChild("n11")
    self.creatTeamBtn.onClick:Add(self.onClickCreate,self)
end

function SetUpTeam:initData(data)
    self.iconId = 1
    local iconData = conf.QualifierConf:getTeamIconById(self.iconId)
    self.icon.url = UIPackage.GetItemURL("paiwei" , iconData.icon)
    self.name.text = ""
    local moneyType = conf.QualifierConf:getValue("create_zd_cost")[1]
    self.costIcon.url = UIItemRes.moneyIcons[BuyMoneyType[moneyType][1]]
    self.costTxt.text = conf.QualifierConf:getValue("create_zd_cost")[2]
end

function SetUpTeam:refreshIconId(data)
    self.iconId = data.iconId
    local iconData = conf.QualifierConf:getTeamIconById(self.iconId)
    self.icon.url = UIPackage.GetItemURL("paiwei" , iconData.icon)
end

function SetUpTeam:onClickChangeIcon()
    mgr.ViewMgr:openView2(ViewName.TeamIconSelect,{type = 1})
end
--
function SetUpTeam:onClickCreate()
    if self.name.text ~= "" then
        local moneyType = conf.QualifierConf:getValue("create_zd_cost")[1]
        local buyMoneyType = BuyMoneyType[moneyType]
        local needCost = conf.QualifierConf:getValue("create_zd_cost")[2]
        local hasMoney = 0
        for k,v in pairs(buyMoneyType) do
            hasMoney = hasMoney + cache.PlayerCache:getTypeMoney(v)
        end
        -- local moneyYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
        -- local moneyBy = cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
        if hasMoney >= needCost then
            proxy.QualifierProxy:sendMsg(1480203,{teamName = self.name.text,icon = self.iconId,reqType = 1,joinTeamId = 0})
            self:closeView()
        else
            GComAlter(language.gonggong18)
        end
    else
        GComAlter(language.qualifier30)
    end
end

return SetUpTeam