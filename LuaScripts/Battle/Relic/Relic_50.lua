--退魔之矢
--乙方后排中间英雄的普工回移除目标身上的增益buf
---@class Relic_50 : Relic @
---@field super Relic @Relic
local M = class("Relic_50", Relic)
M.player = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
end

function M:gameStart()
	M.super.gameStart(self)
	EventDispatcher:registerEvent("injure", {self,self.injureHandler})
	
	local data =
	{
		["count"] = "one",
		["camp"] = "self",
		["pos"] = "position3",
		["race"] = "all",
		["profession"] = "all",
		["area"] = "all",
	}
	self.targets = self.mgr:getTargetData(data)
	if self.targets.Count > 0 then
		self.player = self.targets:get(0)
	end
end

function M:injureHandler(eventName, data)
	local killer = data["killer"]
	local victim = data["victim"]
	if self.player:isLive() then
		if self.player:equal(killer) and killer.curSkillConfig ~= nil and killer.curSkillConfig.anim_name == "attack1" then
			if victim ~= nil then
				victim.bufMgr:removeBufByTag("buff")
			end
		end
	end
end

function M:gameover()
	M.super.gameover(self)
	EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M