--
-- Author: wx
-- Date: 2017-05-25 14:41:03
--查看其它玩家信息
local EquipPanel = import("game.views.pack.EquipPanel") --装备区域
local SeePropsPanel = import(".SeePropsPanel")
local ZuoPanel = import(".ZuoPanel") --坐骑技能和装备
local ZuoProPanel1 = import(".ZuoProPanel1") --坐骑界面的属性
local ZuoProPanel2 = import(".ZuoProPanel2") --伙伴界面的属性 
local SeeStrengPanel = import(".SeeStrengPanel")--强化界面
local SeeStarPanel = import(".SeeStarPanel")--升星界面
local SeeCameoPanel = import(".SeeCameoPanel")--宝石界面
local seePetPanel = import(".seePetPanel")--宠物界面

local SeeOtherMsg = class("SeeOtherMsg", base.BaseView)
--language.zuoqi01 = {"坐骑","神兵","法宝","仙羽","仙器"}
--language.huoban01 = {"灵童","灵羽","灵兵","灵宝","灵器"}
local dectable = {
    language.gonggong55,--属性
    language.zuoqi01[1],--坐骑
    language.zuoqi01[2],--神兵
    language.zuoqi01[3],--法宝
    language.zuoqi01[4],--"仙羽"
    language.zuoqi01[5],--仙器
    language.huoban01[1],--灵童
    language.huoban01[2],--灵羽
    language.huoban01[3],--灵兵
    language.huoban01[4],--灵宝
    language.huoban01[5],--灵器   
    language.forging37[1029],--强化
    language.forging37[1030],--升星
    language.forging37[1031],--宝石
    language.see01,--宠物
    language.gonggong94[1287],--麒麟臂
}

local indextable = {0,1,10,2,3,4,5,9,7,8,6,11,12,13,14,15}

function SeeOtherMsg:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2

    self.sharePackage = {"pet"}
end
-- data 必须包含需要传递的参数 比如roidID
function SeeOtherMsg:initData(data)
    -- body
    --printt("data",data)
    self.data = data

    if data.index then
        self.controllerC1.selectedIndex = data.index
    else
        self.controllerC1.selectedIndex = 0
    end
    if self.ZuoPanel then
        self.ZuoPanel:clear()
    end
    if self.seePetPanel then
        self.seePetPanel.model = nil 
    end

    self.param = {svrId = data.svrId or 0,roleId = data.roleId}
    if data.mainSvrId then
        self.param.svrId = data.mainSvrId 
    end

    proxy.SeeOtherMsgProxy:send(1370101,self.param)
    self:onbtnController()
    self.list2:AddSelection(self.controllerC1.selectedIndex,false)
end

function SeeOtherMsg:initView()
    local window2 = self.view:GetChild("window2")
    local closeBtn = window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)
    window2:GetChild("btn1").visible = false
    window2:GetChild("btn2").visible = false
    window2:GetChild("btn4").visible = false

    window2:GetChild("icon1").visible = false
    window2:GetChild("icon2").visible = false
    window2:GetChild("icon4").visible = false

    window2:GetChild("title1").visible = false
    window2:GetChild("title2").visible = false
    window2:GetChild("title4").visible = false


    window2:GetChild("n10").visible = false
    window2:GetChild("n23").visible = false
    window2:GetChild("n31").visible = false
    --金钱控制
    self.mone1 = window2:GetChild("title1")
    self.mone2 = window2:GetChild("title2")
    self.mone4 = window2:GetChild("title4")

    self.controllerC1 =  self.view:GetController("c1")
    self.controllerC1.onChanged:Add(self.onbtnController,self)

    --查看信息列表
    self.list2 = self.view:GetChild("n20")
    self.list2.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list2.numItems = #dectable
    self.list2.onClickItem:Add(self.onClickItem,self)

    self.panle1 = self.view:GetChild("n22")
    self.panle2 = self.view:GetChild("n23")
end

function SeeOtherMsg:celldata(index, obj)
    -- body
    obj.title = dectable[index+1]
    obj.data =  indextable[index+1]
end

function SeeOtherMsg:onClickItem(context)
    -- body
    self.controllerC1.selectedIndex = context.data.data
    --self:onbtnController()
end

function SeeOtherMsg:setData(data_)

end
--请求消息
function SeeOtherMsg:onbtnController()
    -- body
    if self.controllerC1.selectedIndex == 0 then --属性
        if not self.equipPanel then
            self.equipPanel = EquipPanel.new(self)
        end
        if not self.SeePropsPanel then 
            self.SeePropsPanel = SeePropsPanel.new(self.view:GetChild("rolepanel"))
        end
        self.SeePropsPanel:initRoleMsg()
        self.SeePropsPanel:initPropsMsg()
        --请求消息
        --printt("1370101",self.param)
        proxy.SeeOtherMsgProxy:send(1370101,self.param)
    elseif self.controllerC1.selectedIndex == 1 then --坐骑
        self:createItem()
        self.param.moduleId = 1001
        proxy.SeeOtherMsgProxy:send(1370102,self.param)
    elseif self.controllerC1.selectedIndex == 2 then --法宝
        self:createItem()
        self.param.moduleId = 1005
        proxy.SeeOtherMsgProxy:send(1370102,self.param)
    elseif self.controllerC1.selectedIndex == 3 then --仙羽
        self:createItem()
        self.param.moduleId = 1002
        proxy.SeeOtherMsgProxy:send(1370102,self.param)
    elseif self.controllerC1.selectedIndex == 4 then --仙器
        self:createItem()
        self.param.moduleId = 1004
        proxy.SeeOtherMsgProxy:send(1370102,self.param)
    elseif self.controllerC1.selectedIndex == 5 then --伙伴
        self:createItemHuoban()
        self.param.moduleId = 1006
        proxy.SeeOtherMsgProxy:send(1370102,self.param)
    elseif self.controllerC1.selectedIndex == 6 then --伙伴仙器
        self:createItem()
        self.param.moduleId = 1009
        proxy.SeeOtherMsgProxy:send(1370102,self.param)
    elseif self.controllerC1.selectedIndex == 7 then --伙伴神兵
        self:createItem()
        self.param.moduleId = 1008
        proxy.SeeOtherMsgProxy:send(1370102,self.param)
    elseif self.controllerC1.selectedIndex == 8 then --伙伴法宝
        self:createItem()
        self.param.moduleId = 1010
        proxy.SeeOtherMsgProxy:send(1370102,self.param)
    elseif self.controllerC1.selectedIndex == 9 then --伙伴仙羽
        self:createItem()
        self.param.moduleId = 1007
        proxy.SeeOtherMsgProxy:send(1370102,self.param)
    elseif self.controllerC1.selectedIndex == 10 then --神兵
        self:createItem()
        self.param.moduleId = 1003
        proxy.SeeOtherMsgProxy:send(1370102,self.param)
    elseif self.controllerC1.selectedIndex == 11 then--强化界面
        if not self.seeStrengPanel then
            self.seeStrengPanel = SeeStrengPanel.new(self)
        end
        proxy.ForgingProxy:send(1100101, {part = part,roleId = self.data.roleId,svrId = self.data.svrId})--鍛造部位信息
    elseif self.controllerC1.selectedIndex == 12 then--升星界面
        if not self.seeStarPanel then
            self.seeStarPanel = SeeStarPanel.new(self)
        end
        proxy.ForgingProxy:send(1100101, {part = part,roleId = self.data.roleId,svrId = self.data.svrId})--鍛造部位信息
    elseif self.controllerC1.selectedIndex == 13 then--宝石界面
        if not seeCameoPanel then
            self.seeCameoPanel = SeeCameoPanel.new(self)
        end
        proxy.ForgingProxy:send(1100101, {part = part,roleId = self.data.roleId,svrId = self.data.svrId})--鍛造部位信息
    elseif self.controllerC1.selectedIndex == 14 then--宠物界面
        if not self.seePetPanel then
            self.seePetPanel = seePetPanel.new(self)
        end
        self.seePetPanel.view.visible = false

        local param = {
            petRoleId = self.data.petRoleId or 0,
            roleId = self.data.roleId,
            svrId = self.data.svrId,
            viewType = 1
        }
      
        proxy.PetProxy:sendMsg(1490110, param)--鍛造部位信息
    elseif self.controllerC1.selectedIndex == 15 then--麒麟臂
        self:createItem()
        self.param.moduleId = 1287
        proxy.SeeOtherMsgProxy:send(1370102,self.param)
    end
end

function SeeOtherMsg:createItem()
    -- body
    if not self.ZuoPanel then
        self.ZuoPanel = ZuoPanel.new(self)
    end
    self.ZuoPanel:clear()
    if not self.ZuoProPanel1 then
        self.ZuoProPanel1 = ZuoProPanel1.new(self.panle1)
    end
    self.ZuoProPanel1:setIndex(self.controllerC1.selectedIndex)
end
function SeeOtherMsg:createItemHuoban()
    -- body
    if not self.ZuoPanel then
        self.ZuoPanel = ZuoPanel.new(self)
    end
    self.ZuoPanel:clear()
    if not self.ZuoProPanel2 then
        self.ZuoProPanel2 = ZuoProPanel2.new(self.panle2)
    end
end
--按照选中的皮肤设置属性
function SeeOtherMsg:onSkinBack(data)
    -- body
    if self.controllerC1.selectedIndex  == 5 then
        self.ZuoProPanel2:setData(data,self.info)
    else
        self.ZuoProPanel1:setData(data,self.info)
    end
end

function SeeOtherMsg:onSkincallBack( data )
    -- body
    self.ZuoPanel:initModel(data)
end

--查看属性
function SeeOtherMsg:add5370101(data)
    -- body
    -- printt("玩家属性")
    -- for k,v in pairs(data.attris) do
    --     print(k,v)
    -- end
    if data.attris64 and data.attris64[101] then--经验值
        data.attris[101] = data.attris64[101]
    end
    self.info = data
    self.equips = clone(data.equips)
    if self.SeePropsPanel then
        self.SeePropsPanel:setData(data)
    end
    local roledata = {}
    roledata.roleIcon = data.roleIcon
    roledata.level = data.lev
    roledata.skins = data.skins
    --printt("data.equips",data.equips)
    local equip = {}
    for k ,v in pairs(data.equips) do
        equip[v.index] = v
    end
    if self.equipPanel then
        self.equipPanel:setData(equip,roledata)
    end
end
--各个系统查看
function SeeOtherMsg:add5370102(data)
    -- body
    self.info = data
    self.ZuoPanel:setSelect(self.controllerC1.selectedIndex ,self.info)
end
--查看别人锻造信息
function SeeOtherMsg:add5100101(data)
    if self.controllerC1.selectedIndex == 11 then--强化界面
        if self.seeStrengPanel then
            self.seeStrengPanel:setData(data,self.equips)
        end
    elseif self.controllerC1.selectedIndex == 12 then--升星界面
        if self.seeStarPanel then
            self.seeStarPanel:setData(data,self.equips)
        end
    elseif self.controllerC1.selectedIndex == 13 then--宝石界面
        if self.seeCameoPanel then
            self.seeCameoPanel:setData(data,self.equips)
        end
    end
end

function SeeOtherMsg:addMsgCallBack(data)
    -- body
    --宠物信息查看
    if 5490110 == data.msgId then
        if self.seePetPanel then
            self.seePetPanel:setData(data)
        end
    end
end


function SeeOtherMsg:onClickClose()
    if self.equipPanel then
        self.equipPanel:clear()
    end
    self:closeView()
end


return SeeOtherMsg