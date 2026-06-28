
local M = class("HeroBookNode2",LikeOO.OOUIbase)
--火
M.m_uiName = "HeroBook/HeroBookNode2"

function M:onEnter()
	self.race_panel = self:findGameObject("race_panel")
	UIUtil.setScale(self.race_panel.transform, self.m_control.m_view.m_bg_scale_w, self.m_control.m_view.m_bg_scale_w)
	self:setObjectVisible("tags", false)
	self:refreshUI()    
end

function M:refreshUI()
	self:updateHeroUIInfo()
end

function M:updateHeroUIInfo()
	local heros = self.m_model:getHerosByRace()
	local hero_id_list = UserDataManager.hero_data:getHeroRoleCanUpGradeIdList()
	self.m_model:sortHeros(heros)
	self.show_tab = {}
	for i,v in pairs(heros) do
		-- local tag_obj = self:findGameObject("tag_"..v.id)
		local spine_obj = self:findGameObject("hero_"..v.id)
		local btn_obj = self:findGameObject("btn_"..v.id)
		local hide_bl = self.m_model:getByCid(v.id).hide_in_book or 0
		local have_bl = self.m_model:checkHave(v.id)
		local hero_show_bl = self.m_model:checkCanShow(v.id) --第一次获得的动画
		if not IsNull(spine_obj) and not IsNull(btn_obj) then
			-- tag_obj:SetActive(true)
			spine_obj:SetActive(true)
			btn_obj:SetActive(true)
			local friend_cfg = self.m_model:getFriendLines(v.id)
			-- if friend_cfg then
			-- 	UIUtil.setTextByLanKey(tag_obj.transform, "haogan_text", friend_cfg.lv)
			-- end
			-- local hero_name = UIUtil.setTextByLanKey(tag_obj.transform, "hero_name", v.name)
			local evo = self.m_model:checkEvo(v.id)
			local qu_com = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo]
			-- if qu_com then
			-- 	hero_name.color = qu_com.RGBA
			-- end
			local sg = UIUtil.findImage(spine_obj.transform)
			if v then
				--GameUtil:updateSpineLoadSet(spine_obj, "RoleSpine/"..v.hero_spine, "pose", 0, false)
			end
			if sg then
				sg.gameObject:SetActive(hide_bl == 0)
				btn_obj.gameObject:SetActive(hide_bl == 0)
				if have_bl == true and hero_show_bl == true then
					sg.color = Color( 0/255, 0/255, 0/255)
				elseif have_bl == true and hero_show_bl == false then
					sg.color = GlobalConfig.COMMON_COLLOR.COMMON_1
				else
					sg.color = Color( 0/255, 0/255, 0/255)
				end
			end
			if have_bl == true and hero_show_bl == true then
				table.insert(self.show_tab, {id = v.id, obj = sg})
			end
			local red_point_img = UIUtil.findImage(spine_obj.gameObject.transform, "red_point_img")
			if (red_point_img and table.indexof(hero_id_list, v.id)) or (red_point_img and self.m_model:IsHavePrestigeRed(v.id,v.evo)) then
				red_point_img.gameObject:SetActive(true)
			else
				red_point_img.gameObject:SetActive(false)
			end
		end
	end
	if #self.show_tab > 0 then
		self.m_control:setOnceTimer(self.m_model.m_show_del_tim, handler(self,self.showHeroIn))
	end
	-- for i = 1 , #heros do
	-- 	local cur_hero = heros[i]
	-- 	local spine_obj = self:findGameObject("spine_"..cur_hero.id)
	-- 	if not IsNull(spine_obj) then
	-- 		spine_obj.transform:SetSiblingIndex(#heros - 1) -- 修改层级关系
	-- 	end
	-- end
end

function M:showHeroIn()
	for k,v in pairs(self.show_tab) do
		local luaBehaviour = UIUtil.findLuaBehaviour(v.obj)
		if luaBehaviour then
			local function endCallFunc(anim_name)
				local item = self:creatFlyItem(v.obj.transform)
				self:updateMsg("fly", item)
			end
			self.m_control.m_view:lockTouch()
			self.m_control:setOnceTimer(1.5, function()
				self.m_control.m_view:unlockTouch()
			end )
			self.m_model:setHeroShowStatus(v.id)
			local tag_obj = self:findGameObject("tag_"..v.id)
			if tag_obj then
				local jh_item = self:ceratJiHuo(tag_obj.transform)
				self.m_control:setOnceTimer(0.5, function()
					ResourceUtil:ReturnItem(jh_item)
				end )
			end
			luaBehaviour:RunAnim("HeroBookColor", endCallFunc, 1)
		end
	end
end

function M:creatFlyItem(parent)
	local gift_item = ResourceUtil:LoadUIGameObject("HeroBook/fly_item", Vector3.zero, nil)
	gift_item.transform:SetParent(parent, false)
	return gift_item
end

function M:ceratJiHuo(parent)
	local jihuo_item = ResourceUtil:GetUIEffectItem("HeroBook/UI_HeroBook_JiHuo_003", Vector3.zero, nil)
	jihuo_item.transform:SetParent(parent, false)
	return jihuo_item
end

function M:moveOut()
	if self.race_panel then
		UIUtil.setLocalPosition(self.race_panel.transform, 10000,10000,0)
		self.race_panel:SetActive(false)
	else
		self.race_panel = self:findGameObject("race_panel")	
		UIUtil.setLocalPosition(self.race_panel.transform, 10000,10000,0)
		self.race_panel:SetActive(false)
	end
end

function M:moveIn()
	if self.race_panel then
		UIUtil.setLocalPosition(self.race_panel.transform, 0,0,0)
		self.race_panel:SetActive(true)
	else
		self.race_panel = self:findGameObject("race_panel")	
		UIUtil.setLocalPosition(self.race_panel.transform, 0,0,0)
		self.race_panel:SetActive(true)
	end
end


function M:onButtonClick(obj, name)
	M.super.onButtonClick(self, obj, name)
end

function M:destroy()
	M.super.destroy(self)
end

return M