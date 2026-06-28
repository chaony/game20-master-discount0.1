local M = class("MasterApprenticeRedPacketPopView",LikeOO.OOPopBase)

M.m_uiName = "Friend/MasterApprenticeRedPacketPop"
M.m_size_type = 2


function M:onEnter()
	self:setTextByLanKey("title_text", "master_apprentice_str_0025")
	self:refreshUI()
end

function M:refreshUI()
	self:updateScrollList()
end

function M:updateScrollList()
    local data = self.m_model.m_red_packet
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 3,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour and next(cell_data) ~= nil then
                    if cell_data.status == 0 then
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"open_img",false)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"time_text",true)
                    elseif cell_data.status == 1 then   
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"open_img",true)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"time_text",false)
                    end
                    local function tick(dt)
                        local now_tim = UserDataManager:getServerTime()
                        local show_tim = cell_data.etime - now_tim
                        if show_tim <= 0 then
                            self:updateMsg("remove_red_packet", cell_data)
                        end
                        LuaBehaviourUtil.setText(luaBehaviour, "time_text", GameUtil:formatTimeBySecond(show_tim))
                    end
                    self.m_control:setTimer(1, tick)
                    tick()
                    self:setObjectVisible("tim_bg", true)
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if cell_data.status == 0 then
                    self:updateMsg("get_red_packet", cell_data)
                end
			end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,true)
    end
end


return M