---@class PlayerSkillImprove @处理技能效果改变
---@field table table<number, ConfigEquipHeroSkill>
local M = class("PlayerSkillImprove")

M.player = nil

M.skill = nil

M.table = nil

M.typeTable = {
    "skill",
    "equip_hero",
}

M.type = nil

--初始化
function M:init(player)
    self.player = player
    self.table = {}
    --self.table["skill"] = ConfigManager:getCfgByName("skill_improve");
    self.table["equip_hero"] = ConfigManager:getCfgByName("equip_hero_skill");
    self.skill = {}
end

function M:addItem(type, id)
    if self.table[type] ~= nil and self.table[type][id] then
        self.skill[type..id] = self.table[type][id]
    end
end

function M:removeItem(type, id)
    self.skill[type .. id] = nil
end

---@param frame AnimEvtFrame_Model
function M:eventHandle(frame, skillConfig)
    local data = frame.data
    local type = data["eventName"]
    if skillConfig ~= nil then
        for k1,v1 in pairs(self.skill) do
            local eventStr = string.split(v1.add_event, "_")
            if skillConfig.id == v1.skill_id and string.lower(eventStr[1]) == string.lower(type) and tonumber(eventStr[2]) == frame.eventId then
                data = table.copy(data)
                if tonumber(v1.front_damage) >= 0 then
                    data.frontdamagePercent = v1.front_damage
                end
                if tonumber(v1.last_damage) >= 0 then
                    data.lastdamagePercent = v1.last_damage
                end
                if tonumber(v1.damage_reduce) >= 0 then
                    data.damageReduce = v1.damage_reduce
                end
                if tonumber(v1.puncturedmg) >= 0 then
                    if v1.puncturedmg == 1 then
                        data.puncturedmg = true
                    else
                        data.puncturedmg = false
                    end
                end
                if v1.buffid ~= "" and v1.buffid ~= 0 then
                    data.buffId = v1.buffid
                end
            end
        end
        
    end
    return data
end

function M:featureHandle(skillId)
    for k1,v1 in pairs(self.skill) do
        if skillId == v1.skill_id then
            return v1.param
        end
    end
    return nil
end

function M:clear()
    self.skill = {}
end

function M:destroy()

end

return M