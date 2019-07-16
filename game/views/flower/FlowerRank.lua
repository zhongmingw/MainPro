--
-- Author: 
-- Date: 2018-06-29 10:54:35
--

local FlowerRank = class("FlowerRank", base.BaseView)

function FlowerRank:ctor()
    FlowerRank.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function FlowerRank:initView()
    local closeBtn = self.view:GetChild("n2"):GetChild("n5")
    closeBtn.onClick:Add(self.onBtnClose,self)
    
    self.dec1 = self.view:GetChild("n13")
    self.dec1.text = language.flower01

    self.lastTime = self.view:GetChild("n14")
    self.lastTime.text = ""

    self.dec2 = self.view:GetChild("n17")
    
    self.dec3 = self.view:GetChild("n28")

    self.dec3_1 = self.view:GetChild("n29")
    self.dec4 = self.view:GetChild("n15")
    

  

    local awardBtn = self.view:GetChild("n18")
    awardBtn.onClick:Add(self.onClickAward,self)

    local getFlowerBtn = self.view:GetChild("n30")
    getFlowerBtn.onClick:Add(self.onGetFlower,self)

    local ruleTxt = self.view:GetChild("n12")
    ruleTxt.text = mgr.TextMgr:getTextColorStr(language.flower10,7,"")
    ruleTxt.onClickLink:Add(self.onClickGuize,self)

    self.scoreTxt = self.view:GetChild("n16")
    self.scoreTxt.text = ""

    self.leftModelPanel = self.view:GetChild("n27")
    self.rightModelPanel = self.view:GetChild("n26")

    --全服鲜花榜灵童
    self.lingtongPanel = self.view:GetChild("n37")
    self.icon1 = self.view:GetChild("n24")
    self.icon2 = self.view:GetChild("n25")
    self.icon3 = self.view:GetChild("n35")
    self.titleIcon = self.view:GetChild("n2"):GetChild("n4")
    self.title1 = self.view:GetChild("n7")
    self.title2 = self.view:GetChild("n8")
    self.chenghao1 = self.view:GetChild("n38")
    self.chenghao2 = self.view:GetChild("n39")
    self.awardIcon = self.view:GetChild("n23")

    self.c1 = self.view:GetController("c1")

end




function FlowerRank:initData()
    
    self.manList = self.view:GetChild("n10")
    self.manList.itemRenderer = function(index,obj)
        self:cellManData(index, obj)
    end

    self.womanList = self.view:GetChild("n9")
    self.womanList.itemRenderer = function(index,obj)
        self:cellWomanData(index, obj)
    end

    -- self.rankList = self.view:GetChild("n34")
    -- self.rankList.itemRenderer = function(index,obj)
    --     self:cellData(index, obj)
    -- end

    self.selfRoleId = cache.PlayerCache:getRoleId()
    -- self:initModel()

end
function FlowerRank:setData(data)
    -- printt("鲜花榜",data)
    self.data = data
    if data.mulActId ~= 0 then
        print("多开id",data.mulActId)
        self.mulConfData = conf.ActivityConf:getMulActById(data.mulActId)
        self.pre = self.mulConfData.award_pre
    end

    self.scoreTxt.text = data.myScore
    self.time = data.lastTime
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    table.sort(data.nsRanks,function ( a,b )
        return a.rank < b.rank
    end)
    table.sort(data.hhRanks,function ( a,b )
        return a.rank < b.rank
    end)

    local limt = conf.ActivityConf:getHolidayGlobal("flower_rank_people_limt")
    self:setImgAndModel()
    self.womanList.numItems = limt
    self.manList.numItems = limt
    self:setDecTxt()
end

function FlowerRank:setDecTxt()
    local sex = cache.PlayerCache:getSex()
    local downScore = conf.ActivityConf:getHolidayGlobal("flower_rank_limit_score")

    if self.titleIcon.url == UIPackage.GetItemURL("flower" , "xianhua_028") then--魅力榜
        self.dec2.text = string.format(language.flower02[2],downScore)
        self.dec3.text = language.flower03[2]
        self.dec3_1.text = language.flower03_01[2]
        self.dec4.text = language.flower04_01[sex]
    else
        self.dec2.text = string.format(language.flower02[1],downScore)
        self.dec3.text = language.flower03[1]
        self.dec3_1.text = language.flower03_01[1]
        self.dec4.text = language.flower04[sex]
    end
end


function FlowerRank:setImgAndModel()
    if not self.data.actId then return end
    self.icon1.y = 275
    self.icon2.y = 275
    local id = self.pre and self.pre or self.data.actId
    local imgConfData = conf.ActivityConf:getFlowerRankImgByActId(id)
    if imgConfData then
        self.awardIcon.url = UIPackage.GetItemURL("flower" , imgConfData.award_img)
        --双奖励
        if imgConfData.double_img then
            self.icon1.url = UIPackage.GetItemURL("flower" , imgConfData.double_img[1])
            self.icon2.url = UIPackage.GetItemURL("flower" , imgConfData.double_img[2])
            self.c1.selectedIndex = 0--开服，限时，跨服
        elseif imgConfData.single_img then
            self.icon2.url = UIPackage.GetItemURL("flower" , imgConfData.single_img)
            self.c1.selectedIndex = 1--全服
        end

        self.title1.url = UIPackage.GetItemURL("flower" , imgConfData.rank_name_img[1])
        self.title2.url = UIPackage.GetItemURL("flower" , imgConfData.rank_name_img[2])
    end
    local modelInfo --模型id&类型
    local modelParam --模型参数
    if self.data.mulActId ~= 0 and self.mulConfData then
        local titleIconStr = self.mulConfData.title_icon or "xianhua_002"
        self.titleIcon.url = UIPackage.GetItemURL("flower" , titleIconStr)

        modelInfo = self.mulConfData.model_id
        modelParam = self.mulConfData.model_scale_pos_rot[1]
    else
        self.titleIcon.url = UIPackage.GetItemURL("flower" , imgConfData.title_icon)
        modelInfo = imgConfData.model_id
        modelParam = imgConfData.model_scale_pos_rot[1]
    end
    if #modelInfo > 1 then--两个模型
        if modelInfo[1] then
            self:setModel(modelInfo[1],modelParam,self.leftModelPanel)
        end 
        if modelInfo[2] then
            self:setModel(modelInfo[2],modelParam,self.rightModelPanel)
        end
    else
        if imgConfData.single_img then
            self:setModel(modelInfo[1],modelParam,self.lingtongPanel)
        else
            self:setModel(modelInfo[1],modelParam,self.leftModelPanel)
        end
    end
end

function FlowerRank:setModel(modelInfo,modelParam,panel)
    local modelId = modelInfo[1]
    local modelType = modelInfo[2]
    if modelType == 0 then--普通模型
        local obj = self:addModel(modelId,panel)
        obj:setScale(modelParam[1][1])
        obj:setPosition(modelParam[2][1],modelParam[2][2],modelParam[2][3])
        obj:setRotationXYZ(modelParam[3][1],modelParam[3][2],modelParam[3][3])
    elseif modelType == 1 then--需要载体模型
        local obj = self:addModel(GuDingmodel[1],panel)
        obj:setSkins(nil,nil,modelId)
        obj:setScale(modelParam[1][1])
        obj:setPosition(modelParam[2][1],modelParam[2][2],modelParam[2][3])
        obj:setRotationXYZ(modelParam[3][1],modelParam[3][2],modelParam[3][3])
    elseif modelType == 2 then--特效
        local modelObj = self:addEffect(modelId,panel)
        modelObj.Scale = Vector3.New(modelParam[1][1],modelParam[1][1],modelParam[1][1])
        modelObj.LocalPosition = Vector3(modelParam[2][1],modelParam[2][2],modelParam[2][3])
    end   
end
-- function FlowerRank:initModel()
--     local data = cache.ActivityCache:get5030111()
--     local downScore = conf.ActivityConf:getHolidayGlobal("flower_rank_limit_score")
--     self.dec2.text = string.format(language.flower02,downScore)
--     self.title1.url = UIPackage.GetItemURL("flower" , "xianhua_006")
--     self.title2.url = UIPackage.GetItemURL("flower" , "xianhua_007")
--     self.icon1.y = 275
--     self.icon2.y = 275
--     self.chenghao1.visible = false
--     self.chenghao2.visible = false
--     if (data.acts[1089] and data.acts[1089] == 1) or (data.acts[1090] and data.acts[1090] == 1) then
--         --开服&限时鲜花榜
--         self.c1.selectedIndex = 0
--         self.icon1.url = UIPackage.GetItemURL("flower" , "xianhua_020")
--         self.icon2.url = UIPackage.GetItemURL("flower" , "xianhua_021")
--         self.titleIcon.url = UIPackage.GetItemURL("flower" , "xianhua_002")
--         self.awardIcon.url = UIPackage.GetItemURL("flower" , "xianhua_022")
        
--         local tempConf = conf.ActivityConf:getHolidayGlobal("flower_rank_pet_id")
--         local womanPetId = tempConf[2]
--         local manPetId = tempConf[1]
--         self:setModel(womanPetId,self.leftModelPanel)
--         self:setModel(manPetId,self.rightModelPanel)
--     elseif (data.acts[5003] and data.acts[5003] == 1) then--跨服鲜花榜
--         -- self.c1.selectedIndex = 0
--         -- self.icon1.y = 470
--         -- self.icon2.y = 470
--         -- self.chenghao1.visible = true
--         -- self.chenghao2.visible = true
--         -- self.title1.url = UIPackage.GetItemURL("flower" , "xianhua_035")
--         -- self.title2.url = UIPackage.GetItemURL("flower" , "xianhua_036")
--         -- self.icon1.url = UIPackage.GetItemURL("flower" , "xianhua_038")--
--         -- self.icon2.url = UIPackage.GetItemURL("flower" , "xianhua_039")--
--         -- self.titleIcon.url = UIPackage.GetItemURL("flower" , "xianhua_037")--xianhua_028--魅力榜
--         -- -- self.awardIcon.url = UIPackage.GetItemURL("flower" , "xianhua_034")--xianhua_029

--         -- local tempConf = conf.ActivityConf:getHolidayGlobal("zq_flower_ank_fabao_id")
--         -- local womanFaBao = tempConf[2]
--         -- local manFaBao = tempConf[1]
--         -- --*******法宝*********
--         -- -- self:setEffect(womanFaBao,self.leftModelPanel)
--         -- -- self:setEffect(manFaBao,self.rightModelPanel)
--         -- --*******宠物模型**********
--         -- self.awardIcon.url = UIPackage.GetItemURL("flower" , "xianhua_022")--宠物
--         -- self:setModel(womanFaBao,self.leftModelPanel)
--         -- self:setModel(manFaBao,self.rightModelPanel)
--         -- --*******翅膀模型**********
--         -- local wingId = 3030415
--         -- local modelObj = self:addModel(GuDingmodel[1],self.leftModelPanel)
--         -- modelObj:setSkins(nil,nil,wingId)
--         -- modelObj:setScale(100)
--         -- modelObj:setPosition(86,-300,500)
--         -- modelObj:setRotationXYZ(0,270,350)
--         --2018/11/15跨服鲜花榜奖励改成全服鲜花榜的奖励
--         self.c1.selectedIndex = 1
--         self.titleIcon.url = UIPackage.GetItemURL("flower" , "xianhua_028")
--         self.awardIcon.url = UIPackage.GetItemURL("flower" , "xianhua_030")
--         local modelId = conf.ActivityConf:getHolidayGlobal("flower_whole_model")[1]
--         local modelObj = self:addModel(modelId,self.lingtongPanel)
--         modelObj:setRotationXYZ(0,180,0)
--         modelObj:setPosition(46,-190,220)


--     elseif (data.acts[5011] and data.acts[5011] == 1) then--全服鲜花榜
--         local downScore = conf.ActivityConf:getHolidayGlobal("flower_whole_limit_score")
--         self.dec2.text = string.format(language.flower02,downScore)
--         self.c1.selectedIndex = 1
--         self.titleIcon.url = UIPackage.GetItemURL("flower" , "xianhua_033")--全服鲜花榜
--         self.awardIcon.url = UIPackage.GetItemURL("flower" , "xianhua_030")
--         local modelId = conf.ActivityConf:getHolidayGlobal("flower_whole_model")[1]
--         local modelObj = self:addModel(modelId,self.lingtongPanel)
--         modelObj:setRotationXYZ(0,180,0)
--         modelObj:setPosition(46,-190,220)
--     end
-- end

-- function FlowerRank:setModel(petId,panel)
--     local confData = conf.PetConf:getPetItem(petId)
--     local petModelId = confData.model
--     local modelObj = self:addModel(petModelId,panel)
--     modelObj:setScale(160)
--     modelObj:setRotationXYZ(0,166,0)
--     modelObj:setPosition(0,-120,100)
-- end

-- function FlowerRank:setEffect(effectId,panel)
--     local modelObj = self:addEffect(effectId,panel)
--     modelObj.Scale = Vector3.New(200,200,200)
--     modelObj.LocalPosition = Vector3(0,-160,500)
-- end

--合在一起
function FlowerRank:cellData(index,obj)
    local data = self.rankData[index+1]
    local womanObj = obj:GetChild("n36")
    local manObj = obj:GetChild("n37")
    local womanData = data and data.woman and data.woman or {}
    local manData = data and data.man and data.man or {}
    self:setWomanInfo(index,womanData,womanObj)
    self:setManInfo(index,manData,manObj)
end

--女神榜
-- function FlowerRank:setWomanInfo(index,data,obj)
function FlowerRank:cellWomanData(index,obj)
    local data = self.data.nsRanks[index+1]
    local c1 = obj:GetController("c1")
    local name = obj:GetChild("n4")
    local dec1 = obj:GetChild("n5")
    local score = obj:GetChild("n6")
    local roleBtn = obj:GetChild("n3")
    local dec2 = obj:GetChild("n10")
    local rankImg = obj:GetChild("n2")
    local rankTxt = obj:GetChild("n11")
    obj:GetChild("n12").visible = false
    if index < 3 then 
        rankImg.visible = true
        rankImg.url = UIPackage.GetItemURL("flower" , UIItemRes.flowerRank[index+1])
        rankTxt.text = ""
    else
        rankImg.visible = false
        rankTxt.text = string.format(language.flower06,index+1)
    end
    if data then 
        local roleId = data.roleId --玩家id 
        local uId = string.sub(roleId,1,3)
        -- print("女神榜cache.PlayerCache:getRedPointById(10327)",cache.PlayerCache:getRedPointById(10327),roleId)
        if roleId == cache.PlayerCache:getRoleId() then
            obj:GetChild("n12").visible = false
        else
            if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(roleId) > 10000 then
               obj:GetChild("n12").visible = true
            else
               obj:GetChild("n12").visible = false
            end
        end
        data.sex = 2
        c1.selectedIndex = 0
        name.text = data.roleName
        if self.titleIcon.url == UIPackage.GetItemURL("flower" , "xianhua_028") then--魅力榜
            dec1.text = language.flower07_01[2]
        else
            dec1.text = language.flower07[2]
        end
   
        score.text = data.score
        local t = { level = data.level , roleIcon = data.roleIcon,roleId = data.roleId }
        roleBtn.data = index
        GBtnGongGongSuCai_050(roleBtn,t)
        local giveBtn = obj:GetChild("n7")
        giveBtn.data = data 
        giveBtn.onClick:Add(self.onGiveFlower, self)
        local coupleName = cache.PlayerCache:getCoupleName()
        -- if coupleName and tostring(coupleName) == tostring(data.roleName) then--只能看见自己伴侣的
        --     giveBtn.visible = true
        --     obj:GetChild("n8").visible = true
        -- else
        --     giveBtn.visible = false
        --     obj:GetChild("n8").visible = false
        -- end
        local sex = cache.PlayerCache:getSex()
        if sex == 1 then--男的
            giveBtn.visible = true
            obj:GetChild("n8").visible = true
        else
            giveBtn.visible = false
            obj:GetChild("n8").visible = false
        end
        if self.selfRoleId == data.roleId then--自己不能给自己送
            giveBtn.visible = false
            obj:GetChild("n8").visible = false
        end
    else
        c1.selectedIndex = 1
        dec2.text = language.flower08
    end
end
--护花榜
-- function FlowerRank:setManInfo(index,data,obj)
function FlowerRank:cellManData(index,obj)
    local data = self.data.hhRanks[index+1]
    local c1 = obj:GetController("c1")
    local name = obj:GetChild("n4")
    local dec1 = obj:GetChild("n5")
    local score = obj:GetChild("n6")
    local roleBtn = obj:GetChild("n3")
    local dec2 = obj:GetChild("n8")
    local rankImg = obj:GetChild("n2")
    local rankTxt = obj:GetChild("n9")
    obj:GetChild("n12").visible = false

    if index < 3 then 
        rankImg.visible = true
        rankImg.url = UIPackage.GetItemURL("flower" , UIItemRes.flowerRank[index+1])
        rankTxt.text = ""
    else
        rankImg.visible = false
        rankTxt.text = string.format(language.flower06,index+1)
    end
    if data then 
        local roleId = data.roleId --玩家id 
        local uId = string.sub(roleId,1,3)
        -- print("男榜cache.PlayerCache:getRedPointById(10327)",cache.PlayerCache:getRedPointById(10327),roleId)
        if roleId == cache.PlayerCache:getRoleId() then
            obj:GetChild("n12").visible = false
        else
            if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(roleId) > 10000 then
               obj:GetChild("n12").visible = true
            else
               obj:GetChild("n12").visible = false
            end
        end
        data.sex = 1
        c1.selectedIndex = 0
        name.text = data.roleName
        
        if self.titleIcon.url == UIPackage.GetItemURL("flower" , "xianhua_028") then--魅力榜
            dec1.text = language.flower07_01[1]
        else
            dec1.text = language.flower07[1]
        end
   
        score.text = data.score

        local sex = cache.PlayerCache:getSex()
        local giveBtn = obj:GetChild("n10")
        giveBtn.data = data 
        giveBtn.onClick:Add(self.onGiveFlower, self)
        --自己是男的看不见男榜的按钮
        local sex = cache.PlayerCache:getSex()
        if sex == 1 then
            giveBtn.visible = false
            obj:GetChild("n11").visible = false
        else
            giveBtn.visible = true
            obj:GetChild("n11").visible = true
        end
        local t = { level = data.level , roleIcon = data.roleIcon,roleId = data.roleId }
        roleBtn.data = index
        GBtnGongGongSuCai_050(roleBtn,t)
    else
        c1.selectedIndex = 1
        dec2.text = language.flower08
    end
end

function FlowerRank:onGiveFlower(context)
    cache.ActivityCache:setFlowerRankCome(true)--是从鲜花榜
    local data = context.sender.data
    local t = {roleId = data.roleId,roleName = data.roleName,isFriend = data.isFriend}--==0 不是好友
    mgr.ViewMgr:openView2(ViewName.MarrySongHuaView,t)
end



function FlowerRank:onClickAward()
    if not self.data then
        return
    end
    if self.data.msgId == 5030327 then
        mgr.ViewMgr:openView2(ViewName.RankAward,{myRank = self.data.myRank,actId = 5011})
    else
        mgr.ViewMgr:openView2(ViewName.RankAward,{myRank = self.data.myRank,actId = self.data.actId,pre = self.pre})
    end

end

function FlowerRank:onGetFlower()
    -- local flowerData = cache.PackCache:getPackDataById(materId)--显示要消耗的道具
    mgr.ViewMgr:openView2(ViewName.GetProView)
end
function FlowerRank:onTimer()
    if self.data.isShow and self.data.isShow == 1 then
        self.dec1.text = language.flower13
    else
        self.dec1.text = language.flower01
    end
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:onBtnClose()
    end

    self.time = self.time - 1
end

function FlowerRank:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end
function FlowerRank:onClickGuize()
    local data = cache.ActivityCache:get5030111()
    if (data.acts[1089] and data.acts[1089] == 1) or (data.acts[1090] and data.acts[1090] == 1) then
        GOpenRuleView(1093)
    elseif (data.acts[5003] and data.acts[5003] == 1) then
        GOpenRuleView(1127)
    elseif (data.acts[5011] and data.acts[5011] == 1) then
        GOpenRuleView(1144)
    end

end

function FlowerRank:onBtnClose()
    cache.ActivityCache:setFlowerRankCome(false)
    self:releaseTimer()
    self:closeView()
end

return FlowerRank