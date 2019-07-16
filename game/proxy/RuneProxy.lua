--
-- Author: 
-- Date: 2018-02-22 14:18:03
--
--符文系统
local RuneProxy = class("RuneProxy",base.BaseProxy)

function RuneProxy:init()
    self:add(5500101,self.add5500101)--请求符文背包信息
    self:add(5500102,self.add5500102)--请求装备符文
    self:add(5500103,self.add5500103)--请求符文升级
    self:add(5500104,self.add5500104)--请求符文分解
    self:add(5500105,self.add5500105)--请求符文合成
    self:add(5500106,self.add5500106)--请求符文塔排行信息
    self:add(5500201,self.add5500201)--请求符文寻宝信息
    self:add(5500202,self.add5500202)--请求符文商城碎片兑换
    self:add(5500203,self.add5500203)--请求符文寻宝

    self:add(8030201,self.add8030201)--符文改变广播
end
--请求符文背包信息
function RuneProxy:add5500101(data)
    -- printt("请求符文背包信息",data)
    if data.status == 0 then
        cache.RuneCache:setPackData(data)
        cache.RuneCache:setEquipFwDatas(data.equipFwDatas)
        local view = mgr.ViewMgr:get(ViewName.RunePackView)
        if view then
            view:setData(data)
        end
        local view = mgr.ViewMgr:get(ViewName.RuneMainView)
        if view then
            view:refreshPack()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求装备符文
function RuneProxy:add5500102(data)
    -- printt("请求装备符文",data)
    if data.status == 0 then
        if data.reqType ~= 0 then
            self:send(1500101)
        end
        cache.RuneCache:setEquipFwDatas(data.holeInfos)
        local view = mgr.ViewMgr:get(ViewName.RuneMainView)
        if view then
            view:addServerCallback(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求符文升级
function RuneProxy:add5500103(data)
    -- printt("请求符文升级",data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RuneMainView)
        if view then
            view:severUpRune(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求符文分解
function RuneProxy:add5500104(data)
    if data.status == 0 then
        if data.reqType == 1 then
            self:send(1500101)
        end
        local view = mgr.ViewMgr:get(ViewName.RuneMainView)
        if view then
            view:addServerCallback(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求符文合成
function RuneProxy:add5500105(data)
    -- printt("请求符文合成",data)
    if data.status == 0 then
        if data.reqType == 2 then--合成
            cache.RuneCache:setEquipFwDatas(data.holeInfos)
        end
        local view = mgr.ViewMgr:get(ViewName.RuneMainView)
        if view then
            view:addServerCallback(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求符文塔排行信息
function RuneProxy:add5500106(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RuneMainView)
        if view then
            view:addServerCallback(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求符文寻宝信息
function RuneProxy:add5500201(data)
    -- printt("请求符文寻宝信息",data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:setRuneXunbao(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求符文商城碎片兑换
function RuneProxy:add5500202(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RuneMainView)
        if view then
            view:addServerCallback(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求符文寻宝
function RuneProxy:add5500203(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XunBaoView)
        if view then
            view:severXunbao(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--符文改变广播
function RuneProxy:add8030201(data)
    if data.status == 0 then
        cache.RuneCache:updateRuneData(data.changeItems)
    else
        GComErrorMsg(data.status)
    end
end

return RuneProxy

