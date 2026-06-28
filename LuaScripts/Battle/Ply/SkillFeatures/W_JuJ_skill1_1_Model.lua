--巨鲸 skill1 每隔8秒 巨鲸会使用海潮之力强化自身 使自己的下一次普工威力提升至180%攻击力且变为范围伤害
---@class W_JuJ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JuJ_skill1_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.index = self:getParam(1)
    self.buffId = self:getParam(2)
    self.equip_hero_id = self:getParam(3)
    self.attack1_skill1 = false
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end

function M:spawn()
    M.super.spawn(self)
end

--技能释放
function M:skillStart()
    self.start = false
end

--技能结束
function M:skillEnd()
    if self.attack1_skill1 == false then
        self.start = true
        self.curIndex = self.index
    end
    self.attack1_skill1 = false
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]
    -- if self.index > 3 then
    --     self.start = false
    -- end

    if config == nil or config.anim_name ~= "skill2" then
        if self.start == false and (config and config.anim_name == "attack1") then
            self.player.bufMgr:removeBufById(self.buffId)
        end

    end
    if ply == self.player and self.start and(config == nil or config.anim_name ~= "skill2") then
    
        if config ~= nil then  
            if config.anim_name == "attack1" then
                self.player:set_curSkillConfig(self.skill)
                self.curIndex = self.curIndex - 1
                self.player.curSkillConfig.extra_anim_name = "skill1_attack1"
                if self.curIndex <= 0 then
                     self.start = false
                end
                self.attack1_skill1 = true
                self.player.bufMgr:addBufById(self.buffId, self.player)
            end
        else
            if ply.aiEngine.curState ~= nil then
                if ply.aiEngine.curState.anim_name == "idle" then
                    ply.aiEngine.curState.extra_anim_name = ply.aiEngine.curState.anim_name .. "_skill2"
                end
            end
        end  
    end
end

--技能释放
function M:SkillEndHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]
    -- if ply == self.player and self.start and(config == nil or config.anim_name ~= "skill2") and ply:isLive() == true then
    --     if config ~= nil then  
    --         if config.anim_name == "attack1" then
    --             self.index = self.index + 1
    --         end
    --     end
    -- end
    -- if self.index > 3 then
        -- self.player.bufMgr:removeBufByType("Immunity")
        -- self:skill_end()
    -- end
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
end




return M