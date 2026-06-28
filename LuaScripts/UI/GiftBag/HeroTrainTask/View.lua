local M = class("HeroTrainTaskView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/HeroTrainTask"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "gf_str_0070")
    self:setTextByLanKey("auto_get_btn_text", "qi_men_dun_jia_str_047") --一键领取
	self:refreshUI()
end

function M:refreshUI()
	self:createLoopScroll()
    self:setObjectVisible("auto_get_btn", RedPointUtil:hasRedPointById(139) == true)
end

--[[
    创建任务列表
]]
function M:createLoopScroll()
    local data = self.m_model:getQuestList()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
                if luaBehaviour then
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_btn_text", "new_str_0056")
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "under_way_text", "gf_str_0071")
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "done_text", "new_str_0080")
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", cell_data.cfg.name1)
                    if cell_data.cfg.target_type == 91 then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_des_text", cell_data.cfg.name2, cell_data.data.target_value)
                    elseif  cell_data.cfg.target_type == 92 then   
                        local race = cell_data.data.target_id or cell_data.cfg.target_id
                        if race == 0 then
                            race = 1
                        end
                        local race_cfg = GlobalConfig.TYPE_HERO_RACE[race]
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_des_text", cell_data.cfg.name2, Language:getTextByKey(race_cfg.name))
                    elseif cell_data.cfg.target_type == 128 then     
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_des_text", cell_data.cfg.name2, cell_data.cfg.target_value..Language:getTextByKey("legend_str_029"))
                    elseif cell_data.cfg.target_type == 90 then     
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_des_text", cell_data.cfg.name2, cell_data.cfg.target_value..Language:getTextByKey("gf_str_0135"))
                    else
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_des_text", cell_data.cfg.name2)
                    end
                    local reward_node = luaBehaviour:FindGameObject("reward_node")
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_btn", cell_data.data.status == 1)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_under", cell_data.data.status == 0)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_done", cell_data.data.status == 2)
                    if reward_node then
                        GameUtil:createRewards(reward_node.transform, cell_data.cfg.reward, true, true)
                    end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "get_btn" then
                    self:updateMsg("get_reward", cell_data.id)
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end



return M