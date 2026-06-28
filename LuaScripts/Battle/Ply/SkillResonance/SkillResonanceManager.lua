-- 共鸣技能管理器
---@class SkillResonanceManager
---@field player PlayerModel
---@field resonances SkillResonance[]
---@field fate_skill table<number, ConfigResonance>
local M = class("SkillResonanceManager")

function M:ctor()
    self.resonances = {}
end



-- 共鸣等级 level
function M:init( player, level )
    self.player = player;
    self.level = level;
    self.resonance_skill = ConfigManager:getCfgByName("resonance_skill")
    self:registerLuaScript();
end

-- 注册lua脚本
function M:registerLuaScript()
    for i = 1, self.level, 1 do
        local className = "Battle.Ply.SkillResonance."..self.player.default_plyType.."_Resonance_skill"..i
        if Battle.ClassPathUtil:Exists(className) then
            self:registerResonanceSkill(className, i)
        end
    end
end

function M:registerResonanceSkill(className, level)
    local hero_resonance_skill_config = self.resonance_skill[self.player.plyData.id]
    if hero_resonance_skill_config ~= nil then
        ---@type SkillResonance
        local resonanceSkill = require(className).new()
        resonanceSkill:init(self.player, hero_resonance_skill_config, level)
        table.insert(self.resonances, resonanceSkill)
    end
end

--通过名字获取技能
---@return PlayerSkillItem
function M:getSkill( index )
    if self.resonances ~= nil then
        return self.resonances[index]
    end
    return nil
end

--战斗开始
function M:gameStart()
    for i, v in ipairs(self.resonances) do
        v:gameStart()
    end
end

--更新时间
function M:update(time)
    for i, v in ipairs(self.resonances) do
        v:update(time)
    end
end

-- 触发开始
---@param data PlayerModel | Battle_HandleData_Attack | table
function M:triggerStart( data, ...)
    for i, v in ipairs(self.resonances) do
        v:triggerStart(data, ...) 
    end
end

-- 攻击之前
---@param frameData AnimEvtFrame_Model
---@param data Battle_Frame_Data_Event_Hit
function M:hitFrame(frameData, data)
    for i, v in ipairs(self.resonances) do
        data = v:hitFrame(frameData, data)
    end
    return data
end

-- 攻击之前
---@param data Battle_Frame_Data_Event_Hit
function M:shootFrame( evtFrame, data )
    for i, v in ipairs(self.resonances) do
        v:shootFrame( evtFrame, data )
    end
end

-- 攻击结束
---@param ply PlayerModel
---@param killer PlayerModel
---@param wantdata Battle_BeHitDirectData_WantData
function M:attackOver(ply, killer, wantdata)
    for i, v in ipairs(self.resonances) do
        v:attackOver(ply, killer, wantdata)
    end
end

-- 触发结束
---@param data PlayerModel
function M:triggerEnd(data)
    for i, v in ipairs(self.resonances) do
        v:triggerEnd(data)
    end
end

-- 技能开始
---@param ply PlayerModel
function M:skillStart( ply, skill )
    for i, v in ipairs(self.resonances) do
        v:skillStart( ply, skill )
    end
end

-- 技能结束
---@param ply PlayerModel
function M:skillEnd( ply, skill )
    for i, v in ipairs(self.resonances) do
        v:skillEnd( ply, skill )
    end
end

-- 销毁
function M:destroy()
    for i, v in ipairs(self.resonances) do
        v:destroy()
    end
    self.resonances = {}
end

return M;