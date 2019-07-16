local PackProxy = class("PackProxy",base.BaseProxy)

function PackProxy:init()
    self:add(5040101,self.returnPackInfo)--返回背包和仓库信息
    self:add(5040102,self.returnCleanPackInfo)--返回整理后的背包信息
    self:add(5040202,self.returnWareTakein)--返回放进仓库信息
    self:add(5040203,self.returnWareTakeout)--返回取出仓库信息
    self:add(5040301,self.returnWearEquip)--返回穿脱装备
    self:add(5040401,self.returnUseIPro)--返回使用的道具
    self:add(5040402,self.returnSelectPro)--返回查询道具信息
    self:add(5040403,self.returnDelete)--返回丢弃道具
    self:add(5040404,self.returnGird)--返回格子开启
    self:add(5100109,self.returnSplit)--返回装备分解
    self:add(5040501,self.add5040501)--请求临时背包转移
    self:add(5040601,self.add5040601)--请求吞噬装备
    self:add(5020302,self.add5020302)--请求成长系统阶级
    self:add(5040405,self.add5040405)--请求资质丹、潜力丹能否使用


    self:add(8030101,self.updatePackInfo)--主动广播修改道具信息
    self:add(8030105,self.add8030105)--自己掉落道具广播
    self:add(8030107,self.add8030107)--boss掉落道具显示
end
--请求背包信息
function PackProxy:sendPackMsg()
    local params = {
                    seqs = {
                            Pack.pack,
                            Pack.equip,
                            Pack.JianLing,
                            Pack.equipxian,
                            Pack.shengYinPack,
                            Pack.shengYinEquip,
                            Pack.shengZhuangPack,
                            Pack.shengZhuangEquip,
                            Pack.elementPack,
                            Pack.elementEquip,
                            Pack.dihun,
                            Pack.shengXiao,
                        }
                    }
    self:send(1040101, params)
end
--请求仓库
function PackProxy:sendWareMsg()
    local params = {seqs = {Pack.ware}}
    self:send(1040101, params)
end
--请求临时背包
function PackProxy:sendLimitMsg()
    local params = {seqs = {Pack.limit}}
    self:send(1040101, params)
end
--请求整理后的背包信息
function PackProxy:sendCleanPackMsg(params)
    self:send(1040102, params)
end
--请求穿脱装备
function PackProxy:sendWearEquip(params)
    local data = cache.PackCache:getPackDataByIndex(params.indexs[1])
    if data then
        local lvl = conf.ItemConf:getLvl(data.mid) or 0
        local name = conf.ItemConf:getName(data.mid)
        if cache.PlayerCache:getRoleLevel() < lvl then
            GComAlter(string.format(language.pack36, name, lvl))
            return
        end
    end
    self:send(1040301, params)
end
--请求使用道具
function PackProxy:sendUsePro(_params)

    local params = clone(_params)
    local data = cache.PackCache:getPackDataByIndex(params.index)
    if data then
        local lvl = conf.ItemConf:getLvl(data.mid) or 0
        local name = conf.ItemConf:getName(data.mid)
        if cache.PlayerCache:getRoleLevel() < lvl then
            GComAlter(string.format(language.pack32, name, lvl))
            return
        end
        self.useName = name
        self.usemid = data.mid
    end

    local list = conf.FeiShengConf:getValue("xianguo_item")--使用的是否是仙果
    for k ,v in pairs(list) do
        if v == self.usemid then
            local A541 = cache.PlayerCache:getAttribute(541)
            local confdata = conf.FeiShengConf:getXlexchangeItem(A541)
            local max = (confdata.max_daily_use or 0) - cache.FeiShengCache:getUseTimes()
            max = math.max(max,0)
            --print("max = ",max,params.amount )
            params.amount = math.min(params.amount,max)
            if params.amount == 0 then
                GComAlter(message.errorID[tonumber(22010013)])
                return
            else
                break
            end
        end
    end


    if self.usemid and PackMid.bianxingka == self.usemid then
        --变性需要二次确定
        local param = {}
        param.type = 2
        param.richtext = language.gonggong85
        param.sure = function()
            -- body
            self:send(1040401, params)
        end
        GComAlter(param)
    elseif self.usemid and PackMid.nianshou == self.usemid then
        --年兽需要判断地图位置
        local sId = cache.PlayerCache:getSId()
        if not sId then
            return GComAlter(language.gonggong124)
        end
        local sConf = conf.SceneConf:getSceneById(sId)
        local kind = sConf and sConf.kind or 0
        if kind ~= SceneKind.field then
            return GComAlter(language.gonggong124)
        end
        self:send(1040401, params)
    else
        self:send(1040401, params)
    end

end
--请求查询道具信息
function PackProxy:sendSelectPro(params)
    self:send(1040402,params)
end
--请求丢弃道具
function PackProxy:sendDelete(params)
    self:send(1040403,params)
end
--请求格子开启
function PackProxy:sendOpenGird(params)
    self:send(1040404,params)
end
--请求装备分解
function PackProxy:sendSplit(params)
    self:send(1100109,params)
end
--请求放进仓库或者取出道具
function PackProxy:sendWareTake(data)
    local params = {indexs = {data.index}}
    local divisor = 100000
    local index = math.floor(data.index / divisor) * divisor
    if index == Pack.pack then--在背包就放进
        self:send(1040202, params)
    elseif index == Pack.ware then--在仓库就取出
        self:send(1040203, params)
    end
end
--请求自动吞噬装备
function PackProxy:sendMsgTunshi(params)
    -- body
    self:send(1040601,params)
end
--返回放进仓库信息
function PackProxy:returnWareTakein( data )
    if data.status == 0 then
        self:refreshView()
    else
        GComErrorMsg(data.status)
    end
end
--返回取出仓库信息
function PackProxy:returnWareTakeout( data )
    if data.status == 0 then
        self:refreshView()
    else
        GComErrorMsg(data.status)
    end
end
--返回穿脱装备
function PackProxy:returnWearEquip( data )
    if data.status == 0 then
        --plog("穿装备成功")
        self:refreshView()
        local view = mgr.ViewMgr:get(ViewName.EquipTipsView)
        if view then
            proxy.ForgingProxy:send(1100116,{reqType = 0, part = view:getWearPart()})
            view:onClickClose()
        end
        local view = mgr.ViewMgr:get(ViewName.EquipWearTipView)
        if view then--穿戴提示
            view:successWear()
        end
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view and view.BtnFight then
            view.BtnFight:checkTwoBtn()
        end
    else
        GComErrorMsg(data.status)
    end
end


--返回背包信息
function PackProxy:returnPackInfo( data )
	if data.status == 0 then
        cache.PackCache:setPackData(data.items)
        local isPack = false
        local seqs = data.seqs or {}
        for k,v in pairs(seqs) do
            if v ~= Pack.ware then
                isPack = true
            end
        end
        if isPack then
            local lists = cache.PackCache:getOverdueProp()
            if #lists > 0 then
                cache.PackCache:setPackOverdue(lists)--找到有即将过期的道具
            end
        end
        local view = mgr.ViewMgr:get(ViewName.PackView)
        if view then
            view:refreshWarePanel()--只有仓库需要返回
        end
        local view = mgr.ViewMgr:get(ViewName.LimitPackView)
        if view then
            view:setData()--临时背包
        end
    else
        GComErrorMsg(data.status)
    end
end

--返回整理后的背包信息
function PackProxy:returnCleanPackInfo( data )
	if data.status == 0 then
        cache.PackCache:cleanPack(data.seq)
        cache.PackCache:setPackData(data.items)
        local view = mgr.ViewMgr:get(ViewName.PackView)
        if view then
            if data.seq == Pack.ware then
                view:refreshCleanWare()
            else
                view:refreshPackClean()
            end
        end

        local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--返回使用的道具
function PackProxy:returnUseIPro( data )
    -- print("堆栈",debug.traceback())
    if data.status == 0 then

        self:refreshView()
        local view = mgr.ViewMgr:get(ViewName.WeddingView)
        if view then
            view:setFireworks()
        end

        local view = mgr.ViewMgr:get(ViewName.ZuoQiItemUse)
        if view then
            view:add5040401(data)
        end

        local view = mgr.ViewMgr:get(ViewName.HuobanItemUse)
        if view then
            view:add5040401(data)
        end

        local view = mgr.ViewMgr:get(ViewName.FSXianYuanUp)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.ShengHunView)
        if view then
            proxy.AwakenProxy:send(1600102)
        end

        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view and view.MianJuPanel then --激活面具
            view.MianJuPanel:jiHuoMianJu(data)
        end

        if self.useName then
            GComAlter(string.format(language.pack31, self.useName))
            self.useName = nil
        end
        --坐骑等系统，使用升阶丹之后，没有自动穿戴新的
        --（使用后升阶，则弹出获得界面，如果不是升阶，
        --就飘字提示“XX使用成功，祝福值加XX”）
        --
        if 221041799 == self.usemid then
            --变形成功
            --
            local icon = cache.PlayerCache:getRoleIcon()
            local sex = math.floor(icon/100000000)
            if sex == 1 then
                sex = 2
            else
                sex = 1
            end
            icon =sex*100000000 +  icon%100000000
            cache.PlayerCache:setRoleIcon(icon)
            --改变显示
            local view = mgr.ViewMgr:get(ViewName.MainView)
            if view then
                view:updateRoleInfo()
                if view.BtnFight then
                    view.BtnFight:setSkillIcon()
                end
            end
            --背包界面
            local view = mgr.ViewMgr:get(ViewName.PackView)
            if view then
                view:nextStep(view.mainController.selectedIndex+1)
            end

            GComAlter(language.gonggong86)
        elseif not self:checkUse(self.usemid,data) then
            GOpenAlert3(data.items)
        end
        local view = mgr.ViewMgr:get(ViewName.ExpdrugTipView)
        if view then
            view:initData()
        end
        self.usemid = nil
    elseif data.status == 2204022 then--bxp激活过的时装跳转到升星界面
        -- if 221042634 == self.usemid then
        local temp = conf.ItemConf:getSuitStarModel(self.usemid)
        if not temp then
            print("时装>>",self.usemid,"没有时装升星跳转路径")
            GComErrorMsg(data.status)
            return
        end
        GComErrorMsg(data.status)
        local modelId = temp[1]
        local suitId = temp[2]
        local childIndex = temp[3] or nil
        local param = {id=modelId,suitId = suitId,childIndex = childIndex,grandson = suitId}
        GOpenView(param)
    else
        GComErrorMsg(data.status)
    end
end
--返回查询道具信息
function PackProxy:returnSelectPro( data )
    if data.status == 0 then
        mgr.ViewMgr:openView(ViewName.PropMsgView,function(view)
            view:setData(data.itemInfo)
        end)
    else
        GComErrorMsg(data.status)
    end
end
--更改道具信息
function PackProxy:updatePackInfo( data )
    if data.status == 0 then
        if data.itemSeq == Pack.gang then--幫派廠區
            local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
            if view then
                view:addMsgCallBack(data)
            end
            return
        end

        --更新之前获取当前穿戴装备 9 - 12 计算进阶或者铸星需要的道具
        local _check_t = mgr.GuiMgr:get912PartNeed()

        local oldData = {}--旧数据
        for k,v in pairs(data.changeItems) do--更新前计算旧数据
            local data = cache.PackCache:getPackDataByIndex(v.index)
            local amount = data and data.amount or 0
            oldData[v.index] = amount
        end

        if data.srcSeq ~= 2 and  data.srcSeq ~= 4 then
            cache.PackCache:updatePackData(data.itemSeq,data.changeItems)--更改背包信息
            if data.itemSeq == Pack.shengYinPack then--圣印背包发生改变
                cache.PackCache:updateShengYinPackData(data.changeItems)
            end
            if data.itemSeq == Pack.elementPack then--元素背包发生改变
                cache.PackCache:updateElementPack(data.changeItems)
            end
            if data.itemSeq == Pack.shengZhuangPack then --圣装背包发生改变

                cache.PackCache:updateShengZhuangPackData(data.changeItems)
            end
            if data.itemSeq == Pack.shengZhuangEquip then --圣装已装备发生改变

                cache.PackCache:updateShengZhuangEquipData(data.changeItems)
            end
            if data.itemSeq == Pack.shengXiao then -- 生肖背包改变
                cache.PackCache:updateShengXiaoPackData(data.changeItems)
            end
            --检测是否需要重新计算合成红点
            local fff = false
            for k ,v in pairs(data.changeItems) do
                if _check_t[v.mid] then
                    fff = true
                    break
                else
                    local confdata = conf.ItemConf:getItem(v.mid)
                    if confdata.type == Pack.equipType then
                        local _cc = conf.ForgingConf:getComposeValue("compose_new_part")
                        local _ttt = {}
                        for k ,v in pairs(_cc) do
                            _ttt[v] = true --需要是指定的部位
                        end
                        local _info =  {}
                        local _dd = conf.ForgingConf:getComposeValue("compose_new_color_xin_jie")
                        for k , v in pairs(_dd) do
                            _info[v[1]] = v
                        end
                        if _ttt[confdata.part] then
                            if _info[confdata.color]
                            and confdata.stage_lvl >= _info[confdata.color][3]
                            and mgr.ItemMgr:getColorBNum(v) == _info[confdata.color][2] then
                                fff = true
                                break
                            end
                        else
                            if confdata.color >= conf.ForgingConf:getComposeValue("equip_compose_min_color")
                            and mgr.ItemMgr:getColorBNum(v) == conf.ForgingConf:getComposeValue("equip_compose_min_star")
                            and confdata.stage_lvl >= conf.ForgingConf:getComposeValue("equip_compose_min_jie") then
                                fff = true
                                break
                            end
                        end
                    elseif confdata.type == Pack.xianzhuang then
                        fff = true
                        break
                    elseif confdata.type == Pack.equippetType then
                        local gg = conf.ForgingConf:getComposeValue("compose_pet_color_xin")
                        if confdata.color >= gg[1]
                        and mgr.ItemMgr:getColorBNum(v) == gg[2] then
                            fff = true
                                break
                        end
                    elseif confdata.type == Pack.wuxing then
                        fff = true
                        break
                    elseif confdata.type == Pack.shengYinType then
                        fff = true
                        break
                    elseif confdata.type == Pack.equipawkenType then
                        fff = true
                        break
                    elseif confdata.type == Pack.elementType then
                        fff = true
                        break
                    elseif confdata.type == Pack.dihunType then
                        fff = true
                        break
                    elseif confdata.type == Pack.shengXiaoType then
                        fff = true
                        break
                    end
                end
            end
            if fff then
                --主界面刷新红点
                mgr.GuiMgr:refreshRedBottom()
                local view = mgr.ViewMgr:get(ViewName.ForgingView)
                if view then
                    view:initData()
                end
                local view = mgr.ViewMgr:get(ViewName.AwakenView)
                if view then
                    view:refreshRed()
                end
                -- 刷新生肖背包
                local view1 = mgr.ViewMgr:get(ViewName.ShengXiaoPackView)
                if view1 then
                    view1:flush()
                end
                -- 刷新生肖
                local view2 = mgr.ViewMgr:get(ViewName.KageeViewNew)
                if view2 then
                    view2:flush()
                    view2:refreshAppointRed(1)
                end
            end
        end
        --plog("data.srcSeq",data.srcSeq)
        if data.srcSeq ~= 1 and data.srcSeq ~= 2 then
            local items = {}
            for k,v in pairs(data.changeItems) do
                local iType = conf.ItemConf:getType(v.mid)
                local lvl = conf.ItemConf:getLvl(v.mid)
                if iType == Pack.equipType and v.amount > 0 and cache.PlayerCache:getRoleLevel() >= lvl and (mgr.ItemMgr:isPackItem(v.index)) then
                    table.insert(items, v)
                end
            end
            if #items > 0 then
                -- printt("data.changeItems",data.changeItems)
                -- if not mgr.FubenMgr:checkScene2(cache.PlayerCache:getSId()) then
                --     mgr.ItemMgr:checkEquips(items)
                -- else
                --     for k,v in pairs(items) do
                --         cache.FubenCache:setChangeEquips(v)
                --     end
                -- end
                mgr.ItemMgr:checkEquips(items)
            end
        end

        local srcSeq = data.srcSeq
        if srcSeq == 0 then--进背包的时候更改后飘字
            for k,v in pairs(data.changeItems) do
                local oldAmount = oldData[v.index]
                if v.updateNum > 0 and mgr.ItemMgr:isPackItem(v.index) then
                    if v.amount > oldAmount then
                        local name = conf.ItemConf:getName(v.mid)
                        local info = {text = name,count = v.updateNum,color = 1}
                        mgr.TipsMgr:addRightTip(info)--道具飘字
                        local itemData = clone(v)--飘道具
                        local updateData = clone(v)
                        updateData.amount = v.updateNum
                        mgr.ItemMgr:addItem(updateData)
                        local iType = conf.ItemConf:getType(itemData.mid)
                        local subType = conf.ItemConf:getSubType(itemData.mid)
                        if iType == Pack.prosType and subType == Pros.quickuse then--快捷使用
                            mgr.ItemMgr:checkPros(itemData)
                        else
                            if not mgr.FubenMgr:checkScene(cache.PlayerCache:getSId()) then
                                mgr.ItemMgr:checkPros(itemData)
                            else
                                cache.FubenCache:setChangeItems(itemData)
                            end
                        end
                    end
                elseif v.updateNum > 0 and (mgr.ItemMgr:isShengYinPackItem(v.index) or mgr.ItemMgr:isElementPackItem(v.index)
                    or mgr.ItemMgr:isDiHunPackItem(v.index)) then--圣印背包&元素背包&帝魂背包
                    if v.amount > oldAmount then
                        local name = conf.ItemConf:getName(v.mid)
                        local info = {text = name,count = v.updateNum,color = 1}
                        mgr.TipsMgr:addRightTip(info)--道具飘字
                    end
                elseif v.updateNum > 0 and mgr.ItemMgr:isShengZhuangPackItem(v.index) then--圣裝背包
                    if v.amount > oldAmount then
                        local name = conf.ItemConf:getName(v.mid)
                        local info = {text = name,count = v.updateNum,color = 1}
                        mgr.TipsMgr:addRightTip(info)--道具飘字
                    end

                elseif v.updateNum > 0 and mgr.ItemMgr:isShengXiaoPackItem(v.index) then--生肖背包
                    if v.amount > oldAmount then
                        local name = conf.ItemConf:getName(v.mid)
                        local info = {text = name,count = v.updateNum,color = 1}
                        mgr.TipsMgr:addRightTip(info)--道具飘字
                    end
                end

            end
            if not mgr.ViewMgr:get(ViewName.AdvancedTipView) then
                mgr.ItemMgr:checkAdvPros()--检测获得的进阶丹道具
            end
            if not mgr.ViewMgr:get(ViewName.SQuickUseView) and not mgr.FubenMgr:checkScene(cache.PlayerCache:getSId()) then
                mgr.ItemMgr:checkSPros()
            end
        end

        if srcSeq == 2 then --吞噬装备获得伙伴经验
            for k,v in pairs(data.changeItems) do
                local name = conf.ItemConf:getName(v.mid)
                local equipConf = conf.ItemConf:getItem(v.mid)
                local partner_exp = equipConf.partner_exp
                local info = {text = name,count = v.amount,color = 1,isTunshi = true,partnerExp = partner_exp}
                mgr.TipsMgr:addRightTip(info)--道具飘字
            end
        elseif srcSeq == 4 then
            --仙装吞噬

            for k,v in pairs(data.changeItems) do
                local condata = conf.ItemConf:getItem(v.mid)
                if condata and condata.partner_exp  then
                    local str = clone(language.fs44)
                    str[1].text = string.format(str[1].text , condata.name )
                    str[4].text = string.format(str[4].text , condata.partner_exp )
                    local info = {text =   mgr.TextMgr:getTextByTable(str),count = 0}

                    mgr.TipsMgr:addRightTip(info)--道具飘字
                end
            end
        end

        if srcSeq == Pack.pack and data.itemSeq == Pack.limit then--进临时背包的时候
            --源存储类型:仓库100000,背包200000,装备300000
            for k,v in pairs(data.changeItems) do
                local itemData = clone(v)--飘道具
                itemData.amount = itemData.amount
                mgr.ItemMgr:addItem(itemData)
            end
        end
         --南瓜道具
        local ng_mid = conf.WSJConf:getValue("wsj_ng_mid")
        for k,v in pairs(data.changeItems) do
            if v.mid == ng_mid and mgr.FubenMgr:isWSJChuMo(cache.PlayerCache:getSId()) then
                --降妖除魔任务追踪刷新
                local trackView = mgr.ViewMgr:get(ViewName.TrackView)
                if trackView then
                    trackView:setWsjTrack()
                end
            end
        end

    else
        GComErrorMsg(data.status)
    end
end
--丢弃道具
function PackProxy:returnDelete( data )
    if data.status == 0 then
        GOpenAlert3(data.items)
        self:refreshView()

        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.PetEquipView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.ShenShouEquip)
        if view then
            view:getIsShowEquips()
            view:initShenShouEquip()
        end
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:refreshShenShou()
        end
    else
        GComErrorMsg(data.status)
    end
end
--格子开启
function PackProxy:returnGird( data )
    if data.status == 0 then
        local reqType = data.reqType
        local lastOpenTime = data.lastOpenTime
        local girdOpenNum = data.gridOpenNum
        local preOnlineSec = data.preOnlineSec

        local oldGirdOpenNum = cache.PackCache:getGridKeyData(attConst.packNum)--
        if oldGirdOpenNum == girdOpenNum then--开启失败的时候的打印
            local oldPackTime = cache.PackCache:getGridKeyData(attConst.packTime)--上一次开启背包的时间
            local oldPackSec = cache.PackCache:getGridKeyData(attConst.packSec)--背包格子累計秒數
            -- plog("服务器时间",mgr.NetMgr:getServerTime(),"旧背包开启时间",oldPackTime,"旧背包格子累計秒數",oldPackSec,"旧格子",oldGirdOpenNum,"新背包开启时间",lastOpenTime,"新背包格子累計秒數",preOnlineSec,"新格子",girdOpenNum)
        end
        if reqType == 1 or reqType == 2 then
            cache.PackCache:setGridKeyData(attConst.packTime,lastOpenTime)--
            cache.PackCache:setGridKeyData(attConst.packNum,girdOpenNum)--
            cache.PackCache:setGridKeyData(attConst.packSec,preOnlineSec)--
        else
            cache.PackCache:setGridKeyData(attConst.wareTime,lastOpenTime)--
            cache.PackCache:setGridKeyData(attConst.wareNum,girdOpenNum)--
            cache.PackCache:setGridKeyData(attConst.wareSec,preOnlineSec)--
        end
        local view = mgr.ViewMgr:get(ViewName.PackView)
        if view then
            view:setTimeInterval(0,100)
            view:selelctPage()
        end
    else
        GComErrorMsg(data.status)
    end
end
--分解返回
function PackProxy:returnSplit( data )
    if data.status == 0 then
        GOpenAlert3(data.items)
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:setData()
        end
        local view = mgr.ViewMgr:get(ViewName.HuobanExpPop)
        if view then
            view:refreshView()
        end

        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求临时背包转移
function PackProxy:add5040501(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.LimitPackView)
        if view then
            view:setData()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求吞噬装备
function PackProxy:add5040601(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.PackView)
        if view then
            view:setTunshiType(data.curType)
        end
        local view = mgr.ViewMgr:get(ViewName.WelfareView)
        if view then
            view:updateAutoCheck(data.curType)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求成长系统阶级
function PackProxy:add5020302(data)
    if data.status == 0 then
        if mgr.FubenMgr:checkScene() then
            cache.PackCache:cleanAdvPros()
            return
        end
        local isCheck = mgr.ModuleMgr:CheckView({id = data.modelId})--检测模块配置
        local isNotOpen = cache.PackCache:getNotAdvancedTip(data.modelId)--不能再次打开
        local advdata = cache.PackCache:getOneAdvPro()
        local isTip = false
        if isCheck and not isNotOpen then
            if data.modelId > 1001 and data.modelId <= 1010 then--如果是伙伴系统
                if data.step < RiseProTipJie and data.canUp == 1 then--6阶以下的成长系统提示可跳转
                    isTip = true
                end
            elseif data.step > 0 and data.modelId ~= 1001 then
                isTip = true
                if advdata then
                    advdata["part"] = data.step
                end
            elseif data.canUp > 0 then
                isTip = true
            end
        end
        if isTip and advdata then
            local view = mgr.ViewMgr:get(ViewName.AdvancedTipView)
            if view then
                view:setData(advdata)
            else
                if not g_ios_test then
                    mgr.ViewMgr:openView2(ViewName.AdvancedTipView, advdata)
                end
            end
        else
            cache.PackCache:cleanAdvPros(true)
            mgr.ItemMgr:checkAdvPros()
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求资质丹、潜力丹能否使用
function PackProxy:add5040405(data)
    if data.status == 0 then
        if data.canUse == 1 then
            local packData = cache.PackCache:getPackDataById(data.mid,nil,true)
            if packData.amount >= data.canUseNum then
                packData.amount = data.canUseNum
            end
            local view = mgr.ViewMgr:get(ViewName.SQuickUseView)
            if view then
                view:setData(packData)
            else
                mgr.ViewMgr:openView2(ViewName.SQuickUseView, packData)
            end
        else
            cache.PackCache:cleanSPros(true)
            mgr.ItemMgr:checkSPros()
        end
    else
        GComErrorMsg(data.status)
    end
end

function PackProxy:refreshView()
    local view = mgr.ViewMgr:get(ViewName.PackView)
    if view then--背包界面
        view:setData()
    end
    local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
    if view then--角色界面
        view:updateEquipMsg()
        view:updateEquipPro()
    end


end
--自己掉落道具广播
function PackProxy:add8030105(data)
    if data.status == 0 then
        mgr.PickMgr:addDrop(data.items)
    else
        GComErrorMsg(data.status)
    end
end
--boss掉落道具显示
function PackProxy:add8030107(data)
    if data.status == 0 then
        mgr.PickMgr:addDrop(data.items, data.roleId, data.monsterId, data.sx, data.sy)
    else
        GComErrorMsg(data.status)
    end
end

function PackProxy:checkUse(mId,data)
    -- body
    local t = {
        [PackMid.zuoqi] = 0,
        [PackMid.zuoqi1] = 0,
        [PackMid.zuoqi2] = 0,
        [PackMid.xianyu] = 3,
        [PackMid.xianyu1] = 3,
        [PackMid.xianyu2] = 3,
        [PackMid.shengbing] = 1,
        [PackMid.shengbing1] = 1,
        [PackMid.shengbing2] = 1,
        [PackMid.xianqi] = 4,
        [PackMid.xianqi1] = 4,
        [PackMid.xianqi2] = 4,
        [PackMid.fabao] = 2,
        [PackMid.fabao1] = 2,
        [PackMid.fabao2] = 2,
        [PackMid.lingyu] = 1,
        [PackMid.lingyu1] = 1,
        [PackMid.lingyu2] = 1,
        [PackMid.lingbing] = 2,
        [PackMid.lingbing1] = 2,
        [PackMid.lingbing2] = 2,
        [PackMid.lingqi] = 4,
        [PackMid.lingqi1] = 4,
        [PackMid.lingqi2] = 4,
        [PackMid.lingbao] = 3,
        [PackMid.lingbao1] = 3,
        [PackMid.lingbao2] = 3,
        [PackMid.lingtong] = 0,
        [PackMid.lingtong1] = 0,
        [PackMid.lingtong2] = 0,

        [PackMid.qlb] = 5,
        [PackMid.qlb1] = 5,
        [PackMid.qlb2] = 5,
        [PackMid.qlb3] = 5,
    }
    --坐骑飞升丹
    if mId == PackMid.zuoqi or mId == PackMid.zuoqi1 or mId == PackMid.zuoq2 then
        if data.isUp == 1 then
            local index = t[mId]
            local condata = conf.ZuoQiConf:getDataByLv(data.upNum,index)
            local beforedata =  conf.ZuoQiConf:getDataByLv(data.upNum-1,index)
            local modeldata = conf.ZuoQiConf:getSkinsByJie(condata.jie,index)
            local param = {}
            param.lev = data.upNum

            mgr.ViewMgr:openView(ViewName.ZuoQiUpView,function(view)
                -- body
                view:setData(param,beforedata,nil,nil,index)
            end)

            local tt = {}
            tt.skinId = modeldata.id
            tt.reqType = 1
            proxy.ZuoQiProxy:send(1120105,tt)
        else
            GComAlter(language.gonggong70)
        end

        return true
    elseif mId == PackMid.xianyu or mId == PackMid.xianyu1 or mId == PackMid.xianyu2
        or mId == PackMid.shengbing or mId == PackMid.shengbing1 or mId == PackMid.shengbing2
        or mId == PackMid.xianqi or mId == PackMid.xianqi1 or mId == PackMid.xianqi2
        or mId == PackMid.fabao or  mId == PackMid.fabao1 or  mId == PackMid.fabao2
        or mId == PackMid.qlb or  mId == PackMid.qlb1 or  mId == PackMid.qlb2  or   mId == PackMid.qlb3 then
        local index = t[mId]
        if data.isUp == 1 then
           -- print("data.upNum,index",data.upNum,index)
            local condata = conf.ZuoQiConf:getDataByLv(data.upNum,index)
            local beforedata =  conf.ZuoQiConf:getDataByLv(data.upNum-1,index)
            local modeldata = conf.ZuoQiConf:getSkinsByJie(condata.jie,index)
            local param = {}
            param.lev = data.upNum

            mgr.ViewMgr:openView(ViewName.ZuoQiUpView,function(view)
                -- body
                view:setData(param,beforedata,nil,nil,index)
            end)

            local tt = {}
            tt.skinId = modeldata.id
            if 3 == index then
                proxy.ZuoQiProxy:send(1140105,tt)
            elseif 1 == index then
                proxy.ZuoQiProxy:send(1160105,tt)
            elseif 2 == index then
                proxy.ZuoQiProxy:send(1170105,tt)
            elseif 4 == index then
                proxy.ZuoQiProxy:send(1180105,tt)
            elseif 5 == index then
                proxy.ZuoQiProxy:send(1560105,tt)
            end
        else
            if 5 == index then
                local condata = conf.ItemConf:getItem(mId)
             GComAlter(string.format(language.gonggong131,condata.name, condata.args.arg2))
            else
			 local condata = conf.ItemConf:getItem(mId)
             GComAlter(string.format(language.gonggong71,condata.name, condata.args.arg2))
            end
        end

        return true
    elseif mId == PackMid.lingyu or mId == PackMid.lingyu1 or mId == PackMid.lingyu2
        or mId == PackMid.lingbing or mId == PackMid.lingbing1 or mId == PackMid.lingbing2
        or mId == PackMid.lingqi or mId == PackMid.lingqi1 or mId == PackMid.lingqi2
        or mId == PackMid.lingbao or mId == PackMid.lingbao1 or mId == PackMid.lingbao2
        or mId == PackMid.lingtong or mId == PackMid.lingtong1 or mId == PackMid.lingtong2 then
        local index = t[mId]
        if data.isUp == 1 then
            local condata = conf.HuobanConf:getDataByLv(data.upNum,index)
            local beforedata =  conf.HuobanConf:getDataByLv(data.upNum-1,index)
            local modeldata = conf.HuobanConf:getSkinsByJie(condata.jie,index)
            local param = {}
            param.lev = data.upNum
            if 0 ~= index then
                mgr.ViewMgr:openView(ViewName.HuobanUpView,function(view)
                    -- body
                    view:setData(param,beforedata,nil,nil,index)
                end)
            end
            if 0 == index then
                cache.PlayerCache:setPartnerLevel(data.upNum)
                 --刷一下称号
                local pet = mgr.ThingMgr:getObj(ThingType.pet,cache.PlayerCache:getRoleId())
                if pet then
                    pet:setChenghao(data.upNum)
                end
            elseif 1 == index then
                proxy.HuobanProxy:send(1210105,{skinId = modeldata.id})
            elseif 2 == index then
                proxy.HuobanProxy:send(1220106,{skinId = modeldata.id})
            elseif 3 == index then
                proxy.HuobanProxy:send(1230105,{skinId = modeldata.id})
            elseif 4 == index then
                proxy.HuobanProxy:send(1240105,{skinId = modeldata.id})
            end
        else
            local condata = conf.ItemConf:getItem(mId)
            if index == 0 then
                GComAlter(string.format(language.gonggong93,condata.name, condata.args.arg2 * data.amount))
            else
                GComAlter(string.format(language.gonggong71,condata.name, condata.args.arg2 * data.amount))
            end
        end

        return true
    else
        --检测是否是宠物蛋
        local condata = conf.ItemConf:getItem(mId)
        if condata and condata.petindex then
            --这个是宠物蛋
            local param = {}
            param.index = 15
            param.petId = condata.petindex
            mgr.ViewMgr:openView2(ViewName.GuideZuoqi, param)
            return true
        end
    end

    return false
end

return PackProxy