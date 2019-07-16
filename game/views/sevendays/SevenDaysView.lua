--
-- Author: Your Name
-- Date: 2017-09-16 11:11:41
--

local SevenDaysView = class("SevenDaysView", base.BaseView)

function SevenDaysView:ctor()
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale 
end

function SevenDaysView:initView()
    local closeBtn = self.view:GetChild("n14")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.getBtn = self.view:GetChild("n18")
    self.getBtn.onClick:Add(self.onClickGet,self)
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
end

function SevenDaysView:onController()
    self.select = self.c1.selectedIndex + 1
    -- print("当前选择",self.select,self.data.curDay)
    if self:isInArray(self.select) then
        self.getBtn:GetChild("icon").url = UIPackage.GetItemURL("sevendays" , "qitiandenglu_026")
    else
        self.getBtn:GetChild("icon").url = UIPackage.GetItemURL("sevendays" , "qitiandenglu_023")
    end
    if self.select > self.data.curDay or self:isInArray(self.select) then
        self.getBtn.grayed = true
    else
        self.getBtn.grayed = false
    end
    self:refreshRed()
end

function SevenDaysView:initData()
    self.confData=conf.ActivityConf:getLoginAward()
    for i=1,#self.confData do
        local item = self.view:GetChild("btn"..i)
        if i ~= 3 and i ~= 7 then
            local award = self.confData[i].awards[1]
            local awardItem = item:GetChild("n5")
            local dec = item:GetChild("n8")
            dec.text = self.confData[i].award_dec or ""
            local info = {mid = award[1],amount = award[2],bind = award[3]}
            GSetItemData(awardItem,info,true)
        else
            local model = item:GetChild("n5")
            local sex = cache.PlayerCache:getSex()
            local award = self.confData[i].awards[1]
            if sex == 2 then
                award = self.confData[i].awards[2]
            end
            local mId = award[1]
            local skinId = conf.ItemConf:getItemExt(mId)
            local confData = conf.RoleConf:getFashData(skinId)
            local info = {mid = award[1],amount = award[2],bind = award[3]}
            item.data = info
            item.onClick:Add(self.onClickTips,self)
            if confData.model then
                local obj = self:addModel(confData.model,model)
                if i == 7 then--时装
                    local wuqiMid = self.confData[3].awards[sex][1]
                    local wuqiSkinId = conf.ItemConf:getItemExt(wuqiMid)
                    local wuqiConfData = conf.RoleConf:getFashData(wuqiSkinId)
                    obj:setSkins(nil,wuqiConfData.model)
                    obj:setPosition(0,-260,500)
                    obj:setRotation(160)
                else--武器
                    obj:setPosition(50,-70,500)
                    obj:setRotationXYZ(30,90,90)
                end
                obj:setScale(150)
            end
        end
    end
    self.select = 1
    self.super.initData()
end

function SevenDaysView:onClickTips( context )
    local data = context.sender.data
    GSeeLocalItem(data)
end

function SevenDaysView:setData(data)
    self.data = data
    self.select = data.curDay > 7 and 7 or data.curDay
    for k,v in pairs(self.confData) do
        if not self:isInArray(k) then
            self.select = k
            break
        end
    end
    for i=1,#self.confData do
        local item = self.view:GetChild("btn"..i)
        if self:isInArray(i) then
            item:GetChild("n7").visible = true
            item.grayed = true
        else
            item:GetChild("n7").visible = false
            item.grayed = false
        end
    end
    self.c1.selectedIndex = self.select - 1
    self:onController()
end

function SevenDaysView:refreshRed()
    --领取按钮红点
    local redPoint = self.getBtn:GetChild("n3")
    if not self:isInArray(self.select) and self.select <= self.data.curDay then
        redPoint.visible = true
    else
        redPoint.visible = false
    end
end

function SevenDaysView:onClickGet()
    -- print("领取",self.select)
    if self:isInArray(self.select) then
        GComAlter(language.xiuxian03)
    elseif self.select > self.data.curDay then
        GComAlter(language.loginaward03)
    else
        proxy.ActivityProxy:sendMsg(1030147,{reqType = 1,awardId = self.select})
    end
end

function SevenDaysView:isInArray(val)
    for _, v in ipairs(self.data.gotAwardIdList) do  
        if v == val then  
            return true  
        end  
    end  
    return false  
end

function SevenDaysView:onClickClose()
    self:closeView()
end

return SevenDaysView