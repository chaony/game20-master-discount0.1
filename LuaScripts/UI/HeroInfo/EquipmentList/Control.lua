local M = class("EquipmentListControl",LikeOO.OOControlBase)

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
    	self:replaceEqp(data)
    end
end

--穿上装备 hero_oid: 英雄唯一id equip_oid: 装备唯一id auto: 一键穿装, 0:穿指定装备，1：一键穿装
function M:putOnEqp(data)
	local function callfunc()
		self:updateMsg("update_equip",true,"HeroBag")
		self:updateMsg(99999)
	end
	self.m_model:getNetData("hero_equip_wear",{hero_oid = self.m_model.m_heroid, equip_oid = data.oid}, callfunc)
end

--替换装备 hero_oid，pos，equip_owner
function M:replaceEqp(data)
	local function callfunc()
		self:updateMsg("update_equip",true,"HeroBag")
		self:updateMsg(99999)
	end
	self.m_model:getNetData("hero_equip_wear",{hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos, equip_owner = data.owner}, callfunc)
end

return M
