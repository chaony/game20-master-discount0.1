-- 天命化星管理器
---@class SkillSkyStarManager
---@field player PlayerModel
---@field skyStars SkillSkyStar[]
---@field fate_skill table<number, ConfigFateStar>
local M = class("SkillSkyStarManager")

function M:ctor()
    self.skyStars = {}
end

-- 天命化星等级 level
function M:init( player, level )
    self.player = player;
    self.level = level;
    self.fate_skill = ConfigManager:getCfgByName("fate_skill")
    self:registerLuaScript();
end

-- 注册lua脚本
function M:registerLuaScript()
    for i = self.level, 1, -1 do
        local className = "Battle.Ply.SkillSkyStar."..self.player.default_plyType.."_SkyStar_skill"..i
        if Battle.ClassPathUtil:Exists(className) then
            self:registerSkyStarSkill(className, i)
        else
            if i == 3 then  -- 如果天命3没有角色技能脚本，使用通用天命技能脚本
                local className = "Battle.Ply.SkillSkyStar.SkyStar_Common_Skill3"
                self:registerSkyStarSkill(className, i)
            else
                --    Logger.logError(" 没有找到天命化星的控制类 [ "..className.." ]" )
            end
        end
    end
end

function M:registerSkyStarSkill(className, level)
    local hero_fate_skill_config = self.fate_skill[self.player.plyData.id]
    if hero_fate_skill_config ~= nil then
        ---@type SkillSkyStar
        local skyStar = require(className).new()
        skyStar:init(self.player, hero_fate_skill_config, level)
        table.insert(self.skyStars, skyStar)
    end
end

--战斗开始
function M:gameStart()
    for i, v in ipairs(self.skyStars) do
        v:gameStart()
    end
end

--更新时间
function M:update(time)
    for i, v in ipairs(self.skyStars) do
        v:update(time)
    end
end

-- 触发开始
---@param data PlayerModel | Battle_HandleData_Attack | table
function M:triggerStart( data, ...)
    for i, v in ipairs(self.skyStars) do
        v:triggerStart(data, ...) 
    end
end

-- 攻击之前
---@param frameData AnimEvtFrame_Model
---@param data Battle_Frame_Data_Event_Hit
function M:hitFrame(frameData, data)
    for i, v in ipairs(self.skyStars) do
        data = v:hitFrame(frameData, data)
    end
    return data
end

-- 攻击之前
---@param data Battle_Frame_Data_Event_Hit
function M:shootFrame( evtFrame, data )
    for i, v in ipairs(self.skyStars) do
        v:shootFrame( evtFrame, data )
    end
end

-- 攻击结束
---@param ply PlayerModel
---@param killer PlayerModel
---@param wantdata Battle_BeHitDirectData_WantData
function M:attackOver(ply, killer, wantdata)
    for i, v in ipairs(self.skyStars) do
        v:attackOver(ply, killer, wantdata)
    end
end

-- 触发结束
---@param data PlayerModel
function M:triggerEnd(data)
    for i, v in ipairs(self.skyStars) do
        v:triggerEnd(data)
    end
end

-- 技能开始
---@param ply PlayerModel
function M:skillStart( ply, skill )
    for i, v in ipairs(self.skyStars) do
        v:skillStart( ply, skill )
    end
end

-- 技能结束
---@param ply PlayerModel
function M:skillEnd( ply, skill )
    for i, v in ipairs(self.skyStars) do
        v:skillEnd( ply, skill )
    end
end

-- 销毁
function M:destroy()
    for i, v in ipairs(self.skyStars) do
        v:destroy()
    end
    self.skyStars = {}
end

return M;