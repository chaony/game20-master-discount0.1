--- 主线
local M = class("TaskRewardAreaNode", LikeOO.OOUIbase)

M.m_uiName = "WorldMap/WorldMapTaskReward/TaskRewardAreaNode"
M.m_iphoneXAdapter = true

function M:onEnter()
    self.map_table = ConfigManager:getCfgByName("regional_map")
    self:setTextByLanKey("box_text", "world_map_tex_004")
    self.area_id = self.m_model.m_area_id
    self.mother_map_id = self.m_model.m_scene_id
    if LikeOO.Map2DControl.curMap2D ~= nil then
        self.cur_map_id = LikeOO.Map2DControl.curMap2D.map_id
    end
    local scene_lines_data = UserDataManager:getSceneLineData()
    if scene_lines_data ~= nil then
        local area = scene_lines_data[tostring(self.area_id)]
        if area ~= nil then
            self.scene_lines = area[tostring(self.mother_map_id)]
        end
    end
    self.scene_lines = self.scene_lines or {}
    self:refreshUI()
    self:refreshBox()
end

function M:refreshUI()
    self.m_map_obj_tab = {}
    local scroll_obj = self:findGameObject("Scroll_View")
    local scroll = scroll_obj:GetComponent("ScrollRect")
    local route_obj = ResourceUtil:LoadUIGameObject("Map/MapRoute/Route"..self.mother_map_id, Vector3.zero, scroll.viewport.gameObject)
    if route_obj ~= nil then
        local route_tran = route_obj:GetComponent("RectTransform")
        scroll.content = route_tran

        local bottomList = {}
        local topList = {}

        local bg = nil
        local current = nil
        local target = nil

        local curMaps = self.m_model:getCurTaskMaps()

        for i = 1, route_tran.childCount do
            local child = route_tran:GetChild(i - 1)
            if string.find(child.name, "map") ~= nil then
                local luaBehaviour = UIUtil.findLuaBehaviour(child)
                if luaBehaviour ~= nil then
                    local name = string.split(child.name, '_')
                    local map_id = tonumber(name[2])
                    if self.map_table[map_id] ~= nil then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "map_text", self:getMapName(map_id))
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_WorldMap_BiaoZhi_001", curMaps[map_id] ~= nil)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_WorldMap_BiaoZhi_002", curMaps[map_id] ~= nil)
                        if target == nil and curMaps[map_id] ~= nil then
                            target = child:GetComponent("RectTransform")
                        end
                        if table.indexof(self.scene_lines, map_id) ~= false or self.map_table[map_id].initial_state == 1 then
                            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "opened", true)
                            self:tryEnterMap(luaBehaviour, map_id)


                            if map_id == self.cur_map_id then
                                current = child:GetComponent("RectTransform")
                            end
                        else
                            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "opened", false)
                            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unopened_text", true)
                            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "unopened_text", self:getMapName(map_id))
                            local lastOpenMap = self:getLastOpenMap(map_id)
                            self:tryEnterMap(luaBehaviour, lastOpenMap)
                        end
                        self.m_map_obj_tab[map_id] = child
                    end
                end
            elseif child.name == "bg" then
                child.gameObject:SetActive(false)
            end
        end

        for k,v in ipairs(topList) do
            v:SetParent(route_tran)
            v:SetAsLastSibling()
        end

        local pos = route_tran.anchoredPosition
        pos.x = 0
        pos.y = 0
        if target ~= nil then
            pos.x = -target.anchoredPosition.x
            pos.y = -target.anchoredPosition.y
        else
            if current ~= nil then
                pos.x = -current.anchoredPosition.x
                pos.y = -current.anchoredPosition.y
            end
        end

        route_tran.anchoredPosition = pos
    end
end

function M:tryEnterMap(luaBehaviour, map_id)
    luaBehaviour:FindButton("map_btn", function()
        self:updateMsg("map_btn", {map_id = map_id})
    end)
end

function M:refreshBox()
    local cpd, status = self.m_model:getMapCpd()
    LuaBehaviourUtil.setTextByLanKey(self.m_luaBehaviour, "cpd_text", cpd)
    if status == 2 then
        LuaBehaviourUtil.setImg(self.m_luaBehaviour, "box_btn", "a_ck_linshixiangzi_open", "common_ui")
    else
        LuaBehaviourUtil.setImg(self.m_luaBehaviour, "box_btn", "a_ck_linshixiangzi", "common_ui")
    end
    LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "box_text", status ~= 2)
    LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "tx_box", status == 1)
end

function M:getLastOpenMap(mapId)
    local map = self.map_table[mapId]
    if table.indexof(self.scene_lines, mapId) ~= false then
        return mapId
    else
        if map.mother_map_id > 0 then
            return self:getLastOpenMap(map.mother_map_id)
        end
    end
    return mapId
end

function M:getMapName(id)
    return self.map_table[id].name
end

return M
