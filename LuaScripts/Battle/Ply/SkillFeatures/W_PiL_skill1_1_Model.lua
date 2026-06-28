--霹雳使用火药强化自己的武器，
--使自己的下三次普攻附带爆炸效果，对范围内的敌人造成150%攻击力的外功伤害并使其造成的伤害降低20%，持续5秒，该效果无法叠加
---@class W_PiL_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_PiL_skill1_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.index = self:getParam(1)
    self.buffId = self:getParam(2)
    self.start = false;
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end


--技能释放
function M:skillStart()
    --self.start = false
end


--技能结束
function M:skillEnd()
    self.start = true
    self.curIndex = self.index
end


--技能释放
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]
    if self.index > 3 then
        self.start = false
    end
    if config == nil or config.anim_name ~= "skill2" then
        if self.start == false and config.anim_name == "attack1" then
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
                self.player.bufMgr:addBufById(self.buffId, self.player)
            end
        else
            -- if ply.aiEngine.curState ~= nil then
            --     if ply.aiEngine.curState.anim_name == "idle" then
            --         ply.aiEngine.curState.extra_anim_name = ply.aiEngine.curState.anim_name .. "_skill1" 
            --     end
            -- end
        end  
    end
end

--技能释放
function M:SkillEndHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]
    if ply == self.player and self.start and(config == nil or config.anim_name ~= "skill2") and ply:isLive() == true then
        if config ~= nil then  
            -- if config.anim_name == "attack1" then
            --     self.index = self.index + 1
            -- end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
end


return M