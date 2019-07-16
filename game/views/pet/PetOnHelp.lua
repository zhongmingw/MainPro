--
-- Author: 
-- Date: 2018-07-23 17:08:09
--

local PetOnHelp = class("PetOnHelp", base.BaseView)

function PetOnHelp:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function PetOnHelp:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    local btnOnBatton = self.view:GetChild("n16")
    btnOnBatton.data = 1
    btnOnBatton.onClick:Add(self.onBatton,self)

    local btnOnBatton = self.view:GetChild("n17")
    btnOnBatton.data = 2
    btnOnBatton.onClick:Add(self.onBatton,self)

    self.friendlist = self.view:GetChild("n12")
    self.friendlist.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.friendlist.numItems = 0
    self.friendlist.onClickItem:Add(self.onCallBack,self)  

    self.petlist = self.view:GetChild("n14")
    self.petlist:SetVirtual()
    self.petlist.itemRenderer = function(index,obj)
        self:cellPetdata(index, obj)
    end
    self.petlist.numItems = 0
    self.petlist.onClickItem:Add(self.onPetCallBack,self)  

    self.dec1 = self.view:GetChild("n13") 
    self.dec1.text = ""

    self.view:GetChild("n8").text = language.pet66
    self.view:GetChild("n11").text = language.pet67
end

function PetOnHelp:initData(data)
    -- body
    local petdata = cache.PetCache:getData()
    self.petdata = {}
    for k ,v in pairs(petdata) do
        self.petdata[v.petRoleId] = v
    end
    self.data = data 
    self.pos = data.pos
    self:setData()

    self:setposinfo()
    
end

function PetOnHelp:setData(data_)
    self.friendlist.numItems = 8
    self.friendlist:AddSelection(self.pos%1000-1,false)
end

function PetOnHelp:onPetCallBack( context )
    -- body
    self.select = context.data.data
end

function PetOnHelp:cellPetdata( index, obj )
    -- body
    local data = self.listdata[index+1]
    obj.data = data
    local c1 = obj:GetController("c1")
    if not data then
        c1.selectedIndex = 1
        return
    end
    c1.selectedIndex = 0
    local condata = conf.PetConf:getPetItem(data.petId)
    local t = {}
    t.color = condata.color
    t.url = ResPath.iconRes(condata.src)
    t.isCase = true
    GSetItemData(obj:GetChild("n5"), t)
    local nameTxt = obj:GetChild("n1")
    nameTxt.text = mgr.TextMgr:getQualityStr1(condata.name, condata.color)

    local score = obj:GetChild("n4")
    score.text = mgr.PetMgr:getPetScore(data)
end

function PetOnHelp:celldata( index, obj )
    -- body
    local key = 1000 + index+1
    local data = self.data.warPetData[key]
    local icon = obj:GetChild("n5"):GetChild("n1") 
    icon.url = nil 

    local c1 = obj:GetController("c1")
    if data then
        c1.selectedIndex = 0
        if self.petdata[data] then
            local condata = conf.PetConf:getPetItem(self.petdata[data].petId)
            icon.url = ResPath.iconRes(condata.src)
        end
    else
        c1.selectedIndex = 1
    end

    obj.selected = false
    obj.data = key
end

function PetOnHelp:onCallBack( context )
    -- body
    self.pos = context.data.data
    self:setposinfo()
    if not self.data.warPetData[self.pos] then
        local t = {}
        t.pos = self.pos%1000
        t.opencount = self.data.warPetData
        local condata = conf.PetConf:getPetPosCondi(self.pos)
        if condata.open_lev then
            if condata.open_lev > cache.PlayerCache:getRoleLevel() then
                return GComAlter(string.format(language.gonggong07,condata.open_lev) )
            end
            return
        end
        mgr.ViewMgr:openView2(ViewName.PetOpenPos,t)
    end
end

function PetOnHelp:onBatton(context)
    -- body
    if not self.data then
        return
    end
    if not self.pos  then
        return
    end
    if not self.data.warPetData[self.pos] then
        return GComAlter(language.pet62)
    end
    
    local param = {}
    param.reqType = context.sender.data
    param.pos = self.pos 
    
    local reqType = context.sender.data
    if reqType == 2 then
        --召唤
        if self.data.warPetData[self.pos] == 0 then
            return GComAlter(language.pet54)
        end
        param.petId = self.data.warPetData[self.pos]
        proxy.PetProxy:sendMsg(1490201,param)
        return
    end
    if not self.select then
        return GComAlter(language.pet54)
    end
    --上阵
    param.petId = self.select.petRoleId 
    local condata = conf.PetConf:getPetItem(self.select.petId)
    local info = conf.PetConf:getPetPosCondi(self.pos)
    if info.need_color then
        if condata.color < info.need_color then
            GComAlter(string.format(language.pet60,language.gonggong110[info.need_color]))
            return
        end
    end
    if info.need_lev then
        if self.select.level < info.need_lev then
            GComAlter(string.format(language.pet61,info.need_lev))
            return
        end
    end
    proxy.PetProxy:sendMsg(1490201,param)
end

function PetOnHelp:setposinfo()
    -- body
    local info = conf.PetConf:getPetPosCondi(self.pos)
    --print("self.pos",self.pos,self.pos+1000,info)
    local str = language.pet56
    if info.need_color and info.need_color > 0 then
        str = str .. language.gonggong110[info.need_color] .. language.pet57
        if info.need_lev then
            str = str.. language.pet59 .. string.format(language.pet58,info.need_lev)
        end
    elseif info.need_lev then
        str = str .. string.format(language.pet58,info.need_lev)
    else
        str = ""
    end
    self.dec1.text = str


    local t = {}
    for k , v in pairs(self.data.warPetData) do
        if v~= 0 then
            t[v] = 1
        end
    end
    --筛选
    self.listdata = {}
    for k ,v in pairs(self.petdata) do
        if v.petRoleId ~= cache.PetCache:getCurpetRoleId() and not t[v.petRoleId] then
            if info.need_color then
                local condata = conf.PetConf:getPetItem(v.petId)
                if condata.color >= info.need_color then
                    if info.need_lev then
                        if v.level >= info.need_lev then
                            table.insert(self.listdata,v)
                        end
                    else
                        table.insert(self.listdata,v)
                    end
                end
            elseif info.need_lev then
                if v.level >= info.need_lev then
                    table.insert(self.listdata,v)
                end
            else
                table.insert(self.listdata,v)
            end
            --table.insert(self.listdata,v)
        end
    end

    table.sort(self.listdata,function(a,b)
        -- body
        local aScore = mgr.PetMgr:getPetScore(a)
        local bScore = mgr.PetMgr:getPetScore(b)
        if aScore == bScore then
            local ainfo = conf.PetConf:getPetItem(a.petId)
            local binfo = conf.PetConf:getPetItem(b.petId)
            if ainfo and binfo then
                if ainfo.color == binfo.color then
                    if a.power == b.power then
                        if a.petId == b.petId then
                            return a.petRoleId < b.petRoleId
                        else
                            return a.petId > b.petId
                        end
                    else
                        return a.power > b.power
                    end
                else
                    return ainfo.color > binfo.color
                end
            else
                if a.petId == b.a.petId then
                    return a.petRoleId < b.petRoleId
                else
                    return a.petId > b.petId
                end
                
            end
        else
            return aScore > bScore
        end
    end)

    --mgr.PetMgr:sortPet(self.listdata)
    local  number = #self.listdata
    number = math.max(4,math.ceil(number/4)*4) 

    self.petlist.numItems = number
    self.petlist:SelectNone()
end

function PetOnHelp:addMsgCallBack(data)
    -- body
    if data.msgId == 5490201 then
        self.data.warPetData = data.warPetData
        self.select = nil 
        self:setData()
        self:setposinfo()
    elseif data.msgId == 5490202  then
        self.data.warPetData[data.pos] = 0
        self:setData()
    end
    --self.petlist:RefreshVirtualList()
end


return PetOnHelp