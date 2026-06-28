--场景向导
--主要用于指引玩家去移动
--尤其是多人组队
---@class GuideModeBase_Model @
local M = class("GuideModeBase_Model")


function M:init( scene, mode )
	--模式
	-- 1 无线循环 
	-- 2 固定位置
	self.mode = mode;
	self.scene = scene
	self.config = scene:getHangUpConfig();
	--存到开始位置
	self.startPosition = FixVector3.New(0,0,0)
	--移动的最大距离
	self.maxLength = 120;
	--最大移动速度
	self.maxSpeed = 8
	--触发距离
	self.triggerDis = 6;
	--移动索引
	self.move_index = 0;
	--当前移动的点
	self.curMoveIndex = 0;
	--是否第一次移动
	self.fristMove = true
	--是否可以移动
	self.moving = false;

	self.monster_list =Battle.List.new()
	self.dir = 1;
	self.stageIdleData = GameUtil:getCurStageIdleData();
	local monster = self.stageIdleData.monster;
	for k,v in ipairs(monster) do
		if v.iid ~= 0 then
			self.monster_list:add(v);
		end
	end
	--设定位置之前，做的操作
	self:setPositionBefore();
	--初始化所有的点
	self:initPoints()
end

--初始化点
function M:initPoints()
	--固定点位置
	self.fix_pos_list = {}
	for i = 1, 3 do
		self.fix_pos_list[i] = FixVector3.New(0,0,0)
	end
	if self.scene:get_guideData() ~= nil then
		local guide_data = self.scene:get_guideData();
		local index = 0;
		for k,v in pairs( guide_data ) do
			index = k+1
			self.fix_pos_list[index].x = v.x;
			self.fix_pos_list[index].y = v.y;
			self.fix_pos_list[index].z = v.z;
		end
	end
end

--设定位置前,子类重写
function M:setPositionBefore()

end

--获取追踪点
function M:getPoint(index)
	if index >= 3 then
		index = 0
	end
	if index < 0 then
		index = 0;
	end
	--点的偏移量
	local position_fix = self.fix_pos_list[index+1]
	return self.position + position_fix
end

--设定方向
function M:set_dir( dir )
	if self.forward == nil then
		self.forward = FixVector3.New(0,0,0)
	end
	self.forward.x = dir.x;
	self.forward.y = dir.y;
	self.forward.z = dir.z;
end

function M:get_dir()
	return self.forward;
end

--设定位置
function M:setPos( pos , isForce )
	if self.position == nil then
		self.position = FixVector3.New(0,0,0);
	end
	self.position.x = pos.x;
	self.position.y = pos.y;
	self.position.z = pos.z;
	self.scene:dispatchEvent_Local(Battle.EventType.MV_SceneGuideModelSyncPosition, self)
end

--返回当前向导的位置
function M:get_position()
	local x = GlobalTools:ToFloat(self.position.x)
	local y = GlobalTools:ToFloat(self.position.y)
	local z = GlobalTools:ToFloat(self.position.z)
	return x, y, z;
end

--返回当前向导的位置
function M:getFixPosition()
	return self.position
end

--获取得人的方式
function M:getEnemyPointMode()
	
end

--offset 左右创建敌人
function M:enemyCreateRandom(x_offset, z_offset, monster, init_hp)
	if self.scene.mainPlayer ~= nil then
		local fix_pos = self.scene.mainPlayer.position
		if self.mode == 2 then
			fix_pos = self.position
		end
		local pos_x = fix_pos.x + x_offset;
		local pos_y = fix_pos.y;
		local pos_z = -GlobalTools.base3 + z_offset;
		if next(monster) ~= nil and monster.iid > 0 then
			local pos = FixVector3.New(0, 0, 0)
			pos.x = pos_x;
			pos.y = pos_y;
			pos.z = pos_z;
			local playerData = { id = monster.iid, evo = 0 }
			--创建一个敌人
			local enemy = self.scene.plyMgr:createPlayer(playerData, -1, nil, pos)
			self.checkEnemy = true;
			enemy:setForward( -FixVector3.right() )
			if init_hp then
				--设定最大血量
				enemy.data.hp:setInitialValue(init_hp)
			else
				-- 血量的倍率
				local hp_rate = GlobalTools.base6;
				local hangUpConfig = self.scene:getHandUpSceneConfig()
				if not IsNull(hangUpConfig) then
					hp_rate = GlobalTools:CommonToFix(hangUpConfig.enemyHpRate);
				end
				-- 攻击力
				local atk = self.scene.mainPlayer.data:get_atk()
				-- 总血量是攻击力 的 hp_rate 倍
				local hp = GlobalTools:Mul(atk , hp_rate)
				--设定最大血量
				enemy.data.hp:setInitialValue(hp)
			end
			--设定当前血量
			enemy.data:set_curHp(enemy.data:get_hp())
			--玩家开始运行
			enemy:spawn()
		end
	end
end


--开始移动
function M:play()
	if self.moving == false then
		self.moving = true
	end
end

--停止移动
function M:stop()
	if self.moving == true then
		self.moving = false
	end
end

--移动模式
function M:moveMode( dt )

end

--重置
function M:reset()

end

function M:moveBefore()

end

--更新导航
function M:update(dt,unsdt)
	self:moveBefore();
	if self.moving == true then
		self:moveMode(dt)
	end
end

--销毁
function M:destroy()


end

return M