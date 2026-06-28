--战斗开始时，若周瑜位置相对的敌人为敌方攻击力最高的侠客，则会为敌方攻击力最高的侠客施加“策反”状态5秒，
--被策反的侠客会转而攻击自己的友军，但无法使用必杀技，策反状态无法免疫和清除，
--策反成功后，周瑜会获得30%的攻击力和攻速提升，若周瑜位置相对的敌人不是敌方攻击力最高的侠客，则周瑜会对位置相对的敌人造成200%攻击力的伤害，并使其眩晕3秒，
--若场上存在小乔，则小乔位置相对的是敌方攻击力最高的侠客也可触发策反
--策反成功后获得的攻速和攻击力提升增加至40%
--策反失败也会增加攻击力和攻速提升，但只有成功的1半效果
--策反失败造成的伤害提升至240%
---@class W_ZhouY_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ZhouY_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.ceFanOkEnemyBuf = self:getParam(1) -- 策反成功敌人buff
    self.ceFanOkSelfBuf = self:getParam(2) --  策反成功自己buff
    self.ceFanFailEnemyBuf = self:getParam(3) -- 策反失败敌人buff
    self.ceFanFailSelfBuf = self:getParam(4) -- 策反失败自己buff
    self.ceFanEnd = false
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.ceFanEnd = false
    self:ceFan()
end

function M:skillStart(data)
    self:ceFan()
end



function M:ceFan()
    if self.ceFanEnd ~= false then
        return
    end

    local enemyList = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
    if enemyList.Count == 0 then
        return
    end
    self.ceFanEnd = true
    local maxAtkTarget = nil
    local zhouYTarget = nil
    local maxAtk = GlobalTools.base0
    for i = 1, enemyList.Count do
        local enemy = enemyList:get(i - 1)
        if enemy.data.atk:getValue() > maxAtk then
            maxAtk = enemy.data.atk:getValue()
            maxAtkTarget = enemy
        end
        if enemy.index == self.player.index then
            zhouYTarget = enemy
        end
    end

    --local maxAtkTargets = SelectTargetUtil:findPlayerByParam(self.player, {
    --    camp = "enemy",
    --    ignoreSummon = true,
    --    pos = "forceMax",
    --    --priority = true,
    --})
    --if maxAtkTargets.Count == 0 then
    --    return
    --end

    --local maxAtkTarget = maxAtkTargets:get(0)
    --local zhouYTargets = SelectTargetUtil:findPlayerByParam(self.player, {
    --    camp = "enemy",
    --    posIndex = "oppositeTarget",
    --    ignoreSummon = true,
    --})
    local canCeFan = false
    local canZhouYCeFan = false
    --local zhouYTarget = nil
    --if zhouYTargets.Count > 0 then
    --    zhouYTarget = zhouYTargets:get(0)
    --end
    canZhouYCeFan = zhouYTarget ~= nil and zhouYTarget:equal(maxAtkTarget)
    canCeFan = canZhouYCeFan or canCeFan
    self:addCeFanBuff(self.player, zhouYTarget, canZhouYCeFan)

    local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
    friends:safeWalkInverted(function(ply)
        if ply ~= nil and ply:isLive() and ply.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.XiaoQ then
            --local xiaoQTargets = SelectTargetUtil:findPlayerByParam(ply, {
            --    camp = "enemy",
            --    posIndex = "oppositeTarget",
            --    ignoreSummon = true,
            --})
            local canXiaoQCeFan = false
            local xiaoQTarget = nil
            for i = 1, enemyList.Count do
                local enemy = enemyList:get(i - 1)
                if enemy.index == ply.index then
                    xiaoQTarget = enemy
                end
            end

            --if xiaoQTargets.Count > 0 then
            --    xiaoQTarget = xiaoQTargets:get(0)
            --end
            canXiaoQCeFan = xiaoQTarget ~= nil and xiaoQTarget:equal(maxAtkTarget)
            canCeFan = canXiaoQCeFan or canCeFan
            self:addCeFanBuff(ply, xiaoQTarget, canXiaoQCeFan)
        end
    end)

    if canCeFan then
        self.skill.extra_anim_name = "skill0"
    else
        self.skill.extra_anim_name = "skill0_1"
    end
end

function M:addCeFanBuff(mySelf, target, canCeFan)
    if canCeFan then
        if target ~= nil then
            target.bufMgr:addBufById(self.ceFanOkEnemyBuf,self.player)
        end
        mySelf.bufMgr:addBufById(self.ceFanOkSelfBuf, self.player)
    else
        if target ~= nil then
            target.bufMgr:addBufById(self.ceFanFailEnemyBuf,self.player)
        end
        if self.ceFanFailSelfBuf > 0 then
            mySelf.bufMgr:addBufById(self.ceFanFailSelfBuf, self.player)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M