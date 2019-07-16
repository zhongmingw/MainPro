--
-- Author: wx
-- Date: 2018-03-16 14:39:56
-- 宠物信息界面查看

local seePetPanel = class("seePetPanel",import("game.base.Ref"))

function seePetPanel:ctor(mParent)
    self.mParent = mParent
    self:initView()
end

function seePetPanel:initView()
    -- body
    self.view = self.mParent.view:GetChild("n27")
    self.view.visible = false
    --宠物信息
    self._pettype = self.view:GetChild("n37")
    self._pettype.url = nil 
    self._petname = self.view:GetChild("n38")
    self._petname.text = ""
    self._petlevel = self.view:GetChild("n39")
    self._petlevel.text = ""
    self._petscore = self.view:GetChild("n40")
    self._petscore.text = "0"
    self._panel = self.view:GetChild("n31")

    self.list1 = self.view:GetChild("n33")
    self.list1.itemRenderer = function(index,obj)
        self:celleqipdataleft(index, obj)
    end
    self.list1.numItems = 0
    self.list1.onClickItem:Add(self.onEquipCallBack,self)

    self.list2 = self.view:GetChild("n34")
    self.list2.itemRenderer = function(index,obj)
        self:celleqipdataRight(index, obj)
    end
    self.list2.numItems = 0
    self.list2.onClickItem:Add(self.onEquipCallBack,self)

    self.list3 = self.view:GetChild("n35")
    self.list3.itemRenderer = function(index,obj)
        self:cellskilldata(index, obj)
    end
    self.list3.numItems = 0
    self.list3.onClickItem:Add(self.onSkillCallBack,self)


     --属性模块
    self.plusvalue = self.view:GetChild("n43")
    self.plusvalue.text = ""

    self.listpro = self.view:GetChild("n36")
    self.listpro.itemRenderer = function(index,obj)
        self:cellprodata(index, obj)
    end
    self.listpro.numItems = 0

    local btnGuize = self.view:GetChild("n21")
    btnGuize.onClick:Add(self.onGuize,self)

    self.maxlevelimg = self.view:GetChild("n15")

    --
    local dec1 = self.view:GetChild("n41")
    dec1.text = language.pet01
    local dec1 = self.view:GetChild("n42")
    dec1.text = language.pet01
end

function seePetPanel:getEquipDataByPart(part)
    -- body
    if not self.petData or not part then
        return nil 
    end
    return mgr.PetMgr:getEquipDataByPart(self.petData,part)
end

function seePetPanel:setPetEquipData(part,obj)
    -- body
    local data = self:getEquipDataByPart(part)
    local frame = obj:GetChild("n0")
    frame.url = UIItemRes.pet01[part]

    local itemObj = obj:GetChild("n1")
    local t = data or {}

    GSetItemData(itemObj,t)

    local level = obj:GetChild("n2")
    level.text = ""

    obj.data = data
end

function seePetPanel:celleqipdataleft(index, obj)
    -- body
    local part = index+1
    self:setPetEquipData(part,obj)
end
function seePetPanel:celleqipdataRight(index, obj)
    -- body
    local part = index + 1 + 3 
    self:setPetEquipData(part,obj)
end

function seePetPanel:cellprodata(index, obj)
    -- body
    local data = self.protable[index+1]
    local lab = obj:GetChild("n1")

    lab.text = mgr.PetMgr:getProName(data).."\n".. GProPrecnt(data[1],checkint(data[2]))
    --conf.RedPointConf:getProName(data[1]).."\n".. GProPrecnt(data[1],checkint(data[2]))
end

function seePetPanel:onEquipCallBack(context)
    -- body
    local data = context.data.data
    if data then
        -- local t = clone(data)
        -- t.notsenddata = true 
        -- local part = conf.ItemConf:getPart(t.mid)
        -- GSeeLocalItem(t,{self.petData,part,true})
        mgr.ViewMgr:openView(ViewName.EquipPetTipsView,function(view)
            view:setData(data)
        end)
    end
end

function seePetPanel:onSkillCallBack( context )
    -- body
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

function seePetPanel:cellskilldata( index, obj )
    -- body
    local data = self.petData.skillDatas[index+1]
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

function seePetPanel:onGuize()
    -- body
    GOpenRuleView(1076)
end

function seePetPanel:initPro()
    -- body
    if not self.petData then
        self.listpro.numItems = 0
        return 
    end
    self.protable = mgr.PetMgr:getPetPro(self.petData)

    self.listpro.numItems = #self.protable 

end

function seePetPanel:setModel()
    -- body
    if not self.petData or not self.confdata then
        return
    end
    if not self.confdata.model then
        plog("没有配置模型")
        return
    end

    if not self.model then
        self.model = self.mParent:addModel(self.confdata.model,self._panel)
    else
        self.model:setSkins(self.confdata.model)
    end
    self.model:setScale(SkinsScale[Skins.newpet])
    self.model:setRotationXYZ(0,143.7,0)
    self.model:setPosition(self._panel.actualWidth/2,-self._panel.actualHeight-160,500)
end

function seePetPanel:setData( data )
    -- body
    self.view.visible = true

    self.petData = data.petInfo --当前宠物信息

    self.confdata = conf.PetConf:getPetItem(self.petData.petId)
    self._pettype.url = UIItemRes.huoban01[self.confdata.type]
    self._petname.text = mgr.TextMgr:getQualityStr1(self.petData.name, self.confdata.color) 
    self._petlevel.text = string.format(language.gonggong16,self.petData.level)
    self._petscore.text = mgr.PetMgr:getPetScore(self.petData)
    self.plusvalue.text = string.format(language.pet23,self.petData.growValue / 100) 

    self:setModel()

    --装备
    self.list1.numItems = 3
    self.list2.numItems = 3
    --技能
    self.list3.numItems = 6 
    --属性计算
    self:initPro()

    self.maxlevelimg.visible = false-- mgr.PetMgr:isPetMaxLevel(self.petData)
end

return seePetPanel