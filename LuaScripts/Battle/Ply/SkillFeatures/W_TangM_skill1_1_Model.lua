
---@class W_TangM_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TangM_skill1_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.buffId = self:getParam(1)
	self.buffCount = self:getParam(2)
	EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:injureHandler(eventName, data)
	local ply = data["killer"]
	local victim = data["victim"]
	local skillConfig = data["attackData"]["skillConfig"]
	if ply ~= nil and ply:equal(self.player) and skillConfig ~= nil and skillConfig.anim_name == "skill1" then
		if victim ~= nil then
			--for i = 1, self.buffCount do
			--	victim.bufMgr:addBufById(self.buffId, self.player)
			--end
		end
	end
end

function M:destroy()
	M.super.destroy(self)
	EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

--M.atk = nil
--
--function M:init(ply, skill)
--    M.super.init(self, ply, skill)
--	self.atk = self:getParam(1)
--	EventDispatcher:registerEvent("markWork", {self,self.markWorkHandler})
--end
--
--function M:update(dt,unsdt)
--    M.super.update(self, dt, unsdt)  
--end
--
----条件触发
--function M:markWorkHandler( eventName, data )
--	local buff = data["buf"]
--	if self.player:equal(buff.source) then
--		--延迟给伤害，目的是和特效时间匹配
--		TimeTools:delayTime(0.1,
--				function()
--					local attackData = {}
--					attackData["damage"] = self.player.data.atk:getValue() * self.atk
--					attackData["player"] = self.player
--					attackData["damageFront"] = 1
--					attackData["damageLast"] = 1
--					attackData["angerAir"] = 0
--					attackData["type"] = 0
--					attackData["skillConfig"] = buff.sourceSkill
--					attackData["injureBuf"] = 0
--					attackData["damageType"] = self.skill.atk_type
--					--attackData["hitAudio"] = "skill2_mingzhong"
--					StateSoundManager:playSkillSound("skill2_mingzhong", self.player)
--					if buff.player ~= nil then
--						buff.player:injure(attackData)
--						self:changeFunc(buff)
--					end
--				end)
--	end
--end
--
--function M:changeFunc(buff)
--	-- body
--end
--
--function M:destroy()
--    M.super.destroy(self)
--    EventDispatcher:unRegisterEvent("markWork", {self,self.markWorkHandler})
--end


return M