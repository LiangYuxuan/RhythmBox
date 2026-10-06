---@meta _

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateContextMenu)
---@param ownerRegion Region? # if nil, defaults to UIParent
---@param generator fun(ownerRegion: Region, description: RootMenuDescriptionProxy, ...)
---@param ... any? # passed to the generator
---@return MenuProxy? menu
function MenuUtil.CreateContextMenu(ownerRegion, generator, ...) end

---@class ElementMenuFrame: Frame
---@field AttachTexture fun(self: self): Texture
---@field fontString FontString

---@alias MenuDescriptionInitializer fun(frame: ElementMenuFrame, elementDescription: ElementMenuDescriptionProxy, menu: MenuProxy): number, number
