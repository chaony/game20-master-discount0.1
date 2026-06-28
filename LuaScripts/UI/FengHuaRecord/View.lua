local M = class("FengHuaRecordView",LikeOO.OOPopBase)

M.m_uiName = "FengHuaRecord/FengHuaRecord"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:onEnter()
    self.m_gray = self:findImage("tool_gray")
    local cfg = ConfigManager:getCfgByName("open_condition")
    local fenghua_record_cfg = cfg[372]
    self:setTextByLanKey("name_text", fenghua_record_cfg.name)
    self:refreshUI()
    local bottom = self:findGameObject("bottom")
    UIUtil.setLocalPosition(bottom.transform, nil,-400)
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(bottom.transform:DOLocalMoveY(-287.5, 0.3):SetEase(Tweening.Ease.OutSine))
    sequence:SetLoops(1)
end

function M:refreshUI()
    self:updateHeroScroll()
end

function M:updateHeroScroll()
    local data = self.m_model.select_skin_list
    if self.m_skin_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("skin_loop_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateSkinCell(cell_obj, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if cell_data ~= self.m_model.m_select_skin_id then
                    if not IsNull(self.select_cell_obj) then
                        local luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img",false)
                    end
                    self.select_cell_obj = cell_object
                    local luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img",true)
                    self:updateMsg(click_name,cell_data)
                end
            end
        }
        self.m_skin_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_skin_loop_scroll_view:reloadData(data)
    end
end

function M:updateSkinCell(obj, index, skin_id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour == nil then
        return
    end
    local cfg = self.m_model.fenghua_record_skin[skin_id]
    local hava_flag = self.m_model:getSkinHave(skin_id)
    if cfg then
        local hero_img = luaBehaviour:FindImage("hero_img")
        local bg_img = luaBehaviour:FindImage("bg_img")
        local bottom_img = luaBehaviour:FindImage("bottom_img")
        GameUtil:updateResourcesImg(hero_img, "Texture/HeroIcon/" .. cfg.icon)
        if hava_flag then
            bg_img.material = nil
            hero_img.material = nil
            bottom_img.material = nil
        else
            bg_img.material = self.m_gray.material
            hero_img.material = self.m_gray.material
            bottom_img.material = self.m_gray.material
        end
        if skin_id == self.m_model.m_cur_skin_id then
            self.select_cell_obj = obj
            self.check_cell_obj = obj
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img",true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img",false)
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_img",skin_id == self.m_model.m_cur_skin_id)
    end
end

function M:refreshSkinCheck()
    local luaBehaviour = UIUtil.findLuaBehaviour(self.check_cell_obj)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_img",false)
    luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_img",true)
    self.check_cell_obj = self.select_cell_obj
end

return M