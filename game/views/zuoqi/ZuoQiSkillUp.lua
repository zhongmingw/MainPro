--
-- Author: 
-- Date: 2017-02-17 15:42:26
--

local ZuoQiSkillUp = class("ZuoQiSkillUp", base.BaseView)
local redpoint = {10216,10207,10210,10208,10209,10262}
function ZuoQiSkillUp:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function ZuoQiSkillUp:initData(data)
    -- body
    self.data = data
    --self:setData(data)
end

function ZuoQiSkillUp:initView()
    local window4 = self.view:GetChild("n0")
    local btnClose = window4:GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)
    --self.window4Icon = window4:GetChild("icon")

    self.skillIcon = self.view:GetChild("n8")
    self.skillname = self.view:GetChild("n9")
    self.dec1 = self.view:GetChild("n11")
    self.value1 = self.view:GetChild("n12")
    self.yuan1 = self.view:GetChild("n13")

    self.dec2 = self.view:GetChild("n14")
    self.value2 = self.view:GetChild("n15")
    self.yuan2 = self.view:GetChild("n16")

    self.dec3 = self.view:GetChild("n18")
    self.value3 = self.view:GetChild("n19")
    self.yuan3 = self.view:GetChild("n20")

    self.dec4 = self.view:GetChild("n21")
    self.itemName = self.view:GetChild("n22") 
    self.itemCount = self.view:GetChild("n23")
    self.itemObj = self.view:GetChild("n3")

    local btnPlus = self.view:GetChild("n6")
    btnPlus.onClick:Add(self.onBtnPlus,self)
    self.btnPlus = btnPlus
    if g_ios_test then  --EVE ios版属屏蔽
        btnPlus.scaleX = 0
        btnPlus.scaleY = 0 
    end 

    local btnUp = self.view:GetChild("n7")
    --self.btnUpTitle = btnUp:GetChild("title")
    btnUp.onClick:Add(self.onSkillUp,self)
    self.btnUp = btnUp

    self.c1 = self.view:GetController("c1")

    self:initDec()
end

function ZuoQiSkillUp:initDec()
    -- body
    self.skillname.text = ""

    self.dec1.text = language.zuoqi13 
    self.value1.text = ""
    self.dec2.text = language.zuoqi14
    self.value2.text = ""
    self.dec3.text = language.zuoqi15
    self.value3.text = ""

    self.dec4.text = language.zuoqi16
    self.itemName.text = ""
    self.itemCount.text = ""
end

function ZuoQiSkillUp:setCommon(flag)
    -- body
    self.isUp = {false,false,false}

    self.skillname.text = self.condata.name
    self.skillIcon.url = ResPath.iconRes(self.condata.icon) --UIPackage.GetItemURL("_icons" , ""..self.condata.icon)
    
    local needlv 
    if self.index == 0 then
        needlv = self.confup.horse_lev
    else
        needlv = self.confup.need_lev
    end
    --plog("needlv",needlv)
    local maxto = conf.ZuoQiConf:getValue("endmaxjie",self.index) or 10
    local decStr = string.format(language.zuoqi17[self.index+1],needlv) 
    if needlv <= self.data.maxjie then
        self.value1.text =  decStr
    elseif needlv > maxto then
        self.value1.text =  string.format(language.zuoqi17[self.index+1],maxto)  --decStr
    else
        self.isUp[1] = true --坐骑阶数不满足
        self.value1.text = mgr.TextMgr:getTextColorStr(decStr,14) 
    end

    if self.data.lv <= 0 then --激活
        self.value2.text = language.zuoqi18
        --self.btnUpTitle.text = language.zuoqi21
    else
        self.value2.text = self.confup.dec
        --self.btnUpTitle.text = language.zuoqi22
    end
    
    if self.confup.cost_items  then
        for k ,v in pairs(self.confup.cost_items) do
            if k > 1 then
                break
            end
            local t = {mid = v[1]}
            t.isquan = true
            self.mId = v[1]
            self.itemObj.visible = true
            GSetItemData(self.itemObj,t,true)
            self.itemName.text = conf.ItemConf:getName(v[1]) 

            local itemCount = cache.PackCache:getPackDataById(v[1])
            local param = {}
            if itemCount.amount < v[2] then
                self.isUp[2] = true
                table.insert(param,{color = 14,text = itemCount.amount})
            else
                
                table.insert(param,{color = 7,text = itemCount.amount})
            end
            table.insert(param,{color = 7,text = "/"..v[2]})

            self.itemCount.text = mgr.TextMgr:getTextByTable(param)
        end
    else
        self.isUp[2] = true
        self.itemObj.visible = false
    end

    if self.nextconf and needlv <= maxto then
        self.dec3.text = language.zuoqi15
        self.value3.text = self.nextconf.dec
        self.c1.selectedIndex = 0
    else
        self.isUp[3] = true
        self.c1.selectedIndex = 1
    end
    -- --红点改变
    -- if flag then
    --     for k ,v in pairs(self.isUp) do
    --         if v then
    --             --plog("红点扣除")
    --             mgr.GuiMgr:redpointByID(redpoint[self.index+1])
    --             break
    --         end
    --     end
    -- end
end

function ZuoQiSkillUp:setData(index,flag)
    self.index = index 
    self.condata = conf.ZuoQiConf:getSkillById(self.data.id,index)
    self.confup = conf.ZuoQiConf:getSkillByLev(self.data.id,self.data.lv,index)
    self.nextconf = conf.ZuoQiConf:getSkillByLev(self.data.id,self.data.lv+1,index)

    self:setCommon(flag) 
end

function ZuoQiSkillUp:onBtnPlus()
    -- body
    --加号按钮
    local param = {}
    param.mId = self.mId 
    GGoBuyItem(param)
end

function ZuoQiSkillUp:onSkillUp()
    -- body 技能升级
    if self.isUp then
        for k ,v in pairs(self.isUp) do
            if v then
                if k == 1 then
                    GComAlter(self.value1.text)
                elseif k == 2 then
                    self:onBtnPlus()
                else
                    GComAlter(language.zuoqi19) 
                end
                
                return
            end
        end
    end
    if self.index == 0 then ---坐骑
        proxy.ZuoQiProxy:send(1120104,{skillId = self.data.id})
    elseif self.index == 1 then --神兵
        proxy.ZuoQiProxy:send(1160104,{skillId = self.data.id})
    elseif self.index == 2 then----法宝
        proxy.ZuoQiProxy:send(1170104,{skillId = self.data.id})
    elseif self.index == 3 then --仙羽
        proxy.ZuoQiProxy:send(1140104,{skillId = self.data.id})
    elseif self.index == 4 then
        proxy.ZuoQiProxy:send(1180104,{skillId = self.data.id})
    elseif self.index == 5 then
        proxy.ZuoQiProxy:send(1560104,{skillId = self.data.id})
    end
end

function ZuoQiSkillUp:onBtnClose()
    -- body
    self:closeView()
end

function ZuoQiSkillUp:add5120104(data)
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end
-- 请求坐骑技能升级
function ZuoQiSkillUp:add5140104(data)
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end
-- 请求仙羽技能升级
function ZuoQiSkillUp:add5140104(data)
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end
-- 请求神兵技能升级
function ZuoQiSkillUp:add5160104(data)
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end
-- 请求法宝技能升级
function ZuoQiSkillUp:add5170104(data)
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end
--  请求仙器技能升级
function ZuoQiSkillUp:add5180104(data)
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end

function ZuoQiSkillUp:add5560104( data )
    -- body
     self.data.lv = data.lev
    self:setData(self.index,true)
end

function ZuoQiSkillUp:add5090102()
    -- body
    self:setData(self.index)
end

function ZuoQiSkillUp:add5180104(data)
    -- body
    self.data.lv = data.lev
    self:setData(self.index,true)
end

return ZuoQiSkillUp