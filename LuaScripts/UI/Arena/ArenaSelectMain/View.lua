---@class ArenaSelectMainView:OOPopBase
---@field m_model ArenaSelectMainModel
local M = class("ArenaSelectMainView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaSelectMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true
function M:onEnter()
	self:setTextByLanKey("close_title_text", "world_str_002")
	self.hui = self:findImage("hui");
	self.war_time = self:findText("guild_war_time")
	self.war_time_name = self:findText("guild_war_time_name")
	self.area_ui = {
		["rise_arena"] = {
			--时间名字
			time_name = "normal_time_name",
			--时间
			time_num = "normal_time",
			--名字
			name = "normal_name",
			peak_name = "peak_name",
			--排名名称
			rank_name = "normal_rank_name",
			--时排名
			rank_num = "normal_rank_num",
			normal_btn="normal_btn",
		},
		--["arena"] = {
		--	--时间名字
		--	time_name = "normal_time_name",
		--	--时间
		--	time_num = "normal_time",
		--	--名字
		--	name = "normal_name",
		--	--排名名称
		--	rank_name = "normal_rank_name",
		--	--时排名
		--	rank_num = "normal_rank_num",
		--	normal_btn="normal_btn"
		--},
		["race_arena"] = {
			--时间名字
			time_name = "race_time_name",
			--时间
			time_num = "race_time",
			--名字
			name = "race_name",
			--排名名称
			rank_name = "race_rank_name",
			--时排名
			rank_num = "race_rank_num",
			--描述
			des = "race_des",
			--未开启的描述
			no_open_img = "race_not_open_img",
			race_des_text = "race_des_text",
		},
		["top_race_arena"] = {
			--时间名字
			time_name = "top_race_time_name",
			--时间
			time_num = "top_race_time",
			--名字
			name = "top_race_name",
			--排名名称
			rank_name = "top_race_rank_name",
			--时排名
			rank_num = "top_race_rank_num",
			--描述
			des = "top_race_des",
			--未开启的描述
			no_open_img = "top_race_not_open_img",
			race_des_text = "top_race_des_text",
		},
		["fulwin_arena"] = {
			--时间名字
			--time_name = "top_race_time_name",
			--时间
			--time_num = "top_race_time",
			--名字
			name = "fylt_race_name",
			--排名名称
			--rank_name = "top_race_rank_name",
			--时排名
			--rank_num = "top_race_rank_num",
			--描述
			des = "fylt_num_txt",
			--未开启的描述
			no_open_img = "top_race_not_open_img",
			race_des_text = "top_race_des_text",
		},
	}
	
	self.area_keys = {
		[1] = "rise_arena",--争锋联赛
		--[1] = "arena",--争锋联赛
		[2] = "race_arena",
		[3] = "top_race_arena",
		[4] = "fulwin_arena",
	}
	
	self.area_name_lan_key = {
		["arena"] = "tid#arena_explain1",
		["race_arena"] = "tid#arena_explain7",
		["top_race_arena"] = "tid#GuildWar_2",
	}
	-- 暂时把高阶竞技场隐藏

	self.area_name_key = {
		["rise_arena"] = {name1= "a_ljsz_zhengfengliansai1",name2= "a_ljsz_zhengfengliansai2",name3= "a_ljsz_zhengfengliansai3"},
		--["arena"] = {name= "a_ljsz_zhengfenglunjian"},
		["race_arena"] = {name = "a_ljsz_wenzi_dijisai"},
		["top_race_arena"] = {name = "a_ljsz_wenzi_tianjisai"},
		["fulwin_arena"] = {name = "a_ljsz_fylt_z"},
	}
	
	self:refreshUI()
end

--刷新时间
function M:refreshTimeUI( str )
	-- 0:未开始，1：报名阶段，2：匹配阶段，3：驻扎阶段, 4: 战斗阶段，5：休赛阶段，下个赛季未开始
	local time_str = str;
	if self.m_model.type == 0 then
		self.war_time_name.text = Language:getTextByKey("UnionWar_str_055") --距离帮会战开启还有
	elseif self.m_model.type == 1 then
		self.war_time_name.text = Language:getTextByKey("UnionWar_str_056"); --距离报名结束还有
	elseif self.m_model.type == 2 then
		self.war_time_name.text = Language:getTextByKey("UnionWar_str_057"); --距离匹配结束还有
	elseif self.m_model.type == 3 then
		self.war_time_name.text = Language:getTextByKey("UnionWar_str_058"); --距离今日开战还有
	elseif self.m_model.type == 4 then
		self.war_time_name.text = Language:getTextByKey("UnionWar_str_059"); --距离战斗结束还有
	elseif self.m_model.type == 5 then
		self.war_time_name.text = Language:getTextByKey("UnionWar_str_055"); --距离帮会战开启还有
	end
	self.war_time.text = time_str;
end

--刷新UI
function M:refreshUI()
	--local guild_war_area_open_flag = BtnOpenUtil:isBtnOpen(156)
	--self:setObjectVisible("guild_war_area", guild_war_area_open_flag == true)
	local cur_match_type = 0
	for i, v in ipairs(self.area_keys) do
		--得到ui数据
		local ui_data = self.area_ui[v];
		local server_data = self.m_model:getAreaData(v) or {};
		if v == "rise_arena" then
			if table.nums(server_data)==0 then
				self:setObjectVisible("normal_area",false)
			else
				self:setObjectVisible("normal_area",true)
				self:updateArea(ui_data,server_data,v)
			end
		elseif v == "top_race_arena" then
			local race_img = self:findImage("top_race_btn");
			local race_name_img = self:findImage("top_race_name");
			local race_btn = self:findButton("top_race_btn");
			local race_open_flag, race_tips_str = BtnOpenUtil:isBtnOpen(213)
			local season = server_data.season or 1
			local match_type = server_data.match_type or 0
			cur_match_type = match_type
			self:setObjectVisible("top_race_time_name", race_open_flag );
			self:setObjectVisible("top_race_time", race_open_flag);
			self:setObjectVisible("top_race_rank_bg", race_open_flag and match_type == 1);
			self:setObjectVisible("top_race_rank_name", race_open_flag);
			self:setObjectVisible("top_race_rank_num", race_open_flag);
			self:setObjectVisible("top_race_des_bg", race_open_flag);
			self:setObjectVisible("top_race_des", race_open_flag and match_type == 1);
			self:setObjectVisible("top_race_shili",race_open_flag  and match_type == 1);
			self:setObjectVisible(ui_data.no_open_img, false)
			self:setTextByLanKey(ui_data.race_des_text,"tid#TianJiSai_des_4")
			
			if race_open_flag and season > 0 then
				race_img.material = nil;
				race_name_img.material = nil;
				race_btn.interactable = true;
				self:updateArea(ui_data,server_data,v)
				if server_data.races ~= nil and _G.next(server_data.races) ~= nil then
					self:updateArea(ui_data,server_data,v)
				else
					--self:setObjectVisible("race_area", false);
				end
				if match_type ~= 1 then
					race_img.material = self.hui.material;
					race_name_img.material = self.hui.material;
					--race_btn.interactable = false;
				end
			else
				race_img.material = self.hui.material;
				race_name_img.material = self.hui.material;
				--race_btn.interactable = false;
				--没有开启就隐藏
				
				self:setObjectVisible("top_race_area", false);
				--名字
				self:setTextByLanKey(ui_data.name,"tid#arena_explain7")
			end
		elseif v == "race_arena" then
			local race_img = self:findImage("race_btn");
			local race_name_img = self:findImage("race_name");
			local race_btn = self:findButton("race_btn");
			local race_open_flag, race_tips_str = BtnOpenUtil:isBtnOpen(141)
			local season = server_data.season or 1
			local match_type = server_data.match_type or 0
			self:setObjectVisible("race_time_name", race_open_flag);
			self:setObjectVisible("race_time", race_open_flag);
			self:setObjectVisible("race_rank_bg", race_open_flag and match_type == 0);
			self:setObjectVisible("race_rank_name", race_open_flag);
			self:setObjectVisible("race_rank_num", race_open_flag);
			self:setObjectVisible("race_des_bg", race_open_flag);
			self:setObjectVisible("race_des", race_open_flag and match_type == 0);
			self:setObjectVisible("race_shili", race_open_flag and match_type == 0);
			self:setObjectVisible(ui_data.no_open_img, false);
			self:setTextByLanKey(ui_data.race_des_text,"tid#TianJiSai_des_3")
			if race_open_flag and season > 0  then
				race_img.material = nil;
				race_name_img.material = nil;
				race_btn.interactable = true;
				self:updateArea(ui_data,server_data,v)
				if server_data.races ~= nil and _G.next(server_data.races) ~= nil then
					self:updateArea(ui_data,server_data,v)
				else
					--self:setObjectVisible("race_area", false);
				end
				if match_type ~= 0 then
					race_img.material = self.hui.material;
					race_name_img.material = self.hui.material;
					--race_btn.interactable = false;
				end
			else
				race_img.material = self.hui.material;
				race_name_img.material = self.hui.material;
				--race_btn.interactable = false;
				--没有开启就隐藏
				self:setObjectVisible("race_area", false);
				--名字
				self:setTextByLanKey(ui_data.name,"tid#arena_explain7")
			end
		elseif v == "fulwin_arena" then
			local race_img = self:findImage("fylt_race_btn");
			local race_name_img = self:findImage("fylt_race_name");
			local race_btn = self:findButton("fylt_race_btn");
			local race_open_flag, race_tips_str = BtnOpenUtil:isBtnOpen(312)
			local open_conditionData = ConfigManager:getCfgByName("open_condition")
			local curActive = open_conditionData[312]
			local targetSeason = curActive.season_unlock or 1
			local season_data = UserDataManager.m_season_data or {}
			local curSeason = season_data.season or 0
			self:setImg(self.area_name_key[v].name, ResourceUtil:getLanAtlas(), ui_data.name)

			if race_open_flag and curSeason >= targetSeason then
				race_img.material = nil;
				race_name_img.material = nil;
				race_btn.interactable = true;
			else
				race_img.material = self.hui.material;
				race_name_img.material = self.hui.material;
				--名字
				self:setTextByLanKey(ui_data.name,"tid#arena_explain7")
				--没有开启就隐藏
				self:setObjectVisible("fylt_node", false);
			end
		end
	end
	--local normal_red_point = RedPointUtil:isFuncRedPointById(41)
	local normal_red_point = RedPointUtil:isFuncRedPointById(472)
	local race_red_point = RedPointUtil:isFuncRedPointById(141)
	local guild_war_red_point = RedPointUtil:isFuncRedPointById(168)
	local high_area_red_point_flag = RedPointUtil:isFuncRedPointById(34)
	self:setObjectVisible("normal_red_point", normal_red_point == true)
	self:setObjectVisible("race_red_point", race_red_point == true and cur_match_type == 0)
	self:setObjectVisible("top_race_red_point", race_red_point == true and cur_match_type == 1)
	self:setObjectVisible("fylt_race_red_point", false)
	--self:setObjectVisible("guild_war_red_point", guild_war_red_point == true)
	--self:setObjectVisible("high_area_red_point", high_area_red_point_flag == true)

	--快速导航
	self:setObjectVisible("guide_btn", true)
end

--更新区域
function M:updateArea( ui_data, server_data, key )
	--赛季结束倒计时
	self:setTextByLanKey(ui_data.time_name,"new_str_1058")
	local time = server_data.last_time - UserDataManager:getServerTime()
	--时间数据
	local ft = GameUtil:formatTimeBySecond(time)
	if time > 0 then
		self:setText(ui_data.time_num, ft)
	else
		self:setText(ui_data.time_num, "")
	end
	--排名
	self:setTextByLanKey(ui_data.rank_name,key == "high_arena" and "world_boss_str_0027" or "new_str_0374")

	--名字
	if self.area_name_key[key].name then
		self:setImg(self.area_name_key[key].name, ResourceUtil:getLanAtlas(), ui_data.name)
	else
		--争锋联赛
		local match_type=server_data.rise_id
		local img_name="ljsz_zfls_name"..match_type
		self:setImg(img_name, ResourceUtil:getLanAtlas(), ui_data.peak_name)
		--local img_name="a_ljsz_zhengfengliansai_bg"..match_type
		--self:setImg(img_name,"arena_ui", ui_data.normal_btn)

		local index=self.m_model:getbgIndex(server_data.rise_id)
		local bg_img = self:findImage(ui_data.normal_btn)
		local bg_img_name="selectmain_peak_bg"..index
		GameUtil:updateResourcesImg( bg_img, "Texture/arena/" .. bg_img_name)

		self:setImg("selectmain_peak_name"..index, ResourceUtil:getLanAtlas(), ui_data.name)
	end
	--排名数量
	if server_data.rank > 0 then
		self:setText(ui_data.rank_num, server_data.rank)
	else
		--未上榜
		self:setTextByLanKey(ui_data.rank_num,"new_str_0076")
	end
	--本周参战势力
	if ui_data.des ~= nil then
		self:setTextByLanKey(ui_data.des,"new_str_0752")
	end
	--设定开方种族
	if server_data.races ~= nil then
		local race_key = "race_shili"
		if key == "top_race_arena" then
			race_key = "top_race_shili"
		end
		self:setObjectVisible(race_key .. "1", false);
		self:setObjectVisible(race_key .. "2", false);
		self:setObjectVisible(race_key .. "3", false);
		for i, v in ipairs(server_data.races) do
			self:setObjectVisible(race_key .. i, true);
			local race_img_info = GlobalConfig.TYPE_HERO_RACE[v];
			LuaBehaviourUtil.setImg(self.m_luaBehaviour, race_key .. i, race_img_info.arena_icon, "arena_ui")
		end
	end
end

function M:updateLockArea(ui_data, server_data, key )
	self:setObjectVisible("high_area", true)
	--local high_img = self:findImage("high_btn");
	--high_img.material = self.hui.material;
	self:setObjectVisible("UI_Arena_Glow_001", false)
	--self:setObjectVisible("high_rank_bg", false)
	--赛季结束倒计时
	self:setTextByLanKey(ui_data.time_name, "arena_str_0011")
	self:updateLockAreaTime()
end

function M:updateLockAreaTime()
	local show_lock_top = self.m_model:getAheadShowTopArena()
	if show_lock_top == true and self.m_model.open_top_arena_ts and self.m_model.open_top_arena_ts > 0 then
		local time = self.m_model.open_top_arena_ts - UserDataManager:getServerTime()
		local ft = GameUtil:formatTimeBySecond(time,999)
		self:setTextByLanKey("high_time", ft)
		if time <= 0 then
			self:refreshUI()
		end
	end
end

return M