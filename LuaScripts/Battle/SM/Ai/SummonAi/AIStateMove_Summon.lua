--召唤物 移动AI基类
---@class AIStateMove_Summon : AIState @
---@field super AIState @AIState
local M = class("AIStateMove_Summon",Battle.AIState)

M.anim_name = "run"

--进入移动状态
function M:enter()
	M.super.enter(self)
	--先将动作切换到站立
	self.player.animator:changeState(self.anim_name)
	--设置动画速度
	local animSpeed = GlobalTools:Div( self.player.data:getSpd(), self.player.data:get_moveSpeed())
	
	self.offsetPos = FixVector3.New(0,0,0);
	self.offsetPos.x = self.player.summonData.offset.x;
	self.offsetPos.y = self.player.summonData.offset.y;
	self.offsetPos.z = self.player.summonData.offset.z;
	--设置动画速度
	self.player:setAnimSpeed( animSpeed )
end

--更新移动状态
function M:update(dt)
	M.super.update(self,dt)
	if self.player.summonData.follow == true and self.player.summonData.alwaysfollow == true then
		local x = self.player.summonData.offset.x
        if self.player.master ~= nil and self.player.master:getForward().x < 0  then
            x = GlobalTools:Mul(x , -GlobalTools.base1 )
			self.offsetPos.x = x;
        end
		
		local targetPos = self.player.master.position + self.offsetPos
		local dist = GlobalTools:Distance(self.player.position, targetPos)
		if dist <= GlobalTools:ToFix2( GlobalTools.base0_5 ) then
			self.player.aiEngine:changeState("idle")
		else
			local dir = GlobalTools:Dir(targetPos, self.player.position)
			--玩家移动
			self.player:move_no_coillder(dir,dt)
			self.player:rotaTo(dir, dt);
		end
	end
end

--退出当前状态
function M:exit()
	M.super.exit(self)
	--还原动画速度
	self.player:setAnimSpeed( GlobalTools.base1 )
end


return M