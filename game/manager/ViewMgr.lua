--[[--
窗口管理
]]

local ViewMgr = class("ViewMgr")

function ViewMgr:ctor()
    self.isLock = false
    self.views = {}  --views
    self.openQueue = {}  --窗口打开队列
    self.curInfo = nil
    self.viewCount = 0

    self.uiAssetRef = {}


    self.eventRegis = {}
end

--初始化ui层级
function ViewMgr:init()
    if not self.baseLayer then
        self.minBaseLayer = UIPackage.CreateObject("root", "MinBaseLayer")
        self.baseLayer = UIPackage.CreateObject("root", "BaseLayer")
        self.uiLayer = UIPackage.CreateObject("root", "UILayer")
        self.topLayer = UIPackage.CreateObject("root", "TopLayer")
        self.maxTopLayer = UIPackage.CreateObject("root", "MaxTopLayer")
        GRoot.inst:AddChildAt(self.minBaseLayer, 0)
        GRoot.inst:AddChildAt(self.baseLayer, 1)
        GRoot.inst:AddChildAt(self.uiLayer, 2)
        GRoot.inst:AddChildAt(self.topLayer, 3)
        GRoot.inst:AddChildAt(self.maxTopLayer, 4)
    end
end
--获取ui层级
function ViewMgr:getLayer(index)
    if index == 0 then
        return self.minBaseLayer
    elseif index == 1 then
        return self.baseLayer
    elseif index == 2 then
        return self.uiLayer
    elseif index == 3 then
        return self.topLayer
    elseif index == 4 then
        return self.maxTopLayer
    end
    return GRoot.inst
end

--打开窗口[摒弃]
--viewName=窗口名称， callBack=窗口加载完毕回调， data=窗口打开数据initData中调用
function ViewMgr:openView(viewName, callBack, data)
    local view = self:createView(viewName)
    table.insert(self.openQueue, {vName=viewName, call=callBack, data=data})
    self:checkOpenView()
end

--打开窗口[推荐]
--viewName=打开的模块， data=打开模块完成initData(data)接口默认调用
function ViewMgr:openView2(viewName, data)
    local view = self:createView(viewName)
    table.insert(self.openQueue, {vName=viewName, data=data})
    self:checkOpenView()
end

--创建窗口数据 viewName_:文件名[const-ViewName]
function ViewMgr:createView(viewName)
    local view = self.views[viewName]
    if view ==  nil then
        local viewPackageName = "game.views." .. viewName
        local viewClass = require(viewPackageName)
        view = viewClass.new()
        view.__name = viewName
        local str = string.split(viewName, ".")
        view.__resname = "res/ui/"..str[1]
        view.__package = str[1]
        self.views[viewName] = view
        self.viewCount = self.viewCount + 1
        -- print("ViewMgr>>"..viewName..">>viewPath:  "..viewPackageName)
    end
    return view
end

--检测队列中是否还有窗口
function ViewMgr:checkOpenView()
    if self.isLock == false and #self.openQueue>0 then
        self.curInfo = table.remove(self.openQueue, 1)
        local vName = self.curInfo.vName
        local view = self.views[vName]
        -- 窗口没有加载就被移除了或者已经打开着
        if not view or view.isOpen == true then  
            self:checkOpenView()
            return
        end
        self.isLock = true
        view.openTime = os.time()
        local tempCount = 0
        --是否已经加载过UI
        if view.uiLoadSuccess == false then
            view:setCompleteCallBack(function(ero)
                if ero == -1 then
                    self:loadError()
                else
                    self:loadComplete(view, self.curInfo.data, false)
                end
                
                -- self.eventRegis[vName] = registerCount - tempCount    --记录次数暂时注释
            end)
            tempCount = registerCount
            view:loadUI()
        else
            self:loadComplete(view, self.curInfo.data, true)
        end
    end
end

function ViewMgr:loadError()
    self.isLock = false
end

--窗口打开完毕
function ViewMgr:loadComplete(view, data, isInit)
    if g_var.gameState == g_state.formal or g_var.gameState == g_state.ttFormal then  -- 外网正式环境调用。异常处理
        local ok,errorInfo = pcall(function()
            view.isOpen = true
            view:addStage()
            if not isInit then
                view:initView()
            end
            view:initData(data)
            if self.curInfo.call then
                self.curInfo.call(view)
            end
        end)
        if not ok then  --有报错
            self.isLock = false
            print(errorInfo)
        end
    else
        view.isOpen = true
        view:addStage()
        if not isInit then
            view:initView()
        end
        view:initData(data)
        if self.curInfo.call then
            self.curInfo.call(view)
        end
    end 
    
    self.isLock = false
    self:checkOpenView()
end

--获取view
--viewName_:文件名[const-ViewName]
function ViewMgr:get(viewname)
    local view = self.views and self.views[viewname]
    if view and view.isOpen == true and view.uiLoadSuccess == true then
        return view
    end
end

--此接口只能刷新数据，不可刷新UI
function ViewMgr:getData(viewName)
    if self.views then
        return self.views[viewName]
    end
end

function ViewMgr:getUiAssetRef(name)
    return self.uiAssetRef[name] or 0
end

--设置包的引用次数
function ViewMgr:setUiAssetRef(name, count, tag)
    local oRef = self.uiAssetRef[name] or 0
    local nRef = oRef + count
    if nRef > 0 then
        self.uiAssetRef[name] = nRef
    else
        self.uiAssetRef[name] = nil
    end
    --print("ui-package-refcount:", tag, ">>", name, "=", nRef, "状态", count)
    return nRef
end

--关闭窗口|关闭栈顶元素
function ViewMgr:closeView(viewName)
    local view = self.views[viewName]
    if view then
        if view.isOpen == true then
            view.isOpen = false
            if g_var.platform == Platform.ios then  --这里有个强制true，模拟IOS平台实时清理是否有问题
                local tempCount = registerCount
                self.views[viewName] = nil
                view:dispose(true)
                collectgarbage("collect")
                tempCount = tempCount - registerCount
                -- if self.eventRegis[viewName] then  -- 暂时注释
                --     print("@", viewName, "注册事件数目：",self.eventRegis[viewName],"移除：",tempCount)
                -- end
            else
                if view.uiClear and view.uiClear == UICacheType.cacheDisabled then
                    self.views[viewName] = nil
                    view:dispose(true)
                else
                    view:dispose()
                end
            end
        else
            --self.views[viewName] = nil
        end
    end
end

--清理UI缓存
--方式1：定时轮询机制，超过时间就清理-5分钟清理
--方式2：切换场景调用
--方式3：缓存窗口达到一定数目时候清理
function ViewMgr:clearCache(force)
    for k, v in pairs(self.views) do
        if v.isOpen == false and v.uiLoadSuccess then
            if v.uiClear ~= UICacheType.cacheForever then
                local ot = os.time() - (v.openTime or 0)
                if force or v.uiClear < ot then
                    --plog("模块清理:"..k..",剩余缓存:"..self.viewCount)
                    self.views[k] = nil
                    v:dispose(true)
                    self.viewCount = self.viewCount - 1
                end
            end
        end
    end 
end

--关闭所有窗口
function ViewMgr:closeAllView()
    for k, v in pairs(self.views) do
        if k ~= ViewName.DebugView then
            self:closeView(k)
        end 
    end
end

--关闭所有窗口2
function ViewMgr:closeAllView2(param)
    for k, v in pairs(self.views) do
        if v.isOpen == true then
            if k ~= ViewName.MainView and
               k ~= ViewName.Alert4 and
               k ~= ViewName.SitDownView and
               k ~= ViewName.LoadingView and 
               k ~= ViewName.BossHpView and
               k ~= ViewName.CollectBarView and
               k ~= ViewName.PickAwardsView and 
               k ~= ViewName.XinShouView and 
               k ~= ViewName.GuideBianSheng and
               k ~= ViewName.DeadView and 
               k ~= ViewName.AutoFindView and
               k ~= ViewName.FubenTipView and
               k ~= ViewName.ItemTipView and
               k ~= ViewName.DebugView and
               k ~= ViewName.AdvancedTipView and
               k ~= ViewName.ZuoqiTipView and
               k ~= ViewName.QuickUseView and
               k ~= ViewName.SkinTipsView and
	           k ~= ViewName.EquipWearTipView and 
               k ~= ViewName.ZhanChangTipView and
               k ~= ViewName.BlessTipView and
               k ~= ViewName.OverdueTipView and
               k ~= ViewName.Alert1 and 
               k ~= ViewName.GuideActive and 
               k ~= ViewName.TaskOneView and 
               k ~= ViewName.TrackView and
               k ~= ViewName.EliteBossTipView and
               k ~= ViewName.AchieveGetItem and 
               k ~= ViewName.BossDekaronView and 
               k ~= ViewName.FubenDekaronView and 
               k ~= ViewName.AwardsCaseView and 
               k ~= ViewName.FlagHoldView and
               k ~= ViewName.Alert15 and
               k ~= ViewName.DoubleMajorView and
               k ~= ViewName.XianMoFightView and
               k ~= ViewName.SceneSkillView and 
               k ~= ViewName.TopLockView and 
               k ~= ViewName.FlameView  and 
               k ~= ViewName.WeddingView  and 
               k ~= ViewName.MiniMapView and 
               k ~= ViewName.WarSkillView and
               k ~= ViewName.HomeMainView and 
               k ~= ViewName.BeachMainView and
               k ~= ViewName.LanternDtView and
               k ~= ViewName.DaTiView and
               k ~= ViewName.GetAgainView and 
               k ~= ViewName.RankProceedView and
               k ~= ViewName.XianLvTipsView and
               k ~= ViewName.XianLvPKProceedView and
               k ~= ViewName.TjdkTrackView and 
               k ~= ViewName.XianTongTongFang and
               k ~= ViewName.DanMuTipsView and
               k ~= ViewName.WSJDeadView then
                if not self:keepOpen(param,k) then
                    self:closeView(k)
                end
            end
        end
    end
end

function ViewMgr:keepOpen(param,var)
    -- body
    if not param then
        return false
    end

    for k ,v in pairs(param) do
        if v == var then
            return true
        end
    end

    return false
end

function ViewMgr:dispose(isThorough)
    --清理view
    self.uiAssetRef = {}
    for k, v in pairs(self.views) do
        self.views[k] = nil
        v:dispose(true)
        self.viewCount = self.viewCount - 1
    end
    --清理公共资源缓存
    for k, v in pairs(UICommonRes) do
        if UIPackage.GetByName(v) and v ~= "_audios" then  --不清理音频
            UIPackage.RemovePackage(v)
        end
    end
    --清理容器
    if isThorough then
        self.baseLayer:Dispose()
        self.uiLayer:Dispose()
        self.topLayer:Dispose()
        self.minBaseLayer:Dispose()
        self.maxTopLayer:Dispose()
    end
    --手动gc
    GameUtil.ClearMemory()
end

return ViewMgr