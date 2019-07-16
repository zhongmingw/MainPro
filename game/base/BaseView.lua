--[[--
游戏窗口基类
]]

local BaseView = class("BaseView", import("game.base.Ref"))

function BaseView:ctor()
    self.parent = nil
    self.view = nil  --游戏对象
    self.callBackFunc = nil
    self.uiLoadSuccess = false
    self.prefabsCount = 0
    self.isOpen = false
    self.isGuide = false
    self.drawcall = true

    self.models = {}
    self.timer = {} --定时器
    self.effects = {}  --界面特效
    self:initParams()
    self.extraui = {}

    self.sharePackage = {}

    self.backLoadRes = {}

    self.time = 0    --弹窗效果专用计时变量
end

---------------------public------------------------
--初始化view显示参数 [[子类继承修改]]
function BaseView:initParams()
    self.uiLevel = UILevel.level2           --窗口层级
    self.isBlack = false                    --是否添加黑色背景
    --self.uiClear = UICacheType.cacheForever 
end

--初始化UI [[子类继承]]  --只调用一次
function BaseView:initView()
    
end
--初始化数据 [[子类继承]] --每次打开调用
function BaseView:initData(data)
    --print("BaseView:initData--->>>data")
    local data = cache.GuideCache:getData()
    if data then
        if data.type == 12 then
            mgr.XinShouMgr:growUpAlert(data)
            cache.GuideCache:setData(nil)
        end
    end
end

---------------------特效---------------------------
--添加UI特效 | effId=效果id， parent=父容器
function BaseView:addEffect(effId,parent)
    local e, t = mgr.EffectMgr:playUIEffect(effId,parent)
    if e and t==-1 then
        self.effects[e.Name] = e
    end
    return e,t
end
function BaseView:removeUIEffect(e)
    if e then
        --print("移除特效",e.Name)
        if self.effects[e.Name] then
            mgr.EffectMgr:removeUIEffect(e)
            self.effects[e.Name] = nil 
        end
    end
end
----------------------------------------------------

---------------------模型---------------------------
--添加模型 id=模型id， parent=模型容器， func=模型加载完毕回调返回模型对象
function BaseView:addModel(id, parent, func,action)
    local model = thing.UIModel.new()
    model:playAnimation(action)
    --model:setSkins(id, 3020101, "3030101_ui")
    model:setParent(parent)
    local check = model:setSkins(id)
    self.prefabsCount = self.prefabsCount + 1
    local name = "model_"..self.prefabsCount
    model:setName(name)
    model:setScale(200)
    self.models[name] = model
    return model, check
end

function BaseView:removeModel(model)
    if not model then
        return
    end
    model:dispose()
    local name = model:getName()
    self.models[name] = nil
    model = nil
end
----------------------------------------------------

function BaseView:_getPackageName()
    return self.__package
end
function BaseView:_getResName()
    return self.__resname
end
function BaseView:__getResName( ... )
    return self.__resname.."@"
end
function BaseView:viewName()
    return self.__name
end
function BaseView:getClassName()
  return self.__cname
end

function BaseView:loadUI()
    self.parent = mgr.ViewMgr:getLayer(self.uiLevel)
    local function packageSuc(ero)
        if ero == -1 then
            if self.callBackFunc then
                self.callBackFunc(-1)
            end
            return
        end
        self.view = UIPackage.CreateObject(self:_getPackageName(), self:getClassName())
        if self.drawcall then
            self.view.fairyBatching = true
        end
        self.view:SetSize(GRoot.inst.width, GRoot.inst.height)
        self.uiLoadSuccess = true
        if self.callBackFunc then
            self.callBackFunc()
        end
    end
    if self.sharePackage and #self.sharePackage > 0 then  --优先加载关联包
        local count = #self.sharePackage
        for k, v in pairs(self.sharePackage) do
            local resStr = "res/ui/"..v
            mgr.ViewMgr:setUiAssetRef(v, 1, self:viewName())
            unity.createUIPackage(resStr, v, function()
                count = count - 1
                if count <= 0 then
                    mgr.ViewMgr:setUiAssetRef(self:_getPackageName(), 1, self:viewName())
                    unity.createUIPackage(self:_getResName(),self:_getPackageName(),packageSuc)
                end
            end)
        end
    else
        mgr.ViewMgr:setUiAssetRef(self:_getPackageName(), 1, self:viewName())
        unity.createUIPackage(self:_getResName(),self:_getPackageName(),packageSuc)
    end
end

function BaseView:addStage()
    if self.isBlack then
        self:addBlackbg()
    end
    self.parent:AddChildAt(self.view, self.parent.numChildren)
    self:addWinEffect()
end

--添加弹窗效果
function BaseView:addWinEffect()
    if self.openTween == ViewOpenTween.scale then
        self.view:SetPivot(0.5, 0.5)
        
        self.view:SetScale(0.1, 0.1)
        self.view:TweenScale(Vector2.New(1.1, 1.1), 0.13)
        self:addTimer(0.13, 1, function()
            -- body
            self.view:TweenScale(Vector2.New(1, 1), 0.25)
        end)
    end
end


--添加灰色背景
function BaseView:addBlackbg()
    if not self.blackView then
        self.blackView = UIPackage.CreateObject("_components", "BlackWindow")
        if self.blackView then
            self.blackView:SetSize(GRoot.inst.width, GRoot.inst.height)
        end
    end
    if self.blackView then
        self.parent:AddChildAt(self.blackView, self.parent.numChildren)
    end
end
--EVE 移除灰色背景
function BaseView:removeBlackbg()
    if self.blackView then  --移除黑色背景
        if self.parent then
            self.parent:RemoveChild(self.blackView)
        end
    end
end

function BaseView:setCompleteCallBack(func)
    if func then
        self.callBackFunc = func
    end
end

---------------------定时器-------------------------
--view添加定时器
function BaseView:addTimer(delay, loop, func, tag)
    if not self.totalTimers then
        self.totalTimers = {}
    end
    local t = mgr.TimerMgr:addTimer(delay, loop, func, tag or self:getClassName())
    self.totalTimers[t] = t
    return t
end
--view移除定时器
function BaseView:removeTimer(timer)
    if not self.totalTimers then
        return
    end
    if self.totalTimers[timer] then
        mgr.TimerMgr:removeTimer(timer)
    end
end
----------------------------------------------------

---------------------引导---------------------------
function BaseView:startGuide(data)
    self.isGuide = true
    self.guidedata = data
    self.guideInfo = data.guide
    self.guideIndex = 1
    self:updateGuide(self.guideInfo[self.guideIndex])
end
function BaseView:nextGuide()
    if not self.isGuide then return end
    self.guideIndex = self.guideIndex + 1
    if self.guideIndex <= #self.guideInfo then
        self:updateGuide(self.guideInfo[self.guideIndex])
    else
        self:clearGuide()
    end
end
function BaseView:updateGuide(str)
    local ns = string.split(str, ".")
    local child = self.view
    --plog(#ns,str)
    for i=1, #ns do
        if child then
            child = child:GetChild(ns[i])
        else
            child = nil
            break
        end
    end
    if child and child.parent then
        local param = {btn = child,class = self,guidedata = self.guidedata}
        if self.openTween and self.openTween == ViewOpenTween.scale then
            mgr.TimerMgr:addTimer(0.4, 1, function()
                -- body
                mgr.ViewMgr:openView2(ViewName.GuideLayer,param)
            end)
        else
            mgr.TimerMgr:addTimer(0.2, 1, function()
                -- body
                mgr.ViewMgr:openView2(ViewName.GuideLayer,param)
            end)
            --mgr.ViewMgr:openView2(ViewName.GuideLayer,param)
        end
        
    else
        --TODO 终止指引
        self.isGuide = false
    end
end
function BaseView:clearGuide()
    if not self.isGuide then
        return 
    end
    self.isGuide = false

    if self.guidedata then
        local nextid = self.guidedata.nextguideid
        local id = self.guidedata.guideid
        self.guidedata = nil 
        if nextid then 
            local condata = conf.XinShouConf:getOpenModule(nextid)
            mgr.XinShouMgr:checkXinshou(condata) 
            return
        end
        if id == 1075 or id == 1081 or 1091 == id or 1103 == id 
            or id == 1107 or id == 1049 or id == 1119 or id == 1123 then
        else
            GgoToMainTask()
        end
    end  
end
----------------------------------------------------
--清理事件--部分清理事件的方法
function BaseView:clearEvent()

end

--view关闭窗口
function BaseView:closeView()
    mgr.ViewMgr:closeView(self:viewName(), true)
end
--通用窗口关闭事件
function BaseView:setCloseBtn(btn)
    btn.onClick:Add(self.closeView, self)
end

--清理fairygui
function BaseView:clearUI()
    local function clearTable(t)
        if type(t) == "table" then
            for k, v in pairs(t) do
                if k ~= "class" and v ~= self and type(t) == "table" then
                    clearTable(v)
                end  
            end
        end

        if type(t) == "table" and t["removeAllEvent"] then
            t:removeAllEvent()
        end

        if type(t) == "table" and t["clearFairygui"] then
            t:clearFairygui()
        end
    end
    clearTable(self)
end

function BaseView:addExtraUI(key)
    if not self.extraui then self.extraui = {} end
    self.extraui[key] = 1
end

function BaseView:setLoaderUrl(loader, url)
    if loader then
        loader.url = url
        self.backLoadRes[url] = 1
    end
end

--[virtual]
function BaseView:doClearView(clear)
    -- 子类重写,窗口清理必调此方法
end

function BaseView:dispose(clear)
    self:doClearView(clear)
    self:clearEvent()
    self.callBackFunc = nil
    mgr.GuiMgr:disposePanel(self:viewName(), clear)  --移除gui引用
    --移除所有定时器
    if self.totalTimers then 
        for k,v in pairs(self.totalTimers) do
            self:removeTimer(k)
        end
    end
    self.totalTimers = {}
    --清理特效
    if self.effects then
        for k ,v in pairs(self.effects) do
            mgr.EffectMgr:removeUIEffect(v)
        end
    end
    
    self.effects = {}
    --清理view上的模型
    if self.models then
        for k, v in pairs(self.models) do
            v:dispose()
        end
    end
    self.models = {}
    --清理view
    if clear then
        --分包资源url
        if self.backLoadRes then
            for k, v in pairs(self.backLoadRes) do
                if g_var.gameFrameworkVersion >= 2 then
                    UnityResMgr:ForceDelAssetBundle(k)
                end
            end
        end
        
        if self.blackView then  --移除黑色背景
            self.blackView:Dispose()
        end
        self.blackView = nil
        if self.view then
            self.view:Dispose()
        end
        if self.sharePackage then
            for k,v in pairs(self.sharePackage) do
                self:removePackage(v)
            end
        end
        self:removePackage(self:_getPackageName())
        self:clearUI()
        self.view = nil
    else
        if self.blackView then  --移除黑色背景
            self.parent:RemoveChild(self.blackView)
        end
        self.parent:RemoveChild(self.view)
    end
end

function BaseView:removePackage(name)
    local ref = mgr.ViewMgr:setUiAssetRef(name, -1, self:viewName())
    if ref <= 0 then
        if UIPackage.GetByName(name) then
            UIPackage.RemovePackage(name, true)
        end
    end
end

return BaseView