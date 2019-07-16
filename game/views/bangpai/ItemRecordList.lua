--
-- Author: 
-- Date: 2017-03-10 21:03:47
--

local ItemRecordList = class("ItemRecordList",import("game.base.Ref"))

function ItemRecordList:ctor(param)
    self.view = param
    self:initView()
end

function ItemRecordList:initView()
    -- body
    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    self.radiobtn = self.view:GetChild("n10")
    self.radiobtn.onClick:Add(self.onBtnRadio,self)

    self:initDec()
end

function ItemRecordList:initDec()
    -- body
    self.view:GetChild("n4").text = language.bangpai99
    self.view:GetChild("n5").text = language.bangpai100
    self.view:GetChild("n6").text = language.bangpai101
    self.view:GetChild("n7").text = language.bangpai102
    self.view:GetChild("n9").text = language.bangpai105
    self.view:GetChild("n11").text = language.bangpai106
end

function ItemRecordList:celldata(index,obj)
    -- body
    -- roleid ,rolename,boxind,helpname
    local data = self.showdata[index+1] --sting.split(self.showdata[index+1],"#") 

    local confData = conf.BangPaiConf:getBoxItem(data.id)

    local icon =  obj:GetChild("n2")
    icon.url = UIItemRes.bangpai02[data.id]

    local name = obj:GetChild("n3")
    name.text = confData.name

    local lanname = obj:GetChild("n4")
    lanname.text = data.roleName

    local itemobj = obj:GetChild("n6")
    if confData.assist_items then
        itemobj.visible = true
        local t = {mid = confData.assist_items[1][1],amount = confData.assist_items[1][2],bind = confData.assist_items[1][3]}
        GSetItemData(itemobj,t,true)
    else
        itemobj.visible = false
    end

    local lanb = obj:GetChild("n8")
    lanb.text = data.helpName

    local c1 = obj:GetController("c1")
    if data.roleId == tostring(cache.PlayerCache:getRoleId()) then
        c1.selectedIndex = 1
    else
        c1.selectedIndex = 0
    end
end

function ItemRecordList:setData(data)
    -- body
    self.data = {}
    self.selfdata = {}
    for k,v in pairs(data.assitLogs) do
        local str = string.split(v,"#")
        local t = {}
        --plog(v)
        t.helproleId = str[1]
        t.roleName = str[2]
        t.id = tonumber(str[3])
        t.helpName = str[4]
        t.roleId = str[5]
        table.insert(self.data,t)

        if t.helproleId == tostring(cache.PlayerCache:getRoleId()) then --协助者是自己
            table.insert(self.selfdata,t)
        elseif t.roleId == tostring(cache.PlayerCache:getRoleId()) then--宝箱是自己
            table.insert(self.selfdata,t)
        end
    end


    self:onBtnRadio()
end


function ItemRecordList:onBtnRadio()
    -- body
    self.showdata = {}
    if self.radiobtn.selected then
        self.showdata = self.selfdata
    else
        self.showdata = self.data
    end
    self.listView.numItems = #self.showdata
    --plog(self.listView.numItems,"self.listView.numItems")
end

return ItemRecordList