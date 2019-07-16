--
-- Author: wx
-- Date: 2017-07-19 14:58:06
--

local MarryProxy = class("MarryProxy",base.BaseProxy)

function MarryProxy:init()
    self:add(5390101,self.add5390101)-- 请求赠送鲜花
    self:add(5390102,self.add5390102)-- 请求求婚
    self:add(5390103,self.add5390103)-- 请求求婚处理
    self:add(5390104,self.add5390104)-- 请求离婚
    self:add(5390105,self.add5390105)-- 请求协议离婚处理
    self:add(5390106,self.add5390106)-- 请求爱情盒购买信息
    self:add(5390107,self.add5390107)-- 请求异性玩家列表
    self:add(5390108,self.add5390108)-- 请求异性在线玩家列表

    self:add(5390201,self.add5390201)-- 请求姻缘信息
    self:add(5390202,self.add5390202)-- 请求婚戒升级
    self:add(5390203,self.add5390203)-- 请求情缘升级
    self:add(5390204,self.add5390204)-- 请求姻缘树升级

    self:add(5390301,self.add5390301)

    self:add(5390302,self.add5390302)--请求预约婚礼返回
    self:add(5390303,self.add5390303)--请求宾客列表
    self:add(5390304,self.add5390304)--请求祝福信息
    self:add(5390305,self.add5390305)-- 请求伴侣信息
    self:add(5390306,self.add5390306)--请求索要请柬
    self:add(5390307,self.add5390307)--请求拜堂
    self:add(5390308,self.add5390308)--请求婚宴经验获取
    self:add(5390309,self.add5390309)--请求婚宴场景信息

    self:add(5810303,self.add5810303)--请求场景姻缘树操作

    self:add(8170101,self.add8170101)-- 求婚广播
    self:add(8170102,self.add8170102)-- 赠送鲜花广播
    self:add(8170103,self.add8170103)

    self:add(5027101,self.add5027101)-- 请求情缘副本信息
    self:add(5027102,self.add5027102)-- 请求情缘副本进入挑战
    self:add(5027103,self.add5027103)-- 请求情缘副本另一方同意挑战
    self:add(5027104,self.add5027104)-- 请求情缘副本奖励领取
    self:add(5027105,self.add5027105)-- 请求情缘系统任务追踪信息

    self:add(8180101,self.add8180101)-- 情缘副本挑战通知另一方广播
    self:add(8180102,self.add8180102)-- 情缘副本结算广播
    self:add(8180103,self.add8180103)-- 情缘副本任务广播
    self:add(8190101,self.add8190101)--姻缘树操作广播
    self:add(8170105,self.add8170105)--婚宴热度进度广播
    self:add(8170106,self.add8170106)--拜堂广播广播
    self:add(8170107,self.add8170107)--婚礼个人数据广播

    self:add(5390501,self.add5390501)-- 请求洞房
    self:add(5390502,self.add5390502)-- 请求仙童选择
    self:add(5390601,self.add5390601)-- 请求仙童信息
    self:add(5390602,self.add5390602)-- 请求仙童升阶
    self:add(5390603,self.add5390603)--  请求仙童装备升级
    self:add(5390604,self.add5390604)--  请求仙童天赋升级
    self:add(5390605,self.add5390605)--  请求仙童技能学习
    self:add(5390606,self.add5390606)--  请求仙童出战
    self:add(5390607,self.add5390607)--  请求仙童寄送
    self:add(5390608,self.add5390608)--  请求仙童改名
    self:add(5390609,self.add5390609)--  请求仙童成长值重置
    self:add(5390610,self.add5390610)--  请求仙童阵位信息
    self:add(5390611,self.add5390611)--  请求开启仙童阵位

    self:add(8170201,self.add8170201)--  洞房广播
    self:add(8170202,self.add8170202)--  仙童选择广播
    self:add(8170203,self.add8170203)--  仙童战力广播
end

function MarryProxy:sendMsg(msgId,param,inquireType)
    -- body
    self.param = param
    self.inquireType = inquireType or 0 --伴侣信息查询类型
    self:send(msgId,param)
end

function MarryProxy:add5390101(data)
    -- body
    if data.status == 0 then
        if self.param and self.param.mid and self.param.amount then
            if self.param.source == 0 then 
                local qm = conf.ItemConf:getItemExt(self.param.mid)
                GComAlter(string.format(language.kuafu111,qm*self.param.amount) )
            else
                GComAlter(language.flower14)
            end

        end
        local view = mgr.ViewMgr:get(ViewName.FlowerRank)--刷新鲜花榜bxp
        if view then 
            local actIdTable = {1089,1090,5003,5011}
            local actId
            for _,v in pairs(actIdTable) do
                local data = cache.ActivityCache:get5030111()
                if data.acts[v] and data.acts[v] == 1 then 
                    actId = v
                    break
                end
            end
            if actId == 5011 then
                proxy.ActivityProxy:sendMsg(1030327)
            else
                proxy.ActivityProxy:sendMsg(1030320,{actId = actId})
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
-- 请求求婚
function MarryProxy:add5390102(data)
    -- body
    if data.status == 0 then
        
    else
        GComErrorMsg(data.status)
    end
end
-- 请求求婚处理
function MarryProxy:add5390103(data)
    -- body
    if data.status == 0 then
        if data.reply == 1 then
            cache.MarryCache:clearRespons()
            proxy.MarryProxy:sendMsg(1390305,nil,1)
            GOpenAlert3(data.items)
        else
            cache.MarryCache:deleteData()
            local view = mgr.ViewMgr:get(ViewName.MarryRespons)
            if view then
                view:closeView()
            end
        end
    else
        cache.MarryCache:deleteData()
        local view = mgr.ViewMgr:get(ViewName.MarryRespons)
        if view then
            view:closeView()
        end
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add5390104(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryLihunTips)
        if data.reqType == 3 then
            mgr.ViewMgr:openView2(ViewName.MarryLihunTips, data)
        elseif data.reqType == 1 then
            if view then
                view:closeView()
            end
        elseif data.reqType == 2 then
            if view then
                view:closeView()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add5390105(data)
    -- body
    if data.status == 0 then
        
    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add5390106(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add5390107(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
-- 请求异性在线玩家列表
function MarryProxy:add5390108(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryApplyView)
        if view then
            view:add5390108(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求祝福信息
function MarryProxy:add5390304(data)
    if data.status == 0 then
        if data.items and #data.items > 0 then
            GOpenAlert3(data.items)
        end
        local view = mgr.ViewMgr:get(ViewName.MarryWishView)
        if view then
            view:initData(data)
        else
            mgr.ViewMgr:openView2(ViewName.MarryWishView,data)
        end
    else
        GComErrorMsg(data.status)
    end
end
-- 请求伴侣信息
function MarryProxy:add5390305(data)
    if data.status == 0 then
        if self.inquireType == 1 then
            local view = mgr.ViewMgr:get(ViewName.MarryRespons)
            --print("555555555555",view)
            if view then
                view:initData({index = 1,coupleData = data})
            else
                mgr.ViewMgr:openView2(ViewName.MarryRespons,{index = 1,coupleData = data})
            end
        elseif self.inquireType == 2 then
            mgr.ViewMgr:openView2(ViewName.MarryRespons,{index = 2,coupleData = data})
        elseif self.inquireType == 3 then
            -- local view = mgr.ViewMgr:get(ViewName.MarryWishView)
            -- if view then
            --     view:setUserInfo(data)
            -- end
        elseif self.inquireType == 4 then
            local view = mgr.ViewMgr:get(ViewName.MarryApplyView)
            if view then
                view:setIcon(data)
            end
        elseif self.inquireType == 5 then
            mgr.ViewMgr:openView2(ViewName.MarryRespons,{index = 1,childIndex = 1,coupleData = data})
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求预约婚礼返回
function MarryProxy:add5390302(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryAppointment)
        if view then
            view:initData(data)
        else
            mgr.ViewMgr:openView2(ViewName.MarryAppointment,data)
        end
        if data.reqType == 1 then
            cache.MarryCache:setAppointmentData(data.mine)
            proxy.MarryProxy:sendMsg(1390305,nil,2)
        end
    elseif data.status == 2300028 or data.status == 2300037 or data.status == 2230003 then
        GComErrorMsg(data.status)
        proxy.MarryProxy:sendMsg(1390302,{reqType = 0})
    else
        GComErrorMsg(data.status)
    end
end
--请求宾客列表
function MarryProxy:add5390303( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryInviteView)
            -- print("邀请类型",data.reqType)
        if view then
            view:setData(data)
            view:refreshRed(data.reqType)
        else
            mgr.ViewMgr:openView(ViewName.MarryInviteView,function(view)
                view:setData(data)
            end)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求索要请柬
function MarryProxy:add5390306(data)
    if data.status == 0 then
        if data.reqType == 1 then
            GComAlter(language.marryiage58)
        end
        local view = mgr.ViewMgr:get(ViewName.MarryLuckyView)
        if view then
            view:initData(data)
        else
            mgr.ViewMgr:openView2(ViewName.MarryLuckyView,data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求拜堂
function MarryProxy:add5390307(data)
    if data.status == 0 then
        
    else
        GComErrorMsg(data.status)
    end
end
--请求婚宴经验获取
function MarryProxy:add5390308(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.WeddingView)
        if view then
            view:refreshExp(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求婚宴场景信息
function MarryProxy:add5390309(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.WeddingView)
        if view then
            view:initData(data)
        else
            mgr.ViewMgr:openView2(ViewName.WeddingView,data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add5390201(data)
    -- body
    if data.status == 0 then
        cache.MarryCache:setJHdata(data)
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add5390202(data)
    -- body
    if data.status == 0 then
        cache.MarryCache:setJHlv(data)
        cache.PlayerCache:setDataJie(1313,data.ringLev)

        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
        if gRole then
            gRole.data.skins[Skins.hunjie] = data.ringLev
            gRole:setHunJie()
            gRole:setChenghao()
        end
    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add5390203(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--姻缘树
function MarryProxy:add5390204(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


function MarryProxy:add8170101( data )
    -- body
    if data.status == 0 then
        print("求婚广播")
        cache.MarryCache:insertData(data)
        local view = mgr.ViewMgr:get(ViewName.MarryRespons)
        if not view then
            mgr.ViewMgr:openView2(ViewName.MarryRespons,{index = 0})
        end
    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add8170102( data )
    -- body
    if data.status == 0 then
        local effectId 
        local t = conf.MarryConf:getValue("flower_list")
        for k ,v in pairs(t) do
            if tonumber(v[1])  == data.mid then
                effectId = v[3]
                break
            end
        end
        if effectId then
            local view = mgr.ViewMgr:get(ViewName.Alert15)
            if view then
                view:initData(effectId)
            else
                mgr.ViewMgr:openView2(ViewName.Alert15, effectId)
            end
        else
            plog("这个花没有配置在表marry_global字段flower_list")
        end
        --收到
        --printt(data)
        if data.tarRoleId == cache.PlayerCache:getRoleId() then
            local param = {}
            param.type = 2
            param.richtext = string.format(language.kuafu113,data.roleName
            ,data.amount,conf.ItemConf:getName(data.mid),
            data.amount*conf.ItemConf:getItemExt(data.mid))
            param.sure = function()
                -- body
                local data = {roleId = data.roleId,roleName = data.roleName}
                mgr.ViewMgr:openView2(ViewName.MarrySongHuaView,data)
            end
            param.sureIcon = "ui://alert/gonggongsucai_130"
            param.cancelIcon = "ui://alert/gonggongsucai_129"
            GComAlter(param)
        end
    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add8170103(data)
    -- body
    if data.status == 0 then
        --printt("8170103",data)
        if data.result == 1 then --求婚成功 
            --放个结婚特效
            -- local condata = conf.NpcConf:getNpcById(NPCGLOBAL.marry)
            -- mgr.JumpMgr:roleMovie(condata,function()
            --     -- body
            -- end)
            --放个特效
            mgr.ViewMgr:openView2(ViewName.Alert15,4020127)

            if data.reqName == cache.PlayerCache:getRoleName() then
                cache.PlayerCache:setCoupleName(data.rspName)
                proxy.MarryProxy:sendMsg(1390305,nil,1)
            else
                cache.PlayerCache:setCoupleName(data.reqName)
            end
            cache.PlayerCache:setCoupleGrade(data.grade)
            --刷新一下人物头顶信息
            if gRole then
                gRole:setCoupleName(gRole.data)
            end

            local view = mgr.ViewMgr:get(ViewName.MarryMainView)
            if view then
                view:initData()
            end

        elseif data.result == 2 then --拒绝求婚
            local param = {}
            param.type = 5
            param.richtext = string.format(language.kuafu45,data.rspName)
            GComAlter(param)
        elseif data.result == 3 then --离婚了
            --清理伴侣名字
            cache.PlayerCache:setCoupleName("")
            cache.PlayerCache:setCoupleGrade(0)
            local view = mgr.ViewMgr:get(ViewName.MarryLihunTips)
            if view then
                view:closeView()
            end
            local view1 = mgr.ViewMgr:get(ViewName.MarryApplyView)
            if view1 then
                view1:closeView()
            end
            --刷新一下人物头顶信息
            if gRole then
                gRole:setCoupleName(gRole.data)
            end
            
            --红点清理
            mgr.GuiMgr:redpointByID(10244)
            mgr.GuiMgr:redpointByID(attConst.A10247)
            GComAlter(language.kuafu86)
        elseif data.result == 4 then --豪华婚礼单服 广播
            --放个特效
            mgr.ViewMgr:openView2(ViewName.Alert15,4020127)
        end
    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add5027101(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add5027102(data)
    if data.status == 0 then
        GComAlter(language.kaifu51)
    else
        GComErrorMsg(data.status)
    end
end
--请求情缘副本另一方同意挑战
function MarryProxy:add5027103(data)
    -- body
    if data.status == 0 then
        
    else
        GComErrorMsg(data.status)
    end
end
--请求情缘副本奖励领取
function MarryProxy:add5027104(data)
    -- body
    if data.status == 0 then
        -- GOpenAlert3(data.items)
        -- local view = mgr.ViewMgr:get(ViewName.MarryFubenDekaron)
        -- if view then
        --     view:closeView()
        -- end
        mgr.FubenMgr:quitFuben()
    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add5027105(data)
    if data.status == 0 then
        cache.MarryCache:setFubenCTime(data.createTime)
        local sId = cache.PlayerCache:getSId()
        local passId = sId * 1000 + 1
        cache.FubenCache:setCurrPass(sId,passId)
        cache.MarryCache:setFubenData(data)
        local t = {index = 4}
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setData(t)
        else
            mgr.ViewMgr:openView2(ViewName.TrackView, t)
        end
        mgr.HookMgr:enterHook()
    else
        GComErrorMsg(data.status)
    end
end
--情缘副本挑战通知另一方广播
function MarryProxy:add8180101(data)
    if data.status == 0 then
        if data.reqType == 1 then
            if data.tarRoleId == cache.PlayerCache:getRoleId() then
                local param = {}
                param.type = 2
                param.richtext = string.format(language.kuafu64, data.tarName)
                param.sure = function()
                    -- body
                    proxy.MarryProxy:sendMsg(1027103,{reqType = 1})
                end
                param.cancel = function()
                    -- body
                    proxy.MarryProxy:sendMsg(1027103,{reqType = 2})
                end
                GComAlter(param)
            end
        else
            --plog(data.tarRoleId,cache.PlayerCache:getRoleId())
            if data.tarRoleId == cache.PlayerCache:getRoleId() then
               GComAlter(language.kuafu65) 
            end
        end
    else
        GComErrorMsg(data.status)
    end
end
--情缘副本结算广播
function MarryProxy:add8180102(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:endMarryTime()
        end
        mgr.ViewMgr:openView2(ViewName.MarryFubenDekaron, data)
    else
        GComErrorMsg(data.status)
    end
end
--情缘副本任务广播
function MarryProxy:add8180103(data)
    if data.status == 0 then
        cache.MarryCache:setFubenData(data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setMarryData()
        end
    else
        GComErrorMsg(data.status)
    end
end
--姻缘树操作广播
function MarryProxy:add8190101(data)
    if data.status == 0 then
        local optType = data.optType
        if optType == 0 then--查看
            mgr.ViewMgr:openView2(ViewName.TreeTipView, data)
        else
            local count = 0
            for k,v in pairs(data.optTimesMap) do
                count = count + v
            end
            local tree = mgr.ThingMgr:getObj(ThingType.monster, data.treeRoleId)
            if tree then
                tree:setTreeCont(count)
                tree:addTreeEffect()
            end
            local coupleName = cache.PlayerCache:getCoupleName()
            if data.attachName == coupleName or data.attachName == cache.PlayerCache:getRoleName() then
                GComAlter(language.marryiage15[optType])
            end
        end

    else
        GComErrorMsg(data.status)
    end
end
--add8170105
function MarryProxy:add8170105(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.WeddingView)
        if view then
            view:refreshHot(data)
        end
    else
        GComErrorMsg(data.status) 
    end
end
--拜堂广播
function MarryProxy:add8170106( data )
    if data.status == 0 then
        if data.type == 1 then
            local param = {}
            param.type = 2
            param.richtext = language.marryiage42
            param.sure = function()
                -- body
                proxy.MarryProxy:sendMsg(1390307,{reqType = 2})
            end
            param.cancel = function()
                proxy.MarryProxy:sendMsg(1390307,{reqType = 3})
            end
            GComAlter(param)
        elseif data.type == 2 then
            GComAlter(language.marryiage43)
        elseif data.type == 3 then
            mgr.ViewMgr:openView2(ViewName.Alert15,4020129)
            -- GComAlter("该播动画特效了")
        end
    else
        GComErrorMsg(data.status)
    end
end
--婚礼个人数据广播
function MarryProxy:add8170107( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.WeddingView)
        if view then
            if data.type == 1 then
                local view = mgr.ViewMgr:get(ViewName.Alert15)
                if view then
                    view:closeView()
                end
                mgr.ViewMgr:openView2(ViewName.Alert15,4020149)
            end
                view:refreshJoyful(data)
            -- else
                view:refreshBanquetCount(data)
            -- end
        end
    else
        GComErrorMsg(data.status) 
    end
end

function MarryProxy:add5390301( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryKaiFuRank)
        if view then
            view:add5390301(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add5810303(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TreeTipView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--------------------仙童
function MarryProxy:add5390501( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XianTongtfhz)
        if view then
            view:addMsgCallBack(data) 
        end
    else
        GComErrorMsg(data.status)
    end
end
function MarryProxy:add5390502( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XianTongchoose)
        if view then
            view:addMsgCallBack(data,self.param) 
        else
            mgr.ViewMgr:openView2(ViewName.GuideZuoqi,{index = 16,mid = self.param.mid})
        end
    else
        GComErrorMsg(data.status)
    end
    
end

function MarryProxy:add5390601( data )
    -- body
    if data.status == 0 then
        cache.MarryCache:setXTData(data)
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
        proxy.MarryProxy:sendMsg(1390610,{reqType = 0})
    else
        GComErrorMsg(data.status)
    end
end
function MarryProxy:add5390602( data )
    -- body
    if data.status == 0 then
        cache.MarryCache:setXTlevel(data)
        cache.MarryCache:setXTTianfu(data)
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function MarryProxy:add5390603( data )
    -- body
    if data.status == 0 then
        cache.MarryCache:setXTEquip(data)
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XianTongEquipUp)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function MarryProxy:add5390604( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function MarryProxy:add5390605( data )
    -- body
    if data.status == 0 then
        cache.MarryCache:setXTskill(data)
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XianTongSkillView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function MarryProxy:add5390606( data )
    -- body
    if data.status == 0 then
        cache.MarryCache:setCurpetRoleId(data.xtRoleId)
        if gRole then
            local pet = mgr.ThingMgr:getObj(ThingType.pet, gRole:getXianTonID())
            if pet then
                local info = cache.MarryCache:getgetXTDataByRoleId(data.xtRoleId)
                if info then
                    pet:updtePetName(info.name)
                end  
            end
        end

        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function MarryProxy:add5390607( data )
    -- body
    if data.status == 0 then
        cache.MarryCache:deleteXT(data)

        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
        GOpenAlert3(data.items)
    else
        GComErrorMsg(data.status)
    end
end
function MarryProxy:add5390608( data )
    -- body
    if data.status == 0 then
        cache.MarryCache:setXTName(data)
        if gRole then
            local pet = mgr.ThingMgr:getObj(ThingType.pet, gRole:getXianTonID())
            if pet then
                local info = cache.MarryCache:getgetXTDataByRoleId(data.xtRoleId)
                if info then
                    pet:updtePetName(info.name)
                end  
            end
        end

        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function MarryProxy:add5390609( data )
    -- body
    if data.status == 0 then
        cache.MarryCache:setXTgrowValue(data)
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XianTongGrowView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙童阵位信息
function MarryProxy:add5390610(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XianTongOnHelp)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求开启仙童阵位
function MarryProxy:add5390611(data)
    if data.status == 0 then
        -- proxy.MarryProxy:sendMsg(1390610,{reqType = 0})
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.XianTongOnHelp)
        if view then
            view:addMsgCallBack(data)
        end

    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add8170201( data )
    -- body
    if data.status == 0 then
        --printt("add8170201",data)
       
        if data.dfType == 0 then
            --请求洞房 
            if data.roleId ~= cache.PlayerCache:getRoleId() then
                local view = mgr.ViewMgr:get(ViewName.XianTongTongFang)
                if view then
                    view:initData({index = 0,data = data})
                else
                    mgr.ViewMgr:openView2(ViewName.XianTongTongFang,{index = 0,data = data})
                end
            end
            
        elseif data.dfType == 1 then
            --同意 
            --避免切换场景
            if not mgr.FubenMgr:checkScene() then
                mgr.TaskMgr:stopTask()
            end
            
            --获得奖励 
            --获得的奖励里面有没有仙
            cache.MarryCache:setAwardId(data.awardId)

            local info = {}
            info.id = 4020169
            info.callback = function()
                -- body
                local flag = data.awardId > 2000
                if flag then
                    mgr.ViewMgr:openView2(ViewName.XianTongchoose,data.roleId)
                else
                    mgr.ViewMgr:openView2(ViewName.XianTongTongFang,{index = 1,data = data})
                end
            end
            mgr.ViewMgr:openView2(ViewName.Alert15,info)

            
        elseif data.dfType == 2 then
            --拒绝
            if data.roleId ~= cache.PlayerCache:getRoleId() then
                GComAlter(language.xiantong12)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function MarryProxy:add8170202( data )
    -- body
    if data.status == 0 then
        --printt("add8170202",data)
        local view = mgr.ViewMgr:get(ViewName.XianTongchoose)
        if view then
            view:addMsgCallBack(data)
        else
            mgr.ViewMgr:openView2(ViewName.GuideZuoqi,{index = 16,mid = data.mid})
        end
    else
        GComErrorMsg(data.status)
    end
end
function MarryProxy:add8170203( data )
    -- body
    if data.status == 0 then
        --printt("8170203 ",data)
        cache.MarryCache:setXTPower(data)
        local view = mgr.ViewMgr:get(ViewName.MarryMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
return MarryProxy