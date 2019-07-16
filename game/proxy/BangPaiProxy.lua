--
-- Author: 
-- Date: 2017-03-03 16:54:33
--

local BangPaiProxy = class("BangPaiProxy",base.BaseProxy)

function BangPaiProxy:init()
    -- self:add(5010101,self.resLogin)
    self:add(5250101,self.add5250101)-- 请求创建帮派
    self:add(5250102,self.add5250102)-- 请求搜索帮派列表
    self:add(5250201,self.add5250201)-- 请求申请加入帮派
    self:add(5250104,self.add5250104)-- 请求帮派信息
    self:add(5250103,self.add5250103)-- 请求帮派成员列表
    self:add(5250202,self.add5250202)-- 请求同意申请加入帮派
    self:add(5250203,self.add5250203)-- 请求逐出帮派
    self:add(5250204,self.add5250204)-- 请求退出帮派
    self:add(5250205,self.add5250205)-- 请求禅让帮主
    self:add(5250207,self.add5250207)-- 请求设定帮派职位
    self:add(5250208,self.add5250208)-- 请求设置自动招人条件
    self:add(5250209,self.add5250209)-- 请求世界喊话招人
    self:add(5250301,self.add5250301)-- 请求帮派签到
    self:add(5250105,self.add5250105)-- 请求帮派申请列表
    self:add(5250210,self.add5250210)-- 请求弹劾帮主
    self:add(5250302,self.add5250302)-- 请求帮派商店
    self:add(5250106,self.add5250106)-- 请求帮派日志
    self:add(5250108,self.add5250108)-- 请求帮派周资金榜
    self:add(5250107,self.add5250107)-- 请求帮派技能
    self:add(5250303,self.add5250303)-- 请求帮派仓库
    self:add(5250304,self.add5250303)-- 请求帮派仓库整理
    self:add(5250305,self.add5250305)-- 请求帮派仓库存取
    self:add(5250306,self.add5250306)-- 请求帮派仓库存取记录
    self:add(5250206,self.add5250206)-- 修改公告
    self:add(5250307,self.add5250307)-- 请求帮派宝箱列表
    self:add(5250309,self.add5250309)-- 请求开启帮派宝箱
    self:add(5250308,self.add5250308)-- 请求刷新帮派宝箱品质
    self:add(5250310,self.add5250310)-- 请求领取宝箱奖励(包含额外奖励)
    self:add(5250313,self.add5250313)-- 请求聊天邀请帮派成员协助宝箱
    self:add(5250312,self.add5250312)-- 请求协助帮派成员宝箱开启
    self:add(5250314,self.add5250314)-- 请求帮派宝箱协助记录
    self:add(5250311,self.add5250311)-- 请求帮派宝箱协助列表
    self:add(5250405,self.add5250405)--  请求升级帮派为VIP帮派
    self:add(5250406,self.add5250406)--   请求邀请玩家进仙盟
    self:add(5250407,self.add5250407)--   请求回复帮派邀请
    self:add(5250408,self.add5250408)--请求装备销毁
    self:add(5250502,self.add5250502)--请求仙盟BOSS信息
    self:add(5250504,self.add5250504)--请求仙盟BOSS喂养
    self:add(5250501,self.add5250501)--请求仙盟圣火信息
    self:add(5250503,self.add5250503)--请求仙盟圣火添柴
    self:add(5250505,self.add5250505)--请求仙盟圣火答题
    self:add(5250506,self.add5250506)--请求仙盟圣火抛骰子
    self:add(5250507,self.add5250507)--请求仙盟圣火修炼池
    self:add(5250601,self.add5250601)-- 请求仙盟科技
    self:add(5250701,self.add5250701)-- 请求仙盟合入


    self:add(8060101,self.add8060101)--帮派广播
    self:add(8160102,self.add8160102)-- 仙盟邀请广播
    self:add(8210101,self.add8210101)--仙盟圣火活动信息广播
    self:add(8060102,self.add8060102)--仙盟合入广播
end

function BangPaiProxy:sendMsg(msgId, param)
    -- body
    --plog(msgId)
    --printt(param)
    self:send(msgId,param)
end
--param = {index = index,amount = amount,reqType = reqType}
function BangPaiProxy:send1250305(param,itemData)
    self.itemData = itemData--要存取的道具
    self:sendMsg(1250305,param)
end

function BangPaiProxy:add5250101(data)
    -- body
    if data.status == 0 then
        --创建成功
        --self:sendMsg(1250104) --请求帮派信息
        --printt("创建成功",data)
        cache.PlayerCache:setGangId(data.gangId)
        cache.PlayerCache:setGangName(data.gangName)
        GOpenView({id = 1013,index = 0})

        cache.BangPaiCache:setTaskReset(true)
        proxy.TaskProxy:send(1050101)
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250102( data )
    -- body
    if data.status == 0 then
        if data.page == 1 and #data.gangList == 0 then
            GComAlter(language.bangpai17)
        end

        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.BangPaiFind)
        if view then
            view:add1250102(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250201(data)
    -- body
    if data.status == 0 then
        --plog("6666")
        GComAlter(language.bangpai13)

        if data.autoGangId.."" ~= "0" then
            --plog("add5250201 加入后发送 1050101")
            cache.BangPaiCache:setTaskReset(true)
            proxy.TaskProxy:send(1050101)
        else
            local view = mgr.ViewMgr:get(ViewName.BangPaiFind)
            if view then
                view:add1250201(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250104( data )
    -- body
    if data.status == 0 then
        cache.BangPaiCache:setData(data)
        cache.PlayerCache:setGangName(data.gangName)
        cache.PlayerCache:setGangId(data.gangId)
        cache.PlayerCache:setGangJob(data.gangJob)
        
        gRole:setGangName(data.gangName)
        gRole:setChenghao()
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            --view:initDec()
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250103( data )
    -- body
    if data.status == 0 then
        cache.BangPaiCache:setMember(data)
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.ChooseTipView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250202(data)
    -- body
    if data.status == 0 then --
        local view = mgr.ViewMgr:get(ViewName.BangPaiApplyList)
        if view then
            view:add5250202(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250203(data)
    -- body
    if data.status == 0 then --
        --[[self:sendMsg(1250104)
        cache.BangPaiCache:deleteMember(data)
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end]]--
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250204(data)
    -- body
    if data.status == 0 then
        --回到主界面
        cache.PlayerCache:setGangId("0")
        cache.PlayerCache:setGangName("")
        self:clearRedPonit()
        -- print("刷新主界面帮派聊天按钮")
        local mainview = mgr.ViewMgr:get(ViewName.MainView)
        if mainview then
            mainview:setGangChatVisible()
        end
        cache.PlayerCache:clearGang()
        mgr.ViewMgr:closeAllView2()
        --刷新帮派任务
        cache.TaskCache:deletegangTasks()
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:add8060101()
            view:refreshRedBottom()
        end
        --称号位置调整
        if gRole then 
            gRole:setChenghao()
        end
    else
        GComErrorMsg(data.status)
    end 
end

function BangPaiProxy:add5250205( data )
    -- body
    if data.status == 0 then
        --cache.PlayerCache:clearGang()
        self:sendMsg(1250104) --成员信息
        self:sendMsg(1250103) --成员列表
        --[[cache.BangPaiCache:updateMember(data)
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end]]--
    else
        GComErrorMsg(data.status)
    end 
end

function BangPaiProxy:add5250206(data)
    -- body
    if data.status == 0 then
        cache.BangPaiCache:setNotice(data.notice)
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function BangPaiProxy:add5250207(data)
    -- body
    if data.status == 0 then
        --printt
        cache.BangPaiCache:setMemberJob(data.roleId,data.job)
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function BangPaiProxy:add5250208( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BangPaiSetApply)
        if view then
            view:add5250208(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250209(data)
    -- body
    if data.status == 0 then
        GComAlter(language.bangpai39)
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250301( data )
    -- body
    if data.status == 0 then
        if data.reqType == 2 then
            -- local t = clone(language.bangpai117)
            -- t[2].text = string.format(t[2].text,conf.BangPaiConf:getValue("sign_gang_exp"))
            -- t[4].text = string.format(t[4].text,conf.BangPaiConf:getValue("sign_bg"))
            -- GComAlter(mgr.TextMgr:getTextByTable(t))

            local t = {}
            local confdata = conf.BangPaiConf:getValue("sign_item")
            for k ,v in pairs(confdata) do
                table.insert(t,{mid = v[1],amount = v[2],bind = v[3]})
            end
            table.insert(t,{mid = PackMid.bangpaiexp,amount =conf.BangPaiConf:getValue("sign_gang_exp"),bind = 0})
            table.insert(t,{mid = PackMid.bangpaigx,amount = conf.BangPaiConf:getValue("sign_bg"),bind = 0})
            GOpenAlert3(t)

            self:sendMsg(1250104) --刷新帮派经验

            mgr.GuiMgr:redpointByID(10221)
        elseif data.reqType == 3 then
            mgr.GuiMgr:redpointByID(10221)
        end

        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250105(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BangPaiApplyList)
        if view then
            view:add5250105(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


function BangPaiProxy:add5250210( data)
    -- body
    if data.status == 0 then
        self:sendMsg(1250104) --帮会信息
        self:sendMsg(1250103) --成员列表
        GComAlter(language.bangpai59)
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250302( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250106( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250108( data )
    -- body
    if data.status == 0 then
        --plog("ddddddddddd")
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250107( data )
    -- body
    if data.status == 0 then
        --plog("ddddddddddd")
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250303( data )
    -- body
    if data.status == 0 then
        --plog("ddddddddddd")
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250305(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end

        local view =  mgr.ViewMgr:get(ViewName.BagInOut)
        if view then
            view:add5250305(data)
        end
        if self.itemData and data.reqType < 3 then
            local str = ""
            if data.reqType == 1 then--存入
                str = conf.BangPaiConf:getValue("gang_ware_keep_desc")
            elseif data.reqType == 2 then--取出
                str = conf.BangPaiConf:getValue("gang_ware_take_desc")
            end
            local sendMsg = string.format(str, cache.PlayerCache:getRoleName(),mgr.ChatMgr:getChatPro(self.itemData))
            mgr.ChatMgr:sendChat(sendMsg,ChatType.gangWarehouse)
        end
    else
        if data.status == 22062027 then--道具已经被销毁
            self:send(1250303)
        end
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250306( data )
    -- body
    if data.status == 0 then
        --plog("ddddddddddd")
        local view = mgr.ViewMgr:get(ViewName.BagInOutRecord)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250307( data )
    -- body
    if data.status == 0 then
        cache.BangPaiCache:setBoxData(data)
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250309( data )
    -- body
    if data.status == 0 then
        self:sendMsg(1250307)

        mgr.GuiMgr:redpointByID(10223)
        

        -- cache.BangPaiCache:updateBoxData(data)
        -- local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        -- if view then
        --     view:addMsgCallBack(data)
        -- end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250308( data )
    -- body
    if data.status == 0 then
        --printt(data)
        cache.BangPaiCache:updateBoxColor(data)
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250310(data)
    -- body
    if data.status == 0 then
        GOpenAlert3(data.items)
        cache.BangPaiCache:updateBoxData(data)
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end

        mgr.GuiMgr:redpointByID(10223)
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250313( data )
    -- body
    if data.status == 0 then
        GComAlter(language.bangpai94)
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250312( data )
    -- body
    if data.status == 0 then
        cache.BangPaiCache:updateXieZu(data)
        --GOpenAlert3(data.items)
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250314(data)
    -- body
    if data.status == 0 then
        --printt(data)
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250311( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250405( data )
    -- body
    if data.status == 0 then
        if data.success == 1 then
            self:sendMsg(1250104) --成员信息
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add8060101(data)
    if data.status == 0 then
        --刷新主界面帮派聊天按钮
        if data.noticeType == 1 then--=1加入帮派
            if data.tarRoleId == cache.PlayerCache:getRoleId() then  --自己加入帮派
                --请求任务
                cache.BangPaiCache:setTaskReset(true)
                proxy.TaskProxy:send(1050101)
                cache.PlayerCache:setGangId(data.gangId)
                cache.PlayerCache:setGangName(data.gangName)
                local view = mgr.ViewMgr:get(ViewName.MainView)
                if view then
                    view:refreshRed()
                end
                local view = mgr.ViewMgr:get(ViewName.BangPaiFind)
                if view then
                    GOpenView({id = 1013,index = 0})
                    --如果是引导加了帮派
                    --plog("...",cache.BangPaiCache:getGuide())
                    if cache.BangPaiCache:getGuide() then

                        cache.BangPaiCache:setGuide(false)
                        local param = {
                            type = 12,
                            guideid = 9999,
                            module_name = "bangpai.BangPaiMain",
                            guide = {"n0.btn_close"}
                        }
                        local _view = mgr.ViewMgr:get(ViewName.BangPaiMain)
                        if _view then
                            _view:startGuide(param)
                        else
                            cache.GuideCache:setData(param)
                        end
                    end
                end
                gRole:setGangName(data.gangName)
            else
                --print("@玩家加入帮派了")
                local player = mgr.ThingMgr:getObj(ThingType.player, data.tarRoleId)
                if player then
                    player:setGangName(data.gangName)
                    if player and player.data then
                        player.data.gangId = data.gangId
                        player.data.gangName = data.gangName
                        -- 仙盟ID改变时需要刷新角色攻击模式
                        player:checkCanBeAttack()
                    end
                end
            end    
        elseif data.noticeType == 3 then--3换职位
            local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
            if view then
                self:sendMsg(1250104) --请求帮派信息
            end
            if data.tarRoleId ~= cache.PlayerCache:getRoleId() then --换职位的是鄙人
                local player = mgr.ThingMgr:getObj(ThingType.player, data.tarRoleId)
                if player and player.data then
                    player.data.gangJob = data.gangJob
                    player:setGangName(player.data.gangName)
                end
            end
        elseif data.noticeType == 2 then--踢人
            if data.tarRoleId == cache.PlayerCache:getRoleId() then --被T的是自己
                cache.PlayerCache:setGangId("0")
                cache.PlayerCache:setGangName("")

                self:clearRedPonit()
                local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
                if view then
                    GComAlter(language.bangpai108)
                    mgr.ViewMgr:closeAllView2()
                end
                ---刷新任务
                cache.TaskCache:deletegangTasks()
                local view = mgr.ViewMgr:get(ViewName.MainView)
                if view then
                    view:add8060101()
                    view:refreshRedBottom()
                end
                gRole:setGangName("")
            else
                --如果在帮派界面
                local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
                if view then
                    self:sendMsg(1250104) --成员信息
                    self:sendMsg(1250103) --成员列表
                end
                local player = mgr.ThingMgr:getObj(ThingType.player, data.tarRoleId)
                if player and player.data then
                    player.data.gangId = "0"
                    player.data.gangName = ""
                    player:setGangName("")

                    -- 仙盟ID改变时需要刷新角色攻击模式
                    player:checkCanBeAttack()
                end
            end
        elseif data.noticeType == 4 then --宝箱开启有人协助      
            local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
            if view then
                local c1 = view.view:GetController("c1")
                if c1.selectedIndex == 3 then
                    self:sendMsg(1250307)
                end
            end
        elseif data.noticeType == 5 then
            if data.tarRoleId == gRole:getID() then--自己
                --cache.PlayerCache:setGangId(data.gangId)
                cache.PlayerCache:setGangName(data.gangName)
                gRole:setGangName(data.gangName)
            else
                local player = mgr.ThingMgr:getObj(ThingType.player, data.tarRoleId)
                if player then
                    player:setGangName(data.gangName)
                    if player and player.data then
                        --player.data.gangId = data.gangId
                        player.data.gangName = data.gangName
                        -- 仙盟ID改变时需要刷新角色攻击模式
                        player:checkCanBeAttack()
                    end
                end
            end
        end
        -- print("刷新主界面帮派聊天按钮")
        local mainview = mgr.ViewMgr:get(ViewName.MainView)
        if mainview then
            mainview:setGangChatVisible()
        end
    else
        GComErrorMsg(data.status)
    end
end


function BangPaiProxy:add5250406( data )
    -- body
    if data.status == 0 then

    else
        GComErrorMsg(data.status)
    end
end
function BangPaiProxy:add5250407( data )
    -- body
    if data.status == 0 then

    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250408(data)
    if data.status == 0 then
        self:send(1250303)
    else
        if data.status == 22062027 then--道具已经被销毁
            self:send(1250303)
        end
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add8160102( data )
    -- body
    if data.status == 0 then
        --printt(data)
        if data.reqType == 1 then
            if data.beReqRoleId == cache.PlayerCache:getRoleId() then
                local param = {}
                param.type = 2
                param.richtext = string.format(language.friend47,data.roleName,data.gangName)
                param.sure = function()
                    -- body
                    proxy.BangPaiProxy:sendMsg(1250407,{reqType = 2,tarRoleId = data.reqRoleId})
                end
                param.cancel = function()
                    -- body
                    proxy.BangPaiProxy:sendMsg(1250407,{reqType = 3,tarRoleId = data.reqRoleId})
                end
                GComAlter(param)
            end
        elseif data.reqType == 2 then
            GComAlter(string.format(language.friend48,data.roleName))
        elseif data.reqType == 3 then
            GComAlter(string.format(language.friend49,data.roleName))
        end
    else
        GComErrorMsg(data.status)
    end
end

--推出帮派时候清理一下红点
function BangPaiProxy:clearRedPonit()
    -- body
    local t = {
        10221,10222,10223,50108,10239,50110,10313,10251
    }
    for k , v in pairs(t) do
        if conf.RedPointConf:getDataById(v) then --这个是红点
            cache.PlayerCache:setRedpoint(v,0)
        else
            cache.PlayerCache:setAttribute(v,0)
        end
        mgr.GuiMgr:updateRedPointPanels(v)
    end 
end

--请求仙盟BOSS信息
function BangPaiProxy:add5250502(data)
    if data.status == 0 then 
        -- print("请求仙盟BOSS~~~~~~~~~~~~~~~~~~~~~~~")
        if data.canJoinFire == 1 then
            cache.BangPaiCache:setCanJoinFire(true)
        else
            cache.BangPaiCache:setCanJoinFire(false)
        end
        local view = mgr.ViewMgr:get(ViewName.FeedBoss)   
        if view then 
            view:setData(data)
        end

        local view2 = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view2 then 
            view2:addMsgCallBack(data)
        end 
    else
        GComErrorMsg(data.status)
    end
end

--请求仙盟BOSS喂养
function BangPaiProxy:add5250504(data)
    if data.status == 0 then 
        -- print("喂养请求~~~~~~~~~~~~~")
        -- if data.reqType == 1 then 
        --     mgr.GuiMgr:redpointByID(10251)
        -- end

        local view = mgr.ViewMgr:get(ViewName.FeedBoss)   
        if view then 
            view:setFeedData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙盟圣火信息
function BangPaiProxy:add5250501(data)
    if data.status == 0 then 
        -- print("请求仙盟圣火信息已返回~~~~~~~~~~~~~~~~~~")
        local view = mgr.ViewMgr:get(ViewName.FlameView)
        if view then 
            view:setData(data)
        end 
    else
        GComErrorMsg(data.status)
    end 
end

--请求仙盟圣火添柴返回
function BangPaiProxy:add5250503(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FlameView)
        if view then
            proxy.BangPaiProxy:sendMsg(1250501)
        end
        if data.items and #data.items > 0 then
            GOpenAlert3(data.items)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙盟圣火答题返回
function BangPaiProxy:add5250505(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FlameAnswer)
        if not view then
            mgr.ViewMgr:openView(ViewName.FlameAnswer,function(view)
                view:setQuestion(data)
            end)
        else
            view:setQuestion(data)
        end
        if data.items and #data.items > 0 then
            GOpenAlert3(data.items)
        end
        proxy.BangPaiProxy:sendMsg(1250501)
    else
        GComErrorMsg(data.status)
    end
end

--请求仙盟圣火抛骰子返回
function BangPaiProxy:add5250506(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FlameThrow)
        if view then
            view:setData(data)
        end
        if data.point and #data.point > 0 then
            mgr.ChatMgr:sendxianMenDice(data.point)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求仙盟圣火经验池
function BangPaiProxy:add5250507(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FlameView)
        if view then
            
        end
    else
        GComErrorMsg(data.status)
    end
end

--仙盟圣火活动信息广播
function BangPaiProxy:add8210101(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FlameView)
        if view then
            view:refreshView(data)
        end
        local view = mgr.ViewMgr:get(ViewName.FlameAnswer)
        if view then
            view:refreshView(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function BangPaiProxy:add5250601( data )
    -- body
    if data.status == 0 then
        local view2 = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view2 then 
            view2:addMsgCallBack(data)
        end 
    else
        GComErrorMsg(data.status)
    end
end

--请求仙盟合入
function BangPaiProxy:add5250701(data)
    if data.status == 0 then
        if data.reqType == 1 then
            local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
            if view then
                view:closeView()
            end
            GComAlter(language.bangpai199)
        end
    else
        GComErrorMsg(data.status)
    end
end

--仙盟合入广播
function BangPaiProxy:add8060102(data)
    if data.status ==  0 then
        if data.acceptType == 0 then
            local view = mgr.ViewMgr:get(ViewName.CombineTipsView)
            if view then
                view:initData(data)
            else
                mgr.ViewMgr:openView2(ViewName.CombineTipsView, data)
            end
        elseif data.acceptType == 1 then
            local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
            if view then
                view:closeView()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

return BangPaiProxy