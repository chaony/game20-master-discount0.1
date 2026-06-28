local M = class("WorldBossPopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/WorldBoss/WorldBossPop"
M.m_size_type = 1
M.m_iphoneXAdapter = true
M.bossHpColor2 = {
	Color(85/255,168/255,206/255,1),  -- 天蓝
	Color(167/255,85/255,206/255,1),  -- 紫色
	Color(206/255,165/255,85/255,1),  --黄色
	Color(206/255,85/255,85/255,1),   -- 红色
	Color(0/255,0/255,0/255,1),  -- 黑色
}

local CLOSE_TITLE_TEXT ={"world_boss_str_0035", "world_boss_str_0043"}
function M:onEnter()
	self:setTextByLanKey("close_title_text", "world_boss_str_0017")
	self:setTextByLanKey("mop_up_btn_btn_text", "word_boss_sd_tex")
	self.title_text = self:findText("title_text")
	self.intensify_atk_text = self:findText("intensify_atk_text")
	self.challenge_text = self:findText("challenge_text")
	self.challenge_value_text = self:findText("challenge_value_text")
	self.no_challenge_text = self:findText("no_challenge_text")
	self.next_value_text = self:findText("next_value_text")
	self.times_text = self:findText("times_text")
	self.down_time_text = self:findText("down_time_text")
	self.race_panel = self:findGameObject("race_panel")
	self.dan_img = self:findImage("dan_img")
	self.dan_text = self:findText("dan_text")
	self.rank_text = self:findText("rank_text")
	self.skill_panel = self:findGameObject("skill_panel")
	self.challenge_panel = self:findGameObject("challenge_panel")
	self.race_bg = self:findGameObject("race_bg")
	self.reward_btn = self:findGameObject("reward_btn")
	self.rank_btn = self:findGameObject("rank_btn")
	self.tips_detail_panel = self:findGameObject("tips_detail_panel")
	self.tips_text = self:findGameObject("tips_text")
	-- self.ArenaSegmentNode = self:findGameObject("ArenaSegmentNode")
	self.m_gray_image = self:findImage("gray_image")
	
	self:setTextByLanKey("reward_btn_ext", "new_str_0224")
	self:setTextByLanKey("rank_btn_text", "new_str_0114")
	self:setTextByLanKey("new_rank_btn_text", "new_str_0114")
	self:setTextByLanKey("record_btn_text", "world_boss_str_0005")
	self:setTextByLanKey("challenge_btn_text", "new_str_1060")
	self:setTextByLanKey("title_text", "world_boss_str_0017")
	self:setTextByLanKey("no_rank_text", "world_boss_str_0036")
	--self:setObjectVisible("rank_btn", false)
	self:setObjectVisible("record_btn", false)
	
	self.boss_hpValue = self:findImage("hpValue")
	self.boss_hpBg = self:findImage("hpBg")
	self.treasure = self:findGameObject("treasure") --宝箱
	self.treasure_count = self:findText("treasure_box_text") --宝箱数量
	self.bosshp_slider = self:findSlider("BosshpBar")
	self.bosshead_tx_img = self:findGameObject("bosshead_tx_img")
	
	self.dmg = self:findText("dmg")
	self:refreshUI()
	self:updateIntensifyRace()
	self:updateBossSkill()
	self:initDownTime()

	self:setTextByLanKey("rank_title_text", CLOSE_TITLE_TEXT[self.m_model.m_boss_id])
end

function M:refreshUI()
	local challenge_value = self.m_model:getMaxBattleDamage()
	self:refreshBossHp()
	self:updateBossHead()
	self:refreshBubble()
	self:refreshRankNode()
	self:refreshRedPoint()
	local box_num = self.m_model:getRewardBoxNum()
	self:setTextByLanKey("treasure_box_text", tostring(box_num))
	self.no_challenge_text.text = Language:getTextByKey("world_boss_str_0003")
	local kill_num = self.m_model.m_data.kill_num and self.m_model.m_data.kill_num or 0
	self.challenge_text.text = Language:getTextByKey("world_boss_str_0037", kill_num)
	local left_times = self.m_model:getLeftTimes()
	self.times_text.text = Language:getTextByKey("world_boss_str_0001", left_times)
	local challenge_btn_img = self:findImage("challenge_btn")
	if left_times > 0 then
		challenge_btn_img.material = nil
	else
		challenge_btn_img.material = self.m_gray_image.material
	end
	self.rank_text.text = self.m_model.m_data.self_rank
	self.dan_img.gameObject:SetActive(false)
	self.reward_btn:SetActive(false)
	self:setObjectVisible("mop_up_btn",self.m_model.m_boss_last_damage > 0 and left_times > 0)
	self:setObjectVisible("max_damage_text",  self.m_model:getMaxBattleDamage() > 0)
	self:setTextByLanKey("max_damage_text", "world_boss_str_0039", self.m_model:getMaxBattleDamage())

	--快速导航
	self:setObjectVisible("guide_btn", true)
end

function M:refreshRedPoint()
	local red_flag = UserDataManager:getRedDotByKey("world_boss_like")
	self:setObjectVisible("new_rank_btn_red_point", red_flag == 1)
end

function M:refreshBubble()
	local bubble_tips_id = "world_boss_str_0040"
	local left_times = self.m_model:getLeftTimes()
	
	if left_times > 0 then
		self:setObjectVisible("qipao_img", true)
		local need_damage, is_max = self.m_model:getNextRewardDamage()
		
		if self.m_model.m_boss_last_damage > 0 and self.m_model.m_boss_last_damage < self.m_model.m_data.max_hp then
			self:setTextByLanKey("next_reward_text", "world_boss_str_0040", left_times, need_damage)
		else
			self:setTextByLanKey("next_reward_text", "world_boss_str_0041", left_times)
		end
		local sequence = Tweening.DOTween.Sequence()
		sequence:AppendInterval(0.1 + 5)
		sequence:OnComplete(function()
			self.m_delay_close_sequence = nil
			self:setObjectVisible("qipao_img", false)
		end)
		sequence:SetAutoKill(true)
		self.m_delay_close_sequence = sequence
	else
		self:setObjectVisible("qipao_img", false)
	end
end

function M:updateBossHead()
	local bossHeadConfig = self.m_model:getBossData();
	if bossHeadConfig ~= nil then
		UIUtil.setImg(self.bosshead_tx_img, bossHeadConfig.icon, "hero_head_ui")
		self:setTextByLanKey("boss_title_text", bossHeadConfig.name)
	end
end

function M:refreshRankNode()
	local rank_data = self.m_model.m_data.kill_ranks
	self:setObjectVisible("rank_content_node", rank_data and #rank_data > 0)
	self:setObjectVisible("no_rank_img", not(rank_data) or #rank_data == 0)
	if rank_data and #rank_data > 0  then
		for i = 1, 3 do
			if rank_data[i] then
				self:setObjectVisible("rank_icon_" .. i, true)
				self:setObjectVisible("rank_name_text_" .. i, true)
				self:setText("rank_name_text_" .. i, rank_data[i].user.name)
			else
				self:setObjectVisible("rank_icon_" .. i, false)
				self:setObjectVisible("rank_name_text_" .. i, false)
			end
		end
	end
end

function M:updateIntensifyRace()
	-- UIUtil.destroyAllChild(self.race_panel.transform)
	local world_boss = ConfigManager:getCfgByName("world_boss")
	local world_cfg = world_boss[self.m_model.m_data.world_boss_id]
	if world_cfg then
		local num = self.race_panel.transform.childCount
		--local height = 150
		for i=1,num do
			local race_img = self.race_panel.transform:GetChild(i - 1)
			if i <= #world_cfg.goodness_race then
				race_img.gameObject:SetActive(true)
				local rece_cfg = GlobalConfig.TYPE_HERO_RACE[world_cfg.goodness_race[i]]
				UIUtil.setImg(race_img, rece_cfg.big_race_icon, ResourceUtil:getLanAtlas())
				--height = height + 65
			else
				race_img.gameObject:SetActive(false)
			end
		end
	end
	--self.race_bg:GetComponent("RectTransform"):SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), height);
end

function M:caculateWorldBossHpBar()
	local max_hp = self.m_model.m_boss_max_hp
	local cur_part, cur_hp_percent, total_hp_percent = self.m_model:getWorldBossHp()
	local hp_color_index = cur_part + 1
	local hp_bg_color_index = cur_part + 2
	return cur_hp_percent, hp_color_index, hp_bg_color_index
end

function M:refreshBossHp()
	local cur_hp_percent, hp_color_index, hp_bg_color_index = self:caculateWorldBossHpBar()
	self.boss_hpValue.color = self.bossHpColor2[hp_color_index]
	self.boss_hpBg.color = self.bossHpColor2[hp_bg_color_index]
	self.bosshp_slider.value = 1 - cur_hp_percent
	local total_hp_percent = (1 - self.m_model.m_boss_last_damage / self.m_model.m_boss_max_hp )
	total_hp_percent = math.max(0, total_hp_percent)
	self.dmg.text = string.format("%.2f", (total_hp_percent *100 )) .. "%"
end

function M:updateBossSkill()
	--local world_boss_cycle = ConfigManager:getCfgByName("world_boss_cycle")[self.m_model.m_data.battle_config_id]
	local world_boss = ConfigManager:getCfgByName("world_boss")
	local world_boss_item = world_boss[self.m_model.m_boss_id]
	if world_boss_item then
		--local stage_battle = ConfigManager:getCfgByName("stage_battle")
		local battle_cfg = ConfigManager:getCfgStageBattle(world_boss_item.battle_id)--stage_battle[world_boss_item.battle_id]
		local boss = battle_cfg.monster[battle_cfg.worldboss_position]
		local hero_detail = ConfigManager:getCfgByName("hero_detail")
		local boss_cfg = hero_detail[boss.id]
		local num = self.skill_panel.transform.childCount
		for i=1,num do
			local skill_bg = self.skill_panel.transform:GetChild(i-1)
			skill_bg.gameObject:SetActive(false)
			if i <= #boss_cfg.skill then
				skill_bg.gameObject:SetActive(true)
				local skill_img = self:findGameObject(string.format("skill_%d_img", i))
				local skill = GameUtil:getSkill(boss_cfg.skill[i][1][1])
				UIUtil.setImg(skill_img, skill.icon, "skill_icon")
			end
		end
	end
end

function M:initDownTime()
	local function tick(dt)
		local end_ts = self.m_model.m_data.end_ts
		local down_time = end_ts - UserDataManager:getServerTime()
		if down_time >= 0 then
			local text = GameUtil:formatTimeBySecond(down_time)
			self.down_time_text.text = Language:getTextByKey("world_boss_str_0004",text)
		else
			self:updateMsg("close_mop_up")
			self:updateMsg("fresh_data")
		end
	end
	self.tick_id = self.m_control:setTimer(1, tick)
	tick()
end

function M:showTipsDetail(flag)
	self.tips_detail_panel:SetActive(flag)
end

return M