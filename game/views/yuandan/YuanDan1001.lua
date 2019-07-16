--
-- Author: 
-- Date: 2018-12-18 14:19:30
--元旦登录

local YuanDan1001 = class("YuanDan1001",import("game.base.Ref"))

function YuanDan1001:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function YuanDan1001:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)

    self.timeTxt = panelObj:GetChild("n2")
    self.timeTxt.text = ""
    
    self.decTxt = panelObj:GetChild("n3")
    self.decTxt.text = ""

    self.leftList = panelObj:GetChild("n9")
    self.leftBtn = panelObj:GetChild("n10")
    self.leftBtn.onClick:Add(self.onClickGet,self)

    self.rightList = panelObj:GetChild("n11")
    self.rightBtn = panelObj:GetChild("n12")
    self.rightBtn.onClick:Add(self.onClickGet,self)

    self.quotaTxt = panelObj:GetChild("n17")
    self.hasCharge = panelObj:GetChild("n20")
end
function YuanDan1001:setData(data)
    self.data = data 
    if data.reqType ~=0 then
        GOpenAlert3(data.items)
    end
    --登录
    local loginConf = conf.YuanDanConf:getLoginAward(1,data.curDay)
    if not loginConf then
        return
    end
    self:setListMsg(self.leftList,loginConf.items)
    --累冲
    local chargeConf = conf.YuanDanConf:getLoginAward(2,data.curDay)
    if not chargeConf then
        return
    end
    self:setListMsg(self.rightList,chargeConf.items)
    
    self.quotaTxt.text = chargeConf.quota
    self.decTxt.text = string.format(language.yuandan01,chargeConf.quota)

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
            self.rightBtn.title = language.redbag07
            self.rightBtn:GetChild("red").visible = true
        else
            rightBtnState.selectedIndex = 1--未达成
            self.rightBtn.title = "充 值"
            self.rightBtn:GetChild("red").visible = false
            self.rightBtn:GetChild("icon").grayed = false
        end
    else
        rightBtnState.selectedIndex = 2
        self.rightBtn.title = language.yqs08
    end
    self.leftBtn.data = {state = leftBtnState.selectedIndex,reqType = 1}
    self.rightBtn.data = {state = rightBtnState.selectedIndex,reqType = 2}


end

function YuanDan1001:onTimer()

end

function YuanDan1001:setListMsg(listView,data)
    listView.itemRenderer = function (index,obj)
        self:cellData(index,obj,data)
    end
    listView.numItems = #data
end

function YuanDan1001:cellData(index,obj,data)
    local mData = data[index + 1]
    if mData then
        local itemInfo = {mid = mData[1],amount = mData[2],bind = mData[3]}
        GSetItemData(obj,itemInfo,true)
    end
end



function YuanDan1001:onClickGet(context)
    local data = context.sender.data
    local state = data.state
    local reqType = data.reqType
    if state == 1 then
        if reqType == 2 then
            GGoVipTequan(0)
        else
            GComAlter(language.jianLingBorn05)
        end
        return
    elseif state == 2 then
        GComAlter(language.czccl07)
        return
    end
    proxy.YuanDanProxy:sendMsg(1030677,{reqType = reqType})
end

return YuanDan1001