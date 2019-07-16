--
-- Author: 
-- Date: 2018-01-12 14:58:23
-- 技能一览

local PetSkillSee = class("PetSkillSee", base.BaseView)

function PetSkillSee:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function PetSkillSee:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    self.listView = self.view:GetChild("n9")
    self.listView.itemRenderer = function(index,obj)
        self:cellpackdata(index, obj)
    end
end

function PetSkillSee:addComponent7()
    -- body
    local var = UIPackage.GetItemURL("pet" , "Component7")
    local _compent1 = self.listView:AddItemFromPool(var)
    return _compent1:GetChild("n2")
end
function PetSkillSee:addComponent8(i,v)
    -- body
    local var = UIPackage.GetItemURL("pet" , "Component8")
    local _compent1 = self.listView:AddItemFromPool(var)

    local data = self.typelist[v]
    local start = (i-1) * 8 + 1


    for  k = 0 , 7 do
        local info = data[start+k]

        local itemSkill = _compent1:GetChild("n"..k)
        itemSkill.data = info
        itemSkill.onClick:Clear()
        itemSkill.onClick:Add(self.onSee,self)

        local icon = itemSkill:GetChild("n2")
        local jiaobiao = itemSkill:GetChild("n4")
        jiaobiao.visible = false
        
        if info then
            itemSkill.visible = true
            icon.url = info.icon and ResPath.iconRes(info.icon) or nil
            if info.jiaobiao then
                jiaobiao.visible = true
                jiaobiao.url = ResPath.iconOther(info.jiaobiao) 
            end
        else
            itemSkill.visible = false
        end

        
    end 
end

function PetSkillSee:addComponent9()
    -- body
    local var = UIPackage.GetItemURL("pet" , "Component9")
    local _compent1 = self.listView:AddItemFromPool(var)
end

function PetSkillSee:onSee(context)
    -- body
    local data = context.sender.data
    if data then
        if self.data.flag and self.data.flag == "xt" then
            local view = mgr.ViewMgr:get(ViewName.XiantongSkillMsgTips)
            if view then
                view:initData(data)
            else
                mgr.ViewMgr:openView2(ViewName.XiantongSkillMsgTips,data)
            end
        else
            mgr.PetMgr:seeSkillInfo(data.id)
        end
        
    end
end


function PetSkillSee:setXTData()
    -- body
    self.typelist = {}
    self.typelist[1] = {}
    local t = conf.MarryConf:getAllSkill()
    for k ,v in pairs(t) do
        if not v._notshow then
            table.insert(self.typelist[1],v)
        end
    end

    
    table.sort(self.typelist[1],function(a,b)
        -- body
        return a.id < b.id
    end)

    local nums = math.ceil(#self.typelist[1] / 8)
    for i = 1 , nums do
        self:addComponent8(i,1)
    end
end


function PetSkillSee:initData(data)
    -- body
    self.data = data 
    self.listView.numItems = 0
    if data then
        if data.flag and data.flag == "xt" then
            self:setXTData()
            return
        end
        
    end


    self.data = conf.PetConf:getAllSkill()
    
    
    self.typelist = {}
    local keys  = {}
    for k , v in pairs(self.data) do
        for i , j in pairs(v.skill_type) do
            if not self.typelist[j] then
                self.typelist[j] = {}
                table.insert(keys,j)
            end
            table.insert(self.typelist[j],v)
        end
    end

    for k ,v in pairs(self.typelist) do
        table.sort(self.typelist[k],function(a,b)
            -- body
            return a.id < b.id 
        end)
    end

    table.sort(keys,function(a,b)
        -- body
        return a < b 
    end)

    for k ,v in pairs(keys) do
        if v ~= 4 then
            local title = self:addComponent7()
            title.text = language.pet15[v]

            local nums = math.ceil(#self.typelist[v] / 8)
            for i = 1 , nums do
                self:addComponent8(i,v)
            end

            self:addComponent9()
        end
    end
end

function PetSkillSee:setData(data_)

end

return PetSkillSee