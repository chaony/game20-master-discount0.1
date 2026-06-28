local M = class("NewYearTeamRankListPopView",LikeOO.OOPopBase)

M.m_uiName = "GiftBag/CelebrateNewYear/NewYearTeamRankListPop"
M.m_size_type = 2

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", text_key = "tog_1_text", show_text = "qi_men_dun_jia_str_016", node = "inside_rank_node" }, -- 个人排行榜
	{btn_key = "tog_2", text_key = "tog_2_text", show_text = "qi_men_dun_jia_str_015", node = "team_rank_node" }, -- 帮会排行榜
	{btn_key = "tog_3", text_key = "tog_3_text", show_text = "new_str_0373", node = "reward_node" }, -- 奖励
}

function M:onEnter()
	self.m_toggle_btns = {}
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
	end
	self:setTextByLanKey("common_title_text", "new_str_0114")
	self:refreshUI()
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

function M:switchNode(index)
    self:refreshUI()
end

--刷新UI
function M:refreshUI()
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setObjectVisible(v.node, k == self.m_model.m_sel_tab_index)
	end
	if self.m_model.m_sel_tab_index == 1 then
		self:updateInsideLoopScroll()
	elseif self.m_model.m_sel_tab_index == 2 then
		self:updateTeamLoopScroll()
	elseif self.m_model.m_sel_tab_index == 3 then
		self:createRewardLoopScroll()
		self:updateMyGuildRankUI()
	end
end

----创建个人排行列表------------------------------------------------------------------------------------------
function M:updateInsideLoopScroll()
	local data = self.m_model:getInsideRanks()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("inside_rank_loopscroll")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateInsideTeam(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
        		self.m_control:openView("Pops.PlayerInfo", {uid = cell_data.user.uid, look_model = 5})
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data)
	end
	local own_data = self.m_model:getInsideMainRank()
	local team_rank_own_info = self:findGameObject("inside_rank_own_info")
	self:updateInsideTeam(team_rank_own_info, own_data, true)
end

function M:updateInsideTeam(cell_object, cell_data, my)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if luaBehaviour then
		if next(cell_data) ~= nil then
			if cell_data.rank <= 3 and cell_data.rank > 0 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", true)
				LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..cell_data.rank, "common_ui")
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			end
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", cell_data.rank or 0)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "all_text", cell_data.score or 0)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", cell_data.daily_score or 0)
			local head_node = luaBehaviour:FindGameObject("head_node")
			GameUtil:setUserAvatar(head_node, cell_data.user,nil,nil,{show_flag = true, scale = 1})
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cell_data.user.name)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "all_text", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
			if my and my == true then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text", "未上榜")
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", UserDataManager.user_data:getUserStatusDataByKey("name"))
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "all_text", "0")
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "0")
				local head_node = luaBehaviour:FindGameObject("head_node")
				local user = UserDataManager.user_data.user_status
				GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
			end
		end 
	end
end


----创建帮会排行列表------------------------------------------------------------------------------------------
function M:updateTeamLoopScroll()
	local data = self.m_model:getTeamRanks()
	if self.m_team_scroll_view == nil then
		local loopscroll = self:findGameObject("rank_loopscroll")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateTeam(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
        		--self.m_control:openView("Pops.PlayerInfo", {uid = cell_data.user.uid, look_model = 5})
			end
		}
		self.m_team_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_team_scroll_view:reloadData(data)
	end
	local own_data = self.m_model:getTeamsMainRank()
	local team_rank_own_info = self:findGameObject("team_rank_own_info")
	if own_data then
		self:updateTeam(team_rank_own_info, own_data, true)
		self:setObjectVisible("m_team_obj", true)
	else
		self:setObjectVisible("m_team_obj", false)	
	end
end

function M:updateTeam(cell_object, cell_data, my)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if luaBehaviour then
		if next(cell_data) ~= nil then
			if cell_data.rank <= 3 and cell_data.rank > 0 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", true)
				LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..cell_data.rank, "common_ui")
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			end
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", cell_data.rank)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cell_data.user.name)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_text", cell_data.score)
			local server_name = UserDataManager.server_data:getServerNameById(cell_data.user.server)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_server_text", server_name)
			local union_cfg = ConfigManager:getCfgByName("guild_flag")[cell_data.user.flag]
			if union_cfg then
				local icon_img = luaBehaviour:FindGameObject("icon_img")
				GameUtil:updateResourcesImg(icon_img, "Texture/union_emblem/" .. union_cfg.icon)
			end
			if my and my == true and cell_data.rank == 0  then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text", "未上榜")
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_rank_text", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", UserDataManager.user_data:getUserStatusDataByKey("guild_name"))
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_server_text",  UserDataManager.server_data:getServerName())
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_text", "0")
				local flag =  UserDataManager.user_data:getUserStatusDataByKey("flag")
				local union_cfg = ConfigManager:getCfgByName("guild_flag")[flag]
				if union_cfg then
					local icon_img = luaBehaviour:FindGameObject("icon_img")
					GameUtil:updateResourcesImg(icon_img, "Texture/union_emblem/" .. union_cfg.icon)
				end
			end
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
			if my and my == true then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text", "未上榜")
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", UserDataManager.user_data:getUserStatusDataByKey("guild_name"))
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_text", "0")
			end
		end 
	end
end


----创建奖励列表------------------------------------------------------------------------------------------
function M:createRewardLoopScroll()
    local data = self.m_model.ranks_rewards
    if self.m_scroll_view2 == nil then
        local loopscroll = self:findGameObject("reward_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateRewardItem(cell_obj, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
        
            end
        }
        self.m_scroll_view2 = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view2:reloadData(data)
    end
end

function M:updateRewardItem(obj, index, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", index <= 3) 
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", index > 3) 
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", index > 3) 
        if index <= 3 then
            LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..index, "common_ui")
        else
            local rank_str = data.rank
			if data.last_rank and data.last_rank < data.rank then
				rank_str = data.last_rank .."-"..data.rank
			end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", rank_str)
        end
        local all_reward_node = luaBehaviour:FindGameObject("all_reward")
		local person_reward_node = luaBehaviour:FindGameObject("person_reward")
		local person_reward_node2 = luaBehaviour:FindGameObject("person_reward2")
		local person_reward_node3 = luaBehaviour:FindGameObject("person_reward3")
        GameUtil:createRewards(all_reward_node.transform, data.data.rank_reward, true, true)
		if not IsNull(person_reward_node) then
			if data.data.person_rewards[1] then
				GameUtil:createRewards(person_reward_node.transform, data.data.person_rewards[1], true, true)
			else
				UIUtil.destroyAllChild(person_reward_node.transform)
			end
		end
		if not IsNull(person_reward_node2) then
			if data.data.person_rewards[2] then
				GameUtil:createRewards(person_reward_node2.transform, data.data.person_rewards[2], true, true)
			else
				UIUtil.destroyAllChild(person_reward_node2.transform)
			end
		end
		if not IsNull(person_reward_node3) then
			if data.data.person_rewards[3] then
				GameUtil:createRewards(person_reward_node3.transform, data.data.person_rewards[3], true, true)
			else
				UIUtil.destroyAllChild(person_reward_node3.transform)
			end
		end
    end    
end

function M:updateMyGuildRankUI()
	local rank = self.m_model:getMGuildRank()
	local guild_name = UserDataManager.user_data:getUserStatusDataByKey("guild_name")
	self:setTextByLanKey("reward_own_union_name_text", guild_name)
	if rank == 0 then
		self:setTextByLanKey("reward_own_union_rank_text", "gf_str_0068")
	else
		self:setTextByLanKey("reward_own_union_rank_text", "gf_str_0076", rank)
	end
end


return M