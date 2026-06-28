local M = class("OptionsPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	local uid = UserDataManager.user_data:getUid()
	self:getData("user_user_detail_info", {target_uid = uid})
end

function M:onEnter()
	self.m_tab_index = 1
	self.m_sex = 1  -- 1 男 2 女
	
	local heros = UserDataManager.hero_data:getHerosId()
	self.m_heros = heros
	self.m_team = {}
	self.m_team_hero_data = {}
	self:updateTeamData()
	--local max = math.min(#heros,5)
	--for i=1,#heros do
	--	local oid = heros[i]
	--	local heroData = UserDataManager.hero_data:getHeroDataById(oid)
	--	local flag = true
	--	for i,v in ipairs(self.m_team) do
	--		local heroData2 = UserDataManager.hero_data:getHeroDataById(v)
	--		if heroData.id == heroData2.id then
	--			flag = false
	--			break
	--		end
	--	end
	--	if flag then
	--		self.m_team[#self.m_team + 1] = oid
	--		if #self.m_team == max then
	--			break
	--		end
	--	end
	--end
end

function M:updateTeamData()
	self.m_team_hero_data = {}
	self.m_team = {}
	local team = table.copy(UserDataManager.hero_data:getTeamByKey("view", "best"))
	for k, v in pairs(team) do
		local data, cfg = UserDataManager.hero_data:getHeroDataById(v)
		if data ~= nil then
			local oid = v
			--得到当前英雄id的我拥有的所有英雄
			local heros = UserDataManager.hero_data:getHeroIdsByCid(data.id)
			if #heros >0 then
				local combat = 1
				local evo
				for i, v in pairs(heros) do
					local hero_data = UserDataManager.hero_data:getHeroDataById(v);
					if hero_data.combat > combat then
						combat = hero_data.combat;
						oid = hero_data.oid
						evo = hero_data.evo
					end
				end
			end
			self.m_team[#self.m_team + 1] = oid
			table.insert(self.m_team_hero_data, data.id)
		else
			table.insert(self.m_team_hero_data, 0)
		end
	end
	self.m_medal_cfg = ConfigManager:getCfgByName("medal") or {}
end


function M:getTeamDataByIndex(index)
	return self.m_team[index]
end

function M:setTeamData(oid)
	for i,v in ipairs(self.m_team) do
		if v == oid then
			table.remove(self.m_team, i)
			return
		end
	end
	if #self.m_team < 5 then
		table.insert(self.m_team, oid)
	end
end

function M:getHeroDataByIndex(index)
	return self.m_heros[index]
end

function M:isSelect(oid)
	for i,v in ipairs(self.m_team) do
		if oid == v then
			return true
		end
	end
	return false
end

function M:setTab(index)
	self.m_tab_index = index
end

function M:setSex(sex)
	self.m_sex = sex
end

function M:setClickEffect(flag)
	local click_effect = U3DUtil:PlayerPrefs_GetString("screenClickEffect", "ok")
	if click_effect == "ok" then
		click_effect = "cancel"
	else
		click_effect = "ok"
	end
	U3DUtil:PlayerPrefs_SetString("screenClickEffect", click_effect)
	g_screen_effect = click_effect
end

function M:setMusicVolume(value)
	audio.music_volume = value
	audio:SetBgmVol(value) 
	U3DUtil:PlayerPrefs_SetFloat("music_volume", value)
end

function M:setEffectVolume(value)
	audio.effect_volume = value
	audio:SetSkillsVol(value)
	audio:SetUIVol(value)
	U3DUtil:PlayerPrefs_SetFloat("effect_volume", value)
end

function M:setCVVolume(value)
	audio.cv_volume = value
	audio:SetCVVol(value)
	U3DUtil:PlayerPrefs_SetFloat("cv_volume", value)
end

function M:setGameQuality(value)
	Logger.log(" value "..value )
	--低画质1 
	--高画质2
	if value == 1 then
		CS.UnityEngine.Application.targetFrameRate = 30;
		CS.wt.framework.ResourcesHelper.loadEffect = false;
		CS.LuaGameLaunch.Instance.FixScreenRatio.x = 960;
		CS.LuaGameLaunch.Instance.FixScreenRatio.x = 640;
		CS.LuaGameLaunch.Instance:setDesignContentScale()
	elseif value == 2 then
		CS.UnityEngine.Application.targetFrameRate = 60;
		CS.wt.framework.ResourcesHelper.loadEffect = true;
		CS.LuaGameLaunch.Instance.FixScreenRatio.x = 1280;
		CS.LuaGameLaunch.Instance.FixScreenRatio.x = 720;
		CS.LuaGameLaunch.Instance:setDesignContentScale()
	end
	GameMain.setPictureQuality(value)
	U3DUtil:PlayerPrefs_SetInt("picture_quality", value)
end

function M:getSginDesc()
	return #self.m_data.user.desc == 0 and Language:getTextByKey("options_str_0027") or GameUtil:formatInputText(self.m_data.user.desc)
end

function M:getMedalCfgById(cfg_id)
	if self.m_medal_cfg[cfg_id] then
		return self.m_medal_cfg[cfg_id]
	end
	return nil
end

function M:getMedalShowData()
	local medal_config = self.m_medal_cfg
	local medal_id_tab = {}
	local cur_season = UserDataManager:getCurSeason()
	for i, v in pairs(medal_config) do
		if cur_season >= v.season then
			local have_status =  UserDataManager:getMedalDataById(i) and 1 or 0
			medal_id_tab[#medal_id_tab + 1] = {id = i, order = v.order, have_status = have_status}
		end
	end
  	table.sort(medal_id_tab, function(a, b)
		if a.have_status == b.have_status then
			if a.order == b.order then
				return a.id > b.id
			else
				return a.order > b.order
			end
		else
			return a.have_status > b.have_status
		end
		
	end)
	return medal_id_tab
end

return M
