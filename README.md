# TClass
![Version](https://img.shields.io/badge/version-0.1-blue.svg?cacheSeconds=2592000)

> TClass is an OOP library for Lua , help you programming naturally

## Example

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

Output :
```
kiki barks!
```

## Features
 - Easy to use 
 - Better Static Supports
 - Better Inheritance Supports
 - Meta methods support
 - Simmilar to Java (but not the same)
 - Optional Strict mode
 - Divide the data and methods


## Menu
- [Import to your project](#import-to-your-project)
- [Create a new class](#create-a-new-class)
- [Create an instance](#create-an-instance)
- [Define properties](#define-properties)
    - [Define properties](#define-properties)
    - [Notices](#notices)
    - [Strict mode](#strict-mode)
    - [Don't initialize instance in Options](#dont-initialize-instance-in-options)
- [Add methods to the class](#add-methods-to-the-class)
    - [Add methods](#Add-methods)
    - [Constructor](#constructor)
- [Statics](#statics)
    - [Declare statics](#declare-statics)
    - [Access statics](#access-statics)
    - [Notices](#notices-1)
- [Extends from classes](#extends-from-classes)
    - [Extends from classes](#extends-from-classes)
    - [Overriding methods and properties](#overriding-methods-and-properties)
    - [Call Super class method](#call-super-class-method)
- [MetaMethods](#metamethods)
- [is and isA](#is-and-isa)
- [Methods](#methods)
    - [Class methods](#class-methods)
    - [Instance methods](#instance-methods)
## Import to your project

```lua
local tclass = require ("tclass")
local Class = tclass.Class
local Object = tclass.Object
local null = tclass.null
```




Tclass export three main classes :
 - `Class` : A function to create a new class
 - `Object` : The base Class created by `Class`
 - `null` : A Object that represent nil or null value
 
 ## Create a new class
 Ways to create a new class :

1. Extends from `Object` (recommended)

```lua
local MyClass = Object:extends ("MyClass")
```

2. Using `Class` function

```lua
local MyClass = Class ("MyClass" , {})


```




`extends(SubClassname, [Options])` :
 - `ClassName` : The name of the new class
 - `Options` : The Class options (optional)

`Options` contains  properties and methods : 

```lua
local Object = require ("tclass").Object

local MyClass = Object:extends ("MyClass",{
    property = "value",
    method = function (self)
        print ("Hello World")
    end
})
```
The functions in `Options` will be added to the class as methods.

## Create an instance
### Create an instance
To create an instance:
`Class:new(args...)`
````lua
local Object = require ("tclass").Object
local MyClass = Object:extends ("MyClass")

local myObjectA = MyClass:new()
local myObjectB = MyClass()
````
If the class has a constructor, you can pass arguments to Constructor:

```lua
local Object = require ("tclass").Object
local MyClass = Object:extends ("MyClass")
function MyClass:constructor (label)
    print ("label")
end

MyClass("label")
```

## Define properties
### Define properties
To define properties :
1. using Options
2. using `defineProps` method
3. <del>Assign directly</del>
```lua
local Object = require ("tclass").Object

--- Using Options
local MyClass = Object:extends ("MyClass",{
    p= "value",
})

--- Using defineProps method
local MyClass2 = Object:extends ("MyClass2")
MyClass2:defineProps({
    p = "value",
})

local a = MyClass()
print (a.p) 

local b = MyClass2()
print (b.p) 

-- get Class properties
print(MyClass2:getProps()["p"])
```
Output :
```
value
value
value
```

The Class Method `getProps` returns the class properties.


### Notices :
- <i><b>If you assign a value directly to an instance, it will not be considered as a property , although it declared in the constructor.</b></i>
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
The output seems correct
But 'name' not considered as a property of Person
]]

print(Person:getProps()["name"]) -- will get nil

--[[
  When you extends the 'Person' class, 
  the problem will show up.
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

The `name` and `money` initialize in constructor , thought as properties but they are not. Class `Student` extends `Person` , inherited no `name` or `money` property.

Calling `sayHello` try to access the `money` , which is not copied with default values (not a property) , nor initialized in the constructor.


### Strict mode
Enable the strict mode cloud prevent that error.

Edit `tclass.lua` , change the `StrictMode` variable to `true` :
```lua
--.....other code
local StrictMode = true
--.....other code
```

Run the code again :
```
[Tclass] Error: You Cannot add a new property to an instance in strict mode
Stack trace:
stack traceback:
        .\tclass\init.lua:387: in function 'new'
        (...tail calls...)
        c:/Users/admin/Documents/Lua/Tclass/example/6.lua:13: in main chunk
        [C]: in ?
```

The correct version is :
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

### Don't initialize instance in Options
If your property is an instance , initialize it in constructor.
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

car 1,2,3 initialize with copying properties, but it's shallow copying.
Their `engine` are the same.

The correct Version:
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
`null` is a special Object , Any operation with it will raise an error.

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

## Add methods to the class
### Add methods
There are three ways to add methods to the class :
1. using Options
2. assign directly to the class
3. using `defineMethods` method

```lua
local Object = require ("tclass").Object
local Car = Object:extends ("Car",{
    owner = "John Doe",
    x = 0,
    y = 0,
    --- Method declarated by options
    printOwner = function (self)
        print (self.owner)
    end
})

--define methods by using 'defineMethods'
Car:defineMethods ({
    moveTo = function (self, x, y)
        self.x = x
        self.y = y
        print("Car moved to (".. x.. ", ".. y.. ")")
    end
})

--define methods directly
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

### Constructor
Constructor with method name `"constructor"` , when you using `ClassName:new()` or `ClassName()` , will call the constructor.

The first argument of the constructor should be always `self`.

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
Output :
```
Apple constructor called ,with value =  5
```
## Statics 
### Declare statics
Ways to add statics to the class :
1. Using Options
2. Using `defineStatics` method
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
Output :
```
a = 0
b = 1
```

### Access statics

Instances and Classes can both access statics.
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

### Notices
- <i><b>Defer from Java , Subclasses have their own statics , not the same as the parent class statics.</b></i>

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
Output :
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
`MyCounter` extends `Counter` , Inherits the statics of `Counter` . MyCounter has its own statics variable `count` with value `0` .


Although `MyCounter` call the `constructor` of `Counter` , the reference to `self.count` is `MyCounter.count`.

To count the subclass instances , you should change `self.count` to `Counter.count` .


```lua
---......other code
function Counter:constructor()
    self.id = Counter.count
    Counter.count = Counter.count + 1
    print("Counter (" .. self.id .. ") called")
end
---.....other code
```
Output :
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

## Extends from classes

### Extends from classes
Use `"ParentClass:extends(SubClassName, [Options])"` to extends a class from another class.

The SubClass will inherit the properties , methods ( including constructor ) and statics of the ParentClass.

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
### Overriding methods and properties
Define a method or property in the SubClass with the same name of method or property in the ParentClass will override it

the `moveTo` method and `wheelsNum` property are overridden:
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
Output : 
```
Car Owned by: John moved to (10,20)
Vehicle with 4 wheels at (10,20)
```
### Call Super class method
To call the super class method , use the `super` method of instances.

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
`super` always refers to the parent of class where the method is declared in, similar to `super` in Java.

## MetaMethods
### MetaMethods
Define methods with the same name of metatable methods' , will considere as metamethods.

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
Output :
```
Vector(4, 6)
```
`__add` and `__tostring` are metamethods.

Specially , if you override the `__index` or `__newindex` (Not recommended) , they will be called when member is not found in the properties , methods or statics.

If you override `__index` or `__newindex` , It's recommend to call `self:rawget(key)` or `self:rawset(key,value)` instead of `rawget` or `rawset`.

The example show the difference :
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
Output :
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
When `a` try to access `data1` , it will call `__index` , `rawget` try to get `data` directly from the table , but `data` is a static variable (virtual property) , so it will return `nil` .

When `a` try to set `data1` , it will call `__newindex` , `rawset` try to set `data` directly to the table . It seems to work fine. But `a.data` doesn't refers to the static variable `data` anymore, it refers to a property `data` , masking the static variable.

## `is` and `isA`
### `is` and `isA`
`is` and `isA` are two methods of instances and classes to check if an object is an instance of a class or a subclass of a class.

`is(ClassObject | className)` - is a Class or Class Instance

`isA (ClassObject | className)` - is a subclass or subclass's instance of a Class

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
Output :
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
## Methods
### Instance methods
 - `super("MethodName",arg1,arg2,...)`
 - `getClass()`
 - `getClassName()`
 - `getParentClass()`
 - `static()`   : get statics of the class
 - `rawget(key)`
 - `rawset(key,value)`
 - `is(ClassObject | className)`
 - `isA (ClassObject | className)`
 - `clone ([KeysNeedToDeepCopy])`
 - `deepClone([KeysNotNeedToDeepCopy])`

 ### Class methods
 - `is(ClassObject | className)`
 - `isA (ClassObject | className)`
 - `new(arg1,arg2,...)`
 - `load(datas : table)` : convert table to instance
 - `extends(SubClassName, [Options])`
 - `getClass()` : return self
 - `getProps()`
 - `getMethods()`
 - `getStatics()`
 - `defineProps(props : table)`
 - `defineStatics(statics : table)`
 - `defineMethods(methods : table)`
 - `getClassName()`
 - `getParentClass()`
## Author
👤 **Meainc**

* Github: [@Meainc](https://github.com/Meainc)

## Show your support

Give a ⭐️ if this project helped you!


***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_