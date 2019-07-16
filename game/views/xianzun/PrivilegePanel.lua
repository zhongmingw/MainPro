--仙尊卡特权弹框
local PrivilegePanel = class("PrivilegePanel",base.BaseView)

function PrivilegePanel:ctor()
    -- body
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level2
end

function PrivilegePanel:initData(data)
    -- body
    local closeBtn = self.view:GetChild("n3")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.listView = self.view:GetChild("n4")
    self:initListView()
    self.data = data
    self.listView.numItems = #data
    self.listView.scrollPane:ScrollTop()
end

function PrivilegePanel:initListView()
    -- body
    self.listView.numItems = 0    
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
end

function PrivilegePanel:cellData( index, obj )
    -- body
    local affectId = self.data[index+1]
    local iconItem = obj:GetChild("icon")
    local descText = obj:GetChild("n3")
    local affectImg = conf.VipChargeConf:getAffectImgById(affectId)
    local desc = conf.VipChargeConf:getAffectDecById(affectId)
    local str=""
    for i=1,#desc do
        local dat=desc[i]
        str=str.."[color="..dat[1].."][size="..dat[2].."]"..dat[3].."[/size][/color]"
    end
    iconItem.url = UIPackage.GetItemURL("xianzun", affectImg)
    descText.text = str
    local btnCheck = obj:GetChild("n5")
    local sex = cache.PlayerCache:getSex()
    local data = nil

    if sex == 1 then
        if affectId == 1021 then--时装
            data = {mid = 221071029, amount = 1, bind = 1}
        elseif affectId == 1011 then--武器
            data = {mid = 221071027, amount = 1, bind = 1}
        end
    else
        if affectId == 1021 then--时装
            data = {mid = 221071030, amount = 1, bind = 1}
        elseif affectId == 1011 then--武器
            data = {mid = 221071028, amount = 1, bind = 1}
        end
    end
    if data then
        btnCheck.visible = true
    else
        btnCheck.visible = false
    end
    btnCheck.data = data
    btnCheck.onClick:Add(self.onClickCheck,self)
end

function PrivilegePanel:onClickCheck( context )
    local data = context.sender.data
    GSeeLocalItem(data)
end

function PrivilegePanel:onClickClose()
    -- body
    self:closeView()
end

return PrivilegePanel