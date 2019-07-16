--
-- Author: 
-- Date: 2018-12-03 12:37:40
--
local  fuMoMaxLevel = conf.MianJuConf:getGlobal("mask_fm_max_level")
local  mianjuMaxLevel = conf.MianJuConf:getGlobal("mask_max_level")
local startMaxNum = conf.MianJuConf:getGlobal("mask_start_max")


local MianJuPanel = class("MianJuPanel", import("game.base.Ref"))

function MianJuPanel:ctor(parent)
    self.parent = parent
    self.view = parent.view:GetChild("n22")
    self:initView()
end

function MianJuPanel:initView()
    self.c1 = self.view:GetController("c1") --1：选择前 2：选择后
    -- self.c1.onChanged:Add(self.onChangeC1,self)--panel选择控制
    self.c1.selectedIndex = 0
    self.btnList1 = {}
    self.chooseBeforePanel = self.view:GetChild("n8")
    self.chooseLaterPanel = self.view:GetChild("n18")
    self:initChooseBefore()
    self:initChooseLater()
    self.c1_choose = self.chooseLaterPanel:GetController("c1")
    self.index = 0 --当前索引
    self.mask_max_level = conf.MianJuConf:getGlobal("mask_max_level") --面具最大等级
    self.upstartImg = self.chooseLaterPanel:GetChild("n66")
    self.upstartImg.visible = false

end

-- 1   int32   变量名: maskType   说明: 面具类型
-- 2   array<MaskSubInfo>  变量名: maskSunInfos   说明: 面具小类信息
-- 3   int32   变量名: level  说明: 面具等级
-- 4   map<int32,int32>    变量名: growInfo   说明: 成长丹使用情况 （id - num）
-- 5   int32   变量名: exp    说明: 经验
-- 6   int32   变量名: power  说明: 战力
function MianJuPanel:addMsgCallBack(data)
    printt("面具信息......",data)
    if data.msgId == 5630101 or data.msgId == 5630105 then--面具信息 幻化 返回
        self.data = data
        self.maskInfos = {}
        self.maskSunInfos = {}
        self.growInfo =  {}
        self.power = {} --升级战力列表
        self.upLevelData = {}--升级属性数据
        self.chengZhangDanId = nil --成长丹id
        for k,v in pairs(self.data.maskInfos) do
            self.maskInfos[k] = v
            self.btnList1[k].objbtn:GetChild("n3").text = v.level
            --计算总战力
            local sumpower = 0
            sumpower = v.power 
            self.maskSunInfos[k] = {}
            
            for k1,v1 in pairs(v.maskSunInfos) do
               sumpower = sumpower + v1.power
                --附魔星数战力
                -- print("附魔星数战力")
                -- printt(v1)
                -- sumpower = sumpower + self:calpower(v1)
                table.insert(self.maskSunInfos[k],v1)
            end
            self.growInfo[k] = {}
            for k2,v2 in pairs(v.growInfo) do
                table.insert(self.growInfo[k],{mid = k2,num = v2})
            end
            
            self.btnList1[k].objbtn:GetChild("n7").text = math.floor(sumpower) 

            table.insert(self.power,v.power)
        end
    elseif data.msgId == 5630104 then--升星返回
        for k,_ in pairs(self.maskInfos) do
            for i,v in pairs(self.maskInfos[k].maskSunInfos) do
                if v.id == data.maskInfo.id then
                    self.maskInfos[k].maskSunInfos[i].starNum = data.maskInfo.starNum
                    break
                end
            end
        end
        for k,v in pairs(self.maskSunInfos) do
            if self.maskSunInfos[k].id == data.maskInfo.id then
                self.maskSunInfos[k].starNum = data.maskInfo.starNum
                break
            end
        end
        for k,v in pairs(self.MianJusubData) do
            if data.maskInfo.id == v.id then
                v.starNum = data.maskInfo.starNum
                local data1 = cache.MianJuCache:getMianJuChooseData()
                data1.starNum =  data.maskInfo.starNum
                cache.MianJuCache:setMianJuChooseData(data1)
                break
            end
        end
        self:returnStartRedPoint()
        self:refreshoutBtn()
    end
    
    if self.isJiHuoFanHui then--激活返回
        self.isJiHuoFanHui = false
        self:updateAllList(self.index)
    end
    if self.selectIndex then
        local cell = self.listview01:GetChildAt(self.selectIndex)
        if cell then
            cell.onClick:Call()
        end
    end
    self.listview01:RefreshVirtualList()

    --升级过程中点击时
    self.isLevel = false
    if self.isLevel then
        self.btn1.icon = UIPackage.GetItemURL("shenqi","juesexinxishuxin_014")
    else
        self.btn1.icon = UIPackage.GetItemURL("shenqi","mianju_011")
    end 
    if self.c1.selectedIndex == 0 then--面具大类界面
        --红点计算
        for k,obj in pairs(self.btnList1) do
            local redNum = self:getMianJuUpLevRed(k)--升级红点
            local czdRed = self:getMianJuCzdRed(k)--成长丹红点
            redNum = redNum + czdRed
            -- print("redNUM>>>>>",redNum)
            local maskInfos = self.maskInfos[k].maskSunInfos
            -- printt("self.maskInfos>>>>>>>>>>>>>>>>>",maskInfos)
            for _,v in pairs(maskInfos) do
                if v then
                    local starNum = self:calStartRedPoint(v)--升星红点
                    -- local actNum = self:caljihuoRedPoint(v)--激活红点
                    local fumoNum = self:getMianJuFumoRed(v)--附魔红点
                    redNum = redNum + starNum + fumoNum
                    -- print("红点》》》》》",starNum,actNum,fumoNum,v.id)
                end
            end
            --激活红点
            local confData = conf.MianJuConf:getMianJuConfData()
            local actNum = 0
            for _,v in pairs(confData) do
                local itemId = v.itemId
                local itemData = cache.PackCache:getPackDataById(itemId)
                if itemData.amount > 0 and not cache.MianJuCache:isHasMianJu(v.id) and v.maskType == k then
                    actNum = actNum + 1
                end
            end
            redNum = redNum + actNum

            if redNum > 0 then
                obj.objbtn:GetChild("red").visible = true
            else
                obj.objbtn:GetChild("red").visible = false
            end
        end
    elseif self.c1.selectedIndex == 1 then
        local redNum = self:getMianJuUpLevRed(self.index)--升级红点
        local czdRed = self:getMianJuCzdRed(self.index)--成长丹红点
        redNum = redNum + czdRed
        -- print("面具升级红点>>>>>>>>>>>>",redNum,self.index)
        if redNum > 0 then
            self.sumbtn:GetChild("red").visible = true
        else
            self.sumbtn:GetChild("red").visible = false
        end
    end
end


function MianJuPanel:initChooseBefore()
    for i =8,10 do 
        local btn = self.chooseBeforePanel:GetChild("n"..i)
        btn:GetChild("n4").text = language.mianju01[i -7]
        btn:GetChild("n5").text = language.mianju02[i -7]
        btn:GetChild("n1").text = language.mianju11[i -7] --面具名字
        -- btn:GetChild("n3").text = language.mianju11[i -7] -- level

        btn.data = i- 7
        btn.onClick:Add(self.onEnter,self)
        btn.selected = false
        table.insert(self.btnList1,{objbtn = btn} )
    end
end

function MianJuPanel:onEnter(context)
    local data = context.sender.data
    self.c1.selectedIndex = 1
    self.index = data
    self.c1_choose.selectedIndex = 0
    self.confConsume = conf.MianJuConf:getMianComsumeItem(self.index)
    self.btnList3 = {} -- 材料按钮列表
    for i =24,26 do
        local item = self.chooseLaterPanel:GetChild("n"..i)
        item.data = {index = i - 24}
        item.onClick:Add(self.onClickTouchItem,self)
        table.insert(self.btnList3,{obj = item:GetChild("n4"),amount = 1 ,mid = 1,id = i-24})
    end

    self:updataPanel(data)
      --顶级处理
    self:detailUpLevel()
    --红点
    -- self:detailRedPoint()
end

function MianJuPanel:initChooseLater()
    self.listview01 = self.chooseLaterPanel:GetChild("n45") --选项列表
    self.listview01:SetVirtual()
    self.listview01.itemRenderer = function (index,obj)
        self:celldata1(index, obj)
    end
    self.listview02 = self.chooseLaterPanel:GetChild("n17")--升级属性列表
    self.listview03 = self.chooseLaterPanel:GetChild("n44")--附魔列表

    self.titleName = self.chooseLaterPanel:GetChild("n3")--标题名字

    self.btnList2 = {} -- 属性丹按钮列表
    for i = 52,54 do
       local btn =  self.chooseLaterPanel:GetChild("n"..i)
       table.insert(self.btnList2, btn)
       btn.data = {index = i-51}
       btn.onClick:Add(self.btnClick02,self) --点击属性丹响应
    end
    self.text01  =  self.chooseLaterPanel:GetChild("n13") --战力文本
    self.text02  =  self.chooseLaterPanel:GetChild("n32") --等级文本
    self.text03  =  self.chooseLaterPanel:GetChild("n40") --附魔的等级
    self.text04  =  self.chooseLaterPanel:GetChild("n39") --当前附魔的等级
    self.progress  =  self.chooseLaterPanel:GetChild("n46") --进度条
    local ruleBtn = self.view:GetChild("n19")  
    ruleBtn.onClick:Add(self.onClickRule,self)


    self.controller2 = self.chooseLaterPanel:GetController("c2")
    self.controller1 = self.chooseLaterPanel:GetController("c1")
    self.sumbtn = self.chooseLaterPanel:GetChild("n2")
    self.sumbtn.onChanged:Add(self.Change,self)--总览


    self.btn1 = self.chooseLaterPanel:GetChild("n27") --一键升级
    self.btn1.data = 1
    self.btn1.onClick:Add(self.goLevel,self)
    self.btn2 = self.chooseLaterPanel:GetChild("n28")-- 升级
    self.btn2.data = 2
    self.btn2.onClick:Add(self.goLevel,self)
    self.btn3 = self.chooseLaterPanel:GetChild("n35") --幻化
    self.btn3 .onClick:Add(self.onHuanHua,self)
    self.btn7 = self.chooseLaterPanel:GetChild("n56")-- 技能1
    self.btn7.onClick:Add(self.onShowSkill,self)
    self.btn8 = self.chooseLaterPanel:GetChild("n57") --技能2
    self.btn8 .onClick:Add(self.onShowSkill,self)
    self.btn4 = self.chooseLaterPanel:GetChild("n33") --附魔
    self.btn4.onClick:Add(self.onFumo,self)
    self.btn5 = self.chooseLaterPanel:GetChild("n59") --升星
    self.btn5.onClick:Add(self.onStart,self)
    self.btn6 = self.chooseLaterPanel:GetChild("n68") --返回
    self.btn6.onClick:Add(self.onReturn,self)
    self.isLevel = false
    self.heroModel = self.chooseLaterPanel:GetChild("n62"):GetChild("n60")--模型
    self.effectPanel = self.chooseLaterPanel:GetChild("n62"):GetChild("n62") --触摸
    self.heroPanel = self.chooseLaterPanel:GetChild("n62")--容器
    self.node = self.chooseLaterPanel:GetChild("n63")--升级特效
    self.mianjuitem =  self.chooseLaterPanel:GetChild("n69")--面具道具
    self.mianjuitem.visible =false

end

function MianJuPanel:onShowSkill(context) --技能展示
    local data = context.sender.data
    if data then
        mgr.ViewMgr:openView2(ViewName.MianJuSkillView, data)
    end
end

--总览
function MianJuPanel:Change(context)
    if self.sumbtn.selected == true then
        self.controller1.selectedIndex = 0
        self.text01.text = self.power[self.index]
        -- self.sumbtn:GetController("button").selectedIndex = 1 
        self.listview01.numItems = #self.MianJusubData
        self:updateShengJiList()
        self:addModel()
        self.listview01:ClearSelection()
    end
end

function MianJuPanel:onClickTouchItem(context)
    local data = context.sender.data
    local index = data.index
    local itemData = cache.PackCache:getPackDataById(self.confConsume[index+1][1])
    itemData.index = 0
    GSeeLocalItem(itemData)
end

function MianJuPanel:updataPanel(index)
    self.sumbtn.selected = true
    self.listview01:ClearSelection()
    self:updateAllList(index) -- 刷新列表
    self:updateShuXingDan() --刷新属性丹状态
    self:updataAllTextandProgress(data) --刷新文本和进度条
    self:refreshItems() -- 刷新升级材料
    self:addModel()
    self.sumbtn.onClick:Call()
end

function MianJuPanel:updateAllList(index)
    self.MianJusubData =  conf.MianJuConf:getMianjuTypeData(index)
    local subData  = {} --对应类型小类赋值
    for k,v in pairs(self.maskSunInfos[self.index]) do
        subData[v.id] = v 
    end
    for k,v in pairs(self.MianJusubData) do
        if subData[v.id] then
            v.activation = subData[v.id].activation
            v.starNum = subData[v.id].starNum
            v.wear = subData[v.id].wear
            v.elements = subData[v.id].elements
            v.fmLevel = subData[v.id].fmLevel
            v.power = subData[v.id].power

        end
    end
    
    self.listview01.numItems = #self.MianJusubData -- 刷新左边按钮列表
    if self.controller1.selectedIndex == 0 then
        self:updateShengJiList()
    end
end

--更新升级列表
function MianJuPanel:updateShengJiList() 
    local data1 = conf.MianJuConf:getExp(self.index,(self.maskInfos[self.index].level or 0)) -- 当前级
    local data2 = conf.MianJuConf:getExp(self.index,(self.maskInfos[self.index].level or 0)+ 1) -- 下一级


    local t1 =GConfDataSort(data1)
    local t2 = {}
    if data2 then
         t2 =  GConfDataSort(data2)
    end
    local  t3  = clone(t1) --还未加属性丹的时候
    --已使用属性丹情况
    
    
    for k,v in pairs(self.growInfo[self.index]) do
        local  data = conf.ItemArriConf:getItemAtt(v.mid)
         local  t3 =GConfDataSort(data)
         local t4 = self:calData(t3,v.num)
        G_composeData(t1,t4)
    end
  
     table.sort(t1,function(a,b)
        -- body 
        local asort = conf.RedPointConf:getProSort(a[1]) 
        local bsort = conf.RedPointConf:getProSort(b[1]) 
        if asort == bsort then
            return a[1]<b[1]
        else
            return asort < bsort
        end
    end)
    self.listview02.numItems = 0 

    for k,v in pairs(t1) do
        local url = UIPackage.GetItemURL("shenqi" , "Component7")
        baseitem = self.listview02:AddItemFromPool(url)
        baseitem:GetChild("n0").text = conf.RedPointConf:getProName(v[1])
        baseitem:GetChild("n1").text = GProPrecnt(v[1],v[2])
        baseitem:GetChild("n2").text = ""
        -- if t2[k] and t2[k][2] ~= 0 then
        --     baseitem:GetChild("n2").text = mgr.TextMgr:getTextColorStr("(+"..GProPrecnt(t2[k][1],math.floor(t2[k][2]))..")",7) 
        -- else
        --     baseitem:GetChild("n2").text = ""
        -- end
        for k1,v1 in pairs(t2) do
            if v1[1] == v[1] and data1["att_"..v[1]] then
                local cc = v1[2] - data1["att_"..v[1]]
                local var = "(+" .. math.max(cc,0) .. ")"
                ---local var = "(+"..(GProPrecnt(v1[1],math.floor(v1[2]))-GProPrecnt(t3[k][1],t3[k][2]))..")"

                baseitem:GetChild("n2").text = mgr.TextMgr:getTextColorStr(var,7) 
           
            end
        end
    end
end

function MianJuPanel:updateShuXingDan() --刷新属性丹状态
    local data = conf.MianJuConf:getGlobal("mask_grow_item")[self.index]
    for k,v in pairs(self.btnList2) do
        local num = 0
        local mid = data[k]
        local packData = cache.PackCache:getPackDataById(mid)
        v:GetChild("n9").url = mgr.ItemMgr:getItemIconUrlByMid(mid)
        num = packData.amount
       
        --升级图标
        local upImg =  v:GetChild("n7")
        local  data1 = {} --后端根据面具类型返回成长丹已使用的情况
        if self.growInfo[self.index] then
            for k,v in pairs(self.growInfo[self.index]) do
                data1[k] = v  --id - num
            end
        end
        local level = self.maskInfos[self.index].level or 0
        local grownconf = conf.MianJuConf:getGrownNum(level,self.index)

      
        -- if data1[grownconf[1][k][1]] then --后端返回数据有已使用数量的话 判断是否满足升级
        --     if num >= grownconf[1][k][2]  then
        --         upImg.visible = true
        --     else
        --         upImg.visible = false
        --     end
        -- else --后端没返回时自己判断是否达到条件
    
        -- print(grownconf[k][2],"配置")
        local usenum = 0
        -- local usenum = self.growInfo[self.index][k] and self.growInfo[self.index][k].num or 0--后端返回数量
        for k,v in pairs(self.growInfo[self.index]) do
            if v.mid == mid then
                usenum = v.num
            end
        end
        -- print(usenum,"后端返回已使用数量")
        if usenum < grownconf[k][2] then --已使用小于配置
            if  num > 0 then
                upImg.visible = true
            else
                upImg.visible = false
            end
        else
            upImg.visible = false

        end
        -- end
        v.data.id = mid
        -- v:GetChild("n8").text = num >= 1 and mgr.TextMgr:getTextColorStr(num.."",7) or mgr.TextMgr:getTextColorStr(num.."",14)
        v:GetChild("n8").text = usenum 
        --成长丹是否一直升级
        if  upImg.visible and self.chengZhangDanId then
            proxy.MianJuProxy:send(1630103,{maskType=  self.index,itemId = self.chengZhangDanId})
        end
    end
end

function MianJuPanel:updataAllTextandProgress(data)
 
    if data then  --面具大类升级返回
        self.maskInfos[self.index].level = data.level
        self.power[self.index] = data.power
         self.maskInfos[self.index].exp = data.exp
         self.text01.text = data.power
         printt(self.maskInfos[self.index])
    end
    self.titleName.text = language.mianju03[self.index]
   
    -- print(self.power[self.index])
    self.text02.text = self.maskInfos[self.index].level
    if conf.MianJuConf:getExp(self.index,self.maskInfos[self.index].level or 0).need_exp then
        self.progress.max = conf.MianJuConf:getExp(self.index,self.maskInfos[self.index].level or 0).need_exp
        self.progress.value = self.maskInfos[self.index].exp
        self.progress:GetChild("title").text = self.progress.value .. "/" .. self.progress.max
    else
        self.progress.value =10
        self.progress.max =10
        self.progress:GetChild("title").text = "MAX"
    end
end

function MianJuPanel:celldata1(index, obj)
    local data = self.MianJusubData[index + 1]
    local nameText = obj:GetChild("n3")
    local item = obj:GetChild("n10")
    local XinXin = obj:GetChild("n7")
    local c1 = obj:GetController("c1")
    local redImg = obj:GetChild("n9")
    -- c1.selectedIndex = 1
    local itemData = {mid = data.itemId,amount = 1,bind = 0,isquan = true}
    GSetItemData(item, itemData, true)
    nameText.text =  mgr.TextMgr:getColorNameByMid(data.itemId)
    -- obj.grayed = true
    if data.activation then
         -- obj.grayed = false
        if data.activation == 0 then --未激活
              c1.selectedIndex = 2  
        elseif data.activation == 1 then --激活
                if data.wear == 1  then
                    c1.selectedIndex = 0 --幻化
                else
                    c1.selectedIndex = 1
                end
        end
    else
        c1.selectedIndex = 2
    end
    if data.starNum then
        XinXin:GetController("c1").selectedIndex = data.starNum>= 5 and 5 or data.starNum
    end
    local  act = false
    if c1.selectedIndex ~= 2 then
        act = true
    end
    --红点显示
    local redNum = 0
    local starNum = self:calStartRedPoint(data)--升星红点
    local actNum = self:caljihuoRedPoint(data)--激活红点
    local fumoNum = self:getMianJuFumoRed(data)--附魔红点
    -- print("红点>>>>>>>>>>",starNum, actNum, fumoNum,data.id)
    redNum = starNum + actNum + fumoNum
    if redNum > 0 then
        redImg.visible = true
    else
        redImg.visible = false
    end

    obj.data = {objData= obj, mid = data.itemId,id = data.id,index = index + 1,isact = act}
    obj.onClick:Add(self.btnClick01,self)-- 点击面具小类
end

function MianJuPanel:btnClick01(context) -- 点击面具小类
    self.sumbtn.selected = false
    local data = context.sender.data
    self.selectIndex = data.index - 1--保存listview里所点击的item的index
    self.ChoosemianJumData  = {}
    --计算当前面具战力评分
    local score = 0
    -- self.text01.text =  --    
    self.sumbtn:GetController("button").selectedIndex = 0 
    local  isFind = false
    -- printt(self.maskSunInfos[self.index])
    for k,v in pairs(self.maskSunInfos[self.index]) do
        if v.id == data.id then
            isFind = true
            self.ChoosemianJumData.fmLevel = v.fmLevel or 0

            self.ChoosemianJumData.mid  = data.mid
            self.ChoosemianJumData.index  = self.index
            self.ChoosemianJumData.elements = v.elements
            self.ChoosemianJumData.wear = v.wear
            self.ChoosemianJumData.activation = v.activation
            self.ChoosemianJumData.id = v.id
            self.ChoosemianJumData.starNum = v.starNum or 0
            self.ChoosemianJumData.power = v.power or 0
       
            self.btn3.visible = true
            if v.wear == 1 then -- 已幻化
                self.isHuanHua = true
                self.btn3.icon =  UIPackage.GetItemURL("shenqi" , "mianju_039")  --取消幻化
            else
                self.isHuanHua = false
                self.btn3.icon =  UIPackage.GetItemURL("shenqi" , "mianju_012") --幻化
            end
          
        end
    end
    if not isFind then
        self.ChoosemianJumData.id = data.id
        self.ChoosemianJumData.fmLevel = 0 
        self.ChoosemianJumData.mid  = data.mid
        self.ChoosemianJumData.starNum  = 0
        self.ChoosemianJumData.index  = self.index
        self.ChoosemianJumData.activation = 0
        self.ChoosemianJumData.power = 0

        self.btn3.visible = false
    end

    -- printt(self.ChoosemianJumData,"当前选中面具数据")
    cache.MianJuCache:setMianJuChooseData(self.ChoosemianJumData)
    
    self.controller1.selectedIndex = 1
    local itemdata = conf.MianJuConf:getMianjuIdData(data.mid)
    local data1  = GConfDataSort(itemdata) -- 面具小类本身属性

    local itemstartdata = conf.MianJuConf:getMianjuStartData(self.ChoosemianJumData.id,self.ChoosemianJumData.starNum) --面具小类增加的星级属性
    local data2  = GConfDataSort(itemstartdata) 
    G_composeData(data1,data2)
    self.listview02.numItems = 0 
    self.text03.text = self.ChoosemianJumData.fmLevel >= fuMoMaxLevel and fuMoMaxLevel or self.ChoosemianJumData.fmLevel
    if (tonumber(self.text03.text)) == 0 then
        self.text03.text = "零重"
    else
        self.text03.text = self:numberToString(tonumber(self.text03.text) or 0).."重"
    end
 
    for k,v in pairs(data1) do
        local url = UIPackage.GetItemURL("shenqi" , "Component7")
        baseitem = self.listview02:AddItemFromPool(url)
        baseitem:GetChild("n0").text = conf.RedPointConf:getProName(v[1])
        baseitem:GetChild("n1").text = GProPrecnt(v[1],v[2])
        baseitem:GetChild("n2").text = ""
        score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])
    end

    --附魔列表
    local datafm = conf.MianJuConf:getMianJuFuMo(self.ChoosemianJumData.id,self.ChoosemianJumData.fmLevel)
    local data3 = GConfDataSort(datafm) --附魔重数加成的效果
    local itemstartdata = {}
    if self.ChoosemianJumData.fmLevel >= 1 then
        for k=1,3 do
            for i=0,self.ChoosemianJumData.fmLevel-1 do
                local data = conf.MianJuConf:getMianJuFuMoKongWei(self.ChoosemianJumData.id,i,k)
                local data1 = GConfDataSort(data) 
                G_composeData(itemstartdata,data1)
            end
        end
        if self.ChoosemianJumData.elements and #self.ChoosemianJumData.elements ~= 0 then
            for k,v in pairs(self.ChoosemianJumData.elements) do
                if v == datafm.elements[k] then  --若已激活
                    local data = conf.MianJuConf:getMianJuFuMoKongWei(self.ChoosemianJumData.id,self.ChoosemianJumData.fmLevel,k)
                    local data1 = GConfDataSort(data) 
                    G_composeData(itemstartdata,data1)
                end
            end
        end
        G_composeData(data3,itemstartdata)
        self.listview03.numItems = 0
        
        for k,v in pairs(data3) do
            local url = UIPackage.GetItemURL("shenqi" , "Component7")
            baseitem = self.listview03:AddItemFromPool(url)
            baseitem:GetChild("n0").text = conf.RedPointConf:getProName(v[1])
            baseitem:GetChild("n1").text = GProPrecnt(v[1],v[2])
            baseitem:GetChild("n3").visible = false
            baseitem:GetChild("n2").text = ""
           
        end
    else
        local flag = false
        if self.ChoosemianJumData.elements then
            for k,v in pairs(self.ChoosemianJumData.elements) do
                if v == datafm.elements[k] then  --若已激活
                    flag = true
                end
            end
        end
        -- print("flag >>>>>>>>>>>>>>>>>",flag,self.ChoosemianJumData.fmLevel)
        if self.ChoosemianJumData.fmLevel == 0 and not flag then --0级没有激活
            self.text03.y = 240
            self.text04.y = 240
            self.listview03.y = 268
            local datafm_ = conf.MianJuConf:getMianJuFuMo(self.ChoosemianJumData.id,1) --显示1级属性
            local data3 = GConfDataSort(datafm_)
            if self.ChoosemianJumData.elements and #self.ChoosemianJumData.elements ~= 0 then --判断0重已经激活的孔位
                for k,v in pairs(self.ChoosemianJumData.elements) do
                    if v == datafm_.elements[k] then  --若已激活
                        local data = conf.MianJuConf:getMianJuFuMoKongWei(self.ChoosemianJumData.id,1,k)
                        local data1 = GConfDataSort(data) 
                        G_composeData(data3,data1)
                    end
                end
            end
            self.listview03.numItems = 0
            for k,v in pairs(data3) do
                local url = UIPackage.GetItemURL("shenqi" , "Component7")
                baseitem = self.listview03:AddItemFromPool(url)
                baseitem:GetChild("n0").text = conf.RedPointConf:getProName(v[1])..":"
                baseitem:GetChild("n1").text = GProPrecnt(v[1],v[2])
                baseitem:GetChild("n3").visible = true
                baseitem:GetChild("n2").text = ""
            end
        else
            if self.ChoosemianJumData.elements and #self.ChoosemianJumData.elements ~= 0 then
                for k,v in pairs(self.ChoosemianJumData.elements) do
                    if v == datafm.elements[k] then  --若已激活
                        -- local data = conf.MianJuConf:getMianJuFuMoKongWei(self.ChoosemianJumData.id,self.ChoosemianJumData.fmLevel,k)
                        -- local data = {}
                        for i=0,self.ChoosemianJumData.fmLevel do
                            local data = conf.MianJuConf:getMianJuFuMoKongWei(self.ChoosemianJumData.id,i,k)
                            local data1 = GConfDataSort(data) 
                            G_composeData(itemstartdata,data1)
                        end
                     end
                 end
            end
            G_composeData(data3,itemstartdata)
            self.listview03.numItems = 0
            
            for k,v in pairs(data3) do
                local url = UIPackage.GetItemURL("shenqi" , "Component7")
                baseitem = self.listview03:AddItemFromPool(url)
                baseitem:GetChild("n0").text = conf.RedPointConf:getProName(v[1])
                baseitem:GetChild("n1").text = GProPrecnt(v[1],v[2])
                baseitem:GetChild("n3").visible = false
                baseitem:GetChild("n2").text = ""
               
            end
        end
    end

    if not data.isact then
        self.text01.text = 0
    else
        for k,v in pairs(self.maskSunInfos[self.index]) do
            if v.id == data.id then
                self.text01.text = v.power
            end
        end
    end
    self:addModel()
    --面具技能数据
    local skillConf = conf.MianJuConf:getSkillById(data.id)

    if skillConf then
      
        self.btn7.data = {}
        self.btn8.data = {}

        self.btn7.data = skillConf[1]
        self.btn8.data = skillConf[2]
    end
    --升级过程中点击时
    self.isLevel = false
    if self.isLevel then
        self.btn1.icon = UIPackage.GetItemURL("shenqi","juesexinxishuxin_014")
    else
        self.btn1.icon = UIPackage.GetItemURL("shenqi","mianju_011")
    end 
    self.btn4.data = {}
    --是否激活
    if data.isact then
        self.btn5.visible = true
        self.btn4.icon = UIPackage.GetItemURL("shenqi","mianju_021")  
        self.text03.y = 282
        self.text04.y = 282
        self.listview03.y = 308
        self.mianjuitem.visible =false
        self.btn4.x = 746
        --红点刷新
        self:refreshRed()
    else --未激活时
        self.btn5.visible = false
        self.btn4.data = {state =1}
        self.btn4.icon = UIPackage.GetItemURL("_imgfonts","chongzhivip_075")  
        self.text03.y = 240
        self.text04.y = 240
        self.listview03.y = 268
        self.listview03.numItems = 0
        local datafm = conf.MianJuConf:getMianJuFuMo(self.ChoosemianJumData.id,1) --显示1级属性
        local data3 = GConfDataSort(datafm)
        for k,v in pairs(data3) do
            local url = UIPackage.GetItemURL("shenqi" , "Component7")
            baseitem = self.listview03:AddItemFromPool(url)
            baseitem:GetChild("n0").text = conf.RedPointConf:getProName(v[1])..":"
            baseitem:GetChild("n1").text = GProPrecnt(v[1],v[2])
            baseitem:GetChild("n3").visible = true
            baseitem:GetChild("n2").text = ""
            self.mianjuitem.visible =true
            self.btn4.x = 800
            GSetItemData(self.mianjuitem, {mid = self.ChoosemianJumData.mid,amount = 1,bind = 0,isquan = true}, true)
        end
        local  num = cache.PackCache:getPackDataById(self.ChoosemianJumData.mid).amount or 0
        if num > 0 then
            self.mianjuitem.grayed = false
        else
            self.mianjuitem.grayed = true

        end
        self:jihuoRedPoint()--激活红点
    end


    --替换图标资源
    local data = conf.MianJuConf:getSkillById( self.ChoosemianJumData.id) 

    self.btn7.icon = UIPackage.GetItemURL("shenqi" ,data[1].icon)
    self.btn8.icon =  UIPackage.GetItemURL("shenqi" ,data[2].icon)
  
    self.btn7:GetChild("title").text = string.format(  language.mianju16 ,data[1].name,data[1].lv)
    self.btn8:GetChild("title").text = string.format(  language.mianju16 ,data[2].name,data[2].lv)

    
end

--升星紅點
function MianJuPanel:calStartRedPoint(data)
    local redNum = 0
    local starNum = data.starNum or 0
    if starNum >= startMaxNum then
        return 0
    end
    local confData = conf.MianJuConf:getMianjuStartData(data.id,starNum)
    -- print("data.id>>>>>>>starNum",data.id,starNum)
    if confData.item then
        local flag = true
        for i,item in pairs(confData.item) do
            local mid = item[1]
            local itemData = cache.PackCache:getPackDataById(mid)
            if itemData.amount < item[2] then
                flag = false
            end
        end
        if flag then
            redNum = redNum + 1
            return redNum
        end
    end
    return redNum
end

function MianJuPanel:refreshRed()
    local data = cache.MianJuCache:getMianJuChooseData()
    local starRed = self:calStartRedPoint(data)

    if starRed > 0 then
        self.btn5:GetChild("red").visible = true
    else
         self.btn5:GetChild("red").visible = false
    end
    local fmRed = self:getMianJuFumoRed(data)
    -- print("附魔红点>>>>>>",fmRed)
    if fmRed > 0 then
        self.btn4:GetChild("red").visible = true
    else
        self.btn4:GetChild("red").visible = false
    end
end

--激活紅點
function MianJuPanel:caljihuoRedPoint(data)
    local redNum = 0
    local mId = conf.MianJuConf:getMianJuData(data.id).itemId
    local itemData = cache.PackCache:getPackDataById(mId)
    if itemData.amount and not cache.MianJuCache:isHasMianJu(data.id) then
        redNum = redNum + itemData.amount
        return redNum
    end
    return redNum
end

function MianJuPanel:refreshUpLevRed()
    local Red = self:getMianJuUpLevRed(self.index)

    if Red > 0 then
        self.btn1:GetChild("red").visible = true
        self.btn2:GetChild("red").visible = true

    else
        self.btn1:GetChild("red").visible = false
        self.btn2:GetChild("red").visible = false
    end
end

--升级红点
function MianJuPanel:getMianJuUpLevRed(index)
    local redNum = 0
    local data = self.maskInfos[index]
    local cfgId = (1000+data.maskType)*1000 + data.level
    local confData = conf.MianJuConf:getMianJuLevConfData(cfgId)
    local nextConf = conf.MianJuConf:getMianJuLevConfData(cfgId+1)--下一等级
    if nextConf then
        local costItemData = conf.MianJuConf:getMianComsumeItem(data.maskType)
       
        for _,item in pairs(costItemData) do
            local mid = item[1]
            local itemData = cache.PackCache:getPackDataById(mid)
            if itemData.amount > 0 then
                redNum = redNum + 1
                return redNum
            end
        end
    end
    return redNum
end
--成长丹红点
function MianJuPanel:getMianJuCzdRed(index)
    local redNum = 0
    local data = self.maskInfos[index]
    local growInfo = self.growInfo[index]

    local growConf = conf.MianJuConf:getGrownNum(data.level,index)
    local midData = conf.MianJuConf:getGlobal("mask_grow_item")[index]
    for i,mid in pairs(midData) do
        local hasNum = cache.PackCache:getPackDataById(mid).amount
        local usenum = 0
        for k,v in pairs(growInfo) do
            if v.mid == mid then
                usenum = v.num
            end
        end
        -- print("usenum>>>>>>>>>>>",usenum,growConf[i][2],hasNum,index)
        if usenum < growConf[i][2] and hasNum > 0 then
            redNum = redNum + 1
            return redNum
        end
    end
    return redNum
end

--附魔红点
function MianJuPanel:getMianJuFumoRed(data)
    -- body
    local redNum = 0
    
    if data.activation ==  0 then
        return 0
    end
    local fmLevel = data.fmLevel or 0
    local confData = conf.MianJuConf:getMianJuFuMo(data.id,fmLevel)
    local nextConf = conf.MianJuConf:getMianJuFuMo(data.id,fmLevel+1)
    if nextConf and confData.items then
        local flag = true
        for i,item in pairs(confData.items) do
            local mid = item[1]
            local itemData = cache.PackCache:getPackDataById(mid)
            -- print("附魔道具>>>>>>",mid,itemData.amount)
            if itemData.amount < item[2] then
                flag = false
            end
        end
        if flag and cache.MianJuCache:isHasMianJu(data.id) then
            redNum = redNum + 1
            return redNum
        end
    end
    return redNum
end

function MianJuPanel:calFumoRedPoint()
    local data = cache.MianJuCache:getMianJuChooseData()
    if data.fmLevel < fuMoMaxLevel then
        local conf = conf.MianJuConf:getMianJuFuMo(data.id,data.fmLevel)
        local  num1 = cache.PackCache:getPackDataById(conf.items[1][1]).amount or 0 --背包数
        local  num2 = conf.items[1][2] --消耗数
        if num1 >= num2 then
            self.btn4:GetChild("red").visible = true
        else
            self.btn4:GetChild("red").visible = false
        end
    else
        self.btn4:GetChild("red").visible = false
    end
    
end

function MianJuPanel:btnClick02(context) --点击属性丹响应
    local data = context.sender.data

    if self.btnList2[data.index]:GetChild("n7").visible == true then -- 可升级时点击使用
        self.chengZhangDanId = data.id
        proxy.MianJuProxy:send(1630103,{maskType=  self.index,itemId = data.id})
    else--不可升级点击是tip
        local itemData = {mid = data.id, amount = 1,bind = 0}
        GSeeLocalItem(itemData)
    end
end


function  MianJuPanel:refreshItems()
    self:refreshUpLevRed()
    if self.isLevel then
        self.btn1.icon = UIPackage.GetItemURL("shenqi","juesexinxishuxin_014")
    else
        self.btn1.icon = UIPackage.GetItemURL("shenqi","mianju_011")
    end 
    local islevel = false

    for k,v in pairs(self.btnList3) do
        local itemData = cache.PackCache:getPackDataById(self.confConsume[k][1])
        self.btnList3[k].amount = itemData.amount
        self.btnList3[k].mid = itemData.mid
        itemData.isquan = true
        if itemData.amount < 1 then
            v.obj.grayed = true
        else
            v.obj.grayed = false
            isLevel = true
        end
      
        GSetItemData(v.obj, itemData,false)
    end
    --默认选中材料
    -- print("self.controller2.selectedIndex",self.controller2.selectedIndex)
    self.controller2.selectedIndex = 0
    for k,v in pairs(self.btnList3) do
        if v.amount > 0  then
            self.controller2.selectedIndex = k -1
            break
        end
    end

    local redNum = self:getMianJuUpLevRed(self.index)--升级红点
    local czdRed = self:getMianJuCzdRed(self.index)--成长丹红点
    redNum = redNum + czdRed
    -- print("面具升级红点>>>>>>>>>>>>",redNum,self.index)
    if redNum > 0 then
        self.sumbtn:GetChild("red").visible = true
    else
        self.sumbtn:GetChild("red").visible = false
    end
end

function MianJuPanel:goLevel(context)
    -- for k,v in pairs(self.headData) do
      
    --     if v.id == self.myHeadData.id and not v.hwId then
    --         GComAlter(language.head03)
    --         return
    --     end
    -- end

    -- local confData = conf.RoleConf:getHeadLevel(self.myHeadData.level)
    -- if not confData.need_exp then
    --     GComAlter(language.mianju04)
    --     return
    -- end

    local amount = self.btnList3[self.controller2.selectedIndex+1].amount
    local mid = self.btnList3[self.controller2.selectedIndex+1].mid
    if amount <= 0 then
        GComAlter(language.head02)
        return
    end


    local data = context.sender.data
    -- self.oldLevel = self.myHeadData.level or 0
    if data == 1 then --一键提升
        if not self.isLevel then
             self.btn1.icon = UIPackage.GetItemURL("shenqi","juesexinxishuxin_014")
        else
            self.btn1.icon = UIPackage.GetItemURL("shenqi","mianju_011")
        end 

        if self.isLevel then
            self.isLevel = false
        else
            self.isLevel = true
        end

        local mid = self:getConsumeItemsId()
        if mid and self.isLevel then
            self.upLvType = 1
            -- print("一键提升")
            proxy.MianJuProxy:send(1630102,{maskType = self.index,itemId = mid})
        end
  
    elseif data == 2 then  --提升
        --当前选择的消耗品
        self.isLevel = false
        self.upLvType = 2
              -- print("提升")

        proxy.MianJuProxy:send(1630102,{maskType = self.index,itemId = mid})
    end
    self.oldLevel = self.maskInfos[self.index].level or 0
end

--遍历面具消耗品
function MianJuPanel:getConsumeItemsId()
    if self.btnList3[self.controller2.selectedIndex+1].amount > 0 then
        return self.btnList3[self.controller2.selectedIndex+1].mid
    end
    for k,v in pairs(self.btnList3) do
        if v.amount > 0  then
            self.controller2.selectedIndex = k -1
            return v.mid
        end
    end
end

--面具升级返回
function MianJuPanel:updateMianJuLevel(data)
    self:playEff()
    --更新文本进度条
    self.maskInfos[self.index].level = data.level
    self:updataAllTextandProgress(data)
    self:updateAllList(self.index)
    local mid = self:getConsumeItemsId()
    if data.level > self.oldLevel then
        self.isLevel = false
    end
    self.oldLevel = self.maskInfos[self.index].level

    --更新消耗材料
    self:refreshItems()
    self:refreshoutBtn()

    if mid and self.isLevel then
        proxy.PlayerProxy:send(1630102,{maskType = self.index,itemId = mid})
    else
        self.btn1.icon = UIPackage.GetItemURL("shenqi","mianju_011")
    end
    
    if data.level >= mianjuMaxLevel then --面具升级到顶级
        self.progress.value =10
        self.progress.max =10
        self.progress:GetChild("title").text = "MAX"
        self.btn1.visible = false
        self.btn2.visible = false
        self.upstartImg.visible = true
    end
end


--外部按钮刷新
function MianJuPanel:refreshoutBtn()
      --红点
    local view = mgr.ViewMgr:get(ViewName.ShenQiView)
    if view then
        view:refreshRed()
    end
end


--面具附魔
function MianJuPanel:onFumo(context)
    local data1 = context.sender.data
    local data = cache.MianJuCache:getMianJuChooseData()
    if data1.state == 1 then  --未激活
        local mid = data.mid
        if cache.PackCache:getPackDataById(mid).amount >0 then --有面具道具 可以激活
            --发送激活
            local cachedata = cache.PackCache:getPackDataById(mid)
            local param = {}
            param.index = cachedata.index
            param.amount = 1
            proxy.PackProxy:sendUsePro(param)
        else
            local data = cache.MianJuCache:getMianJuChooseData()
         
            local name = conf.MianJuConf:getMianJuData(data.id).name
            GComAlter(string.format(language.mianju14,name))
        end
        return
    end
     if not data.activation or data.activation == 0 then
        GComAlter(language.mianju07 )
        return
     end
      mgr.ViewMgr:openView2(ViewName.MianJuShengXinAndFuMoView,{selectedIndex = 0})
end

--面具升星
function MianJuPanel:onStart(context)
     local data = cache.MianJuCache:getMianJuChooseData()
     if not data.activation or data.activation == 0 then
        GComAlter(language.mianju06)
        return
     end
     mgr.ViewMgr:openView2(ViewName.MianJuShengXinAndFuMoView,{selectedIndex = 1})
end

--面具幻化
function MianJuPanel:onHuanHua(context)
     local data = cache.MianJuCache:getMianJuChooseData()
     -- if  data.wear == 0 then
        if self.isHuanHua then
            proxy.MianJuProxy:send(1630105,{maskId = data.id ,maskType = self.index,reqType = 1})
        else
            -- print("取消幻化>>>>>")
            proxy.MianJuProxy:send(1630105,{maskId = data.id ,maskType = self.index,reqType = 0})
        end
        -- self.btn3.visible = false

     -- end
    
end

--添加模型
function MianJuPanel:addModel()
    -- print("设置模型",debug.traceback())
    local roleIcon = roleData and roleData.roleIcon or cache.PlayerCache:getRoleIcon()
    local sex = GGetMsgByRoleIcon(roleIcon).sex
    local skins1 = cache.PlayerCache:getSkins(Skins.clothes)--衣服
    -- local skins2 = cache.PlayerCache:getSkins(Skins.wuqi)--武器
    -- local skins3 = cache.PlayerCache:getSkins(Skins.xianyu)--仙羽
    -- local skins5 = cache.PlayerCache:getSkins(Skins.shenbing) --神兵
    -- local skinsHalo = cache.PlayerCache:getSkins(Skins.halo) --光环
    -- local skinHeadWear = cache.PlayerCache:getSkins(Skins.headwear) --头饰
    local skinMianJu = cache.PlayerCache:getSkins(Skins.mianju) --头饰
    if sex == 1 then
        skins1 = 4041401
    elseif sex == 2 then
        skins1 = 4041402
    end

    local modelObj = self.parent:addModel(skins1,self.heroModel)

    self.modelObj = modelObj
    -- modelObj:setSkins(nil,skins2,nil)
    modelObj:setPosition(205 ,-497,118)
    modelObj:setRotationXYZ(352,183,359)

    local mianjuData 
 
    if skinMianJu ~= 0 then
        self.modelObj:removeModelEct()
        mianjuData = conf.MianJuConf:getMianJuData(skinMianJu) 
        self.effect = self.parent:addEffect(mianjuData.effect_id.."", self.effectPanel)
    else
        self.modelObj:removeModelEct()
        local confData = conf.MianJuConf:getMianjuTypeData(self.index)
        mianjuData = conf.MianJuConf:getMianJuData(confData[#confData].id) 
        self.effect = self.parent:addEffect(mianjuData.effect_id.."", self.effectPanel)
    end
    -- print("skinMianJu>>>>>>>>>>>",skinMianJu,self.sumbtn.selected)
    if self.ChoosemianJumData and not self.sumbtn.selected then
        self.modelObj:removeModelEct()
        mianjuData = conf.MianJuConf:getMianJuData(self.ChoosemianJumData.id)
        self.effect = self.parent:addEffect(mianjuData.effect_id, self.effectPanel)
    end

    if mianjuData and mianjuData.id  then
        self.effect.LocalPosition = Vector3(mianjuData.transform[1],mianjuData.transform[2],mianjuData.transform[3])
        self.effect.LocalRotation = Vector3(mianjuData.rotation[1],mianjuData.rotation[2],mianjuData.rotation[3])
        self.effect.Scale = Vector3.New(mianjuData.scale,mianjuData.scale,mianjuData.scale)
    end

end


function MianJuPanel:playEff()
    if self.playing then
        return
    end
     self.playing = true
    local effect,durition =  self.parent:addEffect(4020103,self.node)
    effect.LocalPosition = Vector3(72   ,-12.5,0)--坐标
    effect.Scale = Vector3.New(23,12,70) --
    if not self.attEffTimer then 
        self.attEffTimer = self.parent:addTimer(0.5,1,function()
            -- body
            self.playing = false
            self.parent:removeTimer(self.attEffTimer)
            self.attEffTimer = nil
        end)
    end

end
--请求幻化返回
function MianJuPanel:returnHuanHua()

end

--使用成长丹返回
function MianJuPanel:returnChengZhangDan(data)
    -- print("成长丹返回")
    -- printt(data)
    self.growInfo[self.index] = {}
   --更新成长丹数据
    for k,v in pairs(data.growInfo) do
      table.insert(self.growInfo[self.index],{mid = k,num = v})
    end
    -- printt("更新后成长丹数据",    self.growInfo[self.index])

    self.power[self.index] = data.power
    self.text01.text = data.power
    self:updateShengJiList() 
    self:updateShuXingDan() --刷新属性丹状态
    self:refreshoutBtn()
    local redNum = self:getMianJuUpLevRed(self.index)--升级红点
    local czdRed = self:getMianJuCzdRed(self.index)--成长丹红点
    redNum = redNum + czdRed
    -- print("面具成长丹红点>>>>>>>>>>>>",czdRed,redNum)
    if redNum > 0 then
        self.sumbtn:GetChild("red").visible = true
    else
        self.sumbtn:GetChild("red").visible = false
    end
end

--附魔返回
function MianJuPanel:returnFuMo(data)
    self.ChoosemianJumData = cache.MianJuCache:getMianJuChooseData()
    self:refreshoutBtn()
    for k,v in pairs(self.MianJusubData) do
        if data.maskInfo.id == v.id then
            self.MianJusubData[k].fmLevel = data.maskInfo.fmLevel
            self.MianJusubData[k].elements = data.maskInfo.elements
            self.MianJusubData[k].power = data.maskInfo.power
            break
        end
    end
    self.listview01:RefreshVirtualList()
    local fmRed = self:getMianJuFumoRed(cache.MianJuCache:getMianJuChooseData())
    if fmRed > 0 then
        self.btn4:GetChild("red").visible = true
    else
        self.btn4:GetChild("red").visible = false
    end
    --附魔列表
    local datafm = conf.MianJuConf:getMianJuFuMo(self.ChoosemianJumData.id,self.ChoosemianJumData.fmLevel)
    local data3 = GConfDataSort(datafm) --附魔重数加成的效果
    local itemstartdata = {}
    if self.ChoosemianJumData.fmLevel >= 1 then
        for k=1,3 do
            for i=0,self.ChoosemianJumData.fmLevel-1 do
                local data = conf.MianJuConf:getMianJuFuMoKongWei(self.ChoosemianJumData.id,i,k)
                local data1 = GConfDataSort(data) 
                G_composeData(itemstartdata,data1)
            end
        end
        if self.ChoosemianJumData.elements and #self.ChoosemianJumData.elements ~= 0 then
            for k,v in pairs(self.ChoosemianJumData.elements) do
                if v == datafm.elements[k] then  --若已激活
                    local data = conf.MianJuConf:getMianJuFuMoKongWei(self.ChoosemianJumData.id,self.ChoosemianJumData.fmLevel,k)
                    local data1 = GConfDataSort(data) 
                    G_composeData(itemstartdata,data1)
                end
            end
        end
        G_composeData(data3,itemstartdata)
        self.listview03.numItems = 0
        
        for k,v in pairs(data3) do
            local url = UIPackage.GetItemURL("shenqi" , "Component7")
            baseitem = self.listview03:AddItemFromPool(url)
            baseitem:GetChild("n0").text = conf.RedPointConf:getProName(v[1])
            baseitem:GetChild("n1").text = GProPrecnt(v[1],v[2])
            baseitem:GetChild("n3").visible = false
            baseitem:GetChild("n2").text = ""
           
        end
    else
        local flag = false
        if self.ChoosemianJumData.elements then
            for k,v in pairs(self.ChoosemianJumData.elements) do
                if v == datafm.elements[k] then  --若已激活
                    flag = true
                end
            end
        end
        if self.ChoosemianJumData.fmLevel == 0 and not flag then --0级没有激活
            self.text03.y = 240
            self.text04.y = 240
            self.listview03.y = 268
            local datafm_ = conf.MianJuConf:getMianJuFuMo(self.ChoosemianJumData.id,1) --显示1级属性
            local data3 = GConfDataSort(datafm_)
            if self.ChoosemianJumData.elements and #self.ChoosemianJumData.elements ~= 0 then --判断0重已经激活的孔位
                for k,v in pairs(self.ChoosemianJumData.elements) do
                    if v == datafm_.elements[k] then  --若已激活
                        local data = conf.MianJuConf:getMianJuFuMoKongWei(self.ChoosemianJumData.id,1,k)
                        local data1 = GConfDataSort(data) 
                        G_composeData(data3,data1)
                    end
                end
            end
            self.listview03.numItems = 0
            for k,v in pairs(data3) do
                local url = UIPackage.GetItemURL("shenqi" , "Component7")
                baseitem = self.listview03:AddItemFromPool(url)
                baseitem:GetChild("n0").text = conf.RedPointConf:getProName(v[1])..":"
                baseitem:GetChild("n1").text = GProPrecnt(v[1],v[2])
                baseitem:GetChild("n3").visible = true
                baseitem:GetChild("n2").text = ""
            end
        else
            if self.ChoosemianJumData.elements and #self.ChoosemianJumData.elements ~= 0 then
                for k,v in pairs(self.ChoosemianJumData.elements) do
                    if v == datafm.elements[k] then  --若已激活
                        -- local data = conf.MianJuConf:getMianJuFuMoKongWei(self.ChoosemianJumData.id,self.ChoosemianJumData.fmLevel,k)
                        -- local data = {}
                        for i=0,self.ChoosemianJumData.fmLevel do
                            local data = conf.MianJuConf:getMianJuFuMoKongWei(self.ChoosemianJumData.id,i,k)
                            local data1 = GConfDataSort(data) 
                            G_composeData(itemstartdata,data1)
                        end
                     end
                 end
            end
            G_composeData(data3,itemstartdata)
            self.listview03.numItems = 0
            
            for k,v in pairs(data3) do
                local url = UIPackage.GetItemURL("shenqi" , "Component7")
                baseitem = self.listview03:AddItemFromPool(url)
                baseitem:GetChild("n0").text = conf.RedPointConf:getProName(v[1])
                baseitem:GetChild("n1").text = GProPrecnt(v[1],v[2])
                baseitem:GetChild("n3").visible = false
                baseitem:GetChild("n2").text = ""
               
            end
        end
    end
    self.text03.text = self.ChoosemianJumData.fmLevel >= fuMoMaxLevel and fuMoMaxLevel or self.ChoosemianJumData.fmLevel
     if (tonumber(self.text03.text)) == 0 then
        self.text03.text = "零重"
    else
        self.text03.text = self:numberToString(tonumber(self.text03.text) or 0).."重"
    end
 
end


-- return_t = { [1] = {102,100000},[2] = {103,100000} }

--道具属性乘以数量计算
function MianJuPanel:calData(data,num)
    local data1 = {}
    for k,v in pairs(data) do
        local num = v[2]*num
        data1[k] = {v[1],num}
    end
    return data1
end

--升到顶级处理
function  MianJuPanel:detailUpLevel()
    -- print(self.maskInfos[self.index].level,mianjuMaxLevel)
    if self.maskInfos[self.index].level >= mianjuMaxLevel then --到达顶级
        self.upstartImg.visible = true
        self.btn1.visible = false
        self.btn2.visible = false
    else
        self.upstartImg.visible = false
        self.btn1.visible = true
        self.btn2.visible = true
    end

    
end

--计算小类战力

function MianJuPanel:calpower(data)
    local score = 0
     local itemdata = conf.MianJuConf:getMianjuIdData(data.id)
    local data1  = GConfDataSort(itemdata) -- 面具小类本身属性

    for k,v in pairs(data1) do
     
         score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])
    end

    --附魔列表
    local datafm = conf.MianJuConf:getMianJuFuMo(data.id,data.fmLevel)
    local data3 = GConfDataSort(datafm) --附魔重数加成的效果
    local itemstartdata = {}
    if data.elements and #data.elements ~= 0 then

         for k,v in pairs(data.elements) do
             if v == datafm.elements[k] then  --若已激活
          
                local data_ = conf.MianJuConf:getMianJuFuMoKongWei(data.id,data.fmLevel,k)
                local data1 = GConfDataSort(data_) 
                G_composeData(itemstartdata,data1)
             end
         end
    end
    G_composeData(data3,itemstartdata)
    for k,v in pairs(data3) do
        score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])
    end
    -- print("加了多少")
    return score
end 




--面具激活返回
function MianJuPanel:jiHuoMianJu(data)
    local  mid = data.items.mid
    self.isJiHuoFanHui = true
    proxy.MianJuProxy:send(1630101)
    -- print("激活面具返回>>>>>>>>>")
    -- local id = self.index + 7
    -- self.chooseBeforePanel:GetChild("n"..id).onClick:Call()
    --更新数据
    --更新当前选择面具的数据
    -- local choosemianjudata = cache.MianJuCache:getMianJuChooseData()
    -- choosemianjudata.activation = 1
    -- choosemianjudata.starNum = 0
    -- choosemianjudata.wear = 0
    -- choosemianjudata.elements = {}
    -- choosemianjudata.fmLevel = 0
    -- choosemianjudata.power = conf.getMianjuIdData(mid).power
    -- cache.MianJuCache:setMianJuChooseData(choosemianjudata)
    -- --
    -- -- self.btn3.visible = true
    -- -- self.btn5.visible = true
    --  for k,v in pairs(self.maskSunInfos[self.index]) do
    --     subData[v.id] = v 
    -- end
    -- self:updataPanel(self.index)

end

--按钮选择状态重置
function MianJuPanel:setBtnSelect()
    for k,v in pairs(self.btnList1) do
        v.objbtn.selected = false
    end
end

function MianJuPanel:onReturn(context)
    self.c1.selectedIndex = 0    
    proxy.MianJuProxy:sendMsg(1630101)
end

--战力广播返回
function MianJuPanel:RefreshPower()
     if self.sumbtn:GetController("button").selectedIndex == 1 then --当前选的是大类
         self.text01.text = self.power[self.index]
    else
        local currentchoosebtn = cache.MianJuCache:getMianJuChooseData()
        self.text01.text = currentchoosebtn.power
    end

end

--升星红点刷新
function MianJuPanel:returnStartRedPoint()
    local starRed = self:calStartRedPoint(cache.MianJuCache:getMianJuChooseData())
    if starRed > 0 then
        self.btn5:GetChild("red").visible = true
    else
         self.btn5:GetChild("red").visible = false
    end
end

--激活红点
function MianJuPanel:jihuoRedPoint()
    local jihuoRed = self:caljihuoRedPoint(cache.MianJuCache:getMianJuChooseData())
    if jihuoRed > 0 then
        self.btn4:GetChild("red").visible = true
    else
        self.btn4:GetChild("red").visible = false
    end
end

-- --幻化按钮改变
-- function MianJuPanel:huanhuabtn()
--     local data = cache.MianJuCache:getMianJuChooseData()
--     if data.activation == 0 then
--         self.btn3.visible = false
--     else
--         self.btn3.visible = true
--     end
--     if data.wear == 1 then -- 已穿
--         self.btn3.icon =  UIPackage.GetItemURL("shenqi" , "mianju_039")  --取消幻化
--     else
--         self.btn3.icon =  UIPackage.GetItemURL("shenqi" , "mianju_012") --幻化
--     end
-- end
function MianJuPanel:onClickRule()
    GOpenRuleView(1168)
end



function  MianJuPanel:numberToString(szNum)
    ---阿拉伯数字转中文大写
    local szChMoney = ""
    local iLen = 0
    local iNum = 0
    local iAddZero = 0
    local hzUnit = {"", "十", "百", "千", "万", "十", "百", "千", "亿","十", "百", "千", "万", "十", "百", "千"}
    local hzNum = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"}
    if nil == tonumber(szNum) then
        return tostring(szNum)
    end
    iLen =string.len(szNum)
    if iLen > 10 or iLen == 0 or tonumber(szNum) < 0 then
        return tostring(szNum)
    end
    for i = 1, iLen  do
        iNum = string.sub(szNum,i,i)
        if iNum == 0 and i ~= iLen then
            iAddZero = iAddZero + 1
        else
            if iAddZero > 0 then
            szChMoney = szChMoney..hzNum[1]
        end
            szChMoney = szChMoney..hzNum[iNum + 1] --//转换为相应的数字
            iAddZero = 0
        end
        if (iAddZero < 4) and (0 == (iLen - i) % 4 or 0 ~= tonumber(iNum)) then
            szChMoney = szChMoney..hzUnit[iLen-i+1]
        end
    end
    local function removeZero(num)
        --去掉末尾多余的 零
        num = tostring(num)
        local szLen = string.len(num)
        local zero_num = 0
        for i = szLen, 1, -3 do
            szNum = string.sub(num,i-2,i)
            if szNum == hzNum[1] then
                zero_num = zero_num + 1
            else
                break
            end
        end
        num = string.sub(num, 1,szLen - zero_num * 3)
        szNum = string.sub(num, 1,6)
        --- 开头的 "一十" 转成 "十" , 贴近人的读法
        if szNum == hzNum[2]..hzUnit[2] then
            num = string.sub(num, 4, string.len(num))
        end
        return num
    end
    return removeZero(szChMoney)
end

return MianJuPanel