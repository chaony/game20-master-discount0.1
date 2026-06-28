--战斗开始时，姐姐会瞬移至己方攻击力最高的后排侠客的身后，弟弟会瞬移至己方防御力最高的己方前排侠客身后，并持续跟随改侠客直到战斗结束。
--被姐姐跟随的侠客，会获得昆仑30%的攻击，被弟弟跟随的侠客，会获得昆仑血量30%的生命上限
---@class W_KunL_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field other PlayerModel 召唤的弟弟
---@field atkMaxFriend PlayerModel 跟随对象
---@field isFollowTargetDeath PlayerModel 跟随对象
---@field skill0 W_KunL_skill0_1_Model
---@field skill2 W_KunL_skill2_1_Model
local M = class("W_KunL_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --姐姐
    self.jiejieBuff = self:getParam(1)
    --弟弟
    self.didiBuff = self:getParam(2)
    --不能被选中buf
    self.disappearBuff = self:getParam(3)
end

--出生
function M:spawn()
    M.super.spawn(self)
    local skill2Item = self.player.plySkill:getSkillByName("skill2")
    if skill2Item ~= nil then
        self.skill2 = skill2Item.cur_skill_config.feature
    end
    local skill0Item = self.player.plySkill:getSkillByName("skill0")
    if skill0Item ~= nil then
        self.skill0 = skill0Item.cur_skill_config.feature
    end
    self.checkSelfFollowTarget = true;
    
    self.player.callMe = function()
        self:checkSelfLive()
    end
end

--召唤结束
function M:SendForFinish(other)
    --我的灵魂伴侣
    self.other = other
    self:CheckAtkMaxEnemy()
    if self.atkMaxFriend ~= nil then
        self.player:useSkill("skill1", true)
        if self.skill2 ~= nil then
            self.skill2:follow(self.atkMaxFriend)
        end
        if self.skill0 ~= nil then
            self.skill0:follow(self.atkMaxFriend)
        end
        -- 无法被锁定
        self.player.bufMgr:addBufById(self.disappearBuff, self.player, self.skill)
    end
end

--更新
function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)
    if self.atkMaxFriend then
        if not self.atkMaxFriend:isLive() then
            self:checkSelfLive()
            self:callOther()
        end
    end
end



function M:callOther()
    --姐姐跟随的敌人死亡了
    --如果弟弟有跟随目标的时候
    if self.other ~= nil and self.other:isLive() then
        --把宠物的跟随目标也置空
        if self.other.followTarget ~= nil then
            self.other.followTarget = nil;
            --通知宠物
        end
        if self.other.callMe ~= nil then
            self.other.callMe()
        end
    end
end


--检测自身是否死亡
function M:checkSelfLive()
    --我跟随的人死亡了,丢失跟随
    self.player.followTarget = nil
    --去掉跟随者身上的buf 
    if self.atkMaxFriend ~= nil then
        self.atkMaxFriend.bufMgr:removeBufById(self.jiejieBuff, true)
        self.atkMaxFriend = nil
    end
    -- 无法被锁定
    self.player.bufMgr:removeBufById(self.disappearBuff, true)
end


--技能发送
function M:skillDispatch(data)
    if data.eventName == "skill1_move" then
        if self.atkMaxFriend ~= nil then
            self.player:setPos(self.atkMaxFriend:get_position() - self.atkMaxFriend:getForward() * GlobalTools.base1_5, true)
        end
    end
end

--寻找攻击力最高的后排
function M:CheckAtkMaxEnemy()
    local friends = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
    local maxAtkBack = 0
    local friendBack = nil
    for i = 1, friends.Count do
        local temp = friends:get(i - 1)
        if temp:isLive() == true and temp:equal(self.player) == false and temp:equal(self.other) ==false then
            if SceneManager.curScene.ZhenFaManager:isFront(temp:get_camp(), temp.index) == false then
                if maxAtkBack <= temp.data.atk:getValue() then
                    maxAtkBack = temp.data.atk:getValue()
                    friendBack = temp
                end
            end
        end
    end
    --攻击力最大的玩家
    self.atkMaxFriend = friendBack
    self.player.followTarget = self.atkMaxFriend
    
    if friendBack ~= nil then
        --被姐姐跟随的侠客，会获得昆仑30%的攻击
        friendBack.bufMgr:addBufById(self.jiejieBuff, self.player)
    end
end

--销毁
function M:destroy()
    if self.atkMaxFriend ~= nil then
        self.atkMaxFriend.bufMgr:removeBufById(self.jiejieBuff, true)
        self.atkMaxFriend = nil;
    end
    M.super.destroy(self)
end

return M