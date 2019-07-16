--
-- Author: 
-- Date: 2017-02-16 14:38:45
--

local ZuoqiJie = class("ZuoqiJie",import("game.base.Ref"))
local redpoint = {10216,10207,10210,10208,10209,0}
function ZuoqiJie:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n15")
    --self.view.visible = true
    self:initView()
end

function ZuoqiJie:initView()
    -- body
    self.t0 = self.view:GetTransition("t0")
    self.t1 = self.view:GetTransition("t1")
    --左边
    self.leftName = self.view:GetChild("n47")
    self.leftJie = self.view:GetChild("n35")
    self.leftModel = self.view:GetChild("n48")
    self.listpro = self.view:GetChild("n46")
    self.listpro.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listpro.numItems = 0

    --右边 
    self.rightName = self.view:GetChild("n50")
    self.rightJie = self.view:GetChild("n37")
    --self.rightPower = self.view:GetChild("n38")
    self.rightModel = self.view:GetChild("n49")
    --进阶奖励
    self.rewardlist = {}
    local btn1 = self.view:GetChild("n72")
    table.insert(self.rewardlist,btn1)
    local btn2 = self.view:GetChild("n73")
    table.insert(self.rewardlist,btn2)
    self.rewardImg = self.view:GetChild("n12") 
    --星星
    self.rightXin = self.view:GetChild("n51")
    --self.rightXin.visible = false--屏蔽星级
    --坐骑 或者 其他
    self.c1 = self.view:GetController("c1")
    self.c1.selectedIndex = 1
    --临时属性
    self.c2 = self.view:GetController("c2")
    self.c2.selectedIndex = 0


    ---祝福值的
    self.decc2 = self.view:GetChild("n67") 
    self.value = self.view:GetChild("n68")
    self.decc2.text = "000"
    self.decc2.visible = false
    self.value.text = "00"
    self.value.visible = false
    self.bar2 = self.view:GetChild("n57")
    self.btnjing = self.view:GetChild("n58") 
    self.btnjing.onClick:Add(self.onBtnJie,self)
    self.itemObj = self.view:GetChild("n54") 
    self.itemname = self.view:GetChild("n69")
    self.itemCount = self.view:GetChild("n70")
    local btnplus = self.view:GetChild("n55")
    btnplus.onClick:Add(self.onbtnplus,self)
    self.btnplus = btnplus

    self.btnRadio = self.view:GetChild("n66")
    self.btnRadio.onClick:Add(self.onBtnRadio,self)
    --自动进阶
    local btnAuto = self.view:GetChild("n59")
    btnAuto:GetChild("title").text = language.zuoqi34
    btnAuto.onClick:Add(self.onBtnAuto,self)
    self.btnAuto2 = btnAuto

    self.imgpro = self.view:GetChild("n4") 
    self.listtemp = self.view:GetChild("n74")
    self.listtemp.itemRenderer = function(index,obj)
        self:celldataTemp(index, obj)
    end
    self.listtemp.numItems = 0
    self:initDec()
    self:clear()

    if g_is_banshu then
        self.view:GetChild("n78"):SetScale(0,0)
        self.view:GetChild("n79"):SetScale(0,0)
    end
end

function ZuoqiJie:initDec()
    -- body
    --self.view:GetChild("n41").text = language.zuoqi05
    self.decc2.text = "" 
    self.value.text = ""
    self.bar2.value = 0 
    self.bar2.max = 0
    self.btnjing:GetChild("title").text = language.zuoqi32
    self.view:GetChild("n71").text = language.zuoqi33
end

function ZuoqiJie:clear()
    -- body
    self.leftName.text = ""
    self.listpro.numItems = 0
    self.rightName.text = ""
    for k ,v in pairs(self.rewardlist) do
        v.visible = false
    end
end

function ZuoqiJie:celldata( index, obj )
    -- body
    local dec = obj:GetChild("n0")
    local decvalue = obj:GetChild("n1")
    local more = obj:GetChild("n2")
    -- local isUp = obj:GetChild("n3")
    -- isUp.visible = false

    local data = self.proTabel[index+1]
    local key = data[1]
    local value = data[2]
    --本级属性
    dec.text = conf.RedPointConf:getProName(key)
    decvalue.text = GProPrecnt(key,value) --value..""
    --下级加属性
    if self.nextConfData then
        if self.nextConfData["att_"..key] then
            local var = self.nextConfData["att_"..key] - value
            if var > 0 then
               -- isUp.visible = true
                more.text = "+"..GProPrecnt(key,var) 
            else
                more.text = ""
            end
        else
            more.text = ""
        end
    else --
        more.text = ""
    end
end

function ZuoqiJie:initModel(index,obj)
    -- body
    if not self.refreshModel then
        return
    end

    local confData =  conf.ZuoQiConf:getSkinsByJie(index,self.index) --= conf.ZuoQiConf:getHorsByJie(index)
    local id = confData.modle_id
    local panel = obj:GetChild("n0")
    local cansee = false
    if self.index == 0 or self.index == 3 then
        self.t0:Stop()
        --添加模型
        obj.data,cansee = self.parent:addModel(id,panel)
        obj.data:removeModelEct()
        if self.index == 3 then
            cansee = obj.data:setSkins(GuDingmodel[1],nil,id)
            obj.data:setScale(200)
            obj.data:setRotationXYZ(0,130,0)
            obj.data:setPosition(panel.actualWidth/2,-panel.actualHeight/2-450,500)
        else
            obj.data:setScale(SkinsScale[id] or SkinsScale[Skins.zuoqi])
            obj.data:setRotationXYZ(0,90,0)
            obj.data:setPosition(panel.actualWidth/2,-panel.actualHeight-200,500)
        end
    elseif self.index == 2 or self.index == 4 then
        -- --移除模型
        obj.data = self.parent:addEffect(id,panel)
        if self.index == 2 then
            self.t0:Play()
            obj.data.Scale = Vector3.New(300,300,300)
            obj.data.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-50,500)
        elseif self.index == 4 then
            self.t0:Stop()
            obj.data.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-100,500)
        elseif self.index == 5 then
            self.t0:Play()
            obj.data.Scale = Vector3.New(300,300,300)
            obj.data.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-50+200,500)
        end
    elseif self.index == 5 then
        self.t0:Stop()
        local body = GuDingmodel[1]
        obj.data,cansee = self.parent:addModel(body,panel)
        obj.data:addQingbiEct(id.."_ui")
        obj.data:setPosition(150.3,-615,500)
        obj.data:setRotationXYZ(0,239.3,0)
        obj.data:setScale(SkinsScale[Skins.wuqi])    
    else
        self.t0:Play()
        local body = cache.PlayerCache:getSkins(Skins.wuqi)
        if not body or body == 0 then
            body = GuDingmodel[3]
        end
        obj.data,cansee = self.parent:addModel(body,panel)
        obj.data:addModelEct(id.."_ui")
        obj.data:setPosition(panel.actualWidth/2+70,-250,500)
        obj.data:setRotationXYZ(30,90,90)
        obj.data:setScale(SkinsScale[2])    
    end

    if obj.name == self.leftModel.name then
        self.view:GetChild("n78").visible = cansee
    else
        self.view:GetChild("n79").visible = cansee
    end

end

-- function ZuoqiJie:refreshTime(amount)
--     -- body
--     local value = conf.ItemConf:getItemExt(221041504)
--     --消耗
--     local use = cache.PlayerCache:VipIsActivate(2) and self.confData.sec_ze or self.confData.sec --sec_ze
--     self.isCanUp = false
--     if use > self.data.secs then
--         self.rightCost.text = mgr.TextMgr:getTextColorStr(use, 14)
--     else
--         self.isCanUp = true
--         self.rightCost.text = use
--     end
--     self.rightHave.text = "("..self.data.secs..")" 
-- end

function ZuoqiJie:initLeft()
    -- body
    self.confData  = conf.ZuoQiConf:getDataByLv(self.data.lev,self.index) 
    self.nextConfData = conf.ZuoQiConf:getDataByLv(self.data.lev+1,self.index)

    local jie = self.confData.jie or 1
    if jie <= 0 then
        jie = 1
    end
    self.jie = jie
    self.hourseData = conf.ZuoQiConf:getSkinsByJie(jie,self.index)
    if self.index == 5 then
        local oldxin = self.rightXin:GetController("c1").selectedIndex
        if oldxin > 10 then
            oldxin = oldxin - 10
        end

        if self.parent.is10 and self.confData.xing~=0 then
            self.rightXin:GetController("c1").selectedIndex = self.confData.xing + 10
        else
            if self.confData.xing~=oldxin then
                self.rightXin:GetController("c1").selectedIndex = self.confData.xing
            end
        end
    else

    end
    --飘字需要
    self.exp =  self.confData.exp 
    

    self.leftName.text = self.hourseData.name
    self.leftJie.url = UIItemRes.jieshu[jie]
    self:initModel(jie,self.leftModel)

    local width = self.leftName.width + self.leftJie.width
    local offx = (self.leftModel.width - width)/2 + self.leftModel.x
    self.leftName.x = offx

    --属性
    self.proTabel = GConfDataSort(self.confData)
    self.listpro.numItems = #self.proTabel
end

function ZuoqiJie:onTimer()
    -- body
    -- if self.index == 0 then
    --     return
    -- end
    -- if not self.data then
    --     return
    -- end
    if self.index == 5 then

        return
    end

    if self.index and self.jie  then
        if self.jie < conf.ZuoQiConf:getValue("bless_clear_jie",self.index) then
            self.decc2.text = language.zuoqi65
             self.value.text = ""
            return 
        end
    end

    if self.data and self.data.blessTime and self.data.blessTime ~= 0 then
        
        local var = 24*3600 -(mgr.NetMgr:getServerTime()-self.data.blessTime)
        if  var > 0 then
            self.decc2.text = language.zuoqi31
            self.value.text = GTotimeString(var)
            self.value.visible = true
            self.decc2.visible = true
        else
            self.decc2.text = language.zuoqi66
            self.decc2.visible = true
            self.value.text = ""
        end
    else
        self.decc2.text = language.zuoqi66
        self.decc2.visible = true
        self.value.text = ""
    end
end

function ZuoqiJie:initRight2()
    -- body
    --消耗何种物品
    local confdata = conf.ZuoQiConf:getDataByLv(self.data.lev,self.index) 
    local t = {mid = confdata.cost_items and confdata.cost_items[1] or nil }
    t.isquan = true
    self.usemid = t.mid
    self.useAmount = confdata.cost_items and confdata.cost_items[2] or 0 
    if t.mid then
        local confItemData = conf.ItemConf:getItem(t.mid)
        self.itemObj.visible = true
        GSetItemData(self.itemObj,t,true)
        self.itemname.text = confItemData.name
        local var = cache.PackCache:getLinkCost(t.mid) --cache.PackCache:getPackDataById(t.mid).amount
        self.itemCount.text = var.."/"..confdata.cost_items[2]
        if var < confdata.cost_items[2] then
            local param = {
                {color = 14,text = var},
                {color = 7,text = "/"..confdata.cost_items[2]}
            }
            self.itemCount.text = mgr.TextMgr:getTextByTable(param)
        end
        self.btnplus.visible = true
    else
        self.itemObj.visible = false
        self.itemname.text = ""
        self.itemCount = ""
        self.btnplus.visible = false
    end

    --升级产生暴击
    if self.data.isCrit == 1 then
        self.t1:Play()
    end
    --当前经验
    self.bar2.value = self.data.levExp
    self.bar2.max = confdata.need_exp or self.data.levExp
    --if self.index == 0 then
        local lv = math.floor(self.data.lev / 10)*10 + 10
        local rewardJie = conf.ZuoQiConf:getDataByLv(lv,self.index)
        if self.confData.jie_items then --处理刚好是10 的时候
            self:initReward(self.confData)
        else
            self:initReward(rewardJie)
        end
    -- else
    --     self:initReward(confdata)
    -- end
end

function ZuoqiJie:initReward(rewardJie)
    -- body
    if rewardJie and rewardJie.jie_items and #rewardJie.jie_items > 0 then
        table.sort(rewardJie,function(a,b)
            -- body
            return a[1]<b[1]
        end)

        for k ,v in pairs(rewardJie.jie_items) do
            if k>2 then
                break
            end
            self.rewardlist[k].data = v[1]
            self.rewardlist[k].visible = true

            local t = {mid = v[1],amount = v[2],bind = v[3],isquan = true}
            GSetItemData(self.rewardlist[k],t,true)
        end
        self.rewardImg.visible = true

        
    else
        for k ,v in pairs(self.rewardlist) do
            v.visible = false
        end
        self.rewardImg.visible = false
    end
end

function ZuoqiJie:initRight()
    -- body
    local jie = self.confData.jie or 0
    local hourseData
    if jie <= 0 then
        hourseData = conf.ZuoQiConf:getSkinsByJie(1,self.index)
        self.rightJie.url =  UIItemRes.jieshu[1]
        self:initModel(1,self.rightModel)
    else
        hourseData = conf.ZuoQiConf:getSkinsByJie(jie+1,self.index)
        self.rightJie.url =  UIItemRes.jieshu[jie+1]
        self:initModel(jie+1,self.rightModel)
    end
    self.rightName.text = hourseData.name
    
    --进阶奖励
    -- if self.index == 0 then
    --     self.c1.selectedIndex = 0
        
    --     -- self.rightProess.value = self.data.levExp
    --     -- self.rightProess.max = self.confData.need_exp

    -- else
    --     self.c1.selectedIndex = 1
    --     --self:initRight2()
    -- end
    self:initRight2()

    local width = self.rightName.width + self.rightJie.width
    local offx = (self.rightModel.width - width)/2 + self.rightModel.x
    self.rightName.x = offx

end

function ZuoqiJie:celldataTemp( index,obj )
    -- body
    local data = self.keys[index+1]
    local v = self.data.tempAttris[tonumber(data)]
    local lab = obj:GetChild("n0")
    lab.text = "+"..v..conf.RedPointConf:getProName(data)
    local lab1 = obj:GetChild("n1")
    lab1.text = "(".. language.zuoqi61 .. ")"
end

--临时属性
function ZuoqiJie:initTempAttris(tempAttris)
    -- body
    self.data.tempAttris = tempAttris
    -- if self.index == 0 then
    --     self.c2.selectedIndex = 0 
    --     return
    -- else
        self.c2.selectedIndex = 1
    -- end
    self.keys = {}
    if self.data and self.data.tempAttris then
        self.keys = table.keys(self.data.tempAttris)
    end
    if #self.keys<=0 then
        self.c2.selectedIndex = 0 
        return
    end

    table.sort(self.keys,function(a,b)
        -- body
        return a < b 
    end)
    --printt("临时属性",self.data.tempAttris)
    local number = #self.keys
    local height = 23 * number + 2 
    self.listtemp.height = height
    self.listtemp.numItems = number
    self.imgpro.height = height + 20
end

function ZuoqiJie:setData(data,flag)
    -- body
    self.refreshModel = flag --是否刷新模型
    --plog("refreshModel",flag)
    --切换页面停止自动升级
    if self.index and self.index~=self.parent.c1.selectedIndex then
        --self.isAuto = false
        self:setIsAuto(false)
    end
    --自动购买按钮的状态
    self.index = self.parent.c1.selectedIndex

    self.btnRadio.selected =  cache.ZuoQiCache:getSelectByIndex(self.index) --cache.ZuoQiCache:getIsTips(self.index)
    --plog("self.btnRadio.selected",self.btnRadio.selected,self.index)
    if self.index == 5 then
        self.c1.selectedIndex = 0
    else
        self.c1.selectedIndex = 1
    end

    self.data = data

    self:initTempAttris(self.data.tempAttris)
    self:initLeft()
    self:initRight()
    --是否自动买
    if self.isAuto then
        self:send()
    end
end


function ZuoqiJie:onBtnJie()
    -- body
    self:setIsAuto(false)
        
    local reqType = self.btnRadio.selected  and 1 or 0
    local flag = cache.PackCache:getLinkCost(self.usemid) < self.useAmount
    if flag and reqType == 0 then
        local param = {
            {color = 14,text = cache.PackCache:getLinkCost(self.usemid)},
            {color = 7,text = "/"..self.useAmount}
        }
        self.itemCount.text = mgr.TextMgr:getTextByTable(param)

        self:onbtnplus()
        return 
    end
    self:send()
end

function ZuoqiJie:onbtnplus( ... )
    -- body
    self:setIsAuto(false)
    local needtolv = {99,99}
    if self.index == 0 then 
        --坐骑
        needtolv = {3,4}
    elseif self.index == 1 then
        --神兵
        needtolv = {3,4}
    elseif self.index == 2 then
        --法宝
        needtolv = {3,4}
    elseif self.index == 3 then 
        --仙羽
        needtolv = {3,4}
    elseif self.index == 4 then
        --仙器
        needtolv = {3,4}
    end
    local grade = 1
    if needtolv[2] <= self.jie then
        grade = 2
    end
    local param = {}
    param.mId = self.usemid
    param.grade = grade
    param.zuoqi = true
    param.index = self.index
    if param.mId then
        GGoBuyItem(param)
        local view = mgr.ViewMgr:get(ViewName.ZuoqiTipView)
        if view then
            view:onClickClose()
        end
    end
end

function ZuoqiJie:onBtnRadio()
    -- ZuoqiJie
    cache.ZuoQiCache:setSelectByIndex(self.index,self.btnRadio.selected)
    if self.btnRadio.selected then
        if cache.ZuoQiCache:getIsTips(self.index) then
            return 
        end 

        local param = {}
        param.type = 8
        param.richtext = mgr.TextMgr:getTextByTable(language.zuoqi50)
        param.richtext1 = language.zuoqi51
        param.isradio = cache.ZuoQiCache:getIsTips(self.index)
        param.sure = function(flag)
            -- body
            cache.ZuoQiCache:setIsTips(self.index,flag)
        end
        param.sureIcon = UIItemRes.imagefons01
        --param.titleIcon = 
        GComAlter(param)
    end

    
end

function ZuoqiJie:setIsAuto(falg)
    -- body
    self.isAuto = falg
    if falg then
        --self.btnAuto1.title = language.zuoqi74
        self.btnAuto2.title = language.zuoqi75
    else
        --self.btnAuto1.title = language.zuoqi70
        self.btnAuto2.title = language.zuoqi34
    end
end

function ZuoqiJie:send()
    -- body
    local reqType = self.btnRadio.selected  and 1 or 0
    local function sendmsg()
        
        if self.index == 3 then
            proxy.ZuoQiProxy:send(1140102,{reqType = reqType})
        elseif self.index == 1 then
            proxy.ZuoQiProxy:send(1160102,{reqType = reqType})
        elseif self.index == 2 then
            proxy.ZuoQiProxy:send(1170102,{reqType = reqType})
        elseif self.index == 4 then
            proxy.ZuoQiProxy:send(1180102,{reqType = reqType})
        elseif self.index == 0 then
            proxy.ZuoQiProxy:send(1120102,{auto = reqType})
        elseif self.index == 5 then
            --print("少时诵诗书所所 1560102")
            proxy.ZuoQiProxy:send(1560102,{reqType = reqType})
        end
    end

    local varpack = cache.PackCache:getLinkCost(self.usemid)
    local flag = varpack < self.useAmount
    if reqType == 0 and flag then
        self:onbtnplus()
        return
    end

    --道具足够
    if not flag then 
        sendmsg()
        return
    end
    --今天不在提示消耗元宝
    if cache.ZuoQiCache:getCostMoney(self.index) then
        sendmsg()
        return
    end
    --不是自动消耗
    if not self.btnRadio.selected then
        sendmsg()
        return
    end
    --当前阶是否已经不用再提示
    if cache.ZuoQiCache:getCurPass(self.confData.jie,self.index) then
        sendmsg()
        return
    end

    local costmoney = conf.ItemConf:getBuyPrice(self.usemid)
    local confType = conf.ItemConf:getBuyType(self.usemid)
    local number = self.useAmount - cache.PackCache:getLinkCost(self.usemid)
    if costmoney and confType then
        local fff  
        for k ,v in pairs(confType) do
            if v == MoneyType.bindGold then
                fff = true
                break
            end
        end
        --有消耗绑元
        if fff then
            costmoney = (self.useAmount - varpack) * costmoney
            local money = cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
            if money < costmoney then --绑元不够，要消耗元宝
                local param = {}
                param.type = 8
                param.sureIcon = UIItemRes.imagefons01
                param.richtext = string.format(language.gonggong74,costmoney) 
                param.richtext1 = language.zuoqi51
                param.sure = function(rr)
                    -- body
                    cache.ZuoQiCache:setCostMoney(self.index,rr)
                    cache.ZuoQiCache:setCurPass(self.confData.jie,self.index,true)
                    sendmsg()
                end
                param.cancel = function()
                    -- body
                    self:setIsAuto(false)
                    --self.isAuto = false
                end
                GComAlter(param)
            else
                sendmsg()
            end
        else
            sendmsg()
        end
    else
        sendmsg()
    end
end

function ZuoqiJie:onBtnAuto()
    -- body
    local function gosend()
        -- body
        if self.isAuto then
            self:setIsAuto(false)
            return 
        end
        self:setIsAuto(true)
        self:send()
    end
    
    if self.parent.isGuide and self.index == 0 then
        self.parent:setGoonGuide()
    end

    local flag = cache.PackCache:getLinkCost(self.usemid) < self.useAmount
    if flag and  not self.btnRadio.selected then
        --self.isAuto = false
        
        self:onbtnplus()

        local param = {
            {color = 14,text = cache.PackCache:getLinkCost(self.usemid)},
            {color = 7,text = "/"..self.useAmount}
        }
        self.itemCount.text = mgr.TextMgr:getTextByTable(param)
        return
    end
    gosend()
end



function ZuoqiJie:actionTip()
    -- body
    -- if self.exp then
    --     GComAlter(string.format(language.zuoqi09,self.exp))
    -- end
end

function ZuoqiJie:playEff()
    -- body
    if self.playing then
        --plog("self.playing")
        return
    end
    --plog("self.playing node")
    local node = self.view:GetChild("n75")
    local effect,durition = self.parent:addEffect(4020103,node)
    effect.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight/2,0)--坐标
    effect.Scale = Vector3.New(65,68,70) --背书
    self.playing = true
    if self.isAuto then--进阶声音
        if not self.isAudio then
            mgr.SoundMgr:playSound(Audios[2])
            self.isAudio = true
        end
    else
        mgr.SoundMgr:playSound(Audios[2])
        self.isAudio = nil
    end
    self.parent:addTimer(durition,1,function()
        -- body
        self.playing = false
    end)
end

return ZuoqiJie