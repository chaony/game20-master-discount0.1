local M = class("UnionWarRewardPopView",LikeOO.OOPopBase)

M.m_uiName = "UnionWar/UnionWarRewardPop"
M.m_size_type = 2


local __SETTLEMENT_TAB = {
    {btn_key = "toggle_1", btn_text = "toggle_1_text", text_key = "UnionWar_str_060" }, --规则说明
    {btn_key = "toggle_2", btn_text = "toggle_2_text", text_key = "UnionWar_str_062"  }, --回合奖励
    {btn_key = "toggle_3", btn_text = "toggle_3_text", text_key = "UnionWar_str_063"  }, --赛季奖励
    --{btn_key = "toggle_4", btn_text = "toggle_4_text", text_key = "UnionWar_str_060"  }, --
}

function M:onEnter()
    self.m_toggle_btns = {}
    self.m_reward_loopscroll_cache = {}
    self:setTextByLanKey("common_title_text", "UnionWar_str_064")
    self:setTextByLanKey("day_title", "UnionWar_str_065")
    self:setTextByLanKey("day_title2", "UnionWar_str_067")
    self:setTextByLanKey("day_title3", "UnionWar_str_068")
    self:setTextByLanKey("day_title4", "UnionWar_str_069")
    self:setTextByLanKey("day_text", "UnionWar_str_066")
    self:setTextByLanKey("bout_win", "UnionWar_str_072")
    self:setTextByLanKey("bout_loser", "UnionWar_str_073")
    self:setTextByLanKey("bout_title", "UnionWar_str_074")
    self:setTextByLanKey("bout_title2", "UnionWar_str_075")
    self:setTextByLanKey("bout_title3", "UnionWar_str_074")
    self:setTextByLanKey("bout_title4", "UnionWar_str_075")
    self.toggle_group = self:findGameObject("toggle_group")
    self.toggle_group:SetActive(self.m_model.m_params.isActive_num == nil)
    for k,v in pairs(__SETTLEMENT_TAB) do
		self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_sel_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end, nil, self.m_uiName)
        local season_reward_display = self.m_model:getSeasonRewardIsDisPlay()
        if v.btn_key == "toggle_3" and not season_reward_display then
            tog_btn.gameObject:SetActive(false)
        end
	end
    self:switchTabNode(self.m_model.m_sel_tab_index)
end

function M:switchTabUpdate(is_on, update_key)
    if is_on then
		self:updateMsg(update_key)
	end
end

function M:switchTabNode(index)
    self:setObjectVisible("day_node", false)
    self:setObjectVisible("bout_node", false)
    self:setObjectVisible("season_node", false)
    self:setObjectVisible("explain_node", false)
    for k,v in pairs(__SETTLEMENT_TAB) do
        local tog_text = self:findText(v.btn_text)
        if k == self.m_model.m_sel_tab_index then 
        	tog_text.color = GlobalConfig.COMMON_COLLOR.COMMON_25
        else
            tog_text.color = GlobalConfig.COMMON_COLLOR.COMMON_24
        end
    end
    if index == 1 then
        self:setObjectVisible("explain_node", true)
    elseif index == 2 then
        self:setObjectVisible("bout_node", true)
    elseif index == 3 then
        self:setObjectVisible("season_node", true)
    elseif index == 4 then
        self:setObjectVisible("explain_node", true)
    end
    self:refreshUI()
end

function M:refreshUI()
    --if self.m_model.m_sel_tab_index == 1 then
    --    local day_rewards = self:findGameObject("day_rewards")
    --    local day_rewards_2 = self:findGameObject("day_rewards_2")
    --    local day_rewards_3 = self:findGameObject("day_rewards_3")
    --    local huoyue_reward, kill_reward, max_reward = self.m_model:getDayReward()
    --    GameUtil:createRewards(day_rewards.transform, huoyue_reward, true, true)
    --    GameUtil:createRewards(day_rewards_2.transform, kill_reward, true, true)
    --    GameUtil:createRewards(day_rewards_3.transform, max_reward, true, true)
    --end

    if self.m_model.m_sel_tab_index == 2 then
        local bout_rewards_1 = self:findGameObject("bout_rewards_1")
        local bout_rewards_2 = self:findGameObject("bout_rewards_2")
        local bout_rewards_3 = self:findGameObject("bout_rewards_3")
        local bout_rewards_4 = self:findGameObject("bout_rewards_4")
        local win_union_reward, win_per_reward, lose_union_reward,lose_per_reward = self.m_model:getBoutReward()
        GameUtil:createRewards(bout_rewards_1.transform, win_union_reward, true, true)
        GameUtil:createRewards(bout_rewards_2.transform, win_per_reward, true, true)
        GameUtil:createRewards(bout_rewards_3.transform, lose_union_reward, true, true)
        GameUtil:createRewards(bout_rewards_4.transform, lose_per_reward, true, true)
    end

    if self.m_model.m_sel_tab_index == 3 then
        self:updateLoopScroll()
    end
    
    if self.m_model.m_sel_tab_index == 1 then
        local str = string.gsub(Language:getTextByKey("tid#GuildWar_1" or "???"), "\\n", "\n")
        self:setText("des_text",str)
    end
end



--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getRankRewards()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {id = index , team_id = cell_data.team_id, cell_data = cell_data})
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    if luaBehaviour then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_union_get", "UnionWar_str_070")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_person_get", "UnionWar_str_071")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_img", index <= 3)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_num", index > 3) 
        if index <= 3 then
            LuaBehaviourUtil.setImg(luaBehaviour, "rank_img", "a_phb_icon_"..index, "common_ui")
        else
            local rank_str = cell_data.id
            if cell_data.id > 10 then
                local last_rank = self.m_model:getRankScope(index)
                if index == self.m_model.rank_rewards then
                    rank_str = last_rank..Language:getTextByKey("world_boss_str_0031")
                else
                    rank_str = last_rank.."-"..cell_data.id
                end
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_num", rank_str)
        end
        local season_reward_1 = luaBehaviour:FindGameObject("season_reward_1")
        GameUtil:createRewards(season_reward_1.transform, cell_data.guild_season_rewards, true, true)
        --local season_reward_2 = luaBehaviour:FindGameObject("season_reward_2")
        --GameUtil:createRewards(season_reward_2.transform, cell_data.season_rewards, true, true)
        local season_reward_2_loopscroll = luaBehaviour:FindGameObject("reward_loopscroll")
        self:updateRewardLoopScroll(index, season_reward_2_loopscroll, cell_data.season_rewards)
    end  
end

function M:updateRewardLoopScroll(reward_index, loopscroll_obj, reward_data)
    local loop_scroll_key = tostring(loopscroll_obj)
    if self.m_reward_loopscroll_cache[loop_scroll_key] == nil then
        local params = {
            show_data = reward_data,
            one_line_count = 1,
            loop_scroll_object = loopscroll_obj,
            update_cell = function(index, cell_object, cell_data)
                local item_data = RewardUtil:getProcessRewardData(cell_data)
                GameUtil:updateItemElementByData(cell_object, item_data, true, true)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)

            end
        }
        self.m_reward_loopscroll_cache[loop_scroll_key] = LoopScrollViewUtil.new(params)
    else
        self.m_reward_loopscroll_cache[loop_scroll_key]:reloadData(reward_data)
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M