local M = class("HeroBoxView",LikeOO.OOPopBase)

M.m_uiName = "Item/HeroBox"
M.m_size_type = 1

local ItemBgType = {
	Blue = "a_ck_pinjie_lan",
	Green = "a_ck_pinjie_green",
	Purple = "a_ck_pinjie_zi",
}

local ItemBgLightType = {
	Blue = "a_ck_pinjie_green_shang",
	Green = "a_ck_pinjie_lan_shang",
	Purple = "a_ck_pinjie_zi_shang",
}

function M:onEnter()
	self:setTextByLanKey("pop_tips_text", "new_str_0772")

	self:setTextByLanKey("hint_text", "new_str_0905")
	self:setTextByLanKey("choice_btn_text", "new_str_0771")
	local show_data = self.m_model.m_show_data
	self:setTextByLanKey("common_title_text", show_data.name)
	self:refreshUI()
end

function M:refreshUI()
	self:updateHeroLoopScroll()
	self:setObjectVisible("choice_btn", (self.m_model.m_isShowBtnType > 0))
end

--[[
	创建列表
]]
function M:updateHeroLoopScroll()
	local data = self.m_model:getShowData()
	if self.m_hero_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("hero_loopscroll")
		loopscroll:SetActive(true)
		local params = {
			show_data = data,
			pos_center = true,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateHeroScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "card_btn" then
					self.m_model.m_cur_select_id = cell_data.id
					self:updateMsg("onCardClick", {index = index, hero_id = cell_data[2]})
				elseif click_name == "btn_heroInfoBtn" then
					local heroUtil = RewardUtil:getProcessRewardData(cell_data)					
					static_rootControl:openView("Pops.HeroLookInfo", {hero_id = heroUtil.data_id, is_new = false})
				end
			end
		}
		self.m_hero_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_hero_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateHeroScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cell_data[2])
	if cell_data[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
		local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
		local card_hero_cfg_item = card_hero_cfg[cell_data[2]]
		hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(card_hero_cfg_item.hero_id)
	end
	local btn = luaBehaviour:FindButton("card_btn")
	btn.interactable = true

	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"card_top_img", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"hero_spine", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_img", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"card_bg_img", true)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"card_kuang_img", true)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"hero_img", true)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"img_DropImg", (self.m_model.m_isShowDropType > 0))
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"img_selectFrame", index == self.m_model.cur_select_index)
	local heroUtil = RewardUtil:getProcessRewardData(cell_data)
	local isShowHeroInfoBtn =  heroUtil.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or heroUtil.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or heroUtil.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS_EXT
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"btn_heroInfoBtn", isShowHeroInfoBtn)
	
	local curQuality = hero_cfg.evo
	local itemBgName = nil
	local itemBgLightName = nil
	if curQuality == 2 then
		itemBgName = ItemBgType.Green
		itemBgLightName = ItemBgLightType.Green
	elseif curQuality == 3 then
		itemBgName = ItemBgType.Blue
		itemBgLightName = ItemBgLightType.Blue
	elseif curQuality >= 5 then
		itemBgName = ItemBgType.Purple
		itemBgLightName = ItemBgLightType.Purple
	end
	if itemBgName then
		local card_bg_img = luaBehaviour:FindImage("card_bg_img")
		GameUtil:updateResourcesImg(card_bg_img, "Texture/pub_tex/".. itemBgName)
	end
	if itemBgLightName then
		local card_kuang_img = luaBehaviour:FindImage("card_kuang_img")
		GameUtil:updateResourcesImg(card_kuang_img, "Texture/pub_tex/".. itemBgLightName)
	end
	
	local race_data = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race]
	if race_data then
		LuaBehaviourUtil.setImg(luaBehaviour, "emblem_img", race_data.race_icon,  ResourceUtil:getLanAtlas())
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"martial_text", hero_cfg.name)

	local icon_name = "h_"..hero_cfg.icon.."_j"
	local hero_img = luaBehaviour:FindGameObject("hero_img")
	GameUtil:updateResourcesImg(hero_img, "Texture/pub_tex/" .. icon_name)
end


return M