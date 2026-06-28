---@class BufManager_Model @场景内的Buf管理器
---@field player PlayerModel  @实际控制人
---@field bufList Battle_List @当前buf(我身上的buff)
---@field bufListFromMe  Battle_List @当前buf(我释放的buff)
---@field effectList table
---@field bufData table<number, ConfigBuff> @所有buf配置表
local M = class("BufManager_Model")

--bufManager 实际控制人
M.player = nil;
--当前buf(我身上的buff)
M.bufList = nil;
--当前buf(我释放的buff)
M.bufListFromMe = nil;

--所有buf
M.bufData = nil
--buff特效
M.bufEffect = nil

M.effectList = nil

--初始化buf管理
function M:init( player )
	self.player = player
	self.bufList = Battle.List.new()
	self.bufListFromMe = Battle.List.new()
	self.bufData = ConfigManager:getCfgByName("buff")
	--if Battle.ClassPathUtil:Exists("BattleView.Buf.buff_effect") then
	--	self.bufEffect = require("BattleView.Buf.buff_effect")
	--else
	--	self.bufEffect = require("DataCenter.Config.buff_effect")
	--end
	self.effectList = {}
end

function M:getBuffCfg(buffId)
	return self.bufData[buffId]
end

function M:canAddBuff()
	if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
		return;
	end
	if self.player ~= nil and self.player:isLive() then
		return true
	end
end

--根据id加入buf
---@param source PlayerModel
---@param sourceSkill SkillDataConfig
function M:addBufById( id, source, sourceSkill, sourceBuff)
	if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
		return;
	end
	if self.player ~= nil and self.player:isLive() and id ~= 0 and id ~= nil then
		local buf = self.bufData[id]
		if buf == nil then
			Logger.logError("buf表中没有找到 buf id = "..id )
			return nil
		end
		return self:addBufByData(buf, source, sourceSkill, id, sourceBuff)
	end
	return nil
end

--通过数据去创建buf
---@param bufData ConfigBuff
---@param source PlayerModel
---@param sourceSkill SkillDataConfig
function M:addBufByData( bufData, source, sourceSkill, id, sourceBuff)
	if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
		return;
	end
	if source ~= nil  then
		if bufData ~= nil then
			---@type Battle_AddBuff_Data
			local data = {}
			data["buffType"] = bufData["type"]
			data["buffDes"] = bufData["desc"]
			data["workRound"] = bufData["work_round"]
			data["lastTime"] = bufData["last_time"]
			data["workTime"] = bufData["work_time"]
			data["max_times"] = bufData["max_times"]
			data["delayTime"] = bufData["delay_time"]
			data["group_id"] = bufData["group_id"]
			data["level"] = bufData["level"]
			data["effect_id"] = bufData["effect_id"]
			data["heroLimit"] = bufData["heroLimit"]
			data["buffParam"] = {}
			data.buff_id = id
			data["buff_icon"] = bufData["buff_icon"]
			data["is_bufficon_count"] = bufData["is_bufficon_count"]
			if bufData["param"] ~= nil then
				for k,v in ipairs(bufData["param"]) do
					data["buffParam"][k] = v
				end
			end
			--data["buffEffect"] = {}
			--for k,v in pairs(bufData["effect_id"]) do
			--	local effectData = self.bufEffect[v]
			--	if effectData ~= nil then
			--		data["buffEffect"][k] = {}
			--		data["buffEffect"][k]["prefab"] = effectData["prefab"]
			--		data["buffEffect"][k]["effectType"] = effectData["effect_type"]
			--		data["buffEffect"][k]["isParent"] = effectData["is_parent"]
			--		data["buffEffect"][k]["effectParent"] = effectData["effect_parent"]
			--		data["buffEffect"][k]["offset"] = effectData["offset"]
			--		data["buffEffect"][k]["effectDestroyTime"] = effectData["effect_destroy_time"]
			--	else
			--		Logger.logError("buffEffect not found.  id:" .. v)
			--	end
			--end
			data["buffTags"] = bufData["tag"]
			data["buffExtraTags"] = bufData["tag_extra"]
			data["extra_buff"] = bufData["extra_buff"]
			data["audio"] = bufData["audio"]
			return self:addBuf(data, source, sourceSkill, id, sourceBuff)
		end
	end
end



function M:checkParam(paramDatam, param, default)
	local result = {}
	if paramDatam ~= nil then
		for k,v in ipairs(paramDatam) do
			for k1,v1 in ipairs(v) do
				if v1[1] == param then
					table.insert(result, v1[2])
				end
			end
		end
	end
	if #result == 0 then
		return default
	elseif #result == 1 then
		return result[1]
	else
		return result
	end
end




--buff命中计算
function M:heroLimit(data)
	--英雄限定判断，不符合不上buff
	if data["heroLimit"] ~= nil then
		for k,v in ipairs(data["heroLimit"]) do
			if v[1] == "race" and not table.indexof(v[2],self.player.plyData.race) then
				return false
			elseif v[1] == "roleType" and not table.indexof(v[2],self.player.plyData.role_type) then
				return false
			end
		end
	end
	return true
end


--真正加入buf的
---@param data Battle_AddBuff_Data
---@param source PlayerModel
---@param sourceSkill SkillDataConfig
function M:addBuf(data, source, sourceSkill, id, sourceBuff)
	if not self:canAddBuff() then
		return;
	end
	if self.player.plyState < 0 then
		return nil
	end

	if not self:heroLimit(data) then
		return
	end

	if data["buffType"] == "Shield" then
		-- 找到护盾buf
		if self:hasBufByType("ForbidShield") then
			return
		end
	end

	if SceneManager.curScene.collectData then
		SceneManager.curScene.collectData:causeBuff(source, self.player, sourceSkill, data, id)
	end

	if data["buffType"] == "Mark" then
		local buffs = self:findBufById(id)
		for k,v in ipairs(buffs) do
			if v.source:equal(source) then
				v:reset(false, data)
				return v
			end
		end
	elseif data["buffType"] == "Dot" then
		local buffs = self:findBufById(id)
		for k,v in ipairs(buffs) do
			v.source = source
			v:setBaseAtk(source.data:get_atk())
			v:reset(false, data)
			return v
		end
	elseif data["buffType"] == "BreakShield" or data["buffType"] == "ForbidShield" then
		-- 找到护盾buf
		local shidld_buf = self:findBufByType("Shield")
		for i, v in ipairs(shidld_buf) do
			self:removeBuf(v, true)
		end
	elseif data["buffType"] == "Imprison" then
		--如果是眩晕
		local tag = self:checkParam(data["buffTags"],"tag", "")
		self:removeBufByTag(tag, true)
	end

	local maxCount = (tonumber(data.max_times) or 0)
	--if maxCount > 0 and #existBuffs >= maxCount then
	--	return nil
	--end
	local existBuffs, curLevel = self:findBufByGroupId(data["group_id"])
	if maxCount > 0 then
		if maxCount == 1 then
			if #existBuffs > 0 then
				local buff = existBuffs[1]
				--新加buff等级高于或等于已有buff，替换已有buff
				if curLevel <= data["level"] then
					self:removeBuf(buff)
				--新加buff等级低于已有buff，添加buff失败
				else
					return nil
				end
			end
		elseif maxCount > 1 then
			if #existBuffs > 0 then
				--新加buff等级高于已有buff，已有buff升级
				if curLevel < data["level"] then
					for k,v in ipairs(existBuffs) do
						v:upgrade(data["buffParam"], data["level"])
					end
				--新加buff等级低于已有buff，新加buff升级
				elseif curLevel > data["level"] then
					local buf = existBuffs[1]
					data["buffParam"] = buf.data["buffParam"]
					data["level"] = curLevel
				end
				
				--buff满了之后，替换掉剩余时长最短的buff
				if #existBuffs >= maxCount then
					local minTime = math.maxinteger
					local buf = nil
					for k,v in ipairs(existBuffs) do
						if v.curLastTime < minTime then
							minTime = v.curLastTime
							buf = v
						end
					end
					self:removeBuf(buf, false)
				end
			end
		end
	end
	-- 判断如果人死亡就不给他加buff
	if self.player == nil or self.player:isDead() then
		return nil
	end

	-- ~~~~~~~~~~~~~~ buf 创建所需要的数据 ~~~~~~~~~~~~
	---@type Battle_CreateBuf_Data
	local createData = {}
	createData.id = id;
	if sourceSkill == nil then
		if source ~= nil then
			createData.sourceSkill = source.curSkillConfig;
		else
			Logger.logError(" 加入buf时 Source 是空 ")
		end
		createData.sourceType = 0
	else
		createData.sourceType = 1
		createData.sourceSkill = sourceSkill;
	end
	createData.sourceBuff = sourceBuff
	createData.mgr = self;
	createData.player = self.player;
	createData.source = source;
	--加入buf时当前的技能类型时必杀
	if source ~= nil and source.isInSkillState then
		createData.skillMode = 1
	else
		createData.skillMode = 0
	end
	-- ~~~~~~~~~~~~~~ buf 创建所需要的数据 ~~~~~~~~~~~~
	
	local buf = require("Battle.Buf.PlayerBuf_Model").new()
	buf:init(data, createData)

	if source ~= nil then
		if #existBuffs > 0 then
			local buff = existBuffs[1]
			if buff:getBaseAtk() < source.data:get_atk() then
				for k,v in ipairs(existBuffs) do
					v:setBaseAtk(source.data:get_atk() )
				end
				buf:setBaseAtk(source.data:get_atk() )
			else
				buf:setBaseAtk(buff:getBaseAtk())
			end
		else
			buf:setBaseAtk(source.data:get_atk() )
		end
	end

	if buf.type == "Imprison" or buf.type == "Break" then
		table.insert(buf.tag, "control")
	end

	if buf.type == "Charm" then 
		table.insert(buf.tag, "meihuo") -- 免疫魅惑
	end
	local isZhenShe = false
	if buf.tagExtra then
		for i, v in ipairs(buf.tagExtra) do
			if v == "zhenshe" then
				isZhenShe = true
				break
			end
		end
	end
	if not isZhenShe then
		local buffs = self:findBufByType("Immunity")
		for k, v in ipairs(buffs) do
			if v.bufWork ~= nil and v.bufWork:checkBuf(buf, source) == true then
				return nil
			end
		end
	end
	self.bufList:add(buf)
	buf:start();
	if source ~= nil then
		source.bufMgr.bufListFromMe:add(buf)
	end
	return buf
end

--更新buf
function M:update(time)
	if self.player ~= nil then
		for i = self.bufList.Count,1,-1 do
			---@type PlayerBuf_Model
			local buf = self.bufList:get(i-1);
			if buf ~= nil then
				if buf.mState == -1 then
					self.bufList:remove(buf)
				elseif buf.mState == 1 then
					buf:update(time)
				end
			end
		end
	end
end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim)
	for i = self.bufList.Count,1,-1 do
		local buf = self.bufList:get(i-1);
		if buf ~= nil and buf.bufWork ~= nil then
			buf.bufWork:killerDataChangeTemp(victim)
		end
	end
end

--作为受伤者的属性临时调整
function M:victimDataChangeTemp(killer)
	for i = self.bufList.Count,1,-1 do
		local buf = self.bufList:get(i-1);
		if buf ~= nil and buf.bufWork ~= nil then
			buf.bufWork:victimDataChangeTemp(killer)
		end
	end
end

function M:hasBufByType(type)
	for i = self.bufList.Count,1,-1 do
		local buf = self.bufList:get(i-1);
		if buf.type == type then
			return true;
		end
	end
	return false;
end

---@return boolean
function M:hasBufByTag(tag)
	for i = self.bufList.Count,1,-1 do
		local buf = self.bufList:get(i-1);
		if buf:checkTag(tag) then
			return true;
		end
	end
	return false;
end


---@return PlayerBuf_Model[]
function M:findBufByType(type)
	local tempList = {}
	for i = self.bufList.Count,1,-1 do
		local buf = self.bufList:get(i-1);
		if buf.type == type then
			table.insert(tempList, buf)
		end
	end
	return tempList
end

---@return PlayerBuf_Model[], number
function M:findBufByGroupId(groupId)
	local tempList = {}
	local level = 0
	if groupId ~= 0 then
		for i = self.bufList.Count,1,-1 do
			local buf = self.bufList:get(i-1);
			if buf.groupId == groupId then
				table.insert(tempList, buf)
				level = buf.curLevel
			end
		end
	end
	return tempList, level
end

---@return PlayerBuf_Model[]
function M:findBufById(id)
	local tempList = {}

	for i = self.bufList.Count,1,-1 do
		local buf = self.bufList:get(i-1);
		if buf.id == id then
			table.insert(tempList, buf)
		end
	end
	return tempList
end

--- 查找属于自身添加的buff
---@return PlayerBuf_Model[]
function M:findBufByFromMeType(type)
	local tempList = {}

	for i = self.bufListFromMe.Count,1,-1 do
		local buf = self.bufListFromMe:get(i-1);
		if buf.type == type then
			table.insert(tempList, buf)
		end
	end
	return tempList
end

---@return PlayerBuf_Model[]
function M:findBufByTag(tag)
	local tempList = {}

	for i = self.bufList.Count,1,-1 do
		local buf = self.bufList:get(i-1);
		if buf:checkTag(tag) then
			table.insert(tempList, buf)
		end
	end
	return tempList
end

---@return PlayerBuf_Model[]
function M:findBufByExtraTag(tag)
	local tempList = {}

	for i = self.bufList.Count,1,-1 do
		local buf = self.bufList:get(i-1);
		if buf:checkTag(tag) then
			table.insert(tempList, buf)
		end
	end
	return tempList
end

--删除buf
function M:removeBufById( id, isBreak, notAll )
	local tempList = {}
	
	for i = self.bufList.Count,1,-1 do
		local buf = self.bufList:get(i-1);
		if buf.id == id then
			table.insert(tempList, buf)
		end
	end

	for k,v in ipairs(tempList) do
		self:removeBuf(v, isBreak)
		if notAll == true then
			break
		end
	end
end

--删除buf
function M:removeBufByType( type, isBreak )
	local tempList = {}

	for i = self.bufList.Count,1,-1 do
		---@type PlayerBuf_Model
		local buf = self.bufList:get(i-1);
		if buf.type == type then
			table.insert(tempList, buf)
		end
	end

	for k,v in ipairs(tempList) do
		self:removeBuf(v, isBreak)
	end
end

--删除buf
function M:removeBufByTag( tag, isBreak)
	local tempList = self:findBufByTag(tag)
	for k,v in ipairs(tempList) do
		self:removeBuf(v, isBreak)
	end
end

--- 删除随机角色n个tag标签buf
---@return number @返回移除buff层数
function M:removeRandomOneBufByTag(tag, isBreak)
	local debuffs = self:findBufByTag(tag)
	if(#debuffs == 0)then
		return 0
	else
		local index = WRandom:randomNum(1, #debuffs + 1, true);
		self:removeBuf(debuffs[index], isBreak)  -- 不处理buff移除逻辑
		return 1
	end
end


--删除buf
---@param buf PlayerBuf_Model
function M:removeBuf( buf, isBreak )
	if not buf then
		Logger.logError("移除buff是空", debug.traceback())
		return
	end
	buf:stop(isBreak)
	if buf.source ~= nil then
		buf.source.bufMgr.bufListFromMe:remove(buf)
	end
	self.bufList:remove(buf)

	if buf.buffIcon ~= nil and #buf.buffIcon > 0 then
		self:refreshBuffIcon()
	end
	
	if buf.parasiticBuffList ~= nil then
		for k,v in ipairs(buf.parasiticBuffList) do
			if buf.source ~= nil then
				buf.source.bufMgr.bufListFromMe:remove(v)
			end
			self.bufList:remove(v)
			self:removeBuf(v,isBreak)
		end
	end
end

---@param player PlayerModel
---@param buff PlayerBuf_Model
---@param isBreak boolean
function M:dispelBuff(player, buff, isBreak)
	if SceneManager.curScene.collectData then
		SceneManager.curScene.collectData:dispelBuff(player, buff)
	end
	self:removeBuf(buff, true)
end

function M:refreshBuffIcon()
	if self.player ~= nil then
		self.player:dispatchEvent_Local(Battle.EventType.MV_BufManagerModelRefreshIcon)
	end
end
	
--清除buf
function M:clearBuf(  )
	local bufList = self.bufList:clone()
	for i = bufList.Count,1,-1 do
        local buf = bufList:get(i-1);
		if buf ~= nil and buf.isParasitic ~= true then
			buf:stop()
		end
	end
    self.bufList:clear()
	self.bufListFromMe:clear();
end

function M:checkBuf(type)
	for i = self.bufList.Count,1,-1 do
		local buf = self.bufList:get(i-1);
		if buf.type == type then
			return buf
		end
	end
end

function M:inDebuffState()
	if self.player == nil then
		return false;
	end
	if self.player.inDebuff then
		return true
	end
	local imprison = self.player.bufMgr:findBufByType("Imprison")
	local force = self.player.bufMgr:findBufByType("ForceMove")
	if table.nums(imprison) <= 0 and table.nums(force) <= 0 then
		return false
	end
	return true
end

function M:destoryBuffByPlayer(ply)
	for i = self.bufList.Count,1,-1 do
		local buf = self.bufList:get(i-1);
		if buf ~= nil then
			if buf.player == ply then
				self.bufList:remove(buf)
			end
		end
	end
	for i = self.bufListFromMe.Count,1,-1 do
		local buf = self.bufListFromMe:get(i-1);
		if buf ~= nil then
			if buf.player == ply then
				self.bufListFromMe:remove(buf)
			end
		end
	end
end

function M:destroy()
	self:clearBuf()
	self.player = nil
end

--- 调试方法，获取当前角色buff信息
function M:getDescribe()
	local buffIds = {}
	self.bufList:safeWalkInverted(function(buff)  
		table.insert(buffIds, string.format("%s:%s", buff.bufWork.__cname, buff.buffId))
	end)
	return string.format("BufMgr(%s):[%s]", self.player.plyType, table.concat(buffIds, ","))
end

return M