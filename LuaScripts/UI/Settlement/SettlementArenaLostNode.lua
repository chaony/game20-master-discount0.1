--- 竞技场结算 失败

local M = class("SettlementArenaLostNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementArenaLostNode"

function M:onEnter()
    self:setTextByLanKey("loser_title_text", "new_str_0254")
    self:setTextByLanKey("rank_title_text", "new_str_0226")
    self:setTextByLanKey("hero_level_up_btn_text", "new_str_0255")
    self:setTextByLanKey("wear_equip_btn_text", "new_str_0256")
    self:setTextByLanKey("strengthen_equip_btn_text", "new_str_0257")
    self:setTextByLanKey("vs_info_title_text", "new_str_0510")
    self:setTextByLanKey("vs_title_text", "new_str_0511")
    self:setTextByLanKey("adjust_btn_text", "new_str_0258")
    self:setTextByLanKey("intensify_btn_text", "new_str_0257")
    self:refreshUI()
end

function M:refreshUI()
    local data = self.m_model.m_data
    local cur_rank = data.rank or 0
    local pre_rank = data.pre_rank or 0
    local dif_rank = pre_rank - cur_rank
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HERO_BOSS_PVP then
        self:setObjectVisible("rank_node", false)
    else
        self:setObjectVisible("rank_node", true)
    end
    self:setTextByLanKey("left_rank_text", tostring(pre_rank))
    local right_rank_text = self:setTextByLanKey("right_rank_text", tostring(cur_rank))
    right_rank_text.color = dif_rank >= 0 and GlobalConfig.COMMON_COLLOR.COMMON_18 or GlobalConfig.COMMON_COLLOR.COMMON_11
    local arrow_img = self:setImg(dif_rank >= 0 and "a_zdjs_jiantou" or "a_zdjs_jiantou_1", "battle_ui", "arrow_img")
    --arrow_img.transform.localRotation = Quaternion.Euler(0,0,dif_rank >= 0 and 90 or -90) -- 上 下

    local cur_score = data.score or 0
    local pre_score = data.pre_score or 0
    self:setTextByLanKey("score_text", tostring(cur_score))
    local dif_score = cur_score - pre_score
    local dif_score_str = dif_score
    if dif_score > 0 then
        dif_score_str = "+" .. tostring(dif_score)
    end
    local add_score_text = self:setTextByLanKey("add_score_text", "(" .. dif_score_str .. ")")
    add_score_text.color = dif_score >= 0 and GlobalConfig.COMMON_COLLOR.COMMON_14 or GlobalConfig.COMMON_COLLOR.COMMON_10
    local score_arrow_img = self:setImg(dif_score >= 0 and "ui_jiantou_lv" or "ui_jiantou_hong", "common_ui", "score_arrow_img")
    --score_arrow_img.transform.localRotation = Quaternion.Euler(0,0,dif_score >= 0 and 90 or -90) -- 上 下

    local player_left_node = self:findGameObject("player_left_node")
    local player_right_node = self:findGameObject("player_right_node")
    local left_user = self.m_model:getUserInfoBySort(1)
    local right_user = self.m_model:getUserInfoBySort(2)
    self:setPlayerInfo(player_left_node, data.score, data.pre_score, left_user)
    self:setPlayerInfo(player_right_node, data.defend_score, data.defend_pre_score, right_user)
end

function M:setPlayerInfo(obj, cur_score, pre_score, user)
    if user then
        cur_score = cur_score or 0
        pre_score = pre_score or 0
        local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.name))
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_title_text", "new_str_0249")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", tostring(cur_score))
        local dif_score = cur_score - pre_score
        local dif_score_str = dif_score
        if dif_score > 0 then
            dif_score_str = "+" .. tostring(dif_score)
        end
        local add_score_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "add_score_text", "(" .. dif_score_str .. ")")
        local HeadNode = luaBehaviour:FindGameObject("HeadNode")
        GameUtil:setUserAvatar(HeadNode, user, true,nil,{show_flag = true, scale = 1})
        add_score_text.color = dif_score >= 0 and GlobalConfig.COMMON_COLLOR.COMMON_18 or GlobalConfig.COMMON_COLLOR.COMMON_11
    end
end

return M