local M = class("FiveLinesDeffDetailView",LikeOO.OOPopBase)

M.m_uiName = "FiveLines/FiveLinesDeffDetail"
M.m_size_type = 2

function M:onEnter()
	local cell_type = self.m_model.m_cell_data.type
	local maze_cell_type = ConfigManager:getCfgByName("maze_cell_type")
	local maze_cell_type_item = maze_cell_type[cell_type] or {}
	local tip_lan = "tid#FourTowerDes_0"..cell_type;
	self:setTextByLanKey("tips_text", tip_lan)
	
	self:setObjectVisible("maze_stage_detail_title_text1", false)
	self:setObjectVisible("maze_stage_detail_title_text2", false)
	self:setObjectVisible("maze_stage_detail_title_text3", false)

	local maze_stage_detail_title_text1 = self:setTextByLanKey("common_title_text", "new_str_0722")
	maze_stage_detail_title_text1.gameObject:SetActive(true)
	
	self:setTextByLanKey("reward_title_text", "new_str_0389")
	
	self:setTextByLanKey("ok_btn_text", "new_str_0166")
	self:setTextByLanKey("speed_btttle_btn_text", "new_str_0611")
	if self.m_model:canQuickBattle() then
		self:setObjectVisible("speed_btttle",true);
	else
		self:setObjectVisible("speed_btttle",false);
	end
	self:setObjectVisible("ok_btn", true)
	self:refreshUI()
	audio:SendEvtUI("Play_UI_Enemy")
end

function M:refreshUI()
	self:updateLoopScroll()
    -- 奖励
	local drop = self.m_model:getShowRewardData()
	local reward_node = self:findGameObject("reward_node")
	GameUtil:createRewards(reward_node.transform, drop, true, true, nil,1,nil)
	self:setTextByLanKey("combat_num_text", tostring(self.m_model.m_total_combat))
	--if UserDataManager.active_double_id ~= 0 and GameUtil:checkDoubleActiveByType(2) == true then
		--local num = reward_node.transform.childCount
		--for i = 1, num do
		--	local reward_cell = reward_node.transform:GetChild(i-1)
			--local LuaBehaviour = UIUtil.findLuaBehaviour(reward_cell)
			--if LuaBehaviour then
			--	LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"double_earn", true)
			--end
		--end
	--end
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
			one_line_count = 5,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				local item_node = luaBehaviour:FindGameObject("item_node")
				local ui_element = CommonUIUtil:updateHeroElementByData(item_node, cell_data, nil , true)
				CommonUIUtil:updateHeroLvByData(item_node, data.hero_data)
				-- local blood_slider = luaBehaviour:FindSlider("blood_slider")
				-- local anger_slider = luaBehaviour:FindSlider("anger_slider")
				local dyns = data.dyns or {}
				local hp_pct = dyns.hp_pct or 10240000 -- 血量万分比
				local mp_pct = dyns.mp_pct or 0 -- 怒气万分比
				-- blood_slider.value = hp_pct/10000
				-- anger_slider.value = mp_pct/10000
				CommonUIUtil:updateHeroHpSlider(item_node, GlobalTools:ToFloat(hp_pct)/10000, GlobalTools:ToFloat(mp_pct)/10000)
				local gray_img = luaBehaviour:FindImage("gray_img")
				if hp_pct <= 0 then
					ui_element.item_img.material = gray_img.material
					ui_element.quality_img.material = gray_img.material
				else
					ui_element.item_img.material = nil
					ui_element.quality_img.material = nil
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {index = index, cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

return M