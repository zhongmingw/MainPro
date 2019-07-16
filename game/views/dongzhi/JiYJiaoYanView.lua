--
-- Author: 
-- Date: 2018-12-13 07:14:11
--
local startPos = {{945,154},{948,243},{948,359},{944,483}}
local sendTime = 5
local JiYJiaoYanView = class("JiYJiaoYanView", base.BaseView)


function JiYJiaoYanView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function JiYJiaoYanView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n6")
     closeBtn.onClick:Add(self.onClose,self)
   
    local  sendBtn = self.view:GetChild("n14")
    sendBtn.onClick:Add(self.onSend,self)
    local  guideBtn = self.view:GetChild("n41")
    guideBtn.onClick:Add(self.onGuide,self)
     local  rankBtn = self.view:GetChild("n9")
    rankBtn.onClick:Add(self.onRank,self)
    self.sureBtn = self.view:GetChild("n34")
    self.sureBtn.onClick:Add(self.onSure,self)
    local  danmuBtn = self.view:GetChild("n47")
    danmuBtn.data  = {obj = danmuBtn}
    danmuBtn.onClick:Add(self.onDanmu,self)
    local  biaoqingBtn = self.view:GetChild("n42")
    biaoqingBtn.onClick:Add(self.biaoqingBtn,self)
    self.Timetext = self.view:GetChild("n39")--倒计时
    self.curLunShutext = self.view:GetChild("n4") --轮数
    self.Inputtext = self.view:GetChild("n11") --输入框
    -- self.Inputtext.onChanged:Add(self.onChangeInput,self)
    self.tip = self.view:GetChild("n48") --提示框
    self.rankList = {}
    for i = 36,38 do
        local btn = self.view:GetChild("n"..i)
        table.insert(self.rankList, btn)
    end
    self.opendanmu = true
    self.controller = self.view:GetController("c1")
    self.controller.selectedIndex = 13
    -- self.liaoTianPanel = self.view:GetChild("n52")
    -- self.liaoTianList = self.liaoTianPanel:GetChild("n51")
    -- self.liaoTianList.itemRenderer = function(index,obj)
    --     self:cellPhizData(index, obj)
    -- end
    -- self.liaoTianList.numItems = ChatType.phizNum
    -- self.liaoTianList.onClickItem:Add(self.onPhizClickCall,self)
    -- self.liaoTianPanel.visible =false
    self.dataList = {}
    self.textList ={}
    for i =54,57 do
        local text = self.view:GetChild("n"..i)
        table.insert(self.textList ,{obj = text , oldX = text.x, ismove = false} )
    end
     self.timer = nil
     self.confData = conf.DongZhiConf:getDongZhiJiaoYanNum()
     self.showList = {} -- 记忆区
     for i = 17,21 do
        local btn = self.view:GetChild("n"..i)
        btn.data  = {state = 1,obj = btn}
        btn.onClick:Add(self.choose,self)
        table.insert(self.showList, btn)
     end
     self.huifuList = {} -- huifu区
     for i = 22,26 do
        local btn = self.view:GetChild("n"..i)
        btn.data  = {state = 2,obj = btn,index = i-21,choosetype = 1 }
        btn.onClick:Add(self.choose,self)
        table.insert(self.huifuList, btn)
     end
      self.xuanzeList = {} -- 选择区
     for i = 27,29 do
        local btn = self.view:GetChild("n"..i)
        btn.data  = {state = 3,obj = btn,jiaozitype = i-26}
        btn.onClick:Add(self.choose,self)
        table.insert(self.xuanzeList, btn)
     end
    
     self.timeDelat = 0
     self.isCanSend = true
     self.daanList = {}
end

function JiYJiaoYanView:choose(context)
   local data = context.sender.data
    if self.time >= 45 and self.time <= 60 then -- 记忆时间
        GComAlter(language.dz15)
        return
    end 
    if self.time >= 15 and self.time < 45 then -- 答题时间
       if data.state == 2 then --点击的是恢复区
            self.currentChooseBtn = data.obj
            self.huifuindex = data.index

       elseif data.state == 3 then --点击的是选择区
        if  not self.currentChooseBtn  then return end
            self.currentChooseBtn.data.choosetype =  data.jiaozitype
            print( self.currentChooseBtn.name)
            self.currentChooseBtn:GetChild("icon").url = UIItemRes.dongzhi[data.jiaozitype]
            self.daanList[self.huifuindex] = data.jiaozitype    
       end
    end 
    if self.time <15 then
        GComAlter(language.dz22)
    end

end

function JiYJiaoYanView:onClose(context)
   -- self.liaoTianPanel.visible =false
   self:releaseTimer()
   self:closeView()
end

--重置3个列表
function JiYJiaoYanView:ReverList()
    if self.data.curRound == 0 then
        return
    end
    local conf = conf.DongZhiConf:getDongZhiJiaoYan(self.data.curRound)
    local  memory = conf.memory
    local  restore = conf.restore
    local  select1 = conf.select


    for k,v in pairs(self.huifuList) do
       
        v:GetController("c1").selectedIndex = 0
        if k <= restore then
            v.visible = true
            v.touchable = true
        else
              v.visible = false
            v.touchable = false
        end
    end
    for k,v in pairs(self.showList) do
         v:GetController("c1").selectedIndex = 0
        if k <= memory then
            v.visible = true
            v.touchable = true
        else
              v.visible = false
            v.touchable = false
        end
    end
     for k,v in pairs(self.xuanzeList) do
         v:GetController("c1").selectedIndex = 0
        if k <= select1 then
            v.visible = true
            v.touchable = true
        else
              v.visible = false
            v.touchable = false
        end
    end
    
end

function JiYJiaoYanView:setData(data)
    printt("记忆饺宴",data)
    self.data = data
    cache.ActivityCache:setJyjyData(data)--缓存数据
    if self.data.reqType == 2 and self.data.quickRank ~= 0 then
        local text =  string.format( language.dz25,cache.PlayerCache:getRoleName(),data.quickRank)
           local params = {
            type = ChatType.jiyiDanMu,
            content = self.Inputtext.text,
            isVoice = 0,
            voiceStr = "",
            tarName = ""
        }
        proxy.ChatProxy:send(1060101,params)
    end
    self:ReverList()
    self.curLunShutext.text = string.format(language.dz14,(self.data.curRound or 0),#self.confData) 
    self:refreshRankInfo()
    self:releaseTimer()
    if data.curRound ~= 0  then
        self.time = data.curSec
    else
        local severTime = mgr.NetMgr:getServerTime()
        self.time = GTotimeString13( data.actStartTime -severTime )
        self.time = tonumber(self.time)+60
    end
    for k,v in pairs(self.xuanzeList) do

        v:GetChild("icon").url= UIItemRes.dongzhi[k]
    end

    if not self.actTimer then
        print("启动定时器")
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end



function JiYJiaoYanView:onSend(context)
    -- if self.time <=60 then
    --     GComAlter(language.dz23)
    --     return
    -- end
    if self.Inputtext.text == "" then
        GComAlter(language.dz13 )
        return
    end
    if  not self.isCanSend  then
        GComAlter(language.dz21)
        return
    end
         local params = {
            type = ChatType.jiyiDanMu,
            content = self.Inputtext.text,
            isVoice = 0,
            voiceStr = "",
            tarName = ""
        }
        proxy.ChatProxy:send(1060101,params)
        self.isCanSend = false
    
    
end

function JiYJiaoYanView:onGuide(context)
     mgr.ViewMgr:openView2(ViewName.JiYijiaoyanTip, {})
     
end

function JiYJiaoYanView:onRank(context)
      mgr.ViewMgr:openView2(ViewName.JiYiJiaoYanRank, {})
end

function JiYJiaoYanView:onSure(context)
    local data = context.sender.data
    if self.time<=60 and self.time >45 then
        GComAlter(language.dz15)
        return 
    end
     if self.time<=45 and self.time >30 then
        --是否回答过
        if self.data.canSubmit == 1 then
            GComAlter(language.dz24)
            return
        end
       --可以提交答案
       printt(self.daanList)
       print("提交答案")
   

       proxy.DongZhiProxy:send(1030676,{reqType =2 ,answer = self.daanList})
    end
    if self.time <=30 then
        GComAlter(dz22)
    end
      
end

function JiYJiaoYanView:onDanmu(context)
    local  data = context.sender.data
    local c1 = data.obj:GetController("c1")
    if c1.selectedIndex == 0 then
        c1.selectedIndex = 1
        self.opendanmu = true
    elseif c1.selectedIndex == 1 then
        c1.selectedIndex = 0
        self.opendanmu = false
    end
      
end

function JiYJiaoYanView:biaoqingBtn(context)
    -- if self.liaoTianPanel.visible == false then
    --     self.liaoTianPanel.visible = true
    -- elseif self.liaoTianPanel.visible == true then
    --      self.liaoTianPanel.visible = false
    -- end
    mgr.ViewMgr:openView2(ViewName.BiaoQingView, {})      
end


--更新排行信息
function JiYJiaoYanView:refreshRankInfo()
    self.data = cache.ActivityCache:getJyjyData()
      for k,v in pairs(self.rankList) do
          if self.data.scoreRankings[k] then
              v:GetChild("title").text = self.data.scoreRankings[k].WSScoreRankingInfo.roleName or "无"
              v:GetChild("n4").text =   self.data.scoreRankings[k] and string.format(language.dz12, self.data.scoreRankings[k].WSScoreRankingInfo.ranking,self.data.scoreRankings[k].WSScoreRankingInfo.score)or "无"
              v:GetChild("n3"):GetChild("n3").url = ""
          else
              v:GetChild("title").text =  "无"
              v:GetChild("n4").text =    "无"
              v:GetChild("n3"):GetChild("n3").url =  GGetMsgByRoleIcon(cache.PlayerCache:getRoleIcon()).headUrl
          end
      end
end

function JiYJiaoYanView:onTimer()
    if not self.isCanSend then -- 聊天发送间隔
        self.timeDelat = self.timeDelat + 1
        if self.timeDelat >= sendTime then
            self.isCanSend = true
            self.timeDelat = 0
        end
    end
    self.sureBtn.grayed = true
    self.Timetext.text = 60
     self.time = self.time - 1
    if self.time <= 60   then
        self.Timetext.text = self.time
        --  if self.data.curRound == 0 then
     
        if self.data.curRound == 0  then
            if self.time == 0 then
                self:releaseTimer()
            end

            return
        end
      
    end
    if self.time >= 45 and self.time <= 60 then -- 记忆时间
        if self.time == 60 then
            GComAlter(language.dz17)
        end
        if self.time == 45 then
            GComAlter(language.dz18)
        end
        --展示记忆选项
        for k,v in pairs(self.showList) do
            v:GetChild("icon").url =UIItemRes.dongzhi [self.data.curAnswer[k] ]
            v:GetController("c1").selectedIndex = 0
        end

    end 
    if self.time >= 15 and self.time < 45 then -- 答题时间
        --展示记忆选项
        for k,v in pairs(self.showList) do
        
            v:GetController("c1").selectedIndex = 1
        end
        self.sureBtn.grayed = false
        if self.time == 15 then --发送请求排行版消息
            proxy.DongZhiProxy:send(1030675)
        end

    end   
    if self.time >1 and self.time < 15 then -- 答案时间
        --展示记忆选项
        for k,v in pairs(self.showList) do
         
            v:GetController("c1").selectedIndex = 0
        end
        for k,v in pairs(self.huifuList) do
            v:GetController("c1").selectedIndex = 0

            if  v.data.choosetype ~= self.data.curAnswer[k] then 
                v:GetController("c1").selectedIndex = 3 --错误
            else
                v:GetController("c1").selectedIndex = 2 --正确
            end
            if not self.data.curAnswer[k] then
                v:GetController("c1").selectedIndex = 0
            end
        end

    end 
    if self.time <= 1 then
         for k,v in pairs(self.huifuList) do
            v:GetController("c1").selectedIndex = 0
        end
        self:releaseTimer()
    end
    
   
end

function JiYJiaoYanView:releaseTimer()
    if self.actTimer then
        print("释放定时器")
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end


function JiYJiaoYanView:cellPhizData(index,cell)
    local phizId = index + 1
    if phizId < 10 then
        cell.data = "0"..phizId
    else
        cell.data = phizId
    end
    local imgObj = cell:GetChild("n0")
    imgObj.url = ResPath.phizRes(cell.data)
end

-- function JiYJiaoYanView:onPhizClickCall(context)
--     local cell = context.data
--     local index = cell.data
--     local len = string.utf8len(self.Inputtext.text)
--     if len >= language.chatNum then--输入限制
--         GComAlter(string.format(language.chatSend6, language.chatNum))
--         return
--     end
--     if index then
--         self.Inputtext.text = self.Inputtext.text.."#"..index
--     else
--         self.Inputtext.text = mgr.TextMgr:getPhiz(index)
--     end
-- end

function JiYJiaoYanView:setDanMu(data)
    print("setdanmu")
    if not self.opendanmu then return  end
    self.chatdata = data
    table.insert(self.dataList, data)
    if not self.timer then
        self:onMove()
        self.timer = true
    end
end

function JiYJiaoYanView:onMove()
    local data = table.remove(self.dataList,1)
    if not data then
        self.timer = false
        self:closeView()
        return
    end
    for k,v in pairs(self.textList) do

        if not v.ismove then
            local width = v.obj.width / 2
            v.obj.x = v.oldX + width
            v.obj.text = self:getSendText(self.chatdata)
            local time = HorseTime

            local iY = v.obj.y
            v.ismove = true
    
            UTransition.TweenMove2(v.obj, Vector2.New(-5, iY), time, true, function()
                    v.ismove = false
                    v.obj.text = ""
                    v.obj:SetXY(v.oldX,iY)
                    print("延迟重置")

                    self.timer  = nil
                -- self:addTimer(0.2, 1, function()
      
                --     -- UTransition.TweenMove2(self.label, Vector2.New(-width, iY), time, true, function()
                --     --     self:onMove()
                --     -- end)
                -- end)
            end)
            break
        end
    end
    
end

function JiYJiaoYanView:getSendText(data)
    local imgText = mgr.TextMgr:getImg(UIItemRes.chatType[data.type],40,20)
    -- local hert = "*"..data.sendRoleId.."*"..data.sendName.."*"..data.sendRoleIcon.."*"..data.sendRoleLev.."*"
    -- local str = ""
    local content = data.content
    local content1 = mgr.ChatMgr:getSendText(content,data.sendRoleId)
    -- local sex = GGetMsgByRoleIcon(data.sendRoleIcon).sex or 0
    -- local sendName = mgr.TextMgr:getTextColorStr(data.sendName.."("..language.gonggong28[sex].."):", 12)
    return content1
end

return JiYJiaoYanView