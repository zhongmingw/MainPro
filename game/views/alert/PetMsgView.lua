--
-- Author: wx
-- Date: 2018-01-17 19:51:33
-- 查看宠物信息

local PetMsgView = class("PetMsgView", base.BaseView)

function PetMsgView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function PetMsgView:initView()
    --local btnClose = self.view:GetChild("")
    self:setCloseBtn(self.view)

    self.leftpanle = self.view:GetChild("n0")
    self.rightpanle = self.view:GetChild("n1")
    --显示宠物进阶模型bxp2018/06/27
    self._btnLeft = self.rightpanle:GetChild("n6")
    self._btnLeft.data = -1 
    self._btnLeft.visible = false
    self._btnLeft.onClick:Add(self.onChange,self)
    self._btnRight = self.rightpanle:GetChild("n5")
    self._btnRight.data = 1
    self._btnRight.visible = false
    self._btnRight.onClick:Add(self.onChange,self)
    
end

function PetMsgView:initData(data)
    -- body
    self.model = nil 

    self.data = data 
    -- self._btnLeft.visible = false
    -- self._btnRight.visible = false
    -- if self.data.localpetId then
    --     self._btnLeft.visible = true
    --     self._btnRight.visible = true
    -- end
    self:setData()
end

function PetMsgView:setgetwayList(listView1,condata)
    -- body
    listView1.itemRenderer = function(index,obj)
        local info = condata.formview[index + 1]
        local id = info[1]
        local childIndex = info[2]
        local data = conf.SysConf:getModuleById(id)
        local lab = obj:GetChild("n1")
        lab.text = data.desc
        local btn = obj:GetChild("n0")
        btn.data = {id = id,childIndex = childIndex}
        btn.onClick:Add(self.onBtnGo,self)
    end
    listView1.numItems = condata.formview and #condata.formview or 0 
end

function PetMsgView:onBtnGo(context)
    -- body
    local data = context.sender.data
    local param = {id = data.id,childIndex = data.childIndex}
    GOpenView(param)
end

function PetMsgView:initLeft()
    -- body
    local itemobj = self.leftpanle:GetChild("n6")
    local t = {isCase = true,color = self.condata.color,url = ResPath.iconRes(self.condata.src)}
    GSetItemData(itemobj,t)

    local name = self.leftpanle:GetChild("n10")
    local _name = (self.data and self.data.name) and self.data.name or self.condata.name 
    name.text = mgr.TextMgr:getQualityStr1(_name , self.condata.color)

    self.leftpanle:GetChild("n11").text = language.pet33

    local _type = self.leftpanle:GetChild("n12")
    _type.text = language.pet17[self.condata.type]

    local score = self.leftpanle:GetChild("n9")
    if self.data.localpetId  then
        score.text = mgr.PetMgr:getPetScore(self.condata.id,true)
    else
        score.text = mgr.PetMgr:getPetScore(self.data)
    end
    self.leftpanle:GetChild("n14").text = language.gonggong56

    local level  = (self.data and self.data.level) and self.data.level  or 0
    local lab_level = self.leftpanle:GetChild("n15")
    lab_level.text = level

  
    local listView = self.leftpanle:GetChild("n7")
    listView.numItems = 0

    --添加描述
    local var = UIPackage.GetItemURL("alert" , "Component1")
    local _compent1 = listView:AddItemFromPool(var)
    _compent1:GetChild("n0").text = self.condata.describe
    --基础属性
    local var = UIPackage.GetItemURL("alert" , "baseAttiItem")
    local _compent1 = listView:AddItemFromPool(var)
    _compent1:GetChild("n0").text = language.equip02[3]


    local info = {}
    info.petId = self.petId
    info.level = level
    if self.data and self.data.growValue then
        info.growValue = self.data.growValue
    else
        info.growValue = self.condata.init_grow[1][1]
    end 

    --local _info = conf.PetConf:getLevelUp(self.condata.type,level)
    local _t = mgr.PetMgr:getPetPro(info)
    local str = ""
    --加入成长值
    str = language.pet47 ..  mgr.TextMgr:getTextColorStr(" "..info.growValue/100,7) .."\n\n"

    local number = #_t
    for k ,v in pairs(_t) do
        str = str .. mgr.PetMgr:getProName(v)--(v[1])
        str = str .. mgr.TextMgr:getTextColorStr("+" .. GProPrecnt(v[1],v[2]),7)
        if k ~= number then
            str = str .. "\n"
        end
    end
    _compent1:GetChild("n8").text = str
    _compent1:GetChild("n1").text = ""
    --添加宠物技能
    local var = UIPackage.GetItemURL("alert" , "Component2")
    local _compent1 = listView:AddItemFromPool(var)
    _compent1:GetChild("n0").text = language.pet34

    local skilllist = {}
    if self.data.localpetId  then
        for k ,v in pairs(self.condata.init_skill) do
            skilllist[k] = v 
        end
    else
        skilllist = self.data.skillDatas or {}
    end
    local var = UIPackage.GetItemURL("alert" , "Component5")
    local _compent1 = listView:AddItemFromPool(var)
    for i = 0 , 5 do
        local item = _compent1:GetChild("n"..i)
        local icon = item:GetChild("n2")
        local skilldata = skilllist[i+1]
        if skilldata then
            local _sk = conf.PetConf:getPetSkillById(skilldata)
            if not _sk then
                icon.url = nil 
            else
                icon.url = ResPath.iconRes(_sk.icon)
            end
        else
            icon.url = nil 
        end
        item.data = skilldata
        item.onClick:Add(self.onSkill,self)
    end

    local list = self.leftpanle:GetChild("n8")
    self:setgetwayList(list,self.condata)
end

function PetMsgView:onSkill(context)
    -- body
    context:StopPropagation()
    local data = context.sender.data
    if data then
        mgr.ViewMgr:openView2(ViewName.PetSkillMsgTips, data)
    end
end

function PetMsgView:initRight(condata )
    -- body
    if not condata or not condata.model then
        plog("没有配置模型")
        return
    end
    local _panel = self.rightpanle:GetChild("n4")
    if not self.model then
        self.model = self:addModel(condata.model,_panel)
    else
        self.model:setSkins(condata.model)
    end
    self.model:setScale(SkinsScale[Skins.newpet])
    self.model:setRotationXYZ(0,147.6,0)
    self.model:setPosition(0,-332,500)

    if mgr.PetMgr:getPetByCondition(1,self.petId) then
        self._btnRight.visible = true
    else
        self._btnRight.visible = false
    end

    if  mgr.PetMgr:getPetByCondition(-1,self.petId) then
        self._btnLeft.visible = true
    else
        self._btnLeft.visible = false
    end
    
end

function PetMsgView:onChange(context)
    -- body
    if not self.data then
        return
    end
    context:StopPropagation()
    local index = context.sender.data
    local condata = mgr.PetMgr:getPetByCondition(index,self.petId) 
    if condata then
        self.petId = condata.id
        self:initRight(condata)
    end
end

function PetMsgView:setData(data_)
    self.petId = self.data.localpetId or self.data.petId


    self.condata = conf.PetConf:getPetItem(self.petId)
    if not self.condata then
        print("配置缺少",id)
        return self:closeView()
    end
    self:initLeft()

    self:initRight(self.condata)
end

return PetMsgView