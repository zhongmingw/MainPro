--修仙
local ImmortalityProxy = class("ImmortalityProxy",base.BaseProxy)

function ImmortalityProxy:init()
    self:add(5290101,self.add5290101) --请求修仙信息返回
    self:add(5290102,self.add5290102) --请求修仙升级返回
    self:add(5290103,self.add5290103) --请求领取每日奖励返回
    self:add(5290201,self.add5290201) --请求渡劫返回
    self:add(5290202,self.add5290202) --请求修仙渡劫同意或者拒绝
    self:add(5290203,self.add5290203) --请求修仙渡劫队伍成员准备状态

    --广播渡劫操作
    self:add(8180201,self.add8180201) 
end

--请求
function ImmortalityProxy:sendMsg( sendId,param )
    self:send(sendId,param)
end

--请求修仙信息返回
function ImmortalityProxy:add5290101( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateXiuxianData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.DailyTaskView)
        if view then
            view:updateDailyTask(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求修仙升级返回
function ImmortalityProxy:add5290102( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateXiuxianData(data)
        end
        -- print("修仙等级",data.level)
        if data.level ~= 1 then
            mgr.ViewMgr:openView2(ViewName.UpgradeView,data)
        end
        -- cache.PlayerCache:setAttribute(20139,data.djSign)
        -- local view = mgr.ViewMgr:get(ViewName.ImmortalityView)
        -- if view then
        --     view:gradeUpRefresh(data)
        -- end
    else
        GComErrorMsg(data.status)
    end
end
--请求领取每日奖励返回
function ImmortalityProxy:add5290103( data )
    if data.status == 0 then
        --红点刷新
        local var = cache.PlayerCache:getRedPointById(attConst.A10204)
        cache.PlayerCache:setRedpoint(attConst.A10204,var-1)
        local mainview = mgr.ViewMgr:get(ViewName.MainView)
        if mainview then
            mainview:refreshRed()
        end

        local view = mgr.ViewMgr:get(ViewName.DailyTaskView)
        if view then
            view:getAwardsRefresh(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ImmortalityProxy:add5290201( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DujieView)
        if view then
            -- print("我是队长")
            view:updateTeamInfo(data)
        end
    elseif data.status == 2208017  then
        GComAlter(language.xiuxian22)
    else
        GComErrorMsg(data.status)
    end
end

function ImmortalityProxy:add5290202( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DujieView)
        if view then
            if data.reqType == 1 then
                view:refreshAgree(true)
                view:resetAgree(true)
                -- print("同意")
            else
                view:onCloseView()
            end
        end
        if data.reqType == 2 then
            --退出队伍
            proxy.TeamProxy:send(1300107)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ImmortalityProxy:add5290203( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DujieView)
        local roleId = cache.PlayerCache:getRoleId()
        local isCaptain = cache.TeamCache:getIsCaptain(roleId)
        if view then
            if isCaptain then
                view:initData({index=0})
            else
                view:initData({index=1})
            end
            view:updateTeamInfo(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ImmortalityProxy:add8180201( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DujieView)

        if data.reqType == 1 then     --队长申请渡劫
            if view then
                view:resetAgree(false)
                view:refreshAgree(false)
                proxy.ImmortalityProxy:sendMsg(1290203)
            else
                if not mgr.FubenMgr:checkScene() then
                    mgr.ViewMgr:openView(ViewName.DujieView,function(view)
                        view:initData({index=1})
                        view:resetAgree(false)
                        proxy.TeamProxy:send(1300102)
                    end)
                end
            end
        elseif data.reqType == 2 then --同意渡劫
            if view then
                --请求队员准备状态
                -- print("请求队员准备状态")
                proxy.ImmortalityProxy:sendMsg(1290203)
            end
        elseif data.reqType == 3 then --拒绝渡劫
            if view then
                --请求队员准备状态
                local roleId = cache.PlayerCache:getRoleId()
                local isCaptain = cache.TeamCache:getIsCaptain(roleId)
                if isCaptain then--是队长
                    -- print("队长飘字")
                    GComAlter(language.xiuxian16)
                    view:setIsDujie(false)
                    proxy.ImmortalityProxy:sendMsg(1290203)
                else
                    if data.roleId == roleId then
                        view:onClickRefuse()
                        view:onCloseView()
                    else
                        view:refreshAgree(false)
                        proxy.ImmortalityProxy:sendMsg(1290203)
                    end
                end
            end
        elseif data.reqType == 4 then --队长渡劫按钮刷新
            if view then
                local roleId = cache.PlayerCache:getRoleId()
                local isCaptain = cache.TeamCache:getIsCaptain(roleId)
                if isCaptain then
                    view:setIsDujie(false)
                    view:initInfo()
                else
                    view:refreshAgree(false)
                end
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

return ImmortalityProxy