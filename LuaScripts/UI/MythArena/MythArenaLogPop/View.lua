local M = class("MythArenaLogPopView",LikeOO.OOPopBase)

M.m_uiName = "MythArena/MythArenaLogPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0218")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	self:setTextByLanKey("atk_text", "new_str_0890")
	self:setTextByLanKey("def_text", "new_str_0891")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getShowData()
	self:setObjectVisible("common_tips_node", #data == 0)
	self:setObjectVisible("title_node", #data > 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {id = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local atk_user = data.atk_user or {}
    local def_user = data.def_user or {}
    local rank = data.rank or 0
    local def_rank = data.defender_rank or 0
    local atk_user_name = atk_user.name
    local def_user_name = def_user.name
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_combat","new_str_0453", rank)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_combat","new_str_0453", def_rank)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_name", tostring(atk_user_name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_name", tostring(def_user_name))
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "battle_btn", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_item_node", false)
    local left_headNode = luaBehaviour:FindGameObject("left_headNode")
    local right_headNode = luaBehaviour:FindGameObject("right_headNode")
	GameUtil:setUserAvatar(left_headNode, atk_user, nil, nil, {show_flag = true, scale = 1})
	GameUtil:setUserAvatar(right_headNode, def_user, nil, nil, {show_flag = true, scale = 1})
	local change_score = data.change_score or 0
	local change_score_str = tostring(change_score)
	if change_score > 0 then
		change_score_str = "+" .. tostring(change_score)
	end
	--local score_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", change_score_str)
	--local change_score = data.change_score or 0
	--score_text.color = change_score > 0 and Color( 64/255, 118/255, 17/255) or Color( 183/255, 65/255, 65/255)
	local log_time = data.log_time or 0
	local time = math.max(UserDataManager:getServerTime() - log_time, 0)
	local time_str = GameUtil:formatEndTimeBySecond(time)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "time_text", tostring(time_str))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_title_text", "new_str_0232")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "master_battle_btn", false)
	local battle_id = cell_data.battle_id or 0
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "statistics_btn", battle_id ~= 0)
	LuaBehaviourUtil.setImg(luaBehaviour, "left_result_img", data.result == 1 and "a_sjjs_shengli" or "a_sjjs_shibai", "language_zh_cn")
	LuaBehaviourUtil.setImg(luaBehaviour, "right_result_img", data.result == 0 and "a_sjjs_shengli" or "a_sjjs_shibai", "language_zh_cn")
end
return M