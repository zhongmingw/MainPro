--
-- Author: 
-- Date: 2017-02-20 16:51:07
--
MAX_JIE = {
    [1] = 14,--坐骑
    [2] = 14,--神兵
    [3] = 14,--法宝
    [4] = 14,--仙羽
    [5] = 14,--仙器
    [6] = conf.ZuoQiConf:getValue("endmaxjie",5),--麒麟臂
}

local ZuoQiItemUse = class("ZuoQiItemUse", base.BaseView)
local redpoint = {10216,10207,10210,10208,10209,10262}
function ZuoQiItemUse:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function ZuoQiItemUse:initData(data)
    -- body
    self.data = data
    self:initDec()
    self:setData()
end

function ZuoQiItemUse:initView()
    local window4 = self.view:GetChild("n0")
    local btnClose = window4:GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)
    self.window4Icon = window4:GetChild("icon")
    --道具
    self.itemobj_see = self.view:GetChild("n24")
    self.skillname = self.view:GetChild("n9")
    --使用条件
    self.dec1 = self.view:GetChild("n11")
    self.value1 = self.view:GetChild("n12")
    self.yuan1 = self.view:GetChild("n13")
    --使用效果
    self.dec2 = self.view:GetChild("n14")
    self.listView = self.view:GetChild("n25")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.dec2_1 = self.view:GetChild("n27")
    --已经使用的数量
    self.dec3 = self.view:GetChild("n18")
    --消耗什么道具
    self.dec4 = self.view:GetChild("n21")
    self.itemName = self.view:GetChild("n22") 
    self.itemCount = self.view:GetChild("n23")
    self.itemObj = self.view:GetChild("n3")
    --购买
    local btnPlus = self.view:GetChild("n6")
    btnPlus.onClick:Add(self.onBtnPlus,self)
    self.btnPlus = btnPlus
    if g_ios_test then    --EVE ios版属屏蔽加号
        btnPlus.scaleX = 0
        btnPlus.scaleY = 0
    end 
    --使用
    local btnUp = self.view:GetChild("n7")
    --self.btnUpTitle = btnUp:GetChild("title")
    btnUp.onClick:Add(self.onSkillUp,self)
    self.btnUp = btnUp

    self:initDec()
end

function ZuoQiItemUse:initDec()
    -- body
    self.skillname.text = ""

    self.dec1.text = language.zuoqi23 
    self.value1.text = ""
    self.dec2.text = language.zuoqi24
    self.dec2_1.text = language.zuoqi71


    self.dec3.text = ""

    self.dec4.text = language.zuoqi16
    self.itemName.text = ""
    self.itemCount.text = ""
    --self.btnUpTitle.text = language.zuoqi27
    --self.btnUpTitle.visible = true
end

function ZuoQiItemUse:celldata( index,obj )
    -- body
    local data = self.itempro[index+1]
    local lab = obj:GetChild("n1")
    local lab1 = obj:GetChild("n3")
    if data[1]~=9999 then
        lab.text = conf.RedPointConf:getProName(data[1]).."  "..data[2]
        lab1.text = conf.RedPointConf:getProName(data[1]).."  "..data[2]*(self.use or 0)
    else
        local param = {
            {color = 8,text = language.zuoqi45..":"},
            {color = 7,text = data[2].."%"},
        }
        lab.text =  mgr.TextMgr:getTextByTable(param)

        local param = {
            {color = 8,text = language.zuoqi45..":"},
            {color = 7,text = data[2]*(self.use or 0).."%"},
        }
        lab1.text = mgr.TextMgr:getTextByTable(param)
    end
    obj.height = lab.height
end

function ZuoQiItemUse:setData(reflag)
    GSetItemData(self.itemobj_see,{mid = self.data.mId,isquan = true},true)
    self.skillname.text = conf.ItemConf:getName(self.data.mId)

    local use = 0
    local count = 0

    self.useMid = 0
    if self.data.hourse then
        self.isUp = false
        self.ismax = false
        local confData = conf.ZuoQiConf:getDataByLv(self.data.hourse.lev,self.data.index)
        local t =  conf.ZuoQiConf:getDataByLv(self.data.hourse.lev+1,self.data.index)
        local maxto = conf.ZuoQiConf:getValue("endmaxjie",self.data.index) or 10
        if t and t.jie > maxto then
            t = nil 
        end
        
        local condmodule 
        if self.data.index == 0 then
            condmodule = conf.SysConf:getModuleById(1001)
        elseif self.data.index == 1 then
            condmodule = conf.SysConf:getModuleById(1003)
        elseif self.data.index == 2 then
            condmodule = conf.SysConf:getModuleById(1005)
        elseif self.data.index == 3 then
            condmodule = conf.SysConf:getModuleById(1002)
        elseif self.data.index == 4 then
            condmodule = conf.SysConf:getModuleById(1004)
        elseif self.data.index == 5 then
            condmodule = conf.SysConf:getModuleById(1287)
        end
        local jie =  confData.jie or 1
        -- print("阶>>>>>>>>>>>>>",confData.jie,self.data.hourse.lev)
        local flag = false
        local selectjie = 1
        if self.data.mId == condmodule.zzd_mid then--资质丹
            for k ,v in pairs(condmodule.zzd_limit) do
                if v[1] < jie and v[2] > self.data.hourse.zzdNum then
                    selectjie = v[1]
                    count = v[2]
                    break
                elseif v[1] == jie then
                    selectjie = v[1]
                    count = v[2]
                    break
                end
            end
            use = self.data.hourse.zzdNum
            self.window4Icon.url = UIItemRes.zzd

            self.useMid = 1


            if self.data.index == 5 then 
                self.window4Icon.url = UIItemRes.qlbzzd
            end

        else  ---潜力丹
            for k ,v in pairs(condmodule.qld_limit) do
                if v[1] < jie and v[2] > self.data.hourse.qldNum then
                     selectjie = v[1]
                    count = v[2]
                    break
                elseif v[1] == jie then
                     selectjie = v[1]
                    count = v[2]
                    break
                end
            end
            use = self.data.hourse.qldNum
            flag = true
            self.window4Icon.url = UIItemRes.qld
            if self.data.index == 5 then 
                self.window4Icon.url = UIItemRes.qlbqld
            end

            self.useMid = 2
        end

        local amount = cache.PackCache:getPackDataById(self.data.mId).amount
        if amount > 0 then
            self.itemCount.text = amount.."/1"
        else
            local param = {
                {color = 14,text = 0},
                {color = 7,text = "/1"}
            }
            self.itemCount.text = mgr.TextMgr:getTextByTable(param)
        end
        --print(use ,"<", count)
        if count ~= 0 then 
            if t then
                if use < count then --使用条件

                    self.value1.text = string.format(language.zuoqi17[self.data.index+1], selectjie)
                else
                    self.isUp = jie+1 > maxto and maxto or jie+1 --需要下介
                    self.value1.text = string.format(language.zuoqi17[self.data.index+1],self.isUp )
                end
                self.dec3.text = string.format(language.zuoqi25,use,count) 
                
            else
                self.value1.text = string.format(language.zuoqi17[self.data.index+1], selectjie)
                if use < count then --使用条件
                    --self.value1.text = string.format(language.zuoqi17[self.data.index+1],confData.jie)
                    --self.value1.text = language.zuoqi26
                else
                    self.ismax = true
                    
      
                end
                self.dec3.text = string.format(language.zuoqi25,use,count) 
            end
        else
            if self.useMid == 1 then--查找资质丹
                for k ,v in pairs(condmodule.zzd_limit) do
                    if v[2]>0 and v[1]>jie then
                        --self.isUp = v[1]
                        self.value1.text = string.format(language.zuoqi17[self.data.index+1],v[1])
                        break 
                    end
                end
            else
                for k ,v in pairs(condmodule.qld_limit) do
                    if v[2]>0 and v[1]>jie then
                        ---self.isUp = v[1]
                        self.value1.text = string.format(language.zuoqi17[self.data.index+1],v[1])
                        break 
                    end
                end
            end
        end





        self.use = use
        if flag then
            --全属加百分比
            local Itemdata = conf.ItemConf:getItem(self.data.mId)
            self.itempro = { {9999,Itemdata.ext01 * 1/100} }
        else
            self.itempro = GConfDataSort(conf.ItemConf:getItemPro(self.data.mId))
            for k ,v in pairs(self.itempro) do
                v[2] = v[2]* 1
            end
            
        end
        self.listView.numItems = #self.itempro
    end 

    GSetItemData(self.itemObj,{mid = self.data.mId},true)
    self.itemName.text = conf.ItemConf:getName(self.data.mId)  
    
    if self.isUp then
        self.value1.text = mgr.TextMgr:getTextColorStr(self.value1.text, 14)
    end
    --刷红点
    if reflag then
        --plog(reflag,self.isUp,self.ismax,cache.PackCache:getPackDataById(self.data.mId).amount)
        if self.isUp or self.ismax or cache.PackCache:getPackDataById(self.data.mId).amount<=0 then
            mgr.GuiMgr:redpointByID(redpoint[self.data.index+1])
        end
    end
end

function ZuoQiItemUse:onBtnPlus()
    -- body
    --加号按钮
    local param = {}
    param.zuoqi = true
    param.mId = self.data.mId
    GGoBuyItem(param)
end

function ZuoQiItemUse:onSkillUp()
    -- body 技能升级
    if self.data.hourse then
        if self.ismax then--已达到最大使用上限
            GComAlter(language.zuoqi47)
            return
        elseif self.isUp then--"需坐骑达到%d阶开放"
            GComAlter(self.value1.text)
            return
        end

        self.cachedata = cache.PackCache:getPackDataById(self.data.mId)
        if self.cachedata.amount > 0 then
            local param = {}
            param.index = self.cachedata.index
            param.amount = 1
            proxy.PackProxy:sendUsePro(param)
        else
            self:onBtnPlus()
        end
    end    
end

function ZuoQiItemUse:onBtnClose()
    -- body
   
    self:closeView()
end

function ZuoQiItemUse:add5040401(data)
    -- body
    if self.data.hourse then
        self.issendhourse = true
        if self.useMid == 1 then
            self.data.hourse.zzdNum = self.data.hourse.zzdNum + data.amount
        else 
            self.data.hourse.qldNum = self.data.hourse.qldNum + data.amount
        end

        --plog("self.data.index",self.data.index)
        if self.data.index == 0 then
            proxy.ZuoQiProxy:send(1120101)
        elseif self.data.index == 1 then
            proxy.ZuoQiProxy:send(1160101)
        elseif self.data.index == 2 then
            proxy.ZuoQiProxy:send(1170101)
        elseif self.data.index == 3 then
            proxy.ZuoQiProxy:send(1140101)
        elseif self.data.index == 4 then
            proxy.ZuoQiProxy:send(1180101)
        elseif self.data.index == 5 then
            proxy.ZuoQiProxy:send(1560101)
        end
    end

    self:setData(true)
end

function ZuoQiItemUse:add5090102()
    -- body
    self:setData()
end


return ZuoQiItemUse