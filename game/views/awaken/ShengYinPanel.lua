--
-- Author: 
-- Date: 2018-09-10 15:55:09
--

local ShengYinPanel = class("ShengYinPanel",import("game.base.Ref"))

function ShengYinPanel:ctor(mParent)
    self.mParent = mParent
    self:initView()
end

function ShengYinPanel:initView()
    self.view = self.mParent.view:GetChild("n16")
    --背包
    self.packPanel = self.view:GetChild("n12")
    self.listView =self.packPanel:GetChild("n6")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellPackData(index, obj)
    end
    self.listView.numItems = 0
    --套装总览
    local suitBtn = self.packPanel:GetChild("n1")
    suitBtn.onClick:Add(self.onClickSuit,self)
    --分解
    local resolveBtn = self.packPanel:GetChild("n2")
    resolveBtn.onClick:Add(self.onClickResolve,self)
    --强化
    local strengBtn = self.packPanel:GetChild("n7")
    strengBtn.onClick:Add(self.onClickStreng,self)
    self.strengRedImg = strengBtn:GetChild("red")
    
    self.shengYinCom = self.view:GetChild("n0")
    self.btnList = {}
    for i = 2 , 12 do
        local btn = self.shengYinCom:GetChild("n"..i)
        btn.data = i-1
        btn.onClick:Add(self.onBtnCallBack,self)
        table.insert(self.btnList,btn)
    end
    --评分
    self.score = self.view:GetChild("n14")
    self.score.text = 0
    --材料
    self.materialNum = self.view:GetChild("n17")
    self.materialNum.text = 0
    --套装属性
    local suitProBtn = self.view:GetChild("n21")
    suitProBtn.onClick:Add(self.onClickSuitPro,self)
    --圣魂
    local shengHunBtn = self.view:GetChild("n18")
    shengHunBtn.onClick:Add(self.onClickShengHun,self)

    self.shengHunRedImg = shengHunBtn:GetChild("red")
    self.shengHunRedImg.x = self.shengHunRedImg.x -30
    self.shengHunRedImg.y = self.shengHunRedImg.y +10



end



function ShengYinPanel:addMsgCallBack(data)
    self.partInfo = cache.AwakenCache:getShengYinPartInfo()
    if data.msgId == 5600102 then
        -- printt("圣印消息返回信息",data)
        self.data = data
        self.materialNum.text = data.syScore
        -- 圣印部位信息
        self:setPartInfoMsg()
        self.score.text = data.power

     
    elseif data.msgId == 5600101 then--穿脱
        self:setData()
        self:setPartInfoMsg()
    elseif data.msgId == 5600104 then--分解
        self.materialNum.text = data.syScore
        self.data.syScore = data.syScore
    elseif data.msgId == 8230702 then--战力更新
        self.score.text = data.power
    end
    self:setPackData()
    self:refreshRed()
    local view = mgr.ViewMgr:get(ViewName.AwakenView)
    if view then
        view:refreshRed()
    end
end

function ShengYinPanel:refreshRed()
    --圣魂红点
    self.shengHunRedImg.visible = GGetShengHunRed() > 0  and true or false
    self.strengRedImg.visible = GGetSYstrengRed() > 0  and true or false
        -- print("圣魂",GGetShengHunRed(),"强化",GGetSYstrengRed(),"高阶",GStrongShengYinRedNum(),"穿戴",GCanPutShengYin())

end

--AwakenView内也会调用
function ShengYinPanel:setData()
    -----------------测试调试----------------------------------

    -- local extType = conf.ItemConf:getRedBagType(1211014001)
    -- local suitAttData = conf.ShengYinConf:getSuitAttrByExtType(extType)--套装属性

    -------------------------------------------------------
    --已装备的圣印
    self.equippedPartData = {}
    local data = cache.PackCache:getShengYinEquipData()
    for k ,v in pairs(data) do
        local confdata = conf.ItemConf:getItem(v.mid)
        if not confdata then
            print("前后端配置一样,缺少 mid = "..mid)
        else
            self.equippedPartData[confdata.part] = v 
        end
    end
    -- printt("已装备圣印",self.equippedPartData)

    -- print("!!!!!!!!!!!!!", GStrongShengYinRedNum())

end

function ShengYinPanel:setPartInfoMsg()
    for k,v in pairs(self.btnList) do
        local frame = v:GetChild("n1")
        local icon = v:GetChild("n2")
        local effectPanel = v:GetChild("n3")
        -- if v.data == 11 then
        --     frame.visible = false
        -- end
        frame.url = UIItemRes.shengyin[v.data]
        local info = self.equippedPartData[v.data]
        if info then
            local confData = conf.ItemConf:getItem(info.mid)
            icon.url = confData.src and ResPath.iconRes(confData.src) or nil
            if confData.shengyin_movie then
                effectPanel.url = UIPackage.GetItemURL("_movie" , "MovieShengYin"..confData.shengyin_movie)
            end
            if v.data == 11 then
                effectPanel.url = UIPackage.GetItemURL("_movie" , "MovieShengYin11")
            end
        else
            icon.url = nil
            effectPanel.url = nil
        end
    end

end

function ShengYinPanel:onBtnCallBack(context)
    local btn = context.sender 
    local data = btn.data 
  
    local t = self.equippedPartData[data]
    local info = clone(t)
    if info then
        if next( self.partInfo) ~= nil then
            for k , v in pairs(self.partInfo) do
                local confdata = conf.ItemConf:getItem(info.mid)
                if v.part == confdata.part then
                    info.level = v.strenLev--该部位的强化等级
                    break
                end
            end
        else
            info.level = 0
        end
        info.isquan = true
        info.isArrow = true
        GSeeLocalItem(info)
    end 
end

function ShengYinPanel:setPackData()
    self.packdata = {}
    local data = cache.PackCache:getShengYinData()
    for k,v in pairs(data) do
        table.insert(self.packdata,v)
    end    
    table.sort(self.packdata,function(a,b)
           local aconf = conf.ItemConf:getItem(a.mid)
        local bconf = conf.ItemConf:getItem(b.mid)
        
        local acolor = aconf.color
        local bcolor = bconf.color
        
        local apart = aconf.part
        local bpart = bconf.part

        local ajie = aconf.stage_lvl
        local bjie = bconf.stage_lvl

        if acolor ~= bcolor then
            return acolor > bcolor 
        elseif ajie ~= bjie then
            return ajie > bjie 
        elseif apart ~= bpart then
            return apart > bpart 
        end

    end)
    -- printt("圣印背包数据",self.packdata)
    local num = math.max((math.ceil(#self.packdata/20)*20),20)
    local maxPackNum = conf.ShengYinConf:getValue("pack_max")
    self.listView.numItems = num <= maxPackNum and num or maxPackNum
    -- print("背包格子个数",self.listView.numItems)
end

function ShengYinPanel:cellPackData(index,obj)
    local data = self.packdata[index+1]
    --printt(data)
    if data then
        local info = clone(data)
        info.isquan = true
        info.isArrow = true
        GSetItemData(obj:GetChild("n0"),info,true)
    else
        GSetItemData(obj:GetChild("n0"),{})
    end
end
--套装
function ShengYinPanel:onClickSuit()
    mgr.ViewMgr:openView2(ViewName.ShengYinSuitView)
end
--分解
function ShengYinPanel:onClickResolve()
    mgr.ViewMgr:openView2(ViewName.ShengYinResolve)
end
--强化
function ShengYinPanel:onClickStreng()
    local data = cache.PackCache:getShengYinEquipData()
    local t = {}
    for k,v in pairs(data) do
        table.insert(t,v)
    end
    if #t > 0 then
        mgr.ViewMgr:openView2(ViewName.ShengYinStreng,{materialNum = self.data.syScore, equipData = t})
    else
        GComAlter(language.shengyin03)
    end
end
--套装属性
function ShengYinPanel:onClickSuitPro()
    -- mgr.ViewMgr:openView(ViewName.ShengYinAttTips,function ()
        proxy.AwakenProxy:send(1600103)
    -- end)
    -- mgr.ViewMgr:openView2(ViewName.ShengYinAttTips)
end
--圣魂
function ShengYinPanel:onClickShengHun()
    mgr.ViewMgr:openView2(ViewName.ShengHunView)
end

function ShengYinPanel:getScore()
    local score = 0
    local extTypeList = {}
    for k,v in pairs(self.equippedPartData) do
        --属性积分
        local attiData = conf.ItemArriConf:getItemAtt(v.mid)
        local t = GConfDataSort(attiData)
        --基础属性
        local baseAttData = {}
        for k,v in pairs(t) do
            if tonumber(v[1]) < 300 then
                table.insert(baseAttData,v)
            end
        end
        local attScore = 0
        for k,v in pairs(baseAttData) do
            attScore = attScore + mgr.ItemMgr:baseAttScore(v[1],v[2])--基础评分
        end
        score = score + attScore
        --套装积分
        local extType = conf.ItemConf:getRedBagType(v.mid)
        table.insert(extTypeList,extType)

    end
    -- printt("所有套装",extTypeList)
    local t = {}
    for k,v in pairs(extTypeList) do
        table.insert(t,{v,1})
    end
    --套装激活件数(v[1]:套装id，v[2]:穿戴)
    local suitList = {}
    self:setHashData(t,suitList)
    -- printt("套装激活件数",suitList)
    --套装属性
    local suitAttData = {}
    for k,v in pairs(suitList) do
        local id = v[1]
        local suitData = conf.ShengYinConf:getSuitAttrByExtType(id)--套装属性
        table.sort(suitData,function (a,b)
            return a.dress_num > b.dress_num
        end )
        for i,j in pairs(suitData) do
            if v[2] >= j.dress_num then
                local t = GConfDataSort(j)
                -- printt("激活的套装属性",t)
                self:setHashData(t,suitAttData)              
            end
        end
    end
    -- printt("套装属性",suitAttData)
    for k,v in pairs(suitAttData) do
        score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])--基础评分
    end

    return score 
end

function ShengYinPanel:setHashData(data,tar)
    for k,v in pairs(data) do
        local flag = false
        for i,j in pairs(tar) do
            if j[1] == v[1] then
                tar[i][2] = j[2] + v[2]
                flag = true
            end
        end
        if not flag then
            table.insert(tar,v)
        end
    end
end


return ShengYinPanel