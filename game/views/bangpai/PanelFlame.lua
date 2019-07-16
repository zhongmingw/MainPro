--
-- Author: EVE 
-- Date: 2017-10-12 20:27:45
-- DESC：圣火

local PanelFlame = class("PanelFlame",import("game.base.Ref")) --"PanelFlame", base.BaseView

function PanelFlame:ctor(panelObj,mPanent)
    -- self.super.ctor(self)
    self.view = panelObj
    self.mPanent = mPanent
    -- self.mPanent = param
    -- self.uiLevel = UILevel.level3 
    self:initView()
end

function PanelFlame:initView()
    --圣火奖励显示
    local flameRewardList = self.view:GetChild("n4") 
    GSetAwards(flameRewardList,conf.BangPaiConf:getFlameAward())
    --开启等级
    self.openLv = self.view:GetChild("n11")
    self.openLv.text = language.bangpai153
    --活动时间
    self.activeTime = self.view:GetChild("n12")
    self.activeTime.text = string.format(language.bangpai154,
        mgr.TextMgr:getTextColorStr(language.bangpai155, 5))
    --提示tips
    local tipsBtn = self.view:GetChild("n7")
    tipsBtn.onClick:Add(self.onTipsBtn, self)
    --@钟铭 返回驻地入口
    self.returnBtn = self.view:GetChild("n3")
    self.returnBtn.onClick:Add(self.onReturnBtn, self)
    --仙盟boss模型
    self.modelPos = self.view:GetChild("n15")
    --喂养
    local feedBtn = self.view:GetChild("n22")
    feedBtn.onClick:Add(self.onFeedBtn, self)
    self.feedBtn = feedBtn
    --喂养boss奖励显示
    self.bossRewardList = self.view:GetChild("n26") 
    --boss名称
    self.bossName = self.view:GetChild("n23")
    self.bossName.text = ""
    --喂养红点
    -- self:initData()
end

function PanelFlame:initData()
    -- print("PanelFlame~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    --喂养红点
    local param = {} 
    param.panel = self.feedBtn:GetChild("red")
    param.ids = {10251}
    mgr.GuiMgr:registerRedPonintPanel(param,"bangpai.BangPaiMain.1")
end

-- 返回仙盟驻地
function PanelFlame:onReturnBtn()
    local sceneId = cache.PlayerCache:getSId() 
    -- print("当前场景ID~",sceneId)
    local sceneConf = conf.SceneConf:getSceneById(230001)
    local roleLv = cache.PlayerCache:getRoleLevel()
    -- print("人物等级",roleLv,sceneConf.lvl)
    if sceneId == 230001 then 
        GComAlter(language.bangpai158)
    elseif roleLv < sceneConf.lvl then
        GComAlter(string.format(language.guide07,sceneConf.lvl))
    else
        proxy.ThingProxy:sChangeScene(230001,0,0,3,1) --切换场景
    end 
end

function PanelFlame:onTipsBtn()
    GOpenRuleView(1048)
end

--设置模型
function PanelFlame:setModel(modelConf,modelPos)
    local modelObj = self.mPanent:addModel(modelConf, modelPos)--添加模型
    modelObj:setPosition(modelPos.actualWidth/2-50,-modelPos.actualHeight-200,500)
    modelObj:setRotation(180)
    modelObj:setScale(80)
end

function PanelFlame:onFeedBtn()
    proxy.BangPaiProxy:send(1250502,{reqType=1})
    local view = mgr.ViewMgr:get(ViewName.FeedBoss)   --ViewName.FeedBoss
    if not view then 
        mgr.ViewMgr:openView2(ViewName.FeedBoss,self.data)
    end 
end

--这个函数用于接收请求的BOSS信息，消息号：1250502
function PanelFlame:setData(data)
    -- printt(data)
    -- print("菊花残满腚伤,你的笑容已泛黄~~")

    self.data = data

    local curBossInfor = self:getConfData(self.data.curLevel)

    -- print("BOSS id:",curBossInfor.monster[1])

    local confData = conf.MonsterConf:getInfoById(curBossInfor.monster[1])

    GSetAwards(self.bossRewardList,confData.normal_drop) --BOSS奖励

    self.bossName.text = string.format(language.bangpai161, self.data.curLevel,confData.name) --BOSS名字

    self:setModel(confData.src,self.modelPos) --设置BOSS模型

    --仙盟圣火红点
    if GIsXianMengFlameTime() then
        self.returnBtn:GetChild("red").visible = true
    else
        self.returnBtn:GetChild("red").visible = false
    end
    self:initData()
end

function PanelFlame:getConfData(curLv)
    local confGangData = conf.BangPaiConf:getExpAndRewardById(curLv)
    return confGangData
end

function PanelFlame:onTimer()
    
end
function PanelFlame:clear()
    
end

return PanelFlame