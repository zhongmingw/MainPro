--
-- Author: 
-- Date: 2017-05-25 21:01:00
--

local ZuoProPanel2 = class("ZuoProPanel2",import("game.base.Ref"))

function ZuoProPanel2:ctor(param)
    self.view = param
    self:initView()
end

function ZuoProPanel2:initView()
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
    --伙伴技能
    self.icon = self.view:GetChild("n40"):GetChild("n2")
    self.skillDec = self.view:GetChild("n41")

    self.icon2 = self.view:GetChild("n55"):GetChild("n2")
    self.icon2.url = UIPackage.GetItemURL("see" , "huoban_064")
    self.skillDec2 = self.view:GetChild("n56")
    self.skillDec2.text = ""

    self.xin = self.view:GetChild("n27"):GetController("c1")


    self.moreList = {}
    for i = 46,48 do
        local lab = self.view:GetChild("n"..i)
        lab.text = "" 
        table.insert(self.moreList, lab)
    end

    self.c2 = self.view:GetController("c2")

end

function ZuoProPanel2:initSkill()
    -- body
    
    local condata = conf.HuobanConf:getSkillLevDataByid(self.condata.skillId,0)
    self.icon.url = ResPath.iconRes(condata.icon) --UIPackage.GetItemURL("_icons" , ""..condata.icon)
    self.skillDec.text = condata.dec
end

function ZuoProPanel2:initMsg()
    -- body
    local confData 
   -- printt(self.data.lev,"self.data.lev")
    if self.data.lev == 0 then
        confData = conf.HuobanConf:getDataByLv(self.data.lev+1,0)
        self.xin.selectedIndex = 0
    else
        confData = conf.HuobanConf:getDataByLv(self.data.lev,0)
        if confData.xing ~= 0 then
            self.xin.selectedIndex = confData.xing + 10 
        else
            self.xin.selectedIndex = confData.xing 
        end
        
    end
    
    local confskill = conf.SkillConf:getSkillByIndex(confData.skill_affect_id)
    --按等级读取普通技能描述
    if confskill then
        self.skillDec2.text = confskill.dec or ""
    else
        self.skillDec2.text = ""
    end

    local nextconf = conf.HuobanConf:getDataByLv(self.data.lev+1,0)
    if nextconf then
        self.c2.selectedIndex = 0
    else
        self.c2.selectedIndex = 1
    end

    
end

function ZuoProPanel2:composeData(data,param)
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

function ZuoProPanel2:setPro(t)
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
    if self.data.partnerSkins then 
        for k ,v in pairs(self.data.partnerSkins) do
            if v.skinId == self.condata.id then --已经获得 不计算绿色部分
                flag = false
                break
            end
        end  
    end
    local pfData = conf.HuobanConf:getSkinsByIndex(self.condata.id,0)
    if tonumber(pfData.istshu) == 2 then --特殊皮肤也不计算
        flag = false
    end

    ---未获得
    local more = GConfDataSort(self.condata) --当前选择皮肤
    if flag then
        --获取皮肤属性
        local item2 = conf.ItemConf:getItem(self.moduleConf.qld_mid) 
        if item2 and item2.ext01 then --成长丹
            for k ,v in pairs(more) do
                v[2] = v[2]  +   math.floor(v[2] * item2.ext01/10000 * self.data.qldNum)
            end
        end
    else
        more = {}
    end


    for k ,v in pairs(t) do
        local item = self.proList[k]
        if not item then
            break
        end
        item.text = conf.RedPointConf:getProName(v[1]).." "..v[2]
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

function ZuoProPanel2:initPro1()
    -- body
    --伙伴皮肤只带属性
    local t = {}--
    if self.data.partnerSkins then 
        for k ,v in pairs(self.data.partnerSkins) do
            local pfData = conf.HuobanConf:getSkinsByIndex(v.skinId,0)
            if pfData.istshu ~= 2 then --这个是普通
                self:composeData(t,GConfDataSort(conf.HuobanConf:getSkinsByIndex(v.skinId,0)))
            end
        end
    end

    --等级属性
    local confDataLev = GConfDataSort(conf.HuobanConf:getDataByLv(self.data.lev,0)) 

    --伙伴皮肤只带属性 +等级属性
    self:composeData(t,confDataLev)

    --成长丹
    local item2 = conf.ItemConf:getItem(self.moduleConf.qld_mid)  
    --伙伴皮肤只带属性 +等级属性 * (1+潜力丹*数量)
    if item2 and item2.ext01 then
        for k ,v in pairs(t) do
            v[2] = v[2]  +   math.floor(v[2] * item2.ext01/10000 * self.data.qldNum)
        end
    end

    -- 加资质丹属性 
    local item1 = GConfDataSort(conf.ItemConf:getItemPro(self.moduleConf.zzd_mid)) 
    if self.data.zzdNum > 0 and item1 then
        for k ,v in pairs(item1) do
            item1[k][2] = v[2]*self.data.zzdNum
        end
        self:composeData(t,item1)
    end

    --加获得的特殊皮肤
    if self.data.partnerSkins then 
        for k ,v in pairs(self.data.partnerSkins) do
            local pfData = conf.HuobanConf:getSkinsByIndex(v.skinId,0)
            if pfData.istshu == 2 then --这个是特殊皮肤
                self:composeData(t,GConfDataSort(conf.HuobanConf:getSkinsByIndex(v.skinId,0)))
            end
        end
    end

    --装备
    if self.data.equips then
        for k ,v in pairs(self.data.equips) do
            self:composeData(t,GConfDataSort(conf.HuobanConf:getEquipLevData(k,v,0)))
        end
    end

    --技能
    if self.data.skills then
        for k ,v in pairs(self.data.skills) do
            self:composeData(t,GConfDataSort(conf.HuobanConf:getSkillLevData(k,v,0)))
        end
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

function ZuoProPanel2:initPro3()
    -- body
    local t = GConfDataSort(self.condata)
    self:setPro(t)
end

function ZuoProPanel2:initPro2()
    -- body
    for k ,v in pairs(self.progreen) do
        v.text = ""
    end
    --self:initSkill()
    self:initMsg()

    for k ,v in pairs(self.moreList) do
        v.text = ""
    end
    local t = GConfDataSort(self.condata)
    for k ,v in pairs(t) do
        if not self.moreList[k] then
            break
        end
        self.moreList[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
    end


    self.c2.selectedIndex = 2
end

function ZuoProPanel2:setData(condata,data)
    -- body
    self.moduleConf = conf.SysConf:getModuleById(1006)
    self.condata = condata
    self.data = data
    self.power.text = data.power

   

    if condata.istshu and condata.istshu == 2 then
        self:initPro2()
    else
        self:initSkill()
        --plog("self.data.lev",self.data.lev)
        if self.data.lev  > 0 then
            self.power.text = self.data.power 
            self:initPro1()
        else
            self.power.text = condata.power
            self:initPro3()
        end
        self:initMsg()
    end
        
end


return ZuoProPanel2