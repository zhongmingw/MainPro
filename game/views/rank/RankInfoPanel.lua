local RankInfoPanel = class("RankInfoPanel", import("game.base.Ref"))

function RankInfoPanel:ctor(parent)
    self.parent = parent
    self:initView()
end

function RankInfoPanel:initView()
    -- body
    self.view = self.parent.view:GetChild("n3")
    self.titleList = self.view:GetChild("n3")
    self.listView = self.view:GetChild("n7")
    self.topOnePanel = self.view:GetChild("n0")

    self:initTitleList()
    self:initListView()
end

--排行榜列表
function RankInfoPanel:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:rankListData(index, obj)
    end
    self.listView:SetVirtual()
end
function RankInfoPanel:rankListData( index,obj )
    -- body
    if index + 1 >= self.listView.numItems then
        if not self.rankings then
            return 
        end 
        -- print("9999999",self.page,self.maxPage,self.listView.numItems,index)
        if self.maxPage == self.page then 
            --没有下一页了
            --return
        elseif self.page and self.page < self.maxPage then
            local param = {rankType = self.rankType,svrId = self.sId,page=self.page+1}
            proxy.RankProxy:sendRankMsg(1280102,param)
        end
    end
    local data = self.rankings[index+1]
    local bgIcon = obj:GetChild("n1")
    local numIcon = obj:GetChild("n2")
    obj:GetChild("n8").visible = false
    if self.index then
        if self.index == index then
            obj:GetChild("n8").visible = true
        end
    end
    numIcon.visible = true
    obj:SetSize(436,100)
    if index == 0 then
        bgIcon.url = UIPackage.GetItemURL("rank" , "meili_008")
        numIcon.url = UIPackage.GetItemURL("rank" , "meili_003")
    elseif index == 1 then
        bgIcon.url = UIPackage.GetItemURL("rank" , "meili_009")
        numIcon.url = UIPackage.GetItemURL("rank" , "meili_004")
    elseif index == 2 then
        bgIcon.url = UIPackage.GetItemURL("rank" , "meili_010")
        numIcon.url = UIPackage.GetItemURL("rank" , "meili_005")
    else
        obj:SetSize(436,70)
        bgIcon.url = UIPackage.GetItemURL("_others" , "ditu_004")
        numIcon.visible = false
    end
    local rankTxt = obj:GetChild("n3")
    local nameTxt = obj:GetChild("n4")
    local guildTxt = obj:GetChild("n5")
    local rankingTxt = obj:GetChild("n6")
    rankTxt.text = data.rank
    nameTxt.text = data.roleName
    guildTxt.text = data.gangName == "" and language.rank06 or data.gangName
    if self.rankType == 4 then--坐骑
        local confData = conf.ZuoQiConf:getDataByLv(data.rankingValue,0)
        rankingTxt.text = string.format(language.huoban41,confData.jie) --.. string.format(language.huoban42,confData.xing)
    elseif self.rankType == 5 then--神兵
        local confData = conf.ZuoQiConf:getDataByLv(data.rankingValue,1)
        rankingTxt.text = string.format(language.huoban41,confData.jie) --.. string.format(language.huoban42,confData.xing)
    elseif self.rankType == 6 then--仙羽
        local confData = conf.ZuoQiConf:getDataByLv(data.rankingValue,3)
        rankingTxt.text = string.format(language.huoban41,confData.jie) --.. string.format(language.huoban42,confData.xing)
    elseif self.rankType == 7 then--仙器
        local confData = conf.ZuoQiConf:getDataByLv(data.rankingValue,4)
        rankingTxt.text = string.format(language.huoban41,confData.jie) --.. string.format(language.huoban42,confData.xing)
    elseif self.rankType == 8 then--法宝
        local confData = conf.ZuoQiConf:getDataByLv(data.rankingValue,2)
        rankingTxt.text = string.format(language.huoban41,confData.jie) --.. string.format(language.huoban42,confData.xing)
    elseif self.rankType == 9 then--伙伴
        local confData = conf.HuobanConf:getDataByLv(data.rankingValue,0)
        rankingTxt.text = string.format(language.huoban41,confData.jie) .. string.format(language.huoban42,confData.xing)
    elseif self.rankType == 10 then--剑神
        local confData = conf.AwakenConf:getJsAttr(data.rankingValue)
        rankingTxt.text = string.format(language.huoban41,confData.starlv) .. string.format(language.huoban42,confData.star)
    elseif self.rankType == 11 then--伙伴神兵
        local confData = conf.HuobanConf:getDataByLv(data.rankingValue,2)
        rankingTxt.text = string.format(language.huoban41,confData.jie) --.. string.format(language.huoban42,confData.xing)
    elseif self.rankType == 12 then--伙伴仙羽
        local confData = conf.HuobanConf:getDataByLv(data.rankingValue,1)
        rankingTxt.text = string.format(language.huoban41,confData.jie) --.. string.format(language.huoban42,confData.xing)
    elseif self.rankType == 13 then--伙伴仙器
        local confData = conf.HuobanConf:getDataByLv(data.rankingValue,4)
        rankingTxt.text = string.format(language.huoban41,confData.jie) --.. string.format(language.huoban42,confData.xing)
    elseif self.rankType == 14 then--伙伴法宝
        local confData = conf.HuobanConf:getDataByLv(data.rankingValue,3)        
        rankingTxt.text = string.format(language.huoban41,confData.jie) --.. string.format(language.huoban42,confData.xing)
    elseif self.rankType == 15 then--EVE 离线效率        
        rankingTxt.text = string.format(language.rank11, data.rankingValue)
    elseif self.rankType == 18 then--麒麟
        --print("dddd",data.rankingValue,5)
        local confData = conf.ZuoQiConf:getDataByLv(data.rankingValue,5)
        rankingTxt.text = string.format(language.huoban41,confData.jie) .. string.format(language.huoban42,confData.xing)
    else
        rankingTxt.text = data.rankingValue
    end
    
    data.index = index
    obj.data = data
    obj.onClick:Add(self.onClickCheckInfo,self)
end

function RankInfoPanel:onClickCheckInfo( context )
    local cell = context.sender
    local data = cell.data
    self.index = data.index
    -- print("数量",self.listView.numItems)
    self.listView.numItems = #self.rankings   
    cell:GetChild("n8").visible = true
    self:setTopOneInfo(data)
    -- proxy.PlayerProxy:send(1020205,{svrId = 0,roleId = data.roleId})
end

--服务器列表
function RankInfoPanel:initTitleList()
    -- body
    self.titleList.numItems = 0
    self.titleList.itemRenderer = function(index,obj)
        self:titleData(index, obj)
    end
    self.titleList:SetVirtual()
end

function RankInfoPanel:titleData( index,obj )
    -- body
    local data = self.svrIds[index+1]
    if index == 0 then
        data = 0
    end
    local titleTxt = obj:GetChild("title")
    if index == 0 then
        titleTxt.text = language.rank07
    else
        --10110149
        local serverId = data
        local areaId = serverId%100000 - 10000
        local areaTab = { [1] = "S", 
                          [2] = "A", 
                          [3] = "C", 
                          [4] = "D", 
                          [5] = "E", 
                          [6] = "F" }
        titleTxt.text = areaTab[math.floor(areaId/10000)+1] .. areaId%1000
    end
    obj.data = data
    obj.onClick:Add(self.onClickSend,self)
end

function RankInfoPanel:onClickSend( context )
    local sId = context.sender.data
    self.sId = sId
    self.isFirst = true
    self.index = 0
    self.rankings = {}
    self.page = 1
    local param = {rankType = self.rankType,svrId = sId,page=1}
    proxy.RankProxy:sendRankMsg(1280102,param)
end

--获取服务器返回的排行信息
function RankInfoPanel:setRankInfo( data )
    -- body
    -- self.rankType = data.rankType
    for k,v in pairs(data.rankings) do
        table.insert(self.rankings,v)
    end
    self.maxPage = data.maxPage
    self.page = data.page
    self.myRankingInfo = data.myRankingInfo
    self.listView.numItems = #self.rankings  
    local myRanking = self.view:GetChild("n12")
    if self.myRankingInfo.rank == 0 then
        myRanking.text = language.rank04
    else
        myRanking.text = string.format(language.rank05,self.myRankingInfo.rank)
    end
    -- print("服务器id",self.sId,self.svrIds[1])
    if self.sId ~= 0 then
        myRanking.text = language.rank09
    end
    local data = self.rankings[1]
    -- print("单榜信息",self.isFirst)
    -- printt(data)
    if self.isFirst then
        self.isFirst = false
        if data then
            self.listView:AddSelection(0,false)
            self:setTopOneInfo(data)
            self.listView:ScrollToView(0,false)
        else
            self:setReplaceModel()
        end
    end
end

function RankInfoPanel:setData( svrIds,topData,rankType,myDzList )
    -- body
    self.index = 0
    self.rankings = {} --保存单榜当前信息分页请求用
    self.svrIds = svrIds
    self.myDzList = myDzList
    -- self.topData = topData
    self.rankType = rankType
    self.isFirst = true
    self.page = 1
    self.sId = 0--self.svrIds[1]
    self.titleList.numItems = #self.svrIds

    -- print("单榜数量",#self.svrIds)
    -- printt(self.svrIds)

    local rankDec = self.view:GetChild("n11")
    rankDec.text = conf.RankConf:getRankDescribe(rankType)
    if #self.svrIds > 0 then
        for i=0,(#self.svrIds-1) do
            local obj = self.titleList:GetChildAt(i)
            if i == 0 then
                obj.selected = true
            else
                obj.selected = false
            end
        end
    end
end

--设置占位模型
function RankInfoPanel:setReplaceModel()
    -- body
    local name = self.topOnePanel:GetChild("n2")
    local typeIcon = self.topOnePanel:GetChild("n13")
    local rankValueTxt = self.topOnePanel:GetChild("n5")
    local praiseNum = self.topOnePanel:GetChild("n10")
    -- local src = conf.RankConf:getRankSrcById(self.rankType)
    name.text = language.rank03
    -- typeIcon.url = UIPackage.GetItemURL("rank" , ""..src)
    typeIcon.visible = false
    rankValueTxt.visible = false
    praiseNum.visible = false
    --榜有信息和没信息的不同显示
    self.topOnePanel:GetChild("n12").visible = false
    self.topOnePanel:GetChild("n9").visible = false
    self.topOnePanel:GetChild("n8").visible = false

    if self.effect then
        self.parent:removeUIEffect(self.effect)
        self.effect = nil 
    end

    local heroModel = self.topOnePanel:GetChild("n3")
    local modelObj = self.parent:addModel(RoleSexModel[1].id,heroModel)

    modelObj:setSkins(nil,nil,nil)
    modelObj:setPosition(heroModel.actualWidth/2,-heroModel.actualHeight-200,500)
    modelObj:setRotation(RoleSexModel[1].angle)

    self.modelObj = modelObj
    modelObj:modelTouchRotate(self.topOnePanel:GetChild("n19"))
end

--设置排行个人信息
function RankInfoPanel:setTopOneInfo(data)
    -- body
    self.mbCount = data.dzCount or data.mbCount
    local name = self.topOnePanel:GetChild("n2")
    local typeIcon = self.topOnePanel:GetChild("n13")
    local rankValueTxt = self.topOnePanel:GetChild("n5")
    local praiseNum = self.topOnePanel:GetChild("n10")
    self.modelsee = self.topOnePanel:GetChild("n20")
    -- local src = conf.RankConf:getRankSrcById(self.topData.rankType)
    name.text = data.roleName
    -- typeIcon.url = UIPackage.GetItemURL("rank" , ""..src)
    rankValueTxt.visible = true
    praiseNum.visible = true
    typeIcon.visible = false
    -- if data.roleId == self.topData.roleId then
    --     typeIcon.visible = true
    -- else
    --     typeIcon.visible = false
    -- end
    rankValueTxt.text = data.power or data.rankingValue
    praiseNum.text = string.format(language.rank01,data.dzCount)
    local btnPraise = self.topOnePanel:GetChild("n12")
    btnPraise.data = data
    -- print("点赞情况",data.myDz)
    local flag = false
    for k,v in pairs(self.myDzList) do
        if data.roleId == v then
            flag = true
        end
    end
    if flag then
        btnPraise.icon  = UIPackage.GetItemURL("rank" , "paihangbang_002")
    else
        btnPraise.icon  = UIPackage.GetItemURL("rank" , "paihangbang_014")
    end
    btnPraise.onClick:Add(self.onClickPraise,self)
    local checkBox = self.topOnePanel:GetChild("n8")
    checkBox.data = data
    checkBox.selected = true
    checkBox.onChanged:Add(self.selelctCheck,self)
    --查看玩家信息按钮
    local checkBtn = self.topOnePanel:GetChild("n16")
    checkBtn.data = {roleId = data.roleId,svrId = self.sId,petRoleId = data.extInt01}--data.extInt01
    checkBtn.onClick:Add(self.onClickCheckRole,self)
    --暂时屏蔽麒麟臂的查看信息按钮
    -- if self.rankType == 18 then
    --     checkBtn.visible = false
    -- else
    --     checkBtn.visible = true
    -- end
    --前三个榜和之后的榜的不同显示
    self.topOnePanel:GetChild("n4").visible = true
    if self.rankType >= 4 or self.rankType == 2 then
        self.topOnePanel:GetChild("n9").visible = false
        checkBox.visible = false
        rankValueTxt.visible = false
        self.topOnePanel:GetChild("n4").visible = false
    else
        self.topOnePanel:GetChild("n9").visible = true
        checkBox.visible = true
        rankValueTxt.visible = true
        self.topOnePanel:GetChild("n4").visible = true
    end

    self.wingId = data.skinMap[3] --当前翅膀缓存
    self:setModel(data)
end
--查询信息
function RankInfoPanel:onClickCheckRole(context)
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
    if self.rankType == 17 then--宠物信息跳转
        data.index = 14
    elseif self.rankType == 18 then
        --data.index = 15
    end
    mgr.ViewMgr:openView2(ViewName.SeeOtherMsg,data)
end
--设置模型
function RankInfoPanel:setModel( data )
    local heroModel = self.topOnePanel:GetChild("n3")
    local effectPanel = self.topOnePanel:GetChild("n14")
    local skin1 = string.sub(tostring(data.skinMap[1]),1,3)
    if skin1 == "301" then
        skin1 = data.skinMap[1]
    else
        skin1 = 3010201
    end

    if self.rankType >= 4 then 
        if self.rankType == 4 then--坐骑
            local confData = conf.ZuoQiConf:getDataByLv(data.rankingValue,0)
            local jie = 1
            if confData and confData.jie then jie = confData.jie end
            local modleConf = conf.ZuoQiConf:getSkinsByJie(jie,0)

            skin1 = data.skinMap[4] == 0 and modleConf.modle_id or data.skinMap[4]
        elseif self.rankType == 5 then--神兵
            local confData = conf.ZuoQiConf:getDataByLv(data.rankingValue,1)
            local jie = 1
            if confData and confData.jie then jie = confData.jie end
            local modleConf = conf.ZuoQiConf:getSkinsByJie(jie,1)
            skin1 = data.skinMap[2] == 0 and GuDingmodel[3] or data.skinMap[2]
        elseif self.rankType == 6 then--仙羽
            local confData = conf.ZuoQiConf:getDataByLv(data.rankingValue,3)
            local jie = 1
            if confData and confData.jie then jie = confData.jie end
            local modleConf = conf.ZuoQiConf:getSkinsByJie(jie,3)

            skin1 = data.skinMap[3] == 0 and modleConf.modle_id or data.skinMap[3]
        elseif self.rankType == 7 then--仙器
            local confData = conf.ZuoQiConf:getDataByLv(data.rankingValue,4)
            local jie = 1
            if confData and confData.jie then jie = confData.jie end
            local modleConf = conf.ZuoQiConf:getSkinsByJie(jie,4)

            skin1 = data.skinMap[7] == 0 and modleConf.modle_id or data.skinMap[7]
        elseif self.rankType == 8 then--法宝
            local confData = conf.ZuoQiConf:getDataByLv(data.rankingValue,2)
            local jie = 1
            if confData and confData.jie then jie = confData.jie end
            local modleConf = conf.ZuoQiConf:getSkinsByJie(jie,2)

            skin1 = data.skinMap[6] == 0 and modleConf.modle_id or data.skinMap[6]
        elseif self.rankType == 9 then--伙伴3040102
            skin1 = data.skinMap[15] == 0 and data.skinMap[8] or data.skinMap[15]
        elseif self.rankType == 10 then--剑神
            local attrData = conf.AwakenConf:getJsAttr(data.rankingValue)
            local curModelId = attrData and attrData.starlv or 1--第几阶
            local buffId = conf.AwakenConf:getBuffId(curModelId)
            if data.skinMap[16] and data.skinMap[16] ~= 0 then
                buffId = conf.AwakenConf:getBuffId(data.skinMap[16])
            end
            local buffData = conf.BuffConf:getBuffConf(buffId)
            local model = buffData.bs_args
            -- print("剑神",data.skinMap[16])
            skin1 = model
        elseif self.rankType == 11 then--伙伴神兵
            skin1 = GuDingmodel[4]
        elseif self.rankType == 12 then--伙伴仙羽
            skin1 = GuDingmodel[2]
        elseif self.rankType == 13 then--伙伴仙器
            local confData = conf.HuobanConf:getDataByLv(data.rankingValue,4)
            local modleConf = conf.HuobanConf:getSkinsByJie(confData.jie,4)

            skin1 = data.skinMap[12] == 0 and modleConf.modle_id or data.skinMap[12]
        elseif self.rankType == 14 then--伙伴法宝
            local confData = conf.HuobanConf:getDataByLv(data.rankingValue,3)
            local modleConf = conf.HuobanConf:getSkinsByJie(confData.jie,3)

            skin1 = data.skinMap[11] == 0 and modleConf.modle_id or data.skinMap[11]
        elseif self.rankType == 17 then--宠物
            -- print("宠物模型",data.skinMap[17])
            local confData = conf.PetConf:getPetItem(data.skinMap[17])
            skin1 = confData.model
        elseif self.rankType == 18 then--麒麟臂
            skin1 = GuDingmodel[1]
        end
        -- 3010202,3020102,3030101,3040301,0,0,0,3050104,3030301,0,0,0,1002003,0,0
        -- print("9999999",data.skinMap[self.rankType],skin1,self.rankType)
        -- printt(data.skinMap)
    end
    --法宝(8)和仙器(7)为特效 其他为模型 神兵(5)为模型加特效
    --伙伴仙器(13)、伙伴法宝(14)为特效
    if self.rankType ~= 8 and self.rankType ~= 7 and self.rankType ~= 13  and self.rankType ~= 14 then
        if self.effect then
            self.parent:removeUIEffect(self.effect)
            self.effect = nil 
        end
        -- if self.modelObj then
        --     self.parent:removeModel(self.modelObj)
        --     self.modelObj = nil
        -- end
        
        local modelObj = nil
        if self.rankType ~= 10 then
            if self.skin1 and self.skin1 == skin1 and self.modelObj then
                modelObj = self.modelObj
            else
                modelObj,self.cansee = self.parent:addModel(skin1,heroModel)
            end
        else
            if self.skin1 and self.skin1 == skin1 and self.modelObj then
                modelObj = self.modelObj
            else
                modelObj,self.cansee = self.parent:addModel(skin1[1],heroModel)
            end
        end
        modelObj:setPosition(heroModel.actualWidth/2,-heroModel.actualHeight-200,500)
        if self.rankType < 4 or self.rankType == 15 or self.rankType == 16 then --EVE 离线排行在这里设置模型位置
            -- self.topOnePanel.touchable = true
            self.topOnePanel:GetChild("n19").touchable = true
            -- if self.modelObj ~= modelObj then
                self.cansee = modelObj:setSkins(nil,data.skinMap[2],data.skinMap[3])
                modelObj:setRotation(RoleSexModel[data.sex].angle)
                self.littleEffect = self.parent:addEffect(4020102,self.topOnePanel:GetChild("n18"))
                self.littleEffect.LocalPosition = Vector3(heroModel.actualWidth/2,-heroModel.actualHeight,500)
            -- end
        else
            if self.littleEffect then
                self.parent:removeUIEffect(self.littleEffect)
                self.littleEffect = nil
            end

            if self.rankType == 4 or self.rankType == 6 or self.rankType == 5 or self.rankType == 10 or self.rankType == 18 then
                if self.rankType == 18 then
                    self.topOnePanel:GetChild("n19").touchable = true
                    modelObj:setRotation(90)
                    modelObj:setRotationXYZ(0,168.9,0)
                    modelObj:setPosition(164,-560,500)
    

                    local confData = conf.ZuoQiConf:getDataByLv(data.rankingValue,5)
                    local jie = 1
                    if confData and confData.jie then jie = confData.jie end
                    local modleConf = conf.ZuoQiConf:getSkinsByJie(jie,5)
                    modelObj:addQingbiEct(modleConf.modle_id.."_ui")
                elseif self.rankType ~= 5 and self.rankType ~= 10 then
                    -- self.topOnePanel.touchable = true
                    self.topOnePanel:GetChild("n19").touchable = true
                    modelObj:setRotation(90)
                    modelObj:setScale( SkinsScale[skin1] or  150)
                    if self.rankType == 6 then
                        modelObj:setRotationXYZ(0,330,0)
                        modelObj:setPosition(164,-560,500)
                        if self.modelObj ~= modelObj then
                            self.cansee = modelObj:setSkins(GuDingmodel[1],nil,skin1)
                        end
                    else
                        modelObj:setScale(100)
                        modelObj:setRotationXYZ(0,90,0)
                        modelObj:setPosition(heroModel.actualWidth/2,-heroModel.actualHeight-200,500)
                    end
                elseif self.rankType == 10 then --剑神
                    self.cansee = modelObj:setSkins(nil,skin1[2],skin1[3])
                    -- modelObj:setPosition(0,0,0)
                    modelObj:setPosition(heroModel.actualWidth/2,-heroModel.actualHeight-200,500)
                    modelObj:setRotationXYZ(0,140,0)
                    modelObj:setScale(120)
                else
                    -- self.topOnePanel.touchable = false
                    modelObj:setPosition(heroModel.actualWidth/2+30,-300,500)
                    modelObj:setRotationXYZ(30,90,90)
                    modelObj:setScale(180)
                    -- if self.effect then
                    --     self.parent:removeUIEffect(self.effect)
                    --     self.effect = nil 
                    -- end
                    local confData = conf.ZuoQiConf:getDataByLv(data.rankingValue,1)
                    local jie = 1
                    if confData and confData.jie then jie = confData.jie end
                    local modleConf = conf.ZuoQiConf:getSkinsByJie(jie,1)
                    modelObj:addModelEct(modleConf.modle_id.."_ui")
                    -- self.effect = self.parent:addEffect(4040401,effectPanel)
                    -- self.effect.LocalPosition = Vector3(modelObj.actualWidth/2,-modelObj.actualHeight+100,500)
                end
            elseif self.rankType == 9 or self.rankType == 17 then
                self.topOnePanel:GetChild("n19").touchable = true
                modelObj:setRotationXYZ(0,180,0)
                modelObj:setPosition(heroModel.actualWidth/2,-heroModel.actualHeight-200,500)
            elseif self.rankType == 11 then
                local confData = conf.HuobanConf:getDataByLv(data.rankingValue,2)
                local modleConf = conf.HuobanConf:getSkinsByJie(confData.jie,2)
                local modle_id = data.skinMap[10] == 0 and modleConf.modle_id or data.skinMap[10]
                modelObj:addWeaponEct(modle_id.."_ui")
                modelObj:setRotationXYZ(0,180,0)
                modelObj:setScale(200)
                modelObj:setPosition(heroModel.actualWidth/2,-heroModel.actualHeight-200,500)
            elseif self.rankType == 12 then
                local confData = conf.HuobanConf:getDataByLv(data.rankingValue,1)
                local modleConf = conf.HuobanConf:getSkinsByJie(confData.jie,1)
                local modle_id = data.skinMap[9] == 0 and modleConf.modle_id or data.skinMap[9]

                self.cansee = modelObj:setSkins(skin1,nil,modle_id)
                modelObj:setRotationXYZ(0,0,0)
                modelObj:setScale(200)
                modelObj:setPosition(heroModel.actualWidth/2,-heroModel.actualHeight-200,500)
            end
        end
        self.modelObj = modelObj
        
        --增加头饰光环特效
        if  self.rankType == 1  or self.rankType == 2 or self.rankType == 3
            or self.rankType == 16  or self.rankType == 15 then
            modelObj:removeModelEct()
            local skinsHalo = data.skinMap[Skins.halo]--光环
            local skinHeadWear = data.skinMap[Skins.headwear] --头饰
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

        end
        self.modelsee.visible = self.cansee
        modelObj:modelTouchRotate(self.topOnePanel:GetChild("n19"))
    else
        self.modelsee.visible = false
        if self.modelObj then
            self.parent:removeModel(self.modelObj)
        end
        self.modelObj = nil
        -- if self.effect then
        --     self.parent:removeUIEffect(self.effect)
        --     self.effect = nil 
        -- end
        -- print("特效")
        if self.skin1 ~= skin1 or not self.effect then
            self.effect = self.parent:addEffect(skin1,effectPanel)
        end
        -- self.topOnePanel.touchable = false
        self.topOnePanel:GetChild("n19").touchable = false
        if self.effect then
            if self.rankType == 8 then
                self.effect.LocalPosition = Vector3(164,-350,500)
            elseif self.rankType == 7 then
                self.effect.LocalPosition = Vector3(164,-510,500)
            elseif self.rankType == 13 then
                self.effect.LocalPosition = Vector3(164,-400,250)
            elseif self.rankType == 14 then
                self.effect.LocalPosition = Vector3(164,-300,250)
            end
        end
    end

    self.skin1 = skin1 --保存上一个皮肤id
end
--复选框显示和隐藏翅膀
function RankInfoPanel:selelctCheck(context)
    -- body
    local cell = context.sender
    local data = cell.data
    local selected = cell.selected
    if selected then
        data.skinMap[3] = self.wingId
        self:setModel(data)
    else
        data.skinMap[3] = 0
        self:setModel(data)
    end
end
--刷新个人点赞信息
function RankInfoPanel:refreshPraise(data)
    self.mbCount = self.mbCount + 1
    local btnPraise = self.topOnePanel:GetChild("n12")
    btnPraise.icon  = UIPackage.GetItemURL("rank" , "paihangbang_002")
    table.insert(self.myDzList,data.roleId)
    self.rankings[self.index+1].dzCount = self.mbCount
    local praiseNum = self.topOnePanel:GetChild("n10")
    praiseNum.text = string.format(language.rank01,self.mbCount)
end
--点赞
function RankInfoPanel:onClickPraise( context )
    -- body
    local cell = context.sender
    local data = cell.data
    local param = {rankType = self.rankType,svrId = self.sId,roleId=data.roleId}
    proxy.RankProxy:sendRankMsg(1280103,param,2)
end

function RankInfoPanel:clear()
    -- body
    if self.modelObj then
        self.parent:removeModel(self.modelObj)
        self.modelObj = nil
    end
    if self.littleEffect then
        self.parent:removeUIEffect(self.littleEffect)
        self.littleEffect = nil
    end
end

return RankInfoPanel