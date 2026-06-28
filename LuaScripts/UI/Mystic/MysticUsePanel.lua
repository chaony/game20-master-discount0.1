--- 英雄
local M = class("MysticUsePanel",LikeOO.OOUIbase)

M.m_uiName = "Mystic/MysticUsePanel"
local mystic_bg = {"ui_lan", "ui_zi", "ui_jin", "ui_hong", "ui_cai", "ui_cai", "ui_cai", "ui_cai", "ui_cai", "ui_cai"}
local mystic_type = {"mystic_str_0024", "mystic_str_0025", "mystic_str_0026", "mystic_str_0027", "mystic_str_0028"}
function M:onCreate()
    self.m_attr_panel = {}
    self.m_attrs_list = {}
    for i=1,2 do
        self.m_attr_panel[i] = self:findGameObject("attr_panel_" .. i)
    end
    self.m_mystic = {}
    for i=1,5 do
        local item = self:findGameObject("item_" .. i)
        self.m_mystic[i] = item
        local luaBehaviour = UIUtil.findLuaBehaviour(item)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,  "bg_text_1", mystic_type[i])
    end
    --local UI_MysticUsePanel_SetTing01 = self:findGameObject("UI_MysticUsePanel_SetTing01")
    --self:setParticleRenderOrder(UI_MysticUsePanel_SetTing01)
end

function M:onEnter()  
    self:refreshUI()
end

function M:refreshUI()
    for i,v in ipairs(self.m_mystic) do
        local oid = self.m_model.m_data.mystic_slots[tostring(i-1)]

        if oid then
            local mystic_data = UserDataManager.mystic_data:getMysticDataById(oid)
            local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, mystic_data.id, mystic_data.evo, oid = oid})
            self:updateBooksByData(v, data, i)
            if self.m_model.use_anim_slot == i then
                self.m_model.use_anim_slot = nil
                local slot_anim = ResourceUtil:GetUIEffectItem("Mystic/UI_MysticUsePanel_ChuFa_001", v)
                --slot_anim.transform:SetParent(v.transform, false)
                self:setParticleRenderOrder(slot_anim)
            end
        else    
            self:updateBooksNoData(v, i)
        end
    end
    self:updateAttrsList()
end

function M:updateAttrsList()
    for i,v in ipairs(self.m_attr_panel) do
        local data = self.m_model.m_group_effect[i]
        if data then
            v:SetActive(true)
            local mystic_buff = ConfigManager:getCfgByName("mystic_buff")
            local lv_cfg = mystic_buff[data[2]][3]
            self:setTextByLanKey("attr_title_text_" .. i, lv_cfg.name)
            self:setTextByLanKey("attr_des_" .. i, lv_cfg.dse)
        else
            v:SetActive(false)
        end
    end
end

function M:updateBooksByData(object, data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    luaBehaviour:InjectionFunc()
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

    red_point_img:SetActive(false)
    have_panel:SetActive(true)
    no_panel:SetActive(false)
    up_image:SetActive(false)
    ex_we_bg:SetActive(false)
    lock_image:SetActive(false)
    duigoudi_img:SetActive(false)
    title_node:SetActive(false)
    stars:SetActive(false)
    tips_img:SetActive(false)
    lv_bg_img:SetActive(false)
    count_text_bg_img:SetActive(data.data_num > 1)
    count_text.gameObject:SetActive(data.data_num > 1)
    
    local frame_name = GlobalConfig.QUALITY_MYSTIC_SETTING[data.quality]
    LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame_name.frame_name, "equip_icon")

    local stars = luaBehaviour:FindGameObject("stars")
    -- 显示升级等级
    local lv = data.quality - 5 or 0
    if lv > 0 then
        stars:SetActive(true)
        for i = 1, 5 do
            local star = luaBehaviour:FindGameObject("star_" .. i)
            if star then
                star:SetActive(i <= lv)
            end
        end
    end

    local function clickCallback()
        self:updateMsg("grid_click", index)
    end
    UIUtil.setButtonClick(object,clickCallback)
end

function M:updateBooksNoData(object, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local have_panel = luaBehaviour:FindGameObject("have_panel")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
    have_panel:SetActive(false)
    no_panel:SetActive(true)
    local function clickCallback()
        self:updateMsg("grid_click", index)
    end
    UIUtil.setButtonClick(object,clickCallback)
    LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", "a_ui_currency_dj_hui", "equip_icon")
    local stars = luaBehaviour:FindGameObject("stars")
    stars:SetActive(false)
end

return M