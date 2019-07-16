--
-- Author: ohf
-- Date: 2017-02-22 17:08:05
--
--剑神
local AwakenProxy = class("AwakenProxy",base.BaseProxy)

function AwakenProxy:init()
    self:add(5190101,self.add5190101)
    self:add(5190102,self.add5190102)

    self:add(5430101,self.add5430101)--请求剑神殿信息
    self:add(5430102,self.add5430102)--请求剑神殿boss列表
    self:add(5430103,self.add5430103)--请求剑神殿场景信息
    self:add(5430104,self.add5430104)--请求剑神殿疲劳值使用
    self:add(5430105,self.add5430105)--请求剑神殿疲劳值购买
    self:add(5190201,self.add5190201) -- 请求穿脱剑神装备

    --五行系统
    self:add(5530101,self.add5530101)-- 请求五行装备部位信息
    self:add(5530102,self.add5530102)-- 请求穿脱五行装备
    self:add(5530103,self.add5530103)-- 请求五行装备强化
    self:add(5530104,self.add5530104)-- 请求五行装备套装
    self:add(5530105,self.add5530105)-- 请求五行装备合成
    --圣印系统
    self:add(5600101,self.add5600101)-- 请求圣印穿脱
    self:add(5600102,self.add5600102)-- 请求圣印信息
    self:add(5600103,self.add5600103)-- 请求圣印套装信息    
    self:add(5600104,self.add5600104)-- 请求圣印分解
    self:add(5600105,self.add5600105)-- 请求圣印强化
    self:add(5600106,self.add5600106)-- 请求圣印强化
    --剑神装备
    self:add(5190202,self.add5190202)--  请求剑神装备合成
    self:add(5190203,self.add5190203)--请求剑神装备信息戰力
    --八门元素
    
    self:add(5610101,self.add5610101)--请求八门开启
    self:add(5610102,self.add5610102)--请求八门元素穿脱
    self:add(5610103,self.add5610103)--请求八门信息
    self:add(5610104,self.add5610104)--请求八门元素分解
    self:add(5610105,self.add5610105)--请求八门强化   
    self:add(5610106,self.add5610106)--请求八门进阶  
    self:add(5610107,self.add5610107)--请求八门元素合成


    self:add(8180501,self.add8180501)--剑神殿boss血量广播
    self:add(8180502,self.add8180502)--剑神殿boss结算广播
    self:add(8230702,self.add8230702)--圣印系统战力广播
    self:add(8230801,self.add8230801)--圣装系统战力广播
  
    self.bossDeadNum = 0
end

function AwakenProxy:sendMsg(msgId,data)
    -- body
    self.param = data
    self:send(msgId,self.param)
end

-- 请求穿脱剑神装备
function AwakenProxy:add5190201( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function AwakenProxy:add5190101(data)
    if data.status == 0 then
        local awakenView = mgr.ViewMgr:get(ViewName.AwakenView)
        if awakenView then
            awakenView:setData(data)
        end
        cache.PlayerCache:setRedpoint(10205,data.jsLevel)
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view and data.jsLevel == 1 then--激活第一次检测变身按钮是否可见
            view:checkJianshen()
            if data.reqType == 2 then
                if awakenView then
                    awakenView:initData()
                else
                    GOpenView({id = 1062})
                end
            end
        end
    else
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:getAdvancedPanel().mTag = 0
            view:getAdvancedPanel():setAutoUp()
        end
        GComErrorMsg(data.status)
    end
end
--请求更换剑神皮肤
function AwakenProxy:add5190102(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ShengZhuangShow)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求剑神殿信息
function AwakenProxy:add5430101(data)
    printt("请求剑神殿信息",data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BossView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求剑神殿boss列表
function AwakenProxy:add5430102(data)
    if data.status == 0 then
        cache.AwakenCache:setBossList(data.bossList)
        local view = mgr.ViewMgr:get(ViewName.AwakenBossTipView)
        if view then
            view:setData(data)
        else
            mgr.HookMgr:enterHook()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求剑神殿场景信息
function AwakenProxy:add5430103(data)
    printt("请求剑神殿场景信息",data)
    if data.status == 0 then
        cache.AwakenCache:setAwakenWarData(data)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 9})
        self:send(1430102)
    else
        GComErrorMsg(data.status)
    end
end
--请求剑神殿疲劳值使用
function AwakenProxy:add5430104(data)
    if data.status == 0 then
        printt("请求剑神殿疲劳值使用",data)
        cache.AwakenCache:setAwakenTired(data.leftPlayTime)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:refAwakenTime()
        end
        local view = mgr.ViewMgr:get(ViewName.BossView)
        if view and view.controller1.selectedIndex == 3 then
            self:send(1430101)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求剑神殿疲劳值购买
function AwakenProxy:add5430105(data)
    if data.status == 0 then
        printt("请求剑神殿疲劳值购买",data)
        cache.AwakenCache:setAwakenTired(data.tired)
        local view = mgr.ViewMgr:get(ViewName.BossView)
        if view and view.controller1.selectedIndex == 3 then
            self:send(1430101)
        end
    else
        GComErrorMsg(data.status)
    end
end
--剑神殿boss血量广播
function AwakenProxy:add8180501(data)
    if data.status == 0 then
        cache.AwakenCache:setBossList(data.bossList)
        local num = 0
        for k,v in pairs(data.bossList) do
            if v.pox == 0 and v.poy == 0 then
                num = num + 1
            end
        end
        if self.bossDeadNum ~= num then--boss有死亡就检测下一个boss
            mgr.HookMgr:enterHook()
            self.bossDeadNum = num
        end
        local view = mgr.ViewMgr:get(ViewName.AwakenBossTipView)
        if view then
            view:refreshBoss()
        end
    else
        GComErrorMsg(data.status)
    end
end
--剑神殿boss结算广播
function AwakenProxy:add8180502(data)
    printt("剑神殿boss结算广播",data)
    if data.status == 0 then
        mgr.ViewMgr:openView(ViewName.BossDekaronView,function(view)
            view:setData(data,4)
        end)
    else
        GComErrorMsg(data.status)
    end
end

function AwakenProxy:add5530101( data )
    -- body
    if data.status == 0 then
        --print("################")
        cache.AwakenCache:setJianLing(data.partInfos)
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function AwakenProxy:add5530102( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data,self.param)
        end
    else
        GComErrorMsg(data.status)
    end
end

function AwakenProxy:add5530103( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function AwakenProxy:add5530104(data)
    -- body
    if data.status == 0 then
        mgr.ViewMgr:openView2(ViewName.JianLingSuitTips,data)
    else
        GComErrorMsg(data.status)
    end
end

function AwakenProxy:add5530105( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end



--圣印信息
function AwakenProxy:add5600102(data)
    if data.status == 0 then
        cache.AwakenCache:setShengYinPartInfo(data.partInfo)
        cache.AwakenCache:setShengHunInfo(data.shInfos)
        cache.AwakenCache:setSyScore(data.syScore)
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.ShengHunView)
        if view then
            view:setData()
        end
    else
        GComErrorMsg(data.status)
    end
end
--圣印穿脱
function AwakenProxy:add5600101( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求圣印套装信息
function AwakenProxy:add5600103( data )
    -- body
    if data.status == 0 then
        mgr.ViewMgr:openView2(ViewName.ShengYinAttTips,{suitInfo = data.suitInfo})

    else
        GComErrorMsg(data.status)
    end
end
--圣印分解
function AwakenProxy:add5600104(data)
    if data.status == 0 then

        GOpenAlert3(data.items)
        local view = mgr.ViewMgr:get(ViewName.ShengYinResolve)
        if view then
            view:refeshList()
        end
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--圣印强化
function AwakenProxy:add5600105(data)
    if data.status == 0 then
        -- printt("强化返回",data)
        cache.AwakenCache:updateShengYinPartInfo(data)
        cache.AwakenCache:setSyScore(data.syScore)
        proxy.AwakenProxy:send(1600102)
        local view = mgr.ViewMgr:get(ViewName.ShengYinStreng)
        if view then
            view:setData(data)
        end
        

        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:refreshRed()
        end

    else
        GComErrorMsg(data.status)
    end
end

function AwakenProxy:add5600106( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function AwakenProxy:add8230702(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function AwakenProxy:add8230801(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function AwakenProxy:add5190202( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function AwakenProxy:add5190203( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--八门开启
function AwakenProxy:add5610101(data)
    if data.status == 0 then
        GComAlter(language.eightgates20)
        cache.AwakenCache:upDateGatesState(data.openState)
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:refreshRedBottom()
        end
    else
        GComErrorMsg(data.status)
    end
end
--八门穿脱
function AwakenProxy:add5610102( data )
    -- body
    if data.status == 0 then
        proxy.AwakenProxy:send(1610103)
        cache.PackCache:setEleByType()
        -- local view = mgr.ViewMgr:get(ViewName.AwakenView)
        -- if view then
        --     view:addMsgCallBack(data)
        -- end
    else
        GComErrorMsg(data.status)
    end
end
--请求八门信息
function AwakenProxy:add5610103(data)
    if data.status == 0 then
        cache.AwakenCache:setEightGatesData(data)
        cache.AwakenCache:setBMScore(data.score)
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求八门强化
function AwakenProxy:add5610105(data)
    if data.status == 0 then
        cache.AwakenCache:updateEleInfo(data)
        cache.AwakenCache:setBMScore(data.score)
        -- cache.AwakenCache:setSyScore(data.syScore)
        -- proxy.AwakenProxy:send(1600102)
        -- local view = mgr.ViewMgr:get(ViewName.ShengYinStreng)
        -- if view then
        --     view:setData(data)
        -- end

        local view = mgr.ViewMgr:get(ViewName.ElementStrengView)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:refreshRed()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求八门进阶
function AwakenProxy:add5610106(data)
    if data.status == 0 then
        GComAlter(language.eightgates16)
        proxy.AwakenProxy:send(1610103)--重新请求八门信息
        local view = mgr.ViewMgr:get(ViewName.ElemetStepUpView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求八门合成
function AwakenProxy:add5610107(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求八门元素分解
function AwakenProxy:add5610104(data)
    if data.status == 0 then
        GOpenAlert3(data.items)
        cache. AwakenCache:setBMScore(data.score)
        local view = mgr.ViewMgr:get(ViewName.ShengYinResolve)
        if view then
            view:refeshList()
        end
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
return AwakenProxy