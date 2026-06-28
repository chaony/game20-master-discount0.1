local M = class("KingsoftSearchNode",LikeOO.OOUIbase)

M.m_uiName = "Activities/Kingsoft/KingsoftSearchNode"

function M:onEnter()
    self.m_search_scrollbar = self:findScrollbar("search_scrollbar")
    self.m_result_scrollbar = self:findScrollbar("result_scrollbar")
    self.input = self:findInputField('input')
    --UIUtil.addInputFieldListener(self.input.transform, handler(self,self.inputChanged))
    self:setTextByLanKey("shuru_text", "kingsoft_text_0010")
    self:setTextByLanKey("search_text", "kingsoft_text_0011")
    self:setTextByLanKey("new_create_text", "kingsoft_text_0012")
    self:setTextByLanKey("delect_text", "kingsoft_text_0013")
    self:setTextByLanKey("clear_text", "kingsoft_text_0014")
    self:setTextByLanKey("game_text", "kingsoft_text_0015")
    self:setTextByLanKey("address_text", "kingsoft_text_0016")
    self:setTextByLanKey("name_text", "kingsoft_text_0020")
    self:setTextByLanKey("double_text", "kingsoft_text_0018")
    self:setTextByLanKey("four_text", "kingsoft_text_0019")
    self:setTextByLanKey("name_text", "kingsoft_text_0020")
    self:setTextByLanKey("name_text2", "kingsoft_text_0020")
    self:setTextByLanKey("address_text2", "kingsoft_text_0016")
    self:setTextByLanKey("value_text", "kingsoft_text_0021")
    self:setTextByLanKey("type_text", "kingsoft_text_0022")
    self:setTextByLanKey("lock_text", "kingsoft_text_0023")
    self:setTextByLanKey("lock_hot_text", "kingsoft_text_0024")
    self.m_cur_search_cell_index = 0
    self.m_cur_result_cell_index = 0
    --self:refreshUi()
end

function M:refreshUi( )
    if self.m_model.m_select_total_times > 0 then
        local s_data = self.m_model:getSearchData()
        self:setTextByLanKey("search_result_text","kingsoft_text_0025",tostring(self.m_model.m_select_total_times), tostring(#s_data))
    end
   self:updateSearchListScroll()
   self:updateResultListScroll()
end

--获得当前输入的文字
function M:getMsg()
    return self.input.text
end


function M:chageScrollBarValue(bar_name, is_add)
    local bar = nil
    if bar_name == "result_bar" then
        bar = self.m_result_scrollbar
    else
        bar = self.m_search_scrollbar
    end
    local cur_value = bar.value
    local change_value = bar.value + 0.1 * (is_add and 1 or -1)
    change_value = math.max(0, change_value)
    change_value = math.min(1, change_value)
    bar.value = change_value
end

function M:updateSearchListScroll()
    local data = self.m_model:getSearchData()
    if self.m_search_loopscroll == nil then
        local list_scroll = self:findGameObject("search_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateSearchCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self.m_cur_search_cell_index = index
                self:updateMsg("select_data", cell_data)
                --self.m_search_loopscroll:reloadData(data)
                --self:updateResultListScroll()
            end
        }
        self.m_search_loopscroll = LoopScrollViewUtil.new(params)
    else
        self.m_search_loopscroll:reloadData(data)
    end
    self.m_search_loopscroll:moveToCellIndex(self.m_cur_search_cell_index)
end

function M:updateResultListScroll()
    local data = self.m_model:getResultData()
    self:setObjectVisible("result_bg_img", #data > 0 )
    --if self.m_cur_search_cell_index == 0 then
    --    return
    --end
    if self.m_result_loopscroll == nil then
        local list_scroll = self:findGameObject("result_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateResultCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self.m_cur_result_cell_index = index
                self:updateMsg("open_change_pop", cell_data)
            end
        }
        self.m_result_loopscroll = LoopScrollViewUtil.new(params)
    else
        self.m_result_loopscroll:reloadData(data)
    end
    self.m_result_loopscroll:moveToCellIndex(math.min(#data, self.m_cur_result_cell_index) )
end

function M:updateSearchCell(index, cell_object, cell_data)
    local transform = cell_object.transform
    local data = cell_data
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local show_id = data
    local show_cfg, real_cfg
    local show_cfg = self.m_model:getShowCfgById(show_id)
    local name = real_cfg and real_cfg.name or show_cfg.name
    LuaBehaviourUtil.setText(luaBehaviour, "value_text1", name)
    LuaBehaviourUtil.setText(luaBehaviour, "value_text2", show_cfg.addres_des)
    LuaBehaviourUtil.setText(luaBehaviour, "value_text3", show_cfg.two_des)
    LuaBehaviourUtil.setText(luaBehaviour, "value_text4", show_cfg.four_des)
    --UIUtil.setTextByLanKey(transform, "btn_text", data.btn_text)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img",  self.m_cur_search_cell_index == index)
end

function M:updateResultCell(index, cell_object, cell_data)
    local transform = cell_object.transform
    local data = cell_data
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local show_id, real_id, real_num = data[1], data[2], data[3]
    local show_cfg, real_cfg = nil, nil
    local show_cfg = self.m_model:getShowCfgById(show_id)
    if real_id > 0 then
        real_cfg = self.m_model:getRealCfgById(real_id)
    end
    local name = real_cfg and real_cfg.name or show_cfg.name
    LuaBehaviourUtil.setText(luaBehaviour, "value_text1", name)
    LuaBehaviourUtil.setText(luaBehaviour, "value_text2", show_cfg.addres_des)
    LuaBehaviourUtil.setText(luaBehaviour, "value_text3", GameUtil:formatValueToString(real_num))
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "value_text4", self.m_model:getTypeByNums(real_num))
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "value_text5", "kingsoft_text_0041")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "value_text6", "kingsoft_text_0042")
    --UIUtil.setTextByLanKey(transform, "btn_text", data.btn_text)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", self.m_cur_result_cell_index == index)
end



function M:onBtnClick( btn_name, msg, params)
    local function btnClick(trans,params)
        self:updateMsg(msg, params)
    end
    local btn = self:findGameObject(btn_name)
    UIUtil.setButtonClick(btn.transform, btnClick, params)
end

function M:destroy()
    M.super.destroy(self)
end

return M