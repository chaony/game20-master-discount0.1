local M = class("HeroBossInterceptView",LikeOO.OOPopBase)

M.m_uiName = "Activities/HeroBoss/HeroBossIntercept"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "hero_boss_text_012")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	self.m_refresh_btn = self:findButton("refresh_btn")
	self:refreshUI()
end

function M:refreshUI()
	self.m_refresh_time = self.m_model.m_data.rival_refresh_cd
	self:updateLoopScroll()
end

function M:updateLoopScroll()
	local data = self.m_model.m_data.rivals
	self:setObjectVisible("common_tips_node", #data <= 0)
	if self.m_loop_scroll_view == nil then
		local list_scroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {id = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", "hero_boss_text_017", cell_data.user.name, cell_data.user.guild_name)
	LuaBehaviourUtil.setText(luaBehaviour, "fight_text",  GameUtil:formatValueToString(cell_data.user.full_combat))
	local score = GameUtil:formatValueToString(cell_data.score or 0)
	LuaBehaviourUtil.setText(luaBehaviour, "score", Language:getTextByKey("hero_boss_text_013") .. score)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_text", "hero_boss_text_014")
	for i = 1, 5 do
		local obj = LuaBehaviourUtil.findGameObject(luaBehaviour, tostring(i))
		local hero_id = cell_data.heros[i]
		if hero_id == nil then
			obj:SetActive(false)
			--LuaBehaviourUtil.setObjectVisible(luaBehaviour, tostring(i), false)
		else
			obj:SetActive(true)
			local l = UIUtil.findLuaBehaviour(obj.transform)
			--LuaBehaviourUtil.setObjectVisible(luaBehaviour, tostring(i), true)
			local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
			local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero_cfg.evo] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
			local frame_name = quality_item.hero_item_frame
			LuaBehaviourUtil.setImg(l, "quality_img", frame_name, "hero_head_ui")
			LuaBehaviourUtil.setImg(l,"item_img", hero_cfg.icon, "hero_head_ui")
		end
	end
end

function M:updateTime()
	if self.m_refresh_time <= 0 then
		self.m_refresh_btn.interactable = true
		self:setTextByLanKey("refresh_btn_text", "hero_boss_text_015")
		return
	end
	self.m_refresh_time = self.m_refresh_time - 1
	self.m_refresh_btn.interactable = false
	self:setText("refresh_btn_text", GameUtil:formatTimeBySecond(self.m_refresh_time, 999))
end

return M