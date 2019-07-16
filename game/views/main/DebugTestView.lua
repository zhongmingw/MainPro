--[[

--]]

local DebugTestView = class("DebugTestView", base.BaseView)

function DebugTestView:ctor()
    self.super.ctor(self)
    self.isStartWin = true                 --是否是堆栈开始窗口
    self.isAddStack = true                 --是否加入到堆栈
    self.isBlack = false 
    self.uiLevel = UILevel.level3
    self.logText = "debug_log"
end



function DebugTestView:initView()
	self.isStartWin = true
  	local btn = self.view:GetChild("n4")
    btn.onClick:Add(DebugTestView.onGoClick, self)

    local btn2 = self.view:GetChild("n7")
    btn2.onClick:Add(self.onDebugClick, self)

    local btn3 = self.view:GetChild("n8")
    btn3.onClick:Add(self.onLogClick, self)

    self.view:GetChild("n3").onClick:Add(DebugTestView.onCloseClick,self)

    -- self.sexRadioGroup = self.view:GetController("SexRadioGroup")
    self.inputTxt = self.view:GetChild("n1")
    self.outputTxt = self.view:GetChild("n5")

    self.outputTxt.onClickLink:Add(self.onClickLinkText,self)--部分超链接系统广播
    local dragArea = self.view:GetChild("dragArea")
    if dragArea ~= nil then
        dragArea.draggable = true
        dragArea.onDragStart:Add(DebugTestView.__dragStart,self)
    end

    self.decList = self.view:GetChild("n26") 
    local n24 = self.view:GetChild("n24")
    n24.text = "DebugInputFlag"
    local a0 = self.view:GetChild("a0")
    a0.x = 680
    a0.y = 236
    n24.x = 715
    n24.y = 240
    local dInput = UPlayerPrefs.GetString("debug_input_flag")
    if dInput~=nil and dInput=="true" then
        a0.selected = true
    else
        a0.selected = false
    end    
    a0.onChanged:Add(function(arg1,arg2)
        if a0.selected == true then
            UPlayerPrefs.SetString("debug_input_flag","true")
        else
            UPlayerPrefs.SetString("debug_input_flag","false")
        end
        self:setTextList("debug_input_flag:"..UPlayerPrefs.GetString("debug_input_flag"))
    end,self)

    self.view:GetChild("a1").onClick:Add(function()
        -- local LogApt = class("LogApt", GameFramework.BaseLogAdapter)
        -- function LogApt:Log(arg1,arg2,arg2)
        --     self.outputTxt.text = arg3:ToInt().."|"..arg1
        -- end

        -- Debugger.logger = LogApt.new()
        -- Debugger.useLog = false

        local rd = {
            msgId=1390101,
            roleId='1011000120100000001',
            mid=221041702,
            amount=1073741823,
            auto=1,
        }
        mgr.NetMgr:send(rd.msgId,rd)

        end,self)

    self.view:GetChild("a2").onClick:Add(function()
        -- Debugger.LogError("aaa")
        -- error("aaaaaaaaaaaaaaa")
           mgr.ViewMgr:openView2(ViewName.HuobanExpPop,{})
    end,self)

    --测试拿包测试的时候不用删包重装直接清理缓存即可
    self.view:GetChild("a3").text = "清理缓存";
    self.view:GetChild("a3").onClick:Add(function()
        --self.view:GetChild("cccc").text = "aa"
        GameUtil.ExtendFunc(1002,"")
    end,self)

    self.view:GetChild("a4").text = "打开Test";
    self.view:GetChild("a4").onClick:Add(function()
        -- UnityEngine.Application.logMessageReceived = UnityEngine.Application.logMessageReceived + function(arg1,arg2,arg3)
        --     self.outputTxt.text = arg3:ToInt().."|"..arg1
        -- end
        local view = mgr.ViewMgr:get(ViewName.DebugView)
        if view then
            view:closeView()
        else
            mgr.ViewMgr:openView2(ViewName.DebugView)
        end
        end,self)

    local upUrl = "http://192.168.8.207/gupdate/update.zip";
    --更新
    self.view:GetChild("aupdate").onClick:Add(function()
        print("更新地址:",upUrl)
        GameUtil.StartUpdate(upUrl)
        end,self)

    self.view:GetChild("a6").text = "查看错误";
    self.view:GetChild("a6").onClick:Add(function()
        -- self.outputTxt.text = "lastError:"..GameUtil.LogErrorStr()
        self:setTextList("LastError:"..GameUtil.LogErrorStr())
        end,self)

    self.view:GetChild("a5").text = "错误Count";
    self.view:GetChild("a5").onClick:Add(function()
        self:setTextList("errorCount:"..GameUtil.LogErrorCount())
        end,self)

end

function DebugTestView:setData(data_)
    if string.byte(data_.resultStr) == 64 then --前缀为@的添加到列表
        self:setTextList(data_.resultStr)
    else
	   self:setOutputText(data_.resultStr)
    end
end

function DebugTestView:setOutputText(str)
    self.decList.visible = false
    self.outputTxt.visible = true
    self.outputTxt.text = str
end

--推拽事件
function DebugTestView:__dragStart(context)
    context:PreventDefault()
    self.view:StartDrag(context.data)
end

--点击超链接
function DebugTestView:onClickLinkText(context)
    local strList = string.split(context.data,"@@")--分离服务器名字

    if strList[1] == "scene" then
        local sId = strList[2]
        local posx = strList[3]
        local posy = strList[4]
        local point = Vector3.New(posx, gRolePoz, posy)
        local sConf = conf.SceneConf:getSceneById(sId)
        if sConf then
            mgr.TaskMgr:goTaskBy(sId,point)
        end
    elseif strList[1] == "send" then
        proxy.FubenProxy:send(1810302,{roleId = strList[2],reqType = 1})
    end
    print(strList[1])
end


function DebugTestView:onGoClick()
    if self.inputTxt.text == "cgsb" or self.inputTxt.text == "test3" then
        proxy.ZuoQiProxy:send(1120102,{auto = 0})
        proxy.ZuoQiProxy:send(1160102,{reqType = 0})
        proxy.ZuoQiProxy:send(1140102,{reqType = 0})
        proxy.ZuoQiProxy:send(1180102,{reqType = 0})
        proxy.ZuoQiProxy:send(1170102,{reqType = 0})
        proxy.HuobanProxy:send(1200201,{reqType = 1})
        proxy.HuobanProxy:send(1220103,{reqType = 0})
        proxy.HuobanProxy:send(1210102,{reqType = 0})
        proxy.HuobanProxy:send(1240102,{reqType = 0})
        proxy.HuobanProxy:send(1230102,{reqType = 0})
        -- return
    elseif self.inputTxt.text == "blsb" then
        if g_bang_inout then
            g_bang_inout = false
        else
            g_bang_inout = true
        end
        return
    elseif self.inputTxt.text == "log" then
        local log = UPlayerPrefs.GetInt("debug_log_view")
        if log == 0 then
            UPlayerPrefs.SetInt("debug_log_view", 1)
            self:onDebugClick()
        else
            UPlayerPrefs.SetInt("debug_log_view", 0)
        end
        return
    elseif self.inputTxt.text == "csyx" then
        g_var.yx_game_param = "zjx"
        proxy.YouXunProxy:sendMsg(1020507,{game = g_var.yx_game_param})
        mgr.ViewMgr:get(ViewName.MainView):checkOpen()
        return
    elseif self.inputTxt.text == "csyq" then
        g_var.yx_game_param = "yjpt"
        proxy.YouXunProxy:sendMsg(1020507,{game = g_var.yx_game_param})
        mgr.ViewMgr:get(ViewName.MainView):checkOpen()
        return
    elseif self.inputTxt.text == "csyq1" then
        g_var.packId = "6900"
        return
    elseif self.inputTxt.text == "csyq2" then
        g_var.packId = "6901"
        return
    end

    proxy.LoginProxy:reqTestCmd(self.inputTxt.text)    
end

function DebugTestView:onDebugClick( ... )
    GameUtil.LogInit(0) --关闭自定义日志输出
    if g_var.gameFrameworkVersion < 12 then
        GameUtil.ExtendFunc(1001)
    else
        GameUtil.ExtendFunc(1001,"")
    end
end

function DebugTestView:onLogClick()
    local log = ""
    --打印定时器信息
    log = "g_var.yx_game_param="..tostring(g_var.yx_game_param) .." "..log  
    log = log.."定时器信息："
    local timers = mgr.TimerMgr.timerObj
    for key, value in pairs(timers) do
        log = log..(value.tag or "未知").."&"
    end
    log = log.."\n"
    log = log.."玩家State:"..gRole:getStateID()
    log = log.."\n"
    
    if g_var.gameFrameworkVersion >= 2 then
        log = log.."==========================\n"
        log = log..UPoolMgr:DumpPoolObject()
        log = log.."\n==========================\n"
        log = log..UEffectMgr:DumpEffect()
        log = log.."\n==========================\n"
        log = log..UnityResMgr:DumpAssetBundle()
    end

    self.decList:GetChild("n0").text = log

    cache.FightCache:dumpInfo()

    mgr.HookMgr:dumpInfo()

end

function DebugTestView:setTextList(str)
    self.outputTxt.visible = false
    self.decList.visible = true
    self.decList:GetChild("n0").text = str
end


function DebugTestView:onCloseClick()
	self:closeView()
end


return DebugTestView