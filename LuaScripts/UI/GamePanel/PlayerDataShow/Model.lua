local M = class("PlayerDataShowModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self.attackList = {};
	self.injureList = {};
	self:getData()
end

--加入伤害数据
function M:AddDamageData( data )
	local damage_log = {};
	damage_log.killer = data.plyType;
	damage_log.victim = data.plyType;
	damage_log.damage = data.damage;
	damage_log.skill = data.skill;
	damage_log.isCrit = data.crit;
	damage_log.isGod = data.god;
	damage_log.isDodge = data.dodge;
	if data.isKiller == true then
		table.insert(self.attackList, damage_log)
	else
		table.insert(self.injureList, damage_log)
	end
end


function M:onEnter()
	self.prop_data = {}
	if SceneManager.curScene ~= nil then
		if SceneManager.curScene.plyMgr ~= nil then
			--英雄列表
			local hero_list = SceneManager.curScene.plyMgr.hero_list;
			for i = 1,hero_list.Count do
				local ply = hero_list:get(i-1);
				local data_item = {};
				data_item.name = ply.plyType;
				data_item.playerInstanceId = ply:get_playerInstanceId();
				local attrs = {}
				for k,v in pairs(ply.data.dataList) do
					table.insert(attrs,{key = v, value = ply.data[v].value } )
				end
				table.insert(attrs, {key = "anger", value = ply.angerData.curAnger } )
				data_item.baseProp = attrs;
				table.insert(self.prop_data, data_item);
			end
			--敌人列表
			local enemy_list = SceneManager.curScene.plyMgr.enemy_list;
			for i = 1,enemy_list.Count do
				local ply = enemy_list:get(i-1);
				local data_item = {};
				data_item.name = ply.plyType;
				data_item.playerInstanceId = ply:get_playerInstanceId();
				local attrs = {}
				for k,v in pairs(ply.data.dataList) do
					table.insert(attrs,{key = v, value = ply.data[v].value } )
				end
				table.insert(attrs, {key = "anger", value = ply.angerData.curAnger } )
				data_item.baseProp = attrs;
				table.insert(self.prop_data, data_item);
			end
		end
	end
end

--属性显示数据
function M:getPropShowData()
	local logs = self.prop_data
	return logs
end

return M
