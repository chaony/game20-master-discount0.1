local M = class("ChivalryAcademyView", LikeOO.OOPopBase)
--翰林书院

M.m_uiName = "Chivalry/ChivalryAcademy"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    self.active_data = self.m_model:getActiveData()
    --self.m_grid_obj = self:findGameObject("subject_loopscroll")
    self:setShowText()
    self.m_model:getContent()
    self.m_model:getFontLibrary()
	self:refreshUI()
end

function M:refreshUI()
    self:createLoopScroll()
    self:updateRewardListUI()
    self:refreshRedDod()
end



--[[
    创建排行列表
]]
function M:createLoopScroll()
    local data = self.m_model.show_data
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("subject_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 10,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateRankItem(cell_obj, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("up_write", {index = index, cell_data = cell_data})
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateRankItem(obj, index, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local is_has_word = self.m_model:isCorrect(data.id)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_top",data.cfg.status == 0)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_is_font",data.cfg.status == 1 or data.is_write == 1 or is_has_word)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_no_font",data.cfg.status == 2 and data.is_write == 0 and not is_has_word)
    if data.cfg.status == 1 or is_has_word then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"unlock_text",data.cfg.value)
        LuaBehaviourUtil.setTextColor(luaBehaviour, "unlock_text", Color(121/255, 110/255, 79/255))
    else
        LuaBehaviourUtil.setTextColor(luaBehaviour, "unlock_text", Color(19/255, 27/255, 39/255))
    end
    if data.is_write == 1 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"unlock_text",data.write_value)
        if data.write_value then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_change_font",data.write_value ~= data.cfg.value)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_no_font",false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_is_font",data.write_value == data.cfg.value)
            if data.write_value ~= data.cfg.value then
                self:updateMsg("revoke",{index = index})
            else
                self:updateMsg("preservation",{data = data})
                data.is_write = 0
            end
        end
    end
    
    
end


--[[
    创建奖励列表
]]
function M:updateRewardListUI()
    local data = self.m_model.font_table
    if self.m_font_scroll_view == nil then
        local loopscroll = self:findGameObject("font_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 6,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateRank(cell_obj, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "item_bg" then
                    self:updateMsg("drag_write", {index = index, cell_data = cell_data,cell_object = cell_object})
                end
            end
        }
        self.m_font_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_font_scroll_view:reloadData(data)
    end
end

function M:updateRank(obj, index, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"unlock_text",data.value)
    local btn = luaBehaviour:FindButton("item_bg")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_check",false)
    if data.status == 0 then
        btn.interactable = true
    else
        btn.interactable = false
    end
end

-- 正在操作的棋子选项变红
function M:isMoveChangeRed(obj,isChangeRed)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_check",isChangeRed)
end

--设置显示的文字内容
function M:setShowText()
    if self.active_data then
        self:setTextByLanKey("close_title_text", self.active_data.name)
    end
    self:setTextByLanKey("top_zi_name_text","chivalry_text_0013")
    self:setTextByLanKey("reward_btn_text","chivalry_text_0014")
    self:setTextByLanKey("last_btn_text","chivalry_text_0015")
    self:setTextByLanKey("next_btn_text","chivalry_text_0016")
end

--刷新红点
function M:refreshRedDod()
    local is_receive = self.m_model:getIsHasReward() --是否已领过奖励 领取：true，没领取：false
    local is_write_end = self.m_model:getIsReceive() --已填完
    self:setObjectVisible("reward_red_point_img",is_write_end and not is_receive)
end

return M