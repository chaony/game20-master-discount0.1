--- 剑试天下 世界Boss 成功
local M = class("SettlementSwordWorldBossWinNodeView", LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementSwordWorldBossWinNode"
M.bossHpColor = {
    Color(206 / 255, 165 / 255, 85 / 255, 1), --黄色
    Color(85 / 255, 168 / 255, 206 / 255, 1), -- 天蓝
    Color(167 / 255, 85 / 255, 206 / 255, 1), -- 紫色
    Color(206 / 255, 85 / 255, 85 / 255, 1), -- 红色
}
function M:onEnter()
    self.value_slider = self:findSlider("value_slider")
    self.m_silder_fill = self:findImage("Fill")
    self.m_silder_bg = self:findImage("damage_bg_img")
    self.m_silder_bg.color.a = 0
    self.value_text = self:findText("value_text")
    self.bosshead_tx_img = self:findGameObject("bosshead_tx_img")
    self.m_boss_max_hp = self.m_model.m_data.max_hp
    self.m_boss_hp_cid = self.m_model.m_data.boss_hp_cid
    self:refreshUI()
    self.color = Color(0, 0, 0, 0)
end

function M:refreshUI()
    local data = self.m_model.m_data
    local new_bg_img = self:findGameObject("new_bg_img")
    new_bg_img:SetActive(data.max_damage_change)
    self:setTextByLanKey("max_harm_text", "world_boss_str_0019")
    self:setTextByLanKey("new_bg_text", "xin_jl_text")
    self:setObjectVisible("reward_title_text", true)
    self:setTextByLanKey("reward_title_text" , "new_str_1104")
    local old_rank = data.old_rank
    local new_rank = data.new_rank
    local rank_change = false
    if old_rank and new_rank then
        rank_change = new_rank > old_rank
    end
    self:setObjectVisible("Img_rank_up", rank_change)
    local boss_damage_rank = data.self_boss_damage_rank
    local txt_rank = Language:getTextByKey("boss_fight_main_text_001")
    txt_rank = txt_rank .. ":" ..boss_damage_rank
    self:setTextByLanKey("text_rankShow",txt_rank)
    
    self:setObjectVisible("boss_head", true)
    self:setTextByLanKey("return_btn_text", "new_str_0478")
    local max_damage = self:getMaxDamage()
    self:setText("max_value_text", max_damage)
    local next_dan_1_text = self:findText("next_dan_1_text")
    local next_dan_2_text = self:findText("next_dan_2_text")
    if data.pre_mix_damage and data.pre_mix_damage ~= -1 then
        next_dan_1_text.text = string.format(Language:getTextByKey("world_boss_str_0020"), data.pre_mix_damage)
    else
        self:setObjectVisible("next_dan_1_text", false)
    end
    self:setTextByLanKey("treasure_box_text", tostring(self.m_model.m_data.chest_count or 0))
    self:setObjectVisible("next_reward_text", false)
    self:setObjectVisible("treasureHead", false)
    self.hero_train = ConfigManager:getCfgByName("train_challenge")
    self.hero_train_cfg = self.hero_train[self.m_model.m_boss_id or 1] or {}
    local hero_detail = ConfigManager:getCfgByName("hero_detail");
    local boss_show_data =  self:getBossShowData()
    local boss_id = boss_show_data.data_id
    local hero_data = hero_detail[boss_id];
    UIUtil.setImg(self.bosshead_tx_img, hero_data.icon, "hero_head_ui")
end

function M:getNewBossRewardCfg()
    local world_boss_reward_cfg = ConfigManager:getCfgByName("world_boss_rewards")
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS and world_boss_reward_cfg and next(world_boss_reward_cfg) and world_boss_reward_cfg[self.m_model.m_boss_id] then
        local reward_data = world_boss_reward_cfg[self.m_model.m_boss_id][self.m_boss_hp_cid]
        return reward_data.reward_lost_hp
    end
    return {}
end

function M:showOverWord()
    self:setObjectVisible("return_btn", false)
end

function M:getMaxDamage()
    local max_damage = self.m_model.m_data.boss_max_damage or 0
    return max_damage
end

function M:getSliderColor(cur_index)
    self.value_slider.value = 0
    self.m_silder_bg.color = self.color
    self.lastnum = 0
    local num = cur_index % #self.bossHpColor
    if num <= 0 then
        if self.lastnum > #self.bossHpColor then
            self.lastnum = 1
        end
        num = self.lastnum + 1
    end
    self.lastnum = num
    if num > #self.bossHpColor then
        num = num - #self.bossHpColor
    end
    self.color = self.m_silder_fill.color
    self.color.a = 1
    self.m_silder_fill.color = self.bossHpColor[num]
end

function M:sliderAnim()
    local hp_value = 1
    self.m_silder_fill.color = self.bossHpColor[4]
    local battle_id = self.m_model.m_params.battle_id
    local max_damage = self.m_model.m_data.damage
    --if battle_id ~= nil and self.m_model.m_data.boss_max_damage[tostring(battle_id)] then
    --    max_damage = self.m_model.m_data.boss_max_damage[tostring(battle_id)].damage or 0
    --end
    local sliderFun = nil
    local old_hp = 0
    local slider_anim_time = 2
    
    sliderFun = function()
        Tweening.DOTween.To(function (v)
            local text = math.floor(v)
            self.value_text.text = text
        end, old_hp, max_damage, slider_anim_time)
        self.value_slider.value = 0
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(DOTweenModuleUI.DOValue(self.value_slider, hp_value, slider_anim_time))
        sequence:OnComplete(function()
            self.value_text.text = tostring(max_damage)
        end)
        sequence:SetAutoKill(true)
        self.m_sequence = sequence
    end
    sliderFun()

end

function M:getBossShowData()
    local show_data = {}
    local battle = self.m_model.m_data.battle or {}
    local output = battle.output or {}
    local rounds = output.rounds or {}
    local round_data = rounds[1] or {}
    local defender_team = round_data.defender_team or  {}
    local team = defender_team.team or {}
    local heros = defender_team.heros or {}
    show_data = GameUtil:getFormatTeamData(team, heros, false)
    
    local defender_stats = round_data.defender_stats or {}
    local max_statistics_data = {}
    for k, v in pairs(show_data) do
        v.statistics_data = defender_stats[v.card_id] or {}
        v.max_statistics_data = max_statistics_data
        for k1, v1 in pairs(v.statistics_data) do
            if max_statistics_data[k1 .. "_max"] == nil then
                max_statistics_data[k1 .. "_max"] = v1
            else
                max_statistics_data[k1 .. "_max"] = math.max(max_statistics_data[k1 .. "_max"], v1)
            end
        end
    end
    return show_data[1]
end

function M:destroy()
    if not IsNull(self.m_sequence) then
        self.m_sequence:Kill()
        self.m_sequence = nil
    end
    M.super.destroy(self)
end

return M