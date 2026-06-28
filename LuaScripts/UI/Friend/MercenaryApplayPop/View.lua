local M = class("MercenaryApplayPopView",LikeOO.OOPopBase)

M.m_uiName = "Friend/MercenaryApplyPop"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "friend_str_0025")
	self:refreshUI()
end

function M:refreshUI()
    self:setText("apply_num_text", Language:getTextByKey("friend_str_0024") .. self.m_model.m_data.apply_num .. "/5")
	self:updateListScroll()
end

function M:updateListScroll()
    local data = self.m_model.m_data.apostles
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:setCellHander(cell_object, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, index)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data)
    end
end

function M:setCellHander(obj, index, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
    local owner_text = luaBehaviour:FindText("owner_text")
    local name_text = luaBehaviour:FindText("name_text")
    local power_text = luaBehaviour:FindText("power_text")
    local applayed_text = luaBehaviour:FindText("applayed_text")
    local applay_btn = luaBehaviour:FindGameObject("applay_btn")
    local unapplay_btn = luaBehaviour:FindGameObject("unapplay_btn")
    local post_img = luaBehaviour:FindGameObject("post_img")
    local npc_img = luaBehaviour:FindGameObject("npc_img")
    owner_text.text = Language:getTextByKey("friend_str_0041") 

    local user_name = data.user.name
    if user_name == "" then
        user_name = Language:getTextByKey("new_str_0141") 
    end
    name_text.text = user_name
    power_text.text = data.hero.combat

    post_img:SetActive(data.user.guild_position > 0 and data.user.guild_position<3)
    if data.position == 1 then
        LuaBehaviourUtil.setImg(luaBehaviour, "post_img",  "h_bh_huizhang_icon", "maze_stage_ui")
    elseif data.position == 2 then
        LuaBehaviourUtil.setImg(luaBehaviour, "post_img",  "h_bh_zhanglao_icon", "maze_stage_ui")
    end
    npc_img:SetActive(data.user.is_npc)

    if next(data.lend_user) then
        applay_btn:SetActive(false)
        unapplay_btn:SetActive(false)
        --applay_btn:GetComponent("Button").interactable = false
        applayed_text.text = string.format(Language:getTextByKey("friend_str_0027"), data.lend_user.name)
    else
        applayed_text.text = Language:getTextByKey("friend_str_0028") .. data.apply_num
        if data.applied then
            applay_btn:SetActive(false)
            unapplay_btn:SetActive(true)
            UIUtil.setText(unapplay_btn.transform, Language:getTextByKey("friend_str_0029"), "Text")
        else
            applay_btn:SetActive(true)
            unapplay_btn:SetActive(false)
            UIUtil.setText(applay_btn.transform, Language:getTextByKey("friend_str_0012"), "Text")
        end
    end
    local function hero_click()
        self:updateMsg("hero_click", data)
    end

    local ItemNode = luaBehaviour:FindGameObject("HeroNode")
    local ui_element = CommonUIUtil:updateHeroElement(ItemNode,  {RewardUtil.REWARD_TYPE_KEYS.HEROS, data.hero.id, 1, quality = data.hero.evo, fate = data.hero.fate_level}, false, hero_click)
    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(data.hero.id)
    local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(data.hero, hero_cfg)
    LuaBehaviourUtil.setImg(ui_element.luaBehaviour,"item_img", hero_skin_cfg.icon, "hero_head_ui")
    local item_luaB = ItemNode:GetComponent("LuaBehaviour")
    local lv_text = item_luaB:FindText("lv_text")
    lv_text.text = string.format(Language:getTextByKey("new_str_0075"), data.hero.clv > 0 and data.hero.clv or data.hero.lv)
end

return M