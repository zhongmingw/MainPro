--
-- Author: Your Name
-- Date: 2018-08-13 14:34:25
--
local AmendHeadPanel = class("AmendHeadPanel",import("game.base.Ref"))

function AmendHeadPanel:ctor(mParent)
    self.mParent = mParent
    self.view = self.mParent.view:GetChild("n5")
    self:initPanel()
end

function AmendHeadPanel:initPanel()
    local defaultIcon = self.view:GetChild("n2")--默认的头像
    defaultIcon.title = language.juese28[1]
    self.defaultIcon = defaultIcon
    defaultIcon.onClick:Add(self.onClickDefault,self)
    local albumIcon = self.view:GetChild("n3")--相册的头像
    albumIcon.title = language.juese28[2]
    -- self.albumIcon = albumIcon
    albumIcon.onClick:Add(self.onClickAlbumIcon,self)
    self.view:GetChild("n4").text = language.juese27

    local changeBtn = self.view:GetChild("n8")
    changeBtn.onClick:Add(self.onClickAlbumIcon,self)
end

function AmendHeadPanel:setData()
    local varData = GGetMsgByRoleIcon(cache.PlayerCache:getRoleIcon())
    self.defaultIcon.icon = ResPath.iconRes(varData.sex.."00")
end

--选择默认的头像
function AmendHeadPanel:onClickDefault()
    proxy.PlayerProxy:send(1020203,{headImgId = 0})
    self.mParent:closeView()
end
--选择相册
function AmendHeadPanel:onClickAlbumIcon()
    local roleIcon = cache.PlayerCache:getRoleIcon()
    local iconId = roleIcon % 100
    if iconId >= 50 and iconId < 99 then
        iconId = iconId + 1
    else
        iconId = 50
    end
    local name = cache.PlayerCache:getRoleId()..iconId..".jpg"
    mgr.SDKMgr:takePhoto(1,name,function(ret, msg)
        if tonumber(ret) == 0 then--加载成功
            local headImgId = iconId
            plog("告诉服务器加载成功",headImgId,iconId)
            proxy.PlayerProxy:send(1020203,{headImgId = tonumber(headImgId)})
            
            GComAlter(language.juese29)
        else
            GComAlter(language.juese30)
        end
    end)
end

return AmendHeadPanel