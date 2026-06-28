local guide = class("HelpDagMain", LikeOO.OOGuideBase)

-- 第二关
function guide:excuteGuideFunc1(info)
    local node = self.m_view:findGameObject("level_1_stop_num_but_2")
    self.m_model.stage = "guide"
    if node then
        self.m_listener = {
            key = "level_1_stop_num_but_2",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

--第二关结束返回主界面
function guide:excuteGuideFunc2(info)
    local node = self.m_view:findGameObject("close_btn")
    self.m_control:setOnceTimer(0.05,function()
        local is_past = self.m_model:getLevelCompleteNum()
        if node and is_past >= 2 then
            self.m_listener = {
                key = 99999,
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end)
end

-- 第三关
function guide:excuteGuideFunc3(info)
    local node = self.m_view:findGameObject("level_1_stop_num_but_3")
    self.m_model.stage = "guide"
    if node then
        self.m_listener = {
            key = "level_1_stop_num_but_3",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 领取奖励
function guide:excuteGuideFunc4(info)
    local node = self.m_view:findGameObject("progress_condition_btn_guide")
    self.m_control:setOnceTimer(0.05,function()
        local is_past = self.m_model:getLevelCompleteNum()
        if node  and is_past >= 3 then
            self.m_listener = {
                key = "receiveReward",
            }
            local clickBack = function()
                --self:doNextGuide()
            end
            self:guideTargetNode(node.transform, 1, 1,nil,nil,nil,nil,nil,nil,clickBack,{1})
        end
    end)
end

return guide