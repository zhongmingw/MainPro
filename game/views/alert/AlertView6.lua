--
-- Author: 
-- Date: 2017-02-17 17:33:49
--

local AlertView6 = class("AlertView6", base.BaseView)

function AlertView6:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function AlertView6:initData(data)
    -- body
    self.view:GetChild("n9").visible = true
    self.view:GetChild("n17").visible = true
    self.view:GetChild("n18").visible = true
    self.t0 = self.view:GetTransition("t0")
    self.buyNum = 1
    self:setData(data)
end

function AlertView6:initView()
    
    self.panel1 = self.view:GetChild("n34")
    local window4 = self.view:GetChild("n1")
    local btnClose = window4:GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.itemObj = self.view:GetChild("n13")
    self.itemName =  self.view:GetChild("n22")
    self.itemCount = self.view:GetChild("n29")

    local btnReduce = self.view:GetChild("n14")
    btnReduce.onClick:Add(self.onbtnReduce,self)
    local btnPlus = self.view:GetChild("n15")
    btnPlus.onClick:Add(self.onbtnPlus,self)
    local btnMax = self.view:GetChild("n16")
    btnMax.onClick:Add(self.onBtnMax,self)


    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    self.icon1 = self.view:GetChild("n27")
    self.icon2 = self.view:GetChild("n28")

    self.money1 = self.view:GetChild("n30")
    self.money2 = self.view:GetChild("n31")

    local btnBuy = self.view:GetChild("n19")
    btnBuy.onClick:Add(self.onbtnBuy,self)
    btnBuy.y = 348
    self.listView1 = self.view:GetChild("n20")
    self.listView1.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    if g_ios_test then  --EVE ios版属
        self.listView1.scaleX = 0
        self.listView1.scaleY = 0
    end 

    --
    self.grouCz = self.view:GetChild("n48")
    --self.grouCz.onClick:Add(self.onBtnClose,self)  --EVE 注释：触摸窗口外关闭窗口
    self.grouCz.visible = false
    local grouCzBtn = self.view:GetChild("n45")
    grouCzBtn.onClick:Add(self.onClickCz,self)
    self:initDec()
    self:initDec2()

    --EVE 添加关闭按钮
    local btnClose02 = self.view:GetChild("n53")
    btnClose02.onClick:Add(self.onBtnClose,self)
    --EVE end
end

function AlertView6:initDec()
    -- body
    self.itemName.text = ""
    self.itemCount.text = 1
    self.money1.text = 0
    self.money2.text = 0

    self.view:GetChild("n23").text = language.shop01
    self.view:GetChild("n24").text = language.shop02
    self.view:GetChild("n25").text = language.shop03
    self.view:GetChild("n21").text = language.shop04

    self.view:GetChild("n50").visible = false
    self.view:GetChild("n51").visible = false
    self.view:GetChild("n52").visible = false
end

function AlertView6:initDec2()
    self.panel2 = self.view:GetChild("n39")
    self.listView2 = self.view:GetChild("n33")
    self.listView2.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
end

function AlertView6:cellData(index,obj)
    local id = self.formview[index + 1]
    local data = conf.SysConf:getModuleById(id[1])
    local goBtnVisible = id and id[3] 
    local lab = obj:GetChild("n1")
    lab.text = data.desc
    local btn = obj:GetChild("n0")
    -- print("跳转>>>>>>>>>>",id[3],goBtnVisible)
    if not goBtnVisible or (goBtnVisible and goBtnVisible == 0) then
        btn.visible = true
    else
        btn.visible = false
    end
    btn.data = {data = data,id = id}
    btn.onClick:Add(self.onbtnGo,self)
end

function AlertView6:setData(data_)
    self.data = data_
    if self.data.mid then
        self.data.mId = self.data.mid
    end
    self.itemCount.text = 1
    if data_.index ~= 10 or not data_.index then--index=7为装备强化 特殊处理 10为伙伴
        self.buyPrice = conf.ItemConf:getBuyPrice(self.data.mId) or 0
        self:setMoneyNum()
        local param = {mid = self.data.mId,bind = 1}
        GSetItemData(self.itemObj,param)

        local condata = conf.ItemConf:getItem(self.data.mId)
        self.itemName.text = condata.name
        self.formview = conf.ItemConf:getFormview(self.data.mId)
        self.confType = conf.ItemConf:getBuyType(self.data.mId)
        if self.confType then
            self.panel2.visible = false
            self.panel1.visible = true
            self.icon2.visible = true
            self.money2.visible = true
            self.icon1.url = UIItemRes.moneyIcons[self.confType[1]]
            if #self.confType > 1 then
                self.icon2.url = UIItemRes.moneyIcons[self.confType[2]]
            else
                self.icon2.visible = false
                self.money2.visible = false
                self.view:GetChild("n9").visible = false
                self.buyType = 1
                self.c1.selectedIndex = 0
                self.view:GetChild("n17").visible = false
                self.view:GetChild("n18").visible = false
            end
            if self.formview then
            local len = #self.formview
                self.listView1.numItems = len
            end
            self:chooseBuyType()

            if self.view:GetChild("n18").visible then
                self.c1.selectedIndex = 1
            end
        else
            self.panel2.visible = true
            self.panel1.visible = false
            if self.formview then
            local len = #self.formview
                self.listView2.numItems = len
            end
        end
        -- if self.data.restTimes then
        --     self.view:GetChild("n52").text = self.data.restTimes
        -- end
        self.view:GetChild("n32").visible = true
        self.grouCz.x = 617
    else
        self.view:GetChild("n32").visible = false
    end
    
    --print("首充情况",GFirstChargeIsOpen(),GGetFirstChargeState(2),self.data.index)
    --print("每日首充情况",GGetDayChargeDayTimes()%9,GGetDayChargeState(3),self.data.index)
    
    self.view:GetChild("n32").x = 286
    self.grouCz.visible = false
    self.isDayCharge = true
    self.view:GetChild("n19").y = 348
    self.view:GetChild("n50").visible = false
    self.view:GetChild("n51").visible = false
    self.view:GetChild("n52").visible = false
    if self.data.index and self.data.index == 0 then --坐骑升级
        --玩家没有领取首充第二档的奖励
        -- self.view:GetChild("n19").y = 295
        -- self.view:GetChild("n50").visible = true
        -- self.view:GetChild("n51").visible = true
        -- self.view:GetChild("n52").visible = true
        self.isDayCharge = true
        local confData = conf.VipChargeConf:getDataById(self.data.index)
        if self.data.isGuide or(GGetDayChargeDayTimes() == 1 and GGetDayChargeState(confData.charge_grade)) then 
            self:setChargeSkip()
        end
    end
    if self.data.index and self.data.index == 3 then --仙羽
        --玩家没有领取首充第三档的奖励
        local confData = conf.VipChargeConf:getDataById(self.data.index)
        local i = GGetDayChargeDayTimes()%7
        if GGetDayChargeDayTimes() <= 7 then
            if GGetDayChargeDayTimes()%7 == 0 then i = 7 end
            if SkipType[i] == self.data.index and GGetDayChargeState(confData.charge_grade) then 
                self:setChargeSkip()
            end
        end
    end

    if self.data.index and self.data.index == 5 then --剑神
        --玩家没有领取首充第三档的奖励
        -- local confData = conf.VipChargeConf:getDataById(self.data.index)
        -- if GFirstChargeIsOpen() and self:checkBaiBei() then 
        --     self:setChargeSkip()
        -- end
    end

    if self.data.index and self.data.index == 6 then --装备升星
        --玩家没有领取首充第一档的奖励
        self.isDayCharge = false
        local confData = conf.VipChargeConf:getDataById(self.data.index)
        if GFirstChargeIsOpen() and not GGetFirstChargeState(confData.charge_grade) then 
            self:setChargeSkip()
        end
    end

    if self.data.index and self.data.index == 7 then --装备强化铜钱不足
        --玩家没有领取首充第一档的奖励
        -- self.isDayCharge = false
        local confData = conf.VipChargeConf:getDataById(self.data.index)
        -- if GFirstChargeIsOpen() and GGetDayChargeState(confData.charge_grade) then 
        -- print("首充档次",confData.charge_grade,GGetFirstChargeState(confData.charge_grade))
        if not GGetFirstChargeState(confData.charge_grade) then
            self:setChargeSkip()
        else
            self.grouCz.x = 380
        end
            -- self.grouCz.x = 380
            --self.view.onClick:Add(self.onBtnClose,self) --EVE 注释：触摸窗口外关闭窗口
        -- else
        --     GComAlter(language.gonggong05)
        --     self:closeView()
        --     return
        -- end
    end

    if self.data.index and self.data.index == 10 then --伙伴升级进阶
        -- --玩家没有领取首充第二档的奖励
        -- local confData = conf.VipChargeConf:getDataById(self.data.index)
        -- if GFirstChargeIsOpen() and GGetDayChargeState(confData.charge_grade) then 
        --     self:setChargeSkip()
        -- else
        --     self:closeView()
        --     return
        -- end
    end
    --开服2-8天对应每日首充奖励
    -- 2   神兵     index 1
    -- 4   法宝     index 2
    -- 5   伙伴仙羽 index 11
    -- 6   伙伴神兵 index 12
    -- 7   伙伴仙剑 index 14
    -- 8   伙伴法宝 index 13
    if self.data.index and self.data.index == 1 or self.data.index == 2 
    or self.data.index == 4 or self.data.index == 11 or  self.data.index == 12 
    or self.data.index == 13 or self.data.index == 14 then
        local confData = conf.VipChargeConf:getDataById(self.data.index)
        --print("开放内容",SkipType[GGetDayChargeDayTimes()%9])
        local i = GGetDayChargeDayTimes()%7
        if GGetDayChargeDayTimes() <= 7 then
            if GGetDayChargeDayTimes()%7 == 0 then i = 7 end
            if type(SkipType[i]) == "table" then
                if (SkipType[i][1] == self.data.index or SkipType[i][2] == self.data.index) and GGetDayChargeState(confData.charge_grade) then
                    self:setChargeSkip()
                end
            else
                if SkipType[i] == self.data.index and GGetDayChargeState(confData.charge_grade) then
                    self:setChargeSkip()
                end
            end
        end
    end
    --如果是提示展示的话
    if self.data.isShow then
        self.grouCz.x = 200
        if not  g_ios_test then  --EVE ios版属
            self.grouCz.visible = true
        end 
        self.view:GetChild("n32").visible = false
        --self.view.onClick:Add(self.onBtnClose,self)   --EVE 注释：触摸窗口外关闭窗口
    end
end

--设置充值跳转界面
function AlertView6:setChargeSkip()
    -- body
    local confData = conf.VipChargeConf:getDataById(self.data.index)
    self.view:GetChild("n32").x = 31
    if not  g_ios_test then  --EVE ios版属
        self.grouCz.visible = true
    end
    --设置美术字标题
    local titleImg = self.view:GetChild("n42")
    titleImg.url = UIPackage.GetItemURL("alert" , confData.img_src)
    local sqImg = self.view:GetChild("n49")
    local img = self.view:GetChild("n58")
    img.visible = false
    self.view:GetChild("n54").visible = false
    local node1 = self.view:GetChild("n59")
    node1.visible = false
    local cansee = false
    local effect_id = confData.effect_id
    if self.data.grade and type(confData.effect_id) == "table" then
        effect_id = confData.effect_id[self.data.grade]
        self.step = confData.charge_grade[self.data.grade]-1
    else
        self.step = confData.charge_grade-1
    end
    self.t0:Stop()
    if confData.img then
        if confData.id == 6 then--升星石sanshitiandenglu_062
            img.visible = true
            local icon = UIItemRes.activeIcons.."sanshitiandenglu_062"
            local check = PathTool.CheckResDown(icon..".unity3d")
            if check or g_extend_res == false then
                local url = UIItemRes.activeIcons.."sanshitiandenglu_062"
                img.url = url
            else
                img.url = nil--UIPackage.GetItemURL("activity" , "zaichongxianli_005")
            end
            local node = self.view:GetChild("n43")
            local effect = self:addEffect(4020202,node)
            effect.LocalPosition = Vector3(0,-0,200)
            node1.visible = true
            local effect = self:addEffect(4020203,node1)
        else
            sqImg.visible = true
            sqImg.url = UIPackage.GetItemURL("alert" , confData.img)
            self.view:GetChild("n55").visible = false
        end
    elseif effect_id then
        sqImg.visible = false
        local node = self.view:GetChild("n43")
        local modelObj = nil
        if type(effect_id) == "table" then
            modelObj,cansee = self:addModel(effect_id[1],node)
            cansee = modelObj:setSkins(nil,effect_id[2],effect_id[3])
            modelObj:modelTouchRotate(self.grouCz)
            local pos = confData.pos
            local xyz = confData.xyz
            modelObj:setRotationXYZ(xyz[1],xyz[2],xyz[3])
            modelObj:setScale(confData.scale)
            modelObj:setPosition(pos[1], pos[2], pos[3])
        elseif type(effect_id) == "number" then
            modelObj,cansee = self:addModel(effect_id,node)
            local pos = confData.pos
            local xyz = confData.xyz
            if confData.id == 3 then
                cansee = modelObj:setSkins(GuDingmodel[1],nil,effect_id)
            elseif confData.id == 11 then
                cansee = modelObj:setSkins(GuDingmodel[2],nil,effect_id)
            elseif confData.id == 10 then
                self.view:GetChild("n54").visible = true
            end
            modelObj:setRotationXYZ(xyz[1],xyz[2],xyz[3])
            modelObj:setScale(confData.scale)
            modelObj:setPosition(pos[1], pos[2], pos[3])
        elseif type(effect_id) == "string" then
            local effectId = string.sub(effect_id,1,7)
            if confData.id ~= 12 then--灵兵没有动效
                self.t0:Play()
            end
            if confData.id == 1 then
                modelObj,cansee = self:addModel(GuDingmodel[3],node)
                modelObj:addModelEct(effect_id)
                local pos = confData.pos
                local xyz = confData.xyz
                modelObj:setScale(confData.scale)
                modelObj:setPosition(pos[1], pos[2], pos[3])
                modelObj:setRotationXYZ(xyz[1],xyz[2],xyz[3])
            elseif confData.id == 12 then
                modelObj,cansee = self:addModel(GuDingmodel[2],node)
                modelObj:addWeaponEct(effect_id)
                local pos = confData.pos
                local xyz = confData.xyz
                modelObj:setRotationXYZ(xyz[1],xyz[2],xyz[3])
                modelObj:setScale(confData.scale)
                modelObj:setPosition(pos[1], pos[2], pos[3])
            elseif tonumber(effectId) then
                local effect = self:addEffect(effectId,node)
                local pos = confData.pos
                effect.LocalPosition = Vector3(pos[1],pos[2],pos[3])
                effect.Scale = Vector3.New(confData.scale, confData.scale, confData.scale)
            end
        end
        self.view:GetChild("n55").visible = cansee
    end
end

function AlertView6:onController1()
    self:chooseBuyType()
end

function AlertView6:chooseBuyType()
    local selectedIndex = self.c1.selectedIndex
    self.buyType = self.confType[selectedIndex + 1]
    self:setMoneyNum()
end
--减
function AlertView6:onbtnReduce()
    self.buyNum = self.buyNum - 1
    if self.buyNum <= 1 then
        self.buyNum = 1
        GComAlter(language.gonggong14)
    end
    self.itemCount.text = self.buyNum
    self:setMoneyNum()
end
--加
function AlertView6:onbtnPlus()
    self.buyNum = self.buyNum + 1
    -- print("购买类型",self.buyType)
    local money = cache.PlayerCache:getTypeMoney(self.buyType)
    local maxNum = math.floor(money / self.buyPrice)
    -- if self.data.index == 0 then--坐骑时间道具特殊处理
    --     maxNum = self.data.restTimes>0 and self.data.restTimes or 1
    -- end
    if money < self.buyPrice then
        self.buyNum = 1
        --plog("self.buyType",self.buyType)
        GComAlter(string.format(language.gonggong17, language.money[self.buyType]))
    elseif self.buyNum >= maxNum then
        self.buyNum = maxNum
        GComAlter(language.forging32)
    end
    self.itemCount.text = self.buyNum
    self:setMoneyNum()
end

function AlertView6:setMoneyNum()
    self.itemCount.text = self.buyNum
    local selectedIndex = self.c1.selectedIndex
    self.money1.text = 0
    self.money2.text = 0
    local price = self.buyNum * self.buyPrice
    self.money1.text = price
    self.money2.text = price
    -- if selectedIndex == 0 then
    --     self.money1.text = price
    -- else
    --     self.money2.text = price
    -- end
end

function AlertView6:onBtnMax()
    local money = cache.PlayerCache:getTypeMoney(self.buyType)
    --plog(money,self.buyPrice)
    if money < self.buyPrice then
        GComAlter(string.format(language.gonggong17, language.money[self.buyType]))
    else
        local maxNum = math.floor(money / self.buyPrice)
        -- if self.data.index == 0 then--坐骑时间道具特殊处理
        --     maxNum = self.data.restTimes>0 and self.data.restTimes or 1
        -- end
        self.buyNum = math.max(1,maxNum) --避免错误 至少给1个
        self:setMoneyNum()
    end
end

function AlertView6:onbtnBuy()
    proxy.ShopProxy:send(1090102,{itemId = self.data.mId,buyNum = self.buyNum,buyType = self.buyType})
    self:onBtnClose()
    
    -- plog(self.data.mId,self.buyNum,self.buyType)
    -- if self.data.mId == 221041504 then
    --     local restTimes = self.data.restTimes or 0
    --     if restTimes >= self.buyNum then --次数足够
    --         proxy.ShopProxy:send(1090105,{reqType = 1,amount = self.buyNum,mid = self.data.mId})
    --     else
    --         local bol = false
    --         for i=1,3 do
    --             if not cache.PlayerCache:VipIsActivate(i) then
    --                 bol = true
    --             end
    --         end
    --         if bol then
    --             local param = {}
    --             param.type = 2
    --             if g_ios_test then    --EVE 屏蔽处理，提示字符更改
    --                 param.richtext = language.gonggong76
    --             else
    --                 param.richtext = language.zuoqi72
    --             end
    --             param.sure = function(  )
    --                 GGoVipTequan(2,1)
    --                 self:closeView()
    --             end
    --             GComAlter(param)

    --             -- local param = {}
    --             -- param.type = 5 
    --             -- param.titleIcon = UIItemRes.zuoqi2
    --             -- param.richtext = language.zuoqi10
    --             -- param.sure = function(  )
    --             --     -- body
    --             --    GGoVipTequan(2,1)
    --             --    self:closeView()
    --             -- end
    --             -- GComAlter(param)
    --         else
    --             local param = {}
    --             param.type = 5 
    --             param.titleIcon = UIItemRes.zuoqi2
    --             param.richtext = language.zuoqi10
    --             param.sure = function(  )
    --                 -- body
    --                self:closeView()
    --             end
    --             GComAlter(param)
    --             --GComAlter(language.store08)
    --         end
    --     end
    -- else
    --     proxy.ShopProxy:send(1090102,{itemId = self.data.mId,buyNum = self.buyNum,buyType = self.buyType})
    -- end
    -- self:onBtnClose()
end

--检测剑神是否可以跳转百倍豪礼
function AlertView6:checkBaiBei()
    if cache.PlayerCache:getRedPointById(attConst.A30111)<=0 then
        return false
    end
    local data = cache.ActivityCache:get5030111()
    if not data then
        return false
    end

    local condata = conf.SysConf:getHwbSBItem("jiansheng0")
    if not condata then
        return false
    end
    local curday = data.openDay % 9
    if condata.open_day and curday  ~= condata.open_day then--有天数 要求
        return false
    end
    
    --没有购买要求
    if not condata.buy_danci then
        return false
    end
    local _in = clone(condata.buy_danci)
    if not condata.open_day then
        _in = {condata.buy_danci[curday] or condata.buy_danci[9]}
    end
    --printt(_in)
    --检测是否购买了要求物品
    local key = g_var.accountId.."3010buy"
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
        return falg
    else
        return true
    end
end

function AlertView6:onbtnGo(context)
    -- body
    local data = context.sender.data.data
    local childIndex = context.sender.data.id[2]
    local param = {id = data.id,childIndex = childIndex }
    GOpenView(param)
end

function AlertView6:onClickCz()
    -- body
    local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
    if view then
        view:onClickClose()
    end
    if self.data.isDayFirst then
        GOpenView({id = 1056,index = self.step})
    else
        if self.isDayCharge then
            -- print("跳转页签",self.step)
            if self.data.index == 5 then--剑神
                GOpenView({id = 1114,index = 9998})
            else
                GOpenView({id = 1056,index = self.step})
            end
        else
            GOpenView({id = 1054,index = self.step})
        end
    end
end

function AlertView6:onBtnClose()
    -- body
    -- if self.data.isGuide then
    --     local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
    --     if view then
    --         view:setGoonGuide(self.data.isGuide)
    --     end
    -- end

    self:closeView()
end

-- --EVE 关闭窗口  
-- function AlertView6:onClickClose02()
--     --self:closeView()
--     local rightWindow = self.view:GetChild("n48")
--     rightWindow.visible = false
-- end

return AlertView6