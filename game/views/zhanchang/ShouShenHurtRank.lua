--
-- Author: 
-- Date: 2018-09-17 17:37:35
--

local ShouShenHurtRank = class("ShouShenHurtRank", base.BaseView)

local delay = 5
function ShouShenHurtRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function ShouShenHurtRank:initView()
    local btn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btn)

    local dec1 = self.view:GetChild("n9")
    dec1.text = language.bangpai208

    local dec1 = self.view:GetChild("n10")
    dec1.text = language.bangpai209

    local dec1 = self.view:GetChild("n11")
    dec1.text = language.bangpai210

    self.listView = self.view:GetChild("n13")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0
end

function ShouShenHurtRank:initData(data)
    -- body
    self.roleId = data
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil 
    end

    self:onTimer()
    self.actTimer = self:addTimer(delay, -1, handler(self, self.onTimer))
end
function ShouShenHurtRank:onTimer()
    -- body
    proxy.FubenProxy:send(1331403,{roleId = self.roleId})
end

function ShouShenHurtRank:cellData(index, obj)
    local data = self.data.rankList[index+1]
    local lab1 = obj:GetChild("n1")
    local lab2 = obj:GetChild("n2")
    local bar = obj:GetChild("n6") 

    lab1.text = data.rank
    lab2.text = data.gangName

    bar.max = 100
    bar.value = data.hurtPercent/100

    bar:GetChild("title").text = string.format("%.1f%%",bar.value)
end

function ShouShenHurtRank:addMsgCallBack(data)
    -- body
    self.data = data 
    self.listView.numItems = #self.data.rankList
end

return ShouShenHurtRank