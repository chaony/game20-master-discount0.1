local M = class("BeginPopView", LikeOO.OOPopBase)

M.m_uiName = "Pops/PopGameBegin"
M.m_size_type = 2
-- local url = data.main_url:gsub("https:", "http:")
-- local test = "lf3-fe-tos.dailygn.com/obj/g-marketing-act-assets/-1483643284.1626258771969.png"
-- local test = "https://lf3-fe-tos.dailygn.com/obj/g-marketing-act-assets/-1483643284.1626258771969.png"
-- local test2 = "https://lf3-fe-tos.dailygn.com/obj/g-marketing-act-assets/-731170636.1626258864492.png"

function M:onEnter()
    local data = self.m_model.m_params.pop_data

    local mainObj = self:findGameObject("main_pic")
    local btnObj = self:findGameObject("close_btn")

    local rstNum = 0
    local sucNum = 0

    local function test_show()
        if rstNum == 2 then
            if sucNum == 2 then
                local obj = self:findGameObject("CommonPopBg")
                obj:SetActive(true)

                local img1 = mainObj.transform:GetComponent("Image")
                img1.enabled = true

                local img2 = btnObj.transform:GetComponent("Image")
                img2.enabled = true
            else
                self:updateMsg(99999)
            end
        end
    end

    local webTextLoad = mainObj.transform:GetComponent("WebTextureLoader")
    webTextLoad:LoadWeb(
        data.main_url,
        10,
        function(rst)
            self:setObjectVisible("content_node", true)
            --main pic load end
            rstNum = rstNum + 1
            if rst then
                sucNum = sucNum + 1
            end
            test_show()
        end
    )

    local webTextLoad = btnObj.transform:GetComponent("WebTextureLoader")
    webTextLoad:LoadWeb(
        data.close_url,
        10,
        function(rst)
            self:setObjectVisible("content_node", true)
            --main pic load end
            rstNum = rstNum + 1

            if rst then
                sucNum = sucNum + 1
            end
            test_show()
        end
    )
end


return M
