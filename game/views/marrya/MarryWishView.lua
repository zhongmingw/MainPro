--
-- Author: Your Name
-- Date: 2017-11-25 14:21:47
--

local MarryWishView = class("MarryWishView", base.BaseView)

function MarryWishView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.sharePackage = {"marryshare"} 
end

function MarryWishView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(btnClose)
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    self.recordTab = self.view:GetChild("n4")
    self.listView = self.view:GetChild("n15")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.icon1 = self.view:GetChild("n7"):GetChild("n2"):GetChild("n3")
    self.icon2 = self.view:GetChild("n8"):GetChild("n2"):GetChild("n3")
    self.nameTxt1 = self.view:GetChild("n9")
    self.nameTxt2 = self.view:GetChild("n10")

end

function MarryWishView:onController()
    if self.c1.selectedIndex == 0 then
        self.roleId = self.coupleData[1].roleId
    elseif self.c1.selectedIndex == 1 then
        self.roleId = self.coupleData[2].roleId
    end
end

function MarryWishView:celldata( index,obj )
    local data = self.confData[index + 1]
    if data then
        local decTxt = obj:GetChild("n1")
        decTxt.text = data.text
        obj.data = data
        obj.selected = false
        obj.onClick:Add(self.onClickCheck,self)
    end
end

function MarryWishView:onClickCheck(context)
    local checkBtn = context.sender
    local data = checkBtn.data
    if checkBtn.selected then
        self.id = data.id
        self.type = data.type
    end
end

function MarryWishView:setIcon( nameTxt,topicon,data )
    -- body
    local t = GGetMsgByRoleIcon(data.roleIcon,data.roleId,function(tab)
        if tab then
            topicon.url = tab.headUrl
        end
    end)
    topicon.url = t.headUrl
    nameTxt.text = data.roleName
end

function MarryWishView:onClickWish()
    -- print("发送祝福请求",self.type,self.id,self.roleId)
    if self.id ~= 0 then
        local roleId = cache.PlayerCache:getRoleId()
        local flag = true
        for k,v in pairs(self.coupleData) do
            if v.roleId == roleId then
                flag = false
                break
            end
        end
        if flag then
            proxy.MarryProxy:sendMsg(1390304,{reqType = self.type,id = self.id,roleId = self.roleId})
        else
            GComAlter(language.marryiage48)
        end
    else
        GComAlter(language.marryiage57)
    end
end

function MarryWishView:initData(data)
    self.data = data
    -- printt("祝福信息",data)
    self.coupleData = data.ower
    self:setIcon(self.nameTxt1,self.icon1,self.coupleData[1])
    self:setIcon(self.nameTxt2,self.icon2,self.coupleData[2])

    local recordTxt = self.recordTab:GetChild("n0")
    local str = ""
    for k,v in pairs(data.records) do
        str = str .. v .. "\n"
    end
    recordTxt.text = mgr.TextMgr:getTextColorStr(str, 6)

    self.confData = conf.MarryConf:getMarryWishData()
    self.listView.numItems = #self.confData
    self.listView:RefreshVirtualList()
    self.id = 0
    self.roleId = 0
    self.type = 0
    local wishBtn = self.view:GetChild("n17")
    wishBtn.onClick:Add(self.onClickWish,self)
    self:onController()
end

function MarryWishView:onClickEnter()
    proxy.ThingProxy:send(1020101,{sceneId=238001,type=3})
end

return MarryWishView