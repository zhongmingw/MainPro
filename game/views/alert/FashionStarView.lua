--
-- Author: 
-- Date: 2018-01-04 11:28:49
--
--时装升星
local FashionStarView = class("FashionStarView", base.BaseView)

function FashionStarView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function FashionStarView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.itemObj = self.view:GetChild("n2")
    self.itemName = self.view:GetChild("n3")

    self.listView = self.view:GetChild("n6")
    self:initStar()
    self:initAtti()
    self:initCost()

    local starBtn = self.view:GetChild("n5")
    self.starBtn = starBtn
    starBtn.onClick:Add(self.onClickStar,self)
end

function FashionStarView:initStar()
    -- local url = UIPackage.GetItemURL("alert" , "fashStarItem")
    local starItem = self.view:GetChild("n7")--时装星级
    -- starItem:GetChild("n11").text = language.fashion10
    self.starList = {}
    for i=81,90 do
        local star = starItem:GetChild("n"..i)
        star.enabled = false
        table.insert(self.starList, star)
    end
end

function FashionStarView:initAtti()
    local url = UIPackage.GetItemURL("alert" , "fashionAttiItem")
    self.attiItem = self.listView:AddItemFromPool(url)--加成属性
    self.attiItem:GetChild("n0").text = language.fashion11
    local url2 = UIPackage.GetItemURL("alert" , "FashionNextStar")
    self.nextStarAtt = self.listView:AddItemFromPool(url2)--星级属性加成
    self.nextStarAtt:GetChild("n0").text = language.fashion11_1
end

function FashionStarView:initCost()
    local url = UIPackage.GetItemURL("alert" , "costProItem")
    local costItem = self.listView:AddItemFromPool(url)--消耗道具
    self.costItem = costItem
    costItem:GetChild("n0").text = language.fashion12
    self.costObj = costItem:GetChild("n8")
    self.costName = costItem:GetChild("n1")
    self.costCout = costItem:GetChild("n9")
    local btn = costItem:GetChild("n10")
    btn.onClick:Add(self.onClickBuy,self)
end

function FashionStarView:initData(data)
    -- printt("升星信息",data)
    self.isInit = false--是否0级
    self.isMax = false--是否满级
    local starPre = data.star_pre
    self.starPre = starPre
    self.moduleType = math.floor(starPre / 1000) % 1000
    self.fid = data.id
    -- print("模块类型>>>>>>>>>>>>",self.moduleType)
    local proId = data.skin_pro
    GSetItemData(self.itemObj, {mid = proId,amount = 1})
    self.itemName.text = mgr.TextMgr:getColorNameByMid(proId)
    proxy.PlayerProxy:send(1270106,{fid = self.fid,reqType = 0,moduleType = self.moduleType})
end
--[[
2   
int32
变量名：moduleType  说明：模块类型
3   
int32
变量名：starId  说明：前缀 * 1000+星数
]]
function FashionStarView:addServerCallback(data)
    self.mData = data
    self.curData = conf.RoleConf:getFashionStarAttr(data.starId)
    if not self.curData then
        self.isInit = true
        self.curData = conf.RoleConf:getFashionStarAttr(data.starId + 1)--就获取下一级的
    else
        self.isInit = false
    end
    self.nextData = conf.RoleConf:getFashionStarAttr(data.starId + 1)
    if not self.curData then 
        print("@策划没有配置",data.starId)
        return 
    end
    self:setStarData()
    self:setAttiData()
    self:setCostData()
    if self.isMax then
        self.starBtn.visible = false
    else
        self.starBtn.visible = true
    end
end
--时装星级
function FashionStarView:setStarData()
    local lv = self.mData.starId % 1000 % 1000
    local reqType = self.mData.reqType
    for k,v in pairs(self.starList) do
        if reqType == 1 and k == lv then
            self:addEffect(4020106, v:GetChild("n1"))
            mgr.SoundMgr:playSound(Audios[2])
        end
        if k <= lv then
            v.enabled = true
        else
            v.enabled = false
        end
    end
    if reqType == 1 then
        cache.PlayerCache:setSkinStarLv(self.starPre,lv)
        self:refreshModelView()
    end
end

function FashionStarView:refreshModelView()
    local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
    if view then
        view:updateFashList()
        view:updateAureoleData()
        if self.mData.moduleType == 16 then
            view:updateHeadWearListData()
        end
        print(self.mData.moduleType ,"!!!!!!!!!!!!!!!!!!")

    end
    local view = mgr.ViewMgr:get(ViewName.AwakenView)
    if view then
        view:refAttiData()
    end
    local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
    if view then
        local isSx = true
        view:refreshZuoqi(isSx,self.fid)
    end
    local view = mgr.ViewMgr:get(ViewName.HuobanView)
    if view then
        view:updateZuoqi(self.fid)
    end
    local view = mgr.ViewMgr:get(ViewName.HeadChooseView)
    if view then
        view:refreshFrame()
        view:refreshBubble()
        local view2 = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view2 then
            proxy.PlayerProxy:send(1010103)
        end
    end
end
--加成属性
function FashionStarView:setAttiData()
    local t = GConfDataSort(self.curData)--当前属性
    local callback = function(t,writeStr,arrow)
        for k,v in pairs(t) do
            local str = ""
            if v[2] > 0 then
                local value = v[2]
                if self.isInit and arrow then--如果当前属性是0级的话
                    value = 0
                end
                str = conf.RedPointConf:getProName(v[1]).." "..value
            end
            local arrowStr = ""--箭头
            if arrow then
                arrowStr = mgr.TextMgr:getImg(UIItemRes.alert01)
            end
            if k ~= #t then
                str = str.."\n"
                arrowStr = arrowStr.."\n"
            end
            writeStr = writeStr..str
            if arrow then
                arrow = arrow..arrowStr
            end
        end
        return writeStr,arrow
    end
    local curStr,arrow = callback(t,"","")
    local nextStr = ""
    if self.nextData then--下级属性
        local t = GConfDataSort(self.nextData)
        local arrow = ""
        nextStr = callback(t,"")
    else--满级了
        for k,v in pairs(t) do
            local str = language.fashion09
            if k ~= #t then
                str = str.."\n"
            end
            nextStr = nextStr..str
        end
        self.isMax = true
    end 
    self.attiItem:GetChild("n8").text = curStr--属性加成
    self.attiItem:GetChild("n10").text = arrow--箭头
    self.attiItem:GetChild("n1").text = nextStr--下级属性加成
    local power = self.curData and self.curData.power or 0
    if self.isInit then--如果当前属性是0级的话
        power = 0
    end
    self.attiItem:GetChild("n12").text = power--战斗力
    local arrow = self.attiItem:GetChild("n13")
    local power = self.nextData and self.nextData.power or 0--下级战斗力
    if self.isMax then
        arrow.visible = false
        power = ""
    else
        arrow.visible = true
    end
    self.attiItem:GetChild("n14").text = power

    --星级属性加成
    local nextStarDec = self.nextStarAtt:GetChild("n2")
    local nextStarDec2 = self.nextStarAtt:GetChild("n3")
    local nextStarDec3 = self.nextStarAtt:GetChild("n4")
    local c1 = self.nextStarAtt:GetController("c1")
    local suitStarConf = conf.RoleConf:getSkinsStarAttrData(self.fid,(1000+self.moduleType))
    local suitStars = cache.PlayerCache:getSkinStarLv(self.starPre)
    local needConf = {}--下一属性加成
    local nowConf = {}--当前属性加成
    local maxstar = suitStars
    local suitId = 0
    local skinName = ""
    local otherSuitStars = 0
    for k,v in pairs(suitStarConf) do
        if maxstar < v.need_star then
            maxstar = v.need_star
        end
        if suitStars <= v.need_star then
            nowConf = v
        end
        for _,skinId in pairs(v.skins) do
            if skinId ~= self.fid then
                suitId = skinId
                break
            end
        end
        if suitId ~= 0 then
            local suitData = conf.RoleConf:getFashData(suitId)--配套时装
            local suitStarPre = suitData and suitData.star_pre or 0
            otherSuitStars = cache.PlayerCache:getSkinStarLv(suitStarPre)
            skinName = suitData.name
        end
    end
    for k,v in pairs(suitStarConf) do
        local compareStar = suitStars 
        if suitId ~= 0 then
            compareStar = suitStars < otherSuitStars and suitStars or otherSuitStars
        end
        if compareStar < v.need_star then
            needConf = v
            break
        end
    end
    if suitId ~= 0 then--时装套装
        if suitStars >= maxstar and otherSuitStars >= maxstar then
            c1.selectedIndex = 0
            local textData = clone(language.fashion18)
            textData[1].text = language.fashion22
            textData[2].text = string.format(textData[2].text,nowConf.attr_show/100)
            nextStarDec.text = mgr.TextMgr:getTextByTable(textData)
        else
            c1.selectedIndex = 1
            local textData = clone(language.fashion17)
            -- string.format(language.fashion17,needConf.need_star,language.gonggong94[(1000+self.moduleType)],needConf.attr_show/100)
            local textData = {
                    {text = string.format(language.fashion20,skinName).. language.fashion14_1 .. language.fashion17[1].text,color = 6},
                    {text = string.format("%d",needConf.need_star),color = 7},
                    {text = language.gonggong118,color = 6},
                }
            nextStarDec2.text = mgr.TextMgr:getTextByTable(textData)
            local textData2 = {
                    {text = language.fashion22,color = 6},
                    {text = "+"..(needConf.attr_show/100) .. "%",color = 7},
            }
            nextStarDec3.text = mgr.TextMgr:getTextByTable(textData2)
        end
    else
        c1.selectedIndex = 0
        if suitStars >= maxstar then
            local textData = clone(language.fashion18)
            textData[1].text = string.format(textData[1].text,language.gonggong94[(1000+self.moduleType)])
            textData[2].text = string.format(textData[2].text,nowConf.attr_show/100)
            nextStarDec.text = mgr.TextMgr:getTextByTable(textData)
        else
            local textData = clone(language.fashion17)
            -- string.format(language.fashion17,needConf.need_star,language.gonggong94[(1000+self.moduleType)],needConf.attr_show/100)
            textData[2].text = string.format(textData[2].text,needConf.need_star)
            textData[4].text = string.format(textData[4].text,language.gonggong94[(1000+self.moduleType)])
            textData[5].text = string.format(textData[5].text,needConf.attr_show/100)
            nextStarDec.text = mgr.TextMgr:getTextByTable(textData)
        end
    end
end
--消耗道具
function FashionStarView:setCostData()
    if self.isMax then
        self.costItem.visible = false
    else
        self.costItem.visible = true
        local costPro = self.nextData.cost[1]
        if self.init or self.isMax then
            costPro = self.curData.cost[1]
        end
        local proId = costPro[1]
        local amount = costPro[2]
        GSetItemData(self.costObj, {mid = proId,amount = costPro[2],bind = costPro[3]},true)
        self.proData = cache.PackCache:getPackDataById(proId)--背包数据
        self.costName.text = mgr.TextMgr:getColorNameByMid(proId)
        local color = 14
        self.isCanStar = false--是否可以升星
        if self.proData.amount >= amount then
            color = 7
            self.isCanStar = true
        end
        self.costCout.text = mgr.TextMgr:getTextColorStr(self.proData.amount, color)..mgr.TextMgr:getTextColorStr("/"..amount, 7)
    end
end

function FashionStarView:onClickBuy()
    if self.proData then
        local data = self.proData
        data.index = nil
        GGoBuyItem(data)
    end
end

function FashionStarView:onClickStar()
    if not self.isCanStar then
        self:onClickBuy()
        return
    end
    proxy.PlayerProxy:send(1270106,{fid = self.fid,reqType = 1,moduleType = self.moduleType})
end

return FashionStarView