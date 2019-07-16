--
-- Author: 
-- Date: 2018-10-23 11:52:55
-- 投注选号(双色球)

local BetPanel = class("BetPanel", base.BaseView)

function BetPanel:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale 
end

function BetPanel:initView()
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.redBallList = {}
    self.redBallInfo = {}
    for i =10,42 do
        local redBall = self.view:GetChild("n"..i)
        table.insert(self.redBallList,redBall)
        redBall.data = i- 9
        redBall.onClick:Add(self.redBallClick,self)
    end 

    self.blueBallList = {}
    for i = 45,60 do
        local blueBall = self.view:GetChild("n"..i)
        table.insert(self.blueBallList,blueBall)
        blueBall.data = i - 44
        blueBall.onClick:Add(self.blueBallClick,self)
    end

    self.sureBtn = self.view:GetChild("n1")
    self.sureBtn.onClick:Add(self.btnOnClick,self)
    self.clearBtn = self.view:GetChild("n2")
    self.clearBtn.onClick:Add(self.btnOnClick,self)

end

function BetPanel:initData()
    self:clear()
end

function BetPanel:redBallClick(context)
    local btn = context.sender
    if btn.selected then
        if #self.redNum >= 6 then
            btn.selected = false
            return GComAlter("最多只能选择6个红球")
        end
        table.insert(self.redNum,btn.data)
    else
        for k ,v in pairs(self.redNum) do
            if v == btn.data then
                table.remove(self.redNum,k)
                break
            end
        end
    end
end

function BetPanel:blueBallClick(context)
    local btn = context.sender
    if btn.selected then
        if self.bulebtn then
            self.bulebtn.selected = false
        end
    end

    self.bulebtn = btn
end

function BetPanel:clear()
    for k,v in pairs(self.redBallList) do
        if v.selected then
            v.selected = false
        end
    end
    for k,v in pairs(self.blueBallList) do
        if v.selected then
            v.selected = false
        end
    end
    self.bulebtn = nil
    self.redNum = {}    
end

function BetPanel:btnOnClick(context)
    local btn = context.sender
    if btn.name == "n1" then
        if #self.redNum == 0 or #self.redNum < 6 then
            return GComAlter("请选择6个红球")
        end
        if not self.bulebtn  then
            return GComAlter("请选择1个蓝球")
        end
        
        table.sort(self.redNum,function( a,b)
            -- body
            return a<b
        end)
        

        local param ={}
        param.reqType = 3
        param.redBall = self.redNum
        param.blueBall =  self.bulebtn.data
        param.num = 1

        proxy.ActivityProxy:sendMsg(1030645,param)
        self:closeView()
    elseif btn.name == "n2" then
        self:clear()        
    end
end

return BetPanel