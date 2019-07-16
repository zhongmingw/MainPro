--
-- Author: wx
-- Date: 2017-08-24 15:35:35
-- 护送

local SjHSTask = class("SjHSTask", base.BaseView)
local dayTime = 3
function SjHSTask:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
    --self.isBlack = true
end

function SjHSTask:initView()
    self.bar = self.view:GetChild("n1")
    self.bartitle = self.bar:GetChild("title1")

    self.btnGo = self.view:GetChild("n2")
    self.btnGo.title = language.kuafu140
    self.btnGo.onClick:Add(self.onGOSong,self)

    self.view.onClick:Add(self.onCloseView,self)
end

function SjHSTask:initData()
    -- body
    self.data = cache.KuaFuCache:getTaskCache(2)
    
    self:setData()

    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil 
    end
    self.timer = self:addTimer(0.4,-1,handler(self,self.onTimer))
end

function SjHSTask:onTimer()
    -- body
    if not self.data then
        return
    end
    if cache.KuaFuCache:getIsAuto() then
        self.btnGo.title = language.kuafu149
    else
        self.btnGo.title = language.kuafu140
    end
end

function SjHSTask:setData(data_)
    self.bar.value = self.data.curHp
    self.bar.max = self.data.maxHp

    self.bartitle.text = self:changeNumber(self.data.curHp).."/"..self:changeNumber(self.data.curHp)
end

function SjHSTask:changeNumber(iii)
    -- body
    local w = 10000
    if iii >= w then
        return math.ceil(iii/w)..language.gonggong52
    else
        return iii
    end
end

function SjHSTask:add5410204( data )
    -- body
    if not self.data then
        return
    end
    self.data.curHp = data.curHp
    self.data.maxHp = data.maxHp

    self.bartitle.text = self:changeNumber(data.curHp).."/"..self:changeNumber(data.curHp)

    self:setData()
end

function SjHSTask:onGOSong(context)
    -- body
    --找到车子的位置 开始跟着
    if not self.data then
        return
    end
    context:StopPropagation()

    if cache.KuaFuCache:getIsAuto() then 
        cache.KuaFuCache:setIsAuto()
        gRole:idleBehaviour()
        return
    end

    --开始跟随
    cache.KuaFuCache:setIsAuto(true)
    --plog(self.data.pox,self.data.poy)
    local point = Vector3.New(self.data.pox, gRolePoz, self.data.poy)
    mgr.ModuleMgr:startFindPath(0)
    mgr.TaskMgr:goTaskBy(cache.PlayerCache:getSId(),point)
    
    -- local point = Vector3.New(self.data.pox, gRolePoz, self.data.poy)
    -- mgr.JumpMgr:findPath(point, 100, function()

    -- end)

    --self:onCloseView()
end

function SjHSTask:onCloseView()
    -- body
    self:closeView()
end

return SjHSTask