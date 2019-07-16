--
-- Author: yr
-- Date: 2017-07-25 16:13:34
-- 记录需要切换场景清理的资源

local ResCache = class("ResCache")

function ResCache:ctor()
    self.monsterCache = {}
end

function ResCache:addMonsterCache(res)
    self.monsterCache[res] = 1
end

function ResCache:getMonsterCache()
    return self.monsterCache
end


function ResCache:clear()
    for k, v in pairs(self.monsterCache) do
        if g_var.gameFrameworkVersion >= 2 then
            UnitySceneMgr:ClearMonsterPool(k, false, false)
        else
            UnitySceneMgr:ClearMonsterPool(k, true, false)
        end
    end
    
    self.monsterCache = {}
end


return ResCache