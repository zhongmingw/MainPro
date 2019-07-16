--
-- Author: Your Name
-- Date: 2017-08-09 21:08:12
--
local ActiveRedBag = class("ActiveRedBag", base.BaseView)

function ActiveRedBag:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
end

function ActiveRedBag:initView()
    local closeBtn = self.view:GetChild("n13"):GetChild("n13")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.listView = self.view:GetChild("n39")
    self.listView.numItems = 0
    self.hasYb = 0
    self.model = self.view:GetChild("n35")
    self.text1 = self.view:GetChild("n27")
    self.text2 = self.view:GetChild("n28")
    self.text3 = self.view:GetChild("n29")
    self.text4 = self.view:GetChild("n30")
    for i=1,3 do
        local getItem = self.view:GetChild("n4"..(i-1))
        getItem.visible = false
    end
end

function ActiveRedBag:initData()
    local desTxt = self.view:GetChild("n34")
    desTxt.text = language.active18
    local maxYb = conf.ActivityConf:getValue("active_red_bag_top")
    local textData = {
                    {text = language.active10,color = 6},
                    -- {text = maxYb,color = 7},
                    -- {text = language.active11,color = 6},
            }
    self.text2.text = mgr.TextMgr:getTextByTable(textData)
    local ybPr = conf.ActivityConf:getValue("active_red_bag_yb_per")
    local textData = {
                    {text = language.active12,color = 6},
                    {text = (ybPr/100) .. "%",color = 7},
                    {text = language.active13,color = 6},
            }
    self.text3.text = mgr.TextMgr:getTextByTable(textData)

    local hyPr = conf.ActivityConf:getValue("active_red_bag_byb_per")
    local textData = {
                    {text = language.active15,color = 6},
                    {text = (hyPr/100) .. "%",color = 7},
                    {text = language.active16,color = 6},
            }
    self.text4.text = mgr.TextMgr:getTextByTable(textData)

    local awardsData = conf.ActivityConf:getValue("active_red_bag_fashion")
    local sex = cache.PlayerCache:getSex()
    local mId = awardsData[sex][1]
    if mId then
        local skinId = conf.ItemConf:getSuitmodel(mId)
        local suitArr = conf.ItemConf:getSuitTransformDataById(mId)
        -- local confData = conf.HuobanConf:getSkinsData(skinId)
        local obj = self:addModel(skinId[1][1],self.model)
        -- local chibangMid = awardsData[2][1]
        -- local chibangSkindId = conf.ItemConf:getItemExt(chibangMid)
        -- -- print("伙伴仙羽id",chibangSkindId,chibangMid)
        -- local chibangConf = conf.HuobanConf:getXianyuSkinsData(chibangSkindId)
        -- obj:setSkins(nil,nil,chibangConf.modle_id)
        -- obj:addModelEct(4040698)--伙伴灵宝特效id

        obj:setScale(180)
        obj:setRotationXYZ(suitArr[2][1],suitArr[2][2],suitArr[2][3])
        obj:setPosition(0,-500,1000)
    end
    if self.timers then
        self:removeTimer(self.timers)
        self.timers = nil 
    end

    self.timers = self:addTimer(1,-1,handler(self,self.onTiemr))
end

function ActiveRedBag:onTiemr()
    if not self.data then
        self.text1.text = ""
        return
    end

    self.data.leftTime = self.data.leftTime - 1
    if self.data.leftTime < 0 then
        self.data.leftTime = 0
    end

    local param = clone(language.active20)
    param[2].text = string.format(param[2].text,GGetTimeData2(self.data.leftTime))

    self.text1.text = mgr.TextMgr:getTextByTable(param)
end

function ActiveRedBag:onClickget(context)
    local data = context.sender.data
    local needYbData = conf.ActivityConf:getValue("active_red_bag_fashion_cond")
    local ybPr = conf.ActivityConf:getValue("active_red_bag_yb_per")
    local needYb = needYbData[data.index] / (ybPr/10000)
    if not data.flag and self.data.costYb >= needYb then
        proxy.ActivityProxy:sendMsg(1030204, {reqType = 2,stage = data.index})
    else
        if data.flag then
            GComAlter(language.active05)
        else
            GComAlter(language.active01)
        end
    end
end

function ActiveRedBag:addMsgCallBack(data)
    self.hasYb = 0
    self.listView.numItems = 0
    self.data = data
    local param = clone(language.active20)
    param[2].text = string.format(param[2].text,GGetTimeData2(self.data.leftTime))

    self.text1.text = mgr.TextMgr:getTextByTable(param)
    -- local textData = {
    --                 {text = language.active08,color = 6},
    --                 {text = 5-data.curDay,color = 7},
    --                 {text = language.active09,color = 6},
    --         }
    -- self.text1.text = mgr.TextMgr:getTextByTable(textData)
    -- for k,v in pairs(data.redBags) do
    --     print(k,v)
    -- end
    for i=1,3 do
        local objItemUrl = UIPackage.GetItemURL("activeredbag" , "RedBagItem2")
        if data.curDay == i then
            objItemUrl = UIPackage.GetItemURL("activeredbag","RedBagItem")
        end
        if data.redBags[100+i] then
            self.hasYb = data.redBags[100+i]
        end

        local Obj = self.listView:AddItemFromPool(objItemUrl)

        local ybNum = Obj:GetChild("n1")
        if data.redBags[100+i] then
            ybNum.text = data.redBags[100+i]
        else
            ybNum.text = 0
        end
        
        local bybNum = Obj:GetChild("n2")
        if data.redBags[200+i] then
            bybNum.text = data.redBags[200+i]
        else
            bybNum.text = 0
        end
        local dayIcon = Obj:GetChild("n10")
        if i < 4 then
            dayIcon.url = UIPackage.GetItemURL("activeredbag" ,"huoyuehongbao_00"..(3+i))
        else
            dayIcon.url = UIPackage.GetItemURL("activeredbag" ,"huoyuehongbao_020")
        end
    end
    local awardsData = conf.ActivityConf:getValue("active_red_bag_fashion")
    local condData = conf.ActivityConf:getValue("active_red_bag_fashion_cond")
    for i=1,#condData do
        local getItem = self.view:GetChild("n"..(42 + i- #condData))
        getItem.visible = true
        local getBtn = getItem:GetChild("n1")
        local redPoint = getBtn:GetChild("n5")
        local dexTxt = getItem:GetChild("n4")
        dexTxt.text = language.active18_1
        redPoint.visible = false
        local flag = false
        for k,v in pairs(data.gotItems) do
            if condData[v] == condData[i] then
                flag = true
                break
            end
        end
        local objItem = getItem:GetChild("n3")
        local sex = cache.PlayerCache:getSex()
        if awardsData[sex] then
            local mid = awardsData[sex][1]
            local amount = awardsData[sex][2]
            local bind = awardsData[sex][3]
            local info = {mid = mid , amount = amount , bind = bind}
            GSetItemData(objItem, info, true)
        end

        local needYbData = conf.ActivityConf:getValue("active_red_bag_fashion_cond")
        local ybPr = conf.ActivityConf:getValue("active_red_bag_yb_per")
        local needYb = needYbData[i] / (ybPr/10000)
        if flag or data.costYb < needYb  then
            getBtn:GetChild("n4").url = UIPackage.GetItemURL("activeredbag" ,"huoyuehongbao_013")
        else
            getBtn:GetChild("n4").url = UIPackage.GetItemURL("activeredbag" ,"huoyuehongbao_012")
            redPoint.visible = true
        end
        getBtn.data = {flag = flag,index = i}
        getBtn.onClick:Add(self.onClickget,self)

        local pressText = getItem:GetChild("n5")
        local textData = {
                            {text = data.costYb,color = 14},
                            {text = "/" .. needYb,color = 7},
                            -- {text = language.active17,color = 6},
                        }
        if data.costYb >= needYb then
            textData = {
                            {text = data.costYb,color = 7},
                            {text = "/" .. needYb ,color = 7},
                            -- {text = language.active17,color = 6},
                        }
        end
        pressText.text =  mgr.TextMgr:getTextByTable(textData)
    end
end

function ActiveRedBag:onClickClose()
    -- cache.PlayerCache:setAttribute(30119,self.data.redBags[100+self.data.curDay])
    -- GIsOpenWishPop(30119)
    self:closeView()
end

return ActiveRedBag