extends Node

# Autoload registered as "SaveManager". No class_name on autoloads in 4.6.
# M0 stubs. Full JSON persistence lands in M7.


func save(slot: int = 0) -> bool:
	push_warning("SaveManager.save stubbed (slot=%d)" % slot)
	return false


func load_slot(slot: int = 0) -> bool:
	push_warning("SaveManager.load_slot stubbed (slot=%d)" % slot)
	return false


func has_save(slot: int = 0) -> bool:
	return false
