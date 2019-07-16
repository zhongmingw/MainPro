--
-- Author: 
-- Date: 2017-06-03 17:02:45
--

local DebugView = class("DebugView", base.BaseView)

function DebugView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1 
end

function DebugView:initView()
    debugPanel = self.view:GetChild("n0")
    local text = debugPanel:GetChild("title")
    text.visible = true
    debugPanel.onClick:Add(function()
            if not mgr.ViewMgr:get(ViewName.DebugTestView) then
                mgr.ViewMgr:openView(ViewName.DebugTestView)
            end
        end,self)

    -- local add = self.view:GetChild("add")
    -- add.title = "Log"
    -- add.onClick:Add(function()
    --     -- mgr.ThingMgr:addAIPlayer()
    --     GameUtil.LogInit(2) --日志等级
    -- end,self)

    -- local del = self.view:GetChild("del")
    -- del.text = "Deb"
    -- del.onClick:Add(function()
    --     -- mgr.ThingMgr:removeAIPlayer()
    --     GameUtil.LogInit(0) --关闭自定义日志输出
    --     GameUtil.ExtendFunc(1001,"")
    -- end,self)

end

-- function DebugView:initData()
--     if g_var.gameState == g_state.formal then --正式版本的时候打开调试
--         GameUtil.LogInit(2) --日志等级
--     end
-- end

--按键调试
function DebugView:initKeyEvent()
    self.view.onKeyDown:Add(function(context)
        local evt = context.inputEvent
        if evt.keyCode == KeyCode.C then
            if mgr.ViewMgr:get(ViewName.DebugTestView) then
                mgr.ViewMgr:closeView(ViewName.DebugTestView)
            else
                mgr.ViewMgr:openView(ViewName.DebugTestView)
            end
        elseif evt.keyCode == KeyCode.Z then
            mgr.HookMgr:startHook()
        elseif evt.keyCode == KeyCode.X then
            gRole:sit()
        elseif evt.keyCode == KeyCode.M then
            local id = cache.PlayerCache:getSkins(4)
            --plog("选择了坐骑",id)
            if id > 0 then
                gRole:handlerMount(ResPath.mountRes(id))
            end
        elseif evt.keyCode == KeyCode.O then
            mgr.ViewMgr:closeAllView2()
        end
    end,self)
end

function DebugView:setData(data_)

end

function DebugView:setFps(value)
    local label = self.view:GetChild("n3")
    if label then
        label.text = string.format("FPS:%.2f",value)..GameUtil.GetGameProfiler()
    end
    local errorCount = GameUtil.LogErrorCount()
    if errorCount >0 then 
        self.view:GetChild("n0").text = "text("..errorCount..")"
    end
end

-- function DebugView:dispose(clear)
--     self.super.dispose(self,clear)
-- end

return DebugView