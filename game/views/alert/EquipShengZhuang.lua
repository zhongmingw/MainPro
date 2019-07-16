--
-- Author: 
-- Date: 2018-09-12 11:24:36
--

local EquipShengZhuang = class("EquipTipsView", base.BaseView)
local dian = mgr.TextMgr:getImg(UIItemRes.dian01)

function EquipShengZhuang:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function EquipShengZhuang:initView()
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

function EquipShengZhuang:initData()
    -- body
    self.leftpanel:GetChild("n44").xy = self.leftxy[1]
    self.leftpanel:GetChild("n48").xy = self.leftxy[2]
    self.leftpanel:GetChild("n45").xy = self.leftxy[3]

    self.rightpanel:GetChild("n50").xy = self.rightxy[1]
    self.rightpanel:GetChild("n56").xy = self.rightxy[2]
    self.rightpanel:GetChild("n51").xy = self.rightxy[3]
end
--圣装不进普通背包 ，不用做仓库，背包内部处理
function EquipShengZhuang:setData(data)
    if not data then
        self:closeView()
        return
    end
    self.data = data
    self.strenLev = data.level or 0
    
    self.leftpanel.visible = false
    self.rightpanel.visible = false

    if not data.index then
        data.index = 0
    end
    local confData = conf.ItemConf:getItem(data.mid)
    self.part = confData.part
    
    self.packInfo = cache.PackCache:getShengZhuangDataByIndex(data.index)

    self.leftInfo = cache.AwakenCache:getShengZhuangEquppedByPart(self.part)
    -- printt("已装备圣装",self.leftInfo)
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
            self.index = 4 --卸下
        end
    end
    -- local isSub = conf.ItemConf:getSubType(data.mid) --是不是碎片
    -- if isSub == 2 then
    --     self.index = 1
    -- end
    if self.index == 1 then
        if self.leftInfo then--已经装备了圣裝(左右两个面板都打开)
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

function EquipShengZhuang:initLeft(data)
    self.leftmid = data.mid
    self.leftpanel.visible = true
    --强化等级
    local strenLevTxt = self.leftpanel:GetChild("n57")
    strenLevTxt.text = self.strenLev == 0 and "" or "+"..self.strenLev
    --道具icon
    local itemObj = self.leftpanel:GetChild("n19")
    local t = clone(data)
    t.isquan = true
    GSetItemData(itemObj,t)

    local confData = conf.ItemConf:getItem(data.mid)
    --名字
    local name = self.leftpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)
    --部位
    local partName = self.leftpanel:GetChild("n25") 
    partName.text = language.shengzhuang01[confData.part]
    --绑定
    local isbind = self.leftpanel:GetChild("n26") 
    isbind.text = ""
    --阶数
    local equipDesc1 = self.leftpanel:GetChild("n27")
    local stageLvl = conf.ItemConf:getStagelvl(data.mid)
    equipDesc1.text = string.format(language.equip01,stageLvl)
    -- equipDesc1.text = ""
    --品质
    local colorText1 = self.leftpanel:GetChild("n49")
    colorText1.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[confData.color],confData.color)
    --装备等级
    local level = self.leftpanel:GetChild("n50")
    local lvl = conf.ItemConf:getLvl(data.mid)
    level.text = string.format(language.pack34, lvl)

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

function EquipShengZhuang:initRight(data)
    self.rightmid = data.mid
    self.rightpanel.visible = true
    --道具icon
    local itemObj = self.rightpanel:GetChild("n19")
    local t = clone(data)
    t.isquan = true
    GSetItemData(itemObj,t)

    local confData = conf.ItemConf:getItem(data.mid)

    --名字
    local name = self.rightpanel:GetChild("n24")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)
    --部位
    local partName = self.rightpanel:GetChild("n25") 
    partName.text = language.shengzhuang01[confData.part]
    --绑定
    local isbind = self.rightpanel:GetChild("n26") 
    isbind.text = ""
    --阶数
    local equipDesc1 = self.rightpanel:GetChild("n27")
    local stageLvl = conf.ItemConf:getStagelvl(data.mid)
    equipDesc1.text = string.format(language.equip01,stageLvl)
    --品质
    local colorText1 = self.rightpanel:GetChild("n58")
    colorText1.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[confData.color],confData.color)
 
    --装备等级
    local level = self.rightpanel:GetChild("n57")
    local lvl = conf.ItemConf:getLvl(data.mid)
    level.text = string.format(language.pack34, lvl)

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

function EquipShengZhuang:setEquipContrast()
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

function EquipShengZhuang:setListMsg(listView,data)
    listView.numItems = 0
    local attiData = conf.ItemArriConf:getItemAtt(data.mid)

    local baseAttData = GConfDataSort(attiData)
   
    --基础属性
    local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
    local baseitem = listView:AddItemFromPool(url)

    local score = 0--基础评分
    local str = ""
    for k,v in pairs(baseAttData) do
        local str1 = dian.." "..conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],math.floor(v[2]))
        if k ~= #baseAttData then
            str1 = str1.."\n"
        end
        str = str..str1
        score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])--基础评分
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
        for k,v in pairs(colorAttris) do
            local str1 = self:attiCallback(v.type,v.value)
            local text1 = ""
            if k~= #data.colorAttris then
                str1 = str1.."\n"
            end
            str = str..dian.." "..str1
            synScore = synScore + mgr.ItemMgr:birthAttScore(v.type,v.value)--计算综合评分
        end
    else

        local birthAtt = conf.ItemConf:getBaseBirthAtt(data.mid)--推荐属性
        local isTuijian = true
        if not birthAtt then--固定生成的属性不走推荐
            
            birthAtt = conf.ItemConf:getBirthAtt(data.mid) or {}
            baseitem:GetChild("n0").text = language.equip02[2]
        else
            isTuijian = false
            baseitem:GetChild("n0").text = language.equip02[2]--..string.format(language.equip07, #birthAtt / 2)
        end
        --print("推荐属性",isTuijian,data.eStar)
        for k,v in pairs(birthAtt) do
            if k % 2 == 0 then--值
                local type,value = birthAtt[k - 1],birthAtt[k]
                local str1 = self:attiCallback(type,value,isTuijian)
                local text1 = ""
                if k ~= #birthAtt then
                    str1 = str1.."\n"
                end
                str = str..dian.." "..str1
                if not isTuijian then--如果是固定生成的
                    synScore = synScore + mgr.ItemMgr:birthAttScore(type,value)--计算综合评分
                end
            end
        end
    end
    if str == "" then
        str = dian.." "..language.zuoqi26
    end
    baseitem:GetChild("n0").text = language.equip02[2]
    baseitem:GetChild("n1").text = ""
    baseitem:GetChild("n8").text = str


    --套装显示
    local startNum = data.eStar or  mgr.ItemMgr:getColorBNum(data)
    local countSuit = CGActShengZhuangSuitBystartNum()
    local confData = conf.AwakenConf:getJsTaoZhuangshuxing(startNum)
    local name
    for k,v in pairs(confData) do
        if v.js_name then
            name = v.js_name
        end
    end
    local url = UIPackage.GetItemURL("alert" , "Component2")
    baseitem = listView:AddItemFromPool(url)
    baseitem:GetChild("n0").text =  name.."("..countSuit["num"..startNum] .."/".."10)"
    
    for k,v in pairs(confData) do
        local url = UIPackage.GetItemURL("alert" , "baseAttiItem1")
        baseitem = listView:AddItemFromPool(url)
        
        local var = "["..v.num.."件]"
        local temp = GConfDataSort(v)
        local str3 = ""
        for i,j in pairs(temp) do
            str3 = str3..conf.RedPointConf:getProName(j[1]).." +"..GProPrecnt(j[1],math.floor(j[2]))
            if i ~= #temp then
                str3 = str3.."\n"
            end
            if countSuit["num"..startNum] >= v.num then
                synScore = synScore + mgr.ItemMgr:baseAttScore(j[1],j[2])
            end
        end
        if countSuit["num"..startNum] >= v.num then
            str3 = mgr.TextMgr:getTextColorStr(str3, 7)
            var = mgr.TextMgr:getTextColorStr(var, 7) 

        end
        baseitem:GetChild("n1").text = var
        baseitem:GetChild("n11").text = str3

        --str = dian.." ["..v.num.."件]".."\n"..str3

        -- local actNum = CGActShengZhuangSuitByid(data)
        -- getNum = actNum
        -- colorStr = actNum >= v.num and "[color=#0b8109]" or ""
        -- colorStrEnd = actNum >= v.num and "[/color]" or ""
        -- local str1 = ""
        -- -- str3 = str3.."\n".."        "
        -- str1 = dian..colorStr.." ["..v.num.."件]".." "..str3..colorStrEnd
        -- endStr = v.num >= 10 and "" or "\n"
        -- str = str..str1..endStr 
        -- if actNum >= v.num then
        --     synScore = synScore + mgr.ItemMgr:birthAttScore(j[1],j[2])--计算综合评分
        -- end
    end

    --local data1 = GConfDataSort(confData) 
    
    --baseitem:GetChild("n0").text =  name.."("..countSuit["num"..startNum] .."/".."10)"
    --baseitem:GetChild("n8").text = "[color=#444034]"..str.."[/color]"
    return score,synScore

end

--极品属性
function EquipShengZhuang:attiCallback(id,value,isTuijian)
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
        str = name..attiValue--language.equip08.." "..name..attiValue
    else
        str = name..attiValue
    end
    return mgr.TextMgr:getQualityAtti(str,color)
end

--获取途径
function EquipShengZhuang:setGetWayList(listView1,confData)
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

function EquipShengZhuang:onBtnGo(context)
    local data = context.sender.data
    local param = {id = data.id,childIndex = data.childIndex}
    GOpenView(param)
end

function EquipShengZhuang:setBtnSeeinfo(way)
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
        xylist=  self.rightxy
    end
    
    btn1.onClick:Clear()
    btn1.onClick:Add(self.onWearEquip,self)
    btn2.onClick:Clear()
    btn3.onClick:Clear()

    btn2.title = language.shengzhuang02[2]--上架
    btn2.onClick:Add(self.onShangJia,self)
    btn3.title = language.shengzhuang02[5]--丢弃
    btn3.onClick:Add(self.onDiuQi,self)
    -- btn3.visible = false
    if self.index == 1 then--只是查看
        c1.selectedIndex = 0
    elseif self.index == 2 then--穿戴
        c1.selectedIndex = 1
        btn1.title = language.shengzhuang02[1]
        btn1.visible = true
        btn2.visible = true
        btn3.visible = true
    elseif self.index == 3 then--更换
        c1.selectedIndex = 1
        btn1.visible = true
        btn2.visible = true
        btn3.visible = true
        btn1.title = language.shengzhuang02[4]
    elseif self.index == 4 then--脱
        c1.selectedIndex = 1
        btn1.visible = true
        btn1.title = language.shengzhuang02[3]
        btn2.visible = false
        btn3.visible = false
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

function EquipShengZhuang:onWearEquip(context)
    local btn = context.sender
    local param = {}
    param.indexs = {}
    if self.index == 1 then
        return --看
    elseif self.index == 2 then--穿
        param.opType = 0
        param.toIndexs = {Pack.shengZhuangEquip + self.part}
        table.insert(param.indexs,self.data.index)
    elseif self.index == 3 then--换
        param.opType = 0
        param.toIndexs = {Pack.shengZhuangEquip + self.part}
        table.insert(param.indexs,self.data.index)
    elseif self.index == 4 then--脱
        param.opType = 1
        param.toIndexs = {Pack.shengZhuangPack + self.part}
        table.insert(param.indexs,Pack.shengZhuangEquip + self.part)
       
    end
    printt(param)
    proxy.AwakenProxy:sendMsg(1190201,param)
   
    self:closeView()
end
--上架
function EquipShengZhuang:onShangJia()
     mgr.ViewMgr:openView(ViewName.MarketMainView,function(view)
                
            end,{index = 1})
    self:closeView()
end

--丢弃
function EquipShengZhuang:onDiuQi()
    print("diuqi")
    if not self.data then
        return
    end
    mgr.ItemMgr:delete(self.data.index)
    self:closeView()
end

return EquipShengZhuang