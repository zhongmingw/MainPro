--
-- Author: 
-- Date: 2017-09-21 11:43:26
--

local SuitPanel = class("SuitPanel",import("game.base.Ref"))

local redPoint = {}

function SuitPanel:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n10")
    self:initView()
end

function SuitPanel:initView()
    -- body
    self.data = conf.ForgingConf:getAllSuit(3)
    self.cellred = {}

    self.listView = self.view:GetChild("n169")
    self.listView.itemRenderer = function(index,obj)
        self:cellseverdata(index, obj)
    end
    self.listView.numItems = #self.data
    self.listView.onClickItem:Add(self.onBtnServerCallBack,self)

    self.panel = self.view:GetChild("n3")
    self.isDownloadimg = self.view:GetChild("n88")

    self.equiplist = {}
    for i = 71 , 80 do
        local btn = self.view:GetChild("n"..i)
        table.insert(self.equiplist,btn)
    end
    --套装属性
    self.icon1 = self.view:GetChild("n35") 
    self.list1 = self.view:GetChild("n93")
    self.list2 = self.view:GetChild("n99")

    self.btn = self.view:GetChild("n52")
    self.btn.onClick:Add(self.onJihuo,self)

    local btnskill1 = self.view:GetChild("n755")
    btnskill1.data = 1
    btnskill1.onClick:Add(self.onSkillCall,self)

    local btnskill1 = self.view:GetChild("n766")
    btnskill1.data = 2
    btnskill1.onClick:Add(self.onSkillCall,self)
end

function SuitPanel:cellseverdata(index, obj)
    -- body
    local _t = self.data[index+1]
    obj.data = index + 1 
    local icon = obj:GetChild("n3")
    icon.url = ResPath.iconload(_t.font,"awaken")

    local red = obj:GetChild("n4") 
    self.cellred[index+1] = red 
end

function SuitPanel:onBtnServerCallBack(context)
    -- body
    local data = context.data.data
    self:equipMsg(data)
end

function SuitPanel:initModel()
    -- body
    self.jsLevel = cache.PlayerCache:getRedPointById(10205) --剑神等级
    self.attrData = conf.AwakenConf:getJsAttr(self.jsLevel)
    local curModelId = self.attrData and self.attrData.starlv or 1 --阶

    local buffId = conf.AwakenConf:getBuffId(curModelId)
    local buffData = conf.BuffConf:getBuffConf(buffId)
    local model = buffData.bs_args
    local cansee = false
    if not self.model or self.model:isDispose() then
        self.model = self.parent:addModel(model[1],self.panel)
        cansee = self.model:setSkins(nil,model[2],model[3])
    else
        cansee = self.model:setSkins(model[1],model[2],model[3])
    end

    self.model:setPosition(self.panel.actualWidth/2,-self.panel.actualHeight-200,500)
    self.model:setScale(150)
    local sex = cache.PlayerCache:getSex()
    local angle = RoleSexModel[sex].angle
    self.model:setRotation(angle)

    self.isDownloadimg.visible = cansee

end

function SuitPanel:selectIndex(index)
    -- body
    self.listView:AddSelection(index-1,false)
    self:equipMsg(index)
end

function SuitPanel:isWear(id)
    -- body
    if self.msgData then
        for k , v in pairs(self.msgData.dressEquips) do
            if v == id then
                return true
            end
        end
    end
    return false
end

function SuitPanel:isJihuo(id)
    -- body
    if self.msgData then
        for k , v in pairs(self.msgData.activedEffects) do
            if v == id then
                return true
            end
        end
    end
    return false
end

function SuitPanel:equipMsg(index)
    -- body
    --取套装信息
    if not self.msgData then
        return
    end
    --printt(self.msgData.dressEquips)

    self.condata = self.data[index]
    if not self.condata then
        return
    end
    self.index = index
    --设置套装信息
    local _allequip = {} --用于计算总属性

    self.jienum = 0
    for k ,v in pairs(self.condata.equip_ids) do
        local _t = conf.ItemArriConf:getItemAtt(v)
        table.insert(_allequip,_t)

        local btn = self.equiplist[k]
        local _t = {mid = v,amount = 1,bind = 1}
        if btn then
            local itemObj = btn:GetChild("n3")
            GSetItemData(itemObj,_t,true)
            --是否穿戴过
            local flag = self:isWear(v)
            btn:GetChild("n4").visible = flag
            if flag then
                self.jienum = self.jienum + 1
            end
        end
    end

    self.icon1.url = ResPath.iconload(self.condata.font,"awaken")
    self.list1.numItems = 0
    --战力和进度
    local curNum = self.jienum --收集个数
    local confall = conf.ForgingConf:getSuitEffect(self.condata.id)
    local max = 0
    for k ,v in pairs(confall) do
        if v.equip_num > curNum then
            max = v.equip_num
        end
    end
    if max == 0 then
        max = curNum
    end
    local confeffect = conf.ForgingConf:getSuitEffect(self.condata.id,curNum,true)
    local var = UIPackage.GetItemURL("awaken" , "Component3")
    local _compent1 = self.list1:AddItemFromPool(var)
    _compent1:GetChild("n2").text = confeffect.power
    local bar = _compent1:GetChild("n1")
    bar.value = curNum
    bar.max = max
    _compent1:GetChild("n4").text = string.format("(%d/%d)",bar.value,bar.max)
    --套装属性
    self.listjihuo = {} --待激活列表
    local pro = {} --累计属性
    local pairs = pairs
    for  k ,v in pairs(confall) do
        local var = UIPackage.GetItemURL("awaken" , "Component2")
        local _compent1 = self.list1:AddItemFromPool(var)
        --几件套
        _compent1:GetChild("n6").text = string.format(language.forging11,v.equip_num)
        --是否激活
        if  not self:isJihuo(v.id) then
            _compent1:GetChild("n7").text =  language.gonggong09

            table.insert(self.listjihuo,v)
        else
            _compent1:GetChild("n7").text =  language.gonggong10
        end
        --属性
        local t = conf.ForgingConf:getSuitEffect(self.condata.id,v.equip_num,true) --GConfDataSort(v)
        t = GConfDataSort(t)
        for i , j in pairs(t) do

            if j[1] ~= 329 and j[1]~=315 then
                local str =conf.RedPointConf:getProName(j[1]).." "..GProPrecnt(j[1],j[2])
                local _var = UIPackage.GetItemURL("awaken" , "AttiItem")
                local _compent2 = self.list1:AddItemFromPool(_var)
                _compent2:GetChild("n1").text = str
            end
        end

        if v.att_329 then --
            --剑神之力
            local _var = UIPackage.GetItemURL("awaken" , "AttiItem")
            local _compent2 = self.list1:AddItemFromPool(_var)
            _compent2:GetChild("n1").text = language.awaken41..string.format(language.awaken37[1],index)
        elseif v.att_315 then
            --剑神之伤
            local _var = UIPackage.GetItemURL("awaken" , "AttiItem")
            local _compent2 = self.list1:AddItemFromPool(_var)
            _compent2:GetChild("n1").text = language.awaken41..string.format(language.awaken37[2],index)
        end
    end
    --单件总属性
    local _protable = {}
    local power = 0
    for key,value in pairs(_allequip) do
        for k ,v in pairs(value) do
            if string.find(k,"att_") then --这个是属性
                local pro = string.split(k, "_")
                if tonumber(pro[2]) ~= 512 then
                    if not _protable[pro[2]] then
                        _protable[pro[2]] = tonumber(v or 0)
                    else
                        _protable[pro[2]] = tonumber(v or 0) + _protable[pro[2]]
                    end
                else
                    power = power + v
                end 
            end
        end
    end

    self.list2.numItems = 0
    local var = UIPackage.GetItemURL("awaken" , "SuitAttPanel2")
    local _compent1 = self.list2:AddItemFromPool(var)
    _compent1:GetChild("n2").text = power

    local var = UIPackage.GetItemURL("awaken" , "Component2")
    local _compent1 = self.list2:AddItemFromPool(var)
    _compent1:GetChild("n6").text = language.fashionTips01
    _compent1:GetChild("n7").text = ""

    local t = GConfDataSort(_protable)
    for i , j in pairs(t) do
        local str =conf.RedPointConf:getProName(j[1]).." "..GProPrecnt(j[1],j[2])
        local _var = UIPackage.GetItemURL("awaken" , "AttiItem")
        local _compent2 = self.list2:AddItemFromPool(_var)
        _compent2:GetChild("n1").text = str
    end
end

function SuitPanel:onJihuo()
    -- body
    if not self.listjihuo then
        return
    end
    if not self.msgData then
        return
    end
    local _t = nil
    for k ,v in pairs(self.listjihuo) do
        if not _t then
            _t = v 
        else
            if _t.equip_num > v.equip_num then
                _t = v 
            end
        end
    end
    if _t then
        proxy.ForgingProxy:send(1100107,{suiltEffectId = _t.id})
    end
    --proxy. 1100107
end

function SuitPanel:onSkillCall(context)
    -- body
    if not self.msgData then
        return
    end
    local cell = context.sender
    local data = cell.data
    local param = {
    data = self.msgData,
    index = self.index ,
    skill = data,
    icon = cell.icon,
    num = self.jienum}
    mgr.ViewMgr:openView2(ViewName.AwakenSkill, param)
end

function SuitPanel:addMsgCallBack(data)
    -- body
    if data.msgId == 5100108 then
        self.msgData = data
        self:selectIndex(1)
    elseif data.msgId == 5100107 then
        if not self.msgData then
            return
        elseif not self.index then
            return
        end

        table.insert(self.msgData.activedEffects,data.suiltEffectId)
        self:selectIndex(self.index)
    end
    --红点计算
    self:setRedPoint()
end

function SuitPanel:setRedPoint()
    -- body
    if not self.msgData then
        return
    end
    self._tao = {}--套装件数
    for k ,v in pairs(self.msgData.dressEquips) do
        local confdata = conf.ItemConf:getItem(v)
        if confdata.issuit then
            if not self._tao[confdata.issuit] then
                self._tao[confdata.issuit] = {}
            end
            table.insert(self._tao[confdata.issuit],v)
        end
    end
    --依次检测套装
    local num = 0
    for k , v in pairs(self.cellred) do
        local data = self.data[k]
        v.visible = false
        if self._tao[data.id] then --有这个套装
            local _confdata = conf.ForgingConf:getSuitEffect(data.id)
            for i , j in pairs(_confdata) do
                if not self:isJihuo(j.id) then
                    if #self._tao[data.id] >= j.equip_num then --可激活
                        v.visible = true
                        num = 1
                        break
                    end
                end
            end
        end
    end

    if num == 0 then
        --红点清理
        local var = cache.PlayerCache:getRedPointById(attConst.A10248)
        mgr.GuiMgr:redpointByID(attConst.A10248,var)
    end
end

return SuitPanel