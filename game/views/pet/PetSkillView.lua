--
-- Author: 
-- Date: 2018-01-12 14:58:29
--

local PetSkillView = class("PetSkillView", base.BaseView)

function PetSkillView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function PetSkillView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    self.list1 = self.view:GetChild("n5")
    self.list1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list1.numItems = 0
    self.list1.onClickItem:Add(self.onlist1CallBack,self)

    self.list2 = self.view:GetChild("n6")
    self.list2.itemRenderer = function(index,obj)
        self:cellPackdata(index, obj)
    end
    self.list2.numItems = 0
    self.list2.onClickItem:Add(self.onlist2CallBack,self)

    local dec1 = self.view:GetChild("n3"):GetChild("n2")
    dec1.text = language.pet19
    local dec1 = self.view:GetChild("n4"):GetChild("n2")
    dec1.text = language.pet20

    local btn = self.view:GetChild("n8")
    btn.onClick:Add(self.onSkill,self)

    local btnGuize = self.view:GetChild("n9")
    btnGuize.onClick:Add(self.onGuize,self)

    --EVE 超链接跳转寻宝
    local goXunBao = self.view:GetChild("n10") 
    goXunBao.text = mgr.TextMgr:getTextColorStr(language.pet46 ,7,"") --EVE --ruleDesc[2][1][3]
    goXunBao.onClickLink:Add(self.onClickGOXunBao,self)
end

function PetSkillView:onClickGOXunBao()
    -- body
    GOpenView({id = 1194})
end

function PetSkillView:initData(data)
    -- body
    self.data = data

    self:setData()
    
end

function PetSkillView:setData(data_)
    --6个宠物技能
    self.list1.numItems = 6
    --筛选背包技能书
    self.skilllist = mgr.PetMgr:getPackSkillItem(self.data.petId)
    self.list2.numItems = math.max((math.ceil(#self.skilllist/18)*18),18) --#self.
end

function PetSkillView:celldata( index, obj )
    -- body
    local data = self.data.skillDatas[index+1]
    local icon = obj:GetChild("n0"):GetChild("n2")
    local jiaobiao = obj:GetChild("n0"):GetChild("n4")
    jiaobiao.visible = false
    obj.data = index
    
    local condata = conf.PetConf:getPetSkillById(data)
    if condata then
        if condata.icon then
            icon.url = ResPath.iconRes(condata.icon)
            if condata.jiaobiao then
                jiaobiao.visible = true
                jiaobiao.url = ResPath.iconOther(condata.jiaobiao)
            end
        else
            print("缺少icon配置,pet_skill",data)
            icon.url = nil 
        end
    else
        icon.url = nil 
    end
end

function PetSkillView:onlist1CallBack( context )
    -- body
    local item = context.data
    local data = item.data
    self.selectIndex = data+1

    local info = self.data.skillDatas[self.selectIndex]
    mgr.PetMgr:seeSkillInfo(info)
end


function PetSkillView:cellPackdata( index, obj )
    -- body
    local data = self.skilllist[index+1]
    local itemobj = obj:GetChild("n0")
    if data then
        local packdata = cache.PackCache:getPackDataById(data.mid)
        local t = clone(packdata)
        t.shownumber = false
        obj.data = t
        GSetItemData(itemobj,t)
    else
        obj.data = data 
        GSetItemData(itemobj,{})
    end
end

function PetSkillView:onlist2CallBack( context )
    -- body
    local item =  context.data
    local data = item.data
    if data then
        self.packdata = data 
        local info = clone(data)
        info.index = 0
        GSeeLocalItem(info)
    else
        item.selected = false
    end
end

function PetSkillView:onSkill()
    -- body
    if not self.data then
        return
    end
    -- if not self.selectIndex then
    --     GComAlter(language.pet21)
    --     return
    -- end
    if not self.packdata then
        GComAlter(language.pet22)
        return
    end
    if self.packdata.amount <= 0 then
        GComAlter(language.gonggong11)
        return
    end

    if not mgr.PetMgr:isCanLearnItem(self.data,self.packdata) then
        GComAlter(language.pet45)
        return
    end


    if mgr.PetMgr:isHaveLearnItem(self.data,self.packdata) then
        GComAlter(language.pet24)
        return
    end
    local flag  = mgr.PetMgr:isSomeTypeSkill(self.data,self.packdata)

    if flag then
        local condata = conf.PetConf:getPetSkillById(flag)

        local itemInfo = conf.ItemConf:getItem(self.packdata.mid)
        if not itemInfo or not itemInfo.ext01 then
            return
        end
        local _curSkill = conf.PetConf:getPetSkillById(itemInfo.ext01)
        if not _curSkill then
            return
        end
        local str = clone(language.pet37)
        str[2].text = string.format(str[2].text,_curSkill.name)
        str[4].text = string.format(str[4].text,condata.name)

        local param = {}
        param.type = 2
        param.richtext = mgr.TextMgr:getTextByTable(str)
        param.sure = function( ... )
            -- body
            self:doSend()
        end
        GComAlter(param)
        return
    end

    local flag,skillInfo = mgr.PetMgr:isSomeSkill(self.data,self.packdata) 
    if flag then
        local condata = conf.PetConf:getPetSkillById(skillInfo)
        if condata then
            
            local itemInfo = conf.ItemConf:getItem(self.packdata.mid)
            if not itemInfo or not itemInfo.ext01 then
                return
            end
            local _curSkill = conf.PetConf:getPetSkillById(itemInfo.ext01)
            if not _curSkill then
                return
            end
            local str = clone(language.pet25)
            str[2].text = string.format(str[2].text,_curSkill.name)
            str[4].text = string.format(str[4].text,condata.name)

            local param = {}
            param.type = 2
            param.richtext = mgr.TextMgr:getTextByTable(str)
            param.sure = function( ... )
                -- body
                self:doSend()
            end
            GComAlter(param)
        else
            print("宠物技能缺少 @策划 ",skillInfo)
        end
    else
        self:doSend()
    end
end

function PetSkillView:doSend()
    -- body
    local param = {}
    param.petRoleId = self.data.petRoleId
    param.mid = self.packdata.mid
    proxy.PetProxy:sendMsg(1490107,param)
end

function PetSkillView:onGuize()
    -- body
    --GOpenRuleView(1077)
    mgr.ViewMgr:openView2(ViewName.PetSkillSee)
end

function PetSkillView:addMsgCallBack(data)
    -- body
    if data.msgId == 5490107 then
        if self.data then
            local info  = cache.PetCache:getPetData(self.data.petRoleId)
            if info then
                self:initData(info)

                --做个特效
                --local index = info.skillDatas
                local condata = conf.ItemConf:getItem(self.packdata.mid)
                local index = 0
                for k , v in pairs(info.skillDatas) do
                    if condata.ext01 and condata.ext01 == v then
                        index = k -1 
                        break
                    end
                end

                local item = self.list1:GetChildAt(index)
                if item then
                    local panel = item:GetChild("n1")
                    local effec = self:addEffect(4020106, panel)
                    effec.LocalPosition = Vector3.New(panel.width/2,-panel.height/2,0)
                end
            end
        end
    end
end

return PetSkillView