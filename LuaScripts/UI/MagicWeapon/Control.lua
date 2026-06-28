local M = class("MagicWeaponControl",LikeOO.OOControlBase)

function M:onEnter()
	self:setOnceTimer(0.5, function()
		local output_data = self.m_model:getOutputItem()
		if next(output_data) and self.m_model:checkOptputNum() == true then
			self:openView("MagicWeapon.CollectionPop", {output_data = output_data})
		end
	end)
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:updateMsg("refreshUI",nil, "MagicWeaponSelectMain")
		self:updateMsg("refresh_red_point",nil, "parent")
		self:closeView()
	elseif msg == "guide_btn" then --快速导航
		self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
	elseif msg == "select_id" then
		audio:SendEvtUI("UI_DJYWU")
		self.m_model.m_select_id = data
		self.m_view:refreshUI()
	elseif msg == "cultivate_btn" then
		local wea_data = self.m_model:getWeaponData(self.m_model.m_select_id)
		self:openView("MagicWeapon.MagicWeaponLvUp", {wea_id = self.m_model.m_select_id, wea_data = wea_data})
	elseif msg == "use_btn" then
		self:useWeapon()
	elseif msg == "update_one_weapon" then
		if self.m_model.m_data.relics then
			if self.m_model.m_data.relics[tostring(self.m_model.m_select_id)] then
				self.m_model.m_data.relics[tostring(self.m_model.m_select_id)] = data
				self.m_view:refreshUI(true)	
			end
			UserDataManager.m_relics = self.m_model.m_data.relics
		end
	elseif msg == "hero_jc_btn" then --加持侠客
		self:openView("MagicWeapon.MagicWeaponHeroPop", {heros = self.m_model:getWeaHeros()})
	elseif msg == "reset_btn" then --重置
		local wea_data = self.m_model:getWeaponData(self.m_model.m_select_id)
		if wea_data.lv > 1 then
			local params =
			{  
				no_close_btn = false,
				tow_close_btn = true,
				cost = self.m_model:getAllWeaCost(),
				m_show_own_flag = true,
				show_cost = true,
				on_ok_call = function(msg)
					self:resetRelic()
				end,   
				text = Language:getTextByKey("weapon_str_0005")
			}
			if self.m_model:HavFreeNum() == true then
				local use_num = (self.m_model:getAllFreeNum() - self.m_model:getUseFreeNum()).."/"..self.m_model:getAllFreeNum()
				params.tip_text = Language:getTextByKey("weapon_str_0019",use_num) 
			else
				local need_num = ConfigManager:getCommonValueById(494,100)
				params.cost2 = {107,0,need_num}
			end
			self:openView("Pops.CommonPop",params)
		end
	elseif msg == "level_up_btn" then --升级
		self:weaponLvUp()	
	elseif msg == "skill_max_btn" then
		local wea_data = self.m_model:getWeaponData(self.m_model.m_select_id)
		self:lookWeaponSkillMaxTips({lv = wea_data.lv, wea_id = self.m_model.m_select_id, call_func = function ()
			self.cur_skill_max_pop = nil
		end})
	elseif msg == "help_btn" then
        local params = {}
        params.title = "weapon_str_0002"
        params.content = "tid#treasure_tips_3"
        self:openView("Pops.CommonHelpPop", params)
	elseif msg == "jump_btn" then --跳转到帮会法宝养成界面
		static_rootControl:closeAllViewPop()
		self:updateMsg("total_arena_btn", nil, "parent")
        -- QuickOpenFuncUtil:openFunc(go_type)
	end
end

function M:lookWeaponSkillMaxTips(params)
    if self.cur_skill_max_pop then
        self.cur_skill_max_pop:destroy()
		self.cur_skill_max_pop = nil
    end
    local LookInfoTips = CustomRequire("UI.MagicWeapon.MagicWeaponSkillMaxPop")
    self.cur_skill_max_pop = LookInfoTips.new(self, params)
end


--上阵遗物
function M:useWeapon()
    local function readCallback(response)
		if response then
			table.merge(self.m_model.m_data.slots, response.slots)
			table.merge(UserDataManager.m_slots, response.slots)
			self.m_view:refreshUI()
		end
	end
	local tre_cfg = self.m_model:getTreasureConfig(self.m_model.m_select_id)
	local cur_id = self.m_model:getWeaponIdBySlot(tre_cfg.position)
	if cur_id == self.m_model.m_select_id then
		local cur_wea_cfg = tre_cfg.detail[1]
		if cur_wea_cfg then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#treasure_tips_2", Language:getTextByKey(cur_wea_cfg.name_tips) ), delay_close = 2})	
		end
		return
	end
	local params = {}
	params.slot_id = tre_cfg.position
	params.relic_id = self.m_model.m_select_id
	self.m_model:getNetData("relic_select_relic", params, readCallback)
end

--重置遗物
function M:resetRelic()
    local function readCallback(response)
		if response then
			if response.relic_data then
				if response.reward and next(response.reward) then
					RewardUtil:rewardTipsByData(response.reward)
				end
				self:updateMsg("update_one_weapon", response.relic_data)
				self.m_model.m_data.reset_times = response.reset_times
			end
		end
	end
	local params = {}
	params.relic_id = self.m_model.m_select_id
	self.m_model:getNetData("relic_reset_relic", params, readCallback)
end


--升级遗物
function M:weaponLvUp()
	local lv_up_bl, name = self.m_model:getCanLvUp()
	if lv_up_bl == false and name then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0098", name), delay_close = 2})
		return
	end
	local function skill_call_func()
		local function readCallback(response)
			if response then
				if response.relic_data then
					
					self:openView("MagicWeapon.MagicWeaponLvUpPop", {wea_id = self.m_model.m_select_id, c_lv = response.relic_data.lv, callback = function ()
						self:updateMsg("update_one_weapon", response.relic_data)
					end })
				end
			end
		end
		local params = {}
		params.relic_id = self.m_model.m_select_id
		self.m_model:getNetData("relic_up_lv", params, readCallback)
	end
	if skill_call_func then
		skill_call_func()
	end
	-- local wea_data = self.m_model:getWeaponData(self.m_model.m_select_id)
	-- self:openView("MagicWeapon.MagicWeaponSkillLvUpPop", {wea_id = self.m_model.m_select_id,c_lv = wea_data.lv , call_func = skill_call_func})
end

function M:destroy()
	if self.cur_skill_max_pop then
        self.cur_skill_max_pop:destroy()
    end
	self.cur_skill_max_pop = nil
    M.super.destroy(self)
end

return M
