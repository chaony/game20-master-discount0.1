local M = class("MythArenaMainView",LikeOO.OOPopBase)

M.m_uiName = "MythArena/MythArenaMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 35})
	self:setTextByLanKey("rank_des_text", "wlsh_text_0002")
	self:setTextByLanKey("refresh_btn_text", "union_str_1035")
	self:setTextByLanKey("close_title_text", "wlsh_text_0004")
	self:refreshUI()

	--UserDataManager:removeRedDotByKey("high_arena")
end

function M:refreshUI()
	self:updateListScroll()
	self:updateSelfData()
	self:refreshRedPoint()
	
end

function M:updateActivityTimer()
	local end_ts = self.m_model:getEndTs()
	if end_ts >= 0 then
		local text = GameUtil:formatTimeBySecond(end_ts, 999)
		self:setTextByLanKey("rank_time_text", "wlsh_text_0003", text)
	else
		self:updateMsg("stage_end")
	end
end

function M:refreshRedPoint()
	self:setObjectVisible("rank_btn_red_point", false)
end

function M:updateListScroll()
	local data = self.m_model:getListData()
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index, cell_data)
			end,
			ui_name = self.m_uiName,
			--pull_refresh = function() -- 下拉刷新
			--	self.last_offsety = self.m_list_scroll.m_scroll_rect.viewport.rect.height - self.m_list_scroll.m_scroll_rect.content.rect.height
			--	self:updateMsg("load_rank")
			--end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
		--if self.m_control.m_mail_load == true then
		--	self:pullRefreshListOffset()
		--end
	end
end

local icon_bg_name = {"a_bangdan_yi", "a_bangdan_er", "a_bangdan_san", "a_phb_putong_di"}
function M:listHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local HeadNode = luaBehaviour:FindGameObject("head_node")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text",  (tostring(data.rank < 4 and "" or data.rank)))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "battle_btn_text",  data.quick_pass == 1 and "new_str_0811" or "new_str_0291")
	local name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", Language:getTextByKey(data.user.name))
	local power_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_text",  Language:getTextByKey("openServerRank_str_0008", GameUtil:formatValueToString(data.user.full_combat)))
	GameUtil:setUserAvatar(HeadNode,data.user,nil,nil,{show_flag = true, scale = 1.05})
	local title_id = data.user.title
	if title_id and title_id ~= 0 then
		name_text.transform.anchoredPosition = Vector3.New(-188.63, -19.6, 0)
		--server_name_text.transform.anchoredPosition = Vector3.New(56.722, -3, 0)
		--power_text.transform.anchoredPosition = Vector3.New(17, -1.5, 0)
	else
		name_text.transform.anchoredPosition = Vector3.New(-188.63, -1.5, 0)
		--server_name_text.transform.anchoredPosition = Vector3.New(56.722, 12, 0)
		--power_text.transform.anchoredPosition = Vector3.New(17, -1.5, 0)
	end
	local rank_bg_name = ""
	if data.rank > 3 or data.rank == 0 then
		rank_bg_name = icon_bg_name[4]
		LuaBehaviourUtil.setImg(luaBehaviour, "rank_bg_img", rank_bg_name, "common_ui")
	else
		rank_bg_name = icon_bg_name[data.rank]
		LuaBehaviourUtil.setImg(luaBehaviour, "rank_bg_img", rank_bg_name, "mystic_ui")
	end
	--local server_name_text = luaBehaviour:FindText("server_name_text")
	--local server_name = ""
	--if tonumber(data.user.server) == 0 then
	--	server_name = UserDataManager.server_data:getServerName()
	--else
	--	server_name = UserDataManager.server_data:getServerNameById(data.user.server)
	--end
	--server_name_text.text = "[" .. server_name .. "]"
end

function M:updateSelfData()
	local user_data = UserDataManager.user_data.user_status
	local combat = self.m_model.m_data.combat or UserDataManager.user_data:getUserStatusDataByKey("full_combat")
	--加载spine动画
	local hero = self:findGameObject("hero_sk1")
	local ply_cfg = ConfigManager:getPlayerPictureCfg(user_data.avatar)
	GameUtil:updateSpineLoadSet(hero, "RoleSpine/" .. tostring(ply_cfg.hero_spine), "idle", 0, true)
	local rank = self.m_model.m_data.rank or 0
	self:setTextByLanKey("my_rank_text", "dragonsword_text_0011", tostring(self.m_model.m_data.rank) )
	self:setTextByLanKey("my_combat_text", "new_str_0930", GameUtil:formatValueToString(combat) )
	self:setTextByLanKey("reward_text", "wlsh_text_0001" )
	local rewards_node = self:findGameObject("rewards_node")
	local reward_datas = self.m_model:getRankRewardByRank(self.m_model.m_data.rank)
	GameUtil:createRewards(rewards_node.transform, reward_datas, true, true, nil, 0.85)

end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M