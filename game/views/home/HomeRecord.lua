--
-- Author: wx
-- Date: 2017-11-20 19:32:49
-- 家园拜访记录

local HomeRecord = class("HomeRecord", base.BaseView)

function HomeRecord:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function HomeRecord:initData(data)
    -- body
    self.log = {}
    self:onReset()
end

function HomeRecord:initView()
    local btnClose = self.view:GetChild("n2"):GetChild("n2")
    self:setCloseBtn(btnClose)

    local btnReset = self.view:GetChild("n4")
    btnReset.onClick:Add(self.onReset,self)

    self.listView = self.view:GetChild("n3")
    --self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
end

function HomeRecord:celldata( index, obj )
    -- body
    local data = self.log[index+1]
    local text = obj:GetChild("n0")
    text.text = data
end

function HomeRecord:setData(data_)

end

function HomeRecord:onReset()
    -- body
    proxy.HomeProxy:sendMsg(1460107)
end
function HomeRecord:addComponent1(str)
    -- body
    local var = UIPackage.GetItemURL("home" , "Component1")
    local _compent1 = self.listView:AddItemFromPool(var)
    local lab = _compent1:GetChild("n0")
    lab.text = str
end
function HomeRecord:addComponent2(str,data)
    -- body
    local var = UIPackage.GetItemURL("_components" , "ChannelPanel")
    local _compent1 = self.listView:AddItemFromPool(var)
    local lab = _compent1:GetChild("n1")
    lab.text = str
    local btn = _compent1:GetChild("n0") 
    btn.data = data
    btn.onClick:Add(self.onGo,self)
end

function HomeRecord:onGo(context)
    -- body
    local data = context.sender.data
    if data then
        mgr.HomeMgr:goPosition(data)
    end
end

function HomeRecord:add5460107(data)
    -- body
    --self.data = data
    self.data = cache.HomeCache:getData()
    self.log = {}
    --固定检测 3条
    --1 检测成熟的
    self.listView.numItems = 0
    if cache.HomeCache:getisSelfHome() and self.data then
        --检测是否有种子 和 空田
        if mgr.HomeMgr:isEmtyTianAndSeed() then
            --
            self:addComponent2(language.home139[4],2)
        end
        --
        local _t = {}
        local _info = mgr.HomeMgr:getMature()
        for k,v in pairs(_info) do
            local cc = conf.HomeConf:getSeedByid(v.data.mId)
            _t[cc.level] = cc
        end
        for k ,v in pairs(_t) do
            local var = string.format(language.home139[1],k)
            --table.insert(self.log,var)
            self:addComponent2(var,2)
        end
        --2.检测温泉时间上线
        local max = conf.HomeConf:getValue("day_hot_spring_sec")
        if self.data.leftHotSpringSec > 0 then
            --table.insert(self.log,)
            self:addComponent2(language.home139[2],4)
        end
        --3.检测召唤次数
        --local max = conf.HomeConf:getValue("day_boss_call_max")

        if cache.HomeCache:getCallCount() == 0 then
           --table.insert(self.log,language.home139[3])
           self:addComponent2(language.home139[3],3)
        end

       
    end

    for k ,v in pairs(data.log) do
        self:addComponent1(v)
        --table.insert(self.log,v)
    end
    -- self.listView.numItems = #self.log
end


return HomeRecord