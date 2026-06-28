---
---

local M = class("AwakeSystemAsleepPopView",LikeOO.OOPopBase)

M.m_uiName = "AwakeSystem/AwakeSystemAsleepPop"  -- prefab name
M.m_size_type = 2
M.m_iphoneXAdapter = true

local gray_color =  Color(152 / 255, 152 / 255, 152 / 255)

function M:onEnter()
    self:setTextByLanKey("close_title_text", "awake_system_text_004")
    self:setTextByLanKey("asleep_add_nums_text", "awake_system_text_007")
    self:setTextByLanKey("complete_text", "awake_system_text_008")
    self:setObjectVisible("help_btn", false)
    self.hui = self:findImage("hui")
    self:refreshUI()
end

--刷新UI
function M:refreshUI()
    local consItem = RewardUtil:getProcessRewardData(self.m_model.m_cur_awaken_cfg.final_reward[1])
    self:setImg(consItem.icon_name, consItem.atlas_name, "blue_block_img")
    self:setTextByLanKey("blue_block_text", "X" .. tostring(consItem.data_num))
    self:setObjectVisible("blue_block_text", true)
    self:setTextByLanKey("asleep_nums_text", "awake_system_text_006",self.m_model.m_times)
    self:refreshStage()
    local get_img = self:findImage("blue_block_img")
    get_img.material = self.m_model.m_can_get and self.hui.material or nil
end

--刷新英雄
function M:refreshStage()
    local data = self.m_model:getShowData()
    if self.m_rightloop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll_node")
        local params = {
            show_data = data,
            one_line_count = 5,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                local status = self.m_model:getStageStatus(index,cell_data.stage_id)
                if status == 1 then  --待解锁
                    LuaBehaviourUtil.setImgAlpha(luaBehaviour,"can_fly_bg",1)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"fly_text",true)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_img", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"can_fly_img",true)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"fly_text","awake_system_text_0017")
                elseif status == 4 then  --不能解锁
                    LuaBehaviourUtil.setImgAlpha(luaBehaviour,"can_fly_bg",0.5)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"fly_text",false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_img", true)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"can_fly_img",false)
                elseif status == 3 then  --已经解锁
                    LuaBehaviourUtil.setImgAlpha(luaBehaviour,"can_fly_bg",1)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"fly_text",true)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_img", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"can_fly_img",true)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"fly_text","awake_system_text_0016")
                elseif status == 2 then  --已经通关
                    LuaBehaviourUtil.setImgAlpha(luaBehaviour,"can_fly_bg",1)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"fly_text",true)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_img", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"can_fly_img",true)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"fly_text","awake_system_text_0013")
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("unlock", {index = index,data = cell_data})
            end
        }
        self.m_rightloop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_rightloop_scroll_view:reloadData(data, true)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M

