--
-- Author: Your Name
-- Date: 2017-12-18 20:53:24
--
local Active3013 = import(".Active3013")--圣诞活动登录豪礼
local Active3014 = import(".Active3014")--圣诞活动圣诞树
local Active3015 = import(".Active3015")--圣诞活动许愿袜
local Active3016 = import(".Active3016")--圣诞活动圣排行
local Active3017 = import(".Active3017")--圣诞活动击杀boss
local ChristmasActView = class("ChristmasActView", base.BaseView)

function ChristmasActView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function ChristmasActView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n5")
    btnClose.onClick:Add(self.onBtnClose,self)
    self.listView = self.view:GetChild("n3")
    self.listView.onClickItem:Add(self.onUIClickCall,self)
    self.panel = self.view:GetChild("n1")
    self:initListView()
end

function ChristmasActView:initData(data)
    self.classObj = {}
    if self.showObj then
        for k ,v in pairs(self.showObj) do
            v:Dispose()
        end 
    end
    self.showObj = {}
    self.childIndex = data.childIndex
    self:addTimer(1,-1,handler(self,self.onTimer))
end

function ChristmasActView:onTimer()
    
end

function ChristmasActView:initListView()
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function ChristmasActView:celldata(index,obj)
    local data = self.confData[index+1]
    if data then
        local title = obj:GetChild("title")
        if data.iconup then
            title.text = language.active40[data.id]
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
end

function ChristmasActView:nextStep(id)
    -- print("跳转",id)
    if id then
        for k,v in pairs(self.confData) do
            local cell = self.listView:GetChildAt(k - 1)
            local cellData = cell and cell.data or nil
            if cellData and cellData.id == id then
                self:initChoose(cell)
                self.listView:AddSelection(k-1,false)

                -- self.listView:ScrollToView(cellData.index)
                self.param = {id = id}
                self:openActive()
                break
            end
        end
    else
        self:initChoose(self.listView:GetChildAt(0))
        local cell = self.listView:GetChildAt(0)
        self.listView:AddSelection(0,false)
        self.param = {id = cell.data.id}
        self:openActive()
    end
end

--选中
function ChristmasActView:onUIClickCall(context)
    -- body
    local cell = context.data
    local data = cell.data
    self:initChoose(cell)
    --按活动ID打开界面
    self.param = {id = data.id}
    self:openActive()
end

function ChristmasActView:initChoose(cell)
    if self.oldCell then--self.oldCell.data.iconup
        local title = self.oldCell:GetChild("title")
        title.text = language.active40[self.oldCell.data.id]
    end

    if cell then
        self.oldCell = cell
        local title = cell:GetChild("title")
        title.text = language.active40[cell.data.id]
    end
end

function ChristmasActView:openActive()
    local id = self.param.id
    local falg = false
    if not self.showObj[id] then --用来缓存
        local index = id 
        local var = "Active"..index
        -- print("活动界面",index)
        self.showObj[id] = UIPackage.CreateObject("christmas",var)
        falg = true
        self.panel:AddChild(self.showObj[id])
    end
    --移除旧的
    -- self.panel:RemoveChildren()
    --添加新的
    for k,v in pairs(self.showObj) do
        if k == id then
            v.visible = true
        else
            v.visible = false
        end
    end
   
    if id == 3013 then--圣诞活动登陆豪礼
        if falg then
            self.classObj[id] = Active3013.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030162, {reqType = 1})
    elseif id == 3014 then--圣诞活动圣诞树
        if falg then
            self.classObj[id] = Active3014.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030164)
    elseif id == 3015 then--圣诞活动许愿袜
        if falg then
            self.classObj[id] = Active3015.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030163, {reqType=1})
    elseif id == 3016 then--圣诞活动圣诞狂欢排行
        if falg then
            self.classObj[id] = Active3016.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030165)
    elseif id == 3017 then--圣诞活动圣诞狂欢排行
        if falg then
            self.classObj[id] = Active3017.new(self.showObj[id])
        end
        self.classObj[id]:setCurId(id)
        proxy.ActivityProxy:sendMsg(1030164)
    end
end

function ChristmasActView:setData(data)
    -- print("开服天数",data.openDay)
    self.openDay = data.openDay
    local confData = conf.ActivityConf:getChristmasList() --圣诞活动
    self.confData = {} --日常活动列表里的活动
    for k,v in pairs(confData) do
        if data.acts[v.id] and data.acts[v.id] == 1 then
            table.insert(self.confData,v)
            if v.id == 3014 then--圣诞狂欢界面和圣诞树活动一起
                local param = clone(v)
                param.id = 3017
                param.icondown = "kaifujinjie_027"
                param.iconup = "kaifujinjie_028"
                table.insert(self.confData,param)
            end
        end
    end
    self.listView.numItems = #self.confData
    self:nextStep(self.childIndex)
end

--活动请求消息返回
function ChristmasActView:addMsgCallBack(data)
    if 5030162 == data.msgId and self.param.id == 3013 then--登录好礼
        self.classObj[self.param.id]:add5030162(data)
    elseif 5030164 == data.msgId and self.param.id == 3014 or self.param.id == 3017 then--圣诞树
        self.classObj[self.param.id]:add5030164(data)
    elseif 5030163 == data.msgId and self.param.id == 3015 then--许愿袜
        self.classObj[self.param.id]:add5030163(data)
    elseif 5030165 == data.msgId and self.param.id == 3016 then--圣诞排行
        self.classObj[self.param.id]:add5030165(data)
    end
end

function ChristmasActView:onBtnClose()
    self:closeView()
end

return ChristmasActView