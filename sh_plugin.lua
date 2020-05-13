PLUGIN.name = "Item Giver"
PLUGIN.desc = "Simple tool for admins"
PLUGIN.author = "Dobytchick"

netstream.Hook("cl_return",function(client,whatReturn)
    print(whatReturn)
    return whatReturn
end)

local function checkemptyslot(ent)
    if netstream.Start("CheckEmpty",ent) != false then
        return true
    else
        return false
    end
end

nut.util.include("sv_plugin.lua")

nut.command.add("ig_open", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
        netstream.Start(client,"open_ig_panel")
	end
})

netstream.Hook("open_ig_panel",function(client)
    if !LocalPlayer():IsAdmin() then return false end

    if IsValid(igframe) then
        igframe:Remove()
    end

    igframe = vgui.Create("DFrame")
    igframe:SetSize(ScrW()* 0.3, ScrH() * 0.7)
    igframe:MakePopup()
    igframe:Center()
    igframe:SetTitle("")

    itemlist = igframe:Add("DListView")
    itemlist:Dock(FILL)
    itemlist:SetMultiSelect( false )
    itemlist:AddColumn( "ITM" )
    itemlist:AddColumn( "CAT" )
    itemlist:AddColumn( "UID" )
    itemlist.OnRowSelected = function(l,i,p)
        item = p:GetColumnText(3)
        local dmenu = DermaMenu()

        local giveonself = dmenu:AddSubMenu("Issue himself")
        giveonself:AddOption("1PC.",function()
            netstream.Start("givemyitem",1,nil,item,1)
        end)
        giveonself:AddOption("His quantity",function()
            Derma_StringRequest("His quantity", "Enter the number of items to issue", 0, function(string) 
                string_ = (isnumber(tonumber(string)) and tonumber(string)) or 1
                if string_ > (nut.config.get("invW") * nut.config.get("invH")) then
                    nut.util.notify("Number exceeds allowed ("..nut.config.get("invW") * nut.config.get("invH")..")")
                    return false
                end
                if checkemptyslot(LocalPlayer()) == false then
                    nut.util.notify("No space in inventory")
                    return false
                end
                    netstream.Start("givemyitem",1,nil,item,string_ )
                nut.util.notify("Item "..nut.item.list[item].name.." issued to himself "..string_.." now")
            end, nil, "Give", "Cancel")
        end)
        local giveotherplayer = dmenu:AddSubMenu( "Issue to another player" )
        giveotherplayer:AddOption("1PC.",function()
                local playerselect_f = vgui.Create("DFrame")
                playerselect_f:SetSize(ScrW() * 0.2, ScrH() * 0.5)
                playerselect_f:MakePopup(true)
                playerselect_f:Center()
                playerselect_f:SetTitle("playerselector")
                playerselect_dlv = playerselect_f:Add("DListView")
                playerselect_dlv:Dock(FILL)
                playerselect_dlv:AddColumn("Имя")
                playerselect_dlv:AddColumn("Entindex")
                for k,v in pairs(player.GetAll()) do 
                    if v != LocalPlayer() then
                        if IsValid(v) and v:getChar() then
                            playerselect_dlv:AddLine(v:Name(),v)
                        end
                    end
                end
                function playerselect_dlv:DoDoubleClick(lineID, lineID)
                    if checkemptyslot(LocalPlayer()) == false then
                        nut.util.notify("No space in inventory")
                        return false
                    end
                    netstream.Start("givemyitem",2,lineID:GetColumnText(2),item,1)
                    nut.util.notify("Item "..nut.item.list[item].name.." issued to player "..lineID:GetColumnText(1))
                    playerselect_f:Remove()
                end
                
                nut.util.notify("Double-click on the name to select it.")
            end)
            giveotherplayer:AddOption("His quantity",function()
                local playerselect_f = vgui.Create("DFrame")
                playerselect_f:SetSize(ScrW() * 0.2, ScrH() * 0.5)
                playerselect_f:MakePopup(true)
                playerselect_f:Center()
                playerselect_f:SetTitle("playerselector")
                playerselect_dlv = playerselect_f:Add("DListView")
                playerselect_dlv:Dock(FILL)
                playerselect_dlv:AddColumn("Имя")
                playerselect_dlv:AddColumn("Entindex")
                for k,v in pairs(player.GetAll()) do
                    if v != LocalPlayer() then
                        if IsValid(v) and v:getChar() then
                            playerselect_dlv:AddLine(v:Name(),v)
                        end
                    end
                end
                function playerselect_dlv:DoDoubleClick(lineID, lineID)
                    Derma_StringRequest("His quantity", "Enter the number of items to issue", 0, function(string)
                        string_ = (isnumber(tonumber(string)) and tonumber(string)) or 1
                        if string_ > (nut.config.get("invW") * nut.config.get("invH")) then
                            nut.util.notify("Number exceeds allowed ("..nut.config.get("invW") * nut.config.get("invH")..")")
                            return false
                        end
                        if checkemptyslot(lineID:GetColumnText(2)) == false then
                            nut.util.notify("No space in inventory")
                            return false
                        end
                        netstream.Start("givemyitem",2,lineID:GetColumnText(2),item,string_)
                        nut.util.notify("Item "..nut.item.list[item].name.." issued to player "..lineID:GetColumnText(1).." "..string_.." now")
                        playerselect_f:Remove()
                    end, nil, "Give", "Cancel")
                end
            end)
        dmenu:Open()
    end
    function itemlist:DoDoubleClick(_,line)
        item = line:GetColumnText(3)
    end

    search_item = igframe:Add("DTextEntry")
    search_item:Dock(BOTTOM)
    search_item:SetTooltip("Press Enter for search")
    search_item.OnEnter = function()
        searched = search_item:GetValue()
        for _,line in pairs(itemlist:GetLines()) do
            itemlist:RemoveLine(_)
        end
        for k,v in pairs(nut.item.list) do
            if string.find(v.name, searched) then
                itemlist:AddLine( v.name, (v.category or "unknown"), v.uniqueID )        
            end
        end
    end 

    for k,v in pairs(nut.item.list) do
        itemlist:AddLine( v.name, (v.category or "unknown"), v.uniqueID )
    end
end)
