--- 宠物斗技 失败

local M = class("SettlementPetLostNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementPetLostNode"

function M:onEnter()
	self:setTextByLanKey("self_title_text", "settlement_pet_0001")
	self:setTextByLanKey("rival_attack_text", "settlement_pet_0002")
	self:setTextByLanKey("self_attack_text", "new_str_0392")
	self:setTextByLanKey("self_cure_text", "new_str_0393")
	self:setTextByLanKey("rival_attack_text", "new_str_0392")
	self:setTextByLanKey("rival_cure_text", "new_str_0393")
	self:setTextByLanKey("log_btn_text", "new_str_0304")
	self:setTextByLanKey("tips_text", "new_str_0905")
	self:setTextByLanKey("self_title_text", "settlement_pet_0001")
	self:setTextByLanKey("rival_title_text", "settlement_pet_0002")
    self:refreshUI()
end

function M:refreshUI()
	local left_user = self.m_model:getUserInfoBySort(1)
	local right_user = self.m_model:getUserInfoBySort(2)
	
	local luaBehaviour = self.m_luaBehaviour
	local left_head_node = luaBehaviour:FindGameObject("left_head_node")
	GameUtil:setUserAvatar(left_head_node, left_user, nil, nil, {show_flag = true, scale = 1})
	local right_head_node = luaBehaviour:FindGameObject("right_head_node")
	GameUtil:setUserAvatar(right_head_node, right_user, nil, nil, {show_flag = true, scale = 1})
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_name_text", tostring(left_user.name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_name_text", tostring(right_user.name))
	
    self:updateSelfPetScroll()
	self:updateRivalPetScroll()
	local score = self.m_model.m_params.battle_data.score
	local pre_score = self.m_model.m_params.battle_data.pre_score
	local defend_score = self.m_model.m_params.battle_data.defend_score
	local defend_pre_score = self.m_model.m_params.battle_data.defend_pre_score
	if score >= pre_score then
		self:setTextByLanKey("self_score_text", "pet_douji_text_07",score,(score-pre_score))
	else
		self:setTextByLanKey("self_score_text", "pet_douji_text_08",score,(pre_score-score))	
	end
	if defend_score >= defend_pre_score then
		self:setTextByLanKey("rival_score_text", "pet_douji_text_07",defend_score,(defend_score-defend_pre_score))
	else
		self:setTextByLanKey("rival_score_text", "pet_douji_text_08",defend_score,(defend_pre_score-defend_score))	
	end
end

--[[
	创建列表
]]
function M:updateSelfPetScroll()
	local data = self.m_model:petAtkShowData()
	if self.m_self_scroll_view == nil then
		local loopscroll = self:findGameObject("self_pet_scroll")
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
		self.m_self_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_self_scroll_view:reloadData(data, true)
	end
end

function M:updateRivalPetScroll(data)
	local data = self.m_model:petDefShowData()
	if self.m_rival_scroll_view == nil then
		local loopscroll = self:findGameObject("rival_pet_scroll")
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
		self.m_rival_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_rival_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	LuaBehaviourUtil.setImg(luaBehaviour, "head_img", data.icon_name, data.atlas_name)
	local atk_slider = luaBehaviour:FindSlider("atk_slider")
	local add_slider = luaBehaviour:FindSlider("add_slider")

	local generation_data  = GameUtil:getPetInfoByData(data.hero_data, data.item_cfg)
	local icon_evo_bg = "a_ui_currency_dj_zi"    
    local level = 1
	if generation_data then
		icon_evo_bg = generation_data.icon_evo_bg
		LuaBehaviourUtil.setImg(luaBehaviour, "pet_generation_img", generation_data.evo_bg, "main_ui2")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_generation_text", generation_data.evo_text)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pet_generation_img", true)
		local upgradeCfg = ConfigManager:getCfgByName("pet_upgrade")
        if upgradeCfg[data.hero_data.lv] then
            level = upgradeCfg[data.hero_data.lv].display_level
        end
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pet_generation_img", false)	
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_level_text", level)
	LuaBehaviourUtil.setImg(luaBehaviour, "pet_evo_bg", icon_evo_bg, "equip_icon")

	local statistics_data = data.statistics_data or {}
	local max_statistics_data = data.max_statistics_data or {}
	local atk = math.floor(GlobalTools:ToFloat(statistics_data.atk or 0))
	local cure = math.floor(GlobalTools:ToFloat(statistics_data.cure or 0))

	local atk_max = math.floor(GlobalTools:ToFloat(max_statistics_data.atk_max or 0))
	local cure_max = math.floor(GlobalTools:ToFloat(max_statistics_data.cure_max or 0))

	atk_slider.value = atk_max > 0 and (atk/atk_max) or 0
	add_slider.value = cure_max > 0 and (cure/cure_max) or 0

	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "atk_text", tostring(atk))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "add_text", tostring(cure))

end

return M