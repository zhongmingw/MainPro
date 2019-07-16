--
-- Author: 
-- Date: 2018-12-10 14:37:31
--登录

local ShengDan1001 = class("ShengDan1001",import("game.base.Ref"))

function ShengDan1001:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function ShengDan1001:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)

    self.timeTxt = panelObj:GetChild("n4")
    self.timeTxt.text = ""
    
    self.decTxt = panelObj:GetChild("n5")
    self.decTxt.text = ""

    self.leftList = panelObj:GetChild("n14")
    self.leftBtn = panelObj:GetChild("n15")
    self.leftBtn.onClick:Add(self.onClickGet,self)

    self.rightList = panelObj:GetChild("n16")
    self.rightBtn = panelObj:GetChild("n17")
    self.rightBtn.onClick:Add(self.onClickGet,self)

    self.quotaTxt = panelObj:GetChild("n19")
    self.hasCharge = panelObj:GetChild("n22")


end
--loginSign 登录奖励领取标识 1：已领 0：未领
--rechargeSign充值奖励领取标识 1：已领 0：未领
function ShengDan1001:setData(data)
    -- printt("圣诞登录",data)

    self.data = data 
    --登录
    local loginConf = conf.ShengDanConf:getLoginAward(1,data.curDay)
    if not loginConf then
        return
    end
    self:setListMsg(self.leftList,loginConf.items)
    --累冲
    local chargeConf = conf.ShengDanConf:getLoginAward(2,data.curDay)
    if not chargeConf then
        return
    end
    self:setListMsg(self.rightList,chargeConf.items)
    self.quotaTxt.text = chargeConf.quota
    self.decTxt.text = string.format(language.shengdan01,chargeConf.quota)

    self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)
    self.hasCharge.text = data.rechargeSum

    local leftBtnState = self.leftBtn:GetController("c1")
    local rightBtnState = self.rightBtn:GetController("c1")
    if data.loginSign == 0 then--未领
        leftBtnState.selectedIndex = 0
        self.leftBtn.title = language.redbag07
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
        self.rightBtn.title = language.redbag07
    else
        rightBtnState.selectedIndex = 2
        self.rightBtn.title = language.yqs08
    end
    self.leftBtn.data = {state = leftBtnState.selectedIndex,reqType = 1}
    self.rightBtn.data = {state = rightBtnState.selectedIndex,reqType = 2}

    -- local severTime = mgr.NetMgr:getServerTime()
    -- self.leftTime = data.actEndTime - severTime

end

function ShengDan1001:onTimer()

end

function ShengDan1001:setListMsg(listView,data)
    listView.itemRenderer = function (index,obj)
        self:cellData(index,obj,data)
    end
    listView.numItems = #data
end

function ShengDan1001:cellData(index,obj,data)
    local mData = data[index + 1]
    if mData then
        local itemInfo = {mid = mData[1],amount = mData[2],bind = mData[3]}
        GSetItemData(obj,itemInfo,true)
    end
end



function ShengDan1001:onClickGet(context)
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
    proxy.ShengDanProxy:sendMsg(1030670,{reqType = reqType})
end


return ShengDan1001