local M = class("UnionWarSettlementView",LikeOO.OOPopBase)

M.m_uiName = "UnionWar/UnionWarSettlement"
M.m_size_type = 2


function M:onEnter()
    self:setTextByLanKey("common_title_text", "UnionWar_str_006")
    self:setTextByLanKey("title_occupy_territory_text", "new_str_0857")
    self:setTextByLanKey("title_cumulative_defeat_text", "new_str_0858")
    self:setTextByLanKey("title_get_points_text", "new_str_0851")
    self:setTextByLanKey("title_rank_text", "new_str_0864")
    self:setTextByLanKey("log_btn_text", "new_str_0853")
    self:setTextByLanKey("ok_btn_text", "new_str_0315")
    self:refreshUI()
end

function M:refreshUI()
    self:updateGuildInfo(1, "left_union_img", "left_union_text", "left_union_star_text")
    self:updateGuildInfo(2, "right_union_img", "right_guide_text", "right_union_star_text")
    local round_report = self.m_model.m_round_report or {}
    self:setTextByLanKey("round_points_text", "UnionWar_str_086", round_report.round_id, round_report.max_round) -- 回合
    self:setTextByLanKey("rank_text", tostring(round_report.rank)) --排名
    --self:setTextByLanKey("occupy_territory_text", tostring(round_report.cell_num)) --占领领地
    --self:setTextByLanKey("cumulative_defeat_text", tostring(round_report.kill_num)) -- 累计击败
    --self:setTextByLanKey("get_points_text", tostring(round_report.get_score)) -- 获得积分
    local win = round_report.win or 0
    self:setTextByLanKey("result_text", win == 1 and "new_str_0298" or "new_str_0299")
    LuaBehaviourUtil.setImg(self.m_luaBehaviour, "result_img",  win == 1 and "a_bh_shengli" or "a_bh_shibai", ResourceUtil:getLanAtlas())
    local result_img_bg = self:findImage("result_img_bg")
    GameUtil:updateResourcesImg(result_img_bg, "Texture/arena/" .. (win == 1 and "a_bh_shenglibiaoti_di" or "a_bh_shibaibiaoti_di"))
end

function M:updateGuildInfo(idx, union_img, union_text, score_text)
    local guild_Info, guild_icon = self.m_model:getGuildInfo(idx)
    local union_img = self:findImage(union_img)
    GameUtil:updateResourcesImg(union_img, "Texture/union_emblem/" .. tostring(guild_icon))
    self:setTextByLanKey(union_text, guild_Info.name)
    self:setTextByLanKey(score_text, tostring(guild_Info.score))
end

function M:destroy()
    M.super.destroy(self)
end

return M