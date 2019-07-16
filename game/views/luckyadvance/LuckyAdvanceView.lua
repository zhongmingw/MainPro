--幸运进阶日活动 3001-3009
-- Author: Your Name
-- Date: 2017-08-01 14:20:36
--
local LuckyAdvanceView = class("LuckyAdvanceView", base.BaseView)

function LuckyAdvanceView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function LuckyAdvanceView:initView()
    local closeBtn = self.view:GetChild("n1")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.getBtn = self.view:GetChild("n11")
    self.getBtn.onClick:Add(self.onClickGet,self)
    self.listView = self.view:GetChild("n10")
    self.decTxt = self.view:GetChild("n5")
    self.decImg = self.view:GetChild("n4")
    self.decTxt.text = ""
end

function LuckyAdvanceView:initData()
    self.confData = conf.ActivityConf:getActiveByTimetype(5)
    local data = cache.ActivityCache:get5030111()
    self:setData(data)
end

function LuckyAdvanceView:initListView()
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function LuckyAdvanceView:celldata( index,obj )
    local data = self.data[index+1]
    if data then
        local stepTxt = obj:GetChild("n2")
        stepTxt.text = data.step ..language.luckyawards01
        local icon = obj:GetChild("n3")
        local numText = obj:GetChild("n5")
        local getImg = obj:GetChild("n6")
        local redImg = obj:GetChild("n7")
        local mid = data.awards[1][1]
        local num = data.awards[1][2]
        numText.text = num
        local src = conf.ItemConf:getSrc(mid)
        local iconUrl = ResPath.iconRes(tostring(src))
        icon.url = iconUrl
        obj.data = {mid = mid, amount = num, bind = 1}
        obj.onClick:Add(self.onClickItem,self)
        getImg.visible = false
        redImg.visible = false
        icon.grayed = false
        if data.giftStatus == 0 then
        elseif data.giftStatus == 1 then
            redImg.visible = true
        elseif data.giftStatus == 2 then
            icon.grayed = true
            getImg.visible = true
        end
    end
end

function LuckyAdvanceView:onClickItem(context)
    local data = context.sender.data
    GSeeLocalItem(data) 
end

function LuckyAdvanceView:setData(data_)
    self.id = nil
    self.openDay = data_.openDay
    for k,v in pairs(self.confData) do
        if v.activity_pos and v.activity_pos == 3 and  data_ and data_.acts[v.id] == 1 then --这个活动开启了
            self.id = v.id
            break
        end
    end
    if self.id then
        self.data = conf.ActivityConf:getOpenJieAwardByid(self.id)
        self.decTxt.text = string.format(language.luckyawards02,language.luckyawards03[self.id])
        self.decImg.url = UIPackage.GetItemURL("luckyadvance" , language.luckyawards05[self.id])
    end
    if self.data then
        table.sort(self.data,function(a,b)
            if a.id ~= b.id then
                return a.id < b.id
            end
        end)
    end
    proxy.ActivityProxy:sendMsg(1030110,{actId = self.id,reqType = 0})
end

function LuckyAdvanceView:setMsg5030110( data )
    self:initListView()
    self.getflag = false
    for k,v in pairs(self.data) do
        self.data[k].giftStatus = data.gotGiftStatusMap[v.id]
        if data.gotGiftStatusMap[v.id] == 1 then
            self.getflag = true
        end
    end
    self.listView.numItems = #self.data
    if not self.getflag then
        self.getBtn.grayed = true
    else
        self.getBtn.grayed = false
    end
end

--一键领取
function LuckyAdvanceView:onClickGet()
    if self.getflag then
        proxy.ActivityProxy:sendMsg(1030110,{actId = self.id,reqType = 2,awardId = 0})
    else
        GComAlter(language.luckyawards04)
    end
end

function LuckyAdvanceView:onClickClose()
    self:closeView()
end

return LuckyAdvanceView