--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:39:48
]]

---@class PlayerBuf_View : ViewBase @玩家的单个Buf 所有和 BufView 相关的都在这个类中编写
---@field mgr BufManagerView
---@field player Player_View
---@field bufWork BufWork_View
local M = class("PlayerBuf_View",Battle.ViewBase)
  
--buf开始运作
---@param model PlayerBuf_Model
function M:init( player, mgr, model )
    --玩家的视图
    self.player = player;
    --buf播放特效列表
    self.effectList = {}
    --buff管理器
    self.mgr = mgr;
    --PlayerBufModel 数据层对象
    self.model = model;
    ---- TODO 使用真实配置
    --local buffCfg = self:getBuffConfig()

    local source_model = self.model:get_source()
    self.source = self.player.plyMgr:GetPlayerViewByModel(source_model)
    --buf 图片 Icon
    self.buffIcon = self.model:get_buffIcon();
    self.is_bufficon_count  = self.model:get_showBuffIconCount()
    --声音名字
    self.audioName = self.model:get_audioName();

    self.effect_id = self.model:get_effect_id();
    --获取特效
    self.effect = self:get_effectData();
    -- 监听buf 播放特效
    self:addEventListener_Local(Battle.EventType.MV_PlayerBufModelPlayEffect,{self,self.PlayerBufModelPlayEffect})
    -- 监听buf 播放声音
    self:addEventListener_Local(Battle.EventType.MV_PlayerBufModelPlayAudio,{self,self.PlayerBufModelPlayAudio})
    -- 监听buf 播放声音
    self:addEventListener_Local(Battle.EventType.MV_PlayerBufModelStopAudio,{self,self.PlayerBufModelStopAudio})
    -- 监听buf 刷新Icon 
    self:addEventListener_Local(Battle.EventType.MV_PlayerBufModelRefreshIcon,{self,self.PlayerBufModelRefreshIcon})
    -- 监听buf 删除特效 
    self:addEventListener_Local(Battle.EventType.MV_PlayerBufModelDeleteEffect,{self,self.PlayerBufModelDeleteEffect})
    -- 生效类创建完成
    self:addEventListener_Local(Battle.EventType.MV_BufWorkModelCreateFinish, {self, self.BufWorkModelCreateFinish})
    --重新设置
    self:addEventListener_Local(Battle.EventType.MV_PlayerBufModelReset, {self,self.MV_PlayerBufModelReset})
end


function M:get_effectData()
    local data = {}
    for k,v in pairs(self.effect_id) do
    	local effectData = self.mgr.bufEffect[v]
    	if effectData ~= nil then
    		data[k] = {}
            local prefab = effectData["prefab"]
            if self.source ~= nil then
                prefab = self.source:getNameByPlyType(effectData["prefab"])
            end
    		data[k]["prefab"] = prefab
    		data[k]["effectType"] = effectData["effect_type"]
    		data[k]["isParent"] = effectData["is_parent"]
    		data[k]["effectParent"] = effectData["effect_parent"]
    		data[k]["offset"] = effectData["offset"]
            data[k]["effectDestroyTime"] = effectData["effect_destroy_time"]
            data[k]["mirrorPrefab"] = effectData["mirrorPrefab"]
            data[k]["haveSound"] = effectData["haveSound"]
            data[k]["soundName"] = effectData["soundName"]
            data[k]["soundBank"] = effectData["soundBank"]
    	else
    		Logger.logError("buffEffect not found.  id:" .. v)
    	end
    end
    return data;
end

function M:MV_PlayerBufModelReset(eventName, data)
    if data.effect ~= nil then
        self.effect_id = data.effect;
        self.effect = self:get_effectData();
    end
end

--buf生效类创建完成
function M:BufWorkModelCreateFinish(eventName, data)
    --buf生效类视图层
    local bufwork_model = data;
    local bufwork_lua = "BattleView.Buf.BufWork"..bufwork_model:get_name().."_View";
    self.bufWork = require(bufwork_lua).new();
    SceneManager.MV_EventMgr:register(self.bufWork, bufwork_model);
    self.bufWork:init(self, bufwork_model)
end

--停止播放声音事件
function M:PlayerBufModelStopAudio(eventName, data)
    if self.audio ~= nil and type(self.audio) ~= "number" and self.audio:isValid() == true then
        self.audio:stop(0)
    end
end

--删除buf的特效
function M:PlayerBufModelDeleteEffect(eventName, data)
    --for i = 1, table.nums(self.effect) do
    --    local effect = self.effect[i]
    --    if effect ~= nil then
    --        local destroyTime = tonumber(effect["effectDestroyTime"])
    --        local remove, effectData = self.mgr:tryRemoveEffect(effect["prefab"], destroyTime)
    --        if remove and effectData ~= nil then
    --            self.player:removeEffect(effectData)
    --        end
    --    end
    --end
    for i, v in ipairs(self.effectList) do
        local prefabName = v["prefab"]
        if prefabName == nil then
            prefabName = v.m_data["prefab"]
        end
        if self.mgr:tryRemoveEffect(prefabName) then
            self.player:removeEffect(v)
        end
    end
end

--buf播放音乐
function M:PlayerBufModelPlayAudio(eventName, data)
    --buff的音效
    if self.audioName ~= nil and self.audioName ~= "" and self.player ~= nil then
        self.audio = StateSoundManager:playSkillSound(self.audioName, self.player)
    end
end

--buf刷新icon
function M:PlayerBufModelRefreshIcon(eventName, data)
    self.buffIcon = self.model:get_buffIcon();
    --刷新icon
    if self.buffIcon ~= nil and #self.buffIcon > 0 then
        self.mgr:refreshBuffIcon()
    end
end

--buf播放特效
function M:PlayerBufModelPlayEffect(eventName, data)
    local key = data.key;
    self:playEffect(key)
end

--播放特效
function M:playEffect(type)
    --江湖传说 无双模式敌人不播放buff特效
    if SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND and SceneManager.curScene.battle_mode == 2 then
        return
    end
    for i = 1, table.nums(self.effect) do
        local effect = self.effect[i]
        if effect ~= nil and effect["effectType"] == type then

            self:tryPlaySound(effect)
            
            local addedEffect = self.mgr:getAddedEffect(effect["prefab"])
            if addedEffect and  addedEffect.count > 0 then
                self.mgr:addEffect(effect["prefab"], addedEffect.effectItem)
                table.insert(self.effectList, addedEffect.effectItem)
            else
                local destroyTime = tonumber(effect["effectDestroyTime"])
                --local isNew, effectCountData = self.mgr:addEffect(effect["prefab"], destroyTime)
                --if isNew == false then
                --    break
                --end
                local pos = self.bufWork.model:get_position()
                local effectData = {}
                effectData["prefab"] = effect["prefab"]
                effectData["autodestoryTime"] = destroyTime
                effectData["parent"] = effect["effectParent"]
                effectData["directionType"] = "parent"
                effectData["scaleType"] = "world"
                effectData["mirrorPrefab"] = effect["mirrorPrefab"] == "True"
                local prefabTrans = {}
                prefabTrans["useUserSet"] = true

                if pos == nil then
                    effectData["isPutUpInParent"] = effect["isParent"] == "True"
                    effectData["positionType"] = "parentOffset"
                    prefabTrans["position"] = {
                        [1] = tonumber(effect["offset"].x),
                        [2] = tonumber(effect["offset"].y),
                        [3] = tonumber(effect["offset"].z),
                    }
                else
                    effectData["isPutUpInParent"] = "False"
                    effectData["positionType"] = "worldFix"
                    prefabTrans["position"] = {
                        [1] = tonumber(effect["offset"].x) + GlobalTools:ToFloat(pos.x),
                        [2] = tonumber(effect["offset"].y) + GlobalTools:ToFloat(pos.y),
                        [3] = tonumber(effect["offset"].z) + GlobalTools:ToFloat(pos.z),
                    }
                end

                prefabTrans["rotation"] = {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                }
                prefabTrans["scale"] = {
                    [1] = 1,
                    [2] = 1,
                    [3] = 1,
                }
                effectData["prefabTrans"] = prefabTrans
                
                local effectItem = self.player:playEffect(effectData,self.player,self.model.source,
                        function()
                            if self.bufWork ~= nil then
                                self.bufWork:effectLoadFinish()
                            end
                        end
                )
                --if effectCountData ~= nil then
                --    effectCountData.obj = effectItem
                --    if self.mgr.hideEffect == true and IsNull(effectItem.m_obj) == false then
                --        effectItem.m_obj:SetActive(false)
                --    end
                --end
                if not IsNull(effectItem) then
                    if type == "endPlay" then
                        local timeTask = nil
                        timeTask = TimeTools:delayTimeUnity(destroyTime, function()
                            self.player:removeEffect(effectItem)
                            self.player.timeTaskList:remove(timeTask)
                        end)
                        self.player.timeTaskList:add(timeTask)
                    else
                        table.insert(self.effectList, effectItem)
                        local effectName = effect["prefab"]
                        if effectData["mirrorPrefab"] then
                            effectName = effectName .. "_mirror"
                        end
                        self.mgr:addEffect(effectName, effectItem)
                    end
                end
            end
        end
    end
end

--播放声音
function M:tryPlaySound(effect)
    if effect.haveSound == "True" then
        local bankName = effect["bankName"]
        local soundName = effect["soundName"];
        if soundName == "" then -- 没有配置音效则不用播放
            return
        end
        local source = self.model.source
        if source then
            if bankName == nil or bankName == "" then
                StateSoundManager:playSkillSound(soundName, source);
            else
                if source.banks[bankName] == nil then
                    source.banks[bankName] = 1
                    ResourceUtil:LoadBank(bankName)
                end
                StateSoundManager:playSkillSoundFromBank(soundName, bankName);
            end
        end
    end
end


--function M:getBuffIcon()
--    local buffCfg = self:getBuffConfig()
--    return buffCfg and buffCfg.buff_icon or {}
--end
--
-----@return ConfigBuff
--function M:getBuffConfig()
--    local buffId = self.model:get_buff_id()
--    if(buffId ~= nil)then
--        return ConfigManager:getCfgByName("buff")[buffId]
--    else
--        return self.model.bufData
--    end
--end

return M