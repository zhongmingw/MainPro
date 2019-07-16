--
-- Author: Your Name
-- Date: 2018-07-05 16:22:43
--

local PetPanel = class("PetPanel",import("game.base.Ref"))

function PetPanel:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n65")
    self:initView()
end

function PetPanel:initView()
    self.c1 = self.view:GetController("c1")
    --宠物列表
    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onPetCallBack,self)
    --宠物信息
    self._pettype = self.view:GetChild("n9")
    self._pettype.url = nil 
    self._petname = self.view:GetChild("n10")
    self._petname.text = ""
    self._petlevel = self.view:GetChild("n12")
    self._petlevel.text = ""
    self._petscore = self.view:GetChild("n21")
    self._petscore.text = "0"
    self._panel = self.view:GetChild("n24")
    self.effectNode = self.view:GetChild("n58")

    local btnChangeName = self.view:GetChild("n53")
    btnChangeName.onClick:Add(self.onChangName,self)

    self.list1 = self.view:GetChild("n6")
    self.list1.itemRenderer = function(index,obj)
        self:celleqipdataleft(index, obj)
    end
    self.list1.numItems = 0
    self.list1.onClickItem:Add(self.onEquipCallBack,self)

    self.list2 = self.view:GetChild("n8")
    self.list2.itemRenderer = function(index,obj)
        self:celleqipdataRight(index, obj)
    end
    self.list2.numItems = 0
    self.list2.onClickItem:Add(self.onEquipCallBack,self)

    self.list3 = self.view:GetChild("n18")
    self.list3.itemRenderer = function(index,obj)
        self:cellskilldata(index, obj)
    end
    self.list3.numItems = 0
    self.list3.onClickItem:Add(self.onSkillCallBack,self)
    --出站
    self.btnonWar = self.view:GetChild("n13")
    self.btnonWar.title = language.pet04
    self.btnonWar.onClick:Add(self.onWar,self)

    self.btndelete = self.view:GetChild("n44")
    self.btndelete.title = language.pet40
    self.btndelete.onClick:Add(self.ondelete,self)

    self.btnskill1 = self.view:GetChild("n14")
    self.btnskill1.title = language.pet03
    self.btnskill1.onClick:Add(self.onSkillCall,self)

    self.btneuqip = self.view:GetChild("n17")
    self.btneuqip.title = language.pet02
    self.btneuqip.onClick:Add(self.onEquippCall,self)

    --属性模块
    self.plusvalue = self.view:GetChild("n34")
    self.plusvalue.text = ""

    local btnChengzhang = self.view:GetChild("n43")
    btnChengzhang.onClick:Add(self.onGrow,self)
    --
    self.listpro = self.view:GetChild("n41")
    self.listpro.itemRenderer = function(index,obj)
        self:cellprodata(index, obj)
    end
    self.listpro.numItems = 0

    local btnGuize = self.view:GetChild("n37")
    btnGuize.onClick:Add(self.onGuize,self)

    --3个道具
    self.itemlist = {}
    for  i = 38 , 40 do
        local item = self.view:GetChild("n"..i)
        item.visible = false

        table.insert(self.itemlist,item)
    end

    self.bar = self.view:GetChild("n42")

    self.btnFive = self.view:GetChild("n35")
    self.btnFive.data = 5
    self.btnFive.onClick:Add(self.onPetUp,self)
    self.btnOne = self.view:GetChild("n36")
    self.btnOne.data = 1
    self.btnOne.onClick:Add(self.onPetUp,self)

    --进阶设置
    self.itemObj = self.view:GetChild("n46")
    self.itemname = self.view:GetChild("n47")
    self.itemname.text = ""
    self.itemcost = self.view:GetChild("n48")
    self.itemcost.text = ""

    self.btnJingjie = self.view:GetChild("n50")
    self.btnJingjie.onClick:Add(self.onJingjie,self)

    local btnPlus = self.view:GetChild("n49")
    btnPlus.onClick:Add(self.onPlus,self)

    local dec1 = self.view:GetChild("n22")
    dec1.text = language.pet01
    local dec1 = self.view:GetChild("n23")
    dec1.text = language.pet01

    local dec2 = self.view:GetChild("n51") 
    dec2.text = language.pet43

    local panel = self.view:GetChild("n54")
    panel.onTouchBegin:Add(self.onTouchBegin,self)
    panel.onTouchEnd:Add(self.onTouchEnd,self)

    self.latext = self.view:GetChild("n55")
    self.latext.text = ""

    self._btnLeft = self.view:GetChild("n56")
    self._btnLeft.data = -1 
    self._btnLeft.onClick:Add(self.onMoveCall,self)

    self._btnRight = self.view:GetChild("n57")
    self._btnRight.data = 1 
    self._btnRight.onClick:Add(self.onMoveCall,self)
end


function PetPanel:onTouchBegin(context)
    -- body
    self.bx = context.data.x
end
function PetPanel:onTouchEnd(context)
    -- body
    if not self.bx then
        return
    end

    self.ex = context.data.x
    local dist = self.ex - self.bx
    if math.abs(dist) > 30 then
        if dist < 0 then 
            self:move(1)
        else 
            self:move(-1)
        end
    end
end

function PetPanel:onMoveCall(context)
    -- body
    local data = context.sender.data
    self:move(data or 1)
end

function PetPanel:move(var)
    -- body
    if not var or not self.model_petId then
        return
    end
    local condata = mgr.PetMgr:getPetByCondition(var,self.model_petId) 
    if condata then
        self.model_petId = condata.id
        self:setModel()
    end
end

function PetPanel:initData()
    -- body

    self.model_petId= nil 
    self.bx = nil 
    self.redpoint = {} 
    self.model = nil 
    self.effect = nil
    self.petData = nil 
    self.confdata = nil 
    self.c1.selectedIndex = 0
    for k ,v in pairs(self.itemlist) do
        GSetItemData(v,{},false)
    end
    self.latext.text = ""

    --请求一下宠物信息列表
    proxy.PetProxy:sendMsg(1490101)
end

function PetPanel:setData(data_)
    self.petData = data_ --当前宠物信息
    self.confdata = conf.PetConf:getPetItem(self.petData.petId)
    self._pettype.url = UIItemRes.huoban01[self.confdata.type]

    self.btndelete.title = language.pet40
    if self.warPetData then
        for k ,v in pairs(self.warPetData) do
            if v == self.petData.petRoleId  then
               --助战中
               self.btndelete.title = language.pet63
            end
        end
    end


    self._petname.text = mgr.TextMgr:getQualityStr1(self.petData.name, self.confdata.color) 
    self._petlevel.text = string.format(language.gonggong16,self.petData.level)
    --宠物评分

    self._petscore.text = mgr.PetMgr:getPetScore(self.petData)
    self.plusvalue.text = string.format(language.pet23,self.petData.growValue / 100) 

    self.model_petId = self.petData.petId
    self:setModel()
    --装备
    self.list1.numItems = 3
    self.list2.numItems = 3
    --技能
    self.list3.numItems = 6 
   -- printt("技能列表",self.petData.skillDatas)
    if self.petData.petRoleId == self.onwarpet then
        self.btnonWar.title = language.pet05
        self.btndelete.visible = false
        self:visiblered(true)
    else
        self.btnonWar.title = language.pet04
        self.btndelete.visible = true
        self:visiblered(false)
    end

     --消耗道具设置
    local _item = conf.PetConf:getValue("pet_exp_item")
    for k ,v in pairs(_item) do
        local packdata = cache.PackCache:getPackDataById(v)
        local info = clone(packdata)
        info.index = 0
        info.hidenumber = false
        GSetItemData(self.itemlist[k],info,true)
    end
    --属性计算
    self:initPro()
    
    self:setBar()
    --local nextconf = conf.PetConf:getLevelUp(self.confdata.type,self.petData.level+1)
    if not mgr.PetMgr:isPetMaxLevel(self.petData) then
        self.c1.selectedIndex = 0
    else
        if self.confdata.next_stage and self.confdata.jinjie_cost then
            self.c1.selectedIndex = 2--进阶
            --设置进阶信息
            local _t = {}
            _t.mid = self.confdata.jinjie_cost[1][1]
            _t.amount = 1--self.confdata.jinjie_cost[1][2]
            _t.bind = self.confdata.jinjie_cost[1][3]
            
            GSetItemData(self.itemObj ,_t,true)

            local itemconf = conf.ItemConf:getItem(_t.mid)
            self.itemname.text = mgr.TextMgr:getColorNameByMid(_t.mid)
            local packdata = cache.PackCache:getPackDataById(_t.mid)

            local ss = ""--packdata.amount
            if packdata.amount >= self.confdata.jinjie_cost[1][2] then
                ss = mgr.TextMgr:getTextColorStr(packdata.amount, 7)
            else
                ss = mgr.TextMgr:getTextColorStr(packdata.amount, 14)
            end
            ss = ss .. "/"..mgr.TextMgr:getTextColorStr(self.confdata.jinjie_cost[1][2], 7)
            self.itemcost.text = ss
        else
            self.c1.selectedIndex = 1
        end
    end  
end

function PetPanel:initPro()
    -- body
    if not self.petData then
        self.listpro.numItems = 0
        return 
    end
    self.protable = mgr.PetMgr:getPetPro(self.petData)

    self.listpro.numItems = #self.protable 

end

function PetPanel:setBar()
    -- body
    if not self.petData then
        return 
    end
    self.bar.value = self.petData.exp

    local confdata = conf.PetConf:getLevelUp(self.confdata.type,self.petData.level+1)
    self.bar.max = confdata and confdata.need_exp or self.petData.exp
end

function PetPanel:onWar()
    -- body
    if not self.petData then
        return
    end
    if self.petData.petRoleId == self.onwarpet then
        GComAlter(language.pet05)
        return
    end

    if not self.warPetData then
        return
    end

    for k ,v in pairs(self.warPetData) do
        if v == self.petData.petRoleId  then
            local params = {}
            params.type = 2
            params.sure = function( ... )
                -- body
                proxy.PetProxy:sendMsg(1490106,{petRoleId = self.petData.petRoleId})
            end
            params.richtext = language.pet55
            return GComAlter(params)
        end
    end
    proxy.PetProxy:sendMsg(1490106,{petRoleId = self.petData.petRoleId})
end

function PetPanel:ondelete()
    -- body
    if not self.petData then
        return
    end
     if not self.warPetData then
        return
    end
    if self.petData.petRoleId == self.onwarpet then
        return
    end
     for k ,v in pairs(self.warPetData) do
        if v == self.petData.petRoleId  then
           --助战中
            -- local params = {}
            -- params.type = 2
            -- params.sure = function( ... )
            --     -- body
            --     GComAlter(param)
            -- end
            -- params.richtext = language.pet64
            return GComAlter(language.pet63)
        end
    end

    if mgr.PetMgr:isHaveEquip(self.petData) then
        GComAlter(language.pet41)
        return
    end

    local confdata = conf.PetConf:getLevelUp(self.confdata.type,self.petData.level)
    local str = clone(language.pet42)
    str[2].text = string.format(str[2].text,self.petData.name)
    str[2].color = self.confdata.color
    str[2].quality = self.confdata.color

    local param = {}
    param.type = 20
    param.richtext = mgr.TextMgr:getTextByTable(str)
    param.sure = function()
        -- body
        proxy.PetProxy:sendMsg(1490108,{petRoleId = self.petData.petRoleId})
    end

    param.items = {}
    if confdata and confdata.release_reback_item then
        for k , v in pairs(confdata.release_reback_item) do
            local _t = {mid =v[1],amount = v[2]  ,bind = v[3]}
            table.insert(param.items,_t)
        end
    end
    local colorData = conf.PetConf:getReturnByColor(self.confdata.color)
    if colorData and colorData.awards then
         for k , v in pairs(colorData.awards) do
            local _t = {mid =v[1],amount = v[2]  ,bind = v[3]}
            table.insert(param.items,_t)
        end
    end
    if self.confdata.release_reback_item then
        for k , v in pairs(self.confdata.release_reback_item) do
            local _t = {mid =v[1],amount = v[2]  ,bind = v[3]}
            table.insert(param.items,_t)
        end
    end

   

    GComAlter(param)
end

function PetPanel:onChangName()
    -- body
    if not self.petData then
        return
    end
    mgr.ViewMgr:openView(ViewName.JueSeName,function(view)
        -- body
        view:setDataPetName(self.petData)
    end)
end

function PetPanel:onSkillCall()
    -- body
    if not self.petData then
        return
    end
    mgr.ViewMgr:openView2(ViewName.PetSkillView,self.petData)
end

function PetPanel:onEquippCall()
    -- body
    if not self.petData then
        return
    end
    local data = {data = self.petData,index = 0}
    mgr.ViewMgr:openView2(ViewName.PetEquipView,data)
end

function PetPanel:onPetUp(context)
    -- body
    if not self.petData then
        return
    end
    local param = {}
    param.petRoleId = self.petData.petRoleId
    param.upLevel = context.sender.data or 1
    proxy.PetProxy:sendMsg(1490102,param)
end

function PetPanel:onJingjie()
    -- body
    if not self.petData then
        return
    end
    local mId = self.confdata.jinjie_cost[1][1]
    local packdata = cache.PackCache:getPackDataById(mId)
    if packdata.amount < self.confdata.jinjie_cost[1][2] then
        GComAlter(language.gonggong11)
        return
    end

    local param = {}
    param.petRoleId = self.petData.petRoleId
    proxy.PetProxy:sendMsg(1490103,param)
end

function PetPanel:onPlus()
    -- body
    if not self.petData then
        return
    end
    local param = {}
    param.mId = self.confdata.jinjie_cost[1][1]
    GGoBuyItem(param)
end

function PetPanel:setModel()
    -- body
    if not self.petData  then
        return
    end
    if not self.model_petId then
        plog("没有配置模型")
        return
    end
    local condata = conf.PetConf:getPetItem(self.model_petId)
    if not condata then
        return
    end

    if self.effect then
        self.parent:removeUIEffect(self.effect)
        self.effect = nil 
    end

    if not self.model then
        self.model = self.parent:addModel(condata.model,self._panel)
    else
        self.model:setSkins(condata.model)
    end
    self.model:setScale(SkinsScale[Skins.newpet])
    self.model:setRotationXYZ(0,143.7,0)
    self.model:setPosition(self._panel.actualWidth/2,-self._panel.actualHeight-160,500)

    self.effect = self.parent:addEffect(4020102,self.effectNode)
    self.effect.LocalPosition = Vector3(self.effectNode.actualWidth/2,-self.effectNode.actualHeight+50,500)

    self.latext.text = ""
    if self.model_petId > self.petData.petId then
        --当前模型 未被激活
        local cc = mgr.PetMgr:getPetByCondition(-1,self.model_petId) 
        if cc then
            self.latext.text = string.format(language.pet49,cc.max_lvl)
        end
    end

    if mgr.PetMgr:getPetByCondition(-1,self.model_petId) then
        self._btnLeft.visible = true
    else
        self._btnLeft.visible = false
    end
    if mgr.PetMgr:getPetByCondition(1,self.model_petId) then
        self._btnRight.visible = true
    else
        self._btnRight.visible = false
    end
end

function PetPanel:celldata( index, obj )
    -- body
    if not self.data then
        return
    end
    local data = self.data[index+1]
    local frame = obj:GetChild("n0")
    local icon = obj:GetChild("n3")
    local c1 = obj:GetController("c1")
    obj.data = data
    local condata = conf.PetConf:getPetItem(data.petId)
    if not condata then
        obj.visible = false
        print("找不到宠物配置 pet ",data.petId)
        return
    end
    --print("data.petRoleId",self.onwarpet,data.petRoleId,data.petRoleId == self.onwarpet)
    if data.petRoleId == self.onwarpet then
        c1.selectedIndex = 1
        local confData = conf.SysConf:getModuleById(1188)
        if confData then
            --注册红点
            local redImg = obj:GetChild("red")
            local param = {}
            param.panel = redImg
            param.ids = confData.repoint
            mgr.GuiMgr:registerRedPonintPanel(param,self.parent:viewName())
        end
    else
        c1.selectedIndex = 0
    end

    frame.url = ResPath.iconRes("beibaokuang_00"..condata.color)
    icon.url = ResPath.iconRes(condata.src)
end

function PetPanel:onPetCallBack(context)
    -- body
    local data = context.data.data
    self:setData(data)
end

function PetPanel:getEquipDataByPart(part)
    -- body
    if not self.petData or not part then
        return nil 
    end

    return mgr.PetMgr:getEquipDataByPart(self.petData,part)
end

function PetPanel:setPetEquipData(part,obj)
    -- body
    local data = self:getEquipDataByPart(part)
    local frame = obj:GetChild("n0")
    frame.url = UIItemRes.pet01[part]

    local itemObj = obj:GetChild("n1")
    local t = data or {}
    -- if t.level then
    --     t.amount = t.level
    -- end
    GSetItemData(itemObj,t)
    -- local icon = obj:GetChild("n1")
    -- if data then 
    --     local condata = conf.ItemConf:getItem(data.mid) 
    --     icon.url = ResPath.iconRes(condata.src)
    -- else
    --     icon.url = nil
    -- end
    local level = obj:GetChild("n2")
    level.text = ""

    obj.data = data
end

function PetPanel:celleqipdataleft(index, obj)
    -- body
    local part = index+1
    self:setPetEquipData(part,obj)
end
function PetPanel:celleqipdataRight(index, obj)
    -- body
    local part = index + 1 + 3 
    self:setPetEquipData(part,obj)
end
function PetPanel:onEquipCallBack( context )
    -- body
    local data = context.data.data
    if data then
        local t = clone(data)
        t.notsenddata = true 

        local part = conf.ItemConf:getPart(t.mid)
        GSeeLocalItem(t,{self.petData,part})
    else
        self:onEquippCall()
    end
end
--
function PetPanel:cellprodata(index, obj)
    -- body
    local data = self.protable[index+1]
    local lab = obj:GetChild("n1")

    local dec = mgr.PetMgr:getProName(data)
    dec = dec .. "\n".. GProPrecnt(data[1],checkint(data[2]))
    lab.text = dec
end

function PetPanel:cellskilldata( index, obj )
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

function PetPanel:onSkillCallBack( context )
    -- body
    local sender = context.data
    local data = sender.data
    --print("当前点击技能信息",data)
    if not data then
        return
    end
    -- local xy = sender.parent:LocalToGlobal(sender.xy)
    -- xy.y = xy.y - 100
    -- xy.x = 275
    local param = {}
    param.data = data
    param.xy = 1
    mgr.ViewMgr:openView2(ViewName.PetSkillMsgTips, param)
end

function PetPanel:onGrow()
    -- body
    if not self.data or not self.petData then
        return
    end
    mgr.ViewMgr:openView2(ViewName.PetGrowView, self.petData)
end

function PetPanel:onGuize()
    -- body
    GOpenRuleView(1076)
end

function PetPanel:addMsgCallBack(data)
    -- body
    --重新计算红点个数
    self:resetRedpoint()

    self.data = cache.PetCache:getData()
    if data.msgId == 5490101 
        or data.msgId == 5490106 
        or data.msgId == 5490108  then
        --宠物信息 -- 宠物出战 --宠物放生  
        --排序
        self.onwarpet = cache.PetCache:getCurpetRoleId()
        if self.warPetData then
            for k , v in pairs(self.warPetData) do
                if v == self.onwarpet then
                    self.warPetData[k] = 0
                    break
                end
            end
        end

        mgr.PetMgr:sortPet(self.data)
        self.listView.numItems = #self.data

        --当前选择
        local index = 0
        -- for k ,v in pairs(self.data) do
        --     if v.petRoleId == self.onwarpet then
        --         index = k -1 
        --         --self.listView.AddSelection(k,false)
        --         --self:setData(v)
        --         break
        --     end 
        -- end
        --如果灭有任何选择选择第一个
        --print(index,"index")
        if self.listView.numItems > 0 then
            self.listView:AddSelection(index,false)
            self:setData(self.data[index+1])
        end


    elseif data.msgId == 5490102 
        or data.msgId == 5490103
        or data.msgId == 5490104 
        or data.msgId == 5490107  
        or data.msgId == 5490109 
        or data.msgId == 5490111 
        or data.msgId == 5490105  then
        --升级 --进阶 --装备穿戴 --技能学习 ,资质丹使用 ,--装备吞噬
        if self.petData then
            local info  = cache.PetCache:getPetData(self.petData.petRoleId)
            if info then
                self:setData(info)
            end
        end
    elseif data.msgId == 5490201 then
        self.warPetData = data.warPetData
    end
    
end

function PetPanel:visiblered(flag)
    -- body
    local equip = self.btneuqip:GetChild("red")
    local Five = self.btnFive:GetChild("red")
    local One = self.btnOne:GetChild("red")
    local jie = self.btnJingjie:GetChild("red")
    local id = cache.PetCache:getCurpetRoleId()
    if flag and self.redpoint[id] then
        if self.redpoint[id]["equip"] then
            equip.visible = true
        else
            equip.visible = false
        end
        if self.redpoint[id]["exp"] then
            Five.visible = true
            One.visible = true
        else
            Five.visible = false
            One.visible = false
        end
        if self.redpoint[id]["jie"] then
            jie.visible = true
        else
            jie.visible = false
        end
    else
        equip.visible = false
        Five.visible = false
        One.visible = false
        jie.visible = false
    end
end

function PetPanel:resetRedpoint()
    -- body
    --红点相关：
    --1.已出战的宠物可以升级时。（入口+按钮）
    --2.已出战的宠物的装备可以升级（入口+按钮）

    --当前出战宠物
    local number = 0
    local info  = cache.PetCache:getPetData(cache.PetCache:getCurpetRoleId())
    if not info then
        mgr.GuiMgr:redpointByVar(attConst.A10255,number,2)
        return
    end
    self.redpoint[info.petRoleId] = {}
    --计算宠物差多少经验升级
    local confdata = conf.PetConf:getPetItem(info.petId)
    if mgr.PetMgr:isPetMaxLevel(info) then
        --顶级了
        if confdata.next_stage and confdata.jinjie_cost then
             local _t = {}
            _t.mid = confdata.jinjie_cost[1][1]
            _t.amount = 1

            local packdata = cache.PackCache:getPackDataById(_t.mid)
            if packdata.amount >= confdata.jinjie_cost[1][2] then
                number = number + 1 --可进阶
                self.redpoint[info.petRoleId]["jie"] = 1
            end
        end
    else
        local nextconf = conf.PetConf:getLevelUp(confdata.type,info.level+1)
        if nextconf and nextconf.need_exp then
            local needexp = nextconf.need_exp - info.exp
            if needexp > 0 then
                local _item = conf.PetConf:getValue("pet_exp_item")
                for k ,v in pairs(_item) do
                    local packdata = cache.PackCache:getPackDataById(v)
                    if packdata.amount > 0 then
                        local _item = conf.ItemConf:getItem(v)
                        if _item and _item.ext01 then
                            needexp = needexp - _item.ext01*packdata.amount
                            if needexp <= 0 then
                                self.redpoint[info.petRoleId]["exp"] = 1
                                number = number + 1 
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    --计算是否有装备可升级
    if #info.equipInfos > 0 then
        local packdata = mgr.PetMgr:getPetPackEquip()
        for k ,v in pairs(info.equipInfos) do
            local cc = clone(v)
            cc.level = cc.level + 1 
            local nextconf = conf.PetConf:getEquipLevelUp(cc)
            if nextconf and nextconf.need_exp then
                --如果有下一级
                local needexp = nextconf.need_exp - cc.exp
                if needexp > 0 then
                    local enough = false
                    for i , j in pairs(packdata) do
                        local exp = mgr.PetMgr:getEquipExp(j)
                        needexp = needexp - exp
                        if needexp <= 0 then
                            self.redpoint[info.petRoleId]["equip"] = 1
                            number = number + 1 
                            enough = true
                            break
                        end
                    end
                    if enough then
                        break
                    end
                else
                    break
                end
            end
        end
    end

    mgr.GuiMgr:redpointByVar(attConst.A10255,number,2)
end

return PetPanel