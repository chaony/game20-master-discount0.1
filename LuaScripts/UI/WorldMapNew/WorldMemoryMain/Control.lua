local M = class("WorldMemoryMainControl",LikeOO.OOControlBase)

function M:onEnter()
    LikeOO.NewMap2DControl:init(self)
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "switch_tab" then
        self:switchTabBtn(data.index, data.cell_object, data.cell_data)
        self.m_view:refreshUI()
    elseif msg == "click_stage" then
        self:switchStageNode(data.index, data.obj, data.taskId)
        self:startTask(data)
    elseif msg == "help_btn" then
        local params = {}
        params.title = "world_memory_str_009"
        params.content = "tid#New_Regional_Des_1"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "change_scene" then
        if data then
            if data.area_id and data.map_id then
                UserDataManager.local_data:setUserDataByKey("world_memory_area_id", data.area_id)
                self.m_model.curSceneId = data.area_id
                if LikeOO.NewMap2DControl.curMap2D == nil then
                    LikeOO.NewMap2DControl:openMap2D(data.map_id)
                end
            end
        else
            SceneManager:changeScene(SceneManager.SceneID.HangUpScene, nil, false);
        end
    elseif msg == "guide_close_mapNode" then
        self:reloadData()
    elseif msg == "battle_end_refresh_ui" then
        --SceneManager:changeScene(SceneManager.SceneID.HangUpScene, self.m_model.m_data,false)
        self:updateMsg("battle_end" , {cell_data = self.m_model.m_data})
        self.m_model.battle_end_data = data.data
        local result = data.data.result
        local drama_id = self.m_model:getBattleEndDramaId(result)
        if drama_id ~= 0 then
            self:openView("Guide.GuideDrama", {dialog_id = drama_id, callback = function()
                self:updateMsg("check_guide")
            end})
        else
            self:updateMsg("battle_end" , {cell_data = self.m_model.m_data})
        end
        
        UserDataManager:setTempData("new_map_battle_event_id", nil)
        UserDataManager:setTempData("new_map_battle_event_type", nil)
        self:updateMsg("check_guide", nil, "Guide.GuideDrama")
        if data.data and data.data.update_attrs ~= nil and _G.next(data.data.update_attrs) then
            local tips = UserDataManager:checkWorldMemoryAttrUpdate(data.data.update_attrs)
            TimeTools:delayTimeUnity(0.5,
                    function()
                        GameUtil:lookInfoTips(static_rootControl, {msg = tips, delay_close = 2})
                    end)
        end
    end
end

function M:reloadData()
    local function netCallback(response)
        if response and self.m_model then
            self.m_model:refreshData(response)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("new_big_map_index", nil, netCallback)
end

function M:startTask(data)
    local cfg = data.cfg
    local state, lock_text = self.m_model:checkStageIsOpen(data.taskId)
    if state == 1 then
        local params = {
            text = Language:getTextByKey("world_memory_str_002",tostring(cfg.name_s)),
            tow_close_btn = true,
            on_ok_call = function ()
                self:openMapByData(data)
            end
        }
        self:openView("Pops.CommonPop", params)
    elseif state == 2 then
        self:openMapByData(data)
    else
        GameUtil:lookInfoTips(self, {msg = lock_text, delay_close = 2})
    end
end

function M:openMapByData(data)
    UserDataManager.local_data:setUserDataByKey("world_memory_area_id", self.m_model.m_sel_chapter)
    if LikeOO.NewMap2DControl.curMap2D == nil and data.cfg then
        local mapId = self.m_model:getMapIdByTaskLineId(data.cfg.task_team)
        if mapId then
            self.m_model.curSceneId = data.area_id
            LikeOO.NewMap2DControl:openMap2D(mapId)
        else
            Logger.logError(data.cfg.task_team,"not find mapId By task_line :")
        end
    end
end

-- tab按钮切换
function M:switchTabBtn(index,obj, data)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchTabNode(index,obj,data)
    end
end

-- 关卡切换
function M:switchStageNode(index,obj, taskId)
    if self.m_model.m_sel_stage_index ~= index then
        self.m_model.m_sel_stage_index = index
        self.m_view:switchStageNode(obj,taskId)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;
