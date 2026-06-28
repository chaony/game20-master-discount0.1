
--标记类buff
---@class BufWorkMark : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkMark", BufWork_Model)


function M:initFinish()
	--self.marks = {}
	self.effectList = {}
	self.count = 0
	self.maxCount = self.playerBuf:checkParam("maxCount", GlobalTools.base10000)
	self.time = self.playerBuf:checkParam("lifeTime", GlobalTools.base10000)
	self.interval = self.playerBuf:checkParam("interval", GlobalTools.base10000)
	self.showCount = self.playerBuf:checkParam("showCount", 0)
	self.intervalReduce = 0
	self.timer = {}
	self.effect = {}
end

function M:reset(  )
	M.super.reset(self)
	if self.count < self.maxCount then
		self.count = self.count + 1
		self:showBufIcon(true)

		EventDispatcher:dipatchEvent("markCount",{ count = self.count, source = self.playerBuf.source})
		local time = {}
		time.curTime = 0
		time.intervalTimer = 0
		table.insert(self.timer, time)
		
		self:dispatchEvent_Local(Battle.EventType.MV_BufWorkModelMarkPlayerEffect)
		
		if self.count == self.maxCount then
			EventDispatcher:dipatchEvent("markMax",{ buf = self.playerBuf})
		end
	end
end

--显示buf图标，子类重写
function M:addBufIcon()
end

--显示buf图标，子类重写
function M:removeBufIcon(count)
end

function M:update(dt)
	M.super.update(self,dt)
	if self.interval > 0 then
		for k,v in ipairs(self.timer) do
			v.curTime = v.curTime + dt
			v.intervalTimer = v.intervalTimer + dt
			if v.curTime >= self.interval - self.intervalReduce then
				v.curTime = 0
				self:work()
			end
			if v.intervalTimer >= self.time then
				self.count = self.count - 1
				self:showBufIcon(false, 1)

				EventDispatcher:dipatchEvent("markCount",{ buf = self.playerBuf})
				table.removebyvalue(self.timer, v)
				if self.count == 0 then
					self.playerBuf.player.bufMgr:removeBuf(self.playerBuf)
				end
			end
		end
	end
end

function M:work()
	M.super.work(self)
	EventDispatcher:dipatchEvent("markWork",{ buf = self.playerBuf })
end

function M:removeMark(count)
	if count > 0 then
		for k,v in ipairs(self.timer) do
			if count <= 0 then
				break
			end
			table.removebyvalue(self.timer, v)
			count = count - 1
			self.count = self.count - 1
		end
	else
		self.playerBuf.player.bufMgr:removeBuf(self.playerBuf)
	end
end

function M:stop()
	M.super.stop(self)
end

return M