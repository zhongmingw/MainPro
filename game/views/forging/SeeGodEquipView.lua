--
-- Author: 
-- Date: 2018-10-23 20:37:52
--

local SeeGodEquipView = class("SeeGodEquipView", base.BaseView)

function SeeGodEquipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true 
end

function SeeGodEquipView:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
    self:setCloseBtn(self.view:GetChild("n5"))

    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0
end

function SeeGodEquipView:initData(data)
    local part = data and data.part or 0
    local _type = data and data._type or 21--神装是21
    self.equipData = {}
    self.strFormat = ""
    if _type == 21 or _type == 6 or _type == 7 then
        local _aa = conf.ForgingConf:getComposeValue("compose_god_color_xin_jie")
        local _bb = conf.ForgingConf:getComposeValue("jie_lv")
        local godEquipData = conf.ItemConf:getGodEquipItems()
        for k,v in pairs(godEquipData) do
            if v.part == part then
                if v.part <= 8 then
                    if v.lvl <= cache.PlayerCache:getRoleLevel() and v.birth_att and v.stage_lvl >= _aa[3] then
                        table.insert(self.equipData,v)
                    end
                else
                    for _,j in pairs(_bb) do
                        if j[2] <= cache.PlayerCache:getRoleLevel() and v.stage_lvl == j[1] and v.birth_att then
                            table.insert(self.equipData,v)
                        end
                    end
                end
            end
        end
        self.strFormat = language.equip01
    elseif _type == 25 then
        local godXianData = conf.ItemConf:getGodXianItems()
        local _aa = conf.ForgingConf:getComposeValue("compose_god_xian")
        for k,v in pairs(godXianData) do
            if v.part == part then
                if v.lvl <= cache.PlayerCache:getRoleLevel() and v.birth_att and v.stage_lvl >= _aa[3] and v.stage_lvl <= cache.PlayerCache:getAttribute(541) then
                    table.insert(self.equipData,v)
                end
            end
        end
        self.strFormat = language.equip01_01
    end

    table.sort( self.equipData , function ( a,b )
        local aData = conf.ItemConf:getItem(a.id)
        local bData = conf.ItemConf:getItem(b.id)
        if aData.lvl ~= bData.lvl then
            return aData.lvl > bData.lvl
        elseif aData.stage_lvl ~= bData.stage_lvl then
            return aData.stage_lvl > bData.stage_lvl
        end
    end )
    self.listView.numItems = #self.equipData 
end

function SeeGodEquipView:cellData(index, obj)
    local data = self.equipData[index+1]
    if data then
        local conData = conf.ItemConf:getItem(data.id)
        obj:GetChild("n1").text = mgr.TextMgr:getQualityStr1(conData.name, conData.color)   
        obj:GetChild("n2").text = string.format(self.strFormat,conData.stage_lvl)
        obj:GetChild("n7").text = string.format(language.pack34,conData.lvl)
        local t = {}
        t.mid = data.id
        t.amount = 1
        t.bind = 1
        t.eStar = 3
        GSetItemData(obj:GetChild("n0"),t,true)
    end
end

function SeeGodEquipView:setData(data_)

end

return SeeGodEquipView