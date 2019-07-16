--
-- Author: 
-- Date: 2017-11-28 19:44:28
--
--主宰神殿
local DecideFanePanel = class("DecideFanePanel", import("game.base.Ref"))

function DecideFanePanel:ctor(panelObj)
    self:initPanel(panelObj)
end

function DecideFanePanel:initPanel(panelObj)
    self.bg = panelObj:GetChild("n0")
    self.listView = panelObj:GetChild("n4")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.model = panelObj:GetChild("n8")--模型

    self.xqModel = panelObj:GetChild("n18")
    self.fbModel = panelObj:GetChild("n19")

    self.xmbzText = panelObj:GetChild("n14")--仙盟霸主

    self.mzNameText = panelObj:GetChild("n16")--盟主名字

    self.xiuxianIcon = panelObj:GetChild("n7")--修仙icon

    self.winCountText = panelObj:GetChild("n17")--连胜次数

    local winAwardBtn = panelObj:GetChild("n10")--连胜奖励
    self.winAwardRed = winAwardBtn:GetChild("red")
    winAwardBtn.onClick:Add(self.onClickWinAward,self)
    local winEndBtn = panelObj:GetChild("n11")--连胜终结
    self.winEndBtnRed = winEndBtn:GetChild("red")
    winEndBtn.onClick:Add(self.onClickWinEnd,self)

    panelObj:GetChild("n15").text = language.xmhd08

    local selectBtn = panelObj:GetChild("n12")--查看赛事
    selectBtn.onClick:Add(self.onClickSelect,self)
    local receiveBtn = panelObj:GetChild("n13")--领取俸禄
    self.receiveBtn = receiveBtn
    receiveBtn.onClick:Add(self.onClickReceive,self)
end
--信息返回
function DecideFanePanel:setData(data)
    self.mData = data
    self:refreshRedPoint()
    local firstGangName = data.firstGangName
    if firstGangName == "" then firstGangName = language.rank03 end
    if tostring(cache.PlayerCache:getGangId()) == tostring(data.firstGangId) then
        self.isZzXm = true
    else
        self.isZzXm = false
    end
    self.xmbzText.text = firstGangName
    self:setWinTimes()
    self.listView.numItems = 2
    if data.reqType == 1 then
        self.bg.url = UIItemRes.bangpai03
        self:setMzInfo()
    else
        GOpenAlert3(data.items)
    end
end

function DecideFanePanel:refreshRedPoint()
    local redObj = self.receiveBtn:GetChild("red")
    local redNum = 0
    if self.mData.flGot == 1 then--俸禄是否已领取 1:已领取
        self.receiveBtn.enabled = false
        self.receiveBtn.icon = UIItemRes.gonggong01
        redObj.visible = false
    else
        if cache.PlayerCache:getRedPointById(attConst.A20154) > 0 then
            redObj.visible = true
            redNum = redNum + 1
        else
            redObj.visible = false
        end
        self.receiveBtn.icon = UIItemRes.xmhd09
        self.receiveBtn.enabled = true
    end
    if self.mData.killFp == 1 then
        redNum = redNum + 1
        self.winEndBtnRed.visible = true
    else
        self.winEndBtnRed.visible = false
    end
    if self.mData.winFp == 1 then
        redNum = redNum + 1
        self.winAwardRed.visible = true
    else
        self.winAwardRed.visible = false
    end
    cache.PlayerCache:setRedpoint(attConst.A20154, redNum)
end
--分配返回
function DecideFanePanel:addMsgFpCallBack(data)
    self.mData.isFp = data.isFp
    self.mData.winTimes = data.winTimes
    self.mData.winFp = data.winFp or self.mData.winFp
    self.mData.killFp = data.killFp or self.mData.killFp
    self:setWinTimes() 
    self:refreshRedPoint()
end

function DecideFanePanel:setWinTimes()
    self.winCountText.text = language.xmhd10..mgr.TextMgr:getTextColorStr(self.mData.winTimes, 4)
end

function DecideFanePanel:setMzInfo()
    local showRole = self.mData.showRole
    local roleName = showRole.roleName
    if roleName == "" then roleName = language.rank03 end
    self.mzNameText.text = roleName
    self.xiuxianIcon.url = ""
    -- if #showRole.skins <= 0 then return end

    local activeLv = showRole.skins[Skins.activeTitle] or 0--修仙等级
    local xxConfData = conf.ImmortalityConf:getAttrDataByLv(activeLv)
    local nameImg = xxConfData and xxConfData.name_img or ""
    self.xiuxianIcon.url = UIPackage.GetItemURL("head" , nameImg)

    local skins1 = showRole.skins[Skins.clothes] or ResPath.DefaultPlayer
    local skins2 = showRole.skins[Skins.wuqi] or 0
    local skins3 = showRole.skins[Skins.xianyu] or 0
    local skins5 = showRole.skins[Skins.shenbing] or 0
    
    local modelObj,cansee
    local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
    modelObj,cansee = view:addModel(skins1,self.model)
    modelObj:setSkins(nil,skins2,skins3)
    self.modelObj = modelObj
    modelObj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-300,500)
    local sex = GGetMsgByRoleIcon(showRole.roleIcon).sex or 1
    sex = math.max(0, 1)
    modelObj:setRotation(RoleSexModel[sex].angle)
    modelObj:setScale(180)
    if skins5 > 0 and skins2>0 then
        modelObj:addWeaponEct(skins5.."_ui")
    end
    --法宝
    local fbId = showRole.skins[Skins.fabao] or 0
    if self.fbEffect then
        view:removeUIEffect(self.fbEffect)
        self.fbEffect = nil
    end
    if fbId > 0 then
        local effect = view:addEffect(fbId,self.fbModel)
        effect.Scale = Vector3.New(300,300,300)
        effect.LocalPosition = Vector3(self.fbModel.actualWidth/2,-self.fbModel.actualHeight-200,1000)
        self.fbEffect = effect
    end
    --仙器
    local xqId = showRole.skins[Skins.xianqi] or 0
    if self.fbEffxqEffectect then
        view:removeUIEffect(self.xqEffect)
        self.xqEffect = nil
    end
    if xqId > 0 then
        local effect = view:addEffect(xqId,self.xqModel)
        effect.LocalPosition = Vector3(self.xqModel.actualWidth/2,-self.xqModel.actualHeight-300,500)
        self.xqEffect = effect
    end
end

function DecideFanePanel:cellData(index, obj)
    local controller = obj:GetController("c1")--主控制器
    controller.selectedIndex = index
    if index == 1 then
        local awards = conf.XmhdConf:getValue("xianmeng_first_award_daily")--第一仙盟俸禄
        obj:GetChild("n2").url = UIItemRes.xmhd10[index]
        local listView = obj:GetChild("n3")
        listView.itemRenderer = function(index, itemObj)
            local award = awards[index + 1]
            local itemData = {mid = award[1], amount = award[2], bind = award[3]}
            GSetItemData(itemObj, itemData, true)
        end
        listView.numItems = #awards
    else
        local awards1 = conf.XmhdConf:getValue("xianmeng_win_mz_tq")--盟主特权奖励
        local award = awards1[1]
        local itemData = {mid = award[1], amount = award[2], bind = award[3]}
        GSetItemData(obj:GetChild("n4"), itemData, true)
        local awards2 = conf.XmhdConf:getValue("xianmeng_win_tq")--盟员特权奖励
        local award = awards2[1]
        local itemData = {mid = award[1], amount = award[2], bind = award[3]}
        GSetItemData(obj:GetChild("n5"), itemData, true)
    end
    
end

function DecideFanePanel:onClickWinAward()
    if not self.mData then return end
    -- if not self.isZzXm then 
    --     GComAlter(language.xmhd29) 
    --     return
    -- end
    mgr.ViewMgr:openView2(ViewName.WinAwardsView, self.mData)
end

function DecideFanePanel:onClickWinEnd()
    if not self.mData then return end
    -- if not self.isZzXm then 
    --     GComAlter(language.xmhd29) 
    --     return
    -- end
    mgr.ViewMgr:openView2(ViewName.FinalWinView, self.mData)
end
--查看赛事
function DecideFanePanel:onClickSelect()
    local id = 1139
    local actConf = conf.BangPaiConf:getGangActive(id)
    local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
    if view and view.panelActivity then
        view.panelActivity:nextStep(2)
        -- view:initData({index = language.bangpai186[id],childIndex = actConf and actConf.sort or 1})
    end
end

function DecideFanePanel:onTimer()
    -- body
end

function DecideFanePanel:onClickReceive()
    if not self.isZzXm then 
        GComAlter(language.xmhd29) 
        return
    end
    proxy.XmhdProxy:send(1360202,{reqType = 2})
end

function DecideFanePanel:clear()
    self.bg.url = ""
end

return DecideFanePanel