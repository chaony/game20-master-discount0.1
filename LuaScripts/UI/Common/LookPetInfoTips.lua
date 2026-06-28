--- 宠物信息查看
local M = class("LookPetInfoTipsTips",LikeOO.OOUIbase)

M.m_uiName = "Common/LookPetInfoTips"
M.m_sortOrder = 19999

function M:onCreate()
	self.temp_pos = nil
	self.m_content = self:findGameObject("content")
	self.m_skill_content = self:findGameObject("skill_node")
	self.base_obj_fitter = self.m_content:GetComponent("ContentImmediate")
	self.skill_obj_fitter = self.m_skill_content:GetComponent("ContentImmediate")
	self:setTextByLanKey("flag_txt", "pet_bag_text_0019")
	self.finish = self.m_params.finish
	local delay_open = self.m_params.delay_open or 0.1
	local delay_close = self.m_params.delay_close or 0
	if delay_close > 0 then
		local sequence = Tweening.DOTween.Sequence()
		sequence:AppendInterval(delay_open + delay_close)
		sequence:OnComplete(function()
			self.m_delay_close_sequence = nil
			self:destroy()
		end)
		sequence:SetAutoKill(true)
		self.m_delay_close_sequence = sequence
		self:setObjectVisible("close_btn", false)		
	end
end

function M:setParent(parent)
	if static_root_node then
		self.m_rootView.transform:SetParent(static_root_node.transform, false)
	end
end

function M:onButtonClick(obj, name)
	if name == "close_btn" then
		self:destroy()
	end
end

function M:onEnter()
	self.m_douji = false
	if self.m_params.m_mode and self.m_params.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
		self:setTextByLanKey("no_skill_des", "当前奇兽暂无斗技技能")
		self.m_douji = true
	else
		self:setTextByLanKey("no_skill_des", "当前奇兽暂无协战技能")
		self.m_douji = false
	end
	
	self.is_single = self.m_params.m_mode
	self:refreshUI() 
end

function M:refreshUI()
	self.m_content.transform.localPosition = Vector3.New(100000,10000,0)
	local pet_data,pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_params.pet_id)
	if pet_cfg == nil then
		self:destroy()
		return 
	end
	local lv = 1
	if pet_cfg then
		lv = pet_cfg.lv
	end
    local skill_type_2 = false --是否有协战/斗技技能
	local skill_id = 0
	local skill_tab = {}
    for k,v in pairs(pet_data.skills) do
		if self.m_douji == true then
			if GameUtil:checkPetSkillType(v) == 1 then
				skill_type_2 = true
				skill_id = v
				table.insert(skill_tab, v)
			end
		else
			if GameUtil:checkPetSkillType(v) == 2 then
				skill_type_2 = true
				skill_id = v
		   end	   
		end
    end
	if skill_type_2 == true and skill_id ~= 0 then
		self:setObjectVisible("no_skill_tips", false)
		self:setObjectVisible("skill_node", true)

		local skill_cfg = self:getMainSkillConfig(skill_tab)
		self:setTextByLanKey("title_text", skill_cfg.name)
		
		if self.m_scroll_view == nil then
			local loopscroll = self:findGameObject("skill_node")
			local params = {
				show_data = skill_tab,
				loop_scroll_object = loopscroll,
				update_cell = function(index, cell_obj, cell_data)
					local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
					local random_cfg, skill_cfg = self:getMinLvByEvo(cell_data)
					local skill_des = Language:getTextByKey(random_cfg.skill_des)..(random_cfg.random_max == 1 and Language:getTextByKey("pet_evo_lv_0010") or "")

					local is_main_skill = skill_cfg.icon ~= nil and skill_cfg.icon ~= "" 
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skill_bg", is_main_skill)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "flag_bg", not is_main_skill)

					if is_main_skill then
						LuaBehaviourUtil.setImg(luaBehaviour,"skill_icon", skill_cfg.icon == "" and "JN_badao1" or skill_cfg.icon, "skill_icon")
					else
						LuaBehaviourUtil.setImg(luaBehaviour, "flag_bg", self:getSkillQualityBg(random_cfg.quality), "main_ui2")
					end
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"skill_des", skill_des)

					if self.skill_obj_fitter then
						--触发刷新自适应大小
						self.skill_obj_fitter:ForceRefreshSize()
					end
				end,
			}
			self.m_scroll_view = LoopScrollViewUtil.new(params)
		else
			self.m_scroll_view:reloadData(skill_tab, true)
		end
	else
		self:setObjectVisible("no_skill_tips", true)
		self:setObjectVisible("skill_node", false)
	end
	
	self.m_click_transform = self.m_params.click_transform
	if self.m_click_transform then
		local pos = self.m_content.transform.parent:InverseTransformPoint(self.m_click_transform.position)
		local click_transform_h = self.m_click_transform.rect.height
		local click_transform_w = self.m_click_transform.rect.width
		local content_w,content_h = 440, 210
		if self.m_params.top == true then
			pos.y = pos.y + content_h*0.5 + click_transform_h*0.5
		elseif self.m_params.right == true then
			pos.x = pos.x + content_w*0.5 + click_transform_w*0.5
		else
        	pos.y = pos.y - content_h*0.5 - click_transform_h*0.5
		end
        local width,height = self.m_rt.rect.width, self.m_rt.rect.height
        pos.y = math.max(math.min(pos.y ,height*0.5 - content_h*0.5), - height*0.5)
        pos.x = math.max(math.min(pos.x ,width*0.5 - content_w*0.5), - width*0.5 + content_w*0.5) 
		self.temp_pos = pos
	end

	local delay_close = self.m_params.delay_close or 0
	if delay_close > 0 then
		local sequence = Tweening.DOTween.Sequence()
		sequence:AppendInterval(0.5)
		sequence:Append(self.m_content.transform:DOLocalMoveY(180,delay_close - 0.5))
		sequence:SetAutoKill(true)
		self.m_move_sequence = sequence
	end
	if self.base_obj_fitter then
		--触发刷新自适应大小
		self.base_obj_fitter:ForceRefreshSize()
	end
	
	self.m_control:setOnceTimer(0.15, function ()
		if self.temp_pos then
			if not IsNull(self.m_content) then
				self.m_content.transform.localPosition = self.temp_pos	
			end
		end
	end)
end

function M:getMinLvByEvo(skill_rid)
    local skill_random_tab = ConfigManager:getCfgByName("pet_skill_random")
	if skill_random_tab[skill_rid] then
		local skill_tab = ConfigManager:getCfgByName("skill_detail")
		local skill_id = skill_random_tab[skill_rid].skill_id
		local skill_cfg = skill_tab[skill_id]
		return skill_random_tab[skill_rid], skill_cfg
	end
	return nil
end

function M:getMainSkillConfig(skill_tab)
	if skill_tab == nil or #skill_tab <= 0 then
		return nil
	end
	local skill_detail_config = ConfigManager:getCfgByName("skill_detail")
	for _, v in pairs(skill_tab) do
		local cfg =  skill_detail_config[v]
		if cfg ~= nil and tonumber(cfg.type) == 1 then
			return cfg
		end
	end
	return nil
end

function M:getSkillQualityBg(quality)
	if quality == 1 then
		return "a_cwyc_qsjn_jb06"
	elseif quality == 2 then
		return "a_cwyc_qsjn_jb05"
	elseif quality == 3 then
		return "a_cwyc_qsjn_jb"
	else
		return ""
	end
end

function M:destroy()
	if self.m_delay_close_sequence then
		self.m_delay_close_sequence:Kill()
		self.m_delay_close_sequence = nil
	end
	if self.m_delay_open_sequence then
		self.m_delay_open_sequence:Kill()
		self.m_delay_open_sequence = nil
	end
	if self.m_move_sequence then
		self.m_move_sequence:Kill()
		self.m_move_sequence = nil
	end
	if self.finish ~= nil then
		self.finish()
	end
	M.super.destroy(self)
	GameUtil:resetWeaponLookInfoTips()
end

return M