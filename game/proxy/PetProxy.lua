--
-- Author: 
-- Date: 2018-01-12 14:57:01
--

local PetProxy = class("PetProxy",base.BaseProxy)

function PetProxy:init()
    -- self:add(5010101,self.resLogin)
    self:add(5490101,self.add5490101)--  请求宠物信息
    self:add(5490102,self.add5490102)--  请求宠物升级
    self:add(5490103,self.add5490103)--  请求宠物进阶
    self:add(5490104,self.add5490104)--  请求宠物装备穿戴
    self:add(5490105,self.add5490105)--  请求宠物装备升级
    self:add(5490106,self.add5490106)--  请求宠物出战
    self:add(5490107,self.add5490107)--  请求宠物技能学习
    self:add(5490108,self.add5490108)--  请求宠物放生
    self:add(5490109,self.add5490109)--  请求使用宠物成长丹修改成长值
    self:add(5490110,self.add5490110)--  请求玩家单个宠物信息
    self:add(5490111,self.add5490111)--   请求宠物改名

    self:add(5490201,self.add5490201)--   请求宠物上阵信息
    self:add(5490202,self.add5490202)--    请求开启宠物阵位
end

function PetProxy:sendMsg(msgId,param)
    -- body
    --printt(msgId,param or {})
    self:send(msgId,param)
end

function PetProxy:add5490101( data )
    -- body
    if data.status == 0 then
        cache.PetCache:setData(data.petInfos)
        cache.PetCache:setCurpetRoleId(data.petRoleId)

        --更新当前上阵宠物的名字
        local info  = cache.PetCache:getPetData(data.petRoleId)
        if gRole and info then
            local id = gRole:getPetID()
            local pet = mgr.ThingMgr:getObj(ThingType.pet, id)
            if pet then
                pet:updtePetName(info.name)
            end
        end

        local view = mgr.ViewMgr:get(ViewName.PetMainView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.ChatView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.MarketMainView)
        if view then
            local view = mgr.ViewMgr:get(ViewName.PutAwayPanel)
            if view then
                view:setPetListVisible(true)
                view:setData(data)
            else
                mgr.ViewMgr:openView(ViewName.PutAwayPanel,function(view)
                    view:setPetListVisible(true)
                    view:setData(data)
                end)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
function PetProxy:add5490102( data )
    -- body
    if data.status == 0 then
        cache.PetCache:updateLevel(data)
        local view = mgr.ViewMgr:get(ViewName.PetMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function PetProxy:add5490103( data )
    -- body
    if data.status == 0 then
        cache.PetCache:updatePetId(data)

        --更新当前上阵宠物的名字
        if data.petRoleId == cache.PetCache:getCurpetRoleId() then
            local info  = cache.PetCache:getPetData(data.petRoleId)
            if gRole and info then
                local id = gRole:getPetID()
                local pet = mgr.ThingMgr:getObj(ThingType.pet, id)
                if pet then
                    pet:updtePetName(info.name)
                end
            end
        end

        local view = mgr.ViewMgr:get(ViewName.PetMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function PetProxy:add5490104( data )
    -- body
    if data.status == 0 then
        cache.PetCache:updateEquip(data)
        local view = mgr.ViewMgr:get(ViewName.PetMainView)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.PetEquipView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function PetProxy:add5490105( data )
    -- body
    if data.status == 0 then
        --printt("add5490105",data)
        cache.PetCache:updateEquipLevel(data)


        local view = mgr.ViewMgr:get(ViewName.PetMainView)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.PetEquipView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function PetProxy:add5490106( data )
    -- body
    if data.status == 0 then
        cache.PetCache:setCurpetRoleId(data.petRoleId)
        --更新当前上阵宠物的名字
        local info  = cache.PetCache:getPetData(data.petRoleId)
        if gRole and info then
            gRole.data.petName = info.name
            --print("info.name",info.name)
            local id = gRole:getPetID()
            local pet = mgr.ThingMgr:getObj(ThingType.pet, id)
            if pet then
                pet:updtePetName(info.name)
            end
        end

        local view = mgr.ViewMgr:get(ViewName.PetMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function PetProxy:add5490107( data )
    -- body
    if data.status == 0 then
        --print("add5490107",data)
        GComAlter(language.pet38)

        cache.PetCache:updateSkill(data)


        local view = mgr.ViewMgr:get(ViewName.PetMainView)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.PetSkillView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function PetProxy:add5490108( data )
    -- body
    if data.status == 0 then
        GOpenAlert3(data.items)
        cache.PetCache:deletePet(data)
        local view = mgr.ViewMgr:get(ViewName.PetMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function PetProxy:add5490109( data )
    -- body
    if data.status == 0 then
        GComAlter(string.format(language.pet35,data.growValue/100))

        cache.PetCache:updateZZ(data)
        local view = mgr.ViewMgr:get(ViewName.PetMainView)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.PetGrowView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function PetProxy:add5490110(data)
    -- body
    if data.status == 0 then
        --printt("add5490110",data)
        if data.viewType == 0 then
            mgr.ViewMgr:openView2(ViewName.PetMsgView, data.petInfo)
        else
            --查看玩家宠物信息
            local view = mgr.ViewMgr:get(ViewName.SeeOtherMsg)
            if view then
                view:addMsgCallBack(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
function PetProxy:add5490111( data )
    -- body
    if data.status == 0 then
        cache.PetCache:updatePetName(data)

        if cache.PetCache:getCurpetRoleId() == data.petRoleId then
            --更新当前上阵宠物的名字
            if gRole then
                gRole.data.petName = data.name
                local id = gRole:getPetID()
                local pet = mgr.ThingMgr:getObj(ThingType.pet, id)
                if pet then
                    pet:updtePetName(data.name)
                end
            end
        end

        local view = mgr.ViewMgr:get(ViewName.PetMainView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.JueSeName)
        if view then
            view:closeView()
        end
    else
        GComErrorMsg(data.status)
    end
end

function PetProxy:add5490201(data)
    -- body
    if data.status == 0 then
        --printt("8588888",data)
        local view = mgr.ViewMgr:get(ViewName.PetMainView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.PetOnHelp)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function PetProxy:add5490202(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.PetMainView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.PetOnHelp)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
return PetProxy