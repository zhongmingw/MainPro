--
-- Author: 
-- Date: 2017-05-25 15:19:30
--

local SeePropsPanel = class("SeePropsPanel",import("game.base.Ref"))

local BtnNumber = 3
--角色信息显示
local JuesePro = {
    105,102,103,106,107,108,109,112
}
--基础信息显示
local JueseBase = {
    105,102,103,106,107,108,109,112
}
local JueseBaseAdd = {
    505,506,507 --潜能添加 
}
--特殊属性显示
local JueseMore= {
    110,111,112,305,306,324,323,216,116,311,312,219,119,314,117,319,320,315,316,317,318,321,322
}
function SeePropsPanel:ctor(param)
    self.view = param
    self:initView()
end

function SeePropsPanel:initView()
    -- body

    self.controllerC1 =  self.view:GetController("tabl")
    self.controllerC1.onChanged:Add(self.onbtnController,self)
end

function SeePropsPanel:initRoleMsg()
    -- body
    local rolepanel = self.view:GetChild("n39")

    local window3 = self.view:GetChild("n28")
    window3:GetChild("icon").visible = false

    self.roleIcon = rolepanel:GetChild("n27"):GetChild("n3")
    self.roleName = rolepanel:GetChild("n15")
    self.roleName.text = "" 
    self.rolevip = rolepanel:GetChild("n23") 
    self.rolevip.text = "0"
    self.roleRefineLv = rolepanel:GetChild("n40")
    self.roleRefineLv.url = ""
    --Vip特权
    self.controllerVipC1 =  rolepanel:GetController("c1")
    self.controllerVipC2 =  rolepanel:GetController("c2")
    self.controllerVipC3 =  rolepanel:GetController("c3")
    --战斗力
    self.rolePower = rolepanel:GetChild("n11")
    self.rolePower.text = "0"
    --帮派
    local dec1 = rolepanel:GetChild("n6") 
    dec1.text = language.juese01
    self.bangpaiName = rolepanel:GetChild("n7")
    self.bangpaiName.text = language.juese04 
    --配偶
    local dec2 = rolepanel:GetChild("n2")
    dec2.text = language.juese02
    self.peiouName = rolepanel:GetChild("n3")
    self.peiouName.text = language.juese04 

    self.listView1 = rolepanel:GetChild("n39")
    self.listView1.numItems = 0
    self.listView1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end 
    self.listView1:SetVirtual()
end

function SeePropsPanel:initPropsMsg()
    -- body
    local props = self.view:GetChild("n40")
     --属性
    self.listView2 = props:GetChild("n97")
    self.listView2.numItems = 0 
    self.listView2.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end 
    --潜能属性
    self.props2 = {}
    for i = 1 , 3 do 
        local t = {}
        t.dec = props:GetChild("dec"..i)
        t.dec.text = ""
        t.value = props:GetChild("value"..i)
        t.value.text = ""
        table.insert(self.props2,t)
    end
    --潜力点
    local dec1 = props:GetChild("n42")
    dec1.text = language.juese05

    self.numberQianli =  props:GetChild("n81")
    self.numberQianli.text = 0
end

--用key 获得属性
function SeePropsPanel:getValue(id)
    -- body
    if self.data.attris and self.data.attris[id]  then
        return self.data.attris[id]
    end
    return nil
end

function SeePropsPanel:celldata( index, obj)
    -- body
    local key1 = self.listdata[(index+1)*2-1] 
    if not key1 then
        return
    end
    local dec1 = obj:GetChild("n1")
    dec1.text = conf.RedPointConf:getProName(key1)  -- language.jueseprops[key1] 
    local value1 = obj:GetChild("n2")
    value1.text = GProPrecnt(key1,self:getValue(key1) or 0)  --self:getValue(key1) or 0

    local key2 = self.listdata[(index+1)*2] 
    local dec1 = obj:GetChild("n4")
    local value1 = obj:GetChild("n5")
    dec1.text = ""
    value1.text = ""
    if not key2 then
        return
    end 
    dec1.text = conf.RedPointConf:getProName(key2)  --language.jueseprops[key2]
    value1.text = GProPrecnt(key2,self:getValue(key2) or 0)
end

--角色信息
function SeePropsPanel:initRoleData()
    -- body
    --头像
    local t = GGetMsgByRoleIcon(self.data.roleIcon,self.data.roleId,function(data)
        if self.roleIcon then
            self.roleIcon.url = data.headUrl
        end
    end)
    local refineLevel = self.data.xiuxianLevel
    -- print("修仙等级",self.data.xiuxianLevel) 
    local attrConf = conf.ImmortalityConf:getAttrDataByLv(refineLevel)
    if attrConf and attrConf.name_img then      
        self.roleRefineLv.url = UIPackage.GetItemURL("head", attrConf.name_img) or ""
    end 
    self.roleIcon.url = t.headUrl
    --名字
    self.roleName.text = self.data.roleName or ""
    --vip等级
    self.rolevip.text = self.data.attris[503] or "0"
    --3个特权
    --printt(self.data.vipTypes)
    self.controllerVipC1.selectedIndex = 0
    self.controllerVipC2.selectedIndex = 0
    self.controllerVipC3.selectedIndex = 0
    for k ,v in pairs(self.data.vipTypes) do
        if v == 1 then
            self.controllerVipC1.selectedIndex = 1
        elseif v == 2 then
            self.controllerVipC2.selectedIndex = 1
        elseif v == 3 then
            self.controllerVipC3.selectedIndex = 1
        end
    end
    --战力
    self.rolePower.text = self.data.power
    --帮派明
    if self.data.gangString ~="" then
        self.bangpaiName.text = self.data.gangString
    else
        self.bangpaiName.text = language.juese04 
    end
    --配偶名字
    if self.data.spouse ~= "" then
        self.peiouName.text = self.data.spouse
    else
        self.peiouName.text = language.juese04 
    end
    --显示的属性
    self:setProps(JuesePro,self.listView1)    
end

--基础属性
function SeePropsPanel:initPropDataBase()
    -- body
    self.numberQianli.text = self:getValue(504) or 0
    --显示的属性
    self:setProps(JueseBase,self.listView2)

    self:setQianLi(JueseBaseAdd) 
end

--
function SeePropsPanel:initPropDataMore()
    -- body
    self.numberQianli.text = self:getValue(504) or 0
    self:setProps(JueseMore,self.listView2) 
    self:setQianLi(JueseBaseAdd)
end

--设置属性
function SeePropsPanel:setProps(param,list)
    -- body
    self.listdata = param
    list.numItems = math.ceil(#param/2)
end

--潜力点展示
function SeePropsPanel:setQianLi(param)
    -- body
    for k ,v in pairs(self.props2) do
        self.props2[k].dec.text = ""
        self.props2[k].value.text = ""
    end

    for k ,v in pairs(param) do 
        if not self.props2[k] then
            break
        end
        self.props2[k].dec.text = language.jueseprops[v] --conf.RedPointConf:getProName(v) 
        self.props2[k].value.text = self:getValue(v) or 0
    end
end

function SeePropsPanel:onbtnController()
    -- body
    if self.controllerC1.selectedIndex == 0 then --角色信息
        self:initRoleData()
    elseif self.controllerC1.selectedIndex == 1 then --基础属性
        self:initPropDataBase()
    elseif self.controllerC1.selectedIndex == 2 then --特殊属性
        self:initPropDataMore()
    end
end

function SeePropsPanel:setData(data)
    -- body
    self.data = data
    self:onbtnController()
end


return SeePropsPanel