--
-- Author: wx
-- Date: 2017-12-09 11:27:41
--

local SkillPanelnew = class("SkillPanelnew", import("game.base.Ref"))

function SkillPanelnew:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n45")
    self:initData()
    self:initView()
end

function SkillPanelnew:initData()
    -- body
    local career = cache.PlayerCache:getSex()
    self.confData = conf.SkillConf:getSkillByCareer(career)   
end

function SkillPanelnew:initView()
    -- body
    --技能列表
    self.listView = self.view:GetChild("n1")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onUIClickCall,self)
    --当前选择技能
    self.c1 = self.view:GetController("c1")
    self.c1.selectedIndex = 0

    self.c2 = self.view:GetController("c2")
    self.c2.selectedIndex = 1

    self.curIcon = self.view:GetChild("n6")
    self.curIcon.url = nil
    self.curname = self.view:GetChild("n29")
    self.curname.text = ""
    self.curLevel = self.view:GetChild("n30")
    self.curLevel.text = ""
    self.curType = self.view:GetChild("n31")
    self.curType.text = ""
    self.curCD = self.view:GetChild("n32")
    self.curCD.text = ""
    self.xinImg = self.view:GetChild("n4")
    self.xinC1 = self.xinImg:GetController("c1")
    self.xinC1.selectedIndex = 0
    self.curDesc = self.view:GetChild("n16")
    self.curDesc.text = ""
    self.nextDesc = self.view:GetChild("n22")
    self.nextDesc.text = ""
    self.itemObj = self.view:GetChild("n23")
    self.itemObjull = self.view:GetChild("n40")
    self.objColor = self.view:GetChild("n24")
    self.objColor.text = ""
    self.objJie = self.view:GetChild("n25")
    self.objJie.text = ""
    --升级条件
    self.decTiaojian1 = self.view:GetChild("n36")
    self.decTiaojian1.text = language.skill09
    self.decTiaojian1Value = self.view:GetChild("n37")
    self.decTiaojian2 = self.view:GetChild("n38")
    self.decTiaojian2Value = self.view:GetChild("n39")
    self.decTiaojian2Value.text = ""

    self.btnUpskill = self.view:GetChild("n8")
    self.btnUpskill.onClick:Add(self.onbtnUpskill,self)

    self.btnOneKeyUp = self.view:GetChild("n7")
    self.btnOneKeyUp.onClick:Add(self.onOneKeyUp,self)
    self.redimg = self.btnOneKeyUp:GetChild("red")

    local dec1 = self.view:GetChild("n26")
    dec1.text = language.skill20

    self.btntoget = self.view:GetChild("n28")
    self.btntoget.onClick:Add(self.onGoGet,self)

    local plusTQ = self.view:GetChild("n41") --EVE 添加铜钱获取途径按钮
    plusTQ.onClick:Add(self.getTQBtn,self)
    local practice = self.view:GetChild("n42") --EVE 添加修仙跳转按钮
    practice.onClick:Add(self.gotoPractice,self)
    self.plusTQ = plusTQ
    self.practice = practice

    self.view:GetChild("n45").text = language.skill24
    local btnRadio = self.view:GetChild("n44")
    btnRadio.onClick:Add(self.onBtnRadio,self)
    self.btnRadio = btnRadio
end

function SkillPanelnew:getTQBtn()
    -- body
    local param = {}
    param.mId = 221051004
    GGoBuyItem(param)
end

function SkillPanelnew:gotoPractice()
    -- body
    GOpenView({id=1067})
end

function SkillPanelnew:isCanUpSkill( affectData )
    -- body
    local flag = true
    if affectData and  affectData.up_condition  then
        for k ,v in pairs(affectData.up_condition) do
            if k == 1 then
                local activeLv = cache.PlayerCache:getSkins(14) or 0
                -- local attrConfData = conf.ImmortalityConf:getAttrDataByLv(v)
                -- local sign = cache.PlayerCache:getAttribute(20139)
                -- if (activeLv>=v and activeLv%10 ~= 0) or (activeLv%10 == 0 and sign ~= 0 and activeLv >= v) then
                if activeLv >= v then
                else
                    flag = false
                    break
                end
            else
                if v > 0 then
                    local money = cache.PlayerCache:getTypeMoney(MoneyType.copper)
                    +cache.PlayerCache:getTypeMoney(MoneyType.bindCopper)

                    if money < v then
                        flag = false
                        break
                    end
                end
            end
        end
    else
        flag = false
    end

    return flag
end

function SkillPanelnew:getServerSkill(id)
    -- body
    for k ,v in pairs(self.data.skillInfo) do
        if v.skillId == id then
            return v 
        end
    end
    return nil 
end

function SkillPanelnew:celldata(index, obj)
    -- body
    obj.data = index
    local confData = self.confData[index+1]
    local data = self:getServerSkill(confData.id)
    local level = data and data.skillLevel or 1
    local affectData = conf.SkillConf:getSkillByIdAndLevel(confData.id,level)
    --print("confData.id,level",confData.id,level)
    local icon = obj:GetChild("n6")
    icon.url =  ResPath.iconRes(confData.icon)

    local labname = obj:GetChild("n4")
    labname.text = confData.name

    local ss = ""
    if confData.stype == 1 then
        --任务开启
        if not cache.TaskCache:isfinish(confData.open_lvl) then
            ss = confData.desc
        end
    elseif confData.stype == 3 then
        --等级开启
        if cache.PlayerCache:getRoleLevel() < confData.open_lvl then
            ss = confData.desc
        end
    elseif confData.stype == 4 then
        --装备穿戴开启
        -- if not  cache.PackCache:getEquipDataByPart(confData.part) then
        --     ss = confData.desc
        -- end
        local var = conf.SysConf:getValue("two_btn_lock")
        if cache.PlayerCache:getRoleLevel() < var then
            ss = string.format(language.gonggong07,var)
        end
    end

    local lablevel = obj:GetChild("n5")
    lablevel.text = ss
    --string.format(language.skill03,level)
    --是否可升级
    local c1 = obj:GetController("c1")
    if confData.stype == 4 then
        c1.selectedIndex = 0
    else
        if not affectData.up_condition then
            c1.selectedIndex = 0
        else
            local flag = self:isCanUpSkill(affectData)
            if flag then
                self.redimg.visible = true
            else
                self.redimg.visible = false
            end
            if flag and data then
                c1.selectedIndex = 1
            else
                c1.selectedIndex = 0
            end
        end
    end
end

function SkillPanelnew:onUIClickCall( context )
    -- body
    local cell = context.data
    self.selectindex = cell.data
    self:setSelectData()
end

function SkillPanelnew:setSelectData(flag)
    -- body
    local confData = self.confData[self.selectindex+1]

    local open = UPlayerPrefs.GetInt(confData.id.."_SkillPanel") or 0
    self.btnRadio.selected = (open ~= 2)

    ---self.c2.selectedIndex = confData.stype == 1 and 1 or 0


    local data = self:getServerSkill(confData.id)
    local level = data and data.skillLevel or 1
    local affectData
    if confData.stype == 4 then
        self.xinImg.visible =false
        local partdata = cache.PackCache:getEquipDataByPart(confData.part)
        if partdata then
            self.itemObjull.url = nil 
            GSetItemData(self.itemObj,partdata,true)
            local condata = conf.ItemConf:getItem(partdata.mid)
            --print("partdata.mid",partdata.mid)
            if not condata.skill_affect_id then
                print("道具配置 mid="..partdata.mid.. "缺少skill_affect_id")
            end
            affectData = conf.SkillConf:getSkillByIndex(condata.skill_affect_id)

            

            self.objColor.text = string.format(language.skill18,language.gonggong110[condata.color])
            self.objJie.text =  string.format(language.skill19,condata.stage_lvl)
            self.curType.text = string.format(language.skill04,language.skill22) 
            self.curLevel.text = ""
        else
            local ss 
            if confData.part == 11 then
                ss = "baoshi_008"
            else
                ss = "baoshi_033"
            end
            GSetItemData(self.itemObj,{})
            self.itemObjull.url = UIPackage.GetItemURL("_others" , ss)

            self.nextDesc.text = language.skill16
            self.objColor.text = ""
            self.objJie.text = ""
            self.curLevel.text = language.skill23
            self.curType.text = string.format(language.skill04,language.skill22)
            local mid 
            if confData.part == 12 then 
                mid = 112125005
            else
                mid = 112115005 
            end
            local condata = conf.ItemConf:getItem(mid)
            affectData = conf.SkillConf:getSkillByIndex(condata.skill_affect_id)

        end
        self.curDesc.text = ""
        self.c1.selectedIndex = 1 
         
        self.nextDesc.text = affectData and affectData.dec or ""
        
        
    else
        self.xinImg.visible = true
        affectData = conf.SkillConf:getSkillByIdAndLevel(confData.id,level)
        --print("###",confData.id .. string.format("%03d",level))
        self.c1.selectedIndex = 0
        self.curLevel.text = string.format(language.skill03,tostring(level)) 
        self.curDesc.text = affectData.dec
        local nextconf = conf.SkillConf:getSkillByIdAndLevel(confData.id,level+1)
        if nextconf then
            self.nextDesc.text = nextconf.dec
        else
            self.nextDesc.text = language.skill17
        end
        self.curType.text =  string.format(language.skill04,confData.etypedec)

        if affectData and affectData.jie_start then
            self.curLevel.text = string.format(language.skill15, affectData.jie_start[1], affectData.jie_start[2])
            
            if flag or affectData.jie_start[2] == 0 then
                self.xinC1.selectedIndex = affectData.jie_start[2]
            else
                self.xinC1.selectedIndex = affectData.jie_start[2] + 10
            end
             
        else
            self.curLevel.text = ""
            self.xinC1.selectedIndex = 0
        end 

       
    end

    self.curIcon.url = ResPath.iconRes(confData.icon)
    self.curname.text = confData.name
    
    
    if affectData and affectData.cd_time then
        self.curCD.text = string.format(language.skill05,affectData.cd_time/1000)
    else
        self.curCD.text = ""
    end

    self.iscanUp = {false,false}
    if affectData and affectData.up_condition then
        for k ,v in pairs(affectData.up_condition) do
            if k == 1 then
                self.decTiaojian1.visible = true
                self.decTiaojian1.text = language.skill09
                local str = ""
                local activeLv = cache.PlayerCache:getSkins(14) or 0
                local attrConfData = conf.ImmortalityConf:getAttrDataByLv(v)
                if not attrConfData then
                    print("要求的修仙等级 读取不到配置 up_condition配置错误",v)
                end
                local sign = cache.PlayerCache:getAttribute(20139)
                -- if (activeLv>=v and activeLv%10 ~= 0) or (activeLv%10 == 0 and sign ~= 0 and activeLv >= v) then
                if activeLv >= v then
                    self.iscanUp[1] = true --等级满足
                    str = mgr.TextMgr:getTextColorStr(attrConfData.name.. attrConfData.period_name .."  "..language.skill12,7)
                    
                    --self.practice.visible = false --EVE
                else
                    str = mgr.TextMgr:getTextColorStr(attrConfData.name.. attrConfData.period_name .."  "..language.skill11,14)
                    
                    --self.practice.visible = true --EVE
                end 
                self.decTiaojian1Value.text = str
                self.practice.visible = true
            else
                if v > 0 then
                    self.decTiaojian2.visible = true
                    --self.decTiaojian2.text = language.skill10

                    local money = cache.PlayerCache:getTypeMoney(MoneyType.copper)
                    +cache.PlayerCache:getTypeMoney(MoneyType.bindCopper)

                    local str = ""
                    if money >= v then
                        self.iscanUp[2] = true --铜钱满足
                        str = mgr.TextMgr:getTextColorStr(v .."  "..language.skill12,7)

                        --self.plusTQ.visible = false --EVE
                    else
                        str = mgr.TextMgr:getTextColorStr(v .."  "..language.skill11,14) 

                        --self.plusTQ.visible = true --EVE                      
                    end
                    self.decTiaojian2Value.text = str 
                    self.plusTQ.visible = true --EVE                      
                else
                    self.iscanUp[2] = true --铜钱满足
                    self.decTiaojian2.visible = false
                    self.decTiaojian2Value.text = ""

                    self.plusTQ.visible = false --EVE
                end             
            end
        end
    else
        self.decTiaojian1.visible = false
        self.decTiaojian1Value.text = ""

        self.decTiaojian2.visible = false
        self.decTiaojian2Value.text = ""

        --EVE 按钮隐藏
        self.plusTQ.visible = false
        self.practice.visible = false
    end
end

function SkillPanelnew:setData(data,flag)
    -- body
    self.data = data
    self.listView.numItems = #self.confData
    self.redimg.visible = false
    if not self.selectindex then
        self.selectindex = 0
    end
    self.listView:AddSelection(self.selectindex,false)
    self:setSelectData(flag)
end

--升级技能
function SkillPanelnew:onbtnUpskill()
    -- body
    if not self.data then
        return
    end
    if not self.decTiaojian1.visible then
        GComAlter(language.skill17)
        return
    end
    
    if not self.iscanUp then
        GComAlter(language.skill13)
        return
    end

    for k ,v in pairs(self.iscanUp) do
        if not v then
            if k == 1 then
                GComAlter(language.gonggong114)
            else
                GComAlter(language.gonggong05)
            end
            return
        end
    end

    local confData = self.confData[self.selectindex+1]
    local param = {}
    param.reqType = 1
    param.skillId = confData.id
    proxy.SkillProxy:send(1110102,param) 
end
--一键升级所有技能
function SkillPanelnew:onOneKeyUp()
    -- body
    if not self.data then
        return
    end

    local flag = false
    for k ,v in pairs(self.confData) do
        local data = self:getServerSkill(v.id)
        if data then --有这个技能
            local affectData = conf.SkillConf:getSkillByIdAndLevel(v.id,data.skillLevel)
            if self:isCanUpSkill(affectData) then
                flag = true
                break
            end
        end
    end
    if not flag then
        GComAlter(language.skill14)
        return
    end
    local param = {}
    param.reqType = 2
    param.skillId = 0
    proxy.SkillProxy:send(1110102,param)
end

function SkillPanelnew:onGoGet()
    -- body
    GOpenView({id = 1155})
end


function SkillPanelnew:onBtnRadio(context)
    -- body
    if not self.data then
        --print("1")
        return
    end
    if not self.selectindex then
        --print("2")
        return
    end
    local confData = self.confData[self.selectindex+1]
    if not confData then
        --print("3")
        return
    end
    local btn = context.sender
    local index = btn.selected and 1 or 2
    --print("存入confData.id",confData.id,index)
    UPlayerPrefs.SetInt(confData.id.."_SkillPanel",index)
end

return SkillPanelnew