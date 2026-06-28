---@class HeroLookInfoControl:OOControlBase
local M = class("HeroLookInfoControl",LikeOO.OOControlBase)

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		local callback = self.m_model.m_callback
		self:closeView()
    	if type(callback) == "function" then
    		callback()
    	end
		self:updateMsg("refreshRedPint", nil, "HeroBook")
	elseif msg == "skill1_img" then
		local sk_obj = self.m_view:findGameObject(msg)
		self:openSkillPop(1, sk_obj)
	elseif msg == "skill2_img" then
		local sk_obj = self.m_view:findGameObject(msg)
		self:openSkillPop(2, sk_obj)
	elseif msg == "skill3_img" then
		local sk_obj = self.m_view:findGameObject(msg)
		self:openSkillPop(3, sk_obj)
	elseif msg == "skill4_img" then
		local sk_obj = self.m_view:findGameObject(msg)
		self:openSkillPop(4, sk_obj)
	elseif msg == "evaluate_btn" then
		self:openView("HeroBag.HeroEvaluate",{hero_id = self.m_model.m_hero_id})
	elseif msg == "levelup_btn" then
		local sel_list, num, quality, consume_item, universal = self.m_model:getCanCostHeroList()
		local consItem = RewardUtil:getProcessRewardData(consume_item[1])
		if consItem.user_num < consItem.data_num then
			GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hero_role_upgrade_text3"), delay_close = 2})
			return
		elseif #sel_list< num then
			if universal then
				local universal_data = RewardUtil:getProcessRewardData(universal)
				if universal_data.user_num < (num - #sel_list) * universal_data.data_num then
					GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hero_role_upgrade_text3"), delay_close = 2})
					return
				else
					-- 补齐材料参数
					for i=1, num - #sel_list do
						table.insert(sel_list, "")
					end
				end
			else
				GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hero_role_upgrade_text3"), delay_close = 2})
				return
			end
		end
		
		self:levelUpRequest(sel_list)
	elseif msg == "help_btn" then
		local params = {}
		params.title = "hero_role_upgrade_text4"
		params.content = "tid#HeroroleTips_1"
		self:openView("Pops.CommonHelpPop", params)
	elseif msg == "reset_btn" then
		local evo, heroId = UserDataManager.hero_data:getHeroHighEvoByCid(self.m_model.m_hero_id)
		self:openView("Coach", {oid = heroId, tab_index = 4})
	elseif msg == "cons_img" then
		local sel_list, needNum, quality, consume_item, universal = self.m_model:getCanCostHeroList()
		local consItem = RewardUtil:getProcessRewardData(consume_item[1])
		self:openView("Item.ItemDetail", {show_data = consItem, display = true}, nil, true)
	elseif msg == "prestige_btn" then
		self:getPrestigepiece()
	end
end

function M:getPrestigepiece()
	--local evo, heroId = UserDataManager.hero_data:getHeroHighEvoByCid(self.m_model.m_hero_id)
	local function callback(response)
		if response.reward then
			RewardUtil:rewardTipsByData(response.reward)
		end
	end
	local params = {}
	params.hero = self.m_model.m_hero_id
	self.m_model:getNetData("prestige_recv_piece", params, callback)
end

function M:levelUpRequest(sel_list)
	local evo, heroId = UserDataManager.hero_data:getHeroHighEvoByCid(self.m_model.m_hero_id)
	local function callback(response)
		if response then
			self.m_model:updateHeroRoleData()
			self.m_view:refreshHeroRoleInfo()
		end
		self.m_view:lvUpZoom()
		self:openView("MagicWeapon.MagicWeaponLvUpPop")
	end
	local params = {}
	params.hero_oid = heroId
	params.material = sel_list
	self.m_model:getNetData("hero_book_lvlup", params, callback)
end


function M:openSkillPop(index, click_obj)
	local skills, hero_lv = self.m_model:getHeroSkill()
	self:openView("Pops.SkillPop",{skill = skills[index], pivot =Vector2(0.5,1), index = index, cur_lv = hero_lv , click_transform = click_obj.transform})
end

function M:dataUpdateEvent(event, data)
	if data.event == "hero_prestige" then
		self.m_view:refreshPrestigeBtn()
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	M.super.destroy(self)
end

return M
