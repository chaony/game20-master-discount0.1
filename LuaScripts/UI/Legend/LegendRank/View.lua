local M = class("LegendRankView",LikeOO.OOPopBase)

M.m_uiName = "Legend/LegendRank"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", self.m_model.m_stage_cfg.name)
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	self:setTextByLanKey("rank_label_text", "new_str_0374")
	self:setTextByLanKey("player_label_text", "new_str_0372")
	self:setTextByLanKey("level_label_text", "legend_str_016")
	--self:setTextByLanKey("title_text", "new_str_0270")
	self:refreshUI()
end

function M:refreshUI()
	if self.m_model.m_stage_cfg.type == 1 then
		self:setTextByLanKey("score_label_text", "legend_str_012")
	elseif self.m_model.m_stage_cfg.type == 2 then
		self:setTextByLanKey("score_label_text", "legend_str_013")
	end
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getRankData()
	self:setObjectVisible("common_tips_node", #data == 0)
	self:setObjectVisible("label_content", #data > 0)
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
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", not top_three_flag)
	local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[rank]
	if top_three_item then
		LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
	end
    if rank < 1 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0076")
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", tostring(rank))
    end  
    local power_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "power_text", tostring(user.full_combat))
	local power_title_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "power_title_text", "friend_str_0041")
	
	local name_text = nil
    if user.name == nil or user.name == "" then
		name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.uid))
    else
		name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.name))
    end
    local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
	local title_id = user.title
	if title_id and title_id ~= 0 then
		name_text.transform.anchoredPosition = Vector3.New(42,0,0)
		power_text.transform.anchoredPosition = Vector3.New(35,-28,0)
		power_title_text.transform.anchoredPosition = Vector3.New(-132,-28,0)
	else
		name_text.transform.anchoredPosition = Vector3.New(42,16,0)
		power_text.transform.anchoredPosition = Vector3.New(35,-22,0)
		power_title_text.transform.anchoredPosition = Vector3.New(-132,-22,0)
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "level_text", data.level)
	if self.m_model.m_stage_cfg.type == 1 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", data.score)
	elseif self.m_model.m_stage_cfg.type == 2 then
		local min = math.modf(data.score / 60)
		local sec = math.floor(data.score % 60 + 0.5)
		if min > 0 then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", "legend_str_015", min, sec)
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", "legend_str_014", sec)
		end
	end
	GameUtil:setUserGender(luaBehaviour, user.gender, "gender_img")
end

return M