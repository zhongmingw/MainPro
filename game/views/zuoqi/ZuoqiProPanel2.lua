--
-- Author: 
-- Date: 2017-02-21 20:29:18
--

local ZuoqiProPanel2 = class("ZuoqiProPanel2",import("game.base.Ref"))

local SKINSMODELID = {
    [1] = 1003,
    [2] = 1005,
    [3] = 1002,
    [4] = 1004,
    [5] = 1287,
}

function ZuoqiProPanel2:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n16")
    self:initView()
end

function ZuoqiProPanel2:initView()
    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")
    self.icon = self.view:GetChild("n26") 
    self.proList = {}
    for i = 14 , 20 do
        local lab = self.view:GetChild("n"..i)
        lab.text = ""
        table.insert(self.proList,lab)
    end
    --升星属性
    self.starSuitImg = self.view:GetChild("n62")
    self.starSuitImg.visible = false
    self.proMporeList = self.view:GetChild("n55")
    self.proMporeList.numItems = 0
    self.starAttrList = {}
    for i=59,61 do
        local lab = self.view:GetChild("n"..i)
        lab.text = ""
        table.insert(self.starAttrList, lab)
    end

    self.tempList = {}
    for i = 44,50 do
        local lab = self.view:GetChild("n"..i)
        lab.text = ""
        table.insert(self.tempList,lab)
    end
    self.dec1 =  self.view:GetChild("n42")
    self.dec1.text = ""
    self.btnPlusTop = self.view:GetChild("n43")
    self.btnPlusTop.onClick:Add(self.onBtnPlusTop,self)

    self.value = self.view:GetChild("n36")
    self.value.text = "00"
    self.value.visible = false

    local btnWen = self.view:GetChild("n37")
    btnWen.onClick:Add(self.onBtnWen,self)
    self.btnWen = btnWen

    self.decvalue = self.view:GetChild("n35")
    self.decvalue.text= language.zuoqi31
    self.decvalue.visible = false
    self.bar = self.view:GetChild("n5")
    self.itemObj = self.view:GetChild("n38")
    self.itemName = self.view:GetChild("n39")
    self.itemCount =  self.view:GetChild("n40")
    self.btnPlus2 = self.view:GetChild("n11")
    self.btnPlus2.onClick:Add(self.onBtnPlusBottom,self)
    self.btnJie = self.view:GetChild("n6")
    self.btnJie.onClick:Add(self.onBtnJie,self)
    self.redimg = self.btnJie:GetChild("red")

    self.panel_di = self.view:GetChild("n1")

    self:setistimer()
    -- self.parent:addTimer(1, -1, handler(self,self.onTimer))

    self.imgMax = self.view:GetChild("n52")
    self.jieNotClear =self.view:GetChild("n53") 
    self.jieNotClear.text = language.zuoqi66 
    self.jieNotClear.visible = false
    --几颗星
    self.xin = self.view:GetChild("n54")
    self.xinC1 = self.xin:GetController("c1") 
    self.xin.visible = false--屏蔽星级

    self.labqilb = self.view:GetChild("n63")
    self.labqilb.text = ""
    self.labqilb.visible = false

    if g_is_banshu then
        self.redimg:SetScale(0,0)
    end
end

function ZuoqiProPanel2:onTimer()
    -- body
    if self.index and self.index == 5 then
        --麒麟臂无祝福值
        self.decvalue.visible = false
        self.jieNotClear.visible = false
        self.value.visible = false
        return
    end
    self.labqilb.visible = false
    self:setistimer()
    if self.index and self.jie then
        local var = conf.ZuoQiConf:getValue("bless_clear_jie",self.index)
        if self.jie < (var or 0)  then
            self.jieNotClear.text = language.zuoqi65
            self.jieNotClear.visible = true
            self.value.visible = false
            self.decvalue.visible = false
            return 
        end
    end
    
    if self.data and self.data.blessTime and  self.data.blessTime ~= 0 and self.jie and self.index then
        local var = 24*3600 -(mgr.NetMgr:getServerTime()-self.data.blessTime) 
        if var > 0 then
            -- print(">>>>>>>>>>>>>>",language.zuoqi31,GTotimeString(var))
            self.jieNotClear.text = ""
            self.istimer = true
            self.value.text = GTotimeString(var)
            self.decvalue.text = language.zuoqi31
            self.value.visible = true
            self.decvalue.visible = true
        else
            self.value.visible = false
            self.decvalue.visible = false
            self.jieNotClear.text = language.zuoqi66 
            self.jieNotClear.visible = true
        end
    else
        if self.imgMax.visible then
            self.jieNotClear.text = "" 
        else
            self.jieNotClear.text = language.zuoqi66
        end
        self.jieNotClear.visible = true
        self.value.visible = false
        self.decvalue.visible = false
    end
end

function ZuoqiProPanel2:setistimer()
    -- body
    self.istimer = false
end

function ZuoqiProPanel2:isOverTime()
    -- body
    return  self.istimer
end

function ZuoqiProPanel2:setXin(number)
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

function ZuoqiProPanel2:setData(data)
    -- body


    self.data = data
    if self.data.lev == 0 then
        self.c2.selectedIndex = 0
    else
        self.c2.selectedIndex = 1
    end

    self.index = self.parent.c1.selectedIndex 

    self:updateSelect(self.c1.selectedIndex)

    local confdata = conf.ZuoQiConf:getDataByLv(self.data.lev,self.index) 
    local nextconf = conf.ZuoQiConf:getDataByLv(self.data.lev+1,self.index)
    self.jie = confdata.jie or 1
    if self.jie < 1 then
        self.jie = 1
    end

    local t = {1001,1003,1005,1002,1004,1287}
    self.moduleConf = conf.SysConf:getModuleById(t[self.index+1])

    local str = ""
    local isvip3 = cache.PlayerCache:VipIsActivate(3)
    if self.index == 1 then
        str = language.zuoqi36
    elseif self.index == 2 then 
        str = language.zuoqi37
    elseif self.index == 3 then
        --isvip3 = cache.PlayerCache:VipIsActivate(2)
        str = language.zuoqi35
    elseif self.index == 4 then
        str = language.zuoqi38
    elseif self.index == 5 then
        str = language.zuoqi80

    end
    --
    local precent = conf.ZuoQiConf:getValue("zs_vip_add_coef",self.index)
    local width = 0 


    if precent <= 0 then
        self.dec1.text = ""
        self.btnPlusTop.visible = false
    else
        self.dec1.visible = true
        self.btnPlusTop.visible = true

        if isvip3  then
            self.btnPlusTop.visible = false
            self.dec1.text = string.format(str,precent) .. language.zuoqi62
        else
            self.btnPlusTop.visible = true 
            self.dec1.text = string.format(str,precent)
            width = width + self.btnPlusTop.width
        end
        width = self.dec1.width  + width
    end



    local offx = (self.panel_di.width - width)/2
    self.dec1.x = 16 + offx
    
    --星星
    local confData = conf.ZuoQiConf:getDataByLv(self.data.lev,self.index)
    if self.index == 5 then
        --print("self.data.lev",self.data.lev)
        if self.data.lev > 0 then
            self.xin.visible = true
            self:setXin(confData.xing)
            self.labqilb.visible = false
            self.bar.visible = true
        else
            self.labqilb.visible = true
            self.xin.visible = false
            self.bar.visible = false
        end
    else
        self.labqilb.visible = false
        self.xin.visible = false
        self.bar.visible = true
    end
    if self.data.lev > 0 then
        self:initPro1()
    else
        self:initPro3()
    end
    self.maxTo = conf.ZuoQiConf:getValue("endmaxjie",self.index) or 10
    --print(confdata.cost_items,self.maxTo,nextconf.jie,self.maxTo,nextconf.xing)
    if confdata.cost_items and nextconf and (nextconf.jie < self.maxTo or (nextconf.jie == self.maxTo and (nextconf.xing or 0)<1)) then
        local t = {}
        t.mid = confdata.cost_items[1]
        t.isquan = true
        self.usemid = t.mid
        self.useAmount = confdata.cost_items and confdata.cost_items[2] or 0

        
        local confItemData = conf.ItemConf:getItem(t.mid)
        self.itemObj.visible = true
        GSetItemData(self.itemObj,t,true)
        self.itemName.text = confItemData.name
        local var = cache.PackCache:getLinkCost(t.mid)--cache.PackCache:getPackDataById(t.mid).amount 
        self.itemCount.text = var.."/"..confdata.cost_items[2]
        self.btnPlus2.visible = true
        self.redimg.visible = true
        if var < confdata.cost_items[2] then
            self.redimg.visible = false
            local param = {
                {color = 14 , text = var},
                {color = 7 , text = "/"..confdata.cost_items[2]}
            }
            self.itemCount.text = mgr.TextMgr:getTextByTable(param)
        end
        if self.index == 5 then
            --self.redimg.visible = false
        else
            local var = conf.ZuoQiConf:getValue("bless_clear_jie",self.index)
            if self.jie >= var then
                self.redimg.visible = false
            end
        end

        local str = language.zuoqi81 .. mgr.TextMgr:getTextColorStr(self.useAmount, 7)
        str = str .. string.format(language.zuoqi82,mgr.TextMgr:getColorNameByMid(self.usemid)) 
        self.labqilb.text =  str
    else
        self.itemObj.visible = false
        self.itemCount.text= ""
        self.itemName.text = ""
        self.btnPlus2.visible = false
    end

    self.bar.value = self.data.levExp
    self.bar.max = confdata.need_exp or self.data.levExp

    
    if not nextconf or (confdata.jie and confdata.jie >= self.maxTo) then--
        self.imgMax.visible = true
        self.btnJie.visible = false
        self.bar.visible = false
        self.redimg.visible = false
        --self.btnWen.visible = false
        --self.xin.visible = false
        self.xin.visible = false
    else
        self.imgMax.visible = false
        self.btnJie.visible = true
        if self.index == 5 then
            self.bar.visible = self.data.lev>0
        else
            self.bar.visible = true
        end
        
        --self.xin.visible = false
        --self.btnWen.visible = true
    end

    if self.c1.selectedIndex == 1 then
        self.imgMax.visible = false
    end
end
--累计属性
function ZuoqiProPanel2:initPro1()
    -- body
    --等级属性
    local t = GConfDataSort(conf.ZuoQiConf:getDataByLv(self.data.lev,self.index))
    --vip 添加
    local vipPro = {}
    if self.index~=0  then
        local flag = false
        flag = cache.PlayerCache:VipIsActivate(3)
        -- if self.index == 3 then
        --     flag = cache.PlayerCache:VipIsActivate(2)
        -- else
        --     flag = cache.PlayerCache:VipIsActivate(3)
        -- end
        if flag then
            for k ,v in pairs(t) do
                local inner = {}
                inner[1] = v[1]
                local var = conf.ZuoQiConf:getValue("zs_vip_add_coef",self.index)
                inner[2] = math.floor(v[2]*tonumber(var/100))
                table.insert(vipPro,inner)
            end
        end
    end


    local item1 = GConfDataSort(conf.ItemConf:getItemPro(self.moduleConf.zzd_mid))
    local item2 = conf.ItemConf:getItem(self.moduleConf.qld_mid)
    --潜力丹加百分比
    local itemPro = {}
    if item2.ext01 then
        for k ,v in pairs(t) do
            local inner = {}
            inner[1] = v[1]
            inner[2] = math.floor(v[2]*item2.ext01/10000*self.data.qldNum)
            table.insert(itemPro,inner)
            --v[2] = v[2] + v[2]* item2.ext01/10000 * self.data.qldNum
        end
    end

    self:composeData(t,vipPro)
    self:composeData(t,itemPro)
    --皮肤加
    if self.data.skins then 
        for k ,v in pairs(self.data.skins) do
            local confData = conf.ZuoQiConf:getSkinsByIndex(v.skinId,self.index)
            self:composeData(t,GConfDataSort(confData))
            local starPre = confData and confData.star_pre or 0
            local starId = starPre * 1000 + cache.PlayerCache:getSkinStarLv(starPre)
            local fsData = conf.RoleConf:getFashionStarAttr(starId) or {}
            self:composeData(t,GConfDataSort(fsData))
        end
    end
    --技能加
    if self.data.skills then
        for k ,v in pairs(self.data.skills) do
            self:composeData(t,GConfDataSort(conf.ZuoQiConf:getSkillByLev(k,v,self.index)))
        end
    end
    --装备加
    if self.data.equips then
        for k ,v in pairs(self.data.equips) do
            self:composeData(t,GConfDataSort(conf.ZuoQiConf:getEquipByLev(k,v,self.index)))
        end
    end
    --资质丹加
    if self.data.zzdNum > 0 and item1 then
        for k ,v in pairs(item1) do
            item1[k][2] = v[2]*self.data.zzdNum
        end
        self:composeData(t,item1)
    end

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

function ZuoqiProPanel2:setPro(t)
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

        item.text = conf.RedPointConf:getProName(v[1]).." ".. GProPrecnt(v[1],math.floor(v[2]))   --EVE 改为使用百分比显示  --math.floor(v[2])
        
        local itemtemp = self.tempList[k]
        if itemtemp and self.data.tempAttris then  
            local var = self.data.tempAttris[tonumber(v[1])] --EVE 这里是临时属性
            -- plog("var",var)
            -- plog("v[1]",v[1])
            if var and var ~="" then
                --plog("ka"..var.."aa")
                itemtemp.text = "(+"..GProPrecnt(v[1],var)..language.zuoqi61..")"  --EVE 临时属性使用百分比
            end           
        end
    end
end

function ZuoqiProPanel2:initPro2(v)
    -- body
    --self.c1.selectedIndex = 1
    self:updateSelect(1)

    -- for k , v in pairs(self.proMore) do
    --     v.text = ""
    -- end
    -- local t = GConfDataSort(conf.ZuoQiConf:getSkinsByIndex(v,self.index))
   
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
    -- print("成长系统属性>>>>>>>>>>>",v,self.index)
    local confData = conf.ZuoQiConf:getSkinsByIndex(v,self.index)

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
    -- print("升星id>>>>>>>>>>>>>",starId)
    local t = GConfDataSort(confData)
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
    self.imgMax.visible = false

   
end

function ZuoqiProPanel2:initPro3()
    -- body
    local t = GConfDataSort(conf.ZuoQiConf:getDataByLv(1,self.index)) 
    local isvip3 = cache.PlayerCache:VipIsActivate(3)
    -- if self.index == 3 then
    --     isvip3 = cache.PlayerCache:VipIsActivate(2)
    -- end 
    if isvip3 then
        for k ,v in pairs(t) do
            v[2] = v[2]*0.1
        end
    end
    self:setPro(t)
end

function ZuoqiProPanel2:updateSelect(index)
    -- body
    self.c1.selectedIndex = index
    local url
    if index == 0 then
        if self.index == 1 then
            url = UIItemRes.sbjj
        elseif self.index == 2 then
            url = UIItemRes.fbjj
        elseif self.index == 3 then
            url = UIItemRes.xyjj
        elseif self.index == 4 then
            url = UIItemRes.xqjj
        elseif self.index == 5 then
            url = UIItemRes.xlbjj
        end
    else
       url = UIItemRes.syjc 
    end
    self.icon.url = url

end

function ZuoqiProPanel2:composeData(data,param)
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

function ZuoqiProPanel2:onBtnJie()
    -- body
    self.parent:onbtnCallBack()
end

function ZuoqiProPanel2:onBtnPlusBottom(  )
    -- body
    local param = {}
    param.mId = self.usemid
    param.zuoqi = true
    param.index = self.index
    if param.mId then
        GGoBuyItem(param)
    end
end

function ZuoqiProPanel2:onBtnPlusTop()
    -- body
    GGoVipTequan(2,1)
    --self.parent:closeView()
end
function ZuoqiProPanel2:onBtnWen( )
    -- body
    local t = {1009,1010,1011,1012,1113}
    GOpenRuleView(t[self.index])
end
return ZuoqiProPanel2