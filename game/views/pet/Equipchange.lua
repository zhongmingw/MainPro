--
-- Author: wx
-- Date: 2018-01-12 19:38:13
-- 装备替换

local Equipchange = class("Equipchange",import("game.base.Ref"))

function Equipchange:ctor(param)
    self.view = param

    self:initView()
end

function Equipchange:initView()
    -- body
    local dec1 = self.view:GetChild("n12"):GetChild("n2")
    dec1.text = language.pet07

    local dec2 = self.view:GetChild("n13"):GetChild("n2")
    dec2.text = language.pet08

    self.list1 = self.view:GetChild("n8")
    self.list1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list1.numItems = 0
    self.list1.onClickItem:Add(self.onlist1CallBack,self)

    self.list2 = self.view:GetChild("n9")
    self.list2.itemRenderer = function(index,obj)
        self:cellpackdata(index, obj)
    end
    self.list2:SetVirtual()
    self.list2.numItems = 0
    self.list2.onClickItem:Add(self.onpackCallBack,self)

    local btn1 = self.view:GetChild("n6")
    btn1.onClick:Add(self.onCompose,self)

    local btn2 = self.view:GetChild("n7")
    btn2.onClick:Add(self.onGetEquip,self)
end

function Equipchange:setData(data)
    -- body
    self.data = data 

    self.list1.numItems = 6

    self.packdata = mgr.PetMgr:getPetPackEquip()
    self.list2.numItems = math.max((math.ceil(#self.packdata/18)*18),18)
    --print("self.list2.numItems",self.list2.numItems)
end

function Equipchange:celldata( index, obj )
    -- body
    local part = index + 1 
    local data = mgr.PetMgr:getEquipDataByPart(self.data,part)

    local frame = obj:GetChild("n0")
    frame.url = UIItemRes.pet01[part]

    local itemObj = obj:GetChild("n1")
    local t = data or {}
    -- if t.level then
    --     t.amount = t.level
    -- end
    GSetItemData(itemObj,t)

    local level = obj:GetChild("n2")
    level.text = ""
    -- local icon = obj:GetChild("n1")
    -- if data then 
    --     local condata = conf.ItemConf:getItem(data.mid) 
    --     icon.url = ResPath.iconRes(condata.src)
    -- else
    --     icon.url = nil
    -- end

    obj.data = {data = data ,part = part}
end

function Equipchange:onlist1CallBack( context )
    -- body
    local data = context.data.data
    local part = data.part
    --print(data.data)
    if data.data then
        --该部位有装备
        --printt("data.data",data.data)
        --有装备时显示装备，点击弹出tips
        local t = clone(data.data)
        t.notsenddata = true 
        GSeeLocalItem(t,{self.data,data.part}) 
    else
        --改部位无装备 
        --无装备时显示底，点击无反应
        print("无装备时显示底，点击无反应")
    end
end

function Equipchange:cellpackdata( index, obj )
    -- body
    local data = clone(self.packdata[index+1] or {})
    --local info = clone(data)
    --data.amount = data.level
    obj.data = data 

    local itemObj = obj:GetChild("n0")
    GSetItemData(itemObj,data or {},true)

    if data and data.mid then
        local condata = conf.ItemConf:getItem(data.mid)
        local info = mgr.PetMgr:getEquipDataByPart(self.data,condata.part)
        mgr.PetMgr:conTrastScore(itemObj,info,data)
    end

    
    
end
function Equipchange:onpackCallBack( context )
    -- body
    --点击弹出tips，若该部位已有装备，则显示tips对比
    local item = context.data
    local data = item.data
    if not data or not data.mid then
        item.selected = false
        return
    end
    local condata = conf.ItemConf:getItem(data.mid)
    if not condata then
        print("配置装备丢失",data.mid)
        return
    end
    local part = condata.part
    --local info = mgr.PetMgr:getEquipDataByPart(self.data,part)
    GSeeLocalItem(data,{self.data,part})
end


function Equipchange:onCompose()
    -- body
    --合成神备
    GOpenView({id = 1033 })
end

function Equipchange:onGetEquip()
    -- body
    --获得装备 玩法跳转
    --print("获取装备的位置跳转")
    GOpenView({id = 1191})
end

function Equipchange:addMsgCallBack(data)
    -- body
    if data.msgId == 5490104 or  data.msgId == 5040403 then
        --重新获取
        local info  = cache.PetCache:getPetData(self.data.petRoleId)
        if info then
            self:setData(info)
        end
    end
end






return Equipchange