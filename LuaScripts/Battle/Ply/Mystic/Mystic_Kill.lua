--每击杀触发

---@class Mystic_Kill : Mystic
---@field super Mystic
local M = class("Mystic_Kill", Mystic)

function M:init(mgr, mysticCfg, mysticBufCfg)
	M.super.init(self, mgr, mysticCfg, mysticBufCfg)

	self.addBuff1 = self:getParam(1, 0)	--Buff[] 给自己加buff
	
	EventDispatcher:registerEvent("killPlayer", {self, self.killerPlayerHandler})
end

---@param data Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, data)
	if data.victim:isXiaKe() and self.player:equal(data.killer) then
		self.player.bufMgr:addBufById(self.addBuff1, self.player)
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("killPlayer", {self, self.killerPlayerHandler})
	M.super.destroy(self)
end

return M