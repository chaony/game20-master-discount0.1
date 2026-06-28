--- 威望
local M = class("PrestigeNode",LikeOO.OOUIbase)

M.m_uiName = "WorldMap/PrestigeNode"
M.m_iphoneXAdapter = true


function M:onEnter()
    self:refreshUI()    
end

function M:refreshUI()
    self:setTextByLanKey("title_map_text", self.m_model:getCurMapName())
    self:updateLoopScroll()
end

--[[
    掉落列表
]]
function M:updateLoopScroll()
    self.m_cell_tab = {}   
    local data = self.m_model:getPrestigeTab()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
			show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateItemNode(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                local cfg = self.m_model:getPrestigeCfg(cell_data)
                if self.m_model.cur_prestiges_num >= cfg.sp_exp and  self.m_model:checkPrestigesDone(data) == false then
                    self:updateMsg("get_reward", cell_data)
                end
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end 
end

function M:updateItemNode(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local cfg = self.m_model:getPrestigeCfg(data)
        local reward_node = luaBehaviour:FindGameObject("reward_node")
        LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", "ui_weiwang"..cfg.level, "common_ui")
        GameUtil:createRewards(reward_node.transform, cfg.item_reward, true, true, nil, 1)
        local value = self.m_model.cur_prestiges_num > cfg.sp_exp and cfg.sp_exp or self.m_model.cur_prestiges_num
        LuaBehaviourUtil.setText(luaBehaviour, "progress_value", "<color=#3E8E8D>"..value.."</color><color=#323232>/"..cfg.sp_exp.."</color>")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", "tid#prestigename_"..cfg.level)
        LuaBehaviourUtil.setSliderValue(luaBehaviour, "progress_slider", (self.m_model.cur_prestiges_num/cfg.sp_exp))
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_text", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_reward_btn", false)
        if self.m_model.cur_prestiges_num >= cfg.sp_exp  then
            if self.m_model:checkPrestigesDone(data) == true then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_text", true)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_text", "new_str_0080")
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn", true)
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_reward_btn", true)
        end
    end
end


return M