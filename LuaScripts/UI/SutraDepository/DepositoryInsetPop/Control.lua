local M = class("MeridianListControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		if self.m_model.m_callback then
			self.m_model.m_callback()	
		end
        self:closeView()
    elseif msg == "wear_equip" then 
    	self:putOnEqp(data)
    elseif msg == "replace_equip" then 
    	self:putOnEqp(data)
	elseif msg == "loop_depository" then
		self:openView("SutraDepository.DepositoryPop", data)
	elseif msg == "group_detail_btn" then
		local mystic_group = self.m_model:getMysticBuffGroupById(self.m_model.m_mystic_data.id)
		if mystic_group then
			self:openView("SutraDepository.DepositoryGropSkillTips", {id = self.m_model.m_mystic_data.id})
		end
	elseif msg == "group_list_detail_btn" then
		local mystic_group = self.m_model:getMysticBuffGroupById(data.mystic.id)
		if mystic_group then
			self:openView("SutraDepository.DepositoryGropSkillTips", {id = data.mystic.id})
		end
	elseif type(msg) == "number" and msg >= 1 and msg <= 4 then
		self:switchTabBtn(msg)
	end
end

-- 按钮切换
function M:switchTabBtn(index)
	if self.m_model.m_sel_tab_index ~= index then
		self.m_model.m_sel_tab_index = index
		self.m_view:switchTabNode(index)
	end
end

function M:putOnEqp(data)
	local function callfunc()
		local up_flag = UserDataManager.mystic_data:getWaitUpBuff(self.m_model.m_id)
		if up_flag then
			self:openView("SutraDepository.DepositorySkillUpgrade", {id = self.m_model.m_id})
		end
		self:updateMsg("update_mystic",nil,"HeroBag")
		self:updateMsg("update_data",nil,"SutraDepository")
		GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("mystic_str_0097"), delay_close = 2})
		self:updateMsg(99999)
	end
	local params = {}
	params.mystic_id = self.m_model.m_id
	params.mystic_oid = data.mystic.oid
	params.hero_oid = data.owner or ""
	params.pos = self.m_model.m_pos - 1
	params.mystic_oid_replace = self.m_model.m_oid or 0
	if data.owner then
		local params =
		{
			on_ok_call = function(msg)
				UserDataManager.mystic_data:waitUpMystic( self.m_model.m_id)
				self.m_model:getNetData("hero_mystic_inlay",params, callfunc)
			end,
			text = Language:getTextByKey("mystic_str_0094"),
		}
		self:openView("Pops.CommonPop", params)
	else
		UserDataManager.mystic_data:waitUpMystic( self.m_model.m_id)
		self.m_model:getNetData("hero_mystic_inlay",params, callfunc)
	end
end

return M
