--
-- Author: bxp
-- Date: 2018-10-29 11:53:55
--八门
local table = table
local pairs = pairs

local EightGatesPanel = class("EightGatesPanel",import("game.base.Ref"))


function EightGatesPanel:ctor(mParent)
    self.mParent = mParent
    self:initView()
end


function EightGatesPanel:initView()
    self.view = self.mParent.view:GetChild("n23")
    self.view:GetChild("n19").text = language.eightgates03
    --背包
    self.listView = self.view:GetChild("n6")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellPackData(index, obj)
    end
    self.listView.numItems = 0
    -- --精炼
    -- local refineBtn = self.view:GetChild("n1")
    -- refineBtn.onClick:Add(self.onBtnCallBack,self)

    --强化
    local strengBtn = self.view:GetChild("n2")
    strengBtn.onClick:Add(self.onBtnCallBack,self)
    self.strengRedImg = strengBtn:GetChild("red")

    --分解
    local strengBtn = self.view:GetChild("n7")
    strengBtn.onClick:Add(self.onBtnCallBack,self)
    self.btnList = {}
    for i=1,8 do
        local btn = self.view:GetChild("n8"):GetChild("n"..i)
        btn.data = {pos = i}
        btn.onClick:Add(self.onClickBtn,self)
        table.insert(self.btnList,btn)
    end
    --技能列表
    self.skillList = {}
    for i=1,4 do
        local skillBtn = self.view:GetChild("n"..(11+i))
        skillBtn.onClick:Add(self.onClickSkillBtn,self)
        table.insert(self.skillList,skillBtn)
    end
end

function EightGatesPanel:addMsgCallBack(data)
    if data.msgId == 5610103 then
        -- self.info = data.info
        --已镶嵌的元素
        self.elementData = {}
        for k,v in pairs(data.info) do

        end
    elseif data.msgId == 5610101 then--开启

    elseif data.msgId == 5610102 then--穿脱

    elseif data.msgId == 5610104 then--分解
    
    end
    self:setData()
    self:refreshRed()
    local view = mgr.ViewMgr:get(ViewName.AwakenView)
    if view then
        view:refreshRed()
    end
end

function EightGatesPanel:setData()
    local data = cache.AwakenCache:getEightGatesData()
    self.info = data.info
    self.eightGatesInfo = {}
    for k,v in pairs(self.info) do
        if v.eleInfo then
            self.eightGatesInfo[k] = v
        end
    end
    -- printt("八门信息",self.eightGatesInfo)
    self:setPackData()
    self:setBtnListInfoMsg()

    self:setSkillInfoMsg()
end

function EightGatesPanel:refreshRed()
    self.strengRedImg.visible = GGetBMStrengRed() > 0  and true or false
end

function EightGatesPanel:setPackData()
    self.packData = {}
    -- local data = cache.PackCache:getElementEquipData()
    -- printt("已镶嵌的元素",data)
    local data = cache.PackCache:getElementPackData()
    -- printt("元素背包",data)
    for k,v in pairs(data) do
        table.insert(self.packData,v)
    end    
    table.sort(self.packData,function(a,b)
        local aconf = conf.ItemConf:getItem(a.mid)
        local bconf = conf.ItemConf:getItem(b.mid)
        
        local asubType = aconf.sub_type
        local bsubType = bconf.sub_type

        local asort = aconf.sort
        local bsort = bconf.sort
        if asort ~= bsort then
            return asort < bsort 
        elseif asubType ~= bsubType then
            return asubType < bsubType 
        end
    end)
    local num = math.max((math.ceil(#self.packData/30)*30),30)
    self.listView.numItems = num 
end

--  int32   变量名: state  说明: 门的状态（0未解锁 1已解锁未镶嵌 2镶嵌）
--设置元素镶嵌信息
function EightGatesPanel:setBtnListInfoMsg()
    local btnList = clone(self.btnList)
    --未开启的门
    self.notOpenGates = {}
    for k,v in pairs(btnList) do
        local frame = v:GetChild("n0")
        local icon = v:GetChild("n1")
        local lockImg = v:GetChild("n2")
        local title = v:GetChild("n3")
        local jieIcon = v:GetChild("n5")
        local confData = conf.EightGatesConf:getGatesInfoById(v.data.pos)
        title.text = confData.name
        --门状态
        local state = self.eightGatesInfo[v.data.pos].state
        v.data.state = state
        local mid = self.eightGatesInfo[v.data.pos].eleInfo.mid
        
        lockImg.visible = false
        if state == 0 then
            lockImg.visible = true
            self.notOpenGates[k] = {btn = v,confData = confData}
            jieIcon.url = ""
        elseif state == 1 then
            icon.url = ""
            jieIcon.url = ""
        elseif state == 2 then
            if mid ~= 0 then
                local confData = conf.ItemConf:getItem(mid)
                jieIcon.url = UIItemRes.jieIcon[confData.stage_lvl]
                icon.url = confData.src and ResPath.iconRes(confData.src) or nil
            end
        end
        if v.selected then
            cache.AwakenCache:setEightSite(v.data.pos)
        end
    end
end

function EightGatesPanel:onClickBtn(context)
    local btn = context.sender
    local data = btn.data
    --缓存选中的孔位
    cache.AwakenCache:setEightSite(data.pos)
    local state = data.state
    if state == 0 then
        local isFind = false
        for k,v in pairs(self.notOpenGates) do
            if v.btn.data.pos < data.pos then--存在所选孔位之前还未开启的孔
                isFind = true
                break
            end
        end   
        if isFind then
            GComAlter(language.eightgates09)
        else
            local confData = self.notOpenGates[data.pos].confData
            if confData.item then--材料开启
                mgr.ViewMgr:openView2(ViewName.OpenAlertView,{item = confData.item,site = data.pos})
                return
            else
                if cache.PlayerCache:getRoleLevel() < confData.level then
                    GComAlter(string.format(language.gonggong07,confData.level))
                    return
                else
                    print("请求开启孔位",data.pos)
                    proxy.AwakenProxy:send(1610101,{site = data.pos})
                    return
                end
            end
        end
    elseif state == 1 then
        
    elseif state == 2 then
        local t = self.eightGatesInfo[data.pos]
        local info = clone(t.eleInfo)
        if info and info.mid ~= 0 then
            info.isquan = true
            info.isArrow = true
            GSeeLocalItem(info)
        end 
    end
end

function EightGatesPanel:cellPackData(index, obj)
    local data = self.packData[index+1]
    if data then
        local info = clone(data)
        info.isquan = true
        info.isArrow = true
        GSetItemData(obj:GetChild("n0"),info,true)
    else
        GSetItemData(obj:GetChild("n0"),{})
    end
end



--设置技能
function EightGatesPanel:setSkillInfoMsg()
    local equipData = cache.PackCache:getElementEquipData()
    local openSkill = conf.EightGatesConf:getValue("bm_skill")
    local elementDataByColor = {}
    for k,v in pairs(openSkill) do
        if not elementDataByColor[v[1]] then
             elementDataByColor[v[1]] = {}
        end
    end
    for k,v in pairs(elementDataByColor) do
        for i,j in pairs(equipData) do
            local color = conf.ItemConf:getQuality(j.mid)
            if color >= k then
                table.insert(elementDataByColor[k],j)
            end
        end
    end
    local sex = cache.PlayerCache:getSex()

    --技能激活条件
    for k,v in pairs(openSkill) do
        local skillId = v[2+tonumber(sex)]
        local skillConf = conf.SkillConf:getSkillConfByid(skillId)
        local preid = skillConf and skillConf.s_pre
        --名称
        local titleTxt = self.skillList[k]:GetChild("n1")
        titleTxt.text = conf.SkillConf:getSkillName(preid)
        --设置icon
        local id = conf.SkillConf:getSkillIcon(preid)
        
        local eleNum = #elementDataByColor[v[1]] 
        self.skillList[k].icon = ResPath.iconRes(id)
        local isGrayed = eleNum < v[2]
        self.skillList[k]:GetChild("icon").grayed = isGrayed
        self.skillList[k].data = {skillId = skillId,num = k,isGrayed = isGrayed}
    end
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view and view.BtnFight then
        view.BtnFight:checkEleSkillAct()
    end
end


function EightGatesPanel:onBtnCallBack(context)
    local btn = context.sender
    -- if btn.name == "n1" then--精炼
        -- mgr.ViewMgr:openView2(ViewName.ElementRefineView)
    if btn.name == "n2" then--强化
        local site = cache.AwakenCache:getEightSite() or 0
        local mid = self.eightGatesInfo[site] and self.eightGatesInfo[site].eleInfo.mid or 0
        mgr.ViewMgr:openView2(ViewName.ElementStrengView,{mid = mid})
    elseif btn.name == "n7" then--分解
        mgr.ViewMgr:openView2(ViewName.ShengYinResolve,{isEightElE = true})
    end
end



function EightGatesPanel:onClickSkillBtn(context)
    local btn = context.sender
    local data = btn.data   
    mgr.ViewMgr:openView2(ViewName.SkillInfoView,{skillId = data.skillId,num = data.num,isGrayed = data.isGrayed})
end

return EightGatesPanel