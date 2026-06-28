local M = class("StarDetailsView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "DestinyStar/StarDetails"



function M:onEnter()
    self.hui_material = self:findImage("hui").material
    self:setTextByLanKey("life_title_text","destinyStar_text_0006")
    self:setTextByLanKey("defense_title_text","destinyStar_text_0007")
    self:setTextByLanKey("attack_title_text","destinyStar_text_0008")
    self:updateLoopScroll()
    self:setBadge()
    self:setStarDes()
    self:setAddition()
end

--创建列表
function M:updateLoopScroll()
    local data = self.m_model:getHeroData()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            pos_center = true,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, false, nil, nil, true)
    end
end


function M:updateScrollViewCell(index,cell_object,cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local transform = cell_object.transform

    --英雄展示
    local is_activation = self.m_model:getIsActivation(cell_data.id)
    local spine_staue = is_activation and "idle" or "pose"
    local spine_material = not is_activation and self.hui_material or nil
    local guard_bg = luaBehaviour:FindImage("guard_bg")
    local hero_bg = luaBehaviour:FindGameObject("hero")
    local hero_spine = hero_bg:GetComponent("SkeletonGraphic")
    local hero_spine_name = cell_data.hero_spine
    GameUtil:updateSpineLoadSet(hero_bg,"RoleSpine/" .. hero_spine_name,spine_staue, 0,true)
    --设置背景和英雄spine显示状态
    guard_bg.material = spine_material
    hero_spine.material = spine_material
    --种族显示
    local race_img = "a_fyb_icon_jin"
    if cell_data.race == 1 then --金
        race_img = "a_fyb_icon_jin"
    elseif cell_data.race == 2 then --火
        race_img = "a_ljsz_huoshili"
    elseif cell_data.race == 3 then  --木
         race_img = "a_ljsz_mushili"
    elseif cell_data.race == 4 then  --水
        race_img = "a_ljsz_shuishili"
    elseif cell_data.race == 5 then  --阳
        race_img = "a_ljsz_yangshili"
    elseif cell_data.race == 6 then  --阴
        race_img = "a_ljsz_yinshili"
    end
    LuaBehaviourUtil.setImg(luaBehaviour,"power_img",race_img,  "arena_ui")
    
end

--设置星辰描述
function M:setStarDes()
    local star_des = self.m_model.m_star_data.cfg.star_des
    local star_des_text = Language:getTextByKey(star_des)
    local star_des_text_list = string.split(star_des_text,"/n")
    self:setTextByLanKey("left_zi",star_des_text_list[1]) 
    self:setTextByLanKey("right_zi",star_des_text_list[2]) 
end

--设置徽章显示
function M:setBadge()
    local badge_name = "a_tmhx_icon_jumen"
    if self.m_model.m_star_data ~= nil and self.m_model.m_star_data.cfg ~= nil and self.m_model.m_star_data.cfg.star_icon ~= nil then
        badge_name = self.m_model.m_star_data.cfg.star_icon
    end
    local Img_bg = self:findGameObject("start_name_img")
    GameUtil:updateResourcesImg(Img_bg,"Texture/zh_cn/tmhx_start/"..badge_name)
end

--设置加成
function M:setAddition()
    local hp_value,atk_value,def_value = self.m_model:setAdditionData()
    self:setTextByLanKey("life_value_text",hp_value.."%")
    self:setTextByLanKey("attack_value_text",atk_value.."%")
    self:setTextByLanKey("defense_value_text",def_value.."%")
end

return M