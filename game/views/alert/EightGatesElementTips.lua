--
-- Author: bxp
-- Date: 2018-10-29 14:52:34
--八门元素tips
local table = table
local pairs = pairs
local dian = mgr.TextMgr:getImg(UIItemRes.dian01)


local EightGatesElementTips = class("EquipTipsView", base.BaseView)

function EightGatesElementTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function EightGatesElementTips:initView()
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


function EightGatesElementTips:initData()
    -- body
    self.leftpanel:GetChild("n44").xy = self.leftxy[1]
    self.leftpanel:GetChild("n48").xy = self.leftxy[2]
    self.leftpanel:GetChild("n45").xy = self.leftxy[3]

    self.rightpanel:GetChild("n50").xy = self.rightxy[1]
    self.rightpanel:GetChild("n56").xy = self.rightxy[2]
    self.rightpanel:GetChild("n51").xy = self.rightxy[3]
end

function EightGatesElementTips:setData(data)
    if not data then
        self:closeView()
        return
    end
    --八门孔位
    self.site = cache.AwakenCache:getEightSite()
    self.data = data
    self.leftpanel.visible = false
    self.rightpanel.visible = false

    if not data.index then
        data.index = 0
    end
    local confData = conf.ItemConf:getItem(data.mid)
    self.choseSubType = confData.sub_type
    local view = mgr.ViewMgr:get(ViewName.AwakenView)
    self.packInfo = cache.PackCache:getElementByIndex(data.index)
    if view and view.c1.selectedIndex == 6 then--在八门界面
        if self.packInfo then
            local gatesData = cache.AwakenCache:getEightGatesData()
            if self.site then
                --选中的孔位状态
                local state = gatesData.info[self.site].state
                if state == 0 then--未解锁
                    self.index = 2 --穿戴
                elseif state == 1 then--空
                    self.index = 2 --穿戴
                elseif state == 2 then--已镶嵌
                    self.leftInfo = gatesData.info[self.site].eleInfo
                    self.index = 3--更换
                end
            else
                self.index = 2
            end
        else
             --选择的是穿在身上的
            self.leftInfo = data
            local view = mgr.ViewMgr:get(ViewName.ElementStrengView)
            if view then
                self.index = 1
            else
                self.index = 4 --卸下
            end
            
        end
    else
        --根据index获取背包内的信息
        -- --根据元素类型获取装备的元素
        local subType = conf.ItemConf:getSubType(data.mid)
        self.leftInfo = cache.PackCache:getEleByType(subType)
        -- printt("已装备元素",self.leftInfo)

        if data.index == 0 then
            self.index = 1--只是道具显示
        else
            if self.packInfo then
                self.index = 2 --穿戴
                if self.leftInfo then
                    self.index = 3--更换
                end
            else
                --选择的是穿在身上的
                self.leftInfo = data
                local view = mgr.ViewMgr:get(ViewName.ElementStrengView)
                if view then
                    self.index = 1
                else
                    self.index = 4 --卸下
                end
            end
        end

    end
    -- print("self.index",self.index)
    if self.index == 1 then
        if self.leftInfo then--已经装备了元素(左右两个面板都打开)
            self:initLeft(self.leftInfo)
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
        self:initLeft(self.leftInfo)
        self:initRight(self.data)
    elseif self.index == 4 then
        self:initLeft(self.leftInfo)
        self.leftpanel:Center()
    end
end

function EightGatesElementTips:initLeft(data)
    self.leftmid = data.mid
    self.leftpanel.visible = true
    --强化等级
    local strenLevTxt = self.leftpanel:GetChild("n57")
    strenLevTxt.text = ""
    --道具icon
    local itemObj = self.leftpanel:GetChild("n19")
    local t = clone(data)
    t.isquan = true
    t.isArrow = false
    GSetItemData(itemObj,t)
    local confData = conf.ItemConf:getItem(data.mid)
    --名字
    local name = self.leftpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)
    --元素名字
    local partName = self.leftpanel:GetChild("n25") 
    partName.text = language.eightgates01[confData.ys_type]--暂用背包小类
    --绑定
    local isbind = self.leftpanel:GetChild("n26") 
    isbind.text = ""
    --阶数
    local equipDesc1 = self.leftpanel:GetChild("n27")
    equipDesc1.text = ""
    --品质
    local colorText1 = self.leftpanel:GetChild("n49")
    colorText1.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[confData.color],confData.color)
    --装备等级
    local level = self.leftpanel:GetChild("n50")
    level.text = string.format(language.pack34,confData.lvl)

    local need = self.leftpanel:GetChild("n28")
    need.text =  ""
    --基础评分
    local power = self.leftpanel:GetChild("n18")
    power.text = 0
    --综合评分
    local power1 = self.leftpanel:GetChild("n54")
    power1.text = 0
    --已装备icon
    local isWear = self.leftpanel:GetChild("n4")
    if self.index == 3 or self.index == 4 then
        isWear.visible = true
    else
        isWear.visible = false
    end
    --属性
    local listView = self.leftpanel:GetChild("n41")
    local score,score1 = self:setListMsg(listView,data)
    -- print("~~~~~~",score,score1)
    power.text = math.floor(score)
    power1.text = math.floor(score + score1)
    --仓库令
    self.leftpanel:GetChild("n56").visible = false
    self.leftpanel:GetChild("n55").text = ""
    --获取途径
    local listView1 = self.leftpanel:GetChild("n47")
    self:setGetWayList(listView1,confData)

    self:setBtnSeeinfo(1)

end

function EightGatesElementTips:initRight(data)
    self.rightmid = data.mid
    self.rightpanel.visible = true
    --道具icon
    local itemObj = self.rightpanel:GetChild("n19")
    local t = clone(data)
    t.isquan = true
    t.isArrow = false
    GSetItemData(itemObj,t)

    local confData = conf.ItemConf:getItem(data.mid)
    --名字
    local name = self.rightpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)
    --部位
    local partName = self.rightpanel:GetChild("n25") 
    partName.text = language.eightgates01[confData.ys_type]
    --绑定
    local isbind = self.rightpanel:GetChild("n26") 
    isbind.text = ""
    --阶数
    local equipDesc1 = self.rightpanel:GetChild("n27")
    equipDesc1.text = ""
    --品质
    local colorText1 = self.rightpanel:GetChild("n58")
    colorText1.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[confData.color],confData.color)
    --装备等级
    local level = self.rightpanel:GetChild("n57")
    level.text = string.format(language.pack34, confData.lvl)

    local need = self.rightpanel:GetChild("n28")
    need.text =  ""
    --基础评分
    local power = self.rightpanel:GetChild("n18")
    power.text = 0
    --综合评分
    local power1 = self.rightpanel:GetChild("n62")
    power1.text = 0
    local isWear = self.rightpanel:GetChild("n4")
    isWear.visible = false
    --属性
    local listView = self.rightpanel:GetChild("n47")
    local score,score1 = self:setListMsg(listView,data)
    -- print("右~~~~~~",score,score1)

    power.text = math.floor(score)
    power1.text = math.floor(score + score1)

    local listView1 = self.rightpanel:GetChild("n55")
    self:setGetWayList(listView1,confData)

    self.rightpanel:GetChild("n64").visible = false
    self.rightpanel:GetChild("n63").text = ""

    local isWear = self.leftpanel:GetChild("n4")
    isWear.visible = true
    
    --装备对比
    self:setEquipContrast()

    self:setBtnSeeinfo(2)

end

function EightGatesElementTips:setEquipContrast()
    local text1 = self.rightpanel:GetChild("n41")
    local text2 = self.rightpanel:GetChild("n42")
    local text3 = self.rightpanel:GetChild("n53")

    local text4 = self.rightpanel:GetChild("n43")
    local text5 = self.rightpanel:GetChild("n44")
    local text6 = self.rightpanel:GetChild("n54")


    local righttext1 = self.rightpanel:GetChild("n65")
    local righttext2 = self.rightpanel:GetChild("n66")
    local righttext3 = self.rightpanel:GetChild("n69")

    local righttext4 = self.rightpanel:GetChild("n67")
    local righttext5 = self.rightpanel:GetChild("n68")
    local righttext6 = self.rightpanel:GetChild("n70")

    text1.text = ""
    text2.text = ""
    text3.text = ""
    text4.text = ""
    text5.text = ""
    text6.text = ""

    righttext1.text = ""
    righttext2.text = ""
    righttext3.text = ""
    righttext4.text = ""
    righttext5.text = ""
    righttext6.text = ""

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

    local function getText2(num)
        if num < 0 then
            return mgr.TextMgr:getTextColorStr(num, 7)
        elseif num > 0 then
            return mgr.TextMgr:getTextColorStr("-"..num, 14)
        else
            return ""
        end
    end
    --掉落属性(左减右)
    local _t = GConfDataSort(attiData2)--左侧属性
    local _num = 0
    for k,v in pairs(_t) do
        _num = _num + 1
        local att2 = attiData1 and attiData1["att_"..v[1]] or 0
        -- print("左侧属性",v[1],conf.RedPointConf:getProName(v[1]),"右侧值",att2)
        if att2 == 0 then--说明左侧有右侧没有的属性
            if _num == 1 then
                righttext1.text = conf.RedPointConf:getProName(v[1])
                righttext4.text = getText2(v[2] - att2)
            elseif _num == 2 then
                righttext2.text = conf.RedPointConf:getProName(v[1])
                righttext5.text = getText2(v[2] - att2)
            elseif _num == 3 then
                righttext3.text = conf.RedPointConf:getProName(v[1])
                righttext6.text = getText2(v[2] - att2)
            end
        end
    end
end

function EightGatesElementTips:setListMsg(listView,data)
    listView.numItems = 0
    local attiData = conf.ItemArriConf:getItemAtt(data.mid)
    --基础属性
    local score = 0--基础评分
    local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
    local baseitem = listView:AddItemFromPool(url)
    local attiData = conf.ItemArriConf:getItemAtt(data.mid)
    local baseAttData = GConfDataSort(attiData)
    --强化部分
    local confData = conf.ItemConf:getItem(data.mid)
    local subType = confData and confData.sub_type or 1
    local strengLv = data.level or 0
    local strengInfo = conf.EightGatesConf:getStrengInfo(subType,strengLv)
    if not strengInfo then
        print("八门强化表没有类型",subType,"等级",strengLv)
        return
    end
    local strengAttData = GConfDataSort(strengInfo)
    local t = {}
    for k,v in pairs(strengAttData) do
        t[v[1]] = v[2]
    end
    local str = ""
    local text = ""
    for k,v in pairs(baseAttData) do
        local str1 = dian.." "..conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],math.floor(v[2]))
        if t[v[1]] and strengLv > 0 then
            str1 = str1 .. " [color=#0B8109](强化+"..t[v[1]]..")[/color]"
        end
        if k ~= #t then
            str1 = str1.."\n"
            text = text.." ".."\n"
        end
        str = str..str1
        score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])
    end
    baseitem:GetChild("n0").text = language.equip02[3]
    baseitem:GetChild("n8").text = str
    baseitem:GetChild("n1").text = ""

    --极品属性
    local str = ""
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
            -- baseitem:GetChild("n0").text = language.equip02[2]--..string.format(language.equip07, #birthAtt / 2)
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
    if str == "" then
        str = dian.." "..language.zuoqi26
    end
    baseitem:GetChild("n1").text = ""
    baseitem:GetChild("n8").text = str
    -- print("score",score,"synScore",synScore)
    return score,synScore

end
--极品属性
function EightGatesElementTips:attiCallback(id,value,isTuijian)
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
            attiValue = attiValue--..language.pack41--获得了最佳的极品属性
        end
    end
    local str = ""
    local atti = 0

    if isTuijian then
        str = language.equip08.." "..name..attiValue--name..attiValue
    else
        str = name..attiValue
    end
    -- str = name..attiValue
    return mgr.TextMgr:getQualityAtti(str,color)
end

--获取途径
function EightGatesElementTips:setGetWayList(listView1,confData)
    listView1.itemRenderer = function(index,obj)
        local info = confData.formview[index + 1]
        local id = info[1]
        local childIndex = info[2]
        local data = conf.SysConf:getModuleById(id)
        local lab = obj:GetChild("n1")
        lab.text = data.desc
        local btn = obj:GetChild("n0")
        btn.data = {id = id,childIndex = childIndex}
        btn.onClick:Add(self.onBtnGo,self)
    end
    listView1.numItems = confData.formview and #confData.formview or 0 
end

function EightGatesElementTips:onBtnGo(context)
    local data = context.sender.data
    local param = {id = data.id,childIndex = data.childIndex}
    GOpenView(param)
end

function EightGatesElementTips:setBtnSeeinfo(way)

    local btn1 
    local btn2 
    local btn3
    local c1  
    local p1 --蓝底
    if way == 1 then--左侧面板
        btn1 = self.leftpanel:GetChild("n44")--穿戴
        btn2 = self.leftpanel:GetChild("n48")--吞噬
        btn3 = self.leftpanel:GetChild("n45")--丢弃
        c1 = self.leftpanel:GetController("c1")
        p1 = self.leftpanel:GetChild("n42")
        xylist=  self.leftxy
    else
        btn1 = self.rightpanel:GetChild("n50")
        btn2 = self.rightpanel:GetChild("n56")
        btn3 = self.rightpanel:GetChild("n51")
        c1 = self.rightpanel:GetController("c1")
        p1 = self.rightpanel:GetChild("n48")
        xylist = self.rightxy
    end

    btn1.onClick:Clear()
    btn1.onClick:Add(self.onWearEquip,self)
    btn2.onClick:Clear()
    btn3.onClick:Clear()

    btn2.title = language.eightgates02[6]--分解
    btn2.onClick:Add(self.onTunshi,self)
    btn3.onClick:Add(self.onClickStreng,self)
    btn3.visible = false
    if self.index == 1 then--只是查看
        c1.selectedIndex = 0
    elseif self.index == 2 then--穿戴
        c1.selectedIndex = 1
        btn1.title = language.eightgates02[1]--镶嵌
        btn1.visible = true
        btn2.visible = true
        btn3.visible = false
    elseif self.index == 3 then--更换
        c1.selectedIndex = 1
        btn1.visible = true
        btn2.visible = true
        btn3.visible = false
        btn1.title = language.eightgates02[2]--替换
    elseif self.index == 4 then--脱
        c1.selectedIndex = 1
        btn1.visible = true
        btn2.visible = false
        btn3.visible = true
        btn1.title = language.eightgates02[3]--卸下
        -- btn2.title = language.eightgates02[4]--精炼
        btn3.title = language.eightgates02[5]--强化
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

function EightGatesElementTips:onWearEquip(context)
    local btn = context.sender
    local param = {}
    param.indexs = {}
    if self.index == 1 then
        return --看
    elseif self.index == 2 then--穿
        local data = cache.AwakenCache:getEightGatesData()
        if not self.site then
            -- GComAlter(language.eightgates10)
            -- return
            for k,v in pairs(data.info) do
                if v.state == 1 then
                   self.site = k 
                   break
                end
            end
        end

        local leftInfo = cache.PackCache:getEleByType(self.choseSubType)
        if leftInfo  then
            GComAlter(language.eightgates19)
            return
        end

        if not self.site then
            GComAlter(language.eightgates10)
            return
        end
        local state = data.info[self.site].state
        if state == 2 then
            GComAlter(language.eightgates17)
            return
        elseif state == 0 then
            GComAlter(language.eightgates18)
            return
        end
        param.openType = 0
        param.toIndexs = {Pack.elementEquip + self.site}
        table.insert(param.indexs,self.data.index)
    elseif self.index == 3 then--换
        local data = cache.AwakenCache:getEightGatesData()
        --已装备的mid
        local equipmid = self.leftInfo.mid
        local elementInfo = data.info
        local equipType = conf.ItemConf:getSubType(equipmid)
        
        local leftInfo = cache.PackCache:getEleByType(self.choseSubType)
        if leftInfo and self.choseSubType ~= equipType then
            GComAlter(language.eightgates19)
            return
        end
        --孔位
        local site = 1
        for k,v in pairs(elementInfo) do
            if equipmid == v.eleInfo.mid then
                site = k
                break
            end
        end
        param.openType = 0
        param.toIndexs = {Pack.elementEquip + site}
        table.insert(param.indexs,self.data.index)
    elseif self.index == 4 then--脱
        param.openType = 1
        param.toIndexs = {Pack.elementPack + self.site}
        table.insert(param.indexs,self.leftInfo.index)
    end
    proxy.AwakenProxy:sendMsg(1610102,param)
    self:closeView()
end

function EightGatesElementTips:onClickStreng()
    mgr.ViewMgr:openView2(ViewName.ElementStrengView,{mid = self.data.mid})
    self:closeView()
end

--吞噬
function EightGatesElementTips:onTunshi()
    mgr.ViewMgr:openView2(ViewName.ShengYinResolve,{isEightElE = true})
    self:closeView()
end

return EightGatesElementTips