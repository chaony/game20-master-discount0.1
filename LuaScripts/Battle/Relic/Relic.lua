---@class Relic 遗物基类
local M = class("Relic")

M.data = nil
M.mgr = nil

M.param = nil

M.relicCount = 1

---@param mgr RelicManager
---@param param ConfigTreasureConfig
---@param data ConfigHeirloom
function M:init(mgr, param, data)
	self.data = data
	self.mgr = mgr
	self.param = param
end

function M:get_camp()
	return self.mgr.camp
end

function M:hasRoleType( role_type )
	if self.data.role_type ~= nil then
		for i, v in ipairs(self.data.role_type) do
			if role_type == v then
				return true;
			end
		end
	end
	return false;
end

function M:playEffect( player )
	if self.data.Special ~= "" and self.data.Special ~= nil then
		local task = {
			id = self.param.id,
			ply = player,
			prefabName =  self.data.Special,
			autoTime = 1.2,
		}
		self.mgr:playEffect(task)
	end
end

--返回值（不受叠加次数影响）：数值
function M:getValueSimple(index)
	local value = self.data["param"][index]
	if value ~= nil then
		return value[2]
	else
		Logger.logError("无此参数", "遗物id："..self.data["group_id"])
		return 0
	end
end

--返回值（受叠加次数影响）：数值，类型
function M:getValue(index)
	local value = self.data["param"][index]
	if value ~= nil then
		return value[2] --[[* self.relicCount]], value[1]
	else
		Logger.logError("无此参数", "遗物id："..self.data["group_id"])
		return 0,0
	end
end

--直接处理表中数据
function M:dealWithData(player, name, index, type)
	local value, calType = self:getValue(index)
	if type == "reduce" then
		value = GlobalTools:Mul(value, -GlobalTools.base1)
	end
	self:dealWithValue(player, name, calType, value, type)
end

--处理传入的数据
function M:dealWithValue(player, name, calType, value)
	if calType == 1 then
		player.data[name]:addToAddList(value)
	elseif calType == 2 then
		player.data[name]:addToMulList(value)
	elseif calType == 3 then
		player.data[name]:addToMAAList(value, "relic")
	end
end

--直接处理表中数据（作为临时数据）
function M:dealWithDataTemp(player, name, index, type)
	local value, calType = self:getValue(index)
	if type == "reduce" then
		value = GlobalTools:Mul(value, -GlobalTools.base1)
	end
	self:dealWithValueTemp(player, name, calType, value, type)
end

--处理传入的数据
function M:dealWithValueTemp(player, name, calType, value)
	if calType == 1 then
		player.data[name]:addToAddListTemp(value)
	elseif calType == 2 then
		player.data[name]:addToMulListTemp(value)
	elseif calType == 3 then
		player.data[name]:addToMAAListTemp(value, "relic")
	end
end

--直接移除表中数据
function M:removeData(player, name, index, type)
	local value, calType = self:getValue(index)
	if type == "reduce" then
		value = GlobalTools:Mul(value, -GlobalTools.base1)
	end
	self:removeValue(player, name, calType, value, type)
end

--移除传入的数据
function M:removeValue(player, name, calType, value)
	if calType == 1 then
		player.data[name]:removeFromAddList(value)
	elseif calType == 2 then
		player.data[name]:removeFromMulList(value)
	elseif calType == 3 then
		player.data[name]:removeFromMAAList(value, "relic")
	end
end

function M:gameStart()
	
end

function M:spawnFinish()
	
end

function M:dataChangeTemp(killer, victim)
	
end

function M:update(dt, unsdt)
	
end

function M:gameover()

end

-- 不要使用这个方法
function M:destroy()
	-- 不要在这里写任何逻辑。方法不再使用。
	-- 移除遗物逻辑使用gameover方法
end

--玩家死亡
function M:playDead( dead, killer )
	
end

--攻击结束
function M:attackOver( killer, damage )
	
end

--技能开始
function M:skillStart( skillPlayer, skillData )
	
end

--技能结束
function M:skillEnd( skillPlayer, skillData )

end

--死亡之前
function M:beforeDead(dead, killer, damage)
	return damage;
end

return M