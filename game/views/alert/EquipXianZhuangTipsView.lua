--
-- Author: 
-- Date: 2018-08-23 10:46:48
--
local dian = mgr.TextMgr:getImg(UIItemRes.dian01)
local dian1 = mgr.TextMgr:getImg(UIItemRes.dian02)

local _height = {91,113}
local EquipXianZhuangTipsView = class("EquipTipsView", base.BaseView)

function EquipXianZhuangTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function EquipXianZhuangTipsView:initView()
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

function EquipXianZhuangTipsView:initData()
    -- body
     self.leftpanel.visible = false
    self.rightpanel.visible = false
     self.leftpanel.xy = self.oldxy

    self.leftpanel:GetChild("n44").xy = self.leftxy[1]
    self.leftpanel:GetChild("n48").xy = self.leftxy[2]
    self.leftpanel:GetChild("n45").xy = self.leftxy[3]

    self.rightpanel:GetChild("n50").xy = self.rightxy[1]
    self.rightpanel:GetChild("n56").xy = self.rightxy[2]
    self.rightpanel:GetChild("n51").xy = self.rightxy[3]
end

function EquipXianZhuangTipsView:setData(data_)
    if not data_ then
        print("使用错误 >>>> ", debug.traceback(""))
        return self:closeView()
    end

    self.data = data_
    local part = conf.ItemConf:getPart(self.data.mid)
    --查找对应自己部位是否有装备
    self.partdata = cache.PackCache:getXianEquipDataByPart(part)

    local view = mgr.ViewMgr:get(ViewName.PackView)
    if not self.data.index or  self.data.index  == 0 then
        --只是查看
        self.index = 1
    else
        if mgr.ItemMgr:isPackItem(self.data.index) then
            --print("view.mainController.selectedIndex",view.mainController.selectedIndex)
            if view and view.mainController.selectedIndex~=2  then
                --背包
                if self.partdata then
                    if self.partdata.index == self.data.index then
                        --脱下
                        self.index = 2
                    else
                        --穿戴
                        self.index = 5--更换
                    end
                else
                    --穿戴
                    self.index = 3
                end
            elseif view and  view.mainController.selectedIndex==2 then 
                --存 丢弃
                self.index = 6
            else
                --不在背包界面认为是查看
                self.index = 1
            end
        elseif mgr.ItemMgr:getPackIndex() == Pack.wareIndex then
            if view and view.mainController.selectedIndex == 2  then
                self.index = 4 --取 丢弃
            else
                self.index = 1
            end
        else
            --意外情况
            self.index = 1
        end
    end

    --print("self.index",self.index)
    if self.index == 1 then
        if self.partdata and self.partdata.index ~= self.data.index then
            self.leftpanel.xy = self.oldxy
            self:initLeft(self.partdata)
            self:initRight(self.data)
        else
            self.leftpanel:Center()
            self:initLeft(self.data)
        end
    elseif self.index == 2 then
        self.leftpanel:Center()
        self:initLeft(self.data)
    elseif self.index == 3 then
        if self.partdata then
            self.leftpanel.xy = self.oldxy
            self:initLeft(self.partdata)
            self:initRight(self.data)
        else
            self.leftpanel:Center()
            self:initLeft(self.data)
        end
    elseif self.index == 4 then
        if self.partdata then
            self.leftpanel.xy = self.oldxy
            self:initLeft(self.partdata)
            self:initRight(self.data)
        else
            self.leftpanel:Center()
            self:initLeft(self.data)
        end
    elseif self.index == 5 then
        self.leftpanel.xy = self.oldxy
        self:initLeft(self.partdata)
        self:initRight(self.data)
    elseif self.index == 6 then
        if self.partdata then
            self.leftpanel.xy = self.oldxy
            self:initLeft(self.partdata)
            self:initRight(self.data)
        else
            self.leftpanel:Center()
            self:initLeft(self.data)
        end
    end
end

--极品属性
function EquipXianZhuangTipsView:attiCallback(id,value,isTuijian,quality)
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
            local str = quality == 7 and "" or language.pack41
            attiValue = attiValue..str--获得了最佳的极品属性
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

function EquipXianZhuangTipsView:setlistMsg(listView,data)
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
    local t =   conf.ItemArriConf:getItemAtt(data.mid) or {}
    t = GConfDataSort(t)
    local str = ""
    local text = ""
    for k,v in pairs(t) do --conf.RedPointConf:getProName(v[1])
        local str1 = dian.." "..conf.RedPointConf:getProName(v[1]).." "..v[2]
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
    local quality = conf.ItemConf:getQuality(data.mid)
    local synScore = 0--综合战斗力
    local colorAttris = data.colorAttris
    if colorAttris and #colorAttris > 0 then--系统生成属性
        baseitem:GetChild("n0").text = language.equip02[2]
         --极品属性颜色排序
        local attData = clone(colorAttris)
        for k,v in pairs(attData) do
            local attiData = conf.ItemConf:getEquipColorAttri(v.type)
            local color = attiData and attiData.color or 1
            v.color = color
        end
        table.sort( attData,function (a,b)
            if a.color ~= b.color then
                return a.color > b.color
            end
        end )
        for k,v in pairs(attData) do
            local str1 = self:attiCallback(v.type,v.value,nil,quality)
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
        local birthCloneAtt = clone(birthAtt)
        local _t = {}
        --将原来的一维数组改成{{type,value}}格式
        for i=1,#birthCloneAtt/2 do
            local tab = {}
            tab.type = birthCloneAtt[2*i-1]
            tab.value = birthCloneAtt[2*i]
            table.insert(_t, tab)
        end
        --添加颜色，并排序
        for k,v in pairs(_t) do
            local attiData = conf.ItemConf:getEquipColorAttri(v.type)
            local color = attiData and attiData.color or 1
            v.color = color
        end
        table.sort( _t,function (a,b)
            if a.color ~= b.color then
                return a.color > b.color
            end
        end )
        --排好序的极品属性 还原为一维数组
        local birtyAttSort = {}
        for k,v in pairs(_t) do
            table.insert(birtyAttSort,v.type)
            table.insert(birtyAttSort,v.value)
        end
        for k,v in pairs(birtyAttSort) do
            if k % 2 == 0 then--值
                local type,value = birtyAttSort[k - 1],birtyAttSort[k]
                local str1 = self:attiCallback(type,value,isTuijian,quality)
                local text1 = ""
                if k ~= #birtyAttSort then
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

    --附加属性
    local condata = conf.ItemArriConf:getItemAtt(data.mid)
    local scorefuji = 0
    if condata and condata.attach_att then
        --
        str = ""
        local _ss = ""
        
        local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
        local baseitem = listView:AddItemFromPool(url)
        for i , j in pairs(condata.attach_att) do
            local _c = conf.FeiShengConf:getFsAttachattr(j)
            local color = 6 
            --print(_c.module_id,cache.PlayerCache:getDataJie(_c.module_id),"cache.PlayerCache:getDataJie(_c.module_id)")
            if cache.PlayerCache:getDataJie(_c.module_id) >= _c.need_step then
                color = 7
            end 
            if i ~= 1 then
                str = str .. "\n"
                _ss = _ss .. "\n"
            end
            str = str .. dian1.." " .. mgr.TextMgr:getTextColorStr(string.format(language.fs40,language.gonggong94[_c.module_id],_c.need_step), color) 
            str = str .. "\n"

            local cc  = GConfDataSort(_c)
            for k,v in pairs(cc) do
                local str1 = " ".. dian.." "..conf.RedPointConf:getProName(v[1]).." "..v[2]
                if k ~= #t then
                    str1 = str1.."\n"
                    text = text.." ".."\n"
                    _ss = _ss .. "\n"
                end
                str = str.. mgr.TextMgr:getTextColorStr(str1, color)  
                if color == 7 then
                    scorefuji = scorefuji + mgr.ItemMgr:baseAttScore(v[1],v[2])--计算综合战斗力
                end
            end
        end
        baseitem:GetChild("n1").text = ""--_ss --mgr.TextMgr:getTextColorStr(string.format(language.fs40,language.gonggong94[_c.module_id],_c.need_step)) 
        baseitem:GetChild("n0").text = language.equip02[8]
        baseitem:GetChild("n8").text = str  
    end



    return checkint(score),checkint(synScore),checkint(scorefuji)
end

function EquipXianZhuangTipsView:setgetwayList(listView1,condata)
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

function EquipXianZhuangTipsView:onBtnGo(context)
    -- body
    local data = context.sender.data
    local param = {id = data.id,childIndex = data.childIndex}
    GOpenView(param)
end

function EquipXianZhuangTipsView:setEquipContrast()
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

function EquipXianZhuangTipsView:initLeft(data)
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
    partName.text = language.fs23[condata.part]

    local isbind = self.leftpanel:GetChild("n26") 
    isbind.text = ""

    local equipDesc1 = self.leftpanel:GetChild("n27")--
    equipDesc1.text = ""-- string.format(language.equip01,conf.ItemConf:getStagelvl(data.mid))--mgr.TextMgr:getTextColorStr(language.pet27, 13) 

    local colorText1 = self.leftpanel:GetChild("n49")
    colorText1.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[condata.color],condata.color)

    local jie = conf.ItemConf:getStagelvl(data.mid)
    local str = jie..language.fs21
    local a541 = cache.PlayerCache:getAttribute(541)
    local color 
    if tonumber(jie) > a541 then
        color = 14 
    else
        color = 7
    end
    local level = self.leftpanel:GetChild("n50")
    level.text = language.fs24 .. mgr.TextMgr:getTextColorStr(str, color)

    local need = self.leftpanel:GetChild("n28")
    need.text =  ""

    local power = self.leftpanel:GetChild("n18")
    power.text = 0

    local power1 = self.leftpanel:GetChild("n54")
    power1.text = 0

    local isWear = self.leftpanel:GetChild("n4")
    if self.partdata then
        isWear.visible = true
    else
        isWear.visible = false
    end
    --属性
    local listView = self.leftpanel:GetChild("n41")
    local score,score1,score2 = self:setlistMsg(listView,data)
    power.text = score
    power1.text = score + score1 + score2

    self.base1 = power1.text
    --获取途径
    local listView1 = self.leftpanel:GetChild("n47")
    self:setgetwayList(listView1,condata)

   
    self.leftpanel:GetChild("n56").visible = false
    self.leftpanel:GetChild("n55").text = ""
    
    self:setBtnSeeinfo(1)
end

function EquipXianZhuangTipsView:initRight(data)
    -- body
    self.rightmid = data.mid
    self.rightpanel.visible = true
    local condata = conf.ItemConf:getItem(data.mid)
    local itemObj = self.rightpanel:GetChild("n19")
    GSetItemData(itemObj,data)

    local name = self.rightpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)

    local partName = self.rightpanel:GetChild("n25") 
    partName.text = language.fs23[condata.part]

    local isbind = self.rightpanel:GetChild("n26") 
    isbind.text = ""

    local equipDesc1 = self.rightpanel:GetChild("n27")--几阶装备
    equipDesc1.text = ""--string.format(language.equip01,conf.ItemConf:getStagelvl(data.mid))

    local colorText1 = self.rightpanel:GetChild("n58")
    colorText1.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[condata.color],condata.color)

    local jie = conf.ItemConf:getStagelvl(data.mid)
    local str = jie..language.fs21
    local a541 = cache.PlayerCache:getAttribute(541)
    local color 
    if tonumber(jie) > a541 then
        color = 14 
    else
        color = 7
    end
    local level = self.rightpanel:GetChild("n57")
    level.text = language.fs24 .. mgr.TextMgr:getTextColorStr(str, color)

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
    local score,score1,score2 = self:setlistMsg(listView,data)

    power.text = score
    power1.text = score + score1 + score2

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

--按钮状态
function EquipXianZhuangTipsView:setBtnSeeinfo(way)
    local color = conf.ItemConf:getQuality(self.data.mid)
    -- print("self.index",self.index,"color",color)
    -- --只是查看
    --     self.index = 1
    -- --脱下
    --     self.index = 2
    --  --穿戴
    --     self.index = 3
    -- self.index = 4 --存取 丢弃
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
    end
    btn1.onClick:Clear()
    btn2.onClick:Clear()
    btn3.onClick:Clear()
    btn1.visible = false
    btn2.visible = false
    btn3.visible = false
    --p1.visible = false
    --p2.visible = false
    if self.index == 1 then --查看 
        c1.selectedIndex = 0
    elseif self.index == 2 then --脱下
        c1.selectedIndex = 1
        btn1.visible = true
        btn1.title = language.pack02
        btn1.onClick:Add(self.onWearEquip,self)
    elseif self.index == 3 then--穿戴
        c1.selectedIndex = 1
        btn1.visible = true
        btn1.title = language.pack01
        btn1.onClick:Add(self.onWearEquip,self)

        btn2.visible = true
        btn2.title = language.pack04
        btn2.onClick:Add(self.onDiuqi,self)
        if color == 7 then
            btn3.visible = true
            btn3.title = language.pack45
            btn3.onClick:Add(self.onChaiJie,self)
        end
    elseif self.index == 5 then--换
        c1.selectedIndex = 1
        btn1.visible = true
        btn1.title = language.pack01
        btn1.onClick:Add(self.onWearEquip,self)

        btn2.visible = true
        btn2.title = language.pack04
        btn2.onClick:Add(self.onDiuqi,self)
        if color == 7 then
            btn3.visible = true
            btn3.title = language.pack45
            btn3.onClick:Add(self.onChaiJie,self)
        end
    elseif self.index == 4 then--取
        c1.selectedIndex = 1
        btn1.visible = true
        btn1.title = language.pack07
        btn1.onClick:Add(self.onPack,self)


        -- btn2.visible = true
        -- btn2.title = language.pack04
        -- btn2.onClick:Add(self.onDiuqi,self)
    elseif self.index == 6 then
        c1.selectedIndex = 1
        btn1.visible = true
        btn1.title = language.pack06
        btn1.onClick:Add(self.onPack,self)


        btn2.visible = true
        btn2.title = language.pack04
        btn2.onClick:Add(self.onDiuqi,self)

        if color == 7 then
            btn3.visible = true
            btn3.title = language.pack45
            btn3.onClick:Add(self.onChaiJie,self)
        end
    end

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


function EquipXianZhuangTipsView:onWearEquip()
    -- body
    if self.index == 5 or self.index == 2 or self.index == 3 then
        local param = {}
        param.indexs = {self.data.index}
        param.toIndexs = {Pack.equipxian + conf.ItemConf:getPart(self.data.mid)} 
        if self.index == 2 then
            --脱
            param.opType = 1 
        else
            --穿
            param.opType = 0
        end
        --print(param,"param")

        local jie = conf.ItemConf:getStagelvl(self.data.mid)
        local a541 = cache.PlayerCache:getAttribute(541)
        if tonumber(jie) > a541 then
            GComAlter(language.fs41)
            return
        end

        proxy.FeiShengProxy:sendMsg(1580101,param)
    end
    self:closeView()
end

function EquipXianZhuangTipsView:onDiuqi()
    -- body
    if not self.data then
        return
    end
    mgr.ItemMgr:delete(self.data.index)
    self:closeView()
end

function EquipXianZhuangTipsView:onPack()
    -- body
    if not self.data then
        return 
    end
    proxy.PackProxy:sendWareTake(self.data)
    self:closeView()
end

function EquipXianZhuangTipsView:onChaiJie()
    local index = self.data.index or 0
    local param = {}
    param.index = index
    param.reqType = 1
    proxy.FeiShengProxy:send(1580104,param)
    self:closeView()
end


return EquipXianZhuangTipsView