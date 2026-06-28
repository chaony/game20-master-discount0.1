--灭神之稿
--落石将攻击受到控制效果的敌方武魂
---@class Relic_60 : Relic @
---@field super Relic @Relic
local M = class("Relic_60", Relic)

--时间间隔
M.interval = nil
--伤害
M.damage = nil

M.plyList = nil
--攻击类型
M.damageType = nil

M.sum = 0

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.damageType = data["param"][1][1]
	self.interval = self:getValue(2)
	self.damage = self:getValue(3)
end

function M:gameStart()
	M.super.gameStart(self)
	self.buffData =
	{
		["buffType"] = "AddEffect",
		["buffDes"] = "",
		["workRound"] = "1",
		["lastTime"] = "2",
		["workTime"] = "0",
		["delayTime"] = "0",
		["buffParam"] =
		{
		},
		["buffEffect"] =
		{
			[1] =
			{
				["prefab"] = "fx_Relics_LuoShi_01",
				["effectType"] = "startPlay",
				["effectParent"] = "effectpoint0",
				["effectDestroyTime"] = "2",
			},
		},
		["buffTags"] =
		{
			
		},
	}


	self.plyList = Battle.ListMap.new()

	EventDispatcher:registerEvent("add_debuff", {self,self.addDebuffHandler})
end
M.isStart = false
--debuff开始
function M:addDebuffHandler( eventName, data )
	local buff = data["buff"]
	if buff.player.camp == -1 then
		local plyData = self.plyList:get(buff.player)
		if plyData == nil then
			plyData = {}
			self.plyList:add(buff.player, plyData)
		end
		--if self.plyList[buff.player] == nil then
		--	self.plyList[buff.player] = {}
		--end
		table.insert(plyData, self.interval)
	end
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	if self.plyList ~= nil then
		local enemy = self.mgr:getTarget("enemy", "all")
		for i = 1, enemy.Count do
			local ply = enemy:get(i-1)
			local hp = ply.data:get_hp()
			self.sum = self.sum + hp
		end

		for i = 1, self.plyList.list.Count do
			local k1 = self.plyList.list:get(i-1)
			local v1 = self.plyList:get(k1)
			for k2, v2 in ipairs(v1) do
				v1[k2] = v1[k2] - dt
				if v1[k2] <= 0 then
					local sum_div_enem_len = GlobalTools:Div(self.sum, GlobalTools:ToFix(#self.enemy))
					local dmg = GlobalTools:Mul(sum_div_enem_len, self.damage)
					local attackData = BattleTool:getBaseAttackData()
					attackData["damage"] = dmg
					attackData["damageFront"] = GlobalTools.base1
					attackData["damageLast"] = GlobalTools.base1
					attackData["damageType"] = self.damageType
					attackData["mustHit"] = true
					if k1:isLive() then
						k1.bufMgr:addBuf(self.buffData, nil)
						k1:injure(attackData)
					end
					v1[k2] = nil
				end
			end
			if table.nums(v1) <= 0 then
				self.plyList:remove(k1)
			end
		end
	end
end


function M:gameover()
	M.super.gameover(self)
	EventDispatcher:unRegisterEvent("add_debuff", {self,self.addDebuffHandler})
end

return M