--
-- Author: 
-- Date: 2018-08-01 20:52:04
--狂欢大乐购

local KuangHuanMainView = class("KuangHuanMainView", base.BaseView)

function KuangHuanMainView:ctor()
    KuangHuanMainView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function KuangHuanMainView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    local chargeBtn = self.view:GetChild("n4")
    chargeBtn.onClick:Add(self.onClickCharge,self)
    
    self.chargeTxt = self.view:GetChild("n6")

    self.setpTitle = self.view:GetChild("n7")
    self.nextStep = self.view:GetChild("n8")
    
    self.listView = self.view:GetChild("n9")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    -- self.listView:SetVirtual()

    self.lastTime = self.view:GetChild("n11")

    local dec = self.view:GetChild("n5")
    dec.text = language.khdlg06

    self.titleIcon =  self.view:GetChild("n0"):GetChild("icon")
end


function KuangHuanMainView:setData(data)
    printt("狂欢大乐购",data)
    self.data = data
    self.mulActId = data.mulActId

    --多开活动配置
    local mulConfData = conf.ActivityConf:getMulActById(self.mulActId)
    local titleIconStr = mulConfData.title_icon or "kuanghuandalegou_001"
    self.titleIcon.url = UIPackage.GetItemURL("kuanghuan" , titleIconStr)

    self.chargeTxt.text = data.czSum
   
    self.lockCzConf = conf.ActivityConf:getValue("happy_buy_unlock_cz")

    self.listView.numItems = #self.lockCzConf
    --获得每层的解锁充值元宝
    self.lockCzList = {}
    for k,v in pairs(self.lockCzConf) do
        table.insert(self.lockCzList,v[2])
    end
    table.sort(self.lockCzList)
    local flag = false
    local czCost = 0
    for k,v in pairs(self.lockCzList) do
        if self.data.czSum < v then
            flag = true
            czCost = v
            break
        end
    end
    if flag then
        self.setpTitle.text = language.khdlg01
        self.nextStep.text = czCost -self.data.czSum
    else
        self.setpTitle.text = language.khdlg02
        self.nextStep.text = ""
    end
    self.time = data.actLeftTime
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

end

function KuangHuanMainView:cellData(index,obj)
    local mulActConf = conf.ActivityConf:getMulActById(self.mulActId)
    if mulActConf then
        local data = conf.ActivityConf:getKHDLGByFloor(self.listView.numItems - index,mulActConf.award_pre)
        local awardList = obj:GetChild("n0")
        if data then
            awardList.itemRenderer = function (index, obj)
                self:cellAwardData(index, obj,data)
            end
            awardList.numItems = #data
        end
    end
end

function KuangHuanMainView:cellAwardData(index, obj,data)
    local mData = data[index+1]
    local c1 = obj:GetController("c1")
    if self.data.czSum < mData.unlock_cz then
        c1.selectedIndex = 2--未解锁
    else
        if self.data.buys[mData.id] and self.data.buys[mData.id] >= mData.buy_limit then
            c1.selectedIndex = 1--到上限
        else
            c1.selectedIndex = 0--可购买
        end
    end
    local itemObj = obj:GetChild("n0")
    local awardData = mData.item[1]
    local isquan = mData.isquan
    if not isquan then
        if c1.selectedIndex == 2 or c1.selectedIndex == 1 then
            isquan = 0
        else
            isquan = nil
        end
    end
    local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3],isquan = isquan }
    GSetItemData(itemObj, itemData, false)

    local len = #tostring(mData.id)-3
    local floor = tonumber(string.sub(mData.id,len,len))
    local temp = {}
    temp.awardData = mData
    temp.buyTimes = self.data.buys[mData.id] or 0
    temp.index = c1.selectedIndex
    temp.curFloor = floor
    temp.czSum = self.data.czSum

    obj.data = temp
    obj.onClick:Add(self.onClickObj,self)
end

function KuangHuanMainView:onClickObj(context)
    local data = context.sender.data
    mgr.ViewMgr:openView2(ViewName.KuangHuanBuyView, data)
end

function KuangHuanMainView:onClickCharge()
    GGoVipTequan(0)
    self:closeView()
end

function KuangHuanMainView:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
    end
    self.time = self.time - 1
end

function KuangHuanMainView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end


return KuangHuanMainView