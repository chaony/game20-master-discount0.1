local M = class("GrowUpFundPopView", LikeOO.OOPopBase)

M.m_uiName = "OperateActivity/GrowUpFundPop"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "gf_str_0093")
	self:refreshUI()
end

function M:refreshUI()
	self:createLoopScroll()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_linshi_fund(85)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateCell(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "buy_btn" then
                    self:updateMsg("get_fund", {reward_id = cell_data.id, fund_id = self.c_fund_id} )
                elseif click_name == "goto_btn" then
                    self:updateMsg("go_to", 1)
                end
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(data)
    end 
end

function M:updateCell(index, obj, cfg)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local count_text  = luaBehaviour:FindText("count_text")
        local parent = luaBehaviour:FindGameObject("itemParent")
        count_text.text = Language:getTextByKey(cfg.name) 
        local data = self.m_model:getFundData(cfg.id)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "goto_btn", false)
        local buy_btn
        if data then
            if data.status == 0 then -- 未完成
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_btn_text", "new_str_0029")
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_text", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "goto_btn", true)
                LuaBehaviourUtil.setImg(luaBehaviour, "buy_btn", "a_ui_currency_btn_middle_3", "common_ui")
            elseif data.status == 1 then --可领
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_btn_text", "new_str_0056")
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_text", false)
                LuaBehaviourUtil.setImg(luaBehaviour, "buy_btn", "a_ui_currency_btn_middle_2", "common_ui")
            elseif data.status == 2 then --已领取
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_text", "new_str_0080")
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_text", true)
            end
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_btn_text", "new_str_0259")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_text", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "goto_btn", true)
        end
        UIUtil.destroyAllChild(parent.transform)
        GameUtil:createRewards(parent.transform, cfg.reward, true, true, nil, 0.8)
    end
end

return M