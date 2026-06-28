--- 查找
local M = class("FriendNode",LikeOO.OOUIbase)

M.m_uiName = "Friend/MasterApprenticeFindNode"

local __TAB_BTN_NODE = {
    {btn = "cell_tog_1"},
    {btn = "cell_tog_2"},
 }

function M:onEnter()  
    local pre_text = self.m_model.m_status == 1 and "master_apprentice_str_0003" or "master_apprentice_str_0002"
    local cell_tag1_text = self.m_model.m_status == 1 and "master_apprentice_str_0006" or "master_apprentice_str_0007"
    local cell_tag2_text = self.m_model.m_status == 1 and "master_apprentice_str_0008" or "master_apprentice_str_0009"
    self:setTextByLanKey("desc_title_text", pre_text)
    self:setTextByLanKey("cell_tog_1_text", cell_tag1_text)
    self:setTextByLanKey("cell_tog_2_text", cell_tag2_text)
    
    for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
			if is_on then 
				self:updateMsg("cell_tab_btn",data) 
			end 
		end, i, self.m_uiName)
    end
    self:refreshUI()

end

function M:refreshUI()
    self:updateFindList()
    if #self.m_model.m_desc <= 0 then
        self:setText("desc_text", self.m_model:getDesc2())
    else
        self:setText("desc_text", self.m_model.m_desc)
    end
   
    self:setCellTag()
end

function  M:callbackGetId(id)

end

-- 推荐师傅列表 or 徒弟列表
function M:updateFindList()
    local data = self.m_model.m_recommend
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", cell_data.name)
                    if #cell_data.desc == 0 then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_desc", self.m_model:getDesc())
                    else    
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_desc", cell_data.desc)
                    end
               
                    local btn_text = self.m_model.m_status == 1 and "master_apprentice_str_0005" or "master_apprentice_str_0004"
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_btn_text", btn_text)
                    if self.m_model.m_status == 1 then --拜师
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_combat_text", cell_data.full_combat)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_stage",false)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"combat_img",true)
                    elseif self.m_model.m_status == 2 then --收徒申请
                        local stage_data =self.m_model:getStageName(cell_data.stage)
                        if stage_data then
                            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_stage", "master_apprentice_str_0001", Language:getTextByKey(stage_data.map_point_name) )        
                        end
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_stage",true)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"combat_img",false)
                    end

                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("doing_apply", cell_data.uid)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,true)
    end
end

function M:setCellTag()
    if self.m_model.m_flag == 0 then
        local btn_tab = __TAB_BTN_NODE[1]
        local tog_btn = self:findToggle(btn_tab.btn)
        if tog_btn then
            tog_btn.isOn = true
        end
    else
        local btn_tab = __TAB_BTN_NODE[2]
        local tog_btn = self:findToggle(btn_tab.btn)
        if tog_btn then
            tog_btn.isOn = true
        end
    end
end

return M