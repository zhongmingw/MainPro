local LoadingView = class("LoadingView", base.BaseView)

math.randomseed(tonumber(tostring(os.time()):reverse():sub(0,6)))
function LoadingView:ctor()
    self.super.ctor(self)
end

function LoadingView:initParams()
    self.uiLevel = UILevel.level5           --窗口层级
    self.isBlack = false                     --是否添加黑色背景
    self.uiClear = UICacheType.cacheDisabled
end

function LoadingView:initView()
    self.bgImg = self.view:GetChild("n0")
    self.loadBar = self.view:GetChild("n1")
    self.movieClip1 = self.loadBar:GetChild("n4")
    self.title = self.view:GetChild("n2")
    self.title.text = ""
    if g_ios_test then
        self.loadBar.visible = false
    end
end

function LoadingView:initData()
    if self.uiLoadSuccess then
        self.loadBar.max = 100
        self.loadBar.value = 0
    end
    if g_ios_test then
        local loadUrl = UIItemRes.shios01.."loading3"
        if g_var.gameFrameworkVersion >= 18 then
            local imagePath = "res/images/loading.png"
            local check = PathTool.CheckResExist(imagePath)
            if check then
                loadUrl = "@"..imagePath
            end
        end
        self.bgImg.url = loadUrl
        return
    end
    local lvl = cache.PlayerCache:getRoleLevel()
    local loadConf = conf.SysConf:getLoadingTitle()
    --加载提示bxp
    for i=1,#loadConf do
        if lvl >= loadConf[i].level[1] and lvl <= loadConf[i].level[2] then
            local index = math.random(1,#loadConf[i].title)
            local id = loadConf[i].title[index]
            local str = conf.SysConf:getLoadingTxtByid(id).txt
            self.title.text = mgr.TextMgr:getTextColorStr(str,2)
            self.view:GetChild("n3").visible = true
            break
        else
            self.view:GetChild("n3").visible = false
        end
    end
    local confData = conf.SysConf:getLoadingConfById(1)
    if lvl > conf.SysConf:getValue("first_loading_img_lv") then
        local loadConf = conf.SysConf:getLoadingConf()
        local num = table.nums(loadConf)
        if num > 1 then
            math.randomseed(os.time())
            local random = math.random(2,num)
            -- plog("random",random,num)
            confData = conf.SysConf:getLoadingConfById(random)
        end
    end
    local ab = UIPackage.GetItemURL("loading",confData.loadimg)
    if ab == "" or ab == nil then
        ab = UIItemRes.loading01..confData.loadimg
        local check = PathTool.CheckResDown(ab..".unity3d")
        if check or g_var.platform == "win" then
            self.bgImg.url = ab
        else
            local confData = conf.SysConf:getLoadingConfById(1)
            self.bgImg.url = UIPackage.GetItemURL("loading",confData.loadimg)
        end
    else
        self.bgImg.url = ab
    end
end

function LoadingView:setProgress(rate)
    if self.uiLoadSuccess then
        self.loadBar.max = 100
        self.loadBar.value = 100*rate
        -- self.movieClip1.x = self.loadBar.width * rate
    end
end

return LoadingView