@tool
extends Control
class_name CraftStationTypesEditor

var database : InventoryDatabase
var editor_plugin : EditorPlugin

@onready var craft_station_type_editor : CraftStationTypeEditor = $HSplitContainer/CraftStationTypeEditor
@onready var new_craft_station_type_dialog : FileDialog = $NewCraftStationTypeResourceDialog
@onready var open_craft_station_type_dialog : FileDialog = $OpenCraftStationTypeDialog
@onready var craft_station_types_list : CraftStationTypesItemList = $HSplitContainer/CraftStationTypesItemList
@onready var craft_station_types_popup_menu : PopupMenu = $HSplitContainer/CraftStationTypesItemList/CraftStationTypesPopupMenu
@onready var craft_station_type_remove_confirmation_dialog = %CraftStationTypeRemoveConfirmationDialog
@onready var search_icon = $HSplitContainer/CraftStationTypesItemList/Control/SearchIcon

const ITEM_REMOVE = 100

var current_station : CraftStationType

func set_editor_plugin(editor_plugin : EditorPlugin):
	self.editor_plugin = editor_plugin
	craft_station_type_editor.set_editor_plugin(editor_plugin)
	_apply_theme()


func _apply_theme():
	if not is_instance_valid(editor_plugin) or not is_instance_valid(new_craft_station_type_dialog):
		return
	var scale: float = editor_plugin.get_editor_interface().get_editor_scale()
	new_craft_station_type_dialog.min_size = Vector2(600, 500) * scale
	
	search_icon.texture = get_theme_icon("Search", "EditorIcons")
	

func load_from_database(database : InventoryDatabase) -> void:
	self.database = database
	craft_station_type_editor.load_station(null)
	load_craft_station_types()


func select(station : CraftStationType):
	craft_station_type_editor.load_station(station)


func load_craft_station_types():
	craft_station_types_list.load_craft_station_types(database)


func remove_station(station : CraftStationType):
	var index = database.stations_type.find(station)
	if index == -1:
		return
	database.stations_type.remove_at(index)
	load_craft_station_types()


func new_station_pressed():
	if not is_instance_valid(database):
		return
	
	new_craft_station_type_dialog.popup_centered()


func _on_craft_station_types_item_list_station_selected(station):
	current_station = station
	select(station)


func _on_craft_station_type_editor_changed(station):
	var index = craft_station_types_list.get_index_of(station)
	if index > -1:
		craft_station_types_list.update_item(index)


func _on_new_craft_station_type_resource_dialog_file_selected(path):
	var item : CraftStationType = CraftStationType.new()
	var err = ResourceSaver.save(item, path)
	if err == OK:
		var res : CraftStationType = load(path)
		res.name = "New Craft Station Type"
		editor_plugin.get_editor_interface().get_resource_filesystem().scan()
		database.stations_type.append(res)
		load_craft_station_types()
	else:
		print(err)


func _on_craft_station_types_popup_menu_id_pressed(id):
	match id:
		ITEM_REMOVE:
			craft_station_type_remove_confirmation_dialog.popup_centered()
			craft_station_type_remove_confirmation_dialog.dialog_text = "Remove Item \""+current_station.name+"\"?"


func _on_craft_station_types_item_list_item_popup_menu_requested(at_position):
	var add = at_position + Vector2(0, craft_station_types_popup_menu.size.y) + craft_station_types_list.global_position
	craft_station_types_popup_menu.position = Vector2(get_viewport().position) + add
	craft_station_types_popup_menu.popup()


func _on_craft_station_types_popup_menu_about_to_popup():
	craft_station_types_popup_menu.clear()
	var icon = get_theme_icon("Remove", "EditorIcons")
	craft_station_types_popup_menu.add_icon_item(icon, "Remove", ITEM_REMOVE)


func _on_craft_station_type_remove_confirmation_dialog_confirmed():
	remove_station(current_station)
