--召唤物
---@class Summon_View : ViewBase @
---@field super ViewBase @ViewBase
local M = class("Summon_View",Battle.ViewBase)


function M:init(player, model, mgr)
	self.mgr = mgr;
	self.player = player
	self.model = model;
	self.data = model:get_data()
	self.sourceSkill = model:get_skill()
	
	if self.data["prefab"] ~= nil and self.data["prefab"] ~= "nil" and self.data["prefab"] ~= "" then
		self.obj = ResourceUtil:LoadRole3dEffect(player.prefabRoot, self.data["prefab"], nil )
		if self.obj ~= nil then
			self.obj.transform.position = self.player.tran.position
		end
	end
	-- 播放特效
	self:addEventListener_Local(Battle.EventType.MV_SummonModelPlayEffect, {self,self.MV_SummonModelPlayEffect})
	-- 停止
	self:addEventListener_Local(Battle.EventType.MV_SummonModelStop, {self,self.MV_SummonModelStop})
	-- 销毁
	self:addEventListener_Local(Battle.EventType.MV_SummonModelDestroy, {self,self.MV_SummonModelDestroy})
end

function M:MV_SummonModelStop( eventName, data )
	self:stop();
end


function M:MV_SummonModelDestroy( eventName, data )
	self:destroy();
end

--播放特效宠物
function M:MV_SummonModelPlayEffect( eventName, data )
	if self.obj ~= nil then
		if self.data["destoryPrefab"] ~= nil and self.data["destoryPrefab"] ~= "nil" then
			local effectData = {}
			effectData["prefab"] = self.data["destoryPrefab"]
			effectData["autodestoryTime"] = 2
			effectData["isPutUpInParent"] = false
			effectData["parent"] = nil

			local prefabTrans = {}
			prefabTrans["useUserSet"] = true
			prefabTrans["identity"] = true

			prefabTrans["position"] = {
				[1] = self.player.tran.position.x,
				[2] = self.player.tran.position.y,
				[3] = self.player.tran.position.z,
			}
			prefabTrans["rotation"] = {
				[1] = 0,
				[2] = 0,
				[3] = 0,
			}
			prefabTrans["scale"] = {
				[1] = 1,
				[2] = 1,
				[3] = 1,
			}
			effectData["prefabTrans"] = prefabTrans
			self.player:playEffect(effectData,self.player,self.source)
		end
	end
end


function M:stop()
	self.player.summonMgr:remove(self.model)
end

function M:destroy()
	if self.obj ~= nil then
		ResourceUtil:ReturnItem(self.obj)
	end
end

return M