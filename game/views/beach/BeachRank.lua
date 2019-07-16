--
-- Author: 
-- Date: 2018-01-03 16:30:55
--

local BeachRank = class("BeachRank", base.BaseView)

function BeachRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale

    self.sharePackage = {"vip"}
end

function BeachRank:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    self.listView = self.view:GetChild("n15")
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0

    local btnRecord = self.view:GetChild("n1")
    btnRecord.onClick:Add(self.onRecord,self)

    self._myrank = self.view:GetChild("n16")
    self._myrank.text = ""
    self._ml = self.view:GetChild("n17")
    self._ml.text = ""

    local dec1 = self.view:GetChild("n7")
    dec1.text = language.beach06
    local dec1 = self.view:GetChild("n9")
    dec1.text = language.beach07
    local dec1 = self.view:GetChild("n11")
    dec1.text = language.beach08

    local dec1 = self.view:GetChild("n18")
    dec1.text = language.beach09
    local dec1 = self.view:GetChild("n19")
    dec1.text = language.beach10
    local dec1 = self.view:GetChild("n20")
    dec1.text = language.beach07
    local dec1 = self.view:GetChild("n21")
    dec1.text = language.beach11
    local dec1 = self.view:GetChild("n22")
    dec1.text = language.beach12
    local dec1 = self.view:GetChild("n23")
    dec1.text = language.beach13
end

function BeachRank:initData()
    -- body
    self.c1.selectedIndex = 0
    self:onController1()
end

function BeachRank:setData(data_)

end

function BeachRank:onController1()
    -- body
    local param = {}
    param.page = 1
    param.reqType = self.c1.selectedIndex + 1 

    proxy.BeachProxy:sendMsg(1020422,param)
end

function BeachRank:cellData(index, obj)
    -- body
    if index+1 >= self.listView.numItems then
        if self.data.page < self.data.sumPage then
            local param = {}
            param.page = self.data.page + 1 
            param.reqType = self.c1.selectedIndex + 1 
            proxy.BeachProxy:sendMsg(1020422,param)
        end
    end

    local data = self.data.rankingInfos[index+1]
    local c1 = obj:GetController("c1")
    local _rank = obj:GetChild("n2")
    local _name = obj:GetChild("n4")
    local _gang = obj:GetChild("n5")
    local _ml = obj:GetChild("n6")
    local _micon = obj:GetChild("n8")  
    local _money = obj:GetChild("n9")  
    local _eff_ = obj:GetChild("n11") 
    _eff_.visible = G_BeachItem()

    if data.rank <= 3 then
        c1.selectedIndex = data.rank - 1
    else
        c1.selectedIndex = 3
    end

    _rank.text = data.rank

    _name.text= data.name

    _gang.text = data.gangName

    _ml.text = data.ml

    local confdata = conf.BeachConf:getRankReward(data.rank)
    if not confdata or not confdata.awards then
        _micon.visible = false
        _money.text = ""
    else
        _micon.visible = true
        _money.text = confdata.awards[1][2]
    end

    local btnSong = obj:GetChild("n7")
    btnSong.data = data
    btnSong.onClick:Clear()
    btnSong.onClick:Add(self.onBtnSong,self)
end

function BeachRank:onBtnSong(context)
    -- body
    local btn = context.sender
    local data = btn.data
    if not data then
        return
    end
    if data.roleId == cache.PlayerCache:getRoleId() then
        GComAlter(language.beach29)
        return
    end
    mgr.ViewMgr:openView2(ViewName.BeachSong, data)
end

function BeachRank:onRecord()
    -- body
    mgr.ViewMgr:openView2(ViewName.BeachRecord)
end

function BeachRank:addMsgCallBack(data)
    -- body
    if data.msgId == 5020422 then
        if data.page == 1 then
            self.data = {}
            self.data.sumPage = data.sumPage
            self.data.page = data.page
            self.data.rankingInfos = data.rankingInfos
            self.data.myRank = data.myRank
            self.data.reqType = data.reqType
        else
            self.data.sumPage = data.sumPage
            self.data.page = data.page
            self.data.myRank = data.myRank
            self.data.reqType = data.reqType
            
            for k ,v in pairs(data.rankingInfos) do
                table.insert(self.data.rankingInfos,v)
            end
        end

        self.listView.numItems = #self.data.rankingInfos

        self._myrank.text = string.format(language.beach14 , self.data.myRank.rank)
        self._ml.text = string.format(language.beach15 , self.data.myRank.ml)
    end
end

return BeachRank