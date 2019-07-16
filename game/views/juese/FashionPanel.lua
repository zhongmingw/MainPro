--
-- Author: ohf
-- Date: 2017-03-06 14:31:43
--
--时装区域
local FashionPanel = class("FashionPanel",import("game.base.Ref"))

local color1 = 7--字体颜色
local color2 = 8

function FashionPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function FashionPanel:initPanel()
    self.isFirst = true
    self.fashionTypes = conf.RoleConf:getFashType()
    local panelObj = self.mParent.view:GetChild("n17")
    self.panelObj = panelObj
    self.listView = panelObj:GetChild("n2")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    -- self.listView:SetVirtual()
    self.nameFash = panelObj:GetChild("n16")--称号
    self.heroPanel = panelObj:GetChild("n28")--模型触摸区域
    self.heroModel = panelObj:GetChild("n29")--放置模型区域
    self.powerText = panelObj:GetChild("n18")--战斗力

    self.checkXianyu = panelObj:GetChild("n7")
    self.checkXianyu.selected = true
    self.checkXianyu.onChanged:Add(self.onCheckXianyu,self)

    self.alearyImg = panelObj:GetChild("n8")--未获得标志
    self.alearyImg.visible = false

    self.attiList = {}--属性
    for i=1,6 do
        local atti = panelObj:GetChild("n2"..i)
        atti.text = ""
        table.insert(self.attiList, atti)
    end
    local checkBtn = panelObj:GetChild("n20")
    self.checkController = checkBtn:GetController("button")
    self.checkController.onChanged:Add(self.selelctCheck,self)

    self.fashLookBtn = panelObj:GetChild("n34")--时装总览
    self.fashLookBtn.onClick:Add(self.onClickAllFash,self)
    self.lookCtrl = self.fashLookBtn:GetController("button")
    self.collectBtn = panelObj:GetChild("n48")--时装收藏
    self.collectBtn.onClick:Add(self.onClickCollect,self)

    local wearBtn = panelObj:GetChild("n33")
    wearBtn.onClick:Add(self.onClickWear,self)
    self.wearBtn = wearBtn
    self.wearBtnUrl = wearBtn:GetChild("icon")
    self.attiTitle = panelObj:GetChild("n14")--属性标题
    self.timeText = panelObj:GetChild("n37")
    self.daojishiDec = panelObj:GetChild("n41")
    self.formView = {}--获取途径
    for i=30,32 do
        local text = panelObj:GetChild("n"..i)
        table.insert(self.formView, text)
    end
    --升星套装属性
    self.starSuitImg = panelObj:GetChild("n42")
    self.starAttrList = {}
    for i=44,46 do
        local text = panelObj:GetChild("n"..i)
        table.insert(self.starAttrList, text)
    end
    self.suitDecTxt = panelObj:GetChild("n47")

    self.starBtn = panelObj:GetChild("n40")
    self.starBtn.onClick:Add(self.onClickStar,self)

    --时装藏品
    self.collectList = panelObj:GetChild("n57")
    self.collectList.numItems = 0
    self.collectList.itemRenderer = function (index,obj)
        self:collectCelldata(index, obj)
    end
    self.collectList.onClickItem:Add(self.onCollectionItem,self)
    --藏品套装列表
    self.ItemList = panelObj:GetChild("n58")
    self.ItemList.numItems = 0
    self.ItemList.itemRenderer = function (index,obj)
        self:collectItem(index, obj)
    end
    --藏品属性加成
    self.collectAttrList = panelObj:GetChild("n61")
    self.collectAttrList.numItems = 0
    --藏品模型展示
    self.collectionModel = panelObj:GetChild("n62")

    self.c1 = panelObj:GetController("c1")
end

--子页签，孙子页签
function FashionPanel:setForviewIndex(childIndex,grandson)
    -- print("跳转>>>>>>>>>>>>",childIndex,grandson)
    self.c1.selectedIndex = 0
    self.childIndex,self.grandson = childIndex,grandson

end
--1 
function FashionPanel:setData(data)
    self.confFashion = conf.RoleConf:getAllFash()
    self.skinsShenbing = cache.PlayerCache:getSkins(Skins.shenbing) --神兵
    local mData1 = nil--衣服
    local mData2 = nil--武器
    if data then
        for k1,v1 in pairs(self.confFashion) do
            self.confFashion[k1]["fashionId"] = nil
            self.confFashion[k1]["gotTime"] = nil
            self.confFashion[k1]["isWear"] = nil
            self.confFashion[k1]["endTime"] = 0
            for k2,v2 in pairs(data.fashionInfos) do
                if v1.id == v2.fashionId then
                    self.confFashion[k1]["fashionId"] = v2.fashionId
                    self.confFashion[k1]["gotTime"] = v2.gotTime
                    self.confFashion[k1]["isWear"] = v2.isWear
                    self.confFashion[k1]["endTime"] = v2.endTime
                    if v2.isWear == 1 then
                        if v2.type == 1 then
                            mData1 = self.confFashion[k1]
                        else
                            mData2 = self.confFashion[k1]
                        end
                    end
                end
            end
        end
        self:addModel()
        self:dataSort()
        if self.childIndex then
            self:setListViewData()
        else
            self:updateFashion(mData1,mData2)
            self:onClickAllFash()
        end
    else
        if self.isAllFash then
            self:setAttiData()
        else
            self:setFashAtti(self.mData1,self.mData2)
        end
    end
end
--数据排序
function FashionPanel:dataSort()
    table.sort(self.confFashion, function(a,b)
        local aw = a.isWear or 0
        local bw = b.isWear or 0
        if a.type == b.type then
            if aw ~= bw then
                return aw > bw
            else
                return a.fashion_type < b.fashion_type
            end
        else
            return a.type < b.type
        end
    end)
end
--请求时装佩戴（服务器返回）
function FashionPanel:updateFashData(data)
    local mData1 = nil--衣服
    local mData2 = nil--武器
    local model = nil--记录模型（主要用于卸下）
    for k,v in pairs(self.confFashion) do
        if data.fashionId == v.fashionId then
            self.childIndex = v.type
            self.grandson = data.fashionId
            if v.type == 1 then
                if data.type == 2 then
                    self.confFashion[k]["isWear"] = 0
                    model = cache.PlayerCache:getSkins(1)--衣服
                    self.skins1 = model
                else
                    self.skins1 = v.model
                    self.confFashion[k]["isWear"] = 1
                end
                mData1 = self.confFashion[k]
            else
                if data.type == 2 then
                    self.confFashion[k]["isWear"] = 0
                    model = cache.PlayerCache:getSkins(2)--武器
                    self.skins2 = model
                else
                    self.skins2 = v.model
                    self.confFashion[k]["isWear"] = 1
                end
                mData2 = self.confFashion[k]
            end 
        else
            if data.fashionId == 0 then--一键卸下（目前没用到）
                self.confFashion[k]["isWear"] = 0
            else
                if data.fashoinType == v.type then--同类型的
                    if v.isWear and v.isWear == 1 then
                        self.confFashion[k]["isWear"] = 0
                    end
                else
                    if v.isWear and v.isWear ~= 1 then
                        self.confFashion[k]["isWear"] = 0
                    end
                end
            end
        end
    end
    if data.type == 2 then--穿戴飘字
        GComAlter(language.gonggong25)
    else
        GComAlter(language.gonggong26)
    end
    self:dataSort()
    self:setListViewData(model)
    self:updateFashion(mData1,mData2,model)
end

function FashionPanel:setOpenZero()
    -- print("self.childIndex,self.grandson>>>>>>>>>>>>>>>",self.childIndex,self.grandson)
    -- printt("self.listdata>>>>>>>>>>>",self.listdata)
    local index = 0
    local suitData = {}
    for k,v in pairs(self.listdata) do
        for _,data in pairs(v) do
            -- print("id>>>>>>>>>>>>>>>",data.id)
            if tonumber(self.grandson) == tonumber(data.id) or tonumber(self.grandson) == tonumber(data.reset_sex_id) then
                index = k-1
                suitData = data
                break
            end
        end
    end
    self.listView:ScrollToView(index)

    local cell = self.listView:GetChildAt(index)
    if cell then
        self:setSuit(suitData)
        local c1 = cell:GetController("c1")
        c1.selectedIndex = self.childIndex
    end
    
end

function FashionPanel:setListViewData(model)
    local num = 0
    self.listView.numItems = 0
    self.listdata = {}
    local typeData = conf.RoleConf:getFashShowType()
    for _,_type in pairs(typeData) do
        local cellData = {}
        for k,v in pairs(self.confFashion) do
            if tonumber(v.fashion_type) == tonumber(_type) then
                table.insert(cellData,v)
            end
        end
        table.insert(self.listdata,cellData)
    end
    -- printt("时装列表>>>>>>>>>>>",self.listdata)
    table.sort(self.listdata,function(a,b)
        local a_type = a[1].fashion_type
        local b_type = b[1].fashion_type
        if a_type ~= b_type then
            return a_type < b_type
        end
    end)
    self.listView.numItems = #typeData--#self.listdata
    if self.num then
        self.listView:ScrollToView(self.num - 1)
        self.num = nil
    end
    if self.childIndex then
        self:setOpenZero()
    end
    self.childIndex,self.grandson,self.chooseFashkey = nil,nil,nil
end

function FashionPanel:celldata(index,obj)
    local data = self.listdata[index+1]
    if data then
        local c1 = obj:GetController("c1")
        c1.selectedIndex = 0
        local nameTxt = obj:GetChild("n0")
        obj:GetChild("n3").visible = false
        obj:GetChild("n4").visible = false
        for k,v in pairs(data) do
            nameTxt.text = v.type_name
            local item = obj:GetChild("n"..(2+k))
            item.visible = true
            local icon = item:GetChild("icon")
            icon.url = UIPackage.GetItemURL("_icons" , ""..v.scr)
            local wearImg = item:GetChild("n1")
            if v.isWear == 1 then
                wearImg.visible = true
            else
                wearImg.visible = false
            end
            local timeImg = item:GetChild("n4")
            if v.time > 0 and v.gotTime then
                timeImg.visible = true
            else
                timeImg.visible = false
            end
            if v.fashionId then
                item.grayed = false
            else
                item.grayed = true
            end
            item.data = v
            item.onClick:Add(self.onClickFashItem,self)
        end
    end
end

--预览时装
function FashionPanel:updateFashion(data1,data2,model)
    self.skins1 = cache.PlayerCache:getSkins(Skins.clothes)--衣服
    self.skins2 = cache.PlayerCache:getSkins(Skins.wuqi)--武器
    self.skins3 = cache.PlayerCache:getSkins(Skins.xianyu)--仙羽
    self.mData1 = clone(data1) or self.mData1--当前的衣服
    self.mData2 = clone(data2) or self.mData2--当前的武器
    self.nameFash.text = ""
    if data1 then--衣服時裝
        if data1.isWear and data1.isWear == 1 then
            self.wearBtnUrl.url = UIItemRes.fashionTitle02[1]
            self.attiTitle.url = UIItemRes.fashionTitle01[1]
        else
            if model then
                self.chooseData = nil--清空數據
                self.mData1 = nil
            end
            self.attiTitle.url = UIItemRes.fashionTitle01[2]
            self.wearBtnUrl.url = UIItemRes.fashionTitle02[2]
        end
        if not model then--有模型返回说明是卸下了
            self.nameFash.text = data1.name
        else
            self.nameFash.text = self.mData2 and self.mData2.name or language.fashion06
        end
        local model2 = self.skins2--武器不变
        local model1 = model or data1.model
        -- if self.checkXianyu.selected then
        --     self.modelObj:setSkins(model1,model2,self.skins3)
        -- else
            self.modelObj:setSkins(model1,model2,0)
        -- end
    else
        self.nameFash.text = self.mData1 and self.mData1.name or language.fashion06
    end
    if data2 then--武器時裝
        if data2.isWear and data2.isWear == 1 then
            self.wearBtnUrl.url = UIItemRes.fashionTitle02[1]
            self.attiTitle.url = UIItemRes.fashionTitle01[1]
        else
            if model then
                self.mData2 = nil--清空數據
                self.chooseData = nil
            end
            self.attiTitle.url = UIItemRes.fashionTitle01[2]
            self.wearBtnUrl.url = UIItemRes.fashionTitle02[2]
        end
        if not data1 and not model then--有模型返回说明是卸下了
            self.nameFash.text = data2.name
        else
            self.nameFash.text = self.mData1 and self.mData1.name or language.fashion06
        end
        local model2 = model or data2.model
        local model1 = self.skins1--衣服不变
        if self.mData1 then
            self.mData1.model = self.skins1
        end
        -- if self.checkXianyu.selected then
        --     self.modelObj:setSkins(model1,model2,self.skins3)
        -- else
            self.modelObj:setSkins(model1,model2,0)
        -- end
    else
        if not data1 then
            self.nameFash.text = self.mData2 and self.mData2.name or language.fashion06
        end
    end
    -- if self.skinsShenbing > 0 and (self.mData2 and self.mData2.model > 0 or self.skins2 > 0) then
    --     self.modelObj:addWeaponEct(self.skinsShenbing.."_ui")
    -- end
    self.modelObj:removeModelEct()
    self:setFashAtti(data1,data2)
end
--预览属性
function FashionPanel:setFashAtti(data1,data2)
    local attiData = {}
    local power = 0
    local at = {data1,data2}
    for _,atti in pairs(at) do
        for k,v in pairs(atti) do
            if string.find(k,"att_") then
                if not attiData[k] then
                    attiData[k] = 0
                end
                attiData[k] = attiData[k] + v
            elseif k == "power" then
                power = power + v
            end
        end
    end
    self.powerText.text = power
    if data1 or data2 then
        self:cleanAtti()
    else
        self.timeText.text = mgr.TextMgr:getTextColorStr(language.fashion06,color2)
        self.daojishiDec.visible = false
    end

    local t = GConfDataSort(attiData)
    local id = self.chooseData and self.chooseData.id or 0
    local confData = conf.RoleConf:getFashData(id)--升星
    local starPre = confData and confData.star_pre or 0
    local starId = starPre * 1000 + cache.PlayerCache:getSkinStarLv(starPre)
    local fsData = conf.RoleConf:getFashionStarAttr(starId) or {}
    local t2 = GConfDataSort(fsData)
    self:composeData(t,t2)
    for k,v in pairs(t) do
        self.attiList[k].text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],v[2]) -- v[2] --EVE 使用百分比显示
    end
    self:cleanFromview()
    self:cleanSuitStarAttr()
    if data1 then
        self:updateEffect(data1)
        self:updateSuitStarsAttr(data1)
    elseif data2 then
        self:updateEffect(data2)
        self:updateSuitStarsAttr(data2)
    end
end

function FashionPanel:cleanFromview()
    for k,v in pairs(self.formView) do
        if k == 1 then
            self.formView[k].text = language.fashion08
        else
            self.formView[k].text = ""
        end
    end
end
--获取途径
function FashionPanel:updateEffect(data)
    if data.fashionId then
        self.timeText.visible = true
        -- self.alearyImg.visible = false
        self.wearBtn.visible = true
    else
        self.timeText.visible = false
        -- self.alearyImg.visible = true
        self.wearBtn.visible = false
    end
    for k,text in pairs(data.fromview) do
        self.formView[k].text = text
    end
    self:updateTimer(data)
end
function FashionPanel:cleanSuitStarAttr()
    for k,v in pairs(self.starAttrList) do
        self.starAttrList[k].text = ""
    end
    self.suitDecTxt.text = language.fashion08
end
--升星套装属性加成
function FashionPanel:updateSuitStarsAttr(data)
    -- print("debug.traceback",debug.traceback())
    if data.id then
        local suitStarConf = conf.RoleConf:getSkinsStarAttrData(data.id,1011)
        if #suitStarConf > 0 then
        -- printt("升星套装属性>>>>>>>",suitStarConf)
            local starPre = data.star_pre or 0
            local stars = cache.PlayerCache:getSkinStarLv(starPre)
            local skinName1 = conf.RoleConf:getFashData(data.id).name
            local skinName2 = ""
            -- print("当前时装星级",stars)
            local suitId = 0
            for k,v in pairs(suitStarConf) do
                for _,skinId in pairs(v.skins) do
                    if skinId ~= data.id then
                        suitId = skinId
                        break
                    end
                end
                local str = language.fashion14_1 .. string.format(language.fashion14,v.need_star) .. string.format(language.fashion15,(v.attr_show/100))
                
                local suitData = conf.RoleConf:getFashData(suitId)--配套时装
                local suitStarPre = suitData and suitData.star_pre or 0
                local suitStars = cache.PlayerCache:getSkinStarLv(suitStarPre)
                skinName2 = suitData.name
                if stars >= v.need_star and suitStars >= v.need_star then
                    self.starAttrList[k].text = mgr.TextMgr:getTextColorStr(str,7)
                else
                    self.starAttrList[k].text = mgr.TextMgr:getTextColorStr(str,8)
                end
            end
            local color1 = 11
            local color2 = 11
            for k,v in pairs(self.confFashion) do
                if v.fashionId and v.fashionId == data.id then
                    color1 = 7
                elseif v.fashionId and v.fashionId == suitId then
                    color2 = 7
                end
            end
            local textData = clone(language.fashion16)

            textData[2].text = string.format(language.fashion16[2].text,skinName1)
            textData[2].color = color1
            textData[3].text = string.format(language.fashion16[3].text,skinName2)
            textData[3].color = color2

            self.suitDecTxt.text = mgr.TextMgr:getTextByTable(textData)
        end
    end

end
--倒计时
function FashionPanel:updateTimer(data)
    if data.time > 0 or data.con_type == 3 then--倒计时
        if data.endTime > 0 then
            local serverTime = mgr.NetMgr:getServerTime()
            self.time = data.endTime - serverTime
            self:onTimer()
            if not self.timer then
                self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
            end
        else
            self:releaseTimer()
            local day = data.time / 86400
            if data.con_type == 3 then
                self.timeText.text = mgr.TextMgr:getTextColorStr(language.fashion02,color2)
                self.daojishiDec.visible = false
            else
                local str = string.format(language.fashion04, day)
                self.timeText.text = mgr.TextMgr:getTextColorStr(str,color2)
                self.daojishiDec.visible = true
            end
        end
    else 
        self:releaseTimer()
        self.timeText.text = mgr.TextMgr:getTextColorStr(language.fashion02,color2)
        self.daojishiDec.visible = false
    end
end

function FashionPanel:releaseTimer()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function FashionPanel:onTimer()
    if self.time <= 0 then
        self:releaseTimer()
        self.timeText.text = mgr.TextMgr:getTextColorStr(language.fashion03,color2)
        self.daojishiDec.visible = false
        return
    end
    self.time = self.time - 1
    self.daojishiDec.visible = true
    self.timeText.text = mgr.TextMgr:getTextColorStr(GGetTimeData2(self.time)..language.fashion01, color1)
end
--添加模型
function FashionPanel:addModel()
    local roleIcon = roleData and roleData.roleIcon or cache.PlayerCache:getRoleIcon()
    self.sex = GGetMsgByRoleIcon(roleIcon).sex
    self.skins1 = cache.PlayerCache:getSkins(Skins.clothes)--衣服
    self.skins2 = cache.PlayerCache:getSkins(Skins.wuqi)--武器
    self.skins3 = cache.PlayerCache:getSkins(Skins.xianyu)--仙羽
    local modelObj = self.mParent:addModel(self.skins1,self.heroModel)
    self.cansee = modelObj:setSkins(nil,self.skins2,0)
    self.modelObj = modelObj
    self.modelObj:removeModelEct()
    modelObj:setPosition(self.heroModel.actualWidth/2,-self.heroModel.actualHeight-200,500)
    modelObj:setRotation(RoleSexModel[self.sex].angle)
    --脚底特效
    local effect = self.mParent:addEffect(4020102,self.panelObj:GetChild("n38"))
    effect.LocalPosition = Vector3(self.heroModel.actualWidth/2,-self.heroModel.actualHeight,500)
    self.modelObj:modelTouchRotate(self.heroPanel,self.sex)
    self.panelObj:GetChild("n39").visible = self.cansee
end
--加成总属性
function FashionPanel:setAttiData()
    self:cleanFromview()
    self.wearBtn.visible = false
    local items = self:getSelectItem()
    self.attiTitle.url = UIItemRes.fashionTitle01[1]
    local attiData = {}
    local starAttiData = {}
    local curPower = 0
    if #items > 0 then
        self:cleanAtti()
    else
        local attiData = GAllAttiData()
        for k,v in pairs(attiData) do
            self.attiList[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
        end
    end
    for _,atti in pairs(items) do
        local confData = conf.RoleConf:getFashData(atti.fashionId)--升星
        local starPre = confData and confData.star_pre or 0
        local starId = starPre * 1000 + cache.PlayerCache:getSkinStarLv(starPre)
        local fsData = conf.RoleConf:getFashionStarAttr(starId) or {}
        for k,v in pairs(fsData) do
            if string.find(k,"att_") then
                if not starAttiData[k] then
                    starAttiData[k] = 0
                end
                starAttiData[k] = starAttiData[k] + v
            elseif k == "power" then
                curPower = curPower + v
            end
        end
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
    local t2 = GConfDataSort(starAttiData)
    self:composeData(t,t2)
    for k,v in pairs(t) do
        self.attiList[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
    end 
    -- if self.skinsShenbing > 0 and self.skins2 > 0 then
    --     self.modelObj:addWeaponEct(self.skinsShenbing.."_ui")
    -- end
end

function FashionPanel:composeData(data,param)
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

function FashionPanel:setSuit(data)
    self.chooseData = data--
    self.lookCtrl.selectedIndex = 0
    -- printt("选中的时装>>>>>>>>>>>",data)
    if data.type == 1 then
        self:updateFashion(data,nil)
    else
        self:updateFashion(nil,data)
    end
    local confData = conf.RoleConf:getFashData(self.chooseData.id)--升星
    local starPre = confData and confData.star_pre or 0
    -- print("选中时装星级>>>>>>>>>>>>>",starPre,self.chooseData.id)
    if starPre > 0 and self.timeText.text == mgr.TextMgr:getTextColorStr(language.fashion02,color2) then
        self.starBtn.visible = true
        self.starSuitImg.visible = false
        if self.chooseData.fashionId then
            self.isHave = true
        else
            self.isHave = false
        end
    else
        self.starBtn.visible = false
        self.starSuitImg.visible = true
        for k,v in pairs(self.starAttrList) do
            self.starAttrList[k].text = ""
        end
        self.suitDecTxt.text = ""
        self.isHave = false
    end
    self.confStarData = confData
end

--选择时装
function FashionPanel:onClickFashItem(context)
    self.wearBtn.visible = true
    self.isAllFash = false
    local sender = context.sender
    local data = sender.data
    self.isHave = not sender.grayed

    self:setSuit(data)

    local typeData = conf.RoleConf:getFashShowType()
    for i=1,#typeData do
        local cell = self.listView:GetChildAt(i - 1)
        local c1 = cell:GetController("c1")
        c1.selectedIndex = 0
    end
    sender.selected = true
end
--清空属性
function FashionPanel:cleanAtti()
    for k,v in pairs(self.attiList) do
        self.attiList[k].text = ""
    end
end
--返回已拥有的称号
function FashionPanel:getSelectItem()
   local data = {}
    for k,v in pairs(self.confFashion) do
        if v.fashionId then
            table.insert(data, v)
        end
    end
    return data
end
--穿脱时装
function FashionPanel:onClickWear()
    if self.chooseData then
        local fashionId = self.chooseData.fashionId
        if fashionId then
            local reqType = 1
            if self.chooseData.isWear == 1 then--已经穿上的就脱
                reqType = 2
            else--已经脱了的就穿
                reqType = 1
            end
            proxy.PlayerProxy:send(1270105,{fashionId = self.chooseData.fashionId,reqType = reqType})
        else
            GComAlter(language.fashion05)
        end 
    else
        GComAlter(language.fashion07)
    end
end
--时装总览
function FashionPanel:onClickAllFash()
    self.isAllFash = true
    self.fashLookBtn.selected = true
    self.starBtn.visible = false
    self.starSuitImg.visible = false
    self.suitDecTxt.text = language.fashion08
    self:cleanSuitStarAttr()
    self.timeText.text = ""
    self.lookCtrl.selectedIndex = 1
    self.nameFash.text = language.fashion21
    self.chooseData = nil
    self:setListViewData()
    self:setAttiData()
end
--时装收藏
function FashionPanel:onClickCollect()
    proxy.PlayerProxy:send(1270301,{reqType = 0})
end
--
function FashionPanel:selelctCheck()
    local selectedIndex = self.checkController.selectedIndex
    if selectedIndex == 1 or selectedIndex == 3 then
        self.isSelect = true--仅显示已拥有选项
    else
        self.isSelect = false
    end
    self:setListViewData()
end
--是否显示仙羽
function FashionPanel:onCheckXianyu()
    local model1 = self.mData1 and self.mData1.model or self.skins1--衣服不变
    local model2 = self.mData2 and self.mData2.model or self.skins2--武器不变
    -- if self.checkXianyu.selected then
    --     self.modelObj:setSkins(model1,model2,self.skins3)
    -- else
        self.modelObj:setSkins(model1,model2,0)
    -- end
end

--时装藏品信息
function FashionPanel:setCollectionInfo(data)
    printt("时装藏品信息>>>>>>>>>>>",data)
    local sex = cache.PlayerCache:getSex()
    self.collectData = conf.RoleConf:getCollectionInfo()
    for k,v in pairs(self.collectData) do
        self.collectData[k].isAct = false--是否激活
        for _,v1 in pairs(data.activeSuitData) do--激活信息
            if self.collectData[k].id == v1 then
                self.collectData[k].isAct = true
                break
            end
        end
        local collectData = {}--已收集皮肤信息
        for _,v2 in pairs(data.skinInfos) do
            if v2.suitId == self.collectData[k].id then
                collectData = v2.collectData
            end
        end
        -- printt("collectData>>>>>>>>>>>>>>>>>",collectData)
        local collect_id = v.collect_id
        if sex == 2 then collect_id = v.collect_id_g end
        local count = 0--当前获取皮肤个数
        local max = 0--最大皮肤个数
        for num,v3 in pairs(collect_id) do
            max = max + 1
            self.collectData[k].collect_id[num][3] = false--当前皮肤是否获取(男)
            self.collectData[k].collect_id_g[num][3] = false--当前皮肤是否获取(女)
            for _,v4 in pairs(collectData) do
                if v3[1] == v4.type and v3[2] == v4.value then
                    count = count + 1
                    self.collectData[k].collect_id[num][3] = true
                    if sex == 2 then
                        self.collectData[k].collect_id_g[num][3] = true
                    end
                    break
                end
            end
        end
        self.collectData[k].count = count
        self.collectData[k].max = max
    end
    table.sort(self.collectData,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    self.collectList.numItems = #self.collectData
    if #self.collectData > 0 then
        local cell = self.collectList:GetChildAt(0)
        cell.onClick:Call()
    end
end

--时装收藏列表
function FashionPanel:collectCelldata(index,obj)
    local data = self.collectData[index+1]
    if data then
        local nameTxt = obj:GetChild("n2")
        local bar = obj:GetChild("n3")
        local actImg = obj:GetChild("n4")
        local redImg = obj:GetChild("n5")
        redImg.visible = false
        actImg.visible = false
        bar.value = data.count
        bar.max = data.max
        nameTxt.text = data.name
        if data.isAct then
            actImg.visible = true
        elseif data.count == data.max then
            redImg.visible = true
        end
        obj.data = data
    end
end

--点击收藏列表item
function FashionPanel:onCollectionItem(context)
    local data = context.data.data
    self:showCollectionInfo(data)
end

--当前皮肤套装对应的皮肤
function FashionPanel:collectItem(index,obj)
    local data = self.skinItemData[index+1]
    if data then
        local itemObj = obj:GetChild("n1")
        local nameTxt = obj:GetChild("n2")
        local getImg = obj:GetChild("n3")
        getImg.visible = true
        if data[3] then
            getImg.visible = false
        end
        local confData = GGetSkinInfoByModuleIdAndSkinId(data[1],data[2])
        -- print("confData.skin_pro>>>>>>>>>>>>>>>",data[1],data[2])
        local mid = confData.skin_pro
        GSetItemData(itemObj,{mid = mid},true)
        nameTxt.text = mgr.TextMgr:getColorNameByMid(mid)
    end
end

--当前选择的藏品信息
function FashionPanel:showCollectionInfo(data)
    local sex = cache.PlayerCache:getSex()
    self.skinItemData = data.collect_id
    local modelId = data.model_id[1][1]
    if sex == 2 then
        self.skinItemData = data.collect_id_g
        modelId = data.model_id[2][1]
    end
    self.ItemList.numItems = #self.skinItemData
    local t = GConfDataSort(data)
    self.collectAttrList.itemRenderer = function (index,obj)
        local attrData = t[index+1]
        if attrData then
            obj:GetChild("n0").text = conf.RedPointConf:getProName(attrData[1])
            obj:GetChild("n1").text = GProPrecnt(attrData[1],attrData[2])
        end
    end
    self.collectAttrList.numItems = #t

    --模型设置
    local modelObj = self.mParent:addEffect(modelId,self.collectionModel)
    self.modelObj2 = modelObj
    local posX = data.pos[1] or 80
    local posY = data.pos[2] or -130
    local posZ = data.pos[3] or 500

    local rotX = data.rotation[1] or 0
    local rotY = data.rotation[2] or 180
    local rotZ = data.rotation[3] or 0
    
    self.modelObj2.LocalPosition = Vector3(posX,posY,posZ)
    self.modelObj2.LocalRotation = Vector3(rotX,rotY,rotZ)
    --激活按钮
    local actBtn = self.panelObj:GetChild("n56")
    actBtn:GetChild("red").visible = false
    actBtn.data = data
    actBtn.onClick:Add(self.onClickAct,self)
    if data.isAct then
        actBtn.visible = false
    else
        actBtn.visible = true
        if data.count == data.max then
            actBtn:GetChild("red").visible = true
        end
    end
end

--刷新时装藏品红点
function FashionPanel:refreshCollectionRed()
    local var = cache.PlayerCache:getRedPointById(attConst.A10267)
    if var > 0 then
        self.collectBtn:GetChild("n4").visible = true
    else
        self.collectBtn:GetChild("n4").visible = false
    end
end

function FashionPanel:onClickAct(context)
    local data = context.sender.data
    if data.isAct then
        GComAlter(language.gonggong10)
        return
    end
    if data.count < data.max then
        GComAlter(language.fashion26)
        return
    end
    proxy.PlayerProxy:send(1270301,{reqType = 1,suitId = data.id})
end

function FashionPanel:onClickStar()
    if not self.confStarData then return end
    if not self.isHave then
        GComAlter(language.fashion13)
        return
    end
    mgr.ViewMgr:openView2(ViewName.FashionStarView, self.confStarData)
end

function FashionPanel:clear()
    self.mData1 = nil
    self.mData2 = nil
    if self.modelObj2 then
        self.mParent:removeUIEffect(self.modelObj2)
        self.modelObj2 = nil
    end
end

return FashionPanel