--
-- Author: ohf
-- Date: 2017-03-09 20:14:21
--
--副本結算界面
local FubenDekaronView = class("FubenDekaronView", base.BaseView)

local Time = 9
local effectId = 4020105--特效id

function FubenDekaronView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level4
    self.isBlack = true
end

function FubenDekaronView:initView()
    local quitBtn1 = self.view:GetChild("n10")
    self.quitBtn1 = quitBtn1
    quitBtn1.visible = false
    quitBtn1.onClick:Add(self.onClickQuit,self)
    self.huoqutujing = self.view:GetChild("n12")
    self.huoqutujing.onClick:Add(self.onHuoqutujing,self)
    self.huoqutujing.visible = false
    self.huoqutuText = self.view:GetChild("n13")
    self.huoqutuText.text = language.fuben72
    self.huoqutuText.visible = false

    self.left = self.view:GetChild("n1")
    self.right = self.view:GetChild("n2")
    self.title1 = self.view:GetChild("n5")
    self.timeText1 = self.view:GetChild("n9")
    self.timeText2 = self.view:GetChild("n11")

    self.listView = self.view:GetChild("n8")
    self.listView.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end

    self.titleIcon = self.view:GetChild("n3")
    local quitBtn2 = self.view:GetChild("n6")
    self.quitBtn2 = quitBtn2
    quitBtn2.onClick:Add(self.onClickQuit,self)
    local nextBtn = self.view:GetChild("n7")
    self.nextBtn = nextBtn
    nextBtn.onClick:Add(self.onClickNext,self)
    self.starList = {}
    for i=15,17 do
        local star = self.view:GetChild("n"..i)
        table.insert(self.starList, star)
    end
end

function FubenDekaronView:initData(data)
    self.time = Time
    self:onTimer()
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
    if gRole then
        gRole:stopAI()
        mgr.HookMgr:cancelHook()
    end
end

function FubenDekaronView:setData(data)
    self.mData = data
    printt("副本结算",data)
    local pass = self.mData.pass
    local sceneConfig = conf.SceneConf:getSceneById(data.sceneId)
    self.timeText1.visible = false
    self.timeText2.visible = false
    self.titleIcon.url = UIItemRes.fuben01
    self.title1.url = UIItemRes.fueben01[1]
    self.left.visible = true
    self.right.visible = true

    local confData = conf.FubenConf:getPassData(data.sceneId,pass + 1)
    local playLv = cache.PlayerCache:getRoleLevel()
    local openlv = confData and confData.open_lv or 1
    self.huoqutujing.visible = false
    self.huoqutuText.visible = false
    local isCanEffect = false
    if data.state == 2 or data.state == 3 then
        self.quitBtn1.visible = true
        self.quitBtn2.visible = false
        self.nextBtn.visible = false
        self.timeText2.visible = true
        self.titleIcon.url = UIItemRes.fuben02
        self.huoqutujing.visible = true
        self.huoqutuText.visible = true
        self.title1.url = UIItemRes.fueben01[2]
        self.left.visible = false
        self.right.visible = false
    elseif mgr.FubenMgr:isKuaFuTeamFuben(data.sceneId) then
        --如果是跨服组队副本
        self.quitBtn1.visible = false
        self.quitBtn2.visible = true
        self.nextBtn.visible = true
        self.timeText1.visible = true
        isCanEffect = true
        self.quitBtn1.icon = UIPackage.GetItemURL("_imgfonts" , "kuafuzhanchang_012")
        self.nextBtn.icon = UIPackage.GetItemURL("_imgfonts" , "kuafuzhanchang_013")
    elseif playLv < openlv or pass >= (sceneConfig.max_pass or 1) or (data.sceneId >= Fuben.advaned and data.sceneId < Fuben.level) then
        self.quitBtn1.visible = true
        self.quitBtn2.visible = false
        self.nextBtn.visible = false
        self.timeText2.visible = true
        isCanEffect = true
    else
        self.quitBtn1.visible = false
        self.quitBtn2.visible = true
        self.nextBtn.visible = true
        self.nextBtn.icon = UIPackage.GetItemURL("fuben" , "patafuben_026")
        self.timeText1.visible = true
        isCanEffect = true
    end
    if isCanEffect then
        self.effect = self:addEffect(effectId, self.view:GetChild("n19"))
        mgr.SoundMgr:playSound(Audios[1])
    end
    self:setStar()
    local numItems = #self.mData.items
    self.listView.numItems = numItems
    cache.FubenCache:setCurrPass(data.sceneId,pass)

    --
    if data.state == 2 or data.state == 3 then
    else
        if cache.GuideCache:getGuide() 
        and (cache.TaskCache:CheckTaskID(1075) or cache.TaskCache:CheckTaskID(1087)) then --引导退出
            cache.GuideCache:setGuide(nil)
            self:startGuide(conf.XinShouConf:getOpenModule(1084))
        end
    end
end

function FubenDekaronView:setStar()
    for k,v in pairs(self.starList) do
        if self.mData.star == 0 then
            if self.mData.state == 1 then
                v.grayed = false
            else
                v.grayed = true
            end
        else
            if k <= self.mData.star then
                v.grayed = false
            else
                v.grayed = true
            end
        end
    end
end

function FubenDekaronView:onTimer()
    local str = ""
    if self.quitBtn1.visible then
        str = string.format(language.fuben11, self.time)
    else
        if self.mData and mgr.FubenMgr:isKuaFuTeamFuben(self.mData.sceneId) then
            str = string.format(language.kuafu103, self.time)
        else
            str = string.format(language.fuben71, self.time)
        end
    end
    self.timeText1.text = str
    self.timeText2.text = str
    if self.time <= 0 then
        self:removeTimer(self.timer)
        self.timer = nil
        local view = mgr.ViewMgr:get(ViewName.GuideLayer) --引导期间不给关闭
        if view then
            return
        end
        if self.quitBtn1.visible then
            self:onClickQuit()
        else
            self:onClickNext()
        end
        return
    end
    self.time = self.time - 1
end

function FubenDekaronView:cellAwardsData(index,cell)
    local data = self.mData.items[index + 1]
    GSetItemData(cell, data)
end
--退出副本
function FubenDekaronView:onClickQuit()
    mgr.FubenMgr:quitFuben()
    self:closeView()
end

function FubenDekaronView:onHuoqutujing()
    cache.FubenCache:setFubenModular(1077)
    self:onClickQuit()
end
--挑战下一关
function FubenDekaronView:onClickNext()
    if mgr.FubenMgr:isKuaFuTeamFuben(self.mData.sceneId) then
        cache.KuaFuCache:setQuitAdd(self.mData.sceneId)
        self:onClickQuit()
        return
    end

    cache.FubenCache:setFubenModular(nil)
    mgr.HookMgr:stopHook()
    proxy.FubenProxy:send(1020104,{sceneId = self.mData.sceneId})
    self:closeView()
end

return FubenDekaronView