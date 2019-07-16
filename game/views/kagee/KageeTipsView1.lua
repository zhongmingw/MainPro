--
-- Author: ohf
-- Date: 2017-02-21 19:34:54
--
--影卫连锁--羁绊
local KageeTipsView1 = class("KageeTipsView1", base.BaseView)

function KageeTipsView1:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
    self.uiClear = UICacheType.cacheTime
end

function KageeTipsView1:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.panelObj1 = self.view:GetChild("n2")
    self.panelObj2 = self.view:GetChild("n3")
    self.listView = self.view:GetChild("n4")

    self.upBtn = self.view:GetChild("n5")
    self.upBtn.onClick:Add(self.onClickUp,self)
end

function KageeTipsView1:setData(data,xmid,ywJbLevel)
    self.mData = data or self.mData
    self.xmid = xmid or self.xmid
    local curData = nil
    local nextData = nil
    self.init = false--不是显示初始值
    if ywJbLevel <= 0 then
        self.upBtn.title = language.kagee27
        self.isJh = false--未激活
        if not conf.KageeConf:getFettersattr(self.mData) then--不可以激活
            self.init = true
        end
        curData = conf.KageeConf:getFettersattrById(1)
        nextData = curData
    else
        self.upBtn.title = language.kagee28
        curData = conf.KageeConf:getFettersattrById(ywJbLevel)
        self.isJh = true
    end
    local id = curData.id + 1
    nextData = conf.KageeConf:getFettersattrById(id)
    self.isUp = false
    if not nextData then
        self.upBtn.visible = false
        local curId = curData.id - 1
        local nextId = curData.id
        curData = conf.KageeConf:getFettersattrById(curId)
        nextData = conf.KageeConf:getFettersattrById(nextId)
    else
        self.upBtn.visible = true
        if self.isJh then
            local num = 0
            for k,v in pairs(self.mData) do
                if v >= nextData.lvl then num = num + 1 end
            end
            if num >= nextData.lvl_count then self.isUp = true end
        end
    end
    self.upBtn:GetChild("red").visible = self.isUp or (not self.isJh and not self.init)
    self:setItemData(self.panelObj1,curData,self.init)
    self:setItemData(self.panelObj2,nextData)
    local confData = conf.KageeConf:getYwLimitById(self.xmid)
    if confData then
        local url = UIPackage.GetItemURL("kagee" , "ImageItem")
        local obj = self.listView:AddItemFromPool(url)
        obj:GetChild("n0").url = UIItemRes.kageeImg..confData.img
    end
end

function KageeTipsView1:setItemData(panel,data,init)
    local desc1 = panel:GetChild("n0")
    local desc2 = panel:GetChild("n1")
    local condition = panel:GetChild("n2")
    local listView = panel:GetChild("n5")
    local skillIcon = panel:GetChild("n8")
    local skillName = panel:GetChild("n9")
    local desc3 = panel:GetChild("n10")
    if data then
        local count = data.lvl_count
        local lev = data.lvl
        desc1.text = string.format(language.kagee26, data.id)
        desc2.text = string.format(language.kagee16, count, lev)
        local num = self:getSumByCount(lev)
        local color = 14
        local str = string.format(language.kagee17,num,count)
        if num >= count then
            color = 7
            str = language.kagee31
        end
        condition.text = mgr.TextMgr:getTextColorStr(str, color)
        local t = GConfDataSort(data)
        listView.itemRenderer = function(index,obj)
            local atti = t[index + 1]
            local value = atti[2]
            if init then
                value = 0
            end
            obj:GetChild("n1").text = conf.RedPointConf:getProName(atti[1]).." "..value
        end
        listView.numItems = #t
        local confData = conf.KageeConf:getYwLimitById(self.xmid)
        if confData then
            skillIcon.url = UIPackage.GetItemURL("kagee" , ""..confData.skill_icon)
            skillName.text = confData.skill_name.."Lv"..data.id
        end
        local rate = (data.rate / 100).."%"
        desc3.text = mgr.TextMgr:getTextColorStr(rate, 7)..data.desc
    end
end

--达到当前级别的生肖数量
function KageeTipsView1:getSumByCount(lev)
    local num = 0
    for k,lv in pairs(self.mData) do
        if lv >= lev then
            num = num + 1
        end            
    end
    return num
end

function KageeTipsView1:onClickUp()
    if not self.isJh and self.init then--不可以激活
        GComAlter(language.kagee29)
        return
    else
        if not self.isUp and self.isJh then--不可升级
            GComAlter(language.kagee30)
            return
        end
    end
    proxy.KageeProxy:send(1150102)
end

return KageeTipsView1
