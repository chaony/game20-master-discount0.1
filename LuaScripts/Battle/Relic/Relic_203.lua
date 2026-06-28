--番天印
--战斗开始后，每隔20秒（等级提升间隔缩短，最短10秒）给敌方随机一人造成晕眩1秒效果，
--当被命中对象身上有流血、破甲、中毒这三种负面效果其中之一时，晕眩效果增加至2秒,
--且在之后5秒内受到的伤害提高30%

---@class Relic_203 : Relic @
---@field super Relic @Relic
local M = class("Relic_203", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	--没隔XX秒
	self.triggerTime = self:getValue(1)
	--眩晕效果1秒buf
	self.xuanyunBufId = self:getValue(2)
	--晕眩效果2秒buf
	self.xuanyunBigBufId = self:getValue(3)
	self.curTriggerTime = 0
end


function M:gameStart()
	self.curTriggerTime = self.triggerTime;
end


function M:update(dt, unsdt)
	if self.curTriggerTime and self.curTriggerTime > 0 then
		self.curTriggerTime = self.curTriggerTime - dt;
		if self.curTriggerTime <= 0 then
			self.enemyPlayers = self.mgr:getTarget("enemy", "all")
			local index = WRandom:randomNum(0,self.enemyPlayers.Count,true)
			local curPlayer = self.enemyPlayers:get(index)
			if curPlayer ~= nil then
				local zhongduBufs = curPlayer.bufMgr:findBufByTag("zhongdu");
				if #zhongduBufs > 0 then
					--眩晕2秒
					curPlayer.bufMgr:addBufById(self.xuanyunBigBufId, curPlayer)
				else
					local pojiaBufs = curPlayer.bufMgr:findBufByTag("pojia");
					if #pojiaBufs > 0 then
						--眩晕2秒
						curPlayer.bufMgr:addBufById(self.xuanyunBigBufId, curPlayer)
					else
						local liuxueBufs = curPlayer.bufMgr:findBufByTag("liuxue");
						if #liuxueBufs > 0 then
							--眩晕2秒
							curPlayer.bufMgr:addBufById(self.xuanyunBigBufId, curPlayer)
						else
							--眩晕1秒
							curPlayer.bufMgr:addBufById(self.xuanyunBufId, curPlayer)
						end
					end
				end
			end
			self.curTriggerTime = self.triggerTime;
		end
	end
end


return M