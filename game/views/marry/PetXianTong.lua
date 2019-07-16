--
-- Author: 
-- Date: 2018-08-06 15:44:25
--

local PetXianTong = class("PetXianTong",import("game.base.Ref"))

function PetXianTong:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n9")
    self:initView()
end

function PetXianTong:initView()
    self.c1 = self.view:GetController("c1")
    --宠物列表
    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onPetCallBack,self)

    --宠物信息
    self._petname = self.view:GetChild("n10")
    self._petname.text = ""
    self._petlevel = self.view:GetChild("n12")
    self._petlevel.text = ""
    self._petscore = self.view:GetChild("n21")
    self._petscore.text = "0"
    self._panel = self.view:GetChild("n54")
    self.effectNode = self.view:GetChild("n58")

    local btnChangeName = self.view:GetChild("n53")
    btnChangeName.onClick:Add(self.onChangName,self)

    self.list1 = self.view:GetChild("n6")
    self.list1.itemRenderer = function(index,obj)
        self:celleqipdataleft(index, obj)
    end
    self.list1.numItems = 0
    self.list1.onClickItem:Add(self.onTianFuCallBack,self)

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
    self.btndelete.title = language.xiantong14
    self.btndelete.onClick:Add(self.ondelete,self)

    self.btnskill1 = self.view:GetChild("n14")
    self.btnskill1.title = language.pet03
    self.btnskill1.onClick:Add(self.onSkillCall,self)

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
    dec1.text = language.xiantong27
    local dec1 = self.view:GetChild("n23")
    dec1.text = language.xiantong11

    self.xin = self.view:GetChild("n99"):GetController("c1")
end

function PetXianTong:onPetCallBack( context )
    -- body
    local data = context.data.data
    self:setData(data)
end

function PetXianTong:celldata(index, obj)
    -- body
    if not self.data then
        return
    end
    local data = self.data[index+1]
    local frame = obj:GetChild("n0")
    local icon = obj:GetChild("n3")
    local c1 = obj:GetController("c1")
    obj.data = data
    local condata = conf.MarryConf:getPetItem(data.xtId)
    if not condata then
        obj.visible = false
        return
    end
    --print("data.petRoleId",self.onwarpet,data.petRoleId,data.petRoleId == self.onwarpet)
    if data.xtRoleId == self.onwarpet then
        c1.selectedIndex = 1
        -- local confData = conf.SysConf:getModuleById(1304)
        -- if confData then
        --     --注册红点
        --     local redImg = obj:GetChild("red")
        --     local param = {}
        --     param.panel = redImg
        --     param.ids = confData.repoint
        --     mgr.GuiMgr:registerRedPonintPanel(param,self.parent:viewName())
        -- end
    else
        c1.selectedIndex = 0
    end

    frame.url = ResPath.iconRes("beibaokuang_00"..condata.color)
    icon.url = ResPath.iconRes(condata.src)
end

function PetXianTong:celleqipdataleft(index, obj)
    -- body
    local data = self.xt_talent[index+1]
    local icon = obj:GetChild("n2")
    local labLv = obj:GetChild("n3")
    --local lv = self.petData.talentInfo[data.id]
    icon.url = ResPath.iconRes(data.icon)
    labLv.text = ""

    local c1 = obj:GetController("c1")
    c1.selectedIndex = self.petData.talentInfo[data.id] and 0 or 1
    if data.lock then
        c1.selectedIndex = 2
    end
    obj.data = data

    --红点
    local redimg = obj:GetChild("n4")
    redimg.visible = false
end
function PetXianTong:celleqipdataRight(index, obj)
    -- body
    local data = self.xt_equip[index+1]

    local frame = obj:GetChild("n4")
    local icon = obj:GetChild("n1") 
    local labLv = obj:GetChild("n2")

    
    local lv = self.petData.equipInfo[data.id]
    
    frame.url = UIItemRes.beibaokuang[data.color]
    icon.url = ResPath.iconRes(data.icon)-- UIPackage.GetItemURL("_icons" , ""..data.icon)
    local lv  = lv and lv or 0 
    if lv > 1 then
        labLv.text = "+"..(lv - 1)
    else
        labLv.text = ""
    end

    local c1 = obj:GetController("c1")
    c1.selectedIndex = lv>0 and 0 or 1

    obj.data = data

    local redimg = obj:GetChild("n5")
    redimg.visible = false
    --计算装备是否可以升级
    redimg.visible = self:checkPoint(data)
end


function PetXianTong:cellskilldata( index, obj )
    -- body
    --local id = self.keys[index+1]
    local data = self.petData.skillInfo[index+1]
    obj.data = data
    local icon = obj:GetChild("n2") 
    --print(data,index+1)
    local jiaobiao = obj:GetChild("n4") 
    jiaobiao.visible = false
    if data then
        --print(data)
        local condata = conf.MarryConf:getPetSkillById(data)
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

function PetXianTong:cellprodata( index, obj )
    -- body
    local data = self.protable[index+1]
    local lab = obj:GetChild("n1")

    local dec = conf.RedPointConf:getProName(data[1])
    dec = dec .. "\n".. GProPrecnt(data[1],checkint(data[2]))
    lab.text = dec
end

function PetXianTong:setModel()
    -- body
    if not self.petData  then
        return
    end
    if not self.model_petId then
        plog("没有配置模型")
        return
    end
    local condata = conf.MarryConf:getPetItem(self.model_petId)
    if not condata then
        return
    end

    if self.effect then
        self.parent:removeUIEffect(self.effect)
        self.effect = nil 
    end
    --print("condata.model",condata.model)
    if not self.model then
        self.model = self.parent:addModel(condata.model,self._panel)
    else
        self.model:setSkins(condata.model)
    end
    self.model:setScale(SkinsScale[Skins.newpet])
    self.model:setRotationXYZ(0,180,0)
    self.model:setPosition(self._panel.actualWidth/2,-self._panel.actualHeight-160,500)

    self.effect = self.parent:addEffect(4020102,self.effectNode)
    self.effect.LocalPosition = Vector3(self.effectNode.actualWidth/2,-self.effectNode.actualHeight+50,500)
end

function PetXianTong:setData(data_,flag)
    -- body
    self.petData = data_ --当前宠物信息
    self.confdata = conf.MarryConf:getPetItem(self.petData.xtId)
    self.btndelete.title = language.xiantong14

    self._petname.text = mgr.TextMgr:getQualityStr1(self.petData.name, self.confdata.color) 
    --self._petlevel.text = string.format(language.gonggong16,self.petData.level)

    self._petscore.text = self.petData.power
    self.plusvalue.text = string.format(language.pet23,self.petData.growValue / 100) 

    self.model_petId = self.petData.xtId
    self:setModel()
    --天赋
    self.xt_talent = conf.MarryConf:getTalent()
    self.list1.numItems = #self.xt_talent
    --装备
    self.xt_equip = conf.MarryConf:getEquip() 
    self.list2.numItems = #self.xt_equip
    --技能
    -- self.keys = table.keys(self.petData.skillInfo)
    -- table.sort(self.keys,function(a,b)
    --     -- body
    --     return a<b
    -- end)
    self.list3.numItems = 6 

    if self.petData.xtRoleId == self.onwarpet then
        self.btnonWar.title = language.pet05
        self.btndelete.visible = false
        --self:visiblered(true)
    else
        self.btnonWar.title = language.pet04
        self.btndelete.visible = true

        if self.warXtData then
            for k ,v in pairs(self.warXtData) do
                if v == self.petData.xtRoleId  then
                   --助战中
                   self.btndelete.title = language.pet63
                end
            end
        end
    end

    --消耗道具设置
    self.condata = conf.MarryConf:getXTlev(self.petData.level)
    self._petlevel.text = string.format(language.huoban24,language.gonggong21[self.condata.jie] or "0")
    if flag or  self.condata.xing == 0 then
        self.xin.selectedIndex = self.condata.xing
    else
        self.xin.selectedIndex = self.condata.xing + 10
    end
    
    --local _item = conf.MarryConf:getValue("pet_exp_item")
    local nextcondata = conf.MarryConf:getXTlev(self.petData.level + 1)

    if self.condata.cost_items and nextcondata then
        self.c1.selectedIndex = 0
        local _t = {}
        _t.mid = self.condata.cost_items[1]
        _t.amount = 1--self.confdata.jinjie_cost[1][2]
        _t.bind = self.condata.cost_items[3] or 1
        _t.isquan = true
        GSetItemData(self.itemObj ,_t,true)
        
        local itemconf = conf.ItemConf:getItem(_t.mid)
        self.itemname.text = mgr.TextMgr:getColorNameByMid(_t.mid)
        local packdata = cache.PackCache:getPackDataById(_t.mid)
        local ss = ""--packdata.amount
        if packdata.amount >= self.condata.cost_items[2] then
            ss = mgr.TextMgr:getTextColorStr(packdata.amount, 7)
            self.btnJingjie:GetChild("red").visible = true
        else
            ss = mgr.TextMgr:getTextColorStr(packdata.amount, 14)
            self.btnJingjie:GetChild("red").visible = false
        end
        ss = ss .. "/"..mgr.TextMgr:getTextColorStr(self.condata.cost_items[2], 7)
        self.itemcost.text = ss

        self.mId = _t.mid
    else
        self.c1.selectedIndex = 1
    end

    self:initPro()
end

function PetXianTong:initPro()
    -- body
    if not self.petData then
        self.listpro.numItems = 0
        return 
    end
    self.protable = mgr.XianTongMgr:getPetPro(self.petData)

    self.listpro.numItems = #self.protable 
end

function PetXianTong:onChangName()
    -- body
    if not self.petData then
        return
    end
    mgr.ViewMgr:openView(ViewName.JueSeName,function(view)
        -- body
        view:setXTDataName(self.petData)
    end)
end

function PetXianTong:onEquipCallBack( context )
    -- body
    local data = context.data.data
    local info = clone(data) 
    info.level = self.petData.equipInfo[info.id] or 0
    info.petlevel = self.petData.level
    info.xtRoleId = self.petData.xtRoleId
    mgr.ViewMgr:openView2(ViewName.XianTongEquipUp,info)
end

function PetXianTong:onSkillCallBack( context )
    -- body
    local data = context.data.data
    
    if data then
        local condata = clone(conf.MarryConf:getPetSkillById(data))
        condata.pos = 1
        ---printt(condata)
        local view = mgr.ViewMgr:get(ViewName.XiantongSkillMsgTips)
        if view then
            view:initData(condata)
        else
            mgr.ViewMgr:openView2(ViewName.XiantongSkillMsgTips,condata) 
        end
    end
end

function PetXianTong:onTianFuCallBack( context )
    -- body
    if not self.petData then return end
    local t = {}
    t.info = context.data.data
    t.petData = self.petData

    if t.info.lock then
        GComAlter(language.xiantong29)
        return
    end
    mgr.ViewMgr:openView2(ViewName.XianTongSkillUp,t)
end

function PetXianTong:onWar()
    -- body
    if not self.petData then return end
    if not self.warXtData then
        return
    end
    for k ,v in pairs(self.warXtData) do
        if v == self.petData.xtRoleId  then
            local params = {}
            params.type = 2
            params.sure = function( ... )
                -- body
                proxy.PetProxy:sendMsg(1390606,{xtRoleId = self.petData.xtRoleId})
            end
            params.richtext = language.xiantong40
            return GComAlter(params)
        end
    end
    local param = {}
    param.xtRoleId = self.petData.xtRoleId
    if param.xtRoleId == self.onwarpet then
        return GComAlter(language.pet05)
    end
    proxy.MarryProxy:sendMsg(1390606,param)
end
function PetXianTong:ondelete()
    -- body
    if not self.petData then return end
    --条件判定
    if self.petData.xtRoleId == self.onwarpet then
        return GComAlter(language.xiantong16)
    end
    if self.listView.numItems == 1 then
        return GComAlter(language.xiantong17)
    end
    for k ,v in pairs(self.warXtData) do
        if v == self.petData.xtRoleId  then
            return GComAlter(language.pet63)
        end
    end

    mgr.ViewMgr:openView2(ViewName.XianTongDelete,self.petData)
end



function PetXianTong:onSkillCall()
    -- body
    if not self.petData then return end
    mgr.ViewMgr:openView2(ViewName.XianTongSkillView,self.petData)
end

function PetXianTong:onGuize()
    -- body
    GOpenRuleView(1121)
end

function PetXianTong:onJingjie()
    -- body
    if not self.petData then return end
    local param = {}
    param.xtRoleId = self.petData.xtRoleId
    --print("param.xtRoleId",param.xtRoleId)
    proxy.MarryProxy:sendMsg(1390602,param)
end

function PetXianTong:onPlus( ... )
    -- body
    if not self.mId  then return end
    local param = {}
    param.mId = self.mId 
    GGoBuyItem(param)
end

function PetXianTong:onGrow( ... )
    -- body
    if not self.petData then return end
    mgr.ViewMgr:openView2(ViewName.XianTongGrowView,self.petData)
end

function PetXianTong:setVisible( flag )
    -- body
    self.view.visible = flag
end

function PetXianTong:addMsgCallBack(data)
    -- body

    self.data = cache.MarryCache:getXTData()
    if 5390601 == data.msgId or 5390606 == data.msgId or 5390607 == data.msgId then
        if #self.data<= 0 then
            GComAlter(language.xiantong13)
            self.parent:goToByC1(self.parent.lastId or 5)

            return
        end
        --self.data = data 
        self:setVisible(true)

        self.onwarpet = cache.MarryCache:getCurpetRoleId()
        --print(#self.data,"self.data")
        mgr.XianTongMgr:sortPet(self.data)
        self.listView.numItems = #self.data

        local index = 0
        if self.listView.numItems > 0 then
            self.listView:AddSelection(index,false)
            self:setData(self.data[index+1])
        end

        if 5390606 == data.msgId and data.xtRoleId == self.onwarpet then
            --如果出站仙童
            local condata = conf.MarryConf:getXTlev(self.petData.level)
            cache.PlayerCache:setDataJie(1304,condata.jie)
        end
    elseif 5390602 == data.msgId then
        self.petData.talentInfo = data.talentInfo
        self.petData.level = data.level
        self:setData(self.petData,true)

        if data.xtRoleId == self.onwarpet then
            --如果出站仙童
            local condata = conf.MarryConf:getXTlev(self.petData.level)
            cache.PlayerCache:setDataJie(1304,condata.jie)
        end

    elseif 5390603 == data.msgId then
        self.petData.equipInfo[data.equipId] = data.lev
        self:setData(self.petData)
    elseif 5390605 == data.msgId then
        -- 请求仙童技能学习
        self.petData.skillInfo = data.skillInfo
        self:setData(self.petData)
    elseif 5390609 == data.msgId then
        --成长改变
        self.petData.growValue = data.growValue
        self:setData(self.petData)
    elseif 5390608 == data.msgId then
        self.petData.name = data.name
        self:setData(self.petData)
    elseif 8170203 == data.msgId then

        self.petData.power = data.power[self.petData.xtRoleId]
        self:setData(self.petData)
    elseif 5390610 == data.msgId then
        self.warXtData = data.warXtData
        self:setData(self.petData)
    end

    self:resetRedpoint()
end


function PetXianTong:checkPoint(data)
    -- body
    if not self.petData then
        return
    end

    local lv = self.petData.equipInfo[data.id] or 0
    local conddata = conf.MarryConf:getXTlev(self.petData.level)
    local confup = conf.MarryConf:getEquipByLev(data.id,lv)
    local nextconf = conf.MarryConf:getEquipByLev(data.id,lv+1)
    if not nextconf then
        return false
    end
    local needlv = confup.need_lev
    local curjie = conddata.jie
    if needlv > curjie then
        return false
    end

    local mid = confup.cost_items[1][1]
    local needamount = confup.cost_items[1][2]
    local itemCount = cache.PackCache:getPackDataById(mid)
    return itemCount.amount >= needamount
end

function PetXianTong:resetRedpoint()
    -- body
    if not self.petData then
        return
    end
    local number = 0
    if self.btnJingjie:GetChild("red").visible then
        number = 1
    else
        for k ,v in pairs(self.xt_equip) do
            if self:checkPoint(v) then
                number = 1
                break
            end
        end
    end

    mgr.GuiMgr:redpointByVar(10263,number,2)
end



return PetXianTong