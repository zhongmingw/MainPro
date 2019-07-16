--
-- Author: 
-- Date: 2018-01-03 16:15:54
--

local BeachReward = class("BeachReward", base.BaseView)

function BeachReward:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function BeachReward:initView()
    self.title = self.view:GetChild("n5")
    self.title.text = ""

    self.listView = self.view:GetChild("n7")
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end

    self.btnSure = self.view:GetChild("n8")
    self.btnSure.onClick:Add(self.onSure,self)

    local btnclose = self.view:GetChild("n4"):GetChild("n2")
    self:setCloseBtn(btnclose)
end

function BeachReward:initData(data)
    -- body
    self.data = data 


    self.max = 0
    for k ,v in pairs(self.data.gotAwardList) do
        self.max = math.max(v,self.max)
    end

    self.confRewad = conf.BeachConf:getMlRewardById(self.max+1)
    if not self.confRewad then
        --最大时候
        self.confRewad = conf.BeachConf:getMlRewardById(self.max)
        self.btnSure.visible = false
    else
        if self.confRewad.ml_value <= self.data.curMl then
            self.btnSure.visible = true
        else
            self.btnSure.visible = false
        end
    end
    self.listView.numItems = self.confRewad.awards and #self.confRewad.awards or 0
    self.title.text = string.format(language.beach05,self.confRewad.ml_value)
end

function BeachReward:cellData( index, obj )
    -- body
    local data = self.confRewad.awards[index+1]
    local t ={mid = data[1],amount = data[2],bind = data[3]}  
    GSetItemData(obj,t,true)
end

function BeachReward:setData(data_)

end

function BeachReward:onSure()
    -- body
    if not self.data then
        print("@wx not self.data")
        return
    end

    local param = {}
    param.reqType = 2
    param.cid = self.max + 1
    proxy.BeachProxy:sendMsg(1020424,param)
    self:closeView()
end

return BeachReward