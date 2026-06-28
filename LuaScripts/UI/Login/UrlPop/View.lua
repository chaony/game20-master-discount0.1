local M = class("LoginServerView",LikeOO.OOPopBase)

M.m_uiName = "Login/SelectServer"
M.m_size_type = 2

function M:onEnter()
    self:createLoopScroll()
    self:setTextByLanKey("common_title_text", "new_str_0666")
end

function M:createLoopScroll()
    local data = self.m_model.server_url
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                LuaBehaviourUtil.setText(luaBehaviour, "name_text", data.name)
                local on_img = luaBehaviour:FindGameObject("on_img")
                on_img:SetActive(data.server_list[1] == GameVersionConfig.MASTER_URL)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_server", cell_data)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,true)
    end
end

return M