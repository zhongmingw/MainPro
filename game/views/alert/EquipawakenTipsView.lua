--
-- Author: wx
-- Date: 2017-09-20 15:48:44
-- 

local EquipawakenTipsView = class("EquipTipsView", base.BaseView)

function EquipawakenTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function EquipawakenTipsView:initView()
    self.leftpanel = self.view:GetChild("n0")
    self.rightpanel = self.view:GetChild("n1")

    self.leftpanel.visible = false
    self.rightpanel.visible = false

    self.blackView.onClick:Add(self.onClickClose,self)
end

function EquipawakenTipsView:setlistMsg(listView,data)
    -- body
    listView.numItems = 0
    --基础描述
    local var = UIPackage.GetItemURL("alert" , "Component1")
    local _compent1 = listView:AddItemFromPool(var)
    _compent1:GetChild("n0").text = conf.ItemConf:getDescribe(data.mid)
    --基础属性
    local var = UIPackage.GetItemURL("alert" , "Component2")
    local _compent2 = listView:AddItemFromPool(var)
    _compent2:GetChild("n0").text = language.fashionTips01

    local _t = GConfDataSort(conf.ItemArriConf:getItemAtt(data.mid))
    local str = ""
    for k ,v in pairs(_t) do
        str = str ..  conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],v[2])
        if k ~= #_t then
            str = str .. "\n"
        end
    end
    local var = UIPackage.GetItemURL("alert" , "Component3")
    local _compent3 = listView:AddItemFromPool(var)
    _compent3:GetChild("n0").text = str
    _compent3:GetChild("n1").text = ""
    _compent3.height = _compent3:GetChild("n0").height + 5
    --套装属性
    local index = conf.ItemConf:getFashionsSuitId(data.mid)
    if index then --套装属性不存在则不显示套装 
        local confdata2 = conf.ForgingConf:getSuitEffect(index)
        -- plog("套装属性异常说明：", data.mid, index)
        local var = UIPackage.GetItemURL("alert" , "Component2")
        local _compent2 = listView:AddItemFromPool(var)
        _compent2:GetChild("n0").text = language.fashionTips02
        table.sort(confdata2,function(a,b)
            -- body
            return a.id < b.id
        end)

        for k ,v in pairs(confdata2) do  
            local data = conf.ForgingConf:getSuitEffect(index,v.equip_num,true)
            for k,v in pairs(data) do
                if v == 0 then 
                    data[k] = nil         
                end 
            end

            local str = ""
            local _t = GConfDataSort(data) 
            for i ,j in pairs(_t) do
                str = str ..  conf.RedPointConf:getProName(j[1]).." ".. GProPrecnt(j[1],j[2])
                str = str .. "\n"
            end

            if data.att_329 then
                str = str..language.awaken41..string.format(language.awaken37[1],data.level)
            elseif data.att_315 then
                str = str..language.awaken41..string.format(language.awaken37[2],data.level)
            end

            local var = UIPackage.GetItemURL("alert" , "Component3")
            local _compent3 = listView:AddItemFromPool(var)
            _compent3:GetChild("n0").text = string.format(language.fashionTips03,v.equip_num)
            _compent3:GetChild("n1").text = str
            _compent3.height = _compent3:GetChild("n1").height + 5
        end
    end
end

--设置左边信息
function EquipawakenTipsView:initLeft(data)
    -- body
    self.leftpanel.visible = true

    local condata = conf.ItemConf:getItem(data.mid)

    local itemObj = self.leftpanel:GetChild("n19")
    GSetItemData(itemObj,data)

    local name = self.leftpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)

    local partName = self.leftpanel:GetChild("n25") 
    partName.text = language.equip06[condata.part]

    local isbind = self.leftpanel:GetChild("n26") 
    local bind = data and data.bind or 0
    if bind > 0 then
        isbind.visible = true
    else
        isbind.visible = false
    end

    local equipDesc1 = self.leftpanel:GetChild("n27")--几阶装备
    equipDesc1.text = string.format(language.awaken31,condata.stage_lvl or 0)

    local colorText1 = self.leftpanel:GetChild("n49")
    colorText1.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[condata.color],condata.color)

    local level = self.leftpanel:GetChild("n50")
    level.text = string.format(language.pack34,condata.lvl or 0) 

    local need = self.leftpanel:GetChild("n28")
    need.text =  ""

    local power = self.leftpanel:GetChild("n18")
    power.text = condata.power

    local isWear = self.leftpanel:GetChild("n4")
    if data.index and data.index ~=0 then
        isWear.visible = true
    else
        isWear.visible = false
    end
    --属性
    local listView = self.leftpanel:GetChild("n41")
    self:setlistMsg(listView,data)

    local c1 = self.leftpanel:GetController("c1")
    --printt(data)
    if data.index and data.index ~=0 then
        c1.selectedIndex = 1
        local btn = self.leftpanel:GetChild("n44")
        local btn1 = self.leftpanel:GetChild("n48")
        local btn2 = self.leftpanel:GetChild("n45")
        if self.isself then
            btn.title = language.pack02
            btn1.visible = false
            btn2.visible = false
        else
            btn.title = language.pack01
            btn1.visible = true
            btn2.visible = true
        end
        btn.data = data
        btn.onClick:Add(self.onBtnWear,self)
        
        btn1.title = language.awaken33
        btn1.data = data
        btn1.onClick:Add(self.onFenJie,self)

        btn2.title = language.awaken34
        btn2.data = data
        btn2.onClick:Add(self.onDiuqi,self)
    else
        c1.selectedIndex = 0
    end
    local listView1 = self.leftpanel:GetChild("n47")

    self:setgetwayList(listView1,condata)
end

function EquipawakenTipsView:setgetwayList(listView1,condata)
    -- body
    --获取路径
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

function EquipawakenTipsView:initRight( data )
    -- body
    self.rightpanel.visible = true

    local condata = conf.ItemConf:getItem(data.mid)

    local itemObj = self.rightpanel:GetChild("n19")
    GSetItemData(itemObj,data)

    local name = self.rightpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)

    local partName = self.rightpanel:GetChild("n25") 
    partName.text = language.equip06[condata.part]

    local isbind = self.rightpanel:GetChild("n26") 
    local bind = data and data.bind or 0
    if bind > 0 then
        isbind.visible = true
    else
        isbind.visible = false
    end

    local equipDesc1 = self.rightpanel:GetChild("n27")--几阶装备
    equipDesc1.text = string.format(language.awaken31,condata.stage_lvl or 0)

    local colorText1 = self.rightpanel:GetChild("n49")
    colorText1.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[condata.color],condata.color)

    local level = self.rightpanel:GetChild("n57")
    level.text = string.format(language.pack34,condata.lvl or 0) 

    local need = self.rightpanel:GetChild("n28")
    need.text =  ""

    local power = self.rightpanel:GetChild("n18")
    power.text = condata.power

    local isWear = self.rightpanel:GetChild("n4")
    if data.index and data.index ~=0 then
        isWear.visible = true
    else
        isWear.visible = false
    end
    --属性
    local listView = self.rightpanel:GetChild("n47")
    self:setlistMsg(listView,data)

    local c1 = self.rightpanel:GetController("c1")
    --printt(data)
    if data.index and data.index ~=0 then
        c1.selectedIndex = 1
        local btn = self.rightpanel:GetChild("n50")
        local btn1 = self.rightpanel:GetChild("n56")
        local btn2 = self.rightpanel:GetChild("n51")
        btn.title = language.pack05
        btn.data = data
        btn.onClick:Add(self.onBtnWear,self)
        
        btn1.title = language.awaken33
        btn1.data = data
        btn1.onClick:Add(self.onFenJie,self)

        btn2.title = language.awaken34
        btn2.data = data
        btn2.onClick:Add(self.onDiuqi,self)
    else
        c1.selectedIndex = 0
    end

    local listView1 = self.rightpanel:GetChild("n55")
    self:setgetwayList(listView1,condata)
    
    local list = { {},{},{}}
    list[1].key = self.rightpanel:GetChild("n41")
    list[1].value = self.rightpanel:GetChild("n43")

    list[2].key = self.rightpanel:GetChild("n42")
    list[2].value = self.rightpanel:GetChild("n44")

    list[3].key = self.rightpanel:GetChild("n53")
    list[3].value = self.rightpanel:GetChild("n54")

    for k ,v in pairs(list) do
        v.key.text = ""
        v.value.text = ""
    end

    --属性对比
    if self.equipdata and self.data then
        local _leftconf = GConfDataSort(conf.ItemArriConf:getItemAtt(self.equipdata.mid))
        local _rightconf = GConfDataSort(conf.ItemArriConf:getItemAtt(self.data.mid))

        local pairs = pairs
        for k , v in pairs(_rightconf) do
            for i , j in pairs(_leftconf) do
                if v[1] == j[1] then
                    _rightconf[k][2] = v[2] - j[2]
                    break
                end
            end
        end

        for k ,v in pairs(_rightconf) do
            local var = list[k]
            if var then
                var.key.text = conf.RedPointConf:getProName(v[1])
                if v[2] > 0 then
                    var.value.text ="+"..GProPrecnt(v[1],v[2])
                else
                    var.value.text = mgr.TextMgr:getTextColorStr(GProPrecnt(v[1],v[2]),14) 
                end
                
            else
                break
            end
        end
    end

end

function EquipawakenTipsView:setData(data_)
    
    self.data = clone(data_)
    local part = conf.ItemConf:getPart(data_.mid)
    self.isself = false
    local _view  = mgr.ViewMgr:get(ViewName.AwakenView)
    if not _view then
        self.data.index = nil 
        self.equipdata = nil 
    else
        self.equipdata = cache.PackCache:getAwakenEquipDataByPart(part)
        if data_.index and self.equipdata and self.equipdata.index == data_.index then
            self.isself = true
        end
    end
    
    self.leftpanel.visible = false
    self.rightpanel.visible = false
    if self.equipdata and not self.isself then
        self:initLeft(self.equipdata)
        self:initRight(self.data)
    else
        self:initLeft(self.data)
    end
end

function EquipawakenTipsView:onBtnWear(context)
    -- body
    local btn = context.sender
    local data = btn.data
    if data then
        local index = data.index
        local toIndex = Pack.equipawaken + conf.ItemConf:getPart(data.mid)
        local toIndexs = {}
        local opType = 0
        if btn.title == language.pack02 then
            --脱
            opType = 1
            toIndexs = {}
        else
            --穿
            opType = 0
            toIndexs = {toIndex}
        end

        local params = {
            opType = opType,--脱
            indexs = {index},--装备的位置
            toIndexs = toIndexs,--目标位置
        }
        --printt("params",params)
        proxy.PackProxy:send(1190201,params)
    end
    self:onClickClose()
end

function EquipawakenTipsView:onFenJie(context)
    -- body 分解
    local btn = context.sender
    local data = btn.data
    if data then

    end
    self:onClickClose()
end

function EquipawakenTipsView:onDiuqi(context)
    -- body 丢弃
    local btn = context.sender
    local data = btn.data
    if data then
        mgr.ItemMgr:delete(data.index)
    end
    self:onClickClose()
end

function EquipawakenTipsView:onBtnGo(context)
    -- body
    local data = context.sender.data
    local param = {id = data.id,childIndex = data.childIndex}
    GOpenView(param)
end

function EquipawakenTipsView:onClickClose()
    -- body
    self:closeView()
end


return EquipawakenTipsView