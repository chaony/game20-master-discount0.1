--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-05-06 15:21:07
]]
StateSoundManager = {}

function StateSoundManager:playSound( cfg, player )
    local skill_name,r = cfg:getAnimName()
    if cfg.data.use_se ~= nil and cfg.data.use_se[1] == 1 then
        audio:SendEvtSkill(skill_name, player.prefabRoot)
    end
end

function StateSoundManager:playSkillSound(skill_name, player)
    return audio:SendEvtSkill(skill_name, player.prefabRoot)
end

function StateSoundManager:playSkillSoundFromBank( soundName, bankName )
    audio:SendEvtUI(soundName)
end

function StateSoundManager:playSkillSoundFromBankNew(soundName, bankName)
    return audio:SendEvtSkill(soundName, bankName)
end

function StateSoundManager:LoadBank( bankName )
    ResourceUtil:LoadBank(bankName)
    
end

function StateSoundManager:UnLoadBank( bankName )
    ResourceUtil:UnLoadBank(bankName)
end

function StateSoundManager:playFmodSound(sound_name, bank_name)
    return audio:PlayFmodSound(sound_name, bank_name)
end


function StateSoundManager:playFixSound( soundName, bankName )
    audio:StopAllSkills()
    audio:SendEvtSkill(soundName, bankName)
end

function StateSoundManager:playBGM(mode)
    local music_name = "Set_State_Battle02"
    if mode == Battle.BattleGlobalConfig.BATTLE_MODE.STAGE 
    or mode == Battle.BattleGlobalConfig.BATTLE_MODE.MULT_STAGE
    or mode == Battle.BattleGlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
        music_name = "Set_State_Battle01"
    elseif mode == Battle.BattleGlobalConfig.BATTLE_MODE.WORLD_BOSS or mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
        music_name = "Set_State_Battle03"
    end
    audio:SendEvtBGM(music_name)
end

return StateSoundManager;