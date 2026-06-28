local M = class("GuildHighWarCityPopView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarCityPop"
M.m_size_type = 2
--M.m_iphoneXAdapter = true

local imgPath = {
	[1] = {icon = "a_icon_dfbhz_sjzz_lan",bg = "a_ui_dfbhz_sjzz_tanchuang_bg_lan"},
	[2] = {icon = "a_icon_dfbhz_sjzz_huang",bg = "a_ui_dfbhz_sjzz_tanchuang_bg_huang"},
	[3] = {icon = "a_icon_dfbhz_sjzz_lv",bg = "a_ui_dfbhz_sjzz_tanchuang_bg_lv"},
}
function M:onEnter()
	local build_name = self.m_model:getCfgValueByKey("build_name") or "new_str_0092"
	self:setTextByLanKey("common_title_text", build_name) 
	self:setTextByLanKey("owner_guild_text", "guild_high_war_text_0002")
	self:setTextByLanKey("city_lv_des_text", "guild_high_war_text_0003")
	self:setTextByLanKey("owner_score_text", "guild_high_war_text_0004")
	self:setTextByLanKey("battle_status_text", "guild_high_war_text_0005")
	self:setTextByLanKey("look_btn_text", "guild_high_war_text_0006")
	self:setTextByLanKey("atk_btn_text", "guild_high_war_text_0007")
	self:setTextByLanKey("def_btn_text", "guild_high_war_text_0045")
	self:setTextByLanKey("log_btn_text", "guild_high_war_text_0010")
	self:setTextByLanKey("tell_atk_btn_text", "guild_high_war_text_0011")
	self:setTextByLanKey("battling_btn_text", "guild_high_war_text_0018")
	--刷新背景
	local buff_type = self.m_model.m_city_cfg.buff_type
	local image_name= self:findImage("pop_bg_img")
	GameUtil:updateResourcesImg(image_name,"Texture/guildHighWar/"..imgPath[buff_type].bg)
	for i =1,3 do
		self:setObjectVisible("reward_show_bg"..i,buff_type==i)
	end
	self:setTextByLanKey("reward_title_text"..buff_type, "guild_high_war_text_0009")
	self:refreshUI()
	--self:setTextByLanKey("close_title_text", "total_world_rank_" .. self.m_model.m_cur_rank_sort)
end

function M:destroy()
	M.super.destroy(self)
end

function M:refreshUI()
	self:updateBtnStatus()
	self:updateText()
	self:updateLoopScroll()
	self:updateBuff()
end

function M:updateBtnStatus()
	local city_status = self.m_model.m_city_stauts
	self:setObjectVisible("declare_times_txt", false)
	if city_status == self.m_model.BATTLE_STATUS.PREPARE or city_status == self.m_model.BATTLE_STATUS.WATCH then
		self:setObjectVisible("battling_btn", false)
		self:setObjectVisible("tell_atk_btn", false)
		self:setObjectVisible("atk_btn", false)
		self:setObjectVisible("look_btn", false)
		self:setObjectVisible("def_btn", false)
	elseif city_status == self.m_model.BATTLE_STATUS.DECLARING then
		self:setObjectVisible("battling_btn", false)
		self:setObjectVisible("tell_atk_btn", self.m_model:isGuildManager() and not(self.m_model:isAtk()) and not(self.m_model:isDef()) and not(self.m_model:isWatch()))
		self:setObjectVisible("atk_btn", false)
		self:setObjectVisible("look_btn", false)
		self:setObjectVisible("def_btn", false)
		self:setObjectVisible("declare_times_txt", self.m_model:isGuildManager() and not(self.m_model:isAtk()) and not(self.m_model:isDef()) and not(self.m_model:isWatch()))
		self:setTextByLanKey("declare_times_txt","guild_high_war_text_00106",self.m_model.m_declare_times)
	elseif city_status == self.m_model.BATTLE_STATUS.DEF or city_status == self.m_model.BATTLE_STATUS.ATK then
		self.m_model.m_have_atk = true
		self:setObjectVisible("battling_btn", false)
		self:setObjectVisible("tell_atk_btn", false)
		self:setObjectVisible("look_btn", city_status == self.m_model.BATTLE_STATUS.ATK or (self.m_model.m_have_atk))
		self:setObjectVisible("atk_btn", city_status == self.m_model.BATTLE_STATUS.ATK)
		self:setObjectVisible("def_btn", city_status == self.m_model.BATTLE_STATUS.DEF and self.m_model.m_have_atk)
	elseif city_status == self.m_model.BATTLE_STATUS.BATTLING then
		self:setObjectVisible("battling_btn", true)
		self:setObjectVisible("tell_atk_btn", false)
		self:setObjectVisible("look_btn", false)
		self:setObjectVisible("atk_btn", false)
		self:setObjectVisible("def_btn", false)
	elseif city_status == self.m_model.BATTLE_STATUS.FORMULA then
		self:setObjectVisible("battling_btn", false)
		self:setObjectVisible("tell_atk_btn", false)
		self:setObjectVisible("look_btn", false)
		self:setObjectVisible("atk_btn", false)
		self:setObjectVisible("def_btn", false)
	end
	--self:setObjectVisible("battling_btn", city_status == self.m_model.BATTLE_STATUS.BATTLING)
	--self:setObjectVisible("tell_atk_btn", city_status == self.m_model.BATTLE_STATUS.PRE_DECLARE)
	--self:setObjectVisible("atk_btn", city_status == self.m_model.BATTLE_STATUS.ATK)
	--self:setObjectVisible("look_btn", city_status == self.m_model.BATTLE_STATUS.ATK)
	--self:setObjectVisible("def_btn", city_status == self.m_model.BATTLE_STATUS.DEF)
end


function M:updateBuff()
	local buff_type = self.m_model.m_city_cfg.buff_type
	local buff_level  = self.m_model.m_city_cfg.buff_level 
	for i =1,3 do
		self:setObjectVisible("buff_image_bg"..i,buff_type==i)
	end
	local cfg = ConfigManager:getCfgByName("guild_high_war_buff")
	buff_level= buff_level <= #cfg[buff_type] and buff_level or #cfg[buff_type]
	local data = cfg[buff_type][buff_level]
	self:setTextByLanKey("buff_des_text"..buff_type,data.des)
	self:setTextByLanKey("buff_name_text"..buff_type,data.name)
	self:setImg(imgPath[buff_type].icon, "maze_stage_ui", "buff_Image")
	--self:setImg(aa.name, "maze_stage_ui", "buff_Image")
end
function M:updateText()
	local build_name = self.m_model:getOwnerNameByCityId() or "guild_high_war_text_0053"
	self:setTextByLanKey("guild_name_text", build_name == "" and "guild_high_war_text_0053" or build_name)
	local build_lv = self.m_model:getCfgValueByKey("build_level") or 1
	self:setTextByLanKey("city_lv_text", "new_str_0075", build_lv)
	local obj = self:findImage("city_img")
	--self:setImg("a_csxq_chengshi"..build_lv,"maze_stage_ui","city_img")
	local build_icon = self.m_model:getCfgValueByKey("build_icon")
	self:setImg(build_icon,"maze_stage_ui","city_img")
	obj:SetNativeSize() --设置最大
	local build_score = self.m_model:getCfgValueByKey("build_score") or 1
	self:setTextByLanKey("score_text", tostring(build_score))
	self:setTextByLanKey("battle_guild_text", "guild_high_war_text_0022")
	self:setTextByLanKey("cur_statue_text", self.m_model:getCityStatusDes())
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	--local data = self.m_model:getCityRewards()
	local data = self.m_model:getCityRewards2()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			pos_center = true,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local reward_data = RewardUtil:getProcessRewardData(cell_data)
	local ui_element = GameUtil:updateItemElementByData(cell_object, reward_data, true, true)
	ui_element.red_point_img:SetActive(false)
end

function M:heroHandle(obj, hero_data)
	local data = hero_data
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
	GameUtil:updateHeroContentByData(obj,data,cfg)
end

return M