--
-- Author: 
-- Date: 2017-02-25 17:38:51
--

local HuobanPro = class("HuobanPro",import("game.base.Ref"))

function HuobanPro:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n20")
    self:initView()
end
function HuobanPro:initView( ... )
    -- body
    --战力
    self.power = self.view:GetChild("n45")
    --属性
    self.proList = {}
    self.progreen = {}
    for i = 14 , 19 do
        local lab = self.view:GetChild("n"..i)
        lab.text = "" 
        if i < 17 then
            table.insert(self.proList, lab)
        else
            table.insert(self.progreen, lab)
        end
    end
    --[[local lab = self.view:GetChild("n38")
    lab.text = ""
    table.insert(self.proList, lab)]]--
    --伙伴技能
    self.icon = self.view:GetChild("n40"):GetChild("n2")
    self.skillDec = self.view:GetChild("n41")
    self.icon2 = self.view:GetChild("n55"):GetChild("n2")

    self.skillDec2 = self.view:GetChild("n56")
    self.skillDec2.text = ""
    --
    self.xin = self.view:GetChild("n27"):GetController("c1")
    -- self.labjie = self.view:GetChild("n28")
    -- self.proCur = {}
    -- for i = 29,31 do
    --     local lab = self.view:GetChild("n"..i)
    --     lab.text = "" 
    --     table.insert(self.proCur, lab)
    -- end
    -- self.moreList = {}
    -- for i = 46,48 do
    --     local lab = self.view:GetChild("n"..i)
    --     lab.text = "" 
    --     table.insert(self.moreList, lab)
    -- end
    -- for i = 57,59 do
    --     local lab = self.view:GetChild("n"..i)
    --     lab.text = "" 
    --     table.insert(self.moreList, lab)
    -- end
    --升星属性
    self.starSuitImg = self.view:GetChild("n66")
    self.starSuitImg.visible = false
    self.proMporeList = self.view:GetChild("n67")
    self.proMporeList.numItems = 0
    self.starAttrList = {}
    for i=63,65 do
        local lab = self.view:GetChild("n"..i)
        lab.text = ""
        table.insert(self.starAttrList, lab)
    end

    --升级 偶or 升阶
    self.c1 = self.view:GetController("c1")
    --满级否
    self.c2 = self.view:GetController("c2")

    local btn = self.view:GetChild("n6")
    btn.onClick:Add(self.onbtnUp,self)
    self.btn = btn
    self.redimg = btn:GetChild("red")

    self.value = self.view:GetChild("n32") 
    self.value.text = ""

    local btnGuize = self.view:GetChild("n54")
    btnGuize.onClick:Add(self.onGuize,self)



    self:initDec()

    --self.parent:addTimer(1,-1,handler(self,self.onTimer))
end

function HuobanPro:initDec()
    -- body
    self.view:GetChild("n40"):GetChild("n5").text = ""
    --self.labjie.text = ""
    self.icon2.url = UIPackage.GetItemURL("huoban" , "huoban_064")
end

function HuobanPro:needVipStr()
    -- body
    if self.confData.jie < 4 then
         if g_ios_test then   --EVE 屏蔽处理，提示修改
            return language.gonggong76
        end        
        return language.huoban25[1]
    elseif self.confData.jie < 7 then
         if g_ios_test then   --EVE 屏蔽处理，提示修改
            return language.gonggong76
        end
        return language.huoban25[2]
    else
         if g_ios_test then   --EVE 屏蔽处理，提示修改
            return language.gonggong76
        end
        return language.huoban25[3]
    end
    --string.format(language.huoban25,self.confData.jie_cost_gold) 
end

function HuobanPro:onTimer()
    -- body
    --plog("self.cache.lastUpTime",self.cache.lastUpTime)
    if self.cache and self.cache.lastUpTime and self.confData and self.confData.jie_cost_sec then
        local var = self.confData.jie_cost_sec - (mgr.NetMgr:getServerTime() - self.cache.lastUpTime+ self.cache.onlineSecs)
        if var > 0 then
            self.value.text = string.format(language.huoban26,GTotimeString(var),self:needVipStr())
        else
            self.value.text = language.huoban32
            self.redimg.visible = true
        end
    else
        self.value.text = ""
    end 
end

--计算战力

function HuobanPro:composeData(data,param)
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



function HuobanPro:initPro1()
    -- body
    
    --伙伴皮肤只带属性
    local t = {}--
    if self.cache.skins then 
        for k ,v in pairs(self.cache.skins) do
            local pfData = conf.HuobanConf:getSkinsByIndex(v.skinId,0)
            if pfData.istshu ~= 2 then --这个是普通
                if v.sign == 2 then
                    self:composeData(t,GConfDataSort(conf.HuobanConf:getSkinsByIndex(v.skinId,0)))
                end
            end
        end
    end

    --等级属性
    local confDataLev = GConfDataSort(conf.HuobanConf:getDataByLv(self.cache.lev,0)) 

    --伙伴皮肤只带属性 +等级属性
    self:composeData(t,confDataLev)

    --成长丹
    local item2 = conf.ItemConf:getItem(self.moduleConf.qld_mid)  
    --伙伴皮肤只带属性 +等级属性 * (1+潜力丹*数量)
    if item2 and item2.ext01 then
        for k ,v in pairs(t) do
            --plog(v[2],item2.ext01,self.cache.qldNum)
            --plog(v[1],math.floor(v[2] * item2.ext01/10000 * self.cache.qldNum))
            v[2] = v[2]  +   math.floor(v[2] * item2.ext01/10000 * self.cache.qldNum)
            -- v[2] 表示数值 {攻击,1000} --v[2] == 1000 表示攻击加100
            --  伙伴皮肤只带属性 +等级属性 * (1+潜力丹*数量) = 1000 + 1000*潜力丹百分比*数量
        end
    end

    -- 加资质丹属性 
    local item1 = GConfDataSort(conf.ItemConf:getItemPro(self.moduleConf.zzd_mid)) 
    if self.cache.zzdNum > 0 and item1 then
        for k ,v in pairs(item1) do
            item1[k][2] = v[2]*self.cache.zzdNum
        end
        self:composeData(t,item1)
    end

    --加获得的特殊皮肤
    if self.cache.skins then 
        for k ,v in pairs(self.cache.skins) do
            local pfData = conf.HuobanConf:getSkinsByIndex(v.skinId,0)
            if pfData.istshu == 2 then --这个是特殊皮肤
                local confData = conf.HuobanConf:getSkinsByIndex(v.skinId,0)
                self:composeData(t,GConfDataSort(confData))
                local starPre = confData and confData.star_pre or 0
                local starId = starPre * 1000 + cache.PlayerCache:getSkinStarLv(starPre)
                local fsData = conf.RoleConf:getFashionStarAttr(starId) or {}
                self:composeData(t,GConfDataSort(fsData))
            end
        end
    end

    --装备
    if self.cache.equips then
        for k ,v in pairs(self.cache.equips) do
            self:composeData(t,GConfDataSort(conf.HuobanConf:getEquipLevData(k,v,self.index)))
        end
    end

    --技能
    if self.cache.skills then
        for k ,v in pairs(self.cache.skills) do
            self:composeData(t,GConfDataSort(conf.HuobanConf:getSkillLevData(k,v,self.index)))
        end
    end

    -- if self.cache.skills then
    --     for k ,v in pairs(self.cache.skills) do
    --         self:composeData(t,GConfDataSort(conf.HuobanConf:getSkillLevData(k,v,self.index)))
    --     end
    -- end

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

function HuobanPro:setPro(t)
    -- body
    for k,v in pairs(self.proList) do
        v.text = ""
    end

    for k,v in pairs(self.progreen) do
        v.text = ""
    end

    ---计算绿色 选择可能加的属性
    local more = {}
    local flag = true
    if self.cache.skins then 
        for k ,v in pairs(self.cache.skins) do
            if v.skinId == self.data.id then --已经获得 不计算绿色部分
                if v.sign == 2 then
                    flag = false
                end
                break
            end
        end  
    end
    local pfData = conf.HuobanConf:getSkinsByIndex(self.data.id,0)
    if tonumber(pfData.istshu) == 2 then --特殊皮肤也不计算
        flag = false
    end

    ---未获得
    local more = GConfDataSort(self.data) --当前选择皮肤
    if flag then
        --获取皮肤属性
        local item2 = conf.ItemConf:getItem(self.moduleConf.qld_mid) 
        if item2 and item2.ext01 then --成长丹
            for k ,v in pairs(more) do
                v[2] = v[2]  +   math.floor(v[2] * item2.ext01/10000 * self.cache.qldNum)
            end
        end
    else
        more = {}
    end
    --printt(more)

    for k ,v in pairs(t) do
        local item = self.proList[k]
        if not item then
            break
        end
        --plog("conf.RedPointConf:getProName(v[1])",conf.RedPointConf:getProName(v[1]),v[1],v[2])
        item.text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],math.floor(v[2]))
        for i,j in pairs(more) do
            if tonumber(j[1]) == tonumber(v[1]) then
                --plog("i,j")
                if self.progreen[k] then
                    self.progreen[k].text = j[2]..mgr.TextMgr:getImg(UIItemRes.other01,16,16)
                end
            end
        end
    end
end


function HuobanPro:updateSelect()
    -- body
end

function HuobanPro:initSkill()
    -- body
    --
    
    local confData = conf.HuobanConf:getSkinsByIndex(self.data.id, 0)

    local condata = conf.HuobanConf:getSkillLevDataByid(confData.skillId,0)
    self.icon.url = ResPath.iconRes(condata.icon) --UIPackage.GetItemURL("_icons" , ""..condata.icon)

    self.skillDec.text = condata.dec


end

function HuobanPro:initMsg()
    -- body
    local confData 
    if self.cache.lev == 0 then
        confData = conf.HuobanConf:getDataByLv(self.cache.lev+1,0)
        self.xin.selectedIndex = 0
    else
        confData = conf.HuobanConf:getDataByLv(self.cache.lev,0)
        if confData.xing~=0 then
            local oldxin = self.xin.selectedIndex
            if oldxin > 10 then
                oldxin = oldxin - 10
            end

            if self.parent.is10 and confData.xing~=0 then
                self.xin.selectedIndex = confData.xing + 10
            else
                if oldxin ~= self.confData.xing then
                    self.xin.selectedIndex = confData.xing
                end
            end
        else
            self.xin.selectedIndex = 0
        end
    end
    

    self.confData = confData
    local confskill = conf.SkillConf:getSkillByIndex(confData.skill_affect_id)
    --plog("skill_affect_id",skill_affect_id)
    --按等级读取普通技能描述
    if confskill then
        self.skillDec2.text = confskill.dec or ""
    else
        self.skillDec2.text = ""
    end
    --self.labjie.text = language.huoban19.." " ..string.format(language.huoban24,language.gonggong21[confData.jie] ) 

    -- local t = GConfDataSort(confData)
    -- for k ,v in pairs(self.proCur) do
    --     local data = t[k]
    --     if data then
    --         v.text = conf.RedPointConf:getProName(data[1]).." "..GProPrecnt(data[1],math.floor(data[2])) 
    --     else
    --         v.text = ""
    --     end
    -- end

    local nextconf = conf.HuobanConf:getDataByLv(self.cache.lev+1,0)
    if not nextconf then
        self.c2.selectedIndex = 1
        self.redimg.visible = false
    else
        self.c2.selectedIndex = 0
        --plog("..self:checkPoint()",self:checkPoint())
        self.redimg.visible = self:checkPoint()
    end
    if self.cache.lev == 0 then
        self.c1.selectedIndex = 0 
    else
        if self.xin.selectedIndex == 10 then
            self.c1.selectedIndex = 1
        else
            self.c1.selectedIndex = 2
        end
    end
    self.btn.visible = true
    --如果拥有这个皮肤
    local flag = false
    for k ,v in pairs(self.cache.skins) do
        if tonumber(v.skinId) == tonumber(self.data.id) and v.sign == 2 then
            flag = true
            self.btn.visible = true
            break
        end
    end
    if not flag then
        --plog("????")
        self.btn.visible = flag
        self.redimg.visible = false
    end
end

function HuobanPro:setData(data,param)
    -- body
    self.moduleConf = conf.SysConf:getModuleById(1006)
    self.index = 0
    self.data = conf.HuobanConf:getSkinsByIndex(data.id,0) 
    self.cache = param
    self.power.text = param.power
    self:initSkill()
    if self.cache.lev  > 0 then
        self:initPro1()
    else
        self.power.text = self.data.power
        self:initPro3()
    end
    self:initMsg()
end

function HuobanPro:initPro2(v)
    -- body
    self.data = conf.HuobanConf:getSkinsByIndex(v,0)

    for k ,v in pairs(self.progreen) do
        v.text = ""
    end

    --self:initSkill()
    self:initMsg()

    for k , v in pairs(self.starAttrList) do
        v.text = ""
    end
    self.proMporeList.numItems = 0
    local confData = self.data
    -- print("灵童系统属性>>>>>>>>>>>",v,confData)

    local suitStarPre = confData and confData.star_pre or 0
    local suitStars = cache.PlayerCache:getSkinStarLv(suitStarPre)
    if confData.star_pre then
        self.starSuitImg.visible = false
        --升星属性
        local suitStarConf = conf.RoleConf:getSkinsStarAttrData(v,1006)
        for k,v in pairs(suitStarConf) do
            local str = string.format(language.fashion14,v.need_star) .. string.format(language.fashion15_1,language.gonggong94[1006],(v.attr_show/100))
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

    self.c2.selectedIndex = 2
end

function HuobanPro:initPro3()
    -- body
    local t = GConfDataSort(self.data)--GConfDataSort(conf.HuobanConf:getDataByLv(1,0)) 
    --self:composeData(t,)
    self:setPro(t)
end

function HuobanPro:update(data)
    -- body
    self.moduleConf = conf.SysConf:getModuleById(1006)
    self.cache = data
    self.confData = conf.HuobanConf:getDataByLv(self.cache.lev,0)
    self.power.text = data.power
    if self.data then
        if self.cache.lev  > 0 then
            self:initPro1()
        else
            self:initPro3()
        end
        self:initMsg()
    end
end

function HuobanPro:onbtnUp()
    -- body
    self.parent:onbtnCallBack()
    -- if self.cache.lev <= 0 then
    --     proxy.HuobanProxy:send(1200102,{reqType = 0})
    --     return
    -- end

    -- mgr.ViewMgr:openView(ViewName.HuobanLv, function( view )
    --     -- body
    --     view:setData()
    -- end, self.cache)
end

function HuobanPro:onGuize( ... )
    -- body
    GOpenRuleView(1013)
end

function HuobanPro:checkVip()
    -- body
    local id 
    if self.confData.jie < 4 then
        id = 1
    elseif self.confData.jie < 7 then
        id = 2
    else
        id = 3
    end

    return cache.PlayerCache:VipIsActivate(id)
end
function HuobanPro:checkPoint()
    -- bodyp
    if self.confData.xing == 10 then
        if self.value.text == language.huoban32 then
            return true
        elseif self:checkVip() then
            return true
        else
            return false
        end
    else--装备吞噬红点删除
        if GCheckTunShiEquip() then
            -- cache.PlayerCache:setRedpoint(10211, 1)
            return true
        else
            -- cache.PlayerCache:setRedpoint(10211, 0)
            return false
        end
    end
   
end

return HuobanPro