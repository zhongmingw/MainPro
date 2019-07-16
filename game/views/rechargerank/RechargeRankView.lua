--
-- Author: Your Name
-- Date: 2018-06-12 17:33:14
--

local RechargeRankView = class("RechargeRankView", base.BaseView)

local TITLEICON = {
    [1080] = "chongzhixiaofeibang_001",
    [1081] = "chongzhixiaofeibang_002",
    [1082] = "chongzhixiaofeibang_001",
    [1083] = "chongzhixiaofeibang_002",
    [1130] = "chongzhixiaofeibang_001",
    [1131] = "chongzhixiaofeibang_002",
}

function RechargeRankView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function RechargeRankView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n5")
    self:setCloseBtn(closeBtn)
    local guizeBtn = self.view:GetChild("n28")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    self.gotoBtn = self.view:GetChild("n22")
    self.gotoBtn.onClick:Add(self.onClickGoTo,self)
    self.modelPanel = self.view:GetChild("n27")
    self.huobanModelP = self.view:GetChild("n32")

    self.c1 = self.view:GetController("c1")

    self.awardListView = self.view:GetChild("n24")
    self.awardListView.numItems = 0
    self.awardListView.itemRenderer = function (index,obj)
        self:awardsCelldata(index, obj)
    end
    self.awardListView:SetVirtual()

    self.rankListView = self.view:GetChild("n23")
    self.rankListView.numItems = 0
    self.rankListView.itemRenderer = function (index,obj)
        self:rankCelldata(index, obj)
    end
    self.rankListView:SetVirtual()

    self.TitleIcon = self.view:GetChild("n0"):GetChild("icon")
    self.rankOneIcon = self.view:GetChild("n2")
    -- self.rankOneQuota = self.view:GetChild("n25")
    -- self.firstName = self.view:GetChild("n6")
    -- self.actDec = self.view:GetChild("n13")
    self.myRank = self.view:GetChild("n14")
    self.actTypeDec = self.view:GetChild("n11")
    self.goldNum = self.view:GetChild("n16")
    self.differenceValue = self.view:GetChild("n17")
    self.endTime = self.view:GetChild("n18")
    self.goldIcon = self.view:GetChild("n15")
    self.dec = self.view:GetChild("n21")
    self.pursueTxt = self.view:GetChild("n29")
    self.descendTxt = self.view:GetChild("n31")
    -- self.oneQuota = self.view:GetChild("n26")
    self.checkSuitBtn = self.view:GetChild("n33")
    self.checkSuitBtn.onClick:Add(self.onClickCheck,self)

    self.lastRankBtn = self.view:GetChild("n34")
    self.lastRankBtn.onClick:Add(self.onClickLastRank,self)

    self.anim = self.view:GetTransition("t0")
end

function RechargeRankView:initData(data)
    printt("充值消费排行数据",data)
    self.actId = data.actId
    self.ranking = data.ranking
    self.actDay = data.actDay
    self.goldNum.text = data.quota

    if data.myRank > 0 then
        self.myRank.text = data.myRank
    else
        self.myRank.text = language.rechargeRank10
    end
    self.TitleIcon.url = UIPackage.GetItemURL("rechargerank" ,TITLEICON[self.actId])
    self.goldIcon.url = UIItemRes.moneyIcons[MoneyType.gold]
    if self:isRechargeRank(self.actId) then--充值排行
        self.gotoBtn:GetChild("title").text = language.rechargeRank13
        -- self.actDec.text = language.rechargeRank01
        self.actTypeDec.text = language.rechargeRank04
        self.dec.text = language.rechargeRank08
        -- self.rankOneQuota.text = language.rechargeRank04
    else--消费排行
        self.gotoBtn:GetChild("title").text = language.rechargeRank14
        -- self.actDec.text = language.rechargeRank02
        self.actTypeDec.text = language.rechargeRank05
        self.dec.text = language.rechargeRank09
        -- self.rankOneQuota.text = language.rechargeRank05
    end
    local textData = clone(language.rechargeRank07)
    
    self.differenceValue.visible = true
    self.pursueTxt.visible = false
    self.descendTxt.visible = false
    local rechargeNum = conf.ActivityConf:getValue("recharge_quota_limit")
    textData[1].text = string.format(language.rechargeRank07[1].text,language.rechargeRank16)
    if not self:isRechargeRank(self.actId) then
        rechargeNum = conf.ActivityConf:getValue("cost_quota_limit")
        textData[1].text = string.format(language.rechargeRank07[1].text,language.rechargeRank17)
    end
    textData[2].text = string.format(language.rechargeRank07[2].text,rechargeNum)
    textData[3].text = string.format(language.rechargeRank07[3].text,language.rechargeRank11)
    self.differenceValue.text = mgr.TextMgr:getTextByTable(textData)
    self.c1.selectedIndex = 1
    if data.myRank > 0 and data.myRank ~= 1 then--自己已有排名时
        self.pursueTxt.visible = true
        self.descendTxt.visible = true
        local textData2 = clone(language.rechargeRank07_1)
        local diff = self.ranking[data.myRank-1].quota - data.quota +1
        -- if diff == 0 then diff = 1 end
        textData2[2].text = string.format(language.rechargeRank07_1[2].text,diff)
        textData2[3].text = string.format(language.rechargeRank07_1[3].text,language.rechargeRank12)
        self.pursueTxt.text = mgr.TextMgr:getTextByTable(textData2)
        local textData3 = clone(language.rechargeRank07_1)
        local diff2 = data.quota - data.nextQuota + 1
        -- if diff2 == 0 then diff2 = 1 end
        textData3[2].text = string.format(language.rechargeRank07_1[2].text,diff2)
        textData3[3].text = string.format(language.rechargeRank07_1[3].text,language.rechargeRank12_1)
        self.descendTxt.text = mgr.TextMgr:getTextByTable(textData3)
        self.c1.selectedIndex = 0
    elseif data.myRank == 1 then--自己排名第一时
        self.pursueTxt.visible = true
        local textData3 = clone(language.rechargeRank07_1)
        local diff = data.quota - data.nextQuota + 1
        textData3[2].text = string.format(language.rechargeRank07_1[2].text,diff)
        textData3[3].text = string.format(language.rechargeRank07_1[3].text,language.rechargeRank12_1)
        self.pursueTxt.text = mgr.TextMgr:getTextByTable(textData3)
    else
        local diff = rechargeNum - data.quota
        local textData3 = clone(language.rechargeRank07_1)
        if #self.ranking >= 10 then
            diff = self.ranking[#self.ranking].quota - data.quota +1
            textData3[3].text = string.format(textData3[3].text,language.rechargeRank11_1)
        else
            textData3[3].text = string.format(textData3[3].text,language.rechargeRank11)
        end
        textData3[2].text = string.format(textData3[2].text,(diff))
        self.pursueTxt.visible = true
        self.pursueTxt.text = mgr.TextMgr:getTextByTable(textData3)
        if data.quota < rechargeNum then
            self.pursueTxt.visible = false
        end
    end

    --活动倒计时
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.timer = self:addTimer(1,-1,handler(self, self.onTimer))
    self.lastTime = data.lastTime
    self.endTime.text = GTotimeString(self.lastTime)
    if data.isShow == 1 then
        self.view:GetChild("n12").text = language.powerRanking04[1] .. ":"
    else
        self.view:GetChild("n12").text = language.powerRanking04[2] .. ":"
    end
    --排行榜
    self.rankListView.numItems = 10
    --奖励列表
    self.awardsData = conf.ActivityConf:getCostAwardsById(self.actId,self.actDay)
    self.awardListView.numItems = #self.awardsData

    if self.awardsData[1] and self.awardsData[1].show_mid then
        self:initModel(self.awardsData[1].show_mid)
    end
    --设置模型
    -- 10018001    血源狂神·机甲 1
    -- 10018002    血源狂神·光刃 1
    -- 10018003    血源狂神·机甲 2
    -- 10018004    血源狂神·光刃 2

    -- local skin = {
    --     [1] = 10018001,
    --     [2] = 10018003,
    -- }
    -- local wuqi = {
    --     [1] = 10018002,
    --     [2] = 10018004,
    -- }
    -- local sex = cache.PlayerCache:getSex()
    -- local modelData = conf.RoleConf:getFashData(skin[sex])
    -- local modelObj = self:addModel(modelData.model,self.modelPanel)
    -- local wuqiData = conf.RoleConf:getFashData(wuqi[sex])
    -- modelObj:setSkins(nil,wuqiData.model)
    -- if sex == 1 then
    --     modelObj:setRotationXYZ(0,150,0)
    --     modelObj:setPosition(50,-400,800)
    -- else
    --     modelObj:setRotationXYZ(0,150,0)
    --     modelObj:setPosition(50,-400,800)
    -- end
    -- modelObj:setScale(160)

    -- -- self.huobanModelP

    -- -- local modelData = conf.HuobanConf:getSkinsByModel(1001012,0)
    -- local huobanModelObj = self:addModel(3050304,self.huobanModelP)
    -- huobanModelObj:setSkins(nil,4040797)

    -- huobanModelObj:setRotationXYZ(0,150,0)
    -- huobanModelObj:setPosition(50,-400,800)
    -- huobanModelObj:setScale(150)
end

--模型展示页面
function RechargeRankView:initModel(mid)
    -- body
    local canFloat = conf.ItemConf:getIsCanFloat(mid) --是否有浮动效果
    if canFloat then 
        self.anim:Play()
    else
        -- print("AAAAAAAAAAA")
        self.anim:Stop()
    end 
    if type(mid) == "table" then
        local sex = cache.PlayerCache:getSex()
        mid = mid[sex]
    end
    local sex = 1
    local sexCloth = conf.ItemConf:getSuitmodel(mid)
    if #sexCloth == 2 then
        local roleIcon = cache.PlayerCache:getRoleIcon()
        sex = GGetMsgByRoleIcon(roleIcon).sex--性别
    end

    local skin_oldShow = conf.ItemConf:getSuitmodel(mid)[sex]  --读取suitshow的第一个模型
    local suitTransform = conf.ItemConf:getSuitTransformDataById(mid)

    local a = suitTransform[1]
    local b = suitTransform[2]
    local c = suitTransform[3]


    -- plog("当前模型ID为：",self.data.mid)
    --self:addModel
    if not skin_oldShow then
        return
    end
    if skin_oldShow[2] == 1 and suitTransform then --模型
        if skin_oldShow[3] then 
            if skin_oldShow[3] == 1 then
                self.model = self:addModel(GuDingmodel[1],self.modelPanel)
            else
                self.model = self:addModel(GuDingmodel[2],self.modelPanel)
            end
            self.model:setSkins(nil,nil,skin_oldShow[1])

        elseif tonumber(string.sub(skin_oldShow[1],1,1)) == 6 then--剑神道具
            local buffId = skin_oldShow[1]
            local buffConf = conf.BuffConf:getBuffConf(buffId)
            if buffConf.bs_args then
                self.model = self:addModel(buffConf.bs_args[1],self.modelPanel)
                self.model:setSkins(nil,buffConf.bs_args[2],buffConf.bs_args[3])
            end
        else
            local needModel = conf.ItemConf:getIsNeedModel(mid) --是否需要模特载体
            if needModel then 
                local body 
                if needModel == 1 then  --常规
                    body = cache.PlayerCache:getSkins(Skins.clothes)--衣服载体
                elseif needModel == 2 then --需要男模
                    body = 3010101
                elseif needModel == 3 then --需要女模
                    body = 3010201
                end
              
                self.model = self:addModel(body, self.modelPanel)
                self.model:setSkins(nil, skin_oldShow[1], nil) --添加需要展示的武器
            else
                self.model = self:addModel(skin_oldShow[1],self.modelPanel)
            end 
        end

        -- self.model:setPosition(self.modelPanel.actualWidth/2,-self.modelPanel.actualHeight-200,100)
        -- self.model:setRotationXYZ(0,100,0)
        -- self.model:setScale(100)
        if a and b and c then 
            self.model:setPosition(a[1],a[2],a[3])
            self.model:setRotationXYZ(b[1],b[2],b[3])
            self.model:setScale(c[1]*0.8)
        end  
               
    else --特效
        if skin_oldShow[3] then 
            local useid 
            if skin_oldShow[3] == 1 then
                useid =  cache.PlayerCache:getSkins(Skins.wuqi)
                if useid == 0 then
                    useid = GuDingmodel[3]
                end
            else
                useid = GuDingmodel[2]
            end
            self.model = self:addModel(useid, self.modelPanel) 
     
            if a and b and c then 
                self.model:setPosition(a[1],a[2],a[3])
                self.model:setRotationXYZ(b[1],b[2],b[3])
                self.model:setScale(c[1]*0.8)
            end
            
            --添加神兵特效
            if skin_oldShow[3] == 1 then
                self.model:addModelEct(skin_oldShow[1].."_ui")
            else
                self.model:addWeaponEct(skin_oldShow[1].."_ui")
            end
                      
        else
            if a and c then
                self.model = self:addEffect(skin_oldShow[1],self.modelPanel)
                if self.model then 
                    self.model.LocalPosition = Vector3(a[1],a[2],a[3])
                    self.model.Scale = Vector3.New(c[1]*0.8,c[2]*0.8,c[3]*0.8)
                    -- plog("牛耕田")
                else
                    plog("@策划，当前特效不存在！",skin_oldShow[1])
                end 
            end
        end
    end

end
--
function RechargeRankView:onTimer()
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        self.endTime.text = GTotimeString(self.lastTime)
    else
        proxy.ActivityProxy:sendMsg(1030186,{actId = self.actId,reqType = 0})
        self.endTime.text = GTotimeString(0)
    end
end

function RechargeRankView:rankCelldata(index,obj)
    local data = self.ranking[index+1]
    local bgImg = obj:GetChild("n0")
    local rankIcon = obj:GetChild("n1")
    local rankTxt = obj:GetChild("n2")
    local nameTxt = obj:GetChild("n3")
    local quotaTxt = obj:GetChild("n4")
    rankIcon.visible = true
    if index == 0 then
        bgImg.url = UIPackage.GetItemURL("_panels" , "meili_008")
        rankIcon.url = UIPackage.GetItemURL("_others" , "meili_003")
    elseif index == 1 then
        bgImg.url = UIPackage.GetItemURL("_panels" , "meili_009")
        rankIcon.url = UIPackage.GetItemURL("_others" , "meili_004")
    elseif index == 2 then
        bgImg.url = UIPackage.GetItemURL("_panels" , "meili_010")
        rankIcon.url = UIPackage.GetItemURL("_others" , "meili_005")
    else
        bgImg.url = UIPackage.GetItemURL("_others" , "ditu_004")
        rankIcon.visible = false
    end
    if data then
        rankTxt.text = data.rank
        nameTxt.text = data.name
        quotaTxt.text = data.quota
        quotaTxt.visible = true
    else
        rankTxt.text = index+1
        nameTxt.text = language.rank03
        quotaTxt.visible = false
    end
    quotaTxt.visible = false --屏蔽充值数量
end

function RechargeRankView:awardsCelldata(index,obj)
    local data = self.awardsData[index+1]
    if data then
        local rankTxt = obj:GetChild("n3")
        local listView = obj:GetChild("n4")
        local rank = data.ranking
        if rank[1] == rank[2] then
            rankTxt.text = string.format(language.kaifu12,rank[1])
        elseif rank[2] > 11 then
            rankTxt.text = language.rechargeRank15
        else
            rankTxt.text = string.format(language.kaifu11,rank[1],rank[2])
        end
        local sex = cache.PlayerCache:getSex()
        if sex == 1 then
            GSetAwards(listView,data.awards)
        else
            GSetAwards(listView,data.awards_1)
        end
    end
end

function RechargeRankView:onClickGoTo()
    if self:isRechargeRank(self.actId) then
        GOpenView({id = 1042})
    else
        GOpenView({id = 1043})
    end
end

--充值排行还是消费排行
function RechargeRankView:isRechargeRank(actId)
    if actId == 1080 or actId == 1082 or actId == 1130 then
        return true
    end
    return false
end

function RechargeRankView:onClickGuize()
    if self:isRechargeRank(self.actId) then
        GOpenRuleView(1087)
    else
        GOpenRuleView(1088)
    end
end

function RechargeRankView:onClickCheck()
    local param = {}
    param.id = 1109
    param.childIndex = 12
    GOpenView(param)
end

function RechargeRankView:onClickLastRank()
    local t = {
        [1080] = 1081,
        [1081] = 1080,
        [1082] = 1083,
        [1083] = 1082,
        [1130] = 1130,
        [1131] = 1131,
    }
    if self.actId then
        local lastActId = t[self.actId]
        proxy.ActivityProxy:sendMsg(1030186,{actId = lastActId,reqType = 1})
    end
end

return RechargeRankView