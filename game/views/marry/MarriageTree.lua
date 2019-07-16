--
-- Author: 
-- Date: 2017-08-14 14:37:45
--

local MarriageTree = class("MarriageTree",import("game.base.Ref"))

function MarriageTree:ctor(mParent)
    self.mParent = mParent
    self.oldStep = 0--记录就阶数
    self.view = self.mParent.view:GetChild("n8")
    self:initView()
end

function MarriageTree:initView()
    self.view:GetChild("n5").text = language.marryiage09
    self.view:GetChild("n7").text = language.marryiage10
    self.view:GetChild("n8").text = mgr.TextMgr:getTextByTable(language.marryiage11)
    --self.countText = self.view:GetChild("n9")--今日剩余次数

    self.jieImg = self.view:GetChild("n10")--姻缘树阶
    self.treeName = self.view:GetChild("n11")--姻缘树名字
    self.seedObj = self.view:GetChild("n4")--种子
    self:setDailySeed()
    self.getBtn = self.view:GetChild("n6")
    self.redGet = self.getBtn:GetChild("red")
    self.getBtn.onClick:Add(self.onClickGet,self)
    self.icon = self.view:GetChild("n12")
    self.iconxy = self.icon.xy

    local treeBtn = self.view:GetChild("n17")--种树流程
    treeBtn.title = language.marryiage21
    treeBtn.onClick:Add(function( ... )
        mgr.ViewMgr:openView2(ViewName.TreeExplainView, {})
    end, self)

    self.view:GetChild("n18").text = language.kuafu148--

    local attiPanel = self.view:GetChild("n3")
    self.attiList = {}
    for i=14,20 do
        local atti = attiPanel:GetChild("n"..i)
        if i == 17 or i == 18 or i == 19 or i == 20 then  --EVE 后四条属性显示不需要了
            atti.scaleX = 0
        end  
        table.insert(self.attiList, atti)
    end
    local attiData = GAllAttiData()
    for k,v in pairs(attiData) do
        self.attiList[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
    end
    self.starItem = attiPanel:GetChild("n27")
    self.progressBar = attiPanel:GetChild("n5")

    self.itemObj = attiPanel:GetChild("n35")--需要的道具
    self.itemName = attiPanel:GetChild("n21")--道具名字
    self.itemCount = attiPanel:GetChild("n22")
    local buyBtn = attiPanel:GetChild("n11")--道具购买
    buyBtn.onClick:Add(self.onClickBuy,self)

    local advBtn = attiPanel:GetChild("n6")--进阶
    advBtn.onClick:Add(self.onClickAdv,self)
    self.advBtn = advBtn
    self.advRed = advBtn:GetChild("red")
    local advBtnAuto = attiPanel:GetChild("n48")--EVE 自动进阶
    advBtnAuto.onClick:Add(self.onClickAdvAuto,self)
    self.advBtnAuto = advBtnAuto
    self.advRedAuto = advBtnAuto:GetChild("red")

    local jhBtn = attiPanel:GetChild("n42")
    self.redJh = jhBtn:GetChild("red")
    jhBtn.onClick:Add(self.onClickAdv,self)


    self.maxCtrl = attiPanel:GetController("c1")
    self.treeJhlev = conf.MarryConf:getValue("tree_jh_lev")
    self.qyData = conf.MarryConf:getQingyuanItem(self.treeJhlev)
    attiPanel:GetChild("n43").text = string.format(language.marryiage16, self.qyData.step,self.qyData.star)

    self.effectModel = self.view:GetChild("n13")
    local ruleBtn = attiPanel:GetChild("n38")
    ruleBtn.onClick:Add(self.onClickRule,self)

    self.radio = attiPanel:GetChild("n46")
    self.radiotile = attiPanel:GetChild("n47")
    self.radiotile.text = language.marryiage22

    attiPanel:GetChild("n45").visible = false
    self.radio.visible = false
    self.radiotile.visible = false
end
--[[
1   
int32
变量名：treeLev 说明：姻缘树等级
2   
int32
变量名：power   说明：战力
3   
int8
变量名：reqType 说明：0:查看 1:升级 2:领取种子
4   
array<SimpleItemInfo>
变量名：items   说明：种子奖励
5   
int8
变量名：isGot   说明：今日是否已领取 1:已领取
]]
function MarriageTree:addMsgCallBack(data)
    self.mData = data

    
    
    if data.isGot == 1 then
        self.getBtn.enabled = false
        self.redGet.visible = false
    else
        self:refreshRed()
        self.getBtn.enabled = true
    end
    -- local strTab = clone(language.marryiage12)
    -- strTab[2].text = string.format(strTab[2].text, data.plantCount)
    -- self.countText.text = mgr.TextMgr:getTextByTable(strTab)--今日剩余次数

    local id = data.treeLev
    local attiData = conf.MarryConf:getTreeItem(id)
    local t = GConfDataSort(attiData)--属性加成
    for k,v in pairs(t) do
        self.attiList[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
    end

    self:setDownData()
    conf.MarryConf:getQingyuanItem(id)

    local redNum = cache.PlayerCache:getRedPointById(attConst.A10247)
    --红点刷新一下
    if not self.redGet.visible and not self.advRed.visible  then
        mgr.GuiMgr:redpointByID(attConst.A10247,redNum)
    end
    if not self.redGet.visible and not self.advRedAuto.visible then 
        mgr.GuiMgr:redpointByID(attConst.A10247,redNum)
    end

    -- print(data.reqType,self.radio.selected)
    if data.reqType == 0 then --查看
        self.radio.selected = false
    elseif data.reqType == 1 then --升级
        if self.radio.selected then
            self.advBtn.onClick:Call()
        end
    end
end

function MarriageTree:refreshRed()
    local redNum = cache.PlayerCache:getRedPointById(attConst.A10247)
    if redNum > 0 then
        self.redGet.visible = true
    end
end
--每日种子
function MarriageTree:setDailySeed()
    local item = conf.MarryConf:getValue("marry_seed_daily")[1]
    local itemData = {mid = item[1],amount = item[2],bind = item[3]}
    GSetItemData(self.seedObj, itemData, true)
end

function MarriageTree:setDownData()
    local treeLev = self.mData.treeLev
    local confData = conf.MarryConf:getTreeItem(treeLev)
    local ctrl = self.starItem:GetController("c1")
    local star = confData and confData.star or 0
    if self.mData.reqType == 1 or star == 0 then
        if self.oldStar ~= star then
            ctrl.selectedIndex = star
        end
    else
        ctrl.selectedIndex = star + 10
    end
    self.oldStar = star
    local names = conf.MarryConf:getValue("marry_tree_name")--姻缘树名字
    local imgs = conf.MarryConf:getValue("tree_image")--姻缘树名字
    local step = confData and confData.step or 1
    self.jieImg.url = UIItemRes.jieshu[step]
    self.treeName.text = names[step]
    self.icon.url = UIPackage.GetItemURL("marry" , imgs[step][1])
    self.icon.x = self.iconxy.x + imgs[step][2]
    self.icon.y = self.iconxy.y + imgs[step][3]
    local scale = imgs[step][4] or 1
    self.icon:SetScale(scale,scale)

    self.progressBar.value = self.mData.curExp
    self.progressBar.max = confData and confData.need_exp or 0

    if self.oldStep ~= step then
        local effects = conf.MarryConf:getValue("tree_effects")
        if self.effect then
            self.mParent:removeUIEffect(self.effect)
            self.effect = nil
        end
        self.effect = self.mParent:addEffect(effects[step], self.effectModel)
    end
    self.oldStep = step

    local confData = conf.MarryConf:getTreeItem(treeLev)
    local nextData = conf.MarryConf:getTreeItem(treeLev + 1)
    local itemCost = confData and confData.item_cost
    if treeLev > 0 then
        if nextData then
            self.maxCtrl.selectedIndex = 0
            local mId = itemCost[1]
            local amount = itemCost[2]
            self.proData = {mid = mId,amount = amount,bind = itemCost[3]}
            GSetItemData(self.itemObj, self.proData, true)
            local color = conf.ItemConf:getQuality(mId)
            local name = conf.ItemConf:getName(mId)
            self.itemName.text = mgr.TextMgr:getQualityStr1(name,color)
            local packData = cache.PackCache:getPackDataById(mId)

            local difference = packData.amount - amount --EVE 字体颜色的设置
            if difference >= 0 then 
                self.itemCount.text = packData.amount.."/"..amount
            else
                self.itemCount.text = mgr.TextMgr:getTextColorStr(tostring(packData.amount), 14).."/"..amount           
            end 

            if packData.amount >= amount then
                self.advRed.visible = true
                self.advRedAuto.visible = true
            else
                self.advRed.visible = false
                self.advRedAuto.visible = false
            end
        else
            self.maxCtrl.selectedIndex = 1
        end
    else
        if self.mData.qyLev >= self.treeJhlev then
            self.redJh.visible = true
        else
            self.redJh.visible = false
        end
        self.maxCtrl.selectedIndex = 2
    end
    --没结婚也显示bxp
    -- if cache.PlayerCache:getCoupleName()== "" then
    --     self.maxCtrl.selectedIndex = 3 
    -- end
end

function MarriageTree:onClickGet()
    local treeSeedLev = conf.MarryConf:getValue("tree_seed_lev")
    if self.mData.qyLev < treeSeedLev then
        local qyData = conf.MarryConf:getQingyuanItem(treeSeedLev)
        GComAlter(string.format(language.marryiage17, qyData.step,qyData.star))
        return
    end
    proxy.MarryProxy:sendMsg(1390204,{reqType = 2})
end

function MarriageTree:onClickBuy()
    if self.proData then
        GGoBuyItem(self.proData)
    end
end

function MarriageTree:onClickAdv()
    if not self.mData then return end
    if self.mData.qyLev < self.treeJhlev then
        GComAlter(string.format(language.marryiage16, self.qyData.step,self.qyData.star))
        return
    end
    proxy.MarryProxy:sendMsg(1390204,{reqType = 1})
end
--EVE 自动进阶
function MarriageTree:onClickAdvAuto()
    self.radio.selected = true
    self:onClickAdv()
end

function MarriageTree:onClickRule()
    GOpenRuleView(1042)
end

function MarriageTree:clear()
    self.oldStep = 0
end

return MarriageTree