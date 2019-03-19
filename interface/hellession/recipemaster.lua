require "/scripts/HLSNutil.lua"
require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.savedItemList = {} -- add items that are indexed by the player in other means, so that searching them up is way easier! ex. key-value pair: itemName = shortdescription
  self.state = 0
  self.arrivalState = nil
  self.additionalSearch = 2
  self.fuckingListMembers = {}
  self.savedStoredItems = {}
  initItemStuff()
end

function initItemStuff()
  --step 1/2: merge savedItemList with provided config items..
  ECUtil.mergeTable(self.savedItemList, config.getParameter("knownSortedItems", {}))
  --step 2/2: order the list provided in the config items of just itemIDs and add them to the list
  for k,v in ipairs(config.getParameter("knownItemIDs", {})) do
    local theItem = root.itemConfig({name=v})
    self.savedItemList[v] = theItem.config.shortdescription
  end
  local playerConfigStuff = root.assetJson("/player.config")
  for k,v in ipairs(playerConfigStuff.defaultBlueprints.tier1) do
    local theItem = root.itemConfig({name=v.item})
    if theItem then
    self.savedItemList[v.item] = theItem.config.shortdescription
    end
  end
end

function update(dt)
  if not (self.savedStoredItems == world.containerItems(pane.containerEntityId())) and (self.state == 0 or self.state == 2) then
    if #world.containerItems(pane.containerEntityId()) > 0 then
      widget.setVisible("LblSearch",false)
      widget.setVisible("goBackButton",false)
      widget.setVisible("addCharsButton", false)
      widget.setVisible("selectionButton", true)
      widget.setVisible("SearchImage", false)
      widget.setVisible("filter", false)
      self.state = 2
      if  #root.recipesForItem(world.containerItems(pane.containerEntityId())[1].name) == 0 then
        widget.setButtonEnabled("selectionButton", false)
        widget.setText("selectionButton", "No recipes")
      else
        widget.setButtonEnabled("selectionButton", true)
        widget.setText("selectionButton", "Recipes")
      end
    else
      widget.setVisible("scrollArea", false)
      widget.setVisible("LblSearchResult",false)
      widget.setVisible("LblSearch",true)
      widget.setVisible("Lbl",true)
      widget.setVisible("goBackButton",false)
      widget.setVisible("itemGrid",true)
      widget.setVisible("SearchImage", true)
      widget.setVisible("filter", true)
      widget.setVisible("addCharsButton", true)
      widget.setVisible("selectionButton", false)
      self.state = 0
    end
    self.savedStoredItems = world.containerItems(pane.containerEntityId())
  end
end

function filter()
  ECUtil.justLog(widget.getText("filter"))
  if not (widget.getText("filter") == "") then
    widget.setVisible("scrollArea", true)
    widget.setVisible("LblSearch",false)
    widget.setVisible("Lbl",false)
    widget.setVisible("itemGrid",false)
    widget.setVisible("goBackButton",false)
    widget.setVisible("LblSearchResult",true)
    widget.setVisible("SearchImage", true)
    widget.setVisible("filter", true)
    widget.setVisible("addCharsButton", false)
    searchWithKeyword(widget.getText("filter"))
    self.state = 1
  else
    widget.setVisible("scrollArea", false)
    widget.setVisible("LblSearchResult",false)
    widget.setVisible("LblSearch",true)
    widget.setVisible("Lbl",true)
    widget.setVisible("goBackButton",false)
    widget.setVisible("itemGrid",true)
    widget.setVisible("SearchImage", true)
    widget.setVisible("filter", true)
    widget.setVisible("addCharsButton", true)
    self.state = 0
  end
end

function searchWithKeyword(keyword)
  widget.clearListItems("scrollArea.itemList")
  self.fuckingListMembers = {}
  -- first simple test if it matches.
  widget.setText("LblSearchResult", "text")
  local textChangedYet = false
  if root.itemConfig({name=keyword}) then
    local ourItem = root.itemConfig({name=keyword})
    widget.setText("LblSearchResult", "Matching item found! The item is shown above. Select your item.")
    local newShit = "scrollArea.itemList." .. widget.addListItem("scrollArea.itemList")
    table.insert(self.fuckingListMembers, newShit)
    widget.setText(string.format("%s.itemName", newShit), ourItem.config.shortdescription .. " (" .. keyword .. ")")
    widget.setItemSlotItem(string.format("%s.itemIcon", newShit), {name=keyword})
    widget.setData(string.format("%s.itemName", newShit), {itemID = keyword})
    self.savedItemList[keyword] = ourItem.config.shortdescription
    textChangedYet = true
  end
  -- test number two: look up similar items by adding all alphabet letters and testing
  for i=1,26 do
    local testName = keyword .. ECUtil.numToLetter(i)
    if root.itemConfig({name=testName}) then
      if not textChangedYet then widget.setText("LblSearchResult", "We found similar item results!") textChangedYet = true end
      local ourItem = root.itemConfig({name=testName})
      local newShit = "scrollArea.itemList." .. widget.addListItem("scrollArea.itemList")
      table.insert(self.fuckingListMembers, newShit)
      widget.setText(string.format("%s.itemName", newShit), ourItem.config.shortdescription .. " (^orange;" .. keyword .. "^white;" .. ECUtil.numToLetter(i) .. ")")
      widget.setItemSlotItem(string.format("%s.itemIcon", newShit), {name=testName})
      widget.setData(string.format("%s.itemName", newShit), {itemID = testName})
      self.savedItemList[testName] = ourItem.config.shortdescription
    end
  end
  -- test number three: looks up similar items by adding 2 characters
  for i=1,26 do
    for u=1,26 do
      local testName = keyword .. ECUtil.numToLetter(i) .. ECUtil.numToLetter(u)
      if root.itemConfig({name=testName}) then
        if not textChangedYet then widget.setText("LblSearchResult", "We found similar item results!") textChangedYet = true end
        local ourItem = root.itemConfig({name=testName})
        local newShit = "scrollArea.itemList." .. widget.addListItem("scrollArea.itemList")
        table.insert(self.fuckingListMembers, newShit)
        widget.setText(string.format("%s.itemName", newShit), ourItem.config.shortdescription .. " (^orange;" .. keyword .. "^white;" .. ECUtil.numToLetter(i) .. ECUtil.numToLetter(u) .. ")")
        widget.setItemSlotItem(string.format("%s.itemIcon", newShit), {name=testName})
        widget.setData(string.format("%s.itemName", newShit), {itemID = testName})
        self.savedItemList[testName] = ourItem.config.shortdescription
      end
    end
  end
  -- more similar items check
  if self.additionalSearch == 3 then
    for i=1,26 do
      for u=1,26 do
        for y=1,26 do
          local testName = keyword .. ECUtil.numToLetter(i) .. ECUtil.numToLetter(u) .. ECUtil.numToLetter(y)
          if root.itemConfig({name=testName}) then
            if not textChangedYet then widget.setText("LblSearchResult", "We found similar item results!") textChangedYet = true end
            local ourItem = root.itemConfig({name=testName})
            local newShit = "scrollArea.itemList." .. widget.addListItem("scrollArea.itemList")
            table.insert(self.fuckingListMembers, newShit)
            widget.setText(string.format("%s.itemName", newShit), ourItem.config.shortdescription .. " (^orange;" .. keyword .. "^white;" .. ECUtil.numToLetter(i) .. ECUtil.numToLetter(u) .. ECUtil.numToLetter(y) .. ")")
            widget.setItemSlotItem(string.format("%s.itemIcon", newShit), {name=testName})
            widget.setData(string.format("%s.itemName", newShit), {itemID = testName})
            self.savedItemList[testName] = ourItem.config.shortdescription
          end
        end
      end
    end
  end
  -- from what we've saved so far, check for patterns in existing items!
  for itemName,friendlyName in pairs(self.savedItemList) do
    friendlyName = ECUtil.removeColorCodes(friendlyName)
    if string.find(itemName, keyword) and (not checkIfSameItemExistsInList(itemName)) then
      if not textChangedYet then widget.setText("LblSearchResult", "We found previously known similar items!") textChangedYet = true end
      local ourItem = root.itemConfig({name=itemName})
      local newShit = "scrollArea.itemList." .. widget.addListItem("scrollArea.itemList")
      table.insert(self.fuckingListMembers, newShit)
      local matchPosStart, matchPosEnd = string.find(itemName, keyword)

      local buildString = ""
      if matchPosStart > 1 then
        buildString = buildString .. string.sub(itemName, 1, matchPosStart-1)
      end
      buildString = buildString .. "^orange;" ..  string.sub(itemName, matchPosStart, matchPosEnd) .. "^reset;"
      if matchPosEnd < string.len(itemName) then
        buildString = buildString .. string.sub(itemName, matchPosEnd+1, string.len(itemName))
      end

      widget.setText(string.format("%s.itemName", newShit), ourItem.config.shortdescription .. " (" .. buildString .. ")")
      widget.setItemSlotItem(string.format("%s.itemIcon", newShit), {name=itemName})
      widget.setData(string.format("%s.itemName", newShit), {itemID = itemName})
      self.savedItemList[itemName] = ourItem.config.shortdescription
    end
    if string.find(friendlyName, keyword) and (not checkIfSameItemExistsInList(itemName)) then
      if not textChangedYet then widget.setText("LblSearchResult", "We found previously known similar items!") textChangedYet = true end
      local ourItem = root.itemConfig({name=itemName})
      local newShit = "scrollArea.itemList." .. widget.addListItem("scrollArea.itemList")
      table.insert(self.fuckingListMembers, newShit)
      local matchPosStart, matchPosEnd = string.find(friendlyName, keyword)

      local buildString = ""
      if matchPosStart > 1 then
        buildString = buildString .. string.sub(friendlyName, 1, matchPosStart-1)
      end
      buildString = buildString .. "^orange;" .. string.sub(friendlyName, matchPosStart, matchPosEnd) .. "^reset;"
      if matchPosEnd < string.len(friendlyName) then
        buildString = buildString .. string.sub(friendlyName, matchPosEnd+1, string.len(friendlyName))
      end

      widget.setText(string.format("%s.itemName", newShit), buildString .. " (" .. itemName .. ")")
      widget.setItemSlotItem(string.format("%s.itemIcon", newShit), {name=itemName})
      widget.setData(string.format("%s.itemName", newShit), {itemID = itemName})
      self.savedItemList[itemName] = ourItem.config.shortdescription
    end
  end
  if not textChangedYet then
    widget.setText("LblSearchResult", "No results found! Please remember that this uses technical item IDs.")
  end
end

function checkIfSameItemExistsInList(itemName)
  local result = false
  for k, v in ipairs(self.fuckingListMembers) do
    if widget.getData(v .. ".itemName").itemID == itemName then result = true end
  end
  return result
end

function x()
  pane.dismiss()
end

function itemSelected()
  local select = widget.getListSelected("scrollArea.itemList")
  if not select then
    widget.setVisible("selectionButton", false)
  else
    if self.state == 1 then
      local ourItemAgain = root.itemConfig({name=widget.getData("scrollArea.itemList." .. select .. ".itemName").itemID})
      if not ourItemAgain then
        ECUtil.errorEC("An item exists within the list that has a non-existant item(although the fact that it didn't error me indexing it just means that the data indexed before is NOT nil!). Check it please")
      else
        if  #root.recipesForItem(widget.getData("scrollArea.itemList." .. select .. ".itemName").itemID) == 0 then
          widget.setButtonEnabled("selectionButton", false)
          widget.setText("selectionButton", "No recipes")
        else
          widget.setButtonEnabled("selectionButton", true)
          widget.setText("selectionButton", "Recipes")
        end
      end
    end
    if self.state == 3 then
      widget.setButtonEnabled("selectionButton", true)
      widget.setText("selectionButton", "View Recipe")
    end
    widget.setVisible("selectionButton", true)
  end
end

function itemSelectedRecipeIn()
  local select = widget.getListSelected("inputLabelScroll.itemList")
  if not select then
    widget.setVisible("selectionButton", false)
  else
    reloadOut()
    local ourItemAgain = root.itemConfig({name=widget.getData("inputLabelScroll.itemList." .. select .. ".itemName").itemID})
    if not ourItemAgain then
      ECUtil.errorEC("An item exists within the list that has a non-existant item(although the fact that it didn't error me indexing it just means that the data indexed before is NOT nil!). Check it please")
    else
      if  #root.recipesForItem(widget.getData("inputLabelScroll.itemList." .. select .. ".itemName").itemID) == 0 then
        widget.setButtonEnabled("selectionButton", false)
        widget.setText("selectionButton", "No recipes")
      else
        widget.setButtonEnabled("selectionButton", true)
        widget.setText("selectionButton", "Recipes")
      end
    end
    widget.setVisible("selectionButton", true)
  end
end

function itemSelectedRecipeOut()
  local select = widget.getListSelected("outputLabelScroll.itemList")
  if not select then
    widget.setVisible("selectionButton", false)
  else
    reloadIn()
    local ourItemAgain = root.itemConfig({name=widget.getData("outputLabelScroll.itemList." .. select .. ".itemName").itemID})
    if not ourItemAgain then
      ECUtil.errorEC("An item exists within the list that has a non-existant item(although the fact that it didn't error me indexing it just means that the data indexed before is NOT nil!). Check it please")
    else
      if  #root.recipesForItem(widget.getData("outputLabelScroll.itemList." .. select .. ".itemName").itemID) == 0 then
        widget.setButtonEnabled("selectionButton", false)
        widget.setText("selectionButton", "No recipes")
      else
        widget.setButtonEnabled("selectionButton", true)
        widget.setText("selectionButton", "Recipes")
      end
    end
    widget.setVisible("selectionButton", false)
  end
end

function selectionButtonAction()
  if self.state == 3 then
    self.recipeData = widget.getData("scrollArea.itemList." .. widget.getListSelected("scrollArea.itemList") .. ".itemName").recipe
    widget.setVisible("scrollArea", false)
    widget.setVisible("selectionButton", false)
    self.state = 4
    loadRecipe()
  elseif self.state == 1 then
    self.recipiesFor = widget.getData("scrollArea.itemList." .. widget.getListSelected("scrollArea.itemList") .. ".itemName").itemID
    widget.setVisible("SearchImage", false)
    widget.setVisible("filter", false)
    self.arrivalState = 1
    self.state = 3
    loadRecipeList()
  elseif self.state == 4 then
    self.recipiesFor = widget.getData("inputLabelScroll.itemList." .. widget.getListSelected("inputLabelScroll.itemList") .. ".itemName").itemID
    widget.setVisible("SearchImage", false)
    widget.setVisible("filter", false)
    self.arrivalState = 1
    self.state = 3
    loadRecipeList()
  elseif self.state == 2 then
    self.recipiesFor = world.containerItems(pane.containerEntityId())[1].name
    widget.setVisible("Lbl", false)
    widget.setVisible("itemGrid", false)
    widget.setVisible("LblSearchResult", true)
    self.arrivalState = 2
    self.state = 3
    loadRecipeList()
  end
end

function reloadOut()
  widget.clearListItems("outputLabelScroll.itemList")
  local outputItem = "outputLabelScroll.itemList." .. widget.addListItem("outputLabelScroll.itemList")
  local outputItemConfig = root.itemConfig({name=self.recipeData.output.name})
  widget.setText(string.format("%s.itemName", outputItem), outputItemConfig.config.shortdescription .. " (" .. tostring(self.recipeData.output.count) .. "x)")
  widget.setItemSlotItem(string.format("%s.itemIcon", outputItem), {name=self.recipeData.output.name})
  widget.setData(string.format("%s.itemName", outputItem), {itemID = self.recipeData.output.name})
  self.savedItemList[self.recipeData.output.name] = outputItemConfig.config.shortdescription
end

function reloadIn()
  widget.clearListItems("inputLabelScroll.itemList")
  for k,v in ipairs(self.recipeData.input) do
    local inputItem = "inputLabelScroll.itemList." .. widget.addListItem("inputLabelScroll.itemList")
    local inputItemConfig = root.itemConfig({name=v.name})
    widget.setText(string.format("%s.itemName", inputItem), inputItemConfig.config.shortdescription .. " (" .. tostring(v.count) .. "x)")
    widget.setItemSlotItem(string.format("%s.itemIcon", inputItem), {name=v.name})
    widget.setData(string.format("%s.itemName", inputItem), {itemID = v.name})
    self.savedItemList[v.name] = inputItemConfig.config.shortdescription
  end
  if self.recipeData.currencyInputs then
    for k,v in pairs(self.recipeData.currencyInputs) do
      local inputItem = "inputLabelScroll.itemList." .. widget.addListItem("inputLabelScroll.itemList")
      local inputItemConfig = root.itemConfig({name=k})
      widget.setText(string.format("%s.itemName", inputItem), inputItemConfig.config.shortdescription .. " (" .. tostring(v) .. "x)")
      widget.setItemSlotItem(string.format("%s.itemIcon", inputItem), {name=k})
      widget.setData(string.format("%s.itemName", inputItem), {itemID = k})
      self.savedItemList[k] = inputItemConfig.config.shortdescription
    end
  end
end

function loadRecipe()
  widget.clearListItems("inputLabelScroll.itemList")
  widget.clearListItems("outputLabelScroll.itemList")
  widget.setVisible("inputLabel", true)
  widget.setVisible("outputLabel", true)
  widget.setVisible("inputLabelScroll", true)
  widget.setVisible("outputLabelScroll", true)
  local outputItem = "outputLabelScroll.itemList." .. widget.addListItem("outputLabelScroll.itemList")
  local outputItemConfig = root.itemConfig({name=self.recipeData.output.name})
  widget.setText(string.format("%s.itemName", outputItem), outputItemConfig.config.shortdescription .. " (" .. tostring(self.recipeData.output.count) .. "x)")
  widget.setItemSlotItem(string.format("%s.itemIcon", outputItem), {name=self.recipeData.output.name})
  widget.setData(string.format("%s.itemName", outputItem), {itemID = self.recipeData.output.name})
  self.savedItemList[self.recipeData.output.name] = outputItemConfig.config.shortdescription
  for k,v in ipairs(self.recipeData.input) do
    local inputItem = "inputLabelScroll.itemList." .. widget.addListItem("inputLabelScroll.itemList")
    local inputItemConfig = root.itemConfig({name=v.name})
    widget.setText(string.format("%s.itemName", inputItem), inputItemConfig.config.shortdescription .. " (" .. tostring(v.count) .. "x)")
    widget.setItemSlotItem(string.format("%s.itemIcon", inputItem), {name=v.name})
    widget.setData(string.format("%s.itemName", inputItem), {itemID = v.name})
    self.savedItemList[v.name] = inputItemConfig.config.shortdescription
  end
  if self.recipeData.currencyInputs then
    for k,v in pairs(self.recipeData.currencyInputs) do
      local inputItem = "inputLabelScroll.itemList." .. widget.addListItem("inputLabelScroll.itemList")
      local inputItemConfig = root.itemConfig({name=k})
      widget.setText(string.format("%s.itemName", inputItem), inputItemConfig.config.shortdescription .. " (" .. tostring(v) .. "x)")
      widget.setItemSlotItem(string.format("%s.itemIcon", inputItem), {name=k})
      widget.setData(string.format("%s.itemName", inputItem), {itemID = k})
      self.savedItemList[k] = inputItemConfig.config.shortdescription
    end
  end
  local blueprintStat = ""
  if player.blueprintKnown({name=self.recipeData.output.name}) then
    blueprintStat = "^green;Yes^reset;"
  else
    blueprintStat = "^red;No^reset;"
  end
  widget.setText("LblSearchResult", "Recipe for " .. outputItemConfig.config.shortdescription .. " crafted at " .. filterToStationName(self.recipeData) .. ". Blueprint known: " .. blueprintStat .. ". Click an input item to view how it is crafted.")
end

function loadRecipeList()
  widget.clearListItems("scrollArea.itemList")
  local blueprintStat
  if player.blueprintKnown({name=self.recipiesFor}) then
    blueprintStat = "^green;Yes^reset;"
  else
    blueprintStat = "^red;No^reset;"
  end
  widget.setText("LblSearchResult", "Select your recipe above. Blueprint known: " .. blueprintStat .. ".")
  widget.setVisible("inputLabel", false)
  widget.setVisible("outputLabel", false)
  widget.setVisible("inputLabelScroll", false)
  widget.setVisible("scrollArea", true)
  widget.setVisible("outputLabelScroll", false)
  widget.setVisible("goBackButton", true)
  self.itemRecipies = root.recipesForItem(self.recipiesFor)
  ECUtil.justLog(self.itemRecipies)
  for k,v in ipairs(self.itemRecipies) do
    local ourItem = root.itemConfig({name=self.recipiesFor})
    local newShit = "scrollArea.itemList." .. widget.addListItem("scrollArea.itemList")
    widget.setText(string.format("%s.itemName", newShit), ourItem.config.shortdescription .. " recipe at " .. filterToStationName(v))
    widget.setItemSlotItem(string.format("%s.itemIcon", newShit), {name=self.recipiesFor})
    widget.setData(string.format("%s.itemName", newShit), {recipe=v})
  end
end

function backAction()
  if self.state == 3 then
    self.state = self.arrivalState
    filter()
  end
  if self.state == 4 then
    self.state = 3
    loadRecipeList()
  end
end

function switchAddChars()
  if self.additionalSearch == 2 then
    self.additionalSearch = 3
    widget.setButtonImages("addCharsButton", {
      base = "/interface/hellession/additionalchars3.png",
      hover = "/interface/hellession/additionalchars3hover.png"
    })
  else
    self.additionalSearch = 2
    widget.setButtonImages("addCharsButton", {
      base = "/interface/hellession/additionalchars2.png",
      hover = "/interface/hellession/additionalchars2hover.png"
    })
  end
end

function filterToStationName(recipeConfig)
  local outputList = recipeConfig.groups
  local toReturn = "Unknown"
  for k,v in pairs(outputList) do
    if not (v=="all") then if not (filterNameToFriendly(v) == "Unknown") then toReturn = filterNameToFriendly(v) end end
  end
  return toReturn
end

-- Enum functions below
function filterNameToStation(filterName)

end

function filterNameToFriendly(filterName)
  local database = config.getParameter("filterNameToFriendly")
  for k,v in pairs(database) do
    if k == filterName then return v end
  end
  return "Unknown"
end
