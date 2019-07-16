--
-- Author: Your Name
-- Date: 2018-07-26 17:26:41
--

local XianWeiAttr = class("XianWeiAttr", base.BaseView)

function XianWeiAttr:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function XianWeiAttr:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n1")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function XianWeiAttr:initData()
    self.titleData = conf.DiWangConf:getAllTitleData()
    -- printt("称号>>>>>>>>>>>>>>",self.titleData)
    self.listView.numItems = #self.titleData
end

function XianWeiAttr:celldata(index,obj)
    local data = self.titleData[index+1]
    if data then
        local attrsList = {}
        for i=1,6 do
            local nameTxt = obj:GetChild("att"..i)
            local attTxt = obj:GetChild("att"..(i+10))
            table.insert(attrsList,{nameTxt,attTxt})
        end
        local titleIcon = obj:GetChild("n4")
        local titleData = conf.RoleConf:getTitleData(data.title[1])
        titleIcon.url = UIPackage.GetItemURL("head" , tostring(titleData.scr))
        local buffTxt = obj:GetChild("n11")
        if data.buff then
            local buffData = conf.BuffConf:getBuffConf(data.buff)
            buffTxt.text = buffData.desc
            for i=8,11 do
                obj:GetChild("n"..i).visible = true
            end
        else
            buffTxt.text = ""
            for i=8,11 do
                obj:GetChild("n"..i).visible = false
            end
        end
        --称号属性
        local attrData = GConfDataSort(titleData)
        for k,v in pairs(attrsList) do
            local nameTxt = v[1]
            local attTxt = v[2]
            local t = attrData[k]
            if t then
                nameTxt.visible = true
                attTxt.visible = true
                nameTxt.text = conf.RedPointConf:getProName(t[1])
                attTxt.text = "+" .. GProPrecnt(t[1],math.floor(t[2]))
            else
                nameTxt.visible = false
                attTxt.visible = false
            end
        end

    end
end

return XianWeiAttr