--
-- Author: Your Name
-- Date: 2018-09-12 14:31:15
--万神殿
local WanShenDianProxy = class("WanShenDianProxy",base.BaseProxy)

function WanShenDianProxy:init()
    self:add(5331301,self.add5331301)--请求万神殿信息
    self:add(5331302,self.add5331302)--请求万神殿副本场景信息
    self:add(5331303,self.add5331303)--请求万神殿续时
    self:add(8230701,self.add8230701)--广播万神殿精力值

end

function WanShenDianProxy:add5331301( data )
    if data.status == 0 then
        cache.WanShenDianCache:setLeftCount(data.leftCount)
        local view = mgr.ViewMgr:get(ViewName.BossView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function WanShenDianProxy:add5331302( data )
    if data.status == 0 then
        cache.WanShenDianCache:setJlValue(data.jlValue)
        cache.WanShenDianCache:setEndTime(data.ttEndTime)
        local leftCount = cache.WanShenDianCache:getLeftCount()
        cache.WanShenDianCache:setLeftCount(leftCount-1)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 17})
    else
        GComErrorMsg(data.status)
    end
end

function WanShenDianProxy:add5331303( data )
    if data.status == 0 then
        local leftCount = cache.WanShenDianCache:getLeftCount()
        cache.WanShenDianCache:setLeftCount(leftCount-1)
        print("剩余次数>>>>>>>>",leftCount-1)
        cache.WanShenDianCache:setJlValue(data.jlValue)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:refreshJlValue()
        end
    else
        GComErrorMsg(data.status)
    end
end

function WanShenDianProxy:add8230701( data )
    if data.status == 0 then
        cache.WanShenDianCache:setJlValue(data.jlValue)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:refreshJlValue()
        end
    else
        GComErrorMsg(data.status)
    end
end

return WanShenDianProxy