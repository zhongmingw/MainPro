--
-- Author: Your Name
-- Date: 2018-08-02 11:17:18
--光环
local AureolePanel = class("AureolePanel",import("game.base.Ref"))

local color1 = 4--字体颜色
local color2 = 8

function AureolePanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function AureolePanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n24")
    self.panelObj = panelObj
    self.checkBtn = panelObj:GetChild("n20")
    self.checkBtn.onChanged:Add(self.selelctCheck,self)
    self.listView = panelObj:GetChild("n18")
    -- self.listView:SetVirtual()
    self.listView.numItems = 0
    self.heroPanel = panelObj:GetChild("n1")--模型触摸区域
    self.heroModel = panelObj:GetChild("n2")--放置模型区域

    self.selectName = panelObj:GetChild("n43")

    self.alearyImg = panelObj:GetChild("n12")--未获得
    self.alearyImg.visible = false
    local titleBtn = panelObj:GetChild("n19")--佩戴按钮
    self.titleBtn = titleBtn
    titleBtn.onClick:Add(self.onClickWear,self)
    self.titleBtnUrl = titleBtn:GetChild("icon")

    self.attiTitle = panelObj:GetChild("n15")--属性标题
    self.timeText = panelObj:GetChild("n39")
    self.daojishiDec = panelObj:GetChild("n40")
    --属性区域
    self.powerText = panelObj:GetChild("n22")

    self.attiList = panelObj:GetChild("n86")
    self.attiList.numItems = 0
    --升星属性
    self.starSuitImg = panelObj:GetChild("n44")
    self.starAttrList = {}
    for i=34,36 do
        local lab = panelObj:GetChild("n"..i)
        lab.text = ""
        table.insert(self.starAttrList, lab)
    end
    self.starBtn = panelObj:GetChild("n38")
    self.starBtn.onClick:Add(self.onClickStar,self)
    --光环获取途径文本
    self.halofromviewTxt = panelObj:GetChild("n31")
     --头饰获取途径文本
    self.headfromviewTxt = panelObj:GetChild("n60")
    --等级文本
    self.levelTxt = panelObj:GetChild("n63")
    --进度条
    self.progressbar = panelObj:GetChild("n67")
    --新加头饰系统

    self.controller = panelObj:GetController("c1")
    self.controller.onChanged:Add(self.onController1,self)
    self.controller2 = panelObj:GetController("c2")
    self.controller2.onChanged:Add(self.onController2,self)
    self.btn1 = panelObj:GetChild("n61")
    self.btn1.data = 1
    self.btn1.onClick:Add(self.goLevel,self)
    self.btn2 = panelObj:GetChild("n62")
    self.btn2.data = 2
    self.btn2.onClick:Add(self.goLevel,self)

    --消耗品
    self.confConsume = conf.RoleConf:getHeadValue("hw_item_exp")
    self.btnList = {}
    for i =70,72 do
        local item = panelObj:GetChild("n"..i)
        table.insert(self.btnList,{obj = item,amount = 1 ,mid = 1,id = i})
        item.data = i - 70
        item.onClick:Add(self.onClickTouchItem,self)
    end

    self.headattList = {}
    self.isLevel = false
    self.node = self.panelObj:GetChild("n82")

    --满级
    self.maxLevelImg = panelObj:GetChild("n83")
    self.maxLevelImg.visible = false
    --头饰按钮
    local toushiBtn = panelObj:GetChild("n52")
    self.toushiRed = toushiBtn:GetChild("n4")
end

function AureolePanel:onController1()
        -- if self.actTimer then
        --     print("切换时移除定时器~~~~~~~~~~~~~~~~")
        --     self.mParent:removeTimer(self.actTimer)
        --     self.actTimer = nil
        -- end
    if  self.attEffTimer then
         print("切换时移除特效定时器~~~~~~~~~~~~~~~~")
        self.mParent:removeTimer(self.attEffTimer)
        self.attEffTimer = nil
    end
    
    if self.controller.selectedIndex == 0 then
        proxy.PlayerProxy:send(1570101)--请求光环列表
    elseif self.controller.selectedIndex == 1 then
        self.isLevel = false
        if self.isLevel then
            self.btn1.icon = UIPackage.GetItemURL("juese","juesexinxishuxin_014")
        else
            self.btn1.icon = UIPackage.GetItemURL("juese","toushi_007")
        end 
        proxy.PlayerProxy:send(1570201)--请求头饰列表
    end
end

function AureolePanel:refreshTopRed()
    local toushiBtn = self.panelObj:GetChild("n52")
    self.toushiRed = toushiBtn:GetChild("n4")
    local var = cache.PlayerCache:getRedPointById(attConst.A10266)
    if var > 0 then
        self.toushiRed.visible = true
    else
        self.toushiRed.visible = false
    end
end

function AureolePanel:onController2()
    self.isLevel = false
    -- if self.actTimer then
        self.btn1.icon = UIPackage.GetItemURL("juese","toushi_007")
    --     self.mParent:removeTimer(self.actTimer)
    --     self.actTimer = nil
    -- end
end

--更新光环列表
function AureolePanel:setAureoListView()
    local num = 0 
    self.listView:RemoveEventListeners()
    self.listView:RemoveChildren()
    self.listView.numItems = 0
    for k,v in pairs(self.haloTypes) do
        num = num + 1
        local url = UIPackage.GetItemURL("juese" , "FashionTitleItem")
        local obj = self.listView:AddItemFromPool(url)
        self:cellTitleData1(v,obj)
        if v.open == 1 then
            self.num = num
            local items = self.haloData
            if self.checkBtn.selected then
                items = self:getauloSelectItem()
            end
            if self.grandson then
                local index = 0
                for k,data in pairs(items) do
                    if math.floor(data.id/1000) == v.id then
                        index = index + 1
                        if self.grandson == data.id then
                            self.chooseHaloTitlekey = index--选中的光环
                            break
                        end
                    end
                end
            else
                self.chooseHaloTitlekey = 1
            end
            local i = 0
            for k,data in pairs(items) do
                if math.floor(data.id/1000) == v.id then
                    i = i + 1
                    num = num + 1
                    local url = UIPackage.GetItemURL("juese" , "HaloItem")
                    local obj = self.listView:AddItemFromPool(url)
                    self:cellTitleHaloData(data,obj,i)
                end
            end
        end
    end
    if self.num then
        self.listView:ScrollToView(self.num - 1)
        self.num = nil
    end
    self.childIndex,self.grandson,self.chooseHaloTitlekey = nil,nil,nil
end
--更新头饰列表
function AureolePanel:setHeadListView()
    local num = 0
    self.listView:RemoveEventListeners()
    self.listView:RemoveChildren()
    self.listView.numItems = 0
    for k,v in pairs(self.headTypes) do
        num = num + 1
        local url = UIPackage.GetItemURL("juese" , "FashionTitleItem")
        local obj = self.listView:AddItemFromPool(url)
        self:cellTitleData1(v,obj)
        if v.open == 1 then
            self.num = num
            local items = self.headData
            if self.checkBtn.selected then
                items = self:getheadSelectItem()
            end
            if self.grandson then
                local index = 0
                for k,data in pairs(items) do
                    if math.floor(data.id) == v.id then
                            index = index + 1
                        if self.grandson == data.id then
                            self.chooseHeadTitlekey = index--选中的头饰
                            break
                        end
                    end
                end
            else
                self.chooseHeadTitlekey = 1
            end
            local i = 0
            for k,data in pairs(items) do
                i = i + 1
                num = num + 1
                local url = UIPackage.GetItemURL("juese" , "HaloItem")
                local obj = self.listView:AddItemFromPool(url)
                self:cellTitleHeadData(data,obj,i)    
            end
        end
    end
    if self.num then
        self.listView:ScrollToView(self.num - 1)
        self.num = nil
    end
    self.childIndex,self.grandson,self.chooseHeadTitlekey = nil,nil,nil
end
--父元素
function AureolePanel:cellTitleData1(data,cell)
    local titleName = cell:GetChild("title")
    titleName.text = data.name
    local ctrl = cell:GetController("button")
    ctrl.selectedIndex = data.open
    cell.touchable = false
end

--光环子元素--
function AureolePanel:cellTitleHaloData(data,cell,i)
    local name = cell:GetChild("n8")
    name.text = data.name
    local wearImg = cell:GetChild("n6")
    if data.wear == 1 then
        wearImg.visible = true
    else
        wearImg.visible = false
    end
    local timeImg = cell:GetChild("n5")
    if data.effectType and data.effectType > 0 then
        timeImg.visible = true
    else
        timeImg.visible = false
    end
    local ungetImg = cell:GetChild("n7")
    if data.haloId then
        cell.grayed = false
    else
        cell.grayed = true
    end
    cell.data = data
    cell.onClick:Add(self.onClickHaloItem,self)
    local index = self.chooseHaloTitlekey or 1
    if i == index then
        cell.selected = true
        local context = {sender = cell}
        self:onClickHaloItem(context)
    end
end

--头饰子元素
function AureolePanel:cellTitleHeadData(data,cell,i)
    local name = cell:GetChild("n8")
    name.text = data.name
    local wearImg = cell:GetChild("n6")
    if data.wear == 1 then
        wearImg.visible = true
    else
        wearImg.visible = false
    end
    local timeImg = cell:GetChild("n5")
    timeImg.visible = false
    
    local redImg = cell:GetChild("n9")
    redImg.visible = false
   
    local ungetImg = cell:GetChild("n7")
    if data.hwId then
        cell.grayed = false
        -- local var = cache.PlayerCache:getRedPointById(attConst.A10266)
        -- local level = data.level or 0
        -- local levelConf = conf.RoleConf:getHeadLevel(level)
        -- if var > 0 and levelConf.need_exp then
        --     redImg.visible = true
        -- end
    else
        cell.grayed = true
    end
    
    data.index = i
    cell.data = data
    -- print("i = ",i)
    cell.onClick:Add(self.onClickHeadItem,self)
    local index = self.chooseHeadTitlekey or 1
    if i == index then
        cell.selected = true
        local context = {sender = cell}
        self:onClickHeadItem(context)
    end
end

function AureolePanel:onClickHaloItem(context)
    local sender = context.sender
    local data = sender.data
    self.chooseAutoData = data
    self.myHaloData = data

    self.selectName.text = data.name
    -- self.lookCtrl.selectedIndex = 0
    self.isHaveAulo = not sender.grayed
    -- print("光环id>>>>>>>>>>>>>>>",self.chooseAutoData.id)
    local confData = conf.RoleConf:getHaloData(self.chooseAutoData.id)--升星
    local starPre = confData and confData.star_pre or 0
    -- print("选中时装星级>>>>>>>>>>>>>",starPre,self.chooseAutoData.id,self.timeText.text)
    self:updateHalo(data,true)
    if starPre > 0 and self.timeText.text == mgr.TextMgr:getTextColorStr(language.halo02,color1) then
        -- self.starBtn.visible = true
        self.starSuitImg.visible = false
        if self.chooseAutoData.haloId then
            self.isHaveAulo = true
        else
            self.isHaveAulo = false
        end
    else
        -- self.starBtn.visible = false
        -- self.starSuitImg.visible = true
        self.isHaveAulo = false
    end
    self.confHaloStartData = confData
    self:addModel()
end

function AureolePanel:onClickHeadItem(context)
    local sender = context.sender
    local data = sender.data
    self.chooseHeadData = data
    self.myHeadData = data
    -- print("当前选择的头饰>>>>>>",self.chooseHeadData)
    if self.isLevel then
        -- print("升級過程中點擊停止")
        self.isLevel = false
        self.btn1.icon = UIPackage.GetItemURL("juese","toushi_007")
    end

    local var = cache.PlayerCache:getRedPointById(attConst.A10266)
    local level = data.level or 0
    local levelConf = conf.RoleConf:getHeadLevel(level)
    if var > 0 and levelConf.need_exp then
        self.btn1:GetChild("red").visible = true
        self.btn2:GetChild("red").visible = true
    else
        self.btn1:GetChild("red").visible = false
        self.btn2:GetChild("red").visible = false
    end

    self.selectName.text = data.name
    -- self.lookCtrl.selectedIndex = 0
    self.isHaveHead = not sender.grayed
    local confData = conf.RoleConf:getHeadData(self.chooseHeadData.id)--升星
    local starPre = confData and confData.star_pre or 0
    -- print("选中时装星级>>>>>>>>>>>>>",starPre,self.chooseAutoData.id,self.timeText.text)
    self:updateHead(data,true)
    if starPre > 0  then
        -- self.starBtn.visible = true
        self.starSuitImg.visible = false
        if  self.chooseHeadData.hwId then
            self.isHaveHead = true
        else
            self.isHaveHead = false
        end
    else
        -- self.starBtn.visible = false
        -- self.starSuitImg.visible = true
        self.isHaveHead = false
    end
    self.confHeadStartData = confData
    self:addModel()
    self:updateLevelAndPro(self.headData[data.index])
end

-- 1   int32   变量名: haloId 说明: 光环id
-- 2   int32   变量名: starNum    说明: 星数
-- 3   int8    变量名: effectType 说明: 有效类型 0:永久 1:限时
-- 4   int8    变量名: wear   说明: 是否佩戴 1:已佩戴
-- 5   int32   变量名: beginTime  说明: 获取时间
-- 6   int32   变量名: endTime    说明: 失效时间(限时)
function AureolePanel:setData(data)  --光环主更新
    self.data1570101 = data
    self.checkBtn.selected = self.selectedBtn1 
    --光环列表处理
    self.timeText.text = ""
    self.haloTypes = conf.RoleConf:getHaloType() --光环总类数
    self.haloData = conf.RoleConf:getAllHalo(data) --所有光环
    if data then
        -- printt("光环列表>>>>>>>>>>>",data)
        for k,halo in pairs(self.haloData) do
            for _,v in pairs(data.haloInfos) do
                if halo.id == v.haloId then
                    self.haloData[k].haloId = v.haloId
                    self.haloData[k].effectType = v.effectType
                    self.haloData[k].wear = v.wear
                    self.haloData[k].endTime = v.endTime
                    self.haloData[k].starNum = v.starNum
                    break
                end
            end
        end
        self:HaloDataSort()
        self:addModel()
       
        self:setAureoListView()
    else
        if self.isAllHalo then
            self:setHaloAttData()
        else
            self:updateHalo(self.myHaloData,nil,true)
        end
    end
end
-- 1   int32   变量名: hwId   说明: 头饰id
-- 2   int32   变量名: starNum    说明: 星数
-- 3   int32   变量名: level  说明: 等级
-- 4   int32   变量名: exp    说明: 经验
-- 5   int8    变量名: wear   说明: 是否佩戴 1:佩戴
function AureolePanel:setHeadWearData(data) --头饰主更新
    printt("头饰列表返回数据",data)
    self.data1570201 = data
    self.checkBtn.selected = self.selectedBtn2
    --头饰列表处理
    self.headTypes = conf.RoleConf:getHeadType() --头饰总类型
    self.headData = conf.RoleConf:getAllHead() --所有头饰
    self:refreshItems()
    if data then
         for _,v in pairs(data.hwInfos) do
            for k,head in pairs(self.headData) do
                if head.id == v.hwId then
                    self.headData[k].hwId = v.hwId
                    self.headData[k].exp = v.exp
                    self.headData[k].wear = v.wear
                    self.headData[k].level = v.level or 0
                    self.headData[k].starNum = v.starNum
                    break
                end
            end
        end

        self:HeadDataSort()
        self:addModel()
        self:setHeadListView()
        for k,v in pairs(data.hwInfos) do
            if v.hwId == self.myHeadData.hwId then
                -- print("shifouxiang",v.hwId,self.myHeadData.hwId,v.level)
                self:updateLevelAndPro(v)  
            end
        end
    else
        self:updateHead(self.myHeadData,nil,true)
    end
end


function AureolePanel:HaloDataSort()
    --光环
    table.sort(self.haloData, function(a,b)
        local aw = a.wear or 0
        local bw = b.wear or 0
        if aw ~= bw then
            return aw > bw
        else
            return a.id < b.id
        end
    end)
end

function AureolePanel:HeadDataSort()
     --头饰
    table.sort(self.headData, function(a,b)
        local aw = a.wear or 0
        local bw = b.wear or 0
        if aw ~= bw then
            return aw > bw
        else
            return a.id < b.id
        end
    end)
end

--添加模型
function AureolePanel:addModel()
    local roleIcon = roleData and roleData.roleIcon or cache.PlayerCache:getRoleIcon()
    local sex = GGetMsgByRoleIcon(roleIcon).sex
    local skins1 = cache.PlayerCache:getSkins(Skins.clothes)--衣服
    local skins2 = cache.PlayerCache:getSkins(Skins.wuqi)--武器
    local skins3 = cache.PlayerCache:getSkins(Skins.xianyu)--仙羽
    local skins5 = cache.PlayerCache:getSkins(Skins.shenbing) --神兵
    local skinsHalo = cache.PlayerCache:getSkins(Skins.halo) --光环
    local skinHeadWear = cache.PlayerCache:getSkins(Skins.headwear) --头饰

    local modelObj = self.mParent:addModel(skins1,self.heroModel)
    self.modelObj = modelObj
    self.cansee = modelObj:setSkins(nil,skins2,skins3)
    self.modelObj:removeModelEct()
    if skinsHalo ~= 0 and self.controller.selectedIndex == 0 then
        local haloData = conf.RoleConf:getHaloData(skinsHalo)
        local modelEct = modelObj:addModelEct(haloData.effect_id .. "_ui")
        modelEct.Scale =  Vector3.New(0.35,0.35,0.35)
    end
    -- print("头饰id",skinHeadWear,"光环id",skinsHalo)
    if skinHeadWear ~= 0 and  skinHeadWear and self.controller.selectedIndex == 1 then 
        local headData = conf.RoleConf:getHeadData(skinHeadWear) 
        local modelEct = modelObj:addHeadEct(headData.effect_id)
        -- local modelEct = modelObj:addModelEct(headData.effect_id .. "_ui")
        -- modelEct.Scale =  Vector3.New(0.35,0.35,0.35)
    end

    if self.chooseAutoData and self.controller.selectedIndex == 0 then
        self.modelObj:removeModelEct()
        -- print("self.chooseAutoData",self.chooseAutoData.effect_id)
        local modelEct = modelObj:addModelEct(self.chooseAutoData.effect_id .. "_ui")
        modelEct.Scale =  Vector3.New(0.35,0.35,0.35)
    end
    if self.chooseHeadData and self.controller.selectedIndex == 1 then
        self.modelObj:removeModelEct()
        -- print("self.chooseAutoData",self.chooseAutoData.effect_id)
        local modelEct = modelObj:addHeadEct(self.chooseHeadData.effect_id)
        -- modelEct.Scale =  Vector3.New(0.35,0.35,0.35)
    end

    self.modelObj = modelObj
    modelObj:setPosition(self.heroModel.actualWidth/2,-self.heroModel.actualHeight-200,500)
    modelObj:setRotation(RoleSexModel[sex].angle)
    local effect = self.mParent:addEffect(4020102,self.panelObj:GetChild("n0"))
    effect.LocalPosition = Vector3(self.heroModel.actualWidth/2,-self.heroModel.actualHeight,500)
    if skins5 > 0 and skins2>0 then
        modelObj:addWeaponEct(skins5.."_ui")
    end
    self.modelObj:modelTouchRotate(self.heroPanel,sex)
    self.panelObj:GetChild("n40").visible = self.cansee
end



--当前已有的光环
function AureolePanel:getauloSelectItem()
    local data = {}
    for k,v in pairs(self.haloData) do
        if v.haloId then
            table.insert(data, v)
        end
    end
    return data
end
--当前已有的头饰
function AureolePanel:getheadSelectItem()
    local data = {}
    for k,v in pairs(self.headData) do
        if v.hwId then
            table.insert(data, v)
        end
    end
    return data
end
function AureolePanel:setForviewIndex(childIndex,grandson)
    self.childIndex,self.grandson = childIndex,grandson
end



--光环加成属性
function AureolePanel:setHaloAttData()
    self.titleBtn.visible = false
    local items = self:getauloSelectItem()
    -- self.attiTitle.url = UIItemRes.fashionTitle01[1]
    local attiData = {}
    local curPower = 0
    if #items > 0 then
        self:cleanAtti()
    else
        attiData = GAllAttiData()
        local t = attiData
        self.attiList.itemRenderer = function (index,obj)
            local data = t[index+1]
            if data then
                local str = self.controller.selectedIndex == 1 and mgr.TextMgr:getQualityStr1( "+",7) or ""
                obj:GetChild("n0").text = conf.RedPointConf:getProName(data[1]).." "..GProPrecnt(data[1],data[2])..str
                obj:GetChild("n1").text = ""
            end
        end
        self.attiList.numItems = #t
        -- for k,v in pairs(attiData) do
        --     local str = self.controller.selectedIndex == 1 and mgr.TextMgr:getQualityStr1( "+",7) or ""
        --     self.attiList[k].text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],v[2])..str
        -- end
    end
    for _,atti in pairs(items) do
        for k,v in pairs(atti) do
            if string.find(k,"att_") then
                if not attiData[k] then
                    attiData[k] = 0
                end
                attiData[k] = attiData[k] + v
            elseif k == "power" then
                curPower = curPower + v
            end
        end
    end
    self.powerText.text = curPower
    local t = GConfDataSort(attiData)
    self.attiList.itemRenderer = function (index,obj)
        local data = t[index+1]
        if data then
            obj:GetChild("n0").text = conf.RedPointConf:getProName(data[1]).." "..GProPrecnt(data[1],data[2]) 
            obj:GetChild("n1").text = ""
        end
    end
    self.attiList.numItems = #t

end

--光环升星属性
function AureolePanel:updataHaloSuitStarsAttr(data)
    -- print("升星属性刷新",data.id)
    if data.id then
        for k , v in pairs(self.starAttrList) do
            v.text = ""
        end
        local confData = conf.RoleConf:getHaloData(data.id)

        local suitStarPre = confData and confData.star_pre or 0
        local suitStars = cache.PlayerCache:getSkinStarLv(suitStarPre)
        if confData.star_pre then
            --升星属性
            self.starSuitImg.visible = false
            local suitStarConf = conf.RoleConf:getSkinsStarAttrData(data.id,1013)
            for k,v in pairs(suitStarConf) do
                local str = string.format(language.fashion14,v.need_star) .. string.format(language.fashion15_1,language.gonggong94[1013],(v.attr_show/100))
                if suitStars >= v.need_star then
                    self.starAttrList[k].text = mgr.TextMgr:getTextColorStr(str,7)
                else
                    self.starAttrList[k].text = mgr.TextMgr:getTextColorStr(str,8)
                end
            end
        else
            self.starSuitImg.visible = true
        end
        if suitStars > 0 then
            local starId = suitStarPre*1000+suitStars
            local fsData = conf.RoleConf:getFashionStarAttr(starId) or {}
            -- self.powerText.text = confData.power + fsData.power
            local t = GConfDataSort(confData)
            local t2 = GConfDataSort(fsData)
            self:composeData(t,t2)
            self.attiList.itemRenderer = function (index,obj)
                local data = t[index+1]
                if data then
                    obj:GetChild("n0").text = conf.RedPointConf:getProName(data[1]).." "..GProPrecnt(data[1],data[2]) 
                    obj:GetChild("n1").text = ""
                end
            end
            self.attiList.numItems = #t
            -- for k,v in pairs(t) do
            --     self.attiList[k].text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],v[2]) 
            -- end
        else
            local t = GConfDataSort(confData)
            self.attiList.itemRenderer = function (index,obj)
                local data = t[index+1]
                if data then
                    obj:GetChild("n0").text = conf.RedPointConf:getProName(data[1]).." "..GProPrecnt(data[1],data[2]) 
                    obj:GetChild("n1").text = ""
                end
            end
            self.attiList.numItems = #t
            -- for k,v in pairs(t) do
            --     self.attiList[k].text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],v[2]) 
            -- end
        end
    end
end

--头饰升星属性
function AureolePanel:updataHeadSuitStarsAttr(data)
    printt(data,"升星属性刷新")
    if data.id then
        for k , v in pairs(self.starAttrList) do
            v.text = ""
        end
    
        local confData = conf.RoleConf:getHeadData(data.id)
        local suitStarPre = confData and confData.star_pre or 0
        local suitStars = cache.PlayerCache:getSkinStarLv(suitStarPre)

        local t = GConfDataSort(confData)
        -- print("当前等级>>>>>>>>>>>>>>",self.chooseHeadData.level)
        local levelData =conf.RoleConf:getHeadLevel(self.chooseHeadData.level or 0)
        if suitStars > 0 then
            -- print("星数",suitStars)
            local starId = suitStarPre*1000+suitStars
            local fsData = conf.RoleConf:getFashionStarAttr(starId) or {}
            local t2 = GConfDataSort(fsData)
            self:composeData(t,t2)
        end
        local score = 0

        self.attiList.itemRenderer = function (index,obj)
            local data = t[index+1]
            if data then
                if levelData then
                    local addAttr = 0
                    for key,var in pairs(levelData) do
                        if string.find(key,"att_") then --这个是属性
                            local pro = string.split(key, "_")
                            if tonumber(pro[2]) == data[1] then
                                addAttr = var 
                                score = score + mgr.ItemMgr:baseAttScore(pro[2],var)
                                break
                            end
                        end
                    end
                    obj:GetChild("n0").text = conf.RedPointConf:getProName(data[1]).." "..GProPrecnt(data[1],data[2])
                    if addAttr > 0 then
                        obj:GetChild("n1").text = "+" .. addAttr
                    else
                        obj:GetChild("n1").text = ""
                    end
                else
                    obj:GetChild("n0").text = conf.RedPointConf:getProName(data[1]).." "..GProPrecnt(data[1],data[2])
                    obj:GetChild("n1").text = ""
                end
            end
        end
        self.attiList.numItems = #t
        self.powerText.text =  self.myHeadData.power + score        
    end
end

function AureolePanel:composeData(data,param)
    for k ,v in pairs(param) do
        local falg = false
        for i , j in pairs(data) do
            if j[1] == v[1] then
                data[i][2] = j[2] + v[2]
                falg = true 
            end
        end
        if not falg then
            table.insert(data,v)
        end
    end
end

--穿戴称号返回 isPreview:是否是预览
function AureolePanel:updateHaloData(data)
    -- printt("穿戴称号返回>>>>>>>>>>>>",data)
    for k,v in pairs(self.haloData) do
        if v.haloId == data.haloId then
            if data.reqType == 2 then
                self.haloData[k].wear = 0
            else
                self.haloData[k].wear = 1
            end
            self.myHaloData = self.haloData[k]
        else
            self.haloData[k].wear = 0
        end
    end
    if data.reqType == 2 then
        GComAlter(language.gonggong25)
    else
        GComAlter(language.gonggong26)
    end
    self:HaloDataSort()
    self:addModel()
    self:updateHalo(self.myHaloData,nil,true)
    self:setAureoListView()
end

--预览光环属性
function AureolePanel:updateHalo(data,isPreview,isType)
    if not isPreview then
        self.myHaloData = data
    end
    if data then
        if data.wear and data.wear == 1 then
            self.titleBtnUrl.url = UIItemRes.fashionTitle02[1]
            -- self.attiTitle.url = UIItemRes.fashionTitle01[1]
        else
            -- self.attiTitle.url = UIItemRes.fashionTitle01[3]
            self.titleBtnUrl.url = UIItemRes.fashionTitle02[2]
        end
        self:cleanAtti()
        self.powerText.text = data.power
        self:updateTimer(data)--倒计时
        self.halofromviewTxt.text = data.fromview[1]
        if data.haloId then
            self.alearyImg.visible = false
            self.titleBtn.visible = true
        else
            self.alearyImg.visible = true
            self.titleBtn.visible = false
            self.timeText.text = ""
        end
        self:updataHaloSuitStarsAttr(data)
    else
        self.timeText.text = mgr.TextMgr:getTextColorStr(language.halo08,color2)
    end
end

--预览头饰属性
function AureolePanel:updateHead(data,isPreview,isType)
    if not isPreview then
        self.myHeadData = data
    end
    if data then
        if data.wear and data.wear == 1 then
            self.titleBtnUrl.url = UIItemRes.fashionTitle02[1]
            -- self.attiTitle.url = UIItemRes.fashionTitle01[1]
        else
            -- self.attiTitle.url = UIItemRes.fashionTitle01[3]
            self.titleBtnUrl.url = UIItemRes.fashionTitle02[2]
        end
        self:cleanAtti()
        -- self.powerText.text = data.power

        self.headfromviewTxt.text = data.fromview[1]
        if data.hwId then
            self.alearyImg.visible = false
            self.titleBtn.visible = true
        else
            self.alearyImg.visible = true
            self.titleBtn.visible = false
            self.timeText.text = ""
        end
        -- self.attheadData = data
        self:updataHeadSuitStarsAttr(data)
    end
end
function AureolePanel:cleanAtti()
    self.attiList.numItems = 0
end

--倒计时
function AureolePanel:updateTimer(data)
        -- print("倒计时>>>>>>>>>>>>",data.endTime,data.effectType)
    if data.effectType and data.effectType == 1 then--倒计时
        if data.endTime > 0 then
            local serverTime = mgr.NetMgr:getServerTime()
            self.time = data.endTime - serverTime
            self.daojishiDec.visible = true
            if self.timer then
                self.mParent:removeTimer(self.timer)
            end
            self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
        else
            self:releaseTimer()
            local day = data.limit_value / 86400
            local str = string.format(language.fashion04, day)
            self.timeText.text = mgr.TextMgr:getTextColorStr(str,color1)
            self.daojishiDec.visible = true
        end
    else 
        self:releaseTimer()
        self.timeText.text = mgr.TextMgr:getTextColorStr(language.halo02,color1)
        self.daojishiDec.visible = false
    end
end

function AureolePanel:releaseTimer()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function AureolePanel:onTimer()
    if self.time <= 0 then
        self:releaseTimer()
        self.timeText.text = mgr.TextMgr:getTextColorStr(language.halo03,color2)
        self.daojishiDec.visible = false
        return
    end
    self.time = self.time - 1
    self.daojishiDec.visible = true
    self.timeText.text = mgr.TextMgr:getTextColorStr(GGetTimeData2(self.time)..language.fashion01, color1)
end

function AureolePanel:selelctCheck()
    if self.controller.selectedIndex == 0 then
        self.selectedBtn1 = self.checkBtn.selected 
        self:setAureoListView()
    elseif self.controller.selectedIndex == 1 then
        self.selectedBtn2 = self.checkBtn.selected 
        self:setHeadListView()
    end

end

--佩戴光环 or 头饰
function AureolePanel:onClickWear()
    if self.controller.selectedIndex == 0 then
        if self.chooseAutoData then
            if self.chooseAutoData.haloId then
                local reqType = 1
                if self.chooseAutoData.wear == 1 then--已经戴上的就卸下
                    reqType = 2
                else
                    reqType = 1
                end
                proxy.PlayerProxy:send(1570102,{haloId = self.chooseAutoData.haloId,reqType = reqType})
            else
                GComAlter(language.title05)
            end
        else
            if self.myHaloData and self.myHaloData.wear == 1 then
                proxy.PlayerProxy:send(1570102,{haloId = self.myHaloData.haloId,reqType = 2})
            else
                GComAlter(language.title07)
            end
        end
    elseif self.controller.selectedIndex == 1 then
        if self.chooseHeadData then
            if self.chooseHeadData.hwId then
                local reqType = 1
                if self.chooseHeadData.wear == 1 then--已经戴上的就卸下
                    reqType = 2
                else
                    reqType = 1
                end
                proxy.PlayerProxy:send(1570203,{hwId = self.chooseHeadData.hwId,reqType = reqType})
            else
                GComAlter(language.title05)
            end
        else
            if self.myHeadData and self.myHeadData.wear == 1 then
                proxy.PlayerProxy:send(1570203,{hwId = self.myHeadData.hwId,reqType = 2})
            else
                GComAlter(language.title07)
            end
        end
    end
end

--升星按钮
function AureolePanel:onClickStar()
    if self.controller.selectedIndex == 0 then --光环
        print("光环升星>>>>>>>>>>",self.confHaloStartData)
        if not self.confHaloStartData then return end
        if self.myHaloData and self.myHaloData.effectType and self.myHaloData.effectType > 0 then--时效性
            GComAlter(language.halo10)
            return
        end
        if not self.isHaveAulo then
            GComAlter(language.halo09)
            return
        end
        mgr.ViewMgr:openView2(ViewName.FashionStarView, self.myHaloData)
    elseif self.controller.selectedIndex == 1 then --头饰
        if not self.confHeadStartData then return end
        if not self.isHaveHead then
            GComAlter(language.head01)
            return
        end
        mgr.ViewMgr:openView2(ViewName.FashionStarView, self.myHeadData)
    end
end

--头饰穿戴返回
function AureolePanel:updateHeadWearData(data)
    for k,v in pairs(self.headData) do
        if v.hwId == data.hwId then
            if data.reqType == 2 then
                self.headData[k].wear = 0
            else
                self.headData[k].wear = 1
            end
            self.myHeadData = self.headData[k]
        else
            self.headData[k].wear = 0
        end
    end
    if data.reqType == 2 then
        GComAlter(language.gonggong25)
    else
        GComAlter(language.gonggong26)
    end
    self:HeadDataSort()
    self:addModel()
    self:updateHead(self.myHeadData,nil,true)
    self:setHeadListView()
end

--头饰升级返回
function AureolePanel:updateHeadWearLevelData( data )
    printt("头饰升级返回",data,self.isLevel)
    if not self.isLevel and self.upLvType and self.upLvType == 1 then
        return
    end
    --更新选中的数据属性myHeadData
    self.myHeadData.level = data.level
    self.myHeadData.exp = data.exp
    if data.level > self.oldLevel then
        self.isLevel = false
        self:updateHead(self.myHeadData,nil,true)
    end
    self.oldLevel = data.level

    local var = cache.PlayerCache:getRedPointById(attConst.A10266)
    local level = data.level or 0
    local levelConf = conf.RoleConf:getHeadLevel(level)
    if var > 0 then
        self.toushiRed.visible = true
    else
        self.toushiRed.visible = false
    end
    if var > 0 and levelConf.need_exp then
        self.btn1:GetChild("red").visible = true
        self.btn2:GetChild("red").visible = true
    else
        self.btn1:GetChild("red").visible = false
        self.btn2:GetChild("red").visible = false
    end

    self:refreshItems()
    self:updateLevelAndPro(data)
    -- printt("当前头饰数据myHeadData",self.myHeadData)
    -- self:setHaloAttData() -- 加成总属性
    self:playEff()
    local mid = self:getConsumeItemsId()
    if mid and self.isLevel then
        proxy.PlayerProxy:send(1570202,{hwId = self.myHeadData.hwId,itemId = mid})
    else
        self.btn1.icon = UIPackage.GetItemURL("juese","toushi_007")
    end
end

--更新进度条和等级
function AureolePanel:updateLevelAndPro(data)
    self.levelTxt.text = data.level or 0
    -- self.progressbar.max = conf.RoleConf:getHeadLevel(data.hwId or 1001 ,data.level == 0 and 1 or data.level).need_exp  
    
    local levelConf = conf.RoleConf:getHeadLevel(self.chooseHeadData.level or 0)
    -- print("当前level>>>>>>>>>>",data.level,levelConf.need_exp)
    if levelConf.need_exp then
        self.progressbar.max = conf.RoleConf:getHeadLevel(data.level or 0).need_exp
        self.progressbar.value = data.exp or 0
        self.progressbar:GetChild("title").text = self.progressbar.value .. "/" .. self.progressbar.max
        self.btn1.visible = true
        self.btn2.visible = true
        self.maxLevelImg.visible = false
    else
        self.progressbar.max = 100
        self.progressbar.value = 100
        self.progressbar:GetChild("title").text = language.skill08
        self.btn1.visible = false
        self.btn2.visible = false
        self.maxLevelImg.visible = true
    end
end

function AureolePanel:goLevel(context)
    for k,v in pairs(self.headData) do
        -- print(v.id,self.myHeadData.id,v.hwId)
        if v.id == self.myHeadData.id and not v.hwId then
            GComAlter(language.head03)
            return
        end
    end

    local confData = conf.RoleConf:getHeadLevel(self.myHeadData.level)
    if not confData.need_exp then
        GComAlter(language.head04)
        return
    end

    local amount = self.btnList[self.controller2.selectedIndex+1].amount
    local mid = self.btnList[self.controller2.selectedIndex+1].mid
    if amount <= 0 then
        GComAlter(language.head02)
        return
    end

    local data = context.sender.data

    self.oldLevel = self.myHeadData.level or 0
    if data == 1 then --一键提升

        if not self.isLevel then
            self.btn1.icon = UIPackage.GetItemURL("juese","juesexinxishuxin_014")
        else
            self.btn1.icon = UIPackage.GetItemURL("juese","toushi_007")
        end 

        if self.isLevel then
            self.isLevel = false
        else
            self.isLevel = true
        end
        local mid = self:getConsumeItemsId()
        if mid and self.isLevel then
            self.upLvType = 1
            proxy.PlayerProxy:send(1570202,{hwId = self.myHeadData.hwId,itemId = mid})
        end
        
    elseif data == 2 then  --提升
        --当前选择的消耗品
        self.isLevel = false
        self.upLvType = 2
        proxy.PlayerProxy:send(1570202,{hwId = self.myHeadData.hwId,itemId = mid})
    end
end

--遍历头饰消耗品
function AureolePanel:getConsumeItemsId()
    if self.btnList[self.controller2.selectedIndex+1].amount > 0 then
        return self.btnList[self.controller2.selectedIndex+1].mid
    end
    for k,v in pairs(self.btnList) do
        if v.amount > 0  then
            self.controller2.selectedIndex = k -1
            return v.mid
        end
    end
end

function  AureolePanel:refreshItems()
    for k,v in pairs(self.btnList) do
        local itemData = cache.PackCache:getPackDataById(self.confConsume[k][1])
        self.btnList[k].amount = itemData.amount
        self.btnList[k].mid = itemData.mid
        itemData.isquan = true
        if itemData.amount < 1 then
            v.obj.grayed = true
        else
            v.obj.grayed = false
        end
        GSetItemData(v.obj:GetChild("n4"), itemData,false)
    end
end

function AureolePanel:onClickTouchItem(context)
    local obj = context.sender
    local index = obj.data
    self.controller2.selectedIndex = index
    local itemData = cache.PackCache:getPackDataById(self.confConsume[index+1][1])
    itemData.index = 0
    GSeeLocalItem(itemData)
end

function AureolePanel:playEff()
    if self.playing then
        return
    end
     self.playing = true
    local effect,durition =  self.mParent:addEffect(4020103,self.node)
    effect.LocalPosition = Vector3(self.node.actualWidth/2,-self.node.actualHeight/2,0)--坐标
    effect.Scale = Vector3.New(65,68,70) --
    if not self.attEffTimer then 
        self.attEffTimer = self.mParent:addTimer(0.5,1,function()
            -- body
            self.playing = false
            self.mParent:removeTimer(self.attEffTimer)
            self.attEffTimer = nil
        end)
    end

end

return AureolePanel