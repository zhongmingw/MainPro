--
-- Author: 
-- Date: 2019-01-02 15:19:50
--
--h活动日程
local pos1 = {71,288,498,704}
local Cj1001 = class("Cj1001",import("game.base.Ref"))

function Cj1001:ctor(parent,id)
    self.moduleId = id
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Cj1001:onTimer()
    -- body

    if not self.data then return end
    local severTime =  mgr.NetMgr:getServerTime()
    if severTime >= self.data.actEndTime then
        local  view = mgr.ViewMgr:get(ViewName.ChunJieView2019)
        if view then
            view:closeView()
        end
    end
end

function Cj1001:addMsgCallBack( data )
    self.data = data
    printt("春节活动日程",data)
    self.day = self:checkCurDay(data.curDay)
    for k,v in pairs(self.images) do
        if self.day>= k then
            v.visible = true
        else
            v.visible = false
        end
    end
    for k,v in pairs(self.btn) do
        v.onClick:Clear()
        local c1  = v:GetController("c1")
        if self.day == k then
            self.image.x = pos1[k]
            c1.selectedIndex = 1 
        elseif k < self.day then
            c1.selectedIndex = 0
        elseif k > self.day then
            c1.selectedIndex = 2
        end
        v.data = {state = c1.selectedIndex}
        v.onClick:Add(self.onClickGet,self)
    end
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self.parent:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function Cj1001:initView()
    self.btn = {}
    self.image = self.view:GetChild("n17")
    for i=18,21 do
        local btn = self.view:GetChild("n"..i)
        table.insert(self.btn, btn)
        btn:GetChild("icon").url =  UIItemRes.chunjie2019_01[i-17]
        btn:GetChild("n5").url =  UIItemRes.chunjie2019_01[i-13]
        btn:GetChild("n11").text = language.chunjie2019_04[i-17]
        local model = btn:GetChild("n4")
        local modelConf = conf.ChunJieConf2019:getModelData(i-17)
        local modelObj = self.parent:addModel(modelConf.model_id,model)
        modelObj:setPosition(modelConf.transform[1] ,modelConf.transform[2],modelConf.transform[3])
        modelObj:setRotationXYZ(modelConf.rotation[1],modelConf.rotation[2],modelConf.rotation[3])
        modelObj:setScale(modelConf.scale)
    end
    self.images = {}
    for i=25,28 do
        local image = self.view:GetChild("n"..i)
        table.insert(self.images, image)
    end
end
  

function Cj1001:onClickGet( context )
    local data = context.sender.data
    if data.state == 0 then
        GComAlter(language.chunjie2019_02)
    elseif data.state == 1 then
        local data = {}
        data.id = self.parent.confdata[2].id
        self.parent:initData(data)
    elseif data.state == 2 then
        GComAlter(language.chunjie2019_03)
        
    end

end


function Cj1001:checkCurDay(curday)
    if curday <= 3 then
        return 1
    elseif curday > 3 and  curday <=6 then
        return 2
    elseif curday > 6 and  curday <=9 then
        return 3
    elseif curday > 9 and  curday <=12 then
        return 4
    end
    print("不是在春节活动时间内")
end

return Cj1001