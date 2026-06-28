local M = class("FivelinesView",LikeOO.OOPopBase)

M.m_uiName = "Fivelines/Fivelines"
M.m_iphoneXAdapter = true
M.m_size_type = 1

M.TAB = {	{img = "a_wxz_icon_mu"} , 
		    {img = "a_wxz_icon_huo"} , 
			{img = "a_wxz_icon_tu"} , 	
			{img = "a_wxz_icon_jin"} , 
			{img = "a_wxz_icon_shui"} , 
		}

M.TAB_BOX = {
	{box = "a_wxz_tongxiangzi_anim", value = 1},
	{box = "a_wxz_yinxiangzi_anim", value = 0.68},
	{box = "a_wxz_yinxiangzi_anim", value = 1},
	{box = "a_wxz_jinxiangzi_anim", value = 0.68},
	{box = "a_wxz_jinxiangzi_anim", value = 1},
}

M.TAB_BOX_TYPE = {
	{ }

}

function M:onEnter()
	--置灰的图
	self.gruy_img = self:findImage("gruy_img");
	self.saodang_btn = self:findImage("saodang_btn");
	self:setTextByLanKey("tips","new_str_0769")
	self:setObjectVisible("tips", false);
	--获取动画组件
	self:setObjectVisible("rank_btn", false)
	
	self:setTextByLanKey("auto_btn_text", "new_str_0527")
	self:setTextByLanKey("title_text", "restr_str_0001")
	self:setTextByLanKey("count_text", "restr_str_0005")
	self:setTextByLanKey("close_title_text", "moon_shadow_str_004")
	self:setTextByLanKey("challenge_btn_text","new_str_0733")
	--宝箱隐藏掉
	self:setObjectVisible("box_item_01", false)
	--把五行阵的层隐藏掉
	self:setObjectVisible("top_text", false)
	--箭头UI也不要了
	self:setObjectVisible("jianytou_img", false)
	self:refreshUI()
	self:setObjectVisible("UI_Fivelines_ShangGuang_01", false)
	--遗物图标
	self.heirloom_id = self:findGameObject("heirloom_id")
	self:setObjectVisible("heirloom_id", false);
	self:updateQuestSpecial()
	self:setTextByLanKey("saodang_btn_text","new_str_0573")
	self.relic_formation_btn = self:findGameObject("relic_formation_btn");
	self.m_bag_action = false;
	UserDataManager:removeRedDotByKey("five_once")
	self.hero_item = self:findGameObject("hero_item")
	self:update_Gift(self.hero_item, self.m_model.cur_hero);
end


function M:update_Gift(cell_obj, hero_data)
	if hero_data ~= nil then
		local evo_item = self:getMoodShadowEvoData(self.m_model.day);
		if evo_item ~= nil then
			local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
			if luaBehaviour then
				local heroNode = luaBehaviour:FindGameObject("HeroNode")
				local farm_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo_item.evo]
				self:setTextByLanKey("hero_skill_txt","new_str_1066", Language:getTextByKey(farm_data.name))
				local hero_data = RewardUtil:getProcessRewardData({101,607,1})
				hero_data.quality = evo_item.evo
				CommonUIUtil:updateHeroElementByData(heroNode, hero_data)
			end
			self:setObjectVisible("hero_item", true)
			self:setTextByLanKey("hero_des_txt","new_str_1065",evo_item.show_buff)
		else
			self:setObjectVisible("hero_item", false)
		end
	else
		self:setObjectVisible("hero_item", false)
	end
end


function M:getMoodShadowEvoData( day )
	local item = nil
	for i, v in ipairs(self.m_model.cur_verson_mood_shadow) do
		if i > 1 and day >= i then
			item = v;
		end
	end
	return item;
end


function M:tantanBag()
	if self.m_bag_action ~= true then
		self.m_bag_action = true
		local bag_togglebtn = self.relic_formation_btn
		local sequence = Tweening.DOTween.Sequence()
		sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
		sequence:OnComplete(function ()
			self.m_bag_action = false
		end)
		sequence:SetAutoKill(true)
	end
end

function M:moveHeirloom( data )
	local heirloom = ConfigManager:getCfgByName("heirloom")
	local cfg = self.heirloom[data.heirloom_id]
	if cfg ~= nil then
		LuaBehaviourUtil.setImg(self.m_luaBehaviour, "heirloom_id", cfg.icon, "item_icon")
		self:setObjectVisible("heirloom_id", true);
		self.heirloom_id.transform.position = data.pos;
		self.m_view:setObjectVisible("heirloom_id", true);
		local sequence = Tweening.DOTween.Sequence()
		sequence:Append(self.heirloom_id.transform:DOLocalMove(Vector3(550,-10,0), 4.35):SetEase(Tweening.Ease.OutSine))
		sequence:OnComplete(function()
			--self.m_view:setObjectVisible("heirloom_id", false);
		end)
		sequence:SetAutoKill(true)
	end
end


--[[
	奖励显示
]]
function M:updateLoopScroll()
	self.m_click_cell_object = nil
	local data = self.m_model:getRewards()
	self:setObjectVisible("CommonTipsNode", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("reward_preview_loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			loop_scroll_object = loopscroll,
			one_line_count = 1, -- 行或列的数量
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local status = cell_data.status
				if status ~= -1 then
					self:updateMsg(status == 2 and "main_reward" or "goto_btn", cell_data)
					self.m_click_cell_object = cell_object
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

-- 更新
function M:updateScrollViewCell(index, cell_object, cell_data)
	GameUtil:updateItemElement(cell_object, cell_data, true, true)
end


--玩家开始移动UI做的调整
function M:playRunStart()
	--self:setObjectVisible("battle_btn", false)
end

--玩家移动结束
function M:playRunEnd()
	--self:setObjectVisible("battle_btn", true)
end


function M:refreshUI()
	self:updateLoopScroll();
	
	--剩余次数
	local remain_times = self.m_model.remain_times or 0;
	self:setTextByLanKey("remain_time","budo_str_004",remain_times)
	
	if self.m_model.four_tower_id == 0 then
		self:setObjectVisible("saodang_btn", false);
	else
		local free_times = self.m_model:getFreeTime();
		--还有免费次数
		if free_times > 0 then
			self:setTextByLanKey("saodang_remain_time","new_str_0758",free_times)
			self:setObjectVisible("cost", false);
			self.saodang_btn.material = nil;
		else
			--额外购买次数
			local buy_time = self.m_model:getBuyTime();
			if buy_time > 0 then
				self.saodang_btn.material = nil;
				self:setObjectVisible("cost", true);
				self:setObjectVisible("saodang_remain_time", false);
				--获取消耗数据
				local cost_data = self.m_model:getCostData( self.m_model.open_times + 1);
				--获取消耗货币种类
				local data = RewardUtil:getProcessRewardData( cost_data )
				local img = self:findGameObject("costicon");
				UIUtil.setImg(img,data.icon_name,data.atlas_name)
				self:setText("cost_num_text", data.data_num);
			else
				self:setObjectVisible("cost", false);
				self:setObjectVisible("saodang_remain_time", true);
				self.saodang_btn.material = self.gruy_img.material;
				--今日次数已用尽
				self:setTextByLanKey("saodang_remain_time","new_str_0773")
				self:setObjectVisible("tips", true);
			end
		end
	end
	
	
	--更新激活按钮状态
	--if self.m_model.floor == 0 then
		--把激活打开
		--self:setObjectVisible("battle_btn", true);
		--if self.m_model.four_tower_id == 0 then
		--	self:setObjectVisible("saodang_btn", false);
		--else
		--	self:setObjectVisible("saodang_btn", true);
		--end
	--else
		self:setObjectVisible("saodang_btn", false);
		self:setObjectVisible("battle_btn", false);
	--end
end


function M:updateRewardType()
	local num = #self.m_model.battle_logs
	self:setObjectVisible("a_wxz_tongxiangzi_anim", false)
	self:setObjectVisible("a_wxz_yinxiangzi_anim", false)
	self:setObjectVisible("a_wxz_jinxiangzi_anim", false)
end

function M:updateBoxAnimState()
	local num = #self.m_model.battle_logs
	local Box_Cfg = self.TAB_BOX[num]
	if Box_Cfg then
		local cur_box_anim = self:findGameObject(Box_Cfg.box)
		local anim = self:findAnimation(Box_Cfg.box)
		local anim_state = self:findAnimationState(Box_Cfg.box, "an_get")
		if anim then
			if self.show_anim == true then
				anim:Play("an_get")
			else
				if anim_state then
					anim:Play("an_get")
					anim_state.time = 0 
					anim_state.enabled = true
					anim:Sample()
					anim_state.enabled = false
				end
				UIUtil.setObjectVisible(cur_box_anim.transform, false, "fx_box_spark_001")
			end
		end
	end
end


function M:showEffectTX()
	self:setObjectVisible("UI_Fivelines_ShangGuang_01", true)
	self.m_control:setOnceTimer(1.5, function ()
		self:setObjectVisible("UI_Fivelines_ShangGuang_01", false)
	end)
end


function M:updateQuestSpecial()
	GameUtil:updateQuestSpecialNode(self, 44)
end

return M