--
-- Author: 
-- Date: 2018-07-23 15:07:28
--
local show = {
    {102,0},
    {103,0}, --防御
    {105,0},--生命
    {106,0},--命中
    {107,0},--闪避
    {108,0},--暴击
    {109,0},--抗暴

}

local PetFriend = class("PetFriend",import("game.base.Ref"))

function PetFriend:ctor(mparent)    
    self.mparent = mparent
    self.view = mparent.view:GetChild("n70")

    self:initView()
end

function PetFriend:initView()
    -- body
    --print("55555555555")
    self.btnlist = {}
    for i = 1,8 do
        local btn = self.view:GetChild("n"..i)
        btn.data = i
        btn.onClick:Add(self.onBtnCallBack,self)
        self:setMsg(btn)
        table.insert(self.btnlist,btn)
    end

    self.prolist = self.view:GetChild("n41")
    self.prolist.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.prolist.numItems = 0

    self.countlist = self.view:GetChild("n17")
    self.countlist.itemRenderer = function(index,obj)
        self:celldcountata(index, obj)
    end
    self.countlist.numItems = 0

    local btnGuize = self.view:GetChild("n29")
    btnGuize.onClick:Add(self.onGuize,self)

    self.modelpanel = self.view:GetChild("n23")
end

function PetFriend:setMsg(btn)
    -- body
    local i = btn.data
    --print("in ",i)
    local c1 = btn:GetController("c1")
    c1.selectedIndex = 1

    local icon = btn:GetChild("n1")
    icon.url = UIItemRes.pet02[i]

    local n4 = btn:GetChild("n5")
    n4.visible = false

    local lab = btn:GetChild("n7")
    local condata = conf.PetConf:getPetPosCondi(1000+i)
    if condata.open_lev then
        lab.text = string.format(language.gonggong07,condata.open_lev)
    else
        local _condata = conf.PetConf:getOpenCost(i)
        lab.text = language.pet65
    end

    if not self.data then
        return
    end
    c1.selectedIndex = 0
    if self.data.warPetData[1000+i] == 0 then
        icon.url = UIItemRes.pet03
    else
        local v = self.petdata[self.data.warPetData[i+1000]]
        local condata = conf.PetConf:getPetItem(v.petId)
        --icon.url = ResPath.iconRes(condata.src)
        n4.visible = true
        n4:GetChild("n1").url = ResPath.iconRes(condata.src)
    end
end

function PetFriend:initData()
    -- body
    local petdata = cache.PetCache:getData()
    self.petdata = {}
    for k ,v in pairs(petdata) do
        self.petdata[v.petRoleId] = v
    end

    local id =  cache.PetCache:getCurpetRoleId()
    local v = self.petdata[id]
    local condata = conf.PetConf:getPetItem(v.petId)
    
    self.model = nil 
    self.model = self.mparent:addModel(condata.model,self.modelpanel)
    self.model:setScale(SkinsScale[Skins.newpet])
    self.model:setRotationXYZ(0,143.7,0)
    self.model:setPosition(41.45,-275.4,500)

    self.condataPetAttr = conf.PetConf:getSupportPetAttr()
end

function PetFriend:setData()
    -- body
    --重新设置一下位置信息
    self.count = 0 --上阵个数
    self.colorcount = {}--颜色 - 数量
    for k , v in pairs(self.data.warPetData) do

        self:setMsg(self.btnlist[k%1000])
--        print(v)
        if v ~= 0 then
            self.count = self.count + 1
            local data = self.petdata[v]
            local condata = conf.PetConf:getPetItem(data.petId)
            if not self.colorcount[condata.color] then
                self.colorcount[condata.color]  = 0
            end
            self.colorcount[condata.color]  = self.colorcount[condata.color]  + 1
        end
    end
    self.countlist.numItems = 0
    for k , v in pairs(self.condataPetAttr) do
        self:celldcountata(v)
    end
end

function PetFriend:celldata(index, obj)
    -- body
    local v1 = self.prodata[index+1]
    local var = conf.PetConf:getValue("pet_help_attr_add")
    local cc = v1[2] * var / 10000
    local str = mgr.PetMgr:getProName(v1).."+".. GProPrecnt(v1[1],checkint(cc))
    obj:GetChild("n1").text = str
end

function PetFriend:celldcountata(data)
    -- body
    if not data.zz_num then
        print("宠物配置 support_pet_attr 配置错误，zz_num 是必须配置的")
        return
    end
    local flag = false
    local str = ""
    if data.need_color then
        local number = 0 --self.colorcount[data.need_color]  or 0
        for i = data.need_color , 6 do
            number = number + (self.colorcount[i]  or 0)
        end
        flag  = number >= data.zz_num
        str = string.format(language.pet51,language.gonggong110[data.need_color],data.zz_num,number,data.zz_num)
    else
        flag = self.count >= data.zz_num

        str = string.format(language.pet50,data.zz_num,self.count,data.zz_num)
    end

    local var = UIPackage.GetItemURL("pet" , "Component19")
    local _compent1 = self.countlist:AddItemFromPool(var)
    local lab = _compent1:GetChild("n0")
    if flag then
        lab.text = mgr.TextMgr:getTextColorStr(str, 7)
    else
        lab.text = mgr.TextMgr:getTextColorStr(str, 8)
    end

    local var1 = UIPackage.GetItemURL("pet" , "Component19")
    local _compent2 = self.countlist:AddItemFromPool(var1)
    local lab1 = _compent2:GetChild("n0")
    local sss = string.format(language.pet68,data.pet_add_persent/100)
    if flag then
        lab1.text = mgr.TextMgr:getTextColorStr(sss, 7)
    else
        lab1.text = mgr.TextMgr:getTextColorStr(sss, 8)
    end

    local function setpro( lab,v1 )
        -- body
        if not v1 then
            return
        end
        local _pro = mgr.PetMgr:getProName(v1).."+".. GProPrecnt(v1[1],checkint(v1[2]))
        if flag then
            lab.text = mgr.TextMgr:getTextColorStr(_pro, 7)
        else
            lab.text = mgr.TextMgr:getTextColorStr(_pro, 8)
        end
    end

    local t = GConfDataSort(data)
    local number = #t
    for i = 1 , number,2 do
        local v1 = t[i]
        local v2 = t[i+1]

        local var = UIPackage.GetItemURL("pet" , "Component20")
        local _compent1 = self.countlist:AddItemFromPool(var)
        local labpro1 = _compent1:GetChild("n0")
        local labpro2 = _compent1:GetChild("n1")
        labpro1.text = ""
        labpro2.text = ""
        setpro(labpro1,v1)
        setpro(labpro2,v2)
    end
    
end


function PetFriend:setRight(pos)
    -- body
    --开始计算助阵伙伴信息
    self.prodata = clone(show)
    --printt(self.prodata)
    for k , v in pairs(self.data.warPetData) do
        if v~=0 then
            local data = self.petdata[v]
            local info = mgr.PetMgr:getPetPro(data)
            if info then
                G_composeData(self.prodata,info)
            end
        end
    end

    self.prolist.numItems = #self.prodata
end

function PetFriend:onBtnCallBack(context)
    -- bod
    if not self.data then
        return
    end
    local btn = context.sender
    local pos = btn.data 
    if self.data.warPetData[pos+1000] then
        local t = {}
        t.pos = pos + 1000
        t.warPetData = self.data.warPetData
        mgr.ViewMgr:openView2(ViewName.PetOnHelp,t)
    else
        local t = {}
        t.pos = pos
        t.opencount = self.data.warPetData
        local condata = conf.PetConf:getPetPosCondi(1000+pos)
        if condata.open_lev then
            if condata.open_lev > cache.PlayerCache:getRoleLevel() then
                return GComAlter(string.format(language.gonggong07,condata.open_lev) )
            end
            return
        end
        mgr.ViewMgr:openView2(ViewName.PetOpenPos,t)
    end
end

function PetFriend:onGuize( ... )
    -- body
    GOpenRuleView(1109)
end

function PetFriend:addMsgCallBack(data)
    -- body
    if data.msgId == 5490201 then
        self.data = data 
        self:setData()

        self:setRight(data.pos)

    elseif data.msgId == 5490202 then
        self.data.warPetData[data.pos] = 0

        self:setMsg(self.btnlist[data.pos%1000])
    end

    self.opencount = table.nums(self.data.warPetData)
end

return PetFriend