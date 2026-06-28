local M = class("GuJianQiTanMazeBattleOverView",LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanMazeBattleOver"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("title_text", "new_str_0200")
	self:setTextByLanKey("ok_btn_text", "new_str_0201")
	--self:setTextByLanKey("tips_text", "new_str_0243")
	self:refreshUI()
end

function M:setSpineLoop(spine_graphic)
	self:addSpineComplete(spine_graphic.AnimationState,function()
		if spine_graphic.AnimationState:ToString() == "victory_1" then
			spine_graphic.AnimationState:SetAnimation(0, "victory_2", true)
		end
	end)
end

function M:refreshUI()
	self:updateLoopScroll()
	self:updateRewardLoopScroll()
	self:setObjectVisible("loopscroll", false)
	self:setObjectVisible("reward_loopscroll", false)
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = UserDataManager:getBattleOverQuestsByTargetType({[10] = 1})
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				local cfg = data.cfg
				local cur_progress = data.cur_progress
				local target_value = data.target_value
				local status = data.status
				local finish_flag = data.status == 2
				--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", finish_flag)
				local num_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num_text", tostring(cur_progress) .. "/" .. tostring(target_value))
				local des_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "des_text", cfg.name)
				num_text.color = finish_flag and GlobalConfig.COMMON_COLLOR.COMMON_18 or GlobalConfig.COMMON_COLLOR.COMMON_2
				des_text.color = finish_flag and GlobalConfig.COMMON_COLLOR.COMMON_18 or GlobalConfig.COMMON_COLLOR.COMMON_2
				LuaBehaviourUtil.setImg(luaBehaviour, "finish_img", finish_flag and "a_zdjs_wanchengbiaoji" or "a_zdjs_weiwancheng", "battle_ui")
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--[[
	创建列表
]]
function M:updateRewardLoopScroll()
	local data = self.m_model:getAllGifts()
	if self.m_reward_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("reward_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 4,
			loop_scroll_object = loopscroll,
			pos_center = true,
			update_cell = function(index, cell_object, cell_data)
				local data = cell_data
				GameUtil:updateItemElement(cell_object, data, true, true)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
			end
		}
		self.m_reward_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_reward_loop_scroll_view:reloadData(data)
	end
end

return M