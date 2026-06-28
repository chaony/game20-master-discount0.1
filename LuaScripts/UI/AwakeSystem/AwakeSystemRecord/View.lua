local M = class("AwakeSystemRecordView",LikeOO.OOPopBase)

M.m_uiName = "AwakeSystem/AwakeSystemRecord"
M.m_size_type = 2

local img_path = "Texture/main/"

function M:onEnter()
    self.m_page = self.m_model.m_home_page
    self.openBook_Img = self:findGameObject("biography_Img")
    self:setTextByLanKey("last_text","new_str_0906")
    self:setTextByLanKey("lock_text","rpg_scroll_9")
    self.last_btn = self:findGameObject("last_btn")
    self:setObjectVisible("left_lock_Img", false)
    self.left_scroll_obj = self:findGameObject("Left_Content_list")
    self.scroll_obj = self:findGameObject("Content_list")
    self:refreshUI()
end

function M:setPaperSpine(is_next, callback)
    self:setObjectVisible("paper_obj", false)
    self:setObjectVisible("Left_Content_list", false)
    self:setObjectVisible("Content_list", false)
    local lpos1 = self.left_scroll_obj.transform.localPosition
    local lpos2 = self.scroll_obj.transform.localPosition
    lpos1.y = 0
    lpos2.y = 0
    self.left_scroll_obj.transform.localPosition = lpos1
    self.scroll_obj.transform.localPosition = lpos2
    local play_img = self:findGameObject("book_spine")
    local anim = play_img:GetComponent("SkeletonGraphic")
    anim:Initialize(true)
    if is_next == true then
        anim.AnimationState:SetAnimation(0,"1", false)
    else
        anim.AnimationState:SetAnimation(0,"2", false)    
    end
    self:addSpineComplete(anim.AnimationState,callback)
end

--刷新
function M:refreshUI()
    self:setObjectVisible("paper_obj", true)
    self.Content_list = self.m_luaBehaviour:FindRectTransform("Content_list")
    local vec2 = self.Content_list.transform.anchoredPosition
    vec2.y = 0;
    self.Content_list.transform.anchoredPosition = vec2
    self:updateLegend()
    --设置上一页
    if self.m_page == self.m_model.m_home_page then
        self.last_btn.gameObject:SetActive(false)
    else
        self.last_btn.gameObject:SetActive(true)
    end
    --设置下一页文字
    if self.m_page == self.m_model.m_max_page then
        self:setTextByLanKey("next_text","new_str_0775")
    else
        self:setTextByLanKey("next_text","new_str_0776")
    end
end

function M:setPage(id)
    local cfg = self.m_model.m_awaken_book_cfg[id]
    local title = ""
    local img = ""
    if cfg then
        img = cfg.pic
        title = cfg.des
    end
    return title,img
end

--设置传记内容
function M:updateLegend()
    local left_index = self.m_page
    local next_id = self.m_model.m_awaken_book_cfg[left_index].next
    self:setObjectVisible("lock_Img", false)
    local right_text, right_img = self:setPage(next_id)
    local right_image_name = self:findImage("right_img")
    self:setTextByLanKey("content_text", right_text)
    local left_text, left_img = self:setPage(left_index)
    local left_image_name = self:findImage("left_img")
    self:setTextByLanKey("left_content_text", left_text)
    GameUtil:updateResourcesImg(left_image_name, img_path .. left_img)
    if self.m_page == self.m_model.m_max_page and self.rate == 1 then
        --最后一页 不设置第十页的图片，显示待期待
        self:setObjectVisible("lock_Img", true)
    else
        GameUtil:updateResourcesImg(right_image_name, img_path .. right_img)
    end
    self:setObjectVisible("Left_Content_list", true)
    self:setObjectVisible("Content_list", true)
end

--设置页码
function M:setLengentNum(identification)
    local function CallBackRef()
        self:refreshUI()
    end
    if identification == "next" then
        if self.m_page < self.m_model.m_max_page then
            self.m_page = self.m_model.m_awaken_book_cfg[self.m_page].next
            self.m_page = self.m_model.m_awaken_book_cfg[self.m_page].next
            self:setPaperSpine(true,CallBackRef)
        end
    elseif identification == "last" then
        if self.m_page > self.m_model.m_home_page then
            self.m_page = self.m_model.next_page[self.m_page]
            self.m_page = self.m_model.next_page[self.m_page]
            self:setPaperSpine(false,CallBackRef)
        end
    end
end

return M