--
-- Author: wx
-- Date: 2018-01-15 20:28:58
-- 宠物装备
local dian = mgr.TextMgr:getImg(UIItemRes.dian01)
local _height = {91,113}
local EquipPetTipsView = class("EquipTipsView", base.BaseView)

function EquipPetTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function EquipPetTipsView:initView()
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
    --self.blackView.onClick:Add(self.onClickClose,self)
end

function EquipPetTipsView:initData()
    -- body
    self.leftpanel:GetChild("n44").xy = self.leftxy[1]
    self.leftpanel:GetChild("n48").xy = self.leftxy[2]
    self.leftpanel:GetChild("n45").xy = self.leftxy[3]

    self.rightpanel:GetChild("n50").xy = self.rightxy[1]
    self.rightpanel:GetChild("n56").xy = self.rightxy[2]
    self.rightpanel:GetChild("n51").xy = self.rightxy[3]
end

function EquipPetTipsView:setData(data_,info)
    if not data_  and not info then
        return self:closeView()
    end
    self.base1 = 0

    self.packdata = data_ --背包装备
    self.info = info --宠物信息 --[1] = 宠物信息 [2] = 部位

    self.petPartEquip = nil 
    if info then
        if self.packdata then
            local confdata = conf.ItemConf:getItem(self.packdata.mid)
            self.petPartEquip = mgr.PetMgr:getEquipDataByPart(self.info[1],confdata.part)
        else
            -- printt("self.info>>>>>>>>>>>>",self.info)
            self.petPartEquip = mgr.PetMgr:getEquipDataByPart(self.info[1],self.info[2])
        end
    end

    local view = mgr.ViewMgr:get(ViewName.PackView)
    if not self.info then
        --背包信息
        self.index = 1 --纯看
        -- print("data_.index",data_.index,view.mainController.selectedIndex)
        if data_.index and mgr.ItemMgr:isPackItem(data_.index) then
           if view and view.mainController.selectedIndex~=2  then
                self.index = 5 --只有丢弃
           end
        end
    else
        if self.petPartEquip then
            --对应部位有装备
            if not self.packdata then
                --点击的宠物身上的装备
                self.index = 3 
            else
                --点击的是背包装备
                self.index = 4 
            end
        else
            --点击的是背包装备
            self.index = 2 --只有左边 可穿戴
        end
    end

    self.leftpanel.visible = false
    self.rightpanel.visible = false


    if self.index == 1 or self.index == 2 or self.index == 5 then
        self.leftpanel:Center()
        self:initLeft(self.packdata)
    elseif self.index == 3 then
        self.leftpanel:Center()
        self:initLeft(self.petPartEquip)
    elseif self.index == 4 then
        self.leftpanel.xy = self.oldxy
        self:initLeft(self.petPartEquip )
        self:initRight(self.packdata)
    end

end
--按钮状态
function EquipPetTipsView:setBtnSeeinfo(way)
    -- body
     --3个按钮
    --3.点击身上装备时，操作指令为：“脱下”和“吞噬”
    --点击背包中装备时，操作指令为“更换”和“吞噬”
    --//同部位无装备时，显示为“穿戴”和“吞噬”
    local btn1 
    local btn2 
    local btn3 = self.leftpanel:GetChild("n45")
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
        p2 = self.leftpanel:GetChild("n43")

        xylist=  self.leftxy
        
    else
        btn1 = self.rightpanel:GetChild("n50")
        btn2 = self.rightpanel:GetChild("n56")
        btn3 = self.rightpanel:GetChild("n51")
        c1 = self.rightpanel:GetController("c1")

        p1 = self.rightpanel:GetChild("n48")
        p2 = self.rightpanel:GetChild("n49")
        xylist=  self.rightxy
        --self.rightpanel:GetChild("n48").height = _height[2]
        --self.rightpanel:GetChild("n49").height = _height[1]
    end
    btn1.onClick:Clear()
    btn2.onClick:Clear()
    btn3.onClick:Clear()
    if self.index == 1 then --查看 
        local index = self.packdata.index
        --print("index",index)
        if index ~=0 and mgr.ItemMgr:getPackIndex() == Pack.wareIndex then --仓库
            c1.selectedIndex = 1
            
            if mgr.ItemMgr:isPackItem(index) then
                --存入
                btn1.title = language.pack06
            else
                --取出
                btn1.title = language.pack07
            end
            btn1.visible = true
            btn1.onClick:Add(self.onPack,self)

            btn2.visible = false
            btn3.visible = true
        else
            c1.selectedIndex = 0
            btn1.visible = false
            btn2.visible = false
            btn3.visible = false
            p1.visible = false
            p2.visible = false
            if self.packdata.index == 0 then
                btn3.visible = false
            else
                p1.visible = true
                p2.visible = true
                btn3.visible = true
            end
        end
       
        
    elseif self.index == 2 then --传
        c1.selectedIndex = 1
        btn1.visible = true
        btn1.title = language.pack01
        btn1.onClick:Add(self.onWearEquip,self)
        
        btn2.visible = true
        btn2.title = language.pack30
        btn2.onClick:Add(self.onTunshi,self)
        if not self.packdata or self.packdata.index == 0 then
            btn3.visible = false
        else
            btn3.visible = true
        end

    elseif self.index == 3 then --脱
        c1.selectedIndex = 1
        btn1.visible = true
        btn1.title = language.pack02
        btn1.onClick:Add(self.onWearEquip,self)

        btn2.visible = false
        btn3.visible = false
    elseif self.index == 4 then --换
        if way == 1 then
            c1.selectedIndex = 0
        else
            c1.selectedIndex = 1
        end
        btn1.visible = true
        btn1.title = language.pack05
        btn1.onClick:Add(self.onWearEquip,self)

        btn2.visible = true
        btn2.title = language.pack30
        btn2.onClick:Add(self.onTunshi,self)

        if not self.packdata or self.packdata.index == 0 then
            btn3.visible = false
        else
            btn3.visible = true
        end
    elseif self.index == 5 then --只有丢弃
        --在背包的时候
        c1.selectedIndex = 1
        btn1.visible = false
        btn2.visible = false
        btn3.visible = true
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

--极品属性
function EquipPetTipsView:attiCallback(id,value,isTuijian,equipType)
    -- body
    local attiData = conf.ItemConf:getEquipColorAttri(id)
    local color = attiData and attiData.color or 1
    local attType = attiData and attiData.att_type or 0
    local name = mgr.PetMgr:getProName({attType}) --conf.RedPointConf:getProName(attType)
    if equipType == Pack.shenshouEquipType then
        name = conf.RedPointConf:getProName(attType)
    end
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

function EquipPetTipsView:setlistMsg(listView,data)
    -- body
    listView.numItems = 0
    --基础属性
    local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
    local baseitem = listView:AddItemFromPool(url)
    --local attiData = conf.ItemArriConf:getItemAtt(data.mid)

    local info = {}
    info.mid = data.mid
    info.level = data.level or 0
    --local attiData = conf.PetConf:getEquipLevelUp(info)


    local score = 0--基础评分
    local t = mgr.PetMgr:getEquipPro(info)
    local confData = conf.ItemConf:getItem(info.mid)
    if confData.type == Pack.shenshouEquipType then--神兽装备
        t = conf.ShenShouConf:getEquipPro(info)
    end
    local str = ""
    local text = ""
    for k,v in pairs(t) do --conf.RedPointConf:getProName(v[1])
        local name = mgr.PetMgr:getProName(v)
        if confData.type == Pack.shenshouEquipType then--神兽装备
            name = conf.RedPointConf:getProName(v[1])
        end
        local str1 = dian.." ".. name .." "..v[2]
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
            local str1 = self:attiCallback(v.type,v.value,nil,confData.type)
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
                local str1 = self:attiCallback(type,value,isTuijian,confData.type)
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
    return checkint(score),checkint(synScore)
end

function EquipPetTipsView:setgetwayList(listView1,condata)
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

function EquipPetTipsView:onBtnGo(context)
    -- body
    local data = context.sender.data
    local param = {id = data.id,childIndex = data.childIndex}
    GOpenView(param)
end

function EquipPetTipsView:initLeft(data)
    -- body
    self.leftmid = data.mid
    self.leftpanel.visible = true
    local condata = conf.ItemConf:getItem(data.mid)
    --道具icon
    local itemObj = self.leftpanel:GetChild("n19")
    GSetItemData(itemObj,data)

    local name = self.leftpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)
    --部位
    local partName = self.leftpanel:GetChild("n25") 

    local isbind = self.leftpanel:GetChild("n26") 
    isbind.text = ""

    local equipDesc1 = self.leftpanel:GetChild("n27")--
    if condata.type == Pack.equippetType then
        partName.text = language.pet26[condata.part]
        equipDesc1.text = mgr.TextMgr:getTextColorStr(language.pet27, 13) 
    elseif condata.type == Pack.shenshouEquipType then
        partName.text = language.shenshou01[condata.part]
        equipDesc1.text = mgr.TextMgr:getTextColorStr(language.shenshou02, 13) 
    end

    local colorText1 = self.leftpanel:GetChild("n49")
    colorText1.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[condata.color],condata.color)

    local level = self.leftpanel:GetChild("n50")
    level.text = language.gonggong83..(data.level or 0)

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
    power.text = score
    power1.text = score + score1

    self.base1 = power1.text
    --获取途径
    local listView1 = self.leftpanel:GetChild("n47")
    self:setgetwayList(listView1,condata)

   
    self.leftpanel:GetChild("n56").visible = false
    self.leftpanel:GetChild("n55").text = ""
    
    self:setBtnSeeinfo(1)
end

function EquipPetTipsView:initRight(data)
    -- body
    self.rightmid = data.mid
    self.rightpanel.visible = true
    local condata = conf.ItemConf:getItem(data.mid)
    local itemObj = self.rightpanel:GetChild("n19")
    GSetItemData(itemObj,data)

    local name = self.rightpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)

    local partName = self.rightpanel:GetChild("n25") 

    local isbind = self.rightpanel:GetChild("n26") 
    isbind.text = ""

    local equipDesc1 = self.rightpanel:GetChild("n27")--几阶装备
    if condata.type == Pack.equippetType then
        partName.text = language.pet26[condata.part]
        equipDesc1.text = mgr.TextMgr:getTextColorStr(language.pet27, 13) 
        mgr.PetMgr:conTrastScore(itemObj,self.petPartEquip,self.packdata)
    elseif condata.type == Pack.shenshouEquipType then
        partName.text = language.shenshou01[condata.part]
        equipDesc1.text = mgr.TextMgr:getTextColorStr(language.shenshou02, 13) 
        cache.ShenShouCache:conTrastScore(itemObj,self.petPartEquip,self.packdata)
    end

    local colorText1 = self.rightpanel:GetChild("n58")
    colorText1.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[condata.color],condata.color)

    local level = self.rightpanel:GetChild("n57")
    level.text = language.gonggong83..(data.level or 0)

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

    power.text = score
    power1.text = score + score1

    local listView1 = self.rightpanel:GetChild("n55")
    self:setgetwayList(listView1,condata)

    self.rightpanel:GetChild("n64").visible = false
    self.rightpanel:GetChild("n63").text = ""
    

    --装备对比
    self:setEquipContrast()


    -- local arrow = itemObj:GetChild("n19")
    -- if tonumber(power1.text) > tonumber(self.base1) then
    --     arrow.visible = true
    --     arrow.url = ResPath.iconRes("baoshi_018")
    -- elseif tonumber(power1.text) < tonumber(self.base1) then
    --     arrow.visible = true
    --     arrow.url = ResPath.iconRes("gonggongsucai_137")
    -- else
    --     arrow.visible = false
    -- end
    
    self:setBtnSeeinfo(2)
end

function EquipPetTipsView:setEquipContrast()
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

    local attiData1 = conf.ItemArriConf:getItemAtt(self.rightmid)
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

function EquipPetTipsView:onWearEquip(context)
    -- body
    if not self.info then
        return
    end
     
    local param = {}
    param.petRoleId = self.info[1].petRoleId
    local mid 
    if self.index == 1 then
        return --看
    elseif self.index == 2 then
        param.reqType = 1 --宠物穿
        param.opType = 0--神兽穿
        local condata = conf.ItemConf:getItem(self.packdata.mid)
        mid = self.packdata.mid
        param.parts = {condata.part}
        param.indexs = {self.packdata.index}
    elseif self.index == 3 then
        param.reqType = 2 --宠物脱
        param.opType = 1--神兽脱
        local condata = conf.ItemConf:getItem(self.petPartEquip.mid)
        mid = self.petPartEquip.mid
        param.parts = {condata.part}
        param.indexs = {0}
    elseif self.index == 4 then
        param.reqType = 1 --宠物换
        param.opType = 0 --神兽换
        local condata = conf.ItemConf:getItem(self.packdata.mid)
        param.parts = {condata.part}
        param.indexs = {self.packdata.index}
        mid = self.packdata.mid
    else
        return
    end  
    if not mid then
        return
    end
    local condata = conf.ItemConf:getItem(mid)
    if condata.type == Pack.equippetType then--宠物装备
        local pet = conf.PetConf:getPetItem(self.info[1].petId)
        local equip = conf.ItemConf:getItem(mid)
        if equip.color >  pet.color  then
            GComAlter(language.pet36)
            return
        end

        proxy.PetProxy:sendMsg(1490104,param)
    elseif condata.type == Pack.shenshouEquipType then--神兽装备
        -- print("self.info[1].ssId",self.info[1].ssId)
        local shenshou = conf.ShenShouConf:getShenShouDataById(self.info[1].ssId)
        local equip = conf.ItemConf:getItem(mid)
        if equip.color < shenshou.active_conf[equip.part][2] then
            GComAlter(language.shenshou03)
            return
        end
        param.ssId = self.info[1].ssId
        -- printt("param>>>>>>>>>>>>>",param)
        proxy.ShenShouProxy:sendMsg(1590102,param)
    end
    self:closeView()
end

function EquipPetTipsView:onTunshi()
    -- body
    --吞噬跳转
    local view = mgr.ViewMgr:get(ViewName.PetEquipView)
    if view then
        view.c1.selectedIndex = 1
    end
    --神兽装备吞噬处理
    local view2 = mgr.ViewMgr:get(ViewName.ShenQiView)
    if view2 then
        view2:openShenShouQhView()--打开强化界面
    end
    local view3 = mgr.ViewMgr:get(ViewName.ShenShouEquip)
    if view3 then
        view3:closeView()--关闭神兽装备界面
    end
    self:closeView()
end
--丢弃
function EquipPetTipsView:onDiuqi()
    -- body
    if not self.packdata then
        return
    end
    mgr.ItemMgr:delete(self.packdata.index)
    self:closeView()
end
--仓库存入取出
function EquipPetTipsView:onPack()
    -- body
    if not self.packdata then
        return 
    end
    proxy.PackProxy:sendWareTake(self.packdata)
    self:closeView()
end

return EquipPetTipsView