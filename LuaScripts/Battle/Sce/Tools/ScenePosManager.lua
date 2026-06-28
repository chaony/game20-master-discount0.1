--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-01-17 15:03:28
]]

--场景位置管理器
---@class ScenePosManager @
local M = class("ScenePosManager")

function M:init(type)
    self.type = type;
end

--当前位置是否可以放入此英雄
function M:canPutDown(pos_index, player)
    local param, value = self:caculateBossProperty(player.playerId, pos_index, 0);
    if param ~= nil and value ~= nil then
        if player.plyData["fight_type"] == param then
            return true;
        end
    end
    return false;
end


--能否移动
function M:canMove(pos_index,player)
    local param, value = self:caculateBossProperty(player.playerId, pos_index, 0);
    if param ~= nil and value ~= nil then
        if value == 0 then
            return false;
        end
    end
    return true;
end


--属性加成
function M:addProperty(pos_index,player)
    local param, value = self:caculateBossProperty(player.playerId, pos_index, 0);
    if param ~= nil and value ~= nil then
        if value == 0 then
            return false;
        end
    end
end



--计算boss属性加成
--1.普通关卡 2.世界boss 3.工会boss
--计算boss的属性加成
function M:caculateBossProperty( id, pos_index, pos_type )
	local pos_data = self:GetBossPropertyByPos(self.type, id, pos_index);
	if pos_data ~= nil then
		for k,v in pairs(pos_data) do
			--0 位置限定
			--1 属性加成
			--2 技能变化
			--3 技能伤害倍率改变
			local type = v[0];
			-- 位置限定
			-- 限定角色，0 不限定 1 限近战 2 限远程
			-- 属性加成
			-- common ID
			-- 技能变化
			-- 技能id
			-- 技能伤害倍率
			-- 技能id
			local param = v[1];
			-- 位置限定
			-- 是否可以移动 1 可移动 0 不可移动
			-- 属性加成
			-- buff数值 正数为增，负数为减
			-- 技能变化
			-- 生效开关 1 生效 0 无效
			-- 技能伤害倍率
			-- 伤害倍率，正数为增，负数为减
			local value = v[2];
			if type == pos_type then
                return param,value
            else
                return nil;
			end
		end
    end
    return nil
end


function M:GetBossPropertyByPos(id, pos_index)
	local type_data = ConfigManager:getCfgByName("boss_field")[self.type];
	--类型数据
	if type_data ~= nil then
		--id数据
		local id_data = type_data[id]
		if id_data ~= nil then
			for k,v in pairs(id_data.pos) do
				if k == pos_index then
					return v;
				end
			end
		end
	end
	return nil;
end

return M