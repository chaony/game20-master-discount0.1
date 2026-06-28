local M = class("GifBagDoubleNode", LikeOO.OOUIbase)
--双倍收益
M.m_uiName = "GiftBag/GifBagDoubleNode"

function M:onEnter()
    local double_tab, data = self.m_model:getDoubleCfg()
    local time_str = os.date("%Y年%m月%d日 %H:%M", data.start_ts)
    local time_end = os.date("%Y年%m月%d日 %H:%M", data.end_ts)
    local show_text = time_str .. " - " .. time_end
    self:setText("count_text", show_text)
    self:refreshUI()
    self:setTextByLanKey("title_text","dragonsword_text_0001")
    self:setTextByLanKey("title_text2","huodong_neirong_tex")
    self:setTextByLanKey("get_btn_text", "buy_growup_get")
    self:setTextByLanKey("gitf_btn_text", "new_str_0732")
end

function M:refreshUI()
    local active_data = self.m_model:checkActiveCfgByOpenId(77)
    self:createLoopScroll(active_data.version)
end

--[[
    创建礼包列表
]]
function M:createLoopScroll(version)
    self.m_gift_tab = {}
    local data_tab = self.m_model:get_double_tab(version)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data_tab,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                local LuaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
                if LuaBehaviour then
                    local str = Language:getTextByKey(cell_data.name) 
                    local times = tostring(GameUtil:formatNum(cell_data.times))
                    local ss = string.format(str, times)
                    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "show_text", ss)
                end
                self:updateeItem(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "go_btn" then
                    self:updateMsg("go_to", cell_data.go_type)
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data_tab)
    end
end

function M:updateeItem(cell_obj, cell_data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if LuaBehaviour then
        local jump_id = cell_data.go_type[1]
        local jump_cfg = self.m_model:getJump(jump_id)
        local cfg = BtnOpenUtil:getBtnCfg(jump_cfg.open_condition_id)
        local unlock_condition_param = cfg.unlock_condition_param or 0
        local stage = ConfigManager:getCfgByName("stage")
        local stage_item = stage[unlock_condition_param] or {}
        local name = Language:getTextByKey(tostring(stage_item.map_point_name))
        local tips_str = Language:getTextByKey("new_str_0135", "", name)
        local bl, tips = BtnOpenUtil:isBtnOpen(jump_cfg.open_condition_id)
        if bl == true then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "mask_img", false)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_text", false)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "go_btn", true)
        else
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "lock_text", tips_str)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "mask_img", true)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_text", true)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "go_btn", false)
        end
   
    end
end

function M:showUI(bl)
    self:setObjectVisible("show_time", bl)
    self:setObjectVisible("btns", bl)
    self:setObjectVisible("time_text", bl)
end

function M:destroy()
    M.super.destroy(self)
end

return M
