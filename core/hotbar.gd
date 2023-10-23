@icon("res://addons/inventory-system/icons/hotbar.svg")
extends NodeInventorySystemBase
class_name Hotbar

signal selection_changed(selection_index)


@export var inventory : Inventory

@export var slots_in_hot_bar := 8

var selection_index := -1

func _ready():
	super._ready()
	if inventory != null:
		inventory.updated_slot.connect(_on_updated_slot)


func change_selection(index : int):
	if index < 0 or index >= slots_in_hot_bar:
		return
	set_selection_index(index)


func next_item():
	set_selection_index(selection_index - 1)


func previous_item():
	set_selection_index(selection_index + 1)


func select_none():
	selection_index = -1
	selection_changed.emit(selection_index)


func set_selection_index(new_index : int):
	if new_index >= slots_in_hot_bar:
		new_index -= slots_in_hot_bar
	if new_index < 0:
		new_index += slots_in_hot_bar
	if selection_index != new_index:
		selection_index = new_index
		selection_changed.emit(selection_index)


func has_valid_item_id() -> bool:
	if selection_index < 0 or selection_index >= inventory.slots.size():
		return false
	var slot = inventory.slots[selection_index]
	if slot == null:
		return false
	return slot.item != null


func has_item_on_selection() -> bool:
	if not has_valid_item_id():
		return false
	return true


func get_selected_item() -> InventoryItem:
	if not has_valid_item_id():
		return null
	return inventory.slots[selection_index].item


func _on_updated_slot(slot_index : int):
	# TODO: Why is this necessary?
	if slot_index == selection_index:
		set_selection_index(selection_index)
