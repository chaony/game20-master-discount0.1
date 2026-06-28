--为一名随机敌方侠客添加“极毒印记”，并立即将其引爆，引爆的“极毒印记”会对大范围内的敌人造成300%攻击力的内功伤害，并施加一层中毒
---@class W_XingX_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XingX_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1) --极毒印记buf传到参数
    self.dis = self:getParam(2) --范围
    self.atk = self:getParam(3) -- 攻击力
    self.buffId2 = self:getParam(4) -- 眩晕buf
    self.buffId3 = self:getParam(5) -- 爆炸特效buf
    self.skll1_buffId = 0
    self.skill1_boomBuffId = 0
    self.skill_Start = false
    self.skill1_dis = GlobalTools.base0
end


function M:spawn()
    M.super.spawn(self)
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil and skill1.cur_skill_config ~= nil then
        self.skill1 = skill1.cur_skill_config.feature
        if self.skill1 ~= nil then
            self.skll1_buffId = self.skill1.buffId --剧毒印记buf
            self.maxTime = self.skill1.maxTime --存在时长
            self.atk = self.skill1.atk -- 攻击力
            self.skill1_boomBuffId = self.skill1.buffid3 -- skill1 爆炸特效buf
            self.skill1_dis = self.skill1.dis  -- skill1 的范围
        end
    end
    EventDispatcher:registerEvent("remove_W_XingX_skill3", {self,self.addBuffHandler})
end


function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and buff.player ~= nil and buff.player.camp ~= self.player.camp then
        if buff.source:equal(self.player) then
            local enemys = SceneManager.curScene.plyMgr:getPlayers(buff.player:get_camp())
            for i = 1, enemys.Count do
                local enemy = enemys:get(i-1)
                if enemy ~= nil then
                    local W_XingX_skill1 = enemy.bufMgr:findBufByTag("W_XingX_skill1")
                    if table.nums(W_XingX_skill1) > 0 then
                        enemy.bufMgr:removeBufByTag("W_XingX_skill1", false)
                    end
                end
            end
        end
    end
end


--function M:dmgHandler(distance,enemy,dis)
--    if distance <= dis then
--        local attackData = {}
--        attackData["damage"] = GlobalTools:Mul( self.player.data.atk:getValue(), self.atk )
--        attackData["player"] = self.player
--        attackData["damageFront"] = GlobalTools.base1
--        attackData["damageLast"] = GlobalTools.base1
--        attackData["angerAir"] = 0GlobalTools.base0
--        attackData["type"] = 0
--        attackData["injureBuf"] = 0
--        attackData["damageType"] = 1 
--        attackData["injureType"] = "areaDmg"
--        enemy:injure(attackData)
--    end
--end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("remove_W_XingX_skill3", {self,self.addBuffHandler})
end

return M