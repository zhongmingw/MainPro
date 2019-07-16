--
-- Author: Your Name
-- Date: 2018-08-14 21:32:04
--聊天边框
local HeadFramePanel = class("HeadFramePanel",import("game.base.Ref"))

function HeadFramePanel:ctor(mParent)
    self.mParent = mParent
    self.view = self.mParent.view:GetChild("n6")
    self:initPanel()
end

function HeadFramePanel:initPanel()
    --标题列表
    self.titleList = self.view:GetChild("n16")
    self.titleList.numItems = 0
    self.titleList.itemRenderer = function (index,obj)
        self:titleCelldata(index, obj)
    end
    -- self.titleList:SetVirtual()

    --基础属性列表
    self.attrsList = self.view:GetChild("n25")
    self.attrsList.numItems = 0

    --升星属性列表
    self.starAttrsList = self.view:GetChild("n28")
    self.starAttrsList.numItems = 0

    --升星按钮
    self.upStarsBtn = self.view:GetChild("n21")
    self.upStarsBtn.onClick:Add(self.onClickUpStars,self)
    --激活、佩戴按钮
    self.wearBtn = self.view:GetChild("n20")
    self.wearBtn.onClick:Add(self.onClickWear,self)
    self.c1 = self.view:GetController("c1")
    --当前战力
    self.powerTxt = self.view:GetChild("n24")
    self.powerTxt.text = ""
    --头像Icon
    self.headIcon = self.view:GetChild("n30")
    --当前选择头像框名称
    self.nameTxt = self.view:GetChild("n19")
    --当前选择边框的星级
    self.starItem = self.view:GetChild("n23")
    self.starController = self.starItem:GetController("c1")
    self.starController.selectedIndex = 0
    --获取途径
    self.gainTxt = self.view:GetChild("n29")
end

function HeadFramePanel:setIndex(index)
    self.childId = index
end
-- 变量名：reqType 说明：0:显示信息 1:激活 2:戴 3:脱
-- 变量名：power   说明：系统战力
-- 变量名：skinId  说明：皮肤id
-- 变量名：stars   说明：皮肤星数key:头像边框id,value:星数
-- 变量名：curSkinId   说明：当前的皮肤id
function HeadFramePanel:setData(data)
    -- printt("头像边框>>>>>>>",data)
    if data then
        self.data = data
        self.powerTxt.text = data.power
        self.confData = conf.RoleConf:getChatFrame(data)
        for k,v in pairs(self.confData) do
            if data.curSkinId ~= 0 and data.curSkinId == v.id then--当前穿戴
                self.confData[k].wear = 1
            else
                self.confData[k].wear = 0
            end
            self.confData[k].isHas = 0--当前是否拥有
            self.confData[k].starNum = 0--当前拥有的头像框星数
            for headId,starNum in pairs(data.stars) do
                if v.id == headId then
                    self.confData[k].isHas = 1
                    self.confData[k].starNum = starNum
                    break
                end
            end
        end
        table.sort(self.confData,function(a,b)
            if a.wear ~= b.wear then--穿戴
                return a.wear > b.wear
            elseif a.isHas ~= b.isHas then--拥有
                return a.isHas > b.isHas
            elseif a.id ~= b.id then--其他按照id排序
                return a.id < b.id
            end
        end)
        self.titleList.numItems = #self.confData
        if self.childId then
            local index = 0
            for k,v in pairs(self.confData) do
                if v.id == self.childId then
                    index = k - 1
                end
            end
            print("跳转index >>>>>>>",index)
            self.titleList:ScrollToView(index,false)
            local cell = self.titleList:GetChildAt(index)
            cell.onClick:Call()
        else
            local cell = self.titleList:GetChildAt(0)
            cell.onClick:Call()
        end
    else
        --刷新升星后的属性
        self:setAttrsList(self.chooseData)
    end
end

function HeadFramePanel:titleCelldata(index,obj)
    local data = self.confData[index+1]
    if data then
        local nameTxt = obj:GetChild("n8")
        nameTxt.text = data.name
        local wearImg = obj:GetChild("n6")
        wearImg.visible = false
        obj.data = data
        obj.onClick:Add(self.onClickHaloItem,self)
        if data.isHas == 1 then--拥有的
            obj.grayed = false
        else
            obj.grayed = true
        end
        if data.wear == 1 then--已佩戴
            wearImg.visible = true
        end
    end
end

function HeadFramePanel:onClickHaloItem(context)
    local sender = context.sender
    local data = sender.data
    self.chooseData = data
    self.headIcon.url = UIPackage.GetItemURL("_others" , data.icon)
    self.nameTxt.text = data.name
    self.gainTxt.text = data.gain
    self:setAttrsList(data)

    --当前边框激活穿戴状态
    if data.isHas == 0 then--未激活时（激活）
        self.c1.selectedIndex = 0
    elseif data.wear == 0 then--已激活未穿戴（穿戴）
        self.c1.selectedIndex = 1
    elseif data.wear == 1 then--当前穿戴（卸下）
        self.c1.selectedIndex = 2
    end
    self.childId = nil
end

--属性加成
function HeadFramePanel:setAttrsList(data)
    if data and data.id then
        self.starAttrsList.numItems = 0
        self.attrsList.numItems = 0
        local suitStarPre = data.star_pre or 0
        local suitStars = cache.PlayerCache:getSkinStarLv(suitStarPre)
        if suitStars > 0 then
            self.starController.selectedIndex = suitStars+10
        else
            self.starController.selectedIndex = 0
        end
        self.powerTxt.text = data.power
        --升星属性
        if data.star_pre then
            local suitStarConf = conf.RoleConf:getSkinsStarAttrData(data.id,1014)
            self.starAttrsList.itemRenderer = function (index,obj)
                local starData = suitStarConf[index+1]
                if starData then
                    local txt1 = obj:GetChild("n0")
                    local txt2 = obj:GetChild("n1")
                    local str1 = string.format(language.fashion14,starData.need_star)
                    local str2 = string.format(language.fashion15_1,language.gonggong94[1014],(starData.attr_show/100))
                    if suitStars >= starData.need_star then
                        txt1.text = mgr.TextMgr:getTextColorStr(str1,7)
                        txt2.text = mgr.TextMgr:getTextColorStr(str2,7)
                    else
                        txt1.text = mgr.TextMgr:getTextColorStr(str1,8)
                        txt2.text = mgr.TextMgr:getTextColorStr(str2,8)
                    end
                end
            end
            self.starAttrsList.numItems = #suitStarConf
        end
        local starId = suitStarPre*1000+suitStars
        self.starId = starId
        if suitStars > 0 then
            local starConf = conf.RoleConf:getFashionStarAttr(starId)
            self.powerTxt.text = data.power + starConf.power
        end
        --基础属性
        local t = GConfDataSort(data)
        self.attrsList.itemRenderer = function (index,obj)
            local tab = t[index+1]
            if tab then
                local txt1 = obj:GetChild("n0")
                local txt2 = obj:GetChild("n1")
                txt1.text = conf.RedPointConf:getProName(tab[1])
                if suitStars > 0 then
                    local curData = GConfDataSort(conf.RoleConf:getFashionStarAttr(starId))
                    if curData[index+1] then
                        txt2.text = GProPrecnt(tab[1],math.floor(tab[2])) + curData[index+1][2]
                    end
                else
                    txt2.text = GProPrecnt(tab[1],math.floor(tab[2]))
                end
            end
        end
        self.attrsList.numItems = #t
    end
end

function HeadFramePanel:onClickUpStars()
    if self.chooseData then
        if self.chooseData.isHas == 0 then
            GComAlter(language.fashion24)
            return
        end

        mgr.ViewMgr:openView2(ViewName.FashionStarView, self.chooseData)
    end
end

function HeadFramePanel:onClickWear()
    if self.chooseData then
        if self.chooseData.isHas == 0 then
            --升星消耗是否满足
            local suitStarPre = self.chooseData.star_pre or 0
            local suitStars = cache.PlayerCache:getSkinStarLv(suitStarPre)
            local starId = suitStarPre*1000+suitStars+1
            -- print("升星id>>>>>>>>>>",starId)
            local starConf = conf.RoleConf:getFashionStarAttr(starId)
            local mid = starConf.cost[1][1]
            local amount = cache.PackCache:getPackDataById(mid,true).amount
            if amount > 0 then
                proxy.PlayerProxy:send(1020505,{reqType = 1,skinId = self.chooseData.id})
            else
                GComAlter(language.fashion23)
                return
            end
        elseif self.chooseData.wear == 0 then--穿戴
            proxy.PlayerProxy:send(1020505,{reqType = 2,skinId = self.chooseData.id})
        elseif self.chooseData.wear == 1 then--卸下
            proxy.PlayerProxy:send(1020505,{reqType = 3,skinId = self.chooseData.id})
        end
    end
end

return HeadFramePanel