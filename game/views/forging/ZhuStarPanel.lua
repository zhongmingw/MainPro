--
-- Author: wx
-- Date: 2017-12-06 11:22:15
--
local max = 9 --装备最高阶
local ZhuStarPanel = class("ZhuStarPanel",import("game.base.Ref"))

local _iconlist = {
    [9] = "baoshi_004",
    [10] = "baoshi_010",
    [11] = "baoshi_008",
    [12] = "baoshi_033"
}
function ZhuStarPanel:ctor(mParent)
    self.view = mParent
    self:initPanel()
end

function ZhuStarPanel:initPanel()
    -- body
    self.equip_jinjie_min_cfg = conf.ForgingConf:getValue("equip_jinjie_min_cfg")
    self.equip_zuxing_min_cfg = conf.ForgingConf:getValue("equip_zuxing_min_cfg")

    --选择列表
    self.listView = self.view:GetChild("n1")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onClickItemCall,self)

    self.c1 = self.view:GetController("c1")

    local btn = self.view:GetChild("n52")
    btn.onClick:Add(self.onCallBack,self)
    -- self.frame = {}
    -- for i = 39 , 42 do
    --     local icon = self.view:GetChild("n"..i) 
    --     table.insert(self.frame,icon)
    -- end
    self.iconlist = {}
    for i = 47 , 50 do
        local icon = self.view:GetChild("n"..i) 
        icon.onClick:Add(self.onIconCall,self)
        table.insert(self.iconlist,icon)
    end
    self.text = {}
    for i = 53 , 54 do
        local icon = self.view:GetChild("n"..i) 
        table.insert(self.text,icon)
    end
    self.itemObj = {}
    for i = 59 , 62 do
        table.insert(self.itemObj,self.view:GetChild("n"..i))
    end
    
    self.dec =  self.view:GetChild("n55")

    local btnGuize = self.view:GetChild("n11")
    btnGuize.onClick:Add(self.onGuize,self)
end

function ZhuStarPanel:checkCon(condata,info)
    -- body
    if not condata or not info  then
        return false
    end
    if self.c1.selectedIndex == 1 then
        if max == condata.stage_lvl then
            return false
        end

        if condata.stage_lvl >= self.equip_jinjie_min_cfg[1]
        and condata.color >= self.equip_jinjie_min_cfg[2]
        and mgr.ItemMgr:getColorBNum(info) >= self.equip_jinjie_min_cfg[3] then
            local next_lvl = math.min(max,condata.stage_lvl+1)
            return true
        else
            return false
        end
    else
        if condata.stage_lvl >= self.equip_zuxing_min_cfg[1]
        and condata.color >= self.equip_zuxing_min_cfg[2]
        and mgr.ItemMgr:getColorBNum(info) == self.equip_zuxing_min_cfg[3] then
            return true
        else
            return false
        end
    end
    return false
end

function ZhuStarPanel:celldata( index, obj )
    -- body
    local data = self.confdata[index+1]
    local btn = obj:GetChild("n7")
    local icon = btn:GetChild("icon")
    local itemObj = btn:GetChild("n11")
    local name = obj:GetChild("n4")
    local red = obj:GetChild("red")
    obj.data = index
    red.visible = false
    local info = cache.PackCache:getEquipDataByPart(data.part)
    local equipData = cache.PackCache:getEquipDataByPart(data.part)
    if equipData then
        local color = conf.ItemConf:getQuality(equipData.mid)
        if color == 7 then--神装不能进阶，不能祝星
            info = nil
        end
    end
    -- printt("equipData",equipData)
    icon.url = UIPackage.GetItemURL("forging" , _iconlist[data.part])
    if not info then
        --没有穿戴的时候
        icon.visible = true
        itemObj.visible = false
        name.text = ""
        if self.c1.selectedIndex == 0 then
            name.text = string.format(language.forging83,language.equip06[data.part])
        else
            name.text = string.format(language.forging78,self.equip_jinjie_min_cfg[1],language.equip06[data.part])
        end
          
        return
    end
    icon.visible = false
    itemObj.visible = true
    --print("info.mid",info.mid)
    GSetItemData(itemObj,info)
    local condata = conf.ItemConf:getItem(info.mid)
    --[最低阶数,最低品质,进阶最低星数]
    if self.c1.selectedIndex == 0 then
        --铸星
        red.visible  = G_equip_zhuxin(condata.part)>0
        
        if self:checkCon(condata,info) then
            name.text = string.format(language.forging76,language.equip06[condata.part])
        else
            name.text = string.format(language.forging83,language.equip06[condata.part])
        end
    else
        --进阶
        red.visible  = G_equip_jie(condata.part)>0

        if condata.stage_lvl == max then
            --最高阶了
            name.text = string.format(language.forging79,language.equip06[condata.part] )
            return
        end
        if self:checkCon(condata,info) then
            local next_lvl = math.min(max,condata.stage_lvl+1)
            name.text = string.format(language.forging77,next_lvl,language.equip06[condata.part]) 
        else
            name.text = string.format(language.forging78,self.equip_jinjie_min_cfg[1],language.equip06[condata.part])
        end
    end
end

function ZhuStarPanel:clear()
    -- body
    --print(debug.traceback()
    for k ,v in pairs(self.iconlist) do
        v.data = nil 
        v.url = nil 
    end
    for k , v in pairs(self.text) do
        v.text = ""
    end
    -- for k ,v in pairs(self.frame) do
    --     v.url = UIPackage.GetItemURL("forging" ,"jiezhizhuxingjinjie_006")
    -- end
    for k ,v in pairs(self.itemObj) do
        GSetItemData(v,{})
    end
end

function ZhuStarPanel:setSelect(index)
    -- body
    self:clear()
    self.isCan = false
    self.c1.selectedIndex = index
    if index == 0 then
        --铸星
        self.dec.text = language.forging75
    else
        --进阶
        self.dec.text = ""--language.forging74
    end
    self.confdata = conf.ForgingConf:getDataByType(index+1)
    table.sort(self.confdata,function(a,b)
        -- body
        return a.id < b.id
    end)
    self.listView.numItems = #self.confdata
    if not self.index then
        self.index = 0
    end
    if self.index then
        self.listView:AddSelection(self.index,false)
        self:setData(self.confdata[self.index+1])
    end
end

function ZhuStarPanel:onClickItemCall(context)
    -- body
    local data = context.data.data
    self.index = data
    self:setData(self.confdata[data+1])
end

function ZhuStarPanel:setData(data)
    -- body
    self:clear()
    self.isCan = false
    self.needlv = 0
    self.data = data
    self.cc = nil 
    if self.c1.selectedIndex == 0 then
         if data.id == 3 then
            --铸星
            self.dec.text = language.forging75
        else
            --进阶
            self.dec.text = language.forging74
        end
        --默认第3个格子放icon
        local t = {}
        if data.part == 11 then
            t = {mid = PackMid.zhuxinshijiezi,amount = 1 ,bind = 0}
        else
            t = {mid = PackMid.zhuxinshishouzuo,amount = 1 ,bind = 0}
        end
        
        GSetItemData(self.itemObj[3],t,true)


        -- self.iconlist[3].data = t
        -- local _itemconf = conf.ItemConf:getItem(t.mid)
        -- self.iconlist[3].url = mgr.ItemMgr:getItemIconUrlByMid(t.mid)
        -- self.frame[3].url = ResPath.iconRes("beibaokuang_00".._itemconf.color)

        self.iconlist[4].data = nil
        local info = cache.PackCache:getEquipDataByPart(data.part)
        --print("indo.mid",info.mid)
        if not info then
            self.iconlist[2].url = UIPackage.GetItemURL("forging" ,"taozhuang_022")
            self.iconlist[4].url = UIPackage.GetItemURL("forging" ,"taozhuang_022")
            return
        end
        local condata = conf.ItemConf:getItem(info.mid)
        if not self:checkCon(condata,info) then
            self.iconlist[2].url = UIPackage.GetItemURL("forging" ,"taozhuang_022")
            self.iconlist[4].url = UIPackage.GetItemURL("forging" ,"taozhuang_022")
            return
        end
        --第一个是身上穿戴的
        GSetItemData(self.itemObj[2],info,true)
        -- self.iconlist[2].data = info
        -- self.iconlist[2].url = mgr.ItemMgr:getItemIconUrlByMid(info.mid)
        -- --print("condata.color",condata.color)
        -- self.frame[2].url = ResPath.iconRes("beibaokuang_00"..condata.color)
        --第二个要选择
        self.iconlist[4].url = UIPackage.GetItemURL("forging" ,"baoshi_028")
        self.iconlist[4].data = nil 

        local needconf = conf.ForgingConf:getZhuxinById(info.mid)
        if not needconf then
            print("Z-装备锻造配置 equip_star02 缺少id",info.mid)
            return
        end
        local cost = needconf.cost_item[1]
        local _itemconf = conf.ItemConf:getItem(cost[1])
        local _t = {mid = cost[1],amount = 1,bind = 0}
        GSetItemData(self.itemObj[3],_t,true)
        -- self.iconlist[3].data = {mid = cost[1],amount = 1,bind = 0}
        -- self.iconlist[3].url = mgr.ItemMgr:getItemIconUrlByMid(cost[1])
        -- self.frame[3].url = ResPath.iconRes("beibaokuang_00".._itemconf.color)
        local packdata = cache.PackCache:getPackDataById(cost[1])
        if packdata.amount >= cost[2] then
            self.isCan = true
            self.text[2].text = packdata.amount .. "/" ..  cost[2]
        else
            self.isCan = false
            self.text[2].text = mgr.TextMgr:getTextColorStr(packdata.amount,14).."/" ..  cost[2]
        end

        --上面 下一阶的道具
        local nextinfo = clone(info)
        nextinfo.index = 0
        nextinfo.colorAttris = nil
        nextinfo.colorStarNum = mgr.ItemMgr:getColorBNum(info) + 1 
        GSetItemData(self.itemObj[1],nextinfo,true)

    else
        --进阶
        --1、当没有选择装备时或选择的装备不符合进阶要求时，不显示道具信息
        local info = cache.PackCache:getEquipDataByPart(data.part)
        if not info then
            return
        end
        local condata = conf.ItemConf:getItem(info.mid)
        if not self:checkCon(condata,info) then
            return
        end
        local needconf = conf.ForgingConf:getJingjieById(info.mid)
        if not needconf then
            --
            print("Z-装备锻造配置 equip_jinjie 缺少id",info.mid)
            return
        end
        --//左下角道具框显示穿戴的装备
        GSetItemData(self.itemObj[2],info,true)

        -- self.iconlist[2].data = info
        -- self.iconlist[2].url = mgr.ItemMgr:getItemIconUrlByMid(info.mid)
        -- self.frame[2].url = ResPath.iconRes("beibaokuang_00"..condata.color)
        --//右下角道具框显示需要的材料icon+icon右下角显示当前数量/需要数量，不满足用红色
        local cost = needconf.cost_item[1]
        local _itemconf = conf.ItemConf:getItem(cost[1])
        local _t = {mid = cost[1],amount = 1,bind = 0}
        GSetItemData(self.itemObj[3],_t,true)
        -- self.iconlist[3].data = _t
        -- self.iconlist[3].url = mgr.ItemMgr:getItemIconUrlByMid(cost[1])
        -- self.frame[2].url = ResPath.iconRes("beibaokuang_00".._itemconf.color)
        local packdata = cache.PackCache:getPackDataById(cost[1])
        if packdata.amount >= cost[2] then
            self.isCan = true
            self.text[2].text = packdata.amount .. "/" ..  cost[2]
        else
            self.isCan = false
            self.text[2].text = mgr.TextMgr:getTextColorStr(packdata.amount,14).."/" ..  cost[2]
        end
        --上面 下一阶的道具
        local nextinfo = clone(info)
        nextinfo.mid = needconf.upmid
        nextinfo.index = 0
        nextinfo.colorAttris = nil
        nextinfo.colorStarNum = mgr.ItemMgr:getColorBNum(info)
        GSetItemData(self.itemObj[1],nextinfo,true)

        local _dd = conf.ItemConf:getItem(needconf.upmid)
        if _dd.lvl > cache.PlayerCache:getRoleLevel() then
            self.needlv = _dd.lvl
        end
    end
end

function ZhuStarPanel:inputdata(info)
    -- body
    self.cc = info
    self.iconlist[4].data = info
    if not self.cc then
        self.cc = {}
    end 

    local _t = clone(self.cc)
    _t.func = function()
    -- body
        self.iconlist[4].onClick:Call()
    end
    

    GSetItemData(self.itemObj[4],_t,true)
    -- local condata = conf.ItemConf:getItem(info.mid)
    -- self.iconlist[4].data = info
    -- self.iconlist[4].url = mgr.ItemMgr:getItemIconUrlByMid(info.mid)
    -- self.frame[4].url = ResPath.iconRes("beibaokuang_00"..condata.color)
end

function ZhuStarPanel:onCallBack(context)
    -- body
    local info = cache.PackCache:getEquipDataByPart(self.data.part)
    if not info then
        GComAlter(language.forging80)
        return
    end
    local condata = conf.ItemConf:getItem(info.mid)
    if not self:checkCon(condata,info) then
        GComAlter(language.forging81)
        return
    end
    if not self.isCan then
        GComAlter(language.forging82)
        return
    end
    if self.c1.selectedIndex == 0 then
        if not self.iconlist[4].data then
            GComAlter(language.forging84)
            return
        end
        local param = {}
        param.indexs = {}
        table.insert(param.indexs,info.index)
        table.insert(param.indexs,self.iconlist[4].data.index)
        --printt("param.index",param.index)
        proxy.ForgingProxy:send(1100115,param)
    else
        if self.needlv and self.needlv>0 then
            GComAlter(string.format(language.forging85,self.needlv))
            return
        end
        local param = {}
        param.index = info.index
        proxy.ForgingProxy:send(1100114,param)
    end
end

function ZhuStarPanel:onIconCall(context)
    -- body
    local btn = context.sender
    local data = btn.data
    if btn.name == "n50" then
        --选择列表
        local info = cache.PackCache:getEquipDataByPart(self.data.part)
        if not info then
            GComAlter(forging80)
            return
        end
        local condata = conf.ItemConf:getItem(info.mid)
        if not self:checkCon(condata,info) then
            GComAlter(language.forging81)
            return
        end
        local cc = {info = info,data = self.data,selectdata = self.cc,callback = function(param)
            -- body
            if param then
                self:inputdata(param)
            end
        end}
        mgr.ViewMgr:openView2(ViewName.ZhuXinChoosseView,cc)
        return
    end
    if data then
        GSeeLocalItem(data)
    end
end

function ZhuStarPanel:onGuize()
    -- body
    if self.c1.selectedIndex == 0 then
        GOpenRuleView(1067)
    else
        GOpenRuleView(1069)
    end
end

function ZhuStarPanel:addMsgCallBack(data)
    -- body
    self.listView.numItems = #self.confdata
    if not self.index then
        self.index = 0
    end
    if self.index then
        self.listView:AddSelection(self.index,false)
        self:setData(self.confdata[self.index+1])
    end

    if data.msgId == 5100114 then
        -- local info = data.items[1]
        -- self.iconlist[1].data = info
        -- self.iconlist[1].url = mgr.ItemMgr:getItemIconUrlByMid(info.mid)
        -- self.frame[1].url = ResPath.iconRes("beibaokuang_00"..conf.ItemConf:getQuality(info.mid))
    elseif data.msgId == 5100115 then
    --     local info = data.items[1]
    --     self.iconlist[1].data = info
    --     self.iconlist[1].url = mgr.ItemMgr:getItemIconUrlByMid(info.mid)
    --     self.frame[1].url = ResPath.iconRes("beibaokuang_00"..conf.ItemConf:getQuality(info.mid))
    end

    
end


return ZhuStarPanel