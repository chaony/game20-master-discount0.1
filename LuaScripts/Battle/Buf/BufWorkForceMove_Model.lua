--强制移动
---@class BufWorkForceMove : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkForceMove", BufWork_Model)


function M:initFinish()

	self.moveDir = self.playerBuf:checkParam("attackMoveDir", "forward")

	local curve = {}
	curve.type = self.playerBuf:checkParam("buffCurveMoveType", "line")
	curve.distance = self.playerBuf:checkParam("buffCurveMoveDistance", 0)
	curve.time = self.playerBuf:checkParam("buffCurveMoveTime", 0)

	self:setDir()
	curve.dir = self.dir
	self.playerBuf.player.curveMgr:add(curve)

	--切换ai状态
	self.playerBuf.player.aiEngine:changeState("debuff")
end

function M:setDir()
	if self.moveDir == "forward" then
		if self.useSceneDir then
			self.dir = FixVector3.forward()
		else
			self.dir = self.playerBuf.player:getForward()
		end
	elseif self.moveDir == "back" then
		if self.useSceneDir then
			self.dir = FixVector3.forward() * -GlobalTools.base1
		else
			self.dir = self.playerBuf.player:getForward() * -GlobalTools.base1
		end
	elseif self.moveDir == "left" then
		if self.useSceneDir then
			self.dir = FixVector3.right() * -GlobalTools.base1
		else
			self.dir = self.playerBuf.player:getRight() * -GlobalTools.base1
		end
	elseif self.moveDir == "right" then
		if self.useSceneDir then
			self.dir = FixVector3.right()
		else
			self.dir = self.playerBuf.player:getRight()
		end
	end
end

function M:rangeValueBig( value )
	return GlobalTools:Mul(value, GlobalTools.base100 )
end

function M:rangeValueSmall( value )
	return GlobalTools:Div( value, GlobalTools.base100 );
end


function M:stop()
	M.super.stop(self)
	local imprison = self.playerBuf.player.bufMgr:findBufByType("Imprison")
	if table.nums(imprison) < 1 and (self.playerBuf.player.aiEngine.curState.key ~= "debuff" and self.playerBuf.player.aiEngine.curState.key ~= "injureMove") then
		self.playerBuf.player.aiEngine:changeState("move")
	end
end

return M