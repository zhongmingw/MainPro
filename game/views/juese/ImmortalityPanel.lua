--
-- Author: Your Name
-- Date: 2017-12-06 22:26:27
--

local ImmortalityPanel = class("ImmortalityPanel",  import("game.base.Ref"))

function ImmortalityPanel:ctor(parent)
    self.parent = parent
    self.view = parent.view:GetChild("n20")
    self:initPanel()
end

function ImmortalityPanel:initPanel()
    self.c1 = self.view:GetController("c1")
    --左右切换阶的按钮
    local leftBtn = self.view:GetChild("n14")
    leftBtn.onClick:Add(self.onClickLeft,self)
    local rightBtn = self.view:GetChild("n15")
    rightBtn.onClick:Add(self.onClickRight,self)
    self.attList = {}--当前属性加成
    self.nextAttList = {}--下一阶属性加成
    for i=17,19 do
        local text = self.view:GetChild("n"..i)
        text.text = ""
        table.insert(self.attList,text)
    end
    for i=42,44 do
        local text = self.view:GetChild("n"..i)
        text.text = ""
        table.insert(self.nextAttList,text)
    end
    self.periodImg = self.view:GetChild("n6")
    self.jieIcon = self.view:GetChild("n7")
    self.icon = self.view:GetChild("n8")
    self.name = self.view:GetChild("n25")
    self.lvlUpBtn = self.view:GetChild("n12")
    self.lvlUpBtn.onClick:Add(self.onClicklevelUp,self)
    -- self:setData()
end

function ImmortalityPanel:onClickLeft()
    if self.nowLv > 1 then
        self.nowLv = self.nowLv - 1
        self:setIcon(self.nowLv)
    else

    end
end

function ImmortalityPanel:onClickRight()
    local attrConfData = conf.ImmortalityConf:getAttrData()
    if self.nowLv < #attrConfData-1 then
        self.nowLv = self.nowLv + 1
        self:setIcon(self.nowLv)
    else
        
    end
end

--图标设置
function ImmortalityPanel:setIcon(lv)
    local attrConf = conf.ImmortalityConf:getAttrDataByLv(lv)
    if attrConf then
        self.jieIcon.url = UIItemRes.jieshu[attrConf.step]
        self.icon.url = UIPackage.GetItemURL("juese" , attrConf.pic)

        self.name.text = attrConf.name or language.xiuxian09
        if attrConf.period == 1 then
            self.periodImg.url = UIPackage.GetItemURL("juese" , "xiuxian_032")
        elseif attrConf.period == 2 then
            self.periodImg.url = UIPackage.GetItemURL("juese" , "xiuxian_033")
        elseif attrConf.period == 3 then
            self.periodImg.url = UIPackage.GetItemURL("juese" , "xiuxian_034")
        end
    end
end

--当前属性设置
function ImmortalityPanel:initNowAttr()
    for k,v in pairs(self.attList) do
        v.text = ""
    end
    local lv = self.lv
    local attrConf = conf.ImmortalityConf:getAttrDataByLv(lv)
    local iconName = self.view:GetChild("n54")
    local textName = self.view:GetChild("n55")
    textName.text = attrConf.period_name
    iconName.url = UIPackage.GetItemURL("juese" , attrConf.name_img)
    --属性设置
    local attrData = GConfDataSort(attrConf)
    for k,v in pairs(attrData) do
        local key = v[1]
        local value = v[2]
        local decTxt = self.attList[k]
        local attName = conf.RedPointConf:getProName(key)
        decTxt.text = attName.." "..value
    end
    --技能提升显示
    -- local attId = (math.floor(lv/10)+1)*10
    -- attId = attId > 30 and 30 or attId
    for i=30,33 do
        self.view:GetChild("n" .. i).visible = true
    end
    self.view:GetChild("n38").visible = true
    self.view:GetChild("n66").visible = false
    
    local attrConfData = conf.ImmortalityConf:getAttrDataByLv(lv)
    -- print("当前等级",lv,attrConfData,attrConfData.skill_info)
    if attrConfData and attrConfData.skill_info then
        local sex = cache.PlayerCache:getSex()
        local icon = self.view:GetChild("n31")
        local skillName = self.view:GetChild("n32")
        local skillLv = self.view:GetChild("n33")
        local iconId = conf.SkillConf:getSkillIcon(attrConfData.skill_info[sex])
        local name = conf.SkillConf:getSkillName(attrConfData.skill_info[sex])
        icon.url =  ResPath.iconRes(iconId)
        skillName.text = name
        local affectData = conf.SkillConf:getSkillByIdAndLevel(attrConfData.skill_info[sex],attrConfData.skill_info[3])
        if affectData then
            skillLv.text = affectData.jie_start[1] .. language.gonggong117 .. affectData.jie_start[2] .. language.gonggong118
        else
            skillLv.text = "LV" .. attrConfData.skill_info[3]
        end
    else
        for i=30,33 do
            self.view:GetChild("n" .. i).visible = false
        end
        self.view:GetChild("n38").visible = false
        self.view:GetChild("n66").visible = true
    end

    --战力
    local power = self.view:GetChild("n26")
    power.text = attrConf.power
end

--下一阶属性设置
function ImmortalityPanel:initNextAttr()
    for k,v in pairs(self.nextAttList) do
        v.text = ""
    end
    local lv = self.lv + 1
    local attrConf = conf.ImmortalityConf:getAttrDataByLv(lv)
    local iconName = self.view:GetChild("n57")
    local textName = self.view:GetChild("n56")
    textName.text = attrConf.period_name
    iconName.url = UIPackage.GetItemURL("juese" , attrConf.name_img)
    --属性设置
    local attrData = GConfDataSort(attrConf)
    for k,v in pairs(attrData) do
        local key = v[1]
        local value = v[2]
        local decTxt = self.nextAttList[k]
        local attName = conf.RedPointConf:getProName(key)
        decTxt.text = attName.." "..value
    end
    --技能提升显示
    -- local attId = (math.floor(lv/10)+1)*10
    -- attId = attId > 30 and 30 or attId
    local attrConfData = conf.ImmortalityConf:getAttrDataByLv(lv)
    self.view:GetChild("n40").visible = true
    self.view:GetChild("n41").visible = true
    self.view:GetChild("n46").visible = true
    self.view:GetChild("n47").visible = true
    self.view:GetChild("n48").visible = true
    self.view:GetChild("n67").visible = false
    -- print("下一级技能",lv,attrConfData,attrConfData.skill_info)
    if attrConfData and attrConfData.skill_info then
        local sex = cache.PlayerCache:getSex()
        local icon = self.view:GetChild("n41")
        local skillName = self.view:GetChild("n46")
        local skillLv = self.view:GetChild("n47")
        local iconId = conf.SkillConf:getSkillIcon(attrConfData.skill_info[sex])
        local name = conf.SkillConf:getSkillName(attrConfData.skill_info[sex])
        icon.url =  ResPath.iconRes(iconId)
        skillName.text = name
        local affectData = conf.SkillConf:getSkillByIdAndLevel(attrConfData.skill_info[sex],attrConfData.skill_info[3])
        if affectData then
            skillLv.text = affectData.jie_start[1] .. language.gonggong117 .. affectData.jie_start[2] .. language.gonggong118
        else
            skillLv.text = "LV" .. attrConfData.skill_info[3]
        end
    else
        self.view:GetChild("n40").visible = false
        self.view:GetChild("n41").visible = false
        self.view:GetChild("n46").visible = false
        self.view:GetChild("n47").visible = false
        self.view:GetChild("n48").visible = false
        self.view:GetChild("n67").visible = true
    end
end

--升阶所需条件
function ImmortalityPanel:setLeveUpNeed()
    local attrConf = conf.ImmortalityConf:getAttrDataByLv(self.lv+1)
    if attrConf then
        local needPower = attrConf.need_power or 0
        local needItem = attrConf.cost_item
        local myPower = cache.PlayerCache:getRolePower()
        local powerTxt = self.view:GetChild("n61")
        local needNumTxt = self.view:GetChild("n64")
        local textData = {
            {text = GTransFormNum(myPower),color = 7},
            {text = "/" .. GTransFormNum(needPower),color = 7},
        }
        if myPower < needPower then
            textData = {
                {text = GTransFormNum(myPower),color = 14},
                {text = "/" .. GTransFormNum(needPower),color = 7},
            }
        end
        powerTxt.text = mgr.TextMgr:getTextByTable(textData)
        local itemObj = self.view:GetChild("n63")
        if needItem then
            local mid = needItem[1]
            local amount = cache.PackCache:getPackDataById(mid).amount
            local itemInfo = {mid = mid,amount = amount,bind = 1}
            GSetItemData(itemObj, itemInfo, true)
            local textData2 = {
                {text = amount,color = 7},
                {text = "/" .. needItem[2],color = 7},
            }
            if amount < needItem[2] then
                textData2 = {
                    {text = amount,color = 14},
                    {text = "/" .. needItem[2],color = 7},
                }
            end
            self.view:GetChild("n62").visible = true
            needNumTxt.visible = true
            needNumTxt.text = mgr.TextMgr:getTextByTable(textData2)
            itemObj.visible = true
        else
            self.view:GetChild("n62").visible = false
            needNumTxt.text = language.juese04
            needNumTxt.visible = false
            itemObj.visible = false
        end
    end
end

function ImmortalityPanel:setData(data)
    self.data = data
    self.lv = data.level--cache.PlayerCache:getSkins(14) or 0
    local attrConfData = conf.ImmortalityConf:getAttrData()
    if self.lv == 0 then
        proxy.ImmortalityProxy:sendMsg(1290102)
    else
        if self.lv >= (#attrConfData-1) then
            self:initNowAttr()
            self.c1.selectedIndex = 1
        else
            self.c1.selectedIndex = 0
            self:initNowAttr()
            self:initNextAttr()
            self:setLeveUpNeed()
        end
        self:setIcon(self.lv)
        self.nowLv = self.lv
    end
    local var = cache.PlayerCache:getRedPointById(10245)
    if var > 0 then
        self.lvlUpBtn:GetChild("red").visible = true
    else
        self.lvlUpBtn:GetChild("red").visible = false
    end
end

--升级按钮
function ImmortalityPanel:onClicklevelUp()
    local lv = self.lv
        local nextConf = conf.ImmortalityConf:getAttrDataByLv(lv+1)
        local myPower = cache.PlayerCache:getRolePower()
        if nextConf then
            local costItem = nextConf.cost_item
            local flag = true
            if costItem then
                local amount = cache.PackCache:getPackDataById(costItem[1]).amount
                if amount >= costItem[2] then
                    flag = true
                else
                    GComAlter(language.xiuxian02)
                    return
                end
            else
                flag = true
            end
            if flag then
                if nextConf.need_power then
                    if myPower >= nextConf.need_power then
                        proxy.ImmortalityProxy:sendMsg(1290102)
                    else
                        GComAlter(string.format(language.xiuxian07,nextConf.need_power))
                    end
                else
                    proxy.ImmortalityProxy:sendMsg(1290102)
                end
            end
        else
            GComAlter(language.xiuxian01)
        end
end

return ImmortalityPanel