local fs = require("@lune/fs")

local SRC_DIR = "src"
local OUTPUT_PATH = "src/shared/Modux/types/use.luau"

local function ensureDir(path)
	local parts = string.split(path, "/")
	local current = ""
	for i = 1, #parts - 1 do
		if current == "" then
			current = parts[i]
		else
			current = current .. "/" .. parts[i]
		end
		if not fs.isDir(current) then
			fs.writeDir(current)
		end
	end
end

local function scanDirectory(dir, foundModules)
	if not fs.isDir(dir) then return end
	
	for _, entry in fs.readDir(dir) do
		local fullPath = dir .. "/" .. entry
		if fs.isDir(fullPath) then
			scanDirectory(fullPath, foundModules)
		elseif string.match(entry, "%.luau$") or string.match(entry, "%.lua$") then
			local content = fs.readFile(fullPath)
			
			-- Look for __identifier or __tag
			local identifier = string.match(content, "[%w_]+%.__identifier%s*=%s*[\"']([^\"']+)[\"']")
			if not identifier then
				identifier = string.match(content, "[%w_]+%.__tag%s*=%s*[\"']([^\"']+)[\"']")
			end
			
			if identifier then
				foundModules[identifier] = fullPath
			end
		end
	end
end

print("Scanning for Modux modules in " .. SRC_DIR .. "...")
local foundModules = {}
scanDirectory(SRC_DIR, foundModules)

local typesCount = 0
local requireLines = {}
local intersectionLines = {}

for identifier, path in pairs(foundModules) do
	-- Path must be relative to the game hierarchy or we can just require via path in strictly typed mode.
	-- Since this is just for types, we can use require(script.Parent.Parent.Parent...) or just let Luau infer it 
	-- if we use require() with the actual path.
	-- Actually, Roblox script require() needs a Roblox Instance.
	-- To make `typeof(require(...))` work in Luau, we can mock it for the LSP.
	
	-- Roblox LSP / Luau doesn't support requiring file paths directly in strict mode, unless using rojo-sourcemap or native luau paths.
	-- Wait, Roblox Luau requires instances: `require(game.ReplicatedStorage.Path...)`.
	-- Lune uses file paths. If this type file is used in Roblox Studio, we need Roblox paths.
	-- How is `use.luau` implemented in `Walkthrough.md`?
	-- "UseFn e ImportFn via intersection (&) de overloads"
	-- ex: `((id: "CurrencyService") -> typeof(require(path))) & ...`
	-- Wait, if it's in Roblox, we can't use `require("path/to/file")`. We must build a path like `require(game.ReplicatedStorage.src...)`? 
	-- Or maybe just `any` for now if we can't resolve instances, or use relative paths if Roblox LSP supports it (it does support relative paths like `require(script.Parent.Parent...)` with Luau!).
	
	-- Let's build a relative path from OUTPUT_PATH to fullPath.
	-- OUTPUT_PATH is "src/shared/Modux/types/use.luau"
	-- fullPath might be "src/server/Modux/Services/CurrencyService.luau"
	
	local outputParts = string.split(OUTPUT_PATH, "/")
	local moduleParts = string.split(fullPath, "/")
	
	-- remove file name from outputParts
	table.remove(outputParts)
	
	local common = 0
	while outputParts[common + 1] and moduleParts[common + 1] and outputParts[common + 1] == moduleParts[common + 1] do
		common = common + 1
	end
	
	local upCount = #outputParts - common
	local relativePath = "script"
	for i = 1, upCount do
		relativePath = relativePath .. ".Parent"
	end
	
	for i = common + 1, #moduleParts do
		local part = moduleParts[i]
		if i == #moduleParts then
			part = string.gsub(part, "%.luau$", "")
			part = string.gsub(part, "%.lua$", "")
			if part ~= "init" then
				relativePath = relativePath .. '["' .. part .. '"]'
			end
		else
			relativePath = relativePath .. '["' .. part .. '"]'
		end
	end
	
	typesCount = typesCount + 1
	table.insert(intersectionLines, string.format('((id: "%s") -> typeof(require(%s)))', identifier, relativePath))
end

local outputContent = ""

if typesCount > 0 then
	local intersectionType = table.concat(intersectionLines, "\n\t& ")
	
	outputContent = string.format([[--!strict
-- ARQUIVO GERADO AUTOMATICAMENTE PELO LUNE
-- NÃO EDITE MANUALMENTE

export type UseFn = 
	%s
	& ((id: string) -> any)

export type ImportFn = UseFn

return nil
]], intersectionType)

else
	outputContent = [[--!strict
-- ARQUIVO GERADO AUTOMATICAMENTE PELO LUNE
-- NENHUM MÓDULO ENCONTRADO

export type UseFn = ((id: string) -> any)
export type ImportFn = UseFn

return nil
]]
end

ensureDir(OUTPUT_PATH)
fs.writeFile(OUTPUT_PATH, outputContent)

print("Generated types for " .. typesCount .. " modules at " .. OUTPUT_PATH)
