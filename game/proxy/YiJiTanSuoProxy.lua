--
-- Author: Your Name
-- Date: 2018-12-17 14:04:50
--

local YiJiTanSuoProxy = class("YiJiTanSuoProxy",base.BaseProxy)

function YiJiTanSuoProxy:init()
    self:add(5640101,self.add5640101)--请求遗迹探索信息
    self:add(5640102,self.add5640102)--请求购买次数
    self:add(5640103,self.add5640103)--请求遗迹探索场景信息
    self:add(5640104,self.add5640104)--请求开始探索
    self:add(5640105,self.add5640105)--请求快速完成
    self:add(5640106,self.add5640106)--请求领取奖励
    self:add(5640107,self.add5640107)--请求掠夺
    self:add(5640108,self.add5640108)--请求清除冷却时间
    self:add(5640109,self.add5640109)--请求遗迹探索跳过战斗
    self:add(8240301,self.add8240301)--遗迹探索结算广播

end

function YiJiTanSuoProxy:sendMsg(msgId,param)
    self:send(msgId,param)
end

--请求遗迹探索信息
function YiJiTanSuoProxy:add5640101(data)
    if data.status == 0 then
        cache.YiJiTanSuoCache:setData(data)
        local view = mgr.ViewMgr:get(ViewName.YiJiTanSuoCity)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求购买次数
function YiJiTanSuoProxy:add5640102(data)
    if data.status == 0 then
        if data.reqType == 0 then
            cache.YiJiTanSuoCache:refreshExploreBuyCount(data)
        elseif data.reqType == 1 then
            cache.YiJiTanSuoCache:refreshRobbingBuyCount(data)
        end
        local view = mgr.ViewMgr:get(ViewName.YiJiCityInfoView)
        if view then
            view:refreshView()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求遗迹探索场景信息
function YiJiTanSuoProxy:add5640103(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.YiJiCityInfoView)
        if view then
            view:setData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.YiJiTanSuoCity)
        if view then
            view:closeView()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求开始探索
function YiJiTanSuoProxy:add5640104(data)
    if data.status == 0 then
        cache.YiJiTanSuoCache:refreshExploreCount(cache.YiJiTanSuoCache:getTanSuoCount()+1)
        local view = mgr.ViewMgr:get(ViewName.YiJiCityInfoView)
        if view then
            view:refreshView()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求快速完成
function YiJiTanSuoProxy:add5640105(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.YiJiCityInfoView)
        if view then
            view:refreshView()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求领取奖励
function YiJiTanSuoProxy:add5640106(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.YiJiCityInfoView)
        if view then
            view:refreshView()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求掠夺
function YiJiTanSuoProxy:add5640107(data)
    if data.status == 0 then
        cache.YiJiTanSuoCache:refreshRobbingCount(cache.YiJiTanSuoCache:getLueDuoCount()+1)
        mgr.FubenMgr:gotoFubenWar(YiJiScene)
    elseif data.status == 2220009 then
        local view = mgr.ViewMgr:get(ViewName.YiJiCityInfoView)
        if view then
            view:refreshView()
        end
        GComAlter(language.yjts26)
    else
        GComErrorMsg(data.status)
    end
end

--请求清除冷却时间
function YiJiTanSuoProxy:add5640108(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.YiJiCityInfoView)
        if view then
            view:refreshView()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求遗迹探索跳过战斗
function YiJiTanSuoProxy:add5640109(data)
    if data.status == 0 then

    else
        GComErrorMsg(data.status)
    end
end

--遗迹探索结算广播
function YiJiTanSuoProxy:add8240301(data)
    if data.status == 0 then
        print("遗迹探索结算广播>>>>>>>>>>")
        mgr.ViewMgr:openView2(ViewName.YiJiFightEndView, data)
    else
        GComErrorMsg(data.status)
    end
end

return YiJiTanSuoProxy