--[[
    #TClass# - A Lua OOP framework help you use OOP naturely in Lua.
    Author: Meainc
]] 


local DebugMode = true
local Extends = {
    AnnomymousClass = false
}

local StrictMode = false
-------------------------------------------------------------------------
-- Extends Annomymous Class
local T_ClassId = "ClassId"
local AnnomymousClasses = {}

function cloneTableM(t)

    local newT = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            newT[k] = cloneTableM(v)
        else
            newT[k] = v
        end
    end

    local meta = getmetatable(t)
    if meta ~= nil then
        meta = cloneTableM(meta)
        setmetatable(newT, meta)
    end

    return newT
end

function cloneTableS(t)
    local newT = {}
    for k, v in pairs(t) do
        newT[k] = v
    end
    return newT
end

function scopy(obj)
    if type(obj) ~= "table" then
        return obj
    end
    return cloneTableS(obj)
end

function error(msg)
    if DebugMode then
        print("[Tclass] Error: " .. msg)
        local stackTrace = debug.traceback("Stack trace:", 4)
        print(stackTrace)
    end
end
function warn(msg)
    if DebugMode then
        print("[Tclass] Warnning: " .. msg)
        local stackTrace = debug.traceback("Stack trace:", 4)
        print(stackTrace)
    end
end

-------------------------------------------------------------------------

local DefaultClassname = "Class"

local InfoForcePropsName = "_props"
local InfoForceMethodsName = "_methods"

local InfoClassnameName = "Classname"
local InfoStaticName = "static"

local InstancePorpoertyName = "__Class"

local InstanceIndefity = "__InstanceIndefity"
local ClassIndefity = "__ClassIndefity"
local MethodClassName = "__MethodClassName"

local ClassObjectPropsName = "_props"
local ClassObjectMethodsName = "_methods"

local ClassObjectClassnameName = "Classname"
local ClassObjectConstructorName = "constructor"
local ClassObjectParentClassName = "__ParentClass"

local ClassObjectStaticName = "_static"
local ClassObjectStaticFieldsName = "_staticFields"
local ClassObjectMetaFuncsName = "_metaFuncs"
local ClassObjectHasMetaFuncsName = "_hasMetaFuncs"

local ClassObjectShadowStaticName = "static"

---------------------------------------------------------------------------
local metafuncs = {
    ["__add"] = true,
    ["__sub"] = true,
    ["__mul"] = true,
    ["__div"] = true,
    ["__mod"] = true,
    ["__pow"] = true,
    ["__unm"] = true,
    ["__idiv"] = true,
    ["__band"] = true,
    ["__bor"] = true,
    ["__bxor"] = true,
    ["__bnot"] = true,
    ["__shl"] = true,
    ["__shr"] = true,
    ["__concat"] = true,
    ["__len"] = true,
    ["__eq"] = true,
    ["__lt"] = true,
    ["__le"] = true,
    ["__index"] = true,
    ["__newindex"] = true,
    ["__call"] = true,
    ["__tostring"] = true,
    ["__metatable"] = true,
    ["__mode"] = true,
    ["__gc"] = true,
    ["__pairs"] = true,
    ["__ipairs"] = true,
    ["__next"] = true,
    ["__type"] = true
}

function margeTable(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
end

function cloneClass(class)
    local newClass = {}
    for k, v in pairs(class) do
        if k ~= ClassObjectMetatableName then
            if k ~= ClassObjectParentClassName then
                newClass[k] = scopy(v)
            else
                newClass[k] = v
            end
        end
    end
    return newClass
end

function isMetaFunc(name)
    if metafuncs[name] == nil then
        return false
    end
    return true
end

function isInstance(obj)
    if type(obj) ~= "table" then
        return false
    end
    local idf = getmetatable(obj)[InstanceIndefity]
    if idf == nil then
        return false
    end
    return idf
end

function isClass(obj)
    if type(obj) ~= "table" then
        return false
    end
    local idf = rawget(obj, ClassIndefity)
    if idf == nil then
        return false
    end
    return idf
end

function getClass(obj)
    if isInstance(obj) then
        return getmetatable(obj)[InstancePorpoertyName]
    end
    if isClass(obj) then
        return obj
    end
    return nil
end

function getParentClass(obj)
    if isInstance(obj) then
        return getClass(obj)[ClassObjectParentClassName]
    end
    if isClass(obj) then
        return obj[ClassObjectParentClassName]
    end
    return nil
end

function getClassName(obj)
    if isInstance(obj) then
        return getClass(obj)[ClassObjectClassnameName]
    end
    if isClass(obj) then
        return obj[ClassObjectClassnameName]
    end
    return nil
end

function getClassStatic(class)
    return rawget(class, ClassObjectStaticName)
end

function getClassProps(class)
    return rawget(class, ClassObjectPropsName)
end

function getClassMethods(class)
    return rawget(class, ClassObjectMethodsName)
end

function getClassStaticField(class)
    return rawget(class, ClassObjectStaticFieldsName)
end

function getClassMetaFuncs(class)
    return rawget(class, ClassObjectMetaFuncsName)
end

function getClassHasMetaFuncs(class)
    return rawget(class, ClassObjectHasMetaFuncsName)
end

function getClassnameAndInfo(arg1, arg2)
    local className = DefaultClassname
    local classInfo = ""

    if type(arg1) == "string" then
        className = arg1
        classInfo = arg2 or {}
    else
        classInfo = arg1
        if classInfo[InfoClassnameName] ~= nil then
            className = classInfo[InfoClassnameName]
        else
            warn("Class dont has a name , use Classname Prop to Set Class Name ")
        end
    end
    return className, classInfo
end

function dealInfo(info)
    local result = {
        [ClassObjectMethodsName] = {},
        [ClassObjectPropsName] = {},
        [ClassObjectStaticName] = {},
        [ClassObjectMetaFuncsName] = {},
        [ClassObjectHasMetaFuncsName] = false
    }

    -- Get Ext Info
    local infoForceMethods = info[InfoForceMethodsName] or {}
    local infoForceProps = info[InfoForcePropsName] or {}
    local infoStatic = info[InfoStaticName] or {}

    -- delete to Property
    info[InfoForceMethodsName] = nil
    info[InfoForcePropsName] = nil
    info[InfoClassnameName] = nil
    info[InfoStaticName] = nil

    -- Anlysis Info , Set Props and Methods
    for k, v in pairs(info) do
        if type(v) == "function" then
            result[ClassObjectMethodsName][k] = v
        else
            result[ClassObjectPropsName][k] = v
        end
    end

    margeTable(result[ClassObjectMethodsName], infoForceMethods)
    margeTable(result[ClassObjectPropsName], infoForceProps)
    margeTable(result[ClassObjectStaticName], infoStatic)

    for k, v in pairs(result[ClassObjectMethodsName]) do
        if isMetaFunc(k) then
            result[ClassObjectHasMetaFuncsName] = true
            result[ClassObjectMetaFuncsName][k] = v
            result[ClassObjectMethodsName][k] = nil
        end
    end

    return result
end

function getStatic(obj)
    return rawget(getClass(obj), ClassObjectStaticFieldsName)
end

function _Instance__index(self, key)
    local selfClass = getClass(self)
    if selfClass[ClassObjectMethodsName][key] ~= nil then
        return selfClass[ClassObjectMethodsName][key]
    end
    local staticValue = getStatic(self)[key]
    if staticValue ~= nil then
        return staticValue
    end
    local indexFunc = getClassMetaFuncs(getClass(self))["__index"]
    if indexFunc ~= nil then
        return indexFunc(self, key)
    end
    return
end

function InstanceRawset(self, key, value)
    local selfClass = getClass(self)
    local staticField = getStatic(self)
    if staticField[key] ~= nil then
        staticField[key] = value
        return
    end
    rawset(self, key, value)
end

function InstanceRawget(self, key)
    local selfClass = getClass(self)
    local staticValue = getStatic(self)[key]
    if staticValue ~= nil then
        return staticValue
    end
    return rawget(self, key)
end

function _Instance__newIndex(self, key, value)
    local selfClass = getClass(self)
    local staticField = getStatic(self)
    if staticField[key] ~= nil then
        staticField[key] = value
        return
    end
    local newIndexFunc = getClassMetaFuncs(getClass(self))["__newindex"]
    if newIndexFunc ~= nil then
        newIndexFunc(self, key, value)
        return
    else
        if StrictMode then
            error("You Cannot add a new property to an instance in strict mode")
        else
            rawset(self, key, value)
        end
    end

end

function _load(class, data)
    local meta = {
        __index = _Instance__index,
        __newindex = _Instance__newIndex,
        [InstancePorpoertyName] = class,
        [MethodClassName] = class,
        [InstanceIndefity] = true
    }

    if getClassHasMetaFuncs(class) then
        for k, v in pairs(getClassMetaFuncs(class)) do
            if k ~= "__index" and k ~= "__newindex" then
                meta[k] = v
            end
        end
    end
    setmetatable(data, meta)
    return data
end



function new(class, ...)
    if class == nil then
        error("Class Object is nil , Use Class:new() but not Class.new()")
        return nil
    end
    local obj = cloneTableS(getClassProps(class))
    _load(class, obj)
    local constructorFunc = class[ClassObjectMethodsName][ClassObjectConstructorName]
    if constructorFunc ~= nil then
        constructorFunc(obj, ...)
    end
    return obj
end

function instanceClone(obj, deepList)
    deepList = deepList or {}
    local newObj = {}
    local deepTable = {}

    for k, v in pairs(deepList) do
        deepTable[v] = true
    end

    for k, v in pairs(obj) do
        if deepList[k] == nil then
            newObj[k] = v
        else
            if type(v) == "table" then
                newObj[k] = cloneTableM(v)
            else
                newObj[k] = v
            end
        end
    end
    return newObj
end

function instanceDeepClone(obj, excludeList)
    excludeList = excludeList or {}
    local newObj = {}
    local deepTable = {}
    for k, v in pairs(excludeList) do
        deepTable[v] = true
    end
    for k, v in pairs(obj) do
        if deepTable[k] == nil then
            if type(v) == "table" then
                newObj[k] = cloneTableM(v)
            else
                newObj[k] = v
            end
        else
            newObj[k] = v
        end
    end
    return newObj
end

local methodMeta = {
    __call = function (self,obj,...)
        local meta = getmetatable(obj)
        local class = self.class
        local nowMethodClass = meta[MethodClassName]
        meta[MethodClassName] = class
        local result = self.func(obj,...)
        meta[MethodClassName] = nowMethodClass
        local funcName  = self.funcName
        --print ("log : ".. getClassName(class).. "." .. funcName .. " called" )
        return result
    end
}

function addClassMethod(class, name, func)
    if type(func) ~= "function" then
        error("Method " .. name .. " is not a function")
        return
    end
    if isMetaFunc(name) then
        local metaFuncs = getClassMetaFuncs(class)
        metaFuncs[name] = func
        class[ClassObjectHasMetaFuncsName] = true
    else
        local functable = {
            func = func,
            funcName = name,
            class = class
        }
        setmetatable(functable, methodMeta)
        class[ClassObjectMethodsName][name] = functable
    end
end

function defineProps(class, props)
    local classProps = getClassProps(class)
    margeTable(classProps, props)
end

function defineMethods(class, methods)
    for i in pairs(methods) do
        addClassMethod(class, i, methods[i])
    end
end

function defineStatics(class, statics, value)
    local classStatic = getClassStatic(class)
    if value == nil then
        margeTable(classStatic, statics)
    else
        classStatic[statics] = value
    end
    syncStaticField(class)
end

function registerMetatableForClass(class)
    local metatable = {
        __call = function(self, ...)
            return new(self, ...)
        end,
        __index = function(self, key)
            local staticValue = getClassStaticField(self)[key]
            if staticValue ~= nil then
                return staticValue
            end
        end,
        __newindex = function(self, key, value)
            local staticField = getClassStaticField(self)
            if staticField[key] ~= nil then
                rawset(staticField, key, value)
                return
            end
            local props = getClassProps(self)
            if type(value) == "function" then
                addClassMethod(self, key, value)
            else
                props[key] = value
            end
        end
    }
    setmetatable(class, metatable)
end

function syncStaticField(class)
    class = getClass(class)
    local staticField = getClassStaticField(class)
    local statics = getClassStatic(class)
    for k, v in pairs(statics) do
        if staticField[k] == nil then
            staticField[k] = v
        end
    end
end

function extends(ParentClass, arg1, arg2)

    local newClass = cloneClass(ParentClass)

    local className, classInfo = getClassnameAndInfo(arg1, arg2)

    -- get Config Info , marge the Props , Methods and Statics
    local extendsInfo = dealInfo(classInfo)

    -- Set Class Object info
    newClass[ClassObjectClassnameName] = className
    newClass[ClassObjectParentClassName] = ParentClass
    newClass[ClassObjectHasMetaFuncsName] = newClass[ClassObjectHasMetaFuncsName] or
                                                extendsInfo[ClassObjectHasMetaFuncsName]

    -- marge Props , Statics and Methods
    margeTable(newClass[ClassObjectPropsName], extendsInfo[ClassObjectPropsName])
    margeTable(newClass[ClassObjectStaticName], extendsInfo[ClassObjectStaticName])
    margeTable(newClass[ClassObjectMetaFuncsName], extendsInfo[ClassObjectMetaFuncsName])

    -- Add Methods
    for i in pairs(extendsInfo[ClassObjectMethodsName]) do
        addClassMethod(newClass, i, extendsInfo[ClassObjectMethodsName][i])
    end

    -- Create Static FieldsTable
    newClass[ClassObjectStaticFieldsName] = scopy(newClass[ClassObjectStaticName])

    registerMetatableForClass(newClass)

    return newClass
end

function supercall(self, method, ...)
    local classmeta = getmetatable(self)
    local methodClass =  classmeta[MethodClassName]
    local parentClass = getParentClass(methodClass)
    
    if parentClass == nil then
        error("Call supercall on a Class , [ Classname = " .. getClassName(self) .. " ]")
        return nil
    end
    
    local parentMethod = getClassMethods(parentClass)[method]
    local result = parentMethod(self, ...)
    return result
end

function isThisClass(class, obj)
    local class = getClass(class)
    if type(obj) == "table" then
        if getClass(obj) == class then
            return true
        end
        return false
    elseif type(obj) == "string" then
        if getClassName(class) == obj then
            return true
        end
        return false
    end
    return false
end

function isA(class, obj)
    local objClass = getClass(obj)
    while class ~= nil do
        if isThisClass(class, obj) then
            return true
        end
        class = getParentClass(class)
    end
    return false
end


function AnnomymousClass(self, info)
    if not isInstance(self) then
        error("AnnomymousClass can only be called by instance")
        return
    end
    local annomymousClass
    local classId = info[T_ClassId]
    if classId ~= nil then
        if AnnomymousClasses[classId] ~= nil then
            AnnomymousClass = AnnomymousClasses[classId]
        end
    else
        local class = self:getClass()
        local className = self:getClassName()
        annomymousClass = extends(class, "AnnomymousClass(" .. className .. ")", info)
        if classId ~= nil then
            AnnomymousClasses[classId] = annomymousClass
        end
    end
    local obj = annomymousClass:load(self)
    local constructorFunc = info[ClassObjectConstructorName]
    if constructorFunc ~= nil then
        constructorFunc(obj)
    end
    return obj
end

function Class(arg1, arg2)

    local className, classInfo = getClassnameAndInfo(arg1, arg2)
    local class = {
        [ClassIndefity] = true,
        [ClassObjectClassnameName] = className,
        [ClassObjectStaticName] = {},
        [ClassObjectHasMetaFuncsName] = false,
        [ClassObjectMethodsName] = {}
    }

    -- Get and Set Config Info
    local info = dealInfo(classInfo)
    class[ClassObjectPropsName] = info[ClassObjectPropsName]
    class[ClassObjectStaticName] = info[ClassObjectStaticName]

    -- Add Methods
    for i in pairs(info[ClassObjectMethodsName]) do
        addClassMethod(class, i, info[ClassObjectMethodsName][i])
    end

    -- Create Static FieldsTable
    class[ClassObjectStaticFieldsName] = scopy(class[ClassObjectStaticName])

    -- Set metaFuncs 
    class[ClassObjectMetaFuncsName] = info[ClassObjectMetaFuncsName]
    class[ClassObjectHasMetaFuncsName] = info[ClassObjectHasMetaFuncsName]

    -- # Extends AnnomymousClass
    if Extends.AnnomymousClass then
        class[ClassObjectHasMetaFuncsName] = true
        class[ClassObjectMetaFuncsName]["__call"] = AnnomymousClass
    end

    -- Set Instace Method    
    local methods = class[ClassObjectMethodsName]
    methods["super"] = supercall
    methods["getClass"] = getClass
    methods["getClassName"] = getClassName
    methods["getParentClass"] = getParentClass
    methods["static"] = getStatic
    methods["rawget"] = InstanceRawget
    methods["rawset"] = InstanceRawset
    methods["is"] = isThisClass
    methods["isA"] = isA
    methods["clone"] = instanceClone
    methods["deepClone"] = instanceDeepClone

    class[ClassIndefity] = true

    -- Set Class Object Method
    class.is = isThisClass
    class.isA = isA
    class.new = new
    class.load = _load
    class.static = getStatic
    class.extends = extends
    class.getClass = getClass
    class.getProps = getClassProps
    class.getMethods = getClassMethods
    class.getStatics = getClassStatics
    class.defineProps = defineProps
    class.defineStatics = defineStatics
    class.getClassName = getClassName
    class.defineMethods = defineMethods
    class.getParentClass = getParentClass

    

    registerMetatableForClass(class)

    return class
end

local Object = Class("Object", {
    __tostring = function(self)
        return "[Object " .. getClassName(self) .. "]"
    end
})

local NullObject = Object:extends("NullObject", {
    __index = function(self, key)
        error("You try NullObject[" .. key .. "] , check your initializate variable in constructor")
    end,
    __newindex = function(self, key, value)
        error("You try NullObject[" .. key .. "] = " .. tostring(value) ..
                  " , check your constructor")
    end,
    __call = function(self, ...)
        error("You try to call NullObject , check your initializate variable in constructor")
    end,
    __tostring = function(self)
        error("You try to convert NullObject to string , check your initializate variable in constructor")
        return "Null Object"
    end,
    __len = function(self)
        error("You try to get length of NullObject , check your initializate variable in constructor")
    end,
    __lt = function(self, other)
        error("You try to compare NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __le = function(self, other)
        error("You try to compare NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __eq = function(self, other)
        error("You try to compare NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __concat = function(self, other)
        error("You try to concat NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __add = function(self, other)
        error("You try to add NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __sub = function(self, other)
        error("You try to sub NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __mul = function(self, other)
        error("You try to mul NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __div = function(self, other)
        error("You try to div NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __mod = function(self, other)
        error("You try to mod NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __pow = function(self, other)
        error("You try to pow NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __unm = function(self)
        error("You try to unm NullObject , check your initializate variable in constructor")
    end,
    __idiv = function(self, other)
        error("You try to idiv NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __band = function(self, other)
        error("You try to band NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __bor = function(self, other)
        error("You try to bor NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __bxor = function(self, other)
        error("You try to bxor NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __bnot = function(self)
        error("You try to bnot NullObject , check your initializate variable in constructor")
    end,
    __shl = function(self, other)
        error("You try to shl NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end,
    __shr = function(self, other)
        error("You try to shr NullObject with " .. tostring(other) ..
                  " , check your initializate variable in constructor")
    end
})()

return {
    Object = Object,
    Class = Class,
    null = NullObject
}
