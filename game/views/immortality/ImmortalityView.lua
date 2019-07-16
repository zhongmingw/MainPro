--修仙
local ImmortalityView = class("ImmortalityView",base.BaseView)

function ImmortalityView:ctor()
    self.super.ctor(self)
    self.type = 1
end

function ImmortalityView:initData()
    -- body
    local window2 = self.view:GetChild("n0")
    GSetMoneyPanel(window2,self:viewName())
    local closeBtn = window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)
    local isvip3 = cache.PlayerCache:VipIsActivate(3)
    local bgImg = self.view:GetChild("n17")

    local width = 0
    if isvip3  then
        self.xianzunBtn.visible = false
        self.xianzunDec.text = language.xiuxian24 .. language.zuoqi62
    else
        self.xianzunBtn.visible = true 
        self.xianzunDec.text = language.xiuxian24
        width = width + self.xianzunBtn.width
    end
    width = self.xianzunDec.width  + width
    local offx = (bgImg.width - width)/2
    self.xianzunDec.x = bgImg.x + offx

    self.is10 = true
    self.c2.selectedIndex = 0
    self.super.initData()
end

function ImmortalityView:initView()
    self.attList = {} --属性加成
    self.awardsList = {} --升级奖励
    self.activeAwards = {} --活跃度奖励
    for i=30,35 do
        local text = self.view:GetChild("n"..i)
        text.text = ""
        table.insert(self.attList,text)
    end
    for i=40,43 do
        local awardItem = self.view:GetChild("n"..i)
        awardItem.visible = false
        table.insert(self.awardsList,awardItem)
    end
    for i=44,47 do
        local awardItem = self.view:GetChild("n"..i)
        table.insert(self.activeAwards,awardItem)
    end
    --升级进度条
    self.expBar = self.view:GetChild("n23")
    self.expBar.visible = false
    --升级按钮
    self.lvUpBtn = self.view:GetChild("n22")
    self.lvUpBtn.onClick:Add(self.onClickLvUp,self)
    --活跃奖励领取按钮
    self.actGetBtn = self.view:GetChild("n15")
    self.actGetBtn.grayed = true
    self.actGetBtn.touchable = false
    self.actGetBtn.onClick:Add(self.onClickGetAwards,self)
    --活跃度进度条
    self.activeBar = self.view:GetChild("n9")
    self.activeBar.visible = false
    self.listView = self.view:GetChild("n3")
    --星星控制器
    self.xingxing = self.view:GetChild("n95")
    
    self.effectmodel = self.view:GetChild("neffect")
    self.effectmodel.data = self.effectmodel.x
    self:initListView()
    --阶别切换按钮
    self.btnLeft = self.view:GetChild("n55")
    self.btnLeft.onClick:Add(self.onClickLeft,self)
    self.btnRight = self.view:GetChild("n56")
    self.btnRight.onClick:Add(self.onClickRight,self)

    self.c2 =  self.view:GetController("c2")

    self.periodImg = self.view:GetChild("n101")
    self.xianzunDec = self.view:GetChild("n103")
    self.xianzunBtn = self.view:GetChild("n102")
    self.xianzunBtn.onClick:Add(self.onXianzunBtn,self)
end
function ImmortalityView:onXianzunBtn()
    GGoVipTequan(2,2)
end
--左按钮
function ImmortalityView:onClickLeft( context )
    -- body
    self.lv = (self.lv - 10)<0 and 0 or (self.lv - 10)
    self.is10 = true
    self:setSrcInfo()
end
--右按钮
function ImmortalityView:onClickRight( context )
    -- body
    local attrConfData = conf.ImmortalityConf:getAttrData()
    local len = #attrConfData - 1
    self.lv = (self.lv + 10)>len and len or (self.lv + 10)
    self.is10 = true
    self:setSrcInfo()
end

--设置图标信息
function ImmortalityView:setSrcInfo()
    local attrConf = conf.ImmortalityConf:getAttrDataByLv(self.lv)
    local nowAttZConf = conf.ImmortalityConf:getAttrDataByLv(self.data.level)
    -- print("等级",self.lv,self.data.level,attrConf)
    local orderIcon = self.view:GetChild("n82")
    local signIcon = self.view:GetChild("n83")
    if attrConf then
        orderIcon.url = UIPackage.GetItemURL("immortality" , "huoban_0"..(string.format("%02d",attrConf.step)))
        signIcon.url = UIPackage.GetItemURL("immortality" , attrConf.pic)
        local name = self.view:GetChild("n52")
        name.text = attrConf.name or language.xiuxian09
        self.view:GetChild("n39").visible = false
        -- print("阶段，时期",attrConf.step,nowAttZConf.step,attrConf.period,nowAttZConf.period)
        if attrConf.step > nowAttZConf.step then
            self.view:GetChild("n39").text = language.xiuxian05
            self.xingxing:GetController("c1").selectedIndex = 0
        elseif attrConf.step == nowAttZConf.step then
            if attrConf.period < nowAttZConf.period then
                self.xingxing:GetController("c1").selectedIndex = 20
            elseif attrConf.period == nowAttZConf.period then
                if self.is10 and nowAttZConf.start ~= 0 then
                    self.xingxing:GetController("c1").selectedIndex = nowAttZConf.start + 10
                else
                    self.xingxing:GetController("c1").selectedIndex = nowAttZConf.start
                end
                self.view:GetChild("n39").text = language.xiuxian06
            else
                self.xingxing:GetController("c1").selectedIndex = 0
            end
        else
            self.xingxing:GetController("c1").selectedIndex = 20
        end

        if attrConf.step == 10 and attrConf.period == 3 then
            self.btnRight.visible = false
            self.btnLeft.visible = true
        elseif attrConf.step == 1 and attrConf.period == 1 then
            self.btnLeft.visible = false
            self.btnRight.visible = true
        else
            self.btnRight.visible = true
            self.btnLeft.visible = true
        end
        if attrConf.period == 1 then
            self.periodImg.url = UIPackage.GetItemURL("immortality" , "xiuxian_032")
        elseif attrConf.period == 2 then
            self.periodImg.url = UIPackage.GetItemURL("immortality" , "xiuxian_033")
        elseif attrConf.period == 3 then
            self.periodImg.url = UIPackage.GetItemURL("immortality" , "xiuxian_034")
        end
    end
end

function ImmortalityView:setData(data)
    self.data = data
    cache.PlayerCache:setDujieCD(data.djCdLeftTime)
    -- print("请求修仙返回",data.djCdLeftTime)
    -- printt(data)
    self.awardFlagList = {0,0,0,0} --四个奖励的领取状态
    for k,v in pairs(self.data.awardGotFlag) do
        self.awardFlagList[v] = 1
    end
    for k,v in pairs(self.awardFlagList) do
        if v == 1 then
            self.view:GetChild("n9"..(5+k)).visible = true
        else
            self.view:GetChild("n9"..(5+k)).visible = false
        end
    end
    self.index = 0 --奖励索引

    self.lv = self.data.level --当前显示等级
    if self.data.level > 1 and self.data.level%10 == 0 and self.data.djSign == 0 then
        self.lv = self.data.level - 1
    end
    -- print("当前显示等级",self.lv,self.data.level,self.data.level%10)
    self:setSrcInfo()
    local roleLv = cache.PlayerCache:getRoleLevel()
    self.expWayData = conf.ImmortalityConf:getWayData(roleLv)
    for k,v in pairs(self.expWayData) do
        local num = self.data.expWayMap[v.id] or 0
        if v.max_count - num > 0 then
            self.expWayData[k].isfinish = 0 --未完成
        else
            self.expWayData[k].isfinish = 1 --进度已完成
        end
    end
    table.sort(self.expWayData,function(a,b)
        if a.isfinish ~= b.isfinish then
            return b.isfinish > a.isfinish
        elseif a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    self:initAttr()
    self:setActiveData()

    self.listView.numItems = #self.expWayData
    self:setGuideFiger()
end
--加载属性加成
function ImmortalityView:initAttr()
    -- body
    for k,v in pairs(self.attList) do
        v.text = ""
    end
    local lv = self.data.level
    local attrConf = conf.ImmortalityConf:getAttrDataByLv(lv)
    self.lvUpBtn:GetChild("icon").url = UIPackage.GetItemURL("immortality" , "xiuxian_002")
    self.isDujie = false
    -- print("当前等级",self.data.level,self.data.djSign,attrConf.start)
    if attrConf.start and attrConf.start ~= 0 and self.is10 then
        self.xingxing:GetController("c1").selectedIndex = attrConf.start +10
    else
        if self.data.djSign == 0 and lv > 1 and attrConf.start == 0 then
            self.xingxing:GetController("c1"). selectedIndex = 20
            self.lvUpBtn:GetChild("icon").url = UIPackage.GetItemURL("immortality" , "dujie_005")
            self.isDujie = true
        else
            self.xingxing:GetController("c1"). selectedIndex = attrConf.start or 0
        end
    end
    --属性设置
    local attrData = GConfDataSort(attrConf)
    for k,v in pairs(attrData) do
        local key = v[1]
        local value = v[2]
        local decTxt = self.attList[k]
        local attName = conf.RedPointConf:getProName(key)
        decTxt.text = attName.." "..value
    end
    -- local orderIcon = self.view:GetChild("n82")
    -- orderIcon.url = UIPackage.GetItemURL("immortality" , "huoban_0"..(string.format("%02d",attrConf.step)))
    -- local signIcon = self.view:GetChild("n83")
    -- signIcon.url = UIPackage.GetItemURL("immortality" , attrConf.pic)
    -- local name = self.view:GetChild("n52")
    -- name.text = attrConf.name or language.xiuxian09
    local power = self.view:GetChild("n57")
    power.text = attrConf.power

    self.lvUpBtn.visible = true
    self.view:GetChild("n990").visible = false
    for i=106,110 do
        self.view:GetChild("n"..i).visible = true
    end
    if attrConf.step == 10 and attrConf.period == 3 then
        self.btnRight.visible = false
        if attrConf.start == 10 then
            self.lvUpBtn.visible = false
            self.view:GetChild("n990").visible = true
            self.view:GetChild("n24").visible = false
            for i=106,110 do
                self.view:GetChild("n"..i).visible = false
            end
        end
    elseif attrConf.step == 1 and attrConf.period == 1 then
        self.btnLeft.visible = false
    else
        self.btnRight.visible = true
        self.btnLeft.visible = true
    end
    --技能提升显示
    local attId = (math.floor(lv/10)+1)*10
    if attId%10 == 0 and self.data.djSign == 0 then
        attId = (math.floor((lv-1)/10)+1)*10
    end
    local attrConfData = conf.ImmortalityConf:getAttrDataByLv(attId)
    -- print("当前修仙等级",lv,attId)
    --奖励设置
    -- local attId = (math.floor(lv/30)+1)*30
    -- if self.isDujie and attrConf.period == 1 then
    --     attId = (math.floor(lv/30))*30
    -- end
    --print("当前等级",lv,attId)
    -- local awardsConf = conf.ImmortalityConf:getAttrDataByLv(attId)
    local nextConf = conf.ImmortalityConf:getAttrDataByLv(lv+1)
    self.expBar.visible = true
    local nowExp = self.data.exp
    for i=1,4 do
        self.awardsList[i].visible = false
    end
    if nextConf then
        --奖励取消
        -- if awardsConf and awardsConf.awards then
        --     for k,v in pairs(awardsConf.awards) do
        --         local mid = v[1]
        --         local num = v[2]
        --         local bind = v[3]
        --         local awardItem = self.awardsList[k]
        --         awardItem.visible = true
        --         -- local info = { mid=mid, amount = num, bind = conf.ItemConf:getBind(mid) or 0}
        --         local info = { mid=mid, amount = num, bind = bind}
        --         GSetItemData(awardItem,info,true)
        --     end
        --     self.view:GetChild("n24").visible = true
        -- else
            self.view:GetChild("n24").visible = false
            for i=1,4 do
                self.awardsList[i].visible = false
            end
        -- end
        --技能提升显示
        if attrConfData and attrConfData.skill_info then
            local sex = cache.PlayerCache:getSex()
            local decTxt = self.view:GetChild("n106")
            local icon = self.view:GetChild("n108")
            local skillName = self.view:GetChild("n109")
            local skillLv = self.view:GetChild("n110")
            local iconId = conf.SkillConf:getSkillIcon(attrConfData.skill_info[sex])
            local name = conf.SkillConf:getSkillName(attrConfData.skill_info[sex])
            icon.url =  ResPath.iconRes(iconId)
            skillName.text = name
            skillLv.text = "LV" .. attrConfData.skill_info[3]
            decTxt.text = attrConfData.name .. attrConfData.period_name .. language.xiuxian29
        end
        local nextExp = nextConf.need_exp
        -- print("当前经验和下阶经验",nowExp,nextExp)
        self.expBar.value = nowExp
        self.expBar.max = nextExp
        if self.isDujie then
            self.expBar.max = 0
        end 
    else
        local maxExp = attrConf.need_exp
        self.expBar.value = nowExp
        self.expBar.max = maxExp
    end
    --渡劫等级提示
    local attrConf = conf.ImmortalityConf:getAttrDataByLv(self.data.level)
    local fbId = (224*1000+((attrConf.step - 1) * 3 + attrConf.period)-1)*1000+1
    local fbConf = conf.FubenConf:getPassDatabyId(fbId)
    local djTxt = self.view:GetChild("n105")
    if self.isDujie then
        local textData = { 
            {text = language.xiuxian28[1],color = 5},
            {text = fbConf.open_lv,color = 10},
            {text = language.xiuxian28[2],color = 5},
        }
        djTxt.text = mgr.TextMgr:getTextByTable(textData)
        djTxt.visible = true
        self.view:GetChild("n104").visible = true
    else
        djTxt.visible = false
        self.view:GetChild("n104").visible = false
    end
    self:refreshRedPoint()
end
--活跃奖励设置
function ImmortalityView:setActiveData(  )
    local data = cache.ActivityCache:get5030111()
    local var = data.openDay%9
    if var == 0 then var = 9 end
    local activeData = conf.ImmortalityConf:getActiveAwardsData(var)
    if activeData then
        for k,v in pairs(activeData) do
            local mid = v.awards[1][1]
            local num = v.awards[1][2]
            local bind = v.awards[1][3]
            local awardItem = self.activeAwards[k]
            -- local info = { mid=mid, amount = num, bind = conf.ItemConf:getBind(mid) or 0}
            local info = { mid=mid, amount = num, bind = bind}
            GSetItemData(awardItem,info,true)
        end
        self.view:GetChild("n11").text = self.data.dayProcess .. "/" ..activeData[4].active_exp
        self.activeBar.visible = true
        self.activeBar.value = self.data.dayProcess
        self.activeBar.max = activeData[4].active_exp
        --活跃按钮状态设置
        local awardGotFlag = self.data.awardGotFlag
        local index = 0--math.floor(4/(activeData[4].active_exp / self.data.dayProcess))
        for i=1,4 do
            if self.data.dayProcess>=activeData[i].active_exp then
                index = index + 1
            end
        end
        --进度条分割线位置设置
        for i=1,3 do
            local img = self.view:GetChild("n8"..(3+i))
            local hyTxt = self.view:GetChild("n9"..i)
            local awardIcon = self.view:GetChild("n4"..(3+i))
            hyTxt.text = activeData[i].active_exp
            img.x = self.activeBar.x + self.activeBar.width*(activeData[i].active_exp/activeData[4].active_exp)
            -- hyTxt.x = img.x - 10
            -- awardIcon.x = img.x - 0.8*(awardIcon.width)
        end
        self.view:GetChild("n94").text = activeData[4].active_exp
        if index == 0 then --活跃度不够领取奖励
            self.actGetBtn.grayed = true
            self.actGetBtn.touchable = false
            self.actGetBtn:GetChild("red").visible = false
        else
            self.actGetBtn.grayed = true
            self.actGetBtn.touchable = false
            self.actGetBtn:GetChild("red").visible = false
            local count = 1
            while count <= index do
                if self.awardFlagList[count] == 0 then
                    self.actGetBtn.grayed = false
                    self.actGetBtn.touchable = true
                    self.actGetBtn:GetChild("red").visible = true
                    self.index = count
                    break
                end
                count = count + 1
            end
        end
    end
end
--升级按钮和领取按钮红点刷新
function ImmortalityView:refreshRedPoint()
    -- body
    local attrConf = conf.ImmortalityConf:getAttrDataByLv(self.data.level)
    local nextConf = conf.ImmortalityConf:getAttrDataByLv(self.data.level+1)
    local myPower = cache.PlayerCache:getRolePower()
    local var = cache.PlayerCache:getAttribute(10246)
    if nextConf then
        if self.data.exp >= nextConf.need_exp then
            if nextConf.need_power then
                if myPower >= nextConf.need_power then
                    if var > 0 then
                        self.lvUpBtn:GetChild("red").visible = false
                    else
                        self.lvUpBtn:GetChild("red").visible = true
                    end
                else
                    self.lvUpBtn:GetChild("red").visible = false                    
                end
            else
                if var > 0 then
                    self.lvUpBtn:GetChild("red").visible = false
                else
                    self.lvUpBtn:GetChild("red").visible = true
                end
            end
        else
            --可渡劫
            if self.data.level > 1 and self.data.level%10 == 0 and self.data.djSign == 0 then
                if var > 0 then
                    self.lvUpBtn:GetChild("red").visible = false
                else
                    self.lvUpBtn:GetChild("red").visible = true
                end
            else                     
                self.lvUpBtn:GetChild("red").visible = false                        
            end
        end
    end
end

--升级按钮
function ImmortalityView:onClickLvUp( context )
    if not self.data then
        return
    end
    if self.isDujie then
        if not mgr.FubenMgr:checkScene() then
            local roleId = cache.PlayerCache:getRoleId()
            local isCaptain = cache.TeamCache:getIsCaptain(roleId)
            local isNotTeam = cache.TeamCache:getIsNotTeam()
            local attrConf = conf.ImmortalityConf:getAttrDataByLv(self.data.level)
            local fbId = (224*1000+((attrConf.step - 1) * 3 + attrConf.period)-1)*1000+1
            local fbConf = conf.FubenConf:getPassDatabyId(fbId)
            -- print("渡劫副本id",fbId,fbConf.open_lv)
            local roleLv = cache.PlayerCache:getRoleLevel()
            if isCaptain or isNotTeam then
                if fbConf.open_lv <= roleLv then
                    mgr.ViewMgr:openView(ViewName.DujieView,function()
                        local isNotTeam = cache.TeamCache:getIsNotTeam()
                        if isNotTeam then--创建渡劫队伍
                            local targetId = conf.SysConf:getValue("dujie_team_tartget")
                            local confData = conf.TeamConf:getTeamConfig(targetId)
                            proxy.TeamProxy:send(1300104,{targetId = confData.id,minLvl = confData.lv_section[1],maxLvl = confData.lv_section[2]})
                        else--请求我的队伍信息
                            proxy.TeamProxy:send(1300102)
                        end
                    end)
                else
                    local str = language.xiuxian28[1]..fbConf.open_lv..language.xiuxian28[2]
                    GComAlter(str)
                end
            else
                -- local text = language.team25
                -- local param = {type = 14,richtext = mgr.TextMgr:getTextColorStr(text, 6),sure = function()
                --     proxy.TeamProxy:send(1300107)
                --     mgr.ViewMgr:openView(ViewName.DujieView,function()
                        
                --     end)
                -- end}
                -- GComAlter(param)
                GComAlter(language.xiuxian18)
            end
        else
            GComAlter(language.xiuxian15)
        end
    else
        local lv = self.data.level
        local nowExp = self.data.exp
        local attrConf = conf.ImmortalityConf:getAttrDataByLv(lv)
        local nextConf = conf.ImmortalityConf:getAttrDataByLv(lv+1)
        local myPower = cache.PlayerCache:getRolePower()
        if nextConf then
            if nowExp >= nextConf.need_exp then
                if nextConf.need_power then
                    if myPower >= nextConf.need_power then
                        -- if nextConf.awards then
                        --     mgr.ViewMgr:openView2(ViewName.UpgradeView,self.data)
                        -- end
                        proxy.ImmortalityProxy:sendMsg(1290102)
                    else
                        GComAlter(string.format(language.xiuxian07,nextConf.need_power))
                    end
                else
                    -- if nextConf.awards then
                    --     mgr.ViewMgr:openView2(ViewName.UpgradeView,self.data)
                    -- end
                    proxy.ImmortalityProxy:sendMsg(1290102)
                end
            else
                GComAlter(language.xiuxian02)            
            end
        else
            GComAlter(language.xiuxian01)
        end
    end
end
--升级刷新
function ImmortalityView:gradeUpRefresh( data )
    -- body
    self.data.level = data.level
    self.lv = data.level
    self.data.djSign = data.djSign
    if self.data.level > 1 and self.data.level%10 == 0 and self.data.djSign == 0 then
        self.lv = self.data.level - 1
    end
    self.data.exp = data.exp
    self.is10 = false
    self:initAttr()
    self:setSrcInfo()
    -- mgr.ViewMgr:openView(ViewName.UpgradeView,function( view )
    --     view:setData(data)
    -- end)
    -- local view = mgr.ViewMgr:get(ViewName.UpgradeView)
    -- if view then
    --     view:setData(data)
    -- end
    mgr.SoundMgr:playSound(Audios[2])
end

--领取奖励按钮
function ImmortalityView:onClickGetAwards( context )
    if self.index == 0 then
        GComAlter(language.xiuxian04)
    else
        proxy.ImmortalityProxy:sendMsg(1290103,{awardId = self.index})
    end
end
--领取奖励刷新
function ImmortalityView:getAwardsRefresh( data )
    self.data.awardGotFlag = data.awardGotFlag
    self.awardFlagList = {0,0,0,0} --四个奖励的领取状态
    for k,v in pairs(self.data.awardGotFlag) do
        self.awardFlagList[v] = 1
    end
    for k,v in pairs(self.awardFlagList) do
        if v == 1 then
            self.view:GetChild("n9"..(5+k)).visible = true
        else
            self.view:GetChild("n9"..(5+k)).visible = false
        end
    end
    self.index = 0
    self:setActiveData()
    -- GOpenAlert3(data.items)
end

function ImmortalityView:setGuideFiger()
    -- body
    if cache.GuideCache.shouzhi then
        cache.GuideCache.shouzhi = false
        self.c2.selectedIndex = 1
    end

    -- local flag = false
    -- --local data = self.expWayData[2] --日常任务
    -- local data 
    -- local index
    -- for k ,v in pairs(self.expWayData) do
    --     if v.skipId == 2001 then
    --         index = k
    --         data = v 
    --         break
    --     end
    -- end



    -- if cache.GuideCache.shouzhi and data.isfinish == 0 and index == 1 then
    --     cache.GuideCache.shouzhi = false
    --     flag = true
    --     local effect = self:addEffect(4020118,self.effectmodel)
    --     effect.Scale = Vector3.New(70,70,70)
    --     effect.LocalPosition = Vector3.New(self.effectmodel.width/2,-self.effectmodel.height/2,0)
    -- end
    -- self.effectmodel.visible = flag
end

function ImmortalityView:onScrollEvent()
    -- body
    self.effectmodel.visible = false
end

--加载途径列表
function ImmortalityView:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.listView.scrollPane.onScroll:Add(self.onScrollEvent,self)
    self.listView.onClickItem:Add(self.onClickGoToView,self)
end

function ImmortalityView:itemData(index, obj)
    -- body
    local data = self.expWayData[index+1]
    local timesNum = self.data.expWayMap[data.id] or 0
    local max_count = data.max_count or 0
    local name = obj:GetChild("n1")
    local times = obj:GetChild("n2")
    local singleExp = obj:GetChild("n3")
    -- name.text = data.name
    -- times.text = timesNum .. "/" .. max_count
    -- singleExp.text = data.single_exp
    local oneceExp = data.single_exp
    local isvip3 = cache.PlayerCache:VipIsActivate(3)
    if isvip3  then
        local add = conf.ImmortalityConf:getValue("xiuxian_add_plus")
        oneceExp = math.ceil(data.single_exp + data.single_exp * (add/100))
    end
    if data.isfinish == 1 then --已完成
        obj:GetChild("n0").url = UIPackage.GetItemURL("immortality" , "gonggongsucai_117")
        obj:GetChild("n4").grayed = true
        name.text = mgr.TextMgr:getTextColorStr(data.name,0)
        times.text = mgr.TextMgr:getTextColorStr(timesNum .. "/" .. max_count,0)
        singleExp.text = mgr.TextMgr:getTextColorStr(oneceExp,0)
    elseif data.isfinish == 0 then --未完成
        obj:GetChild("n0").url = UIPackage.GetItemURL("immortality" , "gonggongsucai_051")
        obj:GetChild("n4").grayed = false
        name.text = mgr.TextMgr:getTextColorStr(data.name,6)
        times.text = mgr.TextMgr:getTextColorStr(timesNum .. "/" .. max_count,7)
        singleExp.text = mgr.TextMgr:getTextColorStr(oneceExp,6)
    end
    -- if data.id == 7 or data.id == 12 then
    --     obj:GetChild("n4").visible = true
    -- else
        obj:GetChild("n4").visible = false
    -- end
    obj.data = data

end
--跳转
function ImmortalityView:onClickGoToView( context )
    --plog("call")
    local cell = context.data
    local data = cell.data
    if data.skipId then
        local param = {id = data.skipId}
        GOpenView(param)
    else
        GComAlter(language.xiuxian08)
    end
end

function ImmortalityView:onClickClose()
    -- body
    self:closeView()
end

return ImmortalityView