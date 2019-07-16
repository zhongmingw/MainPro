--
-- Author: 
-- Date: 2017-02-13 15:38:18
--
local MAX_JIE = 14
local ZuoqiProPanel1 = class("ZuoqiProPanel1",import("game.base.Ref"))
function ZuoqiProPanel1:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n13")
    self:initView()
end

function ZuoqiProPanel1:initView()
    -- body
    --是否特殊皮肤
    self.c1 = self.view:GetController("c1")
    --self.c1.onChanged:Add(self.onController1,self)
    --是否顶级
    self.c2 = self.view:GetController("c2")
    --属性展示
    self.proList = {}
    for i = 14 , 20 do
        local lab = self.view:GetChild("n"..i)
        lab.text = ""
        table.insert(self.proList,lab)
    end
    --临时属性
    self.tempList = {}
    for i = 48,54 do
        local lab = self.view:GetChild("n"..i)
        lab.text = ""
        table.insert(self.tempList,lab)
    end
    --特殊皮肤属性显示
    -- self.proMore = {}
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
    --几颗星
    self.xin = self.view:GetChild("n27")
    self.xinC1 = self.xin:GetController("c1")
    self.xin.visible = false--屏蔽星级
    --
    self.progressbar = self.view:GetChild("n5")
    self.progressbar.value = 0
    self.progressbar.max = 0
    --升星
    self.btn = self.view:GetChild("n6")
    self.btn.onClick:Add(self.onbtnCallBack,self)
    self.redimg = self.btn:GetChild("red")
    --购买道具
    self.itemObj = self.view:GetChild("n42")
    self.itemName = self.view:GetChild("n43")
    self.itemCount =  self.view:GetChild("n44")
    self.btnPlus2 = self.view:GetChild("n41")
    self.btnPlus2.onClick:Add(self.onBtnPlusBottom,self)
    --规则
    local btnGuize = self.view:GetChild("n37")
    btnGuize.onClick:Add(self.onGuize,self)
    --钻石仙尊卡
    self.dec22 =  self.view:GetChild("n39")
    self.dec22.text = ""
    self.btnPlusTop = self.view:GetChild("n38")
    self.btnPlusTop.onClick:Add(self.onPlusCallBack,self)
    self.value = self.view:GetChild("n46")
    self.value.text = "0"
    self.value.visible = false
    self.decvalue = self.view:GetChild("n45")
    self.decvalue.text= language.zuoqi31
    self.decvalue.visible = false
    self.jieNotClear =self.view:GetChild("n47") 
    self.jieNotClear.text = language.zuoqi66
    self.jieNotClear.visible = false



    self:setistimer()
    -- self.parent:addTimer(1, -1, handler(self,self.onTimer))
    if g_is_banshu then
        self.redimg:SetScale(0,0)
    end
end

function ZuoqiProPanel1:initDec()
    -- body
    --清理属性
    for k ,v in pairs(self.proList) do
        v.text = ""
    end
    self.progressbar.value = 0
    self.progressbar.max = 0
end

function ZuoqiProPanel1:onTimer()
    -- print("当前阶>>>>>",self.jie,self.data.blessTime)
    self:setistimer()
    if self.jie then
        local var = conf.ZuoQiConf:getValue("bless_clear_jie",0)
        if self.jie < (var or 0)  then
            self.jieNotClear.text = language.zuoqi65
            self.jieNotClear.visible = true
            self.decvalue.visible = false
            self.value.visible = false
            return 
        end
    end
    
    if self.data and self.data.blessTime and  self.data.blessTime ~= 0 and self.jie then
        local var = 24*3600 -(mgr.NetMgr:getServerTime()-self.data.blessTime) 
        -- print(">>>>>>>>>>>>var",var,mgr.NetMgr:getServerTime())
        if var > 0 then
            -- print(">>>>>>>>>>>>>>",language.zuoqi31,GTotimeString(var),self.value.visible,self.value.y)
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
        end
    else
        if self.jie < self.maxTo then
            self.jieNotClear.visible = true
        else
            self.jieNotClear.visible = false
        end
        self.jieNotClear.text = language.zuoqi66
        self.decvalue.visible = false
        self.value.visible = false
    end
end

function ZuoqiProPanel1:setistimer()
    -- body
    self.istimer = false
end

function ZuoqiProPanel1:isOverTime()
    -- body
    return  self.istimer
end


function ZuoqiProPanel1:isSee(flag)
    -- body
    self.btn.visible = flag
    self.btnPlus.visible = flag
    self.progressbar.visible = flag
    self.xin.visible = false--flag
end

function ZuoqiProPanel1:setXin(number)
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

-- --坐骑时间刷新
-- function ZuoqiProPanel1:refreshTime(amount)
--     -- body
--     local value = conf.ItemConf:getItemExt(221041504)
--     local time = value*amount
--     self.data.secs = self.data.secs+time
--     self:setData(self.data)
-- end
--是否激活老鹰
function ZuoqiProPanel1:isYing()
    -- body
    if not self.data then
        return false
    end

    -- for k ,v in pairs(self.data.skins) do
    --     if v == conf.ZuoQiConf:getValue("special_skin_bonus",0)[1][1] then
    --         return true
    --     end
    -- end

    return cache.PlayerCache:VipIsActivate(2)
end

function ZuoqiProPanel1:setData(param,isSx)
    -- body
    self.data = param
    self.isSx = isSx
    --删除钻石仙尊增加10%坐骑属性，改为：获得鹰坐骑后，增加坐骑10%属性

    --9.25 修改成黄金仙尊卡 增加坐骑10%属性
    local width = 0 
    local precent = conf.ZuoQiConf:getValue("special_skin_bonus",0)[1][2]
    if precent > 0 then
        if self:isYing() then
            self.btnPlusTop.visible = false
            self.dec22.text = string.format(language.zuoqi76,precent)..language.zuoqi62
        else
            self.btnPlusTop.visible = true
            self.dec22.text = string.format(language.zuoqi76,precent)
            width = width + self.btnPlusTop.width
        end
        width = self.dec22.width  + width
        local offx = (314 - width)/2
        self.dec22.x = 16 + offx
    else
        self.btnPlusTop.visible = false
        self.dec22.text = ""
    end
    --属性
    self:initDec()
    self:initPro1()
    --星星
    local confData = conf.ZuoQiConf:getDataByLv(self.data.lev,0)
    self.jie = confData.jie or 1
    if self.jie < 1 then
        self.jie = 1
    end
    -- print("当前等阶>>>>>>",self.data.lev)
    -- self:setXin(confData.xing)
    --进度
    self.progressbar.value = self.data.levExp
    self.progressbar.max = confData and confData.need_exp or self.data.levExp
    if confData and confData.need_exp and (confData.need_exp-self.data.levExp) > (self.data.secs or 0) then
        self.redimg.visible = false
    else
        self.redimg.visible = true
    end
    --是否有下一级
    local nextjie = self.data.lev + 1
    local nextconfData = conf.ZuoQiConf:getDataByLv(nextjie,0)
    self.maxTo = conf.ZuoQiConf:getValue("endmaxjie",0) or 10

    --隐藏
    self.itemObj.visible = false
    self.itemCount.text= ""
    self.itemName.text = ""
    self.btnPlus2.visible = false
    self.btn.visible = false
    if not nextconfData or (confData.jie and confData.jie>=self.maxTo) then--
        --没有下一级
        self.c2.selectedIndex = 1
        self.redimg.visible = false
        self.progressbar.visible = false
        self.xin.visible = false
    else
        self.progressbar.visible = true
        self.xin.visible = false
        self.c2.selectedIndex = 0
        --计算道具信息
        if confData.cost_items then
            local t = {}
            t.mid = confData.cost_items[1]
            t.isquan = true
            self.usemid = t.mid
            self.useAmount = confData.cost_items and confData.cost_items[2] or 0
            --道具显示
            local confItemData = conf.ItemConf:getItem(t.mid)
            self.itemObj.visible = true
            GSetItemData(self.itemObj,t,true)
            --名字
            self.itemName.text = confItemData.name
            --数量
            local var = cache.PackCache:getLinkCost(t.mid)
            if var < confData.cost_items[2] then
                self.redimg.visible = false
                local param = {
                    {color = 14 , text = var},
                    {color = 7 , text = "/"..confData.cost_items[2]}
                }
                self.itemCount.text = mgr.TextMgr:getTextByTable(param)
            else
                local jie = conf.ZuoQiConf:getValue("bless_clear_jie",0)
                if self.jie < jie then
                    self.redimg.visible = true
                else
                    self.redimg.visible = false
                end
                self.itemCount.text = var.."/"..confData.cost_items[2] 
            end
            --购买按钮
            self.btnPlus2.visible = true
            --升星按钮
            self.btn.visible = true
        end
    end
    if self.isSx then
        self.view:GetChild("n36").visible = false
    end
end


function ZuoqiProPanel1:initPro1()
    -- body
    local t = GConfDataSort(conf.ZuoQiConf:getDataByLv(self.data.lev,0)) 

    --vip 添加
    local vipPro = {}
    if self:isYing() then
        for k ,v in pairs(t) do
            local inner = {}
            inner[1] = v[1]
            local var = conf.ZuoQiConf:getValue("special_skin_bonus",0)[1][2]
            inner[2] = math.floor(v[2]*tonumber(var/100))
            table.insert(vipPro,inner)
        end
    end

    --潜力点加百分比
    local moduleConf = conf.SysConf:getModuleById(1001)
    local Itemdata = conf.ItemConf:getItem(moduleConf.qld_mid)
    if Itemdata.ext01 then
        for k ,v in pairs(t) do
            v[2] = v[2] + math.floor(v[2]* Itemdata.ext01/10000 * self.data.qldNum)
        end
    end

    for k ,v in pairs(self.data.skills) do
        self:composeData(t,GConfDataSort(conf.ZuoQiConf:getSkillByLev(k,v,0)) )
    end
    for k ,v in pairs(self.data.equips) do
        self:composeData(t,GConfDataSort(conf.ZuoQiConf:getEquipByLev(k,v,0)) )
    end

    for k ,v in pairs(self.data.skins) do
        local confData = conf.ZuoQiConf:getSkinsByIndex(v.skinId,0)
        self:composeData(t,GConfDataSort(confData))
        local starPre = confData and confData.star_pre or 0
        local starId = starPre * 1000 + cache.PlayerCache:getSkinStarLv(starPre)
        local fsData = conf.RoleConf:getFashionStarAttr(starId) or {}
        self:composeData(t,GConfDataSort(fsData))
    end

    local item1 = GConfDataSort(conf.ItemConf:getItemPro(moduleConf.zzd_mid))
    if self.data.zzdNum > 0 then
        for k ,v in pairs(item1) do
            item1[k][2] = v[2]*self.data.zzdNum
        end
        self:composeData(t,item1)
    end
    self:composeData(t,vipPro)

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

function ZuoqiProPanel1:initPro2(v)
    -- body
    self.c1.selectedIndex = 1

    for k , v in pairs(self.starAttrList) do
        v.text = ""
    end
    self.proMporeList.numItems = 0
    local pos = 1 
    -- print("坐骑属性>>>>>>>>>>>",v)
    local confData = conf.ZuoQiConf:getSkinsByIndex(v,0)
    self.c2.selectedIndex = 0
    -- if pos and self.proMore[pos] and (v == 1013 or v == 1019) then
    --     self.proMore[pos].text = language.zuoqi77
    -- end
    local suitStarPre = confData and confData.star_pre or 0
    local suitStars = cache.PlayerCache:getSkinStarLv(suitStarPre)
    if confData.star_pre then
        self.starSuitImg.visible = false
        --升星属性
        local suitStarConf = conf.RoleConf:getSkinsStarAttrData(v,1001)
        -- printt("升星>>>>>>>>>>",suitStarConf)
        for k,v in pairs(suitStarConf) do
            local str = string.format(language.fashion14,v.need_star) .. string.format(language.fashion15_1,language.gonggong94[1001],(v.attr_show/100))
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
    --self:setPro(GConfDataSort(conf.ZuoQiConf:getSkinsByIndex(v,0)))
end

function ZuoqiProPanel1:initPro3()
    -- body
    local t = GConfDataSort(conf.ZuoQiConf:getDataByLv(1,0)) 
    self:setPro(t)
end


function ZuoqiProPanel1:updateSelect(index)
    -- body
    self.c1.selectedIndex = index

    self:setData(self.data)
end

function ZuoqiProPanel1:setPro(t)
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
        --print("v[1]",v[1],v[2])
        item.text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],math.floor(v[2]))  --math.floor(v[2])  --EVE 百分比显示
        
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

function ZuoqiProPanel1:composeData(data,param)
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

function ZuoqiProPanel1:onbtnCallBack()
    -- body
    -- if self.labneed.text~="" then
    --     GComAlter(self.labneed.text)
    --     return
    -- end

    
    self.parent:onbtnCallBack()

end

function ZuoqiProPanel1:onBtnPlusBottom( )
    -- body
    local param = {}
    param.mId = self.usemid
    param.zuoqi = true
    param.index = self.index
    if param.mId then
        GGoBuyItem(param)
    end
end

function ZuoqiProPanel1:onPlusCallBack()
    -- body
    GGoVipTequan(2,1)
    --self.parent:closeView()
    --跳转
    --GOpenView({id = 1114})
end


function ZuoqiProPanel1:onGuize()
    -- body
    GOpenRuleView(1008)
end

return ZuoqiProPanel1