--黑屏时间控制
---@class BlackTimeManager @
---@field plyMgr PlayerManager_Model
local M = class("BlackTimeManager")
--我的玩家
function M:init( plyMgr )
    --玩家管理器
    self.plyMgr = plyMgr;
    --当前黑屏时间
    self.curBlackTime = 0;
    --使用大招的人物
    self.useSkill3_players = Battle.List.new()
end

--开始黑屏时间
function M:startBlackTime( player, blackTime )
    --只有当前的黑屏时间小于0的时候才是开始
    if player ~= nil then
        --黑屏开始
        self:playerStartBlackTime(player)
        --宠物逻辑 
        for i = 1, player.summonList.list.Count do
            local key = player.summonList.list:get(i-1)
            local plys = player.summonList:get(key)
            for i, v in ipairs(plys) do
                self:playerStartBlackTime(v)
            end
        end
        --if player.summon ~= nil then
        --    for k,v in pairs(player.summon) do
        --        for k1,v1 in pairs(v) do
        --            self:playerStartBlackTime(v1)
        --        end
        --    end
        --end
        if player.master ~= nil then
            self:playerStartBlackTime(player.master)
        end
        --通知玩家管理器黑屏开始
        self.plyMgr:startBlackTimeHandler();
    end
    if self.curBlackTime < blackTime then
        self.curBlackTime = blackTime;
    end
end

---@param player PlayerModel
function M:playerStartBlackTime(player)
    --黑屏开始
    player:startBlackTimeHandler();
    --加入放大招列表
    if self.useSkill3_players:contains(player) == false then
        self.useSkill3_players:add( player )
    end
end

--更新
function M:updateBlackTime( dt )
    if self.curBlackTime > 0 then
        self.curBlackTime = self.curBlackTime - dt;
        if self.curBlackTime <= 0 then
            self:overBlackTime();
            self.curBlackTime = 0;
        end
    end
end

--结束黑屏时间
function M:overBlackTime()
    for i = 1, self.useSkill3_players.Count do
        ---@type PlayerModel
        local player = self.useSkill3_players:get(i-1)
        if player ~= nil then
            player:skill3Over()
            player:overBlackTimeHandler();
        end
    end
    self.useSkill3_players:clear();
    self.plyMgr:overBlackTimeHandler();
end

function M:gameOver()
    self:overBlackTime()
    self.curBlackTime = 0
end

function M:destroy()
    self:gameOver()
end

return M;