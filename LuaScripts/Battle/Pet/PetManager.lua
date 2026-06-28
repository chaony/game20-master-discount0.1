

---@class PetManager @宠物管理器
---@field plyMgr PlayerManager_Model
---@field camp number 我方:1 敌方:-1
---@field curPet PlayerModel
local M = class("PetManager")

function M:init(plyMgr, camp)
	self.plyMgr = plyMgr
	self.camp = camp
end

---@param pet PlayerModel
function M:addPet(pet)
	if self.curPet ~= nil then
		Logger.logError("已经设置过宠物了：有且只有一个宠物")
	end
	self.curPet = pet
end

function M:hasPet()
	return self.curPet ~= nil and self.curPet:isLive()
end

function M:getCurPet()
	return self.curPet
end

function M:spawn(dyns)
	if self.curPet then
		self.curPet:spawn(dyns)
	end
end


function M:update(dt)
	if self.curPet then
		self.curPet:update(dt)
	end
end

function M:destroy(isDestoryObj)
	if self.curPet then
		self.curPet:destroy(true)
		self.curPet = nil
	end
end

return M
