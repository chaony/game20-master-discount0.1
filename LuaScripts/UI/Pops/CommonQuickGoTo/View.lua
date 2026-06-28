local M = class("CommonQuickGoToView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonQuickGoTo"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0554")
	self:setTextByLanKey("tips_text", "new_str_0553")
	self:setTextByLanKey("list_title_text", "new_str_0554")
	self.m_item_node = self:findGameObject("item_node")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
	GameUtil:updateItemElementByData(self.m_item_node, self.m_model.m_item_data, false, false)
	self:setTextByLanKey("itemName", self.m_model.m_item_data.name)
	self:setTextByLanKey("itemDes", self.m_model.m_item_data.story)
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {index = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", data.cfg.name)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "des_text", "new_str_0699", Language:getTextByKey(data.cfg.name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0029")
	local lock_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", data.open_flag and "" or data.tips_str)
	lock_text.gameObject:SetActive(not data.open_flag)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "goto_btn", data.open_flag)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "name_text", data.open_flag)
	local icon_name = data.cfg.jump_icon or ""
	local imgAtlas = "main_ui"
	local iconImg = icon_name == "" and "a_icon_chuangwangbaozang" or icon_name 
	if not ResourceUtil:GetSprite(iconImg,imgAtlas) then
		imgAtlas = "main_ui2"
	end
	LuaBehaviourUtil.setImg(luaBehaviour, "func_img", iconImg, imgAtlas)
end

return M