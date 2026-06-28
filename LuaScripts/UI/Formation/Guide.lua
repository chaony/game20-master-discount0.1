local guide = class("Formation", LikeOO.OOGuideBase)

-- 固定位置上阵卡牌
function guide:excuteGuideFunc1(info)
    local target = info.target
    local data = self.m_model.Filtrate_list

    local node = nil
    local hero_id = nil
    if self.m_model.main_team[target[2]] ~= nil and self.m_model.main_team[target[2]] ~= "" then
        self:doNextGuide()
        return
    end
    for i,v in ipairs(data) do
        local hero, cfg = self.m_model:getHero(v)
        if cfg.id == target[1] then
            local ishave = self.m_model:checkIsInTeam(v)
            if ishave then
                break
            else
                local cell_node = self.m_view.m_loop_scroll_view.m_cache_cells[i]
                if cell_node then
                    local luaBehaviour = UIUtil.findLuaBehaviour(cell_node)
                    node = luaBehaviour:FindGameObject("head_btn")
                    hero_id = hero.oid
                    break
                end
            end
        end
    end
    if node then
        self.m_listener = {
            key = "click_card",
        }   
        local addTeams = self.m_model.addTeams
        self.m_model.addTeams = function ( ... )
            self.m_model.main_team[target[2]] = hero_id
            self.m_model.addTeams = addTeams
            return target[2]
        end
        self:guideTargetNode(node.transform, 1, 1)
    else
        self:doNextGuide()
    end
end

-- 上阵卡牌
function guide:excuteGuideFunc2(info)
    local target = info.target[1]
	local data = self.m_model.Filtrate_list

	local node = nil
    for i,v in ipairs(data) do
        local hero, cfg = self.m_model:getHero(v)
        if cfg.id == target then
            local ishave = self.m_model:checkIsInTeam(v)
            if ishave then
                break
            else
                local cell_node = self.m_view.m_loop_scroll_view.m_cache_cells[i]
                if cell_node then
                    local luaBehaviour = UIUtil.findLuaBehaviour(cell_node)
                    node = luaBehaviour:FindGameObject("hero_bg")
                    break
                end
            end
        end
    end
    if node then
        self.m_listener = {
            key = "click_card",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    else
        self:doNextGuide()
    end
end

-- 点击战斗
function guide:excuteGuideFunc3(info)
    local node = self.m_view:findGameObject("start_btn")
    if node then
        self.m_listener = {
            key = "start_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 调整英雄站位
function guide:excuteGuideFunc4(info)
    local target = info.target
    if self.m_model.main_team[target[1]] == "" or self.m_model.main_team[target[1]] == nil then
        self:doNextGuide()
        return
    end
    
    local scene = SceneManager:getCurSceneView()
    local camera_3d = scene.cameraController.CameraRole

    local start_pos = scene.heroPoslist:get(target[1]-1)
    start_pos = camera_3d:WorldToScreenPoint(start_pos)
    start_pos = static_ui_camera:ScreenToWorldPoint(start_pos)
    
    local target_pos = scene.heroPoslist:get(target[2]-1)
    target_pos = camera_3d:WorldToScreenPoint(target_pos)
    target_pos = static_ui_camera:ScreenToWorldPoint(target_pos)
    self.m_listener = {
        key = "updatePlayerPosGuide",
    }   

    local function touchHandle(event, data)
        if event == "touchBegin" then
            if scene and scene.selectPlayer ~= nil then
                self.m_touch_begin_pos = U3DUtil:GetMousePosition()
                return true
            end
            --if U3DUtil:Input_GetMouseButtonDown(0) then
            --    local objList = CS.wt.framework.PhysicsTool.GetHitPlayer()
            --    if objList.Count > 0 then
            --        for i=1,objList.Count do
            --            local obj = objList[i-1];
            --            local helper = obj:GetComponent("LuaTransformHelper")
            --            if helper and helper.camp == 1 then
            --                local selectPlayer = scene.plyMgr:getHeroByIndex(helper.index)
            --                if selectPlayer ~= nil then
            --                    local cur_near_index = selectPlayer.index
            --                    if cur_near_index == (target[1] - 1) then
            --                        self.m_touch_begin_pos = U3DUtil:GetMousePosition()
            --                        return true
            --                    end
            --                end
            --            end
            --        end
            --    end
            --end
            return
        end

        if event == "touchMove" then
            local mouse_pos = U3DUtil:GetMousePosition()
            local dis = Vector3.Distance(self.m_touch_begin_pos, mouse_pos) 
            -- Logger.log(dis,"dis ========")
            if dis > 60 then
                self.m_move_flag = true
            end
            return
        end

        if event == "touchEnd" then
            if self.m_move_flag and scene and scene.isMouseDown == false then
                if scene.GuideUpdatePlayerPos then
                    scene:GuideUpdatePlayerPos(target)
                    GameUtil:resetPlayerInfoTips()
                    GameUtil:resetPlayerRelationTips()
                end
                self.m_move_flag = false
                return true
            end
            return
        end
    end
    self:guideTargetDragNode(start_pos, target_pos, touchHandle, 1, 1)
end

-- 点击布阵
function guide:excuteGuideFunc5(info)
    local node = self.m_view:findGameObject("buzhen_btn")
    if node then
        self.m_listener = {
            key = "buzhen_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击布阵确认
function guide:excuteGuideFunc6(info)
    local node = self.m_view:findGameObject("bottom_return")
    if node then
        self.m_listener = {
            key = "bottom_return",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击阵法
function guide:excuteGuideFunc7(info)
    local node = self.m_view:findGameObject("hero_deployment")
    if node then
        self.m_listener = {
            key = "hero_deployment",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

return guide
