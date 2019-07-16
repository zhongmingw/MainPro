--
-- Author: 
-- Date: 2017-05-25 15:50:10
--

local ZuoPanel = class("ZuoPanel",import("game.base.Ref"))

function ZuoPanel:ctor(param)
    self.parent = param
    self.view = self.parent.view:GetChild("n21")
    self:initView()
end

function ZuoPanel:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")
    --self.c1.onChanged:Add(self.setItemMsg,self)
    --东效
    self.t0 = self.view:GetTransition("t0")
    --名字
    self.name = self.view:GetChild("n48")
    self.icon1 = self.view:GetChild("n12") 
    self.icon2 = self.view:GetChild("n58")
    self.icon3 = self.view:GetChild("n60")
    --左右切
    self.pageBefor = self.view:GetChild("n20")
    self.pageBefor.data = "n20"
    self.pageBefor.onClick:Add(self.onChangeCallBack,self)
    self.pageNext = self.view:GetChild("n19")
    self.pageNext.data = "n19"
    self.pageNext.onClick:Add(self.onChangeCallBack,self)
    --更多皮肤
    self.btnMore = self.view:GetChild("n21")
    self.btnMore.data = "n21"
    self.btnMore.onClick:Add(self.onMoreMsg,self)
    --
    self.dec1 = self.view:GetChild("n22")--列表左 描述
    self.dec2 = self.view:GetChild("n23")--列表右 描述
    --战力
    self.labPower = self.view:GetChild("n50")
    --资质丹 潜力丹 使用个数
    self.labitem1 = self.view:GetChild("n24")
    self.labitem2 = self.view:GetChild("n25")
    --技能
    self.list1 = self.view:GetChild("n30")
    self.list1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list1.numItems = 0
    --装备
    self.list2 = self.view:GetChild("n31")
    self.list2.itemRenderer = function(index,obj)
        self:celldata2(index, obj)
    end
    self.list2.numItems = 0
    --模型
    self.model = self.view:GetChild("n37")
    --返回按钮
    local btnBack = self.view:GetChild("n46")
    btnBack.onClick:Add(self.onBtnBack,self)
    --伙伴列表
    self.list3 = self.view:GetChild("n57")
    self.list3.itemRenderer = function(index,obj)
        self:celldata3(index, obj)
    end
    self.list3.numItems = 0
    self.list3.onClickItem:Add(self.onCallBackItem3,self)
    self.skillList = {}--两个固定模型
    for i = 55,56 do
        local btn = self.view:GetChild("n"..i)
        btn:GetChild("n3").text = ""
        btn.onClick:Add(self.onPetCall,self)
        table.insert(self.skillList,btn)
    end
    --激活条件
    self.jihuodec = self.view:GetChild("n44") 
end
function ZuoPanel:clear()
    -- body
    self.name.text = ""
    self.icon1.url = nil 
    self.icon2.url = nil 
    self.dec1.text = nil 
    self.dec2.text = nil
    self.list1.numItems = 0
    self.list2.numItems = 0
    self.list3.numItems = 0
    self.c1.selectedIndex = 0
    self.model.data = nil 
    self.labitem1.text = ""
    self.labitem2.text = ""
    self.labPower.text = ""
    self.jihuodec.text = ""
end

--技能
function ZuoPanel:celldata(index, obj)
    -- body
    local data = self.leftConf[index+1]

    local icon = obj:GetChild("n2")
    local labLv = obj:GetChild("n3")
    icon.url = ResPath.iconRes(data.icon) --UIPackage.GetItemURL("_icons" , ""..data.icon)

    local lv = self.data.skills[data.id]
    labLv.text = "Lv ".. (lv or "")
    local c1 = obj:GetController("c1")
    c1.selectedIndex = (lv and lv > 0) and 0 or 1
    --obj.data = {id = data.id,lv = lv or 0 ,maxjie = self.maxJie}
end
--装备
function ZuoPanel:celldata2(index,obj)
    -- body
    local frame = obj:GetChild("n4")
    local icon = obj:GetChild("n1") 
    local labLv = obj:GetChild("n2")

    local data = self.rightData[index+1]
    local lv = self.data.equips[data.id]
    
    frame.url = UIItemRes.beibaokuang[data.color]
    icon.url =   ResPath.iconRes(data.icon) --UIPackage.GetItemURL("_icons" , ""..data.icon)
    local lv  = lv and lv or 0 
    if lv > 1 then
        labLv.text = "+"..(lv - 1)
    else
        labLv.text = ""
    end

    local c1 = obj:GetController("c1")
    c1.selectedIndex = lv>0 and 0 or 1
end
function ZuoPanel:initPet()
    -- body
    local condata = conf.HuobanConf:getLeftData(0)
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
    --plog("self.petData1",#self.petData1)
    self.list3.numItems = #self.petData1
    --printt("self.data.partnerSkins",self.data.partnerSkins)
    local pairs = pairs
    for k ,v in pairs(self.skillList) do
        v.data = self.petData2[k]
        local c1 = v:GetController("c1")
        local c2 = v:GetController("c2")
        c2.selectedIndex = 1
        c1.selectedIndex = 0
        for i ,j in pairs(self.data.partnerSkins) do
            if j.skinId == self.petData2[k].id then
                c1.selectedIndex = 1
                break
            end
        end
        local lab =  v:GetChild("n3")
        lab.text = self.petData2[k].dec or ""
        local icon = v:GetChild("n2")
        icon.url = ResPath.iconRes(v.data.icon) -- UIPackage.GetItemURL("_icons" , ""..v.data.icon)
    end
end
function ZuoPanel:celldata3( index,obj )
    -- body
    local data = self.petData1[index+1]
    local c1 = obj:GetController("c1")
    c1.selectedIndex = 0
    for k ,v in pairs(self.data.partnerSkins) do
        if v.skinId == data.id then
            c1.selectedIndex = 1
            break
        end
    end
    local icon = obj:GetChild("n2")
    icon.url =ResPath.iconRes(data.icon) -- UIPackage.GetItemURL("_icons" , ""..data.icon) 

    local lab =  obj:GetChild("n3")
    lab.text = data.dec or ""

    obj.data = data
end

--伙伴模型选中
function ZuoPanel:onCallBackItem3(context)
    -- body
    local data = context.data.data
    self:initModel(data)
end

function ZuoPanel:onPetCall(context)
    -- body
    local data = context.sender.data
    self:initModel(data)
end

--左右切换
function ZuoPanel:onChangeCallBack(context)
    -- body
    if not self.data then
        return
    end

    if self.index == 5 then
        return
    end

    local data = context.sender.data
    if "n20" == data then
        if self.jie > 1 then
            self.jie = self.jie - 1
        end
    else
        if self.jie < self.openMax then
            self.jie = self.jie + 1
        end
    end

    if self.jie < self.openMax then
        self.pageNext.visible = true
    else
        self.pageNext.visible = false
    end

    if self.jie > 1 then
        self.pageBefor.visible = true
    else
        self.pageBefor.visible = false
    end

    --返回是没有旧的就默认选中第一阶皮肤
    self:initModel(nil,self.jie)
end
--更多皮肤
function ZuoPanel:onMoreMsg()
    -- body
    if not self.data then
        return
    end
    local param
    if self.index == 5 then
        param = {skins = self.data.partnerSkins}
    else
        param = {skins = self.data.skins}
    end
    mgr.ViewMgr:openView(ViewName.ZuoQiOtherSkinView, function(view )
        -- body
        view:setDataOther(self.index)
    end,param)
end

--返回
function ZuoPanel:onBtnBack()
    -- body
    if not self.data then
        return
    end
    self:initModel(self.olddata,self.jie)
end
--[[
    if self.controllerC1.selectedIndex == 0 then --属性
        --请求消息
    elseif self.controllerC1.selectedIndex == 1 then --坐骑
    elseif self.controllerC1.selectedIndex == 2 then --法宝
    elseif self.controllerC1.selectedIndex == 3 then --仙羽
    elseif self.controllerC1.selectedIndex == 4 then --仙器
    elseif self.controllerC1.selectedIndex == 5 then --伙伴
    elseif self.controllerC1.selectedIndex == 6 then --伙伴仙器
    elseif self.controllerC1.selectedIndex == 7 then --伙伴神兵
    elseif self.controllerC1.selectedIndex == 8 then --伙伴法宝
    elseif self.controllerC1.selectedIndex == 9 then --伙伴仙羽
    elseif self.controllerC1.selectedIndex == 10 then --神兵
    end
]]
--服务器消息返回
function ZuoPanel:setSelect(index,data)
    -- body
    self.data = data
    self.index = index

    self.maxjie = 0

    self.openMax = 1
    --开始设置信息
    self.btnMore.icon = UIPackage.GetItemURL("see","huoban_001")
    self.btnMore.visible = true
    self.c2.selectedIndex = 0
    if self.index == 1 then--坐骑
        self.dec1.text = language.zuoqi02
        self.dec2.text = language.zuoqi03
        self.btnMore.icon = UIPackage.GetItemURL("see","juesezuoqi_025")
        --装备
        self.rightData = conf.ZuoQiConf:getEquipData(0)
        --技能
        self.leftConf = conf.ZuoQiConf:getSkillData(0)
        --最大阶
        local confData = conf.ZuoQiConf:getDataByLv(data.lev,0)
        self.maxJie = confData.jie
        --当前开启阶数
        self.openMax = conf.ZuoQiConf:getValue("endmaxjie",0) or 10
    elseif self.index == 2 then--法宝
        self.dec1.text = language.zuoqi41
        self.dec2.text = language.zuoqi42
        self.btnMore.icon = UIPackage.GetItemURL("see","juesefabao_004")
        --装备
        self.rightData = conf.ZuoQiConf:getEquipData(2)
        --技能
        self.leftConf = conf.ZuoQiConf:getSkillData(2)
        --最大阶
        local confData = conf.ZuoQiConf:getDataByLv(data.lev,2)
        self.maxJie = confData.jie
         --当前开启阶数
        self.openMax = conf.ZuoQiConf:getValue("endmaxjie",2) or 10
    elseif self.index == 3 then--仙羽
        self.dec1.text = language.zuoqi29
        self.dec2.text = language.zuoqi30
        self.btnMore.icon = UIPackage.GetItemURL("see","juesexianyu_007")
        --装备
        self.rightData = conf.ZuoQiConf:getEquipData(3)
        --技能
        self.leftConf = conf.ZuoQiConf:getSkillData(3)
        --最大阶
        local confData = conf.ZuoQiConf:getDataByLv(data.lev,3)
        self.maxJie = confData.jie
         --当前开启阶数
        self.openMax = conf.ZuoQiConf:getValue("endmaxjie",3) or 10
    elseif self.index == 4 then--仙器
        self.dec1.text = language.zuoqi43
        self.dec2.text = language.zuoqi44

        self.btnMore.icon = UIPackage.GetItemURL("see","juesexianqi_004")
        --装备
        self.rightData = conf.ZuoQiConf:getEquipData(4)
        --技能
        self.leftConf = conf.ZuoQiConf:getSkillData(4)
        --最大阶
        local confData = conf.ZuoQiConf:getDataByLv(data.lev,4)
        self.maxJie = confData.jie
         --当前开启阶数
        self.openMax = conf.ZuoQiConf:getValue("endmaxjie",4) or 10
    elseif self.index == 5 then--伙伴
        self.dec1.text = language.huoban02
        self.dec2.text = language.huoban03
        self.btnMore.icon = UIPackage.GetItemURL("see","huoban_055")
        --装备
        self.rightData = conf.HuobanConf:getRightData(0)
        --技能
        self.leftConf = conf.HuobanConf:getHuobanSkill()
        local confData = conf.HuobanConf:getDataByLv(data.lev,0)
        self.maxJie = confData.jie
    elseif self.index == 6 then----伙伴仙器
        self.dec1.text = language.huoban10
        self.dec2.text = language.huoban11
        self.btnMore.icon = UIPackage.GetItemURL("see","xianqi_004")
        --装备
        self.rightData = conf.HuobanConf:getRightData(4)
        --技能
        self.leftConf = conf.HuobanConf:getLeftData(4)
        local confData = conf.HuobanConf:getDataByLv(data.lev,4)
        self.maxJie = confData.jie
         --当前开启阶数
        self.openMax = conf.HuobanConf:getValue("endmaxjie",4) or 10
    elseif self.index == 7 then --伙伴神兵
        self.dec1.text = language.huoban06
        self.dec2.text = language.huoban07
        self.btnMore.icon = UIPackage.GetItemURL("see","shenbin_005")
        --装备
        self.rightData = conf.HuobanConf:getRightData(2)
        --技能
        self.leftConf = conf.HuobanConf:getLeftData(2)
        local confData = conf.HuobanConf:getDataByLv(data.lev,2)
        self.maxJie = confData.jie
         --当前开启阶数
        self.openMax = conf.HuobanConf:getValue("endmaxjie",2) or 10
    elseif self.index == 8 then--伙伴法宝
        self.dec1.text = language.huoban08
        self.dec2.text = language.huoban09
        self.btnMore.icon = UIPackage.GetItemURL("see","fabao_004")
        --装备
        self.rightData = conf.HuobanConf:getRightData(3)
        --技能
        self.leftConf = conf.HuobanConf:getLeftData(3)
        local confData = conf.HuobanConf:getDataByLv(data.lev,3)
        self.maxJie = confData.jie
         --当前开启阶数
        self.openMax = conf.HuobanConf:getValue("endmaxjie",3) or 10
    elseif self.index == 9 then--伙伴仙羽
        self.dec1.text = language.huoban04
        self.dec2.text = language.huoban05
        self.btnMore.icon = UIPackage.GetItemURL("see","xianyu_007")
        --装备
        self.rightData = conf.HuobanConf:getRightData(1)
        --技能
        self.leftConf = conf.HuobanConf:getLeftData(1)
        --最大阶
        local confData = conf.HuobanConf:getDataByLv(data.lev,1)
        self.maxJie = confData.jie
         --当前开启阶数
        self.openMax = conf.HuobanConf:getValue("endmaxjie",1) or 10
    elseif self.index == 10 then--神兵
        self.dec1.text = language.zuoqi39
        self.dec2.text = language.zuoqi40
        self.btnMore.icon = UIPackage.GetItemURL("see","jueseshenbin_005")
        --装备
        self.rightData = conf.ZuoQiConf:getEquipData(1)
        --技能
        self.leftConf = conf.ZuoQiConf:getSkillData(1)
        --最大阶
        local confData = conf.ZuoQiConf:getDataByLv(data.lev,1)
        self.maxJie = confData.jie
         --当前开启阶数
        self.openMax = conf.ZuoQiConf:getValue("endmaxjie",1) or 10
    elseif self.index == 15 then--麒麟臂
        self.c2.selectedIndex = 1

        self.dec1.text = language.zuoqi78
        self.dec2.text = language.zuoqi79

        self.btnMore.icon = nil
        self.btnMore.visible = false
        --装备
        self.rightData = conf.ZuoQiConf:getEquipData(5)
        --技能
        self.leftConf = conf.ZuoQiConf:getSkillData(5)
        --最大阶
        local confData = conf.ZuoQiConf:getDataByLv(data.lev,5)
        self.maxJie = confData.jie

        self.openMax = conf.ZuoQiConf:getValue("endmaxjie",5) or 10
    end
    --技能
    table.sort(self.leftConf,function (a,b)
        -- body
        return a.id < b.id
    end)
    local number = #self.leftConf
    self.list1.numItems = number
    --装备
    table.sort(self.rightData,function (a,b)
        -- body
        return a.id < b.id
    end)
    local number = #self.rightData
    self.list2.numItems = number
    if self.index == 5 then--伙伴
        self:initPet()
    end
    --战力
    self.labPower.text = self.data.power
    --弹药使用各个个数
    self.labitem1.text = self.data.zzdNum
    self.labitem2.text = self.data.qldNum
    --printt(self.data)
    --模型选中
    self.olddata = nil --清理原来的
    self.selectdata = nil --当前选中
    if self.index == 1 then
        self.selectdata = conf.ZuoQiConf:getSkinsByModle(data.currentSkinId,0)
    elseif self.index == 2 then---法宝
        self.selectdata = conf.ZuoQiConf:getSkinsByModle(data.currentSkinId,2)
    elseif self.index == 3 then--仙羽
        self.selectdata = conf.ZuoQiConf:getSkinsByModle(data.currentSkinId,3)
    elseif self.index == 4 then--仙器
        self.selectdata = conf.ZuoQiConf:getSkinsByModle(data.currentSkinId,4)
    elseif self.index == 10 then--神兵
        self.selectdata = conf.ZuoQiConf:getSkinsByModle(data.currentSkinId,1)
    elseif self.index == 5 then--伙伴
        self.selectdata = conf.HuobanConf:getSkinsByModle(data.currentSkinId,0)
    elseif self.index == 6 then----伙伴仙器
        self.selectdata = conf.HuobanConf:getSkinsByModle(data.currentSkinId,4)
    elseif self.index == 7 then --伙伴神兵
        self.selectdata = conf.HuobanConf:getSkinsByModle(data.currentSkinId,2)
    elseif self.index == 8 then--伙伴法宝
        self.selectdata = conf.HuobanConf:getSkinsByModle(data.currentSkinId,3)
    elseif self.index == 9 then--伙伴仙羽
        self.selectdata = conf.HuobanConf:getSkinsByModle(data.currentSkinId,1)
    elseif self.index == 15 then--麒麟臂
        self.selectdata = conf.ZuoQiConf:getSkinsByModle(data.currentSkinId,5)
    end
    if self.selectdata then
        self.jie = self.selectdata.grow_cons or 1
        
    else
        self.jie = self.maxJie or 1
    end

    if self.jie <= 0 then
        self.jie = 1
    end


    if not self.maxJie then
        self.maxJie = 0
    end
    self:initModel(self.selectdata,self.jie) 
end
--设定模型
function ZuoPanel:initModel(condata,jie)
    -- body
    local cansee = false
    if not condata then
        --返回是没有旧的就默认选中第一阶皮肤
        if not jie then
            jie = 1
        elseif jie <= 0 then
            jie = 1
        end
        if self.index == 1 then
            condata = conf.ZuoQiConf:getSkinsByJie(jie,0)
        elseif self.index == 2 then---法宝
            condata = conf.ZuoQiConf:getSkinsByJie(jie,2)
        elseif self.index == 3 then--仙羽
            condata = conf.ZuoQiConf:getSkinsByJie(jie,3)
        elseif self.index == 4 then--仙器
            condata = conf.ZuoQiConf:getSkinsByJie(jie,4)
        elseif self.index == 10 then--神兵
            condata = conf.ZuoQiConf:getSkinsByJie(jie,1)
        elseif self.index == 5 then--伙伴
            condata = conf.HuobanConf:getSkinsByIndex(1001001,0)
        elseif self.index == 6 then----伙伴仙器
            condata = conf.HuobanConf:getSkinsByJie(jie,4)
        elseif self.index == 7 then --伙伴神兵
            condata = conf.HuobanConf:getSkinsByJie(jie,2)
        elseif self.index == 8 then--伙伴法宝
            condata = conf.HuobanConf:getSkinsByJie(jie,3)
        elseif self.index == 9 then--伙伴仙羽
            condata = conf.HuobanConf:getSkinsByJie(jie,1)
        elseif self.index == 15 then
            condata = conf.ZuoQiConf:getSkinsByJie(jie,5)
        end
    end
    --当前选中第几阶
    if jie then
        self.jie = jie
    else
        self.jie = 1
    end

    --当前选中一些处理
    self.selectdata = condata
    --按照选中的皮肤设置属性
    self.parent:onSkinBack(condata)

    self.jihuodec.text= ""
    self.icon2.visible = false
    if self.index == 5 then --伙伴
        self.pageNext.visible = false
        self.pageBefor.visible = false

        self.c1.selectedIndex = 3
        --名字
        self.name.text = condata.name


        local falg = false
        for k ,v in pairs(self.data.partnerSkins) do
            if v.skinId == condata.id then
                self.name.text = v.name
                falg = true
                break
            end
        end

        if condata.istshu and condata.istshu == 2 then
            if falg then
                self.c1.selectedIndex = 1
            else
                self.jihuodec.text = condata.dec
                self.c1.selectedIndex = 2
            end
        end
         
        
        if condata.type then
            for k ,v in pairs(condata.type) do
                if k > 2 then
                    break
                end
                if k == 1 then
                    self.icon1.url = UIPackage.GetItemURL("see" , "huoban_0"..(34+v))
                else
                    self.icon2.url = UIPackage.GetItemURL("see" , "huoban_0"..(34+v))
                    self.icon2.visible = true
                end
            end
        end

        self.icon3.url = ResPath:petChengHao(self.maxJie)
    else
        self.name.text = condata.name
        self.icon1.url = UIItemRes.jieshu[condata.grow_cons]
        if condata.grow_cons then
            self.c1.selectedIndex = 0
           --plog("self.jie="..self.jie,"self.maxJie="..self.maxJie)
            if self.jie > self.maxJie then
                self.jihuodec.text = string.format(language.zuoqi60,self.jie)
            end
        else
            --是否获得
            local falg = false
            for k ,v in pairs(self.data.skins) do
                if type(v) == "number" then
                    if tonumber(v) == tonumber(condata.id) then
                        falg = true
                        break
                    end
                else
                    if tonumber(v.skinId) == tonumber(condata.id) then
                        falg = true
                        break
                    end
                end
            end
            if falg then --激活
                self.c1.selectedIndex = 1
            else--未激活
                self.c1.selectedIndex = 2
                self.jihuodec.text = condata.desc
            end
        end  

        if self.selectdata.grow_cons then
            if self.jie < self.openMax then
                self.pageNext.visible = true
            else
                self.pageNext.visible = false
            end

            if self.jie > 1 then
                self.pageBefor.visible = true
            else
                self.pageBefor.visible = false
            end
        end
    end
    

    --返回时候的记录
    if self.index~= 5 then
        if condata.grow_cons then
            self.olddata = condata            
        end
    else
        if condata.istshu and condata.istshu ~= 2 then
            self.olddata = condata 
        end
    end
    --开始设置模型
    local panel = self.model:GetChild("n0")
    local touc = self.model:GetChild("n1")
    local node = self.model:GetChild("n2")
    --移除模型
    self.parent:removeModel(self.model.data)
    self.model.data = nil 
    --移除特效
    self.parent:removeUIEffect(self.effect)
    self.effect = nil 
    --脚底
    self.parent:removeUIEffect(self.effect1)
    self.effect1 = nil

    self.t0:Stop()
    if self.index == 1 then--坐骑
        touc.touchable = true
        --模型
        self.model.data,cansee = self.parent:addModel(condata.modle_id,panel)
        self.model.data:setScale(SkinsScale[condata.modle_id] or SkinsScale[Skins.zuoqi])
        self.model.data:setRotationXYZ(0,130,0)
        self.model.data:setPosition(panel.actualWidth/2,-panel.actualHeight-30,100)
        --脚底特效
        self.effect1 = self.parent:addEffect(4020102,node)
        self.effect1.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight+40 ,100)
        if condata.xyz then
            self.model.data:setRotationXYZ(condata.xyz[1],condata.xyz[2],condata.xyz[3])--180
        end
        self.model.data:modelTouchRotate(touc)


    elseif self.index == 2 then--法宝
        self.t0:Play()
        touc.touchable = false
        self.effect = self.parent:addEffect(condata.modle_id,panel)
        self.effect.Scale = Vector3.New(300,300,300)
        self.effect.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-50,100)
    elseif self.index == 3 then--仙羽
        self.model.data,cansee = self.parent:addModel(condata.modle_id,panel)
        cansee = self.model.data:setSkins(GuDingmodel[1],nil,condata.modle_id)
        self.model.data:setScale(SkinsScale[Skins.xianyu])
        self.model.data:setRotationXYZ(0,341,0)--180
        self.model.data:setPosition(panel.actualWidth/2,-panel.actualHeight-70,100)
        --脚底特效
        self.effect1 = self.parent:addEffect(4020102,node)
        self.effect1.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight,100)

        self.model.data:modelTouchRotate(touc)
    elseif self.index == 4 then--仙器
        touc.touchable = false
        self.effect = self.parent:addEffect(condata.modle_id,panel)
        if condata.scale then
            self.effect.Scale = Vector3.New(condata.scale,condata.scale,condata.scale)
        end
        local offx = condata.offect_xy and condata.offect_xy[1] or 0
        local offy = condata.offect_xy and condata.offect_xy[2] or 0
        local z = condata.offect_xy and condata.offect_xy[3] or 100
        if  condata.offect_xy then
            self.effect.LocalPosition = Vector3(offx,offy,z)
        else
            self.effect.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-100,100)
        end
    elseif self.index == 10 then--神兵
        self.t0:Play()
        touc.touchable = false

        self.model.data,cansee = self.parent:addModel(GuDingmodel[3],panel)
        self.model.data:setPosition(panel.actualWidth/2+50,-200,100)
        self.model.data:setRotationXYZ(30,90,90)
        self.model.data:setScale(SkinsScale[Skins.wuqi])
        self.model.data:addModelEct(condata.modle_id.."_ui")
    elseif self.index == 5 then--伙伴
        touc.touchable = true
        self.model.data,cansee = self.parent:addModel(condata.modle_id,panel)
        self.model.data:setScale(SkinsScale[Skins.huoban])
        self.model.data:setPosition(panel.actualWidth/2,-panel.actualHeight-20,100)  
         --脚底特效
        self.effect1 = self.parent:addEffect(4020102,node)
        self.effect1.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight+50,100)

        self.model.data:modelTouchRotate(touc)

        self.model.data:setRotationXYZ(0,0,0)
        if condata.xyz then
            self.model.data:setRotationXYZ(condata.xyz[1],condata.xyz[2],condata.xyz[3])--180
        end
    elseif self.index == 6 then----伙伴仙器
        self.t0:Play()
        touc.touchable = false
        self.effect = self.parent:addEffect(condata.modle_id,panel)
        self.effect.Scale = Vector3.New(300,300,300)
        self.effect.LocalRotation = Vector3.New(340,0,0)
        self.effect.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-400,100)
    elseif self.index == 7 then --伙伴神兵
        touc.touchable = false
        --cache.PlayerCache:getSkins(Skins.huoban)
        self.model.data,cansee = self.parent:addModel(GuDingmodel[2],panel)
        self.model.data:setScale(SkinsScale[Skins.huoban])
        self.model.data:setPosition(panel.actualWidth/2,-panel.actualHeight-20,100) 
        self.model.data:addWeaponEct(condata.modle_id.."_ui")

         --脚底特效
        self.effect1 = self.parent:addEffect(4020102,node)
        self.effect1.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight+50,100)

        self.model.data:setRotationXYZ(0,0,0)
        if condata.xyz then
            self.model.data:setRotationXYZ(condata.xyz[1],condata.xyz[2],condata.xyz[3])--180
        end
    elseif self.index == 8 then--伙伴法宝
        self.t0:Play()
        touc.touchable = false
        self.effect = self.parent:addEffect(condata.modle_id,panel)
        self.effect.Scale = Vector3.New(300,300,300)
        self.effect.LocalRotation = Vector3.New(340,0,0)
        self.effect.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight+130,100)
    elseif self.index == 9 then--伙伴仙羽
        touc.touchable = false
        self.model.data,cansee = self.parent:addModel(GuDingmodel[2],panel)
        self.model.data:setScale(SkinsScale[Skins.huoban])
        self.model.data:setPosition(panel.actualWidth/2,-panel.actualHeight-20,100) 
         --脚底特效
        self.effect1 = self.parent:addEffect(4020102,node)
        self.effect1.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight+50,100)
        cansee = self.model.data:setSkins(GuDingmodel[2],nil,condata.modle_id)
        self.model.data:setRotationXYZ(0,0,0) 
        if condata.xyz then
            self.model.data:setRotationXYZ(condata.xyz[1],condata.xyz[2],condata.xyz[3])--180
        end
    elseif self.index == 15 then--麒麟臂
        touc.touchable = true
        --cache.PlayerCache:getSkins(Skins.huoban)
        self.model.data,cansee = self.parent:addModel(GuDingmodel[1],panel)
        self.model.data:setScale(SkinsScale[Skins.huoban])
        self.model.data:setPosition(panel.actualWidth/2,-panel.actualHeight-20,100) 
        self.model.data:addQingbiEct(condata.modle_id.."_ui")

         --脚底特效
        self.effect1 = self.parent:addEffect(4020102,node)
        self.effect1.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight+50,100)

        self.model.data:setRotationXYZ(0,168.9,0)
        if condata.xyz then
            --self.model.data:setRotationXYZ(condata.xyz[1],condata.xyz[2],condata.xyz[3])--180
        end
        self.model.data:modelTouchRotate(touc)
    end

    self.view:GetChild("n59").visible = cansee



    --动态居中计算
    local width = 0 --self.model.x  
    if self.name.visible then
        width = width + self.name.width
    end
    if self.icon1.visible then
        width = width + self.icon1.width
    end
    if self.icon2.visible then
        width = width + self.icon2.width
    end


    local offx = self.model.x + (self.model.width-width)/2
    if self.name.visible then
        self.name.x = offx
        offx = self.name.width + self.name.x
    end
    if self.icon1.visible then
        self.icon1.x = offx
        offx = self.icon1.width + self.icon1.x
    end
    if self.icon2.visible then
        self.icon2.x = offx
    end
end

return ZuoPanel