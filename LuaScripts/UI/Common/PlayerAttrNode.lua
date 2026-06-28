--- 玩家属性
local M = class("PlayerAttrNode",LikeOO.OOUIbase)

M.m_uiName = "Common/PlayerAttrNode"
M.m_iphoneXAdapter = true

local __ATTR_TAB = {
	-- 金币 粉尘 钻石
		{key = "m_coin", data = {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0}, icon_img = "money_img", icon_text = "money_text"}, 
		{key = "m_dust", data = {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0}, icon_img = "exp_item_img", icon_text = "exp_item_text"}, 
		{key = "m_diamond", data = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0}, icon_img = "diamond_img", icon_text = "diamond_text"},
	}

function M:onCreate()
	self.m_exp_slider = self:findImage("exp_Fill")
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	local application_Id = SDKUtil.sdk_params.applicationId
	if SDKUtil.is_gmsdk then
		if application_Id == "com.hermes.wl" or SDKUtil.sdk_params.app == 2 then
			self.m_control:getCustomerRedPoint() --初始刷新客服红点
		end
	end
	local open_new_spine_flag = ConfigManager:getCommonValueById(821,0)
	self:setObjectVisible("new_year_spine3", open_new_spine_flag > 0)
end

function M:onEnter()
	self.m_full_combat = 0
	self.m_head_node = self:findGameObject("HeadNode")
	self.uid_text = self:findGameObject("uid_text")
	self.m_content_node = self:findGameObject("content_node")
	self:setText("uid_text", "UID:" .. UserDataManager.user_data:getUserStatusDataByKey("uid"))
	self:setTextByLanKey("combat_fly_text1", "new_str_1022")
	self:setTextByLanKey("combat_fly_text2", "new_str_1023")
	self:setObjectVisible("uid_text", false)
	self.m_is_play_combat_anim = false
    self:refreshUI()
	self:refreshCombat(true)
	self.m_content_node = self:findGameObject("content_node")
	self.m_dotween_anim = self.m_content_node:GetComponent("DOTweenAnimation")
	local open_bl = BtnOpenUtil:isBtnOpen(102)
	local combat_up_node = self:setObjectVisible("combat_up_node", false)
	self.m_start_pos = combat_up_node.transform.localPosition
end

function M:onButtonClick(obj, name)
	if name == "add_btn" then
		self.m_control:openView("Pops.Setting")
	elseif name == "icon_btn" then
		self.m_control:openView("Options")
		--self:setObjectVisible("uid_text", not self.uid_text.activeSelf)
	else
		for k,v in pairs(__ATTR_TAB) do
			if v.icon_img == name then
				GameUtil:lookInfoTips(self.m_control, {click_transform = obj.transform, data = v.data})
			    break
			end
		end
	end
	local full_btn_name = self.m_uiName .. "/" .. name
	GameUtil:playBtnSound(full_btn_name)
end

function M:updatePlayerHead_Opt()
	 
	local headIconObj = self:findGameObject("HeadNode_opt")
	local matIns = headIconObj.transform:GetComponent("MaterialInstance")
		
	local headObj = self:findGameObject("HeadNode") 
	local trans = headObj.transform

	local mskImg = UIUtil.findImage(trans,"tx_mask" )
	matIns:SetImg("_MainTex", mskImg);

	local headImg = UIUtil.findImage(trans,"tx_mask/tx_img" )
	matIns:SetImg("_HeadIconTex", headImg);

	local frmImg1 = UIUtil.findImage(trans,"Image")
	matIns:SetImg("_Frame1Tex", frmImg1);

	local brdObjTrans = trans:Find("border_img")
	if brdObjTrans.gameObject.activeSelf then

		local frmImg2 = brdObjTrans:GetComponent("Image")

		matIns:SetImg("_Frame2Tex", frmImg2);
		matIns:SetVector("_Frm2Color", 1,1,1,1);

	else
		matIns:SetVector("_Frm2Color", 1,1,1,0);

	end

	headObj:SetActive(false)
end
function M:refreshUI()
	local user_data = UserDataManager.user_data
	GameUtil:setUserAvatar(self.m_head_node, user_data.user_status, false, nil, {show_flag = true, scale = 1})

	self:updatePlayerHead_Opt()
	self:updateMedal()
	local level = user_data:getUserStatusDataByKey("level")
	local name = user_data:getUserStatusDataByKey("name")
	if self.m_level ~= level then
		self:setTextByLanKey("level_text", level)
		self.m_level = level
	end
	if self.m_name ~= name then
		name = name == "" and "new_str_0141" or name
		self:setTextByLanKey("name_text", tostring(name))
		self.m_name = name
	end
	
	for i,v in pairs(__ATTR_TAB) do
		local item_data = RewardUtil:getProcessRewardData(v.data)
		local user_num = item_data.user_num
		if self[v.key] ~= user_num then
			user_num = GameUtil:formatValueToString(user_num)
			self:setImg(item_data.icon_name, item_data.atlas_name, v.icon_img)
			self:setTextByLanKey(v.icon_text, tostring(user_num))
			self[v.key] = user_num
		end
	end
    local exp = user_data:getUserStatusDataByKey("exp") or 0
    local lv_exp = self:getPlayerLevelExp()
    self.m_exp_slider.fillAmount = exp/lv_exp
	self:creatPlayerTitle() -- 创建称号
	self:setCustomerRedPoint() --客服红点
	--设置称号升级红点
	local title_upgrade_red_flag = UserDataManager:getRedDotByKey("title_upgrade")
	self:setObjectVisible("head_info_red_point_img", title_upgrade_red_flag == 1)
end

function M:refreshCombat(is_init)
	local full_combat =  UserDataManager.user_data:getUserStatusDataByKey("full_combat")
	if not(is_init) and full_combat - self.m_full_combat > 0  then
		self:playCombatUpAnim(full_combat)
	else
		self:setTextByLanKey("combat_num", GameUtil:formatValueToString(full_combat))
		self.m_full_combat = full_combat
	end
end

function M:getPlayerLevelExp()
	local level = UserDataManager.user_data:getUserStatusDataByKey("level")
	local player_level = ConfigManager:getCfgByName("player_level")
	local player_level_item = player_level[level] or {}
	local exp = player_level_item.exp or 0
	return exp > 0 and exp or 999999999
end

function M:dataUpdateEvent(event, data)
	local curEvent = data.event
	if curEvent == "net_data_back" then
		self:refreshUI()
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	M.super.destroy(self)
end

function M:playOutAnim()
	if self.m_dotween_anim then
		self.m_dotween_anim:DORestart()
	end
end

function M:playEnterAnim()
	if self.m_dotween_anim then
		self.m_dotween_anim:DOPlayBackwards()
	end
end

function M:playCombatUpAnim(full_combat)
	self:setTextByLanKey("combat_num", GameUtil:formatValueToString(full_combat))
	self.m_full_combat = full_combat
	do return end
	
	if self.m_is_play_combat_anim then
		return
	end
	self.m_is_play_combat_anim = true
	local combat_up_node = self:setObjectVisible("combat_up_node", true)
	self:setObjectVisible("combat_up_img", true)
	self:setTextByLanKey("combat_value_fly_text","+" .. GameUtil:formatValueToString(full_combat - self.m_full_combat))
	local start_pos = self.m_start_pos

	local target_node = self:findGameObject("combat_num")
	local target_pos = combat_up_node.transform.parent:InverseTransformPoint(target_node.transform.position)
	combat_up_node.transform.localScale = Vector3(0.1, 0.1, 1)
	local sequence = Tweening.DOTween.Sequence()
	sequence:Append(combat_up_node.transform:DOScale(1.2, 0.1))
	sequence:Append(combat_up_node.transform:DOScale(1, 0.08))
	sequence:AppendInterval(1)
	sequence:AppendCallback(function()
		self:setObjectVisible("combat_up_img", false)
	end)
	sequence:Append(combat_up_node.transform:DOLocalMove( Vector3(target_pos.x,target_pos.y,0), 0.5))
	sequence:Join(combat_up_node.transform:DOScale(0.2, 0.5))
	sequence:OnComplete(function ()
		combat_up_node.transform.localPosition = Vector3(start_pos.x,start_pos.y,0)
		self:setObjectVisible("combat_up_node", false)
		self:AttrNumberChange("combat_num",self.m_full_combat, full_combat )
		--self:setTextByLanKey("combat_num", GameUtil:formatValueToString(full_combat))
		self.m_full_combat = full_combat
	end)
	sequence:SetAutoKill(true)
end

function M:AttrNumberChange(text_name, num1, num2)
	local sequence = Tweening.DOTween.Sequence()
	sequence:Append(Tweening.DOTween.To(function(index)
		local temp = math.floor(index)
		self:setText(text_name,  GameUtil:formatValueToString(temp))
	end, num1, num2, 0.5))
	sequence:OnComplete(function ()
		self.m_is_play_combat_anim = false
	end)
	sequence:SetAutoKill(true)
end
-- 创建主界面称号
function M:creatPlayerTitle()
	local title_id = UserDataManager.user_data:getUserStatusDataByKey("title")
	if title_id and title_id ~= 0 then
		self:setObjectVisible("head_title_img", true)
		local title_obj = self:findGameObject("head_title_img")
		local name_img = self:findImage("head_title_img")
		local cfg = UserDataManager.title_data:getTitleConfigById(title_id)
		if cfg and name_img and title_obj then
			name_img.enabled = true
			GameUtil:setTextureLoadTitleLanImgText(name_img, cfg.icon) -- 设置称号图片
			name_img:SetNativeSize()
			UIUtil.setScale(title_obj.transform, 0.7)
		end
		UIUtil.destroyAllChild(name_img.gameObject.transform)
		if cfg.title_effect and cfg.title_effect ~= "" then
			name_img.enabled = false
			ResourceUtil:GetUIEffectItem("Headtitle/" .. cfg.title_effect, name_img.gameObject)
		end
	else
		self:setObjectVisible("head_title_img", false)
	end
end

--设置客服红点
function M:setCustomerRedPoint()
	if SDKUtil.is_gmsdk then
		local application_Id = SDKUtil.sdk_params.applicationId
		if application_Id == "com.hermes.wl" or SDKUtil.sdk_params.app == 2 then
			local red = RedPointUtil:hasRedPointById(142)
			--local red_two = self.m_control:getCustomerRedPoint()
			--if red ~= red_two and red_two ~= nil then
			--	red = red_two
			--end
			self:setCustomerRed(red)
		end
	end
end

--设置客服红点显示
function M:setCustomerRed(ishas_redPoint)
	self:setObjectVisible("customer_red_point_img", ishas_redPoint)
end

function M:updateMedal()
	local MedalNode = self:findGameObject("MedalNode")
	local medals = UserDataManager.m_medals
	local wear_medal = table.nums(medals) > 0
	self:setObjectVisible("MedalNode", wear_medal)
	if wear_medal then
		local medals_id_tab = table.keys(medals)
		table.sort(medals_id_tab)
		local medal_id = medals_id_tab[#medals_id_tab]
		GameUtil:setHeadMedalNode(MedalNode, medal_id, true)
	end

end

return M