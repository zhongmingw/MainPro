--
-- Author: ohf
-- Date: 2017-03-27 12:01:05
--
--福利大厅
local WelfareView = class("WelfareView", base.BaseView)

local NoticePanel = import(".NoticePanel")--更新公告
local OnlinePanel = import(".OnlinePanel")--在线奖励
-- local OfflinePanel = import(".OfflinePanel")--离线经验
local ResFindPanel = import(".ResFindPanel")--资源找回
local SignPanel = import(".SignPanel")--签到奖励
local VipBagPanel = import(".VipBagPanel")--vip礼包
local PrivilegePanel = import(".PrivilegePanel")--仙尊特权
local ActivationPanel = import(".ActivationPanel")--激活码
local OnHookPanel = import(".OnHookPanel")--离线挂机

local GradePackage = import(".GradePackage")--EVE 等级礼包

local FlashSalePanel = import(".FlashSalePanel")--EVE 限时特卖

local VipWorkPanel = import(".VipWorkPanel")--vip礼包

local InviteCodePanel = import(".InviteCodePanel")

local pack = "welfare"

local PanelName = {
    "GradePackage",
    "OnlinePanel",
    "OnHookPanel",
    "ResFindPanel",
    "SignPanel",
    "VipBagPanel",
    "PrivilegePanel",
    "ActivationPanel",
    "NoticePanel",
    "InviteCodePanel",
    "FlashSalePanel",
    "VipWorkPanel",
}
local PanelClass = {
    GradePackage,
    OnlinePanel,
    OnHookPanel,
    ResFindPanel,
    SignPanel,
    VipBagPanel,
    PrivilegePanel,
    ActivationPanel,
    NoticePanel,
    InviteCodePanel,
    FlashSalePanel,
    VipWorkPanel,
}

function WelfareView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function WelfareView:initData(data)
    self.data = nil
    self.nextId = 1
    self.confData = conf.ActivityConf:getAllWelfare()
    self:removeGradePackage()
    self:removeFlashSale()
    self:removeActivationInvite()--邀请码删除
    if g_ios_test then
        self:removeActivationInvite()
        self:removeGift()
    end
    self.childIndex = data.childIndex or 0
    self.id = 0
    if self.flag or data.index == 11 or data.index == 3 then
        self:nextStep(data.index)
    else
        self:nextStep(1)
    end

    --EVE 福利大厅专用计时器
    self:addTimer(1,-1,handler(self,self.onTimer))

    -- if cache.PlayerCache:getRedPointById(attConst.A20127) > 100 then
        -- self:removeItemById(1)
    -- end
    -- self:refreshRedData(data)
end

function WelfareView:onTimer()
    -- body
    if not self.id then
        return
    end

    if self.id ~= 11 then  --需要倒计时的模块在，这里改一下
        return
    end

    if not self.classObj then
        return
    end

    if not self.classObj[self.id] then
        return
    end

    self.classObj[self.id]:onTimer()
end

--等级礼包特定情况下删除
function WelfareView:removeGradePackage()
    if cache.PlayerCache:getRoleLevel() >= conf.ActivityConf:getValue("grade_package_lv") then --EVE 达到配置等级以后，活动才会消失

        local var = cache.PlayerCache:getRedPointById(attConst.A30130)
        -- print("等级礼包结束红点",var)
        -- print("等级礼包红点",cache.PlayerCache:getRedPointById(attConst.A20127))

        if var == 1 then
            for k,v in pairs(self.confData) do
                if v.id == 1 then
                    table.remove(self.confData,k)
                    self.flag = true
                end
            end
        end
    end
end

--限时特卖购买结束
function WelfareView:removeFlashSale()
    -- body
    local var = cache.PlayerCache:getRedPointById(10258)
    --print("限时特卖结束",var)
    if var == 0 then
        for k,v in pairs(self.confData) do
            if v.id == 11 then
                table.remove(self.confData,k)
                --self.listView.numItems = #self.confData
                --local cell = self.listView:GetChildAt(0)
                --cell.onClick:Call()
                break
            end
        end
    end
end

--删除邀请码
function WelfareView:removeActivationInvite()
    for k,v in pairs(self.confData) do
        if v.id == 10 then
            table.remove(self.confData,k)
            break
        end
    end
end

--删除礼包码
function WelfareView:removeGift()
    for k,v in pairs(self.confData) do
        if v.id == 8 then
            table.remove(self.confData,k)
            break
        end
    end
end

function WelfareView:initView()
    self.showObj = {}
    self.classObj = {}
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n5")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.listView = self.view:GetChild("n4")
    -- listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
    self.container = self.view:GetChild("n5")

    --EVE 标志位，判断等级礼包是否移除(为了打开福利大厅时自动选中第一个活动)
    self.flag = false
end

--某条活动到时间后移除
function WelfareView:removeItemById(id)
    for k,v in pairs(self.confData) do
        local cell = self.listView:GetChildAt(k - 1)
        local cellData = cell and cell.data or nil
        if cellData and cellData.data.id == id then
            table.remove(self.confData,k)
        end
    end
    self.listView.numItems = #self.confData

end

function WelfareView:nextStep(id)
    if id then
        self.nextId = id
    end
    self.listView.numItems = #self.confData
    self:initRed()
    -- self.listView:ScrollToView(self.nextId - 1)
    for k,v in pairs(self.confData) do
        local cell = self.listView:GetChildAt(k - 1)
        local cellData = cell and cell.data or nil
        if cellData and cellData.data.id == id then
            self.listView:ScrollToView(cellData.index)
            break
        end
    end
end
--红点
function WelfareView:initRed()
    if self.classObj[6] then
        self.classObj[6]:initRed()--vip礼包
    end
end
--在线福利
function WelfareView:updateOnline(data)
    self:refreshRedData(data)
    self.classObj[2]:setData(data)
end
--离线挂机
function WelfareView:updateOffHook(data)
    self:refreshRedData(data)
    self.classObj[3]:setData(data)
end
--离线挂机自动吞噬设置
function WelfareView:updateAutoCheck(Type)
    -- body
    self.classObj[3]:setCheck(Type)
end
--资源找回
function WelfareView:updateResData(data)
    self:refreshRedData(data)
    self.classObj[4]:setData(data)
end
--签到奖励
function WelfareView:updateSign(data)
    self:refreshRedData(data)
    self.classObj[5]:setData(data)
end
--vip
function WelfareView:updateVip(data)
    -- print("vip周礼包返回")
    -- printt(data)
    self:refreshRedData(data)
    self.classObj[12]:setData(data)
end
--仙尊特权
function WelfareView:updateXianzhun(data)
    self:refreshRedData(data)
    self.classObj[7]:setData(data)
end
--礼包码
function WelfareView:updatelvLbM(data)
    self:refreshRedData(data)
    self.classObj[8]:setData(data)
end
--更新公告
function WelfareView:updateNotice(data)
    self:refreshRedData(data)
    self.classObj[9]:setData(data)
end
--等级礼包
function WelfareView:updateGradePackage(data)
    self:refreshRedData(data)
    self.classObj[1]:setData(data)
end
--等级礼包
function WelfareView:updateInviteCode(data)
    self:refreshRedData(data)
    self.classObj[10]:setData(data)
end

--0点刷新离线挂机红点
function WelfareView:refHookRed()
    if self.classObj[3] then
        self.classObj[3]:refreshRed()
    end
end

--限时特卖
function WelfareView:updateFlashSalePanel(data)
	self:removeFlashSale()
    self:refreshRedData(data)

    local var = cache.PlayerCache:getRedPointById(10258)
    if var <= 0 then
        --self.listView:RemoveChild()
        for i = 0 , self.listView.numItems do
            local cell = self.listView:GetChildAt(i)
            local data = cell.data
            local info = data.data
            if info and info.id == 11 then
                self.listView:RemoveChild(cell)

                self.listView:GetChildAt(0).onClick:Call()
                break
            end
            --if cell.data and cell.data.data.id ==
        end
    end
    self.classObj[11]:setData(data)
end

function WelfareView:refreshRedData(data)
    local redid = self.data.redid
    if redid and data.reqType and data.reqType > 0 then
        local num = cache.PlayerCache:getRedPointById(redid)
        if data.vipId then--如果是vip礼包
            local lqNum = 1
            if data.reqType == 3 then
                lqNum = table.nums(data.vipDaySigns)
            elseif data.reqType == 4 then
                lqNum = table.nums(data.vipWeekSigns)
            end
            cache.PlayerCache:setRedpoint(redid,num - lqNum)
        elseif data.resourceList then--资源找回
            if #data.resourceList <= 0 then
                cache.PlayerCache:setRedpoint(redid,0)
            end
        else
            if redid ~= 20137 then
                if data.onlineTime and data.reqType == 1 then -- 在线奖励
                    local onLineNum = cache.PlayerCache:getAttribute(attConst.A20130) or 0
                    cache.PlayerCache:setAttribute(attConst.A20130,onLineNum + 1)
                end
                cache.PlayerCache:setRedpoint(redid,num - 1)
            end
        end
        mgr.GuiMgr:updateRedPointPanels(redid)
    end

    mgr.GuiMgr:refreshMainRed()
end

function WelfareView:cellData(index, cell)
    local data = self.confData[index + 1]
    cell.data = {data = data,index = index}
    cell.icon = UIPackage.GetItemURL(pack , data.normal_img)
    cell.selectedIcon = UIPackage.GetItemURL(pack , data.selected_img)
    if data.id == self.nextId then
        cell.selected = true
        local context = {data = cell}
        self:onClickItem(context)
    else
        cell.selected = false
    end
    local redimg = cell:GetChild("n4")
    local redText = cell:GetChild("n5")
    if data.redid and data.redid ~= 20128 and data.redid ~= 20137 then --EVE 屏蔽离线挂机红点20137
        local param = {}
        param.panel = redimg
        param.text = redText
        param.ids = {data.redid}
        param.notnumber = true
        mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    else
        redimg.visible = false
        redText.visible = false
    end
end

function WelfareView:onClickItem(context)
    local cell = context.data
    local data = cell.data
    self.data = data.data
    self.nextId = data.index + 1
    if self.id ~= self.data.id then
        self:setPanelData(self.data.id)
        self.id = self.data.id
    end
end

function WelfareView:setPanelData(id)
    local falg = false
    if not self.showObj[id] then --用来缓存
        local var = PanelName[id]
        self.showObj[id] = UIPackage.CreateObject(pack ,var)
        --移除旧的
        -- self.container:RemoveChildren()
        --添加新的
        self.container:AddChild(self.showObj[id])
        falg = true
    end

    for k,v in pairs(PanelName) do
        if k == id then
            if falg then
                self.classObj[id] = PanelClass[id].new(self,self.showObj[id])
            end
            self.classObj[id]:setVisible(true)
            if id == 3 then
                self.classObj[id]:nextStep(self.childIndex)
            end
            self.classObj[id]:sendMsg()
        else
            if self.classObj[k] then
                self.classObj[k]:setVisible(false)
            end
        end
    end
    self.mId = id
end

function WelfareView:onClickClose()
    self:closeView()
end

return WelfareView
