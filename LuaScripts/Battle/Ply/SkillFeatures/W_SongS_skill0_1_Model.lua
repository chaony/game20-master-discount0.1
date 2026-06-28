--当嵩山的生命值低于30%时，会立即使用寒冰真气冰封自身4秒，
--期间无法攻击也不会受到任何伤害，并每秒恢复最大生命值的15%，
--每场战斗仅可触发1次。
---@class W_SongS_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_SongS_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hpRate =  self:getParam(1) --生命比例
    self.maxTime = self:getParam(2) -- 冰冻时长
    self.buffid =  self:getParam(3) --无敌buf
    self.buffid1 = self:getParam(4) --免疫控制buf
    self.buffid2 = self:getParam(5) --生命回复buf
    self.buffid6 = self:getParam(6) --伤害buf
    self.buffid7 = self:getParam(8) --无法选中buf
    self.buff1 = {}
    self.time = 0
    self.start = false
    self.skill_Start = false
end


function M:canUse()
    return false
end


function M:update(dt)
	if self.start == false then
		local hp_value = GlobalTools:Mul( self.player.data:get_hp(), self.hpRate )
		local imprison = self.player.bufMgr:findBufByType("Imprison")
		if self.player.data:get_curHp() <= hp_value and #imprison == 0 then
			local buff = self.player.bufMgr:addBufById(self.buffid1, self.player)
			if buff ~= nil then
				table.insert(self.buff1, buff)
			end
			local buff = self.player.bufMgr:addBufById(self.buffid, self.player)
			if buff ~= nil then
				table.insert(self.buff1, buff)
			end
			buff = self.player.bufMgr:addBufById(self.buffid2, self.player)
			if buff ~= nil then
				table.insert(self.buff1, buff)
			end
			buff = self.player.bufMgr:addBufById(self.buffid7, self.player)
			if buff ~= nil then
				table.insert(self.buff1, buff)
			end
			self.start = true
			self.skill_Start = true;
			self.player.inDebuff = true;
			self.player.aiEngine:changeState("debuff")

			-- 检查触发天命化星
			if self.player.skyStar then
				self.player.skyStar:triggerStart(self)
			end
		end
    end
    if self.skill_Start then
    	self.time = self.time + dt
    	self:altersBuf(dt)
    	if self.time >= self.maxTime then
    		for k,v in ipairs(self.buff1) do
	            if v ~= nil then
	                self.player.bufMgr:removeBuf(v)
	            end
          	end
			self.player.inDebuff = false;
			--self.start = false
			self.skill_Start = false
			self.time = GlobalTools.base0
			self.player.aiEngine:changeState("patrol")
    	end
    end
end


--技能释放
function M:skillStart(data)
	--self.start = false
    --self.skill_Start = true
end


function M:altersBuf( dt )
	-- body
end


function M:destroy()
	M.super.destroy(self)
end

return M