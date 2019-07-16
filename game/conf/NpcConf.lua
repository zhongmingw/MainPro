local NpcConf = class("NpcConf",base.BaseConf)

function NpcConf:ctor()
    self:addConf("npc_config")
end

function NpcConf:getNpcById(id)
    return self.npc_config[id..""]
end

function NpcConf:getNpcByMapId(id)
    local npc={}
    for k,v in pairs(self.npc_config) do
        if v.map_id==id then  --EVE 过滤假NPC和采集器（假NPC和采集物没名字）and v.name and v.name ~= " " 
            table.insert(npc,v)
        end
    end
    return npc
end

return NpcConf