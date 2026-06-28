local M = class("MagicWeaponLvUpControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:closeView()
	elseif msg == "level_up_btn" then --升级
		self:weaponLvUp()
	elseif msg == "reset_btn" then --重置
		if self.m_model:getWeaLv() > 1 then
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
			self:openView("Pops.CommonPop",params)
		end
	elseif msg == "hero_jc_btn" then --加持侠客
		self:openView("MagicWeapon.MagicWeaponHeroPop", {heros = self.m_model:getWeaHeros()})
	end
end

--升级遗物
function M:weaponLvUp()
    local function readCallback(response)
		if response then
			if response.relic_data then
				self.m_model:updateInitData(response.relic_data)
				self:updateMsg("update_one_weapon", response.relic_data, "MagicWeapon")
				self:openView("MagicWeapon.MagicWeaponLvUpPop", {wea_id = self.m_model.m_wea_id, c_lv = response.relic_data.lv })
			end
			self.m_view:refreshUI()
		end
	end
	local tre_cfg = self.m_model:getTreasureConfig(self.m_model.m_select_id)
	local params = {}
	params.relic_id = self.m_model.m_wea_id
	self.m_model:getNetData("relic_up_lv", params, readCallback)
end


--重置遗物
function M:resetRelic()
    local function readCallback(response)
		if response then
			if response.relic_data then
				self.m_model:updateInitData(response.relic_data)
				if response.reward and next(response.reward) then
					RewardUtil:rewardTipsByData(response.reward)
				end
				self:updateMsg("update_one_weapon", response.relic_data, "MagicWeapon")
			end
			self.m_view:refreshUI()
		end
	end
	local tre_cfg = self.m_model:getTreasureConfig(self.m_model.m_select_id)
	local params = {}
	params.relic_id = self.m_model.m_wea_id
	self.m_model:getNetData("relic_reset_relic", params, readCallback)
end

return M
