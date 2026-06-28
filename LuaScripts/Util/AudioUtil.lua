

local M = {}
M.music_volume = 0.5
M.effect_volume = 0.5

local __bgm_key = "Voice_Volume_Music"
local __cv_key = "Voice_Volume_Voice"
local __ui_key = "Voice_Volume_Sound"
local __skills_key = "Voice_Volume_SoundSkills"

local __AudioHelper = CS.wt.framework.AudioHelper.Instance

function M:init()
	self.music_volume = U3DUtil:PlayerPrefs_GetFloat("music_volume", 0.5)
	self.effect_volume = U3DUtil:PlayerPrefs_GetFloat("effect_volume", 0.5)
	self.cv_volume = U3DUtil:PlayerPrefs_GetFloat("cv_volume", 0.5)
	self:SetBusVol(__bgm_key,self.music_volume)
	self:SetBusVol(__cv_key,self.cv_volume)
    self:SetBusVol(__ui_key,self.effect_volume)
    self:SetBusVol(__skills_key,self.effect_volume)
    self.m_skill_pause = false
    self.m_music_pause = false
    self:SetCurrentLanguage()
end

function M:SendEvtSkill(event_name,bank_name)
    return __AudioHelper:PostEvtSkill(event_name,bank_name)
end 

function M:SendEvtUI(event_name, overlap_play)
    if event_name == nil then
        event_name = "event_name_is_null"
    end
    overlap_play = overlap_play or false
    return __AudioHelper:PostEvtUI(event_name, overlap_play)
end 

function M:SendEvtBGM(event_name,focus)
    if focus == nil then
        focus = false
    end
    __AudioHelper:PostEvtBGM(event_name,focus)
end 

function M:StopAllSkills()
    __AudioHelper:StopAllSkills()
end

function M:SendEvtCV(event_name,role_name)
    return __AudioHelper:PostEvtCV(event_name,role_name)
end 

function M:SetBusVol(bus,vol)
    __AudioHelper:SetBusVol(bus,vol)
end

function M:SetBgmVol(vol)
    self:SetBusVol(__bgm_key,vol)
end

function M:SetCVVol(vol)
    self:SetBusVol(__cv_key,vol)
end

function M:SetUIVol(vol)
    self:SetBusVol(__ui_key,vol)
end

function M:SetSkillsVol(vol)
    if self.m_skill_pause == false then
        self:SetBusVol(__skills_key,vol)
    end
end

function M:PauseSkillsBusVol()
    if self.m_skill_pause == false then
        self:SetBusVol(__skills_key,0.0)
        --__AudioHelper:PostEvt("Mute_SfxSubBus_Char_Skills")
        __AudioHelper:PostEvt("Mute_Skills_ShortVo")
        self.m_skill_pause = true
    end
end

function M:ResumeSkillsBusVol()
    if self.m_skill_pause == true then
        self:SetBusVol(__skills_key,self.effect_volume)
        --__AudioHelper:PostEvt("UnMute_SfxSubBus_Char_Skills")
        __AudioHelper:PostEvt("UnMute_Skills_ShortVo")
        self.m_skill_pause = false
    end
end

function M:PauseMusicBusVol()
    if self.m_music_pause == false then
        self:SetBusVol(__bgm_key,0.0)
        self.m_music_pause = true
    end
end

function M:ResumeMusicBusVol()
    if self.m_music_pause == true then
        self:SetBusVol(__bgm_key,self.music_volume)
        self.m_music_pause = false
    end
end

function M:PlayFmodSound(soundName,bankName)
    __AudioHelper:PlayFmodSound(soundName,bankName)
end

function M:StopPlayingID(sound_id, duration)
    if sound_id and sound_id ~= 0 then
        __AudioHelper:StopPlayingID(sound_id, duration or 0)
    end
end

function M:SetCurrentLanguage()
    if __AudioHelper.SetCurrentLanguage then
        local system_language = U3DUtil:Get_SystemLanguage():ToString()
        if system_language == "ChineseSimplified" or system_language == "Chinese" then
            __AudioHelper:SetCurrentLanguage("Chinese")
        else
            -- TODO 暂时没有其他语言。默认使用中文
            __AudioHelper:SetCurrentLanguage("Chinese")
        end
    end
end

function M:PauseAllAudio()
    __AudioHelper:PostEvt("Pause_All")
end

function M:ResumeAllAudio()
    __AudioHelper:PostEvt("Resume_All")
end

return M