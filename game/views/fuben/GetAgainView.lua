--
-- Author: bxp
-- Date: 2018-01-23 15:41:21
--

local GetAgainView = class("GetAgainView", base.BaseView)

function GetAgainView:ctor()
    GetAgainView.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function GetAgainView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onCloseView,self)
    self.title = self.view:GetChild("n4")
    self.times = self.view:GetChild("n13")
    self.costYb = self.view:GetChild("n7")
    self.haveYb = self.view:GetChild("n9")

    self.cancleBtn = self.view:GetChild("n2")
    self.cancleBtn.onClick:Add(self.onCancleBtn,self)

    self.sureBtn = self.view:GetChild("n3")
    self.sureBtn.onClick:Add(self.onSureBtn,self)

    self.btnPlus = self.view:GetChild("n12")
    self.btnPlus.onClick:Add(self.onPlus,self)
    self.btnReduce =self.view:GetChild("n11")
    self.btnReduce.onClick:Add(self.onReduce,self)

end
function GetAgainView:initData(data)
    self.data = data
    if data then
        self.count = data.times or 0
        self.title.text = data.title or ""
        self.times.text = tostring(self.count)
        self.costYb.text= string.format(language.fuben202,data.costYb) or ""
        self.haveYb.text = string.format(language.fuben203,data.haveYb) or ""
        self.allCost = data.costYb
    end
end

function GetAgainView:onPlus()
    if self.count >= self.data.times then
        self.count = self.data.times 
        GComAlter(language.arena16)
    else
        self.count = self.count+1
    end
    self.times.text = tostring(self.count)
    self.allCost = self.count * self.data.oneCost
    self.costYb.text= string.format(language.fuben202,self.allCost)
end

function GetAgainView:onReduce()
    self.count = self.count-1 
    if self.count <= 0 then
        self.count = 0
    end
    self.times.text = tostring(self.count)
    self.allCost = self.count * self.data.oneCost
    self.costYb.text= string.format(language.fuben202,self.allCost)
end

function GetAgainView:onCancleBtn()
    if self.data.cancel then 
        self.data.cancel()
    end
    self:closeView()
end
function GetAgainView:onSureBtn()
    local ybAmount = cache.PackCache:getPackDataById(PackMid.gold).amount
    -- print("拥有",ybAmount,"消耗",self.allCost)

    if self.count == 0 then 
        GComAlter(language.fuben204)
    -- elseif ybAmount < self.allCost then
    --     GComAlter(language.gonggong18)
    --     GGoVipTequan(0)
    else
        -- print("发送消息","sceneId = ",self.data.sceneId,"次数",self.count)
        proxy.FubenProxy:send(1027406,{sceneId = self.data.sceneId,times = self.count})
        if self.data.sceneId and self.data.sceneId == 233001 then 
            proxy.FubenProxy:send(1027301)--刷新单人谧静
        -- elseif self.data.sceneId and self.data.sceneId == 231001 then
        --     proxy.FubenProxy:send(1027201)--刷新仙域灵塔
        -- elseif self.data.sceneId and self.data.sceneId == 234001 then --屏蔽了
        --     proxy.FubenProxy:send(1027309)--刷新组队秘境
        else
            proxy.FubenProxy:send(1027401)--刷新组队仙域
        end
        
    end

end
--再次获取之后返回信息
function GetAgainView:setData(data)
    self.mdata = data 
    if data then 
        self.data.times = self.data.times - data.times
        self.count = self.data.times
        self.times.text = tostring(self.data.times)
        if self.data.times == 0 then 
            self:closeView()
        end
    end
end

function GetAgainView:onCloseView()
    self:closeView()
end

return GetAgainView