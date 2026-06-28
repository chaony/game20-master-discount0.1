--纯阳 大招效果持续期间，普工会使敌人流血5秒 流血状态下的敌人每秒受到60%的攻击力的外伤伤害，该状态可叠加 最多3层
---@class W_ChunY_skill3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ChunY_skill3_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffid = self:getParam(1)
    self.max_time = self:getParam(2)
    self.timer = self.max_time
    self.start = false;
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:spawn()
    self.skill0 = self.player.plySkill:getSkillByName("skill0")
end

---@param data Battle_BeHitDirectData
function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    local injureType = data.attackData["injureType"]
    local wantdata = data["wantdata"]
    local dmg = wantdata["damage"]
    if victim ~= nil and victim:equal(self.player) == false and injureType ~= "dot" then
        if ply ~= nil and ply:equal(self.player) and skillConfig ~= nil and skillConfig.anim_name == "attack1"  then
            if self.start then
                victim.bufMgr:addBufById(self.buffid, self.player, self.skill)
            end
        end
    end
end



--技能释放
function M:skillStart()
    self.start = true
    if self.skill0 ~= nil then
        self.skill0.cur_skill_config.feature:addSkillId()
        -- self.player.skillImprove:addItem("equip_hero",)
    end
    -- 人剑合一开始
    if self.player.skyStar then
        self.player.skyStar:triggerStart(self)
    end
end

function M:update(dt,unsdt)
    if self.start then  
        self.timer = self.timer - dt
        if self.timer <= GlobalTools.base0 then
            self.start = false
            self.timer = self.max_time
            if self.skill0 ~= nil then
                self.skill0.cur_skill_config.feature:removeSkillId()
            end

            -- 人剑合一开始
            if self.player.skyStar then
                self.player.skyStar:triggerEnd(self)
            end
        end
    end
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]

    if self.start and ply == self.player then
        
        if self.timer > GlobalTools.base0 then
            if config ~= nil then  
                if config.anim_name == "attack1" then
                    config.extra_anim_name = "attack1_skill3"  
                end
            end  
        end
        
    end
end




function M:destroy()
    M.super.destroy(self)
    self.start = false
    -- EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end


return M