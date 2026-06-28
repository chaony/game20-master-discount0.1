local guide = class("HeroInfo", LikeOO.OOGuideBase)

function guide:excuteGuideFunc6(info)
    self.m_listener = {
        key = 99999,
    }
    local btn = self.m_view:findGameObject("close_btn")
    if btn then 
        self:guideTargetNode(btn.transform, 3, 1)
    else
    	self:doNextGuide()
    end
end

-- 点击升级
function guide:excuteGuideFunc1(info)
	local lv = info.target[1]
	if self.m_model.m_herodata.lv < lv then
        self.m_control.slid_lock = true
        local function m_levelupclick()
            self.m_control:updateMsg("click_up")
        end
        self.m_view.m_cur_tab_node:addActionChangAn("levet_up_btn",m_levelupclick)

	    local node = self.m_view.m_cur_tab_node:findGameObject("levet_up_btn")
	    if node then
	        self.m_listener = {
	            key = "click_up",
	        }   
	        self:guideTargetNode(node.transform, 1, 1)
	    end
	else
		self:doNextGuide()
	end
end

-- 一键穿装
function guide:excuteGuideFunc2(info)
    local node = self.m_view.m_cur_tab_node:findGameObject("put_on_btn")
    if node then
        self.m_control.slid_lock = true
        self.m_listener = {
            key = "put_on_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 长按升级
function guide:excuteGuideFunc3(info)
    local lv = info.target[1]
    if self.m_model.m_herodata.lv < lv then
        self.m_control.slid_lock = true
        local function m_levelupclick()
            --GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#GuideAsk_086"), delay_close = 2})
            self.m_control:updateMsg("click_up")
        end
        local function m_leveluppress()
            self.m_control:updateMsg("pass_on")
        end
        self.m_view.m_cur_tab_node:addActionChangAn("levet_up_btn",m_levelupclick, m_leveluppress)

        local node = self.m_view.m_cur_tab_node:findGameObject("levet_up_btn")
        if node then
            self.m_listener = {
                key = "pass_on",
                key2 = "click_up",
                --check = function()
                --    return self.m_model.m_cur_Lv >= lv
                --end
            }
            self:guideTargetNode(node.transform, 1, 1, nil, 2)
        end
    else
        self:doNextGuide()
    end
end

return guide
