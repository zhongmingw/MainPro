--
-- Author: Your Name
-- Date: 2017-05-11 18:05:59
--
local VipExperienceView = class("VipExperienceView", base.BaseView)

function VipExperienceView:ctor()
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level3
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function VipExperienceView:initView()
    local btnClose = self.view:GetChild("n3")
    btnClose.onClick:Add(self.onClickClose,self)
    self.listView = self.view:GetChild("n4")
    self.btnWear = self.view:GetChild("n7")
    self.btnWear.onClick:Add(self.onClickWear,self)

    self.timeTxt = self.view:GetChild("n9")
    
    self.btnGoAct = self.view:GetChild("n22")
    self.btnGoAct.onClick:Add(self.onClickGoAct,self)
    self.btnGoAct.visible = false
    self:initListView()
    self.listView.numItems = #language.vip28
end

function VipExperienceView:initData()
    local node1 = self.view:GetChild("n14")
    local modelObj1 = nil
    if cache.PlayerCache:getSex() == 1 then
        modelObj1 = self:addModel(3010101,node1)
    else
        modelObj1 = self:addModel(3010201,node1)
    end
    modelObj1:setRotationXYZ(0,160,0)
    modelObj1:setScale(100)
    modelObj1:setPosition(0, -200, 300)
    local node2 = self.view:GetChild("n15")
    local confData = conf.HuobanConf:getSkinsData(1001007)
    local modelObj2 = self:addModel(confData.modle_id,node2)
    modelObj2:setRotationXYZ(0,200,0)
    modelObj2:setScale(100)
    modelObj2:setPosition(0, -200, 300)
    self.view:GetChild("n20").visible = false
    --self.view.scale = 1.0
    if cache.PlayerCache:VipIsActivate(1) then
        self.timeNum = 0
        self.timeTxt.visible = false
        self.btnGoAct.visible = true
        self.btnWear.visible = false
    else
        self.timeNum = 10
        self.timeTxt.visible = true
        self.btnWear.visible = true
        self.timeTxt.text = string.format(language.vip30,self.timeNum)
        if self.timer then
            self:removeTimer(self.timer)
        end

        self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    self:setBtnState()

    self.super.initData()
end

function VipExperienceView:onTimer()
    -- body
    if self.timeNum > 0 then
        self.timeNum = self.timeNum - 1
        -- print("倒计时",self.timeNum)
        self.timeTxt.text = string.format(language.vip30,self.timeNum)
    else
        local huobanId = cache.PlayerCache:getSkins(8)
        -- local chenghaoId = cache.PlayerCache:getSkins(13)
        -- if huobanId ~= 3050106 then
            if not cache.PlayerCache:VipIsActivate(1) then
                proxy.VipChargeProxy:sendXianzunTy(1,1)
                proxy.HuobanProxy:send(1200107,{skinId = 1001007})
                proxy.HuobanProxy:send(1200105,{skinId = 1001007,reqType = 0})
            end
        -- end
        -- if chenghaoId ~= 1002001 then
        --     proxy.PlayerProxy:send(1270102,{titleId = 1002001,reqType = 1})
        -- end
        self.timeTxt.visible = false
        local view = mgr.ViewMgr:get(ViewName.GuideLayer)
        if view then
            view:onCloseView()
        end
        self:onClickClose()
    end
end

--按钮状态设置
function VipExperienceView:setBtnState()
    -- body
    local huobanId = cache.PlayerCache:getSkins(8)
    local chenghao = cache.PlayerCache:getChenghao()
    for k,v in pairs(chenghao) do
        if v == 1002001 then
           self.btnWear.visible = false
        else
            self.btnWear.grayed = false
            self.btnWear.touchable = true
        end    
    end
    -- if chenghaoId == 1002001 then
    --     self.btnWear.visible = false
    -- else
    --     self.btnWear.grayed = false
    --     self.btnWear.touchable = true
    -- end
end

function VipExperienceView:onClickGoAct()
    -- body
    GOpenView({id=1050})
end

function VipExperienceView:setEndImg()
    -- body
    self.view:GetChild("n20").visible = true
    self.btnWear.visible = false
    self.btnGoAct.visible = true
    self.timeTxt.visible = false
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end

end

function VipExperienceView:initListView()
    -- body
    self.listView.numItems = 0    
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
end

function VipExperienceView:cellData(index,obj)
    -- body
    local desc = language.vip28[index+1]
    local descText = obj:GetChild("n0")
    local str=""
    for i=1,#desc do
        local dat=desc[i]
        str=str.."[color="..dat[1].."][size="..dat[2].."]"..dat[3].."[/size][/color]"
    end
    descText.text = "[color=".."#532226".."][size=".."18".."]"..(index+1).."、".."[/size][/color]"..str
end

--使用按钮
function VipExperienceView:onClickWear()
    -- body
    -- local skins = cache.PlayerCache:getSkins(13)
    -- if skins ~= 1002001 then
    --     --佩戴
    --     proxy.PlayerProxy:send(1270102,{titleId = 1002001,reqType = 1})
    -- end
    --出战
    proxy.VipChargeProxy:sendXianzunTy(1,1)
    proxy.HuobanProxy:send(1200107,{skinId = 1001007})
    proxy.HuobanProxy:send(1200105,{skinId = 1001007,reqType = 0})
    self:onClickClose()
end

function VipExperienceView:onClickClose()
    -- body
    --self.view:TweenScale(0,0.5)
    -- if self.isGuide then
    --     self.isGuide = false
    --     GgoToMainTask()
    -- end
    GgoToMainTask()
    self:closeView()
end

return VipExperienceView