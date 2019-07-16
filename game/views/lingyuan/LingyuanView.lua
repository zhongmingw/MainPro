--
-- Author: 
-- Date: 2017-08-18 14:53:06
--

local LingyuanView = class("LingyuanView", base.BaseView)

function LingyuanView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function LingyuanView:initData(data)
    -- body
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil 
    end

    self.btnData = data._condata
    -- printt("##",self.btnData)
    self.index = data.index
    self.zuoqi = nil 
    self.model = nil 
    if data.param then
        -- printt("零元购",data.param)
        self:add5030206(data.param,true)
    end
    
    self.timer = self:addTimer(1,-1,handler(self,self.onTimer))
    
end

function LingyuanView:initView()
    local btnClose = self.view:GetChild("n27")
    btnClose.onClick:Add(self.onBtnClose,self)
    --大标题
    self.iconbig = self.view:GetChild("n3")
    --奖励
    self.listView = self.view:GetChild("n11")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    --购买
    self.buyPrice = self.view:GetChild("n30")
    self.buyPrice.text = ""
    self.oldPrice = self.view:GetChild("n39")
    self.oldPrice.text = "262632"
    self.c1 = self.view:GetController("c1")

    self.btnBuy = self.view:GetChild("n13")
    self.btnBuy.onClick:Add(self.onShopBuy,self)
    --剩余时间
    self._decbottom = self.view:GetChild("n16")
    self._decbottom.text = ""
    --8个按钮
    self.btnList = {}
    for i = 1 , 8 do
        local btn = self.view:GetChild("btn"..i)
        btn.onClick:Add(self.onBtnList,self)
        table.insert(self.btnList,btn)
    end
    --模型 和 称号
    self.panle = self.view:GetChild("n17")
    self.panle1 = self.view:GetChild("n22")
    self.titleImage = self.view:GetChild("n21")
    self.titleImage.data = self.titleImage.xy
    self.t1 = self.titleImage:GetTransition("t0")

    self.titleImage2 = self.view:GetChild("n31"):GetChild("n0")

    self.isget = self.view:GetChild("n28")

    self.t2 = self.view:GetTransition("t0")
    
    local haveTitle = self.view:GetChild("n33")
    haveTitle.text = language.lingyuan07

    self.leftYb = self.view:GetChild("n44")


end

function LingyuanView:onTimer()
    -- body
    if not self.data then
        return
    end
    self.data.todayLeftTime = self.data.todayLeftTime - 1
    if self.data.todayLeftTime > 0 and not self.isget.visible then
        local var = GGetTimeData2(self.data.todayLeftTime)

        if self.confData.ctype == 2 then
            local time = self.data.todayLeftTime + (9-self.data.openDay)*24*3600
            var = GGetTimeData2(math.max(time,0))  
        end
        
        
        if self.confData.price[1] == 0 then
            self._decbottom.text =string.format(language.lingyuan06,var) 
        else
            self._decbottom.text =string.format(language.lingyuan03,var) 
        end
    else
        self._decbottom.text = ""
    end
end

function LingyuanView:onController1(param)
    -- body
    --按钮红点设定
    -- for k ,v in pairs(self.btnList) do
    --     local redimg  = v:GetChild("red")
    --     redimg.visible = false
    --     if v.visible and v.data then
    --         --plog(v.data,"v.data")
    --         if self.data.signMap[v.data] == 3 then
    --             v:GetChild("red").visible = true
    --         end
    --     end
    -- end
    --称号坐标问题
   
    -- self.isplay = false
    -- self:removeTimer(self.timer1)
    -- self:removeTimer(self.timer2)
    -- self.timer1 = nil
    -- self.timer2 = nil 
    self.t1:Stop()
    self.t2:Stop()
    self.titleImage.xy = self.titleImage.data

    
    self.confData = param
    -- printt("当前界面信息",param)
   
    --限量的
    local xianliangTxt = self.view:GetChild("n32")
    if param.count then
        local num = self.data.counts[param.id] or 0
        xianliangTxt.visible = true
        xianliangTxt.text = "(" .. language.kaifu67 .. (param.count - num) .. ")"
    else
        xianliangTxt.visible = false
    end

    self.buyPrice.text = param.price[1]
    if param.old_price == 0 then --不打折
        self.c1.selectedIndex = 0
    else
        self.c1.selectedIndex = 1
        self.oldPrice.text = tostring(param.old_price)
    end


    if param.price[1] == 0 then
        self.btnBuy.icon = UIPackage.GetItemURL("lingyuan" , "xinshouyingdao_027")
    else
        self.btnBuy.icon = UIPackage.GetItemURL("lingyuan" , "xinshouyingdao_064")
    end
    --模型初始化
    self:initModel()
    --奖励初始化
    self.listView.numItems = #self.confData.items
    --标题
    if self.confData.icon3 then
        if self.confData.icon3 == "lingyuangou_031" then
            self.iconbig.url = UIPackage.GetItemURL("_share" , tostring(self.confData.icon3))
        else
            self.iconbig.url = UIPackage.GetItemURL("lingyuan" , tostring(self.confData.icon3))
        end
        -- if self.confData.icon3 == "lingyuangou_030" 
        --     or "lingyuangou_060" == self.confData.icon3 
        --     or "lingyuangou_059" == self.confData.icon3  then
        --     self.iconbig.url = UIPackage.GetItemURL("_icons" , tostring(self.confData.icon3))
        -- else
            
        -- end
    else
        self.iconbig.url = nil
    end
    --
    if self.data.signMap[tonumber(self.confData.id)] then
        --已购买
        -- self.btnBuy.visible = false
        -- self.isget.visible = true
        self.btnBuy.grayed = true

    else
        self.btnBuy.grayed = false
        -- self.btnBuy.visible = true
        -- self.isget.visible = false
    end
end

function LingyuanView:RunAction()
    -- body
    -- if not self.isplay then
    --     return
    -- end
    -- local time1 = 1
    -- local time2 = 1

    -- self.moveing = self.titleImage:TweenMoveY(self.titleImage.data.y - 13,time1)
    -- --plog("self.moveing",self.moveing)
    -- self.timer1 = self:addTimer(time1, 1,function( ... )
    --     -- body
    --     self.moveing = self.titleImage:TweenMoveY(self.titleImage.data.y ,time2)
    -- end)
    -- self.timer2 = self:addTimer(time1+time2, 1,function( ... )
    --     -- body
    --     self:RunAction()
    -- end)
end

function LingyuanView:initModel()
    -- body
    if self.zuoqi then
        self:removeModel(self.zuoqi)
        self.zuoqi = nil 
    end

    if not self.confData.modle_id then
        if self.model then
            self:removeModel(self.model)
            self.model= nil 
        end
    end
    self.titleImage2.url = nil 
    local titleurl = self.titleImage:GetChild("n0")
    titleurl.url = nil
    self:removeUIEffect(self.effect1)
    self:removeUIEffect(self.effect2)
    self.effect1 = nil
    self.effect2 = nil 
    if type(self.confData.modle_id) == "string" then
        --区分是特效 还是 图片
        local str = string.split(self.confData.modle_id,"_")
        if #str==2 and str[2] =="ui" then 
            --是特效
            --plog("self.confData.modle_id",self.confData.modle_id)
            self.effect1 = self:addEffect(str[1],self.panle)
            local x = 0
            local y = 0
            local z = 0
            if self.confData.xyz then
                x = self.confData.xyz[1]
                y = self.confData.xyz[2]
                z = self.confData.xyz[3]
            end
            self.effect1.LocalPosition = Vector3.New(x,y,500)
            --缩放
            if self.confData.scale then
                self.effect1.Scale = Vector3.New(self.confData.scale,self.confData.scale,self.confData.scale)
            end 

            if self.confData.isplay then
                self.t2:Play()
            end
            return
        end
        if "shizhuangchenghao_056" ~= self.confData.modle_id then
            local iconUrl = UIItemRes.activeIcons..self.confData.modle_id
            local check = PathTool.CheckResDown(iconUrl..".unity3d")
            if check or g_extend_res == false then
                --titleurl.url =  iconUrl
                self:setLoaderUrl(titleurl,iconUrl)
            else
                titleurl.url = nil
            end
        else
            titleurl.url = ResPath.titleRes("shizhuangchenghao_056")
        end
        local x = 0
        local y = 0
        if self.confData.xyz then
            x = x + self.confData.xyz[1]
            y = x + self.confData.xyz[2]
        end
        self.titleImage.x = self.titleImage.data.x +  x
        self.titleImage.y = self.titleImage.data.y +  y

        self.effect1 = self:addEffect(4020203,self.panle)
        self.effect1.LocalPosition = Vector3.New(47.2,0,500)
        self.effect2 = self:addEffect(4020202,self.panle1)
        self.effect2.LocalPosition = Vector3.New(53.7,-122.28,500)

        if self.confData.isplay then
            self.t1:Play()
        end


        --称号
        if self.confData.title then
            self.titleImage2.url = ResPath.titleRes(self.confData.title)
            self.titleImage2.parent.y = self.titleImage.data.y + (self.confData.title_y or 0)
            self.titleImage2.parent.x = self.panle.x - self.titleImage.width/2 + self.panle.actualWidth/2  
        else
            self.titleImage2.url = nil
        end
        return
    end
    
    self:removeUIEffect(self.effect1)
    self:removeUIEffect(self.effect2)
    self.effect1 = nil
    self.effect2 = nil 


    local id = self.confData.modle_id
    if type(self.confData.modle_id) == "table" then
        id = self.confData.modle_id[1]
    end

    self.model = self:addModel(id,self.panle)
    if type(self.confData.modle_id) == "table" then
        self.model:setSkins(self.confData.modle_id[1],self.confData.modle_id[2]
            ,self.confData.modle_id[3])
    end
    --缩放
    if self.confData.scale then
        self.model:setScale(self.confData.scale)
    end
    --位置和层
    local xyz = {self.panle.actualWidth/2,-self.panle.actualHeight-200,500}
    if self.confData.xyz then
        xyz[1] =self.confData.xyz[1]
        xyz[2] =self.confData.xyz[2]
        xyz[3] =self.confData.xyz[3]
    end
    self.model:setPosition(xyz[1],xyz[2],xyz[3])
    --旋转
    if self.confData.rationxyz then
        local x = self.confData.rationxyz[1]
        local y = self.confData.rationxyz[2]
        local z = self.confData.rationxyz[3]
        self.model:setRotationXYZ(x,y,z)
    end 

    
    if self.confData.type_effid then
        if self.confData.type_effid[1] == 1 then 
            self.model:addModelEct(self.confData.type_effid[2].."_ui")
        else
            self.model:addWeaponEct(self.confData.type_effid[2].."_ui")
        end
    end
    --printt(self.confData)
    

    --模型偏移2--[3010104,3010204]

    -- if self.confData.id == 9999 then
    --     local _id_ = cache.PlayerCache:getSkins(Skins.clothes)
    --     local sex = cache.PlayerCache:getSex()
    --     if sex == 1 then
    --         _id_ = 3010104
    --     else
    --         _id_ = 3010204
    --     end
    --     self.zuoqi = self:addModel(_id_,self.panle1,nil,"mount_idle")
    --     --位置和层
    --     local rolexyz = {self.panle1.actualWidth/2+10,-self.panle1.actualHeight-40,500}
    --     if self.confData.xyz_role then
    --         rolexyz[1] = self.confData.xyz_role[1]
    --         rolexyz[2] = self.confData.xyz_role[2]
    --         rolexyz[3] = self.confData.xyz_role[3]
    --     end
    --     self.zuoqi:setPosition( rolexyz[1],rolexyz[2] - 154.8,500+rolexyz[3])
    --     --旋转
    --     if self.confData.rationxyz_role then
    --         local x = self.confData.rationxyz_role[1]
    --         local y = self.confData.rationxyz_role[2]
    --         local z = self.confData.rationxyz_role[3]
    --         self.zuoqi:setRotationXYZ(x,y,z)
    --     end  
    --     --缩放
    --     if self.confData.scale_role then
    --         self.zuoqi:setScale(self.confData.scale_role)
    --     end 
    -- end
    

    --称号
    if self.confData.title then
        titleurl.url = ResPath.titleRes(self.confData.title)
        self.titleImage.y = self.titleImage.data.y + (self.confData.title_y or 0)
        self.titleImage.x = self.panle.x - self.titleImage.width/2 + self.panle.actualWidth/2  
    else
        titleurl.url = nil
    end

    --self.isplay = false
    --self:RunAction()

   
end

--奖励显示
function LingyuanView:celldata(index, obj)
    -- body
    local data = self.confData.items[index+1]
    local t = {mid = data[1],amount = data[2],bind = data[3] }
    GSetItemData(obj,t,true)
end

function LingyuanView:setData()

end



function LingyuanView:onShopBuy()
    -- body
    --购买 or 领取
    if self.confData.buy_lev and self.confData.buy_lev > cache.PlayerCache:getRoleLevel() then
        GComAlter(string.format(language.lingyuan01,self.confData.buy_lev))
        return
    end
    if self.btnBuy.grayed then
        GComAlter(language.lingyuan08)
        return
    end
    proxy.ActivityProxy:sendMsg(1030206,{reqType = 1,cId = self.confData.id})
    -- if self.c2.selectedIndex == 1 then --购买
    --     if self.data.signMap[self.confData.id] == 1 then
    --         proxy.ActivityProxy:sendMsg(1030206,{reqType = 1,cId = self.confData.id})
    --     end
    -- else
    --     --plog("self.data.signMap[self.confData.id] == 2",self.data.signMap[self.confData.id] )
    --     if self.data.signMap[self.confData.id] == 2 then
    --         GComAlter(string.format(language.lingyuan05,self.confData.return_day))
    --     else
    --         proxy.ActivityProxy:sendMsg(1030206,{reqType = 2,cId = self.confData.id})
    --     end
    -- end
end

function LingyuanView:onBtnList(context)
    -- body
    if not self.data then
        return
    end
    local data = context.sender.data
    if not data then
        return
    end
    for k ,v in pairs(self.btnList) do
        if v.data and v.visible then
            v.selected = false
            --v.icon = UIPackage.GetItemURL("lingyuan" , tostring(v.data.icon1))
        end
    end
    context.sender.selected = true
    --context.sender.icon = UIPackage.GetItemURL("lingyuan" , tostring(data.icon2))
    --self.btnBuy.visible = true
    --self.isget.visible = false
    self.selectbtn = context.sender
    self:onController1(data)
end

function LingyuanView:onBtnClose()
    -- body
    self:closeView()
end

function LingyuanView:setStep(index)
    -- body
    self.index = index
end

function LingyuanView:setBtndata(data)
    -- body
    self.btnData = data
end

function LingyuanView:add5030206(data,flag)
    -- body
    self.data = data
    if not self.data then
        return
    end
    local ybData = cache.PackCache:getPackDataById(PackMid.gold)
    self.leftYb.text = ybData.amount
    if data.reqType == 0 or data.reqType == 1 then --显示 或者购买
        --按钮初始化
        for i = 1 , 8 do --默认8个按钮不限
            self.btnList[i].visible = false
        end
        --按当前天数获取按钮
        for k ,v in pairs(self.btnData) do
            if k > 8 then
                break
            end
            self.btnList[k].visible = true
            self.btnList[k].data = v
            self.btnList[k].selected = false
            self.btnList[k].title = v.icon1
            --限一天图片
            local img = self.btnList[k]:GetChild("n4")
            if img then
                if v.ctype == 1 then
                    img.visible = false--bxp改成特惠礼包后没有限制 
                else
                    img.visible = false
                end
            end
            --限量图
            local countImg = self.btnList[k]:GetChild("n5")
            if v.count then
                countImg.visible = true
            else
                countImg.visible = false
            end
        end
        local key = 1
        if self.index then
            for k ,v in pairs(self.btnList) do
                if v.data and v.visible and v.data.id == self.index then
                    key = k
                    break
                end
            end
            self.index = nil
        end
        if flag then
            if self.btnList[key] then
                self.btnList[key].onClick:Call()
            end
        else
            if self.selectbtn then
                self.selectbtn.onClick:Call()-- self:onController1(self.confData)
            end
        end
    end


end

return LingyuanView