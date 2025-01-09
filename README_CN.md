# TClass
![Version](https://img.shields.io/badge/version-0.1-blue.svg?cacheSeconds=2592000)

> TClass 是一个Lua的面对对象库，帮助你自然地在Lua使用面对对象

[ [English](README.md) | [中文](README_CN.md) ]
## 示例

```lua
local Object = require ("tclass").Object

local Dog = Object:extends ("Dog",{
    name = "Dog",
})
function Dog:constructor (name)
    self.name = name
end
function Dog:bark ()
    print (self.name .. " barks!")
end

local myDog = Dog ("kiki")
myDog:bark ()
```

输出 :
```
kiki barks!
```

## 特性
 - 使用简单
 - 更好的静态支持
 - 更好的继承支持
 - 元方法支持
 - 和Java机制类似
 - 可选择的严格模式
 - 将实例的数据和方法区分 (方法都在metatable)


## 菜单
- [导入项目](#导入项目)
- [创建一个新的类](#创建一个新的类)
- [创建一个实例](#创建一个实例)
- [定义属性](#定义属性)
    - [定义属性](#定义属性-1)
    - [注意事项](#注意事项)
    - [严格模式](#严格模式)
    - [不要再类选项中初始化实例](#不要在类选项中初始化实例)
- [#添加方法到类](#添加方法到类)
    - [#添加方法到类](#添加方法到类-1)
    - [构造函数](#构造函数)
- [静态变量](#静态变量)
    - [定义静态变量](#定义静态变量)
    - [访问静态变量](#访问静态变量)
    - [注意事项](#注意事项-)
- [继承自其他类](#继承自其他类)
    - [继承自其他类](#继承自其他类)
    - [覆盖方法和属性](#覆盖方法和属性)
    - [调用父类方法](#调用父类方法)
- [元方法](#元方法)
- [is 和 isA](#is-和-isa)
- [所有方法](#所有方法)
    - [实例对象方法](#实例对象方法)
    - [类的方法](#类的方法)
## 导入项目

```lua
local tclass = require ("tclass")
local Class = tclass.Class
local Object = tclass.Object
local null = tclass.null
```




Tclass 导出三个模块 :
 - `Class` : 用来创建类的函数
 - `Object` : 定义好的基类
 - `null` : 一个特殊对象用来代替nil
 
 ## 创建一个新的类

1. 从 `Object` 继承创建 (推荐)

```lua
local MyClass = Object:extends ("MyClass")
```

2. 用 `Class` 函数创建

```lua
local MyClass = Class ("MyClass" , {})


```




`extends(SubClassname, [Options])` :
 - `ClassName` : 类名
 - `Options` : 类选项 (可选)

`Options` 包含属性和方法 : 

```lua
local Object = require ("tclass").Object

local MyClass = Object:extends ("MyClass",{
    property = "value",
    method = function (self)
        print ("Hello World")
    end
})
```
在 `Options` 里的函数会作为方法被添加到类中

## 创建一个实例
### 创建一个实例
创建一个实例:
`Class:new(args...)`
````lua
local Object = require ("tclass").Object
local MyClass = Object:extends ("MyClass")

local myObjectA = MyClass:new()
local myObjectB = MyClass()
````
如果这个函数的构造函数有参数，可以在创建实例的时候传入参数：

```lua
local Object = require ("tclass").Object
local MyClass = Object:extends ("MyClass")
function MyClass:constructor (label)
    print ("label")
end

MyClass("label")
```

## 定义属性
### 定义属性
1. 用类选项定义
2. 用 `defineProps` 方法
3. <del>直接赋值</del>
```lua
local Object = require ("tclass").Object

--- 用类选项定义
local MyClass = Object:extends ("MyClass",{
    p= "value",
})

--- 用 `defineProps` 方法
local MyClass2 = Object:extends ("MyClass2")
MyClass2:defineProps({
    p = "value",
})

local a = MyClass()
print (a.p) 

local b = MyClass2()
print (b.p) 

-- 获取类属性
print(MyClass2:getProps()["p"])
```
输出 :
```
value
value
value
```

方法 `getProps` 返回类属性集合.


### 注意事项 :
- <i><b>如果你直接给一个实例的成员赋值, 他不会被当作类属性 , 就算赋值过程在构造方法里面.</b></i>
```lua
local Object = require ("tclass").Object
local Person = Object:extends ("Person")
function Person:constructor (name)
  self.name = name
  self.money = 0
end

function Person:sayHello ()
  print ("Hello, my name is ".. self.name)
  print ("I have $".. self.money)
end

local jack = Person ("Jack")
jack:sayHello ()

--[[
输出看似正常
实际上 name 不是一个类属性
]]

print(Person:getProps()["name"]) -- will get nil

--[[
  当继承Person时 问题就出现了
]]
local Student = Person:extends ("Student")
function Student:constructor (name, grade)
    self.grade = grade
    self.name = name
end

local Lucy = Student ("Lucy")
Lucy:sayHello ()
```

Output :
```
Hello, my name is Jack
I have $0
nil
Hello, my name is Lucy
C:\Users\admin\AppData\Local\Programs\Lua\bin\lua.exe: c:/Users/admin/Documents/Lua/Tclass/example/6.lua:10: attempt to concatenate a nil value (field 'money')
stack traceback:
        c:/Users/admin/Documents/Lua/Tclass/example/6.lua:10: in method 'sayHello'
        c:/Users/admin/Documents/Lua/Tclass/example/6.lua:34: in main chunk
        [C]: in ?
```

 `name` 和 `money` 在构造函数被赋值 , 被误认为是属性，但是其实他们不是.  `Student` 类继承自 `Person` , 但是没有继承到 `name` 或者 `money` 属性.

调用 `sayHello` 方法 ，尝试获取 `money` , 但是它既没有作为属性在初始化的时候被复制下来 , 又没有在构造函数被声明.


### 严格模式
用严格模式可以预防这类错误

编辑 `tclass.lua` ,把 `StrictMode` 变量的值改成 `true` :
```lua
--.....other code
local StrictMode = true
--.....other code
```

重新运行代码，在尝试赋值不存在的属性时会得到错误 :
```
[Tclass] Error: You Cannot add a new property to an instance in strict mode
Stack trace:
stack traceback:
        .\tclass\init.lua:387: in function 'new'
        (...tail calls...)
        c:/Users/admin/Documents/Lua/Tclass/example/6.lua:13: in main chunk
        [C]: in ?
```

正确的版本是 :
```lua
local Person = Object:extends ("Person" , {
  name = "unknown",
  money = 0
})
......
local Student = Person:extends ("Student",{
  grade = 1
})
......
```

### 不要在类选项中初始化实例
如果你的类中有一个属性类型是实例对象，你应该在构造函数对他进行初始化
```lua
local Object = require ("tclass").Object
local Engine = Object:extends("Engine",{
    isBroken = false,
})
function Engine:constructor()
    print("Engine created.")
end

local Car = Object:extends("Car",{
    engine = Engine(),
    name = "Unnamed Car"
})
function Car:constructor(name)
    self.name = name
end
function Car:start()
    if self.engine.isBroken then
        print(self.name..": Engine is broken, cannot start.")
    else
        print(self.name..": Engine is working, starting the car.")
    end
end

local car1 = Car("car1")
local car2 = Car("car2")
local car3 = Car("car3")
car1:start()
car2:start()
car3:start()
print("-----------------------------")
car1.engine.isBroken = true
car1:start()
car2:start()
car3:start()
```
Output :
```
Engine created.
car1: Engine is working, starting the car.
car2: Engine is working, starting the car.
car3: Engine is working, starting the car.
-----------------------------
car1: Engine is broken, cannot start.
car2: Engine is broken, cannot start.
car3: Engine is broken, cannot start.
```

car 1,2,3 初始化的时候经过了复制属性, 但是复制过程是浅拷贝.
所以他们的 `engine` 属性实际上是同一个实例对象.

正确的版本应该是 :
```lua
local null = require ("tclass").null
---......other code
local Car = Object:extends("Car",{
    engine = null,
    name = "Unnamed Car"
})
function Car:constructor(name)
    self.name = name
    self.engine = Engine()
end
---.....other code
```
`null` 是一个特殊的对象 ,对他进行任何操作都会收到错误.

```lua
local null = require ("tclass").null
local b = null
local a = b + 5
```
Output :
```
[Tclass] Error: You try to add NullObject with 5 , check your initializate variable in constructor
Stack trace:
stack traceback:
        [C]: in ?
```

## 添加方法到类
### 添加方法到类

1. 使用类属性
2. 直接赋值给类
3. 用 `defineMethods` 方法

```lua
local Object = require ("tclass").Object
local Car = Object:extends ("Car",{
    owner = "John Doe",
    x = 0,
    y = 0,
    --- 使用类属性
    printOwner = function (self)
        print (self.owner)
    end
})

--用 `defineMethods` 方法
Car:defineMethods ({
    moveTo = function (self, x, y)
        self.x = x
        self.y = y
        print("Car moved to (".. x.. ", ".. y.. ")")
    end
})

--直接赋值给类
function Car:info()
    print("Car Info:")
    print("------------------------")
    print("Owner: ".. self.owner)
    print("X: ".. self.x)
    print("Y: ".. self.y)
end

local myCar = Car()
myCar:printOwner()
myCar:moveTo(10,20)
myCar:info()

--get methods of a class
print(Car:getMethods()["info"])
```
Output :
````
John Doe
Car moved to (10, 20)
Car Info:
------------------------
Owner: John Doe
X: 10
Y: 20
function: 0000020C64F10F50
````

### 构造函数
方法名为 `"constructor"` 的是构造函数 , 你在使用 `ClassName:new()` 或者 `ClassName()` 的时候会调用构造函数

构造函数的第一个参数应该为 `self`.

```lua
local Object = require ("tclass").Object
local Apple = Object:extends ("Apple",{
    value = 0,
})
function Apple:constructor (value)
    print ("Apple constructor called ,with value = ",value)
    self.value = value
end
Apple(5)
```
输出 :
```
Apple constructor called ,with value =  5
```
## 静态变量 
### 定义静态变量
1. 用类属性
2. 用 `defineStatics` 方法
```lua
local Object = require ("tclass").Object
local MyClass = Object:extends ("MyClass",{
    static = {
        a = 0,
    }
})
MyClass:defineStatics({
    b = 1,
})
print ("a = " .. MyClass.a)
print ("b = " .. MyClass.b)
```
输出 :
```
a = 0
b = 1
```

### 访问静态变量

类和实例对象都能访问静态变量
```lua
local Object = require ("tclass").Object
local Counter = Object:extends("Counter",{
    static = {
        count = 0
    },
    id = -1
})
function Counter:constructor()
    self.id = self.count
    self.count = self.count + 1
    print ("New Counter created with id: ".. self.id)
end
Counter()
Counter.count = 10
local c = Counter()
c.count = 20
Counter()
print (Counter.count)
```
Output :

```
New Counter created with id: 0
New Counter created with id: 10
New Counter created with id: 20
21
```

### 注意事项
- <i><b>和Java不一样的是，子类拥有独立的静态变量空间</b></i>

```lua
local Object = require("tclass").Object
local Counter = Object:extends("Counter", {
    static = {
        count = 0
    },
    id = 0
})
function Counter:constructor()
    self.id = self.count
    self.count = self.count + 1
    print("Counter (" .. self.id .. ") called")
end
local MyCounter = Counter:extends("MyCounter")
function MyCounter:constructor()
    self:super("constructor")
    print("MyCounter (" .. self.id .. ") called")
end
Counter()
print("---------------")
Counter()
print("---------------")
Counter()
print("---------------")
MyCounter()
```
输出 :
```
Counter (0) called
---------------
Counter (1) called
---------------
Counter (2) called
---------------
Counter (0) called
MyCounter (0) called
```
`MyCounter` 继承自 `Counter` ,获得 `Counter` 的静态变量. `MyCounter` 有他自己的静态变量 `count` = `0` .


尽管 `MyCounter` 调用了 `Counter` 的 `constructor` (构造函数)  , 但是 `self.count` 指的还是 `MyCounter.count`.

如果你要统计子类的对象的数量,把 `self.count` 改成 `Counter.count` .


```lua
---......other code
function Counter:constructor()
    self.id = Counter.count
    Counter.count = Counter.count + 1
    print("Counter (" .. self.id .. ") called")
end
---.....other code
```
输出 :
```
Counter (0) called
---------------
Counter (1) called
---------------
Counter (2) called
---------------
Counter (3) called
MyCounter (3) called
```

## 继承自其他类

### 继承自其他类
用 `"父类:extends(子类名 : 字符串, [类选项])"` 来继承应该类

子类会从父类继承属性 , 方法 ( 包括构造器 ) 和 静态变量

```lua
local Object = require("tclass").Object
local Test1 = Object:extends("Test1",{
    a = 5,
    b = 10,
    str = "hello",
    static = {
        c = 15
    }
})
function Test1:constructor(str)
    self.str = str
end
function Test1:test()
    print(self.a, self.b, self.c)
end

local Test2 = Test1:extends("Test2",{})
local test2 = Test2("test2")
test2:test() 
```
Output :
```
5       10      15
```
### 覆盖方法和属性
给子类声明和父类同名的方法或者属性,会覆盖父类的方法或者属性

下面 `moveTo` 方法 和 `wheelsNum` 属性就被覆盖了:
```lua
local Object = require("tclass").Object
local Vehicle = Object:extends("Vehicle",{
    owner = "unknown",
    x = 0,
    y= 0,
    wheelsNum = 0;
})
function Vehicle:constructor(owner)
    self.owner = owner
end

function Vehicle:moveTo (x,y)
    self.x = x
    self.y = y
    print("Vehicle Owned by: ".. self.owner.. " moved to (".. self.x.. ",".. self.y.. ")")
end

function Vehicle:info ()
    print("Vehicle with ".. self.wheelsNum.." wheels at (".. self.x.. ",".. self.y.. ")")
end
local Car = Vehicle:extends("Car" , {
    wheelsNum = 4;
})
function Car:moveTo (x,y)
    self.x = x
    self.y = y
    print("Car Owned by: ".. self.owner.. " moved to (".. self.x.. ",".. self.y.. ")")
end

local car = Car("John")
car:moveTo(10,20)
car:info()

```
输出 : 
```
Car Owned by: John moved to (10,20)
Vehicle with 4 wheels at (10,20)
```
### 调用父类方法
用`super` 方法可以调用父类方法

`super("methodName",arg1,arg2,...)`
```lua
local Object = require("tclass").Object

local MyClass = Object:extends("MyClass")
function MyClass:info(str)
    print("MyClass info: ".. str)
end


local MyClass2 = MyClass:extends("MyClass2")
function MyClass2:info(str)
    self:super("info",str)
    print("MyClass2 info: "..str)
end

local MyClass3 = MyClass2:extends("MyClass3")
local MyClass4 = MyClass3:extends("MyClass4")
MyClass4():info("hello")

```

Output :
```
MyClass info: hello
MyClass2 info: hello
```
`super` 指方法所在的类的父类 , 这一点和Java的super关键字类似

## 元方法
### 元方法
用metatable元方法的名字来定义类的方法,这个方法会被视为元方法

```lua

local Object = require ("tclass").Object
local null = require ("tclass").null
local Vector = Object:extends("Vector",{
    x = null,
    y = null,
})

function Vector:constructor(x, y)
    self.x = x
    self.y = y
end

function Vector:__add(v)
    return Vector(self.x + v.x, self.y + v.y)
end

function Vector:__tostring()
    return "Vector(".. self.x.. ", ".. self.y.. ")"
end

local v1 = Vector(1, 2)
local v2 = Vector(3, 4)
print(v1+v2)
```
输出` :
```
Vector(4, 6)
```
`__add` 和 `__tostring` 是元方法.

特别的 , 如果你覆写 `__index` or `__newindex` (不推荐) ,他们会在实例的成员,属性,静态变量和方法都找不到的时候调用.

如果你覆写了 `__index` 或者 `__newindex` , 最好调用 `self:rawget(key)` 或者 `self:rawset(key,value)` 而不是 `rawget` 或者 `rawset`.

下面的例子展示了二者的不同之处 :
```lua
local Object = require ("tclass").Object
local MyClass = Object:extends("MyClass",{
    static = {
        data = 5
    },
    __newindex = function(self, key, value) 
        if key == "data1" then
            rawset (self, "data", value) 
        end
    end,
    __index = function(self, key)
        if key == "data1" then
            return rawget (self, "data")
        end
    end
})

local MyClass2 = MyClass:extends("MyClass2",{
    __newindex = function(self, key, value) 
        if key == "data1" then
            self:rawset ("data", value) 
        end
    end,
    __index = function(self, key)
        if key == "data1" then
            return self:rawget ("data")
        end
    end
})
local a = MyClass()
print(a.data1)
a.data1 = 10
print(a.data)
print(a.data1)
print(MyClass.data)
print ("====================")
local b = MyClass2()
print(b.data1)
b.data1 = 10
print(b.data)
print(b.data1)
```
输出 :
```
nil
10
10
5
====================
5
10
10
```
当 `a` 尝试访问属性 `data1` ,  `__index` 方法会被调用, `rawget` 尝试直接从表中获取 `data`  , 但是 `data` 是一个类静态变量 (虚拟属性) ,无法获取, 所以会返回一个 `nil` .

当 `a` 尝试赋值 `data1` ,  `__newindex` 会被调用 , `rawset` 尝试直接设置 `data` 到表中 . 看起来这个方法是可以的. 但是现在 `a.data` 其实不再指向原来的虚拟方法,即静态变量 `data` , 而是指向一个属性 `data` , 这个属性覆盖了原来的`data`.

## `is` 和 `isA`
### `is` 和 `isA`
`is` 和 `isA` 是两个方法检查类和实例直接的关系

`is(ClassObject | className)` - 是否来自同一个类

`isA (ClassObject | className)` - 来自同一个类或者这个类的子类

```lua
local Vehicle = Object:extends("Vehicle")
local Car = Vehicle:extends("Car")
local Truck = Car:extends("Truck")

print (Car:isA(Truck))
print (Truck:isA(Car))
print (Truck:isA("Vehicle"))

print("---------------------")

local car = Car()
local truck = Truck()

print (car:isA(Car))
print (car:isA(Truck))
print (truck:isA(Car))
print (truck:isA(Truck))

print ("----------------------")

print(car:is(Car))
print(car:is(Vehicle))
```
输出 :
```
false
true
true
---------------------
true
false
true
true
----------------------
true
false
```
## 所有方法
### 实例对象方法
 - `super("MethodName",arg1,arg2,...)`
 - `getClass()`
 - `getClassName()`
 - `getParentClass()`
 - `static()`   : 获取静态变量
 - `rawget(key)`
 - `rawset(key,value)`
 - `is(ClassObject | className)`
 - `isA (ClassObject | className)`
 - `clone ([KeysNeedToDeepCopy])`
 - `deepClone([KeysNotNeedToDeepCopy])`

 ### 类的方法
 - `is(ClassObject | className)`
 - `isA (ClassObject | className)`
 - `new(arg1,arg2,...)`
 - `load(datas : table)` : 把一个 table 变成实例对象
 - `extends(SubClassName, [Options])`
 - `getClass()` : 返回自己
 - `getProps()`
 - `getMethods()`
 - `getStatics()`
 - `defineProps(props : table)`
 - `defineStatics(statics : table)`
 - `defineMethods(methods : table)`
 - `getClassName()`
 - `getParentClass()`
## 作者
👤 **Meainc**

* Github: [@Meainc](https://github.com/Meainc)

## 支持

如果这个项目对你有帮助,给我一个 ⭐️ !


***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_