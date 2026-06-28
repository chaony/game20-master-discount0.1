local M = class("commonGachaTrainRankListView", LikeOO.OOPopBase)
--排行奖励

M.m_uiName = "commonActive/commonGachaTrainRankList"
M.m_size_type = 2

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", text_key = "tog_1_text", show_text = "new_str_0235" }, -- 排行
	{btn_key = "tog_2", text_key = "tog_2_text", show_text = "new_str_0373" }, -- 奖励
}

function M:onEnter()
    if self.m_model.m_data.update then
		--self:updateMsg("update_data", self.m_model.m_data, "Activities.WorldBoss.HeroBossTrainPop")
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
        self:updateMsg(99999)
	end
    for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_key, v.show_text)
		local tog_btn = self:findToggle(v.btn_key)
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		if k == self.m_model.m_select_index then
			tog_btn.isOn = true
		end
	end
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
        self:setTextByLanKey("common_title_text", "new_str_0235")
	else
		self:updateRewardListUI()
        self:setTextByLanKey("common_title_text", "new_str_0373")
	end
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
                LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..num, "common_ui")
            end
        elseif index <= 3 then
            LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..index, "common_ui")
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", index)
        end
        local head_node = luaBehaviour:FindGameObject("head_node")
        if my_bl == true then
            GameUtil:setUserAvatar(head_node, UserDataManager.user_data.user_status, false, false,{show_flag = true, scale = 1})
            local server_name = UserDataManager.server_data:getServerName()
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", UserDataManager.user_data:getUserStatusDataByKey("name"))
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_text", server_name)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", GameUtil:formatValueToString(self.m_model:getMyScore()))
        else 
            local server_data = UserDataManager.server_data:getServerDataById(data.user.server)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", data.user.name)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_text", server_data.server_name)    
            GameUtil:setUserAvatar(head_node, data.user, false, false,{show_flag = true, scale = 1})
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", GameUtil:formatValueToString(data.score))
            local battle_id = data.battle_id or 0
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "battle_log_btn", battle_id > 0)
        end
    end    
end


function M:updateRewardListUI()
    local sort, num = self.m_model:getMyRank()
    if sort ~= 0 and num > 0 then
        if sort == 1 then
            self:setTextByLanKey("my_rank_num", "gf_str_0076", num)  
        else
            self:setTextByLanKey("my_rank_num", "gf_str_0077", GameUtil:formatNum(num*100))  
        end
    else
        self:setTextByLanKey("my_rank_num", "new_str_0076")    
    end
	self:createRewardLoopScroll()
end

--[[
    创建奖励列表
]]
function M:createRewardLoopScroll()
    local data = self.m_model.rank_rewards
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
                local last_rank_1,last_rank_2 = self.m_model:getRankScope(index)
                if index == #self.m_model.rank_rewards then
                    rank_str = last_rank_1..Language:getTextByKey("world_boss_str_0031")
                else
                    rank_str = last_rank_1.."-"..last_rank_2
                end
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", rank_str)
        end
        local reward_node = luaBehaviour:FindGameObject("reward_node")
        GameUtil:createRewards(reward_node.transform, data.rank_rewards, true, true)
    end    
end

return M