--当嵩山的生命值低于30%时，会立即使用寒冰真气冰封自身4秒，
--期间无法攻击也不会受到任何伤害，并每秒恢复最大生命值的15%，
--每场战斗仅可触发1次。
local W_SongS_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_SongS_skill0_1_Model")
---@class W_SongS_skill0_2_Model : W_SongS_skill0_1_Model @
---@field super W_SongS_skill0_1_Model @W_SongS_skill0_1_Model
local M = class("W_SongS_skill0_2_Model", W_SongS_skill0_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffid6 = self:getParam(6) --伤害buf
    self.radius = self:getParam(7) --范围
    self.cur_time = GlobalTools.base1;
end


function M:altersBuf( dt )
    self.cur_time = self.cur_time - dt
    if self.cur_time <= 0 then
        self.cur_time = GlobalTools.base1
        if self.skill_Start then
            local players = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
            for i = 1, players.Count do
                local player = players:get(i - 1)
                if player ~= nil then
                    if GlobalTools:Distance(player.position, self.player.position) <= GlobalTools:ToFix2( self.radius ) then
                        player.bufMgr:addBufById(self.buffid6, self.player)
                    end
                end
            end
        end
    end
end


function M:destroy()
	M.super.destroy(self)
end

return M