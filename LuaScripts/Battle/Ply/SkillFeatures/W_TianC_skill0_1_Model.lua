--“无双”状态持续期间，天策每击杀一个敌人，持续时间就增加1秒。--已修改
--新 无双状态持续期间，所有被天策攻击到的敌人，都会被添加一层“威慑”状态
---@class W_TianC_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianC_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.maxCount = self:getParam(1)
    EventDispatcher:registerEvent("injure", {self, self.injureHandler})
end

function M:spawn()
    M.super.spawn(self)
    local skill2 = self.player.plySkill:getSkillByName("skill2")
    if skill2 ~= nil then
        self.skill2 = skill2.cur_skill_config.feature 
    end

    local skill3 = self.player.plySkill:getSkillByName("skill3")
    if skill3 ~= nil and skill3.cur_skill_config ~= nil then
        self.skill3 = skill3.cur_skill_config.feature
    end
end


function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    local wantdata = data["wantdata"]
    local dmg = wantdata["damage"]
    if victim ~= nil then
        if ply ~= nil and ply:equal(self.player)  then
           if self.skill3 ~= nil then
                if self.skill3.start then
                    if self.skill2 ~= nil then
                        self.skill2:isGoonAdd(victim)
                    end
                    --这里需要skill2的参数 威慑buf
                end
           end
        end
    end
end


function M:destroy()
	M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
end

return M