--
-- Author: Your Name
-- Date: 2018-12-17 11:54:08
--

local YiJiTanSuoView = class("YiJiTanSuoView", base.BaseView)

function YiJiTanSuoView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function YiJiTanSuoView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n5")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.onClickItem:Add(self.onClickListItem,self)
end

function YiJiTanSuoView:initData(data)
    self.cityInfoData = conf.YiJiTanSuoConf:getCityInfo()
    self.listView.numItems = #self.cityInfoData
end

function YiJiTanSuoView:celldata(index,obj)
    local data = self.cityInfoData[index+1]
    if data then
        obj.data = data
        local nameTxt = obj:GetChild("n1")
        nameTxt.text = data[1].yj_name
        local cityImg = obj:GetChild("n2")
        cityImg.url = UIPackage.GetItemURL("yiji" , data[1].keng_img)

        local awardsList = obj:GetChild("n6")
        awardsList.numItems = 0
        awardsList.itemRenderer = function(i,cell)
            local info = data[1].awards_show[i+1]
            if info then
                local mid = info[1]
                local amount = info[2]
                local bind = info[3]
                GSetItemData(cell,{mid = mid,amount = amount,bind = bind},true)
            end
        end
        awardsList.numItems = #data[1].awards_show
    end
end

function YiJiTanSuoView:onClickListItem(context)
    local btn = context.data
    local data = btn.data
    if not data then
        return
    end
    printt("点击遗迹>>>>>>>>",data)
    mgr.ViewMgr:openView2(ViewName.YiJiTanSuoCity, data)
end

return YiJiTanSuoView