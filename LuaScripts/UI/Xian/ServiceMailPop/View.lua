local M = class("ServiceMailPopView",LikeOO.OOPopBase)

M.m_uiName = "Xian/ServiceMailPop"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:create()
    M.super.create(self)
end

function M:onEnter()
    self:setTextByLanKey("common_no_have_text", "qh_str_0013")
    self:refreshUI()
end

function M:refreshUI()
    self:updateListScroll()
    self:showRightCount()
end


function M:updateListScroll()
    local data = self.m_model.m_code_list_data
    if #data == 0 then
        self:setObjectVisible("CommonTipsNode", true)
    else
        self:setObjectVisible("CommonTipsNode", false)    
    end
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:listHandle(cell_object, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select", index)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,false)
        if self.m_control.m_mail_load == true then
            self:pullRefreshListOffset()
        end
    end
end

function M:listHandle(obj,id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
    local mail_data = self.m_model:getMailData(id)
    if luaBehaviour and mail_data then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_name", mail_data.data.title)
        local reward_content = luaBehaviour:FindGameObject("reward_content")
        UIUtil.destroyAllChild(reward_content.transform)
        local red_point_img = luaBehaviour:FindGameObject("red_point_img")
        red_point_img:SetActive(mail_data.data.status ~= 2)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img", self.m_model.m_select_index == id)
    end
end

function M:showRightCount()
    local data = self.m_model.m_code_list_data
    if #data == 0 then
        self:setObjectVisible("right_count",false)
        self:setObjectVisible("hero_show_img",false)
        return
    end
    self:setObjectVisible("right_count",true)
    self:setObjectVisible("hero_show_img",true)
    local cur_data = self.m_model:getMailData(self.m_model.m_select_index)
    if cur_data then
        local time = cur_data.data.expire_ts - UserDataManager:getServerTime()
        local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)
        local str_tim = GameUtil:formatTimeBySecond(time)
        -- if day > 0 then
        --     self:setTextByLanKey("title_mail_time", string.format(Language:getTextByKey("mail_str_0002"),day))
        -- elseif hour > 0 then
        --     self:setTextByLanKey("title_mail_time", string.format(Language:getTextByKey("mail_str_0003"),hour))
        -- elseif min > 0 then
        --     self:setTextByLanKey("title_mail_time", string.format(Language:getTextByKey("mail_str_0004"),min))
        -- else
        --     self:setTextByLanKey("title_mail_time", Language:getTextByKey("mail_str_0005"))
        -- end
        self:setTextByLanKey("cdk_num", "xian_str_0007", cur_data.data.code)
        self:setTextByLanKey("title_mail_text", cur_data.data.title)
        self:setTextByLanKey("des_text", cur_data.data.content)
        self:setTextByLanKey("title_mail_time", "xian_str_0008", str_tim)
    end

end

return M