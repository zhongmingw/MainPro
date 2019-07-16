--
-- Author: 
-- Date: 2018-09-26 17:07:40
--
local pairs = pairs
local ShengZhuangShow = class("ShengZhuangShow", base.BaseView)

local tableKey = {{1001,0},{1002,1},{1003,2}}
function ShengZhuangShow:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function ShengZhuangShow:initView()
     self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
     self.modelpanel = self.view:GetChild("n8")
     self.checkBtn = self.view:GetChild("n10")
     self.checkBtn.onChanged:Add(self.isGet,self)
     self.c1 = self.view:GetController("c1")
     self.c1.onChanged:Add(self.onController1,self)
     local btn1 =  self.view:GetChild("n3") 
     btn1.title = conf.AwakenConf:getJsNameByStartName(0)
     local btn2 =  self.view:GetChild("n4")
     btn2.title = conf.AwakenConf:getJsNameByStartName(1)
     local btn3 =  self.view:GetChild("n5")
     btn3.title = conf.AwakenConf:getJsNameByStartName(2)
     self.text01 = self.view:GetChild("n12")
     self.listView = self.view:GetChild("n18")
end

function ShengZhuangShow:initData(data)
    self.countSuit = CGActShengZhuangSuitBystartNum()

    self:updatePanelInfo(self.c1.selectedIndex)
end

function ShengZhuangShow:onController1()
    --self.checkBtn.selected = cache.AwakenCache:getSZCheck(self.c1.selectedIndex)
    if self.c1.selectedIndex == 0 then 
        self:updatePanelInfo(0)
    elseif self.c1.selectedIndex == 1 then
        self:updatePanelInfo(1)  
    elseif self.c1.selectedIndex == 2 then
         self:updatePanelInfo(2)  
    end
end

function ShengZhuangShow:updatePanelInfo(id)
    self.listView.numItems = 0
    local confData = conf.AwakenConf:getJsTaoZhuangshuxing(id)
    -- local str = ""
    -- local colorStr = ""
    -- local colorStrEnd = ""
    for k,v in pairs(confData) do
        local temp = GConfDataSort(v)
        local str =  "【"..v.num.."件】"
        local str3 = ""
        for i,j in pairs(temp) do
            str3 = str3..conf.RedPointConf:getProName(j[1]).." +"..GProPrecnt(j[1],math.floor(j[2]))
            if i ~= #temp then
                str3 = str3.."\n"
            end
        end
        

        local url = UIPackage.GetItemURL("awaken" , "Component17")
        local baseitem = self.listView:AddItemFromPool(url)

        local actNum = self.countSuit["num"..id] --件数
        if actNum >= v.num then
            baseitem:GetChild("n15").text = mgr.TextMgr:getTextColorStr(str, 7)
            baseitem:GetChild("n14").text = mgr.TextMgr:getTextColorStr(str3, 7)
        else
            baseitem:GetChild("n15").text = str
            baseitem:GetChild("n14").text = str3
        end
    end
   
    --更新模型
    local skinId = 0 
    for k,v in pairs(confData) do
        if v.js_skin then
            skinId = tonumber(v.js_skin)
            break
        end
    end
    --print(skinId,"当前皮肤id",cache.PlayerCache:getSkins(Skins.jiansheng))
    self.checkBtn.selected = cache.PlayerCache:getSkins(Skins.jiansheng) == skinId
    self.skinId = skinId

    local jsid = conf.AwakenConf:getBuffId(skinId)
    local buffData = conf.BuffConf:getBuffConf(jsid)
    self.model = buffData.bs_args
    local modelObj = self:addModel(self.model[1],self.modelpanel)
    modelObj:setSkins(self.model[1],self.model[2],self.model[3])
    modelObj:setScale(100) --TODO
    modelObj:setPosition(46.88,-280,500)
    modelObj:setRotationXYZ(0,160,0)
    self.text01.text = string.format(language.shengzhuang05,id )
end

function ShengZhuangShow:isGet(context)
    --判断是否激活10套没有飘字
    local param = {}
    param.id = self.skinId
    if self.c1.selectedIndex == 0 then
        if self.countSuit["num0"] < 10 then
            self.checkBtn.selected = false
            return GComAlter(language.shengzhuang06)
        end
    elseif self.c1.selectedIndex == 1 then
        if self.countSuit["num1"] < 10 then
            self.checkBtn.selected = false
            return GComAlter(language.shengzhuang06)
        end
    elseif self.c1.selectedIndex == 2 then
        if self.countSuit["num2"] < 10 then
            self.checkBtn.selected = false
            return GComAlter(language.shengzhuang06)
        end
    end
    if self.checkBtn.selected then
        param.reqType = 2
        
    else
        param.reqType = 1
    end
    self.checkBtn.selected = false
    proxy.AwakenProxy:send(1190102,param)

    -- if self.c1.selectedIndex == 0 then
    --     if CGActShengZhuangSuitBystartNum(0) < 10  then
    --         self.checkBtn.selected = false
    --         GComAlter(language.shengzhuang06)
    --     else
    --         if self.checkBtn.selected then
    --             proxy.AwakenProxy:send(1190102,{id = 1001 ,reqType = 2})
    --         else
    --             proxy.AwakenProxy:send(1190102,{id = 1001 ,reqType = 1}) 
    --         end
    --     end
    --     cache.AwakenCache:setSZCheck(self.checkBtn.selected,self.c1.selectedIndex)
    -- elseif self.c1.selectedIndex == 1 then
    --     if CGActShengZhuangSuitBystartNum(1) < 10  then
    --         self.checkBtn.selected = false
    --         GComAlter(language.shengzhuang06)
    --     else
    --         if self.checkBtn.selected then
    --             proxy.AwakenProxy:send(1190102,{id = 1002 ,reqType = 2})
    --         else
    --             proxy.AwakenProxy:send(1190102,{id = 1002 ,reqType = 1}) 
    --         end
    --     end 
    --     cache.AwakenCache:setSZCheck(self.checkBtn.selected,self.c1.selectedIndex)
    -- elseif self.c1.selectedIndex == 2 then
    --     if CGActShengZhuangSuitBystartNum(2) < 10  then
    --         self.checkBtn.selected = false
    --         GComAlter(language.shengzhuang06)
    --     else
    --         if self.checkBtn.selected then
    --             proxy.AwakenProxy:send(1190102,{id = 1003 ,reqType = 2})
    --         else
    --             proxy.AwakenProxy:send(1190102,{id = 1003 ,reqType = 1}) 
    --         end
    --     end 
    --     cache.AwakenCache:setSZCheck(self.checkBtn.selected,self.c1.selectedIndex)
    -- end
end

function ShengZhuangShow:getModelData(id)
    local confData = conf.AwakenConf:getJsTaoZhuangshuxing(id)
    local skinId = 0 
    for k,v in pairs(confData) do
        if v.js_skin then
            skinId = tonumber(v.js_skin)
        end
    end
    local id = conf.AwakenConf:getBuffId(skinId)
    local buffData = conf.BuffConf:getBuffConf(id)
    self.model = buffData.bs_args
    local modelObj = self:addModel(self.model[1],self.modelpanel)
    modelObj:setSkins(self.model[1],self.model[2],self.model[3])
    modelObj:setScale(100) --TODO
    modelObj:setPosition(46.88,-144,56)
    modelObj:setRotationXYZ(0,160,0)
end

function ShengZhuangShow:lowerCanShow(id)
    if id == 0 then
        if self.actNumStart1 or self.actNumStart2 then
            return true
        else
            return false
        end
    elseif id == 1 then
        if self.actNumStart2  then
            return true
        else
            return false
        end
    end
end


function ShengZhuangShow:showBySkinId()
    local skinId = cache.PlayerCache:getSkins(16) 
    local var = 0
    for k,v in pairs(tableKey) do
        if v[1] == skinId then
            var = v[2]
        end
    end
    return var
end

function ShengZhuangShow:addMsgCallBack( data )
    -- body
    if 5190102 == data.msgId then
        self:onController1()
    end
end

return ShengZhuangShow