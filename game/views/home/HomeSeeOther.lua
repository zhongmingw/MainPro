--
-- Author: 
-- Date: 2017-11-20 19:41:03
--

local HomeSeeOther = class("HomeSeeOther", base.BaseView)

function HomeSeeOther:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.openTween = ViewOpenTween.scale 
end

function HomeSeeOther:initData()
    -- body
    self.c1.selectedIndex = 0
    self:onController1()

    self.homedata  = cache.HomeCache:getData()
end

function HomeSeeOther:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    local btn1 = self.view:GetChild("n15")
    btn1.title = language.home24
    --btn1.onClick:Add(self.onNear,self)

    local btn2 = self.view:GetChild("n16")
    btn2.title = language.home25
    --btn2.onClick:Add(self.onFriend,self)

    self.input = self.view:GetChild("n17")
    self.input.text = ""

    local btnSearch = self.view:GetChild("n2")
    btnSearch.title = language.home26
    btnSearch.onClick:Add(self.onSearch,self)

    local btnReSet = self.view:GetChild("n1") 
    btnReSet.onClick:Add(self.onReset,self)

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    local dec1 = self.view:GetChild("n7") 
    dec1.text = language.home27
    local dec1 = self.view:GetChild("n8") 
    dec1.text = language.home28
    local dec1 = self.view:GetChild("n9") 
    dec1.text = language.home29
    local dec1 = self.view:GetChild("n10") 
    dec1.text = language.home30
    self.listView = self.view:GetChild("n5")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
end
function HomeSeeOther:celldata(index, obj)
    -- body
    local data = self.data.visitList[index+1]
    if index+1 >= self.listView.numItems then
        if self.data.page < self.data.pageSum then
            self.param.page = self.data.page + 1
            self:onReset()
        end
    end

    local labname = obj:GetChild("n1")
    labname.text = data.roleName

    local lablevel = obj:GetChild("n2")
    lablevel.text = data.roleLev

    local labpower = obj:GetChild("n3")
    labpower.text = data.power

    local btncaozuo = obj:GetChild("n5")
    btncaozuo.title = language.home31
    btncaozuo.data = data
    btncaozuo.onClick:Add(self.onCaozuo,self)
end

function HomeSeeOther:onCaozuo(context)
    -- body
    local data = context.sender.data
    if self.homedata.roleId == data.roleId then
        GComAlter(language.home123)
        return
    end

    proxy.HomeProxy:sendMsg(1460108,{roleId = data.roleId})
    self:closeView()
end

function HomeSeeOther:setData(data_)

end
function HomeSeeOther:onController1()
    -- body
    if self.c1.selectedIndex == 0 then
        self:onNear()
    else
        self:onFriend()
    end
end
function HomeSeeOther:onNear()
    -- body
    --附近
    local param = {}
    param.reqType = 1
    param.name = self.input.text
    param.page = 1
    self.param = param
    proxy.HomeProxy:sendMsg(1460101,param)
end

function HomeSeeOther:onFriend()
    -- body
    --好友
    local param = {}
    param.reqType = 3
    param.name = self.input.text
    param.page = 1
    self.param = param
    proxy.HomeProxy:sendMsg(1460101,param)
end

function HomeSeeOther:onSearch()
    -- body
    --搜索
    local param = {}
    param.reqType = 1
    param.name = self.input.text
    param.page = 1
    self.param = param
    proxy.HomeProxy:sendMsg(1460101,param)
end

function HomeSeeOther:onReset()
    -- body
    if not self.param then
        if self.c1.selectedIndex == 0 then
            self:onNear()
        else
            self:onFriend()
        end
        return
    end
    proxy.HomeProxy:sendMsg(1460101,self.param) 
end

function HomeSeeOther:add5460101(data)
    -- body
    if data.page == 1 then
        self.data = {}
        self.data.reqType = data.reqType
        self.data.name = data.name
        self.data.page = data.page
        self.data.pageSum = data.pageSum
        self.data.visitList = data.visitList
    else
        self.data.reqType = data.reqType
        self.data.name = data.name
        self.data.page = data.page
        self.data.pageSum = data.pageSum
        for k , v in pairs(data.visitList) do
            table.insert(self.data.visitList,v)
        end
    end
   -- print(self.data.page,self.data.pageSum)
    self.listView.numItems = #self.data.visitList
    if data.page == 1 then
        self.listView.scrollPane:ScrollTop()
    end
end

return HomeSeeOther