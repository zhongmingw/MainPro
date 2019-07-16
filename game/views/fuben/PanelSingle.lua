--
-- Author: wx
-- Date: 2017-10-21 15:19:13
--

local PanelSingle = class("PanelSingle",import("game.base.Ref"))

function PanelSingle:ctor(param)
    self.parent = param
    self.view = param:getChoosePanelObj(1130)
    self.leftCd = 0
    self:initView()
end

function PanelSingle:initView()
    self.fightCdTime = 0--记录组队挑战冷却时间
    self.bgurl = self.view:GetChild("n2")
    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2") --EVE 组队和单人按钮区别
    self.c3 = self.view:GetController("c3") --是否有cd时间
    self.titleImg = self.view:GetChild("n7")--文字标题
    local btnRank = self.view:GetChild("n9")
    self.btnRank = btnRank
    btnRank.title = language.fuben128
    btnRank.onClick:Add(self.onRankCall,self)

    local btnChange = self.view:GetChild("n14")
    btnChange.onClick:Add(self.onFightCall,self)

    local btnChange2 = self.view:GetChild("n23")   --EVE 开启组队
    btnChange2.onClick:Add(self.onFightCall,self)
    local btnGoOn = self.view:GetChild("n22")      --EVE 进入副本（组队时候）
    btnGoOn.onClick:Add(self.onGoOn,self)

    local btnOneKey = self.view:GetChild("n16") 
    btnOneKey.onClick:Add(self.onFightOneKeyCall,self)
    self.btnOneKey = btnOneKey
    --self.btnOneKey:SetScale(0,0)  --EVE 屏蔽扫荡

    local btnPlus = self.view:GetChild("n12")
    btnPlus.onClick:Add(self.onPlusCall,self)

    local btnGuize = self.view:GetChild("n5")
    btnGuize.onClick:Add(self.onRuleCall,self)

    self.curCount = self.view:GetChild("n11")
    self.curCount.text = "0"

    self.listView = self.view:GetChild("n4")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0
    --self.listView.onClickItem:Add(self.onClickItem,self)
    self.view:GetChild("n6").text = language.fuben129
    self.view:GetChild("n10").text = language.fuben130
    self.view:GetChild("n13").text = ""--language.fuben200
    self.view:GetChild("n13"):SetSize(200,200)

    self.lvText = self.view:GetChild("n21")
    self.ruleText = self.view:GetChild("n20")

    --EVE 策划要求修改规则文字的位置
    self.tempPos = self.view:GetChild("n20")
    self.saveY = self.tempPos.y
    self.tempPos2 = self.view:GetChild("n21")
    self.saveY2 = self.tempPos2.y
    self.tempPos3 = self.view:GetChild("n17")
    self.saveY3 = self.tempPos3.y
    self.tempPos4 = self.view:GetChild("n19")
    self.saveY4 = self.tempPos4.y

    self.doubleImg = self.view:GetChild("n24")
    --bxp勾选双倍奖励按钮
    self.radioBtn = self.view:GetChild("n25")
    self.radioBtn.onClick:Add(self.onChooseSelect,self)
    --秘境修炼cd时间
    local closeCdbtn = self.view:GetChild("n27")
    closeCdbtn.onClick:Add(self.onCloseCd,self)
    self.leftCdText = self.view:GetChild("n28")
end

function PanelSingle:getComByName(var)
    -- body
    return self.view:GetChild(var)
end

function PanelSingle:onChooseSelect ()
    local roleLv = cache.PlayerCache:getRoleLevel()
    if self.modelId == 1132 then  --秘境修炼
        local openLv = conf.FubenConf:getValue("fam_openLv")
        if self.data.todayLeftCount <= 1 then 
            GComAlter(language.fuben207)
            self.radioBtn.selected = false
            return
        elseif roleLv < openLv then
            GComAlter(string.format(language.fuben205,openLv))
            self.radioBtn.selected = false
            return
        else
            if self.radioBtn.selected then 
                local param = {}
                param.type = 5
                param.richtext = mgr.TextMgr:getTextColorStr(language.fuben206, 6)
                param.titleIcon = UIItemRes.fuben11
                GComAlter(param) 
            end
        end 
        cache.FubenCache:setMjxlDouble(self.radioBtn.selected)
    elseif self.modelId == 1130 then
        local openLv = conf.FubenConf:getValue("xylt_openLv")

        if self.radioBtn.selected then 
            if roleLv < openLv then
                GComAlter(string.format(language.fuben205,openLv))
                self.radioBtn.selected = false
                return
            elseif self.data.todayLeftCount <= 1 then
                self.radioBtn.selected = false
                GComAlter(language.fuben207)
                return
            end
            --2次窗口
            local param = {}
            param.type = 5  
            param.sure = function()
                -- body
                proxy.FubenProxy:send(1027205,{reqType = 1})
            end
            param.cancel = function ()
                self.radioBtn.selected = false
            end
            param.richtext = mgr.TextMgr:getTextColorStr(language.fuben206, 6)
            param.titleIcon = UIItemRes.fuben11
            GComAlter(param)
        else
            proxy.FubenProxy:send(1027205,{reqType = 1})
        end

        
    end
end

--EVE 组队模式时的进入按钮
function PanelSingle:onGoOn()
    local teamSize = cache.TeamCache:getTeamMemberNum() --获取队伍人数
    -- print("当前组队情况：",teamSize)
    local curLv = cache.PlayerCache:getRoleLevel()

    if self.lv > curLv then 
        --等级不足
        return GComAlter(language.fuben163)
    elseif self.data.todayLeftCount <= 0 then
        --挑战次数不足
        GComAlter(language.fuben167)
        return     
    elseif teamSize == 0 then 
        --没组队
        GComAlter(language.team23)
        return
    elseif not cache.TeamCache:getIsCaptain(cache.PlayerCache:getRoleId()) then
        --不是队长
        GComAlter(language.team50)
        return
    end
    local sceneData = conf.SceneConf:getSceneById(Fuben.hjzy)
    local targetId = sceneData and sceneData.team_target or 0
    local confData = conf.TeamConf:getTeamConfig(targetId)
    local cdTime = confData and confData.cd_time or 0--冷却时间
    if Time.getTime() - self.fightCdTime < cdTime then
        GComAlter(language.team66)
        return
    end
    local callback = function()
        proxy.FubenProxy:send(1027305,{sceneId = Fuben.hjzy,reqType = 1})
    end
    if cache.TeamCache:getTeamMemberNum() < 3 then
        local param = {}
        param.type = 2
        param.richtext = language.gonggong103
        param.sure = function()
            callback()
        end
        GComAlter(param)
    else
        callback()
    end
    self.fightCdTime = Time.getTime()
end

function PanelSingle:setModelId(id)
    self.modelId = id
    self.reward = {}
    local condata
    self.btnOneKey.visible = false
    local ruleId = 1050
    self.btnRank.visible = false
    if id == 1130 then  --单人守塔
        self.btnOneKey.icon = UIPackage.GetItemURL("fuben" , "jinjiefuben_015")  --扫荡
        self.bgurl.url = UIItemRes.fuebenImg.."xianyulingta_002"
        self.btnOneKey.visible = true -- 单人守塔有扫荡

        condata = conf.SceneConf:getSceneById(Fuben.xianyulingta)
        self.titleImg.url = UIItemRes.fuben06
        ruleId = 1050
        self.c1.selectedIndex = 0
        self.c2.selectedIndex = 0
        self.btnRank.visible = true
        self.view:GetChild("n13").text = language.fuben200

        self.radioBtn.visible = true
        self.radioBtn.selected = false-- self.data.doubleCost == 1


    elseif id == 1132 then --单人刷波
        self.bgurl.url = UIItemRes.hjzyBg --UIItemRes.mjxlBg
        self.titleImg.url = UIItemRes.fuben05
        condata = conf.SceneConf:getSceneById(Fuben.mjxl)
        ruleId = 1051
        self.c1.selectedIndex = 1
        self.c2.selectedIndex = 0
        self.view:GetChild("n13").text = language.fuben200

        self.radioBtn.visible = true --bxp  秘境修炼增加勾选合并次数功能
        self.radioBtn.selected = false
        cache.FubenCache:setMjxlDouble(self.radioBtn.selected)
    elseif id == 1133 then --组队刷波
        -- self.btnOneKey.visible = true
        self.btnOneKey.icon = UIPackage.GetItemURL("fuben" , "jinjiefuben_015")--进入副本
        self.bgurl.url = UIItemRes.hjzyBg
        self.titleImg.url = UIItemRes.fuben07
        condata = conf.SceneConf:getSceneById(Fuben.mjxl)
        ruleId = 1053
        self.c1.selectedIndex = 0
        self.c2.selectedIndex = 1
        self.view:GetChild("n13").text = ""--language.fuben200

        self.radioBtn.visible = false

    end
    if cache.ActivityCache:get5030168(id) then
        self.doubleImg.visible = true
    else
        self.doubleImg.visible = false
    end
    if condata and condata.normal_drop then
        self.reward = condata.normal_drop
    end
    self.listView.numItems = #self.reward
    --显示等级和规则
    local modData = conf.SysConf:getModuleById(id)
    local lv = modData and modData.open_lev or 0
    self.lvText.text = lv..language.fuben198
    local confRule = conf.RuleConf:getRuleById(ruleId)
    local ruleDesc = confRule.desc
    self.ruleText.text = ruleDesc[2][1][3]

    if id == 1133 then
        self.lv = lv
    end  

    if id == 1132 or id == 1130 then 
        self.tempPos.y = self.saveY + 22      --EVE 设置规则文档的显示位置
        self.tempPos2.y = self.saveY2 + 22
        self.tempPos3.y = self.saveY3 + 22
        self.tempPos4.y = self.saveY4 + 22
        if id == 1130 then 
            self.view:GetChild("n13").x = 634
            self.view:GetChild("n13").y = 464
            self.radioBtn.x = 599
            self.radioBtn.y = 459
        elseif id == 1132 then 
            self.view:GetChild("n13").x = 754
            self.view:GetChild("n13").y = 464
            self.radioBtn.x = 719
            self.radioBtn.y = 459
        end
    else
        self.tempPos.y = self.saveY
        self.tempPos2.y = self.saveY2
        self.tempPos3.y = self.saveY3
        self.tempPos4.y = self.saveY4
        self.view:GetChild("n13").x = 754
        self.view:GetChild("n13").y = 464
        self.radioBtn.x = 719
        self.radioBtn.y = 459
    end
end


function PanelSingle:cellData(index, obj)
    -- body
    local data = self.reward[index+1]
    local _t = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj,_t,true)
end

function PanelSingle:onRankCall()
    -- body
    if not self.data then
        return
    end
    mgr.ViewMgr:openView2(ViewName.TowerRankView,{module_id = self.modelId,data = self.data})
end

function PanelSingle:onPlusCall()
    -- body
    if not self.data then
        return
    end
    if self.data.todayLeftBuyCount == 0 then
        local isGoto = false
        local str = ""
        local isHj = cache.PlayerCache:VipIsActivate(2)
        local isZs = cache.PlayerCache:VipIsActivate(3)
        if self.modelId == 1130 
            or self.modelId == 1131 
            or self.modelId == 1132  then
            if not isHj and not isZs then
                isGoto = true
                str = language.fuben160
            elseif not isHj then
                isGoto = true
                str = language.fuben158
            elseif not isZs then
                isGoto = true
                str = language.fuben159
            else
                GComAlter(language.fuben151)
            end
        elseif self.modelId == 1133 then
            if not isZs then
                isGoto = true
                str = language.fuben159
            else
                GComAlter(language.fuben151)
            end
        end
        if isGoto then
            local param = {type = 14,richtext = mgr.TextMgr:getTextColorStr(str, 6),sure = function()
                GOpenView({id = 1050})
            end}
            GComAlter(param)
        end
        return
    end

    local param = {}
    param.type = 16
    param.module_id = self.modelId
    if self.modelId == 1130 then
        local condata = conf.FubenConf:getTaFangValue("xylt_buy_cost")
        param.price = condata[2] --次数购买价格
    elseif self.modelId == 1132 then
        local condata = conf.FubenConf:getValue("fam_fuben_buy_price")
        param.price = condata[1] --次数购买价格
    elseif self.modelId == 1133 then
        local condata = conf.FubenConf:getValue("hjzy_fuben_buy_price")
        param.price = condata[1] --次数购买价格
    end
    param.max = self.data.todayLeftBuyCount
    param.sure = function(count)
        if count > self.data.todayLeftBuyCount then
            GComAlter(string.format(language.fuben152,self.data.todayLeftBuyCount))
            return
        end
        if self.modelId == 1130 then
            if count + self.data.todayLeftCount > (conf.FubenConf:getTaFangValue("xylt_max_count") or 0) then
                GComAlter(language.fuben154)
                return
            end
            local data = {}
            data.count = count
            proxy.FubenProxy:send(1027202,data)
        elseif self.modelId == 1132 then
            local data = {}
            data.count = count
            proxy.FubenProxy:send(1027302,data)
        elseif self.modelId == 1133 then
            local data = {}
            data.count = count
            proxy.FubenProxy:send(1027306,data)
        end
    end
    GComAlter(param)
end

function PanelSingle:onFightCall()
    -- body
    if not self.data then
        return
    end
    local sceneId = 0
    if self.modelId == 1130 then
        sceneId = Fuben.xianyulingta  
        if self.data.todayLeftCount <= 0 then
            GComAlter(language.fuben155)
            return
        end
    elseif self.modelId == 1132 then
        sceneId = Fuben.mjxl
    elseif self.modelId == 1133 then
        if self.data.todayLeftCount <= 0 then
            GComAlter(language.fuben167)
        else
            mgr.ViewMgr:openView2(ViewName.TeamView, {targetSceneId = Fuben.hjzy})
        end
        return
    end
    if mgr.FubenMgr:checkScene() then
        GComAlter(language.gonggong41)
        return
    end
    if self.leftCd > 0 then
        GComAlter(language.fuben223)
        return 
    end
    if cache.FubenCache:getMjxlDouble() and self.modelId == 1132 then --秘境修炼勾选了合并次数bxp
        mgr.FubenMgr:gotoFubenWar(sceneId,-1)
    else
        mgr.FubenMgr:gotoFubenWar(sceneId)
    end
end

function PanelSingle:onFightOneKeyCall()
    -- body
    if not self.data then
        return
    end
    -- printt(self.data)
    local sceneId = 0
    if self.modelId == 1130 then
        sceneId = Fuben.xianyulingta   --EVE 仙域灵塔扫荡请求（需改）
        local fubenGlobalBo = conf.FubenConf:getValue("xylt_max_bo") --最大波数
        local fubenSdDian = conf.FubenConf:getValue("xylt_sd_bo_dian") --副本扫荡点的个数
        --print("闯过的最大波数是"..self.data.maxRecordBo)
        for i=1,fubenSdDian do
            passId = Fuben.xianyulingta * 1000 + i
            local sweepData = conf.FubenConf:getFubenSweepCost(passId)
            if sweepData then
                local roleLev = cache.PlayerCache:getRoleLevel()
                if roleLev < sweepData.lev then -- 等级不够
                    GComAlter(language.fuben195)
                    break
                elseif self.data.todayLeftCount <= 0 then --挑战次数用完
                    GComAlter(language.fuben155)
                    break
                elseif self.data.maxRecordBo == fubenGlobalBo then --达到最大波数
                    proxy.FubenProxy:send(1027405,{sceneId = sceneId})
                    break
                elseif  self.data.maxRecordBo >= sweepData.bo and self.data.maxRecordBo < fubenGlobalBo then -- 达到最低波数
                    self.data.reqType = 0
                    mgr.ViewMgr:openView2(ViewName.Alert19,self.data)
                    break
                else 
                    local info = string.format(language.fuben192,sweepData.bo)
                    GComAlter(info)
                    break
                end
            end
        end
        return
    elseif self.modelId == 1133 then
        sceneId = Fuben.hjzy
        if cache.TeamCache:getTeamId() == 0 then
            --没有队伍
            GComAlter(language.team23)
            return
        elseif not cache.TeamCache:getIsCaptain(cache.PlayerCache:getRoleId()) then
            GComAlter(language.team50)
            return
        end
        local sceneConfig = conf.SceneConf:getSceneById(sceneId)
        local lvl = sceneConfig and sceneConfig.lvl or 1
        local playLv = cache.PlayerCache:getRoleLevel()
        if playLv < lvl then
            GComAlter(string.format(language.gonggong07, lvl))
            return
        end
        local callback = function()
            proxy.FubenProxy:send(1027305,{sceneId = sceneId,reqType = 1})
        end
        if cache.TeamCache:getTeamMemberNum() < 3 then
            local param = {}
            param.type = 2
            param.richtext = language.gonggong103
            param.sure = function()
                callback()
            end
            GComAlter(param)
        else
            callback()
        end
        return
    end
    mgr.FubenMgr:gotoFubenWar(sceneId,0)
end

function PanelSingle:onRuleCall()
    if self.modelId == 1130 then
        GOpenRuleView(1050)
    elseif self.modelId == 1132 then
        GOpenRuleView(1051)
    elseif self.modelId == 1133 then
        GOpenRuleView(1053)
    end
end

function PanelSingle:addMsgCallBack(data)
    if data.msgId == 5027201 or data.msgId == 5027301 or data.msgId == 5027309 then
        self.data = data
        if 5027201 == data.msgId then
            self.radioBtn.selected = self.data.doubleCost == 1
        end
        self.leftCd = data.leftCd or 0
        if self.leftCd <= 0 then
            self.c3.selectedIndex = 0
        else
            self.c3.selectedIndex = 1
            self.leftCdText.text = language.fuben222..GTotimeString3(self.leftCd)
        end
    elseif data.msgId == 5027202 or data.msgId == 5027302 or data.msgId == 5027306 then
        --data.count 次数
        self.data.todayLeftCount = data.todayLeftCount
        self.data.todayLeftBuyCount = data.todayLeftBuyCount
    elseif data.msgId == 5027205 then 
        self.data.doubleCost = data.doubleCost

        self.radioBtn.selected = self.data.doubleCost == 1
        
    end
    --剩余挑战次数
    self.curCount.text = self.data.todayLeftCount
    self:refreshRed()
end

function PanelSingle:refreshRed()
    if self.data.todayLeftCount <= 0 then--红点
        if self.modelId == 1130 then
            mgr.GuiMgr:redpointByVar(attConst.A50115,0)
        elseif self.modelId == 1132 then
            mgr.GuiMgr:redpointByVar(attConst.A50113,0)
        elseif self.modelId == 1133 then
            mgr.GuiMgr:redpointByVar(attConst.A50114,0)
        end
    else
        if self.modelId == 1130 then
            mgr.GuiMgr:redpointByVar(attConst.A50115,1)
        elseif self.modelId == 1132 then
            mgr.GuiMgr:redpointByVar(attConst.A50113,1)
        elseif self.modelId == 1133 then
            mgr.GuiMgr:redpointByVar(attConst.A50114,1)
        end
    end
end
--cd时间
function PanelSingle:onTimer()
    if self.leftCd < 0 then
        return
    end
    if self.leftCd == 0 then
        self.c3.selectedIndex = 0
    end
    self.leftCdText.text = language.fuben222..GTotimeString3(self.leftCd)
    self.leftCd = self.leftCd - 1
end

function PanelSingle:onCloseCd()
    local param = {type = 14,richtext = mgr.TextMgr:getTextByTable(language.fuben221),sure = function()
        proxy.TeamProxy:send(1027310)
        self.c3.selectedIndex = 0
        self.leftCd = 0
    end}
    GComAlter(param)
end

function PanelSingle:clear()
    self.leftCd = 0
    self.bgurl.url = ""
end

return PanelSingle