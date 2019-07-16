--
-- Author: 
-- Date: 2017-05-25 21:15:02
--

local ZuoProPanel1 = class("ZuoProPanel1",import("game.base.Ref"))

function ZuoProPanel1:ctor(param)
    self.view = param
    self:initView()
end

function ZuoProPanel1:initView()
    -- body
    --是否特殊皮肤
    self.c1 = self.view:GetController("c1")

    self.proList = {}
    for i = 14 , 20 do
        local lab = self.view:GetChild("n"..i)
        lab.text = ""
        table.insert(self.proList,lab)
    end
    self.proMore = {}
    for i = 24,30 do
        local lab = self.view:GetChild("n"..i)
        lab.text = ""
        table.insert(self.proMore,lab)
    end
    self.tempList = {}
    for i = 33,39 do
        local lab = self.view:GetChild("n"..i)
        lab.text = ""
        table.insert(self.tempList,lab)
    end
    self.toptitle = self.view:GetChild("n32")
    self.toptitle.text = ""
end

function ZuoProPanel1:setPro(t)
    -- body
    for k ,v in pairs(self.proList) do
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
        item.text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],math.floor(v[2]))  --math.floor(v[2])  --EVE 百分比显示
    
        local itemtemp = self.tempList[k]
        if itemtemp and self.data.tempAttris then  
            local var = self.data.tempAttris[tonumber(v[1])] --EVE 这里是临时属性
            if var and var ~="" then
                itemtemp.text = "(+"..GProPrecnt(v[1],var)..language.zuoqi61..")"  --EVE 临时属性使用百分比
            end           
        end
    end
end

function ZuoProPanel1:composeData(data,param)
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


function  ZuoProPanel1:isZuoqi()
    if self.index == 1 or self.index == 2 or self.index == 3 or self.index == 4 or self.index == 10 or self.index == 15 then
        return true
    end
    return false
end

--是否激活老鹰 --9.25 修改为黄金仙尊卡
function ZuoProPanel1:isYing()
    -- body
    if not self.data then
        return false
    end

    for k ,v in pairs(self.data.vipTypes) do
        if v == 2 then
            return true
        end
    end

    -- for k ,v in pairs(self.data.skins) do
    --     if v == ZUOQIINDEX then
    --         return true
    --     end
    -- end

    return false
end

function ZuoProPanel1:initPro1()
    -- body
    --等级添加
    local tlv 
    local moduleConf       
    local indextable = {
        [1] = 0,
        [2] = 2,
        [3] = 3,
        [4] = 4,
        [5] = 0,
        [6] = 4,
        [7] = 2,
        [8] = 3,
        [9] = 1,
        [10] = 1,
        [15] = 5}
    if self.index == 1 then --坐骑
        moduleConf = conf.SysConf:getModuleById(1001)
    elseif self.index == 2 then---法宝
        moduleConf = conf.SysConf:getModuleById(1005)
    elseif self.index == 3 then--仙羽
        moduleConf = conf.SysConf:getModuleById(1002)
    elseif self.index == 4 then--仙器
        moduleConf = conf.SysConf:getModuleById(1004)
    elseif self.index == 10 then--神兵
        moduleConf = conf.SysConf:getModuleById(1003)
    elseif self.index == 5 then--伙伴
        moduleConf = conf.SysConf:getModuleById(1006)
    elseif self.index == 6 then----伙伴仙器
        moduleConf = conf.SysConf:getModuleById(1009)
    elseif self.index == 7 then --伙伴神兵
        moduleConf = conf.SysConf:getModuleById(1008)
    elseif self.index == 8 then--伙伴法宝
        moduleConf = conf.SysConf:getModuleById(1005)
    elseif self.index == 9 then--伙伴仙羽
        moduleConf = conf.SysConf:getModuleById(1007)
    elseif self.index == 15 then--伙伴仙羽
        moduleConf = conf.SysConf:getModuleById(1287)
    end
    --计算等级属性
    if self:isZuoqi() then
        tlv = GConfDataSort(conf.ZuoQiConf:getDataByLv(self.data.lev,indextable[self.index]))
    else
        tlv = GConfDataSort(conf.HuobanConf:getDataByLv(self.data.lev,indextable[self.index]))
    end
    --潜力点加成成
    local itemPro = {}
    local Itemdata = conf.ItemConf:getItem(moduleConf.qld_mid)
    if Itemdata.ext01 then
        for k ,v in pairs(tlv) do
            local inner = {}
            inner[1] = v[1]
            inner[2] = math.floor(v[2]*Itemdata.ext01/10000*self.data.qldNum)
            table.insert(itemPro,inner)
        end
    end
    --vip 加成
    local vipPro = {}
    if self.index == 1 or self.index == 2 or self.index == 3 or self.index == 4 or self.index == 10 then
        local issss = false
        if self.index == 1 then
            if self:isYing() then
                issss = true
            end
        -- elseif self.index == 3 then
        --     if self.data.vipTypes[2] and self.data.vipTypes[2] then
        --         issss = true
        --     end
        else
            for k ,v in pairs(self.data.vipTypes) do
                if v == 3 then
                    issss = true
                end
            end
        end
        if issss then
            for k ,v in pairs(tlv) do
                local inner = {}
                inner[1] = v[1]
                local var = conf.ZuoQiConf:getValue("zs_vip_add_coef",indextable[self.index])
                if self.index == 1 then
                    var = conf.ZuoQiConf:getValue("special_skin_bonus",0)[1][2]
                end
                inner[2] = math.floor(v[2]*tonumber(var/100))
                table.insert(vipPro,inner)
            end
        end
    end
    self:composeData(tlv,itemPro)
    self:composeData(tlv,vipPro)
    --技能加成
    for k ,v in pairs(self.data.skills) do
        if self:isZuoqi() then
            self:composeData(tlv,GConfDataSort(conf.ZuoQiConf:getSkillByLev(k,v,indextable[self.index])))
        else
            self:composeData(tlv,GConfDataSort(conf.HuobanConf:getSkillLevData(k,v,indextable[self.index])))
        end
    end
    --装备加成
    for k ,v in pairs(self.data.equips) do
        if self:isZuoqi() then
            self:composeData(tlv,GConfDataSort(conf.ZuoQiConf:getEquipByLev(k,v,indextable[self.index])))
        else
            self:composeData(tlv,GConfDataSort(conf.HuobanConf:getEquipLevData(k,v,indextable[self.index])))
        end
    end
    --皮肤
    --printt("信息>>>>>>>>>",self.data)
    for k ,v in pairs(self.data.skins) do
        if self:isZuoqi() then
            self:composeData(tlv,GConfDataSort(conf.ZuoQiConf:getSkinsByIndex(v,indextable[self.index])))
        else
            self:composeData(tlv,GConfDataSort(conf.HuobanConf:getSkinsByIndex(v,indextable[self.index])))
        end
    end

    local item1 = GConfDataSort(conf.ItemConf:getItemPro(moduleConf.zzd_mid))
    if self.data.zzdNum > 0 then
        for k ,v in pairs(item1) do
            item1[k][2] = v[2]*self.data.zzdNum
        end
        self:composeData(tlv,item1)
    end

    table.sort(tlv,function( a,b )
        -- body
        local asort = conf.RedPointConf:getProSort(a[1]) 
        local bsort = conf.RedPointConf:getProSort(b[1]) 
        if asort == bsort then
            return a[1]<b[1]
        else
            return asort < bsort
        end
    end)

    self:setPro(tlv)
end

function ZuoProPanel1:initPro3()
    -- body
    local t
    if self.index == 1 then
        t = GConfDataSort(conf.ZuoQiConf:getDataByLv(1,0)) 
    elseif self.index == 2 then---法宝
        t = GConfDataSort(conf.ZuoQiConf:getDataByLv(1,2)) 
    elseif self.index == 3 then--仙羽
        t = GConfDataSort(conf.ZuoQiConf:getDataByLv(1,3)) 
    elseif self.index == 4 then--仙器
        t = GConfDataSort(conf.ZuoQiConf:getDataByLv(1,4)) 
    elseif self.index == 10 then--神兵
        t = GConfDataSort(conf.ZuoQiConf:getDataByLv(1,1)) 
    elseif self.index == 5 then--伙伴
        --t = GConfDataSort(conf.ZuoQiConf:getDataByLv(1,1)) 
    elseif self.index == 6 then----伙伴仙器
        t = GConfDataSort(conf.HuobanConf:getDataByLv(1,4))
    elseif self.index == 7 then --伙伴神兵
        t = GConfDataSort(conf.HuobanConf:getDataByLv(1,2))
    elseif self.index == 8 then--伙伴法宝
        t = GConfDataSort(conf.HuobanConf:getDataByLv(1,3))
    elseif self.index == 9 then--伙伴仙羽
        t = GConfDataSort(conf.HuobanConf:getDataByLv(1,1))
    elseif self.index == 15 then
        t = GConfDataSort(conf.ZuoQiConf:getDataByLv(1,5))
    end
    self:setPro(t)
end

function ZuoProPanel1:initPro2()
    -- body
    local t = GConfDataSort(self.condata)
    for k ,v in pairs(t) do
        local item = self.proMore[k] 
        if not item then
            break
        end

        item.text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],math.floor(v[2]))
    end
end

function ZuoProPanel1:setData(condata,data)
    -- body
    for k , v in pairs(self.proMore) do
        v.text = ""
    end
    for k ,v in pairs(self.proList) do
        v.text = ""
    end
    self.condata = condata
    self.data = data
    --属性
    if self.data.lev > 0 then
        self:initPro1()
    else
        self:initPro3()
    end

    self.toptitle.text = ""
    if self.index == 1 or self.index == 2 or self.index == 3 or self.index == 4 or self.index == 10 then
        local str = ""
        if self.index == 1 then
            str = string.format(language.zuoqi76,conf.ZuoQiConf:getValue("special_skin_bonus",0)[1][2] )
        elseif self.index == 2 then
            str = string.format(language.zuoqi37,conf.ZuoQiConf:getValue("zs_vip_add_coef",2) )
            --str = string.format(language.zuoqi37,10)
        elseif self.index == 3 then 
            str = string.format(language.zuoqi35,conf.ZuoQiConf:getValue("zs_vip_add_coef",3) )
            --str = language.zuoqi35
        elseif self.index == 4 then
            --str = language.zuoqi38
            str = string.format(language.zuoqi38,conf.ZuoQiConf:getValue("zs_vip_add_coef",4) )
        elseif self.index == 10 then
            --str = language.zuoqi36
            str = string.format(language.zuoqi36,conf.ZuoQiConf:getValue("zs_vip_add_coef",1) )
        end
        local issss = false
        if self.index == 1 then
            if self:isYing() then
                issss = true
            end
        -- elseif self.index == 3 then
        --     if self.data.vipTypes[2] and self.data.vipTypes[2] then
        --         issss = true
        --     end
        else
            -- for k ,v in pairs(self.data.vipTypes) do
            --     plog(k,v)
            -- end
            -- plog("self.data.vipTypes[3]",self.data.vipTypes[3])
            for k ,v in pairs(self.data.vipTypes) do
                if v == 3 then
                    issss = true
                end
            end
        end

        if issss then
            self.toptitle.text = str .. language.zuoqi62
        else
            self.toptitle.text = ""
        end
        --11/16 屏蔽仙尊加成
        self.toptitle.text = ""
        -- if self.index == 1 and self:isYing() then 

        -- elseif self.index ~= 1 and self.data.vipTypes[3] and self.data.vipTypes[3]>0 then
        --     self.toptitle.text = str .. language.zuoqi62
        -- else
        --     self.toptitle.text = ""
        -- end
    end

    if not condata.grow_cons then  --特殊皮肤
        self.c1.selectedIndex = 1
        self:initPro2()
    else
        self.c1.selectedIndex = 0
    end

end

function ZuoProPanel1:setIndex(index)
    -- body
    self.index = index
end


return ZuoProPanel1