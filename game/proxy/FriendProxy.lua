--
-- Author: 
-- Date: 2017-01-13 12:02:15
--

local FriendProxy = class("FriendProxy",base.BaseProxy)

function FriendProxy:init()
    -- self:add(5010101,self.resLogin)
    self:add(5070101,self.add5070101)-- 请求好友列表
    self:add(5070102,self.add5070102)--： 请求添加好友列表
    self:add(5070103,self.add5070103)-- 请求添加删除好友
    self:add(5070104,self.add5070104)--请求好友申请列表
    self:add(5070105,self.add5070105)-- 请求好友申请同意忽略
    self:add(5070201,self.add5070201)-- 请求黑名单列表
    self:add(5070202,self.add5070202)-- 请求黑名单添加删除
    self:add(5070203,self.add5070203)-- 请求仇人列表
    self:add(5070204,self.add5070204)-- 仇人列表删除
    self:add(5070301,self.add5070301)--请求赠送爱心
    self:add(5070302,self.add5070302)-- 请求领取爱心
    self:add(5070303,self.add5070303)--请求魅力界面或进阶
    self:add(5070304,self.add5070304)--请求爱心记录排行榜
    self:add(5070205,self.add5070205)--请求追杀令追杀
    self:add(5070106,self.add5070106)-- 请求自动拒绝好友申请

    self.param = nil 
end

function FriendProxy:sendMsg(msgId,param)
    -- body
    self.param = param
    self:send(msgId,param)
end

function FriendProxy:addCallBack(data)
    -- body
    local view = mgr.ViewMgr:get(ViewName.FriendView)
    if view then
        view:friendMsgCallBack(data,self.param)
    end

    local view = mgr.ViewMgr:get(ViewName.MarrySongHuaView)
    if view then
        view:addCallBack(data)
    end
end

function FriendProxy:addMeiliBack( data )
    -- body
    local view = mgr.ViewMgr:get(ViewName.FriendView)
    if view then
        view:MeiliMsgCallBack(data,self.param)
    end
end

function FriendProxy:add5070101( data )
    -- body
    if data.status == 0 then
        self:addCallBack(data)
        local view = mgr.ViewMgr:get(ViewName.ZhuiShaView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070102( data )
    -- body
    if data.status == 0 then
        --plog("add5070102",add5070102)
        self:addCallBack(data)
        local view = mgr.ViewMgr:get(ViewName.ZhuiShaView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070103( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FriendTips)
        if view then
            view:closeView()
        end
        --EVE 好友数量更新
        local view = mgr.ViewMgr:get(ViewName.FriendView)  
        if view and  view.friendInfo then  
           view.friendInfo:friendNumShow()
        end
         --EVE END
        self:addCallBack(data)

        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070104( data )
    -- body
    if data.status == 0 then

        self:addCallBack(data)
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070105( data )
    -- body
    if data.status == 0 then
        --printt("data",data)
        self:addCallBack(data)
        proxy.FriendProxy:sendMsg(1070104)
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070201( data )
    -- body
    if data.status == 0 then
        self:addCallBack(data)
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070202( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FriendTips)
        if view then
            view:closeView()
        end
        self:addCallBack(data)
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070203( data )
    -- body
    if data.status == 0 then
        self:addCallBack(data)
        local view = mgr.ViewMgr:get(ViewName.ZhuiShaView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070204( data )
    -- body
    if data.status == 0 then
        --plog("add5070204")
        self:addCallBack(data)
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070301( data )
    -- body
    if data.status == 0 then
        --plog("add5070204")
        self:addCallBack(data)
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070302( data )
    -- body
    if data.status == 0 then
        if data.type == 2 then
            mgr.GuiMgr:redpointByID(10234)
            local view = mgr.ViewMgr:get(ViewName.FriendView)
            if view and view.friendInfo then
                local RecCount = view.friendInfo:getRecCount()
                --print("领取")
                view.friendInfo:RefRecCount(RecCount-1)
                view.friendInfo:refreshRedPoint()
            end
        elseif data.type == 4 then
            cache.PlayerCache:setRedpoint(10234,0)
            local view = mgr.ViewMgr:get(ViewName.FriendView)
            if view and view.friendInfo then
                -- view.friendInfo:RefPresentCount(0)
                --print("一键领取")
                view.friendInfo:RefRecCount(0)
                view.friendInfo:refreshRedPoint()
            end
        end
        --EVE 爱心可领取数量更新
        local view = mgr.ViewMgr:get(ViewName.FriendView)  
        if view and  view.friendInfo then  
            view.friendInfo:renewalOfLove()
        end
        --EVE END
        self:addCallBack(data)
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070303(data)
    -- body
    if data.status ==  0 then
        --plog("5070303")
        self:addMeiliBack(data)
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070304(data)
    -- body
    if data.status ==  0 then
        --plog("add5070304")
        --plog(#data.heartRecord)
        self:addMeiliBack(data)
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070205(data)
    if data.status == 0 then
        if data.reqType == 0 then
            local view = mgr.ViewMgr:get(ViewName.ZhuiShaTipsView)
            if view then
                view:setData(data)
            end
        elseif data.reqType == 1 then
            local sConf = conf.SceneConf:getSceneById(data.sceneId)
            if sConf.kind and (sConf.kind == SceneKind.field or sConf.kind == SceneKind.mainCity) then
                proxy.ThingProxy:send(1020101, {sceneId=data.sceneId, pox=data.pox, poy=data.poy, type=5})
            else
                GComAlter(language.friend57)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function FriendProxy:add5070106(data)
    -- body
    if data.status ==  0 then
    
    else
        GComErrorMsg(data.status)
    end
end
return FriendProxy