---@class MysticReplacePopView:OOPopBase
---@field m_model MysticReplacePopModel
local M=class("MysticReplacePopView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "HeroInfo/MysticReplacePop"

function M:onEnter()
    self.mystic_data=self.m_model.m_params
    local eqp_cfg = UserDataManager.mystic_data:getMysticConfigByCid(self.mystic_data.id)
    --local mystic_go=self:findGameObject("mystic")
    self.mystic_data.lv=self.mystic_data.star or 0

    local cur_cfg=self.m_model:getMysticData()
    local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, tonumber(self.m_model.m_mystic_id), cur_cfg.quality})
    self:updateBooksByData(reward_data,cur_cfg) -- 秘籍icon

    --GameUtil:updateItemEquipInfo(mystic_go.transform, self.mystic_data)
    local type_meridian = GlobalConfig.TYPE_MERIDIAN[eqp_cfg.type]
    self:setImg( type_meridian.pro_icon,  ResourceUtil:getLanAtlas(),"camp_img2")
    local class_meridian = GlobalConfig.CLASS_MERIDIAN[eqp_cfg.role_type or 0] or 0
    if class_meridian == 0 then
        self:setObjectVisible("vocation_img",false)
    else
        self:setObjectVisible("vocation_img",true)
        self:setImg( class_meridian.pro_icon,  ResourceUtil:getLanAtlas(),"vocation_img")
    end

    self:setTextByLanKey("replacableNum_text","mystic_str_00119",self.mystic_data.equipedNum,self.mystic_data.canEquipMax)

    local loopscroll=self:findGameObject("list_scroll")
    local heros=self.m_model.m_params.heros
    if self.m_loop_scroll_view==nil  then
        local params={
            show_data=heros,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                local transform = cell_object.transform
                local heroGo=UIUtil.findTrans(transform,"hero").gameObject
                if luaBehaviour then
                    local oid=cell_data
                    local hero_data = UserDataManager.hero_data:getHeroDataById(oid)
                    local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 1, oid})
                    GameUtil:updateItemElementByData(heroGo, itemData)
                    --GameUtil:updateHeroStarsByQuality(cell_object, itemData.quality)
                    GameUtil:updateHeroInfo(heroGo, itemData)
                    LuaBehaviourUtil.setText(luaBehaviour,"name_text",itemData.name)
                    LuaBehaviourUtil.setText(luaBehaviour,"story_text",itemData.story)
                    --if index == self.m_model.currentHeroIndex then
                    --    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", true)
                    --else
                    --    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", false)
                    --end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "replace_btn" then
                    self.mystic_data.owner=cell_data
                    self:updateMsg("wear_equip", self.mystic_data,"HeroInfo.MeridianList")
                    self:updateMsg(99999)
                end
            end,
            ui_name = self.m_uiName
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(heros)
    end

end


function M:updateBooksByData( data, cfg, mystic_data)
    local object = self:findGameObject("mystic")
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", data.icon_name, data.atlas_name or "item_icon")
    local count_text = LuaBehaviourUtil.setText(luaBehaviour, "count_text", data.data_num)
    local title_node = luaBehaviour:FindGameObject("title_node")
    local title_text = luaBehaviour:FindText("title_text")
    local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
    local lv_text = luaBehaviour:FindGameObject("lv_text")
    local have_panel = luaBehaviour:FindGameObject("have_panel")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local lock_image = luaBehaviour:FindGameObject("lock_image")
    local stars = luaBehaviour:FindGameObject("stars")
    local tips_img = luaBehaviour:FindGameObject("tips_img")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local count_text_bg_img = luaBehaviour:FindGameObject("count_text_bg_img")
    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
    local ex_we_bg = luaBehaviour:FindGameObject("ex_we_bg")
    local ex_di_bg = luaBehaviour:FindGameObject("ex_di_bg")

    local type_meridian = GlobalConfig.TYPE_MERIDIAN[cfg.type]
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "type_name", type_meridian.short_name)
    LuaBehaviourUtil.setTextColor(luaBehaviour,"type_name",type_meridian.name_color)
    if mystic_data and mystic_data.wear and mystic_data.wear ~= "" then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"HeadNode",true)
        local cur_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByOid(mystic_data.wear)
        if cur_skin_cfg then
            LuaBehaviourUtil.setImg(luaBehaviour, "tx_img", cur_skin_cfg.icon, "hero_head_ui")
        end
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"HeadNode",false)
    end
    local atlas_name =  ResourceUtil:getLanAtlas()
    LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", type_meridian.pro_icon,  ResourceUtil:getLanAtlas())
    local class_meridian = GlobalConfig.CLASS_MERIDIAN[cfg.role_type or 0] or 0
    if class_meridian == 0 then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img",false)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img",true)
        LuaBehaviourUtil.setImg(luaBehaviour, "vocation_img", class_meridian.pro_icon,  ResourceUtil:getLanAtlas())
    end
    GameUtil:creatEffectForEquip(object, { quality = cfg.quality, data_type= RewardUtil.REWARD_TYPE_KEYS.MYSTIC})
    red_point_img:SetActive(false)
    have_panel:SetActive(true)
    no_panel:SetActive(false)
    up_image:SetActive(false)
    ex_we_bg:SetActive(false)
    lock_image:SetActive(false)
    duigoudi_img:SetActive(false)
    title_node:SetActive(false)
    tips_img:SetActive(false)
    lv_bg_img:SetActive(false)
    ex_di_bg:SetActive(false)
    stars:SetActive(false)
    count_text_bg_img:SetActive(false)
    count_text.gameObject:SetActive(false)
    local frame = GlobalConfig.QUALITY_COMMON_SETTING[data.quality]
    LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame.frame_name, "equip_icon")

end


function M:setHeroNode()

end

function M:destroy()
    M.super.destroy(self)
end

return M