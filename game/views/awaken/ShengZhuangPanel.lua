--
-- Author: 
-- Date: 2018-09-25 14:05:03
--

local ShengZhuangPanel = class("ShengZhuangView",import("game.base.Ref"))
local MaxNum = 10

function ShengZhuangPanel:ctor(mParent)
    self.mParent = mParent
    self:initView()
end

function ShengZhuangPanel:initView()
    self.view = self.mParent.view:GetChild("n19")

     --背包
    self.packPanel = self.view:GetChild("n30")
    self.listView =self.packPanel:GetChild("n6")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellPackData(index, obj)
    end
    self.listView.numItems = 0 

    self.scoreText = self.view:GetChild("n20")
    
    --套装展示
    local showBtn = self.view:GetChild("n22")
    showBtn.onClick:Add(self.showPanel,self)

    --属性预览
    local propertyBtn = self.view:GetChild("n23")
    propertyBtn.onClick:Add(self.propertyPanel,self)

    --获取圣装
    local getBtn = self.view:GetChild("n30"):GetChild("n2")
    getBtn.onClick:Add(self.goTo,self)

    --模型
    self.shengzhuangCom = self.view:GetChild("n45")--模型容器
    self.model = self.shengzhuangCom:GetChild("n0")
    self.effect = self.shengzhuangCom:GetChild("n1")

    --装备面板
    self.equipList = {}
    for i=1,MaxNum do
        local equipObj = self.view:GetChild("n"..i+31)
        equipObj.data =  i
        table.insert(self.equipList, equipObj)
    end

end

function ShengZhuangPanel:addMsgCallBack(data)

    if data.msgId == 5190201 then

        self.data = data
        --更新背包，装备缓存
        self:setData()
    elseif  data.msgId == 5040403 then
        self:setPackData() 
    elseif data.msgId == 8230801 or data.msgId == 5190203 then
        self.scoreText.text = data.power
    elseif data.msgId == 5190102 then

        self:setModel()
    end

end

function ShengZhuangPanel:showPanel(context)
    mgr.ViewMgr:openView2(ViewName.ShengZhuangShow)
end

function  ShengZhuangPanel:propertyPanel(context)
    mgr.ViewMgr:openView2(ViewName.ShenZhuangAttTips)
    
end

function ShengZhuangPanel:goTo()
     GOpenView({id = 1353})
end

function ShengZhuangPanel:setData()
    --已装备的圣装

    self.equippedPartData = {}
    local  data = cache.PackCache:getShengZhuangEquipData()
    for k,v in pairs(data) do
        local confdata = conf.ItemConf:getItem(v.mid)
        if not confdata then
            print("前后端配置一样,缺少 mid = "..v.mid)
        else
            self.equippedPartData[confdata.part] = v 
        end
    end
    
    -- self.scoreText.text = m?ath.floor(self:JiSuanScore())
    self:setPartInfoMsg()
    self:setPackData()
    self:setModel()
end

function ShengZhuangPanel:setPartInfoMsg()  --更新裝備

    for k,v in pairs(self.equipList) do
            item = v:GetChild("n0")
        if  self.equippedPartData[v.data] then
            local data = self.equippedPartData[v.data]
            data.isquan = true
            item.visible = true
            GSetItemData(item,data,true)
        else
            item.visible = false
        end
    end
end

function ShengZhuangPanel:setModel()
    --local model = self:getModelData()
    local skinId = cache.PlayerCache:getSkins(Skins.jiansheng)
    if skinId == 0 then
        --挑选一个可以激活的星级高的
        local countSuit = CGActShengZhuangSuitBystartNum()
        for i = 2 , 0 ,-1 do
            if countSuit["num"..i] == 10 then
                local confData = conf.AwakenConf:getJsTaoZhuangshuxing(i)
                for k,v in pairs(confData) do
                    if v.js_skin then
                        skinId = tonumber(v.js_skin)
                        break
                    end
                end
            end
            if skinId ~= 0 then
               break
            end
        end
    end
    if skinId == 0 then
        skinId = conf.AwakenConf:getIdByStarLv(1)
    end
    local jsid = conf.AwakenConf:getBuffId(skinId)
    local model = conf.BuffConf:getBuffConf(jsid)

    local modelObj = self.mParent:addModel(model.bs_args[1],self.model)
    modelObj:setSkins(model.bs_args[1],model.bs_args[2],model.bs_args[3])
    modelObj:setScale(130) --TODO
    modelObj:setPosition(40,-453,500)
    modelObj:setRotationXYZ(0,158.7,0)
    modelObj:modelTouchRotate(self.shengzhuangCom)
end

function ShengZhuangPanel:setPackData() -- 更新背包
    self.packdata = {}
    local data = cache.PackCache:getShenZhuangData()
    for k,v in pairs(data) do
        table.insert(self.packdata,v)
    end   
    table.sort(self.packdata,function(a,b)
        local aconf = conf.ItemConf:getItem(a.mid)
        local bconf = conf.ItemConf:getItem(b.mid)
        
        local astart = mgr.ItemMgr:getColorBNum(a)
        local bstart = mgr.ItemMgr:getColorBNum(b)

        local  atype_sort = aconf.sort
        local  btype_sort = bconf.sort

        local acolor = aconf.color
        local bcolor = bconf.color
        
        local apart = aconf.part
        local bpart = bconf.part

        local asyscore = GJSsynScore(a)
        local bsyscore = GJSsynScore(b)

        local asub = aconf.sub_type
        local bsub = bconf.sub_type

        -- if atype_sort ~= btype_sort then
        --     return atype_sort < btype_sort 
        -- elseif apart ~= bpart then
        --     return apart < bpart 
        --  elseif asyscore ~= bsyscore then
        --     return asyscore > asyscore 
        --  end
        if astart ~= bstart then
            return astart > bstart 
        elseif asub ~= bsub then
            return asub < bsub 
        elseif apart ~= bpart then
            return apart < bpart 
        elseif asyscore ~= bsyscore then
            return asyscore > asyscore   
         end
    end)
    local num = math.max((math.ceil(#self.packdata/20)*20),20)
    local maxPackNum = conf.AwakenConf:getShengZhuangBagMax()
    self.listView.numItems = num <= maxPackNum and num or maxPackNum
end


function ShengZhuangPanel:cellPackData(index,obj)
    local data = self.packdata[index+1]
    if data then
        local info = clone(data)
        info.isquan = true
        info.isArrow = true
        GSetItemData(obj:GetChild("n0"),info,true)
    else
        GSetItemData(obj:GetChild("n0"),{})
    end
end
-- function ShengZhuangPanel:JiSuanScore()
--     local score_taozhuang = 0 -- 生效的套装属性评分
--     local score_base = 0 -- 生效的基础属性评分
--     local score_jipinsocre = 0 --生效套装极品分
--     local score_mum = 0 -- 总分
--     local count1 = 0
--     local count2 = 0 
--     local count3 = 0
--     local data_base = {}
--     for k,v in pairs(self.equippedPartData) do 
--         local attiData = conf.ItemArriConf:getItemAtt(v.mid) --计算面板基础评分
--         local baseAttData = GConfDataSort(attiData)
--         G_composeData(data_base,baseAttData)  
--         if v.colorAttris then                                --计算面板极品属性评分
--             for k,m in pairs(v.colorAttris) do
--                 score_jipinsocre = score_jipinsocre + mgr.ItemMgr:birthAttScore(m.type,m.value)
--             end
--         end
--         local startNum = conf.ItemConf:getEquipStar(v.mid) or 0--计算面板套装属性评分
--         if strartNum == 0 then
--             startNum = 1
--         end 
--         if startNum == 1 then
--             count1 = count1 + 1
--         elseif startNum == 2 then
--             count2 = count2 + 1
--         elseif startNum == 3 then
--             count3 = count3 + 1
--         end 
--     end
--     print(count1,count2,count3)
--     local data = {}
--     local taozhuangxinScore1 = conf.AwakenConf:getJsTaoZhuangbyStart(1,count1) or {}
--     local taozhuangxinScore2 = conf.AwakenConf:getJsTaoZhuangbyStart(2,count2) or {}
--     local taozhuangxinScore3 = conf.AwakenConf:getJsTaoZhuangbyStart(3,count3) or {}
--         G_composeData(data,taozhuangxinScore1)
--         G_composeData(data,taozhuangxinScore2)
--         G_composeData(data,taozhuangxinScore3)
--     --面板套装属性分
--     for k,v in pairs(data) do
--          score_taozhuang = score_taozhuang + mgr.ItemMgr:baseAttScore(v[1],v[2])
--     end
--     --面板套装基础分
--     for k,v in pairs(data_base) do
--          score_base = score_base + mgr.ItemMgr:baseAttScore(v[1],v[2])
--     end
--     --总分计算
--     score_mum = score_taozhuang..score_base..score_jipinsocre
--     return score_mum
-- end

function ShengZhuangPanel:getModelData()
    local whichid = cache.AwakenCache:judgeWhichSZModel()
    local data = conf.AwakenConf:getJsTaoZhuangshuxing(whichid)
    local skid
    local modeldata
    for k,v in pairs (data) do
        if v.js_skin then
            skid = v.js_skin
        end
    end
    local jskid = conf.AwakenConf:getBuffId(skid)
    local buffData = conf.BuffConf:getBuffConf(jskid)
    modeldata = buffData.bs_args
    
    if modeldata then
        return modeldata 
    else
        print("找不到对应的模型id")
    end 
end

return ShengZhuangPanel