local M = class("UnionWarSituationView",LikeOO.OOPopBase)

M.m_uiName = "UnionWar/UnionWarSituation"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "new_str_0853")
    self:setTextByLanKey("own_battle_log_btn_text", "new_str_0854")
    self:setTextByLanKey("ok_btn_text", "new_str_0315")
    self:setTextByLanKey("battle_log_detail_btn_text", "new_str_0855")
    self:setTextByLanKey("common_no_have_text", "new_str_0351")
    self:refreshUI()
end

function M:refreshUI()
    self:updateGuildInfo(1, "left_union_img", "left_union_text")
    self:updateGuildInfo(2, "right_union_img", "right_guide_text")
    self:updateLoopScroll()
end

function M:updateGuildInfo(idx, union_img, union_text)
    local guild_Info, guild_icon = self.m_model:getGuildInfo(idx)
    local union_img = self:findImage(union_img)
    GameUtil:updateResourcesImg(union_img, "Texture/union_emblem/" .. tostring(guild_icon))
    self:setTextByLanKey(union_text, guild_Info.name)
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getShowData()
    self:setObjectVisible("CommonTipsNode", #data == 0)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {id = index , cell_data = cell_data})
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", cell_data.cell_cfg.name)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_name_text", "UnionWar_str_040", cell_data.left_t_num)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_name_text", "UnionWar_str_040", cell_data.right_t_num)
    local lan_atlas = ResourceUtil:getLanAtlas()
    LuaBehaviourUtil.setImg(luaBehaviour, "left_result_icon",  cell_data.left_win and "a_bh_shengli_zi" or "a_bh_shibai_zi", lan_atlas)
    LuaBehaviourUtil.setImg(luaBehaviour, "right_result_icon", cell_data.right_win and "a_bh_shengli_zi" or "a_bh_shibai_zi", lan_atlas)
    local left_result_bg = LuaBehaviourUtil.setImg(luaBehaviour, "left_result_bg",  cell_data.left_win and "a_bh_shengli_di" or "a_bh_shibai_di", "arena_ui")
    local right_result_bg = LuaBehaviourUtil.setImg(luaBehaviour, "right_result_bg", cell_data.right_win and "a_bh_shengli_di" or "a_bh_shibai_di", "arena_ui")
    UIUtil.setLocalScale(left_result_bg.transform, cell_data.left_win and 1 or -1)
    UIUtil.setLocalScale(right_result_bg.transform, cell_data.right_win and -1 or 1)
end

function M:destroy()
    M.super.destroy(self)
end

return M