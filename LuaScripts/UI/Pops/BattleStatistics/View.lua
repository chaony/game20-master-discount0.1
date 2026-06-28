local M = class("BattleStatisticsView",LikeOO.OOPopBase)

M.m_uiName = "Pops/BattleStatistics/BattleStatisticsPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("statistics_title_text", "new_str_0303")
	self:setTextByLanKey("play_btn_text", "new_str_0304")
	self:setTextByLanKey("common_title_text", "new_str_0390")
	self:setTextByLanKey("l_hero_label_text", "new_str_0391")
	self:setTextByLanKey("l_atk_label_text", "new_str_0392")
	self:setTextByLanKey("l_add_label_text", "new_str_0393")
	self:setTextByLanKey("l_def_label_text", "new_str_0394")
	self:setTextByLanKey("r_hero_label_text", "new_str_0391")
	self:setTextByLanKey("r_atk_label_text", "new_str_0392")
	self:setTextByLanKey("r_add_label_text", "new_str_0393")
	self:setTextByLanKey("r_def_label_text", "new_str_0394")
	self:setObjectVisible("play_btn", true)
	self:refreshUI()
end

function M:refreshUI()
	local left_user = self.m_model:getUserInfoBySort(1)
    local top_head_node = self:findGameObject("top_head_node")
	GameUtil:setUserAvatar(top_head_node, left_user,nil,nil,{show_flag = true, scale = 1})
	if left_user then
		self:setTextByLanKey("left_name_text", left_user.name)
		self:setObjectVisible("left_name_text", true)
	else
		self:setObjectVisible("left_name_text", false)
	end
	local right_user = self.m_model:getUserInfoBySort(2)
	local bottom_head_node = self:findGameObject("bottom_head_node")
	if right_user then
		self:setTextByLanKey("right_name_text", right_user.name)
		self:setObjectVisible("right_name_text", true)
	else
		self:setObjectVisible("right_name_text", false)
	end
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
		self:createWorldBossHead(bottom_head_node, right_user.avatar)
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS then
		self:createWorldBossHead(bottom_head_node, right_user.avatar)
	else
		GameUtil:setUserAvatar(bottom_head_node, right_user,nil,nil,{show_flag = true, scale = 1})
	end
	local result = self.m_model:getBattleResult()
	local left_result_img = self:findGameObject("top_result_img")
	GameUtil:setLanImgText(left_result_img, result == 1 and "a_zd_sjjs_shengli" or "a_zd_sjjs_shibai")
	local right_result_img = self:findGameObject("bottom_result_img")
	GameUtil:setLanImgText(right_result_img, result ~= 1 and "a_zd_sjjs_shengli" or "a_zd_sjjs_shibai")

	self:updateTopLoopScroll()
	self:updateBottomLoopScroll()
	if self.m_model.m_mode and 
			(self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT) then
		self:setObjectVisible("title_tips", true)
		self:setTextByLanKey("title_tips", self.m_model:getStageName())
	else
		self:setObjectVisible("title_tips", false)
	end
	self:setObjectVisible("play_btn", true)	
end

function M:createWorldBossHead(bottom_head_node, avatar)
	local bossHeadConfig = ConfigManager:getCfgByName("hero_detail")[avatar];
	if bossHeadConfig ~= nil then
		local hero_head_ui = UIUtil.setImg(bottom_head_node.transform, bossHeadConfig.icon, "hero_head_ui", "tx_mask/tx_img")
		if not IsNull(hero_head_ui) then
			UIUtil.destroyAllChild(hero_head_ui.transform)
		end
	end
end

--[[
	创建列表
]]
function M:updateTopLoopScroll()
	local data = self.m_model:getTopShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("top_list_scroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                -- self:updateMsg(click_name, {index = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

--[[
	创建列表
]]
function M:updateBottomLoopScroll()
	local data = self.m_model:getBottomShowData()
	if self.m_bottom_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("bottom_list_scroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                -- self:updateMsg(click_name, {index = index , cell_data = cell_data})
			end
		}
		self.m_bottom_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_bottom_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local item_node = luaBehaviour:FindGameObject("item_node")
	local ui_element = CommonUIUtil:updateHeroElementByData(item_node, cell_data)
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR then
		local heroLv = ConfigManager:getCommonValueById(776,3300 )
		data.hero_data.clv = heroLv
	end
	CommonUIUtil:updateHeroLvByData(item_node, data.hero_data)
	local atk_slider = luaBehaviour:FindSlider("atk_slider")
	local add_slider = luaBehaviour:FindSlider("add_slider")
	local def_slider = luaBehaviour:FindSlider("def_slider")
	local statistics_data = data.statistics_data or {}
	local max_statistics_data = data.max_statistics_data or {}
	local atk = math.floor(GlobalTools:ToFloat(statistics_data.atk or 0))
	local cure = math.floor(GlobalTools:ToFloat(statistics_data.cure or 0)) 
	local def = math.floor(GlobalTools:ToFloat(statistics_data.def or 0))
	local atk_max = math.floor(GlobalTools:ToFloat(max_statistics_data.atk_max or 0))
	local cure_max = math.floor(GlobalTools:ToFloat(max_statistics_data.cure_max or 0))
	local def_max = math.floor(GlobalTools:ToFloat(max_statistics_data.def_max or 0))
	atk_slider.value = atk_max > 0 and (atk/atk_max) or 0
	add_slider.value = cure_max > 0 and (cure/cure_max) or 0
	def_slider.value = def_max > 0 and (def/def_max) or 0
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "atk_text", tostring(atk))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "add_text", tostring(cure))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "def_text", tostring(def))
end

return M