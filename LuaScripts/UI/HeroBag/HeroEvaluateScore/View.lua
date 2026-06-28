local M = class("HeroEvaluateScoreView",LikeOO.OOPopBase)

M.m_uiName = "HeroBag/HeroEvaluateScore"
M.m_size_type = 2


function M:onEnter()
  
    self:refreshUI()
end


function M:refreshUI()
    self:setTextByLanKey("common_title_text", "new_str_0678")
    self:setTextByLanKey("title_text", "new_str_0679")
    --self:clickCallback("star_1")
end

function M:clickCallback(obj_name)
    local tab = string.split(obj_name, "_")
    local num = tonumber(tab[2])

    if num < self.m_model.m_num then
        for i=num+1,self.m_model.m_num do
            local obj = self:findGameObject(tab[1].."_"..i)
            local luaBehaviour = UIUtil.findLuaBehaviour(obj)
            local star_img = luaBehaviour:FindGameObject("star_img")
            star_img:SetActive(false)
            self.m_model.m_num = num

        end
    elseif num > self.m_model.m_num then
        audio:SendEvtUI("UI_XK_Star")
        for i=self.m_model.m_num+1,num do
            local obj = self:findGameObject(tab[1].."_"..i)
            local luaBehaviour = UIUtil.findLuaBehaviour(obj)
            local star_img = luaBehaviour:FindGameObject("star_img")
            star_img:SetActive(true)
            self.m_model.m_num = num

        end
    end
    
    
    
   
    
    
   
    
end


return M