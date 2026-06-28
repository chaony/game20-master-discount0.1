
local M = class("MythArenaSecondView",LikeOO.OOPopBase)
-- 风云擂台晋级赛
M.m_uiName = "MythArena/MythArenaSecond"  -- prefab name
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("shop_btn_text", "new_str_0861")
    self:setTextByLanKey("record_btn_text", "UnionWar_str_006")
    self:setTextByLanKey("go_btn_text", "fylt_str_0065")
    self:initUI()
    self:refreshUI()
end

function M:initUI()
    self:setTextByLanKey("close_title_text", "wlsh_text_0004")
    local bg_path, name_img_path = self.m_model:getImgPathByStage()
    for i=1, 8 do
        local obj = self:findImage("player_data_"..i)
        local luaBehaviour = UIUtil.findLuaBehaviour(obj)
        local record_btn = luaBehaviour:FindGameObject("record_btn")
        local jc_btn = luaBehaviour:FindGameObject("jc_btn")
        GameUtil:updateResourcesImg(obj.gameObject, "Texture/wulinshenhua/".. bg_path)
        LuaBehaviourUtil.setImg(luaBehaviour, "name_bg", name_img_path, "pub_ui")
        UIUtil.setButtonClick(record_btn.transform, function(obj, data)
            self:updateMsg("record_btn", data)
        end, i, nil, self.m_uiName)
        UIUtil.setButtonClick(jc_btn.transform, function(obj, data)
            self:updateMsg("jc_btn", data)
        end, i, nil, self.m_uiName)

    end
end

function M:refreshUI()
    self:setObjectVisible("time_bg", self.m_model.m_open_type == "now")
    self:setObjectVisible("drop_down_bg_img", self.m_model.m_show_drop_down)
    self:setObjectVisible("log_btn", self.m_model.m_big_stage > 3 and self.m_model.m_open_type == "now")
    self:setObjectVisible("go_btn", self.m_model.m_open_type == "now" and self.m_model.m_self_group_id == self.m_model.m_cur_group_id)
    self:setTextByLanKey("cur_team_num","wlsh_text_0007", self.m_model.m_stage_name, self.m_model.m_cur_group_id)
    local select_team_arrow_img = self:findGameObject("select_team_arrow_img")
    UIUtil.setScale(select_team_arrow_img.transform, 1,self.m_model.m_show_drop_down and 1 or -1)
    self:updateLoopScroll()
    for i = 1,8 do
        self:updateCell(i)
    end
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model.m_group_data
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_group", {id = index, cell_data = cell_data})
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
   
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "group_name_text","wlsh_text_0007", self.m_model.m_stage_name, index)
end

function M:updateCell(index)
    local obj = self:findGameObject("player_data_"..index)
    local cur_group_guess_id = self.m_model:getGuessDataByGroupId() 
    local log_data = self.m_model:getLogsByIndex(index)
    if log_data then
        local luaBehaviour = UIUtil.findLuaBehaviour(obj)
        local HeadNode = luaBehaviour:FindGameObject("HeadNode") --玩家头像组件
        local player_btn = luaBehaviour:FindGameObject("player_btn")
        local uid = log_data.uid
        local promotion = log_data.promotion --是否晋级 
        local win_bg = luaBehaviour:FindImage("win_bg")
        win_bg.color = (self.m_model.m_last_stage == 3 and promotion == 3) and Color( 1/255, 1/255, 1/255) or Color( 255/255, 235/255, 255/255)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "win_bg", (promotion == 1 or (promotion == 3 and self.m_model.m_last_stage == 3)) and self.m_model.m_open_type == "last")
        if self.m_model.m_open_type == "last" and self.m_model.m_last_stage == 3 and promotion == 3 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"win_state_text", "wlsh_text_0015")
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"win_state_text", "wlsh_text_0014")
        end
        local user_data = self.m_model:getUserInfoByUid(tostring(uid))
        if user_data and next(user_data) ~= nil then
            GameUtil:setUserAvatar(HeadNode, user_data)
            LuaBehaviourUtil.setText(luaBehaviour,"name_text", user_data.name)
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", cur_group_guess_id == uid and self.m_model.m_open_type == "now")
        if cur_group_guess_id == uid and self.m_model.m_open_type == "now" then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "jc_btn", true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "jc_btn", self.m_model.m_is_jc
                    and not(cur_group_guess_id)
                    and self.m_model.m_open_type == "now")
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "record_btn", self.m_model.m_open_type == "last")
    end
end

function M:updateActivityTimer()
    local end_ts = self.m_model:getEndTs()
    if end_ts >= 0 then
        local text = GameUtil:formatTimeBySecond(end_ts, 999)
        local stage_name = Language:getTextByKey(self.m_model:getCurStageName())
        self:setTextByLanKey("time_text", "wlsh_text_0009", stage_name, text)
    else
        self:updateMsg("stage_end")
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M


