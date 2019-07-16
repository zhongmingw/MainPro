--
-- Author: 
-- Date: 2018-01-13 11:13:22
--
--活动管理
local ActivityMgr = class("ActivityMgr", import("game.base.Ref"))

function ActivityMgr:ctor()
    
end
--副本活动标志 bxp
function ActivityMgr:setFubenActive(param)
    -- if not param.id or not param.obj then return end
    local data = cache.ActivityCache:get5030111()
    local flag = false
    for k,v in pairs(param.id) do
        if data and data.acts[v] and data.acts[v] == 1 and mgr.ModuleMgr:CheckView(v) then 
            flag = true
            break
        end
    end
    param.obj.visible = flag
end
--
function ActivityMgr:formatTimeStr(actStartTime,actEndTime)
    -- body
    local temp = os.date("*t", actStartTime)
    local tempend = os.date("*t",actEndTime)
    local str = clone(language.chunjie01)
    str[2].text = string.format(str[2].text,
        temp.month,temp.day,temp.hour,temp.min,
        tempend.month,tempend.day,tempend.hour,tempend.min)

    return str
end

return ActivityMgr