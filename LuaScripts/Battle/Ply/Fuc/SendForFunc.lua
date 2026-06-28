
--召唤物功能
---@class SendForFunc @
---@field master PlayerModel
---@field player PlayerModel
---@field data Battle_Frame_Data_Event_SendFor
local M = class("SendForFunc")

M.id = nil
--是否完成
M.finish = false
--克隆出的角色
M.player = nil
--数据
M.data = nil

--召唤者
M.master = nil

M.distance = 0

M.targetPos = nil

--初始化
function M:init(data, player, spawnFinish, initAiState)
    self.master = player
    self.finish = false;
    self.data = data
    self.id = data["summonName"]
    self.targetPos = data["targetPos"]
    self.distance = data["distance"]
    self.dirToTarget = data["dirToTarget"] ~= false
    self.summonType = data["summonType"]
    self.serialId = data["id"]
    self.aiType = data["aiType"]
    self.hpType = data["hpType"]
    self.is_sign = data["is_sign"]
    self.is_border = data["is_border"]
    self.dieWithMaster = data["dieWithMaster"] ~= false
    data["offset"].x = data["offset"].x
    data["offset"].y = data["offset"].y
    data["offset"].z = data["offset"].z
    self.initAiState = initAiState or "spawn"

    local playerData = { id = self.id, lv = self.master.data:get_level(), master = self.master, evo = 0, summonAiType = self.aiType,summonType = self.summonType }
    local master_skin = self.master.heroData.skin
    if master_skin ~= 0 then
        local skin = self.master.plyData.skin
        local index = table.indexof(skin, master_skin)
        if index ~= false then
            local hero_table = ConfigManager:getCfgByName("hero_detail")
            local hero_cfg = hero_table[self.id]
            playerData.skin = hero_cfg.skin[index]
        end
    end
    if SceneManager.curScene.sceneId ~= SceneManager.SceneID.QiMenDunJiaScene then
        --奇门遁甲不允许创建召唤物
        local enemys = SelectTargetTool:findPlayerByType(data["count"],player)
        if enemys.Count > 0 then
            for i = 1,enemys.Count do
                local ply = enemys:get(i-1)
                self:createPlayer_sendFor(ply,playerData,data, spawnFinish)
            end
        end
    end
end

function M:createPlayer_sendFor( ply ,playerData,data, spawnFinish)
    self.player = self.master.plyMgr:createPlayer(playerData, self.master.camp, self.master.index, nil, self.master)
    self.player:setScale(self.player.base_scale)
    self.player.data:set_moveSpeed( GlobalTools.base8 )
    self.player:set_playerInstanceId(self.player.playerId.."-"..self.master.plyMgr:getSummonIndex())
    if spawnFinish ~= nil then
        spawnFinish(self.player)
    end
    self:spawnMonster(self.player, ply, data)
end

function M:spawnMonster( ply, ply1, data )
    --ply.master = self.master
    ply.summonType = self.summonType
    ply.summonData = data
    --如果宠物列表中不包含
    if self.master.summonList:contains(self.serialId) == false then
        --加入一个空表进去
        self.master.summonList:add(self.serialId, {})
    end
    local plys = self.master.summonList:get(self.serialId)
    table.insert(plys, ply)
    
    self:calculateData()
    ply:spawn()
    ply.aiEngine:changeState(self.initAiState)
    self:moveDir(ply1)
    EventDispatcher:dipatchEvent("SendForFinish", { player = self.player })
end


--计算召唤物数值
function M:calculateData()
    self.player.data:set_level( self.master.data:get_level() )
    self.player.data:set_evo( self.master.data:get_evo() )
    self.player.plySkill:refreshSkill(nil)
    self.player.data:copyData(self.master, true, GlobalTools.base1)
    if self.hpType == "hpBase" then
        --之后需要改为面板血量
        self.player.data.hp:setInitialValue(self.master.data.hp.initialValue)
    elseif self.hpType == "fixValue" then
        self.fixValue = self.data["fixValue"]
        self.player.data.hp:setInitialValue(self.fixValue)
    elseif self.hpType == "percentValue" then
        self.percentValue = self.data["percentValue"]
        --local hp = GlobalTools:Mul( self.master.data:get_hp(), self.percentValue)
        --self.player.data.hp:setInitialValue(hp)
        self.player.data:copyData(self.master, true, self.percentValue)
    end
end

--更新
function M:update(dt, unsdt)
    
end

function M:moveDir(present_Target)
    if present_Target ~= nil then
        if self.data["targetPos"] == "Up"  then
            self:moveUp(present_Target)
        elseif self.data["targetPos"] == "Down" then
            self:moveDown(present_Target)
        elseif self.data["targetPos"] == "front" then
            self:moveFront(present_Target)
        elseif self.data["targetPos"] == "back" then
            self:moveBack(present_Target)
        elseif self.data["targetPos"] == "Left" then
            self:moveLeft(present_Target)
        elseif self.data["targetPos"] == "Right" then
            self:moveRight(present_Target)
        elseif self.data["targetPos"] == "RightUp" then
            self:moveRightUp(present_Target)
        elseif self.data["targetPos"] == "LeftUp" then
            self:moveLeftUp(present_Target)
        end
    end
end

--移动到目标后面
function M:moveBack(present_Target)
    local dir = present_Target:getForward()
    local forward = dir * -self.distance
    local pos = present_Target.position + forward
    if self.is_border == true then
        if SceneManager.curScene.getAreaPosition ~= nil then
            local lastPos = pos:Clone()
            SceneManager.curScene:getAreaPosition(pos)
            if lastPos ~= pos then
                pos = present_Target.position - forward
            end           
        end
    end
    
    self.player:setPos( pos );
    self:setForward(present_Target)
end

--移动到目标前面
function M:moveFront(present_Target)
    local dir = present_Target:getForward();
    local forward = dir * self.distance
    local pos = present_Target.position + forward
    self.player:setPos( pos );
    self:setForward(present_Target)
end

--移动到目标左面
function M:moveLeft(present_Target)
    local dir = present_Target:getRight();
    local forward = dir * -self.distance
    local pos = present_Target.position + forward
    self.player:setPos(pos);
    self:setForward(present_Target)
end

--移动到目标右面
function M:moveRight(present_Target)
    local dir = present_Target:getRight();
    local forward = dir * self.distance
    local pos = present_Target.position + forward
    self.player:setPos( pos );
    self:setForward(present_Target)
end

--移动到目标右上面
function M:moveRightUp(present_Target)
    local right = present_Target:getRight();
    local right_dis = right *  self.distance;
    local pos = present_Target.position + right_dis
    self.player:setPos( pos );
    local forward = self.player:getForward();
    local forward_dis =  forward * self.distance;
    local pos1 = self.player.position + forward_dis
    self.player:setPos( pos1 );
    self.player:setForward( forward )
end

--移动到目标左上面
function M:moveLeftUp(present_Target)
    local right = present_Target:getRight();
    local right_dis = right * -self.distance;
    local pos = present_Target.position + right_dis
    self.player:setPos( pos );
    local forward = self.player:getForward();
    local forward_dis = forward * self.distance;
    local pos1 = self.player.position + forward_dis
    self.player:setPos( pos1 );
    self.player:setForward( forward )
end

--移动到目标上面
function M:moveUp(present_Target)
    local up = present_Target:getUp();
    local up_dis =  up * self.distance;
    local pos = present_Target.position + up_dis
    self.player:setPos(pos);
    self.player:setForward( present_Target:getForward() )
end

--移动到目标下面
function M:moveDown(present_Target)
    local up = present_Target:getUp();
    local up_dis = up * -self.distance;
    local pos = present_Target.position + up_dis
    self.player:setPos(pos);
    self.player:setForward( present_Target:getForward() )
end

--设置召唤物方向
function M:setForward(present_Target)
    local final_dir = self.player.position - present_Target.position
    if self.dirToTarget == true then
        final_dir = final_dir * -GlobalTools.base1
    end
    self.player:setForward( final_dir )
end

return M