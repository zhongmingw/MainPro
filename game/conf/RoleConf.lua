
local RoleConf = class("RoleConf",base.BaseConf)

function RoleConf:ctor()
    self:addConf("role_name")--R-名字库配置
    self:addConf("role_xing")--R-名字库配置
    self:addConf("rolehead")--R-人物头像配置
    self:addConf("pot_global") --Q-潜能配置
    self:addConf("base_property")--R-人物等级配置
    self:addConf("title_type")--T-称号类型配置
    self:addConf("title_att")--T-称号配置
    -- self:addConf("chenghaonums_accordvip")--T-称号对应vip配置
    self:addConf("title_global")--T-称号gobal
    self:addConf("fashion_type")
    self:addConf("fashion_att")
    self:addConf("fashion_star_attr")--时装升星配置
    self:addConf("fashion_model_ui")--时装模型_ui映射
    self:addConf("skin_star_suit")--特殊皮肤升星属性加成
    self:addConf("halo_type_show")--光环类型配置
    self:addConf("halo_type")--光环属性配置
    self:addConf("chat_paopao")--聊天气泡配置
    self:addConf("head_frame")--头像边框配置
    self:addConf("pet_chenghao")--pet_chenghao
    self:addConf("hw_level_up")--头饰经验配置
    self:addConf("hw_item")--头饰属性配置
    self:addConf("hw_global")--头饰全局配置
    self:addConf("skin_collect")--时装藏品信息s


    

end

function RoleConf:getpetChenghaoByJie( id )
    -- body
    return self.pet_chenghao[tostring(id)]
end

--人物名字配置
function RoleConf:getRandName(sex)
    -- body
    --math.randomseed(os.time()) 
    local k1 = math.random(table.nums(self.role_xing))
    local manName = {} --男名
    local womanName = {} --女名
    for k,v in pairs(self.role_name) do
        if v.sex == 1 then
            table.insert(manName,v)
        elseif v.sex == 2 then
            table.insert(womanName,v)
        end 
    end
    local k2 = nil
    local roleName = {}
    if sex == 2 then
        k2 = math.random(table.nums(womanName))
        roleName = womanName
        -- print("名",sex,k2,womanName[k2].id)
    else
        k2 = math.random(table.nums(manName))
        roleName = manName
    end

    local name = ""
    local xing=self.role_xing[tostring(k1)] 
    if xing then 
        name = name .. xing.xing
    end 
    local role_name=self.role_name[tostring(roleName[k2].id)] 
    if role_name then 
        name = name .. role_name.ming
    end 
    return name
end
--人物头像配置
function RoleConf:getHeadConf()
    -- body
    local t = table.values(self.rolehead)
    table.sort(t, function ( a,b )
        -- body
        return a.sort < b.sort 
    end )

    return t
end

function RoleConf:getHeadConfByid(id)
    -- body
    return self.rolehead[tostring(id)]
end

--Q-潜能配置
function RoleConf:getValue(id)
    -- body
    return self.pot_global[id..""]
end
--base_property
function RoleConf:getByRoleLevel(id)
    -- body
    return self.base_property[id..""]
end
--当前等级对应的升级经验
function RoleConf:getRoleExpById(id)
    -- body
    return self.base_property[tostring(id)].att_101
end

function RoleConf:getTitleType()
    local data = {}
    for k,v in pairs(self.title_type) do
        v["open"] = 0
        table.insert(data, v)
    end
    table.sort(data, function(a,b)
        return a.id < b.id
    end)
    return data
end

function RoleConf:getTitileTypeById(Id)
    local data = {}
    for k,v in pairs(self.title_att) do
        if Id == v.type and v.visible  then
            table.insert(data,v)
        end
    end
    table.sort( data, function(a,b)
        return a.sort < b.sort
    end)
    return data
end

function  RoleConf:getTitileGoval( id)
    return self.title_global[id..""]
end

function   RoleConf:getTitilePrice(buycount)
   local data = self.title_global["title_wear_buy_cost"]
   if buycount >= 4 then
        return data[4]
   else
         return data[buycount+1]
   end
end
-- function RoleConf:getTitileTypeByVip(vipId)
--     return self.chenghaonums_accordvip[""..vipId]
-- end

-- function RoleConf:getTitileTypeNextVip(vipId)
--     local data = self.chenghaonums_accordvip[""..vipId]
--     local data1 = {}
--     for k,v in pairs(self.chenghaonums_accordvip) do
--         table.insert(data1, v)
--     end
--     table.sort(data1,function(a,b)
--         if a.vip ~= b.vip then
--             return a.vip < b.vip
--         end
--     end)

--     for k,v in pairs(data1) do
--         if data.num < v.num then
--             return data1[k + 1]
--         end
--     end
  
-- end


function RoleConf:getAllTitle()
    local data = {}
    local hwpsb = {} --特别需求 必须拥有才显示
    for k,v in pairs(self.title_att) do
        if v.visible then
            table.insert(data, v)
        end
        if v.getsee and v.getsee == 1 then
            hwpsb[v.id] = v 
        end
    end
    table.sort( data, function(a,b)
        return a.id < b.id
    end)
    return data,hwpsb
end

function RoleConf:getTitleData(id)
    return self.title_att[id..""]
end

--光环大类
function RoleConf:getHaloType()
    local data = {}
    for k,v in pairs(self.halo_type_show) do
        v.open = 1
        table.insert(data, v)
    end
    table.sort(data, function(a,b)
        return a.id < b.id
    end)
    return data
end

--所有光环
function RoleConf:getAllHalo(haloData)
    local data = {}
    for k,v in pairs(self.halo_type) do
        local flag = true
        if v.hide then
            flag = false
        end
        if haloData then
            for _,halo in pairs(haloData.haloInfos) do
                if v.id == halo.haloId then
                    flag = true
                    break
                end
            end
        end
        if flag then
            table.insert(data, v)
        end
    end
    table.sort( data, function(a,b)
        return a.id < b.id
    end)
    return data
end

function RoleConf:getHaloData(id)
    return self.halo_type[id..""]
end

function RoleConf:getFashType()
    local data = {}
    for k,v in pairs(self.fashion_type) do
        v["open"] = 0
        table.insert(data, v)
    end
    table.sort(data, function(a,b)
        return a.id < b.id
    end)
    return data
end

function RoleConf:getAllFash()
    local sex = GGetMsgByRoleIcon(cache.PlayerCache:getRoleIcon()).sex
    local data = {}
    for k,v in pairs(self.fashion_att) do
        if v.career == sex and v.isShow == 1 then
            table.insert(data, v)
        end
    end
    table.sort( data, function(a,b)
        return a.fashion_type < b.fashion_type
    end)
    return data
end

function RoleConf:getFashShowType()
    local sex = GGetMsgByRoleIcon(cache.PlayerCache:getRoleIcon()).sex
    local data = {}
    local tab = {}
    for k,v in pairs(self.fashion_att) do
        if v.career == sex and v.isShow == 1 then
            tab[v.fashion_type] = true
        end
    end
    for k,v in pairs(tab) do
        table.insert(data,k)
    end
    return data
end

function RoleConf:getFashData(id)
    return self.fashion_att[id..""]
end
--时装升星
function RoleConf:getFashionStarAttr(id)
    return self.fashion_star_attr[tostring(id)]
end

--时装模型_ui映射
function RoleConf:getFashionUiModel(id)
    return self.fashion_model_ui[tostring(id)]
end

--特殊皮肤升星加成
function RoleConf:getSkinsStarAttrData(id,modelId)
    local data = {}
    for k,v in pairs(self.skin_star_suit) do
        if math.floor(tonumber(v.id)/100000) == modelId then
            for _,fashionId in pairs(v.skins) do
                if id == fashionId then
                    table.insert(data,v)
                    break
                end
            end
        end
    end
    table.sort(data,function(a,b)
        return a.id < b.id
    end)
    return data
end

--聊天气泡
function RoleConf:getChatPaoPao(t)
    local data = {}
    for k,v in pairs(self.chat_paopao) do
        local flag = true
        if v.hide then
            flag = false
        end
        for headId,starNum in pairs(t.stars) do
            if v.id == headId then
                flag = true
                break
            end
        end
        if flag then
            table.insert(data,v)
        end
    end
    return data
end
--聊天边框
function RoleConf:getChatFrame(t)
    local data = {}
    for k,v in pairs(self.head_frame) do
        local flag = true
        if v.hide then
            flag = false
        end
        for headId,starNum in pairs(t.stars) do
            if v.id == headId then
                flag = true
                break
            end
        end
        if flag then
            table.insert(data,v)
        end
    end
    return data
end
--根据聊天边框id获取边框icon
function RoleConf:getFrameIconById(id)
    local icon = nil
    for k,v in pairs(self.head_frame) do
        if tonumber(id) == tonumber(v.id) then
            icon = v.icon
            break
        end
    end
    return icon
end

function RoleConf:getFrameById(id)
    return self.head_frame[tostring(id)]
end

--根据聊天气泡id获取气泡icon
function RoleConf:getBubbleIconById(id)
    local icon = nil
    for k,v in pairs(self.chat_paopao) do
        if tonumber(id) == tonumber(v.id) then
            icon = v.icon
            break
        end
    end
    return icon
end
function RoleConf:getBubbleById(id)
    return self.chat_paopao[tostring(id)]
end

--头饰大类
function RoleConf:getHeadType()
    local data = {}
    table.insert(data,{name = self.hw_global["hw_show_type"], open = 1 })
    return data
end

--已有头饰
function RoleConf:getHadHead(headData)
    local data = {}
    for _,head in pairs(headData) do
        if head.hwId then
            table.insert(data, head)          
        end    
    end
    table.sort( data, function(a,b)
        return a.id < b.id
    end)
    return data
end

--获得所有头饰(已拥有的置前)
function RoleConf:getAllHead()

    local data = {}
    for k,v in pairs(self.hw_item) do
        table.insert(data, v)
    end
    table.sort( data, function(a,b)
        return a.id < b.id
    end)
    -- if headData then
    --     for k,v in pairs(data) do
    --         for k1,v1 in pairs(headData.hwInfos) do
    --             if v1.hwId == v.id then
    --                 v.sort = v.id
    --                 -- v.wear = v1.wear
    --                 -- v.hwId = v1.hwId
    --             else
    --                 v.sort = 0
    --             end
    --         end
    --     end
    --     table.sort( data, function(a,b)
    --         if a.sort ~= b.sort then
    --             return a.sort < b.sort
           
    --         end
    --     end)
    -- end
    -- printt("排序后",data)
    -- local data = {}
    -- for k,v in pairs(self.hw_item) do
    --     local flag = true
    --     if headData then
    --         for _,head in pairs(headData.hwInfos) do
    --             if v.id == head.hwId then
    --                 flag = true
    --                 break
    --             end
    --         end
    --     end
    --     table.insert(data, v)
    -- end
    -- table.sort( data, function(a,b)
    --     return a.id < b.id
    -- end)
     return data
end

function RoleConf:getHeadData(id)
    return self.hw_item[id..""]
end

function RoleConf:getHeadValue(id)
    return self.hw_global[id..""]
end

function RoleConf:getHeadLevel(level)
   
    for k,v in pairs(self.hw_level_up) do 
         -- print("11",math.floor(v.id/1000),v.id/1000,id,v.id%100,level,"~~~~~~~",v.id)
        -- if math.floor(v.id/1000)  == tonumber(id) and v.id%1000 == level then
        if v.id == level then
            return v
        end
    end
end



--头饰更换节点
function RoleConf:CheckisHead(eId)
    for k,v in pairs(self.hw_item) do
    
        if eId == v.effect_id then
            return v.headtype
        end
    end
    -- print("找不到effect_id")
end

--时装藏品信息
function RoleConf:getCollectionInfo()
    local data = {}
    for k,v in pairs(self.skin_collect) do
        if not v.ishide or v.ishide ~= 1 then
            table.insert(data,v)
        end
    end
    return data
end


return RoleConf