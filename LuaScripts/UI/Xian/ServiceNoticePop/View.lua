local M = class("ServiceNoticePopView",LikeOO.OOPopBase)

M.m_uiName = "Xian/ServiceNoticePop"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:create()
    M.super.create(self)
end

function M:onEnter()
    self:setTextByLanKey("title_text", "xian_str_0017")
    self:setTextByLanKey("common_no_have_text", "qh_str_0012")
    self.m_parent = self:findGameObject("cont")
    UIUtil:registerDragEvent(self.content_node, handler(self,self.fingerSliding))
    self:refreshUI()
end

function M:fingerSliding(locat)
	if locat then
		self:updateMsg("Sliding_right")
	else
		self:updateMsg("Sliding_left")
	end
end

function M:refreshUI()
    if #self.m_model.m_notices_list_data == 0 then
        self:setObjectVisible("CommonTipsNode", true)
    else
        self:setObjectVisible("CommonTipsNode", false)    
    end
    if #self.m_model.m_notices_list_data > 0 then
        local data = self.m_model.m_notices_list_data[self.m_model.m_notice_index]
        local text = string.gsub(data.content,"\\n", "\n")
        local count_text = self:setTextByLanKey("count_text3", text)
        if data and data.status == 0 then
            self:updateMsg("red_notice", data.nid)
        end
    end
    self:setTextByLanKey("page_nums", self.m_model:showPageNum())
end


function M:creatItem(parent)
    local item = ResourceUtil:LoadUIGameObject("Xian/ServiceNoticeText", Vector3.zero, nil)
    item.transform:SetParent(parent.transform, false)
    return item
end

function M:redNext()
    if #self.m_model.m_notices_list_data > self.m_model.m_notice_index then
        self.m_model.m_notice_index = self.m_model.m_notice_index + 1
    end
    self:refreshUI()
end

return M