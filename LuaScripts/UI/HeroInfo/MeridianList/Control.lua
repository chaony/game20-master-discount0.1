---@class MeridianListControl OOControlBase
---@field m_model MeridianListModel
local M = class("MeridianListControl",LikeOO.OOControlBase)

function M:onEnter()
	self.m_guide_file_name = "UI.HeroInfo.MeridianList.Guide"
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		if self.m_model.m_callback then
			self.m_model.m_callback()	
		end
        self:closeView()
    elseif msg == "wear_equip" then
		if self.m_model.is_replace then
			self:replaceEqp(data)
		else
			self:putOnEqp(data)
		end

    elseif msg == "replace_equip" then 
    	--self:putOnEqp(data)
		self:openView("HeroInfo.MysticReplacePop",data)
		--self:closeView()
	elseif msg == "loop_depository" then
		self:openView("SutraDepository.DepositoryPop", data)
	elseif msg == "group_detail_btn" then
		local mystic_group = self.m_model:getMysticBuffGroupById(self.m_model.m_eqp_data.id)
		if mystic_group then
			self:openView("SutraDepository.DepositoryGropSkillTips", {id = self.m_model.m_eqp_data.id})
		end
	elseif msg == "group_list_detail_btn" then
		local mystic_group = self.m_model:getMysticBuffGroupById(data.id,data.star)
		if mystic_group then
			self:openView("SutraDepository.DepositoryGropSkillTips", {id = data.id})
		end
	end
end

-- 英雄-穿戴秘籍 hero_oid: 英雄唯一id pos: 位置，1-3 mystic_id: 秘籍id
function M:putOnEqp(data)
	local function callfunc()
		self:updateMsg("update_mystic",{state = "up",pos = self.m_model.m_pos},"HeroBag")
		self:updateMsg(99999)
	end
	local mystic_owner=self.m_model.m_heroid
	if data.owner~=nil then
		mystic_owner=data.owner
	end
	self.m_model:getNetData("hero_mystic_wear",{hero_oid = self.m_model.m_heroid,
												pos = self.m_model.m_pos ,mystic_id = data.id, mystic_owner =mystic_owner},
			callfunc)
end


function M:replaceEqp(data)
	local params = {hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos}
	local function putCallback(response)
		self:updateMsg("update_mystic",{state = "down"},"HeroBag")
		self:putOnEqp(data)
	end
	self.m_model:getNetData("hero_mystic_down", params, putCallback)
end

return M
