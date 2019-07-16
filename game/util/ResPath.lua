local ResPath = {}

--[[**资源的路径规则**
1、[角色、武器、翅膀、坐骑、剑神、剑神翅膀] [灵宠、灵羽] [怪物、npc、地图]
]]

--ui零时资源
ResPath.DefaultPlayer   = 3010999     --角色界面零时资源
ResPath.DefaultWeapon   = 3020999     --武器界面零时资源
ResPath.DefaultWing     = 3030999     --翅膀界面零时资源
ResPath.DefaultMount    = 3040999     --坐骑界面零时资源
ResPath.DefaultPet      = 3050999     --宠物界面零时资源
ResPath.DefaultNpc      = 3060101     --NPC界面模型零时资源
ResPath.DefaultMonster  = 3070301     --怪物界面模型零时资源
ResPath.DefaultJianShen = 3010799     --剑神
ResPath.DefaultJSWing   = 3030799     --剑神翅膀

--场景零时资源
ResPath.Weapon = 3020102
ResPath.JSWeapon = 3020701
ResPath.Mount = 3040101
ResPath.Wing = 3030101
ResPath.PetWing = 3030301
ResPath.Pet = 3050101
ResPath.PlayerBoy = 3010102
ResPath.PlayerGril = 3010202

--默认加载阶数
ResPath.PlayerLevel     = "02"
ResPath.MountLevel      = "01"
ResPath.WingLevel       = "05"
ResPath.WeaponLevel     = "03"
ResPath.JianShenLevel   = "01"
ResPath.PetLevel        = "01"
ResPath.PetWingLevel    = "01"


--ui模型调用的接口 3080199
function ResPath.ThingResById(id)
    local index = tonumber(string.sub(tostring(id), 1, 1))
    local t = tonumber(string.sub(tostring(id), 3, 3))
    local isyd = string.find(id,"yd")
    if index == 3 then --路径在res/things
        if t == 1 then
            local xxLei = tonumber(string.sub(tostring(id), 5, 5))
            if xxLei == 7 then  --剑神
                return ResPath.playerRes(id, ResPath.DefaultJianShen)
            else
                return ResPath.playerRes(id, ResPath.DefaultPlayer)
            end
        elseif t == 2 then
            return ResPath.weaponRes(id, ResPath.DefaultWeapon)
        elseif t == 3 then
            local str, c = ResPath.wingResUI(id)
            if isyd then
                return str
            end
            return str.."_ui", c
        elseif t == 4 then
            local str, c = ResPath.mountRes(id, ResPath.DefaultMount)
            if isyd then
                return str
            end
            return str.."_ui", c
        elseif t == 5 then
            return ResPath.petRes(id, ResPath.DefaultPet)
        elseif t == 6 then
            return ResPath.npcRes(id) 
        elseif t == 7 then
            return ResPath.monsterRes(id)
        elseif t == 8 then
            return ResPath.othersRes(id)
        end
    elseif index == 4 then----路径在res/effects
        if isyd then
            return ResPath.effectResUI(id)
        else
            if t == 1 then
                return ResPath.playerRes(id)
            elseif t == 3 then
                local str = ResPath.wingResUI(id)
                if isyd then
                    return str
                end
                return str.."_ui"
            else
                return ResPath.effectResUI(id) 
            end
        end
    end
end

function ResPath.othersRes(id)
    return PrefabRes.other..id
end

function ResPath.monsterRes(id)
    return ResPath.checkResExit(PrefabRes.monster, id, nil, ResPath.DefaultMonster)
end

function ResPath.playerRes(id, rep)
    local xxLei = tonumber(string.sub(tostring(id), 5, 5))
    if xxLei == 7 then  --剑神
        return ResPath.checkResExit(PrefabRes.player, id, ResPath.JianShenLevel, rep)
    elseif xxLei == 1 or xxLei == 3 then  --男角色 / 时装
        if not rep then rep = ResPath.PlayerBoy end
        return ResPath.checkResExit(PrefabRes.player, id, nil, rep)
    else
        if not rep then rep = ResPath.PlayerGril end
        return ResPath.checkResExit(PrefabRes.player, id, nil, rep)
    end
end

function ResPath.petRes(id, rep)
    if not rep then rep = ResPath.Pet end
    return ResPath.checkResExit(PrefabRes.pet, id, ResPath.PetLevel, rep)
end

function ResPath.effectRes(id)
    return PrefabRes.effect..id
end

function ResPath.effectResUI(id)
    return PrefabRes.effect..id
end

function ResPath.npcRes(id)
    return ResPath.checkResExit(PrefabRes.npc, id, nil, ResPath.DefaultNpc)
end

function ResPath.weaponRes(id, rep)
    local xxLei = tonumber(string.sub(tostring(id), 5, 5))
    if xxLei == 7 then
        if not rep then rep = ResPath.JSWeapon end
        return ResPath.checkResExit(PrefabRes.weapon, id, ResPath.WeaponLevel, rep)
    else
        if not rep then rep = ResPath.Weapon end
        return ResPath.checkResExit(PrefabRes.weapon, id, ResPath.WeaponLevel, rep)
    end 
end

--UIModel ui武器
function ResPath.weaponResUI(id)
    return ResPath.checkResExit(PrefabRes.weapon, id, ResPath.WeaponLevel, ResPath.DefaultWeapon)
end

--场景翅膀
function ResPath.wingRes(id, rep)
    local xxLei = tonumber(string.sub(tostring(id), 5, 5))
    if xxLei == 7 then  --剑神
        return ResPath.checkResExit(PrefabRes.wing, id, ResPath.JianShenLevel, rep)
    elseif xxLei == 3 or xxLei == 9 then  --灵羽 / 时装
        if not rep then rep = ResPath.PetWing end
        return ResPath.checkResExit(PrefabRes.wing, id, ResPath.PetWingLevel, rep)
    else  --角色
        if not rep then rep = ResPath.Wing end
        return ResPath.checkResExit(PrefabRes.wing, id, ResPath.WingLevel, rep)
    end
end

--UIModel 调用获取ui翅膀
function ResPath.wingResUI(id, rep)
    local xxLei = tonumber(string.sub(tostring(id), 5, 5))
    if xxLei == 7 then  --剑神翅膀
        return ResPath.checkResExit(PrefabRes.wing, id, nil, ResPath.DefaultJSWing)
    else
        return ResPath.checkResExit(PrefabRes.wing, id, nil, ResPath.DefaultWing)
    end
end

function ResPath.mountRes(id, rep)
    if not rep then rep = ResPath.Mount end
    return ResPath.checkResExit(PrefabRes.mount, id, ResPath.MountLevel, rep)
end

--检查资源是否是分包下载资源
--resType=资源类型
--id=资源id
--default=默认加载资源的阶数
--replace=直接替换某个资源
function ResPath.checkResExit(resType, id, default, replace)
    local level = default or "01"  --默认阶数
    local ab = resType..id
    local check = mgr.DownloadMgr:checkDownload(id, ab..".unity3d")
    if check then
        if replace then
            ab = resType..replace
        else
            local rId = math.floor(tonumber(id)/100)..level
            ab = resType..rId
            --print("@替换资源ID:"..ab.."  id:"..id)
        end
    end
    return ab, check
end


function ResPath.propRes(id)
    return PrefabRes.prop..id
end

function ResPath.bgRes(id)
    return PrefabRes.bg..id
end

function ResPath.iconRes(id)
    local iconUrl = UIPackage.GetItemURL("_icons" , tostring(id))
    if not iconUrl then
        iconUrl = UIPackage.GetItemURL("_icons2" , tostring(id))
    end
    return iconUrl
end

function ResPath.titleRes(id)
    local iconUrl = UIPackage.GetItemURL("head" , tostring(id))
    if not iconUrl then
        iconUrl = UIPackage.GetItemURL("head2" , tostring(id))
    end
    return iconUrl
end

function ResPath.taskiconRes(id)
    return PrefabRes.taskicon..id
end

function ResPath.phizRes(id)
    return  ResPath.iconRes("liaotianbiaoqing_0"..id) --UIPackage.GetItemURL("_icons" , "liaotianbiaoqing_"..id)
end
--骰子
function ResPath.diceRes(id)
    local url = UIPackage.GetItemURL("_others" , string.format("xianmengshenghuo_0%02d",(id+6)))
    return url
end
function ResPath.buffRes(id)
    return "ui://main/"..id
end
function ResPath:petChengHao(jie)
    -- body
    --local id = tonumber(jie)+33
    local condata = conf.RoleConf:getpetChenghaoByJie(jie)
    if condata and condata.icon then
        return "ui://head/".. condata.icon
    end
    print("找不到对应配置 pet_chenghao",jie)
    return nil
end
function ResPath.imgfontsRes(id)
    -- body
    --plog("id",id)
    return "ui://_imgfonts/"..tostring(id)
end

function ResPath.ShopZe(id)
    -- body
    return "ui://_imgfonts/"..string.format("meiritehui_%03d",id+3)
end

function ResPath.iconOther(id)
    -- body
    return "ui://_others/"..id
end

--icon 加载
function ResPath.iconload(id,name)
    local iconUrl = UIPackage.GetItemURL("_icons" , tostring(id))
    if not iconUrl then
        iconUrl = UIPackage.GetItemURL(name, tostring(id))
    end
    return iconUrl
end

return ResPath

