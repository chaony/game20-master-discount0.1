local M = class("HeroLegend",LikeOO.OOPopBase)

M.m_uiName = "HeroBag/HeroLegend"
M.m_size_type = 2


function M:onEnter()
    self.book_Img = self:findGameObject("book_Img")
    self.openBook_Img = self:findGameObject("biography_Img")
    self:setTextByLanKey("last_text","new_str_0906")
    self:setTextByLanKey("lock_text","rpg_scroll_9")
    self.last_btn = self:findGameObject("last_btn")
    self.book_Img.gameObject:SetActive(true)
    self.openBook_Img.gameObject:SetActive(false)
    self:setObjectVisible("left_lock_Img", false)
    self.m_legent = 0
    self:refreshUI()
    if self.m_model.m_is_go_last then
        self.m_control:setOnceTimer(0.5, function()
            self:openBook()
        end)
        self.m_control:setOnceTimer(1, function()
            local offset_value = #(self.m_model.hero_legend_tab) % 2 == 1 and 1 or 2
            self.m_legent = self.m_model.m_max_legend - offset_value
            self:updateMsg("next_btn")
        end)
    end
end

--打开书
function M:openBook()
    self.book_Img.gameObject:SetActive(false)
    self.openBook_Img.gameObject:SetActive(true)
    self:setFirstLengen(true)
    self:setSpine()
    self:setName()
end

--获取hero Spine
function M:setSpine()
    local spine_name = self.m_model.m_hero_data.hero_spine or "hero_0115_SkeletonData"
    local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img,"RoleSpine/" .. spine_name,"idle", 0,true)
end

--设置人物名称
function M:setName()
    local name = Language:getTextByKey(self.m_model.m_hero_data.name)
    local class = Language:getTextByKey(self.m_model.m_hero_data.class)
    self:setTextByLanKey("hero_name_text",name.."·" ..class)
end

--设置人物生平
function M:setLft()
    return self.m_model.m_hero_data.life
end

--设置人物传记
function M:setLegent(id)
    local legend_id = self.m_model.hero_legend_tab[id]
    local legend_data = self.m_model:getLegendCfg(legend_id)
    if legend_data then
        return legend_data.legend_des,legend_data.legend_name
    end
    return self.m_model.m_hero_data.legend[id] or "", ""
end

--设置人物传记
function M:checkNextLegent(id)
    local legend_id = self.m_model.all_legend_tab[id]
    local legend_data = self.m_model:getLegendCfg(legend_id)
    if legend_data then
        return legend_data.legend_des,legend_data.legend_name
    end
    return self.m_model.m_hero_data.legend[id] or "", ""
end

function M:setPaperSpine(is_next, callback)
    self:setObjectVisible("paper_obj", false)
    local play_img = self:findGameObject("book_spine")
    local anim = play_img:GetComponent("SkeletonGraphic")
    anim:Initialize(true)
    if is_next == true then
        anim.AnimationState:SetAnimation(0,"1", false)
    else
        anim.AnimationState:SetAnimation(0,"2", false)    
    end
    self:addSpineComplete(anim.AnimationState,callback)
    if self.m_legent > 0 then
        self:setFirstLengen(false)
    else
        self:setFirstLengen(true)    
    end
end

--刷新
function M:refreshUI()
    self:setObjectVisible("paper_obj", true)
    --设置滑动条位置
    self.Content_list = self.m_luaBehaviour:FindRectTransform("Content_list")
    local vec2 = self.Content_list.transform.anchoredPosition
    vec2.y = 0;
    self.Content_list.transform.anchoredPosition = vec2
    
    local lengent_text = 0
    local lengent_title = "new_str_0578"
    if self.m_legent == 0 then --角色故事
        lengent_text = self:setLft()
        lengent_title = "new_str_0578"
        self:setTextByLanKey("content_text",lengent_text)
        self:setTextByLanKey("title_text","new_str_0578")
    else --传记
        -- lengent_text = self:setLegent(self.m_legent)
        -- lengent_title = "anecdote_"..self.m_legent + 1
        self:updateLegend()
    end
  
    --设置上一页
    if self.m_legent == 0 then
        self.last_btn.gameObject:SetActive(false)
    else
        self.last_btn.gameObject:SetActive(true)
    end
    --设置下一页文字
    if self.m_legent == self.m_model.m_max_legend then
        self:setTextByLanKey("next_text","new_str_0775")
    else
        self:setTextByLanKey("next_text","new_str_0776")
    end
end

--设置传记内容
function M:updateLegend()
    local left_index = (self.m_legent*2)-1
    local left_text,left_title = self:setLegent(left_index)
    local right_text,right_title = self:setLegent(left_index+1)
    self:setTextByLanKey("left_title_text", left_title)
    self:setTextByLanKey("left_content_text", left_text)
    self:setTextByLanKey("title_text", right_title)
    self:setTextByLanKey("content_text", right_text)
    if self.m_legent >= self.m_model.m_max_legend and next(self.m_model.hero_legend_tab) ~= nil then
        local left_obj = self.m_model.hero_legend_tab[left_index]
        local right_obj = self.m_model.hero_legend_tab[left_index+1]
        if left_obj == nil then
            local lock_obj = self:setObjectVisible("left_lock_Img", true)
            local left_text,left_title = self:checkNextLegent(left_index)
            self:setTextByLanKey("left_title_text", left_title)
            -- self:setTextByLanKey("left_content_text", left_text)
            self:updateSetLockDes(lock_obj)
        elseif right_obj == nil then
            local right_text,right_title = self:checkNextLegent(left_index+1)
            local lock_obj = self:setObjectVisible("lock_Img", true)
            self:setTextByLanKey("title_text", right_title)
            -- self:setTextByLanKey("content_text", right_text)
            self:updateSetLockDes(lock_obj)
        else
            self:setObjectVisible("left_lock_Img", false)
            self:setObjectVisible("lock_Img", false)
        end
    else
        self:setObjectVisible("left_lock_Img", false)
        self:setObjectVisible("lock_Img", false) 
    end
end

function M:updateSetLockDes(obj)
    UIUtil.setTextByLanKey(obj.transform, "hero_promote_text", "hero_ui_str_0046")
    local cur_season = UserDataManager:getCurSeason() -- 当前赛季
    if self.m_model.next_lv > 0 then
        UIUtil.setObjectVisible(obj.transform, cur_season > 1, "hero_promote_text")
        UIUtil.setObjectVisible(obj.transform, cur_season > 1, "hero_Grade_text")
        UIUtil.setObjectVisible(obj.transform, cur_season > 1, "locak_text")
        UIUtil.setObjectVisible(obj.transform, cur_season > 1, "lock_Img_bg")
    else
        UIUtil.setObjectVisible(obj.transform, false, "hero_promote_text")
        UIUtil.setObjectVisible(obj.transform, false, "hero_Grade_text")
        UIUtil.setObjectVisible(obj.transform, false, "locak_text")
        UIUtil.setObjectVisible(obj.transform, false, "lock_Img_bg")
    end
    UIUtil.setTextByLanKey(obj.transform, "hero_Grade_text", self.m_model.next_lv..Language:getTextByKey("new_str_0428"))
end

--设置页码
function M:setLengentNum(identification)
    local function CallBackRef()
        self:refreshUI()
    end
    if identification == "next" then
        if self.m_legent < self.m_model.m_max_legend then
            self.m_legent = self.m_legent+1
            self:setPaperSpine(true,CallBackRef)
        end
    elseif identification == "last" then
        if self.m_legent > 0 then
            self.m_legent = self.m_legent-1
            self:setPaperSpine(false,CallBackRef)
        end
    end
end

--展示首页
function M:setFirstLengen(bl)
    self:setObjectVisible("spine_bg_Img", bl == true)
    self:setObjectVisible("hero_name_Img", bl == true)
    self:setObjectVisible("hero_name_text", bl == true)
    self:setObjectVisible("left_obj", bl == false)
end

return M