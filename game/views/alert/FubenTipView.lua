--
-- Author: 
-- Date: 2017-06-07 17:40:10
--
--副本攻打提示界面
local FubenTipView = class("FubenTipView", base.BaseView)

local Time = 20

function FubenTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function FubenTipView:initData(data)
    self:releaseTimer()
    self.mData = {}
    self:setData(data)
end

function FubenTipView:initView()
    self.titleText = self.view:GetChild("n4")
    self.msgText = self.view:GetChild("n7")
    self.timeText = self.view:GetChild("n6")
    local btn1 = self.view:GetChild("n1")
    btn1.onClick:Add(self.onClickGoto,self)
    local btn2 = self.view:GetChild("n2")
    btn2.onClick:Add(self.onClickClose,self)
end

function FubenTipView:setData(data)
    local list = {}
    for k1,v1 in pairs(data) do
        local isFind = false
        for k2,v2 in pairs(self.mData) do
            if v1 == v2 then
                isFind = true
            end
        end
        if not isFind then
            table.insert(list, v1)
        end
    end
    for k,v in pairs(list) do
        table.insert(self.mData, v)
    end
    self:setPassData()
end

function FubenTipView:releaseTimer()
    if self.tipTimer then
        self:removeTimer(self.tipTimer)
        self.tipTimer = nil
    end
end

function FubenTipView:onTimer()
    self.timeText.text = mgr.TextMgr:getTextColorStr(self.time, 7)..language.tips07
    if mgr.FubenMgr:checkScene() then
        self:releaseTimer()
        self:closeView()
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:onClickClose()
        return
    end
    self.time = self.time - 1
end
--设置数据
function FubenTipView:setPassData()
    if #self.mData <= 0 then
        self:closeView()
        return
    end
    local fubenId = self.mData[1]
    local sId = tonumber(string.sub(fubenId,1,6))
    self.sceneId = sId
    local pass = tonumber(string.sub(fubenId,7,9))
    local sceneData = conf.SceneConf:getSceneById(sId)
    local name = sceneData and sceneData.name or ""
    self.titleText.text = language.tips02
    if sId == Fuben.tower then
        self.msgText.text = string.format(language.tips04, name).."："..mgr.TextMgr:getTextColorStr(pass, 7)..language.tips05
    elseif sId == Fuben.exp then
        self.msgText.text = string.format(language.tips04, name).."："..mgr.TextMgr:getTextColorStr(pass, 7)..language.tips06
    elseif sId >= Fuben.plot and sId < (Fuben.plot + PassLimit) then
        self.msgText.text = string.format(language.tips04, name)
    else--等级提示的副本
        self.msgText.text = string.format(language.tips04, name)
        self.titleText.text = language.tips03
    end
    if not self.tipTimer then
        self.time = Time
        self:onTimer()
        self.tipTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end
--跳转到指定的副本
function FubenTipView:onClickGoto()
    -- local index = language.fuben14[mod]
    if self.sceneId >= Fuben.advaned and self.sceneId < (Fuben.advaned + PassLimit) then--进阶副本
        local index = tonumber(string.sub(self.sceneId,6,6))
        cache.FubenCache:setAdvIndex(index - 1)
    end
    local sId = mgr.FubenMgr:getSIdModular(self.sceneId)
    local mod = language.fuben13[sId]
    GOpenView({id = mod})
    self:releaseTimer()
    if #self.mData <= 0 then
        self:closeView()
        return
    end
    table.remove(self.mData,1)
    self:setPassData()
end

function FubenTipView:onClickClose()
    local sId = mgr.FubenMgr:getSIdModular(self.sceneId)
    cache.FubenCache:setNotTipFubens(sId)
    table.remove(self.mData,1)
    self:releaseTimer()
    if #self.mData <= 0 then
        self:closeView()
        return
    end
    self:setPassData()
end

return FubenTipView