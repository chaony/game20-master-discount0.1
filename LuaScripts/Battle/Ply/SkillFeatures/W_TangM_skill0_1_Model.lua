---@class W_TangM_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TangM_skill0_1_Model", SkillFeatures_Model)

local table_data = require("Battle.Ply.SkillFeaturesData.W_TangM_skill0_1_Data")
M.bulletData = table_data.bulletData;
M.bulletEffectData = table_data.bulletEffectData;
M.selectData = table_data.selectData;

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.buffId = self:getParam(1)
    self.bulletData.buffId = tostring(self.buffId)
	EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
end

--条件触发
function M:deadHandler( eventName, data )
	local ply = data["data"]
	if  SceneManager.curScene.sceneId ~= 1 then
		local enemy = nil
		local list = SelectTargetTool:findPlayerByType(self.selectData,self.player)
		--循环敌人列表
		for i=list.Count,1,-1 do
			enemy = list:get(i-1)
			--enemy.bufMgr:addBufById(self.buffId, self.player)
		end
		if enemy ~= nil then
			self:bulletInit(self.bulletData, enemy.position, enemy)
		end
	end
end

--创建子弹
function M:bulletInit(data, position, target)
    --加载预制
    local createData = {}
    createData.data = data;
    createData.position = position;
    createData.target = target;
    createData.skill = self.skill;
    createData.bulletType = data.bulletType;
    createData.bulletEffectData = self.bulletEffectData;
    createData.player = self.player;
    --将子弹加入到人物管理器
    self.player.bulletMgr:createBullet(createData)
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end

return M