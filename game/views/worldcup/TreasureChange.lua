--
-- Author: 
-- Date: 2018-06-30 14:59:25
--珍品兑换

local TreasureChange = class("TreasureChange",import("game.base.Ref"))
function TreasureChange:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function TreasureChange:initPanel()
    self.view = self.mParent.view:GetChild("n14")

    self.listView = self.view:GetChild("n0")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()

    -- self.leftTimeTxt = self.view:GetChild("n2")

    -- local actDecTxt = self.view:GetChild("n3")
    -- actDecTxt.text = language.worldcup02
  
end

function TreasureChange:cellData(index,obj)
    local data = self.confData[index+1]
    for i=1,3 do
        local item = obj:GetChild("n"..i):GetChild("n1")
        local costTxt = obj:GetChild("n"..i):GetChild("n7")
        local mId = data.cost_item[i][1]
        local needAmont = data.cost_item[i][2]
        local haveAmount = cache.PackCache:getPackDataById(mId).amount
        local color = haveAmount < needAmont and 14 or 10
        local textData = {
                {text = tostring(haveAmount),color = color},
                {text = "/",color = 10},
                {text = tostring(needAmont),color = 10},
            }
        costTxt.text = mgr.TextMgr:getTextByTable(textData)
        local itemData = cache.PackCache:getPackDataById(mId,true,true)
        itemData.hidenumber = true
        itemData.isquan = 0
        GSetItemData(item, itemData, true)
    end
    local awardItem = obj:GetChild("n4")
    local t = {mid = data.awards[1][1],amount = data.awards[1][2],bind = data.awards[1][3]}
    GSetItemData(awardItem, t, true)

    local getBtn = obj:GetChild("n18")
    getBtn.data = data
    getBtn.onClick:Add(self.onClickGet,self)
    --按钮红点
    local flag = true

    for k,v in pairs(data.cost_item) do
        local itemData = cache.PackCache:getPackDataById(v[1],true,true)
        if itemData.amount < v[2] then
            flag = false
            break
        end
    end

    getBtn.data.flag = flag
    if flag then
        getBtn:GetChild("red").visible = true
        getBtn.grayed = false

    else
        getBtn:GetChild("red").visible = false
        getBtn.grayed = true
    end

end

function TreasureChange:onClickGet( context )
    local data = context.sender.data
    local cid = data.id
    if data.flag then --可兑换
        proxy.ActivityProxy:sendMsg(1030502,{reqType = 1,cid = cid})
    else
        GComAlter(language.worldcup03)
        return
    end
end

function TreasureChange:setData(data)
    self.data = data
    self.time = data.lastTime
    self.confData = conf.WorldCupConf:getChangeData()
    self.listView.numItems = #self.confData
end



return TreasureChange