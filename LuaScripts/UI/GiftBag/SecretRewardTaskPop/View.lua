local M = class("SecretRewardTaskPopView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/GiftScrollTaskPop"
M.m_size_type = 2

function M:onEnter()
    RedPointUtil:setSecretActiveShopRedPoint()
    self.m_gray_img = self:findImage("gray_img")
	self:refreshUI()
    self:setTextByLanKey("common_title_text", "new_str_0554")
    self:setTextByLanKey("get_all_btn_text", "mail_str_0017")
    self.m_control:setOnceTimer(0.5, function ()
        self:setObjectVisible("get_all_btn", true)
    end)
end

function M:refreshUI()
    self:createLoopScroll()
    if self.m_scroll_view ~= nil then
        self.m_scroll_view:moveToCellIndex(1)
    end
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_recruit_tab()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateItem(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "ok_btn" then
                    if cell_data.shop_type == true then
                        self:updateMsg("buy_scroll")
                    else
                        local cfg = cell_data.cfg
                        local task_data = self.m_model:getTaskData(cell_data.id)
                        if task_data.status == 0 then
                            self:updateMsg("go_to", cfg.go_type)
                        elseif task_data.status == 1 then
                            self:updateMsg("get_reward_btn", cell_data.id)
                        end
                    end
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateItem(index, obj, cell_data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        if cell_data.shop_type == true then
            self:updateShipData(obj, cell_data)
        else
            self:updateTaskData(obj, cell_data)
        end
    end
end

function M:updateShipData(obj,cell_data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    LuaBehaviourUtil.setImg(LuaBehaviour, "ok_btn", "a_ui_currency_btn_small_2", "common_ui")
    local btn_img = LuaBehaviour:FindImage("ok_btn")
    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "ling_num_text", "gf_str_0050", (cell_data.cfg.time-self.m_model.m_buy_times))
    local parent = LuaBehaviour:FindGameObject("itemParent")
    UIUtil.destroyAllChild(parent.transform)
    local itemNode = GameUtil:createItemElement(cell_data.cfg.reward[1], true, true)
    itemNode.transform:SetParent(parent.transform, false)
    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "desc_text", cell_data.cfg.name)
    LuaBehaviourUtil.setSliderValue(LuaBehaviour, "slider_img", 1)
    if self.m_model.m_buy_times >= cell_data.cfg.time then
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "get_text", "gf_str_0048")
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "get_text", true)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "ok_btn", false)
        LuaBehaviourUtil.setSliderValue(LuaBehaviour, "slider_img", 1)
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "slider_num", "new_str_0470")
    else
        local price_data = RewardUtil:getProcessRewardData(cell_data.cfg.price[1])
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "slider_num", "")
        LuaBehaviourUtil.setSliderValue(LuaBehaviour, "slider_img", 0)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "get_text", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "ok_btn", true)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "btn_text", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "buy_num_text", true)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "buy_icon", true)
        LuaBehaviourUtil.setImg(LuaBehaviour, "buy_icon", price_data.icon_name, price_data.atlas_name)
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "buy_num_text", price_data.data_num)
        btn_img.material = nil
    end
end

function M:updateTaskData(obj,cell_data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    local cfg = cell_data.cfg
    local task_data = self.m_model:getTaskData(cell_data.id)
    local parent = LuaBehaviour:FindGameObject("itemParent")
    UIUtil.destroyAllChild(parent.transform)
    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "desc_text", cfg.name)
    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "buy_num_text", false)
    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "buy_icon", false)
    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "btn_text", true)
    local btn_img = LuaBehaviour:FindImage("ok_btn")
    local ling_str = (cfg.time - task_data.times)
    if cfg.type == 1 then
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "ling_num_text", "gf_str_0053", ling_str)
    else
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "ling_num_text", "gf_str_0043", ling_str)
    end
    local itemNode = GameUtil:createItemElement(cfg.reward[1], true, true)
    itemNode.transform:SetParent(parent.transform, false)
    local show_rate = ""
    if task_data.value >= cfg.target_value then
        show_rate = cfg.target_value.."/"..cfg.target_value
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "slider_num", "new_str_0470")
    else
        show_rate = task_data.value.."/"..cfg.target_value
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "slider_num", show_rate)
    end
    local rate = (task_data.value/cfg.target_value)
    LuaBehaviourUtil.setSliderValue(LuaBehaviour, "slider_img", rate)
    if task_data.status == 0 then 
        btn_img.material = nil
        LuaBehaviourUtil.setImg(LuaBehaviour, "ok_btn", "a_ui_currency_btn_small_3", "common_ui")
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "btn_text", "new_str_0029")
    elseif task_data.status == 1 then
        btn_img.material = nil
        LuaBehaviourUtil.setImg(LuaBehaviour, "ok_btn", "a_ui_currency_btn_small_2", "common_ui")
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "btn_text", "new_str_0056")
    elseif task_data.status == 2 then
        btn_img.material = self.m_gray_img.material
        LuaBehaviourUtil.setImg(LuaBehaviour, "ok_btn", "a_ui_currency_btn_small_3", "common_ui")
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "btn_text", "new_str_0080")
    end
    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "ok_btn", true)
end

function M:destroy()
    M.super.destroy(self)
end

return M