local M = class("ThreeHeroesFiveGallantsChivalrousPopView", LikeOO.OOPopBase)
--排行奖励

M.m_uiName = "ThreeHeroesFiveGallants/ThreeHeroesFiveGallantsChivalrousPop"
M.m_size_type = 2

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", text_key = "tog_1_text", show_text = "flower_text_0009" }, -- 个人榜
	{btn_key = "tog_2", text_key = "tog_2_text", show_text = "three_heroes_five_gallants_text_0011" }, -- 势力榜
}

function M:onEnter()
    for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_key, v.show_text)
		local tog_btn = self:findToggle(v.btn_key)
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		if k == self.m_model.m_select_index then
			tog_btn.isOn = true
		end
	end
    self:setShowText()
	self:refreshUI()
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg("check_tag", update_key)
	end
end

function M:refreshUI()
	self:setObjectVisible("RankListNode", self.m_model.m_select_index == 1)
	self:setObjectVisible("RewardNode", self.m_model.m_select_index == 2)
	if self.m_model.m_select_index == 1 then
		self:updateRankListUI()
	else
		self:updateRewardListUI()
	end
    self:setTextByLanKey("common_title_text", __TAB_BTN_NODE[self.m_model.m_select_index].show_text)

    self:setTextByLanKey("mouse_chivalrous_value",self.m_model:getCampRanks(1)) --鼠阵营总侠义
    self:setTextByLanKey("cat_chivalrous_value",self.m_model:getCampRanks(2)) --猫阵营总侠义
end

function M:updateRankListUI()
	self:createLoopScroll()
    local own_info_Item = self:findGameObject("own_info_Item")
    self:updateRankItem(own_info_Item, 0, nil, true) 
end

--[[
    创建排行列表
]]
function M:createLoopScroll()
    local data = self.m_model:getRanks()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateRankItem(cell_obj, index, cell_data, false)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {index = index, cell_data = cell_data})
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateRankItem(obj, index, data, my_bl)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", index <= 3) 
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", index > 3)
        local rewards_node_content = luaBehaviour:FindGameObject("rewards_node_content")
        if my_bl == true then
            local sort, num = self.m_model:getMyRank()
            if sort == 0 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false) 
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_rank_text", true)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text", "new_str_0076")
            elseif num < 1 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false) 
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_rank_text", true)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text", "new_str_0076")
            else 
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_rank_text", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img",  num >=1 and num <= 3) 
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", num > 3 or num < 1) 
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", num)
                local rewards = self.m_model:getRankReward(num)
                GameUtil:createRewards(rewards_node_content.transform, rewards, true, true)
                LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..num, "common_ui")
            end
        elseif index <= 3 then
            LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..index, "common_ui")
            local rewards = self.m_model:getRankReward(index)
            GameUtil:createRewards(rewards_node_content.transform, rewards, true, true)
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", index)
            local rewards = self.m_model:getRankReward(index)
            GameUtil:createRewards(rewards_node_content.transform, rewards, true, true)
        end
        local head_node = luaBehaviour:FindGameObject("head_node")
        if my_bl == true then
            GameUtil:setUserAvatar(head_node, UserDataManager.user_data.user_status, false, false,{show_flag = true, scale = 1})
            local server_name = self.m_model.m_data.self_score
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", UserDataManager.user_data:getUserStatusDataByKey("name"))
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_text", server_name)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", GameUtil:formatValueToString(self.m_model:getMyScore()))
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", data.user.name)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_text", data.score)    
            GameUtil:setUserAvatar(head_node, data.user, false, false,{show_flag = true, scale = 1})
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", GameUtil:formatValueToString(data.rank))
            local battle_id = data.battle_id or 0
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "battle_log_btn", battle_id > 0)
        end
    end    
end


--[[
    创建奖励列表
]]
function M:updateRewardListUI()
    local data = self.m_model:getCampRewards()
    local reward_node = self:findGameObject("reward_node")
    if reward_node then
        GameUtil:createRewards(reward_node.transform, data.reward, true, true)
    end
end

--设置显示的文字内容
function M:setShowText()
    self:setTextByLanKey("mouse_nane","three_heroes_five_gallants_text_0015")
    self:setTextByLanKey("cat_nane","three_heroes_five_gallants_text_0016")
    self:setTextByLanKey("cat_chivalrous_title","three_heroes_five_gallants_text_0017")
    self:setTextByLanKey("mouse_chivalrous_title","three_heroes_five_gallants_text_0017")
    self:setTextByLanKey("reward_tips","three_heroes_five_gallants_text_0018")
    self:setTextByLanKey("rank_label_text","new_str_0235")
    self:setTextByLanKey("player_label_text","player_bal_tex")
    self:setTextByLanKey("server_name_text","three_heroes_five_gallants_text_0019") --侠义值
    self:setTextByLanKey("score_label_text","gu_jian_qi_tan_str_051") --结算奖励
    self:setTextByLanKey("own_rank_title_text","new_str_1104") 
end

return M