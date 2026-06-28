---@class SelectTargetUtil @目标选择方法
local M = class("SelectTargetTool")

M.CampRace = { 
	--[[1 金]] "LongTing", 
	--[[2 火]] "CaoMang", 
	--[[3 木]] "ShiZu", 
	--[[4 水]] "YiZu", 
	--[[5 阳]] "GuiZhou", 
	--[[6 阴]] "ZhuiFeng",
	--[[7 元]] "Yuan",
}

--- 获取数量对应的字符串
function M:getCountName(cnt)
	if cnt <= 1 then
		return "one"
	elseif cnt == 2 then
		return "two"
	elseif cnt == 3 then
		return "three"
	elseif cnt == 4 then
		return "four"
	else
		return "all"
	end
end

---@param player PlayerModel
---@return PlayerModel 寻找一个敌人
function M:findOneEnemy(player)
	local targets = self:findPlayerByParam(player,{camp = "enemy", count = "one"})
	return targets:get(0)
end

---@param player PlayerModel
---@return Battle_List 寻找我方的侠客队友
function M:findXieKeFriends(player)
	return self:findPlayerByParam(player,{camp = "friend", ignoreSummon = true})
end


---@param player PlayerModel
---@return Battle_List 寻找我方的侠客队友
function M:findXieKeFriendWithRace(player, race)
	local friends = self:findXieKeFriends(player)
	for i = friends.Count, 1, -1 do
		local friend = friends:get(i-1)
		if friend and (not SelectTargetTool:isSameRaceOrYuan(friend, race)) then
			friends:remove(friend)
		end
	end
	return friends
end


---@param player PlayerModel
---@return Battle_List 寻找队友
function M:findFriendsExceptSelf(player)
	return self:findPlayerByParam(player,{camp = "friendExceptSelf"})
end
------------------------------- 通用获取目标方法 --------------------------------
---@param player PlayerModel
---@param param BattleTargetSelectData
---@return Battle_List 寻找目标
---@param param BattleTargetSelectData
function M:findPlayerByParam(player, param)
	local data = {
		["count"] = "all",
		["camp"] = "all",
		["posIndex"] = "all",
		["priority"] = false,
		["ignoreSummon"] = false,
		["targetNoRepeat"] = false,
		["campRace"] = "not",
		["gender"] = "all",
		["pos"] = "not",
		["profession"] = "all",
		["area"] = "all",
		["roleType"] = 0,
		["areaWidth"] = 0,
		["areaHeight"] = 0,
		["areaAngle"] = 0,
		["areaRadius"] = 0,
		["forceSelect"] = false,
		["selectLast"] = false,
		["isFixPoint"] = false,
		["useSelf"] = false,
		["fixpoint"] = "enemyBackCenter"
	}
	for k, v in pairs(param) do
		data[k] = v
	end
	return SelectTargetTool:findPlayerByType(data, player)
end

return M