--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-30 10:44:36
]]

---@class AnimEvtFrame_Model @时间帧的数据部分
---@field player PlayerModel
---@field evtAction AnimEvtAction_Model
---@field data Battle_Frame_Data_Event
local M = class("AnimEvtFrame_Model",Battle.ModelBase)

--加载
-- player 玩家的数据模型
-- data   事件帧的数据
-- evtAction 帧动作
function M:load( data, player, evtAction )
	-- 玩家的数据层
	self.player = player;
	--动作
	self.evtAction = evtAction;
	--数据
	self.data = data
	--触发时间 定点数
	self.triggerTime = self.data.triggerTime;
	--是否生效过
	self.isWork = false;
	--技能条件
	if self.data.eventName == "SkillCondition" then
		self:skillCondition()
	end
	--发送事件帧model创建完成事件
	self.player:dispatchEvent_Local(Battle.EventType.MV_AnimEvtFrameModelCreateFinish, self);
end

--返回帧数据
function M:get_data()
	return self.data;
end

--返回动作信息
function M:get_action()
	return self.evtAction;
end

--开始
function M:start()
	self.isWork = true;
	--self.player.player_enemyList= Battle.List.new()
end


--关键帧，起作用
function M:tryWork()
	if self.isWork then
		self:work();
		self.isWork = false;
	end
end


--到时间就起作用
function M:update( time )
	if self.isWork == true then
		if time >= self.triggerTime then
			self:tryWork()
			return true
		end
	end
	return false
end

--检测强制选择
function M:checkForceSelect()
	if self.data["count"]["forceSelect"] == true then
		return true
	end
	return false
end


--关键帧，起作用
function M:work()
	local eventName = self.data.eventName;
	if eventName == "Hit" then
		self:hit()
	elseif eventName == "Shoot" then
		self:shoot()
	elseif eventName == "BlackScreen" then
		self:blackScreen()
	elseif eventName == "Skill" then
		self:skill()
	elseif eventName == "Hook" then
		self:line()
	elseif eventName == "AttackMove" then
		self:attackMove()
	elseif eventName == "AddBuf" then
		self:addBuff()
	elseif eventName == "RemoveBuf" then
		self:removeBuff()
	elseif eventName == "AddBlood" then
		self:addBlood()
	elseif eventName == "AddSummon" then
		self:addSummon()
	elseif eventName == "InjurePause" then
		self:injurePause()
	elseif eventName == "ChangeAnim" then
		self:changeAnim()
	elseif eventName == "AnimLoop" then
		self:animLoop()
	elseif eventName == "Sendfor" then
		self:sendfor()
	elseif eventName == "SendforControl" then
		self:sendforControl()
	elseif eventName == "AddPlayerPart" then
		self:AddPlayerPart()
	elseif eventName == "Dispatch" then
		self:Dispatch()
	else
		self:triggerMeishu();
	end
end

--黑屏
function M:blackScreen()
	local sceneInfo = SceneManager.curScene:getBattleModeCfg()
	if sceneInfo.showSkill3Effect ~= true then
		return
	end
	if self.player:get_camp() == 1 and self.player.canBlackScreen == true then
		--黑屏
		self.player.plyMgr.blackTimeManager:startBlackTime(self.player, self.data["blackTime"] )
	end
end

--召唤
function M:sendfor()
	local SendForFuncframe = require("Battle.Ply.Fuc.SendForFunc").new()
	local ply = self.player
	if ply.master ~= nil then
		ply = ply.master
	end
	if self.data.summonName ~= nil and self.data.summonName ~= "nil" and self.data.summonName ~= 0 then
		local delayTime = self.data.delayTime or 0
		if delayTime > 0 then
			TimeTools:delayTime(delayTime, function()
				SendForFuncframe:init(table.copy(self.data), ply)
			end)
		else
			SendForFuncframe:init(table.copy(self.data), ply)
		end
	end
end

--控制召唤物
function M:sendforControl()
	local enemys = SelectTargetTool:findPlayerByType(self.data["count"], self.player,true)
	if enemys.Count > 0 then
		local id = self.data["id"]
		for i = 1, self.player.summonList.list.Count do
			local key = self.player.summonList.list:get(i-1)
			if key == tonumber(id) then
				local plys = self.player.summonList:get(key)
				for i, v in ipairs(plys) do
					local canUse = true
					if v.aiEngine.curState.key == "skill" and string.match(v.summonData.animName, "skill3") ~= nil then
						canUse = false
					end
					if canUse then
						v.summonData.target = enemys:get(0)
						v.summonData.targetDist = self.data["targetDist"]
						v.summonData.animName = self.data["animName"]
						v:set_curSkillConfig( self.player:get_curSkillConfig() )
						v.aiEngine:changeState("skill")
					end
				end
			end
		end
	end
end

--位移初始化
function M:moveInit(type, player, data)
	if self.player.moveMgr.canMove == true then
		local move = require("Battle.Ply.Fuc.Move").new()
		--将move加入到move管理器
		self.player.moveMgr:addFrame(move)
		move:init(type,self.player,self.data)
	end
end

--攻击位移
function M:attackMove()
	-- local attackmoveframe = require("Battle.Ply.Fuc.AttackMoveFunc").new()
	-- self.player.moveMgr:addFrame(attackmoveframe)
	-- attackmoveframe:init(self.data,self.player)
	local type = self.data["moveType"]
	if type == nil or type == "nil" then
		type = "MoveGeneral"
	end
	if self.player ~= nil then
		self.player:setScale(self.player.scale)
	end
	self:moveInit(type, self.player , self.data)
end

--释放技能帧
function M:skill()
	local skillFrame = require("Battle.Ply.SkillFrame").new()
	skillFrame:init(self.player,self.data)
	self.player.skillFrameMgr:addFrame(skillFrame)
end

--近战伤害事件
function M:hit()
	local player = self.player
	player = self.player:getPlayer(self.data["useSelf"])

	-- 反伤的时候：最多反伤的人数， 重置反伤人数
	local reboundNum = ConfigManager:getBattleCommonValueById(10001,1, false)
	player.reboundNum = reboundNum;

	local skillConfig = self.player.forceSkillConfig
	if skillConfig == nil then
		skillConfig = self.player.curSkillConfig
	end
	local data = player.skillImprove:eventHandle(self, skillConfig)

	--hitFrame会改变技能编辑器出来的数据,已经在初始化的地方进行拷贝了
	data = player.plySkill:hitFrame(self, data)
	if player.skyStar ~= nil then
		data = player.skyStar:hitFrame(self, data)
	else
		-- 宠物也需要走侠客的化星 例如九黎的老虎 需要走九黎的化星效果
		if player.master and player.master.skyStar ~= nil then		
			data = player.master.skyStar:hitFrame(self, data)
		end
	end
	

	--过去特效数据
	local effectData = self.evtAction:getHitEffectData(data.effectId)
	--是都射击固定点
	local shootFixPoint = data["count"]["isFixPoint"]
	--固定点
	local fixPoint = data["count"]["fixpoint"]
	--攻击数据
    local attackData = {}
	-- 配置的透传参数 
	attackData.extraParam = data.extraParam
	--计算前攻击百分比
	local fontDamagePercentage = data["frontdamagePercent"]
	--计算后攻击百分比
	local lastDamagePercentage = data["lastdamagePercent"]
	--怒气百分比
	local angerAirPercent = data["angerAirPercent"]
	--是否必定命中
	local mustHit = data["mustHit"]
	--是否必定暴击
	local mustCrit = data["mustCrit"]
	--攻击敌人的 bufid
	--local attackEnemyInjureBuf = data["buffType"]
	local injureMove = data["injureMove"]
	local curveMove = data["curveMove"]
	local hitEffect = data["hitEffect"]
	local areaCheck = data["areaCheck"]
	--受击音效
	local hitAudio = ""
	if effectData ~= nil then
		hitAudio = effectData.data["hitAudio"] or ""
	end
	
	--受击特效数据
	local hitEffectList = {}
	local rangeEffectList = {}
	if effectData ~= nil and effectData.data["prefabList"] ~= nil then
		for k,v in pairs(effectData.data["prefabList"]) do
			if v.type == "injureHit" or v.type == "critHit" then
				table.insert(hitEffectList, v)
			elseif v.type == "rangeHit" then
				table.insert(rangeEffectList, v)
			end
		end
	else
		if skillConfig ~= nil then
			--Logger.logError("Lack of HitEffect. player:"..self.player.plyType..". skill:"..skillConfig.anim_name)
		else
			--Logger.logError("Lack of HitEffect. player:"..self.player.plyType)
		end
	end
	
	local power = tonumber(data["power"] or GlobalTools.base30)
	power = GlobalTools:Clamp(power, GlobalTools.base30, GlobalTools.base999)

	attackData["damage"] = player.data.atk:getValue()
	attackData["damageExtra"] = GlobalTools.base0
	local bloodThirsty = player.bufMgr:findBufByType("BloodThirsty")
	for k, v in ipairs(bloodThirsty) do
		attackData["damageExtra"] = attackData["damageExtra"] + v.bufWork:GetValue()
	end
	attackData["damageFront"] = fontDamagePercentage
	attackData["damageLast"] = lastDamagePercentage
	if self.player.ex_hit_bufId ~= nil then
		attackData["buffId"] = self.player.ex_hit_bufId
	else
		attackData["buffId"] = data["buffId"]
	end
	attackData["richBuff"] = data["richBuff"]
	attackData["noAttack"] = data["noAttack"]
	attackData["player"] = player
	attackData["type"] = 0
	attackData["power"] = power
	attackData["skillConfig"] = skillConfig
	attackData["injureType"] = "skill"

	if injureMove["move"] then
		attackData["injureMove"] = {}
		attackData["injureMove"]["injureType"] = injureMove["injureType"]
		attackData["injureMove"]["endType"] = injureMove["injureEndType"]
		attackData["injureMove"]["type"] = curveMove["curveMoveType"]
		attackData["injureMove"]["distance"] = curveMove["curveMoveDistance"]
		attackData["injureMove"]["time"] = curveMove["curveMoveTime"]
		attackData["injureMove"]["injureAnimName"] = injureMove["injureAnimName"]
		local forward = player:getForward();
		attackData["injureMove"]["injureDir"] = FixVector3.New(0,0,0)
		attackData["injureMove"]["injureDir"].x = forward.x;
		attackData["injureMove"]["injureDir"].y = forward.y;
		attackData["injureMove"]["injureDir"].z = forward.z;
		attackData["injureMove"]["moveType"] = curveMove["curveDistanceType"]
	else
		attackData["injureMove"] = nil
	end
	
	attackData["angerAir"] = angerAirPercent
	attackData["hitEffect"] = hitEffect
	attackData["mustHit"] = mustHit
	attackData["mustCrit"] = mustCrit
	attackData["damageType"] = 1
	--显示数据
	attackData["hitEffectList"] = hitEffectList
	attackData["hitAudio"] = hitAudio

	--默认为单体攻击
	attackData.isSingleTarget = true

	if skillConfig ~= nil then
		skillConfig.skill_work = true
		attackData["damageType"] = skillConfig.atk_type
		--攻击增怒
		local hit_energy_num = self.player.data:getAtkEnemgy(skillConfig, angerAirPercent)
		player.data:addAnger( hit_energy_num )
		
		attackData["attackerAnger"] = hit_energy_num
	end
	
	if areaCheck ~= nil and areaCheck["openAreaCheck"] then
		attackData.isSingleTarget = false
		player.targetCheck:addTrigger(areaCheck, attackData)
	else
		--设计固定点
		if shootFixPoint  then
			local point = SelectTargetTool:findFixPoint(player, fixPoint, data.aoeType["aoeSectorRadius"])
			self:checkAoeHit(point, data.aoeType, attackData, rangeEffectList)
		else
			local enemys = nil
			if self.forceSelect then
				enemys = SelectTargetTool:findPlayerByType(data["count"],self.player,true)
			else
				enemys = SelectTargetTool:findPlayerByType(data["count"],self.player,true)

				player.curSkillEnemyList = enemys:clone()
				for i = 1, player.curSkillEnemyList.Count do
					local ply = player.curSkillEnemyList:get(i - 1)
					ply.lockMeList:add(player)
				end
				--end
			end

			enemys = player.plySkill:findPlayer(enemys)
			EventDispatcher:dipatchEvent("selectTarget", {killer = player, skill = player.curSkillConfig, targets = enemys, evtFrame = self})

			if enemys.Count > 0 then
				--找到的敌人给伤害
				for i=1,enemys.Count do
					local enemy = enemys:get(i-1)
					if enemy ~= nil then
						--范围伤害改变受伤方向
						if data["count"]["targetNoRepeat"] == true then
							player:add_player_enemyList(enemy)
						end
						if data["count"]["area"] ~= "all" then
							attackData["injureDir"] = FixVector3.New(0,0,0)
							local dir = GlobalTools:Dir(enemy.position, player.position)
							attackData["injureDir"].x = dir.x
							attackData["injureDir"].y = dir.y
							attackData["injureDir"].z = dir.z
						end
						if data.aoeType == nil or data.aoeType["aoeType"] == nil then
							attackData.isSingleTarget = data["count"]["count"] == "one"
							enemy:injure( attackData )
						else
							local targetPos = enemy:get_position()
							targetPos = player.plySkill:checkAoeTarget(targetPos)
							self:checkAoeHit(targetPos, data.aoeType, attackData, rangeEffectList)
						end
					end
				end
			end

			if self.forceSelect == false and self.hitFinish then
				for i = 1, player.curSkillEnemyList.Count do
					local ply = player.curSkillEnemyList:get(i - 1)
					ply.lockMeList:remove(player)
				end
				player.curSkillEnemyList:clear()
			end
		end
		
	end
end

function M:checkAoeHit(targetPos, aoeData, attackData, rangeEffectList)
	--是范围攻击
	attackData.isSingleTarget = false
	local aoeType = aoeData.aoeType
	local center = FixVector3.New(0, 0, 0)
	center.x = targetPos.x
	center.y = targetPos.y
	center.z = targetPos.z
	
	local targetDir = GlobalTools:Dir(center, self.player:get_position())
	local offset = table.shallow_copy(aoeData.aoeOffset)
	if offset ~= nil then
		if targetDir.x < 0 then
			offset.x = -offset[1]
			offset.z = -offset[3]
		end
		center.x = center.x + offset[1]
		center.y = center.y + offset[2]
		center.z = center.z + offset[3]
	end
	
	if rangeEffectList ~= nil and  #rangeEffectList > 0 then
		local param = {}
		param["effectList"] = rangeEffectList
		param["center"] = center:toVector3()
		self:dispatchEvent_Local(Battle.EventType.MV_AnimEvtFrameMeiShuHitAoeEffect, param)
	end
	
	local function injure()
		local players = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
		if aoeType == "Sector" then
			for i=players.Count,1,-1 do
				local ply = players:get(i-1)
				--计算我的和敌人之间的方向
				local enemyPos = ply:get_position():Clone()
				local distance = GlobalTools:Distance(enemyPos, center)
				local radius = tonumber(aoeData["aoeSectorRadius"])
				attackData.isSingleTarget = radius <= GlobalTools.base0
				if distance <= GlobalTools:ToFix2( radius )  then
					local forward = GlobalTools:Dir(self.player:get_position(), center)
					forward.x = GlobalTools.base0
					forward = forward:SetNormalize()
					
					local nor_vec = GlobalTools:Dir(enemyPos, center)
					--得到角度
					local dot = FixVector3.Dot( nor_vec, forward )
					dot = GlobalTools:Clamp(dot, -GlobalTools.base1, GlobalTools.base1)
					local tmpAngle = GlobalTools:ACos( dot );

					if tmpAngle <= GlobalTools:Mul(aoeData["aoeSectorAngle"], GlobalTools.base0_5) then
						ply:injure( table.shallow_copy(attackData) )
					end
				end
			end
		elseif aoeType == "Rect" then
			attackData.isSingleTarget = aoeData["aoeRectX"] <= GlobalTools.base0 and aoeData["aoeRectY"] <= GlobalTools.base0

			for i= players.Count,1,-1 do
				local ply = players:get(i-1)
				--计算目标点的和敌人之间的方向
				local vec = ply:get_position() - center
				if vec.z < aoeData["aoeRectY"] and GlobalTools:Abs(vec.x) < aoeData["aoeRectX"] then
					ply:injure( table.shallow_copy(attackData) )
				end
			end
		end
	end
	
	local damageDelay = self.data.damageDelay or 0
	if damageDelay > 0 then
		local realDelayTime = damageDelay;
		realDelayTime = GlobalTools:Div( realDelayTime, self.player.animator:get_animSpeed() )
		TimeTools:delayTime(realDelayTime, function()
			injure()
		end)
	else
		injure()
	end
end

--远程攻击的事件
function M:shoot()
	local data = self.player.skillImprove:eventHandle(self, self.player.curSkillConfig)
	if self.player.skyStar ~= nil then
		data = table.copy(data)
		self.player.skyStar:shootFrame(self, data)
	end
	self:shootBullet(data)
end


---@param forceTargets Battle_List	强制指定目标
function M:shootBullet(data, forceTargets)
	local player = self.player:getPlayer(data["useSelf"])

	local type = data["bulletType"]
	if type == nil or type == "nil" then
		type = "Bullet"
	end
	--是都射击固定点
	local shootFixPoint = data["count"]["isFixPoint"]
	--固定点
	local fixPoint = data["count"]["fixpoint"]
	--怒气百分比
	local angerAirPercent = data["angerAirPercent"]

	local attackerAnger = 0

	local notFaceToTarget = data["notFaceToTarget"]

	local skillConfig = self.player.forceSkillConfig
	if skillConfig == nil then
		skillConfig = self.player.curSkillConfig
	end

	--技能配置
	if skillConfig ~= nil then
		skillConfig.skill_work = true
		--攻击增怒
		local hit_energy_num = player.data:getAtkEnemgy(skillConfig, angerAirPercent)
		player.data:addAnger( hit_energy_num )
		attackerAnger = hit_energy_num
	end

	-- 反伤的时候：最多反伤的人数， 重置反伤人数
	local reboundNum = ConfigManager:getBattleCommonValueById(10001,1, false)
	player.reboundNum = reboundNum;

	--设计固定点
	if shootFixPoint  then
		local point = SelectTargetTool:findFixPoint(player, fixPoint)
		self:bulletInit(data, point, nil, attackerAnger, skillConfig)
	else
		local enemys = forceTargets or SelectTargetTool:findPlayerByType(data["count"],self.player, true)
		--找到敌人
		enemys = player.plySkill:findPlayer(enemys)
		EventDispatcher:dipatchEvent("selectTarget", {killer = player, skill = player.curSkillConfig, targets = enemys, evtFrame = self})
		
		local dir = FixVector3.New(0,0,0)
		for i = 1, enemys.Count do
			local enemy = enemys:get(i - 1)
			if enemy ~= nil then
				dir = dir + FixVector3.Normalize(enemy.position - player.position)
				self:bulletInit(data, enemy.position, enemy, attackerAnger, skillConfig)
			end
		end
		if player.isBoss == false and enemys.Count > 0 and notFaceToTarget ~= true then
			player:setForward(dir/enemys.Count)
		end
	end
end


--子弹初始化
---@param target PlayerModel
function M:bulletInit(data, position, target, attackerAnger, skillConfig)
	local player = self.player:getPlayer(data["useSelf"])
	local effectData = self.evtAction:getShootEffectData(data.effectId)
	----加载预制
	--local bullet = require("Battle.Blt.Bullet").new()
	--bullet.target = position
	--bullet.enemy = target
	--bullet.sourceSkill = self.player.curSkillConfig
	--self.data["damageReduce"] = data["damageReduce"]
	--bullet:init(data["bulletType"], effectData, player, data)
	----将子弹加入到人物管理器
	--player.bulletMgr:addBullet(bullet)

	local createData = {}
	createData.data = data;
	createData.attackerAnger = attackerAnger;
	createData.position = position;
	createData.target = target;
	createData.skill = skillConfig
	createData.bulletType = data.bulletType;
	createData.bulletEffectData = effectData;
	createData.player = player;
	--将子弹加入到人物管理器
	player.bulletMgr:createBullet(createData)
end

--连线
function M:line()
    --加载预制
    local line = require("Battle.Line.Line_Model").new()
    line:init(self.data, self.player)
     --将连线加入到管理器
    self.player.lineMgr:addLine(line)
end

--加入召唤物
function M:addSummon()
    self.player.summonMgr:add(self.data, self.player.curSkillConfig)
end

--加入一个buf
function M:addBuff()
	local player = self.player:getPlayer(self.data["useSelf"])
	--怒气百分比
	local angerAirPercent = self.data["angerAirPercent"] or 0
	
	local list = SelectTargetTool:findPlayerByType(self.data["count"], self.player, false)
	list = player.plySkill:findPlayer(list)
	EventDispatcher:dipatchEvent("selectTarget", {killer = player, skill = player.curSkillConfig, targets = list, evtFrame = self})

	-- 反伤的时候：最多反伤的人数， 重置反伤人数
	local reboundNum = ConfigManager:getBattleCommonValueById(10001,1, false)
	player.reboundNum = reboundNum;

	--技能配置
	if player.curSkillConfig ~= nil then
		player.curSkillConfig.skill_work = true
		--攻击增怒
		local hit_energy_num = self.player.data:getAtkEnemgy(self.player.curSkillConfig, angerAirPercent)
		player.data:addAnger( hit_energy_num )
	end

	--循环敌人列表
	for i=list.Count,1,-1 do
		---@type PlayerModel
		local ply = list:get(i-1)
		--if player ~= nil and player.isUnScale then
		--	ply:setUnScale(true)
		--end
		local buffs = string.split(self.data["buffId"], ",")
		for k,v in ipairs(buffs) do
			if ply ~= nil then
				ply.bufMgr:addBufById(tonumber(v), player, player.curSkillConfig)
			else
				Logger.logError(" 玩家的list没有找到 "..player.plyType.." "..player.plyData.id )
			end
		end
	end
end

--删除buf
function M:removeBuff()
	local list = SelectTargetTool:findPlayerByType(self.data["count"],self.player)
	--循环敌人列表
	for i=list.Count,1,-1 do
		local ply = list:get(i-1)
		if self.data["removeByType"] then
			ply.bufMgr:removeBufByType(self.data["type"])
		end
		if self.data["removeByTag"] then
			ply.bufMgr:removeBufByTag(self.data["tag"])
		end
	end
end


function M:addBlood()
	--buf ID
	local damagePercent = tonumber(self.data["damagePercent"])
	--local hp = 0
	--if self.data["cureType"] == "atk" then
	--	hp = self.player.data.atk * damagePercent
	--else
	--	hp = self.player.data.hp * damagePercent
	--end
	local list = SelectTargetTool:findPlayerByType(self.data["count"],self.player)
	--循环敌人列表
	for i=list.Count,1,-1 do
		local ply = list:get(i-1)
		ply:cure(self.data["cureType"], self.player, damagePercent, self.player.curSkillConfig)
	end
end

--切换动画
function M:changeAnim()
	if self.data["isLoop"] then
		self.player.animator.loopCount = self.player.animator.loopCount - 1
		if self.player.animator.loopCount < 0 then
			self.player.animator:changeState(self.data["endAnim"])
			self.player.animator.curExtraLoopCount = 0
		else
			self.player.animator:changeState(self.data["anim"])
		end
	else
		self.player.animator:changeState(self.data["anim"])
	end
end

--动画循环
function M:animLoop()
	self.player.animator.loopCount = self.data["count"]
	self.player.animator.extraLoopCount = self.data["extraCount"]
end

--伤害暂停
function M:injurePause()
    local enemys = SelectTargetTool:findPlayerByType(self.data["count"],self.player)
    if enemys.Count > 0 then
        --找到的敌人给伤害
        for i=1,enemys.Count do
            local enemy = enemys:get(i-1)
            enemy:injurePause(tonumber(self.data["pauseTime"]))
            self.player:injurePause(tonumber(self.data["pauseTime"]))
        end
    end
end

--技能条件
function M:skillCondition()
	local skill_name = string.split(self.evtAction.animName, "_")[1]

	if skill_name == nil then
		skill_name = self.evtAction.animName
	end
	local skill = self.player.plySkill:getSkillByName(skill_name)
	if skill ~= nil then
		skill.cur_skill_config.evtCondition = self.data
	end
end

--生成附属物
function M:AddPlayerPart()
	self.player.partMgr:add(self.data)
end

--发送事件
function M:Dispatch()
	local player = self.player:getPlayer(false)
	local dispatchEventName = self.data["dispatchEventName"]
	if dispatchEventName ~= nil and dispatchEventName ~= "" then
		player.plySkill:skillDispatch({ eventName = dispatchEventName, frame = self })
	end
end


function M:triggerMeishu()
	self:dispatchEvent_Local(Battle.EventType.MV_AnimEvtFrameMeiShuTrigger, self.data);
end

return M;
