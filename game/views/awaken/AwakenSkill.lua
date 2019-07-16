--
-- Author: 
-- Date: 2017-09-21 17:31:49
--

local AwakenSkill = class("AwakenSkill", base.BaseView)

function AwakenSkill:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function AwakenSkill:initView()
    self.view.onClick:Add(self.onCloseView,self)

    self.view:GetChild("n0"):GetChild("n2").visible = false

    self.icon = self.view:GetChild("n2")
    self.name = self.view:GetChild("n3") 
    self.dec = self.view:GetChild("n4")

    local dec1 = self.view:GetChild("n5")
    dec1.text = language.awaken36

    self.dec1 = self.view:GetChild("n6")
    self.dec2 = self.view:GetChild("n7")
end

function AwakenSkill:initData(data)
    -- body
    self.data = data
    self:setData()
end

function AwakenSkill:isJihuo(id)
    -- body
    if self.data.data then
        for k , v in pairs(self.data.data.activedEffects) do
            if v == id then
                return true
            end
        end
    end
    return false
end
--local param = {data = self.msgData,index = self.index ,skill = data,icon = cell.icon}
function AwakenSkill:setData(data_)
    self.icon.url = self.data.icon
    self.name.text = string.format(language.awaken37[self.data.skill],self.data.index)
    --所有套装
    local confData = conf.ForgingConf:getAllSuit(3)[self.data.index]

    local var 
    local confall = conf.ForgingConf:getSuitEffect(confData.id)
    for i,j in pairs(confall) do
        if self.data.skill == 1 then
            if j.att_329 then
                var= j
                break
            end
        else
            if j.att_315 then
                var = j
                break
            end
        end
    end
    local str
    if self.data.skill == 1 then
        str = string.format(language.awaken39,var.equip_num,language.gonggong21[self.data.index])
        self.dec.text = string.format(language.awaken38[1],var.att_329/1000)
    else
        str = string.format(language.awaken39,var.equip_num,language.gonggong21[self.data.index])
        self.dec.text = string.format(language.awaken38[2],var.att_315/10000)
    end
    str = str .. "("
    --
    if self.data.num > var.equip_num then
        str= str .. mgr.TextMgr:getTextColorStr(self.data.num, 7)
    else
        str= str .. mgr.TextMgr:getTextColorStr(self.data.num, 14)
    end
    str = str .. "/"..var.equip_num..")"
    self.dec1.text = str

    self.dec2.text = language.awaken40[self.data.skill][self.data.index]

end

function AwakenSkill:onCloseView()
    -- body
    self:closeView()
end

return AwakenSkill