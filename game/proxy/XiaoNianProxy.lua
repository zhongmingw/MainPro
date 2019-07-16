--
-- Author: 
-- Date: 2019-01-07 20:25:21
--

local XiaoNianProxy = class("XiaoNianProxy",base.BaseProxy)

function XiaoNianProxy:init()
     self:add(5030703,self.addMsgCallBack) -- 请求小年登录
     self:add(5030704,self.addMsgCallBack) -- 请求小年降妖
     self:add(5030705,self.addMsgCallBack) -- 请求小年兑换
     self:add(5030706,self.addMsgCallBack) -- 请求小年boss
     

    self:add(5030707,self.add5030707)-- 请求小年祭灶
    self:add(8240305,self.add8240305)-- 小年祭灶广播

    self:add(5030708,self.add5030708)-- 请求小年豪礼

end

function XiaoNianProxy:sendMsg(msgId,param)
    -- body
    self.param = param
    self:send(msgId,param)
end
function XiaoNianProxy:addMsgCallBack(data)
    -- body
   
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XiaoNianView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


function XiaoNianProxy:add5030707(data)
    if data.status == 0 then
   
        local view = mgr.ViewMgr:get(ViewName.XiaoNianJiZhao)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function XiaoNianProxy:add8240305(data)
    if data.status == 0 then
        print("小年祭灶广播")
        printt(data)
        local view = mgr.ViewMgr:get(ViewName.XiaoNianJiZhao)
        if view then
            view.data.numMap = data.nums
            view.data.allRecord = data.allRecord
            view:RefreshItem()
        end
    else
        GComErrorMsg(data.status)
    end
end


function XiaoNianProxy:add5030708(data)
    if data.status == 0 then
   
        local view = mgr.ViewMgr:get(ViewName.XiaoNianHaoLi)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

return XiaoNianProxy