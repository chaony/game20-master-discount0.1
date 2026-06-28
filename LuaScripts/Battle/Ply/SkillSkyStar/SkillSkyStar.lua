-- 天命化星基础类
---@class SkillSkyStar
---@field player PlayerModel
---@field param ConfigFateStar
local M = class("SkillSkyStar")

--初始化时
---@param player PlayerModel
---@param param ConfigFateStar
function M:init( player, param, level )
    self.player = player;
    self.param = param;
    self.level = level;
end

-- 获取参数
function M:getParam(index, default)
    default = default or 0
    local config_data = self.param["param"][self.level]
    if config_data ~= nil then
        return config_data[index] or default
    end
    return default;
end

-- 游戏开始时
function M:gameStart()
    
end

-- 攻击帧开始之前
---@param frameData AnimEvtFrame_Model
---@param data Battle_Frame_Data_Event_Hit
function M:hitFrame(frameData, data)
    return data
end

-- 射击帧开始之前
---@param data Battle_Frame_Data_Event_Hit
function M:shootFrame( evtFrame, data )
    
end

-- 攻击结束时
---@param victim PlayerModel
---@param killer PlayerModel
---@param wantdata Battle_BeHitDirectData_WantData
function M:attackOver(victim, killer, wantdata)
    
end

-- 技能开始
---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillStart( ply, skill )

end

-- 技能结束
---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillEnd( ply, skill )

end

-- 触发开始
function M:triggerStart( data )
    
end

-- 触发结束
function M:triggerEnd( data )
    
end

function M:destroy()
    
end

-- 持续更新
function M:update( time )
    
end

function M:getTarget(target,count)
    local targets = Battle.List.new()
    local player = self.player.plyMgr:getPlayers(self.player.camp):get(0)
    if player == nil and self.player:isLive() then
        player = self.player
    end
    if player ~= nil then
        local data =
        {
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
        if count ~= nil then
            data["posIndex"] = count
        end
        --无敌人
        if target == "not" then
            targets = Battle.List.new()
        elseif target == "self" then
            --我方全体
            data["camp"] = "friend"
            targets = SelectTargetTool:findPlayerByType(data, player)
        elseif target == "enemy" then
            --敌方全体
            data["camp"] = "enemy"
            targets = SelectTargetTool:findPlayerByType(data, player)
        else
            --id为target的人
            data["camp"] = "friend"
            targets = Battle.List.new()
            local temp = SelectTargetTool:findPlayerByType(data, player)
            for i = 1, temp.Count do
                if temp:get(i - 1):equal(player) == false then
                    targets:add(temp:get(i - 1))
                end
            end
        end
    end
    return targets
end

return M;