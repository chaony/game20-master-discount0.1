local M = class("ArenaRaceRankView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaRace/ArenaRaceRank"
M.m_size_type = 2
local __TAB_BTN_NODE = {
    {match_type = 2, btn_key = "tog_1", text_key = "tog_1_text", show_text = "arena_str_0030" , red_point_img = "race_red_point_img"}, -- 五行
    {match_type = 1, btn_key = "tog_2", text_key = "tog_2_text", show_text = "arena_str_0015" , red_point_img = "race_red_point_img"}, -- 天级
    {match_type = 0, btn_key = "tog_3", text_key = "tog_3_text", show_text = "arena_str_0014" , red_point_img = "reward_red_point_img"}, -- 地级
}

function M:onEnter()
    self:setTextByLanKey("common_title_text", "new_str_0221")
    self:setTextByLanKey("common_no_have_text", "new_str_0351")
    self:setTextByLanKey("rank_label_text", "new_str_0374")
    self:setTextByLanKey("player_label_text", "new_str_0372")
    self:setTextByLanKey("score_label_text", "new_str_0375")
    self:setTextByLanKey("power_label_text", "new_str_0490")
    self.m_toggle_btns = {}
    local tab_btn_node = {}
    if self.m_model.m_open_type == 1 then
        tab_btn_node[1] = __TAB_BTN_NODE[2]
        tab_btn_node[2] = __TAB_BTN_NODE[3]
    elseif  self.m_model.m_open_type == 2 then
        tab_btn_node = __TAB_BTN_NODE
    end
    for k,v in pairs(tab_btn_node) do
        self:setTextByLanKey(v.text_key, v.show_text)
        local tog_btn = self:findToggle(v.btn_key)

        if v.match_type <= self.m_model.m_open_type then
            self.m_toggle_btns[k] = tog_btn
            UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
            if k == self.m_model.m_sel_tab_index then
                tog_btn.isOn = true
                self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
                self:switchTabUpdate(true, k)
            else
                self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
            end
            self:setObjectVisible(v.red_point_img, false)
            self:setObjectVisible(v.btn_key, true)
        else
            self:setObjectVisible(v.btn_key, false)
        end
        
    
    end
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

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getRankData()
    self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("item_click", {id = index, cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local user = data.user or {}
    local rank = data.rank or 0
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    
    local top_three_flag = rank > 0 and rank < 4
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", top_three_flag)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", not top_three_flag)
    local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[rank]
    if top_three_item then
        LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
    end
    if rank < 1 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0076")
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", tostring(rank))
    end  
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", tostring(user.full_combat))
    local score = data.score or 0
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", tostring(score))
    local name_text = nil
    if user.name == nil or user.name == "" then
        name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.uid))
    else
        name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.name))
    end
    local gender = user.gender or 0
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "gender_img", false)
	local gender_cfg_item = GlobalConfig.GENDER_CFG[data.gender]
	if gender_cfg_item then
        --LuaBehaviourUtil.setImg(luaBehaviour, "gender_img", gender_cfg_item.icon, gender_cfg_item.atlas)
	end
    local head_node = luaBehaviour:FindGameObject("head_node")
    GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
    local title_id = user.title
    if title_id and title_id ~= 0 then
        name_text.transform.anchoredPosition = Vector3.New(-30, -12, 0)
    else
        name_text.transform.anchoredPosition = Vector3.New(-30, 0, 0)
    end
end

return M