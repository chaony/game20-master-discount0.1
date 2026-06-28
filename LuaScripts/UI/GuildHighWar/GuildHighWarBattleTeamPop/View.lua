local M = class("GuildHighWarBattleTeamPopView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarBattleTeamPop"
M.m_size_type = 2
--M.m_iphoneXAdapter = true
local __TAB_BTN_NODE = {
	{btn_key = "tog_1",  text_key = "tog_1_text", show_text = "guild_high_war_text_0095" , red_point_img = "race_red_point_img"}, -- 帮会队伍
	{btn_key = "tog_2",  text_key = "tog_2_text", show_text = "guild_high_war_text_0094" , red_point_img = "reward_red_point_img"}, -- 我的队伍
}
local G_CFG = GlobalConfig
function M:onEnter()
	self:setTextByLanKey("title_text1", "guild_high_war_text_0015")
	self:setTextByLanKey("title_text2", "guild_high_war_text_0016")
	self:setTextByLanKey("title_text3", "guild_high_war_text_0017")
	self:setTextByLanKey("formation_edit_btn_text2","guild_high_war_text_00105")
	self:setTextByLanKey("shuo_title_text","guild_high_war_new_0061")
	self:refreshUI()
	self:setTextByLanKey("common_title_text", "guild_high_war_text_0031")
	self.m_toggle_btns ={}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_key, v.show_text)
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
		else
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
		end
		self:setObjectVisible(v.red_point_img, false)
	end
end

function M:switchTabUpdate(is_on, update_key)
	local tog_nod = __TAB_BTN_NODE[update_key]
	if is_on then
		self:updateMsg("check_tag", update_key)
		self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
	else
		self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
	end
end

function M:UpdateCurrentView()
   	self:setObjectVisible("guild_team",self.m_model.m_open_tab_index == 1)
   	self:setObjectVisible("my_team",self.m_model.m_open_tab_index == 2)
	if self.m_model.m_open_tab_index == 2 then
		self:updateLoopScroll()
	end
end


function M:destroy()
	M.super.destroy(self)
end

function M:refreshUI()
	self:updateLeftLoopScroll()
	self:updateRightLoopScroll()
	self:UpdateCurrentView()
	self:UpdataRedPoint()
end

function M:UpdataRedPoint()
	local team_flag = RedPointUtil:hasRedPointById(295)
	self:setObjectVisible("tog_2_red_point_img",team_flag)
end
--[[
	创建列表
]]
function M:updateLeftLoopScroll()
	--local data = {{city_id = 1, city_name = "1", guild_name = "A", is_atk = false, team_nums = {1,2,3}},
	--			  {city_id = 2, city_name = "2", guild_name = "B", is_atk = true, team_nums = {1,2,3}},
	--			  {city_id = 3, city_name = "3", guild_name = "C", is_atk = false, team_nums = {1,2,3}},
	--			  {city_id = 4, city_name = "4", guild_name = "D", is_atk = true, team_nums = {1,2,3}},
	--			  {city_id = 5, city_name = "5", guild_name = "E", is_atk = false, team_nums = {1,2,3}}}--self.m_model.m_heros
	local data = self.m_model.m_city_id_tab
	self:setObjectVisible("common_tips_node", #data == 0)
	self:setObjectVisible("formation_edit_btn2", #data > 0)
	if self.m_left_loopscroll_view == nil then
		local loopscroll = self:findGameObject("left_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateLeftScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "cell"  then
					local city_index = cell_data.city_index
					self:updateMsg("cell", city_index)
				elseif click_name == "hero_node" then
					self:updateMsg("look_hero", cell_data)
				end
			end
		}
		self.m_left_loopscroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_left_loopscroll_view:reloadData(data, true)
	end
end

function M:updateLeftScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", GameUtil:formatValueToString(1))
	local city_index = data.city_index
	local city_data = self.m_model:getCityTeamDataByCityId(city_index)
	if city_data then
		local city_name = self.m_model:getCfgValueByKey(city_data.city_id, "build_name") or ""
		local city_name = city_name
		local guild_name = self.m_model.m_guild_data.name or ""
		local team_nums = city_data.team_num or 0
		local is_atk = data.is_atk
		local icon_name = data.is_atk and "a_bh_czdu_icon_csgj" or "a_bh_czdu_icon_csfy"
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "city_name_text", city_name)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "guild_name_text", is_atk and "guild_high_war_text_0063" or "guild_high_war_text_0029", guild_name)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "team_text", "guild_high_war_text_0030", team_nums)
		local img = LuaBehaviourUtil.setImg(luaBehaviour, "icon_img",icon_name, "pub_ui")
		img:SetNativeSize()
		if self.m_model.m_city_index == nil and index == 1 then
			self.m_model.m_city_index = city_index
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", self.m_model.m_city_index == city_index)
	end
	
end

function M:updateRightLoopScroll()
	local data = self.m_model:getTeamInfoByCityId(self.m_model.m_city_index) or {}
	--local data = self.m_model.m_all_city[self.m_model.m_city_index]
	self:setObjectVisible("common_tips_node", #data == 0)
	--self:setObjectVisible("formation_edit_btn2", #data > 0)
	if self.m_right_loopscroll_view == nil then
		local loopscroll = self:findGameObject("right_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateRightScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "cell" then
					self:updateMsg("cell", cell_data.city_id)
				elseif click_name == "hero_node" then
					self:updateMsg("look_hero", cell_data)
				elseif click_name =="top_button" or click_name =="down_button" then
					self:updateMsg(click_name, {cell_data = cell_data,index =index})
				end
			end,
			pull_refresh = function() -- 下拉刷新
				self.last_offsety1 = self.m_right_loopscroll_view.m_scroll_rect.viewport.rect.height - self.m_right_loopscroll_view.m_scroll_rect.content.rect.height
				self:updateMsg("load_rank")
			end,
		}
		self.m_right_loopscroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_right_loopscroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateRightScrollViewCell(index, cell_object, cell_data)
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local uid = cell_data.uid
	local user_data = self.m_model:getUserDataByUid(uid)
	if user_data then
		local head_node = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "headnode_self", true)
		GameUtil:setUserAvatar(head_node, user_data, false,nil)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name_text", user_data.name)
	end
	local city_data = self.m_model:getCityTeamDataByCityId(self.m_model.m_city_index)
	local is_atk = self.m_model:isAtk(city_data.city_id)
	local data = self.m_model:getTeamInfoByCityId(self.m_model.m_city_index) or {}
	local num = #data
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"top_button",(self.m_model.position == G_CFG.UNION_POS.PRESIDENT or self.m_model.position == G_CFG.UNION_POS.PRESIDENT_VICE) and self.m_model.can_chance == true)
	--LuaBehaviourUtil.setObjectVisible(luaBehaviour,"down_button",(self.m_model.position == G_CFG.UNION_POS.PRESIDENT or self.m_model.position == G_CFG.UNION_POS.PRESIDENT_VICE) and index < num)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"down_button",false)
	--boss 特殊处理 
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"boss_img",cell_data.boss_team == true)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"self_team_node",cell_data.boss_team == false)
	--boss 
	for i = 1, 5 do
		local hero_id = cell_data.team[i]
		local hero_node = luaBehaviour:FindGameObject("hero_node_" .. i)
		if hero_id and hero_id ~= "" then
			local show_hero = cell_data.show_hero[hero_id]
			GameUtil:updateItemElementByData(hero_node.gameObject,show_hero,false,false, callback)
		else
			local ui_element = GameUtil:updateItemElementNoData(hero_node)
			ui_element.add_img.gameObject:SetActive(false)
		end
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "atk_text", is_atk and "guild_high_war_text_0032" or "guild_high_war_text_0033")
	local img =  LuaBehaviourUtil.setImg(luaBehaviour, "atk_img", is_atk and "a_bh_bz_hongdi" or "a_bh_bz_landi", "arena_ui")
	img:SetNativeSize()
end

function M:heroHandle(obj, hero_data)
	local data = hero_data
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
	GameUtil:updateHeroContentByData(obj,data,cfg)
end

---------------------------------我的队伍
function M:updateLoopScroll()
	self.m_sel_cell_index = nil
	local data = self.m_model:getShowData()
	self:setObjectVisible("common_tips_node", #data == 0)
	self:UpdataRedPoint()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {index =index,boss_team = cell_data.boss_team} )
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	----------------------特殊处理怪兽队伍
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "team_node",  true)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "boss_img",  false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "formation_edit_btn",  true)
	------------------特殊处理怪兽队伍
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "upper_num_str_000" .. index)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "formation_edit_btn_text", "new_str_0289")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "recall_btn_text", "UnionWar_str_021")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "go_btn_text", "bounty_str_0013")
	local city_id = self.m_model:getTeamCityId(index)
	local is_out = city_id > 0 and true or false
	local city_name = self.m_model:getCfgValueByKey(city_id, "build_name") or ""
	local real_name = is_out and city_name or "guild_high_war_text_00100"
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "recall_btn",  is_out)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "formation_edit_btn", not is_out)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "go_btn",  not is_out and self.m_model.m_open_type ~= "" )
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "city_text", is_out)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "city_text", false)
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "city_text",  city_name)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "city_left_txt", real_name)
	local icon_name = is_out and self.m_model:getCfgValueByKey(city_id, "build_icon") or "a_jh_dituicon_lan"
	if is_out then
		LuaBehaviourUtil.setImg(luaBehaviour,"city_left_Image",icon_name,"maze_stage_ui")
	else
		LuaBehaviourUtil.setImg(luaBehaviour,"city_left_Image",icon_name,"main_ui")
	end
	------------------特殊处理怪兽队伍
	if data.boss_team == true then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "team_node",  false)
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "recall_btn",  false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "formation_edit_btn",  false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "boss_img",  true)
		return
	end
	------------------特殊处理怪兽队伍
	--local obj = self:findImage("city_left_Image")
	--obj:SetNativeSize() --设置最大
	local team_node = luaBehaviour:FindGameObject("team_node")
	local team_heros_data = data.team_heros_data or {}
	for i = 1, 5 do
		local hero_node = UIUtil.findTrans(team_node.transform, "hero_node_" .. i)
		local item_data = team_heros_data[i]
		if item_data and _G.next(item_data) then
			GameUtil:updateItemElementByData(hero_node.gameObject,item_data,false,false)
		else
			local function callBack()
				self:updateMsg("formation_edit_btn", {index = index})
			end
			local ui_element = GameUtil:updateItemElementNoData(hero_node, nil, nil, callBack)
			ui_element.add_img.gameObject:SetActive(true)
		end
	end
	--LuaBehaviourUtil.setImg(luaBehaviour, "exchange_btn", self.m_model.m_edit_status == 2 and "a_jjc_tiaozheng" or "a_jjc_tiaozheng_1", "arena_ui")

end
-------------------------------我的队伍

return M