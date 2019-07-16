--装备区域
local EquipPanel = class("EquipPanel",import("game.base.Ref"))

local MaxNum = 12
local effectId = 4020103

function EquipPanel:ctor(mParent)
	self.mParent = mParent
	self.skins1 = 0
	self.skins2 = 0
	self.skins3 = 0
	self.skins5 = 0
	self:initPanel()
end

function EquipPanel:initPanel()
	local panelObj = self.mParent.view:GetChild("panel_equip")
	self.panelObj = panelObj
	self.textLv = panelObj:GetChild("n44")

	self.itemList = {}
	self.equipList = {}
	self.effectModels = {}
	self.effectList = {}
	for i=1,MaxNum do
		local num1 = 60 + i
		local num2 = 80 + i
		local itemObj = panelObj:GetChild("n"..num1)
		itemObj.data = Pack.equip + i
		local equipObj = panelObj:GetChild("n"..num2)--本质是按钮
	    table.insert(self.itemList, itemObj)
	    table.insert(self.equipList, equipObj)
	end
end

function EquipPanel:playEffect(effectPanel,k)
	if self.effectList[k] then
        self.mParent:removeUIEffect(self.effectList[k])
        self.effectList[k] = nil
    end
    self.effectList[k] = self.mParent:addEffect(effectId, effectPanel)
end
--添加模型
function EquipPanel:addModel(node)
	local skins1 = cache.PlayerCache:getSkins(Skins.clothes)--衣服
	local skins2 = cache.PlayerCache:getSkins(Skins.wuqi)--武器
	local skins3 = cache.PlayerCache:getSkins(Skins.xianyu)--仙羽
	local skins5 = cache.PlayerCache:getSkins(Skins.shenbing) --神兵

	
	if self.roleData and self.roleData.skins then
		skins1 = self.roleData.skins[Skins.clothes]
		skins2 = self.roleData.skins[Skins.wuqi]
		skins3 = self.roleData.skins[Skins.xianyu]
		skins5 = self.roleData.skins[Skins.shenbing]
	end
	local cansee = false
	if self.skins1 ~= skins1 or self.skins2 ~= skins2 or self.skins3 ~= skins3 or self.skins5 ~= skins5 then
		local modelObj
		modelObj,cansee = self.mParent:addModel(skins1,node)
		modelObj:setSkins(nil,skins2,skins3)
		self.modelObj = modelObj
		modelObj:setPosition(node.actualWidth/2,-node.actualHeight-70,100)
	    modelObj:setRotation(RoleSexModel[self.sex].angle)
	    modelObj:setScale(220)
	    if self.mParent:viewName() == ViewName.PackView then
	    	modelObj:setPosition(node.actualWidth/2,-656.6,500)
	    end
	    --print("EquipPanel:addModel(node)",node.actualWidth/2, -node.actualHeight)

	    local effect = self.mParent:addEffect(4020102,self.panelObj:GetChild("n0"))
	    effect.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight,500)

	    if skins5 > 0 and skins2>0 then
	    	modelObj:addWeaponEct(skins5.."_ui")
	    end
	end
    self.skins1 = skins1
	self.skins2 = skins2
	self.skins3 = skins3
	self.skins5 = skins5

	-- plog("cansee",cansee)
	self.panelObj:GetChild("n100").visible = cansee
end

function EquipPanel:setData(data,roleData)
	local equipData = data or cache.PackCache:getEquipData()
	for i,itemObj in pairs(self.itemList) do
		local equipObj = self.equipList[i]
		equipObj.visible = false
		for index,data in pairs(equipData) do
			if itemObj.data == index then 
				equipObj.visible = true
				local v = clone(data)
				v.isquan = true
				GSetItemData(equipObj,v,true)
			else
				local id = itemObj.data - Pack.equip + Pack.equipxian
				if id == index then --仙装
					equipObj.visible = true
					local v = clone(data)
					v.isquan = true
					GSetItemData(equipObj,v,true)
				end
			end
		end
	end

	self.roleData = roleData
	local roleIcon = roleData and roleData.roleIcon or cache.PlayerCache:getRoleIcon()
	self.sex = GGetMsgByRoleIcon(roleIcon).sex
	local roleLv = roleData and roleData.level or cache.PlayerCache:getRoleLevel()
	self.textLv.text = roleLv
	--添加模型
	local panelModel = self.panelObj:GetChild("n47")
 	self:addModel(panelModel)
	--self.panelObj:GetChild("n85").visible = self.cansee
	
	if not self.isSetModel then--是否设置了模型
		self.modelObj:modelTouchRotate(self.panelObj,self.sex)
		self.isSetModel = true
	end
end

function EquipPanel:clear()
	self.skins1 = 0
	self.skins2 = 0
	self.skins3 = 0
	self.skins5 = 0
	self.isSetModel = false
end

return EquipPanel