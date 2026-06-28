--==================================
-- brief:  情缘
--==================================
local M = class("FateView", LikeOO.OOPopBase)

M.m_uiName = "Hotel/Fate"
M.m_size_type = 1

function M:onEnter()
    self:setTextByLanKey("close_title_text", "fate_text_001")
    self.m_select_obj = nil
    self.m_gray_img = self:findImage("gray_img")
    local scroll_img = self:findImage("scroll_img")
    scroll_img.transform.localScale = Vector3(0.1, 1, 1)
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(scroll_img.transform:DOScale(Vector3(1, 1, 1), 0.3))
    sequence:AppendInterval(0.1)
    sequence:OnComplete(function()
        self:refreshUI()
    end)
    sequence:SetAutoKill(true)
end

function M:refreshUI()
    self:updateHeroScroll()
    self:setTextByLanKey("times_text", "fate_text_004", self.m_model.m_dare_num_max - self.m_model.m_cur_dare_num, self.m_model.m_dare_num_max)
    if self.m_model.m_listen_cd > 0 then
        self:setTextByLanKey("cd_text", "fate_text_005", GameUtil:formatTimeBySecond2(self.m_model.m_listen_cd))
    else
        self:setText("cd_text", "")
    end
end

function M:updateHeroScroll()
    local data = self.m_model.m_fates
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            --pos_center = true,
            --one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:listHandle(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "story_btn" then --聆听
                    self:updateMsg("story_btn", {index = index, cell_data = cell_data})
                elseif click_name == "box" then --宝箱
                    if cell_data.reward_status == 1 then
                        self:updateMsg("reward_box",{index = index, cell_data = cell_data, click_transform = click_object.transform})
                    else
                        self:updateMsg("box",{index = index, cell_data = cell_data, click_transform = click_object.transform})
                    end
                else
                    if self.m_model.m_listen_cd > 0 then
                        return
                    end
                    if self.m_select_obj ~= nil then
                        local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_obj)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img",false)
                        --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "story_btn",false)
                    end
                    self.m_select_obj = cell_object
                    local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_obj)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img",true)
                    --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "story_btn",true)--显示聆听按钮
                end
            end,
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, true)
    end
end

function M:listHandle(index, obj, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    --spine
    local hero_id = cell_data.hero_id
    local hero_data = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
    local hero_spine_name = hero_data.hero_spine
    local hero_spine = luaBehaviour:FindGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(hero_spine,"RoleSpine/" .. hero_spine_name,"idle", 0,true)
    local name_str = Language:getTextByKey(hero_data.name)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"name_text", name_str)
    local card_bg = luaBehaviour:FindImage("card_bg")
    local card_mask = luaBehaviour:FindImage("card_mask")
    local name_di = luaBehaviour:FindImage("name_di")
    local hero_spine_obj = luaBehaviour:FindGameObject("hero_spine")
    local hero_spine = hero_spine_obj.gameObject:GetComponent("SkeletonGraphic")
    local cur_stage = UserDataManager:getCurStage()
    local is_open = cur_stage >= cell_data.open_stage
    if is_open == true then
        is_open = self.m_model.m_listen_cd <= 0 or self.m_model.m_cur_hero == hero_id
    end
    if is_open then
        card_bg.material = nil
        card_mask.material = nil
        name_di.material = nil
        hero_spine.material = nil
        --hero_spine.color = Color.white
    else
        card_bg.material = self.m_gray_img.material
        card_mask.material = self.m_gray_img.material
        name_di.material = self.m_gray_img.material
        hero_spine.material = self.m_gray_img.material
        --hero_spine.color = Color.gray
    end
    local status = cell_data.reward_status or 0
    if self.m_model.m_cur_hero == hero_id then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img",true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "story_btn",status == 0)
        self.m_select_obj = obj
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img",false)
        if self.m_model.m_listen_cd > 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "story_btn",false)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "story_btn",is_open == true and status == 0)
        end
    end
    --可领取或者已领取，都代表通关
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pass",status ~= 0)
    --通关奖励宝箱红点
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"box_point",status == 1)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"box_effect",status == 1)
    --可打红点
    local is_challenge = self.m_model:isChallenge(cell_data)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"red_point",is_challenge == true)
    --是否已有
    local is_have = UserDataManager.hero_data:checkHeroCollect(hero_id)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "flag_text",is_have == true)
    --开启关卡
    if cur_stage >= cell_data.open_stage then
        LuaBehaviourUtil.setText(luaBehaviour, "cond_text", "")
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cond_text", "new_str_0135", cell_data.open_stage_name, "")
    end
    --set text content
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"story_btn_text","fate_text_002")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"pass_text","fate_text_009")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"flag_text","fate_text_010")
end

function M:destroy()
    M.super.destroy(self)
end

return M