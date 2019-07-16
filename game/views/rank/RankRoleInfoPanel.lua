local RankRoleInfoPanel = class("RankRoleInfoPanel", import("game.base.Ref"))

function RankRoleInfoPanel:ctor(parent)
    self.parent = parent
    self:initView()
end

function RankRoleInfoPanel:initView()
    -- body
    self.view = self.parent.view:GetChild("n2")
    self.listView = self.view:GetChild("n1")
    --控制list的两个按钮
    local btnRight = self.view:GetChild("n22")
    btnRight.onClick:Add(self.onClickTurnRight,self)
    local btnLeft = self.view:GetChild("n23")
    btnLeft.onClick:Add(self.onClickTurnLeft,self)
    self.wings = {}
    self:initListView()
end

--按钮
function RankRoleInfoPanel:onClickTurnRight( context )
    -- body
    if self.index < (#self.tops-1) then
        self.index = self.index+1
    end
    self.listView:ScrollToView(self.index,true)
end
function RankRoleInfoPanel:onClickTurnLeft( context )
    -- body
    if self.index > 0 then
        self.index = self.index-1
    end
    self.listView:ScrollToView(self.index,true)
end

function RankRoleInfoPanel:setData( tops,svrIds,myDzList )
    -- body

    self.tops = tops
    self.svrIds = svrIds
    self.myDzList = myDzList
    for k,v in pairs(self.tops) do
        table.insert(self.wings,v.skinMap[3])
    end

    self.listView.numItems = #self.tops
    self.index = 0
end

function RankRoleInfoPanel:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.listView:SetVirtual()
end

function RankRoleInfoPanel:itemData( index,obj )
    -- body
    local data = self.tops[index+1]
    local nameTxt = obj:GetChild("n2")
    local rankValueTxt = obj:GetChild("n5")
    local typeIcon = obj:GetChild("n13")
    local praiseNum = obj:GetChild("n10")
    local src = conf.RankConf:getRankSrcById(language.rank10[data.rankType]) or ""
    typeIcon.url = UIPackage.GetItemURL("rank" , ""..src)
    nameTxt.text = data.roleName
    rankValueTxt.text = data.rankingValue
    rankValueTxt.visible = false
    obj:GetChild("n4").visible = false
    praiseNum.text = string.format(language.rank01,data.dzCount)
    local btnPraise = obj:GetChild("n12")
    btnPraise.data = data
    local falg = false
    for k,v in pairs(self.myDzList) do
        if v == data.roleId then
            falg = true
        end
    end
    if falg then
        btnPraise.icon  = UIPackage.GetItemURL("rank" , "paihangbang_002")
    else
        btnPraise.icon  = UIPackage.GetItemURL("rank" , "paihangbang_014")
    end
    btnPraise.onClick:Add(self.onClickPraise,self)
    obj.data = data

    --查看玩家信息按钮
    local checkBtn = obj:GetChild("n16")
    checkBtn.data = {roleId = data.roleId,svrId = 0,petRoleId = data.extInt01,index = (data.rankType == 17) and 14 or 0}
    checkBtn.onClick:Add(self.onClickCheckInfo,self)
    -- --暂时屏蔽宠物的查看信息按钮
    -- if data.rankType == 17 then
    --     checkBtn.visible = false
    -- else
    --     checkBtn.visible = true
    -- end
    --设置模型
    local heroModel = obj:GetChild("n3")
    self:setModel(data,heroModel,obj)

    local littleEffect = self.parent:addEffect(4020102,obj:GetChild("n18"))
    littleEffect.LocalPosition = Vector3(heroModel.actualWidth/2,-heroModel.actualHeight,500)
    --复选框 翅膀显隐
    local checkBox = obj:GetChild("n8")
    checkBox.data = index
    checkBox.selected = true
    if data.skinMap[3] == 0 then
        checkBox.selected = false
    end
    checkBox.onChanged:Add(self.selelctCheck,self)
end

--查询信息
function RankRoleInfoPanel:onClickCheckInfo(context)
    -- body
    local cell = context.sender
    local data = cell.data
    if tonumber(data.roleId)<10000 then
        GComAlter(language.gonggong58)
        return
    elseif data.roleId == cache.PlayerCache:getRoleId() then
        GComAlter(language.gonggong57)
        return
    end
    mgr.ViewMgr:openView2(ViewName.SeeOtherMsg,data)
end

--设置模型
function RankRoleInfoPanel:setModel(data,node,obj)
    local skinsHalo = data.skinMap[Skins.halo]--光环
    local skinHeadWear = data.skinMap[Skins.headwear] --头饰
    -- body
    local modelObj,cansee = self.parent:addModel(data.skinMap[1],node)
    cansee = modelObj:setSkins(nil,data.skinMap[2],data.skinMap[3])
    obj:GetChild("n20").visible = cansee
    modelObj:removeModelEct()
    if skinsHalo ~= 0 and  skinsHalo then
        local haloData = conf.RoleConf:getHaloData(skinsHalo)
        local modelEct = modelObj:addModelEct(haloData.effect_id .. "_ui")
        modelEct.Scale =  Vector3.New(0.35,0.35,0.35)
    end
    if skinHeadWear ~= 0 and  skinHeadWear  then
        local headData = conf.RoleConf:getHeadData(skinHeadWear) 
        local modelEct = modelObj:addHeadEct(headData.effect_id)
    end

    if data.skinMap[Skins.mianju] and data.skinMap[Skins.mianju] ~= 0 then
        local confData = conf.MianJuConf:getMianJuData(data.skinMap[Skins.mianju])
        local modelEct = modelObj:addMianJuEct(confData.effect_id)
    end

    modelObj:setPosition(node.actualWidth/2,-node.actualHeight-300,800)
    if not data.sex then
        data.sex = 1
    end
    data.sex = math.max(data.sex,1)


    --data.sex = data.sex and 1 or 1 or data.sex == 0 and 1 or data.sex
    modelObj:setRotation(RoleSexModel[data.sex].angle)
    modelObj:setScale(SkinsScale[data.skinMap[1]] or 180)


end

function RankRoleInfoPanel:selelctCheck( context )
    -- body
    local cell = context.sender
    local index = cell.data
    local obj = cell.parent
    local heroModel = obj:GetChild("n3")
    local data = self.tops[index+1]
    if cell.selected then
        data.skinMap[3] = self.wings[index+1]
        self:setModel(data,heroModel,obj)
    else
        data.skinMap[3] = 0
        self:setModel(data,heroModel,obj)
    end
end

--点赞按钮
function RankRoleInfoPanel:onClickPraise( context )
    -- body
    local cell = context.sender
    local data = cell.data
    local param = {rankType = data.rankType,svrId = self.svrIds[1],roleId=data.roleId}
    proxy.RankProxy:sendRankMsg(1280103,param,1)
end

return RankRoleInfoPanel