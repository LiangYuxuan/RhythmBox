---@meta _
---@class TypeDataProvider<T>: DataProviderMixin
---@field callbackTables table<number, table<string, table<any, function>>>
---@field isUndefinedEventAllowed boolean?
---@field collection T[]
---@field sortComparator (fun(a: T, b: T): boolean?)?
local TypeDataProvider = {}

---@event TypeDataProvider.Event
---| "OnSizeChanged" -> sorting: boolean
---| "OnInsert" -> insertIndex: number, elementData: T, hasSortComparator: boolean
---| "OnRemove" -> elementData: T, index: number
---| "OnSort" ->
---| "OnMove" -> elementData: T, currentIndex: number, newIndex: number

-- CallbackRegistryMixin

function TypeDataProvider:OnLoad()
end

---@param allowed boolean
function TypeDataProvider:SetUndefinedEventsAllowed(allowed)
end

---@return table<number, table<string, table<any, function>>>
function TypeDataProvider:GetCallbackTables()
end

---@param callbackType number
---@return table<string, table<any, function>>
function TypeDataProvider:GetCallbackTable(callbackType)
end

---@param callbackType number
---@param event string
---@return table<any, function>
function TypeDataProvider:GetCallbacksByEvent(callbackType, event)
end

---@param callbackType number
---@param event string
---@return table<any, function>
function TypeDataProvider:GetMutableCallbacksByEvent(callbackType, event)
end

---@param event string
---@return boolean
function TypeDataProvider:HasRegistrantsForEvent(event)
end

---@param event string
function TypeDataProvider:SecureInsertEvent(event)
end

---@generic O
---@generic E: TypeDataProvider.Event
---@param event E
---@param func fun(owner: O, ...params<E>)
---@param owner O
---@param ... any
function TypeDataProvider:RegisterCallback(event, func, owner, ...)
end

---@generic O
---@generic E: TypeDataProvider.Event
---@param event E
---@param func fun(owner: O, ...params<E>)
---@param owner O
---@param ... any
function TypeDataProvider:RegisterCallbackWithHandle(event, func, owner, ...)
end

---@generic E: TypeDataProvider.Event
---@param event E
---@param closures table<any, function>
---@param funcs table<any, function>
function TypeDataProvider:ReconcileDeferredCallbacks(event, closures, funcs)
end

---@generic E: TypeDataProvider.Event
---@param callbackType number
---@param event E
---@param target table
function TypeDataProvider:CopyDeferredCallbacks(callbackType, event, target)
end

---@generic E: TypeDataProvider.Event
---@param event E
---@param ... params<E>
function TypeDataProvider:TriggerEvent(event, ...)
end

---@generic O
---@generic E: TypeDataProvider.Event
---@param event E
---@param owner O
function TypeDataProvider:UnregisterCallback(event, owner)
end

function TypeDataProvider:UnregisterEvents()
end

---@generic E: TypeDataProvider.Event
---@param eventTable E[]
function TypeDataProvider:UnregisterEventsByEventTable(eventTable)
end

---@generic E: TypeDataProvider.Event
---@param eventTable E[]
function TypeDataProvider:GenerateCallbackEvents(eventTable)
end

---@generic E: TypeDataProvider.Event
---@param frame TypeDataProvider
---@param event E
function TypeDataProvider.DoesFrameHaveEvent(frame, event)
end

-- DataProviderMixin

---@param tbl T[]
function TypeDataProvider:Init(tbl)
end

---@return false
function TypeDataProvider:IsVirtual()
end

---@param indexBegin number?
---@param indexEnd number?
---@return (fun(tbl: T[], index: number): number, T), T[], number
function TypeDataProvider:Enumerate(indexBegin, indexEnd)
end

---@return (fun(tbl: T[], index: number): number, T), T[], number
function TypeDataProvider:EnumerateEntireRange()
end

---@param indexBegin number?
---@param indexEnd number?
---@return (fun(tbl: T[], index: number): number, T), T[], number
function TypeDataProvider:ReverseEnumerate(indexBegin, indexEnd)
end

---@return (fun(tbl: T[], index: number): number, T), T[], number
function TypeDataProvider:ReverseEnumerateEntireRange()
end

---@return T[]
function TypeDataProvider:GetCollection()
end

---@return number
function TypeDataProvider:GetSize()
end

---@return boolean
function TypeDataProvider:IsEmpty()
end

---@private
---@param elementData T
---@param insertIndex number?
function TypeDataProvider:InsertInternal(elementData, insertIndex)
end

---@param elementData T
---@param insertIndex number?
function TypeDataProvider:InsertAtIndex(elementData, insertIndex)
end

---@param ... T
function TypeDataProvider:Insert(...)
end

---@param tbl T[]
function TypeDataProvider:InsertTable(tbl)
end

---@param tbl T[]
---@param indexBegin number
---@param indexEnd number
function TypeDataProvider:InsertTableRange(tbl, indexBegin, indexEnd)
end

---@param elementData T
---@param newIndex number?
function TypeDataProvider:MoveElementDataToIndex(elementData, newIndex)
end

---@param ... T
---@return number?
function TypeDataProvider:Remove(...)
end

---@param predicate fun(elementData: T): boolean?
function TypeDataProvider:RemoveAllByPredicate(predicate)
end

---@param predicate fun(elementData: T): boolean?
function TypeDataProvider:RemoveByPredicate(predicate)
end

---@param index number
function TypeDataProvider:RemoveIndex(index)
end

---@param indexBegin number?
---@param indexEnd number?
function TypeDataProvider:RemoveIndexRange(indexBegin, indexEnd)
end

---@param index number
---@param newElementData T
function TypeDataProvider:ReplaceAtIndex(index, newElementData)
end

---@param sortComparator fun(a: T, b: T): boolean
---@param skipSort boolean?
function TypeDataProvider:SetSortComparator(sortComparator, skipSort)
end

function TypeDataProvider:ClearSortComparator()
end

---@return boolean
function TypeDataProvider:HasSortComparator()
end

---@param sortComparator (fun(a: T, b: T): boolean)?
function TypeDataProvider:Sort(sortComparator)
end

---@param index number
---@return T?
function TypeDataProvider:Find(index)
end

---@return T?
function TypeDataProvider:FindLast()
end

---@param elementData T
---@return (number, T) | (nil)
function TypeDataProvider:FindIndex(elementData)
end

---@param predicate fun(elementData: T): boolean?
---@return (number, T) | (nil)
function TypeDataProvider:FindByPredicate(predicate)
end

---@param predicate fun(elementData: T): boolean?
---@return T?
function TypeDataProvider:FindElementDataByPredicate(predicate)
end

---@param predicate fun(elementData: T): boolean?
---@return number?
function TypeDataProvider:FindIndexByPredicate(predicate)
end

---@param predicate fun(elementData: T): boolean?
---@return boolean
function TypeDataProvider:ContainsByPredicate(predicate)
end

---@param func fun(elementData: T)
function TypeDataProvider:ForEach(func)
end

---@param func fun(elementData: T)
function TypeDataProvider:ReverseForEach(func)
end

function TypeDataProvider:Flush()
end
