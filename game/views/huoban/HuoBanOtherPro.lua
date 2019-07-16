--
-- Author: 
-- Date: 2017-02-27 10:30:04
--

local HuoBanOtherPro = class("HuoBanOtherPro",import("game.base.Ref"))
local SKINSMODELID = {
    [1] = 1007,
    [2] = 1008,
    [3] = 1010,
    [4] = 1009,
}
function HuoBanOtherPro:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n21")
    self:initView()
end

function HuoBanOtherPro:initView()
    -- body
    --升阶 属性 满阶
    self.c1 = self.view:GetController("c1")
    --icon控制其
    self.c2 = self.view:GetController("c2")

    self.c3 = self.view:GetController("c3")
    --属性
    self.proList = {}
    for i = 14,20 do
        local lab = self.view:GetChild("n"..i)
        lab.text = ""
        table.insert(self.proList,lab)
    end
    -- self.proMore = {}--皮肤单独
    -- for i = 28,34 do
    --     local lab = self.view:GetChild("n"..i)
    --     lab.text = ""
    --     table.insert(self.proMore,lab)
    -- end
     --升星属性
    self.starSuitImg = self.view:GetChild("n63")
    self.starSuitImg.visible = false
    self.proMporeList = self.view:GetChild("n56")
    self.proMporeList.numItems = 0
    self.starAttrList = {}
    for i=60,62 do
        local lab = self.view:GetChild("n"..i)
        lab.text = ""
        table.insert(self.starAttrList, lab)
    end

    self.tempList = {}--临时
    for i = 44,50 do
        local lab = self.view:GetChild("n"..i)
        lab.text = ""
        table.insert(self.tempList,lab)
    end
    --
    self.dec1 =  self.view:GetChild("n42")
    self.dec1.text = ""
    self.btnPlusTop = self.view:GetChild("n43")
    self.btnPlusTop.onClick:Add(self.onBtnPlusTop,self)

    self.decvalue = self.view:GetChild("n35")
    self.decvalue.text= language.zuoqi31
    self.decvalue.visible = false
    self.value = self.view:GetChild("n36")
    self.value.text = "0"
    self.value.visible = false

    local btnWen = self.view:GetChild("n37")
    btnWen.onClick:Add(self.onBtnWen,self)

    self.bar = self.view:GetChild("n5")
    self.itemObj = self.view:GetChild("n38")
    self.itemName = self.view:GetChild("n39")
    self.itemCount =  self.view:GetChild("n40")
    self.btnPlus2 = self.view:GetChild("n11")
    self.btnPlus2.onClick:Add(self.onBtnPlusBottom,self)
    self.btnJie = self.view:GetChild("n6")
    self.btnJie.onClick:Add(self.onBtnJie,self)
    self.redimg = self.btnJie:GetChild("red")

    self.jieNotClear = self.view:GetChild("n52")
    self.jieNotClear.text = language.zuoqi66
    self.jieNotClear.visible = false

    --  --几颗星
    self.xin = self.view:GetChild("n53")
    -- self.xinC1 = self.xin:GetController("c1") 
    self.xin.visible = false
    self.parent:addTimer(1, -1, handler(self,self.onTimer))
end

function HuoBanOtherPro:onTimer()
    -- body
    --plog(self.index,self.jie)
    self:setistimer()
    if self.index and self.jie then
        local var = conf.HuobanConf:getValue("bless_clear_jie",self.index)
        if var and self.jie < var then
            self.jieNotClear.text = language.zuoqi65
            self.jieNotClear.visible = true
            self.decvalue.visible = false
            self.value.visible = false
            return 
        else
            self.redimg.visible = false
        end
    end

    self.jieNotClear.text = ""
    if self.data and self.data.blessTime and  self.data.blessTime ~= 0 then
        local var = 24*3600 -(mgr.NetMgr:getServerTime()-self.data.blessTime) 
        if var > 0 then
            -- print(">>>>>>>>>>>>>>",language.zuoqi31,GTotimeString(var))
            self.jieNotClear.text = ""
            self.istimer = true
            self.value.text = GTotimeString(var)
            self.decvalue.text = language.zuoqi31
            self.decvalue.visible = true
            self.value.visible = true
        else
            self.decvalue.visible = false
            self.value.visible = false
            self.jieNotClear.text = language.zuoqi66
            self.jieNotClear.visible = true
            --self.decvalue.text = ""
            --self.value.text = ""
        end
    else
        self.jieNotClear.text = language.zuoqi66
        self.jieNotClear.visible = true
        self.decvalue.visible = false
        self.value.visible = false
    end
end
---这个方法用于关闭的时候一个单纯
function HuoBanOtherPro:setistimer()
    -- body
    self.istimer = false
end

function HuoBanOtherPro:isOverTime()
    -- body
    return  self.istimer
end

function HuoBanOtherPro:setCostItem()
    -- body
    if not self.data or not self.confdata then
        return
    end
    if self.confdata.cost_items then 
        self.itemObj.visible = true
        self.btnPlus2.visible = true

        local t = {}
        t.mid = self.confdata.cost_items[1]
        t.isquan = true
        self.usemid = t.mid
        self.useAmount = self.confdata.cost_items  and self.confdata.cost_items[2] or 0 

        local confItemData = conf.ItemConf:getItem(t.mid)
        GSetItemData(self.itemObj,t,true)
        self.itemName.text = confItemData.name
        local var = cache.PackCache:getLinkCost(t.mid)  --getPackDataById(t.mid).amount
        self.itemCount.text = var.."/"..self.confdata.cost_items[2]


        self.redimg.visible = true
        if var < self.confdata.cost_items[2] then
            self.redimg.visible = false
            local param = {
                {color = 14,text = var},
                {color = 7,text = "/"..self.confdata.cost_items[2]}
            }
            self.itemCount.text = mgr.TextMgr:getTextByTable(param)
        end

        local var = conf.HuobanConf:getValue("bless_clear_jie",self.index)
        if self.jie >= var then
            self.redimg.visible = false
        end
    else
        self.redimg.visible = false
        self.itemObj.visible = false
        self.itemCount.text = ""
        self.itemName.text = ""
        self.btnPlus2.visible = false
    end

    self.bar.value = checkint(self.data.levExp) 
    self.bar.max = self.confdata.need_exp or checkint(self.data.levExp)
    
end

function HuoBanOtherPro:setXin(number)
    -- body
    if number == 0 then
        self.xinC1.selectedIndex = 0
        return
    end

    if self.parent.is10 then
        if number~=0 then
            self.xinC1.selectedIndex = number + 10 
        end
    else
        local oldxin = self.xinC1.selectedIndex
        if oldxin > 10 then
            oldxin = oldxin - 10
        end

        if oldxin ~= number then
            self.xinC1.selectedIndex = number
        end
    end
end
--
function HuoBanOtherPro:setData(data)
    --printt(data)
    self.data = data
    --printt(data)
    self.index = self.parent.c1.selectedIndex --当前选中的是那个
    --plog(".self.index..",self.index,self.index)
    --plog(self.data.lev,self.index)
    self.confdata = conf.HuobanConf:getDataByLv(self.data.lev, self.index)
    -- self:setXin(self.confdata.xing)
    
    self.nextconf = conf.HuobanConf:getDataByLv(self.data.lev+1, self.index)
    self.jie = self.confdata.jie or 1
    if self.jie < 1 then
        self.jie = 1
    end
    if self.index == 0 then
        self.moduleConf = conf.SysConf:getModuleById(1006)
    elseif self.index == 1 then
        self.moduleConf = conf.SysConf:getModuleById(1007)
    elseif self.index == 2 then
        self.moduleConf = conf.SysConf:getModuleById(1008)
    elseif self.index == 3 then
        self.moduleConf = conf.SysConf:getModuleById(1009)
    elseif self.index == 4 then
        self.moduleConf = conf.SysConf:getModuleById(1010)
    end
    --所有属性加成
    if self.data.lev > 0 then
        self:initPro1()
    else
        self:initPro3()
    end
    
    self.maxTo = conf.HuobanConf:getValue("endmaxjie",self.index) or 10

    if not self.nextconf or (self.confdata.jie and self.confdata.jie >= self.maxTo) then-- 
        self.c1.selectedIndex = 2
        self.redimg.visible = false
    else
        if self.c2.selectedIndex == 5 then
            self.c1.selectedIndex = 1 
        else
            self.c1.selectedIndex = 0
        end
        --设置消耗
        self:setCostItem()
        
    end

    if self.data.lev == 0 then
        self.c3.selectedIndex = 0 
    else
        self.c3.selectedIndex = 1
    end
end

function HuoBanOtherPro:composeData(data,param)
    -- body

    for k ,v in pairs(param) do
        local falg = false
        for i , j in pairs(data) do
            if j[1] == v[1] then
                data[i][2] = j[2] + v[2]
                falg = true 
            end
        end
        if not falg then
            table.insert(data,v)
        end
    end
end

function HuoBanOtherPro:initPro1()
    -- body
    local t = GConfDataSort(self.confdata) 

    local item1 = GConfDataSort(conf.ItemConf:getItemPro(self.moduleConf.zzd_mid)) 
    local item2 = conf.ItemConf:getItem(self.moduleConf.qld_mid)  
    -- 成长丹
    if item2 and item2.ext01 then
        for k ,v in pairs(t) do
            v[2] = v[2] + math.floor(v[2] * item2.ext01/10000 * self.data.qldNum) 
        end
    end
    --皮肤
    if self.data.skins then 
        for k ,v in pairs(self.data.skins) do
            local confData = conf.HuobanConf:getSkinsByIndex(v,self.index)
            self:composeData(t,GConfDataSort(confData))
            local starPre = confData and confData.star_pre or 0
            local starId = starPre * 1000 + cache.PlayerCache:getSkinStarLv(starPre)
            local fsData = conf.RoleConf:getFashionStarAttr(starId) or {}
            self:composeData(t,GConfDataSort(fsData))
        end
    end
    --技能
    if self.data.skills then
        for k ,v in pairs(self.data.skills) do
            self:composeData(t,GConfDataSort(conf.HuobanConf:getSkillLevData(k,v,self.index)))
        end
    end
    --装备
    if self.data.equips then
        for k ,v in pairs(self.data.equips) do
            self:composeData(t,GConfDataSort(conf.HuobanConf:getEquipLevData(k,v,self.index)))
        end
    end
    
    --资质蛋
    if self.data.zzdNum > 0 and item1 then
        for k ,v in pairs(item1) do
            item1[k][2] = v[2]*self.data.zzdNum
        end
        self:composeData(t,item1)
    end
    --
    table.sort(t,function( a,b )
        -- body
        local asort = conf.RedPointConf:getProSort(a[1]) 
        local bsort = conf.RedPointConf:getProSort(b[1]) 
        if asort == bsort then
            return a[1]<b[1]
        else
            return asort < bsort
        end
    end)

    self:setPro(t)
end



function HuoBanOtherPro:setPro(t)
    -- body
    for k,v in pairs(self.proList) do
        v.text = ""
    end

    for k ,v in pairs(self.tempList) do
        v.text = ""
    end

    for k ,v in pairs(t) do
        local item = self.proList[k]
        if not item then
            break
        end

        item.text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],math.floor(v[2])) 
        
        local itemtemp = self.tempList[k] --临时输赢
        if itemtemp and self.data and self.data.tempAttris then
            local var = self.data.tempAttris[tonumber(v[1])]
            if var   then
                itemtemp.text = "(+"..var..language.zuoqi61..")"
            end
        end
    end
end
--单个皮肤
function HuoBanOtherPro:initPro2(v)
    -- body
    self:updateSelect(5)
    self.c1.selectedIndex = 1
    -- for k , v in pairs(self.proMore) do
    --     v.text = ""
    -- end
    -- local t =  GConfDataSort(conf.HuobanConf:getSkinsByIndex(v,self.index))
    -- for k ,v in pairs(t) do
    --     local item = self.proMore[k] 
    --     if not item then
    --         break
    --     end

    --     item.text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],math.floor(v[2])) 
    -- end
    for k , v in pairs(self.starAttrList) do
        v.text = ""
    end
    self.proMporeList.numItems = 0
    local confData = conf.HuobanConf:getSkinsByIndex(v,self.index)
    -- print("灵童系统属性>>>>>>>>>>>",v,confData)

    local suitStarPre = confData and confData.star_pre or 0
    local suitStars = cache.PlayerCache:getSkinStarLv(suitStarPre)
    if confData.star_pre then
        self.starSuitImg.visible = false
        --升星属性
        local suitStarConf = conf.RoleConf:getSkinsStarAttrData(v,SKINSMODELID[self.index])
        for k,v in pairs(suitStarConf) do
            local str = string.format(language.fashion14,v.need_star) .. string.format(language.fashion15_1,language.gonggong94[SKINSMODELID[self.index]],(v.attr_show/100))
            if suitStars >= v.need_star then
                self.starAttrList[k].text = mgr.TextMgr:getTextColorStr(str,7)
            else
                self.starAttrList[k].text = mgr.TextMgr:getTextColorStr(str,8)
            end
        end
    else
        self.starSuitImg.visible = true
    end

    local starId = suitStarPre*1000+suitStars
    local t = GConfDataSort(confData)
    -- printt("升星id>>>>>>>>>>>>>",t)
    self.proMporeList.itemRenderer = function (index,obj)
        local data = t[index+1]
        if data then
            local txt1 = obj:GetChild("n0")
            local txt2 = obj:GetChild("n1")
            txt1.text = conf.RedPointConf:getProName(data[1]).." "..GProPrecnt(data[1],math.floor(data[2]))
            if suitStars > 0 then
                local curData = GConfDataSort(conf.RoleConf:getFashionStarAttr(starId))
                if curData[index+1] then
                    txt2.text = "+".. curData[index+1][2]
                end
            else
                txt2.text = ""
            end
        end
    end
    self.proMporeList.numItems = #t
   
end

function HuoBanOtherPro:initPro3()
    -- body
    local t = GConfDataSort(conf.HuobanConf:getDataByLv(1, self.index)) 
    self:setPro(t)
end

function HuoBanOtherPro:updateSelect(index)
    -- body
    self.c2.selectedIndex = index or self.index
end

function HuoBanOtherPro:onBtnJie()
    -- body
    self.parent:onbtnCallBack()
end

function HuoBanOtherPro:onBtnPlusBottom(  )
    -- body
     -- plog("onBtnPlusBottom",self.index)
    local param = {}
    param.mId = self.usemid
    param.index = self.index+10
    if param.mId then
        GGoBuyItem(param)
    end
end

function HuoBanOtherPro:onBtnPlusTop()
    -- body
    --plog("顶部加号点击")
end
function HuoBanOtherPro:onBtnWen( )
    -- body
    -- plog("onBtnWen")
    local t = {1014,1015,1016,1017}
    GOpenRuleView(t[self.index])
end

return HuoBanOtherPro