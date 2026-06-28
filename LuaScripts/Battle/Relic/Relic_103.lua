--阴阳镜
--战斗开始时获得阴阳镜其中之一：
--基础效果：敌对所有侠客伤害降低15%、防御降低20%（满级对面伤害降低25%，伤害降低30%）
--阴效果：我方生命提高10%（满级我方生命提高20%）
--阳效果：我方伤害增加10%（满级我方生命提高15%）

---@class Relic_103 : Relic @
---@field super Relic @Relic
local M = class("Relic_103", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	--降低敌方侠客属性的buf
	self.enemyBufId = self:getValue(1)
	--阴效果
	self.yinBufId = self:getValue(2)
	--阳效果
	self.yangBufId = self:getValue(3)
	--阴条件
	self.yinCondition = self:getValue(4)
	--阳条件
	self.yangCondition = self:getValue(5)
	--阴阳同时激活效果
	self.yinYangBuffId = self:getValue(6)
end

function M:gameStart()
	local players = self.mgr:getTarget("enemy", "all")
	for i=1,players.Count do
		local ply = players:get(i-1)
		ply.bufMgr:addBufById(self.enemyBufId, ply)
	end
	--计算我方有几个阴阳侠客
	local yinCount = 0;
	local yangCount = 0;
	local players = self.mgr:getTarget("self", "all")
	for i=1,players.Count do
		local ply = players:get(i-1)
		if ply.master == nil then
			if ply.plyData.race == 6 or ply.plyData.race == 7 then
				yinCount = yinCount + 1;
			end
			if ply.plyData.race == 5 or ply.plyData.race == 7then
				yangCount = yangCount + 1;
			end
		end
	end


	if yinCount >= self.yinCondition and yangCount >= self.yangCondition then
		--预留阴阳效果
		self:triggerYinYangSkill()
	else
		if yinCount >= self.yinCondition then
			self:triggerYinSkill()
		elseif yangCount >= self.yangCondition then
			self:triggerYangSkill()
		else
			local players = self.mgr:getTarget("self", "all")
			for i=1,players.Count do
				local ply = players:get(i-1)
				self:playEffect(ply)
			end
		end
	end
end

--触发阴技能
function M:triggerYinSkill()
	local players = self.mgr:getTarget("self", "all")
	for i=1,players.Count do
		local ply = players:get(i-1)
		ply.bufMgr:addBufById(self.yinBufId, ply)
	end
end

--触发阳技能
function M:triggerYangSkill()
	local players = self.mgr:getTarget("self", "all")
	for i=1,players.Count do
		local ply = players:get(i-1)
		ply.bufMgr:addBufById(self.yangBufId, ply)
	end
end

---阴阳同时激活效果
function M:triggerYinYangSkill()
	local players = self.mgr:getTarget("self", "all")
	for i=1,players.Count do
		local ply = players:get(i-1)
		ply.bufMgr:addBufById(self.yinYangBuffId, ply)
	end
end

return M