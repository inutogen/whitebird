-- yabastar, main dev
-- JackMacWindows, major bug fixes, dbprotect.lua
-- RyanT, fixed an annoying bug JMW and I couldn't fix, selection menu
-- minerobber, fixed a minor selection menu bug

local ver = "1.1.0 RELEASE"

for i=1,100  do
    print("whitebird")
end

sleep(0.5)

function clear()
    term.clear()
    term.setCursorPos(1, 1)
end

function starts(start, num)
    return string.sub(start,1,num)
end

local function selectmenu(options)
    local curX, curY = term.getCursorPos()
    local curOpt = 1

    local _, Ty = term.getSize()

    if curY + 4 > Ty then
        term.scroll(curY + 4 - Ty)
        curY = curY - (curY + 4 - Ty)
    end

    while true do
        term.setCursorPos(curX, curY)
        term.clearLine()
        term.setCursorPos(curX, curY + 1)
        term.write(tostring(options[curOpt]))
        term.setCursorPos(curX, curY + 2)
        term.write("Press arrow keys or w/s to select.")
        term.setCursorPos(curX, curY + 3)
        term.write("Press enter to confirm.")
        term.setCursorPos(curX, curY + 4)
        term.clearLine()

        local e = {os.pullEvent()}
        if e[1] == "key" then
            if e[2] == keys.w or e[2] == keys.up then
                curOpt = curOpt - 1
                if curOpt == 0 then curOpt = #options end
                term.setCursorPos(curX, curY + 1)
                term.clearLine()
            elseif e[2] == keys.s or e[2] == keys.down then
                curOpt = curOpt + 1
                if curOpt == #options + 1 then curOpt = 1 end
                term.setCursorPos(curX, curY + 1)
                term.clearLine()
            elseif e[2] == keys.enter then
                term.setCursorPos(curX, curY + 1)
                term.clearLine()
                term.setCursorPos(curX, curY + 2)
                term.clearLine()
                term.setCursorPos(curX, curY + 3)
                term.clearLine()
                term.setCursorPos(curX, curY + 4)
                term.clearLine()
                term.setCursorPos(curX, curY)

                return options[curOpt]
            end
        end
    end
end


clear()

if fs.exists("/virtualmachines") then
    vms = fs.list("/virtualmachines")
else
    fs.makeDir("/virtualmachines")
    vms = fs.list("/virtualmachines")
end

table.insert(vms,1,"Create New VM")
opt = selectmenu(vms)
if opt == "Create New VM" then
    clear()
    print("Name:")
    vmname = io.read()
    if fs.exists("virtualmachines/"..vmname) then
        print("VM already exists. Rebooting")
    else
        if vmname == "rom" then
            print("Cannot be named 'rom'. Rebooting")
        else
            fs.makeDir("virtualmachines/"..vmname)
            print("Done. Rebooting")
        end
    end
    sleep(2)
    os.reboot()
else
    virfold = opt
end

clear()

local expect = require "cc.expect"
local field = expect.field

local oldfs = fs
_G.fs = {}
for k, v in pairs(oldfs) do fs[k] = v end

local function isVM(path)
    return string.find(path, "^virtualmachines/"..virfold) == 1
end

_ENV.fs.open = function(path, mode)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.open(cleanRawPath, mode)
    else
        if isVM(cleanPath) == true then
            return oldfs.open(cleanPath, mode)
        else
            return nil
        end
    end
end

_ENV.fs.list = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,3) == "rom" then
        return oldfs.list(cleanRawPath)
    else
        if cleanRawPath == "" then
            local data = oldfs.list(cleanPath)
            table.insert(data,1,"rom")
            return data
        else
            if isVM(cleanPath) == true then
                return oldfs.list(cleanPath)
            else
                return nil
            end
        end
    end
end

_ENV.fs.find = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)
    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.find(cleanRawPath)
    else
        local foundFiles = oldfs.find(cleanPath)
        local modifiedPaths = {}

        for _, foundPath in ipairs(foundFiles) do
            local modifiedPath = string.gsub(foundPath, "^virtualmachines/"..virfold, "")
            table.insert(modifiedPaths, modifiedPath)
        end

        return modifiedPaths
    end
end

_ENV.fs.isDir = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.isDir(cleanRawPath)
    else
        if cleanRawPath == "rom" then
            return true
        else
            if isVM(cleanPath) == true then
                return oldfs.isDir(cleanPath)
            else
                return nil
            end
        end
    end
end

_ENV.fs.copy = function(path,dest)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanDest = fs.combine("virtualmachines/"..virfold, dest)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.copy(cleanRawPath,cleanDest)
    else
        if isVM(cleanPath) == true then
            return oldfs.copy(cleanPath, cleanDest)
        else
            return nil
        end
    end
end

_ENV.fs.delete = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        print(cleanRawPath)
        return oldfs.delete(cleanRawPath)
    else
        if isVM(cleanPath) == true then
            return oldfs.delete(cleanPath)
        else
            return nil
        end
    end
end

_ENV.fs.attributes = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.attributes(cleanRawPath)
    else
        if isVM(cleanPath) == true then
            return oldfs.attributes(cleanPath)
        else
            return nil
        end
    end
end

_ENV.fs.getCapacity = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.getCapacity(cleanRawPath)
    else
        if isVM(cleanPath) == true then
            return oldfs.getCapacity(cleanPath)
        else
            return nil
        end
    end
end

_ENV.fs.getFreeSpace = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.getFreeSpace(cleanRawPath)
    else
        if isVM(cleanPath) == true then
            return oldfs.getFreeSpace(cleanPath)
        else
            return nil
        end
    end
end

_ENV.fs.getDrive = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.getDrive(cleanRawPath)
    else
        if isVM(cleanPath) == true then
            return oldfs.getDrive(cleanPath)
        else
            return nil
        end
    end
end

_ENV.fs.move = function(path,dest)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanDest = fs.combine("virtualmachines/"..virfold, dest)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.move(cleanRawPath,cleanDest)
    else
        if isVM(cleanPath) == true then
            return oldfs.move(cleanPath, cleanDest)
        else
            return nil
        end
    end
end

_ENV.fs.makeDir = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.makeDir(cleanRawPath)
    else
        if isVM(cleanPath) == true then
            return oldfs.makeDir(cleanPath)
        else
            return nil
        end
    end
end

_ENV.fs.isReadOnly = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.isReadOnly(cleanRawPath)
    else
        if isVM(cleanPath) == true then
            return oldfs.isReadOnly(cleanPath)
        else
            return nil
        end
    end
end

_ENV.fs.getSize = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.getSize(cleanRawPath)
    else
        if isVM(cleanPath) == true then
            return oldfs.getSize(cleanPath)
        else
            return nil
        end
    end
end

_ENV.fs.isDriveRoot = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.isDriveRoot(cleanRawPath)
    else
        if isVM(cleanPath) == true then
            return oldfs.isDriveRoot(cleanPath)
        else
            return nil
        end
    end
end

_ENV.fs.complete = function(sPath, sLocation, bIncludeFiles, bIncludeDirs) -- thanks JMW
    expect(1, sPath, "string")
    expect(2, sLocation, "string")
    local bIncludeHidden = nil

    if type(bIncludeFiles) == "table" then
        bIncludeDirs = field(bIncludeFiles, "include_dirs", "boolean", "nil")
        bIncludeHidden = field(bIncludeFiles, "include_hidden", "boolean", "nil")
        bIncludeFiles = field(bIncludeFiles, "include_files", "boolean", "nil")
    else
        expect(3, bIncludeFiles, "boolean", "nil")
        expect(4, bIncludeDirs, "boolean", "nil")
    end

    bIncludeHidden = bIncludeHidden ~= false
    bIncludeFiles = bIncludeFiles ~= false
    bIncludeDirs = bIncludeDirs ~= false
    local sDir = sLocation
    local nStart = 1
    local nSlash = string.find(sPath, "[/\\]", nStart)
    if nSlash == 1 then
        sDir = ""
        nStart = 2
    end
    local sName
    while not sName do
        local nSlash = string.find(sPath, "[/\\]", nStart)
        if nSlash then
            local sPart = string.sub(sPath, nStart, nSlash - 1)
            sDir = fs.combine(sDir, sPart)
            nStart = nSlash + 1
        else
            sName = string.sub(sPath, nStart)
        end
    end

    if fs.isDir(sDir) then
        local tResults = {}
        if bIncludeDirs and sPath == "" then
            table.insert(tResults, ".")
        end
        if sDir ~= "" then
            if sPath == "" then
                table.insert(tResults, bIncludeDirs and ".." or "../")
            elseif sPath == "." then
                table.insert(tResults, bIncludeDirs and "." or "./")
            end
        end
        local tFiles = fs.list(sDir)
        for n = 1, #tFiles do
            local sFile = tFiles[n]
            if #sFile >= #sName and string.sub(sFile, 1, #sName) == sName and (
                bIncludeHidden or sFile:sub(1, 1) ~= "." or sName:sub(1, 1) == "."
            ) then
                local bIsDir = fs.isDir(fs.combine(sDir, sFile))
                local sResult = string.sub(sFile, #sName + 1)
                if bIsDir then
                    table.insert(tResults, sResult .. "/")
                    if bIncludeDirs and #sResult > 0 then
                        table.insert(tResults, sResult)
                    end
                else
                    if bIncludeFiles and #sResult > 0 then
                        table.insert(tResults, sResult)
                    end
                end
            end
        end
        return tResults
    end

    return {}
end

_ENV.fs.exists = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)
    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.exists(cleanRawPath)
    else
        return oldfs.exists(cleanPath)
    end
end

-- dbprotect.lua - Protect your functions from the debug library
-- By JackMacWindows
-- Licensed under CC0, though I'd appreciate it if this notice was left in place.

-- Simply run this file in some fashion, then call `debug.protect` to protect a function.
-- It takes the function as the first argument, as well as a list of functions
-- that are still allowed to access the function's properties.
-- Once protected, access to the function's environment, locals, and upvalues is
-- blocked from all Lua functions. A function *can not* be unprotected without
-- restarting the Lua state.
-- The debug library itself is protected too, so it's not possible to remove the
-- protection layer after being installed.
-- It's also not possible to add functions to the whitelist after protecting, so
-- make sure everything that needs to access the function's properties are added.

if not dbprotect then
    local protectedObjects
    local n_getfenv, n_setfenv, d_getfenv, getlocal, getupvalue, d_setfenv, setlocal, setupvalue, upvaluejoin =
        getfenv, setfenv, debug.getfenv, debug.getlocal, debug.getupvalue, debug.setfenv, debug.setlocal, debug.setupvalue, debug.upvaluejoin

    local error, getinfo, running, select, setmetatable, type, tonumber = error, debug.getinfo, coroutine.running, select, setmetatable, type, tonumber

    local superprotected

    local function keys(t, v, ...)
        if v then t[v] = true end
        if select("#", ...) > 0 then return keys(t, ...)
        else return t end
    end

    local function superprotect(v, ...)
        if select("#", ...) > 0 then return superprotected[v or ""] or v, superprotect(...)
        else return superprotected[v or ""] or v end
    end

    function debug.getinfo(thread, func, what)
        if type(thread) ~= "thread" then what, func, thread = func, thread, running() end
        local retval
        if tonumber(func) then retval = getinfo(thread, func+1, what)
        else retval = getinfo(thread, func, what) end
        if retval and retval.func then retval.func = superprotected[retval.func] or retval.func end
        return retval
    end

    function debug.getlocal(thread, level, loc)
        if loc == nil then loc, level, thread = level, thread, running() end
        local k, v
        if type(level) == "function" then
            local caller = getinfo(2, "f")
            if protectedObjects[level] and not (caller and protectedObjects[level][caller.func]) then return nil end
            k, v = superprotect(getlocal(level, loc))
        elseif tonumber(level) then
            local info = getinfo(thread, level + 1, "f")
            local caller = getinfo(2, "f")
            if info and protectedObjects[info.func] and not (caller and protectedObjects[info.func][caller.func]) then return nil end
            k, v = superprotect(getlocal(thread, level + 1, loc))
        else k, v = superprotect(getlocal(thread, level, loc)) end
        return k, v
    end

    function debug.getupvalue(func, up)
        if type(func) == "function" then
            local caller = getinfo(2, "f")
            if protectedObjects[func] and not (caller and protectedObjects[func][caller.func]) then return nil end
        end
        local k, v = superprotect(getupvalue(func, up))
        return k, v
    end

    function debug.setlocal(thread, level, loc, value)
        if loc == nil then loc, level, thread = level, thread, running() end
        if tonumber(level) then
            local info = getinfo(thread, level + 1, "f")
            local caller = getinfo(2, "f")
            if info and protectedObjects[info.func] and not (caller and protectedObjects[info.func][caller.func]) then error("attempt to set local of protected function", 2) end
            setlocal(thread, level + 1, loc, value)
        else setlocal(thread, level, loc, value) end
    end

    function debug.setupvalue(func, up, value)
        if type(func) == "function" then
            local caller = getinfo(2, "f")
            if protectedObjects[func] and not (caller and protectedObjects[func][caller.func]) then error("attempt to set upvalue of protected function", 2) end
        end
        setupvalue(func, up, value)
    end

    function _G.getfenv(f)
        local v
        if f == nil then v = n_getfenv(2)
        elseif tonumber(f) and tonumber(f) > 0 then
            local info = getinfo(f + 1, "f")
            local caller = getinfo(2, "f")
            if info and protectedObjects[info.func] and not (caller and protectedObjects[info.func][caller.func]) then return nil end
            v = n_getfenv(f+1)
        elseif type(f) == "function" then
            local caller = getinfo(2, "f")
            if protectedObjects[f] and not (caller and protectedObjects[f][caller.func]) then return nil end
            v = n_getfenv(f)
        else v = n_getfenv(f) end
        return v
    end

    function _G.setfenv(f, tab)
        if tonumber(f) then
            local info = getinfo(f + 1, "f")
            local caller = getinfo(2, "f")
            if info and protectedObjects[info.func] and not (caller and protectedObjects[info.func][caller.func]) then error("attempt to set environment of protected function", 2) end
            n_setfenv(f+1, tab)
        elseif type(f) == "function" then
            local caller = getinfo(2, "f")
            if protectedObjects[f] and not (caller and protectedObjects[f][caller.func]) then error("attempt to set environment of protected function", 2) end
        end
        n_setfenv(f, tab)
    end

    if d_getfenv then
        function debug.getfenv(o)
            if type(o) == "function" then
                local caller = getinfo(2, "f")
                if protectedObjects[o] and not (caller and protectedObjects[o][caller.func]) then return nil end
            end
            local v = d_getfenv(o)
            return v
        end

        function debug.setfenv(o, tab)
            if type(o) == "function" then
                local caller = getinfo(2, "f")
                if protectedObjects[o] and not (caller and protectedObjects[o][caller.func]) then error("attempt to set environment of protected function", 2) end
            end
            d_setfenv(o, tab)
        end
    end

    if upvaluejoin then
        function debug.upvaluejoin(f1, n1, f2, n2)
            if type(f1) == "function" and type(f2) == "function" then
                local caller = getinfo(2, "f")
                if protectedObjects[f1] and not (caller and protectedObjects[f1][caller.func]) then error("attempt to get upvalue of protected function", 2) end
                if protectedObjects[f2] and not (caller and protectedObjects[f2][caller.func]) then error("attempt to set upvalue of protected function", 2) end
            end
            upvaluejoin(f1, n1, f2, n2)
        end
    end

    function debug.protect(func, ...)
        if type(func) ~= "function" then error("bad argument #1 (expected function, got " .. type(func) .. ")", 2) end
        if protectedObjects[func] then error("attempt to protect a protected function", 2) end
        protectedObjects[func] = keys(setmetatable({}, {__mode = "k"}), ...)
    end

    superprotected = {
        [n_getfenv] = _G.getfenv,
        [n_setfenv] = _G.setfenv,
        [d_getfenv] = debug.getfenv,
        [d_setfenv] = debug.setfenv,
        [getlocal] = debug.getlocal,
        [setlocal] = debug.setlocal,
        [getupvalue] = debug.getupvalue,
        [setupvalue] = debug.setupvalue,
        [upvaluejoin] = debug.upvaluejoin,
        [getinfo] = debug.getinfo,
        [superprotect] = function() end,
    }

    protectedObjects = keys(setmetatable({}, {__mode = "k"}),
        getfenv,
        setfenv,
        debug.getfenv,
        debug.setfenv,
        debug.getlocal,
        debug.setlocal,
        debug.getupvalue,
        debug.setupvalue,
        debug.upvaluejoin,
        debug.getinfo,
        superprotect,
        debug.protect
    )
    for k,v in pairs(protectedObjects) do protectedObjects[k] = {} end
end

for functionName, func in pairs(fs) do
    term.setTextColor(colors.lightGray)
    io.write("[")
    term.setTextColor(colors.yellow)
    io.write("LOAD")
    term.setTextColor(colors.lightGray)
    io.write("] ")
    term.setTextColor(colors.white)
    io.write(functionName)
    print("")
    local function trytoprotect()
        debug.protect(func)
    end
    local v, message = pcall(trytoprotect)
    if v == true then
        term.setTextColor(colors.lightGray)
        io.write("[")
        term.setTextColor(colors.green)
        io.write("OK")
        term.setTextColor(colors.lightGray)
        io.write("] ")
        term.setTextColor(colors.white)
        io.write(functionName)
        print("")
    else
        term.setTextColor(colors.lightGray)
        io.write("[")
        term.setTextColor(colors.red)
        io.write("FAIL")
        term.setTextColor(colors.lightGray)
        io.write("] ")
        term.setTextColor(colors.white)
        io.write(functionName)
        print("")
    end
end

sleep(2)

clear()

term.setTextColor(colors.yellow)
print("whitebird VM")
print(ver)
os.run(_ENV, "rom/programs/shell.lua")

_G.fs = oldfs
