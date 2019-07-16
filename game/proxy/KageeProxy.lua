--
-- Author: ohf
-- Date: 2017-02-21 14:55:21
--
--影卫协议
local KageeProxy = class("KageeProxy",base.BaseProxy)

function KageeProxy:init()
    self:add(5150101,self.add5150101)
    self:add(5150102,self.add5150102)--请求影卫火凤升级
end

function KageeProxy:add5150101(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.KageeViewNew)
        if view then
            view:flush()
            view.viewList[0]:setYwJbLevel(data.level)
            view.viewList[0]:setReqType(data.reqType)
            view.viewList[0]:setData(data.ywLevelMap)
        else
            -- mgr.ViewMgr:openView(ViewName.KageeView,function (view)
            --     view:setYwJbLevel(data.level)
            --     view:setReqType(data.reqType)
            --     view:setData(data.ywLevelMap)
            -- end)
        end
    elseif data.status == 22020004 then
        GGoBuyItem({index = 7})
    else
        GComErrorMsg(data.status)
    end
end
--请求影卫火凤升级
function KageeProxy:add5150102(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.KageeTipsView1)
        if view then
            view:setData(nil,nil,data.level)
        end
        local view = mgr.ViewMgr:get(ViewName.KageeViewNew)
        if view then
            view.viewList[0]:setYwJbLevel(data.level)
            view.viewList[0]:refreshRed()
            view.viewList[0]:setAllAttiData()
        end
    else
        GComErrorMsg(data.status)
    end
end

return KageeProxy