--
-- Author: 
-- Date: 2018-12-10 14:46:12
--2018圣诞节

local ShengDanProxy = class("ShengDanProxy",base.BaseProxy)

function ShengDanProxy:init()
    self:add(5030668, self.add5030668)-- 请求圣诞福利活动
    self:add(5030669, self.add5030669)-- 请求许愿圣诞树


    self:add(5030670, self.addMsgCallBack)-- 请求圣诞登录活动
    self:add(5030671, self.addMsgCallBack)-- 请求圣诞宝树活动
    self:add(5030672, self.addMsgCallBack)-- 请求圣诞BOSS
    self:add(5030673, self.addMsgCallBack)-- 请求圣诞兑换
    self:add(5030674, self.addMsgCallBack)-- 请求圣诞副本双倍

end

function ShengDanProxy:sendMsg(msgId, param)
    -- body
    self.param = param
    self:send(msgId,param)
end

function ShengDanProxy:add5030668(data)
    if data.status == 0 then
        if data.reqType == 2 then
            GOpenAlert3(data.items)
        end
        local view = mgr.ViewMgr:get(ViewName.ShengDanCharge)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ShengDanProxy:add5030669(data)
    if data.status == 0 then
        if data.reqType == 2 then
            GOpenAlert3(data.items)
        end
        local view = mgr.ViewMgr:get(ViewName.XuYuanShengDanShu)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ShengDanProxy:addMsgCallBack(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ShengDanMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


return ShengDanProxy