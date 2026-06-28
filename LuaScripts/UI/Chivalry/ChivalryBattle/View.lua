local M = class("ChivalryBattleView",LikeOO.OOPopBase)

M.m_uiName = "Chivalry/ChivalryBattle"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local ACTIVE_MODE_TAB = {
	{id = 7,open_id = 395,btn_name = "assassin_img",over_text_name = "assassin_over_text",time_text_name = "assassin_time_text",over_img_name = "assassin_over_img",time_img_name = "assassin_time_img",btn_text = "assassin_btn_text"}, 	--刺客联盟
	{id = 8,open_id = 395,btn_name = "strongest_img",over_text_name = "strongest_over_text",time_text_name = "strongest_time_text",over_img_name = "strongest_over_img",time_img_name = "strongest_time_img",btn_text = "strongest_btn_text"}, 	--最强战神
	{id = 9,open_id = 395,btn_name = "mounttai_img",over_text_name = "mounttai_over_text",time_text_name = "mounttai_time_text",over_img_name = "mounttai_over_img",time_img_name = "mounttai_time_img",btn_text = "mounttai_btn_text"}, 	--泰山之盾
}

local ACTIVE_SEVEN_STAR_TAB = {
	{id = 13,btn_img_name = "a_tmhx_icon_ziwei"},
	{id = 14,btn_img_name = "a_tmhx_icon_kangjinlong"},
	{id = 15,btn_img_name = "a_tmhx_icon_tiantong"},
	{id = 16,btn_img_name = "a_tmhx_icon_ditumo"},
	{id = 17,btn_img_name = "a_tmhx_icon_kangjinlong"},
	{id = 18,btn_img_name = "a_tmhx_icon_xinyuehu"},
	{id = 19,btn_img_name = "a_tmhx_icon_kangjinlong"},
}

function M:onEnter()
	RedPointUtil:saveLocalRedPointFreshTime("ThreeHeroesFiveGallantsBattle")
	--self:updateMsg("refresh_rank_info")
	if self.m_model.seven_star then
		self:setObjectVisible("seven_star_img",true)
		for i, v in ipairs(ACTIVE_MODE_TAB) do
			self:setObjectVisible(v.btn_name,false)
		end
		for i, v in ipairs(ACTIVE_SEVEN_STAR_TAB) do
			v.id = ConfigManager:getCommonValueById(100 + i - 1)
		end
	else
		self:setObjectVisible("seven_star_img",false)
		for i, v in ipairs(ACTIVE_MODE_TAB) do
			v.id = ConfigManager:getCommonValueById(100 + i - 1)
		end
	end


	if self.m_model.is_show_break_btn == 1 then
		self:setObjectVisible("break_btn",true)
		self:setObjectVisible("break_text",true)
	else
		self:setObjectVisible("break_btn",false)
		self:setObjectVisible("break_text",false)
	end
	local active_data = self.m_model:getActiveData()
	self:setTextByLanKey("close_title_text", active_data.name) --游戏名称
	self:setTextByLanKey("break_text","tid#ActiveTrainAttack") --击破描述
	self:setTextByLanKey("task_btn_text","new_str_0062") --任务
	self:setTextByLanKey("ranking_btn_text","new_str_0235") --排行
	self:setTextByLanKey("buff_add_text","dragonsword_text_0013") --伤害加成
	self:setTextByLanKey("no_rank_text","new_str_0838") --还没有大侠上榜
	self:setTextByLanKey("get_btn_text","UnionWar_str_089") --奖励
	self:setTextByLanKey("culture_btn_text","equip_str_035") --培养
	self:setTextByLanKey("break_btn_text","national_beautiful_text_0001") --击破
	self:showReward(false)
	self:setHeroInfo()
	self:refreshUI()
	self:setTextByLanKey("tiaozhan_text","new_str_0386") --挑战
	RedPointUtil:saveLocalRedPointFreshTime("EvilShadowBattle")
end

--刷新
function M:refreshUI()
	self:refreshShowData()
	self:setTime()
	self:refreshRedPoint()
	self:refreshModelStude()
end

--刷新显示数据
function M:refreshShowData()
	--self:setTextByLanKey("max_hurt_text","moon_shadow_str_009") --最高伤害
	self:setTextByLanKey("top_output_text",GameUtil:formatValueToString(self.m_model.m_data.max_damage or 0)) --最高伤害
	--self:setTextByLanKey("buff_tips_text",self.m_model:getHeroBffoData()) --最高伤害
	local str = string.gsub(Language:getTextByKey(self.m_model:getHeroBffoData()), "\\n", "\n")
	self:setText("buff_tips_text",str)
end

--刷新模式状态
function M:refreshModelStude()
	if self.m_model.seven_star then
		self.time_text_name = "seven_star_time_text"
		local over = true
		for i, v in ipairs(ACTIVE_SEVEN_STAR_TAB) do
			if v.id == self.m_model.m_version then
				GameUtil:updateResourcesImg(self:findGameObject("seven_star_btn"),"Texture/zh_cn/tmhx_start/"..v.btn_img_name)
				over = false
			end
		end
		self:setTextByLanKey("seven_star_over_text","new_str_0259")
		if over then
			self:setObjectVisible("seven_star_over_img",true)
			self:setObjectVisible("seven_star_time_img",false)
		else
			self:setObjectVisible("seven_star_over_img",false)
			self:setObjectVisible("seven_star_time_img",true)
		end
	else
			--三期试炼状态
			for i, v in ipairs(ACTIVE_MODE_TAB) do
				local battle_name = self.m_model:getBattleNameData(i)
				if battle_name then
					self:setTextByLanKey(v.btn_text,battle_name)
					self:setObjectVisible(v.over_img_name,v.id ~= self.m_model.m_version)
					self:setObjectVisible(v.time_img_name,v.id == self.m_model.m_version)
					if v.id < self.m_model.m_version then
						self:setTextByLanKey(v.over_text_name,"activities_str_0007")
					elseif v.id > self.m_model.m_version then
						self:setTextByLanKey(v.over_text_name,"new_str_0259")
					else
						self.time_text_name = v.time_text_name
					end
					self:setObjectVisible(v.btn_name,true)
				else
					self:setObjectVisible(v.btn_name,false)
				end
			end
		end

		--侠客拥有状态
		local hero_id = self.m_model:getShowHeroId() or 101
		local is_has_hero,hero_data = self.m_model:getHeroBuff()
		--self:setObjectVisible("get_btn",not is_has_hero)
		--self:setObjectVisible("culture_btn",is_has_hero)
		self:setObjectVisible("tips_img",true)
		if is_has_hero then
		self:setTextByLanKey("tips_text",Language:getTextByKey("chivalry_text_0002",hero_data) .. "%")
		else
		if hero_data then
		self:setTextByLanKey("tips_text","chivalry_text_0001",Language:getTextByKey(hero_data.name))
		else
		self:setObjectVisible("tips_img",false)
			end
			end
	end

--设置时间
function M:setTime()
	local today_time = os.date("%Y-%m-%d",UserDataManager:getServerTime())
	local string_day = string.format("%s %d:%d:%d",today_time,23,59,59)
	self.day_time = GameUtil:stringToTimesTamp(string_day)
	local active_data = self.m_model:getActiveData()
	self.totle_day_time = GameUtil:stringToTimesTamp(active_data.end_time)
end

--更新时间
function M:updateTime()
	local cur_tim = UserDataManager:getServerTime() --服务器时间
	local surplus_time = 0
	local surplus_day_time = 0
	if self.totle_day_time ~= nil then
		surplus_day_time = self.totle_day_time - cur_tim
	end
	if self.day_time ~= nil then
		surplus_time = self.day_time - cur_tim
	end
	if surplus_time <= 0 then
		self:updateMsg("refresh_rank_info")
	elseif surplus_day_time <= 0 then
		self:setTime()
		self:updateMsg("refresh_rank_info")
	else
		local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_day_time) --换算剩余时间
		if self.time_text_name then
			--local time_content = string.format("gf_str_0042",remain_day,remain_hour,remain_min,remain_sec)
			if remain_day == 0 then
				self:setTextByLanKey(self.time_text_name, "chivalry_text_0018",remain_hour,remain_min,remain_sec) --重置剩余时间
			else
				self:setTextByLanKey(self.time_text_name, "chivalry_text_0017",remain_day,remain_hour,remain_min,remain_sec) --重置剩余时间
			end
		end
	end
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
	local hero_id = self.m_model:getShowHeroId() or 101
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
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
	self:setObjectVisible("task_btn_red_point_img", self.m_model:getTaskRedPoint())
	if self.m_model.is_show_break_btn == 1 then
		self:setObjectVisible("break_btn_red_point_img", self.m_model:getBreakRedPoint()) --击破红点
	end
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