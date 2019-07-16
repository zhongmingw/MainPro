--
-- Author: 
-- Date: 2017-09-15 17:43:51
--
--聊天管理
local ChatMgr = class("ChatMgr")

function ChatMgr:ctor()
    
end

function ChatMgr:onClickLink(strText)--玩家道具查看超链接
    local strTab = string.split(strText,ChatHerts.PROINFOHERT)
    local roleId = strTab[2]
    local mid = tonumber(strTab[3])
    local index = tonumber(strTab[4])
    local amount = tonumber(strTab[5])
    local sendMainSrvId = tonumber(strTab[6])
    local colorStr = strTab[7]
    local colorTab = string.split(colorStr,",")
    local colorAttris = {}--极品属性
    local level = tonumber(strTab[8])
    -- print("等级>>>>>>>>>>@@@@@",level)
    -- printt("道具信息返回>>>>>>",strTab)
    self:ckProsInfo(roleId,mid,index,amount,sendMainSrvId,colorStr,nil,level)
end

function ChatMgr:onClickLink2(strText)--查看玩家信息超链接
    local t = {}
    local i = 0
    while true do
        i = string.find(strText, ChatHerts.PLAYINFOHERT, i+1)
        if i == nil then break end
        table.insert(t, i)
    end

    local roleId = string.sub(strText, t[1] + 1,t[2] - 1)
    local roleName = string.sub(strText, t[2] + 1,t[3] - 1)
    local roleIcon = string.sub(strText, t[3] + 1,t[4] - 1)
    local sendRoleLev = string.sub(strText, t[4] + 1,t[5] - 1)
    -- plog(roleId,roleName,roleIcon,sendRoleLev)
    if roleId ~= " " then--打开聊天道具信息
        if roleId ~= cache.PlayerCache:getRoleId() then
            local params = {roleId = roleId,roleName = roleName,level = sendRoleLev,pos = {x = 150,y = 0},roleIcon = roleIcon,chouren = true,trade = true}
            mgr.ViewMgr:openView(ViewName.FriendTips,function(view)
                view:setData(params)
            end)
        end
    end
end
--公会帮主喊话超链guidId^
function ChatMgr:onClickLink3(strText)
    local guidId = string.gsub(strText,ChatHerts.GANGHERT,"")
    if guidId then
        if cache.PlayerCache:getGangId() .. ""~= "0" then --已经是帮怕i成员
            GComAlter(language.bangpai112)
            return
        end

        local param = {}
        param.gangIds = {guidId}
        param.reqType = 0
        proxy.BangPaiProxy:sendMsg(1250201,param)
        GComAlter(language.bangpai113)
        
    end
end
--公会帮主协助超链^roleId^boxIndex
function ChatMgr:onClickLink4(strText)
    local t = {}
    local i = 0
    while true do
        i = string.find(strText, ChatHerts.GANGHELPHERT, i+1)
        if i == nil then break end
        table.insert(t, i)
    end
    local roleId = string.sub(strText, t[1] + 1,t[2] - 1)
    local boxIndex = string.sub(strText,t[2] + 1,t[3] - 1)
    -- plog(roleId,boxIndex)
    if roleId.."" == cache.PlayerCache:getRoleId() then
        GComAlter(language.bangpai122)
    else
        local param = {}
        param.roleId = roleId
        param.boxIndex = boxIndex
        proxy.BangPaiProxy:sendMsg(1250312,param)
    end

end
--坐标超链接
function ChatMgr:onClickLink5(strText)
    local strList = string.split(strText,ChatHerts.POSHERT)--分离服务器名字
    local roleId = strList[2]
    if roleId ==cache.PlayerCache:getRoleId() then
        GComAlter(language.chatSend25)
    end
    local sId = strList[3]
    local posx = strList[4]
    local posy = strList[5]
    local point = Vector3.New(posx, gRolePoz, posy)
    local sConf = conf.SceneConf:getSceneById(sId)
    if sConf then
        mgr.TaskMgr:goTaskBy(sId,point)
    end
end
--跨服邀请入队
function ChatMgr:onClickLink6(strText)
    if mgr.FubenMgr:checkScene() then
        GComAlter(language.gonggong41)
        return
    end
    local msg = strText
    local teamId = string.split(msg,ChatHerts.KUAFUTEAM)[2]
    proxy.KuaFuProxy:sendMsg(1380101,{teamId = tonumber(teamId)})
end
--跨服三界争霸
function ChatMgr:onClickLink7(strText)
    if mgr.FubenMgr:isKuaFuWar(cache.PlayerCache:getSId()) then
        --移动过去
        local xy = string.split(strText,ChatHerts.KUASEPC)
        if #xy == 4 then
            local point = Vector3.New(tonumber(xy[2]), gRolePoz, tonumber(xy[3]))
            mgr.JumpMgr:findPath(point, 40, function()
            -- body
            end)
        end
    else
        --不是跨服三界争霸场景
        GComAlter(language.kuafu142)
    end
end

--系统道具
function ChatMgr:onLinkSystemTeam(strText)
    local strTab = string.split(strText,ChatHerts.SYSTEMTEAM)
    local teamId = strTab[2] or 0
    proxy.TeamProxy:send(1300111,{teamId = teamId})
end
--世界boss仙盟招募
function ChatMgr:onLinkBossZmSystem(strText)
    local strTab = string.split(strText,ChatHerts.SYSTEWORLDBOSS)
    local sceneId = strTab[2] or 0
    local monsterId = strTab[3] or 0
    if mgr.FubenMgr:isWorldBoss(sceneId) then--世界boss
        modelId = 1049
    elseif mgr.FubenMgr:isBossHome(sceneId) then--boss之家
        modelId = 1128
    elseif mgr.FubenMgr:isXianyuJinDi(sceneId) then--仙域禁地
        modelId = 1135
    elseif mgr.FubenMgr:isKuafuWorld(sceneId) then
        modelId = 1191
    elseif mgr.FubenMgr:isWuXingShenDian(sceneId) then
        modelId = 1266
    elseif mgr.FubenMgr:isFsFuben(sceneId) then
        modelId = 1324
    elseif mgr.FubenMgr:isShenShou(sceneId) then
        modelId = 1337
    elseif mgr.FubenMgr:getJudeWarScene(sceneId,SceneKind.shenshoushengyu) then
        modelId = 1353
    elseif mgr.FubenMgr:isTaiGuXuanJing(sceneId) then
        modelId = 1378
    
    end
    --print("id",id,monsterId,sceneId)
    GOpenView({id = modelId,childIndex = tonumber(monsterId),sceneId = tonumber(sceneId)})
end

--系统道具
function ChatMgr:onLinkSystemPros(strText)
    local strTab = string.split(strText,ChatHerts.SYSTEMPRO)
    local roleId = strTab[2]
    local mid = tonumber(strTab[3])
    local index = tonumber(strTab[4])
    local amount = 1
    local sendMainSrvId = tonumber(strTab[5])
    local colorStr = strTab[6]
    self:ckProsInfo(roleId,mid,index,amount,sendMainSrvId,colorStr)
end

--抽奖记录道具
function ChatMgr:onLinkRecordPros(strText)
    local strTab = string.split(strText,ChatHerts.SYSTEMPRO)
    local roleId = 0
    local mid = tonumber(strTab[2])
    local index = 0
    local amount = 1
    local sendMainSrvId = 0
    local colorStr = strTab[3] or "0,0"
    self:ckProsInfo(roleId,mid,index,amount,sendMainSrvId,colorStr,true)
end

function ChatMgr:ckProsInfo(roleId,mid,index,amount,sendMainSrvId,colorStr,isNotDz,level)
    local colorTab = string.split(colorStr,",")
    local colorAttris = {}--极品属性
    for k,v in pairs(colorTab) do
        if k % 2 == 0 then
            local id = colorTab[k - 1]
            if id ~= "0" then
                local data = {type = id,value = tonumber(colorTab[k])}
                table.insert(colorAttris, data)
            end
        end
    end
    if sendMainSrvId == cache.PlayerCache:getServerId() then
        sendMainSrvId = 0
    end
    local data = {roleId = roleId, mid = tonumber(mid),level = tonumber(level), index = tonumber(index),amount = tonumber(amount),svrId = sendMainSrvId,colorAttris = colorAttris}
    
    local type = conf.ItemConf:getType(data.mid)
    local isSuit = conf.ItemConf:getSuitmodel(data.mid) --是不是时装
    if isSuit and type ~= Pack.equipawkenType then 
        mgr.ViewMgr:openView(ViewName.FashionTipsView,function(view)
            view:setData(data)
        end)
        return
    end
    if type == Pack.equipType then
        mgr.ViewMgr:openView(ViewName.EquipTipsView,function(view)
            view:setData(data,true,isNotDz)
        end)
    elseif type == Pack.equippetType or type == Pack.shenshouEquipType then
        mgr.ViewMgr:openView(ViewName.EquipPetTipsView,function(view)
            view:setData(data)
        end)
    elseif type == Pack.runeType then--符文
        mgr.ViewMgr:openView2(ViewName.RuneIntroduceView, data)
    elseif  type == Pack.wuxing then --加五行bxp
        mgr.ViewMgr:openView(ViewName.EquipWuXing,function(view)
            view:setData(data)
        end)
    elseif type == Pack.xianzhuang then
        mgr.ViewMgr:openView(ViewName.EquipXianZhuangTipsView,function(view)
            view:setData(data)
        end) 
    elseif type == Pack.shengYinType then
        mgr.ViewMgr:openView(ViewName.EquipShengYin,function(view)
            local t = clone(data)
            t.index = 0
            view:setData(t)
        end) 
    elseif type == Pack.equipawkenType then
        mgr.ViewMgr:openView(ViewName.EquipShengZhuang,function(view)
            local t = clone(data)
            t.index = 0
            view:setData(t)
        end) 
    else
        mgr.ViewMgr:openView(ViewName.PropMsgView,function(view)
            view:setData(data,true)
        end)
    end
end
--系统广播超链接跳转
function ChatMgr:onClickLinkGo(strText)
    local tab = string.split(strText,",")
    if #tab > 0 then
        local id = tab[1] or 1
        local childIndex = tab[2] or 1
        local grandson = tab[3] or 1
        print("跳转链接>>>>>>>>>>>>",strText,id,childIndex)
        GOpenView({id = tonumber(id),childIndex = tonumber(childIndex),grandson = tonumber(grandson)})
    end
end
--宠物信息查看
function ChatMgr:onClickTextSee( text )
     -- body
    local ss = string.split(text,"=")
    if #ss <= 1 then
        return 
    end
    if ss[1] == ChatHerts.PETHERTCHAT then --宠物信息
        local _t = string.split(ss[2],",")
        --petId , roleId , petRoleId , svrId
        local param = {}
        param.roleId = _t[2]
        param.petRoleId = tonumber(_t[3])
        param.svrId = tonumber(_t[4])
        param.viewType = 0
        proxy.PetProxy:sendMsg(1490110,param)
    end
end


--聊天显示文本解析
function ChatMgr:getSendText(content,roleId)
    local k = 0
    local lt = {}
    for i=1,2 do
        k = string.find(content, "|",k+1)
        if k == nil then break end
        table.insert(lt, k)
    end
    if #lt == 2 and lt[1] == 1 and lt[2] - lt[1] > 1 then--检测是否是骰子数
        local text = tonumber(string.sub(content,2,lt[2] - 1))
        if text and text <= 99 then
            local str = mgr.TextMgr:getTextColorStr(text, 14)
            return language.chatSend13[1]..str..language.chatSend13[2]
        end
    end
---------------------------------------
    local i = 0
    local t = {}
    while true do
        i = string.find(content, "@@", i+1)
        if i == nil then break end
        table.insert(t, i)
    end
    if t[1] == 1 and #t == 5 then--坐标
        local roleId = string.sub(content, t[1] + 2,t[2] - 1)
        local sId = string.sub(content, t[2] + 2,t[3] - 1)
        local condata = conf.SceneConf:getSceneById(sId)
        local posName = condata and condata.name or "" 
        local posx = string.sub(content, t[3] + 2,t[4] - 1)
        local posy = string.sub(content, t[4] + 2,t[5] - 1)
        hert = "+"..roleId.."+"..sId.."+"..posx.."+"..posy.."+"
        local text = posName.."("..posx..","..posy..")"
        return mgr.TextMgr:getTextColorStr(text, globalConst.ChatMgr01, hert)
    end
    
---------------------------------------
    local sendText = content
    for phiz in string.gmatch(sendText, "#%d%d") do
        local phizId = string.sub(phiz,2,3)
        local phizText = mgr.TextMgr:getPhiz(phizId)
        sendText = string.gsub(sendText,phiz,phizText)
    end

    -- print("解析字符串>>>>>>>",sendText)
    local chatStr = mgr.TextMgr:getProsText(sendText,roleId)
    --继续解析
    
    local dd = ChatHerts.PETHERT.."(.+)"..ChatHerts.PETHERT
    local info = ""
    for phiz in string.gmatch(chatStr,dd) do
        local text = mgr.TextMgr:getPetText(phiz)
        chatStr = string.gsub(chatStr,phiz,text)
    end
    chatStr = string.gsub(chatStr,ChatHerts.PETHERT,"")
    --

    -- print("chatStr",chatStr)
    return chatStr
end

--字符串之间的相似度计算
function ChatMgr:editDistance(source,target)
    if source == target then return 1 end
    local slen = string.utf8len(source)
    local tlen = string.utf8len(target)
    local d = {}
    for i=1,slen + 1 do--初始化
        d[i] = {}
        for j=1,tlen + 1 do
            d[i][j] = 0
        end
    end
    for i=1,slen + 1 do
        d[i][1] = i - 1
    end
    for j=1,tlen + 1 do
        d[1][j] = j - 1
    end
    local temp
    for i=2,slen + 1 do
        for j=2,tlen + 1 do
            local si = i - 1
            local tj = j - 1
            if GUtf8sub(source,si,1) == GUtf8sub(target,tj,1) then
                temp = 0
            else 
                temp = 1
            end
            local insert = d[i][j - 1] + 1
            local del = d[i - 1][j] + 1
            local update = d[i - 1][j - 1] + temp
            local num = math.min(insert,del)
            d[i][j] = math.min(num,update)
        end
    end
    local num = d[slen + 1][tlen + 1]
    -- print("相似度",1-num/math.max(slen,tlen))
    return 1-num/math.max(slen,tlen)
end

function ChatMgr:getTypeData(chatType)
    local data = {}
    if chatType == ChatType.world or chatType == ChatType.near then--世界和附近
        return cache.ChatCache:getWorldData()
    elseif chatType == ChatType.private then--私聊的
        return cache.ChatCache:getPrivateData()
    elseif chatType == ChatType.friend then--好友的
        return cache.ChatCache:geFriendData()
    elseif chatType == ChatType.team then--队伍的
        return cache.ChatCache:geTeamData()
    elseif chatType == ChatType.gang then
        return cache.ChatCache:getGangData()
    end
    return {content = ""}
end

--根据服务器频道选择客户端界面频道
function ChatMgr:getChooseChannel(chatType)
    if chatType == ChatType.system or chatType == ChatType.horseLamp or chatType == ChatType.boss or chatType == ChatType.kuafueTeam or chatType == ChatType.kuafuBoss or chatType == ChatType.sjzbSepc or chatType == ChatType.sjzbBoss or chatType == ChatType.sjzbCar or chatType == ChatType.sjzbBossDead or chatType == ChatType.fubenTeam  or ChatType.kuafuSystem then--系统的
        return 0
    elseif chatType == ChatType.world or chatType == ChatType.gangRecruit or chatType == ChatType.horn then--世界的
        return 1
    elseif chatType == ChatType.near then
        return 2
    elseif chatType == ChatType.private then--私聊的
        return 6
    elseif chatType == ChatType.friend then--好友的
        return 5
    elseif chatType == ChatType.team then--队伍的
        return 4
    elseif chatType == ChatType.gang or chatType == ChatType.ganghelp or chatType == ChatType.gangWarehouse
    or chatType == ChatType.gangHd or chatType == ChatType.worldBossSystem or chatType == ChatType.xmshDice or chatType == ChatType.xmFlame then--放在仙盟频道的
        return 3
    end
end
--仙盟圣火骰子
function ChatMgr:sendxianMenDice(nums)
    local sendMsg = ""
    for k,v in pairs(nums) do
        sendMsg = sendMsg..v.."*"
    end
    sendMsg = "*"..sendMsg
    local params = {
        type = ChatType.xmshDice,
        content = sendMsg,
        isVoice = 0,
        voiceStr = "",
        tarName = ""
    }
    proxy.ChatProxy:send(1060101,params)
end
--返回仙盟圣火的骰子数的字符
function ChatMgr:getXmshDice(msg)
    local tab = string.split(msg,"*")
    local str = ""
    if string.find(msg,"*") then
        local num = 0
        for i=2,4 do
            local url = ResPath.diceRes(tonumber(tab[i]))
            num = num + tonumber(tab[i])
            -- print("点数",tab[i],url)
            str = str .. mgr.TextMgr:getImg(url,30,32)
        end
        str = language.bangpai174 .. str .. string.format(language.bangpai175,num)
    else
        str = msg
    end
    return str
end
--外部调用发送聊天
function ChatMgr:sendChat(sendMsg,chatType)
    local params = {
        type = chatType,
        content = sendMsg,
        isVoice = 0,
        voiceStr = "",
        tarName = ""
    }
    proxy.ChatProxy:send(1060101,params)
end
--设置获取聊天道具字符   <a href='|#roleId|#mid|#index|#svrId|#prop|'>#ename</a>
function ChatMgr:getChatPro(data)
    local hert = "<a href='|%s|%s|%s|%s|%s|'>%s</a>"
    local roleId = cache.PlayerCache:getRoleId()
    local mId = data.mid
    local index = data.index
    local svrId = cache.PlayerCache:getServerId()
    local colorAttris = data.colorAttris or {}
    local colorStr = ""
    for k,v in pairs(colorAttris) do
        if k ~= #colorAttris then
            colorStr = colorStr..v.type..","..v.value..","
        else
            colorStr = colorStr..v.type..","..v.value
        end
    end
    if colorStr == "" then
        colorStr = "0,0"
    end
    local itemName = conf.ItemConf:getName(mId)
    local itemHertStr = string.format(hert, roleId, mId, index, svrId, colorStr, itemName)
    local color = conf.ItemConf:getQuality(mId)
    return mgr.TextMgr:getQualityStr1(itemHertStr, color)
end

return ChatMgr