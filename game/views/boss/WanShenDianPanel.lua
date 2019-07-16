--
-- Author: Your Name
-- Date: 2018-09-12 14:37:19
--万神殿
local WanShenDianPanel = class("WanShenDianPanel",import("game.base.Ref"))

local existsTime = conf.WanShenDianConf:getValue("tt_exists_interval")--图腾存在时间
local refreshTime = conf.WanShenDianConf:getValue("tt_refresh_interval")--图腾刷新时间

function WanShenDianPanel:ctor(parent)
    self.parent = parent
    self.view = parent.view:GetChild("n34")
    self:initView()
end

function WanShenDianPanel:initView()
    --场景列表
    self.sceneListView = self.view:GetChild("n11")
    self.sceneListView:SetVirtual()
    self.sceneListView.itemRenderer = function(index,obj)
        self:cellSceneData(index, obj)
    end
    self.sceneListView.onClickItem:Add(self.onClickSceneItem,self)
    --当前场景boss列表
    self.bossList = self.view:GetChild("n4")
    self.bossList:SetVirtual()
    self.bossList.itemRenderer = function(index,obj)
        self:bossCellData(index, obj)
    end
    self.bossList.onClickItem:Add(self.onClickItem,self)

    --奖励列表
    self.awardsList = self.view:GetChild("n5")
    self.awardsList:SetVirtual()
    self.awardsList.itemRenderer = function(index,obj)
        self:awardsCellData(index, obj)
    end

    self.bgImg = self.view:GetChild("n3")

    --怪物模型
    self.modelPanel = self.view:GetChild("n7")

    --进入场景按钮
    local warBtn = self.view:GetChild("n6")
    warBtn.onClick:Add(self.onClickWar,self)
    --剩余次数
    self.leftCountTxt = self.view:GetChild("n23")
    --刷新或消失倒计时
    self.timeTxt = self.view:GetChild("n25")
    self.decTxt1 = self.view:GetChild("n24")
    --怪物灵力列表
    self.monsterAttrList = self.view:GetChild("n21")
    self.monsterAttrList:SetVirtual()
    self.monsterAttrList.itemRenderer = function(index,obj)
        self:AttrCellData(index, obj)
    end
    --人物灵力查看按钮
    self.roleCheckBtn = self.view:GetChild("n27")
    self.roleCheckBtn.onClick:Add(self.onClickCheckRole,self)
    --怪物灵力查看按钮
    self.monsterCheckBtn = self.view:GetChild("n28")
    self.monsterCheckBtn.onClick:Add(self.onClickCheckMonster,self)
end

-- 变量名：leftCount   说明：剩余次数
-- 变量名：ttEndTime   说明：图腾消失时间<场景，消失时间>
function WanShenDianPanel:setData(data)
    printt("万神殿信息>>>>>>>>>>>>>",data)
    self.bgImg.url = UIItemRes.bossWorld
    self.leftCount = data.leftCount
    self.leftCountTxt.text = data.leftCount
    self.sceneData = {}--场景列表
    self.bossData = {}--boss列表
    self.sceneId = nil
    self.endTime = nil
    for k,v in pairs(data.ttEndTime) do
        -- if not self.endTime then
        --     self.endTime = v
        -- end
        table.insert(self.sceneData,{sId = k,endTime = v})
    end
    if #self.sceneData > 0 then
        table.sort(self.sceneData,function(a,b)
            if a.sId ~= b.sId then
                return a.sId < b.sId
            end
        end)
        self.sceneListView.numItems = #self.sceneData
        local cell = self.sceneListView:GetChildAt(0)
        cell.onClick:Call()
    else
        self.sceneListView.numItems = 0
        self.bossList.numItems = 0
    end

    if self.timer then
        self.parent:removeTimer(self.timer)
        self.timer = nil
    end
    self.timer = self.parent:addTimer(1, -1, handler(self, self.onTimer))
end

function WanShenDianPanel:onTimer()
    if self.timeTxt and self.endTime then
        if self.endTime > mgr.NetMgr:getServerTime() then
            self.decTxt1.text = language.wanshendian05
            self.timeTxt.text = GTotimeString(self.endTime - mgr.NetMgr:getServerTime())
        else
            self.decTxt1.text = language.wanshendian04
            local nextTime = (self.endTime + refreshTime - existsTime) - mgr.NetMgr:getServerTime()
            if nextTime <= 0 then
                self.endTime = self.endTime + refreshTime
            else
                self.timeTxt.text = GTotimeString(nextTime)
            end
        end
    end
end

function WanShenDianPanel:cellSceneData(index,obj)
    local data = self.sceneData[index+1]
    if data then
        local sId = data.sId
        local sConf = conf.SceneConf:getSceneById(sId)
        local nameTxt = obj:GetChild("title")
        local crossImg = obj:GetChild("n5")
        crossImg.visible = false
        nameTxt.text = sConf.name
        if sConf.cross == 2 then
            crossImg.visible = true
        end
        print("场景信息>>>>>>>>>>",data.sId)
        obj.data = {sId = data.sId,cross = sConf.cross,endTime = data.endTime}
    end
end

function WanShenDianPanel:onClickSceneItem(context)
    local data = context.data.data
    if data then
        self.bossList.numItems = 0
        self.bossData = {}
        self.endTime = data.endTime
        if self.endTime then
            if self.endTime > mgr.NetMgr:getServerTime() then
                self.decTxt1.text = language.wanshendian05
                self.timeTxt.text = GTotimeString(self.endTime - mgr.NetMgr:getServerTime())
            else
                self.decTxt1.text = language.wanshendian04
                local nextTime = (self.endTime + refreshTime - existsTime) - mgr.NetMgr:getServerTime()
                self.timeTxt.text = GTotimeString(nextTime)
            end
        end
        local sId = data.sId
        self.sceneId = sId
        local sConf = conf.SceneConf:getSceneById(sId)
        -- print("怪物信息>>>>>>>>>>",sConf.monsters)
        for k,v in pairs(sConf.monsters) do
            local bossConf = conf.MonsterConf:getInfoById(v[2])
            table.insert(self.bossData,{bossConf = bossConf,cross = data.cross})
        end
        self.bossList.numItems = #self.bossData
        if #self.bossData > 0 then
            local cell = self.bossList:GetChildAt(0)
            cell.onClick:Call()
        end
    end
end

function WanShenDianPanel:bossCellData(index,obj)
    local data = self.bossData[index+1]
    if data then
        obj:GetChild("n4").visible = false
        obj:GetChild("n5").visible = false
        obj:GetChild("n10").visible = false
        local nameTxt = obj:GetChild("n8")
        local lvTxt = obj:GetChild("n7")
        local crossImg = obj:GetChild("n9")
        local bossConf = data.bossConf
        crossImg.visible = false
        nameTxt.text = bossConf.name
        lvTxt.text = bossConf.level
        if data.cross and data.cross == 2 then
            crossImg.visible = true
        end
        obj.data = bossConf
    end
end

function WanShenDianPanel:onClickItem(context)
    local data = context.data.data
    if data then
        --设置boss模型
        local modelObj = self.parent:addModel(data.src,self.modelPanel)--添加模型
        modelObj:setPosition(self.modelPanel.actualWidth/2,-self.modelPanel.actualHeight-200,500)
        modelObj:setRotation(180)
        modelObj:setScale(100)
        --boss相克属性设置
        local attrData = {att_340 = 0,att_341 = 0,att_342 = 0,att_343 = 0,att_344 = 0}
        for k,v in pairs(data) do
            if attrData[k] then
                attrData[k] = attrData[k] + v
            end
        end
        self.attrTab = GConfDataSort(attrData)
        self.bossName = data.name
        self.monsterAttrList.numItems = #self.attrTab
        --boss奖励
        self.awards = data.normal_drop
        self.awardsList.numItems = self.awards and #self.awards or 0
        cache.FubenCache:setChooseMonsterId(data.id)
    end
end

function WanShenDianPanel:awardsCellData(index,obj)
    local awardData = self.awards[index + 1]
    local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
    GSetItemData(obj, itemData, true)
end

function WanShenDianPanel:AttrCellData( index,obj )
    if self.attrTab then
        local data = self.attrTab[index+1]
        if data then
            local oppositeTab = {
                [340] = 343,--火克金
                [341] = 340,--金克木
                [342] = 344,--土克水
                [343] = 342,--水克火
                [344] = 341,--木克土
            }
            local proName = conf.RedPointConf:getProName(oppositeTab[data[1]])
            local value = data[2]
            obj:GetChild("n0").text = proName .. " " .. value
        end
    end
end

function WanShenDianPanel:onClickWar()
    if self.sceneId then
        if self.leftCount > 0 then
            local proId = 221043201
            local itemCount = cache.PackCache:getPackDataById(proId).amount --入场券数量
            local ybNum = conf.WanShenDianConf:getValue("ticket_cost")[2]
            local costItem = conf.WanShenDianConf:getCostItem(self.sceneId)
            local vip = cache.PlayerCache:getVipLv()
            local confData = conf.VipChargeConf:getVipAwardById(vip)
            local count = confData and confData.vip_tequan[9][2] or 0
            local keyConf = conf.WanShenDianConf:getCostNum(self.sceneId)
            local index = (keyConf and(count - self.leftCount + 1) > #keyConf) and #keyConf or (count - self.leftCount + 1)
            local needCount = keyConf and keyConf[index] or 1 --需要的入场券数量
            local data = {}
            data.itemInfo = {mid = proId,amount = itemCount,bind = 1}
            data.text1 = language.fuben216_2
            data.text2 = string.format(language.fuben217_2,needCount)
            if itemCount >= needCount then
                data.text3 = language.fuben174
            else
                local needYb = ybNum*(needCount - itemCount)
                data.text3 = string.format(language.fuben173,needYb)
            end
            data.sure = function ()
                if itemCount >= needCount then
                    mgr.FubenMgr:gotoFubenWar2(self.sceneId)
                else
                    local needYb = ybNum*(needCount - itemCount)
                    local param = {}
                    param.type = 2
                    param.richtext = string.format(language.fuben175,needYb)
                    param.sure = function()
                        cache.FubenCache:setChooseBossId(self.mosterId)
                        mgr.FubenMgr:gotoFubenWar2(self.sceneId)
                    end
                    GComAlter(param)
                end
            end
            mgr.ViewMgr:openView(ViewName.XianYuJinDiTips,function(view)
                view:setData(data)
            end)
        else
            GComAlter(language.ingotcopy06)
        end
    end
end

function WanShenDianPanel:onClickCheckMonster()
    if self.attrTab then
        mgr.ViewMgr:openView2(ViewName.MonsterLingLiTips,{attrTab = self.attrTab,name = self.bossName})
    end
end

function WanShenDianPanel:onClickCheckRole()
    mgr.ViewMgr:openView2(ViewName.MonsterLingLiTips,{attrTab = {},name = language.wanshendian10,type = 1})
end

function WanShenDianPanel:clear()
    if self.timer then
        self.parent:removeTimer(self.timer)
        self.timer = nil
    end
    self.bgImg.url = ""
    self.sceneListView.numItems = 0
    self.bossList.numItems = 0
    self.sceneId = nil
end

return WanShenDianPanel