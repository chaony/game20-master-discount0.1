--- 章节结算 失败
local M = class("SettlementMultChapterLostNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementMultChapterLostNode"

function M:onEnter()
    self:setTextByLanKey("loser_title_text", "new_str_0254")
    self:setTextByLanKey("adjust_btn_text", "new_str_0258")
    self:setTextByLanKey("intensify_btn_text", "new_str_0257")
    self:setTextByLanKey("no_open_btn_text", "new_str_0259")
    self:setTextByLanKey("open_lv_text", "new_str_0260", 99)
    self:refreshUI()
end

function M:refreshUI()
    self:updateLoopScroll()
end
--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getBattleRounds()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("result_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {index = index , cell_data = cell_data})
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local round_data = data.round_data or {}
    local result = round_data.result or 0
    local round = round_data.round or 0
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "new_str_0295", index)

    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "team_num_text", "mult_stage_text00" .. index)
    local lan_atlas = ResourceUtil:getLanAtlas()
    LuaBehaviourUtil.setImg(luaBehaviour,"left_result_img",result == 1 and "a_sjjs_shengli" or "a_sjjs_shibai", lan_atlas)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "battle_log_btn", self.m_model.m_quick_pass ~= true)
end

function M:playAnim()
    if self.m_luaBehaviour then
        self.m_luaBehaviour:RunAnim("SettlementChapterLostNode_show",nil, 1)
    end
end

function M:updateButtonVisible(flag)
	self:setTextByLanKey("loser_title_text", "new_str_0466")
	self:setObjectVisible("lost_ok_btn", flag)
	self:setObjectVisible("intensify_btn", false)
	self:setObjectVisible("adjust_btn", false)
	self:setObjectVisible("ok_text", flag)
	self:setObjectVisible("adjust_btn_text", flag)
	self:setObjectVisible("intensify_btn_text", false)
end

return M