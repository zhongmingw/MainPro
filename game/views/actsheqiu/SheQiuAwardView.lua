--
-- Author: yr
-- Date: 2018-07-09 20:23:55
--

local SheQiuAwardView = class("SheQiuAwardView", base.BaseView)

function SheQiuAwardView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function SheQiuAwardView:initView()
    local component = self.view:GetChild("n0")
    self:setCloseBtn(component:GetChild("n0"):GetChild("n2"))
    self.awardList = component:GetChild("n1")
    self.awardList:SetVirtual()
    self.awardList.itemRenderer = function(index,obj)
        self:onItemRenderer(index, obj)
    end
end

function SheQiuAwardView:initData(data)
    self.sumGotData = data.sumGotData
    self.actId = data.actId
    self.shootSumCount = data.shootSumCount
    self.awardData = conf.ActivityConf:getSheQiuAwardList(data.actId)
    self:sort()
    self.awardList.numItems = #self.awardData
end

function SheQiuAwardView:sort()
    for k,v in pairs(self.awardData) do
        if self:isGet(v.id) then
            self.awardData[k].sortindex = 2
        else
            self.awardData[k].sortindex = 1
        end
    end
    table.sort(self.awardData,function(a,b)
        if a.sortindex ~= b.sortindex then
            return a.sortindex < b.sortindex
        else
            return a.id < b.id
        end
    end)
end

function SheQiuAwardView:isGet(id)
    local flag = false
    for k,v in pairs(self.sumGotData) do
        if id == v then
            flag = true
            break
        end
    end
    return flag
end

function SheQiuAwardView:onItemRenderer(index, obj)
    local data = self.awardData[index + 1]
    if data then
        local decTxt = obj:GetChild("n1")
        local textData = {
                            {text = language.active50[1],color = 6},
                            {text = self.shootSumCount,color = 7},
                            {text = string.format(language.active50[2],data.count),color = 6},
                        }
        decTxt.text = mgr.TextMgr:getTextByTable(textData)
        local list = obj:GetChild("n3")
        list.numItems = 0
        for k,v in pairs(data.rewards) do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local Item = list:AddItemFromPool(url)
            local info = {mid = v[1],amount = v[2],bind = v[3]}
            GSetItemData(Item,info,true)
        end
        local getBtn = obj:GetChild("n4")
        local canGet = false
        local c1 = obj:GetController("c1")

        local flag = false
        for k,v in pairs(self.sumGotData) do
            if v == data.id then
                flag = true
                break
            end
        end
        if self.shootSumCount >= data.count and not flag then
            canGet = true
            c1.selectedIndex = 0
        else
            if flag then
                c1.selectedIndex = 2
            else
                c1.selectedIndex = 1
            end
            canGet = false
        end
        getBtn.data = {tarId = data.id,canGet = canGet}
        getBtn.onClick:Add(self.onClickGet,self)
    end
end

function SheQiuAwardView:refreshView( data )
    self.sumGotData = data.sumGotData
    self:sort()
    self.awardList.numItems = #self.awardData
end

function SheQiuAwardView:onClickGet(context)
    local data = context.sender.data
    if data.canGet then
        -- print("活动ID",self.actId)
        proxy.ActivityProxy:sendMsg(1030324,{reqType = 3,cid = data.tarId,actId = self.actId})
    else
        GComAlter(language.active32)
    end
end

return SheQiuAwardView