local M = class("GuildHighNewMainView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarNewMain"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local PLAYOFF_TYPE = {
	[1] = {name = "guild_high_war_new_007"},
	[2] = {name = "guild_high_war_new_008"},
	[3] = {name = "guild_high_war_new_009"},
	[4] = {name = "guild_high_war_new_0010"},
	[5] = {name = "guild_high_war_new_0016"},
}
local GHW_STAGW = {
	[1] = {name = "guild_high_war_new_0022"},
	[2] = {name = "guild_high_war_new_0023"},
	[3] = {name = "guild_high_war_new_0024"},
	[4] = {name = "guild_high_war_new_0025"},
	[5] = {name = "guild_high_war_new_0026"},
	[6] = {name = "guild_high_war_new_0024"},
	[7] = {name = "guild_high_war_new_0027"},
	[8] = {name = "guild_high_war_new_0022"},
	[9] = {name = "guild_high_war_new_0023"},
}
local REWARD_TYPE = {
	[2] = {name = "guild_high_war_new_0019"},
	[4] = {name = "guild_high_war_new_007"},
	[6] = {name = "guild_high_war_new_008"},
	[8] = {name = "guild_high_war_new_009"},
	[10] = {name = "guild_high_war_new_0010"},
}
function M:onEnter()
	--self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 18})
	self.grayImage = self:findImage("grayImage")
	self:setTextByLanKey("close_title_text", "guild_high_war_new_001")
	self:setTextByLanKey("array_btn_text", "guild_high_war_new_0037") --商店
	self:setTextByLanKey("report_btn_text", "guild_high_war_new_005")	
	self:setTextByLanKey("guess_btn_text", "guild_high_war_new_004")
	self:setTextByLanKey("rank_btn_text", "guild_high_war_new_0030")
	self:setTextByLanKey("schedule_btn_text", "guild_high_war_new_0049")
	self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_006")
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	for i = 1,3 do
		self:updatePlayerInfo(i)
	end
	--self:setBottomUI()
	--self:refreshRedPoint()
	----快速导航
	--self:setObjectVisible("guide_btn", true)
	self:createLoopScroll()
	self:updateListTopScroll()
	self:updateActivityTimer()
end

function M:refreshRedPoint()
	self:setObjectVisible("guess_red_point", self.m_model:checkGuessRedPoint())
end
--HuashanSwordTop3 a_hslj_pmzs_1
function M:setBottomUI()
	if self.m_model:checkOpenType() == false or self.m_model:checkHasData() == false then
		self:setTextByLanKey("cur_des_text", Language:getTextByKey("peak_str_0046"))
		self:setTextByLanKey("down_time_des_text", Language:getTextByKey("peak_str_0060"))
	elseif self.m_model.m_data.week and self.m_model.m_data.week > 7 then
		self:setTextByLanKey("cur_des_text", Language:getTextByKey("peak_str_0065"))	
		self:setTextByLanKey("down_time_des_text", self.m_model:getSeasonTime())
	else
		self:setTextByLanKey("cur_des_text", Language:getTextByKey("peak_str_0011")..self.m_model:getCurBattleStatus())	
		self:setTextByLanKey("down_time_des_text", self.m_model:getSeasonTime())
	end
	self:setTextByLanKey("last_des_text", Language:getTextByKey("peak_str_0012")..self.m_model:getPreRank())
	self:setTextByLanKey("history_des_text", Language:getTextByKey("peak_str_0013")..self.m_model:getBestRank())
end

function M:updatePlayerInfo(index)
	local player_data = self.m_model:getPlayerData(index)
	local rank_obj = self:findGameObject("new_rank_"..index)
	local luaBehaviour = UIUtil.findLuaBehaviour(rank_obj)
	if luaBehaviour then
		if next(player_data) ~= nil then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_obj", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "guild_name", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "player_name", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "server_name", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_spine", true)
			local user = player_data.user
			--设置帮会名字
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "guild_name", player_data.guild_info.name or "")
			--设置会长名字
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name", user.name or "")
			--设置服务器
			local server_name = UserDataManager.server_data:getServerNameById(user.server)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"server_name",server_name or "")
			
			--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "zan_num_text", 0)
			--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", player_data.user.name)
			--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_brand", true)
			--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "player_mask", true)
			--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_obj", false)
			local rank_spine = luaBehaviour:FindGameObject("rank_spine")
			self:setSpine(rank_spine, player_data.user.avatar)

			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_obj", false)
			--self.m_model:checkLickData(player_data.user.uid)
			--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "zan_btn_"..index, true)
			--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "zan_num_text"..index, player_data.like)
			--if self.m_model:checkLickData(player_data.user.uid) == true then
			--	LuaBehaviourUtil.setImg(luaBehaviour, "zan_btn_"..index, "a_dz_weidianliang", "common_ui")
			--else
			--	LuaBehaviourUtil.setImg(luaBehaviour, "zan_btn_"..index, "a_dz_dianliang", "common_ui")	
			--end
			--local head_title_img = luaBehaviour:FindGameObject("head_title_img")
			--local title_id = player_data.user.title
			--if title_id and title_id ~= 0 then
			--	head_title_img:SetActive(true)
			--	self:setTitleImage(title_id,head_title_img)
			--else
			--	head_title_img:SetActive(false)
			--end
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_spine", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_obj", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "guild_name", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "player_name", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "server_name", false)
		end
	end
end

function M:setBrandData(obj, data)
	if data then
		UIUtil.setTextByLanKey(obj.transform, "name_text", data.user.name)
	else
		UIUtil.setTextByLanKey(obj.transform, "name_text", "new_str_0835")
	end
end

function M:setSpine(play_img, hero_id)
	local cfg = ConfigManager:getPlayerPictureCfg(tonumber(hero_id))
	local spine =  "hero_0101_SkeletonData"
	if cfg and next(cfg) ~= nil then
		spine = cfg.hero_spine
	else
		local cur_skin_cfg = ConfigManager:getHeroSkinCfg(hero_id)
		if cur_skin_cfg and next(cur_skin_cfg) ~= nil then
			spine = cur_skin_cfg.hero_spine
		end
	end
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" ..spine, "idle", 0, true)
end

-- 设置称号图片
function M:setTitleImage(title_id, titleObj)
	if title_id and title_id ~= 0 then
		titleObj:SetActive(true)
		local name_img = titleObj:GetComponent("Image")
		local cfg = UserDataManager.title_data:getTitleConfigById(title_id)
		UIUtil.destroyAllChild(name_img.gameObject.transform)
		if cfg.title_effect and cfg.title_effect ~= "" then
			ResourceUtil:GetUIEffectItem("Headtitle/" .. cfg.title_effect, name_img.gameObject)
			name_img.enabled = false
		else
			GameUtil:setTextureLoadTitleLanImgText(titleObj, cfg.icon) -- 设置称号图片
			name_img:SetNativeSize()
			name_img.enabled = true
		end
	else
		titleObj:SetActive(false)
	end
end
-------------------------------------------------------------------------
--[[
    创建页签列表
]]
function M:createLoopScroll(first)
	if self.m_model.m_reward_type == 2 then
		--self:setObjectVisible("tab_loopscroll",false)
		return
	end
	self:setObjectVisible("tab_loopscroll",true)
	self.cur_tab = self.m_model.chapter_season_list 
	self.select_cell_obj = nil
	self.first_into = first
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("tab_loopscroll")
		local params = {
			show_data = self.cur_tab,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
				self:update_tag(index, cell_obj, cell_data)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
				if luaBehaviour then
					if self.first_into and self.first_into == true then
						luaBehaviour:RunAnim("OperateActivity_cell", nil, 1)
					end
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				if self.m_model.m_sel_tab_index ~= index then
					self.m_model.m_reward_type = cell_data.type
					self:updateMsg("switch_tab", { index =  index,cell_object =cell_object})
				end
			end,
			ui_name = self.m_uiName
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(self.cur_tab, true, nil, true)
		self:lockTouch()
		self.m_control:setOnceTimer(0.5, function ()
			self.m_scroll_view.m_do_tween_reload_play = false
			self:unlockTouch()
		end)
	end
	if first == true then
		self:lockTouch()
		self.m_control:setOnceTimer(0.5, function ()
			self.first_into = false
			self:unlockTouch()
		end)
	end
end

function M:update_tag(index, obj, data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local tag_name = luaBehaviour:FindText("tag_name_text")
	tag_name.text = Language:getTextByKey(data.name)
	if index == self.m_model.m_sel_tab_index then
		self.select_cell_obj = obj
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", index == self.m_model.m_sel_tab_index)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Achievement_XuanZ_001", index == self.m_model.m_sel_tab_index)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point",false)
end

function M:switchTabNode(index, cell_object)
	if not IsNull(cell_object) then
		if not IsNull(self.select_cell_obj) then
			local luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Achievement_XuanZ_001", false)
		end
		self.select_cell_obj = cell_object
		local luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", true)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Achievement_XuanZ_001", true)
	end
	--刷新排行
	for i = 1,3 do
		self:updatePlayerInfo(i)
	end
	self:updateListTopScroll() --刷新奖励列表
	self:updateActivityTimer()
	--self:refreshTopInfo() -- 章节信息刷新
end
--------------------左侧按钮
-------------------巅峰帮会奖励
function M:updateListTopScroll()
	local data = self.m_model:getRewardData(self.m_model.m_reward_type)
	if self.m_top_list_scroll == nil then
		local list_scroll = self:findGameObject("top_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:listHandle(cell_object, index, cell_data, true)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end
		}
		self.m_top_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_top_list_scroll:reloadData(data)
	end
end

function M:listHandle(obj, id, data, is_top)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_text", data.rank)
	if #data.rank == 1 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_txt", data.rank[1])
	elseif #data.rank >= 2 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_txt", data.rank[1].." - "..data.rank[2])
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_txt", "0")
	end
	local reward_node = luaBehaviour:FindGameObject("reward_node")
	GameUtil:createRewards(reward_node.transform, data.reward, true, true)
end

function M:updateActivityTimer()
	--, 1:报名, 2:常规赛, 3:季后赛, 4:展示期
	self:setObjectVisible("Image2",false)
	self:setObjectVisible("Image1",false)
	if self.m_model.big_stage == 1 then
		self:setTextByLanKey("title_txt_1","guild_high_war_new_0011")
		self:setObjectVisible("Image2",false)
	elseif self.m_model.big_stage == 2 then
		self:setObjectVisible("Image2",true)
		--self:setObjectVisible("Image2",true)
		local end_ts = self.m_model:getEndTs()
		self:setTextByLanKey("title_txt_1","guild_high_war_new_0012",self.m_model.cycle)
		self:setTextByLanKey("title_txt_2","guild_high_war_new_0013",self.m_model.round_id.."/"..self.m_model.all_round_id)
		self:setTextByLanKey("title_txt_3",GHW_STAGW[self.m_model.ghw_stage].name,GameUtil:formatTimeBySecond2(end_ts))
	elseif self.m_model.big_stage == 3 then
		self:setObjectVisible("Image2",true)
		--self:setObjectVisible("Image2",true)
		local end_ts = self.m_model:getEndTs()
		if self.m_model.playoff_type == 0 then
			self:setTextByLanKey("title_txt_1","guild_high_war_new_0045")
		elseif self.m_model.playoff_type > 0 then
			self:setTextByLanKey("title_txt_1",Language:getTextByKey(PLAYOFF_TYPE[self.m_model.playoff_type].name)..string.format(Language:getTextByKey("guild_high_war_new_0015"),self.m_model.cycle))
		end
		self:setTextByLanKey("title_txt_2","guild_high_war_new_0013",self.m_model.round_id.."/"..self.m_model.all_round_id)
		self:setTextByLanKey("title_txt_3",GHW_STAGW[self.m_model.ghw_stage].name,GameUtil:formatTimeBySecond2(end_ts))
	elseif self.m_model.big_stage== 4 then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1087"), delay_close = 2})
		self:updateMsg(99999)
		self:updateMsg("new_close_btn",nil,"UnionWar")
		return
	end
	self:setTextByLanKey("scroll_title_text1", "guild_high_war_new_002",Language:getTextByKey(REWARD_TYPE[self.m_model.m_reward_type].name))
	self:setTextByLanKey("title_txt_4",Language:getTextByKey(REWARD_TYPE[self.m_model.m_reward_type].name))
	
	--状态切换
	local end_ts = self.m_model:getCycleEndTs()
	if end_ts <=0  then --战斗阶段
		if self.m_model.is_can_updata == false then
			self.m_model.is_can_updata = true
			self:updateMsg("update_stage",nil,"GuildHighWar.GuildHighWarNewMain")
		end
	else
		local cycle_ts = self.m_model:getEndTs()
		if cycle_ts <= 0 and (self.m_model.big_stage ==2 or self.m_model.big_stage ==3) then
			if self.m_model.is_can_updata == false then
				self.m_model.is_can_updata = true
				self:updateMsg("update_stage",nil,"GuildHighWar.GuildHighWarNewMain")
			end	
		end
	end
	self:updateButtonstage()
end

function M:updateButtonstage()
	self:setObjectVisible("peak_game_btn",false)
	if self.m_model.is_sign_up == 0 then --未报名
		self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_0017")
	else --已经报名
		local buy_img = self:findImage("peak_game_btn")
		buy_img.material = nil
		if self.m_model.is_condition == 0 or self.m_model.big_stage == 1 then
			self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_0018")
			buy_img.material = self.grayImage.material
		elseif self.m_model.big_stage == 2 then
			--self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_0020",Language:getTextByKey("guild_high_war_new_0019"))
			self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_0038")
		elseif self.m_model.big_stage == 3 then
			--self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_0020",Language:getTextByKey(PLAYOFF_TYPE[self.m_model.playoff_type].name))
			self:setTextByLanKey("peak_game_btn_text", "guild_high_war_new_0038")
		end
	end
end



function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end


return M