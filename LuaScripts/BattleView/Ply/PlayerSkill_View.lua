--玩家的技能管理器 
---@class PlayerSkill_View @
local M = class("PlayerSkill_View")

--技能初始化
function M:init( player )
	self.player = player;
	self.skillFeature_list = Battle.List.new()
	self.player:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelCreateFinish, {self, self.SkillFeaturesModelCreateFinish});
end

--技能Model创建完成
function M:SkillFeaturesModelCreateFinish(eventName, data)
	--技能的Model
	local skillFeature_model = data;
	local fileName_view = "BattleView."..skillFeature_model.className.."_View"
	if Battle.ClassPathUtil:Exists(fileName_view) then
		--技能视图
		local skillFeature_view = require(fileName_view).new();
		--注册 model 和 view 的事件发送
		SceneManager.MV_EventMgr:register(skillFeature_view, skillFeature_model);
		skillFeature_view:init(self.player, skillFeature_model.skill, skillFeature_model)
		--把技能视图加入到列表中
		self.skillFeature_list:add( skillFeature_view )
	else
		Logger.logError(" ClassPathUtil 没有找到！！！ "..fileName_view )
	end
end

--技能事件
function M:loadFinish(data)
	for i = 1, self.skillFeature_list.Count do
		local feature = self.skillFeature_list:get(i - 1)
		if feature ~= nil and feature ~= nil then
			feature:loadFinish(data)
		end
	end
end

--销毁
function M:destroy()
	for i = 1, self.skillFeature_list.Count do
		local skillFeature = self.skillFeature_list:get(i - 1)
		skillFeature:destroy()
	end
	self.skillFeature_list:clear()
end

return M