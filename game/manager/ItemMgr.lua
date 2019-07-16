--
-- Author: ohf
-- Date: 2017-01-04 21:30:03
--
--item管理器
local ItemMgr = class("ItemMgr")

function ItemMgr:ctor()
    self.panelIndex = 0
    self.timer = nil
    self.objPools = {}
    self.itemList = {}--飘道具库
    self.parent = nil
    self:initClickInfo()
end

function ItemMgr:initClickInfo()
    self.clickItemInfo = {index = 0, time = 0, count = 0}
end

function ItemMgr:setPackIndex( index )
    self.panelIndex = index
end

function ItemMgr:getPackIndex()
    return self.panelIndex
end

-- 生肖数据
function ItemMgr:setShengXiaoInfo(itemObj, data)
    local root = itemObj:GetChild("n25")
    local sxTypeImg = itemObj:GetChild("n23")
    local sxLevel = itemObj:GetChild("n24")
    local itemCfg = conf.ItemConf:getItem(data.mid)

    root.visible = itemCfg.type == Pack.shengXiaoType

    if itemCfg.type == Pack.shengXiaoType then
        sxTypeImg.url = UIPackage.GetItemURL("_others" , "shengxiao_0" .. (22 + itemCfg.sub_type))
        local stage = itemCfg.stage_lvl < 10 and itemCfg.stage_lvl or itemCfg.stage_lvl - 1
        sxLevel.url = UIPackage.GetItemURL("_others" , "shengxiao_0" .. (34 + stage))
    end
end

--////////////////////////////////////////////

--data的数据可扩展，一般是amount,mid,index
--data-{amount 数量 or 等级,mid 道具编号,bind--锁,amountScale
--isGet是否已领取--isRealMid,--grayed灰色,
--func 回调,--isCase是否只显示框},isClick是否有点击事件,isChatPro是否聊天栏道具
function ItemMgr:setItemData(itemObj,data,isClick,isChatPro)
    --是否有圈圈特效
    local movie = itemObj:GetController("c1")
    if movie then
        if data.mid and not data.isquan then
            --plog(".data.mid.",data.mid)
            local id = conf.ItemConf:getIsQuan(data.mid)
            if not id then
                id = 0
            elseif id > 4 then
                id = 0
            elseif id < 0 then
                id = 0
            end
            movie.selectedIndex = id
        else
            movie.selectedIndex = 0
        end
    end
    local shengYinLoader = itemObj:GetChild("n20")
    if data.mid then
        local shengYinMovie = conf.ItemConf:getShengYinMovie(data.mid)
        if shengYinMovie ~= 0 then
            shengYinLoader.url = UIPackage.GetItemURL("_movie" , "MovieShengYin"..shengYinMovie)
        else
            shengYinLoader.url = nil
        end
    end

    local jieIcon = itemObj:GetChild("n22")
    if data.mid then
        local _type = conf.ItemConf:getType(data.mid)
        local subType = conf.ItemConf:getSubType(data.mid)
        if _type == Pack.elementType and subType ~= 15 then
            jieIcon.url = UIItemRes.jieIcon[conf.ItemConf:getStagelvl(data.mid)]
        else
            jieIcon.url = ""
        end
    end
    if data.mid then
        self:setShengXiaoInfo(itemObj, data) -- 生肖数据

        self:setColorAtti(itemObj,data)--先设置星bxp
        local realMid = conf.ItemConf:getRealMid(data.mid) or 0
        local starCount = conf.ItemConf:getEquipStar(data.mid) or 0
        if starCount > 0 and realMid > 0 then--如果是假显示的道具
            --在打开view的时候会改成真实id，view内不会显示出星，所以先赋值假显示的星
            data.eStar = self:getColorBNum(data)
            data.mid = realMid
        end
        local bind = data.bind or conf.ItemConf:getBind(data.mid) or 0
        local unlock = itemObj:GetChild("n4")--锁
        unlock.visible = false
        if bind > 0 then
            unlock.visible = true
        end
        local equipped = itemObj:GetChild("n5")--已装备字样
        equipped.visible = false
        local packIndex = data.index or 0
        local index = math.floor(packIndex / 100000) * 100000
        if isChatPro and index == Pack.equip then
            equipped.visible = true
        end
        itemObj.data = {time = 0,clickCount = 0,data = data}
        itemObj.visible = true
        local titleObj = itemObj:GetChild("title")
        if data.amountScale then
            titleObj:SetScale(data.amountScale.x,data.amountScale.y)
        else
            titleObj:SetScale(1,1)
        end
        local amount = data.amount or 1
        titleObj.text = GTransFormNum3(amount)   --EVE GTransFormNum(amount) （原）
        if amount <= 1 or data.hidenumber then
            titleObj.visible = false
        else
            titleObj.visible = true
        end

        local isGet = data.isGet--该道具是否已领取（仅用于部分系统，不与背包关联）
        local getImg = itemObj:GetChild("n6")
        if isGet then
            getImg.visible = true
        else
            getImg.visible = false
        end

        local iconObj = itemObj:GetChild("icon")
        --print(data.url,self:getItemIconUrlByMid(data.mid),"#####")
        iconObj.url = data.url or self:getItemIconUrlByMid(data.mid)
        local color = conf.ItemConf:getQuality(data.mid)
        local iType = conf.ItemConf:getType(data.mid)
        local itemFrame = itemObj:GetChild("n1")

        itemFrame.url = ResPath.iconRes("beibaokuang_00"..color)--设置品质框


        local effectIcon = itemObj:GetChild("n7")--特效区域
        effectIcon.visible = false
        if color >= Pack.color and iType == Pack.equipType then
            -- effectIcon.url = UIItemRes.effect01[color]
            -- effectIcon.visible = true
        else
            effectIcon.visible = false
        end

        local timeImg = itemObj:GetChild("n8")--限时标签
        local limitTime = conf.ItemConf:getlimitTime(data.mid) or 0
        if limitTime > 0 then
            timeImg.visible = true
            local propTime = data.propMap and data.propMap[attConst.packAging]
            if propTime then
                if mgr.NetMgr:getServerTime() < limitTime + propTime then
                    timeImg.url = UIItemRes.pack01[1]--限时
                else
                    timeImg.url = UIItemRes.pack01[2]--过时
                end
            else
                timeImg.url = UIItemRes.pack01[1]--限时
            end
        else
            timeImg.visible = false
        end

        local grayed = data.grayed--需要额外传递
        itemFrame.grayed = grayed
        iconObj.grayed = grayed

        if grayed then--置灰的道具并且不能点击
            isClick = false
        end

        local isneed = itemObj:GetChild("n11")
        -- if g_isskillneed then --作弊看技能书是否需要
        --     data.isneed = cache.PlayerCache:__getIsNeed(data.mid)
        -- elseif g_isskillneedcur then --作弊只看当前的
        --     data.isneed = cache.PlayerCache:getIsNeed(data.mid)
        -- end
        if data.isneed then
            isneed.visible = true
        else
            isneed.visible = false
        end

        local isdone = itemObj:GetChild("n18")
        isdone.visible = false
        -- if data.isdone then
        --     isdone.visible = true
        --     if data.isdone == 1 then
        --         isdone.url = ResPath.iconload("gonggongsucai_134","_icons")
        --     elseif data.isdone == 2 then
        --         isdone.url = ResPath.iconload("gonggongsucai_124","_imgfonts")
        --     elseif data.isdone == 3 then
        --         isdone.url = ResPath.iconload("gonggongsucai_135","_icons")
        --     else
        --         isdone.url = nil
        --     end
        -- else
        --     isdone.visible = false
        -- end

        --按钮事件
        if isClick then
            itemObj.onClick:Add(self.onClickItem,self)
        end
        -- self:setColorAtti(itemObj,data)

        self:scoreCompare(itemObj,data)--评分比较
    elseif data.isCase then --只显示框和icon
        for i = 0 , itemObj.numChildren-1 do
            local var = itemObj:GetChildAt(i)
            if var and var.name ~="n15"
                and var.name ~="n16"
                and var.name ~="n17" then
                var.visible = false
            end
        end
        itemObj:GetController("c2").selectedIndex = 0
        local itemFrame = itemObj:GetChild("n1")
        itemFrame.visible = true
        local color = data.color or 1
        itemFrame.url = ResPath.iconRes("beibaokuang_00"..color)--设置品质框
        local iconObj = itemObj:GetChild("icon")
        iconObj.visible = true
        iconObj.url = data.url or nil
        local effectIcon = itemObj:GetChild("n7")--特效区域
        effectIcon.visible = true
        effectIcon.url = ""

        if isClick then
            -- if not data.mid then return end  --bxp
            itemObj.data = {data = data}
            itemObj.onClick:Add(self.onClickItem,self)
        end
    else
        itemObj.visible = false
    end
end
--极品属性星级
function ItemMgr:setColorAtti(itemObj,data)
    local colorBNum = 0
    if data.eStar then
        colorBNum = data.eStar
    else
        colorBNum = self:getColorBNum(data)
    end
    local jbsxC2 = itemObj:GetController("c2")
    if colorBNum >= 3 then
        colorBNum = 3
    end
    jbsxC2.selectedIndex = colorBNum
end

--评分比较
function ItemMgr:scoreCompare(itemObj,data)
    local arrow = itemObj:GetChild("n19")
    arrow.visible = false
    local index = data.index or 0
    local type = conf.ItemConf:getType(data.mid)
    local subType = conf.ItemConf:getSubType(data.mid)
    if type == Pack.equipType and not self:isEquipItem(index) and data.isArrow then
        local part = conf.ItemConf:getPart(data.mid)
        local equipData = cache.PackCache:getEquipDataByPart(part)
        if equipData then
            local equipScore = self:getCompreScore(equipData)
            local score = self:getCompreScore(data)
            if score > equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("baoshi_018")
            elseif score < equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("gonggongsucai_137")
            end
        end
    elseif type == Pack.wuxing and data.isArrow and self:isPackItem(index)  then
        local part = conf.ItemConf:getPart(data.mid)
        local equipData = cache.AwakenCache:getEquipByPart(part)
        if equipData then
            local equipScore = self:getCompreScore(equipData)
            local score = self:getCompreScore(data)
            --local score = self:getCompreScore(data)
            if score > equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("baoshi_018")
            elseif score < equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("gonggongsucai_137")
            end
        else
            arrow.visible = true
            arrow.url = ResPath.iconRes("baoshi_018")
        end
    elseif type == Pack.xianzhuang and data.isArrow and self:isPackItem(index)  then
        local part = conf.ItemConf:getPart(data.mid)
        local equipData = cache.PackCache:getXianEquipDataByPart(part)
        if equipData then
            local equipScore = self:getCompreScore(equipData)
            local score = self:getCompreScore(data)
            --local score = self:getCompreScore(data)
            --print(equipScore,"equipScore",score)
            if score > equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("baoshi_018")
            elseif score < equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("gonggongsucai_137")
            end
        else
            arrow.visible = true
            arrow.url = ResPath.iconRes("baoshi_018")
        end
    elseif type == Pack.shengYinType and data.isArrow and self:isShengYinPackItem(index)  then
        local part = conf.ItemConf:getPart(data.mid)
        local equipData = cache.PackCache:getShengYinEquipDataByPart(part)
        -- printt("信息",equipData)
        if equipData then
            local equipScore = self:getShengYinScore(equipData)
            local score = self:getShengYinScore(data)
            -- print("score",score,"equipScore",equipScore)
            if score > equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("baoshi_018")
            elseif score < equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("gonggongsucai_137")
            end
        else
            arrow.visible = true
            arrow.url = ResPath.iconRes("baoshi_018")
        end
     elseif type == Pack.equipawkenType and data.isArrow and self:isShengZhuangPackItem(index)  then
        --print("???? equipawkenType")
        local part = conf.ItemConf:getPart(data.mid)
        local equipData = cache.PackCache:getShengZhuangEquipDataByPart(part)
        if equipData then
            local equipScore = self:getCompreScore(equipData)
            local score = self:getCompreScore(data)
            -- print("score",score,"equipScore",equipScore)
            if score > equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("baoshi_018")
            elseif score < equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("gonggongsucai_137")
            end
        else
            arrow.visible = true
            arrow.url = ResPath.iconRes("baoshi_018")
        end
    elseif type == Pack.elementType and subType ~= 15 and data.isArrow and self:isElementPackItem(index) then--元素subType = 15是道具
        local equipData = cache.PackCache:getEleByType(subType)
        -- print("subType",subType)
        -- printt("信息",equipData)
        if equipData then
            local equipScore = self:getCompreScore(equipData)
            local score = self:getCompreScore(data)
            -- print("score",score,"equipScore",equipScore)
            if score > equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("baoshi_018")
            elseif score < equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("gonggongsucai_137")
            end
        else
            arrow.visible = false
            arrow.url = ResPath.iconRes("baoshi_018")
        end
    elseif type == Pack.dihunType and data.isArrow and self:isDiHunPackItem(index)  then
        local part = conf.ItemConf:getPart(data.mid)
        local _type = conf.ItemConf:getSubType(data.mid)
        local equipData = cache.DiHunCache:getPartInfoByTypeAndPart(_type,part)
        -- printt("信息",equipData)
        if equipData then
            local equipScore = self:getCompreScore(equipData)
            local score = self:getCompreScore(data)
            -- print("score",score,"equipScore",equipScore)
            if score > equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("baoshi_018")
            elseif score < equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("gonggongsucai_137")
            end
        else
            arrow.visible = true
            arrow.url = ResPath.iconRes("baoshi_018")
        end
    elseif type == Pack.shengXiaoType and data.isArrow and self:isShengXiaoPackItem(index) then
        -- 生肖箭头
        local part = conf.ItemConf:getPart(data.mid)
        local _type = conf.ItemConf:getSubType(data.mid)
        local equipData = cache.ShengXiaoCache:getSxPartInfo(_type, part)
        if equipData and equipData.itemInfo.mid > 0 then
            local equipScore = self:getShengXiaoScore(equipData.itemInfo)
            local score = self:getShengXiaoScore(data)
            if score > equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("baoshi_018")
            elseif score < equipScore then
                arrow.visible = true
                arrow.url = ResPath.iconRes("gonggongsucai_137")
            end
        else
            arrow.visible = true
            arrow.url = ResPath.iconRes("baoshi_018")
        end
    end
end
--装备的综合评分
function ItemMgr:getCompreScore(data)
    local score = self:getBaseScore(data) + self:getBirthScore(data) + self:getFujia(data)
    return checkint(score)
end
--圣印的综合评分
function ItemMgr:getShengYinScore(data)
    local score = self:getBaseScore(data) + self:getBirthScore(data) + self:getShengYinSuitScore(data)
    return checkint(score)
end

-- 生肖的综合评分
function ItemMgr:getShengXiaoScore(data)
    local score = self:getBaseScore(data) + self:getBirthScore(data)
    return checkint(score)
end

--装备的基础评分
function ItemMgr:getBaseScore(data)
    local attiData = conf.ItemArriConf:getItemAtt(data.mid)
    local t = GConfDataSort(attiData)
    local str = ""
    local text = ""
    local score = 0--基础评分
    for k,v in pairs(t) do
        score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])--计算综合战斗力
    end
    return checkint(score)
end
--极品评分
function ItemMgr:getBirthScore(data)
    local synScore = 0
    if data.colorAttris and #data.colorAttris > 0 then
        for k,v in pairs(data.colorAttris) do
            synScore = synScore + mgr.ItemMgr:birthAttScore(v.type,v.value)--计算综合评分
        end
    else
        local birthAtt = conf.ItemConf:getBaseBirthAtt(data.mid)--推荐属性
        local isTuijian = true
        if not birthAtt then--固定生成的属性不走推荐
            isTuijian = false
            birthAtt = conf.ItemConf:getBirthAtt(data.mid) or {}
        end
        if not isTuijian then--如果是固定生成的
            for k,v in pairs(birthAtt) do
                if k % 2 == 0 then--值
                    local type,value = birthAtt[k - 1],birthAtt[k]
                    synScore = synScore + mgr.ItemMgr:birthAttScore(type,value)--计算综合评分
                end
            end
        end
    end
    return checkint(synScore)
end
--附加属性评分
function ItemMgr:getFujia(data)
    -- body
    local score = 0
    local condata = conf.ItemArriConf:getItemAtt(data.mid)
    if condata and condata.attach_att then
        for i , j in pairs(condata.attach_att) do
            local _c = conf.FeiShengConf:getFsAttachattr(j)
            local cc  = GConfDataSort(_c)
            if cache.PlayerCache:getDataJie(_c.module_id) >= _c.need_step then
                for k,v in pairs(cc) do
                    score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])--计算综合战斗力
                end
            end
        end
    end
    return checkint(score)
end
--圣印套装积分
function ItemMgr:getShengYinSuitScore(data)
    local score = 0
    local extType = conf.ItemConf:getRedBagType(data.mid)
    if extType then
         --套装激活件数
        local suitAttData = conf.ShengYinConf:getSuitAttrByExtType(extType)--套装属性
        for k,v in pairs(suitAttData) do
            local temp = GConfDataSort(v)
            local suitScore = 0
            for i,j in pairs(temp) do
                suitScore = suitScore + mgr.ItemMgr:baseAttScore(j[1],j[2])--按照基础评分计算
            end
            score = score + suitScore
        end
    end
    return checkint(score)
end

--返回极品属性星星数
function ItemMgr:getColorBNum(data)
    local colorAttris = data.colorAttris
    local colorBNum = 0
    local maxColor = conf.ItemConf:getEquipColorGlobal("max_color")
    if data.colorStarNum then
        colorBNum = data.colorStarNum
    else
        if not colorAttris then
            colorAttris = {}
            local birthAtt = {}
            if not conf.ItemConf:getBaseBirthAtt(data.mid) then--固定生成的属性不走推荐
                birthAtt = conf.ItemConf:getBirthAtt(data.mid) or {}
            else
                local starCount = conf.ItemConf:getEquipStar(data.mid) or 0
                local realMid = conf.ItemConf:getRealMid(data.mid) or 0
                if starCount > 0 and realMid > 0 then--如果是假显示的道具
                    return starCount
                -- else
                    -- birthAtt = conf.ItemConf:getBaseBirthAtt(data.mid) or {}
                end
            end
            for k,v in pairs(birthAtt) do
                if k % 2 == 0 then
                    local atti ={type = birthAtt[k - 1], value = birthAtt[k]}
                    table.insert(colorAttris, atti)
                end
            end
        end
        for k,v in pairs(colorAttris) do
            local confData = conf.ItemConf:getEquipColorAttri(v.type)
            local colorAtt = confData and confData.color or 0
            if colorAtt == maxColor then--最高属性品质
                colorBNum = colorBNum + 1
            end
        end
    end
    --是否是圣印
    local isShengYin = self:isShengYin(data.mid)
    if isShengYin then
        return 0
    end

    -- 是否是生肖
    local isShengXiao = self:isShengXiao(data.mid)
    if isShengXiao then
        return 0
    end
    return colorBNum
end

function ItemMgr:isShengYin(id)
    local flag = false
    -- local shengYinItem = conf.ItemConf:getShengYinItems()
    -- for k,v in pairs(shengYinItem) do
    --     if v.id == id then
    --         flag = true
    --         break
    --     end
    -- end
    local type = conf.ItemConf:getType(id)
    if type == Pack.shengYinType then
        flag = true
    end
    return flag
end

-- 是否是生肖
function ItemMgr:isShengXiao(id)
    local type = conf.ItemConf:getType(id)
    return type == Pack.shengXiaoType
end

--获取物品iconUrl
function ItemMgr:getItemIconUrlByMid(mid)
    local src = conf.ItemConf:getSrc(mid)
    local iconUrl = ResPath.iconRes(tostring(src))
    return iconUrl
end

--单击操作
function ItemMgr:onClickItem(context)
    context:StopPropagation()
    self.data = context.sender.data.data
    self.data.amountScale = nil
    if self:getPackIndex() == Pack.wareIndex then--如果是仓库
        if not self.timer then
            self.timer = mgr.TimerMgr:addTimer(0.03, -1, handler(self, self.update), "ItemMgr")
        end
        local index = self.data.index or 0
        if self.clickItemInfo.index ~= index  then
            self.clickItemInfo.index = index
            self.clickItemInfo.time = os.time()
            self.clickItemInfo.count = 1
        else
            self.clickItemInfo.count = 2
        end
    else

        if self.data and self.data.func then
            self.data.func()
        else
            GSeeLocalItem(self.data)
        end
    end
end

function ItemMgr:update()
    local nowTime = os.time()
    local lastTime = self.clickItemInfo.time
    if nowTime - lastTime >= 0.3 then
        if self.clickItemInfo.count == 1 then
            --TODO 单击处理
            GSeeLocalItem(self.data)
        else
            --TODO 双击处理
            -- if conf.ItemConf:getQuality(self.data.mid) == 7 and conf.ItemConf:getType(self.data.mid) == Pack.equipType then--粉装不能放仓库
            --     GComAlter(language.pack46)
            -- else
                proxy.PackProxy:sendWareTake(self.data)
            -- end
        end
        self:initClickInfo()
        if self.timer then
            mgr.TimerMgr:removeTimer(self.timer)
            self.timer = nil
        end
    end
end
--道具丢弃
function ItemMgr:delete(index,func)
    local param = {type = 2,richtext = mgr.TextMgr:getTextColorStr(language.pack23, 11),sure = function()
        local params = {index = index}
        proxy.PackProxy:sendDelete(params)
        if func then
            func()
        end
    end}
    GComAlter(param)
end

--是不是临时背包的道具
function ItemMgr:isLimitItem(index)
    if index >= Pack.limit and index < Pack.limit + Pack.ware then
        return true
    end
end
--是不是已装备道具
function ItemMgr:isEquipItem(index)
    if index > Pack.equip and index < Pack.limit then
        return true
    end
end
--是不是背包道具
function ItemMgr:isPackItem(index)
    if index > Pack.pack and index < Pack.pack + Pack.ware then
        return true
    end
end
--是不是仓库
function ItemMgr:isWareItem(index)
    if index > Pack.ware and index < Pack.pack then
        return true
    end
end

--是不是仙盟仓库
function ItemMgr:isGangWareItem(index)
    if index > Pack.gang and index < Pack.gang + Pack.ware then
        return true
    end
end
--是不是圣印背包
function ItemMgr:isShengYinPackItem(index)
    if index > Pack.shengYinPack and index < Pack.shengYinEquip then
        return true
    end
end

--是不是圣装背包
function ItemMgr:isShengZhuangPackItem(index)

    if index > Pack.shengZhuangPack and  index < Pack.shengZhuangPack + Pack.ware  then
        return true
    end
end
--是不是元素背包
function ItemMgr:isElementPackItem(index)

    if index > Pack.elementPack and  index < Pack.elementPack + Pack.ware  then
        return true
    end
end
--是不是帝魂背包
function ItemMgr:isDiHunPackItem(index)
    if index > Pack.dihun and  index < Pack.dihun + Pack.ware  then
        return true
    end
end

--是不是生肖背包
function ItemMgr:isShengXiaoPackItem(index)
    if index > Pack.shengXiao and  index < Pack.shengXiao + Pack.ware  then
        return true
    end
end

-------------------------飘道具------------------------
function ItemMgr:addItem(data)
    self.tipTime = Time.getTime()
    table.insert(self.itemList, data)
    if not self.itemTimer then
        self.itemTimer = mgr.TimerMgr:addTimer(0.25, -1, handler(self, self.updateItem),"itemTimer")
    end
    --添加稀有道具提示
    local color = conf.ItemConf:getQuality(data.mid)
    local iType = conf.ItemConf:getType(data.mid)
    if color >= ProsRareColor and iType == Pack.equipType then
        cache.PackCache:addRareEquipData(data)
        if cache.ActivityCache:getTurnTable() or cache.ActivityCache:getSllbChouJiang() then
            return  --幸运转盘&&神炉炼宝 的屏蔽飘道具bxp
        else
            if not mgr.ViewMgr:get(ViewName.RareEquipTipsView) then
               mgr.ViewMgr:openView2(ViewName.RareEquipTipsView)
            end
        end
    end
end

function ItemMgr:updateItem()
    if Time.getTime() - self.tipTime >= ItemTipsTime then
        self.itemList = {}
        if self.itemTimer then
            mgr.TimerMgr:removeTimer(self.itemTimer)
            self.itemTimer = nil
        end
    elseif #self.itemList > 0 then
        local info = table.remove(self.itemList, 1)
        local item = self:createItem()
        self:setItemData(item,info)
        if cache.ActivityCache:getValentineRallfe() or cache.ActivityCache:getSllbChouJiang() or mgr.ViewMgr:get(ViewName.ZhenXiQianKun) then
            return  --情人节抽奖的屏蔽飘道具到背包bxp
        else
            self:addToStage(item,info)
        end

    end
end

function ItemMgr:createItem()
    if #self.objPools > 0 then
        return table.remove(self.objPools, 1)
    else
        return UIPackage.CreateObject("_components" , "ComItemBtn")
    end
end

function ItemMgr:removeItem(item)
    if #self.objPools > 15 then
        item:Dispose()
        item = nil
        return
    end
    item:RemoveFromParent()
    -- GRoot.inst:AddChild(item)
    item.visible = false
    item.alpha = 1
    table.insert(self.objPools, item)
end

function ItemMgr:addToStage(item,info)
    if g_is_banshu then
        return
    end
    local pos = {x = 0, y = 0}
    local view  = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        if self:isLimitItem(info.index) then
            pos = view:getLimitPackPos()--飘到临时背包
        elseif info.isSXBZ then -- 生肖宝藏抽奖道具
            local view1 = mgr.ViewMgr:get(ViewName.KageeViewNew)
            if view1 then
                pos = view1:getBaoZangWarePos()
            end
        else
            pos = view:getPackPos()
        end
    end
    if not self.parent then
        local view = mgr.ViewMgr:get(ViewName.ItemTipView)
        if view then
            self.parent = view.view
        else
            self:removeItem(item)
            return
        end
    end
    self.parent:AddChildAt(item,self.parent.numChildren)
    local viewWith = self.parent.initWidth
    local viewHeight = self.parent.initHeight
    item.visible = true
    item.scaleX = 1
    item.scaleY = 1
    item.x = viewWith / 2
    item.y = viewHeight / 2
    local speed = 1
    item:TweenScale(Vector2.New(0.1, 0.1),speed)
    UTransition.TweenMove(item, Vector2.New(pos.x, pos.y), speed, true,function()
        if self:isLimitItem(info.index) then
            view:playLimitEff()
        elseif info.isSXBZ then -- 生肖宝藏抽奖道具
            local view1 = mgr.ViewMgr:get(ViewName.KageeViewNew)
            if view1 then
                view1:playEff()
            end
        else
            view:playPackEff()
        end
        self:removeItem(item)
    end)
end

function ItemMgr:dispose()
    for i=1,#self.objPools do
        local label = self.objPools[i]
        label:Dispose()
    end
    self.objPools = {}
    self.itemList = {}
end
--检测道具
function ItemMgr:checkPros(data)
    if g_is_banshu then
        return
    end
    local mid = data.mid
    local iType = conf.ItemConf:getType(mid)
    if iType == Pack.prosType then
        local subType = conf.ItemConf:getSubType(mid)
        if subType == Pros.quickuse then--快捷使用道具
            local risePros = {--各成长系统的进阶丹
                [221041040] = 1001,
                [221041041] = 1002,
                [221041042] = 1003,
                [221041043] = 1004,
                [221041044] = 1005,
                [221041046] = 1007,
                [221041047] = 1008,
                [221041048] = 1009,
                [221041049] = 1010,
                [221042817] = 1287,
            }
            local riseModelId = risePros[mid]
            local canSave = false
            if riseModelId then--如果是升阶丹道具
                if cache.PlayerCache:getDataJie(riseModelId) >= RiseProTipJie then
                    canSave = true
                else
                    canSave = false
                end
            else
                canSave = true
            end
            if canSave then
                if not cache.ActivityCache:getValentineRallfe() then --bxp 情人节抽奖不弹快速使用弹窗
                    self:openQuickUse(data)
                end
            end
        elseif subType == Pros.squickuse then--资质丹、潜力丹
            cache.PackCache:setSPros(data)
        elseif subType == Pros.advanced then--进阶丹道具
            local mid = data.mid
            local taskId = AdvProsTask[data.mid]
            local isAdv = false
            if taskId then
                if cache.TaskCache:isfinish(taskId) then
                    isAdv = true
                end
            else
                isAdv = self:getIsAdv(mid)
            end
            if isAdv then
                cache.PackCache:setAdvPros(data)
            end
        end
    elseif iType == Pack.gemType then--宝石
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if not view or view and view.selectedIndex ~= 2 then
            cache.PackCache:setAdvPros(data)
        end
    end
end

function ItemMgr:openQuickUse(data)
    local view = mgr.ViewMgr:get(ViewName.QuickUseView)
    if not view then
        mgr.ViewMgr:openView2(ViewName.QuickUseView, data)
    else
        view:setSaveData(data)
    end
end

function ItemMgr:getIsAdv(mid)
    if mid == 221041050 then--剑神晶体
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if not view then
            return true
        end
    elseif mid == 221041002 then--仙羽进阶丹
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if not view then
            return true
        end
    elseif mid == 221041003 then--神兵进阶丹
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if not view then
            return true
        end
    elseif mid == 221041004 then--仙器进阶丹
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if not view then
            return true
        end
    elseif mid == 221041005 then--法宝进阶丹
        local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
        if not view then
            return true
        end
    elseif mid == 221041006 then--灵羽进阶丹
        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if not view then
            return true
        end
    elseif mid == 221041007 then--灵兵进阶丹
        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if not view then
            return true
        end
    elseif mid == 221041008 then--灵器进阶丹
        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if not view then
            return true
        end
    elseif mid == 221041009 then--灵宝进阶丹
        local view = mgr.ViewMgr:get(ViewName.HuobanView)
        if not view then
            return true
        end
    elseif mid == 221031001 then--升星石
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if not view or (view and view.selectedIndex ~= 1) then
            cache.PackCache:setAdvPros(data)
        end
    end

    for k,v in pairs(cache.PackCache:getAdvPros()) do
        if v.mid and v.mid == mid then
            return false
        end
    end
    return true
end
--检测装备
function ItemMgr:checkEquips(items)
    if g_is_banshu then
        return
    end
    local view = mgr.ViewMgr:get(ViewName.EquipWearTipView)
    if view then
        view:setData(items)
    else
        if cache.ActivityCache:getTurnTable() or cache.ActivityCache:getSllbChouJiang() then
            return  --幸运转盘&&神炉炼宝 的屏蔽装备使用bxp
        else
            mgr.ViewMgr:openView(ViewName.EquipWearTipView, function(view)
                view:setData(items)
            end)
            --local view = mgr.ViewMgr:getData(ViewName.EquipWearTipView)
            -- if view then
            --     view:setData(items)
            -- else
            --     mgr.ViewMgr:openView(ViewName.EquipWearTipView, function(view)
            --         view:setData(items)
            --     end)
            -- end
        end
    end
end
--检测进阶丹
function ItemMgr:checkAdvPros()
    if g_is_banshu then
        return
    end
    if true then--暂时不弹
        return
    end
    if #cache.PackCache:getAdvPros() <= 0 then
        local view = mgr.ViewMgr:get(ViewName.AdvancedTipView)
        if view then
            view:closeView()
        end
    end
    for k,v in pairs(cache.PackCache:getAdvPros()) do
        if v.modelId then
            if v.modelId == 1029 then
                local view = mgr.ViewMgr:get(ViewName.AdvancedTipView)
                if view then
                    view:setData(v)
                else
                    if not g_ios_test then   --EVE 屏蔽小弹窗
                        mgr.ViewMgr:openView2(ViewName.AdvancedTipView, v)
                    end
                end
            end
            break
        else
            local tabType = conf.ItemConf:getTabType(v.mid)
            if type(tabType) ~= "number" then
                proxy.PackProxy:send(1020302,{modelId = tabType[1]})
                break
            end
        end
    end
end
--检测资质丹、潜力丹
function ItemMgr:checkSPros()
    -- if not cache.TaskCache:isfinish(TaskId) then
    --     cache.PackCache:cleanSPros()
    --     return
    -- end
    if g_is_banshu then
        return
    end

    local data = cache.PackCache:getOneSPro()
    if data then
        proxy.PackProxy:send(1040405,{mid = data.mid})
    end
end

function ItemMgr:checkStreng(isTipStren)
    if mgr.FubenMgr:checkScene() then
        return
    end
    local isCanStren = false
    local stengData = cache.PackCache:getForgData(1)
    local strenLev = stengData and stengData.strenLev or 0
    local costMoney = conf.ForgingConf:getStrenMoney(strenLev)--强化所需要的钱
    local money = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0
    if money >= costMoney then
        local playLv = cache.PlayerCache:getRoleLevel()
        local maxLv = playLv
        if maxLv >= conf.ForgingConf:getStrengMaxLv() then
            maxLv = conf.ForgingConf:getStrengMaxLv()
        end
        if playLv < 70 then
            if maxLv - strenLev >= 5 then
                isCanStren = true--满足强化条件
            end
        elseif playLv >= 70 and playLv <= 90 then
            if maxLv - strenLev >= 3 then
                isCanStren = true--满足强化条件
            end
        else
            if maxLv - strenLev >= 1 then
                isCanStren = true--满足强化条件
            end
        end
        if strenLev < maxLv then--强化红点
            cache.PlayerCache:setRedpoint(attConst.A10229, 1)
            mgr.GuiMgr:redpointByID(attConst.A10229,0)
        end
    end
    if isCanStren and isTipStren and cache.TaskCache:isfinish(StrenTask) then--获得绑定铜钱看是否满足强化
        local modelId = 1029
        local isHave = false--是不是已经有强化弹窗了
        for k,v in pairs(cache.PackCache:getAdvPros()) do
            if v.modelId and v.modelId == modelId then
                isHave = true
                break
            end
        end
        if not isHave then
            local isCheck = mgr.ModuleMgr:CheckView({id = modelId})--检测模块配置
            local isNotOpen = cache.PackCache:getNotAdvancedTip(modelId)--不能再次打开
            if isCheck and not isNotOpen then
                local view = mgr.ViewMgr:get(ViewName.AdvancedTipView)
                local data = {modelId = modelId,step = 0,canUp = 1}
                if view then
                    local viewData = view:getData()
                    local viewModelId = viewData and viewData.modelId or 0
                    if viewModelId ~= modelId then
                        cache.PackCache:setAdvPros(data)
                    end
                else
                    cache.PackCache:setAdvPros(data)
                    mgr.ItemMgr:checkAdvPros()
                end
            end
        end
    end
end
--极品属性id,属性值(1001,20)
function ItemMgr:birthAttScore(id,value)
    local attiData = conf.ItemConf:getEquipColorAttri(id)
    local attType = attiData and attiData.att_type or 0
    local score = conf.RedPointConf:getScore(attType) / 10
    return value * score
end

--基础属性类型type,属性值(102,30)
function ItemMgr:baseAttScore(type,value)
    local score = conf.RedPointConf:getScore(type) / 10
    return value * score
end

return ItemMgr