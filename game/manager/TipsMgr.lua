--
-- Author: ohf
-- Date: 2017-01-09 10:48:03
--
--提示飘字管理
local TipsMgr = class("TipsMgr")

local DanMuY = {0,30,60,90,120,150,180,210,240}
math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))


local CENTER = 1--中间飘字
local RIGHT = 2--右下角飘字
local DANMU = 3--弹幕

function TipsMgr:ctor()
    self.objCenterPools = {}
    self.tipsCenterList = {}--中间飘字库
    self.objRightPools = {}
    self.tipsRightList = {}--右下角飘字库
    self.objDanMuPools = {}
    self.tipsDanMuList = {}--弹幕

end
----添加中间公告道具飘字{text="test"}
function TipsMgr:addCenterTip(info)
    self.centerTime = Time.getTime()
    table.insert(self.tipsCenterList, info)
    if not self.tipsCenterTimer then
        self.tipsCenterTimer = mgr.TimerMgr:addTimer(0.5, -1, handler(self, self.updateCenter), "TipsMgr updateCenter")
    end
end
--添加右下角道具飘字 info = {text="test", count=5, color = 1}
function TipsMgr:addRightTip(info)
    self.rightTime = Time.getTime()
    table.insert(self.tipsRightList, info)
    if not self.tipsRightTimer then
         --bxp屏蔽情人节的抽奖飘字
        if not cache.ActivityCache:getValentineRallfe() then
            self.tipsRightTimer = mgr.TimerMgr:addTimer(0.25, -1, handler(self, self.updateRight), "TipsMgr updateRight")
        end
    end
end

function TipsMgr:addDanMuTip(info)
    self.danMuTime = Time.getTime()
    table.insert(self.tipsDanMuList,info)
    if not self.tipsDanMuTimer then
        self.tipsDanMuTimer = mgr.TimerMgr:addTimer(0.5, -1, handler(self, self.updateDanMu), "TipsMgr updateDanMu")
    end
end
--中间的飘字
function TipsMgr:updateCenter()
    if Time.getTime() - self.centerTime >= TipsTime then
        self.tipsCenterList = {}
        if self.tipsCenterTimer then
            mgr.TimerMgr:removeTimer(self.tipsCenterTimer)
            self.tipsCenterTimer = nil
        end
    elseif #self.tipsCenterList > 0 then
        local info = table.remove(self.tipsCenterList, 1)
        local label = self:createLabel(CENTER)
        label.visible = false
        local labelText = label:GetChild("n0")
        labelText.text = info.text
        self:addToCenterStage(label)
    end
end
--右下角的飘字
function TipsMgr:updateRight()
    if Time.getTime() - self.rightTime >= TipsTime then
        self.tipsRightList = {}
        if self.tipsRightTimer then
            mgr.TimerMgr:removeTimer(self.tipsRightTimer)
            self.tipsRightTimer = nil
        end
    elseif #self.tipsRightList > 0 then
        local info = table.remove(self.tipsRightList, 1)
        local label = self:createLabel(RIGHT)
        label.visible = false
        local labelText = label:GetChild("n0")
        local str = info.text or ""
        local text = str
        if info.count > 0 and not info.isTunshi then
            text = language.getDec..str..mgr.TextMgr:getTextColorStr(info.count,4)
        elseif info.count > 0 and info.isTunshi then
            text = language.getDec3..str.."x"..mgr.TextMgr:getTextColorStr(info.count,4)..language.getDec4..mgr.TextMgr:getTextColorStr(info.partnerExp,4)
        end
        labelText.text = text
        self:addToRightStage(label)
    end
end


function TipsMgr:updateDanMu()
    if Time.getTime() - self.danMuTime >= TipsTime then
        self.tipsDanMuList = {}
        if self.tipsDanMuTimer then
            mgr.TimerMgr:removeTimer(self.tipsDanMuTimer)
            self.tipsDanMuTimer = nil
        end
    elseif #self.tipsDanMuList > 0 then
        local info = table.remove(self.tipsDanMuList, 1)
        local label = self:createLabel(DANMU)
        label.visible = false
        local labelText = label:GetChild("n0")
        labelText.text = mgr.TextMgr:getTextColorStr(info.text,0)
        self:addToDanMuStage(label)
    end
end

function TipsMgr:createLabel(type)
    if type == CENTER then
        if #self.objCenterPools > 0 then
            return table.remove(self.objCenterPools, 1)
        else
            return UIPackage.CreateObject("_components" , "Label5")
        end
    elseif type == RIGHT then
        if #self.objRightPools > 0 then
            return table.remove(self.objRightPools, 1)
        else
            return UIPackage.CreateObject("_components" , "Label1")
        end
    elseif type == DANMU then
        if #self.objDanMuPools > 0 then
            return table.remove(self.objDanMuPools, 1)
        else
            return UIPackage.CreateObject("_components" , "Label2")
        end
    end
end

function TipsMgr:removeCenterLabel(label)
    if #self.objCenterPools > 10 then
        label:Dispose()
        return
    end
    label:RemoveFromParent()
    -- GRoot.inst:AddChild(label)
    label.visible = false
    label.alpha = 1
    table.insert(self.objCenterPools, label)
end
--中间飘字运动参数
function TipsMgr:addToCenterStage(label)
    if not self.centerParent then
        local view = mgr.ViewMgr:get(ViewName.ItemTipView)
        if view then
            self.centerParent = view.view
        else
            self:removeCenterLabel(label)
            return
        end
    end

    self.centerParent:AddChildAt(label,self.centerParent.numChildren)
    local viewWith = self.centerParent.initWidth
    local viewHeight = self.centerParent.initHeight
    label.visible = true
    label.x = viewWith / 2
    label.y = viewHeight * 0.9
    UTransition.TweenMove(label, Vector2.New(viewWith / 2, viewHeight / 1.55), 0.7, true,function()
        UTransition.TweenFade(label,0,1.5,false,function()
            self:removeCenterLabel(label)
            label = nil
        end)    
    end)
end

function TipsMgr:removeRightLabel(label)
    if #self.objRightPools > 10 then
        label:Dispose()
        return
    end
    label:RemoveFromParent()
    -- GRoot.inst:AddChild(label)
    label.visible = false
    label.alpha = 1
    table.insert(self.objRightPools, label)
end
--右下角飘字运动参数
function TipsMgr:addToRightStage(label)
    if not self.rightParent then
        local view = mgr.ViewMgr:get(ViewName.ItemTipView)
        if view then
            self.rightParent = view.view:GetChild("n0")
        else
            self:removeRightLabel(label)
            return
        end
    end

    self.rightParent:AddChildAt(label,self.rightParent.numChildren)
    local viewWith = self.rightParent.initWidth
    local viewHeight = self.rightParent.initHeight
    label.visible = true
    label.x = viewWith / 2
    label.y = viewHeight * 0.9
    UTransition.TweenMove(label, Vector2.New(viewWith / 2, viewHeight * 0.2), 0.3, true,function()
        UTransition.TweenFade(label,0,0.7,false,function()
            self:removeRightLabel(label)
            label = nil
        end)    
    end)
end

function TipsMgr:removeDanMuLabel(label)
    if #self.objDanMuPools > 10 then
        label:Dispose()
        return
    end
    label:RemoveFromParent()
    -- GRoot.inst:AddChild(label)
    label.visible = false
    label.alpha = 1
    table.insert(self.objDanMuPools, label)
end
--弹幕是单独的界面
function TipsMgr:addToDanMuStage(label)
    if not self.danMuParent then
        local view = mgr.ViewMgr:get(ViewName.DanMuTipsView)
        if view then
            self.danMuParent = view.view:GetChild("n0")
        else
            self:removeDanMuLabel(label)
            return
        end
    end
    local randomIndex = math.random(1,#DanMuY)
    local _y = DanMuY[randomIndex]
    self.danMuParent:AddChildAt(label,self.danMuParent.numChildren)
    local viewWith = self.danMuParent.initWidth
    local viewHeight = self.danMuParent.initHeight
    label.visible = true
    label.x = viewWith 
    label.y = _y

    -- label:TweenMoveX(0-label.initWidth,10)
    UTransition.TweenMove2(label, Vector2.New(0-label.initWidth, _y), 10, true,function()
        -- UTransition.TweenFade(label,0,0.7,false,function()
            self:removeDanMuLabel(label)
            label = nil
        -- end)    
    end)
end

function TipsMgr:dispose()
    for i=1,#self.objCenterPools do
        local label = self.objCenterPools[i]
        label:Dispose()
    end
    for i=1,#self.objRightPools do
        local label = self.objRightPools[i]
        label:Dispose()
    end
    self.tipsCenterList = {}
    self.tipsRightList = {}

end
function  TipsMgr:disposeDanMu()
    for i=1,#self.objDanMuPools do
        local label = self.objDanMuPools[i]
        label:Dispose()
    end
    self.tipsDanMuList = {}

end


return TipsMgr