--
-- Author: 
-- Date: 2017-03-08 15:14:27
--

local ItemRecord = class("ItemRecord",import("game.base.Ref"))

function ItemRecord:ctor(param)
    self.view = param
    self:initView()
end

function ItemRecord:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onbtnController,self)

    local btn1 = self.view:GetChild("n0")
    btn1:GetChild("title").text = language.bangpai66
    local btn1 = self.view:GetChild("n1")
    btn1:GetChild("title").text = language.bangpai67
    local btn1 = self.view:GetChild("n2")
    btn1:GetChild("title").text = language.bangpai68

    local dec1 = self.view:GetChild("n3")
    dec1.text = language.bangpai66..":"
    self.listView = self.view:GetChild("n5")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0


    local dec2 = self.view:GetChild("n10")
    dec2.text = language.bangpai70
    local dec2 = self.view:GetChild("n11")
    dec2.text = language.bangpai35
    local dec2 = self.view:GetChild("n12")
    dec2.text = language.bangpai71

    self.listView2 = self.view:GetChild("n9")
    self.listView2.itemRenderer = function(index,obj)
        self:celldata2(index, obj)
    end
    self.listView2:SetVirtual()
    self.listView2.numItems = 0
end

function ItemRecord:setSelect(index)
    -- body
    --self.index = index
    self.c1.selectedIndex = index
    self:onbtnController()
end

function ItemRecord:onbtnController()
    -- body
    if self.c1.selectedIndex == 0 then
        proxy.BangPaiProxy:sendMsg(1250106)
    elseif self.c1.selectedIndex == 1 then

    elseif self.c1.selectedIndex == 2 then
        --plog("send 1250108")
        proxy.BangPaiProxy:sendMsg(1250108) 
    end
end

function ItemRecord:celldata( index,obj )
    -- body
    local data = self.data.logs[index+1]
    local lab = obj:GetChild("n1")
    lab.text = string.gsub(data,"#"," ") 

    obj.height = lab.height + 6
end

function ItemRecord:celldata2( index,obj )
    -- body
    local data = self.data.rankings[index+1]
    local lab = obj:GetChild("n7")
    lab.text = data.rank

    local lab = obj:GetChild("n8")
    lab.text = data.roleName

    local lab = obj:GetChild("n9")
    lab.text = data.rankValue

    local c1 = obj:GetController("c1")
    if data.rank <= 3 then
        c1.selectedIndex = data.rank - 1
    else
        c1.selectedIndex = 3
    end
end

function ItemRecord:add5250106(data)
    -- body
    self.data = data
    self.listView.numItems = #data.logs
end

function ItemRecord:add5250108(data)
    -- body
    self.data = data
    self.listView2.numItems = #data.rankings
end

return ItemRecord