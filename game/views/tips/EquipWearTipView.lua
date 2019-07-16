--
-- Author: 
-- Date: 2017-03-03 10:48:09
--

local EquipWearTipView = class("EquipWearTipView", base.BaseView)

function EquipWearTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
    self.mData = {}
end

function EquipWearTipView:initView()
    self.time = 0
    self.itemObj = self.view:GetChild("n4")
    self.itemName = self.view:GetChild("n5")
    local btn = self.view:GetChild("n6")
    self.panel = self.view:GetChild("n7")
    self.panel.visible = false
    btn.onClick:Add(self.onClickWear,self)
    local closeBtn = self.view:GetChild("n8")
    closeBtn.onClick:Add(self.onClickClose,self)
end

function EquipWearTipView:setData(items)
    -- printt("EquipWearTipView",items)
    self:setDataItems(items)
    self:judgeData()
end

function EquipWearTipView:setDataItems(items)
    if not self.mData then return end
    for k1,v1 in pairs(items) do
        local mid = v1.mid
        local iType = conf.ItemConf:getType(mid)
        if iType == Pack.equipType and v1.amount > 0 then
            local isWear = false--判断是否可以添加或者替换装备
            local part1 = conf.ItemConf:getPart(mid)
            local score1 = mgr.ItemMgr:getCompreScore(v1)
            local data = cache.PackCache:getEquipDataByPart(part1)--寻找同部位的装备
            if not data then--该部位没有装备的情况
                isWear = true
            end
            if data then
                local score = mgr.ItemMgr:getCompreScore(data)
                if score1 > score then--该部位的装备属性低于新装备的情况
                    isWear = true
                end
            end
            if isWear then
                local isUpdate = false
                local isFind = false
                for k,v2 in pairs(self.mData) do
                    local mid = v2.mid
                    local part2 = conf.ItemConf:getPart(mid)
                    local score2 = mgr.ItemMgr:getCompreScore(v2)
                    if part1 == part2 then
                        isFind = true--找到同部位的
                        if score1 > score2 then--找到战力更高的
                            self.mData[k] = v1
                            isUpdate = true
                        end
                    end
                end

                if not isUpdate and not isFind then--没有改变
                    table.insert(self.mData, v1)
                end
            end
        end
    end
end
--判断数据
function EquipWearTipView:judgeData()
    -- printt("判断裝備数据",self.mData)
    if self.mData and #self.mData > 0 then
        self:setEquipData()
    else
        self:onClickClose()
    end
end
--设置数据
function EquipWearTipView:setEquipData()
    self.panel.visible = true
    local data = self.mData[1]
    local name = conf.ItemConf:getName(data.mid)
    local color = conf.ItemConf:getQuality(data.mid)
    self.itemName.text = mgr.TextMgr:getQualityStr1(name,color)
    GSetItemData(self.itemObj, data)
    -- if not self.equipTimer then
    --     self.time = EquipTipTime
    --     self:onTimer()
    --     self.equipTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    -- end
end
--
function EquipWearTipView:onTimer()
    if self.time <= 0 then--规定时间过后自动穿上装备并且关闭界面
        local view = mgr.ViewMgr:get(ViewName.GuideLayer) --引导期间不给关闭
        if view then
            return
        end
        -- local indexs = {}--背包位置
        -- local toIndexs = {}--目标位置
        -- for k,v in pairs(self.mData) do
        --     table.insert(indexs, v.index)
        --     local toIndex = Pack.equip + conf.ItemConf:getPart(v.mid)
        --     table.insert(toIndexs, toIndex)
        -- end
        -- local params = {
        --     opType = 0,--穿
        --     indexs = indexs,--背包的位置
        --     toIndexs = toIndexs,--目标位置
        -- }
        -- proxy.PackProxy:sendWearEquip(params)
        self:onClickClose()
        return
    end
    self.time = self.time - 1
end

function EquipWearTipView:onClickWear()
    if #self.mData <= 0 then return end
    local mId = self.mData[1].mid
    local index = self.mData[1].index
    local toIndex = Pack.equip + conf.ItemConf:getPart(mId)
    local params = {
        opType = 0,--穿
        indexs = {index},--背包的位置
        toIndexs = {toIndex},--目标位置
    }
    -- printt("indexs",{index})
    -- printt("toIndexs",{toIndex})
    proxy.PackProxy:sendWearEquip(params)
    --self:nextGuide()
end
--穿戴成功返回
function EquipWearTipView:successWear()
    table.remove(self.mData, 1)
    self:judgeData()
end

function EquipWearTipView:onClickClose()
    self.panel.visible = false
    self.time = 0
    self.mData = {}
    if self.equipTimer then
        self:removeTimer(self.equipTimer)
        self.equipTimer = nil
    end
    self:closeView()
end

return EquipWearTipView