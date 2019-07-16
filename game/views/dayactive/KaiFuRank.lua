--
-- Author: 
-- Date: 2017-03-28 15:49:44
--

local KaiFuRank = class("KaiFuRank", base.BaseView)
local t = {
    [1001]=3,
    [1002]=1,
    [1003]=4,
    [1004]=2,
    [1005]=7,
    [1006]=5,
    [1007]=8,
    [1008]=6,
    [1023]=0,
}

local sortActs = {
    [1023]=0,
    [1001]=1,
    [1002]=2,
    [1003]=3,
    [1004]=4,
    [1005]=5,
    [1006]=6,
    [1007]=7,
    [1008]=8,
}


function KaiFuRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.drawcall = false
    self.uiClear = UICacheType.cacheTime
end

function KaiFuRank:initView()
    self.c1 = self.view:GetController("c1")
    self.c1.selectedIndex = 1
    --排名
    self.listRank = self.view:GetChild("n13")
    self.listRank.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listRank.numItems = 0
    self.listRank.onClickItem:Add(self.onCallBack,self)

    local btn = self.view:GetChild("n14")
    btn.onClick:Add(self.onBtnCallBack,self)

    self.titleicon = self.view:GetChild("n16")
    --排名
    self.listRank1 = self.view:GetChild("n7")
    self.listRank1.itemRenderer = function(index,obj)
        self:cellRankdata(index, obj)
    end
    self.listRank1.numItems = 0

    local btnClose = self.view:GetChild("n2"):GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)
end

function KaiFuRank:onBtnCallBack()
    -- body
    if self.c1.selectedIndex == 1 then
        self.c1.selectedIndex = 0
    else
        self.c1.selectedIndex = 1
    end
end

function KaiFuRank:celldata(index,obj)
    -- body
    local data = self.data.openActHisList[index+1]
    local c1 =  obj:GetController("c1")
    c1.selectedIndex = t[data]
    obj.data = {actid = data, index = index}
end

function KaiFuRank:onCallBack(context)
    -- body
    local index = context.data.data
    self:sendMsg(index)
end

function KaiFuRank:sendMsg(data)
    -- body
    local cell = self.listRank:GetChildAt(data.index)
    --plog("index",index)
    self.index = data.actid --活动ID
    self.titleicon.url = cell:GetChild("n1").url

    if self.index == self.id then
        self:add1030109(self.data)
    else
        proxy.ActivityProxy:sendMsg(1030109, {actId = self.index })
    end
end

function KaiFuRank:setCurId(id)
    -- body
    self.id = id
end

function KaiFuRank:setData(data_)
    self.data = data_
    table.sort(self.data.openActHisList,function(a,b)
        local num1 = sortActs[a]
        local num2 = sortActs[b]
        return num1 < num2
    end)
    self.listRank.numItems = #data_.openActHisList

    if self.listRank.numItems<=1 then
        self.c1.selectedIndex = 2
    else
        if self.c1.selectedIndex == 2 then
            self.c1.selectedIndex = 1
        end
    end
    --默认选中
    for k ,v in pairs(self.data.openActHisList) do
        if v == self.id then
            self.listRank:AddSelection(k-1,false)

            self:sendMsg({actid = v, index = k-1})
            return
        end
    end

    -- local pairs = pairs
    -- for k ,v in pairs(t) do
    --     if v == self.id then
    --         for i , j in pairs(controller) do
    --             if j == k then
    --                 self.listRank:AddSelection(i,false)
    --                 self:sendMsg(i)
    --                 return
    --             end
    --         end
            
    --     end
    -- end
end

function KaiFuRank:cellRankdata(index,obj)
    -- body -ranking roleName-step
    local data = self.showdata.rankInfos[index + 1]
    local c1 = obj:GetController("c1")
    local rank = obj:GetChild("n6")
    local name = obj:GetChild("n11")
    local jie = obj:GetChild("n12")
    local power = obj:GetChild("n13")
    rank.text = index + 1
    if index + 1 <= 3  then
        c1.selectedIndex = index + 1
    else
        c1.selectedIndex = 0
    end
    -- if self.index == 1023 then
    -- else
    --     obj.height = 41
    --     power.visible = false
    -- end
    if data then
        name.text = data.roleName
        jie.text = string.format(language.kaifu07[t[self.index]],data.step)
        power.visible = true
        power.text = string.format(language.kaifu071[t[self.index]],data.power)
        obj.height = 62
    else
        name.text = language.kaifu13
        local str = string.format(language.kaifu07[t[self.index]],100)
        str = string.gsub(str,"100","?")
        jie.text = str
    end
end

function KaiFuRank:onBtnClose()
    -- body
    self:closeView()
end

function KaiFuRank:add1030109( data )
    -- body
    self.showdata = data

    local var = #data.rankInfos
    if var < 20 then
        var = 20
    end
    self.listRank1.numItems = var
end

return KaiFuRank