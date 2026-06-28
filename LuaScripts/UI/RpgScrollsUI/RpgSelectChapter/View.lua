local M = class("RpgSelectChapterView",LikeOO.OOPopBase)

M.m_uiName = "RpgScrollsUI/RpgSelectChapter"
M.m_size_type = 2
M.m_iphoneXAdapter = true
function M:onEnter()
	self:refreshUI()
	self:setTextByLanKey("common_title_text", self.m_model:getTeamName())
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
				if click_name == "cell_button" then
					self:updateMsg("check", {c_id = cell_data})
				elseif click_name == "cell_start_btn" then	
					self:updateMsg("click", {c_id = cell_data})
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
		local cfg, data = self.m_model:getChapterCfgByCId(cell_data)
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "call_name", cfg.chapter_name)
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "call_name2", cfg.chapter_name)
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_text", "rpg_scroll_2")
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "lock_text", "rpg_scroll_9")
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_num_text", self.m_model:getProgress(cell_data))
		local lock = cfg.switch == 1
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"cell_lock", not lock)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"lock_show", not lock)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"cell_name_bg", lock)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"lock_obj", lock)
		local cell_start_btn = LuaBehaviour:FindGameObject("cell_start_btn")
		local cell_lock = LuaBehaviour:FindGameObject("cell_lock")
		GameUtil:updateResourcesImg(cell_start_btn, "Texture/common_img/"..cfg.pic_id)
		GameUtil:updateResourcesImg(cell_lock, "Texture/common_img/"..cfg.pic_id)
		local end_num = self.m_model:getEnding(cell_data)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"cell_lock_text", end_num == 0)
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour,"cell_lock_text", "rpg_scroll_8")
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"pro_loopscroll", end_num ~= 0)
		local pro_scroll_obj = LuaBehaviour:FindGameObject("pro_loopscroll")
		if end_num > 0 then
			local attrs = self.m_model:getBuffById(cell_data)
			self:cellLoopScroll(pro_scroll_obj, attrs)
		end
	end
end

function M:cellLoopScroll(obj, attrs)
	local data = {}
	local params = {
		show_data = attrs,
		loop_scroll_object = obj,
		update_cell = function(index, cell_object, cell_data)
			local LuaBehaviour = UIUtil.findLuaBehaviour(cell_object)
			if LuaBehaviour then
				local str = GameUtil:getAttrsName(GameUtil:getAttrsKey(cell_data[1])) .."： "..cell_data[2]
				LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "show_text", str)
			end
		end,
	}
	LoopScrollViewUtil.new(params)
end

return M