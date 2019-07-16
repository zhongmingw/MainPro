--
-- Author: 
-- Date: 2017-03-07 10:50:39
--

local BangPaiApplyList = class("BangPaiApplyList", base.BaseView)

function BangPaiApplyList:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function BangPaiApplyList:initView()

    local btnCancel = self.view:GetChild("n2")
    btnCancel.onClick:Add(self.onOneKeyCancel,self)

    local btnSure = self.view:GetChild("n3")
    btnSure.onClick:Add(self.onOneKeySure,self)

    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    local dec1 = self.view:GetChild("n6")
    dec1.text = language.bangpai35

    local dec1 = self.view:GetChild("n7")
    dec1.text = language.bangpai36

    local dec1 = self.view:GetChild("n8")
    dec1.text = language.bangpai37

    local dec1 = self.view:GetChild("n9")
    dec1.text = language.bangpai38

    self.listView = self.view:GetChild("n5")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
end

function BangPaiApplyList:setData(data_)

end

function BangPaiApplyList:celldata(index, obj)
    -- body
    if self.data.page ~= self.data.maxPage and index+1 == self.number then
        proxy.BangPaiProxy:sendMsg(1250105,{page = self.data.page + 1})
    end

    local data = self.data.applyList[index+1]
    local lab1 = obj:GetChild("n1")

    local str = string.split(data.roleName,".")
    if #str == 2 then
        local param = {
            {text = str[1]..".",color = 7},
            {text = str[2]..".",color = 6}
        }
        lab1.text = mgr.TextMgr:getTextByTable(param)
    else
        lab1.text = mgr.TextMgr:getTextColorStr(data.roleName, 6)
    end

    local lab2 =  obj:GetChild("n2")
    lab2.text = data.roleLev

    local lab3 =  obj:GetChild("n3")
    lab3.text = data.power

    local btnSure = obj:GetChild("n5")
    btnSure.data = data.roleId
    btnSure.onClick:Add(self.onItemSure,self)

    local btnCancel = obj:GetChild("n4")
    btnCancel.data = data.roleId
    btnCancel.onClick:Add(self.onItemCancel,self)
end

function BangPaiApplyList:onOneKeyCancel()
    -- body
    if not self.data then
        return 
    end

    local param = {}
    param.reqType = 2
    param.roleIds = {}
    for k ,v in pairs(self.data.applyList) do
        table.insert(param.roleIds,v.roleId)
    end

    if #param.roleIds == 0 then
        GComAlter(language.bangpai34)
        return
    end

    proxy.BangPaiProxy:sendMsg(1250202, param)
end

function BangPaiApplyList:onOneKeySure()
    -- body
    if not self.data then
        return 
    end

    local param = {}
    param.reqType = 1
    param.roleIds = {}
    for k ,v in pairs(self.data.applyList) do
        table.insert(param.roleIds,v.roleId)
    end

    if #param.roleIds == 0 then
        GComAlter(language.bangpai34)
        return
    end

    proxy.BangPaiProxy:sendMsg(1250202, param)
end


function BangPaiApplyList:onItemSure(context)
    -- body
    local roleId = context.sender.data
    local param = {}
    param.reqType = 1
    param.roleIds = {roleId}
    proxy.BangPaiProxy:sendMsg(1250202, param)
end

function BangPaiApplyList:onItemCancel(context)
    -- body
    local roleId = context.sender.data
    local param = {}
    param.reqType = 2
    param.roleIds = {roleId}
    proxy.BangPaiProxy:sendMsg(1250202, param)
end

function BangPaiApplyList:onBtnClose()
    -- body
    if self.request then --如果有同意成员加入 重新请求帮派信息
        proxy.BangPaiProxy:sendMsg(1250104)
    end

    self:closeView()
end

function BangPaiApplyList:add5250105(data)
    -- body
    if not self.data then
        self.data = {}
    end 
    --data.page == 0 self:add5250202 里面可能出现
   --plog("maxPage",data.maxPage)
    if data.page == 1 or data.page == 0 then
        self.data.page = data.page
        self.data.maxPage = data.maxPage
        self.data.applyList = data.applyList
    else
        self.data.page = data.page
        self.data.maxPage = data.maxPage
        for k ,v in pairs(data.applyList) do
            table.insert(self.data.applyList,v)
        end
    end

    self.number = #self.data.applyList
    self.listView.numItems = self.number
    --红点扣除
    if self.number<= 0 then
        mgr.GuiMgr:redpointByID(10313,cache.PlayerCache:getRedPointById(10313))
    end

    if data.page == 1 or data.page == 0 then
        self.listView.scrollPane:ScrollTop()
    end

end

function BangPaiApplyList:add5250202( data )
    -- body
    if data.reqType == 1 and #data.roleIds > 0 then
        self.request = true
    end

    local keys = {}
    for k ,v in pairs(data.roleIds) do
        for i , j in pairs(self.data.applyList) do
            if v == j.roleId then
                table.insert(keys,i)
            end
        end
    end

    table.sort(keys,function(a,b)
        -- body
        return a > b 
    end)

    for k , v in pairs(keys) do
        table.remove(self.data.applyList,v)
    end
    self.number = #self.data.applyList
    if self.number <= 0 then
        proxy.BangPaiProxy:sendMsg(1250105, {page = 1})
    else
        local page 
        if self.number%10 == 0 then
            page = self.number/10
        else
            page = math.ceil(self.number/10)
        end
        self.data.page = page

        --self:add5250105(self.data)
        --self.number = #self.data.applyList
        self.listView.numItems = self.number
        --红点扣除
        if self.number<= 0 then
            mgr.GuiMgr:redpointByID(10313,cache.PlayerCache:getRedPointById(10313))
        end

        if data.page == 1 or data.page == 0 then
            self.listView.scrollPane:ScrollTop()
        end
    end
end

return BangPaiApplyList