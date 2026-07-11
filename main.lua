local fetchfrom = {
    game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"),
    game:GetService("ReplicatedStorage")
}

local dir = "collectorsaves"
if not isfolder(tostring(dir)) then
    makefolder(tostring(dir))
end

local hashLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeCompiled/refs/heads/main/libraries/hash.lua"))()

local function fingerprint(bytecode)
    local h = hashLib.sha256(tostring(bytecode or ""))
    return string.sub(h, 1, 6) .. string.sub(h, 25, 30)
end

local function scan(container, res, seen)
    for _,v in next, container:GetDescendants() do
        if v:IsA("ModuleScript") or v:IsA("LocalScript") then
            local suc, bytecode = pcall(getscriptbytecode, v)
            if suc and bytecode and not seen[v] then
                seen[v] = true
                local fp = fingerprint(bytecode)
                table.insert(res, string.format("%s|%s|%s", v:GetFullName(), fp, v.Name))
            end
        end
    end
end
local start = tick()
print("Started operation at " .. os.date("%H:%M:%S"))
local output = {}
local seen = {}
for _, v in next, fetchfrom do
    scan(v, output, seen)
end

local date = os.date("%d-%m-%Y")
writefile(dir .. "/fingerprinted " .. date..".txt", table.concat(output, "\n"))
local elapsed = math.floor((tick() - start) * 1000)
print("Finished in " .. elapsed .. " ms")
