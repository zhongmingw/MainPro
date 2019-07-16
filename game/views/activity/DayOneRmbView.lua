--每日一元
local DayOneRmbView = class("DayOneRmbView",base.BaseView)

function DayOneRmbView:ctor()
    -- body
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function DayOneRmbView:initData()
    -- body
    local btnClose = self.view:GetChild("n20"):GetChild("n8")
    btnClose.onClick:Add(self.onClickClose,self)
    self.t0 = self.view:GetTransition("t0")
    local node1 = self.view:GetChild("n17")
    local node2 = self.view:GetChild("n24")
    local effect1 = self:addEffect(4020203,node1)
    local effect2 = self:addEffect(4020202,node2)
    effect2.LocalPosition = Vector3(0,-0,200)
    self.t0:Play()
    self.listView = self.view:GetChild("n13")
    self:initListView()
end

function DayOneRmbView:setData( data )
    -- body
    self.data = data
    if data.Items and #data.Items>0 then
        GOpenAlert3(data.Items)
    end
    self.confData = conf.ActivityConf:getDayOneYuanData(1)
    self.awardsData = self.confData.awards
    local getBtn = self.view:GetChild("n12")
    getBtn.data = data.ItemStatus[1]
    getBtn.onClick:Add(self.onClickGet,self)
    if data.ItemStatus[1] == 0 then
        getBtn.touchable = true
        getBtn.grayed = false
        getBtn:GetChild("red").visible = false
        getBtn:GetChild("icon").url = UIPackage.GetItemURL("activity" , "chongdianxiaoqian")
    elseif data.ItemStatus[1] == 1 then
        getBtn.touchable = true
        getBtn.grayed = false
        getBtn:GetChild("red").visible = true
        getBtn:GetChild("icon").url = UIPackage.GetItemURL("activity" , "sanshitiandenglu_034")
    elseif data.ItemStatus[1] == 2 then
        getBtn.touchable = false
        getBtn.grayed = true
        getBtn:GetChild("red").visible = false
        getBtn:GetChild("icon").url = UIPackage.GetItemURL("activity" , "sanshitiandenglu_035")
    end
    self.listView.numItems = #self.awardsData
end

function DayOneRmbView:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function DayOneRmbView:celldata( index,obj )
    -- body
    local data = self.awardsData[index+1]
    local mId = data[1]
    local amount = data[2]
    local bind = data[3]
    -- local info = {mid = mId,amount = amount,bind = conf.ItemConf:getBind(mId) or 0}
    local info = {mid = mId,amount = amount,bind = bind}

    GSetItemData(obj,info,true)
end

function DayOneRmbView:onClickGet(context)
    -- body
    local cell = context.sender
    local status = cell.data
    if status == 0 then
        GOpenView({id = 1042})
    elseif status == 1 then
        proxy.ActivityProxy:sendMsg(1030124,{reqType = 1,awardId = self.confData.id})
    end
end

function DayOneRmbView:onClickClose()
    -- body
    self:closeView()
end

return DayOneRmbView