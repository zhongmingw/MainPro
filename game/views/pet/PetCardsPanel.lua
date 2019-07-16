--
-- Author: Your Name
-- Date: 2018-07-05 16:55:03
--

local PetCardsPanel = class("PetCardsPanel",import("game.base.Ref"))

function PetCardsPanel:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n66")
    self:initView()
end

function PetCardsPanel:initView()
    --宠物列表
    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onPetCallBack,self)

    -- local panel = self.view:GetChild("n54")
    -- panel.onTouchBegin:Add(self.onTouchBegin,self)
    -- panel.onTouchEnd:Add(self.onTouchEnd,self)
    --宠物信息
    self._panel = self.view:GetChild("n24")
    self.effectNode = self.view:GetChild("n58")
    self._pettype = self.view:GetChild("n9")
    self._pettype.url = nil 
    self.nameTxt = self.view:GetChild("n10")
    self.nameTxt.text = ""
    self.skillList = self.view:GetChild("n18")
    self.skillList.itemRenderer = function(index,obj)
        self:cellskilldata(index, obj)
    end
    self.skillList.numItems = 0
    self.skillList.onClickItem:Add(self.onSkillCallBack,self)
    --属性信息
    self.protable = {}
    for i=1,3 do
        local nameTxt = self.view:GetChild("n"..(i+99))
        local attrTxt = self.view:GetChild("n"..(i+109))
        table.insert(self.protable,{nameTxt,attrTxt})
    end
    self.growNumTxt = self.view:GetChild("n34")
    self.skillNumTxt = self.view:GetChild("n35")
    self.latext = self.view:GetChild("n55")
    self.latext.text = ""
    --初始评分
    self.gradeTxt = self.view:GetChild("n21")
    self.leftBtn = self.view:GetChild("n56")
    self.leftBtn.data = -1
    self.leftBtn.onClick:Add(self.onMoveCall,self)
    self.rightBtn = self.view:GetChild("n57")
    self.rightBtn.data = 1
    self.rightBtn.onClick:Add(self.onMoveCall,self)

end

function PetCardsPanel:onClickLeft()
    if self.index > 0 then
        self.index = self.index - 1
        self.petData = self.petConfData[self.index+1]
        self.listView:ScrollToView(self.index,false)
        self.listView:AddSelection(self.index,true)
        self:setData(self.petData)--初始化宠物信息
    else
        GComAlter(language.gonggong47)
    end
end

function PetCardsPanel:onClickRight()
    if self.index < #self.petConfData-1 then
        self.index = self.index + 1
        self.petData = self.petConfData[self.index+1]
        self.listView:ScrollToView(self.index,false)
        self.listView:AddSelection(self.index,true)
        self:setData(self.petData)--初始化宠物信息
    else
        GComAlter(language.gonggong48)
    end
end

function PetCardsPanel:initData(data)
    self.bx = nil
    self.petModel = nil
    self.petEffect = nil
    self.index = data.index or 0
    self.petConfData = {}
    self.latext.text = ""
    local showData = conf.PetConf:getAllPetItem()
    for k,v in pairs(showData) do--100101001
        if (v.id%1000) == 1 then
            table.insert(self.petConfData,v)
        end
    end
    table.sort(self.petConfData,function(a,b)
        -- if a.id ~= b.id then
        --     return a.id < b.id
        -- end
        if a.color == b.color then
            return a.id < b.id
        else
            return a.color < b.color
        end
    end)
    self.petData = self.petConfData[1]
    for k,v in pairs(self.petConfData) do
        if self.index == v.id then
            self.index = k - 1
            self.petData = v
            break
        end
    end

    self.listView.numItems = #self.petConfData
    self.listView:ScrollToView(self.index,false)
    self.listView:AddSelection(self.index,true)
    self:setData(self.petData)--初始化宠物信息
end

function PetCardsPanel:onMoveCall(context)
    -- body
    local data = context.sender.data
    self:move(data or 1)
end

function PetCardsPanel:move(var)
    -- body
    if not var or not self.petData then
        return
    end
    local condata = mgr.PetMgr:getPetByCondition(var,self.petData.id) 
    if condata then
        self.petData = condata
        self:setModel(self.petData)
    end
end

function PetCardsPanel:celldata(index,obj)
    if not self.petConfData then
        return
    end
    local data = self.petConfData[index+1]
    if data then
        local frame = obj:GetChild("n0")
        local icon = obj:GetChild("n3")
        local c1 = obj:GetController("c1")
        c1.selectedIndex = 0

        local petId = data.id
        local condata = conf.PetConf:getPetItem(petId)
        frame.url = ResPath.iconRes("beibaokuang_00"..condata.color)
        icon.url = ResPath.iconRes(condata.src)
        obj.data = data
    end
end

function PetCardsPanel:cellskilldata(index,obj)
    local data = self.petData.rec_id[index+1]
    obj.data = data
    local icon = obj:GetChild("n2") 
    --print(data,index+1)
    local jiaobiao = obj:GetChild("n4") 
    jiaobiao.visible = false
    if data then
        --print(data)
        local condata = conf.PetConf:getPetSkillById(data)
        if condata and condata.icon then
            icon.url = ResPath.iconRes(condata.icon)
            if condata.jiaobiao then
                jiaobiao.visible = true
                jiaobiao.url = ResPath.iconOther(condata.jiaobiao)
            end
        else
            print("缺少icon配置,pet_skill",data)
            icon.url = nil 
        end
    else
        icon.url = nil 
    end
end

function PetCardsPanel:onSkillCallBack(context)
    local sender = context.data
    local data = sender.data
    --print("当前点击技能信息",data)
    if not data then
        return
    end

    local param = {}
    param.data = data
    param.xy = 1
    mgr.ViewMgr:openView2(ViewName.PetSkillMsgTips, param)
end

function PetCardsPanel:onPetCallBack(context)
    -- body
    local data = context.data.data
    self.petData = data
    self:setData(data)
end

function PetCardsPanel:setData(data)
    printt("当前选择的宠物信息",data)
    self:setModel(data)
    --技能
    self.skillList.numItems = 6 
    --属性
    self:initPro()
    --获取途径
    self:initUpListView()
end

function PetCardsPanel:initUpListView()
    if self.petData then
        local upListView = self.view:GetChild("n38")
        upListView.itemRenderer = function(index,obj)
            obj.data = self.petData.formViews[index + 1]    
            local iconUrl = UIPackage.GetItemURL("_icons2" , tostring(self.petData.module_icons[index + 1]))
            if not iconUrl then
                iconUrl = UIPackage.GetItemURL("_icons" , tostring(self.petData.module_icons[index + 1]))
                if not iconUrl then
                    iconUrl = UIPackage.GetItemURL("main" , tostring(self.petData.module_icons[index + 1]))
                end
            end
            obj.icon = iconUrl
        end
        upListView.numItems = #self.petData.module_icons
        upListView.onClickItem:Add(self.onCallGoto,self)
    end
end

function PetCardsPanel:onCallGoto(context)
    local formView = context.data.data
    GOpenView({id = formView[1], childIndex = formView[2]})
end

function PetCardsPanel:setModel(data)
    -- body
    if not data then
        return
    end
    
    local condata = conf.PetConf:getPetItem(data.id)
    if not condata then
        return
    end

    self.nameTxt.text = condata.name
    self._pettype.url = UIItemRes.huoban01[condata.type]
    if self.petEffect then
        self.parent:removeUIEffect(self.petEffect)
        self.petEffect = nil 
    end
    if self.petModel then
        self.parent:removeModel(self.petModel)
        self.petModel = nil
    end

    if not self.petModel then
        self.petModel = self.parent:addModel(condata.model,self._panel)
    else
        self.petModel:setSkins(condata.model)
    end
    self.petModel:setScale(SkinsScale[Skins.newpet])
    self.petModel:setRotationXYZ(0,143.7,0)
    self.petModel:setPosition(self._panel.actualWidth/2,-self._panel.actualHeight-160,500)

    self.petEffect = self.parent:addEffect(4020102,self.effectNode)
    self.petEffect.LocalPosition = Vector3(self.effectNode.actualWidth/2,-self.effectNode.actualHeight+50,500)
    self.latext.text = ""
    if (data.id%1000) ~= 1 then
        local cc = mgr.PetMgr:getPetByCondition(-1,data.id) 
        if cc then
            self.latext.text = string.format(language.pet49,cc.max_lvl)
        end
    end

    if mgr.PetMgr:getPetByCondition(-1,data.id) then
        self.leftBtn.visible = true
    else
        self.leftBtn.visible = false
    end
    if mgr.PetMgr:getPetByCondition(1,data.id) then
        self.rightBtn.visible = true
    else
        self.rightBtn.visible = false
    end
end

function PetCardsPanel:initPro()
    -- body
    if not self.petData then
        return 
    end
    local confdata = conf.PetConf:getPetItem(self.petData.id)
    --宠物等级属性
    --最小等级属性
    local minConfdata = conf.PetConf:getLevelUp(confdata.type,0)
    local minProtable = GConfDataSort(minConfdata)
    -- for k , v in pairs(minProtable) do
    --     minProtable[k][2] = v[2]
    -- end
    -- --最大等级属性
    -- local maxConfdata = conf.PetConf:getMaxLeveUp(confdata.type)
    -- local maxProtable = GConfDataSort(maxConfdata)
    -- for k , v in pairs(maxProtable) do
    --     maxProtable[k][2] = math.floor(v[2] * self.petData.grow_field[2] / 100)
    -- end

    for k,v in pairs(self.protable) do
        v[1].text = conf.RedPointConf:getProName(minProtable[k][1])
        v[2].text = math.floor(minProtable[k][2]*(confdata.grow_field[1]/100)) .. "~" .. math.floor(minProtable[k][2]*(confdata.grow_field[2]/100))
    end
    self.skillNumTxt.text = #confdata.init_skill_num
    self.growNumTxt.text = language.pet47 .. (confdata.grow_field[1]/100) .. "~" .. (confdata.grow_field[2]/100)
    self.gradeTxt.text = confdata.grade
end

return PetCardsPanel