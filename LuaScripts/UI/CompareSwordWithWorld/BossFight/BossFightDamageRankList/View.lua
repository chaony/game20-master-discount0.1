local M = class("BossFightDamageRankListView",LikeOO.OOPopBase)

M.m_uiName = "CompareSwordWithWorld/BossFight/BossFightDamageRankList"
M.m_size_type = 2

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1",  text_key = "tog_1_text", show_text = "game_of_heaven_and_earth_reward_text_007" , red_point_img = "race_red_point_img" , battle_id = 0}, -- 总伤害榜
	{btn_key = "tog_2",  text_key = "tog_2_text", show_text = "game_of_heaven_and_earth_reward_text_008" , red_point_img = "reward_red_point_img", battle_id = 0}, -- boss 
}

function M:onEnter()
	--__TAB_BTN_NODE[2].show_text = self.m_model.m_params.selectData.name  --设置tab页名称
	__TAB_BTN_NODE[2].battle_id = self.m_model.m_params.selectData.battle_id --
	
    self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_key, v.show_text)
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTab_onClick(is_on, k) end,nil,self.m_uiName)
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
		else
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
		end
		self:setObjectVisible(v.red_point_img, false)
	end
	self:setTextByLanKey("rank_label_text", "new_str_0374")	--排名
	self:setTextByLanKey("common_title_text", "new_str_0114")	--标题
	self:setTextByLanKey("own_rank_title_text", "new_str_0077")

	self.m_own_info_node = self:findGameObject("own_info_node")
	local lua_own_info_node = UIUtil.findLuaBehaviour(self.m_own_info_node)
	self.m_own_info_prefab = lua_own_info_node:FindGameObject("RankListItem").transform
	
    self.m_reward_red_point_img = self:findGameObject("tog_2_red_point_img") --Unused
	self:switchNode()  --设置默认打开的页签
end

function M:switchTab_onClick(is_on, update_key)  --切换页签调用
	local tog_nod = __TAB_BTN_NODE[update_key]
	if is_on then
		self:updateMsg("check_tag", update_key )
		self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
	else
		self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
	end
end

function M:switchTab()
	self:refreshUI()
end

function M:switchNode()		--切换节点
	self:setTextByLanKey("player_label_text", "new_str_0372")
	self:setTextByLanKey("lv_label_text", "new_str_0436")
	self:setTextByLanKey("score_label_text", "guild_high_war_text_0025")
	self:setObjectVisible("power_label_text", true)
	self:setObjectVisible("gang_label_text", true)
	self:setObjectVisible("gang_label_text", true)
	self:setTextByLanKey("power_label_text", "new_str_0490")
	self:setTextByLanKey("gang_label_text", "new_str_0444")
    self:refreshUI()
end

function M:refreshUI()
	local data = self.m_model:getOwnFightRankData()  --todo : 获取自己的排行榜数据
	self:updateItemInfo(self.m_own_info_prefab, data , data.rank)
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getRankData()
	self:setObjectVisible("CommonTipsNode", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "btn_check_formation" then
					self:updateMsg("check_formation",{id = index , open_tab_index = 2})
				else
					self:updateMsg("check_formation", {id = index , open_tab_index = 3})
				end
			end,
			pull_refresh = function() -- 下拉刷新
				self.last_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
				self:updateMsg("load_rank")
			end,
            ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
		if self.m_control.m_mail_load == true then
			self:pullRefreshListOffset()
		end
	end
end

function M:pullRefreshListOffset()
	self.now_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	local position = (self.last_offsety - self.now_offsety) / self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	self.m_loop_scroll_view:setVerticalNormalizedPosition(position)
	self.m_control.m_mail_load = false
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
	self:updateItemInfo(cell_object, data, index)
end

function M:updateRankIcon(id, transform, rank, luaBehaviour)
	if id  and id ~= 0 then
		local top_three_flag = id < 4
		UIUtil.setObjectVisible(transform, top_three_flag, "top_three_rank_img")
		UIUtil.setObjectVisible(transform, not top_three_flag, "rank_text")
		local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[id]
		if top_three_item then
			LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
		end
		for i = 1,3 do
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Ui_Rank_Bang_00"..i, i==id)
		end
		UIUtil.setText(transform, tostring(rank), "rank_text")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg",not top_three_flag)
	else
		UIUtil.setObjectVisible(transform, false, "top_three_rank_img")
		UIUtil.setObjectVisible(transform, true, "rank_text")
		if rank < 1 then
			UIUtil.setTextByLanKey(transform, "none_rank_text", "new_str_0076")
			UIUtil.setTextByLanKey(transform, "rank_text", "new_str_0076")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", true)
		else
			UIUtil.setTextByLanKey(transform, "none_rank_text", "")
			UIUtil.setText(transform, tostring(rank), "rank_text")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", true)
		end
	end
end

function M:updateItemInfo(obj, data, id)
    local user = data.user or {}
    local rank = data.rank or 0
    local score = data.score or 0
	local server_name = data.user.server_name or ""
    local transform = obj.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	self:updateRankIcon(id, transform, rank, luaBehaviour)

	local name_text = nil
    if user.name == nil or user.name == "" then
		name_text = UIUtil.setText(transform, tostring(user.uid), "name_text")
    else
		name_text = UIUtil.setText(transform, tostring(user.name), "name_text")
    end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_check_formation", self.m_model.m_cur_tab_index ~= 1)
	local head_node = luaBehaviour:FindGameObject("head_node") --获取头像
	GameUtil:setUserAvatar(head_node, user, false, false, {show_flag = true, scale = 1})
	local btn_check_formation = luaBehaviour:FindGameObject("btn_check_formation")
	--btn_check_formation:SetActive(self.m_model.m_cur_tab_index ~= 0)
	local txt_score = GameUtil:formatValueToString(score)
	UIUtil.setText(transform, txt_score, "damage_text")
	UIUtil.setText(transform, server_name, "server_name_text")
	
    local gender = user.flag or 0
	local flag_cfg = ConfigManager:getCfgByName("guild_flag")[gender]
	if flag_cfg then
		local union_icon_img = luaBehaviour:FindImage("gender_img")
		GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
	end
	UIUtil.setObjectVisible(transform, gender > 0 and flag_cfg, "gender_img")

end

function M:updateItemInfo1(obj, data, id)
	local user = data.user or {}
	local rank = data.rank or 0
	local score = data.score or 0
	local transform = obj.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	self:updateRankIcon(id, transform, rank, luaBehaviour)
	local name_text = nil
	if user.name == nil or user.name == "" then
		name_text = UIUtil.setText(transform, tostring(user.uid), "name_text")
	else
		name_text = UIUtil.setText(transform, tostring(user.name), "name_text")
	end
	
	UIUtil.setText(transform, tostring(score), "race_score_text")
	UIUtil.setObjectVisible(transform,true,"power_text")
	UIUtil.setObjectVisible(transform,true,"gang_text")
	UIUtil.setObjectVisible(transform,false,"level_text")
	UIUtil.setText(transform, tostring(GameUtil:formatValueToString(user.full_combat or 0)), "power_text")
	UIUtil.setText(transform, tostring(user.guild_name or ""), "gang_text")
	local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, user, false, false, {show_flag = true, scale = 1})
	local title_id = user.title
	if title_id and title_id ~= 0 then
		name_text.transform.anchoredPosition = Vector3.New(-90, -15, 0)
	else
		name_text.transform.anchoredPosition = Vector3.New(-90, 0, 0)
	end
end


return M