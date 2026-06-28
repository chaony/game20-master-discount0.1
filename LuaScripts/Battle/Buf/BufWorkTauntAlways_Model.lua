--持续嘲讽
---@class BufWorkTauntAlways : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkTauntAlways", BufWork_Model)


function M:initFinish()
	self.range = self.playerBuf:checkParam("range",GlobalTools.base10)
	self.list = {}
end

function M:update( time )
	M.super.update(self, time)
	local enemys = SceneManager.curScene.plyMgr:getPlayers(-self.playerBuf.player:get_camp())
	for i = 1, enemys.Count do
		local enemy = enemys:get(i - 1)
		local dist =  GlobalTools:Distance(enemy.position, self.playerBuf.player.position)
		if dist <= GlobalTools:ToFix2(self.range) then
			if table.keyof(enemy.tauntList, self.playerBuf.player) == nil then
				enemy:add_tauntList(self.playerBuf.player)
				table.insert(self.list, enemy)
				enemy:lockEnemy(nil)
			end
		else
			if table.keyof(enemy.tauntList, self.playerBuf.player) ~= nil then
				enemy:remove_tauntList(self.playerBuf.player, true)
				table.removebyvalue(self.list, enemy)
			end
		end
	end
end

function M:stop()
	M.super.stop(self)
	for k,v in ipairs(self.list) do
		v:remove_tauntList(self.playerBuf.player, true)
	end
	self.list = {}
end

return M