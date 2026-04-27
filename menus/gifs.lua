Name = "gifs"
NamePretty = "Walky Gifs"
Icon = "image-gif"
Cache = false
Matching = "none"

function GetEntries(query)
    if query == "" then 
        return {{ Text = "Search GIFs...", Subtext = "Type to find GIFs", Value = "" }} 
    end
    
    local home = os.getenv("HOME")
    local safe_query = query:gsub("'", "")
    local script_path = home .. "/.config/walker/scripts/gif_search.sh"
    
    local cmd = script_path .. " --plain '" .. safe_query .. "'"
    local handle = io.popen(cmd)
    
    local entries = {}
    if handle then
        for line in handle:lines() do
            local url, title = line:match("([^|]+)|([^|]+)")
            if url and title then
                -- Generate a simple filename hash for the cached gif
                local hash = ""
                for i = 1, #url do hash = hash .. string.format("%02x", string.byte(url, i)) end
                hash = hash:sub(1, 16)
                
                local local_path = "/tmp/walker_gifs/" .. hash .. ".gif"
                
                local check = io.open(local_path, "r")
                if not check then
                    os.execute("curl -sL -o '" .. local_path .. "' '" .. url .. "' &")
                else
                    check:close()
                end
                
                table.insert(entries, {
                    Text = title, 
                    Subtext = url,
                    Value = url,
                    Icon = local_path,
                    Preview = local_path,
                    PreviewType = "file",
                    Actions = {
                        {
                            label = "Copy GIF",
                            exec = "gif-copy '" .. url .. "'",
                        }
                    }
                })
            end
        end
        handle:close()
    end

    if #entries == 0 then
        return {{ Text = "No Results Found", Value = "" }}
    end

    return entries
end
