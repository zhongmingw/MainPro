--
-- Author: 
-- Date: 2018-12-20 17:38:42
--

local YuanDan1005 = class("YuanDan1005",import("game.base.Ref"))

function YuanDan1005:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function YuanDan1005:initPanel()

    local panelObj = self.mParent:getPanelObj(self.modelId)

    panelObj:GetChild("n2").text = language.yuandan16

    local goBtn = panelObj:GetChild("n4")
    goBtn.onClick:Add(self.onGoFuben,self)

    self.leftTimeTxt = panelObj:GetChild("n6")

    self.c1 = panelObj:GetController("c1")

end

function YuanDan1005:setData()
    self.openTime = cache.PlayerCache:getRedPointById(20214) or 0
    -- print("20214", cache.PlayerCache:getRedPointById(20214))--活动结束时间戳 14:10分  > 0表示开启
    --print("20215", cache.PlayerCache:getRedPointById(20215))--活动下次开始时间戳 14:00分
    if self.openTime > 0 then
        self.c1.selectedIndex = 0--已开启
    else
        self.c1.selectedIndex = 1
        local netTime = mgr.NetMgr:getServerTime()
        self.nextStartTime = cache.PlayerCache:getRedPointById(20215) or 0
        self.leftTimeTxt.text = GTotimeString(self.nextStartTime-netTime)
    end

end

function YuanDan1005:onTimer()
    local netTime = mgr.NetMgr:getServerTime()
    if not self.nextStartTime  then return end
    self.leftTimeTxt.text = GTotimeString(self.nextStartTime-netTime)
    -- print("开启时间", self.nextStartTime-netTime,"20214",self.openTime)
    -- print("下次开启时间20215",cache.PlayerCache:getRedPointById(20215),"剩余时间",tonumber(self.nextStartTime)-tonumber(netTime))
    if tonumber(self.nextStartTime)-tonumber(netTime) <= 0 then
        self.c1.selectedIndex = 0
        -- self.mParent:refeshList()
    else
        if self.openTime <= 0 then
            self.c1.selectedIndex = 1--不可进
            -- self.mParent:refeshList()
            -- self.nextStartTime = cache.PlayerCache:getRedPointById(20215) or 0
            -- print("活动没开启",self.nextStartTime)
        end
    end
end

function YuanDan1005:refeshNextStartTime()
    self.nextStartTime = cache.PlayerCache:getRedPointById(20215) or 0
end


function YuanDan1005:onGoFuben()
    local data = cache.ActivityCache:get5030111()
    if data.acts[1208] and data.acts[1208] == 1 then
        proxy.DongZhiProxy:sendMsg(1030676,{reqType = 0,answer = {}})
        self.mParent:closeView()
    else
        GComAlter(language.vip11)
    end 
end


return YuanDan1005