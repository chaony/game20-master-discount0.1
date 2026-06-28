local M = class("LiteratureGroupRankListPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --每隔1秒执行一次
    self:setTimer(1,function()

    end)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "out_force_btn" then
        if self.m_model:getActStatus() == 1 then
            self:outForce()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    end
end


-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchNode(index)
    end
end

function M:outForce()
    local params = {
        text = Language:getTextByKey("enjoySpring_str_0039"),
        tow_close_btn = true,
        on_ok_call = function ()
             self:requestoutForce()
        end
    }
    self:openView("Pops.CommonPop", params, true)
end

function M:requestoutForce()
    local function outForceCallback(response)
        if response then
            self:updateMsg("update_data",nil, "Activities.FourForceWar")
            self:closeView("Activities.FourForceWar.FourForceWarTask")
            self:updateMsg(99999)
        end
    end
    local params = {}
    params.force_id = self.m_model.m_force
    self.m_model:getNetData("enjoy_spring_exit_wenqu", params, outForceCallback)
end

return M
