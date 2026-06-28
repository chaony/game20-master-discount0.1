local M = class("PeakArenaRankListPopView",LikeOO.OOPopBase)

M.m_uiName = "PeakArena/PeakArenaRankListPop"
M.m_size_type = 2

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", text_key = "tog_1_text", show_text = "new_str_0235" }, -- 排行榜
	{btn_key = "tog_2", text_key = "tog_2_text", show_text = "new_str_0373" }, -- 奖励
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
	self:setTextByLanKey("score_label_text", "scjf_text")
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
    self:setObjectVisible("RankListNode", index == 1)
    self:setObjectVisible("RewardNode", index == 2)
    self:refreshUI()
	self:setObjectVisible("tog_lock", self.m_model.m_open_type == false)
end

--刷新UI
function M:refreshUI()
	if self.m_model.m_sel_tab_index == 1 then
		self:updateLoopScroll()
		local own_info = self:findGameObject("own_info")
		self:updateTeam(own_info, self.m_model:myRanks(), true)
	else
		self:createRewardLoopScroll()
	end
end
----创建排行列表------------------------------------------------------------------------------------------
function M:updateLoopScroll()
	local data = self.m_model:getRanks()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateTeam(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
        		self.m_control:openView("Pops.PlayerInfo", {uid = cell_data.user.uid, look_model = 5})
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data)
	end
end

function M:updateTeam(cell_object, cell_data, my)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if luaBehaviour then
		if next(cell_data) ~= nil then
			if cell_data.rank <= 3 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", true)
				LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..cell_data.rank, "common_ui")
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			end
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", cell_data.rank)
			local head_node = luaBehaviour:FindGameObject("head_node")
			GameUtil:setUserAvatar(head_node, cell_data.user,nil,nil,{show_flag = true, scale = 1})
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cell_data.user.name)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "level_text", cell_data.user.level)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", cell_data.score)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
			if my and my == true then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text", "未上榜")
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", UserDataManager.user_data:getUserStatusDataByKey("name"))
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "level_text", UserDataManager.user_data:getUserStatusDataByKey("level"))
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", "0")
				local head_node = luaBehaviour:FindGameObject("head_node")
				local user = UserDataManager.user_data.user_status
				GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
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
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_img", index <= 3) 
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", index > 3) 
        if index <= 3 then
            LuaBehaviourUtil.setImg(luaBehaviour, "rank_img", "a_phb_icon_"..index, "common_ui")
        else
            local rank_str = data.id
            if data.id > 3 then
                if index == #self.m_model.ranks_rewards then
                    rank_str = data.rank[1]..Language:getTextByKey("world_boss_str_0031")
                else
                    rank_str = data.rank[1] .."-"..data.rank[2]
                end
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", rank_str)
        end
        local reward_node = luaBehaviour:FindGameObject("reward_node")
        GameUtil:createRewards(reward_node.transform, data.reward, true, true)
    end    
end

return M