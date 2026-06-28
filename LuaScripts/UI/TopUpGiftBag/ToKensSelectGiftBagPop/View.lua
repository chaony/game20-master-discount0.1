local M = class("ToKensSelectGiftBagPopView", LikeOO.OOPopBase)

M.m_uiName = "TopUpGiftBag/ToKensSelectGiftBagPop"
M.m_size_type = 2

M.BG_NAME = {153,115,171,122,123,124,236,248,244,245,275,288,264,265,292,294,284,309,313,314,324,329,330,339,364,371,373,380,384,87,385,393,403,450,408,419,433,436}

--代金券入口
function M:onEnter()
    self:setTextByLanKey("common_title_text", "gf_str_0126")
    self:setTextByLanKey("tokens_text", "gf_str_0128")
	self:refreshUI()
end

function M:refreshUI()
    local tokens_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.VOUCHER,0,0})
    if tokens_data then 
        self:setImg(tokens_data.icon_name, tokens_data.atlas_name, "tokens_icon")
        self:setTextByLanKey("tokens_num", tokens_data.user_num)
    end
    self:createLoopScroll()
end

--[[
    创建页签列表
]]
function M:createLoopScroll()
    self.m_tag_tab = {}
    local data = self.m_model.m_common_data--self.m_model:getCommonData()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("tab_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_tag_tab[cell_obj] = cell_data
                self:update_tag(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                self:updateMsg("open_gift_bag",cell_data)
            end,
            ui_name = self.m_uiName
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end


function M:update_tag(index, obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local open_cond_cfg = self.m_model:getOpenConditionCfgById(data)
        if open_cond_cfg and next(open_cond_cfg) ~= nil then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tag_name_text", open_cond_cfg.name)
            for k, v in pairs(self.BG_NAME) do
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_"..v, false)
            end 
            local bg_img = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_"..data, true)
            if IsNull(bg_img) then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_153", true)
            end
        end
    end
end

return M