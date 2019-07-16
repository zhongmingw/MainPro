--
-- Author: 
-- Date: 2017-02-27 19:37:11
--

local HuoBanJie = class("HuoBanJie",import("game.base.Ref"))
local redpoint = {10211,10213,10212,10215,10214}
local _max_ = {11,13,13,13,13}
function HuoBanJie:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n22")
    self:initView()
end

function HuoBanJie:initView()
    -- body

    self.c1 = self.view:GetController("c1")
    self.c1.selectedIndex = 1

    self.c2 = self.view:GetController("c2")
    self.c2.selectedIndex = 0

    self.c3 = self.view:GetController("c3")

    self.t0 = self.view:GetTransition("t0")
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
    self.rightModel = self.view:GetChild("n49")
    --进阶奖励
    self.rewardlist = {}
    local btn1 = self.view:GetChild("n72")
    table.insert(self.rewardlist,btn1)
    local btn2 = self.view:GetChild("n73")
    table.insert(self.rewardlist,btn2)
    self.rewardImg = self.view:GetChild("n12") 
    --祝福值的
    self.decc2 = self.view:GetChild("n67") 
    self.value = self.view:GetChild("n68")
    self.bar2 = self.view:GetChild("n57")
    self.btnjing = self.view:GetChild("n58") 
    self.btnjing.onClick:Add(self.onBtnJie,self)
    self.itemObj = self.view:GetChild("n54") 
    self.itemname = self.view:GetChild("n69")
    self.itemCount = self.view:GetChild("n70")
    local btnplus = self.view:GetChild("n55")
    btnplus.onClick:Add(self.onbtnplus,self)
    self.btnplus = btnplus

    --self.c1 = self.view:GetChild("n105") 
    self.rightXin = self.view:GetChild("n105")
    self.rightXin.visible = false
    --伙伴升级
    local xing = self.view:GetChild("n51")
    self.huobanc1 = xing:GetController("c1")

    --伙伴升级消耗的装备
    -- self.putData = {}
    self.btnHuoBan = self.view:GetChild("n24") 
    -- self.btnPut = self.view:GetChild("n88")
    self.btnHuoBan.onClick:Add(self.onHuobanUp,self)
    self.btnHuoBan.data = self.btnHuoBan.x 
    self.btnHuoBan:GetChild("red").visible = false
    -- self.btnPut.onClick:Add(self.onClickPut,self)

    self.labdec = self.view:GetChild("n89") 
    self.labdec.text = ""

    self.expbar = self.view:GetChild("n29") 


    self.btnRadio = self.view:GetChild("n66")
    self.btnRadio.onClick:Add(self.onBtnRadio,self)

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
    --伙伴专属技能
    self.icon1 = self.view:GetChild("n98"):GetChild("n2")
    self.skilldec1 = self.view:GetChild("n99")
    self.icon2 = self.view:GetChild("n101"):GetChild("n2")
    self.skilldec2 = self.view:GetChild("n102")


    self:initDec()
    self:clear()
end

--[[--自动添加装备
function HuoBanJie:onClickPut()
    -- body
    --背包装备信息
    -- print("背包装备信息")
    local data = GGetEquipData()
    if #data > 0 then
        if self.confData.xing == 10 then
            GComAlter(language.huoban38)
        else
            local num = 0
            for i=1,6 do
                local item = self.view:GetChild("n8"..i)
                local img = self.view:GetChild("n9"..(i-1))
                img.visible = false
                if data[i] and data[i].color<4 and  ( tonumber(data[i].type) == 2 or  data[i].color < 4) then
                    num = num + 1
                    local info = {mid = data[i].id,amount = 1,isCase = false,isquan = true}
                    info.isquan = true
                    GSetItemData(item,info,false)
                    self.putData[i] = data[i]
                    -- item.data = {data = data,index = i}
                    -- item.onClick:Add(self.onClickOpenPop,self)
                    
                elseif self:checkinPutEquip() then
                    img.visible = true
                end
            end
            if num == 0 then
                GComAlter(language.huoban39)
            end
            -- if #data > 6 then
            --     self.btnPut:GetChild("red").visible = true
            -- else
            --     self.btnPut:GetChild("red").visible = false
            -- end
            if #self.putData > 0 then
                self.btnHuoBan:GetChild("red").visible = true
            else
                self.btnHuoBan:GetChild("red").visible = false
            end
        end
    else
        GComAlter(language.huoban39)
    end
    self:setExpBar()
    -- print("装备数量",#self.putData)
end
]]--
--[[--获取当前放入的装备
function HuoBanJie:getPutData()
    -- body
    return self.putData
end
]]--
--[[--装备选择弹框
function HuoBanJie:onClickOpenPop(context)
    -- body
    local cell = context.sender
    local data = cell.data
    mgr.ViewMgr:openView2(ViewName.HuobanExpPop,data)
end
]]--
--[[--设置伙伴经验进度条
function HuoBanJie:setExpBar()
    -- body
    self.addExp = 0
    for i=1,6 do
        if self.putData[i] then
            self.addExp = self.addExp+self.putData[i].partner_exp
        end
    end
    self.expbar.value = self.addExp+self.data.exp
    self.expbar.max = self.confData.cost_exp or self.data.exp
    local textData = {
                {text=self.data.exp.."",color = 5},
                {text="+"..self.addExp,color = 4},
            }
    if self.addExp > 0 then
        self.expbar:GetChild("title").text = mgr.TextMgr:getTextByTable(textData)
    else
        self.expbar:GetChild("title").text = self.data.exp
    end
end

function HuoBanJie:checkinPutEquip()
    -- body
    local equipData = GGetEquipData()--可以用的道具
    local numbers = table.nums(self.putData)--已经使用的个数
    if numbers>=6 then
        return false
    else
        if numbers >= table.nums(equipData) then
            return false
        end
    end

    return true
end
]]--

--[[--设置装备框所选的装备
function HuoBanJie:setPutData(data)
    -- body
    if not data then
        return
    end
    local eqData = data.data
    local index = data.index
    -- print("设置装备框所选的装备",index,eqData.id)
    --printt("eqData",eqData)
    self.putData[index] = eqData

    local item = self.view:GetChild("n8"..index)
    local img = self.view:GetChild("n9"..(index-1))
    img.visible = false

    local info = {mid = self.putData[index].id,amount = 1,colorAttris = self.putData[index].colorAttris}
    info.isquan = true
    GSetItemData(item,info,false)
    item.data = index
    
    self:setExpBar()
end
]]--

---

function HuoBanJie:onTimer()
    -- body
    -- if self.index  == 0 then
    --     if not self.data or not self.confData.jie_cost_sec then
    --         self.labdec.text = ""
    --         return
    --     end
    --     local var = self.confData.jie_cost_sec - (mgr.NetMgr:getServerTime() - self.data.lastUpTime+ self.data.onlineSecs)
        
        
    --     if var <= 0 then
    --         self.btnHuoBan:GetChild("red").visible = true
    --         self.labdec.text = language.huoban32
    --         self.isUp = true
    --     else
    --         self.btnHuoBan:GetChild("red").visible = false
    --         self.labdec.text = string.format(language.huoban26,GTotimeString(var),self:needVipStr())
    --         self.isUp = false
    --     end
    --     return
    -- end
    if self.index ~= 0 and self.jie then
        if self.jie < conf.HuobanConf:getValue("bless_clear_jie",self.index) then
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
        else
            self.decc2.text = language.zuoqi66
            self.value.text = ""
        end
    else
        self.decc2.text = language.zuoqi66
        self.value.text = ""
    end
end

function HuoBanJie:initDec()
    -- body
    self.icon1.url = UIPackage.GetItemURL("huoban" , "huoban_064")
    self.icon2.url = UIPackage.GetItemURL("huoban" , "huoban_064")

    self.bar2.value = 0 
    self.bar2.max = 0
    self.btnjing:GetChild("title").text = language.zuoqi32
    self.view:GetChild("n71").text = language.zuoqi33
end

function HuoBanJie:clear()
    -- body
    self.leftName.text = ""
    self.listpro.numItems = 0
    self.rightName.text = ""
    for k ,v in pairs(self.rewardlist) do
        v.visible = false
    end
end

function HuoBanJie:celldata( index, obj )
    -- body
    local dec = obj:GetChild("n0")
    local decvalue = obj:GetChild("n1")
    local more = obj:GetChild("n2")
    --local isUp = obj:GetChild("n3")
    --isUp.visible = false

    local data = self.proTabel[index+1]
    local key = data[1]
    local value = data[2]

    dec.text = conf.RedPointConf:getProName(key)
    decvalue.text = GProPrecnt(key,value)-- value..""

    if self.nextConfData then
        if self.nextConfData["att_"..key] then
            local var = self.nextConfData["att_"..key] - value
            if var > 0 then
                --isUp.visible = true
                more.text = "+"..GProPrecnt(key,var) --var
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

function HuoBanJie:initModel(index,obj)
    -- body
    if not self.refreshModel then
        return
    end

    if self.index == 0 then
        index = self.param.id
    end

    local condata  = conf.HuobanConf:getSkinsByJie(index,self.index)
    local panel = obj:GetChild("n0")
    local touc = obj:GetChild("n1")
    local node = obj:GetChild("n2")
    local cansee = false
    if self.index == 0 or self.index == 1 or self.index == 2 then --伙伴
        --移除特效
        self.t0:Stop()
        local info
        if self.index == 0 then
            info = condata.modle_id
        elseif self.index == 1 then
            info = condata.modle_id
        else
            info = GuDingmodel[2] 
        end
        obj.data,cansee = self.parent:addModel(info,panel)
        touc.touchable = false
        if self.index == 1 then
            cansee = obj.data:setSkins(GuDingmodel[2],nil,condata.modle_id)
            obj.data:setRotationXYZ(0,0,0)
            obj.data:setPosition(panel.actualWidth/2,-panel.actualHeight-200,500)
        elseif self.index == 2 then
            --obj.data:setSkins(cache.PlayerCache:getSkins(Skins.huoban),nil,0)
            obj.data:addWeaponEct(condata.modle_id.."_ui")
            obj.data:setRotationXYZ(0,0,0)
            obj.data:setPosition(panel.actualWidth/2,-panel.actualHeight-200,500)
        else
            touc.touchable = true
            obj.data:setScale(SkinsScale[Skins.huoban])
            cansee = obj.data:setSkins(condata.modle_id)
            obj.data:setRotationXYZ(0,0,0)
            obj.data:setPosition(panel.actualWidth/2,-panel.actualHeight-200,500)
        end
        if condata.xyz then
            obj.data:setRotationXYZ(condata.xyz[1],condata.xyz[2],condata.xyz[3])--180
        end

    elseif self.index == 3 or self.index == 4 then --伙伴法宝
        touc.touchable = false
        obj.data = self.parent:addEffect(condata.modle_id,panel)
        if self.index == 3 then
            self.t0:Play()
            obj.data.Scale = Vector3.New(300,300,300)
            obj.data.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight,500)

        elseif self.index == 4 then
            self.t0:Play()
            obj.data.Scale = Vector3.New(300,300,300)
            obj.data.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-300,500)
        end
    end

    if obj.name == self.leftModel.name then
        self.view:GetChild("n103").visible = cansee
    else
        self.view:GetChild("n104").visible = cansee
    end
end

function HuoBanJie:changpos(p1,p2,p3)
    -- body
    local width = 0
    width = width + (p1.visible and p1.actualWidth or 0)
    width = width + (p2.visible and p2.actualWidth or 0)

    local x = (p3.actualWidth - width)/2 + p3.x 
    if p1.visible then
        p1.x = x 
        x = x + p1.actualWidth
    end
    p2.x = x
end

function HuoBanJie:initSkill(condata,dec)
    -- body
    local confskill = conf.SkillConf:getSkillByIndex(condata.skill_affect_id)
    --按等级读取普通技能描述
    if confskill then
        dec.text = confskill.dec or ""
    else
        dec.text = ""
    end
end

function HuoBanJie:initLeft()
    -- body
    self.jie = self.confData.jie
    if self.index == 0 then
        self.leftName.text = ""
        self.leftJie.url = ResPath:petChengHao(self.jie)
        self.leftJie.y = 86

        self:initSkill(self.confData,self.skilldec1)
        --self.skilldec1.text = 
    else
        self.leftName.text = self.hourseData.name
        
        self.leftJie.url = UIItemRes.jieshu[self.jie]
        self.leftJie.y = 6
    end

    self:changpos(self.leftName,self.leftJie,self.leftModel)
    if self.index == 0 then
        self.leftJie.x = 147.5
    end
    --

    self:initModel(self.confData.jie,self.leftModel)
    self.proTabel = GConfDataSort(self.confData)
    self.listpro.numItems = #self.proTabel
end

function HuoBanJie:initReward(items)
    -- body
    if items and items.jie_items and #items.jie_items>0 then
       
        for k ,v in pairs(items.jie_items) do
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

function HuoBanJie:initRight()
    -- body
    local max = conf.HuobanConf:getValue("endmaxjie",self.index)  --_max_[self.index+1]
    local rightjie = self.confData.jie + 1 > max and max or self.confData.jie + 1
    self:initModel(rightjie,self.rightModel)
    
    local lv = math.floor(self.data.lev / 10)*10 + 10
    local rewardJie = conf.HuobanConf:getDataByLv(lv,self.index)
    if self.confData.jie_items then --处理刚好是10 的时候
        self:initReward(self.confData)
    else
        self:initReward(rewardJie)
    end

    if self.index == 0 then
        --
        local confData =  conf.HuobanConf:getDataByLv(11*(rightjie-1)+1 ,self.index)
        self:initSkill(confData,self.skilldec2)

        local oldxin = self.huobanc1.selectedIndex
        if oldxin > 10 then
            oldxin = oldxin - 10
        end

        if self.parent.is10 and self.confData.xing~=0 then
            self.huobanc1.selectedIndex = self.confData.xing + 10
        else
            if oldxin ~= self.confData.xing then
                self.huobanc1.selectedIndex = self.confData.xing
            end
        end

        if self.huobanc1.selectedIndex == 10 or self.huobanc1.selectedIndex == 20 then
            -- self.btnHuoBan.icon = "ui://huoban/zuoqi_008"  --EVE 按钮换成技术字
            self.btnHuoBan.icon = UIPackage.GetItemURL("huoban" , "huoban_020")
           
        else
            self.btnHuoBan.icon = UIPackage.GetItemURL("_icons" , "huoban_067")
        end
        -- print("ResPath:petChengHao(rightjie)",ResPath:petChengHao(rightjie))
        self.rightJie.url = ResPath:petChengHao(rightjie)
        self.rightJie.y = 86
        self.expbar.value = self.data.exp
        self.expbar.max = self.confData.cost_exp or self.data.exp
        self.expbar:GetChild("title").text = self.data.exp
    else
        local confData = conf.HuobanConf:getSkinsByJie(rightjie,self.index)
        -- print("名字>>>>>>>>",confData.name,rightjie)
        self.rightName.text = confData.name
        self.rightJie.url = UIItemRes.jieshu[rightjie]
        self.rightJie.y = 6
        local t = {mid = self.confData.cost_items and self.confData.cost_items[1] or nil }
        self.usemid = t.mid
        self.useAmount = self.confData.cost_items and self.confData.cost_items[2] or 0 
        t.isquan = true
        if t.mid then
            local confItemData = conf.ItemConf:getItem(t.mid)
            self.itemObj.visible = true
            GSetItemData(self.itemObj,t,true)
            self.itemname.text = confItemData.name
            local var = cache.PackCache:getLinkCost(t.mid)-- cache.PackCache:getPackDataById(t.mid).amount
            self.itemCount.text = var.."/"..self.useAmount
            if var < self.useAmount then
                local param = {
                    {color = 14,text = var},
                    {color = 7,text = "/"..self.useAmount}
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
        self.bar2.value = self.data.levExp
        -- print("经验>>>>>>>>>>>>>>",self.data.levExp)
        self.bar2.max = self.confData.need_exp or self.data.levExp

        -- --星星设定
        -- local oldxin = self.rightXin:GetController("c1").selectedIndex
        -- if oldxin > 10 then
        --     oldxin = oldxin - 10
        -- end

        -- if self.parent.is10 and self.confData.xing~=0 then
        --     self.rightXin:GetController("c1").selectedIndex = self.confData.xing + 10
        -- else
        --     if self.confData.xing~=oldxin then
        --         self.rightXin:GetController("c1").selectedIndex = self.confData.xing
        --     end
        -- end
    end 
    self:changpos(self.rightName,self.rightJie,self.rightModel)
     if self.index == 0 then
        self.rightJie.x = 646.5
    end

end

function HuoBanJie:setData(data,param,flag)
    -- body
    self.refreshModel = flag --是否刷新模型
    --切换页面停止自动升级
    self.param = param
    if self.index and self.index~=self.parent.c1.selectedIndex then
        self:setIsAuto(false)
    end
    self.index = self.parent.c1.selectedIndex

    self.c3.selectedIndex = self.index

    self.btnRadio.selected = cache.HuobanCache:getSelectByIndex(self.index)
    self.data = data
    self.confData = conf.HuobanConf:getDataByLv(self.data.lev,self.index)
    self.nextConfData = conf.HuobanConf:getDataByLv(self.data.lev+1,self.index)
    if self.index == 0 then
        self.hourseData = conf.HuobanConf:getSkinsByJie(param.id,self.index)
        self.c1.selectedIndex = 0
    else
        self.hourseData = conf.HuobanConf:getSkinsByJie(self.confData.jie,self.index)
        self.c1.selectedIndex = 1
    end
    
    -- self.putData = {}
    if GCheckTunShiEquip() then
        self.btnHuoBan:GetChild("red").visible = true
    else
        self.btnHuoBan:GetChild("red").visible = false
    end

    if self.nextConfData then
        self:initLeft()
        self:initRight()
        self:initTempAttris(self.data.tempAttris)
    end

   
    if self.isAuto and self.nextConfData then
        self:send()
    end
end

function HuoBanJie:celldataTemp( index,obj )
    -- body
    local data = self.keys[index+1]
    local v = self.data.tempAttris[tonumber(data)]
    local lab = obj:GetChild("n0")
    lab.text = "+"..v..conf.RedPointConf:getProName(data)
    local lab1 = obj:GetChild("n1")
    lab1.text = "(".. language.zuoqi61 .. ")"
end

function HuoBanJie:initTempAttris(tempAttris)
    -- body
    self.data.tempAttris = tempAttris
    if self.index == 0 then
        self.c2.selectedIndex = 0 
        return
    else
        self.c2.selectedIndex = 1
    end

    self.keys = table.keys(self.data.tempAttris)
    if #self.keys<=0 then
        self.c2.selectedIndex = 0 
        return
    end

    table.sort(self.keys,function(a,b)
        -- body
        return a < b 
    end)

    local number = #self.keys
    local height = 23 * number + 2 
    self.listtemp.height = height
    self.listtemp.numItems = number
    self.imgpro.height = height + 20
end

function HuoBanJie:setIsAuto(flag)
    -- body
    self.isAuto = flag
    if flag then
        self.btnAuto2.title = language.zuoqi75
    else
        self.btnAuto2.title = language.zuoqi34
    end
end

--单次进阶
function HuoBanJie:onBtnJie()
    self:setIsAuto(false)
    local reqType = self.btnRadio.selected  and 1 or 0
    local flag = cache.PackCache:getLinkCost(self.usemid)< self.useAmount
    if reqType == 0 and flag then
        self:onbtnplus()
        return 
    end
    self:send()
end
--道具不足
function HuoBanJie:onbtnplus()
    -- body
    self:setIsAuto(false)
    local needtolv = {99,99}
    if self.index == 0 then 
        --伙伴
        needtolv = {3,4}
    elseif self.index == 1 then
        --灵羽
        needtolv = {3,4}
    elseif self.index == 2 then
        --灵兵
        needtolv = {3,4}
    elseif self.index == 3 then 
        --灵宝
        needtolv = {3,4}
    elseif self.index == 4 then
        --灵器
        needtolv = {3,4}
    end
    local grade = 1
    if needtolv[2] <= self.jie then
        grade = 2
    end
    local param = {}
    param.mId = self.usemid
    param.grade = grade
    param.index = self.index+10
    if param.mId then
        GGoBuyItem(param)
    end
    if self.usemid and self.useAmount and self.index ~= 0 then
        local param = {
            {color = 14,text = cache.PackCache:getLinkCost( self.usemid)},
            {color = 7,text = "/"..self.useAmount}
        }
        self.itemCount.text = mgr.TextMgr:getTextByTable(param)
    end
end

function HuoBanJie:onBtnRadio()
    -- ZuoqiJie
    cache.HuobanCache:setSelectByIndex(self.index,self.btnRadio.selected)
    if self.btnRadio.selected then
        if cache.HuobanCache:getIsTips(self.index) then
            return 
        end 
        local param = {}
        param.type = 8
        param.richtext = mgr.TextMgr:getTextByTable(language.huoban29)
        param.richtext1 = language.zuoqi51
        param.sure = function(flag)
            -- body
            cache.HuobanCache:setIsTips(self.index,flag)

        end
        param.sureIcon = UIItemRes.imagefons01
        GComAlter(param)
    end

    
end

function HuoBanJie:send()
    -- body
    if not self.view.visible then
        return 
    end
    local function sendmsg()
        local reqType = self.btnRadio.selected  and 1 or 0    
        if self.index == 1 then
            proxy.HuobanProxy:send(1210102,{reqType = reqType})
        elseif self.index == 2 then
            proxy.HuobanProxy:send(1220103,{reqType = reqType})
        elseif self.index == 3 then
            proxy.HuobanProxy:send(1230102,{reqType = reqType})
        elseif self.index == 4 then
            proxy.HuobanProxy:send(1240102,{reqType = reqType})
        end
    end

  
    local varpack = cache.PackCache:getLinkCost(self.usemid)
    local flag = varpack < self.useAmount
    --道具足够
    if not flag then 
        sendmsg()
        return
    else
        if not self.btnRadio.selected then
            self:onbtnplus()
            return
        end
    end
    --今天不在提示消耗元宝
    if cache.HuobanCache:getCostMoney(self.index) then
        sendmsg()
        return
    end
    --不是自动消耗
    if not self.btnRadio.selected then
        sendmsg()
        return
    end
    --当前阶是否已经不用再提示
    if cache.HuobanCache:getCurPass(self.confData.jie,self.index) then
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
                    cache.HuobanCache:setCostMoney(self.index, rr)
                    cache.HuobanCache:setCurPass(self.confData.jie,self.index,true)
                    sendmsg()
                end
                param.cancel = function()
                    -- body
                    self:setIsAuto(false)
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

function HuoBanJie:onBtnAuto()
    -- body
    local flag = cache.PackCache:getLinkCost(self.usemid) < self.useAmount
    if flag  and not self.btnRadio.selected then
        self:setIsAuto(false)
        self:onbtnplus()
        return 
    end
    if self.isAuto then
        self:setIsAuto(false)
        return 
    end
    self:setIsAuto(true)
    self:send() 
end

--伙伴升级
function HuoBanJie:onHuobanUp()
    -- body
    if not self.data then
        return
    end
    -- local num = 0
    -- for i=1,6 do
    --     if self.putData[i] then
    --         num = num + 1
    --     end
    -- end
    local function callback(falg)
        -- body
        proxy.HuobanProxy:send(1200201,{destIndex = {},reqType = falg})
    end
    if self.confData.xing == 10 then
        callback(2)
        -- if self.isUp then
        --     callback(2)
        -- else
        --     if self:checkVip() then
        --         callback(3)
        --     else
        --         GComAlter(self:needVipStr())
        --         GOpenView({id = 1050})
        --     end
        -- end
        return
    else
        mgr.ViewMgr:openView2(ViewName.HuobanExpPop,{})
    end

    -- if num > 0 or (num <= 0 and self.expbar.value > self.expbar.max) then
    --     local data = {}
    --     for i=1,6 do
    --         if self.putData[i] then
    --             table.insert(data,self.putData[i].index)
    --         end
    --     end
    --     proxy.HuobanProxy:send(1200201,{destIndex = data,reqType = 1})
    --     return
    -- else
    --     GComAlter(language.huoban30)
    --     return
    -- end

end

function HuoBanJie:playEff()
    -- body
    -- self.putData = {}
    self.btnHuoBan:GetChild("red").visible = false
    if self.playing then
        return
    end
    local node = self.view:GetChild("n76")
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

function HuoBanJie:needVipStr()
    -- body
    if g_ios_test then
        return language.gonggong76
    end
    return ""
    -- if self.jie < 4 then
    --     return language.huoban25[1]
    -- elseif self.jie < 7 then
    --     return language.huoban25[2]
    -- else
    --     return language.huoban25[3]
    -- end
end
function HuoBanJie:checkVip()
    -- body
    return true
    -- local id 
    -- if self.jie < 4 then
    --     id = 1
    -- elseif self.jie < 7 then
    --     id = 2
    -- else
    --     id = 3
    -- end
    -- return cache.PlayerCache:VipIsActivate(id)
end

return HuoBanJie