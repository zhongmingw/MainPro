--
-- Author: 
-- Date: 2017-03-03 16:53:47
--

local PanelBangPaiList = import(".PanelBangPaiList")

local BangPaiFind = class("BangPaiFind", base.BaseView)

function BangPaiFind:ctor()
    self.super.ctor(self)
end

function BangPaiFind:initData(data)
    --货币管理
    local window2 = self.view:GetChild("n0")
    GSetMoneyPanel(window2,self:viewName())

    local closeBtn = window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.super.initData()
end

function BangPaiFind:initView()
    self.PanelBangPaiList = PanelBangPaiList.new(self.view:GetChild("n33"))
end

function BangPaiFind:setData(data_)

end

function BangPaiFind:onClickClose()
    -- body
    cache.BangPaiCache:setGuide(false)
    self:closeView()
end

-----帮派列表信息
function BangPaiFind:add1250102(data)
    -- body
    if not self.data then
        self.data = {}
    end
    self.data.page = data.page
    self.data.maxPage = data.maxPage
    self.data.gangName = data.gangName
    if self.data.page == 1 then
        self.data.gangList = data.gangList
    else
        for k ,v in pairs(data.gangList) do
            table.insert(self.data.gangList,v)
        end
    end
    self.PanelBangPaiList:setData(self.data)
    if self.data.page == 1 then
        self.PanelBangPaiList:gotoTop()
        self.PanelBangPaiList:selectTop()
    end
end

function BangPaiFind:add1250201(data)
    -- body
    --plog("callbackParam")
    if data.reqType == 1 then
        --从新请求帮派列表
        local param = {}
        param.gangName = ""
        param.page = 1
        proxy.BangPaiProxy:sendMsg(1250102, param)
    else
        for k ,v in pairs(data.gangIds) do
            for i , j in pairs(self.data.gangList) do
                if v == j.gangId then
                    self.data.gangList[i].applyStatu = 1 
                    break
                end
            end
        end
        self.PanelBangPaiList:updateCurData()
        self.PanelBangPaiList.listView:RefreshVirtualList()
    end
end

return BangPaiFind