--
-- Author: 
-- Date: 2018-01-24 17:24:57
--

local LoginAward = import(".LoginAward")--登录豪礼
local HongBao1 = import(".HongBao1")--天降红包 
local HongBao2 = import(".HongBao2")--全服红包
local ChouQian = import(".ChouQian")--好运灵签 

local ChunJieMainView = class("ChunJieMainView", base.BaseView)
local PanelName = {
    [1201] = "LoginAward",
    [1202] = "Hongbao4",
    [1203] = "HongBao2",
    [1204] = "ChouQian",
}
local PanelClass = {
    [1201] = LoginAward,
    [1202] = HongBao1,
    [1203] = HongBao2,
    [1204] = ChouQian,
}
function ChunJieMainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
    self.showObj = {}
    self.classObj = {}
end

function ChunJieMainView:initData(data)
    -- body
    local activeData = cache.ActivityCache:get5030111()
    if not activeData then
        self:closeView()
        return
    end
    --抽取配置
    local confData = conf.ActivityConf:getChunjieActList()
    self.confData = {}
    --检测活动开关
    local flag = false
    for k,v in pairs(confData) do
        if activeData.acts and activeData.acts[v.id] and activeData.acts[v.id] == 1 then
            table.insert(self.confData,v)

            flag = true
        end
    end

    if not flag then
        self:closeView()
        return
    end
    self.listView.numItems = #self.confData
    self.modelId = data.index or self.confData[1].module_id
    self:initAct()

    self:addTimer(1, -1, handler(self, self.onTimer))
end

function ChunJieMainView:onTimer()
    -- body
end

function ChunJieMainView:initView()
    local window = self.view:GetChild("n4")
    self.window7 =  window:GetChild("n0")
    self.window7.icon = UIItemRes.chunjie01

    local btnClose = self.window7:GetChild("n5")
    self:setCloseBtn(btnClose)


    self.container = window:GetChild("n1")

    self.listView = window:GetChild("n3")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
    self.listView.numItems = 0
end

function ChunJieMainView:cellData(index, obj)
    local data = self.confData[index + 1]
    if data then
        obj.title = data.name or ""
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
end

function ChunJieMainView:onClickItem(context)
    local sender = context.data
    local data = sender.data
    self:createObj(data.module_id)
end

function ChunJieMainView:createObj(modelId)
    if not self.showObj[modelId] then --用来缓存
        local var = PanelName[modelId]
        self.showObj[modelId] = UIPackage.CreateObject("chunjie" ,var)
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

function ChunJieMainView:sendMsg()
    -- body
    if self.classObj[self.modelId] then 
        self.classObj[self.modelId]:sendMsg()
    end
end
--默认点击
function ChunJieMainView:initAct()
    local isFind = false
    for k = 1,self.listView.numItems do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local modelId = change.module_id
            if self.modelId == modelId then
                cell.onClick:Call()
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
            end
        end
    end
end

function ChunJieMainView:getChoosePanelObj(modelId)
    return self.showObj[modelId]
end



function ChunJieMainView:setData(data_)

end

function ChunJieMainView:addMsgCallBack(data)
    --print("ChunJieMainView")
    if self.classObj[self.modelId] then 
        self.classObj[self.modelId]:setData(data)
    end
    -- if self.modelId == 1166 and data.msgId == 5470101 then
    --     self.classObj[self.modelId]:setData(data)
    -- elseif self.modelId == 1165 and data.msgId == 5030303 then --EVE 兑换年货
    --     self.classObj[self.modelId]:setData(data)
    -- elseif data.msgId == 5030302 and self.modelId == 1164 or self.modelId == 1167 then --bxp 登录豪礼&收集桃符
    --     self.classObj[self.modelId]:setData(data)
    -- end
end

return ChunJieMainView