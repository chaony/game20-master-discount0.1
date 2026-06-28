local M = class("GuJianQiTanMazeMeltView",LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanMazeMelt"
M.m_size_type = 2

function M:onEnter()
	self.m_select_cell_obj = nil --
	self:setTextByLanKey("common_title_text", "gu_jian_qi_tan_str_043")
	self:setTextByLanKey("use_btn_text", "gu_jian_qi_tan_str_044")
	self:refreshUI()
end

function M:refreshUI()
	local cost = ConfigManager:getCommonValueById(47)
	if _G.next(cost) then
		local cost_data = RewardUtil:getProcessRewardData(cost[1])
		self:setTextByLanKey("tips_text", "new_str_0179", cost_data.data_num, cost_data.name)
		self:setTextByLanKey("cost_num_text", tostring(cost_data.user_num))
		self:setImg(cost_data.icon_name, cost_data.atlas_name or "item_icon", "cost_icon")
	end
	self:updateLoopScroll()
	--self:setObjectVisible("red_point", self.m_model:checkIsDie() == true)
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getShowHeroData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 6,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local main_hero_cell = GameUtil:updateHeroContentByData(cell_object, data.hero_data, data.item_cfg, nil, nil)
				local dyns = data.dyns or {}
				local hp_pct = dyns.hp_pct or 10240000 -- 血量万分比
				local mp_pct = dyns.mp_pct or 0 -- 怒气万分比
				GameUtil:updateBigHeroHpSlider(cell_object, GlobalTools:ToFloat(hp_pct) /10000,  GlobalTools:ToFloat(mp_pct)/10000)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				if luaBehaviour  then
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigou_img", self.m_model:getSelectedHeroID() ==cell_data.card_id)
				end
				luaBehaviour:InjectionFunc()
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if not IsNull(self.m_select_cell_obj) then
					local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_cell_obj)
					if luaBehaviour  then
						LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigou_img", false)
					end
				end 
				self.m_select_cell_obj = cell_object
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				if luaBehaviour  then
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigou_img", true)
				end
				cell_data.lock_flag_custom = true
				self.m_model:setSelectedHeroID(cell_data.card_id)
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end



function M:runAnim()
	if self.m_loop_scroll_view then
		self:lockTouch()
		local cache_cells = self.m_loop_scroll_view.m_cache_cells
		local show_data = self.m_loop_scroll_view.m_show_data
		for k,v in pairs(cache_cells) do
			local data = show_data[k]
			if data then
				local dyns = data.dyns or {}
				local hp_pct = dyns.hp_pct or 10000 -- 血量万分比
				if hp_pct <= 0 then
					local luaBehaviour = UIUtil.findLuaBehaviour(v)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_MazeStage_shengji_001", true)
				end
			end
		end
		self.m_control:setOnceTimer(1, function()
			for k,v in pairs(cache_cells) do
				local luaBehaviour = UIUtil.findLuaBehaviour(v)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_MazeStage_shengji_001", false)
			end
			self:unlockTouch()
			self:refreshUI()
		end)
	else
		self:refreshUI()
	end
end

return M