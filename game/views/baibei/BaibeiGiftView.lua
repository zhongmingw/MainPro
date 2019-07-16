--百倍礼包
local BaibeiGiftView = class("BaibeiGiftView",base.BaseView)

function BaibeiGiftView:ctor()
    -- body
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function BaibeiGiftView:initData(data)
    -- body
    self.isFirstIn = true  

    self.controllerC.selectedIndex =  data.index 
end

function BaibeiGiftView:initView()
    -- body
    local  btnClose = self.view:GetChild("n19"):GetChild("n3")
    btnClose.onClick:Add(self.onClickClose,self)
    self.controllerC = self.view:GetController("c1")
    self.controllerC.onChanged:Add(self.onController,self)
    -- self.costIcon = self.view:GetChild("n12")
    self.listView = self.view:GetChild("n16")
    self:initListView()
    self.timeTxt = self.view:GetChild("n14")
    self.timeTxt.text = ""
    self.lastTime = 10
    self.timeTxt.visible = false
    self.mainTimer = self:addTimer(1.0, -1, handler(self, self.timerClick)) 
end

--请求百倍礼包
function BaibeiGiftView:sendMsg()
    -- body
    proxy.ActivityProxy:sendMsg(1030115,{reqType = 0,privilegeType = 1})
end

function BaibeiGiftView:setData(data)
    -- body
    self.data = data
    if self.isFirstIn then
        for i=1,3 do
            if data.gotStatusMap[i] == 0 then
                self.controllerC.selectedIndex = i-1
                break
            end
        end
        self.isFirstIn = false
    end

    --奖励设置
    local confData = conf.ActivityConf:getBaibeiGiftData(self.controllerC.selectedIndex+1)
    self.listView.numItems = #confData.awards
    --模型图片展示
    local modelId = confData.model_id
    local downImg = self.view:GetChild("n24")
    downImg.visible = false
    local cansee = false
    if modelId then
        if type(modelId) == "number" or type(modelId) == "table" then
            local node = self.view:GetChild("n21")
            if self.effect then
                self:removeUIEffect(self.effect)
                self.effect = nil
            end
            local pos = confData.pos
            local xyz = confData.xyz
            if type(modelId) == "table" then
                -- print("人物模型",modelId[1],modelId[2],modelId[3])
                self.modelObj,cansee = self:addModel(modelId[1],node)
                cansee = self.modelObj:setSkins(nil,modelId[2],modelId[3])
            else
                self.modelObj,cansee = self:addModel(modelId,node)
            end
            self.modelObj:setRotationXYZ(xyz[1],xyz[2],xyz[3])
            self.modelObj:setScale(confData.scale)
            self.modelObj:setPosition(pos[1], pos[2], pos[3])
            self.view:GetChild("n20").visible = false
        elseif type(modelId) == "string" then
            cansee = false
            local imageIcon = self.view:GetChild("n20")
            imageIcon.visible = true
            if self.modelObj then
                self:removeModel(self.modelObj)
                self.modelObj = nil
            end
            imageIcon.url = UIPackage.GetItemURL("baibei" , confData.model_id)
            local node1 = self.view:GetChild("n22")
            self.effect = self:addEffect(4020110,node1)
        end
        downImg.visible = cansee
    end
    --倒计时
    self.lastTime = data.lastTime
    self.timeTxt.text = GtimeTransition(self.lastTime)
    --购买按钮
    local btnBuy = self.view:GetChild("n11")
    btnBuy.onClick:Add(self.onClickBuy,self)

    if data.gotStatusMap[confData.id] == 0 then
        btnBuy.grayed = false
        btnBuy.touchable = true
    else
        btnBuy.grayed = true
        btnBuy.touchable = false
    end
    self.timeTxt.visible = true
end

--倒计时
function BaibeiGiftView:timerClick()
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        self.timeTxt.text = GtimeTransition(self.lastTime)
    else
        self.timeTxt.visible = false
        self:closeView()
    end
end

--奖励列表
function BaibeiGiftView:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function BaibeiGiftView:celldata( index, obj )
    -- body
    local confData = conf.ActivityConf:getBaibeiGiftData(self.controllerC.selectedIndex+1)
    local awardsData = confData.awards[index+1]
    local info = {mid=awardsData[1],amount = awardsData[2],bind=awardsData[3]}
    GSetItemData(obj,info,true)
end

function BaibeiGiftView:onController()
    -- body
    if 0 == self.controllerC.selectedIndex then
        -- self.view:GetChild("n23").visible = false
        -- self.costIcon.url = UIPackage.GetItemURL("baibei","touzijihua_013")
        proxy.ActivityProxy:sendMsg(1030115,{reqType = 0,privilegeType = 1})
    elseif 1 == self.controllerC.selectedIndex then
        -- self.view:GetChild("n23").visible = true
        -- self.costIcon.url = UIPackage.GetItemURL("baibei","touzijihua_014")
        proxy.ActivityProxy:sendMsg(1030115,{reqType = 0,privilegeType = 2})
    elseif 2 == self.controllerC.selectedIndex then
        -- self.view:GetChild("n23").visible = false
        -- self.costIcon.url = UIPackage.GetItemURL("baibei","touzijihua_015")
        proxy.ActivityProxy:sendMsg(1030115,{reqType = 0,privilegeType = 3})
    end
end

--购买
function BaibeiGiftView:onClickBuy( context )
    local buyType = self.controllerC.selectedIndex+1
    if cache.PlayerCache:VipIsActivate(buyType) then
        local curTime = cache.VipChargeCache:getXianzunTyTime()
        if curTime and curTime > 0 then
            if g_ios_test then    --EVE 屏蔽处理，提示字符更改
                GComAlter(language.gonggong76)
            else
                GComAlter(language.vip31)
            end
        else
            proxy.ActivityProxy:sendMsg(1030115,{reqType = 1,privilegeType = buyType})
        end
    else
        if g_ios_test then    --EVE 屏蔽处理，提示字符更改
            GComAlter(language.gonggong76)
        else
            GComAlter(language.vip24..language.vip20[buyType])
        end
    end
end

function BaibeiGiftView:onClickClose()
    -- body
    self.effect = nil
    self.modelObj = nil
    self:closeView()
end

return BaibeiGiftView