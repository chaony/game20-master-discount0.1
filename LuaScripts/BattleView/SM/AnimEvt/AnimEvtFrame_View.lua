--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-30 10:44:49
]]

--时间帧的显示部分
---@class AnimEvtFrame_View : ViewBase @
---@field super ViewBase @ViewBase
---@field player Player_View
local M = class("AnimEvtFrame_View",Battle.ViewBase)

--加载
function M:load( data, player, evtAction )
    -- 玩家的数据层
    self.player = player;
    -- 动作信息
    self.evtAction = evtAction;
    --数据
    self.data = data
    --监听美术帧调用
    self:addEventListener_Local(Battle.EventType.MV_AnimEvtFrameMeiShuTrigger, {self,self.AnimEvtFrameMeiShuTrigger})
    self:addEventListener_Local(Battle.EventType.MV_AnimEvtFrameMeiShuHitAoeEffect, {self,self.AnimEvtFrameMeiShuHitAoeEffect})
end

function M:AnimEvtFrameMeiShuTrigger() 
    self:work();
end


--关键帧，起作用
function M:work()
    local eventName = self.data.eventName;
    if eventName == "PlayEffect" then
        self:playEffect()
    elseif eventName == "PlayActive" then
        self:active()
    elseif eventName == "DestroyNode" then
        self:destroyNode()
    elseif eventName == "PlaySound" then
        self:playSound()
    elseif eventName == "CameraShake" then
    	self:cameraShake()
    elseif eventName == "SpecialAreaEffect" then
        self:specialAreaEffectFunc()
    elseif eventName == "TriggerSceneEvent" then
        self:TriggerSceneEvent()
    elseif eventName == "RangeShow" then
        self:RangeShow()
    end
end

--触发场景事件
function M:TriggerSceneEvent()
    local id = self.data["triggerId"];
    CS.SceneEventConfigTrigger.Inst:TriggerEvent(id);
end

function M:AnimEvtFrameMeiShuHitAoeEffect(eventName, data)
    for k,v in pairs(data.effectList) do
        local effectName = v.prefab
        local destroyTime = v.autoDestroy
        local pos = data.center
        pos.x = pos.x + v.position.x
        pos.y = pos.y + v.position.y
        pos.z = pos.z + v.position.z
        local rot = v.eulerAngle
        local scale = v.scale
        self:PlayerEffectOnPoint(effectName, destroyTime, pos, rot, scale, self.player)
    end
end

--特别的场景特效
function M:specialAreaEffectFunc()
    
    --是都射击固定点
    local fixpoint = self.data["count"]["fixpoint"]
    local isFixPoint = self.data["count"]["isFixPoint"]
    local is_dead_Destroy = self.data["is_dead_Destroy"]
    local offset = tonumber(self.data["offset"] or 0)
    offset = GlobalTools:ToFloat(offset)
    local rotation = self.data["rotation"] or Vector3.New(0,0,0)
    local effectName = self.data["prefab"]
    effectName = string.gsub(effectName, self.player.default_plyType, self.player.plyType)
    local destroyTime = self.data["effectDestroyTime"]
    local point = nil
    if isFixPoint == true then
        local ply = self.player
        point = SelectTargetTool_View:findFixPoint( ply, fixpoint )
        if point ~= nil then
            point = point:toVector3()
            local effect = self:PlayerEffectOnPoint(effectName, destroyTime, point, rotation, Vector3.New(1,1,1), self.player)
            if is_dead_Destroy == true then
                self.player.footEffect = effect
            end
        end
    else
        local players = SelectTargetTool_View:findPlayerByType( self.data["count"], self.player, true)
        for i = 1, players.Count do
            local player = players:get(i - 1)
            local pos = {x = 0, y = 0, z= 0}
            pos.x = player.position.x + player.forward.x * offset
            pos.y = player.position.y + player.forward.y * offset
            pos.z = player.position.z + player.forward.z * offset
            local effect = self:PlayerEffectOnPoint(effectName, destroyTime, pos, rotation, Vector3.New(1,1,1), player)
            if is_dead_Destroy == true then
                self.player.footEffect = effect
            end
        end
    end
    SelectTargetTool_View:clear()
end

--在某个点上播放特效
function M:PlayerEffectOnPoint(effectName, destroyTime, pos, rotation, scale, player)
    if pos ~= nil then
        local effectData = {}
        effectData["prefab"] = effectName
        effectData["autodestoryTime"] = destroyTime
        effectData["isPutUpInParent"] = false
        effectData["parent"] = "body"
        effectData["directionType"] = "playerForward"
        effectData["scaleType"] = "world"
        effectData["positionType"] = "worldFix"

        local prefabTrans = {}
        prefabTrans["useUserSet"] = true

        prefabTrans["position"] = {
            [1] = pos.x,
            [2] = pos.y,
            [3] = pos.z,
        }
        prefabTrans["rotation"] = {
            [1] = rotation.x,
            [2] = rotation.y,
            [3] = rotation.z,
        }
        prefabTrans["scale"] = {
            [1] = scale.x,
            [2] = scale.y,
            [3] = scale.z,
        }
        effectData["prefabTrans"] = prefabTrans

        local effectItem = player:playEffect(effectData, player, self.player)
        return effectItem
    end
end

--播放声音
function M:playSound()
    local bankName = self.data["bankName"]
    local soundName = self.data["soundName"];
    if soundName == "" then
        soundName = self.evtAction.animName
    end
    if bankName == nil or bankName == "" then
        StateSoundManager:playSkillSound(soundName, self.player);
    else
        if self.player.banks[bankName] == nil then
            self.player.banks[bankName] = 1
            ResourceUtil:LoadBank(bankName)
        end
        StateSoundManager:playSkillSoundFromBank(soundName, bankName);
    end
end

--播放声音
function M:playBtnSound()
    local name = self.data["SoundName"];
    --audio:SendEvtSkill();
end

--播放特效
function M:playEffect()
	--特效的 bundle 名字
    if SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND and self.player.camp == -1 then
        return;
    end
    self.data["effect_bundle"] ="fx_"..string.lower( self.player.effect_prefabRoot );
    local effectItem = self.player:playEffect(self.data, self.player, self.player)

    if self.player.model.curSkillConfig ~= nil and not IsNull(effectItem) then
        self.player:addSkillEffectList(self.player.model.curSkillConfig.anim_name, effectItem)
    end
end


function M:destroyNode()
    local destroyNode = self.data["destroyNode"]
    if not IsNull(self.player.tranformHelper) then
        local obj = self.player.tranformHelper:FindObj(self.player.tran, destroyNode)
        if obj ~= nil then
            ResourceUtil:ReturnItem(obj);
        end
    end
end


--消失显示
function M:active()
    local selfactive = self.data["active"] == true
    local activeNode = self.data["activeNode"]
    local hpBarActive = self.data["hpBarActive"] ~= false
    if self.player.tranformHelper ~= nil then
        local obj = self.player.tranformHelper:FindObj(self.player.tran, activeNode)
        --血条
        if self.player.hpBar ~= nil then
            if hpBarActive then
                self.player.hpBar:Show(false)
            else
                self.player.hpBar:Show(true)
            end
        end

        if obj ~= nil then
            if selfactive then
                obj.gameObject:SetActive(false)
            else
                obj.gameObject:SetActive(true)
            end
        end
    end
end

--近战伤害事件
function M:hit()
    -- 过去特效数据
    -- if self.data.effectId ~= nil then
    --    local effectData = self.evtAction.hitEffectFrames[self.data.effectId]
    --    if effectData ~= nil and effectData.data ~= nil then
    --        --攻击抖动w
    --        local cameraShake = effectData.data["cameraShake"];
    --        if cameraShake.shake == 'True' then
    --            local _CamerShake = SceneManager.curScene.cameraController.m_shake;
    --            local curve_id = tonumber(cameraShake.curve_id)
    --            if self.player.shakeCurves ~= nil and self.player.shakeCurves.curve3s.Count > curve_id then
    --                _CamerShake:StartShake(self.player.shakeCurves.curve3s[curve_id])
    --            end
    --        end
    --    end
    --else
    --    Logger.log(" 人物 : "..self.player.plyType.. "  动画名称 : "..self.evtAction.animName .. " 执行事件 hit ")
    --end
end

--震屏
function M:cameraShake()
    --local _CamerShake = SceneManager:getCurSceneView().cameraController.m_shake;
    --local player_model = self.player:get_model()
    --if player_model.curSkillConfig ~= nil and _CamerShake ~= nil then
    --    if player_model.curSkillConfig.type == 1 then
    --        _CamerShake:StartShake(SceneManager.gameGlobalConfig.mBigSkillShakeAnim)
    --    elseif player_model.curSkillConfig.type == 2 then
    --        _CamerShake:StartShake(SceneManager.gameGlobalConfig.mCommonHitShakeAnim)
    --    else
    --        _CamerShake:StartShake(SceneManager.gameGlobalConfig.mCommonSkillShakeAnim)
    --    end
    --end
end

--范围展示
function M:RangeShow()
    local player_model = self.player:get_model()
    if player_model.curSkillConfig ~= nil and SceneManager:getCurSceneView().plyMgr.rangeShow ~= nil then
        if self.player.camp == 1 then
            if player_model.curSkillConfig.friend_warning_zone == true then
                SceneManager:getCurSceneView().plyMgr.rangeShow:addRange(self.player, self.data)
            end 
        else
            if player_model.curSkillConfig.enemy_warning_zone == true then
                SceneManager:getCurSceneView().plyMgr.rangeShow:addRange(self.player, self.data)
            end
        end
    end
end


return M;