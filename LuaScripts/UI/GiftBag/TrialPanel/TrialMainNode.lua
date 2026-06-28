local M = class("TrialMainNodeView",LikeOO.OOUIbase)

M.m_uiName = "GiftBag/TrialMainNode"

function M:onEnter()
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
    local data = self.m_model:getTaskList()
    local sort_data = self.m_model:ItemSort(data)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = sort_data,
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
				self.m_gift_tab[index] = cell_obj
                self:updateCell(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local cfg, data = self.m_model:getTaskCfg(cell_data)
                if data.status == 1 then 
                    self:updateMsg("get_reward", cell_data)
                elseif data.status == 0 then
                    local go_type = cfg.go_type or {}
                    if _G.next(go_type) then
                        self:updateMsg("go_to", go_type)
                    end
                end
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(sort_data)
    end 
end

function M:updateCell(obj, id)
    local transform = obj.transform
    local cfg, data = self.m_model:getTaskCfg(id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local title_text = luaBehaviour:FindText("title_text")
    local rate_text = luaBehaviour:FindText("rate_text")
    local btn_text = luaBehaviour:FindText("btn_text")
    local btn_text2 = luaBehaviour:FindText("btn_text2")
    local reward_num_text = luaBehaviour:FindText("reward_num_text")
    local parent = luaBehaviour:FindGameObject("itemParent")
    title_text.text = Language:getTextByKey(cfg.name)
    reward_num_text.text = Language:getTextByKey(cfg.score)
    if data.value >= cfg.target_value then
        rate_text.text = cfg.target_value .."/"..cfg.target_value 
    else
        rate_text.text = data.value.."/"..cfg.target_value
    end
    UIUtil.destroyAllChild(parent.transform)
    GameUtil:createRewards(parent.transform, cfg.reward, true, true, nil)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "ok_btn", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_spine", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_text", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_text2", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", false)
    if data.status == 0 then
        local go_type = cfg.go_type or {}
        btn_text.text = Language:getTextByKey("未达成")
        btn_text2.text = Language:getTextByKey("未达成")
        if _G.next(go_type) then
            btn_text.text = Language:getTextByKey("前往")
            btn_text2.text = Language:getTextByKey("前往")
            LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_3", "common_ui")
          
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "ok_btn", true)
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_text", true)
    elseif data.status == 1 then    
        btn_text.text = Language:getTextByKey("领取")
        btn_text2.text = Language:getTextByKey("领取")
        LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_2", "common_ui")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "ok_btn", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_text2", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_spine", true)
    elseif data.status == 2 then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", true)
    end
end


return M