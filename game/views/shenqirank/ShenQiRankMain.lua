--
-- Author: 
-- Date: 2018-07-02 11:18:24
--神器排行

local ShenQiRankMain = class("ShenQiRankMain", base.BaseView)

local ShenQiRank = import(".ShenQiRank") --神器战力排行
local ShenQiReturn = import(".ShenQiReturn") --神器寻宝返还


function ShenQiRankMain:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
    self.showObj = {}
    self.classObj = {}
end

local PanelName = {
    [1249] = "ShenQiRank",
    [1250] = "ShenQiReturn",
}
local PanelClass = {
    [1249] = ShenQiRank,
    [1250] = ShenQiReturn,
}
local ActId = {
    -- 1091,
    1092,
    1106,
    1186,
    1187,
}

function ShenQiRankMain:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n5")
    closeBtn.onClick:Add(self.onBtnClose,self)
    self.container = self.view:GetChild("n1")
    self.listView = self.view:GetChild("n3")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
end

function ShenQiRankMain:initData(data)
    local activeData = cache.ActivityCache:get5030111()
    if not activeData then
        self:onBtnClose()
        return
    end
    local confData = conf.ActivityConf:getShenQiList()
    self.confData = {}
    local flag = false
    for k,v in pairs(ActId) do
        if activeData.acts and activeData.acts[v] and activeData.acts[v] == 1 then
            flag = true
            break
        end
    end
    if flag then
        for k,v in pairs(confData) do
            if activeData.acts[v.id] and activeData.acts[v.id] == 1 then
                table.insert(self.confData,v)
            end
        end
        
        self.listView.numItems = #self.confData
        self.moduleId = data.index or self.confData[1].module_id
        self:initAct()
        if self.timertick then 
            self:removeTimer(self.timertick)
            self.timertick = nil
        end
        if not self.timertick then 
            self:onTimer()
            self.timertick = self:addTimer(1, -1, handler(self, self.onTimer))
        end
    else
        GComAlter(language.vip11)
        self:onBtnClose()
    end
end

function ShenQiRankMain:onTimer()
    self.classObj[self.moduleId]:onTimer()
end
function ShenQiRankMain:cellData(index,obj)
    --图片
    local data = self.confData[index+1]
    if data then
        local icon = obj:GetChild("icon")
        if data.iconup then 
            icon.url = UIPackage.GetItemURL("shenqirank" ,data.iconup)
        end
        obj.data = data
        if data.redid then
            local param = {}
            param.panel = obj:GetChild("n4")
            param.text = obj:GetChild("n5") 
            param.ids = {data.redid}
            param.notnumber = true
            mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
        end
    end

    -- local data = self.confData[index+1]
    -- if data then
    --     obj.title = data.name or ""
    --     obj.data = data
    --     if data.redid then
    --         local param = {}
    --         param.panel = obj:GetChild("n4")
    --         param.text = obj:GetChild("n5") 
    --         param.ids = {data.redid}
    --         param.notnumber = true
    --         mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    --     end
    -- end
end

function ShenQiRankMain:initAct()
    local isFind = false
    for k = 1,self.listView.numItems do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local moduleId = change.module_id
            if self.moduleId == modelId then
                cell.onClick:Call()
                self:initChoose(cell)
                isFind =true
                break
            end
        end
    end
    if not isFind then
        if self.listView.numItems > 0 then
            local cell = self.listView:GetChildAt(0)
            if cell then
                cell.onClick:Call()
                self:initChoose(cell)
            end
        end
    end
end


function ShenQiRankMain:onClickItem(context)
    local cell = context.data
    local data = cell.data

    self:createObj(data.module_id)
    self:initChoose(cell)
end
function ShenQiRankMain:initChoose(cell)
    if self.oldCell then
        local icon = self.oldCell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("shenqirank" ,self.oldCell.data.iconup)
    end

    if cell then 
        self.oldCell = cell
        local icon = cell:GetChild("icon")
        icon.url = UIPackage.GetItemURL("shenqirank" ,cell.data.icondown)
    end
end
function ShenQiRankMain:createObj(moduleId)
    if not self.showObj[moduleId] then 
        local name = PanelName[moduleId]
        self.showObj[moduleId] = UIPackage.CreateObject("shenqirank",name)
        self.container:AddChildAt(self.showObj[moduleId],0)
    end
    if not self.classObj[moduleId] then
        self.classObj[moduleId] = PanelClass[moduleId].new(self,moduleId)   
    end
    for k,v in pairs(self.showObj) do
        if k == moduleId then
            v.visible = true
        else
            v.visible = false
        end
    end
    self.moduleId = moduleId
    self:sendMsg()
end

function ShenQiRankMain:getPanelObj(moduleId)
    return self.showObj[moduleId]
end

function ShenQiRankMain:sendMsg()
    local activeData = cache.ActivityCache:get5030111()
    if self.moduleId == 1249 then --神器战力排行
        if activeData.acts and activeData.acts[1091] and activeData.acts[1091] == 1 then
            proxy.ActivityProxy:sendMsg(1030409)--开服神奇排行
        elseif activeData.acts and activeData.acts[1092] and activeData.acts[1092] == 1 then
            proxy.ActivityProxy:sendMsg(1030410)--限时神器排行
        elseif activeData.acts and activeData.acts[1186] and activeData.acts[1186] == 1 then
            proxy.ActivityProxy:sendMsg(1030414)--合服神器排行
        end
    elseif self.moduleId == 1250 then --神器寻宝返还
        if activeData.acts and activeData.acts[1186] and activeData.acts[1186] == 1 then

            proxy.ActivityProxy:sendMsg(1030415,{reqType = 0,cfgId = 0})--合服神器排行
        else
            proxy.ActivityProxy:sendMsg(1030413,{reqType = 0,cfgId = 0})
        end
    end
end
--服务器返回信息
function ShenQiRankMain:addMsgCallBack(data)


    if data.msgId == 5030409 or data.msgId == 5030410 or data.msgId == 5030414 then
        self.classObj[self.moduleId]:setData(data)
    elseif data.msgId == 5030413 and self.moduleId == 1250 then
        self.classObj[self.moduleId]:setData(data)
    elseif data.msgId == 5030415 and self.moduleId == 1250 then
        self.classObj[self.moduleId]:setData(data)    
    end
end

function ShenQiRankMain:onBtnClose()
    if self.timertick then
        self:removeTimer(self.timertick)
        self.timertick = nil
    end
    self:closeView()
end

function ShenQiRankMain:setData(data)

end

return ShenQiRankMain