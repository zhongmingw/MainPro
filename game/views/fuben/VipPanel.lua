--
-- Author: ohf
-- Date: 2017-03-06 20:32:18
--
--vip副本
local VipPanel = class("VipPanel",import("game.base.Ref"))

function VipPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function VipPanel:initPanel()
    self.confVipData = conf.FubenConf:getPassVip()
    local panelObj = self.mParent:getChoosePanelObj(1020)
    self.panelObj = panelObj
    self.listView = panelObj:GetChild("n6")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)

    self.heroPanel = panelObj:GetChild("n9")--模型触摸区域
    self.heroModel = panelObj:GetChild("n10")--放置模型区域

    self.awardsListView = panelObj:GetChild("n13")
    self.awardsListView:SetVirtual()
    self.awardsListView.itemRenderer = function(index, obj)
        self:cellAwardData(index, obj)
    end

    self.mVipText = panelObj:GetChild("n14")--我的vip
    self.vipText = panelObj:GetChild("n15")
    self.countText = panelObj:GetChild("n19")--剩余次数
    self.heroName = panelObj:GetChild("n20")

    local warBtn = panelObj:GetChild("n21")
    self.warBtn = warBtn
    self.warRed = self.warBtn:GetChild("red")
    self.warBtnImg = warBtn:GetChild("icon")
    warBtn.onClick:Add(self.onClickWar,self)

    self.sweepBtn = panelObj:GetChild("n24")--一键扫荡
    self.sweepRed = self.sweepBtn:GetChild("red")
    self.sweepBtn.onClick:Add(self.onClickSweep,self)
     if g_ios_test then
        self.sweepBtn.visible = false
    else
        self.sweepBtn.visible = true
    end
end

--添加模型
function VipPanel:addModel()
    local sex = GGetMsgByRoleIcon(cache.PlayerCache:getRoleIcon()).sex
    local skins1 = cache.PlayerCache:getSkins(1)--衣服
    local skins2 = cache.PlayerCache:getSkins(2)--武器
    local skins3 = cache.PlayerCache:getSkins(3)--仙羽
    local skins5 = cache.PlayerCache:getSkins(Skins.shenbing) --神兵
    local modelObj = self.mParent:addModel(skins1,self.heroModel)
    local cansee = modelObj:setSkins(nil,skins2,skins3)
    self.modelObj = modelObj
    modelObj:setPosition(self.heroModel.actualWidth/2,-self.heroModel.actualHeight-200,500)
    modelObj:setRotation(RoleSexModel[sex].angle)
    modelObj:modelTouchRotate(self.heroPanel,sex)
    local effect = self.mParent:addEffect(4020102,self.panelObj:GetChild("n22"))
    effect.LocalPosition = Vector3(self.heroModel.actualWidth/2,-self.heroModel.actualHeight,500)
    if skins5 > 0 and skins2>0 then
        modelObj:addWeaponEct(skins5.."_ui")
    end
    self.panelObj:GetChild("n23").visible = cansee
end

function VipPanel:setData(data)
    self.listView.numItems = 0
    self.viplv = cache.PlayerCache:getVipLv()
    self.heroName.text = cache.PlayerCache:getRoleName()
    self.mData = data
    self.mVipText.text = self.viplv
    self.mIndex = self:getIndex()
    self.listView.numItems = #self.confVipData
    self:gotoScrollView()
    self:addModel()
end

function VipPanel:cellData(index, cell)
    local lvl = index + 1
    local icon = cell:GetChild("icon")
    local data = self.confVipData[lvl]
    icon.url = UIPackage.GetItemURL("fuben" , tostring(data.view_icon))
    local sceneId = tonumber(string.sub(data.id,1,6))
    local count = self.mData.fubenIds and self.mData.fubenIds[sceneId] or 0
    local redPanel = cell:GetChild("n8")--红点
    if count > 0 then
        icon.grayed = false
        redPanel.visible = true
    else
        icon.grayed = true
        redPanel.visible = false
    end
    local text = cell:GetChild("n6")
    text.text = tonumber(string.sub(data.id,4,6))
    cell.data = data
    if lvl == self.mIndex then
        cell.selected = true
        local context = {data = cell}
        self:onClickItem(context)
    end
end

function VipPanel:getIndex()
    local index = 1
    for k,v in pairs(self.confVipData) do
        local sceneId = tonumber(string.sub(v.id,1,6))
        local count = self.mData.fubenIds and self.mData.fubenIds[sceneId]
        if count and count > 0 then
            index = k
            break
        end
    end
    return index
end

function VipPanel:gotoScrollView()
    self.listView:ScrollToView(self.mIndex - 1)
end

function VipPanel:onClickItem(context)
    self.awards = {}
    local cell = context.data
    local data = cell.data
    if not data or (data and not data.id) then return end
    local lvl = tonumber(string.sub(data.id,4,6))
    self.vipText.text = lvl
    local sceneId = tonumber(string.sub(data.id,1,6))
    self.sceneId = sceneId
    local count = self.mData.fubenIds and self.mData.fubenIds[sceneId] or 0
    if self.viplv < lvl then
        local sceneConfig = conf.SceneConf:getSceneById(sceneId)
        self.countText.text = sceneConfig.max_over_count or 1
    else
        self.countText.text = count or 0
    end
    if count > 0 then
        self.warBtnImg.url = UIItemRes.vipFuben02[1]
        self.warBtn.enabled = true
        self.warRed.visible = true
        if self.viplv >= lvl then 
            self.sweepBtn.enabled = true
            self.sweepRed.visible = cache.PlayerCache:VipIsActivate(2) 
        else
            self.sweepRed.visible = false
        end
    else
        self.warRed.visible = false
        self.sweepRed.visible = false
        if self.viplv < lvl then 
            self.warBtn.enabled = true
            self.warBtnImg.url = UIItemRes.vipFuben02[1]
        else
            self.sweepBtn.enabled = false
            self.warBtn.enabled = false
            self.warBtnImg.url = UIItemRes.vipFuben02[2]
        end
    end
    local drop = data and data.normal_drop or {}
    self.awards = clone(drop)
    local vipRatio = data and data.pass_exp_coef or 1
    local expArgs = conf.FubenConf:getValue("vip_fuben_exp_arg")
    local amount = (expArgs[1]*cache.PlayerCache:getRoleLevel()+expArgs[2])*vipRatio
    local expData = {221061001,amount,1}
    table.insert(self.awards, expData)
    self.awardsListView.numItems = #self.awards
end

function VipPanel:cellAwardData(index, cell)
    local awards = self.awards[index + 1]
    local data = {mid = awards[1],amount = awards[2],bind = awards[3]}
    GSetItemData(cell, data, true)
end

function VipPanel:onClickWar()
    if not self.sceneId then return end 
    local lvl = tonumber(string.sub(self.sceneId,4,6))
    if self.viplv < lvl then
        if g_ios_test then    --EVE 屏蔽处理，提示字符更改
            GComAlter(language.gonggong76)
        else
            GComAlter(language.gonggong27)
        end
        return
    elseif self.mData.fubenIds and not self.mData.fubenIds[self.sceneId] then
        GComAlter(language.fuben17)
        return
    end
    mgr.FubenMgr:gotoFubenWar(self.sceneId)
end

--一键扫荡
function VipPanel:onClickSweep()
    if not self.mData then
        return
    end
    local mPassId = self.sceneId * 1000 + 1 
    local confData = conf.FubenConf:getFubenSweepCost(mPassId)
    local sweepLv = confData and confData.lev or 1
    local vipLv = cache.PlayerCache:getVipLv()
    if vipLv == 0 then
        GComAlter(language.gonggong27) 
        return 
    end
    if cache.PlayerCache:getRoleLevel() >= sweepLv or vipLv >= 2 then
        proxy.FubenProxy:send(1027107,{ids = {}})  
    else
         GComAlter(string.format(language.fuben196,sweepLv))
    end

end

function VipPanel:clear()
    self.listView.numItems = 0
end

return VipPanel