local guide = class("GamePanel", LikeOO.OOGuideBase)

-- 点击释放技能
function guide:excuteGuideFunc4(info)
    local skill_btns = self.m_view.skillBtns
    local node = nil
	for i=1,skill_btns.Count,1 do
		local btn = skill_btns:get(i-1)
        if btn.isAready then
            node = btn.icon_btn
            break
        end
	end
    if node then
        --战斗暂停
        SceneManager:pause();
        self.m_listener = {
            key = "skill_click",
        }
        
        local function skipCallBack()
            SceneManager:continue();
        end
        UserDataManager.guide_data:setSkipCallback(skipCallBack)
        
        self:guideTargetNode(node.transform, 1, 1, nil, nil, nil, nil, nil, true)
    end
end

-- 点击自动战斗
function guide:excuteGuideFunc5(info)
    local node = self.m_view:findGameObject("h_auto")
    
    if node then
        --战斗暂停
        SceneManager:pause();
        self.m_listener = {
            key = "h_auto",
        }

        local function skipCallBack()
            SceneManager:continue();
        end
        UserDataManager.guide_data:setSkipCallback(skipCallBack)
        
        self:guideTargetNode(node.transform, 1, 1, nil, nil, nil, nil, nil, true)
    end
end

-- 点击二倍速
function guide:excuteGuideFunc6(info)
    local node = self.m_view:findGameObject("h_speed2")

    if node then
        --战斗暂停
        SceneManager:pause();
        self.m_listener = {
            key = "h_speed2",
        }

        local function skipCallBack()
            SceneManager:continue();
        end
        UserDataManager.guide_data:setSkipCallback(skipCallBack)
        
        self:guideTargetNode(node.transform, 1, 1, nil, nil, nil, nil, nil, true)
    end
end

-- 自动打开自动按钮
function guide:excuteGuideFunc7(info)
    local auto = self.m_model:changeAuto()
    if auto ~= 1 then
        self.m_control:selectAuto()
        self:doNextGuide()
    end
end

return guide
