local M = class("ActiveCurrentLuckDrawView",LikeOO.OOPopBase)

M.m_uiName = "ActiveCurrent/ActiveCurrentLuckDraw"
M.m_size_type = 1
M.m_iphoneXAdapter = true


function M:onEnter()
	self.hui_img_material = self:findImage("hui_img").material
	self.luck_draw_btn = self:findImage("luck_draw_btn")
	if self.m_model.m_active_data ~= nil then
		self:setTextByLanKey("close_title_text", self.m_model.m_active_data.cell_data.cfg.name)
		self:setTextByLanKey("huojia_name", self.m_model.m_active_data.cell_data.cfg.name)
		local bg_img = self:findGameObject("bg_img")
		GameUtil:updateResourcesImg(bg_img,"Texture/ActiveCurrent/"..self.m_model.m_background) --设置背景
	end
	self:setTextByLanKey("luck_draw_text", "new_str_0814") --抽奖
	self:refreshUI()
	RedPointUtil:saveLocalRedPointFreshTime("EvilShadowExchange")
end

function M:refreshUI()
	self:refreshTaskList()
	self:setHeroInfo()
	local price = GameUtil:switchMoneyType(self.m_model:getPrice()) 
	local tip_word_one = self.m_model.m_day_price >= price and "active_current_str_0004"  or "active_current_str_0005"
	local tip_word_one_num = self.m_model.m_day_price >= price and price or self.m_model.m_day_price
	self:setTextByLanKey("tips_text", Language:getTextByKey(tip_word_one,tip_word_one_num, price)) --可抽奖提示
	local todayIsCharge = self.m_model:todayIsCharge()
	if todayIsCharge == 1 then --可抽奖
		self.luck_draw_btn.material = nil
	else
		self.luck_draw_btn.material = self.hui_img_material
	end
end

--刷新奖励数据信息
function M:refreshTaskList()
	local show_data = self.m_model:getShowData()
	if #show_data > 0 then
		for i = 1, 7 do
			local reward_node = self:findRectTransform("reward_node_"..i)
			UIUtil.destroyAllChild(reward_node)
			local item, ui_element = GameUtil:createItemElement(show_data[i].cfg.reward[1], true, true)
			ui_element.duigoudi_img:SetActive(show_data[i].stute == 1)
			item.transform:SetParent(reward_node.transform, false)
		end
	end
end


function M:setHeroInfo()
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_model.m_hero_skin_data.hero)
	local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({}, hero_cfg)

	local class_str = Language:getTextByKey(hero_cfg.class)
	local name_str = Language:getTextByKey(shin_data_cfg.name)
	self:setTextByLanKey("hero_name", name_str)
	self:setTextByLanKey("hero_name2", class_str)
	local race = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race].big_race_icon
	self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
	--local frame_data = GlobalConfig.QUALITY_FRAME[hero_cfg.max_evo]
	self:setImg(GameUtil:get_lineframename(hero_cfg.Ex_hero,hero_cfg.max_evo), "common_ui","hero_evo")

	local spine_name = self.m_model.m_hero_skin_data.hero_spine or "hero_0001_SkeletonData"
	local play_img = self:findGameObject("hero_spine")
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
end

function M:destroy()
	M.super.destroy(self)
end

return M