---@class PetGetNewPopModel: OODataBase
local M = class("PetGetNewPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_pet_id = self.m_params.pet_id
	self.m_cid = self.m_params.cid
	self.is_new = self.m_params.is_new or false
end

function M:getPetData()
	local pet_data = nil
	local pet_cfg = nil
	if self.m_pet_id then
		pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_pet_id)
	elseif self.m_cid then
		pet_cfg = UserDataManager.pet_data:getPetConfigByCid(self.m_cid)
	end
	return pet_data, pet_cfg
end


return M