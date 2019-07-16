--
-- Author: wx
-- Date: 2018-01-12 20:15:52
-- 装备升级
--默认筛选条件
local starnumber = 0 --
local color = 3
local equipup = class("equipup",import("game.base.Ref"))

function equipup:ctor(param)
    self.view = param
    self:initView()
end

function equipup:initView()
    -- body
    local dec1 = self.view:GetChild("n21"):GetChild("n2")
    dec1.text = language.pet09

    local dec2 = self.view:GetChild("n22"):GetChild("n2")
    dec2.text = language.pet10 

    local dec3 = self.view:GetChild("n15")
    dec3.text = language.pet11

    self.list1 = self.view:GetChild("n9")
    self.list1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list1.numItems = 0
    self.list1.onClickItem:Add(self.onlist1CallBack,self)

    self.list2 = self.view:GetChild("n10")
    self.list2.itemRenderer = function(index,obj)
        self:cellpackdata(index, obj)
    end
    self.list2.numItems = 0
    self.list2:SetVirtual()
    self.list2.onClickItem:Add(self.onpackCallBack,self)
    --筛选条件
    self.imgcall = self.view:GetChild("n11") 
    self.imgcall.onClick:Add(self.onSelectCall,self)

    self.starbtn = self.view:GetChild("n7")  
    self.starbtn.onClick:Add(self.onstarbtnCall,self)

    self.labelText = self.view:GetChild("n18")
    self.labelText.text = ""

    self.lablev = self.view:GetChild("n16")
    self.lablev.text = ""

    self.bar = self.view:GetChild("n8")
    self.bar.value = 0
    self.bar.max = 0

    self.desc = self.view:GetChild("n17")
    self.desc.text = ""

    self.btnget = self.view:GetChild("n6")
    self.btnget.onClick:Add(self.onGetEquip,self)

    self.group = self.view:GetChild("n20")
    self.list3 = self.group:GetChild("n1")
    self.list3.itemRenderer = function(index,obj)
        self:celllistdata(index, obj)
    end
    self.list3.numItems = 0
    
    self.list3.onClickItem:Add(self.onSelectCallBack,self)
end

function equipup:setData(data)
    -- body
    --筛选条件
    self.btnget.visible = false

    self.data = data

    
    self.list1.numItems = 6

    if not self.part then
        for i = 1 , 6 do
            if mgr.PetMgr:getEquipDataByPart(self.data,i) then
                self.part = i 
                break
            end
        end
    end
    if self.part then
        self.list1:AddSelection(self.part-1,false)
        self:setMsg()
    end

    self.group.visible = false
    self.starbtn.selected = false
    self.packdata = mgr.PetMgr:getPetPackEquip()
    self.starnumber = starnumber
    self.color = color

    self.list3.numItems = #language.huoban46[2]

    self.labelText.text = language.huoban46[2][self.color-2]
    self:starSelect()
    self.list2.numItems = math.max((math.ceil(#self.packdata/12)*12),12)
end

function equipup:setMsg()
    -- body
    local data = mgr.PetMgr:getEquipDataByPart(self.data,self.part)
    if not data then
        print("找不到装备@wx")
        return
    end

    self.lablev.text = language.gonggong83..data.level

    local condata = conf.ItemConf:getItem(data.mid)
    if not condata then
        print("道具配置缺少",data.mid)
        return
    end
    local info = clone(data)
    info.level = info.level + 1 
    local _condata = conf.PetConf:getEquipLevelUp(info)


    self.bar.value = data.exp
    self.bar.max = (_condata and _condata.need_exp) and _condata.need_exp or data.exp

    if not _condata then
        self.bar.visible = false
        self.desc.visible = false
        self.btnget.visible = false

        self.lablev.text = language.gonggong83..language.gonggong13
    else
        self.desc.visible = true
        self.bar.visible = true
        self.btnget.visible = true
    end
end
--计算经验
function equipup:setExp()
    -- body
    local exp = 0
    for k ,v in pairs(self.selectlist) do
        if v[1] then
            exp = exp + mgr.PetMgr:getEquipExp(v[2])
            -- local condata = conf.ItemConf:getItem(v[2].mid)
            -- if condata then
            --     exp = exp + (condata.partner_exp or 0)
            -- end
        end
    end
    local str = clone(language.pet14)
    str[2].text = string.format(str[2].text,exp)
    self.desc.text = mgr.TextMgr:getTextByTable(str)
end

function equipup:celldata( index, obj )
    -- body
    local part = index + 1 
    local data = mgr.PetMgr:getEquipDataByPart(self.data,part)

    local frame = obj:GetChild("n0")
    frame.url = UIItemRes.pet01[part]

    local itemObj = obj:GetChild("n1")
    local t = data or {}
    -- if t.level then
    --     t.amount = data.level
    -- end
    GSetItemData(itemObj,t)


    -- local icon = obj:GetChild("n1")
    -- if data then 
    --     local condata = conf.ItemConf:getItem(data.mid) 
    --     icon.url = ResPath.iconRes(condata.src)
    -- else
    --     icon.url = nil
    -- end

    obj.data = {data = data ,part = part}
end

function equipup:onlist1CallBack(context)
    -- body
    local data = context.data.data
    local part = data.part
    if data.data then
        --该部位有装备
        self.part = part
        self:setMsg()
    else
        --改部位无装备 
        --1.上面是身上的六个装备格子，需选中，无法选中没有装备的格子
        if self.part then
            self.list1:AddSelection(self.part-1,false)
        end
    end
end

function equipup:cellpackdata( index, obj )
    -- body
    local t = clone(self.packdata[index+1] or {})
    t.isquan = true
    obj.data = t

    local itemObj = obj:GetChild("n0")
    GSetItemData(itemObj,t)

    local level = obj:GetChild("n2")
    level.text = ""
   
    --筛选条件
    if t.index then
        obj.selected = self.selectlist[t.index][1]
    else
        obj.selected = false
    end
end

function equipup:onpackCallBack(context)
    -- body
    local item = context.data
    local data = item.data
    if data.index then
        self.selectlist[data.index][1] = item.selected 
        self:setExp()
    else
        item.selected = false
    end
end

function equipup:onSelectCall()
    -- body
    --筛选条件
    self.group.visible = not self.group.visible
end

function equipup:celllistdata( index,obj )
    -- body
    local color = index + 1 + 2
    obj.title = language.huoban46[2][index + 1]
    obj.data = color

    obj.selected = false
end

function equipup:onSelectCallBack(context)
    -- body
    self:onSelectCall()
    local data = context.data.data
    --筛选条件确定
    self.color = data 
    self.labelText.text = language.huoban46[2][self.color-2]

    self:starSelect()

    self.list2:RefreshVirtualList()
end

function equipup:onstarbtnCall()
    -- body
    if self.starbtn.selected then
        self.starnumber = 1
    else
        self.starnumber = starnumber
    end
    self:starSelect()

    self.list2:RefreshVirtualList()
end

function equipup:starSelect()
    -- body
    self.selectlist = {}
    for k  , v in pairs(self.packdata) do

        if mgr.PetMgr:isCondition(v,self.color,self.starnumber) then
            self.selectlist[v.index] = {true,v}
        else
            self.selectlist[v.index] = {false,v}
        end
    end

    --经验计算
    self:setExp()
end

function equipup:onGetEquip()
    -- body
    if not self.data then
        return
    end
    if not self.part then
        return GComAlter(language.pet12)
    end
    local param = {}
    param.petRoleId = self.data.petRoleId
    param.part = self.part
    param.indexs = {}
    for k  , v in pairs(self.selectlist) do
        if v[1] then
            table.insert(param.indexs,k)
        end
    end
    if #param.indexs <= 0 then
        return GComAlter(language.pet13)
    end
    --printt("1490105",param)
    proxy.PetProxy:sendMsg(1490105,param)
end

function equipup:addMsgCallBack(data)
    -- body
    if data.msgId == 5490105 or  data.msgId == 5040403 then
        local info  = cache.PetCache:getPetData(self.data.petRoleId)
        if info then
            self:setData(info)
        end
    end
end


return equipup