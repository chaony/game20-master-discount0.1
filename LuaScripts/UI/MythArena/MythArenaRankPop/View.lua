local M = class("MythArenaRankPopView",LikeOO.OOPopBase)

M.m_uiName = "MythArena/MythArenaRankPop"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "wlsh_text_0008")
    self:setTextByLanKey("common_no_have_text", "new_str_0351")
	self:setTextByLanKey("rank_label_text", "new_str_0374")
	self:setTextByLanKey("player_label_text", "new_str_0372")
    self:setTextByLanKey("score_label_text", "new_str_0375")
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
            pull_refresh = function() -- 下拉刷新
                self.last_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
                self:updateMsg("load_rank")
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("item_click", {id = index, cell_data = cell_data})
			end
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
    --local position = self.m_list_scroll:getVerticalNormalizedPosition()
    local position = (self.last_offsety - self.now_offsety) / self.m_loop_scroll_view.m_scroll_rect.content.rect.height
    self.m_loop_scroll_view:setVerticalNormalizedPosition(position)
    self.m_control.m_mail_load = false
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
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", GameUtil:formatValueToString(user.full_combat))
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
        name_text.transform.anchoredPosition = Vector3.New(78, -12, 0)
    else
        name_text.transform.anchoredPosition = Vector3.New(78, 0, 0)
    end
end


return M