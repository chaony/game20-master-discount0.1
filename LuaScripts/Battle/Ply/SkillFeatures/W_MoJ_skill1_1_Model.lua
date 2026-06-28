--战斗开始时，墨家会在自身所在位置建造一个机关塔，机关塔拥有墨家70%的血量和60%的攻击力，机关塔存在期间会持续攻击范围内的敌人，机关塔被破坏时，会在原地留下一个残骸
---@class W_MoJ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_MoJ_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hp = self:getParam(1)
    self.atk = self:getParam(2)
	EventDispatcher:registerEvent("SendForFinish", {self,self.sendForHandler})
    EventDispatcher:registerEvent("killPlayer", {self, self.killPlayerHandler})
end

--出生
function M:spawn()
    M.super.spawn(self)
    local skill0 = self.player.plySkill:getSkillByName("skill0")
    if skill0 ~= nil then
        self.skill0 = skill0.cur_skill_config.feature
    end
end

function M:killPlayerHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]

    --墨家死亡
    if victim:equal(self.player) then
        if self.skill0 ~= nil then
            self.skill0:removeBuff()
        end
        if self.summon ~= nil then
            local attack1_item = self.summon.plySkill:getSkillByName("attack1")
            if attack1_item ~= nil then
                local attack1 = attack1_item.cur_skill_config.feature
                if attack1.isDead == true or self.player.plyMgr.hero_list.Count <= 0 then
                    self.summon:destroy(true)
                end
            end
        end
        --队友死亡
    elseif victim:get_camp() == self.player:get_camp() then
        if self.summon ~= nil then
            if self.player.plyMgr.hero_list.Count <= 0 then     -- 我方全部死亡后，销毁召唤物
                self.summon:destroy(true)
            end
        end
        
    end
end

--召唤成功
function M:sendForHandler( eventName, data )
    local player = data["player"]
    if self.player:equal(player.master) == true then
        player.data.hp:setInitialValue(player.data:getCopyData(self.player.data.hp, true, self.hp))
        player.data.atk:setInitialValue(player.data:getCopyData(self.player.data.atk, true, self.atk))
        player.data.def:setInitialValue(player.data:getCopyData(self.player.data.def, true, self.atk))
        player.data:set_curHp(player.data:get_hp())
        if self.player.index ~= 0 and self.player.index ~= 1 then
            local pos = player.position
            if player:getForward().x > 0 then
                pos.x = pos.x + GlobalTools.base0_5
            else
                pos.x = pos.x - GlobalTools.base0_5
            end
            player:setPos(pos, true)
        end 
        self.summon = player
        if self.skill0 ~= nil then
            self.skill0:addBuff()
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
    EventDispatcher:unRegisterEvent("SendForFinish", {self,self.sendForHandler})
    M.super.destroy(self)
end


return M