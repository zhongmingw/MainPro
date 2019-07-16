--
-- Author: Your Name
-- Date: 2017-12-19 14:33:25
--

local ProRecordPanel = class("ProRecordPanel", base.BaseView)

function ProRecordPanel:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.uiClear = UICacheType.cacheTime
    self.isBlack = true
end

function ProRecordPanel:initView()
    --关闭
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onCloseView, self)

    --列表
    self.awardRecordList = self.view:GetChild("n1")
end

function ProRecordPanel:setData(data)
    -- printt(data)
    -- printt(data.preAwardRecords)
    -- print("~~~~~~~~~~~~~~~~~~哈利路亚~~~~~~~~~~~~~~~~~~")

    self.data = data

    self.preAwardRecords = {}
    local size = #self.data.preAwardRecords
    for i=1,size do

        local tempData = self.data.preAwardRecords[i]
        local tempItem = string.split(tempData,",")
        table.insert(self.preAwardRecords, tempItem)
    end

    -- printt(self.preAwardRecords)

    self:setList()
    self.awardRecordList.numItems = #self.preAwardRecords
end

function ProRecordPanel:setList()
    self.awardRecordList.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.awardRecordList:SetVirtual()

    self.awardRecordList.numItems = 0
end

function ProRecordPanel:cellData(index, obj)
    local data = self.preAwardRecords[index+1]

    --期数
    local phase = obj:GetChild("n0")
    phase.text = string.format(language.buyCloud05, data[1])

    --中奖人
    local name = obj:GetChild("n1")
    name.text = data[2]

    --物品
    local itemObj = obj:GetChild("n2")
    local mId = conf.ItemConf:getRealMid(data[3]) or data[3]
    local amount = 1
    local bind = 0
    local eStar = conf.ItemConf:getSuitmodel(mId) and 0 or 3
    local info = {mid = mId, amount = amount, bind = bind, eStar = eStar}   --colorStarNum
    GSetItemData(itemObj, info, true)
end

--关闭
function ProRecordPanel:onCloseView()
    -- body
    self:closeView()
end

return ProRecordPanel