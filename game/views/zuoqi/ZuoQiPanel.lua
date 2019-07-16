--
-- Author: 
-- Date: 2017-02-13 14:37:59
--

local ZuoQiPanel = class("ZuoQiPanel",import("game.base.Ref"))
local redpoint = {10216,10207,10210,10208,10209}
function ZuoQiPanel:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n9")
    --self.view.visible = true
    
    self:initView()
end

function ZuoQiPanel:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.setItemMsg,self)

    self.t0 = self.view:GetTransition("t0")

    self.name = self.view:GetChild("n48") 
    self.iconJie = self.view:GetChild("n12") 
    --骑乘
    self.btn1 = self.view:GetChild("n17")
    self.btnTitle = self.btn1:GetChild("title")
    self.btn1.onClick:Add(self.onQiCallBack,self)
    --
    self.tojie = self.view:GetChild("n49")

    --
    self.pageBefor = self.view:GetChild("n20")
    self.pageBefor.data = "n20"
    self.pageBefor.onClick:Add(self.onChangeCallBack,self)
    self.pageNext = self.view:GetChild("n19")
    self.pageNext.data = "n19"
    self.pageNext.onClick:Add(self.onChangeCallBack,self)
    --
    self.rightbtn1 = self.view:GetChild("n34")
    self.rightbtn1.data = "n34"
    self.rightbtn1.onClick:Add(self.onItemUse,self)
    self.rightbtn2 = self.view:GetChild("n35")
    self.rightbtn2.data = "n35"
    self.rightbtn2.onClick:Add(self.onItemUse,self)
    --
    self.btnMore = self.view:GetChild("n21")
    if g_ios_test then       --EVE 屏蔽特殊皮肤
        self.btnMore.visible = false
    else
        self.btnMore.data = "n21"
        self.btnMore.onClick:Add(self.onMoreMsg,self)
    end 

    self.dec1 = self.view:GetChild("n22")
    self.dec2 = self.view:GetChild("n23")
    self.labPower = self.view:GetChild("n50")
    self.labitem1 = self.view:GetChild("n24")
    self.labitem2 = self.view:GetChild("n25")

    self.imgRed1 = self.view:GetChild("n51")
    self.imgRed2 = self.view:GetChild("n52")
    --技能
    self.list1 = self.view:GetChild("n30")
    self.list1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list1.numItems = 0
    self.list1.onClickItem:Add(self.onCallBackItem,self)
    --装备
    self.list2 = self.view:GetChild("n31")
    self.list2.itemRenderer = function(index,obj)
        self:celldata2(index, obj)
    end
    self.list2.numItems = 0
    self.list2.onClickItem:Add(self.onCallBackItem2,self)

    --模型
    self.model = self.view:GetChild("n37")
    --激活条件
    self.c1Jihuo = self.view:GetChild("n44")
    --激活or限时标题
    self.jihuoImg = self.view:GetChild("n41")
    --获取跳转
    local btnget = self.view:GetChild("n57") 
    btnget.onClick:Add(self.onBtnget,self)
    self.btnget = btnget
    --返回按钮
    local btnBack = self.view:GetChild("n46")
    btnBack.onClick:Add(self.onBtnBack,self)
    --活动提示按钮
    self.signBtn = self.view:GetChild("n53")
    self.signBtn.data = self.signBtn.xy
    self.signBtn.onClick:Add(self.onClickSign,self)
    --特惠提示按钮
    self.TehuiBtn = self.view:GetChild("n59")
    self.TehuiBtn.data = self.TehuiBtn.xy
    self.TehuiBtn.onClick:Add(self.onClickTeHui,self)
    --百倍豪礼提示按钮
    self.BaibeiBtn = self.view:GetChild("n60")
    self.BaibeiBtn.data = self.BaibeiBtn.xy
    self.BaibeiBtn.onClick:Add(self.onClickBaibei,self)

    self.modelsee = self.view:GetChild("n58")

    self.starBtn = self.view:GetChild("n65")--升星
    self.starBtn.onClick:Add(self.onClickStar,self)
    if g_is_banshu then
        self.signBtn:SetScale(0,0)
        self.imgRed1:SetScale(0,0)
        self.imgRed2:SetScale(0,0)
        if not g_ios_test then
            self.btnMore:SetScale(0,0)
        end
        self.modelsee:SetScale(0,0)
    elseif g_ios_test then   --EVE ios版属屏蔽
        self.signBtn.scaleX = 0
        self.signBtn.scaleY = 0   
    end
end

function ZuoQiPanel:setBaibeiVisible()
    -- body
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
    local condata = conf.SysConf:getHwbSBItem("zuoqi"..self.superSelect)
    if not condata then
        return
    end
    local curday = data.openDay % 9
    if condata.open_day and curday  ~= condata.open_day then--有天数 要求
        return
    end
    --没有购买要求
    if not condata.buy_danci then
        self.BaibeiBtn.visible = false
        return
    end
    local _in = clone(condata.buy_danci)
    if not condata.open_day then
        _in = {condata.buy_danci[curday] or condata.buy_danci[9]}
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

function ZuoQiPanel:setTehuiBtnVisible()
    -- body
    if g_ios_test then
        self.TehuiBtn.visible = false
        return
    end 
    self.TehuiBtn.visible = false
    local data = cache.ActivityCache:get5030111()
    if not data then
        return
    end
    local condata = conf.SysConf:getHwbSBItem("zuoqi"..self.superSelect)
    if not condata then
        return
    end
    local curday = data.openDay % 9
    if condata.open_day and curday  ~= condata.open_day then--有天数 要求
        return
    end
    --没有购买要求
    if not condata.buy_id then
        self.TehuiBtn.visible = false
        return
    end
    --
    local _in = clone(condata.buy_id)
    if not condata.open_day then
        _in = {condata.buy_id[curday] or condata.buy_id[9]}
    end



    --检测是否购买了要求物品
    local key = g_var.accountId.."1026buy"
    local _localbuy = UPlayerPrefs.GetString(key)
    --plog("今天已将购买",_localbuy)
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
function ZuoQiPanel:setSignBtnVisible()
    -- body
    if g_ios_test then
        self.signBtn.visible = false
        return
    end 
    local index = self.superSelect
    local confData = conf.VipChargeConf:getDataById(index)
    if index == 0 then
        -- print("每日首充",GGetDayChargeState(confData.charge_grade),confData.charge_grade)
        if GGetDayChargeDayTimes() == 1 and GGetDayChargeState(confData.charge_grade) then 
            self.signBtn.visible = true
        else
            self.signBtn.visible = false
        end
    else
        local openDay = cache.ActivityCache:get5030111().openDay
        if openDay > 7 then
            self.signBtn.visible = false
            return
        end
        if SkipType[GGetDayChargeDayTimes()%7] == index and GGetDayChargeState(confData.charge_grade) then
            self.signBtn.visible = true
        else
            self.signBtn.visible = false
        end
    end
end

function ZuoQiPanel:clear()
    -- body
    self.dec1.text = ""
    self.dec2.text = ""
    self.labPower.text = 0
    self.btnTitle.text = ""
    self.labitem1.text = 0
    self.labitem2.text = 0
end

function ZuoQiPanel:initDec()
    -- body
    --self:clear()
    if 0 == self.superSelect then
        self.dec1.text = language.zuoqi02
        self.dec2.text = language.zuoqi03
        self.btnTitle.text = language.zuoqi04
    elseif 3 == self.superSelect then
        self.btnTitle.text = language.zuoqi28
        self.dec1.text = language.zuoqi29
        self.dec2.text = language.zuoqi30
        self.c1Jihuo.text = ""
    elseif 1 == self.superSelect then
        self.btnTitle.text = language.zuoqi28
        self.dec1.text = language.zuoqi39
        self.dec2.text = language.zuoqi40
        self.c1Jihuo.text = ""
    elseif 2 == self.superSelect then
        self.btnTitle.text = language.zuoqi28
        self.dec1.text = language.zuoqi41
        self.dec2.text = language.zuoqi42
        self.c1Jihuo.text = ""
    elseif 4 == self.superSelect then
        self.btnTitle.text = language.zuoqi28
        self.dec1.text = language.zuoqi43
        self.dec2.text = language.zuoqi44
        self.c1Jihuo.text = ""
    elseif 5 == self.superSelect then
        self.btnTitle.text = language.zuoqi28
        self.dec1.text = language.zuoqi78
        self.dec2.text = language.zuoqi79
        self.c1Jihuo.text = ""
    end
end

function ZuoQiPanel:celldata(index,obj)
    -- body
    local data = self.leftData[index+1]

    local icon = obj:GetChild("n2")
    local labLv = obj:GetChild("n3")
    icon.url = ResPath.iconRes(data.icon) --UIPackage.GetItemURL("_icons" , ""..data.icon)

    local lv = self.data.skills[data.id]
    labLv.text = "Lv ".. (lv or "")
    local c1 = obj:GetController("c1")
    c1.selectedIndex = (lv and lv > 0) and 0 or 1
    obj.data = {id = data.id,lv = lv or 0 ,maxjie = self.maxJie}


    local redimg = obj:GetChild("n4")
    redimg.visible = false
    --计算技能是否可以升级
    redimg.visible = self:checkPoint(obj.data,1)
    
end
--技能列表选择
function ZuoQiPanel:onCallBackItem( context )
    -- body
    local data = context.data.data
    self.parent:callLeftItem(data)
end

--list2
function ZuoQiPanel:celldata2(index,obj)
    -- body
    local frame = obj:GetChild("n4")
    local icon = obj:GetChild("n1") 
    local labLv = obj:GetChild("n2")

    local data = self.rightData[index+1]
    local lv = self.data.equips[data.id]
    
    frame.url = UIItemRes.beibaokuang[data.color]
    icon.url = ResPath.iconRes(data.icon)-- UIPackage.GetItemURL("_icons" , ""..data.icon)
    local lv  = lv and lv or 0 
    if lv > 1 then
        labLv.text = "+"..(lv - 1)
    else
        labLv.text = ""
    end

    local c1 = obj:GetController("c1")
    c1.selectedIndex = lv>0 and 0 or 1

    obj.data = {id =data.id,lv = lv or 0 ,maxjie = self.maxJie }

    local redimg = obj:GetChild("n5")
    redimg.visible = false
    --计算装备是否可以升级
    redimg.visible = self:checkPoint(obj.data,2)
end
--列表选择
function ZuoQiPanel:onCallBackItem2( context )
    -- body
    local data = context.data.data
    self.parent:callRightItem(data)
end

function ZuoQiPanel:setbtnTitle(data)
    -- body
    if data and data.reqType == 1 then -- 特殊皮肤拖操作
    end
    local t = {Skins.zuoqi,Skins.shenbing,Skins.fabao,Skins.xianyu,Skins.xianqi,Skins.qilinbi}
    local var = t[self.superSelect+1]
    local id = cache.PlayerCache:getSkins(var) --当前选择
    --plog(id,"id",self.modle_id)
    if id == self.modle_id then
        self.btnTitle.text = language.zuoqi67[t[self.superSelect+1]][2]
        self.isWear = true
    else
        self.isWear = false
        self.btnTitle.text =language.zuoqi67[t[self.superSelect+1]][1]
    end
end

--
function ZuoQiPanel:initModel(index,isid)
    -- body
    self.modelIndex = index
    local confData = conf.ZuoQiConf:getSkinsByIndex(index,self.superSelect)--升星
    local starPre = confData and confData.star_pre or 0
    if starPre > 0 then
        self.starBtn.visible = true
    else
        self.starBtn.visible = false
    end
    self.confStarData = confData

    local condata
    --形象
   -- plog(index,isid)
    if not isid then --不是特使皮肤
        self.c1.selectedIndex = 0
        condata = conf.ZuoQiConf:getSkinsByJie(index,self.superSelect)
        
        if index <= self.maxJie then
            self.tojie.text = ""
            
            if self.data.lev > 0 then
                self.btn1.visible  = true
            else
                --self.tojie.text = string.format(language.zuoqi60,index)
                self.btn1.visible  = false
            end
        else
            self.tojie.text = string.format(language.zuoqi60,index)
            self.btn1.visible  = false
        end
    else--特殊皮肤
        condata = conf.ZuoQiConf:getSkinsByIndex(index,self.superSelect)
    end

    local panel = self.model:GetChild("n0")
    local touc = self.model:GetChild("n1")
    local node = self.model:GetChild("n2")

    if self.effect1 then
        self.parent:removeUIEffect(self.effect1)
    end
    self.cansee = false
    if self.superSelect == 0 or self.superSelect == 3 then
        self.t0:Stop()

        touc.touchable = true
        --移除特效
        self.parent:removeUIEffect(self.effect)
        self.effect = nil 
        
        --添加模型
        if not self.model.data then
            self.model.data,self.cansee = self.parent:addModel(condata.modle_id,panel)
        end

        if self.superSelect == 3 then
            self.cansee = self.model.data:setSkins(GuDingmodel[1],nil,condata.modle_id)
        else
            self.cansee = self.model.data:setSkins(condata.modle_id)
        end

        --移除神兵特效
        self.model.data:removeModelEct()

        self.model.data:modelTouchRotate(touc)
        

        self.effect1 = self.parent:addEffect(4020102,node)
        if self.superSelect == 3 then
            self.model.data:setScale(SkinsScale[Skins.xianyu])
            self.model.data:setRotationXYZ(0,341,0)--180
            self.model.data:setPosition(panel.actualWidth/2,-panel.actualHeight-200,500)

            self.effect1.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight,500)
        else
            if condata.modle_id == 3040311 then--帝王坐骑特殊处理
                self.model.data:setScale(80)
            elseif condata.modle_id == 3040314 then--帝王坐骑特殊处理
                self.model.data:setScale(100)
            elseif condata.scale then
                self.model.data:setScale(condata.scale )
            else
                self.model.data:setScale(SkinsScale[condata.modle_id] or SkinsScale[Skins.zuoqi])
            end
            if condata.modle_id == 3040308 then--天剑特殊处理bxp
                self.model.data:setRotationXYZ(19,90,331)
            else
                self.model.data:setRotationXYZ(0,130,0)
            end

            if condata.dongzuo then
                self.t0:Play()
            end
            local offx = condata.offect_xy and condata.offect_xy[1] or 0
            local offy = condata.offect_xy and condata.offect_xy[2] or 0
            local z = condata.offect_xy and condata.offect_xy[3] or 500
			if  condata.offect_xy then
				self.model.data:setPosition(offx,offy,z)
			else
				self.model.data:setPosition(panel.actualWidth/2,-panel.actualHeight-160,500)
			end
            self.effect1.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight+40 ,500)
        end
         --脚底特效
        
            

        if condata.xyz then
            self.model.data:setRotationXYZ(condata.xyz[1],condata.xyz[2],condata.xyz[3])--180
        end
    elseif self.superSelect == 2 or self.superSelect == 4   then
        touc.touchable = false
        --移除模型
        self.parent:removeModel(self.model.data)
        self.model.data = nil 
        --移除神兵特效
        local flag = false
        if not self.modle_id  then
            flag = true
        elseif self.modle_id~=condata.modle_id then
            flag = true
        elseif self.modle_id == condata.modle_id  then
            flag = false
        end
        if flag then
            if self.effect then
                self.parent:removeUIEffect(self.effect)
                self.effect = nil 
            end
            self.effect = self.parent:addEffect(condata.modle_id,panel)
            --print("condata.modle_id",condata.modle_id)
            if self.superSelect == 2 then
                self.t0:Play()
                self.effect.Scale = Vector3.New(300,300,300)
                self.effect.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-50,500)

            elseif self.superSelect == 4 then  
                self.t0:Stop()
                local offx = condata.offect_xy and condata.offect_xy[1] or 0
                local offy = condata.offect_xy and condata.offect_xy[2] or 0
                local z = condata.offect_xy and condata.offect_xy[3] or 500
                if  condata.offect_xy then
                    self.effect.LocalPosition = Vector3(offx,offy,z)
                else
                    self.effect.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-100,500)
                end
                if condata.scale then
                    self.effect.Scale = Vector3.New(condata.scale,condata.scale,condata.scale)
                end
            elseif self.superSelect == 5 then
                self.t0:Play()
                self.effect.Scale = Vector3.New(300,300,300)
                self.effect.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-50+200,500)
            end

            --特殊旋转
            if condata.xuanzhuan then
                self.effect.LocalRotation = Vector3.New(condata.xuanzhuan[1],condata.xuanzhuan[2],condata.xuanzhuan[3])--180
            end
        end
    elseif self.superSelect == 5 then
        self.t0:Stop()
        touc.touchable = true

        self.parent:removeModel(self.model.data)
        self.model.data = nil 
        self.model.data,self.cansee = self.parent:addModel(GuDingmodel[1],panel)

        self.model.data:setPosition(225,-653.8,500)
        self.model.data:setRotationXYZ(0,168.9,0)
        self.model.data:setScale(SkinsScale[Skins.wuqi])
        
        self.model.data:addQingbiEct(condata.modle_id.."_ui")
        self.model.data:modelTouchRotate(touc)

        self.effect1 = self.parent:addEffect(4020102,node)
        self.effect1.LocalPosition = Vector3(node.actualWidth/2,-448.9 ,500)
    else
        --plog("dunsss")
        self.t0:Play()
        touc.touchable = false
        local useid = cache.PlayerCache:getSkins(Skins.wuqi)
        if useid == 0 then
            useid =  GuDingmodel[3]
        end
        self.parent:removeModel(self.model.data)
        self.model.data = nil 
        self.model.data,self.cansee = self.parent:addModel(useid,panel)

        self.model.data:setPosition(panel.actualWidth/2+50,-330,500)
        self.model.data:setRotationXYZ(30,90,90)
        self.model.data:setScale(SkinsScale[Skins.wuqi])
        
        self.model.data:addModelEct(condata.modle_id.."_ui")
    end

    self.modelsee.visible = self.cansee 

    self.name.text = condata.name
    self.iconJie.url = UIItemRes.jieshu[condata.grow_cons] or nil
    self.c1Jihuo.text = condata.desc

    --左右箭头
    if not isid  then
        if index < self.maxTo then
            --self.pageBefor
            self.pageNext.visible = true
        else
            self.pageNext.visible = false
        end

        if index > 1 then
            self.pageBefor.visible = true
        else
            self.pageBefor.visible = false
        end
    else
        self.pageNext.visible = false
        self.pageBefor.visible = false

        local flag = false
        self.isXianShi = false
        --皮肤是否拥有
        -- printt("激活限时>>>>>>>>>>>>>>",self.data.skins)
        for k ,v in pairs(self.data.skins) do
            if v.skinId == condata.id then
                self.c1.selectedIndex = 1
                flag = true
                if v.skinType == 1 then
                    self.isXianShi = true
                    self.endTime = v.lastTime
                end
                break
            end
        end

        self.btn1.visible  = flag

        if not flag then
            self.c1.selectedIndex = 2
            self.jihuoImg.url = UIPackage.GetItemURL("zuoqi" , "huoban_024")
        end
        if flag and self.isXianShi then
            self.c1.selectedIndex = 3
            self.starBtn.visible = false
            self.jihuoImg.url = UIPackage.GetItemURL("zuoqi" , "zuoqi_027")
            local netTime = mgr.NetMgr:getServerTime()
            self.c1Jihuo.text = GGetTimeData2(self.endTime-netTime)
        end
    end


    self.selectskin = condata.id
    self.modle_id = condata.modle_id
    self.getpath = condata.tab_type
    if self.getpath then
        self.btnget.visible = true
    else
        self.btnget.visible = false
    end

    self:setbtnTitle()
end
--关闭界面设置nil
function ZuoQiPanel:setSelfmodle_id()
    self.modle_id = nil
end

function ZuoQiPanel:onTimer()
    if self.endTime and self.isXianShi then
        local netTime = mgr.NetMgr:getServerTime()
        if self.endTime-netTime > 0 then
            self.c1Jihuo.text = GGetTimeData2(self.endTime-netTime)
        else
            self.c1.selectedIndex = 2
            self.isXianShi = false
            self.jihuoImg.url = UIPackage.GetItemURL("zuoqi" , "huoban_024")
            if self.modelIndex then
                local condata = conf.ZuoQiConf:getSkinsByIndex(self.modelIndex,self.superSelect)
                self.c1Jihuo.text = condata.desc
            end
        end
    end
end

function ZuoQiPanel:initSkill( data )
    -- body
    table.sort(self.leftData,function (a,b)
        -- body
        return a.id < b.id
    end)
    local number = #self.leftData
    self.list1.numItems = number
end

function ZuoQiPanel:initEquip()
    -- body
    table.sort(self.rightData,function (a,b)
        -- body
        return a.id < b.id
    end)
    local number = #self.rightData
    self.list2.numItems = number
end


function ZuoQiPanel:setItemMsg()
    -- body
    self.labitem1.text = self.data.zzdNum
    self.labitem2.text = self.data.qldNum
    self.imgRed1.visible = false
    self.imgRed2.visible = false
    --plog("self.c1.selectedIndex",self.c1.selectedIndex)
    if self.c1.selectedIndex == 0 and self.data.lev > 0 then
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

--self.data.index    0 = 坐骑，
function ZuoQiPanel:setData(param)
    -- body
    self.isRed = false --是否有红点

    self.superSelect = self.parent.c1.selectedIndex
    --
    self.maxTo = conf.ZuoQiConf:getValue("endmaxjie",self.superSelect) or 10
    --print("self.maxTo",self.maxTo)

    self.oldSelect = self.superSelect
    self.data = param
    --当前最大阶
    local confData = conf.ZuoQiConf:getDataByLv(param.lev,self.superSelect)
    self.maxJie = confData and confData.jie or 1 --默认是1阶开始
    if self.maxJie < 1 then
        self.maxJie = 1
    end
    --技能信息
    self.leftData = conf.ZuoQiConf:getSkillData(self.superSelect)
    self:initSkill()
    --装备信息
    self.rightData = conf.ZuoQiConf:getEquipData(self.superSelect)
    self:initEquip()
    ----丹药
    local t = {1001,1003,1005,1002,1004,1287}
    self.moduleConf = conf.SysConf:getModuleById(t[self.superSelect+1])
    self:setItemMsg()

    --战斗力
    self:initDec()
    if self.data.lev == 0 then
        local p1 = conf.ZuoQiConf:getDataByLv(1,self.superSelect)
        self.labPower.text = p1.power
    else
        self.labPower.text = self.data.power 
    end
    local t = {
        [0] = "juesezuoqi_025",
        [1] = "jueseshenbin_005",
        [2] = "juesefabao_004",
        [3] = "juesexianyu_007",
        [4] = "juesexianqi_004",
    }
    if not g_ios_test  then  --EVE 
        if t[self.superSelect] then
            self.btnMore.icon = UIPackage.GetItemURL("zuoqi" ,t[self.superSelect])
            self.btnMore.visible = true
        else
            self.btnMore.visible = false
        end
    end
    --计算左上角按钮显示
    self:setLeftTopVis()

    if self.superSelect == 5 then
        self.rightbtn1.icon = ResPath.iconRes(221071328) 
        self.rightbtn2.icon = ResPath.iconRes(221071329) 
    else
        self.rightbtn1.icon = UIPackage.GetItemURL("zuoqi" ,"huoban_018") 
        self.rightbtn2.icon = UIPackage.GetItemURL("zuoqi" ,"huoban_019") 
    end
   
end
function ZuoQiPanel:setLeftTopVis()
    -- body
     --进阶活动
    self:setSignBtnVisible()
    if g_ios_test then
        self.TehuiBtn.visible = false
        self.BaibeiBtn.visible = false
    else
        --特惠礼包
        self.TehuiBtn.visible =  self.parent:checkTehui(self.superSelect)
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

--4、进入坐骑标签，默认显示进阶形象中当前阶的形象
function ZuoQiPanel:selectCur(flag,maxjie,mid)
    -- body
    --当前坐骑信息
    --4,2,5,3,6
    local id 

    if 0 == self.superSelect then
        id = cache.PlayerCache:getSkins(Skins.zuoqi)
    elseif 3 == self.superSelect then
        id = cache.PlayerCache:getSkins(Skins.xianyu)
    elseif 1 == self.superSelect then
        id = cache.PlayerCache:getSkins(Skins.shenbing)
    elseif 2 == self.superSelect then
        id = cache.PlayerCache:getSkins(Skins.fabao)
    elseif 4 == self.superSelect then
        id = cache.PlayerCache:getSkins(Skins.xianqi)
    elseif 5 == self.superSelect then
        id = cache.PlayerCache:getSkins(Skins.qilinbi)
    end

    -- --特殊处理选择了特殊皮肤也不选择特殊皮肤
    -- local info = conf.ZuoQiConf:getSkinsByModle(id,self.superSelect)
    -- if info and not info.grow_cons then
    --     --强制修改id 
    --     local wpsb = conf.ZuoQiConf:getSkinsByJie(self.maxJie,self.superSelect)
    --     id = wpsb.modle_id
    --     return
    -- end
   
    
    local confData = conf.ZuoQiConf:getSkinsByModle(id,self.superSelect)
    -- if confData and not confData.grow_cons then
    --     --特殊皮肤
    --     self:initModel(confData.id,true)
    --     return
    -- end

    if flag then --选择上次选择的
        self:initModel(self.jie or 1)
        return 
    end

    local jie = confData and confData.grow_cons or nil
   -- plog("jie",jie)
    if jie and jie > 0 and jie < self.maxTo then --当前
        self.jie = jie
    else
        self.jie = self.maxJie
    end

    if maxjie then
        self.jie = self.maxJie
    end
    self:initModel(self.jie)
end

--骑乘
function ZuoQiPanel:onQiCallBack()
    -- body
    if self.data.lev == 0 then
        GComAlter(language.zuoqi68)
        return
    end

    if self.isWear  then
        local t = {Skins.zuoqi,Skins.shenbing,Skins.fabao,Skins.xianyu,Skins.xianqi}
        GComAlter(language.zuoqi69[t[self.superSelect+1]])
        return
    end

    if 0 == self.superSelect then
        local param = {}
        param.skinId = self.selectskin
        param.reqType = 1
        proxy.ZuoQiProxy:send(1120105,param)
    else
        local param = {}
        param.skinId = self.selectskin
        if 3 == self.superSelect then
            proxy.ZuoQiProxy:send(1140105,param)
        elseif 1 == self.superSelect then
            proxy.ZuoQiProxy:send(1160105,param)
        elseif 2 == self.superSelect then
            proxy.ZuoQiProxy:send(1170105,param)
        elseif 4 == self.superSelect then
            proxy.ZuoQiProxy:send(1180105,param)
        elseif 5 == self.superSelect then
            proxy.ZuoQiProxy:send(1560105,param)
        end
    end
end
--
function ZuoQiPanel:onChangeCallBack(context)
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
--丹药使用
function ZuoQiPanel:onItemUse(context)
    -- body
    local mid 
    local data = context.sender.data

    local moduleConf 
    if self.superSelect == 0 then
        moduleConf = conf.SysConf:getModuleById(1001)
    elseif self.superSelect == 1 then
        moduleConf = conf.SysConf:getModuleById(1003)
    elseif self.superSelect == 2 then
        moduleConf = conf.SysConf:getModuleById(1005)
    elseif self.superSelect == 3 then
        moduleConf = conf.SysConf:getModuleById(1002)
    elseif self.superSelect == 4 then
        moduleConf = conf.SysConf:getModuleById(1004)
    elseif self.superSelect == 5 then
        moduleConf = conf.SysConf:getModuleById(1287)
    end
    if "n34" == data then
        mid = moduleConf.zzd_mid
    else
        mid = moduleConf.qld_mid
    end
    
    mgr.ViewMgr:openView(ViewName.ZuoQiItemUse, function(view )
        -- body
    end, {mId = mid, hourse = self.data ,index = self.superSelect})
end

function ZuoQiPanel:onMoreMsg()
    -- body
    --plog("更多信息去看")
    mgr.ViewMgr:openView(ViewName.ZuoQiOtherSkinView, function(view )
        -- body
        view:setData(self.superSelect)
    end,self.data)
end
--获取路径跳转
function ZuoQiPanel:onBtnget()
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

            if data and data.openDay and data.openDay ~= param.grandson and param.index < 9000 then
                GComAlter(language.gonggong92)
                return
            end
        elseif param.id == 1111 then
            local data = cache.ActivityCache:get5030111()
            if data and data.acts and data.acts[1038] == 1 then
            else
                GComAlter(language.vip11)
                return
            end
        elseif param.id == 1115 then
            local data = cache.ActivityCache:get5030111()
            if data and data.acts and data.acts[1042] == 1 then
            else
                GComAlter(language.vip11)
                return
            end
        elseif param.id == 1121 then
            local data = cache.ActivityCache:get5030111()
            if data and data.acts and data.acts[1046] == 1 then
            else
                GComAlter(language.vip11)
                return
            end
        elseif param.id == 1122 then
            local data = cache.ActivityCache:get5030111()
            if data and data.acts and data.acts[1047] == 1 then
            else
                GComAlter(language.vip11)
                return
            end
        elseif param.id == 1204 then
            local data = cache.ActivityCache:get5030111()
            if data and data.acts and data.acts[1071] == 1 then
            else
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


function ZuoQiPanel:onBtnBack()
    -- body
    self:initModel(self.jie)
    self.parent:onSkinBack(0)
end

--活动提示按钮
function ZuoQiPanel:onClickSign()
    -- body
    local confdata = conf.ZuoQiConf:getDataByLv(1,self.superSelect)
    local needtolv = {99,99}
    if self.superSelect == 0 then 
        --坐骑
        needtolv = {3,4}
    elseif self.superSelect == 1 then
        --神兵
        needtolv = {3,4}
    elseif self.superSelect == 2 then
        --法宝
        needtolv = {3,4}
    elseif self.superSelect == 3 then 
        --仙羽
        needtolv = {3,4}
    elseif self.superSelect == 4 then
        --仙器
        needtolv = {3,4}
    end
    local grade = 1
    if needtolv[2] <= self.jie then
        grade = 2
    end
    local param = {}
    param.index = self.superSelect
    param.grade = grade
    param.mId = confdata.cost_items and confdata.cost_items[1] or nil
    if self.superSelect == 0 then
        param.mId = 221041504
    end
    param.isShow = true
    GGoBuyItem(param)
end

--特惠礼包提示按钮
function ZuoQiPanel:onClickTeHui()
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
function ZuoQiPanel:onClickBaibei()
    -- body
    GOpenView({id = 1114})
end

function ZuoQiPanel:checkPoint( param,index )
    -- body
    local data 
    local nextdata 
    if index == 1 then
        data = conf.ZuoQiConf:getSkillByLev(param.id,param.lv,self.superSelect)
        nextdata = conf.ZuoQiConf:getSkillByLev(param.id,param.lv+1,self.superSelect)
    else
        data = conf.ZuoQiConf:getEquipByLev(param.id,param.lv,self.superSelect)
        nextdata = conf.ZuoQiConf:getEquipByLev(param.id,param.lv+1,self.superSelect)
    end
    if not data or not nextdata then
        return false
    end

    local flag = false
    local needlv
    if self.superSelect == 0 then
        needlv = data.horse_lev
    else
        needlv = data.need_lev
    end
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

function ZuoQiPanel:refreshRed()
    -- body
    if not self.superSelect or not self.data then
        return 0
    end
    
    if self.imgRed1.visible or self.imgRed2.visible or self.isRed then
        return 1
    end 

    return 0
end

function ZuoQiPanel:checkIsHave(id)
    -- body
    if not self.data then
        return false
    end
    --皮肤是否拥有
    for k ,v in pairs(self.data.skins) do
        if v.skinId == id then
            return true
        end
    end

    return false
end

function ZuoQiPanel:onClickStar()
    if not self.confStarData then return end
    if not self:checkIsHave(self.confStarData.id) then
        GComAlter(language.fashion13)
        return
    end
    mgr.ViewMgr:openView2(ViewName.FashionStarView, self.confStarData)
end

return ZuoQiPanel