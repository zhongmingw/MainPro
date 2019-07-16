--
-- Author: Your Name
-- Date: 2018-09-19 22:43:21
--
local MonsterLingLiTips = class("MonsterLingLiTips", base.BaseView)

function MonsterLingLiTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function MonsterLingLiTips:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0

    self.nameTxt = self.view:GetChild("n2")
end

function MonsterLingLiTips:initData(data)
    if data.type == 1 then
        --已装备的圣印
        self.equippedPartData = {}
        local tab = cache.PackCache:getShengYinEquipData()
        local attrData = {att_340 = 0,att_341 = 0,att_342 = 0,att_343 = 0,att_344 = 0}
        for _ ,attr in pairs(tab) do
            local confdata = conf.ItemArriConf:getItemAtt(attr.mid)
            if not confdata then
                print("前后端配置一样,缺少 mid = "..mid)
            else
                for k,v in pairs(confdata) do
                    if attrData[k] then
                        attrData[k] = attrData[k] + v
                    end
                end
            end
        end
        self.attrData = GConfDataSort(attrData)
        self.nameTxt.text = data.name
        self.listView.numItems = #self.attrData
    else
        self.attrData = data.attrTab
        if self.attrData then
            self.nameTxt.text = data.name
            self.listView.numItems = #self.attrData
        end
    end


end

function MonsterLingLiTips:cellData(index,obj)
    local data = self.attrData[index+1]
    if data then
        local proName = conf.RedPointConf:getProName(data[1])
        local value = data[2]
        obj:GetChild("n0").text = proName
        obj:GetChild("n1").text = value
    end
end

return MonsterLingLiTips