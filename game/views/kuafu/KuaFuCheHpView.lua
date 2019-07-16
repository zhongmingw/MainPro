--
-- Author: 
-- Date: 2017-09-22 20:48:54
--

local KuaFuCheHpView = class("KuaFuCheHpView", base.BaseView)

function KuaFuCheHpView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function KuaFuCheHpView:initView()
    self.name = self.view:GetChild("n5")
    self.belong = self.view:GetChild("n6")
    self.bar = self.view:GetChild("n4")
    self.title = self.bar:GetChild("title1")
end

function KuaFuCheHpView:initData(data)
    -- body
    if not data then
        self:closeView()
        return
    end
    self.data = data

    self:setData()
end
function KuaFuCheHpView:setData()
    --名字
    local confdata = conf.MonsterConf:getInfoById(self.data.mId)
    self.name.text = confdata.name
    --归属
    self.belong.text =  string.format(language.kuafu161,self.data.name) 

    --血条改变
    self:setHp()
end

function KuaFuCheHpView:changeNumber(iii)
    -- body
    local w = 10000
    if iii >= w then
        return math.ceil(iii/w)..language.gonggong52
    else
        return iii
    end
end

function KuaFuCheHpView:setHp()
    -- body
    --printt(self.data.attris)
    self.bar.value = self.data.attris[104] or 100 --
    self.bar.max = self.data.attris[105] or 100--self:changeNumber()
    self.title.text = self:changeNumber(self.bar.value).."/"..self:changeNumber(self.bar.max)
end

function KuaFuCheHpView:checkHp(data)
    -- body
    if not self.data then
        return
    end
    if self.data.roleId == data.roleId then
        self:setHp()
    end
end

function KuaFuCheHpView:checkDispose(data)
    -- body
    if not self.data then
        return
    end
    if self.data.roleId == data.roleId then
        self:closeView()
    end
end

return KuaFuCheHpView