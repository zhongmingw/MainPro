--
-- Author: Your Name
-- Date: 2017-05-24 11:13:21
--

local HookAwardsView = class("HookAwardsView", base.BaseView)

function HookAwardsView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.uiClear = UICacheType.cacheTime
end

function HookAwardsView:initView()
    local closeBtn = self.view:GetChild("n18")
    closeBtn.onClick:Add(self.onClickClose,self)
    local knowBtn = self.view:GetChild("n15")
    knowBtn.onClick:Add(self.onClickClose,self)
    --查看详情
    local detailsBtn = self.view:GetChild("n16")
    detailsBtn.onClick:Add(self.onClickDetails,self)
    self.selectController = self.view:GetController("c1")
    self.outlineTimeTxt = self.view:GetChild("n6")
    self.leftGuajiTimeTxt = self.view:GetChild("n7")
    self.oldLvTxt = self.view:GetChild("n8")
    self.jiantou = self.view:GetChild("n9")
    self.nowLvTxt = self.view:GetChild("n10")
    self.awardsTxt = self.view:GetChild("n11")
    self.robbedTimesTxt = self.view:GetChild("n12")
    self.listView = self.view:GetChild("n13")
    self:initListView()

    self.c2 = self.view:GetController("c2")
    local autoTitle = self.view:GetChild("n26")
    autoTitle.text = mgr.TextMgr:getTextColorStr(language.welfare59,6,"")
    autoTitle.onClickLink:Add(self.goSite,self)
    
    self.huoBanExp = self. view:GetChild("n25")
    self.huoBanExp.text = ""
    
    self.purpleEquipTitle = self.view:GetChild("n27")
    self.purpleEquipTitle.text = ""
   
    self.blueEquipTitle = self.view:GetChild("n28")
    self.blueEquipTitle.text = ""
end
--跳转自动吞噬设置
function HookAwardsView:goSite()
    GOpenView({id = 1076})
end

function HookAwardsView:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function( index,obj )
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
end
-- 变量名：amount  说明：数量
-- 变量名：mid 说明：道具id
-- 变量名：bind
function HookAwardsView:cellData( index,obj )
    -- body
    local data = self.data.awardsEquip[index+1]
    if data then
        data.index = 0
        GSetItemData(obj,data,true)
    end
end

-- 变量名：outlineTime 说明：累计离线收益时间
-- 变量名：leftGuajiTime  说明：剩余离线时间
-- 变量名：guajiExp    说明：今日挂机获得经验
-- 变量名：guajiTq 说明：今日挂机获得铜钱
-- 变量名：robbedTimes 说明：被抢夺次数
-- 变量名：awardsEquip 说明：挂机获得装备
-- 变量名：curType 说明：0:不设置默认 1:当前类型 2:设置吞噬类型
function HookAwardsView:setData(data)
    self.data = data
    local sex = cache.PlayerCache:getSex()
    if sex == 1 then
        self.selectController.selectedIndex = 0
    else
        self.selectController.selectedIndex = 1
    end
    self.outlineTimeTxt.text = self:toTimeString(self.data.outlineTime)
    self.leftGuajiTimeTxt.text = language.welfare32 ..self:toTimeString(self.data.leftGuajiTime).."）"
    local roleLv = cache.PlayerCache:getRoleLevel()
    local lvupExp = conf.RoleConf:getRoleExpById(roleLv)
    local oldLvupExp = conf.RoleConf:getRoleExpById(data.oldLevel)
    local oldExp = cache.ActivityCache:getOfflineExp()
    local nowExp = cache.PlayerCache:getRoleExp()
    if oldLvupExp > 0 then
        self.oldLvTxt.text = data.oldLevel .. language.gonggong43 ..(math.floor((data.oldExp/oldLvupExp)*1000)/10).."%"
        self.nowLvTxt.text = cache.PlayerCache:getRoleLevel() .. language.gonggong43 .. (math.floor((nowExp/lvupExp)*1000)/10).."%"
    else
        self.oldLvTxt.text = data.oldLevel .. language.gonggong43 .."100%"
        self.nowLvTxt.text = cache.PlayerCache:getRoleLevel() .. language.gonggong43 .. "100%"
    end
    ---self.oldLvTxt.text = data.oldLevel .. language.gonggong43 .. (math.floor((data.oldExp/oldLvupExp)*1000)/10).."%"
    self.listView.numItems = #self.data.awardsEquip
    local textData = {
                {text=language.welfare25[1],color = 6},
                {text=self.data.robbedTimes,color = 7},
                {text=language.welfare25[2],color = 6},
            }
    self.robbedTimesTxt.text = mgr.TextMgr:getTextByTable(textData)
    local textData2 = {
                {text=language.welfare26[1],color = 6},
                {text=self.data.guajiExp,color = 7},
                -- {text=language.welfare26[2],color = 6},
                -- {text=self.data.guajiTq,color = 7},
                {text=language.welfare26[3],color = 6},
                {text=self.data.equipNum,color = 7},
                {text=language.welfare26[4],color = 6},
            }
    self.awardsTxt.text = mgr.TextMgr:getTextByTable(textData2)

    self.jiantou.x = self.oldLvTxt.x + self.oldLvTxt.width + 5
    self.nowLvTxt.x = self.jiantou.x + self.jiantou.width + 5
    --添加自动吞噬 bxp
    local tuiShiEquip = {} --可吞装备
    self.showAwardData = {}
    for k,v in pairs(self.data.awardsEquip) do
        local type = conf.ItemConf:getType(v.mid)
        if type == 1 then --是装备
            local color = conf.ItemConf:getQuality(v.mid)
            --只显示紫色以上或者一星以上并且勾选吞噬bxp
            if self.data.curType == 1 and(color <= 4 or data.colorStarNum == 0) then 
                table.insert(tuiShiEquip,v)
            else
                table.insert(self.showAwardData,v)
            end
        else
            table.insert(self.showAwardData,v)--道具
        end
    end
    self.listView.numItems = #self.data.awardsEquip
    local purpleEquip = {} --可吞紫装
    local blueEquip = {} --可吞蓝装
    for k,v in pairs(tuiShiEquip) do
        local color = conf.ItemConf:getQuality(v.mid)
        if color == 4 then 
            table.insert(purpleEquip,v)
        elseif color == 3 then 
            table.insert(blueEquip,v)
        end
    end
    if self.data.curType == 0 then 
        self.c2.selectedIndex = 0
        self.huoBanExp.text = tostring(0)
    else
        self.c2.selectedIndex = 1
        
        local t = clone(language.welfare62) --紫装
        t[3].text = string.format(t[3].text,#purpleEquip)
        self.purpleEquipTitle.text = mgr.TextMgr:getTextByTable(t)
        
        local t2 = clone(language.welfare61) --蓝装
        t2[3].text = string.format(t2[3].text,#blueEquip)
        self.blueEquipTitle.text = mgr.TextMgr:getTextByTable(t2)
        
        self:getEquipExp(tuiShiEquip)
        
        local data = {}
        for k,v in pairs(tuiShiEquip) do
            table.insert(data,v.index)
        end
        proxy.HuobanProxy:send(1200201,{destIndex = data,reqType = 1})
    end
end

--计算所选装备可加的经验
function HookAwardsView:getEquipExp(equipData)
    local addExp = 0
    for k,v in pairs(equipData) do
        local amount = 1
        if v.amount then
            amount = v.amount
        end
        v.partner_exp = conf.ItemConf:getPartnerExp(v.mid)
        addExp = addExp + v.partner_exp*amount
    end
    self.huoBanExp.text = tostring(addExp)
end
function HookAwardsView:toTimeString(timeValue)
    -- body
    local hour=math.floor(timeValue/3600);

    local minute=math.floor((timeValue%3600)/60);

    local second=(timeValue%3600)%60;
    
    return string.format("%02d时%02d分",hour,minute)
end

function HookAwardsView:onClickDetails()
    -- body
    local param = {id = 1076,childIndex = 0}
    GOpenView(param)
end

function HookAwardsView:onClickClose()
    -- body
    mgr.XinShouMgr:checkModuleOpen()
    self:closeView()
end

return HookAwardsView