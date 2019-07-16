--
-- Author: 
-- Date: 2017-10-16 16:05:38
--
--仙尊boss
local XianzunBossPanel = class("XianzunBossPanel",import("game.base.Ref"))

function XianzunBossPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function XianzunBossPanel:initPanel()
    self.confData = conf.SceneConf:getXianzunBoss()
    self.mosterId = 0--怪物id
    self.leftTimes = 0--疲劳值
    self.buyTimes = 1 --购买次数
    local panelObj = self.mParent.view:GetChild("n10")
    self.mainController = panelObj:GetController("c1")--主控制器
    self.mainController.selectedIndex = 1
    self.listView = panelObj:GetChild("n4")--boss
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)

    self.listAwardsList = panelObj:GetChild("n5")--掉落奖励
    self.listAwardsList:SetVirtual()
    self.listAwardsList.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end
    panelObj:GetChild("n9").text = language.fuben127
    local warBtn = panelObj:GetChild("n11")
    warBtn.onClick:Add(self.onClickWar,self)
    self.countText = panelObj:GetChild("n12")
    -- panelObj:GetChild("n13").text = language.fuben69
    self.modelPanel = panelObj:GetChild("n14")
    self.bgImg = panelObj:GetChild("n3")
    local addBtn = panelObj:GetChild("n16")
    addBtn.onClick:Add(self.onClickAdd,self)

    self.desc = panelObj:GetChild("n20")
    local dec = panelObj:GetChild("n6") 
    dec.text = language.fuben170

    local btn = panelObj:GetChild("n22")
    btn.onClick:Add(self.onClickXianshi,self)
    
end

function XianzunBossPanel:setData(data)
    self.bgImg.url = UIItemRes.bossWorld
    self.bossInfos = data and data.bossInfos or {}
    self.tipConfMap = data and data.tipConfMap or {}
    self.leftBuyCount = data.leftBuyCount or 0
    self.listView.numItems = #self.confData
    self.listView:ScrollToView(cache.FubenCache:getXzBossIndex())
    self:initChooseBoss()
    self:setLeftTimes(data)
end
--设置疲劳值
function XianzunBossPanel:setLeftTimes(data)
    if data.msgId == 5440102 then
        self.buyTimes = self.buyTimes + 1 
    end
    self.leftTimes = data and data.leftTimes or 0
    self.leftBuyCount = data.leftBuyCount
    self.countText.text = mgr.TextMgr:getTextColorStr(language.fuben165, 6)..mgr.TextMgr:getTextColorStr(self.leftTimes, 7)
end

function XianzunBossPanel:initChooseBoss()
    local max = #self.confData
    if max >= 3 then
        max = 3
    end
    for k = 1,max do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local index = change.index
            if index == cache.FubenCache:getXzBossIndex() then--选中boss
                cell.onClick:Call()
            end
        end
    end
end

function XianzunBossPanel:cellData(index,cell)
    local key = index + 1
    local sceneData = self.confData[key]
    local icon = cell:GetChild("icon")

    local isKuafu = cell:GetChild("n9")  --EVE 设置世界boss标志
    local cross = sceneData and sceneData.cross or 0
    if cross > 0 then 
        isKuafu.visible = true
    else  
        isKuafu.visible = false
    end
    -- local viewIcon = sceneData and sceneData.view_icon or ""
    -- icon.url = UIPackage.GetItemURL("boss" , tostring(viewIcon))
    local timeText = cell:GetChild("n10")--刷新时间
    timeText.text = ""
    local fubenId = sceneData.id * 1000 + 1
    local fubenData = conf.FubenConf:getPassDatabyId(fubenId)
    local model = fubenData.model
    local mConf = conf.MonsterConf:getInfoById(model)
    local name = mConf and mConf.name or ""
    local bossText = cell:GetChild("n8")
    bossText.text = name
    local lvl = sceneData and sceneData.lvl or 1
    local lvText = cell:GetChild("n7")
    local str = "LV"..lvl
    if cache.PlayerCache:getRoleLevel() >= lvl then
        lvText.text = mgr.TextMgr:getTextColorStr(str, 5)
    else
        lvText.text = mgr.TextMgr:getTextColorStr(str, 14)
    end
    local arleayImg = cell:GetChild("n4")--已刷新
    local unAppear = cell:GetChild("n5")--未出现
    arleayImg.visible = false
    unAppear.visible = false
    cell.data = {data = sceneData, index = index, model = model}
end
--掉落奖励
function XianzunBossPanel:cellAwardsData(index,cell)
    local awardData = self.awards[index + 1]
    local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
    GSetItemData(cell, itemData, true)
end

--选中boss
function XianzunBossPanel:onClickItem(context)
    local cell = context.data
    local change = cell.data
    local sceneData = change.data
    self.sceneId = sceneData.id
    local lvl = sceneData.lvl or 1
    cache.FubenCache:setXzBossIndex(change.index)
    self:addBossModel(change.model)

    local confData = conf.FubenConf:getBossXianzhunLayer(self.sceneId)
    local cons = confData and confData.con or {}
    local xianZun = cons[1] or 1
    self.desc.text = string.format(language.fuben166, language.fuben124[xianZun])
end

function XianzunBossPanel:addBossModel(model)
    local mConf = conf.MonsterConf:getInfoById(model)
    self.mosterId = model
    local name = mConf and mConf.name or ""
    self.awards = mConf and mConf.normal_drop or {}
    self.listAwardsList.numItems = #self.awards
    local src = mConf and mConf.src or 0
    local modelObj = self.mParent:addModel(src,self.modelPanel)--添加模型
    modelObj:setPosition(self.modelPanel.actualWidth/2,-self.modelPanel.actualHeight-200,500)
    modelObj:setRotation(180)
    modelObj:setScale(100)
end

function XianzunBossPanel:onClickWar()
    --先判断等级
    local sceneConfig = conf.SceneConf:getSceneById(self.sceneId)
    local lvl = sceneConfig and sceneConfig.lvl or 1
    local playLv = cache.PlayerCache:getRoleLevel()
    if playLv < lvl then
        GComAlter(string.format(language.gonggong07, lvl))
        return
    end
    --再判断仙尊等级
    local confData = conf.FubenConf:getBossXianzhunLayer(self.sceneId)
    local cons = confData and confData.con or {}
    local notXianzun = true
    for k,v in pairs(cons) do
        if cache.PlayerCache:VipIsActivate(tonumber(v)) then--拥有了其中一个仙尊
            notXianzun = false
            break
        end
    end
    if notXianzun then--
        local xianZun = cons[1] or 1
        local param = {type = 14,richtext = mgr.TextMgr:getTextColorStr(string.format(language.fuben125, language.fuben124[xianZun]), 6),sure = function()
            GOpenView({id = 1050})
        end}
        GComAlter(param)
        return
    end
    if self.leftTimes <= 0 then--判断次数是否足够
        -- local money = conf.SysConf:getValue("xianzun_boss_buy_times")
        -- local param = {}
        -- param.type = 14
        -- param.richtext = mgr.TextMgr:getTextColorStr(string.format(language.fuben120, money,self.leftBuyCount), 6)
        -- param.okUrl = UIItemRes.imagefons04
        -- param.sure = function()
        --     proxy.FubenProxy:send(1440102,{reqType = 1})
        -- end  
        GComAlter("剩余次数不足！")
        return
    end
    
    local str = clone(language.fuben121)
    local item = conf.SysConf:getValue("xianzun_boss_admission_ticket")[1]
    local itemData = {mid = item[1],amount = item[2],bind = item[3]}
    local name = conf.ItemConf:getName(item[1])
    str[2].text = string.format(str[2].text, item[2])
    local money = conf.SysConf:getValue("xianzun_boss_buy_admission_ticket")
    str[4].text = string.format(str[4].text, money)
    local param = {type = 17,richtext = mgr.TextMgr:getTextByTable(str),okUrl = UIItemRes.imagefons01,itemData = itemData,sure = function()
        local packData = cache.PackCache:getPackDataById(item[1])--判断入场卷是否足够
        if packData.amount >= item[2] then
            mgr.FubenMgr:gotoFubenWar2(self.sceneId)
            return
        end
        local bindYb = cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
        local yb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
        if yb >= money or bindYb >= money then
            mgr.FubenMgr:gotoFubenWar2(self.sceneId)
        else
            GComAlter(language.gonggong100)
        end
    end}
    GComAlter(param)
end

function XianzunBossPanel:onClickAdd()

    if  self.leftBuyCount <= 0  then--判断次数是否足够
         GComAlter("剩余次数不足！")
         return
    end
    print(self.buyTimes)
    local money = conf.SysConf:getValue("xianzun_boss_buy_cost")[self.buyTimes]
    local param = {type = 14,richtext = mgr.TextMgr:getTextColorStr(string.format(language.fuben119, money,self.leftBuyCount), 6),okUrl = UIItemRes.imagefons04,sure = function()
        proxy.FubenProxy:send(1440102,{reqType = 1})    
    end}
    GComAlter(param)
end

function XianzunBossPanel:onClickXianshi()
    if self.mosterId > 0 then
        mgr.ViewMgr:openView2(ViewName.BossCCAwardsView, {mosterId = self.mosterId})
    end
end

function XianzunBossPanel:clear()
    self.mosterId = 0
    self.bgImg.url = ""
    self.listView.numItems = 0
end

return XianzunBossPanel