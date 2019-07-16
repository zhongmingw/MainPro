--
-- Author: 
-- Date: 2017-09-06 20:26:06
--

local GuideWSSB = class("GuideWSSB", base.BaseView)

function GuideWSSB:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2--bxp原层级太高，测试反应遮挡其他页面
    self.drawcall = false
end

function GuideWSSB:initView()
    self.c1 = self.view:GetController("c1")
    self.groud = self.view:GetChild("n7")
end

function GuideWSSB:initData(data)
    -- body
    local x = 0
    local y = 0 
    -- if data.id == 1114 then --百倍豪礼
    --     self.c1.selectedIndex = 2
    --     x = -24
    --     y = 0
    if data.id == 1059 then --投资计划
        self.c1.selectedIndex = 0
        x = -39
        y = 0
    elseif data.id == 1060 then -- 聚宝盆
        self.c1.selectedIndex = 1
        x = -36
        y = 0
    elseif data.id == 1241 then--鲜花榜
        local actData = cache.ActivityCache:get5030111()
        if (actData.acts[1089] and actData.acts[1089] == 1) or (actData.acts[1090] and actData.acts[1090] == 1) then
            self.c1.selectedIndex = 3
        elseif (actData.acts[5003] and actData.acts[5003] == 1) then
            self.c1.selectedIndex = 11
        end
        x = -36
        y = 0
    elseif data.id == 1249 then--神器排行
        self.c1.selectedIndex = 4
        x = -36
        y = 0
    elseif data.id == 1245 then--世界杯
        self.c1.selectedIndex = 5
        x = -36
        y = 0
    elseif data.id == 1253 then--充值返利
        self.c1.selectedIndex = 6
        x = -36
        y = 0
    elseif data.id == 1264 then--摇钱树
        self.c1.selectedIndex = 7
        x = -36
        y = 0
    elseif data.id == 1268 then--寻仙探宝
        self.c1.selectedIndex = 8
        x = -36
        y = 0
    elseif data.id == 1269 or data.id == 1270 then--剑灵出世
        self.c1.selectedIndex = 9
        x = -36
        y = 0
    elseif data.id == 1302 then--疯狂返利
        self.c1.selectedIndex = 10
        x = -36
        y = 10
    elseif data.id == 1333 then--双倍返利
        x = -36
        y = 10

        self.c1.selectedIndex = 12
    end

    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        local pairs = pairs
        local topos
        for k ,v in pairs(view.TopActive.btnlist) do
            for i , j in pairs(v) do
                if j.data and j.data.id == data.id then
                    topos = j.xy + j.parent.xy
                    break
                end
            end
        end
        if topos then
            self.groud.xy = topos
            self.groud.x = self.groud.x - 150 + x
            self.groud.y = self.groud.y + 65 + y
        end
    end

    self:addTimer(15, 1, function( ... )
        -- body
        self:closeView()
    end)
end

function GuideWSSB:setData(data_)

end

return GuideWSSB