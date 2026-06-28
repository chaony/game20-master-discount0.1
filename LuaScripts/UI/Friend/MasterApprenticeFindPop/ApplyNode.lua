--- 申请
local M = class("FriendNode",LikeOO.OOUIbase)

M.m_uiName = "Friend/MasterApprenticeApplyNode"

function M:onEnter()  
    self:refreshUI()
end


function M:refreshUI()
    self:updateFindList()
end


--申请列表
function M:updateFindList()
    local data = self.m_model.m_apply
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    local title_text = self.m_model:getApplyTitleText(cell_data.sort)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", cell_data.name)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_desc", cell_data.desc)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_combat_text", cell_data.full_combat)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"yes_btn",true)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"no_btn",true)
                    if cell_data.sort == 1 then --拜师申请
                        local stage_data =self.m_model:getStageName(cell_data.stage)
                        if stage_data then
                            --LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_desc",true)
                            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_desc", "master_apprentice_str_0001", stage_data.map_point_name)        
                        end
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_desc",false)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"combat_img",true)
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "master_apprentice_str_0027")
                    elseif cell_data.sort == 2 then --收徒申请
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_desc",false)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"combat_img",true)
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "master_apprentice_str_0026")
                    elseif cell_data.sort == 3 then --解除关系申请    
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_desc",true)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"combat_img",false)
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_desc", "master_apprentice_str_0019")
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"no_btn",false)
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "master_apprentice_str_0028")
                    end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "yes_btn" then
                    self:updateMsg("handle_apply", {uid = cell_data.uid, sort = cell_data.sort, status = 1 })
                elseif click_name == "no_btn" then
                    self:updateMsg("handle_apply", {uid = cell_data.uid, sort = cell_data.sort, status = 0 })
                end
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,true)
    end
end

return M