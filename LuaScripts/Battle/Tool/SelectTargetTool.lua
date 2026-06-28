---@class SelectTargetTool @目标选择工具
---@field player_list Battle_List
---@field priorityList Battle_List
---@field notPriorityList Battle_List
local M = class("SelectTargetTool")


function M:init()
	--注册camp功能
	self:registerCampFunc()
	--注册魅惑表
	self:registerCharmCamp();
	--注册区域功能
	self:registerAreaFunc();
	--注册位置索引功能
	self:registerPosIndexFunc();
	--注册位置类型功能
	self:registerPosTypeFunc()
	--注册查找功能
	self:registerSortFunc();
	--注册职业
	self:registerProfession();
	--注册Race
	self:registerRace();
	--注册性别
	self:registerGender();
	--注册Count
	self:registerCount();
	
	self.sortFunction = handler(self, self.sort);
end


--找符合要求的玩家
---@param player PlayerModel
---@return Battle_List
function M:findPlayerByType(data, player, isFrame)
	self.player = player:getPlayer(data["useSelf"])
	--人数
	self.count = data["count"]
	--阵营
	self.camp = data["camp"]
	--是否优先选择
	self.priority = data["priority"] == true
	--是否忽略低级召唤物
	self.ignoreSummon = data["ignoreSummon"] == true
	self.summonList = {}
	--索引位置
	self.posIndex = data["posIndex"]
	self.playerType = data.playerType 
	--条件
	self.posType = data["pos"]
	--roleType
	self.roleType = data["roleType"] or 0
	--类型(力量敏捷内功)
	self.profession = self.professionData[data["profession"]] or 0
	--if self.profession == "agility" then
	--	self.profession = 2 --暂定为职业的
	--elseif self.profession == "strength" then
	--	self.profession = 1
	--elseif self.profession == "fashi" then
	--	self.profession = 3
	--else
	--	self.profession = 0
	--end
	--阵营
	self.race = self.raceData[data["campRace"]] or 0
	--if self.race == "LongTing" then
	--	self.race = 1 --暂定为职业的
	--elseif self.race == "CaoMang" then
	--	self.race = 2
	--elseif self.race == "ShiZu" then
	--	self.race = 3
	--elseif self.race == "YiZu" then
	--	self.race = 4
	--elseif self.race == "GuiZhou" then
	--	self.race = 5
	--elseif self.race == "ZhuiFeng" then
	--	self.race = 6
	--else
	--	self.race = 0
	--end

	--性别
	self.gender = self.genderData[data["gender"]] or 0
	--if self.gender == "woman" then
	--	self.gender = 2
	--elseif self.gender == "man" then
	--	self.gender = 1
	--else
	--	self.gender = 0
	--end

	--目标范围
	self.area = data["area"]
	self.areaWidth =  data["areaWidth"]
	self.areaHeight = data["areaHeight"]
	self.areaAngle = data["areaAngle"]
	self.areaRadius = data["areaRadius"]

	--是否能和上一次重复选择
	self.targetNoRepeat = data["targetNoRepeat"] == true

	--使用上次目标
	local selectLast = data["selectLast"] == true

	self.player_list = nil

	if selectLast and player.lastSelect ~= nil then
		self.player_list = player.lastSelect:clone()
		return self.player_list
	end

	if self.targetNoRepeat == false then
		self.player:clear_player_enemyList();
	end

	-- 选择目标为宠物走单独的选目标
	if self.playerType == "pet" then
		self.player_list = Battle.List.new()
		if self.camp == "enemy" then
			local petMgr = self.player.plyMgr:getPetMgr(-self.player.camp)
			if petMgr:hasPet() then
				self.player_list:add(petMgr:getCurPet())
			end
		elseif self.camp == "myenemy" then
			if self.player:get_enemy() ~= nil then
				self.player_list:add(self.player.enemy)
			else
				local petMgr = self.player.plyMgr:getPetMgr(-self.player.camp)
				if petMgr:hasPet() then
					self.player_list:add(petMgr:getCurPet())
				end
			end
		else
			Logger.logError(self.camp, "选择协战宠物目标失败")	
		end
	else
		--找敌人
		self:findCampPlayer()
	end

	if self.camp ~= "curFriend" or self.camp ~= "myenemy" then
		if self.area ~= "all" then
			self:findAreaPlayer()
		end
		if self.priority then
			self.priorityList = self.player_list:clone()
			self.notPriorityList = Battle.List.new()
		end
		if self.posIndex ~= nil and self.posIndex ~= "all" then
			self:findPosIndexPlayer()
		end
		if self.race ~= 0 then
			self:findRacePlayer()
		end
		if self.profession ~= 0 then
			self:findProfessionPlayer()
		end
		if self.gender ~= 0 then
			self:findGenderPlayer()
		end
		if self.roleType ~= 0 then
			self:findRoleTypePlayer()
		end
		if self.posType ~= "not"  then
			self:findPos_TypePlayer()
		end
		if self.count ~= "all" then
			self:findCountPlayer()
		end
	end
	
	--嘲讽处理
	if player ~= nil and (self.camp == "all" or self.camp == "enemy" or self.camp == "myenemy") then
		local tauntList = player.tauntList
		if #tauntList > 0 then
			local index = 0
			for k,v in ipairs(tauntList) do
				if index < self.player_list.Count and  v ~= nil and v:isLive() and self.player_list:contains(v) == false then
					self.player_list:set(index, v)
					index = index + 1
				end
			end
		end
	end

	if self.targetNoRepeat then
		for i = 1, self.player_list.Count do
			local ply = self.player_list:get(i - 1)
			self.player:add_player_enemyList(ply)
		end
	end

	if isFrame == true then
		player.lastSelect = self.player_list:clone()
	end
	return self.player_list
end

--注册 camp 功能
function M:registerCampFunc()
	if self.campFuncPool == nil then
		self.campFuncPool = {}
	end

	--全体（包括自己）
	self.campFuncPool["all"] = function()
		self.player_list = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp()):clone()
		local temp = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
		for i = 1, temp.Count do
			self.player_list:add(temp:get(i - 1))
		end
	end

	--全体（不包括自己）
	self.campFuncPool["allExceptSelf"] = function()
		self.player_list = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp()):clone()
		local temp = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
		for i = 1, temp.Count do
			self.player_list:add(temp:get(i - 1))
		end
		self.player_list:remove(self.player)
	end

	--敌人
	self.campFuncPool["enemy"] = function()
		self.player_list = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp()):clone()
		--if self.player.player_enemyList ~= nil then
		--	if self.targetNoRepeat == false then
		--		self.player:clear_player_enemyList();
		--	end
		--end
	end

	--队友
	self.campFuncPool["friend"] = function()
		self.player_list = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp()):clone()
	end

	--自己 
	self.campFuncPool["self"] = function()
		if self.player_list == nil then
			self.player_list = Battle.List.new()
		end
		if self.player.master ~= nil then
			self.player_list:add(self.player.master)
		else
			self.player_list:add(self.player)
		end
	end

	--队友除了自己 
	self.campFuncPool["friendExceptSelf"] = function()
		self.player_list = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp()):clone()
		self.player_list:remove(self.player)
		if self.player.master ~= nil then
			self.player_list:remove(self.player.master)
		end
	end

	--我的敌人 
	self.campFuncPool["myenemy"] = function()
		if self.player_list == nil then
			self.player_list = Battle.List.new()
		else
			self.player_list:clear();
		end
		if self.player:get_enemy() ~= nil then
			self.player_list:add(self.player.enemy)
		else
			self.player_list = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp()):clone()
		end
	end

	--当前好友 
	self.campFuncPool["curFriend"] = function()
		if self.player_list == nil then
			self.player_list = Battle.List.new()
		else
			self.player_list:clear();
		end
		if self.player.friend ~= nil then
			self.player_list:add(self.player.friend)
		else
			self.player_list = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp()):clone()
		end
	end

	--主人
	self.campFuncPool["master"] = function()
		if self.player_list == nil then
			self.player_list = Battle.List.new()
		else
			self.player_list:clear();
		end
		if self.player.master ~= nil then
			self.player_list:add(self.player.master)
		else
			self.player_list:add(self.player)
		end
	end


	--我方召唤物
	self.campFuncPool["mySummoned"] = function()
		if self.player_list == nil then
			self.player_list = Battle.List.new()
		else
			self.player_list:clear();
		end
		--找到队友
		local friends = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
		for i = 1, friends.Count do
			local friendPly = friends:get(i-1)
			--找到队友的宠物
			for j = 1, friendPly.summonList.list.Count do
				local key = friendPly.summonList.list:get(j-1)
				local plys = friendPly.summonList:get(key)
				for k, v in ipairs(plys) do
					self.player_list:add(v)
				end
			end
		end
	end


	--敌方召唤物
	self.campFuncPool["enemySummoned"] = function()
		if self.player_list == nil then
			self.player_list = Battle.List.new()
		else
			self.player_list:clear();
		end
		--找到敌人
		local enemys = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
		for i = 1, enemys.Count do
			local enemyPly = enemys:get(i-1)
			--找到敌人的宠物
			for j = 1, enemyPly.summonList.list.Count do
				local key = enemyPly.summonList.list:get(j-1)
				local plys = enemyPly.summonList:get(key)
				for k, v in ipairs(plys) do
					self.player_list:add(v)
				end
			end
		end
	end
	

	--我自己的所有召唤物
	self.campFuncPool["summoned"] = function()
		if self.player_list == nil then
			self.player_list = Battle.List.new()
		else
			self.player_list:clear();
		end
		for i = 1, self.player.summonList.list.Count do
			local key = self.player.summonList.list:get(i-1)
			local plys = self.player.summonList:get(key)
			for i, v in ipairs(plys) do
				self.player_list:add(v)
			end
		end
	end

	--杀我的人
	self.campFuncPool["killerEnemy"] = function()
		if self.player_list == nil then
			self.player_list = Battle.List.new()
		else
			self.player_list:clear();
		end
		if self.player.killer ~= nil then
			self.player_list:add(self.player.killer)
		else
			self.player_list:add(self.player)
		end
	end
end

--注册魅惑表
function M:registerCharmCamp()
	if self.charmCamp == nil then
		self.charmCamp = {enemy = "friendExceptSelf",friend = "enemy",friendExceptSelf = "enemy",curFriend = "enemy",myenemy="friendExceptSelf"}
	end
end
--注册区域功能
function M:registerAreaFunc()
	if self.areaFunc == nil then
		self.areaFunc = {}
	end
	self.areaFunc["rectangle"] = function()
		--范围是矩形
		for i=self.player_list.Count,1,-1 do
			local ply = self.player_list:get(i-1)
			--计算我的和敌人之间的方向
			local vec = ply.position - self.player.position
			--矩形前方距离
			if self.player.forward.x < GlobalTools.base0 then
				vec.x = GlobalTools:Mul( vec.x , -GlobalTools.base1 )
			end
			--在后方或者超出范围
			if vec.x < GlobalTools.base0 or vec.x > self.areaHeight then
				self.player_list:remove(ply)
			else
				if math.abs(vec.z) > self.areaWidth then
					self.player_list:remove(ply)
				end
			end
			--local forwardDis = FixVector3.Dot(self.player:getForward(), vec)
			--if forwardDis < 0 or forwardDis > self.areaHeight then
			--	self.player_list:remove(ply)
			--else
			--	if Mathf.Abs(FixVector3.Dot( self.player:getRight(), vec)) > self.areaWidth then
			--		self.player_list:remove(ply)
			--	end
			--end
		end
	end

	self.areaFunc["sector"] = function()
		--范围是扇形
		for i=self.player_list.Count,1,-1 do
			local ply = self.player_list:get(i-1)
			--计算我的和敌人之间的方向
			local vec = ply.position - self.player.position;
			local nor_vec = FixVector3.Normalize(vec)
			local forward = self.player:getForward():Clone()
			forward.z = GlobalTools.base0;
			forward = FixVector3.Normalize(forward)
			if vec:SqrMagnitude() > GlobalTools:ToFix2( self.areaRadius ) then
				self.player_list:remove(ply)
			else

				local fix_dot = FixVector3.Dot(nor_vec, forward)
				--得到角度
				local tmpAngle = GlobalTools:ACos( fix_dot )
				if tmpAngle > GlobalTools:Mul(self.areaAngle, GlobalTools.base0_5) then
					self.player_list:remove(ply)
				end
			end
		end
	end

	--敌人区域
	self.areaFunc["enemyArea"] = function()
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.BossScene and SceneManager.curScene.sceneId ~= SceneManager.SceneID.UnionBossScene and SceneManager.curScene.sceneId ~= SceneManager.SceneID.ActiveBossScene then
			local center = self:findFixPoint(self.player, "sceneCenter")
			for i = self.player_list.Count, 1, -1 do
				local ply = self.player_list:get(i-1)
				if self.player.camp == 1 and ply.position.x <= center.x then
					self.player_list:remove(ply)
				elseif self.player.camp == -1 and ply.position.x > center.x then
					self.player_list:remove(ply)
				end
			end
		end
	end

	--我方区域
	self.areaFunc["selfArea"] = function()
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.BossScene and SceneManager.curScene.sceneId ~= SceneManager.SceneID.UnionBossScene and SceneManager.curScene.sceneId ~= SceneManager.SceneID.ActiveBossScene then
			local center = self:findFixPoint(self.player, "sceneCenter")
			for i = self.player_list.Count, 1, -1 do
				local ply = self.player_list:get(i-1)
				if self.player.camp == 1 and ply.position.x >= center.x then
					self.player_list:remove(ply)
				elseif self.player.camp == -1 and ply.position.x < center.x then
					self.player_list:remove(ply)
				end
			end
		end
	end
end
--注册位置索引功能
function M:registerPosIndexFunc()
	if self.posIndexFunc == nil then
		self.posIndexFunc = {}
	end
	self.posIndexFunc["frontrow"] = function()
		local index = {}
		for i = 0, 4 do
			if self.player_list:get(0) ~= nil then
				if SceneManager.curScene.ZhenFaManager:isFront(self.player_list:get(0).camp, i) then
					table.insert(index, i)
				end
			end
		end
		return index;
	end

	self.posIndexFunc["backrow"] = function()
		local index = {}
		for i = 0, 4 do
			if self.player_list:get(0) ~= nil then
				if SceneManager.curScene.ZhenFaManager:isFront(self.player_list:get(0).camp, i) == false then
					table.insert(index, i)
				end
			end

		end
		return index;
	end

	self.posIndexFunc["position1"] = function()
		local index = {}
		table.insert(index, 0)
		return index;
	end

	self.posIndexFunc["position2"] = function()
		local index = {}
		table.insert(index, 1)
		return index;
	end

	self.posIndexFunc["position3"] = function()
		local index = {}
		table.insert(index, 2)
		return index;
	end

	self.posIndexFunc["position4"] = function()
		local index = {}
		table.insert(index, 3)
		return index;
	end

	self.posIndexFunc["position5"] = function()
		local index = {}
		table.insert(index, 4)
		return index;
	end

	self.posIndexFunc["oppositeTarget"] = function()
		local index = {}
		table.insert(index, self.player.index)
		return index;
	end
end

--注册位置类型功能
function M:registerPosTypeFunc()
	if self.posTypeFunc == nil then
		self.posTypeFunc = {}
	end
	self.posTypeFunc["distanceRecently"] = function()
		local findType = 1
		local operator = -1
		return findType,operator
	end

	self.posTypeFunc["distanceFarthest"] = function()
		local findType = 1
		local operator = 1
		return findType,operator
	end

	self.posTypeFunc["bloodLeast"] = function()
		local findType = 2
		local operator = -1
		return findType,operator
	end

	self.posTypeFunc["bloodMax"] = function()
		local findType = 2
		local operator = 1
		return findType,operator
	end

	self.posTypeFunc["defenseLeast"] = function()
		local findType = 3
		local operator = -1
		return findType,operator
	end

	self.posTypeFunc["defenseMax"] = function()
		local findType = 3
		local operator = 1
		return findType,operator
	end

	self.posTypeFunc["forceMax"] = function()
		local findType = 4
		local operator = 1
		return findType,operator
	end

	self.posTypeFunc["forceLeast"] = function()
		local findType = 4
		local operator = -1
		return findType,operator
	end

	self.posTypeFunc["ClosestToEnemy"] = function()
		local findType = 6
		local operator = 1
		return findType,operator
	end

	self.posTypeFunc["farthestFromEnemy"] = function()
		local findType = 6
		local operator = -1
		return findType,operator
	end

	self.posTypeFunc["AngerMax"] = function()
		local findType = 6
		local operator = 1
		return findType,operator
	end

	self.posTypeFunc["AngerLeast"] = function()
		local findType = 7
		local operator = -1
		return findType,operator
	end

	self.posTypeFunc["hpRateMax"] = function()
		local findType = 8
		local operator = 1
		return findType,operator
	end

	self.posTypeFunc["hpRateLeast"] = function()
		local findType = 8
		local operator = -1
		return findType,operator
	end
end

--注册排序功能
function M:registerSortFunc()
	if self.sortFunc == nil then
		self.sortFunc = {}
	end

	--查找类型 1 距离查找
	self.sortFunc[1] = function(a, b)
		local posResult = false
		local aDis = GlobalTools:Distance(self.player.position, a.position)
		local bDis = GlobalTools:Distance(self.player.position, b.position)
		if self.operator == 1 then
			--找最大值
			posResult = aDis < bDis
		elseif self.operator == -1 then
			--找最小值 
			posResult = aDis > bDis
		end
		return posResult;
	end
	
	--查找类型 2 血量查找
	self.sortFunc[2] = function(a, b)
		local posResult = false
		if self.operator == 1 then
			--找最大值
			posResult = a.data:get_curHp() < b.data:get_curHp()
		elseif self.operator == -1 then
			--找最小值 
			posResult = a.data:get_curHp() > b.data:get_curHp()
		end
		return posResult;
	end

	--查找类型 3 防御查找
	self.sortFunc[3] = function(a, b)
		local posResult = false
		if self.operator == 1 then
			--找最大值
			posResult = a.data.def:getValue() < b.data.def:getValue()
		elseif self.operator == -1 then
			--找最小值 
			posResult = a.data.def:getValue() > b.data.def:getValue()
		end
		return posResult;
	end

	--查找类型 4 战力查找
	self.sortFunc[4] = function(a, b)
		local posResult = false
		if self.operator == 1 then
			--找最大值
			posResult = a.data.atk:getValue() < b.data.atk:getValue()
		elseif self.operator == -1 then
			--找最小值 
			posResult = a.data.atk:getValue() > b.data.atk:getValue()
		end
		return posResult;
	end

	--查找类型 6 距离敌方位置
	self.sortFunc[6] = function(a, b)
		local posResult = false
		if self.operator == 1 then
			--找最大值
			if self.player.camp == 1 then
				posResult = a.position.x < b.position.x
			else
				posResult = a.position.x > b.position.x
			end
		elseif self.operator == -1 then
			--找最小值 
			if self.player.camp == 1 then
				posResult = a.position.x > b.position.x
			else
				posResult = a.position.x < b.position.x
			end
		end
		return posResult;
	end

	--查找类型 7 怒气查找
	self.sortFunc[7] = function(a, b)
		local posResult = false
		if self.operator == 1 then
			--找最大值
			posResult = a.data:get_curAnger() < b.data:get_curAnger()
		elseif self.operator == -1 then
			--找最小值 
			posResult = a.data:get_curAnger() > b.data:get_curAnger()
		end
		return posResult;
	end

	--查找类型 8 血量百分比查找
	self.sortFunc[8] = function(a, b)
		local posResult = false
		if self.operator == 1 then
			--找最大值
			posResult = a.data:get_hpRate() < b.data:get_hpRate()
		elseif self.operator == -1 then
			--找最小值 
			posResult = a.data:get_hpRate() > b.data:get_hpRate()
		end
		return posResult;
	end
end

function M:registerCount()
	if self.countData == nil then
		self.countData = {one = 1,two = 2, three=3, four = 4}
	end
end

function M:registerRace()
	if self.raceData == nil then
		self.raceData = { LongTing = 1,CaoMang = 2,ShiZu = 3, YiZu = 4,GuiZhou = 5,ZhuiFeng = 6}
	end
end

function M:registerProfession()
	if self.professionData == nil then
		self.professionData = { strength = 1,agility = 2,fashi = 3 }
	end
end

function M:registerGender()
	if self.genderData == nil then
		self.genderData = { man = 1,woman = 2 }
	end
end

--阵营选择
function M:findCampPlayer()
	--魅惑处理
	if self.player.bufMgr ~= nil and#self.player.bufMgr:findBufByType("Charm") > 0 then
		--魅惑处理
		self.camp = self.charmCamp[self.camp] or self.camp
		--if self.camp == "enemy" then
		--	self.camp = "friendExceptSelf"
		--elseif self.camp == "friend" then
		--	self.camp = "enemy"
		--elseif self.camp == "friendExceptSelf" then
		--	self.camp = "enemy"
		--elseif self.camp == "curFriend" then
		--	self.camp = "enemy"
		--elseif self.camp == "myenemy" then
		--	self.camp = "friendExceptSelf"
		--end
	end
	
	--新的实现方式
	if self.campFuncPool ~= nil then
		local func = self.campFuncPool[self.camp]
		if func ~= nil then
			func()
		end
	end

	----全体（包括自己）
	--if self.camp == "all" then
	--	self.player_list = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp()):clone()
	--	local temp = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
	--	for i = 1, temp.Count do
	--		self.player_list:add(temp:get(i - 1))
	--	end
	----全体（不包括自己）
	--elseif self.camp == "allExceptSelf" then
	--	self.player_list = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp()):clone()
	--	local temp = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
	--	for i = 1, temp.Count do
	--		self.player_list:add(temp:get(i - 1))
	--	end
	--	self.player_list:remove(self.player)
	--elseif self.camp == "enemy" then
	--	self.player_list = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp()):clone()
	--elseif self.camp == "friend" then
	--	self.player_list = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp()):clone()
	--elseif self.camp == "self" then
	--	self.player_list = Battle.List.new()
	--	if self.player.master ~= nil then
	--		self.player_list:add(self.player.master)
	--	else
	--		self.player_list:add(self.player)
	--	end
	--elseif self.camp == "friendExceptSelf" then
	--	self.player_list = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp()):clone()
	--	self.player_list:remove(self.player)
	--	if self.player.master ~= nil then
	--		self.player_list:remove(self.player.master)
	--	end
	--elseif self.camp == "myenemy" then
	--	self.player_list = Battle.List.new()
	--	if self.player:get_enemy() ~= nil then
	--		self.player_list:add(self.player.enemy)
	--	else
	--		self.player_list = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp()):clone()
	--	end
	--elseif self.camp == "curFriend" then
	--	self.player_list = Battle.List.new()
	--	if self.player.friend ~= nil then
	--		self.player_list:add(self.player.friend)
	--	else
	--		self.player_list = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp()):clone()
	--	end
	--elseif self.camp == "master" then
	--	self.player_list = Battle.List.new()
	--	
	--	if self.player.master ~= nil then
	--		self.player_list:add(self.player.master)
	--	else
	--		self.player_list:add(self.player)
	--	end
	--elseif self.camp == "killerEnemy" then
	--	self.player_list = Battle.List.new()
	--	
	--	if self.player.killer ~= nil then
	--		self.player_list:add(self.player.killer)
	--	else
	--		self.player_list:add(self.player)
	--	end
	--
	--end
	
	--重置不重复锁敌的列表
	--if self.camp == "enemy" then
	--	if self.player.player_enemyList ~= nil then
	--		if self.targetNoRepeat == false then
	--			self.player.player_enemyList:clear()
	--		end
	--	end
	--end
	--移除列表的情况：死亡，已经被选择过，不能被锁定
	for i = self.player_list.Count, 1, -1 do
		local ply = self.player_list:get(i-1)
		if ply:isDead() or self.player.player_enemyList:contains(ply) then
			self.player_list:remove(ply)
		end
		
		local disappearBuff = ply.bufMgr:findBufByType("Disappear")
		if #disappearBuff > 0 then
			local disappearAll = false
			for k,v in ipairs(disappearBuff) do
				if v.bufWork.type == 0 then
					disappearAll = true
					break
				end
			end
			--不能被所有人锁定
			if disappearAll then
				self.player_list:remove(ply)
			else
				--不能被敌方锁定
				if self.camp == "enemy" or self.camp == "myenemy" or self.camp == "all" then
					self.player_list:remove(ply)
				end
			end
		end

		if self.ignoreSummon and ply.master ~= nil then
				--and ply.isSenior == false then
			
			self.player_list:remove(ply)
			table.insert(self.summonList, ply)
		end
	end
end

--范围选择
function M:findAreaPlayer()
	if self.areaFunc ~= nil then
		local func = self.areaFunc[self.area]
		if func ~= nil then
			func()
		end
	end
	--if self.area == "rectangle" then
	--	--范围是矩形
	--	for i=self.player_list.Count,1,-1 do
	--		local ply = self.player_list:get(i-1)
	--		--计算我的和敌人之间的方向
	--		local vec = ply.position - self.player.position
	--		--矩形前方距离
	--		if self.player.forward.x < GlobalTools.base0 then
	--			vec.x = GlobalTools:Mul( vec.x , -GlobalTools.base1 ) 
	--		end
	--		if vec.x < GlobalTools.base0 or vec.x > self.areaHeight then
	--			self.player_list:remove(ply)
	--		else
	--			if math.abs(vec.z) > self.areaWidth then
	--				self.player_list:remove(ply)
	--			end
	--		end
	--		--local forwardDis = FixVector3.Dot(self.player:getForward(), vec)
	--		--if forwardDis < 0 or forwardDis > self.areaHeight then
	--		--	self.player_list:remove(ply)
	--		--else
	--		--	if Mathf.Abs(FixVector3.Dot( self.player:getRight(), vec)) > self.areaWidth then
	--		--		self.player_list:remove(ply)
	--		--	end
	--		--end
	--	end
	--elseif self.area == "sector" then
	--	--范围是扇形
	--	for i=self.player_list.Count,1,-1 do
	--		local ply = self.player_list:get(i-1)
	--		--计算我的和敌人之间的方向
	--		local vec = ply.position - self.player.position;
	--		local nor_vec = FixVector3.Normalize(vec)
	--		local forward = self.player:getForward():Clone()
	--		forward.z = GlobalTools.base0;
	--		forward = FixVector3.Normalize(forward)
	--		if vec:SqrMagnitude() > GlobalTools:ToFix2( self.areaRadius ) then
	--			self.player_list:remove(ply)
	--		else
	--			
	--			local fix_dot = FixVector3.Dot(nor_vec, forward)
	--			--得到角度
	--			local tmpAngle = GlobalTools:ACos( fix_dot )
	--			if tmpAngle > GlobalTools:Mul(self.areaAngle, GlobalTools.base0_5) then
	--				self.player_list:remove(ply)
	--			end
	--		end
	--	end
	--elseif self.area == "enemyArea" then
	--	if SceneManager.curScene.sceneId ~= SceneManager.SceneID.BossScene and SceneManager.curScene.sceneId ~= SceneManager.SceneID.UnionBossScene then
	--		local center = self:findFixPoint(self.player, "sceneCenter")
	--		for i = self.player_list.Count, 1, -1 do
	--			local ply = self.player_list:get(i-1)
	--			if self.player.camp == 1 and ply.position.x <= center.x then
	--				self.player_list:remove(ply)
	--			elseif self.player.camp == -1 and ply.position.x > center.x then
	--				self.player_list:remove(ply)
	--			end
	--		end
	--	end
	--elseif self.area == "selfArea" then
	--	if SceneManager.curScene.sceneId ~= SceneManager.SceneID.BossScene and SceneManager.curScene.sceneId ~= SceneManager.SceneID.UnionBossScene then
	--		local center = self:findFixPoint(self.player, "sceneCenter")
	--		for i = self.player_list.Count, 1, -1 do
	--			local ply = self.player_list:get(i-1)
	--			if self.player.camp == 1 and ply.position.x >= center.x then
	--				self.player_list:remove(ply)
	--			elseif self.player.camp == -1 and ply.position.x < center.x then
	--				self.player_list:remove(ply)
	--			end
	--		end
	--	end
	--end
end

--固定位置选择
function M:findPosIndexPlayer()
	local index = {}
	if self.posIndexFunc ~= nil then
		local func = self.posIndexFunc[self.posIndex]
		if func ~= nil then
			index = func()
		end
	end
	--if self.posIndex == "frontrow" then
	--	for i = 0, 4 do
	--		if self.player_list:get(0) ~= nil then
	--			if SceneManager.curScene.ZhenFaManager:isFront(self.player_list:get(0).camp, i) then
	--				table.insert(index, i)
	--			end
	--		end
	--		
	--	end
	--elseif self.posIndex == "backrow" then
	--	for i = 0, 4 do
	--		if self.player_list:get(0) ~= nil then
	--			if SceneManager.curScene.ZhenFaManager:isFront(self.player_list:get(0).camp, i) == false then
	--				table.insert(index, i)
	--			end
	--		end
	--		
	--	end
	--elseif self.posIndex == "position1" then
	--	table.insert(index, 0)
	--elseif self.posIndex == "position2" then
	--	table.insert(index, 1)
	--elseif self.posIndex == "position3" then
	--	table.insert(index, 2)
	--elseif self.posIndex == "position4" then
	--	table.insert(index, 3)
	--elseif self.posIndex == "position5" then
	--	table.insert(index, 4)
	--elseif self.posIndex == "oppositeTarget" then
	--	table.insert(index, self.player.index)
	--end
	
	local list = nil
	if self.priority then
		list = self.priorityList
	else
		list = self.player_list
	end
	for i = list.Count, 1, -1 do
		local ply = list:get(i -1)
		local isPri = false
		for k,v in ipairs(index) do
			if ply.index == v then
				isPri = true
				break
			end
		end
		if isPri == false then
			if self.priority then
				self.priorityList:remove(ply)
				self.notPriorityList:add(ply)
			else
				self.player_list:remove(ply)
			end
		end
	end
end

--种族选择
function M:findRacePlayer()
	local list = nil
	if self.priority then
		list = self.priorityList
	else
		list = self.player_list
	end
	for i = list.Count, 1, -1 do
		local ply = list:get(i -1)
		if ply.plyData.race ~= self.race then
			if self.priority then
				self.priorityList:remove(ply)
				self.notPriorityList:add(ply)
			else
				self.player_list:remove(ply)
			end
		end
	end
end

---@param player PlayerModel
---@return boolean 是否是同阵营
function M:isSameRaceOrYuan(player, race2)
	if player.plyData.race == race2 then
		return true
	end
	
	if race2 <= 4 then	-- 金木水火1-4
		return player.plyData.race == 7	-- 元 Battle.EnumData.BATTLE_RACE.Yuan
	end
	return false
end

--类型选择
function M:findProfessionPlayer()
	local list = nil
	if self.priority then
		list = self.priorityList
	else
		list = self.player_list
	end
	for i = list.Count, 1, -1 do
		local ply = list:get(i -1)
		if ply.plyData.type ~= self.profession then
			if self.priority then
				self.priorityList:remove(ply)
				self.notPriorityList:add(ply)
			else
				self.player_list:remove(ply)
			end
		end
	end
end

--性别选择
function M:findGenderPlayer()
	local list = nil
	if self.priority then
		list = self.priorityList
	else
		list = self.player_list
	end
	for i = list.Count, 1, -1 do
		local ply = list:get(i -1)
		if tonumber(ply.plyData.sex) ~= self.gender then
			if self.priority then
				self.priorityList:remove(ply)
				self.notPriorityList:add(ply)
			else
				self.player_list:remove(ply)
			end
		end
	end
end

--role_type 1 护卫 2战士 3刺客 4 射手 5辅助 6术士
function M:findRoleTypePlayer()
	---@type Battle_List
	local list = nil
	if self.priority then
		list = self.priorityList
	else
		list = self.player_list
	end
	for i = list.Count, 1, -1 do
		local ply = list:get(i -1)
		if tonumber(ply.plyData.role_type) ~= self.roleType then
			if self.priority then
				self.priorityList:remove(ply)
				self.notPriorityList:add(ply)
			else
				self.player_list:remove(ply)
			end
		end
	end
end


--通过位置找玩家
function M:findPos_TypePlayer()
	self.findType = 0 -- 查找类型
	self.operator = 0  --操作符
	if self.posTypeFunc ~= nil then
		local func = self.posTypeFunc[self.posType]
		if func ~= nil then
			self.findType, self.operator = func()
		end
	end
	--if self.posType == "distanceRecently" then
	--	self.findType = 1
	--	self.operator = -1
	--elseif self.posType == "distanceFarthest" then
	--	self.findType = 1
	--	self.operator = 1
	--elseif self.posType == "bloodLeast" then
	--	self.findType = 2
	--	self.operator = -1
	--elseif self.posType == "bloodMax" then
	--	self.findType = 2
	--	self.operator = 1
	--elseif self.posType == "defenseLeast" then
	--	self.findType = 3
	--	self.operator = -1
	--elseif self.posType == "defenseMax" then
	--	self.findType = 3
	--	self.operator = 1
	--elseif self.posType == "forceMax" then
	--	self.findType = 4
	--	self.operator = 1
	--elseif self.posType == "forceLeast" then
	--	self.findType = 4
	--	self.operator = -1
	--elseif self.posType == "ClosestToEnemy" then
	--	self.findType = 6
	--	self.operator = 1
	--elseif self.posType == "farthestFromEnemy" then
	--	self.findType = 6
	--	self.operator = -1
	--elseif self.posType == "AngerMax" then
	--	self.findType = 7
	--	self.operator = 1
	--elseif self.posType == "AngerLeast" then
	--	self.findType = 7
	--	self.operator = -1
	--elseif self.posType == "hpRateMax" then
	--	self.findType = 8
	--	self.operator = 1
	--elseif self.posType == "hpRateLeast" then
	--	self.findType = 8
	--	self.operator = -1
	--end

	if self.findType ~= 0 and self.operator ~= 0 then
		if self.priority then
			self.priorityList:sort(self.sortFunction)
			self.notPriorityList:sort(self.sortFunction)
		else
			self.player_list:sort(self.sortFunction)
		end
	end
end

--找到玩家
function M:sort(a, b)
	local posResult = false
	if self.sortFunc ~= nil then
		local func = self.sortFunc[self.findType]
		if func ~= nil then
			posResult = func(a,b);
		end
	end
	--if self.findType == 1 then		--查找类型 1 距离查找
	--	local aDis = GlobalTools:Distance(self.player.position, a.position)
	--	local bDis = GlobalTools:Distance(self.player.position, b.position)
	--	if self.operator == 1 then
	--		--找最大值
	--		posResult = aDis < bDis
	--	elseif self.operator == -1 then
	--		--找最小值 
	--		posResult = aDis > bDis
	--	end
	--elseif self.findType == 2 then	--查找类型 2 血量查找
	--	if self.operator == 1 then
	--		--找最大值
	--		posResult = a.data:get_curHp() < b.data:get_curHp()
	--	elseif self.operator == -1 then
	--		--找最小值 
	--		posResult = a.data:get_curHp() > b.data:get_curHp()
	--	end
	--elseif self.findType == 3 then	--查找类型 3 防御查找
	--	if self.operator == 1 then
	--		--找最大值
	--		posResult = a.data.def:getValue() < b.data.def:getValue()
	--	elseif self.operator == -1 then
	--		--找最小值 
	--		posResult = a.data.def:getValue() > b.data.def:getValue()
	--	end
	--elseif self.findType == 4 then	--查找类型 4 战力查找
	--	if self.operator == 1 then
	--		--找最大值
	--		posResult = a.data.atk:getValue() < b.data.atk:getValue()
	--	elseif self.operator == -1 then
	--		--找最小值 
	--		posResult = a.data.atk:getValue() > b.data.atk:getValue()
	--	end
	--elseif self.findType == 6 then	--查找类型 6 距离敌方位置
	--	if self.operator == 1 then
	--		--找最大值
	--		if self.player.camp == 1 then
	--			posResult = a.position.x < b.position.x
	--		else
	--			posResult = a.position.x > b.position.x
	--		end
	--	elseif self.operator == -1 then
	--		--找最小值 
	--		if self.player.camp == 1 then
	--			posResult = a.position.x > b.position.x
	--		else
	--			posResult = a.position.x < b.position.x
	--		end
	--	end
	--elseif self.findType == 7 then   --查找类型 7 怒气查找
	--	if self.operator == 1 then
	--		--找最大值
	--		posResult = a.data:get_curAnger() < b.data:get_curAnger()
	--	elseif self.operator == -1 then
	--		--找最小值 
	--		posResult = a.data:get_curAnger() > b.data:get_curAnger()
	--	end
	--elseif self.findType == 8 then	--查找类型 8 血量百分比查找
	--	if self.operator == 1 then
	--		--找最大值
	--		posResult = a.data:get_hpRate() < b.data:get_hpRate()
	--	elseif self.operator == -1 then
	--		--找最小值 
	--		posResult = a.data:get_hpRate() > b.data:get_hpRate()
	--	end
	--end
	return posResult
end

--玩家数量
function M:findCountPlayer()
	local playerCount = self.countData[self.count] or 0
	--if self.count == "one" then
	--	playerCount = 1
	--elseif self.count == "two" then
	--	playerCount = 2
	--elseif self.count == "three" then
	--	playerCount = 3
	--elseif self.count == "four" then
	--	playerCount = 4
	--end
	if self.posType ~= "not" then
		if self.priority then
			if self.priorityList.Count >= playerCount then
				self.notPriorityList:clear()
				for i = self.priorityList.Count, 1, -1 do
					if i > playerCount then
						self.priorityList:removeAt(i - 1)
					end
				end
			else
				for i = self.notPriorityList.Count, 1, -1 do
					if i > playerCount - self.priorityList.Count then
						self.notPriorityList:removeAt(i - 1)
					end
				end
			end
		else
			for i = self.player_list.Count, 1, -1 do
				if i > playerCount then
					self.player_list:removeAt(i - 1)
				end
			end
		end
	else
		if self.priority then
			if self.priorityList.Count >= playerCount then
				self.notPriorityList:clear()
				self.priorityList = GlobalTools:RandomList(self.priorityList,playerCount)
			else
				for i = self.notPriorityList.Count, 1, -1 do
					self.notPriorityList = GlobalTools:RandomList(self.notPriorityList,playerCount - self.priorityList.Count)
				end
			end
		else
			self.player_list = GlobalTools:RandomList(self.player_list,playerCount)
		end
	end

	--整合结果
	if self.priority then
		self.player_list = self.priorityList
		for i = 1, self.notPriorityList.Count do
			self.player_list:add(self.notPriorityList:get(i - 1))
		end
	end

	--if self.ignoreSummon and #self.summonList > 0 and self.player_list.Count < playerCount then
	--	local index = 1
	--	for i = 1, playerCount - self.player_list.Count do
	--		-- self.player_list:add(self.summonList[index])
	--	end
	--end
end

M.fixPoint = nil

function M:resetFixPoint()
	self.fixPoint = {}
	local enemyPos0 = self:checkSpawnPoint(SceneManager:getCurSceneModel():findSpawnPosition(-1, 0))
	local enemyPos1 = self:checkSpawnPoint(SceneManager:getCurSceneModel():findSpawnPosition(-1, 1), enemyPos0)
	local enemyPos2 = self:checkSpawnPoint(SceneManager:getCurSceneModel():findSpawnPosition(-1, 2), enemyPos0)
	local enemyPos3 = self:checkSpawnPoint(SceneManager:getCurSceneModel():findSpawnPosition(-1, 3), enemyPos0)
	local enemyPos4 = self:checkSpawnPoint(SceneManager:getCurSceneModel():findSpawnPosition(-1, 4), enemyPos0)
	local selfPos0 = self:checkSpawnPoint(SceneManager:getCurSceneModel():findSpawnPosition(1, 0))
	local selfPos1 = self:checkSpawnPoint(SceneManager:getCurSceneModel():findSpawnPosition(1, 1), selfPos0)
	local selfPos2 = self:checkSpawnPoint(SceneManager:getCurSceneModel():findSpawnPosition(1, 2), selfPos0)
	local selfPos3 = self:checkSpawnPoint(SceneManager:getCurSceneModel():findSpawnPosition(1, 3), selfPos0)
	local selfPos4 = self:checkSpawnPoint(SceneManager:getCurSceneModel():findSpawnPosition(1, 4), selfPos0)

	local fixPos = SceneManager.curScene:findSceneFixPoint();
	self.fixPoint["enemyBackCenter"] = self:cloneVector3( enemyPos3 )
	local enemyBackCenter2 = (enemyPos2 + enemyPos3 + enemyPos4) / GlobalTools.base3;
	self.fixPoint["enemyBackCenter2"] = self:cloneVector3(enemyBackCenter2)	--3-5号位的中心为中心点
	local enemyFrontCenter = (enemyPos0 + enemyPos1) / GlobalTools.base2;
	self.fixPoint["enemyFrontCenter"] = self:cloneVector3( enemyFrontCenter )
	local enemyCenter = (self.fixPoint["enemyFrontCenter"] + self.fixPoint["enemyBackCenter"]) / GlobalTools.base2
	self.fixPoint["enemyCenter"] = self:cloneVector3(enemyCenter);
	self.fixPoint["sceneCenter"] = self:cloneVector3(fixPos)
	local selfFrontCenter = (selfPos0 + selfPos1) / GlobalTools.base2
	self.fixPoint["selfFrontCenter"] = self:cloneVector3( selfFrontCenter )
	self.fixPoint["selfBackCenter"] = self:cloneVector3( selfPos3 )
	local selfBackCenter2 = (selfPos2 + selfPos3 + selfPos4) / GlobalTools.base3;
	self.fixPoint["selfBackCenter2"] = self:cloneVector3(selfBackCenter2)	--3-5号位的中心为中心点
	local selfCenter = (self.fixPoint["selfFrontCenter"] + self.fixPoint["selfBackCenter"]) / GlobalTools.base2
	self.fixPoint["selfCenter"] = self:cloneVector3(selfCenter)
end

function M:findFixPoint(player, fixPoint, radius)
	if fixPoint == "Densearea" then
		radius = radius or GlobalTools.base2
		local players = player.plyMgr:DenseareaPlayer(radius, player.camp * -1)

		return self:GetCenterPoint(players)
	elseif fixPoint == "curPos" then
		return self:cloneVector3(player:get_position())
	else
		if player ~= nil and player.camp == -1 then
			if string.find (fixPoint, "enemy") then
				fixPoint = string.gsub(fixPoint, "enemy", "self")
			elseif string.find (fixPoint, "self") then
				fixPoint = string.gsub(fixPoint, "self", "enemy")
			end
		end
		if self.fixPoint ~= nil then
			return self:cloneVector3(self.fixPoint[fixPoint])
		else
			return FixVector3.New(0,0,0)
		end
	end
end

function M:GetCenterPoint(players)
	if #players > 0 then
		if #players == 1 then
			return players[1].position
		elseif #players == 2 then
			return (players[1].position + players[2].position)/GlobalTools.base2
		else
			local pos = players[1].position
			for i = 2, #players do
				pos = pos + players[i].position
			end
			pos = pos / GlobalTools:ToFix(#players)
			return pos
		end
	else
		return self:cloneVector3(self.fixPoint["sceneCenter"])
	end

end

function M:checkSpawnPoint(pos, defaultPos)
	if pos.x == 0 and pos.y == 0 and pos.z == 0 then
		if defaultPos == nil then
			Logger.logWarning("场景缺少出生点")
			return pos
		end
		return defaultPos
	end
	return pos
end

function M:cloneVector3(pos)
	local clonePos = FixVector3.New(0,0,0)
	clonePos.x = pos.x
	clonePos.y = pos.y
	clonePos.z = pos.z
	return clonePos
end

function M:clearPlayer( player )
	if self.player_list ~= nil then
		self.player_list:remove(player)
	end
	if self.priorityList ~= nil then
		self.priorityList:remove(player)
	end
	if self.notPriorityList ~= nil then
		self.notPriorityList:remove(player)
	end
	if self.player == player then
		self.player = nil;
	end
end

function M:clear()
	if self.player_list ~= nil then
		self.player_list:clear()
		self.player_list = nil;
	end
	if self.priorityList ~= nil then
		self.priorityList:clear();
		self.priorityList = nil;
	end
	if self.notPriorityList ~= nil then
		self.notPriorityList:clear();
		self.notPriorityList = nil;
	end
	if self.player ~= nil then
		self.player = nil;
	end
end

return M