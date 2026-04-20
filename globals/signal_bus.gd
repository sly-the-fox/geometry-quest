extends Node

# Autoload registered as "SignalBus". No class_name — Godot 4.6 forbids a
# class_name that collides with an autoload registration name.

# Combat — 5
signal player_damaged(amount: int, source: Node3D)
signal enemy_damaged(enemy: Node3D, info: DamageInfo)
signal enemy_released(enemy: Node3D)
signal boss_damaged(boss: Node3D, info: DamageInfo)
# Pre-mitigation hook. Fires from Hurtbox.receive() before HealthComponent
# applies damage. M11 block/parry reads this to veto damage within the
# shield cone; M2 declares the signal but nothing listens.
signal hurtbox_hit(hurtbox: Node, info: DamageInfo)

# Canonical 4-phase boss flow — 9
signal boss_encounter_started(boss: Node3D)
signal boss_phase_entered(boss: Node3D, phase: int)
signal boss_observed(boss: Node3D)
signal boss_intervention_progress(boss: Node3D, progress: float)
signal boss_vulnerability_started(boss: Node3D)
signal boss_vulnerability_ended(boss: Node3D, attacked: bool)
signal boss_re_corrupted(boss: Node3D, new_difficulty: float)
signal boss_integrated(boss_id: StringName)
signal boss_became_ally(boss_id: StringName)

# Player state — 6
signal player_died()
signal player_respawned()
signal player_weapon_changed(weapon: WeaponResource)
signal player_stats_changed(stats: Stats)
signal player_field_integrity_changed(current: int, max: int)
signal player_acquired_weapon(weapon_id: StringName)

# Lock-on — 2
signal lock_on_acquired(target: Node3D)
signal lock_on_released()

# World — 6
signal room_entered(room_id: StringName)
signal region_entered(region_id: StringName)
signal interactable_hovered(interactable: Node3D)
signal interactable_unhovered(interactable: Node3D)
signal door_opened(door_id: StringName)
signal puzzle_solved(puzzle_id: StringName)

# Corruption & process order — 3
signal corruption_entered(volume: Node3D)
signal corruption_exited(volume: Node3D)
signal process_step_completed(step: StringName)

# Time dilation (Lens) — 1
signal slowmo_broadcast(scale: float)

# Dialogue / UI — 4
signal dialogue_started(root: DialogueLine)
signal dialogue_advanced(line: DialogueLine)
signal dialogue_ended()
signal hud_message(text: String, duration: float)

# Meta — 3
signal game_paused(paused: bool)
signal game_loaded()
signal game_saved()
