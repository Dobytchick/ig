netstream.Hook("givemyitem",function(client,mode,otherclient,item,ccount)
    if !isnumber(mode) then return false end
    if !client:IsAdmin() then return false end
    if mode == 1 then
        client:getChar():getInv():add(item)
    end
    if mode == 2 && otherclient != nil then
        for i=1,ccount do
            otherclient:getChar():getInv():add(item)
        end
    end
end)
