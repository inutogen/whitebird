-- yabastar, main dev
-- JackMacWindows, major bug fixes
-- RyanT, fixed an annoying bug JMW and I couldn't fix, selection menu
-- minerobber, fixed a minor selection menu bug

local ver = "1.0.0 RELEASE"

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

local function select(options)
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
opt = select(vms)
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

local oldfs = fs
_G.fs = {}
for k, v in pairs(oldfs) do fs[k] = v end

function customDofile(filename)
    local file = oldfs.open(filename, "r")
    if not file then
        return error("File not found: " .. filename)
    end

    local content = file.readAll()
    file.close()

    local func, err = load(content, "=" .. filename, "t", _ENV)
    if not func then
        return error("Error loading file: " .. err)
    end

    return func()
end

_G.fs.open = function(path, mode)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.open(cleanRawPath, mode)
    else
        return oldfs.open(cleanPath, mode)
    end
end

_G.fs.list = function(path)

    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.list(cleanRawPath)
    else
        if cleanRawPath == "" then
            local data = oldfs.list(cleanPath)
            table.insert(data,1,"rom")
            return data
        else
            return oldfs.list(cleanPath)
        end
    end
end

_G.fs.find = function(path)
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

_G.fs.isDir = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.isDir(cleanRawPath)
    else
        if starts(cleanRawPath,3) == "rom" then
            return true
        else
            return oldfs.isDir(cleanPath)
        end
    end
end 

_G.fs.copy = function(path,dest)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanDest = fs.combine("virtualmachines/"..virfold, dest)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.copy(cleanRawPath,cleanDest)
    else
        return oldfs.copy(cleanPath,cleanDest)
    end
end 

_G.fs.delete = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        print(cleanRawPath)
        return oldfs.delete(cleanRawPath)
    else
        return oldfs.delete(cleanPath)
    end
end 

_G.fs.attributes = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.attributes(cleanRawPath)
    else
        return oldfs.attributes(cleanPath)
    end
end 

_G.fs.getCapacity = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.getCapacity(cleanRawPath)
    else
        return oldfs.getCapacity(cleanPath)
    end
end 

_G.fs.getFreeSpace = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.getFreeSpace(cleanRawPath)
    else
        return oldfs.getFreeSpace(cleanPath)
    end
end 

_G.fs.getDrive = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.getDrive(cleanRawPath)
    else
        return oldfs.getDrive(cleanPath)
    end
end 

_G.fs.move = function(path,dest)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanDest = fs.combine("virtualmachines/"..virfold, dest)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.move(cleanRawPath,cleanDest)
    else
        return oldfs.move(cleanPath,cleanDest)
    end
end 

_G.fs.makeDir = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.makeDir(cleanRawPath)
    else
        return oldfs.makeDir(cleanPath)
    end
end 

_G.fs.isReadOnly = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.isReadOnly(cleanRawPath)
    else
        return oldfs.isReadOnly(cleanPath)
    end
end 

_G.fs.getSize = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.getSize(cleanRawPath)
    else
        return oldfs.getSize(cleanPath)
    end
end 

_G.fs.isDriveRoot = function(path)
    local cleanPath = fs.combine("virtualmachines/"..virfold, path)
    local cleanRawPath = fs.combine(path)

    if starts(cleanRawPath,4) == "rom/" then
        return oldfs.isDriveRoot(cleanRawPath)
    else
        return oldfs.isDriveRoot(cleanPath)
    end
end 

term.setTextColor(colors.yellow)
print("whitebird VM")
print(ver)
os.run(_ENV, "rom/programs/shell.lua")

_G.fs = oldfs
