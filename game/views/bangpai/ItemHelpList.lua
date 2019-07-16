--
-- Author: 
-- Date: 2017-03-10 20:22:02
--

local ItemHelpList = class("ItemHelpList",import("game.base.Ref"))

function ItemHelpList:ctor(param)
    self.view = param
    self:initView()
end

function ItemHelpList:initView()
    -- body
    self.c1 = self.view:GetController("c1")

    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    local btnReflesh = self.view:GetChild("n2")
    btnReflesh.onClick:Add(self.onReflesh,self)

    self:initDec()
end

function ItemHelpList:celldata( index, obj )
    -- body
    local data = self.data.assistList[index+1]
    local confData = conf.BangPaiConf:getBoxItem(data.boxColor)

    local icon =  obj:GetChild("n2")
    icon.url = UIItemRes.bangpai02[data.boxColor]

    local name = obj:GetChild("n3")
    name.text = confData.name

    local lanname = obj:GetChild("n4")
    lanname.text = data.roleName

    local itemobj = obj:GetChild("n6")
    if confData.assist_items then
        itemobj.visible = true
        local t = {mid = confData.assist_items[1][1],amount = confData.assist_items[1][2],bind=confData.assist_items[1][3]}
        GSetItemData(itemobj,t,true)
    else
        itemobj.visible = false
    end

    local btnHelp = obj:GetChild("n7")
    btnHelp.data = data
    btnHelp:GetChild("title").text = language.bangpai103
    btnHelp.onClick:Add(self.onHelp,self)

    --是否被协助过=1被协助过
    if data.assistedStatu == 0 then
        btnHelp.touchable = true
        --btnHelp.visible = true
    else
        btnHelp.touchable = false
        btnHelp:GetChild("title").text = language.bangpai140
        --btnHelp.visible = false
    end
end

function ItemHelpList:setData(data)
    -- body
    self.data = data
    self.listView.numItems = #self.data.assistList
    self.listView.scrollPane:ScrollTop()

    if self.listView.numItems == 0 then
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0 
    end
end

function ItemHelpList:initDec()
    -- body
    self.view:GetChild("n4").text = language.bangpai99
    self.view:GetChild("n5").text = language.bangpai100
    self.view:GetChild("n6").text = language.bangpai101
    self.view:GetChild("n7").text = language.bangpai102
end

function ItemHelpList:onReflesh()
    -- body
    proxy.BangPaiProxy:sendMsg(1250311)
end

function ItemHelpList:onHelp(context)
    -- body
    local var = cache.BangPaiCache:getdayBoxAssistCount()
    local helpvar = conf.BangPaiConf:getValue("day_box_assit_count")
    if var >= helpvar then
        GComAlter(language.bangpai104)
        return
    end

    local data = context.sender.data
    local param = {
        roleId = data.roleId,
        boxIndex = data.boxIndex
    }
    proxy.BangPaiProxy:sendMsg(1250312, param)
end

function ItemHelpList:add5250312( data )
    -- body

    for k ,v in pairs(self.data.assistList) do
        if v.boxIndex == data.boxIndex and v.roleId == data.roleId then
            self.data.assistList[k].assistedStatu = 1
            break
        end
    end
    self.listView:RefreshVirtualList()
end

return ItemHelpList