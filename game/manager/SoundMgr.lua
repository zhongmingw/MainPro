--
-- Author: yr
-- Date: 2017-03-06 16:44:22
-- 背景音乐格式mp3  音效格式wav
--

local SoundMgr = class("SoundMgr")

function SoundMgr:ctor()
    self.musicEnable = true
    self.soundEnable = true
    self.musicVolume = 1
    self.soundVolume = 1
    self.curMusic = ""
end

function SoundMgr:playBgMusic(name)
    if self:getMusicEnable() then
        local volume = self:getMusicVolume()
        UnitySound:PlayBGMAudioClip(name,volume,true)
    else
        UnitySound:BGMPause()
    end
    self.curMusic = name
end
--音乐开关
function SoundMgr:setMusicEnable(b)
    local enable = 0
    if type(b) == "number" then
        enable = b
    else
        if b then
            enable = 0--开
            UnitySound:PlayBGMAudioClip(self.curMusic,self:getMusicVolume(),true)
        else
            enable = 1--关
            UnitySound:BGMPause()
        end
    end
    
    UPlayerPrefs.SetInt("Music",enable)
end


function SoundMgr:getMusicEnable()
    local enable = UPlayerPrefs.GetInt("Music")
    if enable == 0 then
        return true
    end
end
--音乐音量
function SoundMgr:setMusicVolume(value)
    if value >= 0 then
        UnitySound:BGMSetVolume(value)
    end
    UPlayerPrefs.SetFloat("MusicVolume",value)
end

function SoundMgr:getMusicVolume()
    if self:getSiteMusic() == 0 then
        return gameVolume
    end
    return UPlayerPrefs.GetFloat("MusicVolume")
end

--记录是否设置过音乐音量
function SoundMgr:setSiteMusic()
    UPlayerPrefs.SetInt("MusicVolume1",1)
end

function SoundMgr:getSiteMusic()
    return UPlayerPrefs.GetInt("MusicVolume1")
end

function SoundMgr:playSound(name)
    local view = mgr.ViewMgr:get(ViewName.ChatView)
    if view then
        if view.soundMute then
            return
        end
    end
    if self:getSoundEnable() then
        local volume = self:getSoundVolume()
        UnitySound:PlaySound(name, volume)
    end
end

function SoundMgr:stopSound(name)
    UnitySound:StopSound(name)
end
--音效开关
function SoundMgr:setSoundEnable(b)
    local enable = 0
    if type(b) == "number" then
        enable = b
    else
        if b then
            enable = 0--开
            Stage.inst.soundVolume = self:getSoundVolume()
        else
            enable = 1--关
            Stage.inst.soundVolume = 0
        end
    end
    UnitySound:SoundSwitch(b)--c#层音效开关
    UPlayerPrefs.SetInt("Sound",enable)
end

function SoundMgr:getSoundEnable()
    local enable = UPlayerPrefs.GetInt("Sound")
    if enable == 0 then
        return true
    end
end
--音效音量
function SoundMgr:setSoundVolume(value)
    Stage.inst.soundVolume = value
    UPlayerPrefs.SetFloat("SoundVolume",value)
end

function SoundMgr:getSoundVolume()
    if self:getSiteSound() == 0 then
        return gameVolume
    end
    return UPlayerPrefs.GetFloat("SoundVolume")
end
--记录是否设置过音效音量
function SoundMgr:setSiteSound()
    UPlayerPrefs.SetInt("SoundVolum1",1)
end

function SoundMgr:getSiteSound()
    return UPlayerPrefs.GetInt("SoundVolum1")
end



return SoundMgr