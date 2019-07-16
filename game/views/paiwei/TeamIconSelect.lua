--
-- Author: Your Name
-- Date: 2018-01-10 21:29:09
--

local TeamIconSelect = class("TeamIconSelect", base.BaseView)

function TeamIconSelect:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true 
end

function TeamIconSelect:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n5")
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function TeamIconSelect:celldata(index,obj)
    local data = self.teamIconConf[index + 1]
    if data then
        local icon = obj:GetChild("n0")
        icon.url = UIPackage.GetItemURL("paiwei" , data.icon)
        obj.data = data
        obj.onClick:Add(self.onClickSelect,self)
    end
end

function TeamIconSelect:initData(data)
    self.teamIconConf = conf.QualifierConf:getTeamIconData()
    self.listView.numItems = #self.teamIconConf
end

function TeamIconSelect:onClickSelect(context)
    local data = context.sender.data
    print("当前选择的战队icon",data.id)
    local view = mgr.ViewMgr:get(ViewName.SetUpTeam)
    if view then
        view:refreshIconId({iconId = data.id})
    end
    self:closeView()
end

return TeamIconSelect