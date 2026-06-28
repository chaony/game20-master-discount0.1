--==================================
-- brief:  聆听故事
--==================================
local M = class("FateStoryView", LikeOO.OOPopBase)

M.m_uiName = "Hotel/FateStory"
M.m_size_type = 1

function M:onEnter()
    self:setTextByLanKey("close_title_text", "fate_text_002")
    self.m_gray_img = self:findImage("gray_img")
	self:refreshUI()
end

function M:refreshUI()
    self:setTextByLanKey("times_text", "fate_text_004", self.m_model.m_dare_num_max - self.m_model.m_cur_dare_num, self.m_model.m_dare_num_max)
    self:refreshStage()
end

--刷新英雄
function M:refreshStage()
    local data = self.m_model.m_stages
    if self.m_list_scroll == nil then
        local loopscroll = self:findGameObject("loopscroll_node")
        local params = {
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local function callback()
                    cell_object.gameObject:SetActive(true)
                    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                    local stage_img = luaBehaviour:FindImage("img")
                    if index <= self.m_model.m_cur_stage_index then
                        stage_img.material = nil
                        LuaBehaviourUtil.setTextColor(luaBehaviour, "text", Color(146/255, 83/255, 50/255))
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_img", false)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"pass_img", true)
                    elseif index == self.m_model.m_cur_stage_index + 1 then
                        stage_img.material = nil
                        LuaBehaviourUtil.setTextColor(luaBehaviour, "text", Color(146/255, 83/255, 50/255))
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_img", false)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"pass_img", false)
                    else
                        stage_img.material = self.m_gray_img.material
                        LuaBehaviourUtil.setTextColor(luaBehaviour, "text", Color(98/255, 98/255, 98/255))
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_img", true)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"pass_img", false)
                    end
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"text",cell_data.name)
                end
                if index <= 6 then
                    cell_object.gameObject:SetActive(false)
                    self.m_control:setOnceTimer(index <= 6 and  (0.1 * index) or 0, callback)
                else
                    callback()
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("click", {index = index, data = cell_data})
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, true)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M