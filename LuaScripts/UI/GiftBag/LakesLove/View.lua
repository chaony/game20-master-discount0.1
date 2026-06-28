--==================================
-- file:  View.lua
-- brief:  江湖情缘
--==================================
local M = class("LakesLoveView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/LakesLove"
M.m_size_type = 1

function M:onEnter()
    self:setTextByLanKey("close_title_text", UserDataManager.m_activity_name)
    --self:setTextByLanKey("close_title_text", self.m_model.m_title_name)
    self:setTextByLanKey("hint_text", "lakes_love_text_003")
    self:setTextByLanKey("confirm_btn_text", "new_str_0006")
	self:refreshUI()
end

function M:refreshUI()
    if self.m_model.m_hero_id <= 0 then
        self:updateHeroScroll()
    else
        self:refreshHero(self.m_model.m_hero_id)
        self:refreshConds()
    end
    local text = Language:getTextByKey("new_str_0919") .. GameUtil:formatTimeBySecond(self.m_model.m_end_ts - UserDataManager:getServerTime())
    self:setTextByLanKey("time_text", text)
end


--右侧侠客列表
function M:updateHeroScroll()
    local data = self.m_model:getHeroes()
    self.m_select_index = 1
    self.select_cell_obj = nil
    if self.m_hero_scroll == nil then
        local list_scroll = self:findGameObject("hero_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = list_scroll,
            init_cell = function(index, cell_object)
                local function callback()
                    local itemNode = ResourceUtil:LoadUIGameObject("Main/MainHeroNodeCell", Vector3.zero, nil)
                    local canvas_group = itemNode:GetComponent("CanvasGroup")
                    canvas_group.blocksRaycasts = false
                    itemNode.name = "cell_content"
                    itemNode.transform:SetParent(cell_object.transform, false)
                    self:listHandle(itemNode, index)
                    itemNode:SetActive(true)
                end
                if index <= 6 then
                    self.m_control:setOnceTimer(index <= 6 and  (0.033 * index) or 0, callback)
                else
                    callback()
                end
            end,
            update_cell = function(index, cell_object, cell_data)
                local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
                if content_tran then
                    content_tran.gameObject:SetActive(true)
                    self:listHandle(content_tran.gameObject, index)
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
                if content_tran then
                    if index ~= self.m_select_index then
                        if not IsNull(self.select_cell_obj) then
                            local LuaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
                            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",false)
                        end
                        self.m_select_index = index
                        self.select_cell_obj = content_tran
                        local LuaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",true)
                        --local hero_id = self.m_model:getHeroIDByIndex(index)
                        self:updateMsg("select_hero", cell_data)
                    end
                end
            end,
        }
        self.m_hero_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_hero_scroll:reloadData(data, true)
    end

    --默认选择第一个侠客
    self:updateMsg("select_hero", data[1])

    --tween
    self:setObjectVisible("right_hero", true)
    self:setObjectVisible("conds", false)
    --local width = GlobalConfig.UI_DESIGN_WIDTH
    --[[
    local right_hero = self:findGameObject("right_hero")
    local hero_spine = self:findGameObject("hero_spine")
    local pos = right_hero.transform.localPosition
    UIUtil.setLocalPosition(right_hero.transform, pos.x + 400,nil)
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(right_hero.transform:DOLocalMoveX(pos.x, 0.3))
    sequence:Append(DOTweenModuleUI.DOFade(hero_spine, 1.0, 0.3))
    --sequence:Insert(0, DOTweenModuleUI.DOFade(hero_spine, 0, 0.5))
    sequence:OnComplete(function ()
    end)
    --sequence:Append(transform:DOLocalMoveX(pos.x + GlobalConfig.UI_DESIGN_WIDTH, 0.15))
    sequence:SetAutoKill(true)
    ]]--
end

--单个侠客
function M:listHandle(obj, index)
    --Logger.logWarning(hero_id, "hero_id :")
    local data = self.m_model:getHeroes()
    if index > #data then
        return
    end
    local hero_id = data[index]
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
    GameUtil:updateHeroContentByData(obj, nil, cfg)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lv_text", false) --隐藏等级
        if index == self.m_select_index then
            self.select_cell_obj = obj
            --self.check_cell_obj = obj
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",true)
        else
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",false)
        end
        --LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigou_img",hero_id == self.m_model.m_hero_id)
    end
end

function M:refreshHero(hero_id)
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
    local skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({skin = cfg.skin[1]}, cfg)
    local spine_name = skin_cfg.hero_spine or "hero_0001_SkeletonData"
    self:setObjectVisible("hero_spine", true)
    local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
    --evo
    self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,cfg.max_evo), "common_ui","hero_evo")
    --name
    local class_str = Language:getTextByKey(cfg.class)
    local name_str = Language:getTextByKey(skin_cfg.name)
    self:setTextByLanKey("hero_name", name_str)
    self:setTextByLanKey("hero_name2", class_str)
    --race
    local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].big_race_icon
    self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
    --info
    self:setTextByLanKey("hero_tips_text", cfg.type_des03)
    --skill
    local skills = cfg.skill or {}
    for i = 1,4 do
        self:setObjectVisible("di_"..i, false)
    end
    for k,v in pairs(skills) do
        if k <= 4 then
            self:setObjectVisible("di_"..k, true)
            local str_name = "skill"..k.."_img"
            local show_text = "skill_"..k.."_text"
            local cur_skill = GameUtil:getSkill(v[1][1])
            self:setTextByLanKey(show_text, cur_skill.show_type)
            self:setImg(cur_skill.icon, "skill_icon", str_name)
        end
    end
end

function M:refreshConds()
    self:setObjectVisible("right_hero", false)
    self:setObjectVisible("conds", true)
    local screen_rect = self:findGameObject("screen_rect")
    local bg_width = screen_rect.transform.rect.width
    local bg_height = screen_rect.transform.rect.height
    local conds = self.m_model.m_cond_cfg
    local i = 1
    for k, v in pairs(conds) do
        --根据屏幕设置蒙版宽高
        local width = bg_width / 2
        local height = bg_height / 2
        local cond_obj = self:findGameObject("cond" .. i)
        UIUtil:setLocalDelta(cond_obj.transform, width, height)
        local data = self.m_model.m_conds[tostring(k)]
        if data ~= nil then
            if data.status == 2 then
                self:setObjectVisible("cond" .. i, false)
            elseif data.status == 1 then
                self:setObjectVisible("cond" .. i, true)
                self:setObjectVisible("name_text" .. i, false)
                self:setObjectVisible("goto_btn" .. i, false)
                self:setObjectVisible("unlock_btn" .. i, data.value >= v.target_value)
                self:setTextByLanKey("unlock_btn_text" .. i, "lakes_love_text_004")
            elseif data.status == 0 then
                self:setObjectVisible("cond" .. i, true)
                self:setObjectVisible("name_text" .. i, true)
                if v.target_type == 1 then --通关类型
                    self:setTextByLanKey("name_text" .. i, Language:getTextByKey(v.cond_name) .. "\n" .. Language:getTextByKey("lakes_love_text_001", 0, 1))
                else
                    self:setTextByLanKey("name_text" .. i, Language:getTextByKey(v.cond_name) .. "\n" .. Language:getTextByKey("lakes_love_text_001", data.value, v.target_value))
                end
                self:setObjectVisible("goto_btn" .. i, v.go_type ~= nil and #v.go_type > 0 and data.value < v.target_value)
                self:setTextByLanKey("goto_btn_text" .. i, "lakes_love_text_002")
                self:setObjectVisible("unlock_btn" .. i, false)
            end
        else
            self:setObjectVisible("cond" .. i, false)
        end
        i = i + 1
    end
end

function M:refreshCond(cond_id)
    local conds = self.m_model.m_cond_cfg
    local i = 1
    for k, v in pairs(conds) do
        if cond_id == k then
            self:playUnlock(i)
            self.m_control:setOnceTimer(0.5, function ()
                self:setObjectVisible("cond" .. i, false)
            end)
            --self:setObjectVisible("cond" .. i, false)
            break
        end
        i = i + 1
    end
end

--解锁特效
function M:playUnlock(index)
    --self:setObjectVisible("cond_unlock_effect" .. index, false)
    self:setObjectVisible("unlock_effect" .. index, true)
end

--确认侠客
function M:confirmHero()
    self:setObjectVisible("right_hero", false)
    self:refreshConds()
end

function M:destroy()
    M.super.destroy(self)
end

return M