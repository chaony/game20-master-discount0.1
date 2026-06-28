--战斗开始时，姐姐会瞬移至己方攻击力最高的后排侠客的身后，弟弟会瞬移至己方防御力最高的己方前排侠客身后，并持续跟随改侠客直到战斗结束。
--被姐姐跟随的侠客，会获得昆仑30%的攻击，被弟弟跟随的侠客，会获得昆仑血量30%的生命上限
---@class W_KunL_Nan_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field defMaxFriend PlayerModel
local M = class("W_KunL_Nan_skill1_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --姐姐
    self.jiejieBuff = self:getParam(1)
    --弟弟
    self.didiBuff = self:getParam(2)
    --不能被选中buf
    self.disappearBuff = self:getParam(3)

    self.distance = 0
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
    --注册callMe回调
    self.player.callMe = function()
        self:checkSelfLive()
    end
end

--召唤
function M:SendForFinish()
    self:CheckDefMaxEnemy()
    if self.defMaxFriend ~= nil then
        self.player:useSkill("skill1", true)
        if self.skill2 ~= nil then
            self.skill2:follow(self.defMaxFriend)
        end
        if self.skill0 ~= nil then
            self.skill0:follow(self.defMaxFriend)
        end
        -- 无法被锁定
        self.player.bufMgr:addBufById(self.disappearBuff, self.player, self.skill)
    end
end

--更新
function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)
    if self.defMaxFriend then
        --如果追随者死了
        if not self.defMaxFriend:isLive() then
            self:checkSelfLive();
            self:callMaster();
        end
    end
end


function M:callMaster()
    if self.player.master ~= nil then
        if self.player.master.followTarget ~= nil then
            self.player.master.followTarget = nil;
        end
        if self.player.master.callMe ~= nil then
            self.player.master.callMe()
        end
    end
end


function M:checkSelfLive()
    --去掉自己的跟随者
    self.player.followTarget = nil
    --去掉跟随者的buf
    if self.defMaxFriend ~= nil then
        self.defMaxFriend.bufMgr:removeBufById(self.didiBuff, true)
        self.defMaxFriend = nil
    end
    -- 无法被锁定
    self.player.bufMgr:removeBufById(self.disappearBuff, true)
    if self.player.master ~= nil then
        self:moveFront(self.player.master)
    end
    
end

--技能发送
function M:skillDispatch(data)
    if data.eventName == "other_skill1_move" then
        if self.defMaxFriend ~= nil then
            self.player:setPos(self.defMaxFriend:get_position() - self.defMaxFriend:getForward() * GlobalTools.base1_5, true)
        end
    end
end


--移动到目标前面
function M:moveFront(present_Target)
    local dir = present_Target:getForward();
    local forward = dir * self.distance
    local pos = present_Target.position + forward
    self.player:setPos( pos );
    self:setForward(present_Target)
end


--设置召唤物方向
function M:setForward(present_Target)
    local final_dir = self.player.position - present_Target.position
    final_dir = final_dir * -GlobalTools.base1
    self.player:setForward( final_dir )
end


--检测防御力最高的
function M:CheckDefMaxEnemy()
    local friends = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
    local maxDefBack = 0
    local friendBack = nil
    for i = 1, friends.Count do
        local temp = friends:get(i - 1)
        if temp:isLive() == true and temp:equal(self.player) == false and temp:equal(self.player.master) ==false then
            if SceneManager.curScene.ZhenFaManager:isFront(temp:get_camp(), temp.index) == true then
                if maxDefBack <= temp.data.def:getValue() then
                    maxDefBack = temp.data.def:getValue()
                    friendBack = temp
                end
            end
        end
    end
    
    self.defMaxFriend = friendBack
    self.player.followTarget = self.defMaxFriend
    if friendBack ~= nil then
        --被弟弟跟随的侠客，会获得昆仑血量30%的生命上限
        friendBack.bufMgr:addBufById(self.didiBuff, self.player)
    end
end


function M:destroy()
    if self.defMaxFriend ~= nil then
        self.defMaxFriend.bufMgr:removeBufById(self.didiBuff, true)
        self.defMaxFriend = nil;
    end
    M.super.destroy(self)
end

return M