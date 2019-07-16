--
-- Author: 
-- Date: 2018-12-10 12:53:12
--
local  time = {2.1,2.4,3}
local startMaxNum = conf.MianJuConf:getGlobal("mask_start_max")
local MianJuShengXinAndFuMoView = class("MianJuShengXinAndFuMoView", base.BaseView)
local  fuMoMaxLevel = conf.MianJuConf:getGlobal("mask_fm_max_level")

function MianJuShengXinAndFuMoView:ctor(parent)
    self.super.ctor(self)
    self.parent = parent
    -- self.uiLevel = UILevel.level3 
end

function MianJuShengXinAndFuMoView:initView()
    self.c1 = self.view:GetController("c1")
    self.btn1 = self.view:GetChild("n6") -- 升星或者附魔按钮
    self.btn1.onClick:Add(self.onClick01,self)

    self.closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self.closeBtn.onClick:Add(self.onClose,self)
    self:setCloseBtn(self.closeBtn)
    self.heroModel = self.view:GetChild("n18"):GetChild("n18")

    self.effectPanel = self.view:GetChild("n18"):GetChild("n67")

    local XinXin = self.view:GetChild("n69") -- 星星
    self.starC = XinXin:GetController("c1")
    self.item = self.view:GetChild("n7") -- 道具
    self.itemText = self.view:GetChild("n47") -- 道具消耗文本s
    
    self.listview01 = self.view:GetChild("n46") --升星属性列表


    --附魔文本组件
    self.fumoTexCom1 = self.view:GetChild("n55")
    self.fumoTexCom2 = self.view:GetChild("n66")
    self.texList01 = {}
    self.texList02 = {}
    self.texList03 = {} -- 附魔文本


    for i = 55,63 do 
        local  j = i -47
        local text = self.fumoTexCom1:GetChild("n"..i)
        local text1 = self.fumoTexCom2:GetChild("n"..i)
        local text2 = self.view:GetChild("n"..j)

        table.insert(self.texList01, text)
        table.insert(self.texList02, text1)
        table.insert(self.texList03, text2)

    end

    self.titleIcon = self.view:GetChild("n67")

end

function MianJuShengXinAndFuMoView:onClose()
    self:closeView()
end

function MianJuShengXinAndFuMoView:initData(data)
    self.btn1.data = {}
    self.btn1:GetChild("red").visible = false
    self:addPanelModel()
    -- local index = math.floor(cache.MianJuCache:getMianJuChooseData().id/1000)
    local confData = conf.MianJuConf:getMianJuData(cache.MianJuCache:getMianJuChooseData().id)
    if confData then
        self.titleIcon.url = UIPackage.GetItemURL("shenqi" , confData.mainju_name)
    end

    if data.selectedIndex == 0 then --附魔
        self.coms = {}
        for i = 49,51 do 
            table.insert(self.coms,{ obj = self.view:GetChild("n"..i),isFind = false})
        end
          for k,v in pairs(self.coms) do
            
             v.obj:GetChild("n0"):GetChild("n52").url = ""
        end
        self.c1.selectedIndex  = 0
        self.oldelements = nil
        self.oldfmLevel = nil
        self.isfirst = true
        self:refreshFumoView()
        

    elseif  data.selectedIndex == 1 then --升星
        self:refreshStartView()
    end
end

function MianJuShengXinAndFuMoView:onClickRule()
    GOpenRuleView(1168)
end



--升星刷新
function MianJuShengXinAndFuMoView:refreshStartView()
    self.btn1:GetChild("red").visible = self:calStartRedPoint()
 
    self.upstart = false -- false：没有达到顶级
    self.mianjuData = cache.MianJuCache:getMianJuChooseData()
    -- printt(self.mianjuData)
    -- print("升星刷新数据")
    self.c1.selectedIndex  = 1
    self.listview01.numItems = 0 
    local data_1 = conf.MianJuConf:getMianjuStartData(self.mianjuData.id,(self.mianjuData.starNum >= startMaxNum and startMaxNum or self.mianjuData.starNum))
    local data_2 = conf.MianJuConf:getMianjuStartData(self.mianjuData.id,(self.mianjuData.starNum >= startMaxNum+ 1  and startMaxNum +1 or self.mianjuData.starNum +1)) or nil

    local data1 =  GConfDataSort(clone(data_1))
    local data2 = GConfDataSort(clone(data_2)) 
  
    for k,v in pairs(data1) do
        local url = UIPackage.GetItemURL("shenqi" , "Component22")
        baseitem = self.listview01:AddItemFromPool(url)
        baseitem:GetChild("n100").text = conf.RedPointConf:getProName(v[1])
        baseitem:GetChild("n110").text = GProPrecnt(v[1],v[2])
        local upImg = baseitem:GetChild("n21") 
        if data2[k]  then
            upImg.visible = true
            baseitem:GetChild("n120").text = GProPrecnt(data2[k][1],data2[k][2])
        else
            upImg.visible = false
            baseitem:GetChild("n120").text = ""
        end
    end
    -- 更新星星数
    
    self.starC.selectedIndex = self.mianjuData.starNum >=5 and 5 or self.mianjuData.starNum
    local maskId1 =  conf.MianJuConf:getMianjuIdData(self.mianjuData.mid).id
    self.btn1.data = {state = 1 ,maskId  = maskId1,maskType = self.mianjuData.index}
    --更新消耗材料
    if data_1.item ~= nil then
        GSetItemData(self.item,{mid =  data_1.item[1][1],amount = 1 ,bind = 0 ,isquan = true}, true)
        self.num1 = 0 -- 当前拥有
        self.num2 = 0 --升星所需
        self.num1 = cache.PackCache:getPackDataById(self.mianjuData.mid).amount or 0
        self.num2 = data_1.item[1][2]
        self.itemText.visible =true
        self.itemText.text = self.num1 >= self.num2 and  "[color=#0b8109]"..self.num1.."/"..self.num2.."[/color]" or  "[color=#da1a27]"..self.num1.."[/color][color=#0b8109]".."/"..self.num2.."[/color]"
    else
        self.num1 = 0 
        self.num2 = 0 
        self.item.visible = false
        self.itemText.visible =false
      
        self.upstart = true
    end
    
        
end

--附魔刷新
function MianJuShengXinAndFuMoView:refreshFumoView()
    self.btn1:GetChild("red").visible = self:calFumoRedPoint()
    self.mianjuData = cache.MianJuCache:getMianJuChooseData()

    -- printt("当前面具信息",self.mianjuData)
    self:refreshFumoTex()
    self:refreshFumoCom()--刷新附魔的三个组件
end


--更新附魔文本

function MianJuShengXinAndFuMoView:refreshFumoTex()

    if self.mianjuData.fmLevel <= 10 then
        local  data1 = conf.MianJuConf:getMianJuFuMo(self.mianjuData.id,self.mianjuData.fmLevel or 0) --当前
        local data2 = GConfDataSort(data1)
        for k,v in pairs(self.texList01) do
            if data2[k] then
                local str =  conf.RedPointConf:getProName(data2[k][1]).."+" ..GProPrecnt(data2[k][1],data2[k][2])
                v.text = mgr.TextMgr:getTextColorStr( str,20)
            else
                v.text = ""
                if k == 8 then
                    if self.mianjuData.fmLevel == 0 then
                        v.text = mgr.TextMgr:getTextColorStr( string.format(language.mianju08,"零"),20)

                    else
                        v.text = mgr.TextMgr:getTextColorStr( string.format(language.mianju08,self:numberToString(self.mianjuData.fmLevel or 0)),20)
                    end
                end
            end
        end
        
        local  data3 = conf.MianJuConf:getMianJuFuMo(self.mianjuData.id,(self.mianjuData.fmLevel or 0 ) +1) --下一级
        local data4 = GConfDataSort(data3)

        for k,v in pairs(self.texList02) do
            if data4[k] then
                local str  = conf.RedPointConf:getProName(data4[k][1]).."+".. GProPrecnt(data4[k][1],data4[k][2])
                v.text = str
               
            else
              
                v.text =  ""
                if k == 8 then
                    v.text = string.format(language.mianju10, self:numberToString(self.mianjuData.fmLevel + 1) )
                elseif k == 7 then
                    v.text = language.mianju09
                end
            end
        end
        local data5 = conf.MianJuConf:getMianJuFuMo(self.mianjuData.id,self.mianjuData.fmLevel or 0).elements -- 当前附魔对应元素
        for k1,v1 in pairs(self.texList03) do
            local  data  = conf.MianJuConf:getMianJuFuMoKongWei(self.mianjuData.id,self.mianjuData.fmLevel or 0,k1)
            local data1 = GConfDataSort(data)
      
            for k,v in pairs(data1) do
                if self.mianjuData.elements[k1] == data5[k1] then
                    v1.text = mgr.TextMgr:getTextColorStr(  language.mianju15[data5[k1]]..conf.RedPointConf:getProName(v[1]).."+"..GProPrecnt(v[1],v[2]),10 )
                    v1.stroke = 1
                    self.coms[k1].obj:GetChild("icon").url = UIPackage.GetItemURL("shenqi" , "mianju_017") 
                else
                     v1.text = mgr.TextMgr:getTextColorStr(  language.mianju15[data5[k1]].. conf.RedPointConf:getProName(v[1]).."+"..GProPrecnt(v[1],v[2]),8 )
                    v1.stroke = 0
                    self.coms[k1].obj:GetChild("icon").url = UIPackage.GetItemURL("shenqi" , "mianju_016") 
                end
             
            end
        end
        --达到定级时
        if self.mianjuData.fmLevel == 10 then
            for k,v in pairs(self.texList02) do
                v.text = ""
            end
        end
    else -- 附魔等级大于10级走这
        local  data1 = conf.MianJuConf:getMianJuFuMo(self.mianjuData.id,fuMoMaxLevel) --当前
        local data2 = GConfDataSort(data1)
        for k,v in pairs(self.texList01) do
            if data2[k] then
                local str =  conf.RedPointConf:getProName(data2[k][1]).."+" ..GProPrecnt(data2[k][1],data2[k][2])
                v.text = mgr.TextMgr:getTextColorStr( str,7 )
            else
                v.text = ""
                if k == 8 then
                    v.text = mgr.TextMgr:getTextColorStr( string.format(language.mianju08,self:numberToString(fuMoMaxLevel)),7)
                end
            end
        end
        
     
        local data5 = conf.MianJuConf:getMianJuFuMo(self.mianjuData.id,fuMoMaxLevel).elements -- 当前附魔对应元素
        for k1,v1 in pairs(self.texList03) do
        

            local  data  = conf.MianJuConf:getMianJuFuMoKongWei(self.mianjuData.id,fuMoMaxLevel,k1)
            local data1 = GConfDataSort(data)
            for k,v in pairs(data1) do
                if self.mianjuData.elements[k1] == data5[k1] then
                      v1.text = mgr.TextMgr:getTextColorStr(  language.mianju15[data5[k1]]..conf.RedPointConf:getProName(v[1]).."+"..GProPrecnt(v[1],v[2]),10)
                    self.coms[k1].obj:GetChild("icon").url = UIPackage.GetItemURL("shenqi" , "mianju_017") 
                    v1.stroke = 1

                else
                     v1.text = mgr.TextMgr:getTextColorStr(  language.mianju15[data5[k1]].. conf.RedPointConf:getProName(v[1]).."+"..GProPrecnt(v[1],v[2]),8 )
                    self.coms[k1].obj:GetChild("icon").url = UIPackage.GetItemURL("shenqi" , "mianju_016") 
                    v1.stroke = 0
                end
           
           

            end
        end
     
     
        for k,v in pairs(self.texList02) do
            v.text = ""
        end
       

    end


end

function MianJuShengXinAndFuMoView:refreshFumoCom()
    self.item.visible= true
    self.itemText.visible= true
    -- for k,v in pairs(self.coms) do
    --     v.obj:GetChild("n52").url = ""

    -- end
     local num =0                
    if self.oldfmLevel and (self.oldfmLevel < self.mianjuData.fmLevel) then --附魔升级

        for k,v in pairs(self.coms) do
             v.isFind = false
             v.obj:GetChild("n0"):GetChild("n52").url = ""
        end
        self.oldelements = nil
    else
            if self.oldelements and #self.oldelements ~= 0 then -- 播放抽奖特效
                self.closeBtn.touchable = false
                self.btn1.touchable = false
                for k,v in pairs(self.coms) do
                    if v.isFind == false then
                        v.obj:GetChild("n0"):GetChild("n52").url = ""
                
                       v.obj:GetChild("n0"):GetTransition("t"..self.mianjuData.elements[k]):Play() 
                     
                    end
                end
                 self:addTimer(time[3], 1, function()
                        for k,v in pairs(self.coms) do
                             v.obj:GetChild("n0"):GetChild("n51").y = -1725
                        end
                      self.closeBtn.touchable = true
                      self.btn1.touchable = true
                        local maps = conf.MianJuConf:getMianJuFuMo(self.mianjuData.id,self.mianjuData.fmLevel or 0).elements --面具小类对应元素
                
                        for k,v in pairs(self.mianjuData.elements) do
                            if v == maps[k] then
                                self.coms[k].isFind = true
                                num = num + 1 
                                self.coms[k].obj:GetChild("n0"):GetChild("n52").url =  UIItemRes.mainju[maps[k]]
                                -- self.coms[k].obj:GetChild("n52").url = ""
                            else
                                self.coms[k].obj:GetChild("n0"):GetChild("n52").url =  UIItemRes.mainju[v]
                           
                                self.coms[k].isFind = false
                                self.coms[k].index = v
                         
                            end
                   
                        end
          
                        if num == 3 then -- 所有孔位匹配一致时变换按钮状态
                            if self.mianjuData.fmLevel == 10 then --10级不能再提升
                            
                                self.btn1.data = {state = 4,maskId  = self.mianjuData.id,maskType = self.mianjuData.index,reqType = 1}

                            else
                                self.btn1.data = {state = 2,maskId  = self.mianjuData.id,maskType = self.mianjuData.index,reqType = 1}

                            end

                            self.btn1.icon = UIPackage.GetItemURL("shenqi" , "mianju_018")
                            self.item.visible= false
                            self.itemText.visible= false

                        else
                            self.btn1.data = {state = 2,maskId  = self.mianjuData.id,maskType = self.mianjuData.index,reqType = 0}

                            self.btn1.icon = UIPackage.GetItemURL("shenqi" , "mianju_021")
                            --刷新材料状态
                            local data1 =  conf.MianJuConf:getMianJuFuMo(self.mianjuData.id,self.mianjuData.fmLevel or 0)
                       
                            GSetItemData(self.item,{mid =  data1.items[1][1],amount = 1 ,bind = 0 ,isquan = true}, true)
                            self.num1 = cache.PackCache:getPackDataById(data1.items[1][1]).amount or 0
                            self.num2 = data1.items[1][2]
                           
                            self.itemText.text = self.num1 >= self.num2 and  "[color=#0b8109]"..self.num1.."/"..self.num2.."[/color]" or  "[color=#da1a27]"..self.num1.."[/color][color=#0b8109]".."/"..self.num2.."[/color]"
                            
                        end
                    end)
            else
                if #self.mianjuData.elements ~= 0 and self.isfirst  then  -- 第一次不播放动画效果
                    
    
                    local maps = conf.MianJuConf:getMianJuFuMo(self.mianjuData.id,self.mianjuData.fmLevel or 0).elements --面具小类对应元素
                    for k,v in pairs(self.mianjuData.elements) do
                        if v == maps[k] then
                            self.coms[k].isFind = true
                            num = num + 1 
                            self.coms[k].obj:GetChild("n0"):GetChild("n52").url =  UIItemRes.mainju[maps[k]]
                        
                        else
                            self.coms[k].obj:GetChild("n0"):GetChild("n52").url =  UIItemRes.mainju[v]
                            self.coms[k].isFind = false
                            self.coms[k].index = v
                        end 
                     end  
                    self.isfirst = false
                 

                elseif #self.mianjuData.elements ~= 0 then
                    -- print("空元素走这里")
                  
                    self.closeBtn.touchable = false
                    self.btn1.touchable = false
                    for k,v in pairs(self.coms) do
                        v.obj:GetChild("n0"):GetChild("n52").url = ""
                        local index = self.mianjuData.elements[k]
                        v.obj:GetChild("n0"):GetTransition("t"..index):Play() 
                    end
                    self:addTimer(time[3], 1, function()
                        for k,v in pairs(self.coms) do
                           v.obj:GetChild("n0"):GetChild("n51").y = -1725
                        end
                        self.closeBtn.touchable = true
                        self.btn1.touchable = true
                        local maps = conf.MianJuConf:getMianJuFuMo(self.mianjuData.id,self.mianjuData.fmLevel or 0).elements --面具小类对应元素
                        for k,v in pairs(self.mianjuData.elements) do
                            if v == maps[k] then
                                self.coms[k].isFind = true
                                num = num + 1 
                                self.coms[k].obj:GetChild("n0"):GetChild("n52").url =  UIItemRes.mainju[maps[k]]
                            
                            else
                                self.coms[k].obj:GetChild("n0"):GetChild("n52").url =  UIItemRes.mainju[v]
                                self.coms[k].isFind = false
                                self.coms[k].index = v
                            end 
                         end
                    end)
                end
             end     
        
    end
 
    self.num1 = 0 -- 当前拥有
    self.num2 = 0 --附魔所需
    -- print("num~~~~~~~~~~~",num)

    if num == 3 then -- 所有孔位匹配一致时变换按钮状态
        -- print("找到了该等级对应所有元素")
        self.btn1.data = {state = 2,maskId  = self.mianjuData.id,maskType = self.mianjuData.index,reqType = 1}
        self.btn1.icon = UIPackage.GetItemURL("shenqi" , "mianju_018")
        self.item.visible= false
        self.itemText.visible= false
        if self.mianjuData.fmLevel == fuMoMaxLevel then
            self.btn1.data = {state = 4}
        end
    else
        if self.mianjuData.fmLevel <= fuMoMaxLevel   then
            self.btn1.data = {state = 2,maskId  = self.mianjuData.id,maskType = self.mianjuData.index,reqType = 0}
            self.btn1.icon = UIPackage.GetItemURL("shenqi" , "mianju_021")
            --刷新材料状态
            local data1 =  conf.MianJuConf:getMianJuFuMo(self.mianjuData.id,self.mianjuData.fmLevel or 0)
            GSetItemData(self.item,{mid =  data1.items[1][1],amount = 1 ,bind = 0 ,isquan = true}, true)
            self.num1 = cache.PackCache:getPackDataById(data1.items[1][1]).amount or 0
            self.num2 = data1.items[1][2]
           
            self.itemText.text = self.num1 >= self.num2 and  "[color=#0b8109]"..self.num1.."/"..self.num2.."[/color]" or  "[color=#da1a27]"..self.num1.."[/color][color=#0b8109]".."/"..self.num2.."[/color]"
        else
            self.btn1.data = {state = 4}
            self.item.visible = false   
            self.itemText.visible = false
        end
    end


end

function MianJuShengXinAndFuMoView:callback()
    print("播放回调")
end

function MianJuShengXinAndFuMoView:onClick01(context)

   local  data = context.sender.data

   if data.state == 1 then -- 升星

        if self.num1 >= self.num2 and not self.upstart  then
            proxy.MianJuProxy:send(1630104,{maskId =data.maskId,maskType = data.maskType })
        else
            if self.upstart then
                GComAlter(language.forging19)
                return
            end
            GComAlter(language.mianju05)
        end
  elseif data.state == 2 then -- 附魔
      if self.num1 >= self.num2 then
            self.oldelements = {}

            self.oldfmLevel = self.mianjuData.fmLevel or 0 
            -- printt("旧的元素",self.mianjuData.elements)
            -- printt(self.mianjuData)
            for k,v in pairs(self.mianjuData.elements) do
                self.oldelements[k] = v -- 旧的元素赋值
            end
            local param = {}
            param.reqType =data.reqType
            param.maskId =data.maskId
            param.maskType =data.maskType
            -- print("附魔参数")
            -- printt(param)
            proxy.MianJuProxy:send(1630106,param)
        else
            GComAlter(language.mianju13)
        end
       
  elseif data.state == 4 then -- 提升
        GComAlter(language.mianju12)
   end

end

--添加模型
function MianJuShengXinAndFuMoView:addPanelModel()
    local roleIcon = roleData and roleData.roleIcon or cache.PlayerCache:getRoleIcon()
    local sex = GGetMsgByRoleIcon(roleIcon).sex
    local skins1 = cache.PlayerCache:getSkins(Skins.clothes)--衣服
    local skins2 = cache.PlayerCache:getSkins(Skins.wuqi)--武器
    local skins3 = cache.PlayerCache:getSkins(Skins.xianyu)--仙羽
    local skins5 = cache.PlayerCache:getSkins(Skins.shenbing) --神兵
    local skinsHalo = cache.PlayerCache:getSkins(Skins.halo) --光环
    local skinHeadWear = cache.PlayerCache:getSkins(Skins.headwear) --头饰
    local skinMianJu = cache.PlayerCache:getSkins(Skins.mianju) --头饰
     if sex == 1 then
        skins1 = 4041401
    elseif sex == 2 then
        skins1 = 4041402
    end
     local modelObj = self:addModel(skins1,self.heroModel)

    self.modelObj = modelObj
    modelObj:setSkins(nil,nil,nil)
    modelObj:setPosition(111 ,-390,159)
    modelObj:setRotationXYZ(352,183,359)
    modelObj:setScale(140)
    self.ChoosemianJumData = cache.MianJuCache:getMianJuChooseData()
    if self.ChoosemianJumData then
         self.modelObj:removeModelEct()
         local mianjuData = conf.MianJuConf:getMianJuEffectId(self.ChoosemianJumData.mid)
        self.effect = self:addEffect(mianjuData, self.effectPanel)
        self.effect.LocalPosition = Vector3(177,-161,185)
        self.effect.LocalRotation = Vector3(2,182,357)
        self.effect.Scale = Vector3.New(27,27,27)
    
    end

end

function MianJuShengXinAndFuMoView:calStartRedPoint()
    local data = cache.MianJuCache:getMianJuChooseData()
    local num1 = cache.PackCache:getPackDataById(data.mid).amount or 0
    local num2 = conf.MianJuConf:getMianjuStartData(data.id,(data.starNum >= startMaxNum and startMaxNum or data.starNum)) 
   
    if num2.item then
        if num1 >= num2.item[1][2] then
            return true
        else
            return false
        end
    else
        return false
    end
end


function MianJuShengXinAndFuMoView:calFumoRedPoint()
    local data = cache.MianJuCache:getMianJuChooseData()
    if data.fmLevel < fuMoMaxLevel then
        local conf = conf.MianJuConf:getMianJuFuMo(data.id,data.fmLevel)
        local  num1 = cache.PackCache:getPackDataById(conf.items[1][1]).amount or 0 --背包数
        local  num2 = conf.items[1][2] --消耗数
        if num1 >= num2 then
            return true
        else
            return false
        end
    else
        return false
    end
    
end

function  MianJuShengXinAndFuMoView:numberToString(szNum)
    ---阿拉伯数字转中文大写
    local szChMoney = ""
    local iLen = 0
    local iNum = 0
    local iAddZero = 0
    local hzUnit = {"", "十", "百", "千", "万", "十", "百", "千", "亿","十", "百", "千", "万", "十", "百", "千"}
    local hzNum = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"}
    if nil == tonumber(szNum) then
        return tostring(szNum)
    end
    iLen =string.len(szNum)
    if iLen > 10 or iLen == 0 or tonumber(szNum) < 0 then
        return tostring(szNum)
    end
    for i = 1, iLen  do
        iNum = string.sub(szNum,i,i)
        if iNum == 0 and i ~= iLen then
            iAddZero = iAddZero + 1
        else
            if iAddZero > 0 then
            szChMoney = szChMoney..hzNum[1]
        end
            szChMoney = szChMoney..hzNum[iNum + 1] --//转换为相应的数字
            iAddZero = 0
        end
        if (iAddZero < 4) and (0 == (iLen - i) % 4 or 0 ~= tonumber(iNum)) then
            szChMoney = szChMoney..hzUnit[iLen-i+1]
        end
    end
    local function removeZero(num)
        --去掉末尾多余的 零
        num = tostring(num)
        local szLen = string.len(num)
        local zero_num = 0
        for i = szLen, 1, -3 do
            szNum = string.sub(num,i-2,i)
            if szNum == hzNum[1] then
                zero_num = zero_num + 1
            else
                break
            end
        end
        num = string.sub(num, 1,szLen - zero_num * 3)
        szNum = string.sub(num, 1,6)
        --- 开头的 "一十" 转成 "十" , 贴近人的读法
        if szNum == hzNum[2]..hzUnit[2] then
            num = string.sub(num, 4, string.len(num))
        end
        return num
    end
    return removeZero(szChMoney)
end

return MianJuShengXinAndFuMoView