local M = class("ShiguangRelicFormationShowView",LikeOO.OOPopBase)

M.m_uiName = "ShiGuang/ShiguangRelicFormationShow"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("tips_text", "new_str_0162")
	self:setTextByLanKey("tips_text2", "new_str_0162")
	self:setTextByLanKey("title_text", "new_str_0182")
	self:setTextByLanKey("detail_text", "new_str_0183")
	self:setTextByLanKey("attr_add_title_text", "new_str_0274")
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
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getHeirloomData()
	local count = #data
	self:setObjectVisible("info_node", count > 0)
	self:setObjectVisible("none_node", count == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 5,
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
	local name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cfg.name)
	local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[cfg.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
	name_text.color = quality_item.RGBA
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "detail_text", cfg.des)
	CommonUIUtil:updateMazeStageRelicElement(cell_object, cfg)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "combat_node", true)
	local atkrating_ratio = cfg.atkrating_ratio or 0
	local atkrating_ratio_str = tostring(atkrating_ratio) .. "%"
	if atkrating_ratio > 0 then
		atkrating_ratio_str = "+" .. atkrating_ratio_str
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", atkrating_ratio_str)
	local combat_title_img = luaBehaviour:FindGameObject("combat_title_img")
	GameUtil:setLanImgText(combat_title_img, "a_ui_zhanli")
end

return M