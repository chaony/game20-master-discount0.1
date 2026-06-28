local M = class("RpgScrollsUIView",LikeOO.OOPopBase)

M.m_uiName = "RpgScrollsUI/RpgScrollsUI"
M.m_size_type = 1
M.m_iphoneXAdapter = true
function M:onEnter()
	self:setTextByLanKey("common_title_text", "rpg_scroll_1")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

function M:updateLoopScroll()
    self.m_cell_tab = {}
	local data = self.m_model.team_cfg
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self.m_cell_tab[cell_data.id] = cell_object
				self:updateTeam(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local lock = self.m_model:checkLock(cell_data.id)
				if cell_data.data.switch == 0 then
					self:updateMsg("unopen")
				else
					if lock == true then
						self:updateMsg("select", {id = cell_data.id, chapter_data = self.m_model:getChapterById(cell_data.id)})
					else
						self:updateMsg("unlock", {id = cell_data.id})
					end
				end
				
			
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateTeam(obj, data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
	if luaBehaviour then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"cell_title_text",data.data.team_name)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"unlock_text", "rpg_scroll_9")
		local type_name = self.m_model:getTypeName(data.id)
		if type_name == "" then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"type_img", false)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"type_img", true)
		end
		GameUtil:setLanImgText(luaBehaviour:FindRectTransform("type_img"), type_name)
		local lock = self.m_model:checkLock(data.id)
		local icon_img = luaBehaviour:FindGameObject("icon_img")
		local lock_icon_img = luaBehaviour:FindGameObject("lock_icon_img")
		GameUtil:updateResourcesImg(icon_img, "Texture/common_img/"..data.data.pic_ID)
		GameUtil:updateResourcesImg(lock_icon_img, "Texture/common_img/"..data.data.pic_ID)
		if data.data.switch == 0 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unopen_img", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unlock_img", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_lock_title_bg", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_icon_img", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_di_img", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "need_heros", false)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unopen_img", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unlock_img", not lock)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_lock_title_bg", not lock)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_icon_img", not lock)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_di_img", not lock)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "need_heros", lock)
			if self.m_model:canlock(data.id) == true then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_spine", true)
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_spine", false)
			end
			if lock then
				local need_heros = luaBehaviour:FindGameObject("need_heros")
				local count = need_heros.transform.childCount
				local heros = data.data.hero
				for i = 1, count do
					local hero_cell = need_heros.transform:GetChild(i-1)
					local cur_cell_hero = heros[i]
					if cur_cell_hero then
						local c_luaBehaviour = UIUtil.findLuaBehaviour(hero_cell.transform)
						if c_luaBehaviour then
							local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cur_cell_hero)
							LuaBehaviourUtil.setTextByLanKey(c_luaBehaviour,"hero_name", hero_cfg.name)
						end
						hero_cell.gameObject:SetActive(true)
					else
						hero_cell.gameObject:SetActive(false)
					end
				end
			end
		end
	end
end

function M:openLockSpine(t_id, call_back)
	local obj = self.m_cell_tab[t_id]
	if obj then
		local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
		if luaBehaviour then
			local lock_spine_obj = luaBehaviour:FindGameObject("lock_spine")
			local lock_anim = lock_spine_obj:GetComponent("SkeletonGraphic")
			if lock_anim then
				lock_anim.AnimationState:SetAnimation(0, "animation_2", false)
				self:addSpineComplete(lock_anim.AnimationState, handler(self,self.refreshUI))
			end
		end
	end
end


function M:releaseVisibleView()
	M.super.releaseVisibleView(self)
	local function call_b()
		local function callback()
			self:refreshUI()
		end
		self.m_model:updateData(callback)
	end
	self.m_control:setOnceTimer(0.1,call_b)
end



function M:retainVisibleView( )
	M.super.retainVisibleView(self)
end

return M