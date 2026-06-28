---@class TargetCheck_Model @范围检测
local M = class("TargetCheck_Model")

M.player = nil

M.triggerTable = nil

function M:init(player)
	self.player = player
	self.triggerTable = {}
end

--添加检测
function M:addTrigger(data, attackData)
	local trigger = {}
	
	trigger.shape = data["shape"]
	local center = data["center"]
	local dir = data["direction"]
	--玩家位置时偏移以玩家前方为基准偏移，其他以世界方向为基准
	local offect = data["offset"]
	local offect_fix = FixVector3.New(0,0,0);
	offect_fix.x = offect.x;
	offect_fix.y = offect.y;
	offect_fix.z = offect.z;
	data["radius"] = 3481
	if center == "player" then
		self:setCenter(trigger, self.player.position + offect_fix)
	elseif center == "sceneCenter" then
		self:setCenter(trigger, SelectTargetTool:findFixPoint(self.player, "sceneCenter"))
	elseif center == "sceneEdge" then
		local scene = SceneManager.curScene
		local min_top_x,max_top_x = scene:getMinMaxXByZ(scene.top)
		local min_bottom_x,max_bottom_x = scene:getMinMaxXByZ(scene.bottom)
		local top = FixVector3.zero()
		top.x = min_top_x
		top.z = scene.top
		local bottom = FixVector3.zero()
		bottom.x = min_bottom_x
		bottom.z = scene.bottom
		local left = (top + bottom)/GlobalTools.base2
		
		top.x = max_top_x
		bottom.x = max_bottom_x
		local right = (top + bottom)/GlobalTools.base2
		
		if self.player.forward.x > 0 then
			self:setCenter(trigger, left)
		else
			self:setCenter(trigger, right)
		end
	elseif center == "custom" then
		
	elseif center == "Densearea" then
		local point = SelectTargetTool:findFixPoint(self.player, "Densearea", data["radius"])
		if point == nil then
			self:setCenter(trigger, SelectTargetTool:findFixPoint(self.player, "enemyCenter"))
		else
			self:setCenter(trigger, point)
		end
	end

	if string.match(center, "scene") ~= nil then
		self:setCenter(trigger, trigger.center + offect_fix )
	end

	trigger.dir = FixVector3.New(0, 0, 0)
	if dir == "forward" then
		local dir_temp = FixVector3.New(0, 0,0)
		dir_temp.x = self.player:getForward().x
		local dir_normalize = FixVector3.Normalize(dir_temp)
		if string.match(center, "scene") == nil then
			trigger.dir.x = dir_normalize.x
			trigger.dir.z = dir_normalize.y
			trigger.dir.y = dir_normalize.z
		else
			trigger.dir.x = dir_normalize.x
			trigger.dir.z = dir_normalize.y
			trigger.dir.y = dir_normalize.z
		end
	elseif dir == "right" then
		local dir_temp = FixVector3.New(0, 0,0)
		dir_temp.x = self.player:getRight().x
		local dir_normalize = FixVector3.Normalize(dir_temp)
		if string.match(center, "scene") == nil then
			trigger.dir.x = dir_normalize.x
			trigger.dir.z = dir_normalize.y
			trigger.dir.y = dir_normalize.z
		else
			trigger.dir.x = dir_normalize.x
			trigger.dir.z = dir_normalize.y
			trigger.dir.y = dir_normalize.z
		end
	end

	if trigger.shape == "circular" then
		trigger.innerRadius = data["innerRadius"] or 0
		trigger.radius = data["radius"] or 0
		trigger.radiusSpeed = data["radiusExpandSpeed"] or 0
	elseif trigger.shape == "rect" then
		trigger.length = data["length"] or 0
		trigger.weight = data["weight"] or 0
		trigger.lengthSpeed = data["lengthExpandSpeed"] or 0
		trigger.weightSpeed = data["weightExpandSpeed"] or 0
	end
	--
	trigger.speed = data["speed"] or 0
	trigger.time = data["time"] or GlobalTools.base1
	trigger.curTime = 0
	trigger.height = data["height"] or 0
	trigger.backTime = data["backTime"] or 0
	
	if self.player.camp == 1 then
		trigger.camp = -1
	else
		trigger.camp = 1
	end
	
	trigger.callback =
	function(ply, hitPos, t)
		--attackData["injurePosition"] = hitPos
		attackData["injureDir"] = GlobalTools:Dir(ply.position, self.player.position)
		ply:injure( attackData )
	end

	--trigger.obj = ResourceUtil:LoadRole3dBullet(self.player.prefabRoot, "TargetCheck_"..trigger.shape, nil)
	--
	--if trigger.shape == "circular" then
	--	trigger.obj.transform.localScale = trigger.obj.transform.localScale * trigger.radius
	--elseif trigger.shape == "rect" then
	--	local scale = trigger.obj.transform.localScale
	--	scale.z = trigger.weight * 2
	--	scale.x = trigger.length
	--	trigger.obj.transform.localScale = scale
	--end
	--
	table.insert(self.triggerTable, trigger)
end

function M:setCenter( trigger, pos )
	if trigger.center == nil then
		trigger.center = FixVector3.New(0,0,0);
	end
	trigger.center.x = pos.x;
	trigger.center.y = pos.y;
	trigger.center.z = pos.z;
end


--移除一个检测
function M:removeTrigger(trigger)
	--if trigger.obj ~= nil then
	--	ResourceUtil:ReturnItem(trigger.obj)
	--end
	table.removebyvalue(self.triggerTable, trigger)
end

function M:update(dt)
	local list = nil
	for k,v in ipairs(self.triggerTable) do
		if v.curTime <= v.time then
			v.curTime = v.curTime + dt
			if v.backTime > 0 then
				v.backTime = v.backTime - dt
				if v.backTime <= 0 then
					v.dir = v.dir * -GlobalTools.base1
					v.hasList = {}
				end
			end
			if v.camp == 1 then
				list = SceneManager.curScene.plyMgr.hero_list
			elseif v.camp == -1 then
				list = SceneManager.curScene.plyMgr.enemy_list
			else
				list = SceneManager.curScene.plyMgr.hero_list:clone()
				for i = 1, SceneManager.curScene.plyMgr.enemy_list.Count do
					list:add(SceneManager.curScene.plyMgr.enemy_list:get(i - 1))
				end
			end
			
			for i = 1, list.Count do
				local ply = list:get(i - 1)
				if ply ~= nil then
					--真正的检测
					if v.shape == "circular" then
						self:circularCheck(v, ply)
					elseif v.shape == "rect" then
						self:rectCheck(v, ply)
					end
				end
			end
			local dir_speed = v.dir * v.speed
			local dir_speed_dt = dir_speed * dt;
			local center_add_dir = v.center + dir_speed_dt;
			--if SceneManager:getCurSceneModel():get_loopTimeNormal() >= 83 and SceneManager:getCurSceneModel():get_loopTimeNormal() <= 87  then
			--	Logger.logError(" 设定 dir_speed ("..dir_speed.x..","..dir_speed.y..","..dir_speed.z..") F "..SceneManager:getCurSceneModel():get_loopTimeNormal() )
			--end
			--if SceneManager:getCurSceneModel():get_loopTimeNormal() >= 83 and SceneManager:getCurSceneModel():get_loopTimeNormal() <= 87  then
			--	Logger.logError(" 设定 dir_speed_dt ("..dir_speed_dt.x..","..dir_speed_dt.y..","..dir_speed_dt.z..") F "..SceneManager:getCurSceneModel():get_loopTimeNormal() )
			--end
			--if SceneManager:getCurSceneModel():get_loopTimeNormal() >= 83 and SceneManager:getCurSceneModel():get_loopTimeNormal() <= 87  then
			--	Logger.logError(" 设定 dir ("..v.dir.x..","..v.dir.y..","..v.dir.z..") F "..SceneManager:getCurSceneModel():get_loopTimeNormal() )
			--end
			self:setCenter(v, center_add_dir)
				
			if v.shape == "circular" then
				v.radius = v.radius + GlobalTools:Mul( v.radiusSpeed, dt)
			elseif v.shape == "rect" then
				v.length = v.length + GlobalTools:Mul(v.lengthSpeed, dt)
				v.weight = v.weight + GlobalTools:Mul(v.weightSpeed, dt)
			end
			
			if v.curTime >= v.time then
				self:removeTrigger(v)
			end
		end
	end
end


--圆形检测
function M:circularCheck(v, ply, targets)
	local dis = GlobalTools:Distance(v.center, ply.position)
	if GlobalTools:ToFix2(ply.data.triggerRadius + v.radius) > dis and GlobalTools:ToFix2(v.innerRadius) <= dis then
		if v.hasList == nil then
			v.hasList = {}
		end
		local has = false
		for k1,v1 in ipairs(v.hasList) do
			if v1:equal(ply) then
				has = true
				break
			end
		end
		if has == false then
			dis = dis - ply.data.triggerRadius
			local hitPos = FixVector3.zero()
			if dis <= 0 then
				hitPos = ply.position:Clone()
				hitPos.y = v.height
			else
				local center_dis = GlobalTools:Dir3DOne(v.center, ply.position)
				hitPos = ply.position + center_dis * dis
				hitPos.y = ply.position.y + v.height
			end
			if v.callback ~= nil then
				v.callback(ply, hitPos:toVector3(), v)
			end
			table.insert(v.hasList, ply)
		end
	end
end

--矩形检测
function M:rectCheck(v, ply)
	--计算中心和敌人之间的方向
	local vec = ply.position - v.center
	--矩形前方距离
	if vec.x < v.length and vec.x > 0 then
		if GlobalTools:Abs(vec.z) < v.weight then
			if v.hasList == nil then
				v.hasList = {}
			end
			local has = false
			for k1,v1 in ipairs(v.hasList) do
				if v1:equal(ply) then
					has = true
					break
				end
			end

			if has == false then
				local pos = FixVector3.zero()
				pos.x = ply.position.x
				pos.y = (v.height) + ply.position.y
				pos.z = ply.position.z
				local hitPos = pos
				if v.callback ~= nil then
					v.callback(ply, hitPos:toVector3(), v)
				end
				table.insert(v.hasList, ply)
			end
		end
	end
end

return M