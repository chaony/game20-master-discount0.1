
--聚宝山场景
---@class PetHallScene_Model : Scene_Model @
---@field super Scene_Model @Scene_Model
local M = class("PetHallScene_Model",Battle.Scene_Model)

M.pet_state = {
    create = 0,
    idle = 1,
    idle_end = 2,
    move = 3,
    move_end = 4,
}

--初始化场景
function M:init()
    M.super.init(self)
    self.m_pet_max_num = 4
end

--进入场景
function M:enter( data )
    M.super.enter( self, data )
    self.m_min_pos = FixVector3.New(0, 0 ,0)
    self.m_min_pos.x = GlobalTools:CommonToFix(-4.33)
    self.m_min_pos.z = GlobalTools:CommonToFix(-4.70)
    self.m_max_pos = FixVector3.New(0, 0 , 0)
    self.m_max_pos.x = GlobalTools:CommonToFix(4.5)
    self.m_max_pos.z = GlobalTools:CommonToFix(-0.94)
    self.m_mid_pos = FixVector3.New(0, 0 , 0)
    self.m_mid_pos.z = GlobalTools:CommonToFix(-3.05)
    -- 展示宠物
    self.m_pets = {}
    self.moveTime = GlobalTools.base0_5;
    self.curMoveTime = 0;
    self.startPlayerMove = false
    self.pet_interact = false
    self.interactPetPly = nil
    self.interact_state = 0

    TimeManager:set_baseUpdateDelaTime(TimeManager.hangUpUpdateDelteTime)
end

function M:getPetsNullIndex()
    for i=1, self.m_pet_max_num do
        if self.m_pets[i] == nil then
            return i
        end
    end
end

function M:addPet(pet_data, is_origin)
    if pet_data then
        local index = self:getPetsNullIndex()
        if index then
            -- 计算出生坐标
            local position = self.m_mid_pos:CloneNew()
            if not is_origin then
                local x = (math.random(0, 883) - 433) * 0.01
                local z = (math.random(0, 376) - 470) * 0.01
                position.x = GlobalTools:CommonToFix(x)
                position.z = GlobalTools:CommonToFix(z)
            end

            local avatar,custom_prefab = UserDataManager.pet_data:getPetPrefebByOid(pet_data)
            if avatar then
                local playerData = { id = tonumber(avatar), evo = 0, custom_prefab = custom_prefab, playerData = "pet"}
                local player = self.plyMgr:createPlayer(playerData,1,index,nil,nil)
                self.m_pets[index] = {data = pet_data, player = player, state = self.pet_state.create, state_time = 0, start_pos = position:CloneNew(), target_pos = self.m_mid_pos:CloneNew()}
                player.loadPlayerViewFinish = function(ply)
                    local shadow = ply.tranformHelper:FindObj(ply.tran, "shadow")
                    if IsNull(shadow) == false then
                        shadow:SetActive(false)
                    end
                    player:setPos( position )
                    self.plyMgr:playerSpawnCamp(1);
                    if player.animator ~= nil then
                        player.animator:changeState("idle")
                    end

                    player:setScale(GlobalTools.base1_2);
                    self.m_pets[index].state = self.pet_state.idle_end
                end
            end
        end
    end
end

function M:updatePet(data)
    if data then
        self.m_data = data
    end
    -- 移除宠物
    for i=1, self.m_pet_max_num do
        local pet = self.m_pets[i]
        if pet then
            local remove = true
            for k,v in pairs(self.m_data.pet_view) do
                if v == pet.data then
                    remove = false
                    break
                end
            end
            if remove then
                self.plyMgr:destoryPlayer(pet.player)
                self.m_pets[i] = nil
            end
        end
    end
    -- 添加新宠物
    for k,v in pairs(self.m_data.pet_view) do
        local add = true
        for kk,vv in pairs(self.m_pets) do
            if v == vv.data then
                add = false
                break
            end
        end
        if add then
            self:addPet(v)
        end
    end
end

-- 宠物大厅场景
function M:getCurSceneName()
    self:createSceneConfig(141)
    return "pet_hall"
end

--子类重写
function M:getCurSceneObjName()
    return "hangUpscene_data_w";
end

--加载完成
function M:loadFinish()
    Logger.log(self.m_data.pet_view,"self.m_data.pet_view =====")
    for k,v in pairs(self.m_data.pet_view) do
        self:addPet(v)
    end
    GameMain.addUpdate("pet_Update", handler(self,self.UnityUpdate))
    --self.scene_obj_meishu = U3DUtil:GameObject_Find("Scene");
    --self.isMove = false;
    --static_rootControl:updateMsg("close_sync_load_big_loading");
    --注册一个点击事件
    --CS.GameObjectClickMgr.Inst:Register("ClickObj",handler(self,self.selectTargetGrid))
    --CS.GameObjectClickMgr.Inst:GetListeners();
    self:set_sceneState(3)
end

function M:updatePetState()
    for k,v in pairs(self.m_pets) do
        if v.state == self.pet_state.idle_end or v.state == self.pet_state.move_end then
            local state = math.random(1,2)
            if state == 1 then -- idle
                if v.state == self.pet_state.move_end then
                    local anim = self:getPetAnimation(v.player, "idle2")
                    v.player.animator:changeState(anim)
                end
                local time = math.random(10,50)
                v.state = self.pet_state.idle
                v.state_time = time * 0.1
            else
                if v.state == self.pet_state.idle_end then
                    local anim = self:getPetAnimation(v.player, "idle1")
                    v.player.animator:changeState(anim)
                end
                local x = (math.random(0, 883) - 433) * 0.01
                local z = (math.random(0, 376) - 470) * 0.01
                v.target_pos.x = GlobalTools:CommonToFix(x)
                v.target_pos.z = GlobalTools:CommonToFix(z)
                v.start_pos.x = v.player.position.x
                v.start_pos.y = v.player.position.y
                v.start_pos.z = v.player.position.z
                v.state = self.pet_state.move
                v.state_time = GlobalTools.base0
                v.move_time = GlobalTools:Div(GlobalTools:Distance(v.start_pos,v.target_pos), GlobalTools.base4)
            end
        end
    end
end

--更新任务
function M:UnityUpdate(dt)
    if not self.pet_interact then
        self:updatePetState()
        self:playerMove(dt)
    end
end

--玩家移动
function M:playerMove( dt )
    for k,v in pairs(self.m_pets) do
        if v.state == self.pet_state.idle then
            v.state_time = v.state_time - dt
            if v.state_time <= 0 then
                v.state = self.pet_state.idle_end
            end
        elseif v.state == self.pet_state.move then
            local dt_fix = GlobalTools:CommonToFix(dt)
            v.state_time = v.state_time + dt_fix
            if v.state_time > v.move_time then
                v.state_time = v.move_time
                v.state = self.pet_state.move_end
            end
            local t = GlobalTools:Div(v.state_time, v.move_time)
            local position = FixVector3.New(0,0,0)
            GlobalTools:Lerp(position, v.start_pos, v.target_pos, t)
            local dir = GlobalTools:Dir(v.target_pos,v.player.position)
            v.player:setForward(dir)
            v.player:setPos(position)
        end
    end
end

function M:showInteractPet(ply)
    for k,v in pairs(self.m_pets) do
        if k == ply.index then
            v.player:setScale(GlobalTools.base3)
            v.player:setPos(self.m_mid_pos)
            self.pet_interact = true
            self.interactPetPly = v.player
            self.interactPetOid = v.data
        else
            v.player:hideBody(false)
        end
    end
end

function M:closeInteractPet()
    self.pet_interact = false
    self.interactPetPly = nil
    self.interact_state = 0
    self.interactPetOid = nil
    for k,v in pairs(self.m_pets) do
        v.player:hideBody(true)
        v.player:setScale(GlobalTools.base1_2)
        if v.state == self.pet_state.move then
            local anim = self:getPetAnimation(v.player, "idle1")
            v.player.animator:changeState(anim)
        elseif v.state == self.pet_state.idle then
            local anim = self:getPetAnimation(v.player, "idle2")
            v.player.animator:changeState(anim)
        end
    end
end

function M:InteractPet(ply)
    if ply then
        static_rootControl:updateMsg("interact_pet", nil, "PetBreeding.PetBreedingInteraction")
        self:showInteractAnimation(1)
    else
        if self.interact_state ~= 2 then
            self:showInteractAnimation(2)
        end
    end
end

function M:showInteractAnimation(interac_type)
    if self.interactPetPly then
        local anim = "idle"
        if interac_type == 1 then
            anim =  self:getPetAnimation(self.interactPetPly, "touch")
        else
            anim = self:getPetAnimation(self.interactPetPly, "stay")
        end
        self.interact_state = interac_type
        self.interactPetPly.animator:changeState(anim)
        self.interactPetPly.animator.curState.onCompleteHandler = function()
            self:showInteractAnimation(2)
        end
    end
end

function M:getPetAnimation(ply, key)
    if ply and key then
        local cfg = UserDataManager.pet_data:getPetConfigByCid(ply.playerId)
        if type(cfg[key]) == "table" then
            if key == "stay" then
                local anims = {}
                for i,v in ipairs(cfg[key]) do
                    if self.interactPetPly.animator.stateData.stateName ~= v then
                        table.insert(anims, v)
                    end
                end
                local id = math.random(1, #anims)
                return anims[id] or anims[1]
            else
                local id = math.random(1, #cfg[key])
                return cfg[key][id] or cfg[key][1]
            end
        end
    end
end

--销毁场景
function M:destroy( nextScene )
    M.super.destroy(self,nextScene);
    GameMain.removeUpdate("pet_Update");
end

return M;