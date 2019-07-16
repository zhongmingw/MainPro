--
-- Author: 
-- Date: 2017-10-21 16:28:09
--

local TowerRankView = class("TowerRankView", base.BaseView)

function TowerRankView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function TowerRankView:initView()
    self.window4 = self.view:GetChild("n0")

    local btnClose = self.window4:GetChild("n2")
    btnClose.onClick:Add(self.onCloseView,self)

    self.dec1 = self.view:GetChild("n5")
    self.dec2 = self.view:GetChild("n6")
    self.dec2.data = self.dec2.xy
    self.dec3 = self.view:GetChild("n12")
    self.dec3.data = self.dec3.xy
    self.dec4 = self.view:GetChild("n7")
    self.dec5 = self.view:GetChild("n8")
    self.dec6 = self.view:GetChild("n9")
    self.dec7 = self.view:GetChild("n10")

    self.listView = self.view:GetChild("n4")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0
end

function TowerRankView:clear()
    -- body
    self.dec1.text = ""
    self.dec2.text = ""
    self.dec3.text = ""
    self.dec4.text = ""
    self.dec5.text = ""
    self.dec6.text = ""
    self.dec7.text = ""
end

function TowerRankView:cellData(index, obj)
    -- body
    local rankbg = obj:GetChild("n21")
    rankbg.url = nil 
    local rankbg1 = obj:GetChild("n22")
    rankbg1.url = nil 
    local rank = obj:GetChild("n23")
    rank.text = ""

    local dec1 = obj:GetChild("n24")
    dec1.text = ""

    local dec2 = obj:GetChild("n25")
    dec2.text = ""

    local dec3 = obj:GetChild("n26")
    dec3.text = ""

    local dec4 = obj:GetChild("n27") 
    dec4.text = ""

    if self.data.module_id then
        local data = self.data.data.ranking[index+1]
        if  data.rank > 0 and  data.rank < 4 then
            rankbg.url = UIItemRes.rank123[data.rank]
            rankbg1.url = UIItemRes.rank123yuan[data.rank]
        end 
        local _strname = data.roleName
        -- --排除掉服务器名字
        -- local ss = string.split(data.roleName,".")
        -- local _strname = ""
        -- for i , j in pairs(ss) do
        --     if i % 2 == 0 then
        --         _strname = _strname .. j
        --     end
        -- end 

        rank.text = data.rank
        dec1.text = _strname
        dec2.text = GTotimeString5(data.passSec)
        dec3.text = data.maxBo


        
        if self.data.module_id == 1131 or self.data.module_id == 1133 then
            dec4.text = ""
            dec1.x = (219 + 359)/2 - 8
        else
            
            if data.gangName == "" then
                dec4.text = language.friend38
            else
                dec4.text = data.gangName
            end
            dec1.x = 219
            dec4.x = 359
        end
    end
end

function TowerRankView:initData(data)
    -- body
    self:clear()
    self.data = data
    self:setData()
end

function TowerRankView:setData(data_)
    if self.data.module_id then
        if self.data.module_id == 1130 or self.data.module_id == 1132 then 
            self.window4.icon = "ui://fuben/jianshengshouhu_005" 
        else
            self.window4.icon = "ui://fuben/jianshengshouhu_010" 
        end
        if self.data.module_id == 1130 
            or self.data.module_id == 1132 
            or self.data.module_id == 1131
            or self.data.module_id == 1133 then 
            self.listView.numItems = #self.data.data.ranking 
            self.listView:ScrollToView(0)
            self.dec1.text = language.fuben132
            self.dec2.text = language.fuben133
            self.dec3.text = language.fuben134
            self.dec4.text = language.fuben135
            self.dec5.text = language.fuben136
            self.dec6.text = language.fuben137

            if self.data.module_id == 1131 or self.data.module_id == 1133 then
                self.dec3.text = ""
                self.dec2.x = (self.dec2.data.x + self.dec3.data.x)/2
            else
                self.dec3.x = self.dec3.data.x
                self.dec2.x = self.dec2.data.x
            end

            if self.data.data.myRankInfo.rank == 0 then
                self.dec7.text = language.kuafu50
            else
                self.dec7.text = self.data.data.myRankInfo.rank
            end
        end
    end
end

function TowerRankView:onCloseView()
    -- body
    self:closeView()
end

return TowerRankView