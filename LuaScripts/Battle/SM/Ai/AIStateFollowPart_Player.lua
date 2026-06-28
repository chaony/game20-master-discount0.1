                                                                                                                                                   --AI的跟随附属物
local M = class("AIStateFollowPart_Player.lua",Battle.AIState)

M.anim_name = "run"

M.extra_anim_name = nil

M.skillConfig = nil

--进入移动状态
function M:enter()
	M.super.enter(self)
	--先将动作切换到站立
	if self.extra_anim_name == nil then
		self.player.animator:changeState(self.anim_name)
	else
		self.player.animator:changeState(self.extra_anim_name)
		self.extra_anim_name = nil
	end
end

function M:setPosition()
	M.super.setPosition(self)
end

--更新移动状态
function M:update(dt)
	M.super.update(self,dt)
	if self.player.followPart ~= nil then
		local pos = self.player.followPart:getPlayerPos()
		if pos ~= nil then
			--敌人和我的距离
			local distance = GlobalTools:Distance(pos, self.player.position )
			if distance < GlobalTools:ToFix2( GlobalTools.base0_1 ) then
				self.player.aiEngine:changeState("move")
			else
				--我和敌人的方向
				local dir = GlobalTools:Dir(pos,self.player.position)
				--玩家移动
				self.player:move_no_coillder(dir,dt)
				self.player:rotaTo(dir,dt);
			end
		else
			self.player.aiEngine:changeState("move")
		end
	else
		self.player.aiEngine:changeState("move")
	end
end


--退出当前状态
function M:exit()
	M.super.exit(self)
end



return M
