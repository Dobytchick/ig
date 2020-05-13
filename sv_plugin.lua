netstream.Hook("givemyitem",function(client,mode,otherclient,item,quantity)
    print(client,mode,otherclient,item,quantity)
    if !isnumber(mode) then return false end
    if !client:IsAdmin() then return false end
    if mode == 1 then
        client:getChar():getInv():add(item,quantity or 1)
    end
    if mode == 2 && otherclient != nil then
        otherclient:getChar():getInv():add(item,quantity or 1)
    end
end)

netstream.Hook("CheckEmpty",function(client,otherclient)
    if client:IsAdmin() then
        if otherclient:getChar():getInv():findEmptySlot() != nil then
            netstream.Start(client,"cl_return",nil,true)
        else
            netstream.Start(client,"cl_return",nil,false)
        end
    end
end)
