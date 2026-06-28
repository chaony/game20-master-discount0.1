local guide = class("HotelHall", LikeOO.OOGuideBase)

-- 点击升级按钮
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("open_upgrade_btn")
    if node then
        self.m_listener = {
            key = "open_upgrade_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    else
        self:doNextGuide()
    end
end

-- 点击更换按钮
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("open_hero_btn2")
    if node then
        self.m_listener = {
            key = "open_hero_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    else
        self:doNextGuide()
    end
end

-- 点击经营按钮
function guide:excuteGuideFunc3(info)
    local node = self.m_view:findGameObject("run_btn")
    if node then
        self.m_listener = {
            key = "run_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    else
        self:doNextGuide()
    end
end

--返回
function guide:excuteGuideFunc4(info)
    --self.m_listener = {
    --    key = "close_new_btn",
    --}
    local btn = self.m_view:findGameObject("close_btn")
    if btn then
        local function clickCallback()
            self.m_control:updateMsg(99999)
        end
        self:guideTargetNode(btn.transform, 1, 3, nil, nil, nil, nil, nil, true, clickCallback)
    end
end

-- 点击侠客列表
function guide:excuteGuideFunc5(info)
    local heroes_node = self.m_view.m_cur_node
    if heroes_node == nil then
        return
    end
    local node = nil
    self.m_view:lockTouch()
    local function endCallBack()
        self.m_view:unlockTouch()
        local cell_node = heroes_node.m_list_scroll.m_cache_cells[1]
        if cell_node then
            node = cell_node
        end
        if node then
            self.m_listener = {
                key = "up_hero",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
    self.m_control:setOnceTimer(0.28, endCallBack)
end

-- 点击任务
function guide:excuteGuideFunc6(info)
    local node = self.m_view:findGameObject("quest_btn")
    if node then
        self.m_listener = {
            key = "quest_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    else
        self:doNextGuide()
    end
end

return guide
