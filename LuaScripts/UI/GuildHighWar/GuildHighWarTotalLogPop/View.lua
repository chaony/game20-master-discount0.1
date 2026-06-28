local M = class("GuildHighWarTotalLogPopView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarTotalLogPop"
M.m_size_type = 2
--M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("title_text1", "guild_high_war_text_0015")
	self:setTextByLanKey("title_text2", "guild_high_war_text_0016")
	self:setTextByLanKey("title_text3", "guild_high_war_text_0017")
	self.m_scroll_view_tab = {}
	self:refreshUI()
	self:setTextByLanKey("common_title_text", "guild_high_war_text_0042")

end

function M:destroy()
	M.super.destroy(self)
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model.m_logs --{{rank = 1, real_index = 1}, {rank = 2, real_index = 2},} --self.m_model:getRankData()
	self:setObjectVisible("common_tips_node", #data == 0)
	local all_cell_size = {}
	for i,v in ipairs(data or {}) do
		if  v.city_id == self.m_model.m_cur_select_id  then
			all_cell_size[i] = Vector2(856, 336)
		else
			all_cell_size[i] = Vector2(856, 148)
		end
	end
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("global_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			all_cell_size = all_cell_size,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "race_img" then
					self:updateMsg("score_look",{click_transform = click_object.transform, msg = Language:getTextByKey("new_str_0074"), top = true})
				elseif click_name == "click_btn" then
					--self:updateMsg("handle_point_btn", {index = index, uid = cell_data.user.uid})
					self:updateMsg("click_btn", cell_data)
				else
					self:updateMsg("item_click", {id = index})
				end
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true, all_cell_size)
	end
end


--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local is_win = data.atk_win == 1
	local hero_node = luaBehaviour:FindGameObject("hero_node")
	--self:heroHandle(hero_node, data.hero)
	local bg_img = luaBehaviour:FindImage("cell_bg_img")
	--修改
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_guild_name_text", "guild_high_war_text_0071")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_guild_name_text", "guild_high_war_text_0072")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"self_best_text",false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"enemy_best_text",false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"self_best_player_name_text",false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"enemy_best_player_name_text",false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"self_cell_player_name_text2",true)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"enemy_cell_player_name_text2",true)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "self_best_player_name_text2", data.atk_g_name)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "enemy_best_player_name_text2", data.def_g_name ~= "" and data.def_g_name or "guild_high_war_text_0053")
	--修改
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_guild_name_text", data.atk_g_name)
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_guild_name_text", data.def_g_name ~= "" and data.def_g_name or "guild_high_war_text_0053")
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "self_best_text", "guild_high_war_text_0044")
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "enemy_best_text", "guild_high_war_text_0044")
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "self_best_player_name_text", data.atk_mvp.name)
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "enemy_best_player_name_text", data.def_mvp.name)
	
	local text = is_win and "guild_high_war_text_0096" or  "guild_high_war_text_0097"
	local img_path = is_win and "a_zjb_chenggongdiban" or "a_zjb_shibaidiban"
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_result_txt", text)
	LuaBehaviourUtil.setImg(luaBehaviour,"cell_result_Image",img_path,"maze_stage_ui")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_result_txt", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_result_Image", false)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "city_name_text", self.m_model:getCityDataById(data.city_id).build_name or "")
	LuaBehaviourUtil.setImg(luaBehaviour, "left_city_result_img", is_win and "a_sjjs_shengli" or "a_sjjs_shibai", ResourceUtil:getLanAtlas())
	LuaBehaviourUtil.setImg(luaBehaviour, "right_city_result_img", not is_win and "a_sjjs_shengli" or "a_sjjs_shibai", ResourceUtil:getLanAtlas())
	if data.user and next(data.user) then
		--data.user.title = 30001
		local head_node = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_node", true)
		GameUtil:setUserAvatar(head_node, data.user, false,nil,{show_flag = true, scale = 1})
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_node", false)
	end

	local title_img = luaBehaviour:FindImage("city_img")
	if title_img then
		LuaBehaviourUtil.setImg(luaBehaviour,"city_img",self.m_model:getCityDataById(data.city_id).build_icon or "","maze_stage_ui")
		--GameUtil:setTextureLoadTitleLanImgText(title_img, title_cfg.icon)
		title_img:SetNativeSize()
	end
	
	local rect = cell_object:GetComponent("RectTransform")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "handle_point_btn", true)
	if (data.city_id == self.m_model.m_cur_select_id)  then
		rect.sizeDelta = Vector2(rect.rect.width, 336)
		local team_loopscroll = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "team_loopscroll", true)
		self:updateTeamScroll(team_loopscroll, data, index)
		--if handle_point_btn then
		--	handle_point_btn.transform.localScale = Vector3(1, -1, 1)
		--end
	else
		rect.sizeDelta = Vector2(rect.rect.width, 148)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "team_loopscroll", false)
		--if handle_point_btn then
		--	handle_point_btn.transform.localScale = Vector3(1, 1, 1)
		--end
	end
end

function M:updateTeamScroll(loopscroll, data, team_id)
	local data = self.m_model:getCurLogsByCityId(data.city_id)
	--if self.m_scroll_view_tab[team_id] == nil then
		local loopscroll = loopscroll
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateTeamScrollViewCell(index, cell_object, cell_data)
			end,
			pull_refresh = function() -- 下拉刷新
				self.last_offsety = self.m_scroll_view_tab[team_id].m_scroll_rect.viewport.rect.height - self.m_scroll_view_tab[team_id].m_scroll_rect.content.rect.height
				self:updateMsg("load_rank")
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {index = index , cell_data = cell_data})
			end
		}
		self.m_scroll_view_tab[team_id] = LoopScrollViewUtil.new(params)
	--else
	--	self.m_scroll_view_tab[team_id]:reloadData(data, true)
	--	 if self.m_control.m_logs_load == true then
	--		self:pullRefreshListOffset(team_id)
	--	 end
	--end
end

function M:pullRefreshListOffset(team_id)
	self.now_offsety = self.m_scroll_view_tab[team_id].m_scroll_rect.viewport.rect.height - self.m_scroll_view_tab[team_id].m_scroll_rect.content.rect.height
	--local position = self.m_list_scroll:getVerticalNormalizedPosition()
	local position = (self.last_offsety - self.now_offsety) / self.m_scroll_view_tab[team_id].m_scroll_rect.content.rect.height
	self.m_scroll_view_tab[team_id]:setVerticalNormalizedPosition(position)
	self.m_control.m_logs_load = false
end

function M:updateTeamScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	Logger.log("-------------------------------------atk:"..tostring(data.atk_user.name))
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local atk_user = data.atk_user
	local def_user = data.def_user
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "self_player_name_text", atk_user.name)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "enemy_player_name_text", def_user.name)
	local is_win = data.win == atk_user.uid and true or false
	LuaBehaviourUtil.setImg(luaBehaviour, "left_result_img", is_win and "a_bh_shengli_zi" or "a_bh_shibai_zi", ResourceUtil:getLanAtlas())
	LuaBehaviourUtil.setImg(luaBehaviour, "right_result_img", not is_win and "a_bh_shengli_zi" or "a_bh_shibai_zi", ResourceUtil:getLanAtlas())
	self:updatePlayerHeadNode(luaBehaviour, atk_user, true)
	self:updatePlayerHeadNode(luaBehaviour, def_user, false)
	for i = 1, 5 do
		local hero_node = luaBehaviour:FindGameObject("hero_node_" .. i)
		local e_hero_node = luaBehaviour:FindGameObject("e_hero_node_" .. i)
		local hero_id = data.atk_team[i] or ""
		if hero_id ~= "" and data.atk_heros[hero_id] then
			local hero_data = data.atk_heros[hero_id]
			self:heroHandle(hero_node, hero_data)
		else
			self:heroHandle(hero_node)
		end

		local ehero_id = data.def_team[i] or ""
		if ehero_id ~= "" and data.def_heros[ehero_id] then
			local hero_data = data.def_heros[ehero_id]
			self:heroHandle(e_hero_node, hero_data)
		else
			self:heroHandle(e_hero_node)
		end
	end
end

function M:updatePlayerHeadNode(luaBehaviour, user_data, is_atk)
	local head_node = is_atk and luaBehaviour:FindGameObject("headnode_self") or luaBehaviour:FindGameObject("headnode_enemy")
	local name_path = is_atk and "self_player_name_text" or "enemy_player_name_text"
	if user_data then
		GameUtil:setUserAvatar(head_node, user_data, false,nil,{show_flag = false, scale = 0.6})
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, name_path, user_data.name)
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, name_path, "player_name_text")
	end
end

function M:heroHandle(obj, hero_data)
	if hero_data then
		local show_data = self.m_model:getShowHeroData(hero_data)
		GameUtil:updateItemElementByData(obj.gameObject,show_data,false,false, callback)
	else
		local ui_element = GameUtil:updateItemElementNoData(obj)
		ui_element.add_img.gameObject:SetActive(false)
	end
end

return M