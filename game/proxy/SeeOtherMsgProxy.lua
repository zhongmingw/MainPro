--
-- Author: 
-- Date: 2017-05-25 20:38:31
--

local SeeOtherMsgProxy = class("SeeOtherMsg",base.BaseProxy)

function SeeOtherMsgProxy:init()
    self:add(5370101,self.add5370101)
    self:add(5370102,self.add5370102)
end

function SeeOtherMsgProxy:add5370101(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.SeeOtherMsg)
        if view then
            if data.attris64 and data.attris64[101] then--经验值
                data.attris[101] = data.attris64[101]
            end
            if data.attris[312] then
                print("伤害减免",data.attris[312])
            else
                print("没有伤害减免",data.attris[312])
            end
            view:add5370101(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function SeeOtherMsgProxy:add5370102(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.SeeOtherMsg)
        if view then
            view:add5370102(data)
        end
    else
        GComErrorMsg(data.status)
    end
end



return SeeOtherMsgProxy