
local VipAttributePanel = class("VipAttributePanel", import("game.base.Ref"))

local MAXVIP = 13

local VIPICON = {
    [1] = "chongzhivip_129",
    [2] = "chongzhivip_130",
    [3] = "chongzhivip_131",
    [4] = "chongzhivip_132",
    [5] = "chongzhivip_133",
    [6] = "chongzhivip_134",
    [7] = "chongzhivip_135",
    [8] = "chongzhivip_136",
    [9] = "chongzhivip_137",
    [10] = "chongzhivip_138",
    [11] = "chongzhivip_139",
    [12] = "chongzhivip_180",
    [13] = "chongzhivip_181",
}

function VipAttributePanel:ctor(mParent)
    -- body
    self.parent = mParent
    self:initView()
end

function VipAttributePanel:initView()
    -- body
    self.view = self.parent.view:GetChild("n42")
    self.attList = {} --属性列表
    for i=46,53 do
        local text = self.view:GetChild("n"..i)
        text.text = ""
        table.insert(self.attList,text)
    end

    self.controllerC1 = self.view:GetController("c1")
    self.canAct = false

    self.icon = self.view:GetChild("n40") 

    local vipLv = cache.PlayerCache:getVipLv()
    self.index = (vipLv-1)>0 and vipLv-1 or 0
    self:initVipAtt()

    self:initDiscountedPacksPanel() --VIP折扣礼包
end

--加载VIP属性
function VipAttributePanel:initVipAtt()
    -- body
    for k,v in pairs(self.attList) do
        v.text = ""
    end
    local vipLv = cache.PlayerCache:getVipLv()
    local vipStars = cache.PlayerCache:getVipStars()
    self.controllerC1.selectedIndex = vipStars-1
    local vipExp = cache.PlayerCache:getVipExp()
    local id = vipLv*1000+vipStars
    local vipLvTxt = self.view:GetChild("n69")
    self.vipExpBar = self.view:GetChild("n111")
    local starsDecTxt = self.view:GetChild("n55")
    local costDecTxt = self.view:GetChild("n56")
    local btnCharge = self.view:GetChild("n10")
    btnCharge:GetChild("red").visible = false
    local btnAct = self.view:GetChild("n87")
    local dec = self.view:GetChild("n84")
    local power = self.view:GetChild("n61")--VIP加成属性所提高的战力
    power.text = 0
    dec.visible = false
    self.view:GetChild("n110").visible = false
    vipLvTxt.text = vipLv 

    -- print("当前VIP等级为为为：",self.curVipLv,vipLv)    
    self:compareAndObtainTheRealLevel(self.curVipLv, vipLv)  --EVE 用于获取当且界面就提升的VIP的实时等级
    

    if vipLv == 0 then
        self.icon.url = nil
    else
        self.icon.url = UIPackage.GetItemURL("vip" , VIPICON[vipLv])
    end
    
    if vipLv >= 1 then
        btnCharge.onClick:Add(self.onClickCharge, self)
        btnAct.visible = false
        btnCharge.visible = true
        local vipAttConf = conf.VipChargeConf:getVipAttrDataById(id)    
        local data = GConfDataSort(vipAttConf)
        power.text = vipAttConf.pow
        for k,v in pairs(data) do
            local key = v[1]
            local value = v[2]
            local decTxt = self.attList[k]
            local attName = conf.RedPointConf:getProName(key)
            decTxt.text = attName..":+"..value
        end
        if vipLv == 1 then
            self.controllerC1.selectedIndex = 11 --屏蔽星级
            self.vipExpBar.visible = true
            starsDecTxt.visible = false
            costDecTxt.visible = true
            local nextVipConf = conf.VipChargeConf:getVipAttrDataById(2001)
            local needVipExp = nextVipConf.vip_exp - vipAttConf.vip_exp
            local needCharge = (nextVipConf.vip_exp - vipExp) > 0 and (nextVipConf.vip_exp - vipExp) or 0
            self.vipExpBar.value = vipExp-vipAttConf.vip_exp
            self.vipExpBar.max = needVipExp
            costDecTxt.text = string.format(language.vip13,needCharge,2)--language.vip08
            if vipExp-vipAttConf.vip_exp >= needVipExp then
                self.canUp = true
                starsDecTxt.text = language.vip33
                btnCharge:GetChild("icon").url = UIPackage.GetItemURL("_imgfonts" , "chengjiu_031")
                btnCharge:GetChild("red").visible = true
            else
                btnCharge:GetChild("icon").url = UIPackage.GetItemURL("vip" , "chongzhivip_045")
                self.canUp = false
            end
        else
            --计算下一等级需要的经验
            local nextId = id
            if vipStars == 10 then
                nextId = (vipLv+1)*1000+1
            else
                if vipLv == 1 then
                    nextId = 2001
                else
                    nextId = id+1
                end
            end
            local nextVipConf = conf.VipChargeConf:getVipAttrDataById(nextId)
            if nextVipConf then
                local needVipExp = nextVipConf.vip_exp - vipAttConf.vip_exp
                self.vipExpBar.visible = true
                self.vipExpBar.value = vipExp-vipAttConf.vip_exp
                self.vipExpBar.max = needVipExp
                starsDecTxt.visible = true
                starsDecTxt.text = string.format(language.vip12,(nextVipConf.vip_exp-vipExp))
                if vipExp-vipAttConf.vip_exp >= needVipExp then
                    self.canUp = true
                    starsDecTxt.text = language.vip33
                    btnCharge:GetChild("icon").url = UIPackage.GetItemURL("_imgfonts" , "chengjiu_031")
                    btnCharge:GetChild("red").visible = true
                else
                    btnCharge:GetChild("icon").url = UIPackage.GetItemURL("vip" , "chongzhivip_045")
                    self.canUp = false
                end
            end
            if vipLv < MAXVIP then
                local nextVipLv = vipLv+1
                -- if nextVipLv > 10 then
                --     costDecTxt.visible = false
                -- else
                    local nextVipId = nextVipLv*1000+1
                    local conf = conf.VipChargeConf:getVipAttrDataById(nextVipId)
                    local nextVipExp = conf.vip_exp
                    local needCharge = nextVipExp-vipExp > 0 and (nextVipExp-vipExp) or 0
                    costDecTxt.text = string.format(language.vip13,needCharge,nextVipLv)
                    if vipStars == 10 then
                        costDecTxt.visible =true
                        starsDecTxt.visible = false
                    end
                -- end
            else
                self.controllerC1.selectedIndex = vipStars
                costDecTxt.visible =false
                if vipStars == 10 then
                    self.vipExpBar.value = vipExp
                    self.vipExpBar.max = vipAttConf.vip_exp
                    costDecTxt.visible =true
                    costDecTxt.text = language.vip17
                    starsDecTxt.visible = false
                    btnCharge:GetChild("icon").url = UIPackage.GetItemURL("vip" , "chongzhivip_045")
                    self.canUp = false
                end
            end
        end
    else
        self.view:GetChild("n110").visible = true
        self.view:GetChild("n110").text = language.vip09
        dec.visible = true
        self.controllerC1.selectedIndex = 11 --屏蔽星级
        self.vipExpBar.visible = true
        starsDecTxt.visible = false
        costDecTxt.visible = false

        self.vipExpBar.value = cache.PlayerCache:getRoleLevel()
        self.vipExpBar.max = 30
        if cache.PlayerCache:getRoleLevel() >= 30 then
            self.vipExpBar:GetChild("title").text = language.vip10
        end
        btnAct.onClick:Add(self.onClickActive, self)
        btnAct.visible = true
        btnCharge.visible = false
    end
end

--充值、升级按钮
function VipAttributePanel:onClickCharge()
    -- body
    if self.canUp then
        proxy.VipChargeProxy:sendVipUpGrade()
    else
        self.parent.controllerC1.selectedIndex = 0
    end
end
--激活按钮
function VipAttributePanel:onClickActive()
    -- body
        -- print("激活按钮",self.canAct)
    -- if self.canAct then
    --     proxy.VipChargeProxy:sendFirstGetVipMsg()
    -- else
    --     GComAlter(language.vip15)
    -- end
    self.parent:onClickClose()
    GOpenView({id = 1053 ,index = 0})
end

function VipAttributePanel:celldata(index, obj)
    local icon = obj:GetChild("icon")
    local iconUrlDown = UIPackage.GetItemURL("vip" , "".."chongzhivip_0"..(18+index))
    local iconUrlUp = UIPackage.GetItemURL("vip" , "".."chongzhivip_0"..(string.format("%02d",(5+index))))
    obj.onClick:Add(self.onClickVipBtn,self)
    obj.data = index
    if index == self.index then
        obj.selected = true
        icon.url = iconUrlUp
    else
        obj.selected = false
        icon.url = iconUrlDown
    end
    if index == 3 then
        obj:GetChild("n4").visible = true
    else
        obj:GetChild("n4").visible = false
    end
end
function VipAttributePanel:onClickVipBtn( context )
    local item = context.sender
    self.index = item.data
    -- print("点击",item.data)
    self:initVipAtt()
    -- self:setAttr(item.data)
    self.btnListView:RefreshVirtualList()
end 


--EVE VIP折扣礼包
function VipAttributePanel:initDiscountedPacksPanel()
    self.discountedPacksList = self.view:GetChild("n129"):GetChild("n0")

    self.curSex = cache.PlayerCache:getSex()--当前性别

    -- print("当前性别:",self.curSex)

    self:initListView()
end

function VipAttributePanel:initListView()
    self.discountedPacksList.itemRenderer = function (index,obj)
        self:discountedPacksListData(index, obj)
    end
    self.discountedPacksList:SetVirtual()
    self.discountedPacksList.numItems = 0
end

function VipAttributePanel:discountedPacksListData(index, obj)
    -- body
    local data = self.discountedPackConfData[index+1]
    --VIP等级
    local vipLv = obj:GetChild("n3")
    vipLv.text = string.format(language.vip35,data.vip_lev)
    --奖励ICON
    local awardList = obj:GetChild("n6")
    if self.curSex == 2 then 
        GSetAwards(awardList,data.item_other)
    else
        GSetAwards(awardList,data.item)
    end 
    --原价
    local oldPrice = obj:GetChild("n14")
    oldPrice.text = data.old_price
    --现价
    local price = obj:GetChild("n13")
    price.text = data.price
    --折扣
    local discount = obj:GetController("c1")
    discount.selectedIndex = data.price/data.old_price*10 - 1
    --是否已经购买
    local isBuy = obj:GetController("c2")
    if self.buys[data.id] then 
        isBuy.selectedIndex = 1 
    else
        isBuy.selectedIndex = 0
    end 
    --购买
    local btnGet = obj:GetChild("n7")
    local isOK = false                   --检测当前VIP等级是否符合
    if self.curVipLv >= data.vip_lev then 
        isOK = true
    end 
    local data = {id = data.id, isOK = isOK} 
    btnGet.data = data --按钮的状态 
    btnGet.onClick:Add(self.onClickGet,self)
end

function VipAttributePanel:onClickGet( context )
    local cell = context.sender
    local data = cell.data   

    if data.isOK then 
        -- print("购买那个档的奖励",data.id) 
        proxy.ActivityProxy:send(1130106,{reqType = 1, cfgId = data.id}) --购买请求
    else
        GComAlter(language.vip36)
    end
end

function VipAttributePanel:setDiscountedPacksData(data)
    -- body
    -- print("VIP折扣礼包消息返回成功666")
    -- printt(data)

    --购买完成弹窗
    if data.items and #data.items>0 then
        -- print("恭喜获得@！！！")
        GOpenAlert3(data.items)
    end

    self.curVipLv = cache.PlayerCache:getVipLv()                              --当前VIP等级

    self:setReturnMsg(data.buys)                                              --设置已购买的

    self.discountedPackConfData = conf.VipChargeConf:getDiscountedPacksConf() --配置

    self.discountedPacksList.numItems = #self.discountedPackConfData
end

function VipAttributePanel:setReturnMsg(data)
    self.buys = {}

    for _,v in pairs(data) do
        self.buys[v] = true
    end
end

--用于比较并且获取实时改变的VIP等级
function VipAttributePanel:compareAndObtainTheRealLevel(curVipLv, realLv)
    if not realLv then 
        -- print("实时等级为nil")
        return
    end 

    if not curVipLv or curVipLv < realLv then 
        -- print("获取实时等级的VIP消息")
        proxy.VipChargeProxy:sendDiscountedPacksMsg()
        return
    end  
end

return VipAttributePanel