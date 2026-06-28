local M = class("TowerStageView",LikeOO.OOPopBase)

M.m_uiName = "TowerStage/TowerStage"

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	-- self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	self.m_cache_cell = {}
	local data = self.m_model:getStageData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "detail_btn" then
					self:updateMsg("look_detail", {data = cell_data})
				elseif click_name == "head_node" then
					self:updateMsg("look_player", {data = cell_data})
				elseif click_name == "challenge_btn" then
					self:updateMsg("challenge_btn", {data = cell_data})
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
	self.m_loop_scroll_view:moveToCellIndex(self.m_model:getCurFloorId())
end

--更新
function M:updateScrollViewCell(index, cell_object, cell_data)
	self.m_cache_cell[index] = cell_object
	local data = cell_data
	local transform = cell_object.transform
	UIUtil.setTextByLanKey(transform, "title_text", "new_str_0083", tostring(data.floor_id))
	local floor_id = data.floor_id
	local cur_floor_id = data.cur_floor_id

	UIUtil.setObjectVisible(transform, floor_id < cur_floor_id, "finish_node")
	UIUtil.setObjectVisible(transform, floor_id == cur_floor_id, "challenge_btn")
	local item_node = UIUtil.setObjectVisible(transform, floor_id >= cur_floor_id, "item_node")
	UIUtil.setObjectVisible(transform, floor_id > cur_floor_id, "mask_img")
	local stage_battle_cfg = data.stage_battle_cfg or {}
	local monster = stage_battle_cfg.monster or {}
	UIUtil.destroyAllChild(item_node)
	
	if floor_id >= cur_floor_id then
		for i,v in ipairs(monster) do
			local prefab = GameUtil:createPrefab("TowerStage/TowerStageHeroItem", item_node)
			local prefab_transform = prefab.transform
			UIUtil.setTextByLanKey(prefab_transform, "lv_text", "new_str_0038", v.lv)
			local hero_spine = prefab_transform:Find("hero_spine")
			GameUtil:setHeroSpineAnim(hero_spine, v.id)
			local race_img = UIUtil.findTrans(prefab_transform, "race_img")
			GameUtil:setHeroRace(race_img, v.id)
		end
	end
	local players = self.m_model:getFloorPayersByFloorId(data.floor_id)
	UIUtil.setObjectVisible(transform, #players > 0, "head_node")
end

function M:updatePlayersShow()
	for k,v in pairs(self.m_cache_cell) do
		local data = self.m_model:getStageDataByIndex(k)
		local players = self.m_model:getFloorPayersByFloorId(data.floor_id)
		local transform = v.transform
		UIUtil.setObjectVisible(transform, #players > 0, "head_node")
	end
end

return M