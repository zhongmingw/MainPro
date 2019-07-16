--
-- Author: 
-- Date: 2017-02-25 15:55:34
--

local HuobanProxy = class("HuobanProxy",base.BaseProxy)

function HuobanProxy:init()
    -- self:add(5010101,self.resLogin)
    self:add(5200101,self.add5200101)
    self:add(5200102,self.add5200102)
    self:add(5200103,self.add5200103)
    self:add(5200104,self.add5200104)
    self:add(5200105,self.add5200105)
    self:add(5200106,self.add5200106)
    self:add(5200107,self.add5200107)
    self:add(5200201,self.add5200201)--伙伴吞噬装备升级

    self:add(5210101,self.add5200101)
    self:add(5210102,self.add5200102)
    self:add(5210103,self.add5200103)
    self:add(5210104,self.add5200104)
    self:add(5210105,self.add5210105)

    self:add(5220102,self.add5200101)
    self:add(5220103,self.add5200102)
    self:add(5220104,self.add5200103)
    self:add(5220105,self.add5200104)
    self:add(5220106,self.add5220105)

    self:add(5230101,self.add5200101)
    self:add(5230102,self.add5200102)
    self:add(5230103,self.add5200103)
    self:add(5230104,self.add5200104)
    self:add(5230105,self.add5230105)

    self:add(5240101,self.add5200101)
    self:add(5240102,self.add5200102)
    self:add(5240103,self.add5200103)
    self:add(5240104,self.add5200104)
    self:add(5240105,self.add5240105)

    self:add(5250101,self.add5200101)
    self:add(5250102,self.add5200102)
    self:add(5250103,self.add5200103)
    self:add(5250104,self.add5200104)
    self:add(5250105,self.add5250105)
end

function HuobanProxy:add5200101(data)
    -- body
    if data.status == 0 then
        cache.HuobanCache:setData(data)
        if data.msgId == 5200101 then
            local modelId = cache.PlayerCache:getSkins(8)
            local confData = conf.HuobanConf:getSkinsByModel(modelId,0)
            if confData and confData.id then
                for k,v in pairs(data.skins) do
                    if confData.id == v.skinId then
                        cache.PlayerCache:setPetName(v.name)
                        gRole:addRolePet() --刷新一下
                    end
                end
            end
        end

        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.HuoBanChange)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function HuobanProxy:add5200102(data)
    -- body
    if data.status == 0 then
        --cache.HuobanCache:setLevelData(data)
        if data.msgId == 5200102 then
            cache.PlayerCache:setPartnerLevel(data.lev)
            gRole:addRolePet() --刷新一下
        end

        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            view:setAuto(false)
        end
        GComErrorMsg(data.status)
    end
end

function HuobanProxy:add5200103(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.HuobanEquipUp)
        if view then
            view:add5200103(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function HuobanProxy:add5200104( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.HuobanSkillUp)
        if view then
            view:add5210104(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--  请求坐骑皮肤改变
function HuobanProxy:add5200105( data )
    -- body
    if data.status == 0 then
        local id = data.skinId
        if data.reqType == 1 then
            local var = cache.PlayerCache:getSkins(Skins.huoban)
            local info = conf.HuobanConf:getSkinsByModel(var,0)
            id = info.id
        end
        local name = cache.HuobanCache:getName(id)
        if name and name~="" then
        else
            local confdata = conf.HuobanConf:getSkinsByIndex(id,0)
            name = confdata.name
        end
        cache.PlayerCache:setPetName(name)
        gRole:addRolePet() --刷新一下


        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view.BtnFight:checkHuoban()
        end

        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            view:addMsgCallBack(data)
        end
        local view2 = mgr.ViewMgr:get(ViewName.VipExperienceView)
        if view2 then
            view2:setBtnState()
        end
    else
        GComErrorMsg(data.status)
    end
end

function HuobanProxy:add5200106( data )
    -- body
    if data.status == 0 then
        cache.HuobanCache:setName(data.skinId, data.name)
        local confdata = conf.HuobanConf:getSkinsByIndex(data.skinId, 0)
        if confdata.modle_id == cache.PlayerCache:getSkins(Skins.huoban) then
            cache.PlayerCache:setPetName(data.name)
            gRole:addRolePet() --刷新一下
        end

        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function HuobanProxy:add5200107( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--伙伴吞噬装备升级
function HuobanProxy:add5200201( data )
    -- body
    if data.status == 0 then
        --print("吞噬伙伴",data.reqType)
        if data.reqType == 1 then --伙伴吞噬升级成功刷新红点
            if not GCheckTunShiEquip() then
                local var = cache.PlayerCache:getRedPointById(10211)
                cache.PlayerCache:setRedpoint(10211, var - 1)
                local mainView = mgr.ViewMgr:get(ViewName.MainView)
                if mainView then
                    mainView:refreshRedBottom()
                end
                mgr.GuiMgr:updateRedPointPanels(10211)
            end
            -- local equipData = GGetEquipData()
            -- local useData = {}
            -- for k,v in pairs(equipData) do
            --     if v.color < 5 then
            --         table.insert(useData,v)
            --     end
            -- end
            -- -- print("剩余可吞装备数量",#useData)
            -- if #useData == 0 then
            --     -- local var = cache.PlayerCache:getRedPointById(10211)
            --     -- cache.PlayerCache:setRedpoint(10211, var-1)
            --     -- -- print("伙伴红点值",cache.PlayerCache:getRedPointById(10211))
            --     -- local mainView = mgr.ViewMgr:get(ViewName.MainView)
            --     -- if mainView then
            --     --     mainView:refreshRedBottom()
            --     -- end
            --     -- mgr.GuiMgr:updateRedPointPanels(10211)
            -- end
        end
        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            data.msgId = 5200201
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.HuobanExpPop)
        if view then
            --飘字获得经验
            local addExp = view:getAddExp()
            local str = language.getDec4 .. addExp
            GComAlter(str)
            view:onCloseView()
        end

    else
        GComErrorMsg(data.status)
    end
end

function HuobanProxy:add5210105( data )
    -- body
    if data.status == 0 then
        --[[local confData = conf.ZuoQiConf:getHourSkin(data.skinId)
        local modelid = confData.modle_id
        gRole:handlerMount(ResPath.mountRes(modelid))]]--

        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function HuobanProxy:add5220105( data )
    -- body
    if data.status == 0 then
        --[[local confData = conf.ZuoQiConf:getHourSkin(data.skinId)
        local modelid = confData.modle_id
        gRole:handlerMount(ResPath.mountRes(modelid))]]--

        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function HuobanProxy:add5230105( data )
    -- body
    if data.status == 0 then
        --[[local confData = conf.ZuoQiConf:getHourSkin(data.skinId)
        local modelid = confData.modle_id
        gRole:handlerMount(ResPath.mountRes(modelid))]]--

        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function HuobanProxy:add5240105( data )
    -- body
    if data.status == 0 then
        --[[local confData = conf.ZuoQiConf:getHourSkin(data.skinId)
        local modelid = confData.modle_id
        gRole:handlerMount(ResPath.mountRes(modelid))]]--

        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


return HuobanProxy