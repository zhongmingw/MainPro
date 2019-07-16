--
-- Author: Your Name
-- Date: 2017-11-25 14:22:26
--

local MarryRespons = class("MarryRespons", base.BaseView)

function MarryRespons:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.sharePackage = {"marryshare"}
end

function MarryRespons:initView()
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    local closeBtn = self.view:GetChild("n16")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.name = self.view:GetChild("n22")
    self.timeTxt = self.view:GetChild("n27")
    
    local btnSure = self.view:GetChild("n4")
    btnSure.onClick:Add(self.onSure,self)

    local btnRe = self.view:GetChild("n58")
    btnRe.onClick:Add(self.onCancel,self)

    --头像、名字
    self.topicon1 = self.view:GetChild("n1"):GetChild("n2"):GetChild("n3")
    self.topicon2 = self.view:GetChild("n18"):GetChild("n2"):GetChild("n3")
    self.name1 = self.view:GetChild("n36")
    self.name2 = self.view:GetChild("n38")
end

--index=0 嫁给我吧
function MarryRespons:setMarryData()
    self.data = cache.MarryCache:getFirstResponsData()
    -- printt("数据",self.data)
    if not self.data then
        self:closeView()
        return
    end
    --放个特效
    mgr.ViewMgr:openView2(ViewName.Alert15,4020127)

    local condata = conf.MarryConf:getGradeItem(self.data.grade)
    self.name.text = self.data.reqName
    local itemObj = {}
    table.insert(itemObj,self.view:GetChild("n25"))
    table.insert(itemObj,self.view:GetChild("n26"))

    for k ,v in pairs(itemObj) do
        v.visible = false
    end
    if condata.show then
        for k ,v in pairs(condata.show) do
            local cell = itemObj[k]
            if cell then
                local t = {mid=v[1],amount=v[2],bind=v[3]}
                GSetItemData(cell,t,true)
            end
        end
    end
    --默认180秒拒绝一次
    if not self.tiemer then
        self:removeTimer(self.tiemer)
    end
    self.timesNum = 180
    self.timers = self:addTimer(1,-1,handler(self,self.onTiemr))
end
--index=1 缔结姻缘
function MarryRespons:setYinYuanData()
    if self.coupleData then
        local sex = cache.PlayerCache:getSex()
        local myName = cache.PlayerCache:getRoleName()
        local myRoleId = cache.PlayerCache:getRoleId()
        local myIcon = cache.PlayerCache:getRoleIcon()
        if sex == 1 then
            self:setIcon(self.name1,self.topicon1,{roleIcon = myIcon,roleId = myRoleId,roleName = myName})
            self:setIcon(self.name2,self.topicon2,self.coupleData)
        else
            self:setIcon(self.name1,self.topicon1,self.coupleData)
            self:setIcon(self.name2,self.topicon2,{roleIcon = myIcon,roleId = myRoleId,roleName = myName})
        end
        local yuyueBtn = self.view:GetChild("n43")
        yuyueBtn.onClick:Add(self.onClickYuYue,self)
        local refuseBtn = self.view:GetChild("n59")
        refuseBtn.onClick:Add(self.onClickRefuse,self)
        if self.childIndex and self.childIndex == 1 then
            for i=41,45 do
                self.view:GetChild("n"..i).visible = false
            end
            self.view:GetChild("n59").visible = false
        else
            for i=41,45 do
                self.view:GetChild("n"..i).visible = true
            end
            self.view:GetChild("n59").visible = true
        end
    end
end

--index=2 预约成功
function MarryRespons:setAppointmentData()
    --os.date(language.marryiage31,data.time)
    if self.coupleData then
        local sex = cache.PlayerCache:getSex()
        local myName = cache.PlayerCache:getRoleName()
        local myRoleId = cache.PlayerCache:getRoleId()
        local myIcon = cache.PlayerCache:getRoleIcon()
        if sex == 1 then
            self:setIcon(self.name1,self.topicon1,{roleIcon = myIcon,roleId = myRoleId,roleName = myName})
            self:setIcon(self.name2,self.topicon2,self.coupleData)
        else
            self:setIcon(self.name1,self.topicon1,self.coupleData)
            self:setIcon(self.name2,self.topicon2,{roleIcon = myIcon,roleId = myRoleId,roleName = myName})
        end
        local decTxt = self.view:GetChild("n47")
        decTxt.text = string.format(language.marryiage54,self.coupleData.roleName)
        local timeTxt = self.view:GetChild("n48")
        local yuyueData = cache.MarryCache:getAppointmentData()
        local confData = conf.MarryConf:getValue("wedding_banquet_time")
        if yuyueData then
            local T = GGetTimeData(confData[yuyueData[1]][1])
            timeTxt.text = string.format(language.marryiage55,T.hour,T.min)
        else
            timeTxt.text = ""
        end

        local awardItem = self.view:GetChild("n51")
        local awardData = conf.MarryConf:getValue("invite_guests_gift")
        local itemInfo = {mid = awardData[1][1],amount = awardData[1][2],bind = awardData[1][3]}
        GSetItemData(awardItem, itemInfo, true)
        local inviteBtn = self.view:GetChild("n54")
        inviteBtn.onClick:Add(self.onClickInvite,self)
        local closeBtn = self.view:GetChild("n60")
        closeBtn.onClick:Add(self.onClickRefuse,self)
    end
end

function MarryRespons:setIcon( nameTxt,topicon,data )
    -- body
    local t = GGetMsgByRoleIcon(data.roleIcon,data.roleId,function(tab)
        if tab then
            topicon.url = tab.headUrl
        end
    end)
    topicon.url =  t.headUrl --UIPackage.GetItemURL("_icons" , "jiehun_025")
    nameTxt.text = data.roleName
end

function MarryRespons:onTiemr()
    if self.timesNum > 0 then
        self.timeTxt.text = language.marryiage26 .. GTotimeString3(self.timesNum)
        self.timesNum = self.timesNum - 1
    else
        self:onCancel()
    end
end

function MarryRespons:onController()
    if self.c1.selectedIndex == 0 then
        self:setMarryData()
    elseif self.c1.selectedIndex == 1 then
        self:setYinYuanData()
    elseif self.c1.selectedIndex == 2 then
        self:setAppointmentData()
    end
end

function MarryRespons:initData(data)
    self.c1.selectedIndex = data and data.index or 0
    self.childIndex = data.childIndex
    -- print("data",data.childIndex)
    self.coupleData = data and data.coupleData or nil
    self:onController()
end

function MarryRespons:onSure()
    -- body
    local param = {}
    param.reply = 1
    param.reqRoleId = self.data.reqRoleId
    param.grade = self.data.grade
    proxy.MarryProxy:sendMsg(1390103, param)
end

function MarryRespons:onCancel()
    -- body
    local param = {}
    param.reply = 2
    param.reqRoleId = self.data.reqRoleId
    param.grade = self.data.grade
    proxy.MarryProxy:sendMsg(1390103, param)
end

function MarryRespons:onClickYuYue()
    proxy.MarryProxy:sendMsg(1390302,{reqType = 0})
    self:closeView()
end

function MarryRespons:onClickInvite()
    mgr.ViewMgr:openView2(ViewName.MarryInviteView)
    self:closeView()
end

function MarryRespons:onClickRefuse()
    self:closeView()
end

function MarryRespons:onClickClose()
    if self.c1.selectedIndex == 0 then
        self:onCancel()
    elseif self.c1.selectedIndex == 1 then
        self:closeView()
    elseif self.c1.selectedIndex == 2 then
        self:closeView()
    end
end

return MarryRespons