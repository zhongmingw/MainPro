--
-- Author: Your Name
-- Date: 2018-07-26 14:45:25
--

local DiWangFightTips = class("DiWangFightTips", base.BaseView)

function DiWangFightTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function DiWangFightTips:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    --取消
    self.cancelBtn = self.view:GetChild("n1")
    self:setCloseBtn(self.cancelBtn)
    self.decTxt = self.view:GetChild("n4")
    self.decTxt2 = self.view:GetChild("n7")
end

function DiWangFightTips:initData(data)
    self.leftColdTime = data.leftColdTime
    --确认
    local sureBtn = self.view:GetChild("n2")
    sureBtn.data = data.rank
    sureBtn.onClick:Add(self.onClickSure,self)

    local myRank = data.myRank
    if myRank ~= 0 then
        local xianWeiData = conf.DiWangConf:getXianWeiDataByRank(myRank)
        local textData = clone(language.diwang02)
        textData[2].text = string.format(textData[2].text,xianWeiData.name)
        self.decTxt.text = mgr.TextMgr:getTextByTable(textData)
    else
        self.decTxt.text = language.diwang05
    end
    local cdTime = conf.DiWangConf:getDiWangValue("cold_sec")
    self.decTxt2.text = string.format(language.diwang03,cdTime/60)
end

function DiWangFightTips:onClickSure(context)
    local rank = context.sender.data
    if self.leftColdTime > 0 then
        mgr.ViewMgr:openView2(ViewName.DiWangHuiFuTips, {leftColdTime = self.leftColdTime})
    else
        proxy.DiWangProxy:sendMsg(1550102,{rank = rank})
    end
end

return DiWangFightTips