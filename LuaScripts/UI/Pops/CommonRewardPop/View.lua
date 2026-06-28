local M = class("CommonRewardPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonRewardPop"
M.m_size_type = 2

function M:onEnter()
	self.sound = audio:SendEvtUI('PLAY_UI_ITEM')
	self.reward_grid = self:findGameObject("reward_grid")
	self.m_reward_node = self:findGameObject("reward_node")
	self.m_privilege_tip_text = self:findGameObject("privilege_tip_text")
	self:setTextByLanKey("privilege_tip_text", "privilege_tip_tex")
	--self.title_spine = self:findGameObject("title_spine")
	self:setTextByLanKey("tips_text", "new_str_0799")
	self:refreshUI()
	--self.animation = self.title_spine:GetComponent("SkeletonGraphic")
	--self:addSpineComplete(self.animation.AnimationState,handler(self,self.setAnimation))
	self.m_control:setOnceTimer(0.4,handler(self,self.fitPosition))
	self:lockTouch()
	self.m_control:setOnceTimer(0.6,function()
		self:unlockTouch()
	end)
end

function M:refreshUI()
	self.m_item = {}
	local num = #self.m_model.m_rewards
	if self.m_model.m_from_type > 0 then
		self:setObjectVisible("from_txt", true)
		if self.m_model.m_from_type == 5 then
			self:setText("from_txt", Language:getTextByKey("jubaoShan_str_009"))
		elseif self.m_model.m_from_type == 4 then
			self:setText("from_txt", Language:getTextByKey("jubaoShan_str_008"))
		end
	else
		self:setObjectVisible("from_txt", false)
	end
	local mystic_piece_flag = false
	local g_layout = self.reward_grid:GetComponent("GridLayoutGroup")
	g_layout.childAlignment = U3DUtil:Get_TextAnchor(num < 6 and "UpperCenter" or "UpperLeft")
	self:setObjectVisible("big_close_btn", num <= 10)
	local cell_type_config = ConfigManager:getCfgByName("dice_cell_type")
	for i = 1, num do
		local data = self.m_model.m_rewards[i]
		local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
		local item = GameUtil:instanceObject(self.m_reward_node)
		local luaBehaviour = UIUtil.findLuaBehaviour(item)
		item:SetActive(true)
		
		--来自文本
		if self.m_model.m_from_rewards ~= nil then
			if type(self.m_model.m_from_rewards) == "table" then
				--Logger.logError(data," 奖励数据 ~~~~~~~~~~~~~~ ")
				local key = RewardUtil:getRewardKeyById(data[1]);
				local item_id = tonumber(data[2]) or 0
				if item_id > 0 then
					key = key.."_"..data[2]
				else
					key = data[1]
				end
				--Logger.logError(" 奖励数据 key ~~~~~~~~~~~~~~ "..key)
				local from_item = self.m_model.m_from_rewards[key]
				if from_item ~= nil then
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "from_txt", true)
					local map_id = from_item.map_id;
					local item_type = from_item.item_type;
					local item_id = from_item.item_id;
					local config_data = cell_type_config[map_id][item_type][item_id]
					--Logger.logError(from_item," 来自item  ")
					--Logger.logError(config_data," 配置信息  ")
					local from_txt = luaBehaviour:FindText("from_txt");
					if config_data ~= nil and config_data.name ~= "" and config_data.name ~= nil then
						from_txt.text = Language:getTextByKey(config_data.name)
					else
						from_txt.text = "config is nil";
					end
				else
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "from_txt", false)
				end
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "from_txt", true)
				local from_txt = luaBehaviour:FindText("from_txt");
				from_txt.text = Language:getTextByKey("jubaoShan_str_026")
			end
		end

		GameUtil:updateItemElement(item, data, showNum, true)
		
		item.transform:SetParent(self.reward_grid.transform, false)
		--首通
		if self.m_model.m_firstReward then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fristReward", true)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fristReward", false)
		end
		
		if self.m_model.m_allDouble then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "double_earn", true)
		else
			if self.m_model.m_double then
				if data[1]  == RewardUtil.REWARD_TYPE_KEYS.COIN or data[1]  == RewardUtil.REWARD_TYPE_KEYS.HERO_EXP then
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "double_earn", true)
				else
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "double_earn", false)
				end
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "double_earn", false)
			end
		end
		UIUtil.setOpacity(item.transform, 0)
		if self.m_item[i] == nil then
			self.m_item[i] = {}
			self.m_item[i].obj = item
			self.m_item[i].type = data[1];
		end
		mystic_piece_flag = mystic_piece_flag or data.mystic_piece == 1
		local extra_type = data.extra_type
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "privilege_img", extra_type == 1)
		self.m_privilege_tip_text.gameObject:SetActive(extra_type == 1)
	end
	local tips_str = ""
	if mystic_piece_flag then
		tips_str = Language:getTextByKey("new_str_0799")
		if self.m_model.m_tips then
			tips_str = tips_str .. "\n"
		end
	end
	if self.m_model.m_tips then
		tips_str = tips_str .. Language:getTextByKey(self.m_model.m_tips)
	end
	local tips_up_str = self.m_model.m_tips_up or " "
	self:setText("tips_text", tips_str)
	self:setText("tips_text_up", Language:getTextByKey(tips_up_str))
	--self:setObjectVisible("tips_text", mystic_piece_flag)
	self.num = num
end

function M:setAnimation( )
	--if self.animation.AnimationState:ToString() == "animation_1" then
	--	self.animation.AnimationState:SetAnimation(0, "animation_2", true)
	--end
end

function M:fitPosition()
	if self.num > 4 then
		local rect = self.reward_grid.transform.rect
		UIUtil.setLocalPosition(self.reward_grid.transform, 0, -rect.height*0.5, 0)
	end

	for i,v in ipairs(self.m_item) do
		UIUtil.setOpacity(v.obj.transform, 1)
	end
end

function M:destroy()
	audio:StopPlayingID(self.sound)
	self.sound = nil
    M.super.destroy(self)
end

function M:getEffectByReward(parent)
	local random_y = Mathf.Random(0,1000)
	local yanwu = nil
	if random_y > 650 then
		yanwu = ResourceUtil:GetUIEffectItem("Main/UI_Main_JinBi_001",parent)
	elseif random_y > 300 then 
		yanwu = ResourceUtil:GetUIEffectItem("Main/UI_Main_JinBi_002",parent)
	elseif random_y > 150 then 
		yanwu = ResourceUtil:GetUIEffectItem("Main/UI_Main_YuanBao_001",parent)
	else  
		yanwu = ResourceUtil:GetUIEffectItem("Main/UI_Main_YuanBao_002",parent)
	end
	return parent
end

function M:PlayFly(callback)
	if self:needFly() == false then
		if callback then
			callback()
		end
		return
	end
	if IsNull(self.bao_01) then
		self:lockTouch()
		self.m_control:setOnceTimer(0.15,function ()
			self:unlockTouch()
			self:itemFlyAction()
			if callback then
				callback()
			end
		end)
		self.bao_01 = ResourceUtil:GetUIEffectItem("Main/UI_Main_Bao_001", self.m_ui_obj)
		self.bao_01.transform:SetParent(self.m_model.m_target_control.m_view.m_ui_obj.transform, true)
	end
end

function M:needFly()
	for k, v in pairs(self.m_item) do
		if self.m_model.m_fly_reward_types[v.type] then
			return true
		end
    end
	return false
end

function M:itemFlyAction()
    audio:SendEvtUI("PLAY_UI_GOLD")
	local delay = 0
	local target = self.m_model:getTarget()
	local num = 0
    for k, v in pairs(self.m_item) do
		if self.m_model.m_fly_reward_types[v.type] then
			self:flyMove(v.obj, delay, target)
			delay = delay + 0.03
			for i = 1, 8 do
				if num >=  20 then
					return
				end
				num = num + 1
				local item_obj = U3DUtil:Instantiate( v.obj );
				local random_y = Mathf.Random(10,200)
				local pos = v.obj.transform.localPosition + Vector3(4 * i, random_y, 0)
				self:flyMove(item_obj, delay, target, pos)
				delay = delay + 0.03
			end
		end
    end
end

function M:flyMove( obj, delay, target, pos )
	obj = self:getEffectByReward(obj)
    local reward_fly_ui = self.m_model.m_target_control.m_view:findGameObject("reward_fly_ui")
	if IsNull(reward_fly_ui) then
		reward_fly_ui = self.m_model.m_target_control.m_view.m_ui_obj
	end
	obj.transform:SetParent(reward_fly_ui.transform, true)
	obj.transform.localScale = Vector3(1,1,1)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
	if LuaBehaviour then
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "double_earn", false)  
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "quality_img", false)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "count_text_bg_img", false)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "count_text", false)
	end
	if pos ~= nil then
		obj.transform.localPosition = pos;
	end
	local tweener = obj.transform:DOScale(0.4, 1)
	CS.wt.framework.TweenTool.Bezier(
			obj,
			target.transform,
			0.6,
			CS.wt.framework.BezierType.Bezier_Level2,
			delay,
			false,
			function()
				tweener:Kill()
				UIUtil.destroyObject(obj)
				if not IsNull(self.bao_01) then
					UIUtil.destroyObject(self.bao_01)
					self.bao_01 = nil
				end
				static_rootControl:updateMsg("bag_action", nil, "parent")
			end
	)
end

return M