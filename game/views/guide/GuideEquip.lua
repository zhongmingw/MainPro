--
-- Author: 
-- Date: 2017-04-25 19:29:18
--

local GuideEquip = class("GuideEquip", base.BaseView)

function GuideEquip:ctor()
    self.super.ctor(self)
    --self.isBlack = true
    self.uiLevel = UILevel.level4
end

function GuideEquip:initData(data)
    -- body
    self.icon.xy = self.iconpos
    self.moveTime = 1.5 --移动时间
    self.stopTime = 2.0 --停留时间

    self.data = data
    self:setData()
end

function GuideEquip:initView()
    self.icon = self.view:GetChild("n23") 
    self.iconpos = self.icon.xy
    self.effect = self.view:GetChild("n24") 

    self.iocnlist = {}
    self.frame = {}
    for i = 1 , 10 do
        table.insert(self.iocnlist,self.view:GetChild("icon"..i))
        table.insert(self.frame,self.view:GetChild("frame"..i))
    end
end

function GuideEquip:setData(data_)
    for k , v in pairs(self.data.data) do
        local src = conf.ItemConf:getSrc(v.mid)
        local pos = conf.ItemConf:getPart(v.mid) 
        local color = conf.ItemConf:getQuality(v.mid)
        self.iocnlist[pos].url = ResPath.iconRes(src)-- UIPackage.GetItemURL("_icons" , ""..src)
        self.frame[pos].url = UIItemRes.beibaokuang[color] or UIItemRes.beibaokuang[1]
    end
    local src = conf.ItemConf:getSrc(self.data.mId)
    local pos = conf.ItemConf:getPart(self.data.mId) 
    local color = conf.ItemConf:getQuality(self.data.mId)
    --plog("self.data.mId",self.data.mId,"pos",pos)
    if not pos then
        plog("任务奖励 不是装备@策划")
    end
    self.frame[pos].url = UIItemRes.beibaokuang[color] or UIItemRes.beibaokuang[1]
    self.icon.url =ResPath.iconRes(src) -- UIPackage.GetItemURL("_icons" , ""..src)
    local movetime = self.moveTime
    self.icon:TweenMove(self.iocnlist[pos].xy,movetime)

    self:addTimer(movetime, 1, function()
        -- body
        
        local effect,durition = self:addEffect(4020106,self.effect)
        effect.LocalPosition = Vector3.New(self.effect.width/2,-self.effect.height/2,500)
    end)

    self:addTimer(movetime+self.stopTime, 1, function()
        -- body
        self:closeView()
        --GgoToMainTask()
    end)
end

return GuideEquip