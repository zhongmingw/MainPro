--仙尊卡
--Remarks: EVE 添加模型的背景特效
local XianzunView = class("XianzunView",base.BaseView)

function XianzunView:ctor()
    self.super.ctor(self)
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function XianzunView:initView()
    -- body
    local closeBtn = self.view:GetChild("n16"):GetChild("n3")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.timeTxt = self.view:GetChild("n11")
    self.timeTxt.visible = false
    self.view:GetChild("n10").visible = false
    local btnCharge = self.view:GetChild("n15")
    btnCharge.onClick:Add(self.onClickCharge,self)
    self.isFirstIn = true
    self.lastTime = 0
    self.mainTimer = self:addTimer(1.0, -1, handler(self, self.timerClick))
    self.modelList = {}
end

function XianzunView:onClickCharge()
    GGoVipTequan(0)
    self:closeView()
end

function XianzunView:setData( data )
    -- body
    self.isTouch = true
    self.data = data
    self.lastTime = data.lastTime
    self.timeTxt.text = GtimeTransition(self.lastTime)
    if self.lastTime > 0 then
        self.timeTxt.visible = true
        self.view:GetChild("n10").visible = true
    end
    self:initCards()
end

--倒计时
function XianzunView:timerClick()
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        self.timeTxt.text = GtimeTransition(self.lastTime)
    else
        self.timeTxt.visible = false
        self.view:GetChild("n10").visible = false
    end
end

--初始化仙尊卡
function XianzunView:initCards()
    -- body
    for i=1,3 do
        local item = self.view:GetChild("n"..(i+5))
        local btnBuy = item:GetChild("n16")
        btnBuy:GetChild("icon").url = UIPackage.GetItemURL("xianzun" , "xianzunka_00"..(8-i))
        btnBuy.data = i
        btnBuy.onClick:Add(self.onClickBuy,self)
        local bgIcon = item:GetChild("n0")
        bgIcon.url = UIPackage.GetItemURL("xianzun" , "xianzunka_0"..string.format("%02d",(8+i)))
        local actImg = self.view:GetChild("n2"..(2+i))
        if self.data.activeStatus[i] == 0 then
            actImg.url = UIPackage.GetItemURL("xianzun" , "xianzunka_013")
            -- btnBuy.grayed = false
            btnBuy:GetChild("n3").visible = true
            actImg.visible = false
            btnBuy.visible = true
        else
            -- btnBuy.grayed = true
            btnBuy:GetChild("n3").visible = false
            actImg.url = UIPackage.GetItemURL("xianzun" , "xianzunka_012")
            actImg.visible = true
            btnBuy.visible = false
        end
        local spritImg = item:GetChild("n10")
        local discount = item:GetChild("n15")
        local quota = item:GetChild("n8")
        local actquota = item:GetChild("n9")
        local ybImg = item:GetChild("n7")
        local ybImg2 = item:GetChild("n18")
        local affectData = conf.VipChargeConf:getAffectDataById(i)
        spritImg.x = ybImg.x
        if self.lastTime > 0 then
            spritImg.visible = true
            quota.visible = true
            quota.text = affectData.quota
            actquota.text = affectData.act_quota
            spritImg.width = ybImg.width+quota.width-10
        else
            spritImg.visible = false
            discount.visible = false
            quota.visible = false
            ybImg.visible = false
            actquota.text = affectData.quota
            if self.isFirstIn then
                actquota.x = actquota.x - 38
                ybImg2.x = ybImg2.x - 38
                if i == 3 then
                    self.isFirstIn = false
                end
            end
        end
        if not btnBuy.visible then
            discount.visible = false
            spritImg.visible = false
            quota.visible = false
            actquota.visible = false
            ybImg.visible = false
            ybImg2.visible = false
        end
        --特权列表
        local listView = item:GetChild("n11")
        listView.numItems = 0
        local affect = affectData.vip_affect
        local num = 1
        for num=1,4 do
            if affect[num] then
                local url = UIPackage.GetItemURL("xianzun" , "ItemIcon")
                local obj = listView:AddItemFromPool(url)
                local affectImg = conf.VipChargeConf:getAffectImgById(affect[num])
                local iconUrl = UIPackage.GetItemURL("xianzun", affectImg)
                obj:GetChild("icon").url = iconUrl
                if num == 4 then
                    obj:GetChild("icon").url = UIPackage.GetItemURL("xianzun" , "chongzhivip_111")
                end
                obj.data = affect
                obj.onClick:Add(self.onClickAffect,self)
            end
        end
        --模型设置
        local iconImg = self.view:GetChild("n1"..(6+i))
        local model = self.view:GetChild("n2"..(i-1))
        local modelId = affectData.model_id
        local downImg = self.view:GetChild("n3"..i)
        -- model.onClick:Clear()
        local btnItem = self.view:GetChild("n3"..(i+3))

        local efcPos = self.view:GetChild("n3"..(i+6))
        self:addEffect(4020137,efcPos) --EVE 添加模型背景特效

        if i > 1 then
            local sex = cache.PlayerCache:getSex()
            local data = {mid = 221071027, amount = 1, bind = 1}--武器

            if sex == 1 then
                if i == 3 then--时装
                    data = {mid = 221071029, amount = 1, bind = 1}
                end
            else
                if i == 3 then--时装
                    data = {mid = 221071030, amount = 1, bind = 1}
                else--武器
                    data = {mid = 221071028, amount = 1, bind = 1}
                end
            end

            btnItem.data = data
            btnItem.onClick:Add(self.onClickCheck,self)
        end
        downImg.visible = false
        local cansee = false
        if modelId then
            if type(modelId) == "number" or type(modelId) == "table" then
                local pos = affectData.pos
                local xyz = affectData.xyz
                local modelObj = nil
                if type(modelId) == "table" then
                    local sex = cache.PlayerCache:getSex()
                    if sex == 1 then
                        modelObj,cansee = self:addModel(modelId[1][1],model)
                        cansee = modelObj:setSkins(nil,modelId[1][2])
                    else
                        modelObj,cansee = self:addModel(modelId[2][1],model)
                        cansee = modelObj:setSkins(nil,modelId[2][2])
                    end
                else
                    modelObj,cansee = self:addModel(modelId,model)
                end
                self.modelList[i] = modelObj
                modelObj:setRotationXYZ(xyz[1],xyz[2],xyz[3])
                modelObj:setScale(affectData.scale)
                modelObj:setPosition(pos[1], pos[2], pos[3])
                iconImg.visible = false
            elseif type(modelId) == "string" then
                iconImg.visible = true
                if self.modelList[i] then
                    self:removeModel(self.modelList[i])
                    self.modelList[i] = nil
                end
                iconImg.url = UIPackage.GetItemURL("xianzun" , modelId)
            end
            downImg.visible = cansee
        end
    end
end

function XianzunView:onClickCheck(context)
    local data = context.sender.data
    GSeeLocalItem(data)
end

function XianzunView:onClickAffect(context)
    -- body
    local cell = context.sender
    local data = cell.data

    mgr.ViewMgr:openView(ViewName.PrivilegePanel,function(view)

    end,data)
end

--购买仙尊卡
function XianzunView:onClickBuy( context )
    -- body
    local cell = context.sender
    local vipType = cell.data
    if self.data.activeStatus[vipType] == 0 then
        local affectData = conf.VipChargeConf:getAffectDataById(vipType)
        local ybNum = affectData.quota
        if self.lastTime > 0 then
            ybNum = affectData.act_quota
        end
        local t = {
                {color = 8,text=language.invest10},
                {color = 7,text=string.format("%d",ybNum)},
                {color = 8,text=language.vip27},
                {color = 8,text=language.vip26..language.vip20[vipType]}
            }
        local param = {}
        param.type = 2
        param.richtext = mgr.TextMgr:getTextByTable(t)
        param.sure = function()
            proxy.VipChargeProxy:sendVipPrivilege(1,vipType)
        end
        param.cancel = function ()
            -- body
        end
        GComAlter(param)
    else
        GComAlter(language.vip23)
    end
end

function XianzunView:onClickClose()
    -- body
    self.modelList = {}
    self:closeView()
end

return XianzunView