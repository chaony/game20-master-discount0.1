---@class MazeStageRelicFormationShowView:OOPopBase
---@field m_model MazeStageRelicFormationShowModel
local M = class("MazeStageRelicFormationShowView",LikeOO.OOPopBase)

M.m_uiName = "MazeStage/MazeStageRelicFormationShow"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("tips_text", self.m_model.tips_text)
	self:setTextByLanKey("tips_text2", "new_str_0162")
	self:setTextByLanKey("title_text", "new_str_0182")
	self:setTextByLanKey("detail_text", "new_str_0183")
	self:setTextByLanKey("attr_add_title_text", "new_str_0274")
	self:setTextByLanKey("combat_add_text", "new_str_0175")
	self:setTextByLanKey("common_no_have_text", "four_tower_str_0022")
	self:setTextByLanKey("common_title_text", self.m_model.common_title_text)
	local relic_combat_title_img = self:findGameObject("relic_combat_title_img")
	GameUtil:setLanImgText(relic_combat_title_img, "a_ui_zhanli")
	self:refreshUI()
end

function M:refreshUI()
	local heirloom_num = self.m_model:getHeirloomNum()
	for k,v in pairs({7,5,3}) do
		local heirloom_num_item = heirloom_num[v] or {}
		self:setTextByLanKey("relic_num_text_" .. k, tostring(heirloom_num_item.num or 0))	
		local atkrating_ratio = heirloom_num_item.atkrating_ratio or 0
		local atkrating_ratio_str = tostring(atkrating_ratio or 0) .. "%"
		if atkrating_ratio >= 0 then
			atkrating_ratio_str = "+" .. atkrating_ratio_str
		end
		self:setTextByLanKey("attr_add_text_" .. k, atkrating_ratio_str)	
	end
	local add_value, _ = self.m_model:getHeirloomCombatAddRatio()
	self:setText("combat_add_value_text", string.format("+%0.2f%%", add_value*100))
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getHeirloomData()
	local count = #data
	self:setObjectVisible("CommonTipsNode", count == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("cell_click", {data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local cfg = data.cfg
	CommonUIUtil:updateMazeStageRelicElement(cell_object, cfg)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "combat_node", false)
	local atkrating_ratio = cfg.atkrating_ratio or 0
	local atkrating_ratio_str = tostring(atkrating_ratio) .. "%"
	if atkrating_ratio > 0 then
		atkrating_ratio_str = "+" .. atkrating_ratio_str
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", atkrating_ratio_str)
	--local combat_title_img = luaBehaviour:FindGameObject("combat_title_img")
	--GameUtil:setLanImgText(combat_title_img, "a_ui_zhanli")
	local attr_icon = luaBehaviour:FindGameObject("attr_icon")
	attr_icon:SetActive(true)
end

return M