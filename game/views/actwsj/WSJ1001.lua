--
-- Author: 
-- Date: 2018-10-22 14:19:21
--

local WSJ1001 = class("WSJ1001",import("game.base.Ref"))


function WSJ1001:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function WSJ1001:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)

    self.timeTxt = panelObj:GetChild("n6")
    self.timeTxt.text = ""
    
    self.decTxt = panelObj:GetChild("n7")
    self.decTxt.text = ""

    self.leftList = panelObj:GetChild("n16")
    self.leftBtn = panelObj:GetChild("n17")
    self.leftBtn.onClick:Add(self.onClickGet,self)

    self.rightList = panelObj:GetChild("n18")
    self.rightBtn = panelObj:GetChild("n19")
    self.rightBtn.onClick:Add(self.onClickGet,self)

    self.quotaTxt = panelObj:GetChild("n21")
    self.hasCharge = panelObj:GetChild("n25")

    self.leftTimeTxt = panelObj:GetChild("n28")


end
--loginSign 登录奖励领取标识 1：已领 0：未领
--rechargeSign充值奖励领取标识 1：已领 0：未领
function WSJ1001:setData(data)
    printt("登录",data)

    self.data = data 
    --登录
    local loginConf = conf.WSJConf:getLoginAward(1,data.curDay)
    if not loginConf then
        return
    end
    self:setListMsg(self.leftList,loginConf.items)
    --累冲
    local chargeConf = conf.WSJConf:getLoginAward(2,data.curDay)
    if not chargeConf then
        return
    end
    self:setListMsg(self.rightList,chargeConf.items)
    self.quotaTxt.text = chargeConf.quota
    self.decTxt.text = string.format(language.wsj01,chargeConf.quota)

    self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)
    self.hasCharge.text = data.rechargeSum

    local leftBtnState = self.leftBtn:GetController("c1")
    local rightBtnState = self.rightBtn:GetController("c1")
    if data.loginSign == 0 then--未领
        leftBtnState.selectedIndex = 0
        self.leftBtn.title = language.friend22
    else--已领取
        leftBtnState.selectedIndex = 2
        self.leftBtn.title = language.yqs08
    end

    if data.rechargeSign == 0 then
        if data.rechargeSum >= tonumber(chargeConf.quota) then
            rightBtnState.selectedIndex = 0--可领取
        else
            rightBtnState.selectedIndex = 1--未达成
        end
        self.rightBtn.title = language.friend22
    else
        rightBtnState.selectedIndex = 2
        self.rightBtn.title = language.yqs08
    end
    self.leftBtn.data = {state = leftBtnState.selectedIndex,reqType = 1}
    self.rightBtn.data = {state = rightBtnState.selectedIndex,reqType = 2}

    local severTime = mgr.NetMgr:getServerTime()
    self.leftTime = data.actEndTime - severTime
    self.leftTimeTxt.text = language.kaifu15 .. GGetTimeData2(self.leftTime)

end

function WSJ1001:onTimer()
    if not self.data then return end
    if self.leftTime then
        self.leftTime = self.leftTime - 1
        self.leftTimeTxt.text = language.kaifu15 .. GGetTimeData2(self.leftTime)
        if self.leftTime <= 0 then
            self.mParent:closeView()
        end
    end
end

function WSJ1001:setListMsg(listView,data)
    listView.itemRenderer = function (index,obj)
        self:cellData(index,obj,data)
    end
    listView.numItems = #data
end

function WSJ1001:cellData(index,obj,data)
    local mData = data[index + 1]
    if mData then
        local itemInfo = {mid = mData[1],amount = mData[2],bind = mData[3]}
        GSetItemData(obj,itemInfo,true)
    end
end



function WSJ1001:onClickGet(context)
    local data = context.sender.data
    local state = data.state
    local reqType = data.reqType
    if state == 1 then
        if reqType == 2 then
            GComAlter(language.wsj14)
        else
            GComAlter(language.jianLingBorn05)
        end
        return
    elseif state == 2 then
        GComAlter(language.czccl07)
        return
    end
    proxy.WSJProxy:send(1030642,{reqType = reqType})
end


return WSJ1001