--
-- Author: 
-- Date: 2017-03-07 11:50:52
--

local PanelSkill = class("PanelSkill",import("game.base.Ref"))

function PanelSkill:ctor(param)
    self.view = param
    self:initView()
end

function PanelSkill:initView()
    -- body
    self.c1 = self.view:GetController("c1")

    self.listView = self.view:GetChild("n12")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onItemCallBack,self)
    self.confData = conf.BangPaiConf:getAllSkill()

    self.icon = self.view:GetChild("n2"):GetChild("n1")
    self.iconname = self.view:GetChild("n3")
    self.dec1 = self.view:GetChild("n20")
    self.dec2 = self.view:GetChild("n21")

    self.dec3 = self.view:GetChild("n22")
    self.power1 = self.view:GetChild("n30")

    self.dec4 = self.view:GetChild("n23")
    self.power2 = self.view:GetChild("n31")

    self.dec5 = self.view:GetChild("n24")
    self.dec6 = self.view:GetChild("n25")
    self.dec7 = self.view:GetChild("n26")

    self.value1 = self.view:GetChild("n27")
    self.value2 = self.view:GetChild("n28")
    self.value3 = self.view:GetChild("n29")

    local btn = self.view:GetChild("n11")
    btn.onClick:Add(self.onSkillUp,self)

    self:initDec()
end

function PanelSkill:initDec()
    -- body
    self.dec1.text = ""
    self.dec2.text = ""

    --self.icon.url = ""
    self.dec3.text = ""
    self.power1.text = ""

    self.dec4.text = ""
    self.power2.text = ""

    self.dec5.text = language.bangpai73
    self.dec6.text = language.bangpai74
    self.dec7.text = language.bangpai75

    self.value1.text = ""
    self.value2.text = ""
    self.value3.text = ""
end



function PanelSkill:celldata( index, obj )
    -- body
    local data = self.confData[index+1]

    local skillIcon = obj:GetChild("n1"):GetChild("n1")
    skillIcon.url = ResPath.iconRes(data.icon) --UIPackage.GetItemURL("_icons" , ""..data.icon)

    local typeIcon = obj:GetChild("n2")
    typeIcon.url = UIPackage.GetItemURL("_imgfonts" , ""..data.type)
    
    local lablv = obj:GetChild("n3")
    local lv = self.data.skillLevs[data.id] or 0
    lablv.text = string.format(language.bangpai10,lv)

    obj.data = index
end

function PanelSkill:onItemCallBack(context)
    -- body
    local data = context.data.data
    self.index = data
    self:initRight()
end

function PanelSkill:initRight()
    -- body
    local confData = self.confData[self.index+1]
    local id = confData.id
    self.skillId = id 
    self.icon.url = ResPath.iconRes(confData.icon) -- UIPackage.GetItemURL("_icons" , ""..confData.icon)
    self.iconname.url = UIPackage.GetItemURL("_imgfonts" , ""..confData.type)
    if confData.decs then
        self.dec1.text = language.bangpai72 .. " "..confData.decs
    else
        self.dec1.text = ""
    end
    local lv = self.data.skillLevs[id] or 0
    self.dec2.text = string.format(language.bangpai10,lv)

    local conflv = conf.BangPaiConf:getSkillLev(id,lv)
    local confNext = conf.BangPaiConf:getSkillLev(id,lv+1)

    self.dec3.text = conflv.dec
    self.power1.text = conflv.power

    
    if confNext then
        self.dec4.text = confNext.dec
        self.power2.text = confNext.power
        self.c1.selectedIndex = 0

        self.value1.text = conflv.gang_lev
        self.value2.text = conflv.gx
        if  conflv.gx <= cache.PlayerCache:getTypeMoney(MoneyType.gx) then
            self.value3.text = mgr.TextMgr:getTextColorStr( cache.PlayerCache:getTypeMoney(MoneyType.gx), 7)
            self.isUp = 0
        else
            self.isUp = 1
            self.value3.text = mgr.TextMgr:getTextColorStr( cache.PlayerCache:getTypeMoney(MoneyType.gx), 14)
        end
        -- printt("conflv",conflv)
        if conflv.gang_lev > cache.BangPaiCache:getBangLev() then
            self.isUp = 2   
        end
    else --顶级了
        self.c1.selectedIndex = 1
    end

    
    ---红点检测
    self:redPointCheck() 
end

function PanelSkill:redPointCheck()
    -- body
    --直接找一个条件合适的
    local flag = false 
    for k ,v in pairs(self.confData) do
        local lv = self.data.skillLevs[v.id] or 0 --当前等级
        local conflv = conf.BangPaiConf:getSkillLev(v.id,lv)
        if conflv and conflv.gx and  conflv.gang_lev then
            if conflv.gang_lev >= cache.BangPaiCache:getBangLev() then --等级满足
                if conflv.gx <= cache.PlayerCache:getTypeMoney(MoneyType.gx) then --贡献满足
                    flag = true
                    break
                end
            end
        end
    end

    if not flag then
        mgr.GuiMgr:redpointByID(10222)
    end
end

function PanelSkill:onSkillUp()
    -- body
    --plog("elf.isUp",self.isUp)
    if self.isUp and self.isUp == 1 then
        GComAlter(language.gonggong19)
        return
    elseif self.isUp and self.isUp == 2 then
        GComAlter(language.bangpai143)
        return
    end
    local param = {}
    param.reqType = 2
    param.skillId = self.skillId
    proxy.BangPaiProxy:sendMsg(1250107,param)
end


function PanelSkill:setData(data)
    -- body
    self.data = data
    self.listView.numItems = #self.confData


    if not self.index then
        self.index = 0
    end
    self.listView:AddSelection(self.index,false)
    self:initRight(self.index)
end

return PanelSkill