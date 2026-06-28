local guide = class("MazeStage", LikeOO.OOGuideBase)

-- 点击格子
function guide:excuteGuideFunc1(info)
    static_rootControl:closeView("Pops.CommonPop")
    local target = info.target[1]
    local startGrid = SceneManager:getCurSceneModel().startGrid
    if startGrid == nil then
        return
    end
    local cell_id = SceneManager:getCurSceneModel():infoToID(startGrid.index_pos.x, startGrid.index_pos.y)
    local centent = SceneManager:getCurSceneModel().guide_check_cell
    if centent == nil then
        return
    end
    if cell_id ~= centent.cell_id then
        UserDataManager.guide_data:resetCurGuide()
        return
    end
    
    local around_grid = SceneManager:getCurSceneModel():getAroundCell(centent)
    local node
    for i,v in ipairs(around_grid) do
        if v.server_data ~= nil and v.server_data.type == target then
            node = v.obj
            break
        end
    end
    
    if node then
        self.m_listener = {
            key = "cell_click",
        }
        
        local worldPos = node.transform.position
        local position = SceneManager:getCurSceneView().cameraController.Camera_3D:WorldToScreenPoint(worldPos);
        -- position.z = 0
        position = static_ui_camera:ScreenToWorldPoint(position)
        self:guideTargetNode(node.transform, 1, 1, nil, nil, nil, nil, position)
    end
end

-- 点击遗物
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("relic_formation_btn")
    if node then
        self.m_listener = {
            key = "relic_formation_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 引导所以可通过的路口
function guide:excuteGuideFunc3(info)
    local centent = SceneManager:getCurSceneModel():getCellData(SceneManager.curScene.cell_id)
    local around_grid = SceneManager:getCurSceneModel():getAroundCell(centent)
    local nodes = {}
    
    for i,v in ipairs(around_grid) do
        if (v.server_data ~= nil and v.server_data.type == 16) or v.server_data == nil then
            local worldPos = v.obj.transform.position
            local position = SceneManager:getCurSceneView().cameraController.Camera_3D:WorldToScreenPoint(worldPos);
            -- position.z = 0
            position = static_ui_camera:ScreenToWorldPoint(position)
            nodes[#nodes + 1] = position
        end
    end
    if #nodes > 0 then
        self.m_listener = {
            key = "maze_goto",
            key2 = "maze_goto_guide",
        }
        self:guideTargetNode(around_grid[1].obj.transform, 3, 4, nil, nil, nil, nil, nil,nil,nil,{target_pos_list = nodes})
    end
end

-- 出小怪提示页面
function guide:excuteGuideFunc4(info)
    self.m_control:openView("MazeStage.MazeStageEnemyTips")
    self:doNextGuide()
end

return guide
