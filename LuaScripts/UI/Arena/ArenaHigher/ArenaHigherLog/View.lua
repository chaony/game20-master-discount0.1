local M = class("ArenaHigherLogView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaHigher/ArenaHigherLog"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0218")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
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
    local user = data.user_info or {}
    local rank = data.defender_rank or 0
    local name = user.name
    if name == nil or name == "" then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.uid))
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(name))
	end
	local status = data.status -- 0自己 1敌人
	if status == 1 then
		rank = data.rank
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "battle_btn", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_item_img", false)
    local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, user,nil,nil,{show_flag = true, scale = 1})
	local log_time = data.log_time or 0
	local time = math.max(UserDataManager:getServerTime() - log_time, 0)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "time_text", "new_str_0220", tostring(math.ceil(time/3600)))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_title_text", "new_str_0232")
	local result = data.result or 0
	local battle_result_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "battle_result_text", result == 1 and "new_str_0298" or "new_str_0299")
	battle_result_text.color = result == 1 and GlobalConfig.COMMON_COLLOR.COMMON_8 or GlobalConfig.COMMON_COLLOR.COMMON_11
	LuaBehaviourUtil.setImg(luaBehaviour,"result_img",result == 1 and "a_bh_shengli_zi" or "a_bh_shibai_zi", ResourceUtil:getLanAtlas())
	local result_img_bg = LuaBehaviourUtil.setImg(luaBehaviour,"result_img_bg",result == 1 and "a_bh_shenglidi" or "a_bh_shibaidi", "arena_ui")
	UIUtil.setLocalScale(result_img_bg.transform, result == 1 and 1 or -1)
	if rank == 0 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "segment_node", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "arena_level_text", true)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "arena_level_text", "new_str_0076")
	else
		local cfg = ConfigManager:getHighArenaCfgByRank(rank)
		local segment_node = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "segment_node", true)
		CommonUIUtil:setSegmentInfo(segment_node, cfg, true)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "arena_level_text", false)
	end
	local battle_id = cell_data.battle_id or 0
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "statistics_btn", battle_id ~= 0)
end
return M