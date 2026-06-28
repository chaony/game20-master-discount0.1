local M = class("WorldTestView",LikeOO.OOPopBase)

M.m_uiName = "WorldTest/WorldTest"
M.m_iphoneXAdapter = true
M.m_size_type = 2

local __TAB_BTN_NODE = {
	{ name = "world_str_001", img = "a_JH_chuangwangbaozang", open_id = 18},
	{ name = "world_str_002", img = "a_JH_yingxionglei", open_id = 24},
	{ name = "world_str_003", img = "a_JH_zhenwushilian", open_id = 29},
	{ name = "world_str_004", img = "a_JH_wuxingzhen", open_id = 10},
	{ name = "world_str_005", img = "a_JH_sixiangfutu", open_id = 0},
	{ name = "world_str_006", img = "a_JH_jianghushijie", open_id = -1},
}

function M:create()
    M.super.create(self)
end

function M:onEnter()
    self:updateLoopScroll()
    self:setTextByLanKey("title_text","world_str_007")
    self:setTextByLanKey("text_tips", "world_str_008")
end

--[[
    掉落列表
]]
function M:updateLoopScroll()
    self.m_reward_cell_tab = {}   
    if self.m_reward_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
			show_data = __TAB_BTN_NODE,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                local LuaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
                if LuaBehaviour then
                    LuaBehaviourUtil.setImg(LuaBehaviour, "icon_img", cell_data.img, "hero_ui")
                    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "btn_text", cell_data.name)
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                self:updateMsg("openView", cell_data.open_id)
            end
        }
        self.m_reward_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_reward_scroll_view:reloadData( __TAB_BTN_NODE)
    end 
end


return M