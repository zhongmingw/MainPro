--
-- Author: 
-- Date: 2018-10-30 11:03:34
--

local KuaFuLveDuo = class("KuaFuLveDuo", base.BaseView)


function KuaFuLveDuo:ctor()
    self.super.ctor(self)
   
end

function KuaFuLveDuo:initView()
    local  closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.btn = {}
    for i = 10,13 do
        local btn = self.view:GetChild("n"..i)
        btn.onClick:Add(self.onChoose,self)
        table.insert(self.btn,btn)
    end
end
-- 1   int8    变量名: bossStatu  说明: 精英boss1:已死亡;世界boss1:已死亡,2未刷新,3已刷新
-- 2   int32   变量名: nextRefreshTime    说明: 下次刷新时间
-- 3   int32   变量名: sceneId    说明: 场景id
-- 4   string  变量名: lastKillName   说明: 上一次击杀者的名字
-- 5   int32   变量名: monsterId  说明: 怪物id
-- 6   string  变量名: serverName 说明: 服务器名
function KuaFuLveDuo:initData(data)
    -- printt("总数据",data)
    self.data = data 
    local data_only_kuafu = {}
    for k,v in pairs(data) do
        if v.serverName ~= "" then
            table.insert(data_only_kuafu,v)
        end
    end

    table.sort(data_only_kuafu,function(a,b)
        local asId = a.agentServerId or 0
        local bsId = a.agentServerId or 0
        if asId ~= bsId then
            return asId < bsId
        end
    end)
    local mData = {}
    for k,v in pairs(data) do
        if v.agentServerId == 0 then
            v.agentServerId = 1
        end
        if not mData[v.agentServerId] then
            mData[v.agentServerId] = {}
        end

        table.insert(mData[v.agentServerId],v)
    end
    local data1 = {}
    for k,v in pairs(mData) do
        table.insert(data1, v)
    end
    for k,v in pairs(self.btn) do
        local data = data1[k]
        local name = v:GetChild("n6")
        local bossNum = v:GetChild("n9")
        v.touchable = true
        if data  then
            local survenum = 0 
            for k,v in pairs(data) do
                if v.bossStatu ~= 1 then
                    survenum = survenum + 1
                end
            end
            name.text = "服务器名："..data[1].serverName or ""
            bossNum.text = "剩余BOSS："..survenum
            v.data = data
        else
            v.touchable = false
            bossNum.text = ""
            name.text = "服务器名：无"
        end
    end
end


function  KuaFuLveDuo:onChoose(context)
    local data = context.sender.data
    local sId = data[1].sceneId
    --等级限制
    local index = sId%1000 - 1
    local openLv = conf.FubenConf:getBossValue("cross_tgxj_boss_lvs")[index] or 0
    if cache.PlayerCache:getRoleLevel() < openLv then
        GComAlter(string.format(language.tgxj01, openLv))
        return
    end
    mgr.ViewMgr:openView2(ViewName.TaiGuXuanJingBossList,data)

end
return KuaFuLveDuo