local M = class("InGameNoticePopView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Notice/InGameNoticePop"


function M:onEnter()
	self:refreshUI()
end

--刷新
function M:refreshUI()
	self:refreshGouXuan()
    self:refreshContent()
    self:refreshLeftAndRightBtn()
    self:updateLevelLoopScroll()
end

--刷新勾选按钮
function M:refreshGouXuan()
    self.m_model.callback_time = UserDataManager.local_data:getUserDataByKey("gameNotice", nil)
    local is_gouxuan = self.m_model.callback_time == nil and 0 or 1
    self:setObjectVisible("gouxuan_img",is_gouxuan == 1)
end

--刷新显示内容
function M:refreshContent()
    local content = self.m_model:getNoticeContent(self.m_model.current_id)
    local goto_btn = false
    if content ~= nil then
        self:setTextByLanKey("title_text",content.title or "")
        self:setTextByLanKey("content_text",content.des or "")
        self:setTextByLanKey("goto_text",content.name or "")
        self.m_model.targetUrl = content.targetUrl
        if content.name ~= nil or content.name ~= "" then
            goto_btn = true
        end
    else
        self:setTextByLanKey("title_text", "notice_str_0002")
        self:setTextByLanKey("content_text", "notice_str_0003")
        self:setTextByLanKey("goto_text", "")
        self.m_model.targetUrl = nil
    end
    self:setObjectVisible("goto_btn",goto_btn)
end

--刷新左右按钮显示
function M:refreshLeftAndRightBtn()
    local left_btn = true
    local right_btn = true
    if self.m_model.current_id == 1 then
        left_btn = false
    end
    if self.m_model.current_id == self.m_model:getNoticeListCount() or #self.m_model.m_notice == 0 then
        right_btn = false
    end
    self:setObjectVisible("left_btn",left_btn)
    self:setObjectVisible("right_btn",right_btn)
end

--创建关卡列表
function M:updateLevelLoopScroll()
    self.m_level_click_cell_object = nil
    local data = self.m_model.m_notice
    if self.m_level_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            pos_center = true,
            update_cell = function(index,cell_object,cell_data)
                self:updateLevelScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index,cell_object,cell_data,click_object,click_name)
                
            end
        }
        self.m_level_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_level_loop_scroll_view:reloadData(data,true)
    end
end

--设置关卡数据
function M:updateLevelScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local transform = cell_object.transform
    
    local check = false
    if index == self.m_model.current_id then
        check = true
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unChecked_img", not check)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Checked_img", check)
end

function M:destroy()
    M.super.destroy(self)
end

return M