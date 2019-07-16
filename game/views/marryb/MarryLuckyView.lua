--
-- Author: Your Name
-- Date: 2017-11-25 18:04:38
--

local MarryLuckyView = class("MarryLuckyView", base.BaseView)

function MarryLuckyView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.sharePackage = {"marryshare"} 
end

function MarryLuckyView:initView()
    local btnClose = self.view:GetChild("n1")
    self:setCloseBtn(btnClose)
    self.icon1 = self.view:GetChild("n5"):GetChild("n2"):GetChild("n3")
    self.icon2 = self.view:GetChild("n6"):GetChild("n2"):GetChild("n3")
    self.nameTxt1 = self.view:GetChild("n10")
    self.nameTxt2 = self.view:GetChild("n11")
    self.decTxt = self.view:GetChild("n12")
    self.timeTxt = self.view:GetChild("n13")
    self.enterBtn = self.view:GetChild("n18")
    self.enterBtn.onClick:Add(self.onClickEnter,self)
    self.claimBtn = self.view:GetChild("n17")
    self.claimBtn.onClick:Add(self.onClickClaim,self)
    self.tipsTxt = self.view:GetChild("n15")
end

function MarryLuckyView:setIcon( nameTxt,topicon,data )
    -- body
    local t = GGetMsgByRoleIcon(data.roleIcon,data.roleId,function(tab)
        if tab then
            topicon.url = tab.headUrl
        end
    end)
    topicon.url =  t.headUrl --UIPackage.GetItemURL("_icons" , "jiehun_025")
    nameTxt.text = data.roleName
end

-- roleId
-- roleIcon
-- roleName
-- sex

function MarryLuckyView:initData(data)
    if data then
        -- printt("111111111111",data)
        local str = os.date(language.marryiage31,data.time)
        local textData = {
                {text = language.marryiage30,color = 5},
                {text = str,color = 10},
        }
        self.timeTxt.text = mgr.TextMgr:getTextByTable(textData)

        for k,v in pairs(data.users) do
            if v.sex == 1 then
                self:setIcon(self.nameTxt1,self.icon1,v)
            else
                self:setIcon(self.nameTxt2,self.icon2,v)
            end
        end
        local name1 = self.nameTxt1.text
        local name2 = self.nameTxt2.text
        local strData = {
                {text = name1,color = 10},
                {text = language.marryiage29[1],color = 5},
                {text = name2,color = 10},
                {text = language.marryiage29[2],color = 5},
        }
        self.decTxt.text = mgr.TextMgr:getTextByTable(strData)
        self.tipsTxt.text = mgr.TextMgr:getTextByTable(language.marryiage59)
    end
end

function MarryLuckyView:onClickEnter()
    proxy.ThingProxy:send(1020101,{sceneId=238001,type=3})
end

function MarryLuckyView:onClickClaim()
    proxy.MarryProxy:sendMsg(1390306,{reqType = 1})
end

return MarryLuckyView