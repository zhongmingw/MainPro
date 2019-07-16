--
-- Author: yr
-- Date: 2017-04-10 20:37:59
--
local donet = {
    [1001] = Skins.zuoqi,--坐骑
    [1002] = Skins.xianyu,--仙羽
    [1003] = Skins.shenbing,--神兵
    [1004] = Skins.xianqi,--仙器
    [1005] = Skins.fabao,--法宝
    [1006] = Skins.huoban,--伙伴
    [1007] = Skins.huobanxianyu,--灵羽
    [1008] = Skins.huobanshenbing,--灵兵
    [1009] = Skins.huobanxianqi,--灵器
    [1010] = Skins.huobanfabao,--灵宝
    [1287] = Skins.qilinbi,--灵宝
}
local XinShouView = class("XinShouView", base.BaseView)

function XinShouView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
    self.uiClear = UICacheType.cacheForever
end

function XinShouView:initView()
    self.mindModule = self.view:GetChild("n2")
    self.icon1 = self.view:GetChild("n5")
    self.icon2 = self.view:GetChild("n6")
    self.icon3 = self.view:GetChild("n12")
    self.icon4 = self.view:GetChild("n14")
    self.t0 = self.view:GetTransition("t0")
    self.t1 = self.view:GetTransition("t1")
    self.t2 = self.view:GetTransition("t2")

    local btnN8 = self.view:GetChild("n9")
    btnN8.onClick:Add(self.onClickCall,self)
    
end

function XinShouView:onClickCall()
    -- body
    if not self.data then
        return
    end

    local tempConf = self:setConfData(self.data.info)
    local param = {info = self.data.info, confData = tempConf} 
    mgr.ViewMgr:openView2(ViewName.GuideXinshouTips, param)
end

--EVE 设置GuideXinshouTips中将要使用的配置表
function XinShouView:setConfData(data)
    -- body
    if not data then
        return
    end 

    local tempConfData = conf.XinShouConf:getRemindModule() --EVE
    local tempConf = {}
    local tempIndex = 1
    local level = cache.PlayerCache:getRoleLevel()
    local data111 = cache.ActivityCache:get5030111()
    local openDay = data111.openDay 
    for k,v in pairs(tempConfData) do
        if v.openday and v.level then
            if not donet[v.module_id] then
                if openDay < v.openday or level < v.level then
                    table.insert(tempConf,v)
                    -- break
                end
            else
                local ccc = cache.PlayerCache:getSkins(donet[v.module_id])
                --if not ccc or ccc == 0 then
                    if openDay < v.openday then
                        table.insert(tempConf,v)
                    else
                        if v.level > level then
                            table.insert(tempConf,v)
                        end
                    end
                --end
            end
        elseif v.taskid then
            if not cache.TaskCache:isfinish(v.taskid) then
                table.insert(tempConf,v)
            end
        elseif v.level then
            if  v.level >  level then
                table.insert(tempConf,v)
            end
        end
        

        -- if k >= data["sort"] then 
        --     tempConf[tempIndex] = v
        --     tempIndex = tempIndex +1
        -- end  
    end
    return tempConf
end

function XinShouView:setData(data,flag)
    -- body
    self.data = data
    
    if data.info.icon1 then
        self.icon1.url = UIPackage.GetItemURL("guide" , data.info.icon1)
    else
        self.icon1.url = nil 
    end
    if data.info.icon2 then
        self.icon2.url = UIPackage.GetItemURL("guide" , data.info.icon2)
    else
        self.icon2.url = nil 
    end
    local _t = cache.ActivityCache:get5030111()
    if _t then
        if data.info.openday then
            --print(data.info.id,"###########")
            if tonumber(data.info.openday) > _t.openDay then
                self.icon1.url = UIPackage.GetItemURL("guide" , data.info.icon3)
            else
                self.icon1.url = UIPackage.GetItemURL("guide" , data.info.icon4)
            end
        end
    end
    

    if data.type == 1 then  --预告功能

        local info = data.info
        if info["res_type"] == 3 then
            self.icon3.visible = true
            self.mindModule.visible = false
        else
            self.icon3.visible = false
            self.mindModule.visible = true
        end
        if self.modelId == info["model_id"] then
            return
        end
        self.modelId = info["model_id"]
        self.icon4.url = nil

        -- print("modelId",self.modelId,info.res_type)
        local parent = self.mindModule:GetChild("n0")
        if self.effectModel then
            mgr.EffectMgr:removeEffect(self.effectModel)
            self.effectModel = nil
        end

        if info["res_type"] == 1 then
            if self.mindModel then

            else
                self.mindModel = self:addModel(self.modelId, parent)
            end
            self.mindModel:setScale(info.scale)
            --self.mindModel:setRotationXYZ(Vector3.New(50,50,50))

            if tonumber(info["id"]) == 2002 then --剑神
                local buffId = conf.AwakenConf:getBuffId(1)
                local buffData = conf.BuffConf:getBuffConf(buffId)
                local model = buffData.bs_args

                self.mindModel:setSkins(self.modelId,model[2],model[3])
            elseif tonumber(info["id"]) == 2004 then --仙羽
                self.mindModel:setSkins(GuDingmodel[5],nil,self.modelId)
            elseif 2008 == tonumber(info["id"]) then --灵羽
                self.mindModel:setSkins(GuDingmodel[2],nil,self.modelId)
            else
                self.mindModel:setSkins(self.modelId)
            end
            if info["rz"] then
                self.mindModel:setRotationXYZ(info["rz"][1],info["rz"][2],info["rz"][3])
            end
            -- print("info.model_bgimg",info.model_bgimg)
            if info.model_bgimg then
                self.icon4.url = UIPackage.GetItemURL("guide" , info.model_bgimg)
                -- print("self.icon4.url",self.icon4.url)
            end
            -- if info.pos then
            --     self.mindModel:setPosition(info["pos"][1], info["pos"][2], info["pos"][3])
            -- else
                self.mindModel:setPosition(parent.actualWidth/2+info.xy[1], -parent.actualHeight-250+info.xy[2], 800)
            -- end
            -- self.mindModel:setPosition(parent.actualWidth/2+info.xy[1], -parent.actualHeight-250+info.xy[2], 800)

        elseif info["res_type"] == 2 then
            if self.mindModel then
                self:removeModel(self.mindModel)
                self.mindModel = nil
            end

            self.effectModel = self:addEffect(self.modelId, parent)
            if info.scale then
                self.effectModel.Scale = Vector3.New(info.scale,info.scale,info.scale)
            else
                self.effectModel.Scale = Vector3.New(50,50,50)
            end

            -- self.effectModel.LocalPosition = Vector3.New(parent.actualWidth/2, -parent.actualHeight/2,800)
            self.effectModel.LocalPosition = Vector3.New(parent.actualWidth/2+info.xy[1], -parent.actualHeight/2+info.xy[2],800)
        elseif info["res_type"] == 3 then
            if self.mindModel then
                self:removeModel(self.mindModel)
                self.mindModel = nil
            end
            
            self.icon3.url = UIPackage.GetItemURL("guide" ,tostring(info["model_id"]) )
            if info.xy then
                self.icon3.x = info.xy[1]
                self.icon3.y = info.xy[2]
            end
        end
        if not flag then
            if info.dongzuo and info.dongzuo == 1 then
                self.t0:Play()
            else
                self.t0:Stop()
            end
        else
            self.t0:Stop()
        end
    elseif data.type == 2 then

    elseif data.type == 3 then

    end
end

function XinShouView:initData(data)
    self.mindModel = nil
    self.effectModel = nil
    if self.data and self.data.info.id ~= data.info.id then --原来的要关闭
        --获得窗口
        self.newdata = data
        self:reset()
    else
        self:setData(data)
    end
end

function XinShouView:reset()
    -- body
    --开始移除
    self.t0:Stop()
    self.t1:Play()
    self:addTimer(0.5,1,function()
        -- body
        --self.t2:Play()
        self:setData(self.newdata,flag)
        self:addTimer(0.5,1,function()
            self.t2:Play()
            self:addTimer(0.5, 1, function()
                -- body
                --plog(self.newdata.info.dongzuo,"self.newdata.info.dongzuo")
                if self.newdata.info.dongzuo and self.newdata.info.dongzuo == 1 then
                    self.t0:Play()
                else
                    self.t0:Stop()
                end
            end)
            
        end)
    end)
end

function XinShouView:clearMindModule()
    self.mindModule.visible = false
    if self.mindModel then
        self:removeModel(self.mindModel)
        self.mindModel = nil
    end
    if self.effectModel then
        mgr.EffectMgr:removeEffect(self.effectModel)
        self.effectModel = nil
    end
    --self:dispose(true)
end

function XinShouView:dispose(clear)
    self:clearMindModule()
    self.super.dispose(self,clear)
end

return XinShouView