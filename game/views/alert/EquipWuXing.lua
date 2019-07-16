--
-- Author: 
-- Date: 2018-07-16 17:29:45
--
local _height = {91,113}
local EquipWuXing = class("EquipTipsView", base.BaseView)
local dian = mgr.TextMgr:getImg(UIItemRes.dian01)
function EquipWuXing:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function EquipWuXing:initView()
    self.leftpanel = self.view:GetChild("n0")
    self.oldxy = self.leftpanel.xy
    self.rightpanel = self.view:GetChild("n1")

    self.leftpanel.visible = false
    self.rightpanel.visible = false
    self.leftxy = {
        self.leftpanel:GetChild("n44").xy,
        self.leftpanel:GetChild("n48").xy,
        self.leftpanel:GetChild("n45").xy,
    }
    self.rightxy = {
        self.rightpanel:GetChild("n50").xy,
        self.rightpanel:GetChild("n56").xy,
        self.rightpanel:GetChild("n51").xy,
    }
    self:setCloseBtn(self.blackView)
end

function EquipWuXing:initData()
    -- body
    self.leftpanel:GetChild("n44").xy = self.leftxy[1]
    self.leftpanel:GetChild("n48").xy = self.leftxy[2]
    self.leftpanel:GetChild("n45").xy = self.leftxy[3]

    self.rightpanel:GetChild("n50").xy = self.rightxy[1]
    self.rightpanel:GetChild("n56").xy = self.rightxy[2]
    self.rightpanel:GetChild("n51").xy = self.rightxy[3]
end

function EquipWuXing:setData(data_)
    if not data_  then
        return self:closeView()
    end
    self.base1 = 0

    self.leftpanel.visible = false
    self.rightpanel.visible = false

    self.level = data_.level or 0

    local view = mgr.ViewMgr:get(ViewName.PackView)

    self.data = data_
    if not data_.index then
        data_.index = 0
    end
    local confdata = conf.ItemConf:getItem(data_.mid)
    self.part = confdata.part
    self.info = cache.PackCache:getPackDataByIndex(data_.index)
    self.leftinfo = cache.AwakenCache:getEquipByPart(self.part)
    if data_.index == 0 then
        self.index = 1 --只是看
    elseif mgr.ItemMgr:isWareItem(data_.index) then
        self.index = 5 --仓库界面
    else
        if self.info then
            self.index = 2 --穿戴
            --对比相同部位是否穿戴
            if self.leftinfo then
                self.index = 3 --更换
            end

            if view then
                --print("view.mainController.selectedIndex",view.mainController.selectedIndex)
                if view.mainController.selectedIndex == 2 then
                    self.index = 5 --仓库界面
                    --仓库
                else 
                    self.index = 6 --背包分解使用
                end
            end
        else
            self.leftinfo = data_
            self.index = 4 --脱
        end
    end

    if self.index == 1 or self.index == 5 or self.index == 6 then
        if self.leftinfo then
            self:initLeft(self.leftinfo)
            self:initRight(self.data)
            self.leftpanel.xy = self.oldxy
        else
            self:initLeft(self.data)
            self.leftpanel:Center()
        end
    elseif self.index == 2 then 
        self:initLeft(self.data)
        self.leftpanel:Center()
    elseif self.index == 3 then
        self.leftpanel.xy = self.oldxy
        self:initLeft(self.leftinfo)
        self:initRight(self.data)
    elseif self.index == 4 then
        self:initLeft(self.leftinfo)
        self.leftpanel:Center()
    end
end

--极品属性
function EquipWuXing:attiCallback(id,value,isTuijian)
    -- body
    local attiData = conf.ItemConf:getEquipColorAttri(id)
    local color = attiData and attiData.color or 1
    local attType = attiData and attiData.att_type or 0
    local name = conf.RedPointConf:getProName(attType)
    local maxColor = conf.ItemConf:getEquipColorGlobal("max_color")
    local attiValue = "+"..GProPrecnt(attType,value)
    if color >= maxColor then--是否是最高品质
        local attiRange = attiData.att_range or {}
        local maxValue = attiRange[#attiRange] and attiRange[#attiRange][2]
        if maxValue and value >= maxValue then
            attiValue = attiValue..language.pack41--获得了最佳的极品属性
        end
    end
    local str = ""
    local atti = 0
    if isTuijian then
        str = language.equip08.." "..name..attiValue
    else
        str = name..attiValue
    end
    return mgr.TextMgr:getQualityAtti(str,color)
end

function EquipWuXing:setlistMsg(listView,data)
    -- body
    listView.numItems = 0
    --基础属性
    local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
    local baseitem = listView:AddItemFromPool(url)
    local attiData = conf.ItemArriConf:getItemAtt(data.mid)

    local info = {}
    info.mid = data.mid
    info.level = self.level
    --local attiData = conf.PetConf:getEquipLevelUp(info)

    local confdata = conf.ItemConf:getItem(info.mid)
    local score = 0--基础评分
    local t = GConfDataSort(attiData) --conf.WuxingConf:getStrenInfo(self.part,confdata.color,self.level)
    local str = ""
    local text = ""
    for k,v in pairs(t) do --conf.RedPointConf:getProName(v[1])
        local str1 = dian.." "..conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],math.floor(v[2]))
        if k ~= #t then
            str1 = str1.."\n"
            text = text.." ".."\n"
        end
        str = str..str1
        score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])--计算综合战斗力
    end
    baseitem:GetChild("n0").text = language.equip02[3]
    baseitem:GetChild("n8").text = str
    baseitem:GetChild("n1").text = ""



    --极品属性
    str = ""
    text = ""
    local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
    baseitem = listView:AddItemFromPool(url)
    local synScore = 0--综合战斗力
    local colorAttris = data.colorAttris
    if colorAttris and #colorAttris > 0 then--系统生成属性
        baseitem:GetChild("n0").text = language.equip02[2]
        for k,v in pairs(colorAttris) do
            local str1 = self:attiCallback(v.type,v.value)
            local text1 = ""
            if k~= #data.colorAttris then
                str1 = str1.."\n"
            end
            str = str..str1
            synScore = synScore + mgr.ItemMgr:birthAttScore(v.type,v.value)--计算综合评分
        end
    else
        local birthAtt = conf.ItemConf:getBaseBirthAtt(data.mid)--推荐属性
        local isTuijian = true
        if not birthAtt then--固定生成的属性不走推荐
            isTuijian = false
            birthAtt = conf.ItemConf:getBirthAtt(data.mid) or {}
            baseitem:GetChild("n0").text = language.equip02[2]
        else
            baseitem:GetChild("n0").text = language.equip02[2]..string.format(language.equip07, #birthAtt / 2)
        end

        for k,v in pairs(birthAtt) do
            if k % 2 == 0 then--值
                local type,value = birthAtt[k - 1],birthAtt[k]
                local str1 = self:attiCallback(type,value,isTuijian)
                local text1 = ""
                if k ~= #birthAtt then
                    str1 = str1.."\n"
                end
                str = str..str1
                if not isTuijian then--如果是固定生成的
                    synScore = synScore + mgr.ItemMgr:birthAttScore(type,value)--计算综合评分
                end
            end
        end
    end
    baseitem:GetChild("n1").text = ""
    baseitem:GetChild("n8").text = str


      --强化属性
    local _info = cache.AwakenCache:getJianLingByPart(self.part)
    local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
    local baseitem = listView:AddItemFromPool(url)
    local t = GConfDataSort(conf.WuxingConf:getStrenInfo(self.part,confdata.color,_info.strenLev))
    local str = ""
    local text = ""
    for k,v in pairs(t) do --conf.RedPointConf:getProName(v[1])
        local str1 = dian.." "..conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],math.floor(v[2]))
        if k ~= #t then
            str1 = str1.."\n"
            --text = text.." ".."\n"
        end
        str = str..str1
    end
    baseitem:GetChild("n0").text = language.equip02[4]
    baseitem:GetChild("n8").text = str
    baseitem:GetChild("n1").text = ""
    return score,synScore
end

function EquipWuXing:setgetwayList(listView1,condata)
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

function EquipWuXing:onBtnGo(context)
    -- body
    local data = context.sender.data
    local param = {id = data.id,childIndex = data.childIndex}
    GOpenView(param)
end

function EquipWuXing:setBtnSeeinfo(way)
    -- body
     local btn1 
    local btn2 
    local btn3
    local c1  
    local p1 
    local p2 
    local xylist 
     if way == 1 then
        btn1 = self.leftpanel:GetChild("n44")
        btn2 = self.leftpanel:GetChild("n48")
        btn3 = self.leftpanel:GetChild("n45")
        c1 = self.leftpanel:GetController("c1")

        p1 = self.leftpanel:GetChild("n42")
        --p2 = self.leftpanel:GetChild("n43")
        --self.leftpanel:GetChild("n42").height = _height[2]
        --self.leftpanel:GetChild("n43").height = _height[1]
         xylist=  self.leftxy
    else
        btn1 = self.rightpanel:GetChild("n50")
        btn2 = self.rightpanel:GetChild("n56")
        btn3 = self.rightpanel:GetChild("n51")
        c1 = self.rightpanel:GetController("c1")

        p1 = self.rightpanel:GetChild("n48")
        xylist=  self.rightxy
        --p2 = self.rightpanel:GetChild("n49")
        --self.rightpanel:GetChild("n48").height = _height[2]
        --self.rightpanel:GetChild("n49").height = _height[1]
    end

    btn1.onClick:Clear()
    btn1.onClick:Add(self.onWearEquip,self)
    btn2.onClick:Clear()
    btn3.onClick:Clear()
    
    btn2.title = language.pack44
    btn2.onClick:Add(self.onTunshi,self)
    btn3.visible = false
    if self.index == 1 then 
        --查看 

        c1.selectedIndex = 0
    elseif self.index == 2 then 
        --穿戴
        c1.selectedIndex = 1
        

        btn1.title = language.pack01
        btn1.visible = true
        
        btn2.visible = true
        btn3.visible = false
    elseif self.index == 3 then
        --更换
        c1.selectedIndex = 1
        btn3.visible = false
        btn1.visible = true
        btn2.visible = true
        btn1.title = language.pack05


    elseif self.index == 4 then
        --脱
        btn1.visible = true
        c1.selectedIndex = 1
        btn1.title = language.pack02
        btn2.visible = false
        btn3.visible = false
    elseif self.index == 5 then
        --仓库
        c1.selectedIndex = 1
        btn1.visible = true
        btn2.visible = false
        btn3.visible = false
        if mgr.ItemMgr:isWareItem(self.data.index) then
            --取
            btn1.title = language.pack07
        else
            --存
            btn1.title = language.pack06
        end
    elseif self.index == 6 then
        c1.selectedIndex = 1
        btn1.visible = true
        btn2.visible = true
        btn3.visible = true

        btn1.title = language.pack03
    end

    btn3.title = language.pack04
    btn3.onClick:Add(self.onDiuqi,self)



    local count =  (btn1.visible and 1 or 0) +(btn2.visible and 1 or 0)+(btn3.visible and 1 or 0)
    --print("count",count,btn1.visible,btn2.visible,btn3.visible )
    if count == 3 then
        p1.height = 158
    elseif count == 2 then
        p1.height = 115
    else
        p1.height = 74
    end

    local t = {}
    table.insert(t,btn1)
    table.insert(t,btn2)
    table.insert(t,btn3)

    local number = 1
    for k ,v in pairs(t) do
        if v.visible then
            v.xy = xylist[number]
            number = number + 1
        end
    end
end

function EquipWuXing:initLeft(data)
    -- body
    self.leftmid = data.mid
    self.leftpanel.visible = true

    --道具icon
    local itemObj = self.leftpanel:GetChild("n19")
    GSetItemData(itemObj,data)

    local condata = conf.ItemConf:getItem(data.mid)
    local name = self.leftpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)

    --部位
    local partName = self.leftpanel:GetChild("n25") 
    partName.text = language.awaken51[condata.part]..language.awaken53

    local isbind = self.leftpanel:GetChild("n26") 
    isbind.text = ""

    local equipDesc1 = self.leftpanel:GetChild("n27")--
    equipDesc1.text = "" --mgr.TextMgr:getTextColorStr( string.format(language.equip01,condata.stage_lvl),condata.color)

    local colorText1 = self.leftpanel:GetChild("n49")
    colorText1.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[condata.color],condata.color)

    local level = self.leftpanel:GetChild("n50")
    level.text = ""

    local need = self.leftpanel:GetChild("n28")
    need.text =  ""

    local power = self.leftpanel:GetChild("n18")
    power.text = 0

    local power1 = self.leftpanel:GetChild("n54")
    power1.text = 0

    local isWear = self.leftpanel:GetChild("n4")
    if self.index == 3 or self.index == 4 then
        isWear.visible = true
    else
        isWear.visible = false
    end

     --属性
    local listView = self.leftpanel:GetChild("n41")
    local score,score1 = self:setlistMsg(listView,data)
    power.text = math.floor(score)
    power1.text = math.floor(score + score1) 

    self.base1 = power1.text

    self.leftpanel:GetChild("n56").visible = false
    self.leftpanel:GetChild("n55").text = ""

    --获取途径
    local listView1 = self.leftpanel:GetChild("n47")
    self:setgetwayList(listView1,condata)

    self:setBtnSeeinfo(1)
end

function EquipWuXing:setEquipContrast()
    -- body
    local text1 = self.rightpanel:GetChild("n41")
    local text2 = self.rightpanel:GetChild("n42")
    local text3 = self.rightpanel:GetChild("n53")

    local text4 = self.rightpanel:GetChild("n43")
    local text5 = self.rightpanel:GetChild("n44")
    local text6 = self.rightpanel:GetChild("n54")

    text1.text = ""
    text2.text = ""
    text3.text = ""
    text4.text = ""
    text5.text = ""
    text6.text = ""

    local confdataright = conf.ItemConf:getItem(self.rightmid)
    local confdataleft = conf.ItemConf:getItem(self.leftmid)

    local attiData1 = conf.ItemArriConf:getItemAtt(self.rightmid )
    local attiData2 = conf.ItemArriConf:getItemAtt(self.leftmid)
    local num = 0
    local function getText(num)
        if num < 0 then
            return mgr.TextMgr:getTextColorStr(num, 14)
        elseif num > 0 then
            return mgr.TextMgr:getTextColorStr("+"..num, 7)
        else
            return ""
        end
    end
    local t = GConfDataSort(attiData1)
    for k,v in pairs(t) do
        num = num + 1
        local att2 = attiData2 and attiData2["att_"..v[1]] or 0
        if num == 1 then
            text1.text = conf.RedPointConf:getProName(v[1])
            text4.text = getText(v[2] - att2)
        elseif num == 2 then
            text2.text = conf.RedPointConf:getProName(v[1])
            text5.text = getText(v[2] - att2)
        elseif num == 3 then
            text3.text = conf.RedPointConf:getProName(v[1])
            text6.text = getText(v[2] - att2)
        end
    end
end

function EquipWuXing:initRight(data)
    -- body
    self.rightmid = data.mid
    self.rightpanel.visible = true

    local condata = conf.ItemConf:getItem(data.mid)
    local itemObj = self.rightpanel:GetChild("n19")
    GSetItemData(itemObj,data)

    local name = self.rightpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)

    local partName = self.rightpanel:GetChild("n25") 
    partName.text = language.awaken51[condata.part]..language.awaken53

    local isbind = self.rightpanel:GetChild("n26") 
    isbind.text = ""

    local equipDesc1 = self.rightpanel:GetChild("n27")--几阶装备
    equipDesc1.text = ""--mgr.TextMgr:getTextColorStr( string.format(language.equip01,condata.stage_lvl),condata.color)

    local colorText1 = self.rightpanel:GetChild("n58")
    colorText1.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[condata.color],condata.color)

    local level = self.rightpanel:GetChild("n57")
    level.text = ""

    local need = self.rightpanel:GetChild("n28")
    need.text =  ""

    local power = self.rightpanel:GetChild("n18")
    power.text = 0

    local power1 = self.rightpanel:GetChild("n62")
    power1.text = 0

    local isWear = self.rightpanel:GetChild("n4")
    isWear.visible = false

    --属性
    local listView = self.rightpanel:GetChild("n47")
    local score,score1 = self:setlistMsg(listView,data)

    power.text = math.floor(score)
    power1.text = math.floor(score + score1)

    local listView1 = self.rightpanel:GetChild("n55")
    self:setgetwayList(listView1,condata)

    self.rightpanel:GetChild("n64").visible = false
    self.rightpanel:GetChild("n63").text = ""
    --mgr.PetMgr:conTrastScore(itemObj,self.petPartEquip,self.packdata)

    local isWear = self.leftpanel:GetChild("n4")
    isWear.visible = true
    
    --装备对比
    self:setEquipContrast()

    self:setBtnSeeinfo(2)
end

function EquipWuXing:onTunshi()
    -- body
    if self.index == 6 then
         mgr.ModuleMgr:OpenView({id = 1272})
    end
    mgr.ViewMgr:openView2(ViewName.HuobanExpPop,{way = "JianLing"})
    self:closeView()
end

function EquipWuXing:onWearEquip(context)
    -- body
    local btn = context.sender
    local param = {}
    if self.index == 5 then
        proxy.PackProxy:sendWareTake(self.data)
    elseif self.index == 6 then
        --使用
        mgr.ModuleMgr:OpenView({id = 1272})
    else
        param.indexs = {}
        param.toIndexs = {Pack.JianLing + self.part}
        if self.index == 1 then
            return --看
        elseif self.index == 2 then
            --穿
            param.opType = 0
            table.insert(param.indexs,self.data.index)
        elseif self.index == 3 then
            --换
            param.opType = 0
            table.insert(param.indexs,self.data.index)
        elseif self.index == 4 then
            --脱
            param.opType = 1
            table.insert(param.indexs,self.leftinfo.index)
        end
         proxy.AwakenProxy:sendMsg(1530102,param)
    end
    
    
   
    self:closeView()
end

--丢弃
function EquipWuXing:onDiuqi()
    -- body
    if not self.info  then
        return
    end
    mgr.ItemMgr:delete(self.info.index)
    self:closeView()
end

return EquipWuXing