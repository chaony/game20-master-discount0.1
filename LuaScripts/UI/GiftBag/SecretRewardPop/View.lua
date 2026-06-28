local M = class("SecretRewardPopView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/SecretRewardPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local Time_1 = 0.2
local Time_2 = 0.5

function M:onEnter()
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 32})
	self:setTextByLanKey("close_title_text", self.m_model:getPanelName())
	self:setTextByLanKey("get_ace_pag_btn_text", "secret_reward_pop_text001")
	self:setTextByLanKey("reward_btn_text", "secret_reward_pop_text002")
	self:setTextByLanKey("exchange_btn_text", "secret_reward_pop_text003")
	self:setTextByLanKey("jiangli_text", "secret_reward_pop_text004")
	self:setTextByLanKey("btn_one_text", "secret_reward_pop_text005")
	self:setTextByLanKey("btn_five_text", "secret_reward_pop_text006")
	self:setObjectVisible("change_btn", false)
	self.m_new_box_reward_slider = self:findSlider("new_box_reward_slider")
	self.axian_head_img = self:findGameObject("axian_head_img")
	self.one_red_point = self:findGameObject("one_red_point")
	self.five_red_point = self:findGameObject("five_red_point")
	self.get_red_point = self:findGameObject("get_red_point")
	
	self.itemNodeList = {}
	self.selImgList = {}
	for i = 1, 14 do
		local obj = self:findGameObject("cell_item_" .. i)
		local luaBehaviour = obj:GetComponent("LuaBehaviour")
		local little_bg = luaBehaviour:FindGameObject("little_bg")
		self.itemNodeList[i] = obj
		self.selImgList[i] = little_bg
	end
	self:refreshUI()
	self:initAXianPos()
end

function M:refreshUI()
	self:setTextByLanKey("title_text", "secret_reward_pop_text007",self.m_model.cur_floor)
	self:refreshBoxStatus()
	self.m_new_box_reward_slider.value = self.m_model.cur_floor /self.m_model.max_layer
	self:refreshLayerReward()
	self:refreshAllRedPoint()
end

function M:refreshAllRedPoint()
	local count = self.m_model:getUserItemCount()
	if count >= 1 and not self.m_model:checkMaxFloor() then
		self.one_red_point:SetActive(true)
	else
		self.one_red_point:SetActive(false)
	end
	if count >= 5 and not self.m_model:checkMaxFloor() then
		self.five_red_point:SetActive(true)
	else
		self.five_red_point:SetActive(false)
	end
	if self.m_model:checkTaskRedPoint() then
		self.get_red_point:SetActive(true)
	else
		self.get_red_point:SetActive(false)
	end
end

-- 刷新本层奖励
function M:refreshLayerReward()
	local rewardTab = self.m_model.layer_gifts
	for i = 2, 14 do
		local obj = self:findGameObject("cell_item_" .. i)
		local luaBehaviour = obj:GetComponent("LuaBehaviour")
		local item = luaBehaviour:FindGameObject("ItemNode")
		if rewardTab[i] then
			GameUtil:updateItemElement(item,rewardTab[i][1],true, true)
		end
	end
end

function M:gacha(reward)
	self:setAXianPos(reward)
end


function M:refreshBoxStatus()
	local max_index = 4
	for i = 1, max_index do
		local box_status, floor_num = self.m_model:getBoxStatus(i)
		local task_box = self:findGameObject("one_box_node" .. i)
		task_box:SetActive(true)
		local transform = task_box.transform
		local luaBehaviour = UIUtil.findLuaBehaviour(transform)
		local score_text = luaBehaviour:FindText("score_text")
		local str = self.m_model.big_reward_floor_List[i] or ""
		score_text.text = Language:getTextByKey("secret_reward_pop_text009", str)
		local function btns(trans,params)
			if box_status == 2 then -- 可领取
				self:updateMsg("box_reward", {click_transform = transform, layer = floor_num})
			else
				self:updateMsg("box_click", {click_transform = transform, data = i, is_look = box_status == 0})
			end
		end
		UIUtil.setButtonClick(transform, btns, i)
		local box_effect = UIUtil.findRectTransform(transform, "UI_Arena_BX_01")
		local box_effect2 = UIUtil.findRectTransform(transform, "UI_Arena_BX_02")
		if box_status == 0 then
			UIUtil.setImg(transform, "a_xwyj_phb_chestoff", "mystic_ui", "box_img")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", false)
		elseif box_status == 2 then
			UIUtil.setImg(transform, "a_xwyj_phb_chestoff", "mystic_ui", "box_img")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", false)
		elseif box_status == -1 then
			UIUtil.setImg(transform, "a_xwyj_phb_cheston", "mystic_ui", "box_img")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", true)
		end
		if box_effect ~= nil then
			box_effect.gameObject:SetActive(false)
		end
		if box_effect2 ~= nil then
			box_effect2.gameObject:SetActive(false)
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_02", box_status == 2)
		if box_status == 2 then
			if box_effect ~= nil then
				box_effect.gameObject:SetActive(true)
			end
			if box_effect2 ~= nil then
				box_effect2.gameObject:SetActive(true)
			end
		end
	end
end

function M:initAXianPos()
	local trans = self.itemNodeList[self.m_model.cur_position].transform
	self.axian_head_img.transform.localScale = Vector3(1,1,1);
	self.axian_head_img.transform.localRotation = Quaternion.Euler(0,0,0)
	self.axian_head_img.transform.localPosition = trans.localPosition
	self:refreshSelRewardBg(self.m_model.cur_position)
end

-- 刷一下选中获得奖励的底板
function M:refreshSelRewardBg(index)
	for i = 1, 14 do
		if self.selImgList[i] then
			if i <= index then
				self.selImgList[i]:SetActive(true)
			else
				if i ~= 1 and i ~= 14 then
					self.selImgList[i]:SetActive(false)
				end
			end
		end
	end
end

function M:setAXianPos(reward)
	if self.m_model.cur_position < self.m_model.last_position then
		if self.itemNodeList[self.m_model.cur_position+1] then
			self:moveTo(self.axian_head_img, self.itemNodeList[self.m_model.cur_position+1], self.m_model.cur_position +1, reward)
		end
	else
		if self.m_model.cur_position+1 > 14 then
			local function callBack()
				self.m_model.cur_position = 0
				self:refreshUI() -- 刷一下格子奖励
				self:refreshSelRewardBg(1) -- 刷一下选中获得奖励的底板
				self:moveTo(self.axian_head_img, self.itemNodeList[self.m_model.cur_position+1], self.m_model.cur_position +1, reward)
			end 
			self:updateMsg("next_layer",{callBack = callBack})
		else
			if self.itemNodeList[self.m_model.cur_position+1] then
				self:moveTo(self.axian_head_img, self.itemNodeList[self.m_model.cur_position+1], self.m_model.cur_position +1, reward)
			end
		end
	end
end

function M:moveTo(obj_1, obj_2, index, reward)
	local sequence = Tweening.DOTween.Sequence()
	sequence:Append(obj_1.transform:DOScale(0.2, Time_1):SetEase(Tweening.Ease.OutSine))
	sequence:Join(obj_1.transform:DOLocalMove(obj_2.transform.localPosition, Time_2):SetEase(Tweening.Ease.OutSine))
	sequence:Join(obj_1.transform:DOScale(1, Time_1):SetEase(Tweening.Ease.OutSine))
	sequence:OnComplete(function ()
		self.m_model.cur_position = index
		self.selImgList[self.m_model.cur_position]:SetActive(true)
		if self.m_model.last_position ~= self.m_model.cur_position then
			self:setAXianPos(reward)
		elseif self.m_model.last_position == self.m_model.cur_position then
			if reward then
				RewardUtil:rewardTipsByData(reward)
			end
			self:refreshAllRedPoint()
			self:unlockTouch()
		end
	end)
	sequence:SetAutoKill(true)
end

function M:updateTime()
	local end_ts = self.m_model:getEndTs()
	if end_ts >= 0 then
		local text = GameUtil:formatTimeBySecond(end_ts)
		text = Language:getTextByKey("new_str_0919") .. text
		self:setTextByLanKey("time_text", text)
	else
		self:setTextByLanKey("time_text", "new_str_0558")
	end
end

function M:destroy()
    if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	self.itemNodeList = {}
	self.selImgList = {}
    M.super.destroy(self)
end



return M