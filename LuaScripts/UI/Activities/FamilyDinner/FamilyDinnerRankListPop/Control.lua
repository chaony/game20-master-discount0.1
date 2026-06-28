local M = class("FamilyDinnerRankListPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --每隔1秒执行一次
    self:setTimer(1,function()

    end)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "refreshRedPoint" then    
        self.m_view:refreshUI()
    elseif msg == "hint_btn" then 
        local params = {}
        params.title = "gf_str_0078"
        params.content = Language:getTextByKey("gf_str_0078")
        self:openView("Pops.CommonHelpPop", params) 
    elseif msg == "check_tag" then
        self.m_model:updateData(data, function()
            self:switchTabBtn(data)
        end)
    end
end


-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchNode(index)
    end
end

return M
