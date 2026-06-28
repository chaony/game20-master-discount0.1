local M = class("SyncLoadBigLoadingView",LikeOO.OOPopBase)

M.m_uiName = "Loading/SyncLoadBigLoading"
M.m_normal = false
M.m_sortOrder = 10010
M.m_size_type = 2
M.m_sortOrderChange = false

function M:onEnter()
	self:setTextByLanKey("tips_text", "new_str_0445")
	self.progress_slider = self:findSlider("progress_slider")
	self.progress_speed_text = self:findText("progress_speed_text")
	self.m_spine_player = self:findGameObject("spine_1")
	self.m_spine_biao = self:findGameObject("spine_3")
	self.progress_speed_text.text = "0%"
	if SceneManager then
		local show_loading_black = SceneManager:getData("show_loading_black")
		self:setObjectVisible("black_image", show_loading_black == true)
		local show_loading_content = SceneManager:getData("show_loading_content")
		self:setObjectVisible("content_node", show_loading_content ~= false)
	else
		self:setObjectVisible("black_image", false)	
	end
	self:setObjectVisible("bg_root",self.m_model.isShowBg)
	self:refreshUI()

	local index = Mathf.Random(1,3)
	--local img_name = "bg_im" .. index
	--self:setObjectVisible(img_name,true)
	local bg_img = self:findImage("bg_img")
	GameUtil:updateResourcesImg(bg_img, "Texture/a_dl_bg" .. index)
end

function M:refreshUI()
	local preload_heros = self.m_model:getPreloadHeros()
	local preload_atlas = self.m_model:getPreloadAtlas()
	local max_num = #preload_heros + #preload_atlas
	if max_num > 0 and not GameVersionConfig.preload_res then
		self.progress_slider.gameObject:SetActive(true)
		self.progress_slider.value = 0
	else
		self.progress_slider.gameObject:SetActive(false)
		self.progress_speed_text.gameObject:SetActive(false)
		self:setTextByLanKey("tips_text", "tid#loadingtips_" .. math.random(1,8))
	end
end

function M:setProgressSlider(value, max_value)
	self.progress_slider.value = value / max_value;
	local speed_text = math.ceil(self.progress_slider.value * 100)
	self.progress_speed_text.text = speed_text.."%"
end

function M:destroy()
	SceneManager:setData("show_loading_content", true)
	M.super.destroy(self)
end

return M