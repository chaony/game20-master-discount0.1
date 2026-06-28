local M = class("MazeStageHerosView",LikeOO.OOPopBase)

M.m_uiName = "MazeStage/MazeStageHeros"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0176")
	self:setTextByLanKey("use_btn_text", "new_str_0662")
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
	self:setObjectVisible("red_point", self.m_model:checkIsDie() == true)
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
				-- local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				-- local item_node = luaBehaviour:FindGameObject("item_node")
				-- local ui_element = CommonUIUtil:updateHeroElementByData(item_node, cell_data, nil, true)
				-- CommonUIUtil:updateHeroLvByData(item_node, data.hero_data)
				local dyns = data.dyns or {}
				local hp_pct = dyns.hp_pct or 10240000 -- 血量万分比
				local mp_pct = dyns.mp_pct or 0 -- 怒气万分比
				GameUtil:updateBigHeroHpSlider(cell_object, GlobalTools:ToFloat(hp_pct) /10000,  GlobalTools:ToFloat(mp_pct)/10000)
				-- CommonUIUtil:updateHeroHpSlider(item_node, hp_pct/10000, mp_pct/10000)
				-- local item_cfg = data.item_cfg
				-- local race_item = GlobalConfig.TYPE_HERO_RACE[item_cfg.race]
				-- local camp_img = LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_item.race_icon, "common_ui")
				-- local gray_img = luaBehaviour:FindImage("gray_img")
				-- if hp_pct <= 0 then
				-- 	ui_element.item_img.material = gray_img.material
				-- 	ui_element.quality_img.material = gray_img.material
				-- else
				-- 	ui_element.item_img.material = nil
				-- 	ui_element.quality_img.material = nil
				-- end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
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