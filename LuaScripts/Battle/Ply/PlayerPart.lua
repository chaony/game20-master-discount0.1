--角色的附属物品
---@class PlayerPart @
local M = class("PlayerPart")

M.player = nil

M.data = nil

M.mgr = nil

M.obj = nil

M.timer = nil

M.position = nil

M.grid = nil

function M:init(ply, data, mgr)
	self.player = ply
	self.data = data
	
	self.prefab = data["part"]
	self.lifeTime = (data["lifeTime"])
	self.speed = (data["speed"])
	self.maxDistance = (data["maxDistance"])
	self.playerFollow = data["playerFollow"] == true
	self.offset = FixVector3((data.targetPos.x), (data.targetPos.y), (data.targetPos.z))

	--self.obj = ResourceUtil:LoadRole3dEffect(self.player.plyType, self.prefab, nil)
	
	self.position = self:getTargetPos()

	local grid = SceneManager.curScene.aStar:setGrid(self.position, self.grid)
	if grid ~= nil then
		self:setGrid(grid)
	end
	
	self.timer = self.lifeTime

	if self.playerFollow then
		self.player:setFollowPart(self)
	end
end

function M:update(dt)
	if SceneManager:getCurSceneModel():get_sceneState() == 3 then
		if self.obj == nil then
			self.obj = ResourceUtil:LoadRole3dEffect(self.player.prefabRoot, self.prefab, nil)
			self:setPosition()
		else
			local dis = GlobalTools:Distance3D(self:getTargetPos(), self.position)
			if dis <= GlobalTools:ToFix2( self.maxDistance ) then
				self:checkAiState()
			else
				self:setPosition()
			end
			
			if self.timer > 0 then
				self.timer = self.timer - dt
				if self.timer <= 0 then
					self.mgr:remove(self)
				end
			end
		end
		
	end
end

--刷新显示位置
function M:setPosition()
	self.position = self:getTargetPos()

	local grid = SceneManager.curScene.aStar:setGrid(self.position, self.grid)
	if grid ~= nil then
		self:setGrid(grid)
	end
	
	if self.obj ~= nil then
		self.obj.transform.position = self.position:toVector3()
		self.obj.transform.forward = self.player:getForward():toVector3()
	end
end

--获取附属物位置
function M:getTargetPos()
	if self.player.camp == 1 then
		return self.player.position + self.offset
	else
		return self.player.position - self.offset
	end
end

--获取玩家位置
function M:getPlayerPos()
	local pos = nil
	if self.player.camp == 1 then
		pos = self.position - self.offset
	else
		pos = self.position + self.offset
	end
	return pos
end

function M:destroy()
	if self.playerFollow then
		self.player.followPart = nil
	end
	if self.obj ~= nil then
		ResourceUtil:ReturnItem(self.obj)
		self.obj = nil
	end
end

--检测玩家是否在附属物周围
function M:checkAiState()
	local pos = self:getPlayerPos()
	if pos ~= nil then
		--敌人和我的距离
		local distance = GlobalTools:Distance(pos, self.player.position )
		--我和敌人的方向
		--local dir = GlobalTools:Dir(pos,self.player.position)
		if distance > GlobalTools:ToFix2( 1 ) then
			if self.player.aiEngine.curState.key ~= "skill" and self.player.aiEngine.curState.key ~= "attack" and
					self.player.aiEngine.curState.key ~= "followPart" then
				self.player.aiEngine:changeState("followPart")
			end
		end
	end
end

--设定格子
function M:setGrid( gridData )
	if self.grid ~= nil then
		self.grid:setValue(0);
	end
	self.grid = gridData;
	if self.grid ~= nil then
		self.grid:setValue(1);
	end
end

return M