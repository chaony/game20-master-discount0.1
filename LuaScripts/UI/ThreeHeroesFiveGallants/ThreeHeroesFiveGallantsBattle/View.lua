local M = class("ThreeHeroesFiveGallantsBattleView",LikeOO.OOPopBase)

M.m_uiName = "ThreeHeroesFiveGallants/ThreeHeroesFiveGallantsBattle"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	RedPointUtil:saveLocalRedPointFreshTime("ThreeHeroesFiveGallantsBattle")
	self:updateMsg("refresh_rank_info")

	local name = self.m_model:getActiveName()
	self:setTextByLanKey("close_title_text", name) --游戏名称
	
	self:setTextByLanKey("battle_btn_text","new_str_0386") --挑战
	self:setTextByLanKey("reward_btn_text","new_str_0062") --任务
	self:setTextByLanKey("ranking_btn_text","new_str_0235") --排行
	self:setTextByLanKey("my_record_text","dragonsword_text_0007") --我的战绩
	self:setTextByLanKey("ranking_reward_text","dragonsword_text_0008") --排名奖励
	self:setTextByLanKey("ranking_reward_text","dragonsword_text_0008") --排名奖励
	self:setTextByLanKey("reward_grant_text","three_heroes_five_gallants_text_0026") --排名奖励在每日重置时发放
	self:setTextByLanKey("surplus_time_text","new_str_0485") --剩余时间
	self:setTextByLanKey("buff_add_text","dragonsword_text_0013") --伤害加成
	self:setTextByLanKey("no_rank_text","new_str_0838") --还没有大侠上榜
	self:showReward(false)
	self:setHeroInfo()
	self:refreshUI()
	self:setTextByLanKey("tiaozhan_text","new_str_0386") --挑战
	RedPointUtil:saveLocalRedPointFreshTime("EvilShadowBattle")
	self:setObjectVisible("hero_item", false)
end

--刷新
function M:refreshUI()
	self:refreshShowData()
	self:setTime()
	self:refreshRedPoint()
	--self.hero_item = self:findGameObject("hero_item")
	--local hero_data = self.m_model:getHeroBffoData()[self.m_model.m_current_start_day]
	--self.cur_hero = UserDataManager.hero_data:getHeroIdsByCid(hero_data.check_hero)
	--local hero_data,hero_cfg = self.m_model:IsHashero(self.cur_hero,hero_data.evo)
	--self:update_Gift(self.hero_item, hero_data,hero_cfg);
end

--刷新显示数据
function M:refreshShowData()
	--self:setTextByLanKey("max_hurt_text","moon_shadow_str_009") --最高伤害
	self:setTextByLanKey("top_output_text",GameUtil:formatValueToString(self.m_model.m_data.max_damage or 0)) --最高伤害
	self:setTextByLanKey("my_ranking_text",Language:getTextByKey("dragonsword_text_0011",self.m_model.m_data.rank)) --我的排名
	--local ranking_info = self.m_model:getRankingReward(self.m_model.m_data.rank)
	----奖励
	--local reward = ranking_info.cfg.daily_rewards or {}
	--local reward_node = self:findGameObject("reward_Content")
	--local function callBack()
	--	audio:SendEvtUI("UI_TJL_Gold")
	--end
	--GameUtil:createRewards(reward_node.transform, reward, true, true, callBack, 1)
	--种族加成
	--local buff_img = self:findGameObject("buff_img")
	--UIUtil.destroyAllChild(buff_img.transform)
	--local race_info = self.m_model:getRace()
	--local race_data = race_info.race
	--for i, v in ipairs(race_data) do
	--	local buff_item = self:createObj("Dragonsword/power_item",buff_img)
	--	local luaBehaviour = UIUtil.findLuaBehaviour(buff_item)
	--	local transform = buff_img.transform
	--	local race_data = GlobalConfig.TYPE_HERO_RACE[v]
	--	if race_data ~= nil then
	--		LuaBehaviourUtil.setImg(luaBehaviour,"power_img", race_data.big_race_icon, ResourceUtil:getLanAtlas())
	--	end
	--	local btn = luaBehaviour:FindButton("power_img")
	--	btn.onClick:AddListener(function() self:updateMsg("race_info",{percent = race_info.percent,race_data = race_data,btn = btn}) end)
	--end

end

--设置时间
function M:setTime()
	local today_time = os.date("%Y-%m-%d",UserDataManager:getServerTime())
	local string_day = string.format("%s %d:%d:%d",today_time,23,59,59)
	self.day_time = GameUtil:stringToTimesTamp(string_day)
end

--更新时间
function M:updateTime()
	local cur_tim = UserDataManager:getServerTime() --服务器时间
	local surplus_time = 0
	if self.day_time ~= nil then
		surplus_time = self.day_time - cur_tim
	end
	if surplus_time <= 0 then
		self:updateMsg("refresh_rank_info")
	else
		local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算剩余时间
		self:setTextByLanKey("time_text", string.format("%02d:%02d:%02d",remain_hour,remain_min,remain_sec)) --重置剩余时间
	end
end

--左下角
function M:update_Gift(cell_obj, hero_data,hero_cfg)
	if hero_data ~= nil then
		local evo_item = self.m_model:getHeroBffoData()[self.m_model.m_current_start_day]
		if evo_item ~= nil and hero_data.evo >= evo_item.evo then
			local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
			if luaBehaviour then
				local heroNode = luaBehaviour:FindGameObject("HeroNode")
				local farm_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo_item.evo]
				self:setTextByLanKey("hero_skill_txt",Language:getTextByKey("active_current_str_0008",Language:getTextByKey(hero_cfg.class),Language:getTextByKey(farm_data.name)))
				--self:setTextByLanKey("hero_skill_txt","new_str_1079",Language:getTextByKey(farm_data.name))
				local hero_data_1 = RewardUtil:getProcessRewardData({101,evo_item.check_hero,1})
				hero_data_1.quality = evo_item.evo
				CommonUIUtil:updateHeroElementByData(heroNode, hero_data_1)
			end
			self:setObjectVisible("hero_item", false)
			self:setTextByLanKey("hero_des_txt","new_str_1065",evo_item.show_buff)
		else
			self:setObjectVisible("hero_item", false)
		end
	else
		self:setObjectVisible("hero_item", false)
	end
end

function M:getMoodShadowEvoData( day )
	local item = nil
	for i, v in ipairs(self.m_model:getHeroBffoData()) do
		if i >= 1 and day >= i then
			item = v;
		end
	end
	return item;
end

--创建object
function M:createObj(name,parent)
	local obj = ResourceUtil:LoadUIGameObject(name,Vector3.zero,parent)
	return obj
end

function M:destroy()
	M.super.destroy(self)
end

--设置spine
function M:setHeroInfo()
	local hero_id = self.m_model:getShowHeroId()
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
	--local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({}, hero_cfg)
	--
	--local class_str = Language:getTextByKey(hero_cfg.class)
	--local name_str = Language:getTextByKey(shin_data_cfg.name)
	--self:setTextByLanKey("hero_name", name_str)
	--self:setTextByLanKey("hero_name2", class_str)
	--local race = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race].big_race_icon
	--self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
	--local frame_data = GlobalConfig.QUALITY_FRAME[hero_cfg.max_evo]
	--self:setImg(frame_data.line_frame_name, "common_ui","hero_evo")
	--
	local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
	local play_img = self:findGameObject("hero_spine")
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
end

--是否显示奖励
function M:showReward(is_show)
	self:setObjectVisible("reward_Content",is_show)
end

--刷新红点
function M:refreshRedPoint()
	self:setObjectVisible("reward_btn_red_point_img",self.m_model:getTaskRedPoint())
end

--刷新排行榜
function M:refreshRank()
	local ranks = self.m_model.m_data.ranks
	self:setObjectVisible("rank_list",#ranks > 0)
	self:setObjectVisible("no_rank_text",#ranks == 0)
	if #ranks > 0 then
		for i = 1, 3 do
			local show_list = false
			if ranks[i] ~= nil then
				show_list = true
				self:setTextByLanKey("rank_name_"..i,ranks[i].user.name)
			end
			self:setObjectVisible("rank_bg_img_"..i,show_list)
			self:setObjectVisible("rank_name_"..i,show_list)
			self:setObjectVisible("rank_img_"..i,show_list)
		end
	end
end

return M