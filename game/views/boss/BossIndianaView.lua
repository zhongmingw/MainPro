--
-- Author: 
-- Date: 2017-08-23 17:12:57
--

local BossIndianaView = class("BossIndianaView", base.BaseView)

-- local actionCounts = {[1] = 0.5,[2] = 0.5, [3] = 1}--转圈次数对应速度
 
local areaAngles = {0, 70, 150, 210, 290}--区域角度

local lastActionSpeed = 1--最后转动速度

function BossIndianaView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function BossIndianaView:initView()
    self.view:GetChild("n4").text = language.fuben99
    local closeBtn = self.view:GetChild("n5")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.blackView.onClick:Add(self.onClickClose,self)
    self.itemIcons = {}
    for i=6,10 do
        local icon = self.view:GetChild("n"..i)
        table.insert(self.itemIcons, icon)
    end

    self.countLists = {}
    for i=11,15 do
        local text = self.view:GetChild("n"..i)
        table.insert(self.countLists, text)
    end

    self.arrow = self.view:GetChild("n1")--旋转箭头

    self.indianaBtn = self.view:GetChild("n2")
    self.indianaBtn.onClick:Add(self.onClickIndiana,self)
end

function BossIndianaView:initData()
    proxy.FubenProxy:send(1330304,{reqType = 0, stage = 0})
end

function BossIndianaView:setData(data)
    self.mData = data
    if data.reqType == 1 then--抽奖
        self.count = 1
        self:playAction()
    else
        self:setInfoData()
    end
end

function BossIndianaView:setInfoData()
    local count = 0
    for k,v in pairs(self.mData.leftCounts) do
        if v > 0 then
            count = count + 1
        end
    end
    if count > 0 then
        self.indianaBtn.enabled = true
    else
        self.indianaBtn.enabled = false
    end
    self:setAwardsData()
end
--设置奖励信息
function BossIndianaView:setAwardsData()
    local sceneId = cache.PlayerCache:getSId()
    local type = 3
    local view = mgr.ViewMgr:get(ViewName.BossHpView)
    if view then
        if view:getBossPercent() >= 0.5 then
            type = 3
        else
            type = 4
        end
    else
        type = 4
    end
    if self.mData.leftCounts[1] and self.mData.leftCounts[1] > 0 then--50%夺宝
        type = 3
    elseif self.mData.leftCounts[2] and self.mData.leftCounts[2] > 0 then--100%夺宝
        type = 4
    end
    local confData = conf.FubenConf:getWorldAward(sceneId,type)
    for k,v in pairs(confData.items) do
        local icon = self.itemIcons[k]
        if icon then
            local src = conf.ItemConf:getSrc(v[1])
            icon.url = ResPath.iconRes(tostring(src))
        end
        local text = self.countLists[k]
        if text then
            text.text = "x"..v[2]
        end
    end
end
--执行动作
function BossIndianaView:playAction()
    local callback = function( ... )
        self.indianaBtn.enabled = true
        -- printt("self.mData.items",self.mData.items)
        GOpenAlert3(self.mData.items)--弹窗奖励
        self:setInfoData()
    end
    self.indianaBtn.enabled = false
    if g_var.gameFrameworkVersion >= 3 then
        UTransition.TweenRotate(self.arrow, 360 * 3, 2, true, function()
            self.arrow.rotation = 0
            local index = self.mData.index + 1
            if index == 1 then
                callback()
            else
                if g_var.gameFrameworkVersion >= 3 then
                    UTransition.TweenRotate(self.arrow, areaAngles[index], lastActionSpeed, true, function()
                        callback()
                    end)
                else
                    callback()
                end
            end
        end)
    else
        callback()
    end
end

function BossIndianaView:onClickIndiana()
    if not self.mData then return end
    local stage = 1
    if self.mData.leftCounts[1] and self.mData.leftCounts[1] > 0 then--50%夺宝
        stage = 1
    elseif self.mData.leftCounts[2] and self.mData.leftCounts[2] > 0 then--100%夺宝
        stage = 2
    end
    proxy.FubenProxy:send(1330304,{reqType = 1, stage = stage})
end

function BossIndianaView:onClickClose()
    self:closeView()
end

return BossIndianaView