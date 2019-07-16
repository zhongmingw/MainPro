local SceneConf = class("SceneConf",base.BaseConf)

function SceneConf:ctor()
    self:addConf("scene_config")
    self:addConf("map_lian")
    self:addConf("map_effect")

    --场景技能
    self:addConf("scene_skill")
end

function SceneConf:getSceneSkill(id)
    -- body
    if not id then
        return nil 
    end

    return self.scene_skill[tostring(id)]
end

function SceneConf:getSceneById(id)
    return self.scene_config[id..""]
end

function SceneConf:getMapEffect(mapId)
    return self.map_effect[tostring(mapId)]
end

--EVE 获取所有需要在世界地图显示的场景的id
function SceneConf:getSceneIdAll()
    -- body
    local listScenesId = {}

    for k,v in pairs(self.scene_config) do
        if v.map_order then
            listScenesId[v.map_order] = {map_id = v.map_id, 
                                        name_icon=v.name_icon, 
                                        map_grade=v.map_grade} 
        end
    end

    return listScenesId
end

function SceneConf:getMap(mapId)
    -- body
    local t = {}
    for k ,v in pairs(self.map_lian) do
        for i , j in pairs(v.maplian) do
            if j == mapId then
                table.insert(t,v)
                break
            end
        end
    end

    return t
end

function SceneConf:getMapButMain(mapId)
    -- body
    for k ,v in pairs(self.map_lian) do
        if tonumber(k) ~= 1 then
            for i , j in pairs(v.maplian) do
                if tonumber(j) == tonumber(mapId) then
                    return self.map_lian[k].maplian
                end
            end
        end
    end

    return nil 
end

function SceneConf:getMapById(id)
    -- body
    return self.map_lian[id..""]
end

function SceneConf:getMapLian( param )
    -- body
    if type(param) == "table" then
        for k ,v in pairs(self.map_lian) do
            local flag = {}
            for i , j in pairs(param) do
                local index = table.indexof(v.maplian,tonumber(j))
                if index then
                    table.insert(flag,index)
                end
            end

            if #flag == 2 then
                return v.maplian
            end


            -- local flag = {}
            -- for i , j in pairs(param) do
            --     plog("j",j)
            --     for h ,g in pairs(v.maplian) do
            --         plog("g",g)
            --         if g == j then
            --             table.insert(flag,v.maplian)
            --             break
            --         end
            --         plog("#flag",#flag)
            --         if #flag == #param then
            --             return v.maplian
            --         end
            --     end
            -- end
        end

        return nil 
    end

    return nil
end

function SceneConf:getSceneConf()
    return self.scene_config
end
--问鼎数据
function SceneConf:getWenDings()
    local lists = {}
    for _,v in pairs(self.scene_config) do
        if mgr.FubenMgr:isWenDing(v.id) then
            table.insert(lists, v)
        end
    end
    return lists
end
--返回所有剑神殿
function SceneConf:getAwakenBoss()
    local lists = {}
    for _,v in pairs(self.scene_config) do
        if mgr.FubenMgr:isAwakenWar(v.id) then
            table.insert(lists, v)
        end
    end
    table.sort(lists,function(a,b)
        return a.id < b.id
    end)
    return lists
end
--返回仙尊boss
function SceneConf:getXianzunBoss()
    local lists = {}
    for _,v in pairs(self.scene_config) do
        if mgr.FubenMgr:isXianzunBoss(v.id) then
            table.insert(lists, v)
        end
    end
    table.sort(lists,function(a,b)
        return a.id < b.id
    end)
    return lists
end

function SceneConf:getJianshengHouhu()
    -- body
    local lists = {}
    for _,v in pairs(self.scene_config) do
        if mgr.FubenMgr:isJianShengshouhu(v.id) then
            table.insert(lists, v)
        end
    end
    table.sort(lists,function(a,b)
        return a.id < b.id
    end)
    return lists
end

--根据地图类型返回所有对应类型的地图的ID
function SceneConf:getAllScenesIdByKind(kind)
    -- body
    local tempConf = {}

    for k,v in pairs(self.scene_config) do
        if v.kind == kind then
            table.insert(tempConf, v.id)
        end
    end

    return tempConf
end

return SceneConf