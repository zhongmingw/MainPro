--
-- Author: 
-- Date: 2018-02-22 14:26:45
--
--符文系统主界面
local RuneInlay = import(".RuneInlay")--符文镶嵌
local RuneChange = import(".RuneChange")--符文兑换
local RuneCompose = import(".RuneCompose")--符文合成
local RuneSplit = import(".RuneSplit")--符文分解
local RuneMainView = class("RuneMainView", base.BaseView)

local PanelName = {
    [1213] = "RuneInlay",
    [1214] = "RuneChange",
    [1215] = "RuneCompose",
    [1216] = "RuneSplit",
}
local PanelClass = {
    [1213] = RuneInlay,
    [1214] = RuneChange,
    [1215] = RuneCompose,
    [1216] = RuneSplit,
}
local redPoints = {
    [1213] = attConst.A10257,--符文镶嵌红点
}

function RuneMainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
    self.showObj = {}
    self.classObj = {}
end

function RuneMainView:initView()
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.container = self.view:GetChild("n2")
    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
end

function RuneMainView:initData(data)
    self.selectIndex = 0
    proxy.RuneProxy:send(1500101)
    self.fuwenTypes = conf.RuneConf:getFuwenGlobal("fuwen_types")
    self.listView.numItems = #self.fuwenTypes
    self.modelId = data.index or self.fuwenTypes[1]
    self:initSystem()
    self:addTimer(1, -1, handler(self, self.onTimer))
end

function RuneMainView:onTimer()
    
end

function RuneMainView:initSystem()
    local isFind = false
    for k = 1,self.listView.numItems do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local modelId = change.id
            if self.modelId == modelId then--选中boss
                cell.onClick:Call()
                isFind = true
                break
            end
        end
    end
    if not isFind then
        if self.listView.numItems > 0 then
            local cell = self.listView:GetChildAt(0)
            if cell then
                cell.onClick:Call()
            end
        end
    end
end

function RuneMainView:addServerCallback(data)
    self.classObj[self.modelId]:setData(data)
end

function RuneMainView:refreshPack()
    if self.modelId == 1216 then
        self.classObj[self.modelId]:refreshPack()
    end
end
--升级符文
function RuneMainView:severUpRune(data)
    self.classObj[1213]:severUpRune(data)
end

function RuneMainView:cellData(index, obj)
    local id = self.fuwenTypes[index + 1]
    local confData = conf.SysConf:getModuleById(id)
    if confData then
        obj.title = confData.name or ""
        obj.data = confData
        obj.data.index = index + 1
        obj.onClick:Add(self.onClickBtn,self)
        if redPoints[id] then
            local param = {}
            param.panel = obj:GetChild("red")
            param.ids = {redPoints[id]}
            mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
        end
    end
end

function RuneMainView:getChoosePanelObj(modelId)
    return self.showObj[modelId]
end

function RuneMainView:onClickBtn(context)
    local sender = context.sender
    local data = sender.data
    if self.selectIndex ~= data.index then
        self:createObj(data.id)
        self.selectIndex = data.index
    end
end

function RuneMainView:createObj(modelId)
    if not self.showObj[modelId] then --用来缓存
        local var = PanelName[modelId]
        self.showObj[modelId] = UIPackage.CreateObject("rune" ,var)
        self.container:AddChildAt(self.showObj[modelId],0)--添加新的
    end
    if not self.classObj[modelId] then
        self.classObj[modelId] = PanelClass[modelId].new(self,modelId)   
    end
    for k,v in pairs(self.showObj) do
        if k == modelId then
            v.visible = true
        else
            v.visible = false
        end
    end
    self.modelId = modelId
    self:sendMsg()
end

function RuneMainView:sendMsg()
    if self.modelId == 1213 then--符文镶嵌
        proxy.RuneProxy:send(1500102,{reqType = 0, srcIndexs = {},dstIndexs = {}})
    elseif self.modelId == 1214 then --符文兑换
        plog("1500202",1500202)
        proxy.RuneProxy:send(1500202,{reqType = 1, cid = 1,amount = 0})
    elseif self.modelId == 1215 then--符文合成 
        proxy.RuneProxy:send(1500105,{reqType = 1,dressIndexs = {},packIndexs = {},itemId = 0})
    elseif self.modelId == 1216 then--符文分解
        proxy.RuneProxy:send(1500104,{reqType = 0,decmColors = {}})
    end
end

function RuneMainView:doClearView(clear)
    if self.classObj[1213] then
        self.classObj[1213]:clear()
    end
end

return RuneMainView