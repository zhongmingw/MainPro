--
-- Author: 
-- Date: 2017-07-18 17:33:46
--
--精英boss1分钟提示弹窗
local EliteBossTipView = class("EliteBossTipView", base.BaseView)

local EliteTipTime = 20

function EliteBossTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function EliteBossTipView:initView()
    self.desc = self.view:GetChild("n7")
    self.view:GetChild("n12").text = language.gonggong75
    self.timeText = self.view:GetChild("n13")
    local btnGoto = self.view:GetChild("n3")
    btnGoto.onClick:Add(self.onClickGoto,self)
    local btnClose = self.view:GetChild("n4")
    btnClose.onClick:Add(self.onClickClose,self)
end

function EliteBossTipView:initData(data)
    self.mList = {}
    self:setData(data)
    self.time = EliteTipTime
    self:setInfo()
end

function EliteBossTipView:setData(data)
    table.insert(self.mList, data)
end

function EliteBossTipView:setInfo()
    local data = self.mList[1]
    local richText = {
        {color = 7,text = data.bossName},
        {color = 6,text = language.fuben92},
    }
    self.desc.text = mgr.TextMgr:getTextByTable(richText)
    if not self.tipTimer then
        self:onTiemr()
        self.tipTimer = self:addTimer(1, -1, handler(self, self.onTiemr))
    end
end

function EliteBossTipView:releaseTimer()
    if self.tipTimer then
        self:removeTimer(self.tipTimer)
        self.tipTimer = nil
    end
end

function EliteBossTipView:onTiemr()
    self.timeText.text = mgr.TextMgr:getTextColorStr(self.time, 7)..language.tips07
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
        return
    end
    self.time = self.time - 1
end

function EliteBossTipView:onClickGoto()
    local data = self.mList[1]
    local gotoId = 0
    local modelId = 0
    if mgr.FubenMgr:isEliteBoss(data.sceneId) then--精英boss
        modelId = 1048
        gotoId = data.sceneId
    elseif mgr.FubenMgr:isWorldBoss(data.sceneId) then--世界boss
        modelId = 1049
        gotoId = data.monsterId
    elseif mgr.FubenMgr:isBossHome(data.sceneId) then--boss之家
        modelId = 1128
        gotoId = data.monsterId
    elseif mgr.FubenMgr:isXianyuJinDi(data.sceneId) then--仙域禁地
        modelId = 1135
        gotoId = data.monsterId
    elseif mgr.FubenMgr:isKuafuWorld(data.sceneId) then--跨服boss
        modelId = 1191
        gotoId = data.monsterId
    elseif mgr.FubenMgr:isKuafuXianyu(data.sceneId) then--跨服禁地
        modelId = 1221
        gotoId = data.monsterId
    elseif mgr.FubenMgr:isWuXingShenDian(data.sceneId) then--五行神殿
        modelId = 1266
        gotoId = data.monsterId
    elseif mgr.FubenMgr:isShangGuShenJi(data.sceneId) then--上古神迹
        modelId = 1242
        gotoId = data.monsterId
    elseif mgr.FubenMgr:isFsFuben(data.sceneId) then--飞升
        modelId = 1324
        gotoId = data.monsterId
    elseif mgr.FubenMgr:isShenShou(data.sceneId) then--神兽岛
        modelId = 1337
        gotoId = data.monsterId
    elseif mgr.FubenMgr:isTaiGuXuanJing(data.sceneId) then--太古玄境
        modelId = 1378
        gotoId = data.monsterId
    end
    GOpenView({id = modelId,childIndex = gotoId})
    -- if mgr.FubenMgr:isKuaFuBoss(data.sceneId) then
    --     mgr.ViewMgr:openView2(ViewName.KuaFuMainView, {index = 2,childIndex=data.sceneId})
    -- else
    --     GOpenView({id = 1048,childIndex = data.sceneId})
    -- end
    self:onClickClose()
end

function EliteBossTipView:onClickClose()
    table.remove(self.mList,1)
    if #self.mList <= 0 then
        self:releaseTimer()
        self:closeView()
    else
        self.time = EliteTipTime
        self:setInfo()
    end
end

return EliteBossTipView