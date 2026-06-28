--- 法宝信息查看
local M = class("LookWeaponInfoTips",LikeOO.OOUIbase)

M.m_uiName = "Common/LookWeaponInfoTips"
M.m_sortOrder = 19999

function M:onCreate()
	self.temp_pos = nil
	self.m_content = self:findGameObject("content")
	self.base_obj_fitter = self.m_content:GetComponent("ContentImmediate")
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
	self:refreshUI() 
end

function M:refreshUI()
	self.m_content.transform.localPosition = Vector3.New(100000,10000,0)
	local wea_data, wea_cfg = self:getWeaRelics(self.m_params.wea_id)
	if wea_cfg == nil then
		self:destroy()
		return 
	end
	local lv = 1
	if wea_data then
		lv = wea_data.lv
	end
	local cur_wea_cfg = wea_cfg.detail[lv]
	self:setTextByLanKey("title_text", Language:getTextByKey(cur_wea_cfg.name_tips).."("..lv.."/"..cur_wea_cfg.skill_limit..")" )
	if cur_wea_cfg.att then
		for i = 1,3 do
			if cur_wea_cfg.att[i] then
				local cur_atr_data = cur_wea_cfg.att[i]
				local atr_key = GameUtil:getAttrsKey(cur_atr_data[1])
				local atr_name = GameUtil:getAttrsName(atr_key)
				local cur_num = cur_atr_data[2] or 0
				if GameUtil:canPerAttrTransition(atr_key) == true then
					cur_num = cur_num*100
				end
				if GameUtil:attrTransition(atr_key) == true then 
					self:setTextByLanKey("attr_num_"..i, GameUtil:formatNum(cur_num).."%")
				else
					self:setTextByLanKey("attr_num_"..i, GameUtil:formatNum(cur_num))
				end
				self:setTextByLanKey("attr_name_"..i, atr_name)
			end
		end
	end
	local skill_cfg = self:getSkillDataById(cur_wea_cfg.skill_id)
	if skill_cfg then
		self:setTextByLanKey("skill_des",  skill_cfg.des)
		self:setTextByLanKey("skill_name", skill_cfg.name)
		self:setTextByLanKey("skill_lv", lv)
		self:setImg(skill_cfg.icon, "skill_icon","skill_icon")
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

--法宝数据
function M:getWeaRelics(id)
    local tab_cfg = ConfigManager:getCfgByName("treasure_config")
    return UserDataManager.m_relics[tostring(id)], tab_cfg[id]
end

function M:getSkillDataById(id)
	local tab_cfg = ConfigManager:getCfgByName("heirloom")
	return tab_cfg[id]
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