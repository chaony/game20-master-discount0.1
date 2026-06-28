local M = class("MythArenaSecondDetailsPopView",LikeOO.OOPopBase)
--晋级赛阶段战报
M.m_uiName = "MythArena/MythArenaSecondDetailsPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("common_title_text", "wlsh_myth_002")
    self:refreshUI()
end

function M:refreshUI()
    self:refreshDetailsList()
    local promotion = self.m_model.m_log_data and self.m_model.m_log_data.promotion or 0
    self:setObjectVisible("promotion_bg", promotion == 1)
    self:setTextByLanKey("statistics_num", "+999")
    self:setImg("statistics_img", ResourceUtil:getLanAtlas(), "iocn")
end

function M:refreshDetailsList()
    -- 战斗列表
    local data = self.m_model:getBattleLog()
    if self.m_detailScroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            one_line_count = 2, -- 行或列的数量
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:refreshCellItem(cell_obj, cell_data)
            end,
            ui_name = self.m_uiName,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "head_btn" then
                    self:updateMsg("look_player", cell_data.uid)
                elseif click_name == "record_btn" then
                    self:updateMsg("record_btn", cell_data.battle_id)
                end
            end
        }
        self.m_detailScroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_detailScroll_view:reloadData(data, true)
    end
end

function M:refreshCellItem(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    --LuaBehaviourUtil.setImg(luaBehaviour, "money_icon", "图片", "item_icon")
    --LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "money_num", "+999")--积分
    local is_win = data.win
    local uid = data.uid
    local user_data = self.m_model:getUserInfoByUid(uid)
    local time_des = GameUtil:formatTimeBySecond(math.max(1,  data.ts * 0.001), 999)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"time_text", "wlsh_text_0011", time_des)
    local win_img = nil
    local HeadNode = luaBehaviour:FindGameObject("head_node") --玩家头像组件
    if user_data and next(user_data) ~= nil then
        GameUtil:setUserAvatar(HeadNode, user_data, nil, nil, {show_flag = true, scale = 1})
        local name_text = LuaBehaviourUtil.setText(luaBehaviour,"name_text", user_data.name)
        local title_id = user_data.title
        if title_id and title_id ~= 0 then
            name_text.transform.anchoredPosition = Vector3.New(-34.1, -18.1, 0)
        else
            name_text.transform.anchoredPosition = Vector3.New(-34.1, 0, 0)
        end
    end
    if is_win == 1 then
        win_img = LuaBehaviourUtil.setImg(luaBehaviour, "result_img", "a_bh_shengli_zi", ResourceUtil:getLanAtlas())
    else
        win_img = LuaBehaviourUtil.setImg(luaBehaviour, "result_img", "a_bh_shibai_zi", ResourceUtil:getLanAtlas())
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "record_btn",  self.m_model.m_cur_stage and self.m_model.m_cur_stage >= 6)

    --if self.m_model.m_cur_stage and self.m_model.m_cur_stage == 6 then
   --     win_img.transform.anchoredPosition = Vector3.New(-34.1, -18.1, 0)
   -- else
    --    win_img.transform.anchoredPosition = Vector3.New(-34.1, -18.1, 0)
 --   end
    win_img:SetNativeSize()
end


function M:destroy()
    M.super.destroy(self)
end

return M