--
-- Author: Your Name
-- Date: 2018-01-11 17:47:30
--

local PwsOverView = class("PwsOverView", base.BaseView)

function PwsOverView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function PwsOverView:initView()
    self:setCloseBtn(self.view)
    self.decIcon = self.view:GetChild("n5")
    self.dec = self.view:GetChild("n6")
    self.effect = self.view:GetChild("n8")
    self.imgIcon = self.view:GetChild("n21"):GetChild("n0")
    self.lvIcon = self.view:GetChild("n21"):GetChild("n1")
    self.lvIcon.visible = false
    self.Challenger = self.view:GetChild("n21"):GetChild("n3")
end

function PwsOverView:initData(data)
    self.data = data

    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil 
    end

    self.num = 0
    self.timer = self:addTimer(1,-1,handler(self, self.onTimer))
    local pwLev = data.pwLev
    local oldPwsLev = data.oldPwLev
    if not pwLev then
        if data.clacInfos then--组队排位结算
            local roleId = cache.PlayerCache:getRoleId()
            for k,v in pairs(data.clacInfos) do
                if roleId == v.roleId then
                    pwLev = v.pwLev
                    oldPwsLev = v.oldPwsLev
                    break
                end
            end
        end
    end
    if pwLev then
        if data.win == 1 then
            self.decIcon.url = UIPackage.GetItemURL("paiwei","kuafupaiweisai_004")
            self.dec.grayed = false
        else
            self.dec.grayed = true
            if pwLev < oldPwsLev then
                self.decIcon.url = UIPackage.GetItemURL("paiwei","kuafupaiweisai_005")
            else
                self.decIcon.url = UIPackage.GetItemURL("paiwei","kuafupaiweisai_109")
            end
        end
        local myPwData = conf.QualifierConf:getPwsDataByLv(pwLev)
        if data.clacInfos then
            myPwData = conf.QualifierConf:getPwTeamDataByLv(pwLev)
        end
        self.imgIcon.url = UIPackage.GetItemURL("paiwei",myPwData.img)
        -- self.lvIcon.url = UIPackage.GetItemURL("paiwei",myPwData.lv_img)
        self.dec.text = myPwData.name .. myPwData.stars .. language.gonggong118
        if not myPwData.max_stars then
            if data.clacInfos then
                self.Challenger.visible = false
            else
                self.Challenger.visible = true
            end
        else
            self.Challenger.visible = false
        end
        
    end
    local effect = self:addEffect(4020112, self.effect)
end

function PwsOverView:onTimer()
    self.num = self.num + 1
    if self.num > 3 then
        if self.timer then
            self:removeTimer(self.timer)
            self.timer = nil 
        end
        self:closeView()
    end
end

return PwsOverView