--
-- Author: 
-- Date: 2017-02-14 17:46:01
--

local ZuoQiProxy = class("ZuoQiProxy",base.BaseProxy)

function ZuoQiProxy:init()
    -- self:add(5010101,self.resLogin)
    self:add(5120101,self.add5120101)--请求坐骑信息
    self:add(5120102,self.add5120102)--请求坐骑升级
    self:add(5120103,self.add5120103)--请求坐骑装备升级
    self:add(5120104,self.add5120104)--请求坐骑技能升级
    self:add(5120105,self.add5120105)--请求坐骑皮肤改变
    self:add(5120201,self.add5120201)-- 请求坐骑骑乘

    self:add(5140101,self.add5140101)-- 请求仙羽信息
    self:add(5140102,self.add5140102)--  请求仙羽进阶
    self:add(5140103,self.add5140103)--  请求仙羽装备升级
    self:add(5140104,self.add5140104)--  请求仙羽装备升级
    self:add(5140105,self.add5140105)--  请求仙羽

    self:add(5160101,self.add5160101)-- 请求神兵信息
    self:add(5160102,self.add5160102)--  请求神兵进阶
    self:add(5160103,self.add5160103)--  请求神兵装备升级
    self:add(5160104,self.add5160104)--  请求神兵装备升级
    self:add(5160105,self.add5160105)--  请求神兵

    self:add(5170101,self.add5170101)-- 请求神兵信息
    self:add(5170102,self.add5170102)--  请求神兵进阶
    self:add(5170103,self.add5170103)--  请求神兵装备升级
    self:add(5170104,self.add5170104)--  请求神兵装备升级
    self:add(5170105,self.add5170105)--  请求神兵装备升级

    self:add(5180101,self.add5180101)-- 请求神兵信息
    self:add(5180102,self.add5180102)--  请求神兵进阶
    self:add(5180103,self.add5180103)--  请求神兵装备升级
    self:add(5180104,self.add5180104)--  请求神兵装备升级
    self:add(5180105,self.add5180105)--  请求神兵装备升级

    self:add(8050401,self.add8050401)--祝福值提示广播
    self:add(8020207,self.add8020207)--临时属性广播

    self:add(5560101,self.add5560101)--  请求麒麟臂信息
    self:add(5560102,self.add5560102)--   请求麒麟臂进阶
    self:add(5560103,self.add5560103)--   请求麒麟臂装备升级
    self:add(5560104,self.add5560104)--   请求麒麟臂技能升级
    self:add(5560105,self.add5560105)--    请求麒麟臂幻形
end

function ZuoQiProxy:add5120101(data)
    -- body
    if data.status == 0 then
        --plog("add5120101")
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
            --异常情况
            if data.lev == 0 then
                self:send(1120102,{auto = 0})
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5120102( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:setAuto(false)
        end
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5120103( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiEquipUp)
        if view then
            view:add5120103(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5120104( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiSkillUp)
        if view then
            view:add5120104(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--  请求坐骑皮肤改变
function ZuoQiProxy:add5120105( data )
    -- body
    if data.status == 0 then
        
        -- local confData = conf.ZuoQiConf:getSkinsByIndex(data.skinId,0)
        -- local modelid = confData.modle_id
        -- if gRole:isMount() then
        --     gRole:handlerMount(ResPath.mountRes(modelid))
        -- end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function ZuoQiProxy:add5120201( data )
    -- body
    if data.status == 0 then
    else
        GComErrorMsg(data.status)
    end
end



--------------------------限于 ------------------------------

function ZuoQiProxy:add5140101(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5140102(data)
    -- body
    if data.status == 0 then
        --plog("add5140102",add5140102)
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:setAuto(false)
        end
        GComErrorMsg(data.status)
    end
end
function ZuoQiProxy:add5140103( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiEquipUp)
        if view then
            view:add5120103(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5140104( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiSkillUp)
        if view then
            view:add5140104(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5120104( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiSkillUp)
        if view then
            view:add5120104(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--   请求仙羽幻形
function ZuoQiProxy:add5140105( data )
    -- body
    if data.status == 0 then
        --cache.PlayerCache:setSkins(3,data.skinId)
        -- local confData = conf.ZuoQiConf:getSkinsByIndex(data.skinId,3)
        -- gRole:setSkins(nil,nil,confData.modle_id)

        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

-------------------------------------------神兵

function ZuoQiProxy:add5160101(data)
    -- body
    if data.status == 0 then
        --plog("dddddddddd ,add5160101, ,add5160101")
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5160102(data)
    -- body
    if data.status == 0 then
        --plog("add5140102",add5140102)
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:setAuto(false)
        end
        GComErrorMsg(data.status)
    end
end
function ZuoQiProxy:add5160103( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiEquipUp)
        if view then
            view:add5160103(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5160104( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiSkillUp)
        if view then
            view:add5160104(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--   请求仙羽幻形
function ZuoQiProxy:add5160105( data )
    -- body
    if data.status == 0 then
        --cache.PlayerCache:setSkins(5,data.skinId)
        --local confData = conf.ZuoQiConf:getSkinsByIndex(data.skinId,1)
        --gRole:
        --gRole:setSkins(nil,confData.modle_id,nil)
        --gRole:updateWeaponEct(confData.modle_id)
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


-------------------------------------------发宝

function ZuoQiProxy:add5170101(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5170102(data)
    -- body
    if data.status == 0 then
        --plog("add5140102",add5140102)
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:setAuto(false)
        end
        GComErrorMsg(data.status)
    end
end
function ZuoQiProxy:add5170103( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiEquipUp)
        if view then
            view:add5170103(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5170104( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiSkillUp)
        if view then
            view:add5170104(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--   请求仙羽幻形
function ZuoQiProxy:add5170105( data )
    -- body
    if data.status == 0 then
        --cache.PlayerCache:setSkins(6,data.skinId)
        local confData = conf.ZuoQiConf:getSkinsByIndex(data.skinId,2)
        gRole:addFaBao(confData.modle_id)

        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

-------------------------------------------请求仙器信息

function ZuoQiProxy:add5180101(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5180102(data)
    -- body
    if data.status == 0 then
        --plog("add5140102",add5140102)
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:setAuto(false)
        end
        GComErrorMsg(data.status)
    end
end
function ZuoQiProxy:add5180103( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiEquipUp)
        if view then
            view:add5180103(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5180104( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiSkillUp)
        if view then
            view:add5180104(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--   请求仙羽幻形
function ZuoQiProxy:add5180105( data )
    -- body
    if data.status == 0 then
        --cache.PlayerCache:setSkins(7,data.skinId)
        --local confData = conf.ZuoQiConf:getSkinsByIndex(data.skinId,4)
        --gRole:addXianQi(confData.modle_id)

        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--祝福值提示广播
function ZuoQiProxy:add8050401(data)
    if data.status == 0 then
        cache.ZuoQiCache:setBlessTipData(data)
    else
        GComErrorMsg(data.status)
    end
end
--临时属性广播
function ZuoQiProxy:add8020207(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
        -- print("临时属性广播",view.zuoqiJie)
            if view.zuoqiJie and view.zuoqiJie.data then
                view.zuoqiJie:initTempAttris(data.attris)
            end
        end
        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if view then
            if view.HuoBanJie and view.HuoBanJie.data then
                view.HuoBanJie:initTempAttris(data.attris)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--麒麟臂

--------------------------限于 ------------------------------

function ZuoQiProxy:add5560101(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5560102(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:setAuto(false)
        end
        GComErrorMsg(data.status)
    end
end
function ZuoQiProxy:add5560103( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiEquipUp)
        if view then
            view:add5560103(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ZuoQiProxy:add5560104( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiSkillUp)
        if view then
            view:add5560104(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--   请求仙羽幻形
function ZuoQiProxy:add5560105( data )
    -- body
    if data.status == 0 then
        --cache.PlayerCache:setSkins(3,data.skinId)
        -- local confData = conf.ZuoQiConf:getSkinsByIndex(data.skinId,3)
        -- gRole:setSkins(nil,nil,confData.modle_id)
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


return ZuoQiProxy