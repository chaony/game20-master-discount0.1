local M = class("ServiceMailDetailsPopView",LikeOO.OOPopBase)

M.m_uiName = "Xian/ServiceMailDetailsPop"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:create()
    M.super.create(self)
end

function M:onEnter()
    self:setTextByLanKey("des_text", self.m_model.m_mail_data.data.content )
    self:setTextByLanKey("common_title_text", self.m_model.m_mail_data.data.title )
    self:updateRewardsScroll()
end

function M:updateRewardsScroll()
    local data = self.m_model.m_mail_data.data.gifts
    if data and #data > 0 then
        self:setObjectVisible("yes_btn", self.m_model.m_mail_data.data.status ~= 2)
        self:setObjectVisible("rewards_image", true)
    else
        self:setObjectVisible("yes_btn", false)   
        self:setObjectVisible("rewards_image", false) 
    end
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("rewards_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:listHandle(cell_object, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)

            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,true)
    end
end

function M:listHandle(obj, id)
	local data = self.m_model.m_rewards[id]
	-- UIUtil.setScale(obj.transform, 0.8)
	local item = GameUtil:updateItemElement(obj, data, true, true)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local tips_img = luaBehaviour:FindGameObject("tips_img")
    local tips_text = luaBehaviour:FindText("tips_text")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"duigoudi_img", self.m_model.m_mail_data.data.status == 2)
	-- Logger.log(self.m_model.m_params.is_received,"is_received ===")
	tips_img:SetActive(self.m_model.m_params.is_received)
	tips_text.text = ""
end


return M