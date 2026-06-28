local M = class("NoticePopView",LikeOO.OOPopBase)

M.m_uiName = "Notice/NoticePop"
M.m_size_type = 2

local mark_img = {"a_gg_zuixin", "a_gg_remen"}
function M:onEnter()
	self.rewards_image = self:findGameObject("rewards_image")

	self.detail_panel = self:findGameObject("detail_panel")
	self:setTextByLanKey("common_title_text", "notice_str_0001")
	self.detail_title_text = self:findGameObject("detail_title_text")
	self.des_text = self:findGameObject("des_text")
	self.text_scroll = self:findGameObject("text_scroll")

	--self:setObjectVisible("send_text", false)
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
	self:refreshDetailUI()
end

function M:updateListScroll()
	local data = self.m_model.m_notice
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
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
				self:updateMsg("click_cell", index)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data,true)
	end
end

function M:listHandle(obj,id)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
	local title_text = luaBehaviour:FindText("title_text")
	local select_img = luaBehaviour:FindGameObject("select_img")
	local mark_image = luaBehaviour:FindGameObject("mark_image")

	select_img:SetActive(id == self.m_model.m_select_index)
	if id == self.m_model.m_select_index then
		LuaBehaviourUtil.setTextColor(luaBehaviour, "title_text", GlobalConfig.COMMON_COLLOR.COMMON_1)
	else
		LuaBehaviourUtil.setTextColor(luaBehaviour, "title_text", GlobalConfig.COMMON_COLLOR.COMMON_9)
	end
	local data = self.m_model:getNoticeByIndex(id)
	title_text.text = Language:getTextByKey(data.name)
	if mark_img[data.mark] then
		mark_image:SetActive(true)
		GameUtil:setLanImgText(luaBehaviour:FindRectTransform("mark_image"), mark_img[data.mark])
	else
		mark_image:SetActive(false)
	end
end

function M:refreshDetailUI()
	Logger.log(self.m_model.m_select_index,"m_select_index ===")
	local notice = self.m_model:getNoticeByIndex(self.m_model.m_select_index)
	if notice then
		if notice.url and notice.url ~= "" then
			self:setObjectVisible("url_btn", true)
		else
			self:setObjectVisible("url_btn", false)
		end
		self:setText("detail_title_text", notice.title or "")
		self:setText("des_text", notice.des or "")
		self.detail_title_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical();
		self.des_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical();
	else
		self:setObjectVisible("url_btn", false)
		self:setTextByLanKey("detail_title_text", "notice_str_0002")
		self.detail_title_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical();
		self:setTextByLanKey("des_text", "notice_str_0003")
		self.des_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical();
	end
	self.des_text.transform.parent:GetComponent('ContentSizeFitter'):SetLayoutVertical();
end

return M