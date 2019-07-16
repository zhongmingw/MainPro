--
-- Author: 
-- Date: 2018-10-31 15:08:02
--

local OpenAlertView = class("OpenAlertView", base.BaseView)

function OpenAlertView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function OpenAlertView:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
    local sureBtn = self.view:GetChild("n4")
    sureBtn.onClick:Add(self.onClickSureBtn,self)
    self.title = self.view:GetChild("n3")
    self.itemObj = self.view:GetChild("n5"):GetChild("n7")
end

function OpenAlertView:initData(data)
    if data then
        self.data = data
        local mid = data.item[1] 
        local amount = data.item[2]
        local quality = conf.ItemConf:getQuality(mid)
        local name = conf.ItemConf:getName(mid)
        local str = mgr.TextMgr:getQualityStr1(name.."X"..amount,quality)
        self.title.text = string.format(language.eightgates07,str,language.eightgates04[data.site])
        local t = {}
        t.mid = mid
        t.amount = 1
        t.bind = 1
        GSetItemData(self.itemObj,t, true)

        local packdata = cache.PackCache:getPackDataById(mid)
        local color = packdata.amount < amount and 14 or 10
        local textData = {
                {text = tostring(packdata.amount),color = color},
                {text = "/",color = 10},
                {text = tostring(amount),color = 10},
            }
        self.view:GetChild("n5"):GetChild("n13").text = mgr.TextMgr:getTextByTable(textData)
    end

end

function OpenAlertView:onClickSureBtn()
    -- print("请求开启孔位",self.data.site)
    proxy.AwakenProxy:send(1610101,{site = self.data.site})
    self:closeView()
end

return OpenAlertView