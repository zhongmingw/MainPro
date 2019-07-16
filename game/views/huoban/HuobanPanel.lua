--
-- Author: 
-- Date: 2017-02-25 11:32:45
--

local HuobanPanel = class("HuobanPanel",import("game.base.Ref"))
local redpoint = {10211,10213,10212,10215,10214}
local _max_ = {12,10,10,10,10}
function HuobanPanel:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n18")
    self:initView()
end

function HuobanPanel:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.setItemMsg,self)
    --浮动动画
    self.t0 = self.view:GetTransition("t0")
    ---名字
    self.name = self.view:GetChild("n48") 
    self.iconJie = self.view:GetChild("n12")
    self.icon2 = self.view:GetChild("n60")
    self.icon3 = self.view:GetChild("n66")
    self.icon3.visible = false
    --改名名字
    local btnChangeName =  self.view:GetChild("n56")
    btnChangeName.onClick:Add(self.onbtnChangeName,self)
    btnChangeName.visible = false
    self.btnChangeName = btnChangeName
    --特殊皮肤
    local btnMore = self.view:GetChild("n21")
    if g_ios_test then              --EVE 屏蔽特殊皮肤
        btnMore.visible = false
    else 
        btnMore.onClick:Add(self.onMoreMsg,self)
        self.btnMore = btnMore
    end 
    --技能
    self.dec1 = self.view:GetChild("n22")
    self.list1 = self.view:GetChild("n30")
    self.list1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list1.numItems = 0
    self.list1.onClickItem:Add(self.onCallBackItem,self)
    --z装备
    self.dec2 = self.view:GetChild("n23")
    self.list2 = self.view:GetChild("n31")
    self.list2.itemRenderer = function(index,obj)
        self:celldata2(index, obj)
    end
    self.list2.numItems = 0
    self.list2.onClickItem:Add(self.onCallBackItem2,self)
    --出站按钮
    self.btnBat = self.view:GetChild("n17")
    self.btnBat.onClick:Add(self.onBattle,self)
    self.btnBatTitle = self.btnBat:GetChild("title")
    --伙伴的5个技能
    self.skillList = {}
    for i = 54,55 do
        local btn = self.view:GetChild("n"..i)
        btn:GetChild("n3").text = ""
        btn.onClick:Add(self.onPetCall,self)
        table.insert(self.skillList,btn)
    end
    self.list3 = self.view:GetChild("n62")
    self.list3.itemRenderer = function(index,obj)
        self:celldata3(index, obj)
    end
    self.list3.numItems = 0
    self.list3.onClickItem:Add(self.onCallBackItem3,self)


    --丹药
    self.labitem1 = self.view:GetChild("n24")
    self.labitem2 = self.view:GetChild("n25")
    self.imgRed1 = self.view:GetChild("n59")
    self.imgRed2 = self.view:GetChild("n58")

    --模型
    self.model = self.view:GetChild("n37")

    ------------------------------------------
    self.pageBefor = self.view:GetChild("n20")
    self.pageBefor.data = "n20"
    self.pageBefor.onClick:Add(self.onChangeCallBack,self)
    self.pageNext = self.view:GetChild("n19")
    self.pageNext.data = "n19"
    self.pageNext.onClick:Add(self.onChangeCallBack,self)
    ---
    self.labPower = self.view:GetChild("n28")
    self.tojie = self.view:GetChild("n49") 

    self.rightbtn1 = self.view:GetChild("n34")
    self.rightbtn1.data = "n34"
    self.rightbtn1.onClick:Add(self.onItemUse,self)
    self.rightbtn2 = self.view:GetChild("n35")
    self.rightbtn2.data = "n35"
    self.rightbtn2.onClick:Add(self.onItemUse,self)

    self.c1Jihuo = self.view:GetChild("n44")

    local btnBack = self.view:GetChild("n46")
    btnBack.onClick:Add(self.onBtnBack,self)

    --获取跳转
    local btnget = self.view:GetChild("n67") 
    btnget.onClick:Add(self.onBtnget,self)
    self.btnget = btnget

    self.lingqu = self.view:GetChild("n61") 
    self.lingqu.onClick:Add(self.onGetCall,self)
    --特殊皮肤--huoban
    self.teshuBat = self.view:GetChild("n65")  
    self.teshuBat.visible = false
    self.teshuBat.onClick:Add(self.onBattle,self)  
    self:initDec()
    --活动提示按钮
    self.signBtn = self.view:GetChild("n63")
    self.signBtn.data = self.signBtn.xy
    self.signBtn.onClick:Add(self.onClickSign,self)
    --特惠提示按钮
    self.TehuiBtn = self.view:GetChild("n70")
    self.TehuiBtn.data = self.TehuiBtn.xy
    self.TehuiBtn.onClick:Add(self.onClickTeHui,self)
    --百倍豪礼提示按钮
    self.BaibeiBtn = self.view:GetChild("n71")
    self.BaibeiBtn.data = self.BaibeiBtn.xy
    self.BaibeiBtn.onClick:Add(self.onClickBaibei,self)
    
    self.modelsee = self.view:GetChild("n68")
    self.starBtn = self.view:GetChild("n75")--升星
    self.starBtn.onClick:Add(self.onClickStar,self)
    if g_ios_test then  --EVE ios版属
        self.signBtn.scaleX = 0
        self.signBtn.scaleY = 0
    end 
end

function HuobanPanel:initDec()
    -- body
    self.dec1.text = ""
    self.btnBatTitle.text = ""
    self.tojie.text = ""
end

--活动提示按钮
function HuobanPanel:onClickSign()
    -- body
    local confdata = conf.HuobanConf:getDataByLv(1,self.superSelect)
    local needtolv = {99,99}
    if self.superSelect == 0 then 
        --伙伴
        needtolv = {3,4}
    elseif self.superSelect == 1 then
        --灵羽
        needtolv = {3,4}
    elseif self.superSelect == 2 then
        --灵兵
        needtolv = {3,4}
    elseif self.superSelect == 3 then 
        --灵宝
        needtolv = {3,4}
    elseif self.superSelect == 4 then
        --灵器
        needtolv = {3,4}
    end
    local grade = 1
    if needtolv[2] <= self.jie then
        grade = 2
    end
    local param = {}
    param.index = self.superSelect+10
    param.grade = grade
    param.mId = confdata.cost_items and confdata.cost_items[1] or nil
    if param.index == 10 then
        param.mId = 221061002
    end
    param.isShow = true
    GGoBuyItem(param)
end
function HuobanPanel:setBaibeiVisible()
    if g_ios_test then
        self.BaibeiBtn.visible = false
        return
    end
    self.BaibeiBtn.visible = false
    if cache.PlayerCache:getRedPointById(attConst.A30111)<=0 then
        return
    end
    local data = cache.ActivityCache:get5030111()
    if not data then
        return
    end

    local condata = conf.SysConf:getHwbSBItem("lingdong"..self.superSelect)
    if not condata then
        return
    end
    local curday = data.openDay % 9
    if condata.open_day and curday  ~= condata.open_day then--有天数 要求
        return
    end
     --没有购买要求
    if not condata.buy_danci then
        self.BaibeiBtn.visible = true
        return
    end
    
    --检测是否购买了要求物品
    local key = g_var.accountId.."3010buy"
    local _localbuy = UPlayerPrefs.GetString(key)
    if _localbuy~="" then
        local _t = json.decode(_localbuy)
        local pairs = pairs

        local falg = false 
        for k,v in pairs(condata.buy_danci) do
            local innnerbuy = false--当前物品是否买过
            for i , j in pairs(_t) do
                if tonumber(j) == tonumber(v) then
                    innnerbuy = true 
                    break
                end
            end
            if not innnerbuy then --有个需求物品没有买
                falg = true
                break
            end
        end
        self.BaibeiBtn.visible = falg
    else
        self.BaibeiBtn.visible = true
    end
end
function HuobanPanel:setTehuiBtnVisible()
    if g_ios_test then
        self.TehuiBtn.visible = false
        return
    end 
    self.TehuiBtn.visible = false
    local data = cache.ActivityCache:get5030111()
    if not data then
        return
    end
    local condata = conf.SysConf:getHwbSBItem("lingdong"..self.superSelect)
    if not condata then
        return
    end
    local curday = data.openDay % 9
    if condata.open_day and curday  ~= condata.open_day then--有天数 要求
        return
    end
    --没有购买要求
    if not condata.buy_id then
        self.TehuiBtn.visible = true
        return
    end
    local _in = clone(condata.buy_id)
    if not condata.open_day then
        _in = {condata.buy_id[curday] or condata.buy_id[9]}
    end
    --检测是否购买了要求物品
    local key = g_var.accountId.."1026buy"
    local _localbuy = UPlayerPrefs.GetString(key)
    if _localbuy~="" then
        local _t = json.decode(_localbuy)
        local pairs = pairs
        local falg = false 
        for k,v in pairs(_in) do
            local innnerbuy = false--当前物品是否买过
            for i , j in pairs(_t) do
                if tonumber(j) == tonumber(v) then
                    innnerbuy = true 
                    break
                end
            end
            if not innnerbuy then --有个需求物品没有买
                falg = true
                break
            end
        end
        self.TehuiBtn.visible = falg
    else
        self.TehuiBtn.visible = true
    end
end
--活动提示按钮显隐设置
function HuobanPanel:setSignBtnVisible()
    if g_ios_test then
        self.signBtn.visible = false
        return
    end
    local openDay = cache.ActivityCache:get5030111().openDay
    if openDay > 7 then
        return
    end
    local index = self.superSelect+10
    local confData = conf.VipChargeConf:getDataById(index)
    if index == 10 then
        self.signBtn.visible = false
        -- if GFirstChargeIsOpen() and not GGetFirstChargeState(confData.charge_grade) then 
        --     self.signBtn.visible = true
        -- else
        --     self.signBtn.visible = false
        -- end
    else
        local i = GGetDayChargeDayTimes()%7
        if GGetDayChargeDayTimes()%7 == 0 then i = 7 end
        if type(SkipType[i]) == "table" then
            if (SkipType[i][1] == index or SkipType[i][2] == index) and GGetDayChargeState(confData.charge_grade) then
                self.signBtn.visible = true
            else
                self.signBtn.visible = false
            end
        else
            self.signBtn.visible = false
        end
    end
end

function HuobanPanel:onbtnUpskill(context)
    -- body
    local data = context.sender.data
    mgr.ViewMgr:openView(ViewName.HuobanSkillUp, function(view)
        -- body
        view:setData(self.superSelect)
    end, data) 
end

function HuobanPanel:setbtnTitle(data)
    -- body
    local t = {Skins.huoban,Skins.huobanxianyu,Skins.huobanshenbing,Skins.huobanfabao,Skins.huobanxianqi}
    local var = t[self.superSelect+1]
    local id = cache.PlayerCache:getSkins(var) --当前选择

    if self.superSelect~=0 then
        if id == self.modle_id then
            self.btnBatTitle.text = language.huoban33[t[self.superSelect+1]][2]
            self.isWear = true
            --self.teshuBat.icon = UIPackage.GetItemURL("huoban" ,"shizhuangchenghao_018")
        else
            self.isWear = false
            self.btnBatTitle.text =language.huoban33[t[self.superSelect+1]][1]
            --self.teshuBat.icon = UIPackage.GetItemURL("huoban" ,"shizhuangchenghao_007")
        end
    else
        local info = cache.PlayerCache:getSkins(Skins.huobanteshu)
        local condata = conf.HuobanConf:getSkinsByIndex(self.selectskin,self.superSelect)
        if condata.istshu == 2 then
            --如果当前选择是特殊皮肤
            if info and self.modle_id == info then
                self.isWear = true
                self.teshuBat.icon = UIPackage.GetItemURL("huoban" ,"shizhuangchenghao_018")
            else
                self.isWear = false
                self.teshuBat.icon = UIPackage.GetItemURL("huoban" ,"shizhuangchenghao_007")
            end
        else 
            if id == self.modle_id then
                self.btnBatTitle.text = language.huoban33[t[self.superSelect+1]][2]
                self.isWear = true
                --self.teshuBat.icon = UIPackage.GetItemURL("huoban" ,"shizhuangchenghao_018")
            else
                self.isWear = false
                self.btnBatTitle.text =language.huoban33[t[self.superSelect+1]][1]
                --self.teshuBat.icon = UIPackage.GetItemURL("huoban" ,"shizhuangchenghao_007")
            end
        end 
    end
end

function HuobanPanel:resetChengHao()
    -- body
    self.icon3.visible = true
    local innerdata = conf.HuobanConf:getDataByLv(self.data.lev,0)
    local jie = innerdata.jie
    if jie <= 0 or jie > self.maxTo then
        jie = 1
    end
    -- print("ResPath:petChengHao(jie)",ResPath:petChengHao(jie))
    self.icon3.url = ResPath:petChengHao(jie)
end

function HuobanPanel:initModel(jie,isid)
    local confData = conf.HuobanConf:getSkinsByIndex(jie,self.superSelect)--升星
    local starPre = confData and confData.star_pre or 0
    if starPre > 0 then
        self.starBtn.visible = true
    else
        self.starBtn.visible = false
    end
    self.confStarData = confData
    if self.superSelect == 0 then
        self.starBtn.x,self.starBtn.y = 30,453
    else
        self.starBtn.x,self.starBtn.y = 110,464
    end
    if self.selectskin then
        self.oldselectskin = self.selectskin
    end
    -- body
    self.btnBat.visible = false
    self.cansee = false
    local condata
    if not isid then --按阶取形象
        self.c1.selectedIndex = 0
        condata = conf.HuobanConf:getSkinsByJie(jie,self.superSelect)
        --升到n阶激活
        if self.superSelect > 0 then
            if jie <= self.maxJie then
                self.tojie.text = ""
                
            else
                self.tojie.text = string.format(language.zuoqi60,jie)
                
            end
        end
    else
        condata = conf.HuobanConf:getSkinsByIndex(jie,self.superSelect)
    end
    self.name.text = condata.name 
    --类型 或者 阶
    self.btnChangeName.visible = false
    self.lingqu.visible = false
    self.lingqu:GetChild("red").visible = true

    --self.btnBat.visible = false
    self.teshuBat.visible = false
    local isget = false
    if self.superSelect == 0 then
        self.icon2.visible = false
        if condata.type then
            for k ,v in pairs(condata.type) do
                if k > 2 then
                    break
                end
                if k == 1 then
                    self.iconJie.url = UIItemRes.huoban01[v]
                else
                    self.icon2.url = UIItemRes.huoban01[v]
                    self.icon2.visible = true
                end
            end
        end

        for k ,v in pairs(self.data.skins) do
            if tonumber(v.skinId) == tonumber(condata.id) then
                self.name.text = v.name
                if v.sign == 2 then
                    isget = true
                    --self.btnChangeName.visible = true
                    self.btnBat.visible = true
                else
                    self.lingqu.visible = true
                    if v.sign == 1 then
                        self.lingqu:GetChild("red").visible = true
                    end
                    --EVE 是否领取            
                end
                break
            end
        end
    else
        self.iconJie.url = UIItemRes.jieshu[condata.grow_cons]
        if jie <= self.maxJie then
            self.btnBat.visible = true
        else
            self.btnBat.visible = false
        end
    end
    
    local panel = self.model:GetChild("n0")
    local touc = self.model:GetChild("n1")
    local node = self.model:GetChild("n2")
    if self.effect1 then
        self.parent:removeUIEffect(self.effect1)
        self.effect1 = nil 
    end
    self.icon3.visible = false
    if self.superSelect == 0 or self.superSelect == 1 or self.superSelect == 2 then --伙伴
        --移除特效
        if self.superSelect == 0 then
            touc.touchable = true
        else
            touc.touchable = false
        end

        self.t0:Stop()
        -- self.parent:removeUIEffect(self.effect)
        -- self.effect = nil 
        --添加模型
        --if not self.model.data then--
        if self.superSelect == 0 then
            self.model.data,self.cansee = self.parent:addModel(condata.modle_id,panel)
        elseif self.superSelect == 1 then
            self.model.data,self.cansee = self.parent:addModel(GuDingmodel[2],panel)
        else
            -- local info = cache.PlayerCache:getSkins(Skins.huobanteshu)
            -- if not info or info ==0 then
            --     info = cache.PlayerCache:getSkins(Skins.huoban)
            -- end
            self.model.data,self.cansee = self.parent:addModel(GuDingmodel[2],panel)    
        end
        self.model.data:setScale(SkinsScale[Skins.huoban])
        self.model.data:setPosition(panel.actualWidth/2,-panel.actualHeight-150,500)  
        --end
        --脚底特效
        self.effect1 = self.parent:addEffect(4020102,node)
        self.effect1.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight+50,500)

        
        if self.superSelect == 1 then
            self.cansee = self.model.data:setSkins(GuDingmodel[2],nil,condata.modle_id)
        elseif self.superSelect == 2 then
            local modelId = cache.PlayerCache:getSkins(Skins.huobanteshu)
            if not modelId or modelId ==0 then
                modelId = cache.PlayerCache:getSkins(Skins.huoban)
            end
            if modelId == 0 then
                modelId = GuDingmodel[4]
            end
            self.model.data:addWeaponEct(condata.modle_id.."_ui")
        else
            local info = cache.PlayerCache:getSkins(Skins.huobanteshu)
            local id = condata.modle_id
            if info and info ~= 0 and condata.istshu ~= 2 then
                id = info
            end
            self.cansee = self.model.data:setSkins(id,nil,0) 
            --称号
            self:resetChengHao()
        end

        
        self.model.data:modelTouchRotate(touc)
        self.model.data:setRotationXYZ(0,0,0)
        if condata.xyz then
            --plog(x,y,z,"self.superSelect = ",self.superSelect)
            self.model.data:setRotationXYZ(condata.xyz[1],condata.xyz[2],condata.xyz[3])--180
        end
    elseif self.superSelect == 3 or self.superSelect == 4 then --伙伴法宝
        self.t0:Play()
        touc.touchable = false
        --self.parent:removeModel(self.model.data)
        --self.model.data = nil 
        local flag = false
        if not self.modle_id  then
            flag = true
        elseif self.modle_id~=condata.modle_id then
            flag = true
        elseif self.modle_id == condata.modle_id  then
            flag = false
        end

        if flag then
            self.parent:removeUIEffect(self.effect) 
            self.effect = self.parent:addEffect(condata.modle_id,panel)
            if self.superSelect == 3 then
                self.t0:Play()
                self.effect.Scale = Vector3.New(300,300,300)
                self.effect.LocalRotation = Vector3.New(340,0,0)
                self.effect.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight+130,500)
            elseif self.superSelect == 4 then
                --self.t0:Stop()
                self.t0:Play()
                self.effect.Scale = Vector3.New(300,300,300)
                self.effect.LocalRotation = Vector3.New(340,0,0)
                self.effect.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-350,500)
            end
        end
    end

    --特殊皮肤激活描述
    
    if self.superSelect == 0 then
        self.c1Jihuo.text = condata.dec
    else
        self.c1Jihuo.text = condata.desc
    end
    --左右箭头
    if not isid  then
        if jie < self.maxTo then
            --self.pageBefor
            self.pageNext.visible = true
        else
            self.pageNext.visible = false
        end

        if jie > 1 then
            self.pageBefor.visible = true
        else
            self.pageBefor.visible = false
        end
    else
        self.pageNext.visible = false
        self.pageBefor.visible = false

        local flag = false
        --皮肤是否拥有
        if self.superSelect == 0 then --小伙伴
            if condata.istshu == 2 then
                self.btnBat.visible = false
                if isget then
                    self.c1.selectedIndex = 4
                    self.teshuBat.visible = true
                else
                    self.c1.selectedIndex = 2
                    self.teshuBat.visible = false
                end
            else
                self.teshuBat.visible = false
                self.c1.selectedIndex = 3
            end
            
        else
            for k ,v in pairs(self.data.skins) do
                if v == condata.id then
                    self.c1.selectedIndex = 1
                    flag = true
                    self.btnBat.visible = true
                    break
                end
            end
            if not flag then
                self.c1.selectedIndex = 2
            end
        end
    end
    --当前选中的皮肤
    self.selectskin = condata.id
    self.modle_id = condata.modle_id
    self.getpath = condata.tab_type
     if self.getpath then
        self.btnget.visible = true
    else
        self.btnget.visible = false
    end
    ------
    self:setbtnTitle()
    
    self.modelsee.visible = self.cansee 

    --动态居中计算
    local width = 0 --self.model.x  
    if self.name.visible then
        width = width + self.name.width
    end
    if self.iconJie.visible then
        width = width + self.iconJie.width
    end
    if self.icon2.visible then
        width = width + self.icon2.width
    end
    if self.btnChangeName.visible then
        width = width + self.btnChangeName.width
    end

    local offx = self.model.x + (self.model.width-width)/2 + 20
    if self.name.visible then
        self.name.x = offx
        offx = self.name.width + self.name.x
    end
    if self.iconJie.visible then
        self.iconJie.x = offx
        offx = self.iconJie.width + self.iconJie.x
    end
    if self.icon2.visible then
        self.icon2.x = offx
        offx = self.icon2.width + self.icon2.x
    end
    if self.btnChangeName.visible then
        self.btnChangeName.x = offx + self.btnChangeName.width
    end

end

--关闭界面设置nil
function HuobanPanel:setSelfmodle_id()
    self.modle_id = nil
end
function HuobanPanel:celldata( index,obj )
    -- body
    local data = self.leftConf[index+1]
    local icon = obj:GetChild("n2")
    icon.url =ResPath.iconRes(data.icon) -- UIPackage.GetItemURL("_icons" , ""..data.icon)
    local c1 = obj:GetController("c1")

    local lv = self.data.skills[data.id]

    if lv then --获得
        c1.selectedIndex = 0
    else
        c1.selectedIndex = 1
    end

    local labLv = obj:GetChild("n3")
    labLv.text = lv and "Lv ".. (lv or "") or ""

    local labget = obj:GetChild("n5")
    labget.text = data.dec or ""

    obj.data = {id = data.id , lv = lv or 0 ,maxjie = self.maxJie}

    local redimg = obj:GetChild("n7")
    redimg.visible = false
    --计算技能是否可以升级
    redimg.visible = self:checkPoint(obj.data,1)

end

function HuobanPanel:onCallBackItem(context)
    -- body
    local cell = context.data
    local data = cell.data
    self.parent:callLeftItem(data)
end

function HuobanPanel:initSkill( data )
    -- body
    --printt(self.leftConf)

    table.sort(self.leftConf,function (a,b)
        -- body
        return a.id < b.id
    end)
    self.list1.numItems = #self.leftConf
end

function HuobanPanel:celldata2(index,obj)
    local frame = obj:GetChild("n4")
    local icon = obj:GetChild("n1") 
    local labLv = obj:GetChild("n2")

    local data = self.rightConf[index+1]
    local lv = self.data.equips[data.id]

    frame.url = UIItemRes.beibaokuang[data.color]
    icon.url = ResPath.iconRes(data.icon) --UIPackage.GetItemURL("_icons" , ""..data.icon)
    local lv = lv or 0
   -- labLv.text = 
    if lv > 1 then
        labLv.text =  "+"..(lv-1) --(lv and lv>0) and "+"..lv or ""
    else
        labLv.text = ""
    end

    local c1 = obj:GetController("c1")
    c1.selectedIndex = lv>0 and 0 or 1

    obj.data = {id = data.id,lv = lv or 0 ,maxjie = self.maxJie}

    local redimg = obj:GetChild("n5")
    redimg.visible = false
    --计算是否可以升级
    redimg.visible = self:checkPoint(obj.data,2)
end

--列表选择
function HuobanPanel:onCallBackItem2( context )
    -- body
    local data = context.data.data
    self.parent:callRightItem(data)
end

function HuobanPanel:initEquip()
    -- body
    table.sort(self.rightConf,function (a,b)
        -- body
        return a.id < b.id
    end)
    self.list2.numItems = #self.rightConf
end

function HuobanPanel:celldata3( index,obj )
    -- body
    local data = self.petData1[index+1]
    obj:GetChild("n7").visible = false
    local redimg = obj:GetChild("n6")
    redimg.visible = false
    local c1 = obj:GetController("c1")
    c1.selectedIndex = 0
    for k ,v in pairs(self.data.skins) do
        if v.skinId == data.id then
            c1.selectedIndex = 1
            if v.sign == 2 then
                
            elseif v.sign == 1 then
                redimg.visible = true
            end
            break
        end
    end

    local icon = obj:GetChild("n2")
    icon.url =ResPath.iconRes(data.icon)-- UIPackage.GetItemURL("_icons" , ""..data.icon) 

    local lab =  obj:GetChild("n3")
    lab.text = data.dec or ""

    obj.data = data
end
function HuobanPanel:onCallBackItem3( context )
    -- body
    local data = context.data.data
    self.parent:callpetItem(data)
end

function HuobanPanel:onPetCall( context )
    -- body
    local data = context.sender.data
    self.parent:callpetItem(data)
end

function HuobanPanel:onGetWatCall(context)
    -- body
    local btn = context.sender

    if btn.data.id ==  1001007 then
        GOpenView({id = 1050})
    elseif btn.data.id == 1001008 then
        GOpenView({id = 1042,index = 1})
    end
end

function HuobanPanel:initPet()
    -- body
    local condata = conf.HuobanConf:getLeftData(self.superSelect)
    self.petData1 = {} --非固定的
    self.petData2 = {} --固定的
    for k ,v in pairs(condata) do
        if not v.islist or v.islist == 1 then
            table.insert(self.petData2,v)
        else
            table.insert(self.petData1,v)
        end
    end

    table.sort(self.petData1,function(a,b)
        -- body
        return a.id < b.id 
    end)
    table.sort(self.petData2,function(a,b)
        -- body
        return a.id < b.id 
    end)
    self.list3.numItems = #self.petData1
    --检测是否有皮肤可以领取
    self.toIndex = 0
    for k ,v in pairs(self.petData1) do
        for i , j in pairs(self.data.skins) do
            if j.sign == 2 and  v.id == j.skinId then
                self.toIndex = math.max(k,self.toIndex) 
            end
        end
    end
    if self.toIndex >= self.list3.numItems then
        self.toIndex = self.list3.numItems - 1
    end
    --print("toIndex",toIndex)
    --print()
    
    --
    -- for i ,j in pairs(self.data.skins) do
    --     if j.skinId == self.petData1[k].id then
    --         if j.sign ~= 2 then --有这皮肤可以领取
                
    --         end
    --         break
    --     end
    -- end


    local pairs = pairs
    for k ,v in pairs(self.skillList) do
        v.data = self.petData2[k]
        local c1 = v:GetController("c1")
        local c2 = v:GetController("c2")
        local redimg = v:GetChild("n6")
        local icon = v:GetChild("n2")
        local btnget = v:GetChild("n7")
        btnget.data = v.data 
        btnget.onClick:Add(self.onGetWatCall,self)
        -- btnget.onClick:Add(function()
        --     -- body
        --     if v.data.id ==  1001007 then
        --         GOpenView({id = 1050})
        --     elseif v.data.id == 1001008 then
        --         GOpenView({id = 1042})
        --     end
        -- end)
        icon.url = ResPath.iconRes(v.data.icon) --UIPackage.GetItemURL("_icons" , ""..v.data.icon) 
        redimg.visible = false
        c2.selectedIndex = 1
        c1.selectedIndex = 0
        for i ,j in pairs(self.data.skins) do
            if j.skinId == self.petData2[k].id then
                c1.selectedIndex = 1
                if j.sign ~= 2 then --有这皮肤可以领取
                    redimg.visible = true
                    self.isRed = true
                end
                break
            end
        end
        local lab =  v:GetChild("n3")
        lab.text = self.petData2[k].dec or ""
    end
end

function HuobanPanel:setItemMsg()
    -- body
    self.labitem1.text = self.data.zzdNum
    self.labitem2.text = self.data.qldNum
    self.imgRed1.visible = false
    self.imgRed2.visible = false
    if self.c1.selectedIndex == 0 or self.c1.selectedIndex == 3 then
        if cache.PackCache:getPackDataById(self.moduleConf.zzd_mid).amount>0 then
            for k ,v in pairs(self.moduleConf.zzd_limit) do
                if v[1] == self.maxJie and v[2]>self.data.zzdNum then
                    self.imgRed1.visible = true
                    break
                end
            end
        end
        if cache.PackCache:getPackDataById(self.moduleConf.qld_mid).amount>0 then
            for k ,v in pairs(self.moduleConf.qld_limit) do
                if v[1] == self.maxJie and v[2]>self.data.qldNum then
                    self.imgRed2.visible = true
                    break
                end
            end
        end
    end
end

function HuobanPanel:setData(param)
    self.isRed = false

    self.superSelect = self.parent.c1.selectedIndex
    
    self.maxTo = conf.HuobanConf:getValue("endmaxjie",self.superSelect) or _max_[self.superSelect+1]

    self.data = param
    if self.superSelect ~= 0 then
        self.leftConf = conf.HuobanConf:getLeftData(self.superSelect)
    else
        self.leftConf = conf.HuobanConf:getHuobanSkill()
    end
    self.rightConf = conf.HuobanConf:getRightData(self.superSelect)
    self.confData = conf.HuobanConf:getDataByLv(param.lev,self.superSelect)
    if self.superSelect == 0 then
        self.moduleConf = conf.SysConf:getModuleById(1006)
        self.dec1.text = language.huoban02
        self.dec2.text = language.huoban03
    elseif self.superSelect == 1 then
        self.moduleConf = conf.SysConf:getModuleById(1007)
        self.dec1.text = language.huoban04
        self.dec2.text = language.huoban05
    elseif self.superSelect == 2 then
        self.moduleConf = conf.SysConf:getModuleById(1008)
        self.dec1.text = language.huoban06
        self.dec2.text = language.huoban07
    elseif self.superSelect == 3 then
        self.moduleConf = conf.SysConf:getModuleById(1010)
        self.dec1.text = language.huoban08
        self.dec2.text = language.huoban09
    elseif self.superSelect == 4 then
        self.moduleConf = conf.SysConf:getModuleById(1009)
        self.dec1.text = language.huoban10
        self.dec2.text = language.huoban11
    end
    local t = {
        [0] = "huoban_055",
        [1] = "xianyu_007",
        [2] = "shenbin_005",
        [3] = "fabao_004",
        [4] = "xianqi_004",
    }
    if not  g_ios_test then  --EVE --屏蔽特殊皮肤
        self.btnMore.icon = UIPackage.GetItemURL("huoban" ,t[self.superSelect])
    end 

    self.maxJie = self.confData and self.confData.jie or 1
    self.maxJie  = self.maxJie > 0 and self.maxJie or 1
    self:setItemMsg()
    self:initSkill()
    self:initEquip()
    if self.superSelect == 0 then
        self:initPet()
    end
    --战斗力
    if self.data.lev == 0 then
        local p1 = conf.HuobanConf:getDataByLv(1,self.superSelect) 
        self.labPower.text = p1.power
    else
        self.labPower.text = self.data.power 
    end
     --计算左上角按钮显示
    self:setLeftTopVis()
   
end

function HuobanPanel:setLeftTopVis()
    -- body
    --进阶活动
    self:setSignBtnVisible()
    if g_ios_test then
        self.TehuiBtn.visible = false
        self.BaibeiBtn.visible = false
    else
        --特惠礼包
        self.TehuiBtn.visible = self.parent:checkTehui(self.superSelect)
        --百倍豪礼
        self.BaibeiBtn.visible = self.parent:checkBaiBei(self.superSelect)
    end
    --可见往左边移动
    local t = {self.signBtn,self.TehuiBtn,self.BaibeiBtn}
    local index = 1
    for k ,v in pairs(t) do
        if v.visible then
            v.xy = t[index].data
            index = index + 1
        end
    end
end


function HuobanPanel:backModel()
    -- body
    if 0 == self.superSelect then
        --先在固定里面找
        for k ,v in pairs(self.skillList) do
            if v.data and v.data.id == self.oldselectskin then
                v.onClick:Call()
                return
            end
        end
        --在列表里面找
        for k ,v in pairs(self.petData1) do
            if self.oldselectskin and v.id == self.oldselectskin then
                self.list3:AddSelection(k-1,true)
                self.parent:callpetItem(v)
                return
            end
        end
        --如果没有就默认第一个
        self.list3:AddSelection(0,true)
        self.parent:callpetItem(self.petData1[1])
    else
        self.jie = self.jie or 1
        self:initModel(self.jie)
    end
end

function HuobanPanel:ScrollToRed()
    -- body
    if self.toIndex and self.toIndex ~= 0 then
        self.list3:ScrollToView(self.toIndex)
    end
end

function HuobanPanel:selectCur(flag,falg1)
    -- body
    local id 
    if 0 == self.superSelect then
        id = cache.PlayerCache:getSkins(Skins.huoban)
    elseif 1 == self.superSelect then
        id = cache.PlayerCache:getSkins(Skins.huobanxianyu)
    elseif 2 == self.superSelect then
        id = cache.PlayerCache:getSkins(Skins.huobanshenbing)
    elseif 3 == self.superSelect then
        id = cache.PlayerCache:getSkins(Skins.huobanfabao)
    elseif 4 == self.superSelect then
        id = cache.PlayerCache:getSkins(Skins.huobanxianqi)
    end
    local confData = conf.HuobanConf:getSkinsByModel(id,self.superSelect)
    --plog(mid,id,self.superSelect,confData)
    if 0 == self.superSelect then
        -- if confData and confData.istshu == 2 then
        --     self.parent:onSkincallBack(confData.id)
        --     return 
        -- end
        self.jie = nil
        if flag then --选择之前选中的
            --先在固定里面找
            for k ,v in pairs(self.skillList) do
                if v.data and v.data.id == self.oldselectskin then
                    v.onClick:Call()
                    return
                end
            end
            --在列表里面找
            for k ,v in pairs(self.petData1) do
                if self.oldselectskin and v.id == self.oldselectskin then
                    self.list3:AddSelection(k-1,true)
                    self.parent:callpetItem(v)
                    return
                end
            end
        end

        self.selectskin = nil 
        local data 
        if confData then --当前选中的
            --先在固定里面找
            for k ,v in pairs(self.skillList) do
                if v.data and v.data.id == confData.id then
                    v.onClick:Call()
                    return
                end
            end


            for k ,v in pairs(self.petData1) do
                if v.id == confData.id then
                    data = v 
                    --plog("...")
                    self.list3:AddSelection(k-1,true)
                    self.parent:callpetItem(data)
                    return
                end
            end
        else
            data = self.petData1[1]
            --self.list3:AddSelection(0,true)

            self.parent:callpetItem(data)

        end
        
        --self:initFiveSkill()
    else
        -- if confData and  not confData.grow_cons then
        --     --特殊皮肤
        --     self:initModel(confData.id,true)
        --     return
        -- end

        if flag then
            self:initModel(self.jie or 1)
            return 
        end
        self.selectskin = nil 
        
        local jie = confData and confData.grow_cons or nil
        if jie and jie > 0 and jie < self.maxTo then --当前
            self.jie = jie
        else
            self.jie = self.maxJie
        end
        if falg1 then
            self.jie = self.maxJie
        end
        self:initModel(self.jie)
    end

end

function HuobanPanel:selectCallBack()
    -- body
    if 0 == self.superSelect then

    end
end

function HuobanPanel:onbtnChangeName()
    -- body
    if self.c1.selectedIndex == 3 then 
        mgr.ViewMgr:openView(ViewName.JueSeName, function( view )
            -- body
            --printt(self.data.skins)
            view:setDataHuoBan(self.selectskin,self.data.skins)
        end)
    end
end
--查看更多皮肤信息
function HuobanPanel:onMoreMsg()
    -- body
    mgr.ViewMgr:openView(ViewName.HuobanOtherSkinView, function(view )
        -- body
        view:setData(self.superSelect)
    end,self.data)
end
--左右切换
function HuobanPanel:onChangeCallBack(context)
    -- body
    local data = context.sender.data
    if "n20" == data then
        if self.jie > 1 then
            self.jie = self.jie - 1
        end
    else
        if self.jie < self.maxTo then
            self.jie = self.jie + 1
        end
    end
    self:initModel(self.jie)
end

function HuobanPanel:onBtnBack()
    -- body
    self.parent:onSkinBack(0)
end

function HuobanPanel:onItemUse( context )
    -- body
    local mid 
    local data = context.sender.data

    local moduleConf 
    if self.superSelect == 0 then
        moduleConf = conf.SysConf:getModuleById(1006)
    elseif self.superSelect == 1 then
        moduleConf = conf.SysConf:getModuleById(1007)
    elseif self.superSelect == 2 then
        moduleConf = conf.SysConf:getModuleById(1008)
    elseif self.superSelect == 3 then
        moduleConf = conf.SysConf:getModuleById(1010)
    elseif self.superSelect == 4 then
        moduleConf = conf.SysConf:getModuleById(1009)
    end
    if "n34" == data then
        mid = moduleConf.zzd_mid
    else
        mid = moduleConf.qld_mid
    end
    
    mgr.ViewMgr:openView(ViewName.HuobanItemUse, function(view )
        -- body
        view:setData(self.superSelect)
    end, {mId = mid, hourse = self.data})
end
--领取 激活
function HuobanPanel:onGetCall()
    -- body
    proxy.HuobanProxy:send(1200107,{skinId = self.selectskin})
end
--特惠礼包提示按钮
function HuobanPanel:onClickTeHui()
    -- body
    local data = cache.ActivityCache:get5030111()
    if not data then
        GComAlter(language.acthall03)
        return
    end
    if data.acts[1026] and data.acts[1026] == 1 then
        GOpenView({id = 1028,childIndex = 1026})
    elseif data.acts[1032] and data.acts[1032] == 1 then
        GOpenView({id = 1028,childIndex = 1032})
    else
        GComAlter(language.acthall03)
    end
end

--百倍豪礼提示按钮
function HuobanPanel:onClickBaibei()
    -- body
    GOpenView({id = 1114})
    
end
--获取路径跳转
function HuobanPanel:onBtnget()
    -- body
    if self.getpath then
        local param = {}
        param.id = self.getpath[1]
        param.index = self.getpath[2]
        param.grandson = self.getpath[3]
        if param.id == 1114 then
            local data = cache.ActivityCache:get5030111()
            if cache.PlayerCache:getAttribute(30111) <= 0 then
                GComAlter(language.vip11)
                return
            end
            --print("param.grandson",param.grandson,"data.openDay",data.openDay)
            if data and data.openDay and data.openDay ~= param.grandson 
                and param.index < 9000 then
                GComAlter(language.gonggong92)
                return
            end
        elseif param.id == 1113 then
            local data = cache.ActivityCache:get5030111()
            if data and data.acts and data.acts[1037] == 1 then
            else
                -- if data and data.openDay and data.openDay <= 13 then
                --     GComAlter(language.kaifu53)
                --     return
                -- end

                GComAlter(language.vip11)
                return
            end
        elseif param.id == 1115 then
            local data = cache.ActivityCache:get5030111()
            if data and data.acts and data.acts[1042] == 1 then
            else
                -- if data and data.openDay and data.openDay <= 15 then
                --     GComAlter(language.kaifu59)
                --     return
                -- end

                GComAlter(language.vip11)
                return
            end
        end
        if param.id == 1228 or param.id == 1229 or param.id == 1230 or param.id == 1231 then
            local t = {
                [30142] = 1228,
                [30143] = 1229,
                [30144] = 1230,
                [30145] = 1231,
            }
            for i = 30142,30145 do
                local var = cache.PlayerCache:getRedPointById(i)
                if var > 0 then
                    param.id = t[i]
                    break
                end
            end
            GOpenView(param)
        else
            GOpenView(param)
        end
    end
end

function HuobanPanel:onBattle()
    -- body
    --if 
    local condata = conf.HuobanConf:getSkinsByIndex(self.selectskin,self.superSelect)
    local req = 0
    if self.isWear  then
        if condata.istshu == 2 and 0 == self.superSelect then
            req = 1
        else
            local t = {Skins.huoban,Skins.huobanxianyu,Skins.huobanshenbing,Skins.huobanfabao,Skins.huobanxianqi}
            GComAlter(language.huoban34[t[self.superSelect+1]])
            return
        end
    end

    if 0 == self.superSelect then
        proxy.HuobanProxy:send(1200105,{skinId = self.selectskin,reqType = req})
    elseif 1 == self.superSelect then
        proxy.HuobanProxy:send(1210105,{skinId = self.selectskin})
    elseif 2 == self.superSelect then
        proxy.HuobanProxy:send(1220106,{skinId = self.selectskin})
    elseif 3 == self.superSelect then
        proxy.HuobanProxy:send(1230105,{skinId = self.selectskin})
    elseif 4 == self.superSelect then
        proxy.HuobanProxy:send(1240105,{skinId = self.selectskin})
    end
end

function HuobanPanel:checkPoint( param,index )
    -- body
    local data 
    local nextdata 
    if index == 1 then
        data = conf.HuobanConf:getSkillLevData(param.id,param.lv,self.superSelect)
        nextdata = conf.HuobanConf:getSkillLevData(param.id,param.lv+1,self.superSelect)
    else
        data = conf.HuobanConf:getEquipLevData(param.id,param.lv,self.superSelect)
        nextdata = conf.HuobanConf:getEquipLevData(param.id,param.lv+1,self.superSelect)
    end
    if not data or not nextdata then
        return false
    end

    local flag = false
    local needlv = data.need_lev

    if needlv <= self.maxJie then --阶满足
        --local data.cost_items
        if data.cost_items then
            local itemMsg = cache.PackCache:getPackDataById(data.cost_items[1][1])
            if itemMsg.amount >= data.cost_items[1][2] then 
                flag = true
            end
        else
            flag = true
        end
    end

    if not self.isRed and flag then
        self.isRed = true
    end

    return flag
end

function HuobanPanel:refreshRed()
    -- HuobanPanel
    if not self.superSelect or not self.data then
        return 0
    end
    
    if self.imgRed1.visible or self.imgRed2.visible or self.isRed then
        return 1
    end 

    return 0
end

function HuobanPanel:checkIsHave(id)
    if not self.data then
        return false
    end
    --皮肤是否拥有
    for k ,v in pairs(self.data.skins) do
        if self.superSelect == 0 then
            if tonumber(v.skinId) == tonumber(id) and v.sign == 2 then
                return true
            end
        else
            if tonumber(v) == tonumber(id) then
                return true
            end
        end
    end

    return false
end

function HuobanPanel:onClickStar()
    if not self.confStarData then return end
    if not self:checkIsHave(self.confStarData.id) then
        GComAlter(language.fashion13)
        return
    end
    mgr.ViewMgr:openView2(ViewName.FashionStarView, self.confStarData)
end

return HuobanPanel