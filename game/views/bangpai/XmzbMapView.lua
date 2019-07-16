--
-- Author: 
-- Date: 2017-12-01 15:58:46
--

local XmzbMapView = class("XmzbMapView", base.BaseView)

function XmzbMapView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.xmzOurPlayers = {}--我方人员
    self.xmzOtherPlayers = {}--敌方人员
    self.crystalStatues = {}--水晶
    self.camps = {}--阵营
end

function XmzbMapView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.view:GetChild("n3").text = language.xmhd15
    self.view:GetChild("n4").text = string.format(language.xmhd16, conf.XmhdConf:getValue("xianmeng_max_res"))
    self.curMap = self.view:GetChild("n2")
    self.view:GetChild("n6").url = UIItemRes.xmhd03[1]
    self.view:GetChild("n7").url = UIItemRes.xmhd03[2]
    self.view:GetChild("n8").url = UIItemRes.xmhd03[0]
    self.view:GetChild("n9").text = language.xmhd32[1]
    self.view:GetChild("n10").text = language.xmhd32[2]
    self.view:GetChild("n11").text = language.xmhd32[3]
end

function XmzbMapView:initData(data)
    local sId = cache.PlayerCache:getSId()  
    local sConf = conf.SceneConf:getSceneById(sId)
    local map_id = sConf["map_id"] or 0
    self.curMap.icon = "res/maps/s"..map_id.."/s"..map_id.."_s"
    self:updateWarMap()
end

--部分战斗地图需要实时知道信息的
function XmzbMapView:updateWarMap()
    local sId = cache.PlayerCache:getSId()

    self.mapSendFunc = nil--请求的方法
    local sConf = conf.SceneConf:getSceneById(sId)
    if sConf and sConf["size"] then--放大比例
        self.scaleX = sConf["size"][1] / 620
        self.scaleY = sConf["size"][2] / 383
    else
        plog("@当前地图没有配置SID",cache.PlayerCache:getSId())
    end
    local campBorn = sConf and sConf.born or {}
    if campBorn then
        local warData = cache.XmzbCache:getTrackData()
        local campType = warData and warData.campType or 1--我方阵营位置下标
        local OURCAME,OTHERCAME = 1,2--记录自己的阵营位置下标
        if campType == 1 then
            OURCAME,OTHERCAME = 1,2
        else
            OURCAME,OTHERCAME = 2,1
        end
        local OUR,OTHER = 1,2--记录自己阵营对象

        if not self.camps[OUR] then--我方阵营
            self.camps[OUR] = self:createObj()
            self.curMap:AddChildAt(self.camps[OUR],self.curMap.numChildren)
        end
        self.camps[OUR].icon = UIItemRes.xmhd04[1]
        local pos = campBorn[OURCAME]
        self.camps[OUR].x = pos[1] / self.scaleX
        self.camps[OUR].y = pos[2] / self.scaleY

        if not self.camps[OTHER] then--敌方阵营
            self.camps[OTHER] = self:createObj()
            self.curMap:AddChildAt(self.camps[OTHER],self.curMap.numChildren)
        end
        self.camps[OTHER].icon = UIItemRes.xmhd04[2]
        local pos = campBorn[OTHERCAME]
        self.camps[OTHER].x = pos[1] / self.scaleX
        self.camps[OTHER].y = pos[2] / self.scaleY
    end
    local pendants = conf.XmhdConf:getValue("crystal_pos_state")
    if pendants then
        for k,v in pairs(pendants) do
            local crystalStatue = self.crystalStatues[k]
            if not crystalStatue then
                crystalStatue = self:createObj()
                crystalStatue.icon = UIItemRes.xmhd03[v[3]]
                self.crystalStatues[k] = crystalStatue
                self.curMap:AddChildAt(crystalStatue,self.curMap.numChildren)
            end
            crystalStatue.x = v[1] / self.scaleX
            crystalStatue.y = v[2] / self.scaleY
        end
    end
end

function XmzbMapView:createObj()
    return UIPackage.CreateObject("bangpai", "ThingObj")
end

return XmzbMapView