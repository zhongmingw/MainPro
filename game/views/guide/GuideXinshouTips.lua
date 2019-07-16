--
-- Author: 
-- Date: 2017-10-19 16:23:37
-- Remarks: EVE 添加动画t0，用于模型的浮动效果

local GuideXinshouTips = class("GuideXinshouTips", base.BaseView)

local notFloat = {  --EVE 不可漂浮的模块
    ["3030301_yd"] = true,
    ["4040701_yd"] = true,
    ["3040101_yd"] = true,
    ["3010701_yd"] = true,
    ["3050101_yd"] = true,
    ["3030101_yd"] = true,
    [3050401] = true, --宠物不可漂浮
}

function GuideXinshouTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function GuideXinshouTips:initView()
    local btnClose = self.view:GetChild("n4")
    btnClose.onClick:Add(self.onCloseView,self)

    self.panel = self.view:GetChild("n2")

    local dec1 = self.view:GetChild("n5")
    dec1.text = language.guide04

    local dec1 = self.view:GetChild("n7")
    dec1.text = language.guide05

    self.dec1 = self.view:GetChild("n6")
    self.dec2 = self.view:GetChild("n8")

    self.icon = self.view:GetChild("n10")

    self.t0 = self.view:GetTransition("t0") --EVE

    self.previewList = self.view:GetChild("n13") --EVE 预览列表
    self.previewList.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.previewList.onClickItem:Add(self.onPreviewListItem,self) 
    self.previewList.numItems = 0

    self.falg = true
end

function GuideXinshouTips:initData(data)
    -- body
    self.icon.url = nil 
    self.mindModel = nil
    self.effectModel = nil 
    self.confData = data.confData 

    if not data then
        self:onCloseView()
        return
    end

    self:setData(data.info)
    self:setPreviewList()  
end

--EVE
function GuideXinshouTips:setPreviewList() 

    local sizeList = #self.confData
    if sizeList > 5 then 
        self.previewList.numItems = 5
    else
        self.previewList.numItems = sizeList
    end
end
--EVE
function GuideXinshouTips:celldata(index, obj) 
    local info = self.confData[index+1]

    obj:GetChild("n2").text = info["item"]

    if index == 0 and self.falg then 
        obj.selected = true
    elseif self.falg then 
        obj.selected = false
    end 
 
    local tempData = {info = info, confData = self.confData}
    obj.data = tempData
end
--EVE 注意列表点击时数据的传递
function GuideXinshouTips:onPreviewListItem(context)
    local cell = context.data
    local data = cell.data

    self.falg = false

    self:setData(data.info)
    --self:initData(data)
    -- print("BIUBIUBIUBIUBIUBIUBIUBIU~~~~~~~~~~~~~~~~~",data.info["model_id"])
end

function GuideXinshouTips:initModel(info)
    -- body
    local info = info
    self.modelId = info["model_id"]

    if not notFloat[self.modelId] then  --EVE 漂浮控制
        self.t0:Play()
    else
        self.t0:Stop()
        -- self.panel.xy = self.originalPos 
    end


    if self.mindModel then
        self:removeModel(self.mindModel)
        self.mindModel = nil 
    end
    if self.effectModel then
        self:removeUIEffect(self.effectModel)
        self.effectModel = nil
    end
    if info.res_type == 3 then
        self.icon.url = UIPackage.GetItemURL("guide" ,tostring(info["model_id"]))
        return
    elseif info.res_type == 2 then
        self.icon.url = nil 
        self.effectModel = self:addEffect(self.modelId, self.panel)
        self.effectModel.Scale = Vector3.New(50,50,50)
        self.effectModel.LocalPosition = Vector3.New(self.panel.actualWidth/2+info.xy[1]-30, -self.panel.actualHeight/2+info.xy[2]-50,800)
        return
    else
        -- print("info.model_bgimg",info.model_bgimg)
        if info.model_bgimg then
            self.icon.url = UIPackage.GetItemURL("guide" , info.model_bgimg)
        else
            self.icon.url = nil
        end
    end
    -- print("当前的模型ID",self.modelId, type(self.modelId))

    if self.mindModel then
    else
        self.mindModel = self:addModel(self.modelId, self.panel)
    end
    local scale = info and info.scale_tips or 60

    self.mindModel:setScale(scale)

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

    if info.pos then
        self.mindModel:setPosition(info["pos"][1], info["pos"][2], info["pos"][3])
    else
        self.mindModel:setPosition(self.panel.actualWidth/2+info.xy_tips[1],
                        -self.panel.actualHeight-250+info.xy_tips[2],
                        800)
    end
end

function GuideXinshouTips:setData(data)
    self:initModel(data)

    self.dec1.text = data.desc
    --检查开启条件
    local str = ""
    if data.taskid then
        local confData = conf.TaskConf:getTaskById(data.taskid)
        str = string.format(language.guide06,confData.name or "")
        self.dec2.text = mgr.TextMgr:getTextColorStr(str, 14)
    elseif data.openday then
        local _t = cache.ActivityCache:get5030111()
        if _t then
            --if tonumber(self.data.openday) > _t.openDay then
            local _ss = string.format(language.guide09,data.openday)
            if data.openday > _t.openDay then
                str = str .. mgr.TextMgr:getTextColorStr(_ss,14)
            else
                str = str .. _ss
            end
            if data.level then
                str = str.."\n"
                local cc = ""
                cc = cc .. string.format(language.guide07,data.level)
                if data.level > cache.PlayerCache:getRoleLevel() then
                    cc = cc .. string.format(language.guide08,data.level - cache.PlayerCache:getRoleLevel())
                    str = str .. mgr.TextMgr:getTextColorStr(cc,14)
                else
                    str = str .. cc
                end
            end

            self.dec2.text = str
        else
            self.dec2.text = ""
        end
    elseif data.level then

        local cc = ""
        cc = cc .. string.format(language.guide07,data.level)
        if data.level > cache.PlayerCache:getRoleLevel() then
            cc = cc .. string.format(language.guide08,data.level - cache.PlayerCache:getRoleLevel())
            str = str .. mgr.TextMgr:getTextColorStr(cc,14)
        else
            str = str .. cc
        end

        self.dec2.text = str
    end
end

function GuideXinshouTips:onCloseView()
    -- body
    self.falg = true --列表Item选中状态保存

    self:closeView()
end

return GuideXinshouTips