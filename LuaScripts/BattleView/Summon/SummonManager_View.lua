--技能禁止
---@class SummonManager_View @
local M = class("SummonManager_View")

--连线数组
M.summonList = nil

M.maxNum = 1000

--我的管理者
M.player = nil
--初始化
function M:init(player)
	self.maxNum = 1000
	self.player = player
	self.summonList = {}
	self.player:addEventListener_Local(Battle.EventType.MV_SummonModelCreateFinish,{self,self.MV_SummonModelCreateFinish})
end

-- 宠物Model创建成功
function M:MV_SummonModelCreateFinish( eventName, data )
	local summon_model = data;
	local summon_view = require("BattleView.Summon.Summon_View");
	SceneManager.MV_EventMgr:register(summon_view, summon_model);
	summon_view:init(self.player, summon_model, self)
	self.summonList[summon_model] = summon_view;
end

--移除连线
function M:remove( model )
	self.summonList[model] = nil;
end

--清除所有子弹
function M:clear()
	for i, v in pairs(self.summonList) do
		v:destroy()
	end
	self.summonList = {}
end

function M:destroy()
	self:clear()
end

return M