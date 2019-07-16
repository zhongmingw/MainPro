-- --
-- -- Author: ohf
-- -- Date: 2017-03-06 14:32:09
-- --
-- --称号区域
-- local TitlePanel = class("TitlePanel",import("game.base.Ref"))

-- local color1 = 7--字体颜色
-- local color2 = 8

-- function TitlePanel:ctor(mParent)
--     self.mParent = mParent
--     self:initPanel()
-- end

-- function TitlePanel:initPanel()
--     self.titleTypes = conf.RoleConf:getTitleType()
--     self.confTitleList = conf.RoleConf:getAllTitle()
--     local panelObj = self.mParent.view:GetChild("n16")
--     self.panelObj = panelObj
--     self.listView = panelObj:GetChild("n2")
--     -- self.listView:SetVirtual()
--     self.titleIcon = panelObj:GetChild("n33")--称号
--     self.titleIcon.url = ""
--     self.titleEffect = panelObj:GetChild("n44")--称号特效
--     self.heroPanel = panelObj:GetChild("n28")--模型触摸区域
--     self.heroModel = panelObj:GetChild("n29")--放置模型区域
--     local titleBtn = panelObj:GetChild("n6")--佩戴按钮
--     self.titleBtn = titleBtn
--     titleBtn.onClick:Add(self.onClickWear,self)
--     self.titleBtnUrl = titleBtn:GetChild("icon")
    
--     self.powerText = panelObj:GetChild("n18")
--     self.attiList = panelObj:GetChild("n45")
--     self.attiList.numItems = 0
--     -- for i=1,7 do
--     --     local atti = panelObj:GetChild("n2"..i)
--     --     atti.text = ""
--     --     table.insert(self.attiList, atti)
--     -- end
--     local checkBtn = panelObj:GetChild("n20")
--     self.checkController = checkBtn:GetController("button")
--     self.checkController.onChanged:Add(self.selelctCheck,self)

--     self.timeText = panelObj:GetChild("n32")
--     self.timeText.text = ""

--     self.titleLookBtn = panelObj:GetChild("n37")--称号总览
--     self.titleLookBtn.onClick:Add(self.onClickAllTitle,self)
--     self.lookCtrl = self.titleLookBtn:GetController("button")

--     self.attiTitle = panelObj:GetChild("n14")--属性标题

--     self.alearyImg = panelObj:GetChild("n38")
--     self.alearyImg.visible = false

--     self.formView = {}
--     for i=34,36 do
--         local text = panelObj:GetChild("n"..i)
--         table.insert(self.formView, text)
--     end
-- end
--子页签，孙子页签
-- function TitlePanel:setForviewIndex(childIndex,grandson)
--     self.childIndex,self.grandson = childIndex,grandson
-- end
-- --称号列表
-- function TitlePanel:setData(data)
--     local mData = nil
--     -- self:setOpenZero()
--     self.confTitle = {}
--     for k ,v in pairs(self.confTitleList) do
--         local callback = function()
--             table.insert(self.confTitle,v)
--             local count = #self.confTitle
--             self.confTitle[count]["titleId"] = nil
--             self.confTitle[count]["gotTime"] = nil
--             self.confTitle[count]["isWear"] = nil
--             self.confTitle[count]["titleEndTime"] = nil
--         end
--         if not v.buysee then
--             callback()
--         end
--         for k,v2 in pairs(data.titleInfos) do
--             if v.buysee then
--                 if v.id == v2.titleId and not self:getTitle(v.id) then
--                     callback()
--                 end
--             end
--             if v.id == v2.titleId then
--                 local count = #self.confTitle
--                 self.confTitle[count]["titleId"] = v2.titleId
--                 self.confTitle[count]["gotTime"] = v2.gotTime
--                 self.confTitle[count]["isWear"] = v2.isWear
--                 self.confTitle[count]["titleEndTime"] = v2.titleEndTime
--                 if v2.isWear == 1 then
--                     mData = self.confTitle[count]
--                 end
--             end
--         end
--     end
--     self:dataSort()
--     -- printt(self.confTitle)
--     self:updateTitle(mData)
--     -- self:setModel()
--     self:addModel()
--     if self.childIndex then
--         self:setOpenZero()
--         self:setListViewData()
--     else
--         self:onClickAllTitle()
--     end
-- end

-- function TitlePanel:getTitle(id)
--     for k,v in pairs(self.confTitle) do
--         if v.id == id then
--             return true
--         end
--     end
--     return false
-- end

-- function TitlePanel:dataSort()
--     table.sort(self.confTitle, function(a,b)
--         local aw = a.isWear or 0
--         local bw = b.isWear or 0
--         if aw ~= bw then
--             return aw > bw
--         else
--             return a.sort < b.sort
--         end
--     end)
-- end

-- function TitlePanel:setOpenZero()
--     for k,v in pairs(self.titleTypes) do
--         if self.childIndex and self.childIndex == k then
--             self.titleTypes[k].open = 1
--         else
--             self.titleTypes[k].open = 0
--         end
--     end
-- end

-- function TitlePanel:setListViewData()
--     local num = 0
--     self.listView.numItems = 0
--     for k,v in pairs(self.titleTypes) do
--         num = num + 1
--         local url = UIPackage.GetItemURL("juese" , "FashionTitleItem")
--         local obj = self.listView:AddItemFromPool(url)
--         self:cellTitleData1(v,obj)
--         if v.open == 1 then
--             self.num = num
--             local items = self.confTitle
--             if self.isSelect then
--                 items = self:getSelectItem()
--             end
--             if self.grandson then
--                 local index = 0
--                 for k,data in pairs(items) do
--                     if data.type == v.id then
--                         index = index + 1
--                         if self.grandson == data.id then
--                             self.chooseTitlekey = index--选中的称号
--                             break
--                         end
--                     end
--                 end
--             end
--             local i = 0
--             for k,data in pairs(items) do
--                 if data.type == v.id then
--                     i = i + 1
--                     num = num + 1
--                     local url = UIPackage.GetItemURL("juese" , "TitleItem")
--                     local obj = self.listView:AddItemFromPool(url)
--                     self:cellTitleData2(data,obj,i)
--                 end
--             end
--         end
--     end
--     if self.num then
--         self.listView:ScrollToView(self.num - 1)
--         self.num = nil
--     end
--     self.childIndex,self.grandson,self.chooseTitlekey = nil,nil,nil
-- end
-- --夫元素
-- function TitlePanel:cellTitleData1(data,cell)
--     local titleName = cell:GetChild("title")
--     titleName.text = data.name
--     local ctrl = cell:GetController("button")
--     ctrl.selectedIndex = data.open
--     cell.data = data
--     cell.onClick:Add(self.onClickTitleSuit,self)
-- end
-- --子元素--
-- function TitlePanel:cellTitleData2(data,cell,i)
--     local icon = cell:GetChild("icon")
--     icon.url = ResPath.titleRes(data.scr)
--     icon.scaleX = data.scale
--     icon.scaleY = data.scale
--     local wearImg = cell:GetChild("n6")
--     if data.isWear == 1 then
--         wearImg.visible = true
--     else
--         wearImg.visible = false
--     end
--     local timeImg = cell:GetChild("n5")
--     if data.time > 0 and data.gotTime then
--         timeImg.visible = true
--     else
--         timeImg.visible = false
--     end
--     local ungetImg = cell:GetChild("n7")
--     if data.titleId then
--         cell.grayed = false
--     else
--         cell.grayed = true
--     end
--     cell.data = data
--     cell.onClick:Add(self.onClickTitleItem,self)
--     local index = self.chooseTitlekey or 1
--     if i == index then
--         cell.selected = true
--         local context = {sender = cell}
--         self:onClickTitleItem(context)
--     end
-- end
-- --穿戴称号返回 isPreview:是否是预览
-- function TitlePanel:updateTitleData(data)
--     for k,v in pairs(self.confTitle) do
--         if v.titleId == data.titleId then
--             if data.type == 2 then
--                 self.confTitle[k]["isWear"] = 0
--             else
--                 self.confTitle[k]["isWear"] = 1
--             end
--             self.mData = self.confTitle[k]
--         else
--             self.confTitle[k]["isWear"] = 0
--         end
--     end
--     if data.type == 2 then
--         GComAlter(language.gonggong25)
--     else
--         GComAlter(language.gonggong26)
--     end
--     self:dataSort()
--     self:updateTitle(self.mData,nil,true)
--     self:setListViewData()
-- end
-- --预览称号属性
-- function TitlePanel:updateTitle(data,isPreview,isType)
--     if not isPreview then
--         self.mData = data
--     end
--     if data then
--         if data.isWear and data.isWear == 1 then
--             self.titleBtnUrl.url = UIItemRes.fashionTitle02[1]
--             self.attiTitle.url = UIItemRes.fashionTitle01[1]
--         else
--             if isType then 
--                 self.chooseData = nil
--             end
--             self.attiTitle.url = UIItemRes.fashionTitle01[3]
--             self.titleBtnUrl.url = UIItemRes.fashionTitle02[2]
--         end
--         self.titleIcon.url = ResPath.titleRes(data.scr)

--         -- if not self.effectMode then
--         --     self.effectMode = self.titleEffect.blendMode
--         -- end
--         local url = nil
--         if data.id == 1005002 then--仙盟盟主
--             url = UIPackage.GetItemURL("_movie" , "MovieChenghao1")
--             -- self.titleEffect.blendMode = self.effectMode
--         end
--         if data.id == 1004001 then--战力至尊
--             url = UIPackage.GetItemURL("_movie" , "MovieChenghao2")
--             -- self.titleEffect.blendMode = self.effectMode
--         end
--         if data.id == 1006015 then--三生三世
--             -- self.titleIcon.url = ""
--             -- self.effectMode = self.titleEffect.blendMode
--             -- self.titleEffect.blendMode = self.titleIcon.blendMode
--             url = UIPackage.GetItemURL("_movie" , "MovieChenghao3")
--         end
--         if url then
--             self.titleEffect.visible = true
--         else
--             self.titleEffect.visible = false
--         end
--         self.titleEffect.url = url
--         self:cleanAtti()
--         self.powerText.text = data.power
--         local t = GConfDataSort(data)
--         self.attiList.itemRenderer = function (index,obj)
--             local data = t[index+1]
--             if data then
--                 obj:GetChild("n0").text = conf.RedPointConf:getProName(data[1]).." "..GProPrecnt(data[1],data[2]) --v[2] --EVE 使用百分比显示
--             end
--         end
--         self.attiList.numItems = #t
--         -- for k,v in pairs(t) do
--             -- plog(v[1].."    ".. GProPrecnt(v[1],v[2]))
--         -- end
--         self:updateTimer(data)--倒计时
--         self:cleanFromview()
--         for k,text in pairs(data.fromview) do--获取途径
--             self.formView[k].onClickLink:Clear()
--             if data.hert then
--                 self.formView[k].text = mgr.TextMgr:getTextColorStr(text, 7, tostring(data.hert[1]))
--                 self.formView[k].onClickLink:Add(self.onLinkText,self)
--             else
--                 self.formView[k].text = text
--             end
--         end
--         if data.titleId then
--             self.alearyImg.visible = false
--             self.titleBtn.visible = true
--         else
--             self.alearyImg.visible = true
--             self.titleBtn.visible = false
--         end
--     else
--         self.titleIcon.url = ""
--         self.timeText.text = mgr.TextMgr:getTextColorStr(language.title06,color2)
--     end
-- end

-- function TitlePanel:onLinkText(context)
--     GOpenView({id = tonumber(context.data)})
-- end

-- function TitlePanel:cleanFromview()
--     for k,v in pairs(self.formView) do
--         if k == 1 then
--             self.formView[k].text = language.title08
--         else
--             self.formView[k].text = ""
--         end
--     end
-- end
-- --加成总属性
-- function TitlePanel:setAttiData()
--     self:cleanFromview()
--     self.titleBtn.visible = false
--     local items = self:getSelectItem()
--     self.attiTitle.url = UIItemRes.fashionTitle01[1]
--     local attiData = {}
--     local curPower = 0
--     if #items > 0 then
--         self:cleanAtti()
--     else
--         local attiData = GAllAttiData()
--         for k,v in pairs(attiData) do
            
--         end
--         self.attiList.itemRenderer = function (index,obj)
--             local data = attiData[index+1]
--             if data then
--                 obj:GetChild("n0").text = conf.RedPointConf:getProName(data[1]).." "..GProPrecnt(data[1],data[2])
--             end
--         end
--         self.attiList.numItems = #attiData
--     end
--     for _,atti in pairs(items) do
--         for k,v in pairs(atti) do
--             if string.find(k,"att_") then
--                 if not attiData[k] then
--                     attiData[k] = 0
--                 end
--                 attiData[k] = attiData[k] + v
--             elseif k == "power" then
--                 curPower = curPower + v
--             end
--         end
--     end
--     self.powerText.text = curPower
--     local t = GConfDataSort(attiData)
--     for k,v in pairs(t) do
--     end
--     self.attiList.itemRenderer = function (index,obj)
--         local data = t[index+1]
--         if data then
--             obj:GetChild("n0").text = conf.RedPointConf:getProName(data[1]).." "..GProPrecnt(data[1],data[2]) 
--         end
--     end
--     self.attiList.numItems = #t
-- end
-- --倒计时
-- function TitlePanel:updateTimer(data)
--     if data.time > 0 or data.con_type == 4 or data.con_type == 5 then
--         if data.gotTime then
--             local serverTime = mgr.NetMgr:getServerTime()
--             if data.con_type == 4 or data.con_type == 5 then
--                 self.time = data.titleEndTime - serverTime
--             else
--                 self.time = data.time - (serverTime - data.gotTime)
--             end
--             self:onTimer()
--             if not self.timer then
--                 self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
--             end
--         else
--             self:releaseTimer()
--             if data.con_type == 4 or data.con_type == 5 then 
--                 self.timeText.text = mgr.TextMgr:getTextColorStr(language.title04,color2)
--             else
--                 self.timeText.text = mgr.TextMgr:getTextColorStr(language.title05,color2)
--             end
--         end
--     else 
--         self:releaseTimer()
--         self.timeText.text = mgr.TextMgr:getTextColorStr(language.title02,color2)
--     end
-- end



-- function TitlePanel:onTimer()
--     if self.time <= 0 then
--         self:releaseTimer()
--         self.timeText.text = mgr.TextMgr:getTextColorStr(language.title03,color2)
--         -- proxy.PlayerProxy:send(1270101)
--         return
--     end
--     self.time = self.time - 1
--     self.timeText.text = mgr.TextMgr:getTextColorStr(GGetTimeData2(self.time)..language.title01, color1)
-- end
-- --添加模型
-- function TitlePanel:addModel()
--     local roleIcon = roleData and roleData.roleIcon or cache.PlayerCache:getRoleIcon()
--     local sex = GGetMsgByRoleIcon(roleIcon).sex
--     local skins1 = cache.PlayerCache:getSkins(Skins.clothes)--衣服
--     local skins2 = cache.PlayerCache:getSkins(Skins.wuqi)--武器
--     local skins3 = cache.PlayerCache:getSkins(Skins.xianyu)--仙羽
--     local skins5 = cache.PlayerCache:getSkins(Skins.shenbing) --神兵
--     local modelObj = self.mParent:addModel(skins1,self.heroModel)
--     self.cansee = modelObj:setSkins(nil,skins2,skins3)
--     self.modelObj = modelObj
--     modelObj:setPosition(self.heroModel.actualWidth/2,-self.heroModel.actualHeight-200,500)
--     modelObj:setRotation(RoleSexModel[sex].angle)
--     local effect = self.mParent:addEffect(4020102,self.panelObj:GetChild("n39"))
--     effect.LocalPosition = Vector3(self.heroModel.actualWidth/2,-self.heroModel.actualHeight,500)
--     if skins5 > 0 and skins2>0 then
--         modelObj:addWeaponEct(skins5.."_ui")
--     end
--     self.modelObj:modelTouchRotate(self.heroPanel,sex)
--     self.panelObj:GetChild("n40").visible = self.cansee
-- end

-- function TitlePanel:setModel()
--     -- local skins1 = cache.PlayerCache:getSkins(1)--衣服
--     -- local skins2 = cache.PlayerCache:getSkins(2)--武器
--     -- local skins3 = cache.PlayerCache:getSkins(3)--仙羽毛
--     -- if self.modelObj then
--     --     self.modelObj:setSkins(skins1,skins2,skins3)
--     -- end
--     -- self:addModel()
-- end

-- function TitlePanel:onClickTitleSuit(context)
--     local data = context.sender.data
--     for k,v in pairs(self.titleTypes) do
--         if data.id == v.id then
--             if v.open == 0 then--关
--                 self.titleTypes[k].open = 1
--             else
--                 self.chooseData = nil
--                 self.titleTypes[k].open = 0
--             end
--         else
--             self.chooseData = nil
--             self.titleTypes[k].open = 0
--         end
--     end
--     self:setListViewData()
-- end

-- function TitlePanel:cleanAtti()
--     self.attiList.numItems = 0
-- end

-- function TitlePanel:onClickTitleItem(context)
--     local data = context.sender.data
--     self.chooseData = data--
--     self.lookCtrl.selectedIndex = 0
--     self:updateTitle(data,true)
-- end
-- --返回已拥有的称号
-- function TitlePanel:getSelectItem()
--     local data = {}
--     for k,v in pairs(self.confTitle) do
--         if v.titleId then
--             table.insert(data, v)
--         end
--     end
--     return data
-- end
-- --佩戴称号
-- function TitlePanel:onClickWear()
--     if self.chooseData then
--         if self.chooseData.titleId then
--             local reqType = 1
--             if self.chooseData.isWear == 1 then--已经戴上的就卸下
--                 reqType = 2
--             else
--                 reqType = 1
--             end
--             proxy.PlayerProxy:send(1270102,{titleId = self.chooseData.titleId,reqType = reqType})
--         else
--             GComAlter(language.title05)
--         end
--     else
--         if self.mData and self.mData.isWear == 1 then
--             proxy.PlayerProxy:send(1270102,{titleId = self.mData.titleId,reqType = 2})
--         else
--             GComAlter(language.title07)
--         end
--     end
-- end
-- --称号总览
-- function TitlePanel:onClickAllTitle()
--     self.titleLookBtn.selected = true
--     self.lookCtrl.selectedIndex = 1
--     self:setOpenZero()
--     self:setListViewData()
--     self:setAttiData()
-- end

-- function TitlePanel:selelctCheck()
--     local selectedIndex = self.checkController.selectedIndex
--     if selectedIndex == 1 or selectedIndex == 3 then
--         self.isSelect = true--仅显示已打造选项
--         self:setListViewData()
--     else
--         self.isSelect = false
--         self:setListViewData()
--     end
-- end

-- return TitlePanel
----------------------

local TitlePanel = class("TitlePanel",import("game.base.Ref"))

local hasNum,canhasNum,listindex = 0,0,0

function TitlePanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function  TitlePanel:initPanel()
    self.titleTypes = conf.RoleConf:getTitleType()
    self.confTitleList = conf.RoleConf:getAllTitle()
    local panelObj = self.mParent.view:GetChild("n16")
    self.panelObj = panelObj
    self.listView = panelObj:GetChild("n2")
    self.listView1 = panelObj:GetChild("n66")
    self.listView1.itemRenderer = function ( index,obj)
        self:cellData(index,obj)
    end

    local addBtn = panelObj:GetChild("n51")
    addBtn.onClick:Add(self.onClickAdd,self)
  
    self.hasText = panelObj:GetChild("n47")
    self.hasText.text = ""
    self.canhasText = panelObj:GetChild("n49")
    self.canhasText.text = "" 
    self:setListViewData()
    self.timertable = {}
    self.timetabler1 = {}
    self.timeTexttable = {}
end

function  TitlePanel:setData(data)
    printt("#####################",data)
    self.data = data
    self.infos = {}
    self.count = data.count
    self.titleMax = data.titleMax
    self.buyCount = data.buyCount
    hasNum = self.titleMax - self.count
    canhasNum = self.count 
    for k,v in pairs(self.data.titleInfos ) do
        self.infos[v.titleId] = v
    end
    table.sort(self.infos,function(a,b)
        if a.titleId ~= b.titleId then
            return a.titleId < b.titleId
        end
    end)
    --默认选第一个
    local cell = self.listView:GetChildAt(0)
    cell.onClick:Call()
    self:calculateNum()
end

function TitlePanel:onClickAdd(context)
    local vip =cache.PlayerCache:getVipLv()
    
    local data = conf.VipChargeConf:getVipNum(vip)
    local num = conf.VipChargeConf:getVipAccordNum(vip)
    if  self.count < num + 1 then

         local t = clone(language.ch02)
         local price = conf.RoleConf:getTitilePrice(self.buyCount)
         t[1].text = string.format(t[1].text,price)

        local param = {
        type = 14,
        richtext = mgr.TextMgr:getTextByTable(t),
        okUrl = UIItemRes.imagefons04,
        sure = function()
            local money =  cache.PlayerCache:getTypeMoney(MoneyType.gold)
            if money >= price then
                 proxy.PlayerProxy:send(1270107)
            else
                local param = {}
                param.id = 1042
                GOpenView(param) -- 前往充值
            end 
        end
        }
        GComAlter(param)
    else
        
        local Num = conf.VipChargeConf:getVipMAxNum()
        if vip == 13  or (self.count > Num )then
            GComAlter(language.ch03)
            return
        end
        GComAlter(string.format(language.ch01,data.vip_level ))
    end

end

function TitlePanel:setListViewData()
    self.listView.numItems = 0
    for k,v in pairs(self.titleTypes) do
        local url = UIPackage.GetItemURL("juese" , "ChenHaoTitleItem")
        local obj = self.listView:AddItemFromPool(url)
        self:cellTitleData1(v,obj,k)
    end
end

function TitlePanel:calculateNum(data)
    if data then  
    printt("称号购买返回",data)
        self.buyCount = self.buyCount + 1
        self.count = data.count
        canhasNum = self.count
        hasNum = 0
         for k,v in pairs(self.infos) do
            if v.isWear  == 1 then --佩戴
                hasNum = hasNum + 1
                canhasNum = canhasNum - 1
            end
        end
    else  
        hasNum = 0
        canhasNum = self.count
        for k,v in pairs(self.infos) do
            if v.isWear  == 1 then --佩戴
                hasNum = hasNum + 1
                canhasNum = canhasNum - 1
            end
        end
    end
    self.hasText.text = hasNum..""
    local str = ""
    if canhasNum > 0 then
        str = mgr.TextMgr:getTextColorStr(""..canhasNum, 7).."/"..self.count 
    else
        str = mgr.TextMgr:getTextColorStr(""..canhasNum, 18).."/"..self.count 
    end
    self.canhasText.text = str
end

--夫元素
function TitlePanel:cellTitleData1(data,cell,k)
    local titleName = cell:GetChild("title")
    titleName.text = data.name
    cell.data = k
    cell.onClick:Add(self.onClickTitleSuit,self)
end

function TitlePanel:onClickTitleSuit(context)
    local data = context.sender.data
    self.data1 = {}
    self.data1 = conf.RoleConf:getTitileTypeById(data)
    self:sortListView()
    self:releaseTimer()
    self.listView1.numItems = #self.data1
end

function TitlePanel:cellData(index,obj)
    local data = self.data1[index + 1]
    -- if  data.buysee and not self.infos[data.id] then
    --     print("购买才显示")
    --     self.listView1:RemoveChildAt(index)
    --     return
    -- end
    local  c1 = obj:GetController("c1")
    local titleEffect = obj:GetChild("n70")
    local url = nil
    --部分称号有特效（特殊处理了）
    if data.id == 1005002 then--仙盟盟主
        url = UIPackage.GetItemURL("_movie" , "MovieChenghao1")
    end
    if data.id == 1004001 then--战力至尊
        url = UIPackage.GetItemURL("_movie" , "MovieChenghao2")
    end
    if data.id == 1006015 then--三生三世
        url = UIPackage.GetItemURL("_movie" , "MovieChenghao3")
    end
    if url then
        titleEffect.visible = true
        titleEffect.url = url
    else
        titleEffect.visible = false
    end

    c1.selectedIndex = 0
    local icon = obj:GetChild("n56")
    icon.url =  UIPackage.GetItemURL("head" ,data.scr.."")
    local textList = {}
    for i = 62,65 do 
        table.insert(textList, obj:GetChild("n"..i))
    end
    local  temp  = GConfDataSort(data)
 
    local isshow =false
    for i,j in pairs(textList) do
       if i ~= #textList+ 1 and temp[i] then
 
            if temp[i][2] == 0 then
                textList[i].text = conf.RedPointConf:getProName(temp[i][1]).." +".."无"
                isshow = true
            else
                textList[i].text = conf.RedPointConf:getProName(temp[i][1]).." +"
                .. mgr.TextMgr:getTextColorStr(GProPrecnt(temp[i][1],math.floor(temp[i][2])), 7) 
            end
       else
            textList[i].text = ""       
       end 
    end
    if isshow then
        for i,j in pairs(textList) do
             textList[i].text = "" 
        end
        textList[1].text = "无"  
    end

    --属性没有时
    if  textList[1].text == "" then
        textList[1].text = "无" 
    end

    local text1 = obj:GetChild("n58")
    local text2 = obj:GetChild("n59")
    local btn1  = obj:GetChild("n6") --佩戴
    local btn2  = obj:GetChild("n66")  --卸下
    local bgImg =  obj:GetChild("n54") -- 背景框
    --与服务器返回对比
    if self.infos[data.id] then
        if self.infos[data.id].isWear == 0 then --未配  
   
            c1.selectedIndex = 2
            btn1.data = {titleId = self.infos[data.id].titleId,reqType = 1}
            btn1.onClick:Add(self.onClickWear,self)  
        elseif self.infos[data.id].isWear == 1 then
     
            c1.selectedIndex = 1
            btn2.data = {titleId = self.infos[data.id].titleId,reqType = 2}
            btn2.onClick:Add(self.onClickWear,self)     
        end
        -- listindex = listindex + 1
        text1.text = "倒计时："

        local serverTime = mgr.NetMgr:getServerTime()
        if (self.infos[data.id].titleEndTime - serverTime) > 0 or (self.infos[data.id].titleEndTime == 0 and data.time > 0) then --永久
            local curTime = self.infos[data.id].titleEndTime -serverTime
            if self.infos[data.id].titleEndTime == 0 then
                curTime = data.time + self.infos[data.id].gotTime - serverTime
            end
            self.timetabler1[data.id] = curTime 
            self.timeTexttable[data.id] = text2
            text2.text = ""..GGetTimeData3(curTime)

            if not self.timertable[data.id] then
                self.timertable[data.id] =  self.mParent:addTimer(1, -1, handler(self, self.onTimer))
            end
        else
            text2.text = "永久"
        end
        icon.grayed = false
        bgImg.grayed = false
    else
        text2.text = ""
        icon.grayed = true
        bgImg.grayed = true
        titleEffect.visible = false
        for k,text in pairs(data.fromview) do--获取途径
            text1.onClickLink:Clear()
            if data.hert then
                text1.text = mgr.TextMgr:getTextColorStr("获取途径：", 6)..mgr.TextMgr:getTextColorStr(text, 6, tostring(data.hert[1]))
                text1.onClickLink:Add(self.onLinkText,self)
            else
                text1.text = mgr.TextMgr:getTextColorStr("获取途径：", 6)..mgr.TextMgr:getTextColorStr(text, 6)
            end
        end
        c1.selectedIndex = 0
    end
end

function TitlePanel:sortListView()
    --购买才显示
    local tab = {}
    for k,v in pairs(self.data1) do
        if not v.buysee or self.infos[v.id] then 
            table.insert(tab,v)
        end
    end
    self.data1 = tab

    for k,v in pairs(self.infos) do
        for i,j in pairs(self.data1) do
            if v.titleId == j.id then
                j.isWear =v.isWear
            end
        end
    end
    table.sort(self.data1,function(a,b)
        local aiswear = a.isWear or -1
        local biswear = b.isWear or -1
        local asort = a.sort
        local bsort = b.sort
        if aiswear ~= biswear then
            return aiswear > biswear
        else
            return a.sort < b.sort
        end
    end)
end



function TitlePanel:onTimer()
    for k,v in pairs(self.timetabler1) do
        if self.timetabler1[k] then
            if self.timetabler1[k] > 86400 then 
                self.timeTexttable[k].text = GTotimeString7(self.timetabler1[k])
            else
                self.timeTexttable[k].text = GTotimeString2(self.timetabler1[k])
            end
        end
        if self.timetabler1[k]< 0 then
    
            self:releaseTimer()
            proxy.PlayerProxy:send(1270101)
            return
        end
        self.timetabler1[k] = self.timetabler1[k] -1 
    end
end

function TitlePanel:releaseTimer()
    for k,v in pairs(self.timertable) do
        self.mParent:removeTimer(self.timertable[k])
        self.timertable[k] = nil
         self.timetabler1[k] = ""
        self.timeTexttable[k].text = ""
    end
end

function TitlePanel:onLinkText(context)
    print(context.data,"跳转id@@@@@@@@@@@")
    GOpenView({id = tonumber(context.data)})
end

function TitlePanel:setForviewIndex(childIndex,grandson)
    self.childIndex,self.grandson = childIndex,grandson
end

function TitlePanel:onClickWear(context)
    local data = context.sender.data
    if canhasNum > 0 or data.reqType == 2 then
        proxy.PlayerProxy:send(1270102,data)
    else
        GComAlter(language.ch04)
    end
end

--穿戴称号返回 
function TitlePanel:updateTitleData(data)
    for k,v in pairs(self.infos) do
        if v.titleId == data.titleId then
            if data.type == 1 then
                v.isWear = data.type  
            elseif  data.type == 2 then
                v.isWear = 0
            end
        end
    end
    self:sortListView()
    self.listView1.numItems = #self.data1
    self:calculateNum()
end






return TitlePanel