local M = class("RpgEndPopView",LikeOO.OOPopBase)

M.m_uiName = "RpgScrollsUI/RpgEndPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true
function M:onEnter()
	self.m_gray_image = self:findImage("ui_gray")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model.m_show_list
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local data = self.m_model:getEndDataByCId(cell_data.id)
				if data then
					self:updateMsg("click", cell_data)
				else
					self:updateMsg("unclick", cell_data)
				end
                
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local LuaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
	if LuaBehaviour then
		local data = self.m_model:getEndDataByCId(cell_data.id)
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_name_text", cell_data.cfg.end_name)
		local icon_img = LuaBehaviour:FindGameObject("cell_bg_icon")
		GameUtil:updateResourcesImg(icon_img, "Texture/common_img/"..cell_data.cfg.pic_ID)
		local title_bg_img = LuaBehaviour:FindImage("title_bg_img")
		if data then
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "check_btn", true)
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_img", false)
			icon_img.material = nil
			title_bg_img.material = nil
		else
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "check_btn", false)
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_img", true)
			icon_img.material = self.m_gray_image.material	
			title_bg_img.material = self.m_gray_image.material	
		end
	end
end

return M