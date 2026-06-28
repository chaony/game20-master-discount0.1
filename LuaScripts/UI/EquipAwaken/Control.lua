local M = class("EquipAwakenControl",LikeOO.OOControlBase)

function M:onEnter()
	if self.m_model.m_hero_oid == nil or self.m_model.m_pos == nil then
		self:openView("EquipAwaken.ArtifactBookPop")
	end
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:updateMsg("red_point_update", nil, "MagicWeaponSelectMain")
		self:closeView()
	elseif msg == "guide_btn" then --快速导航
		local function closeCallback()
			static_rootControl:closeView("MagicWeaponSelectMain")
			self:updateMsg("close_btn", nil, "parent")
			self:updateMsg(99999)
		end
		self:openView("WorldMap.WorldMapGuide", {close_parent_view_func = closeCallback, pop_from_func_id = -1})
	elseif msg == "tag_btn" then
		if self.m_model.tag_index ~= data then
			self.m_model.tag_index = data
			self.m_model.select_index = 1
			self.m_view:refreshUI()
		end	
	elseif msg == "select_eqp" then
		audio:SendEvtUI("UI_Tab_N5")
		if self.m_model.select_index ~= data then
			self.m_model.select_index = data
			self.m_view:refreshUI()
		end	
	elseif msg == "awaken_btn" then
		self:netAwaken()
	elseif msg == "art_btn" then
		self:openView("EquipAwaken.ArtifactBookPop")	
	elseif msg == "tips_btn" then
		self.m_view:showTips(true)
	elseif msg == "tips_close_btn" then
		self.m_view:showTips(false)
	elseif msg == "thrones_phase_btn" then
		self.m_view:showThronesTips(true)
	elseif msg == "thrones_info_mask" then
		self.m_view:showThronesTips(false)
	elseif msg == "red_point_update" then
		self.m_view:refreshRedPoint()
	end
end

function M:netAwaken()	
	local can_awake, type = self.m_model:canAwakenIng() 
	if can_awake == true then
		local cur_equip_data = self.m_model:getCurEquip()
		local function netCallback()
			if cur_equip_data.hero_id and cur_equip_data.pos then
				local function callfunc()
					audio:SendEvtUI("UI_Sfx_JX")
					self.m_view:playAwakenAnim(function ()
							-- 升阶成功
						self:openView("EquipAwaken.EquipAwakenPop", {equip_data = cur_equip_data} )	
						self.m_model:updateData()
						self.m_view:playExit()
						self.m_view:refreshUI()
					end)
				end
				self.m_model:getNetData("awake",{ hero_oid = cur_equip_data.hero_id, pos = tonumber(cur_equip_data.pos) }, callfunc)			
			elseif cur_equip_data.equ_data and cur_equip_data.equ_data.oid then
				local function callfunc()
					audio:SendEvtUI("UI_Sfx_JX")
					self.m_view:playAwakenAnim(function ()
						-- 升阶成功
						self:openView("EquipAwaken.EquipAwakenPop", {equip_data = cur_equip_data})	
						self.m_model:updateData()
						self.m_view:playExit()
						self.m_view:refreshUI()
					end)
				end
				self.m_model:getNetData("awake",{ equip_oid = cur_equip_data.equ_data.oid }, callfunc)			
			end
		end
		local cur_equip_data = self.m_model:getCurEquip()
		local equip_name = Language:getTextByKey(cur_equip_data.equ_cfg.name)
		local params = {
			text = Language:getTextByKey("equip_str_050",equip_name),
			tow_close_btn = true,
			on_ok_call = function ()
				netCallback()
			end
		}
		self:openView("Pops.CommonPop", params)
	else
		if type == 2 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("compass_str_002"), delay_close = 2})		
		elseif type == 1 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_str_041"), delay_close = 2})
		else
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_str_041"), delay_close = 2})	
		end
	end
end

return M
