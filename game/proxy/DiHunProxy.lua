--
-- Author: 
-- Date: 2018-11-26 20:27:06
--

local DiHunProxy = class("DiHunProxy",base.BaseProxy)

function DiHunProxy:init()
    self:add(5620101,self.add5620101)--请求帝魂信息
    self:add(5620102,self.add5620102)--请求点亮帝魂圆点
    self:add(5620103,self.add5620103)--请求附体
    self:add(5620104,self.add5620104)-- 请求帝魂魂饰穿戴
    self:add(5620105,self.add5620105)-- 请求帝魂强化
    self:add(5620106,self.add5620106)-- 请求帝魂魂饰分解
    self:add(5620107,self.add5620107)--  请求帝魂升星激活
    self:add(5620108,self.add5620108)--  请求帝魂任务信息

end
function DiHunProxy:sendMsg(msgId, param)
    self.param = param
    self:send(msgId,param)
end

--请求帝魂信息
function DiHunProxy:add5620101(data)
    if data.status == 0 then
        cache.DiHunCache:setData(data)
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:setDiHunData(data)
        end
        --请求帝魂魂饰穿戴完成后
        local view = mgr.ViewMgr:get(ViewName.DiHunPack)
        if view then
            view:onController1()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求点亮帝魂圆点
function DiHunProxy:add5620102(data)
    if data.status == 0 then
        GComAlter(language.zuoqi64)        
        proxy.DiHunProxy:sendMsg(1620101)
    else
        GComErrorMsg(data.status)
    end
end

--请求附体
function DiHunProxy:add5620103(data)
    if data.status == 0 then
        GComAlter(language.dihun16)
        proxy.DiHunProxy:sendMsg(1620101)
    else
        GComErrorMsg(data.status)
    end
end

--请求帝魂魂饰穿戴
function DiHunProxy:add5620104(data)
    if data.status == 0 then
        proxy.DiHunProxy:sendMsg(1620101)
    else
        GComErrorMsg(data.status)
    end
end
--请求帝魂强化
function DiHunProxy:add5620105(data)
    if data.status == 0 then
        proxy.DiHunProxy:sendMsg(1620101)
        GComAlter(language.talent17)
      
        local moneyMap = {}
        for k,v in pairs(data.colorScore) do --k从3开始
            moneyMap[MoneyType.dh1-3 +k] = v
        end
        cache.DiHunCache:upDateScore(data.colorScore)
        cache.PlayerCache:updateMoneyInfo(moneyMap)
        local view = mgr.ViewMgr:get(ViewName.HunShiStrengView)
        if view then
            view:setInfo(data.partInfo.strenLevel)
        end

    else
        GComErrorMsg(data.status)
    end
end

--魂饰分解
function DiHunProxy:add5620106(data)
    if data.status == 0 then
        GOpenAlert3(data.items)
        cache.DiHunCache:upDateScore(data.colorScore)
        local view = mgr.ViewMgr:get(ViewName.DiHunPack)
        if view then
            view:onController1()
        end
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:refreshRed()
            -- if view.DiHunPanel then
            --      view.DiHunPanel:refreshRed()
            -- end
        end
        proxy.DiHunProxy:sendMsg(1620101)
    else
        GComErrorMsg(data.status)
    end
end
--请求帝魂升星激活
function DiHunProxy:add5620107(data)
    if data.status == 0 then
        proxy.DiHunProxy:sendMsg(1620101)
        if data.reqType == 0 then
            cache.DiHunCache:upDateDhInfo(data)
            mgr.ViewMgr:openView2(ViewName.GetDiHunView,data.info)
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                view.TopActive:checkOpen()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求帝魂任务信息
function DiHunProxy:add5620108(data)
    if data.status == 0 then
        cache.DiHunCache:setDiHunTaskFinish(table.nums(data.gotSigns) == 8)
        local view = mgr.ViewMgr:get(ViewName.DiHunMainView)
        if view then
            view:addMsgCallBack(data)
        end
        if data.reqType == 1 then
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                view.TopActive:checkOpen()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

return DiHunProxy