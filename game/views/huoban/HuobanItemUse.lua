--
-- Author: 
-- Date: 2017-02-27 17:00:58
--
MAX_JIE = {
    [1] = 12,
    [2] = 13,
    [3] = 13,
    [4] = 13,
    [5] = 13,
}
local HuobanItemUse = class("HuobanItemUse", base.BaseView)
local redpoint = {10211,10213,10212,10215,10214}
function HuobanItemUse:ctor()
    self.super.ctor(self)
    self.openTween = ViewOpenTween.scale
end

function HuobanItemUse:initData(data)
    -- body
    self.data = data
end

function HuobanItemUse:initView()
    local window4 = self.view:GetChild("n0")
    local btnClose = window4:GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.c1 = self.view:GetController("c1")
     --道具
    self.itemobj_see = self.view:GetChild("n24")
    self.skillname = self.view:GetChild("n9")
     --使用条件
    self.dec1 = self.view:GetChild("n11")
    self.value1 = self.view:GetChild("n12")
    self.yuan1 = self.view:GetChild("n13")
    --使用效果
    self.dec2 = self.view:GetChild("n14")
    self.dec2_1 = self.view:GetChild("n27")
    self.listView = self.view:GetChild("n25")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
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

function HuobanItemUse:initDec()
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

function HuobanItemUse:celldata( index,obj )
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



function HuobanItemUse:setData(index,reflag)
    self.index = index
    --plog("index",index)

    GSetItemData(self.itemobj_see,{mid = self.data.mId,isquan = true},true)
    self.skillname.text = conf.ItemConf:getName(self.data.mId)

    local use = 0
    local count = 0
    self.useMid = 0

    if self.data.hourse then
        local language_dec = {
            language.huoban16,
            language.huoban12,
            language.huoban13,
            language.huoban14,
            language.huoban15
        }

        self.isUp = false
        self.ismax = false
        local confData = conf.HuobanConf:getDataByLv(self.data.hourse.lev,index)
        -- plog(index,self.data.hourse.lev)
        local jie =  confData.jie or 1

        local t = conf.HuobanConf:getDataByLv(self.data.hourse.lev+1,index)
        local maxto = conf.HuobanConf:getValue("endmaxjie",index) or MAX_JIE[index+1]
        if t and t.jie > maxto then
            t = nil 
        end

        local pp = {1006,1007,1008,1010,1009}
        local condmodule = conf.SysConf:getModuleById(pp[index+1])

        local flag = false
        local selectjie
        if self.data.mId == condmodule.zzd_mid then--资质丹
            for k ,v in pairs(condmodule.zzd_limit) do
                if v[1] < jie and  v[2] > self.data.hourse.zzdNum then
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
            self.c1.selectedIndex = 0

            self.useMid = 1
        else  ---潜力丹
            for k ,v in pairs(condmodule.qld_limit) do
                if v[1] < jie and  v[2] > self.data.hourse.qldNum then
                    count = v[2]
                    selectjie = v[1]
                    break
                elseif v[1] == jie then
                    selectjie = v[1]
                    count = v[2]
                    break
                end
            end
            use = self.data.hourse.qldNum
            flag = true
            self.c1.selectedIndex = 1

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
        --print(">>>>>>>>>>>>>",use,count,t)
        if count ~= 0 then
            if t then
                if use < count then --使用条件
                    self.value1.text = string.format(language_dec[index+1],selectjie)
                else
                    self.isUp = jie+1 >maxto and maxto or jie+1 --需要下介
                    self.value1.text = string.format(language_dec[index+1],self.isUp)
                end
                self.dec3.text = string.format(language.zuoqi25,use,count) 
            else
                self.value1.text = string.format(language_dec[index+1],selectjie)
                if use < count then --使用条件
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
                        self.value1.text = string.format(language_dec[index+1],v[1])
                        break 
                    end
                end
            else
                for k ,v in pairs(condmodule.qld_limit) do
                    if v[2]>0 and v[1]>jie then
                        --self.isUp = v[1]
                        self.value1.text = string.format(language_dec[index+1],v[1])
                        break 
                    end
                end
            end
        end

        self.use = use
        if flag then
            --全属加百分比
            --plog("self.data.mId",self.data.mId)
            local Itemdata = conf.ItemConf:getItem(self.data.mId)
            self.itempro = { {9999,Itemdata.ext01 * 1/100} }
        else
            self.itempro = GConfDataSort(conf.ItemConf:getItemPro(self.data.mId))
            --[[for k ,v in pairs(self.itempro) do
                v[2] = v[2]* use
            end]]--
            
        end
        self.listView.numItems = #self.itempro
    end 

    GSetItemData(self.itemObj,{mid = self.data.mId,isquan = true},true)
    self.itemName.text = conf.ItemConf:getName(self.data.mId)  


    if self.isUp then
        self.value1.text = mgr.TextMgr:getTextColorStr(self.value1.text, 14)
    end

    --刷红点
    if reflag then
        --plog(reflag,self.isUp,self.ismax,cache.PackCache:getPackDataById(self.data.mId).amount)
        if self.isUp or self.ismax or cache.PackCache:getPackDataById(self.data.mId).amount<=0 then
            mgr.GuiMgr:redpointByID(redpoint[self.index+1])
        end
    end
end

function HuobanItemUse:onBtnPlus()
    -- body
    --加号按钮
    local param = {}
    param.mId = self.data.mId
    GGoBuyItem(param)
end

function HuobanItemUse:onSkillUp()
    -- body 技能升级
    if self.data.hourse then
        if self.isUp then--"需坐骑达到%d阶开放"
            GComAlter(self.value1.text) 
            return
        elseif self.ismax then--已达到最大使用上限
            GComAlter(language.zuoqi47)
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

function HuobanItemUse:onBtnClose()
    -- body
    
    self:closeView()
end

function HuobanItemUse:add5040401(data)
    -- body
    if self.data.hourse then
        self.issendhourse = true
        if self.useMid == 1 then
            self.data.hourse.zzdNum = self.data.hourse.zzdNum + data.amount
        else 
            self.data.hourse.qldNum = self.data.hourse.qldNum + data.amount
        end

        if self.index == 0 then
            proxy.HuobanProxy:send(1200101)
        elseif self.index == 1 then
            proxy.HuobanProxy:send(1210101)
        elseif self.index == 2 then
            proxy.HuobanProxy:send(1220102)
        elseif self.index == 3 then
            proxy.HuobanProxy:send(1230101)
        elseif self.index == 4 then
            proxy.HuobanProxy:send(1240101)
        end
    end

    self:setData(self.index,true)
end

function HuobanItemUse:add5090102()
    -- body
    self:setData(self.index)
end

return HuobanItemUse