# Geometry Quest — Technical Spec (Vertical Slice)

Authoritative spec for the v1 vertical slice. The slice proves the **canonical
bible loop**: player enters Nexus, learns to observe with Heptagon Lens,
descends into a corrupted region, applies a disruption geometry (Pentagram
Inverter) to break the boss's loop, stabilizes with Hexagonal Shield, and
integrates with the Octagon Harmonizer — after which the healed boss becomes
an ally NPC in the Nexus. The five weapons in the slice *are* the bible's
process order: **observe (7) → disrupt (5) → stabilize (6) → complete (8) →
integrate (12-equivalent via Harmonizer's completion)**, with Tetrahedron
Blade (3) as the universal default verb.

See `geo_quest_lore&mechanics_bible.md` for the authoritative lore and
mechanics bible. Where this SPEC and the bible conflict, **the bible wins** —
raise a PR to reconcile. Where the SPEC is silent, the bible fills in.

---

## 0. Scope

### In-scope (v1 vertical slice)
- **1 hub:** Crystal Nexus (small, ~2 rooms + fast-travel stubs for regions not yet built).
- **2 regions:** **Region 2** (Collapsing Triangle Mines, Alchemist resonance, 528 Hz, emerald) and **Region 7** (Sphere Pulse Meditation Domes, Observer resonance, 741 Hz, silver/white).
- **2 canonical 4-phase bosses:** **The Crystallized Alchemist** (R2), **The Overwhelmed Observer** (R7). Healed forms become interactable NPCs in the Nexus.
- **5 weapons — the canonical slice kit:**
  1. **Tetrahedron Blade** (3-sided) — universal default.
  2. **Pentagram Inverter** (5-sided) — R2 regional weapon, disruption + reflection.
  3. **Hexagonal Shield** (6-sided) — stabilization, parry.
  4. **Heptagon Lens** (7-sided) — R7 regional weapon + **required for every boss Phase 1**.
  5. **Octagon Harmonizer** (8-sided) — **required for every boss Phase 4 integration**. Granted mid-Alchemist fight as a narrative gift.
- **Core systems:** player controller, combat, lock-on camera, enemy AI, save/load, dialogue, HUD, inventory, room streaming, canonical 4-phase boss framework, 4-sided corruption debuff volumes, bible-formula stats.
- **Bible-derived identity systems:** 432 Hz world drone, per-pyramid frequency audio, process-order enforcement, "attacking during vulnerability re-corrupts boss and resets fight with +difficulty."
- **Geometric primitives aesthetic:** procedural meshes + CSG + shader-driven glow, with per-region sky shader + volumetric fog + set-dressing density rule.
- **Single-player only.**

### Out of scope (v1)
Regions 1, 3, 4, 5, 6, 8–16. Weapons 9, 10, 11, 12, 13, 14 (Nonagon, Decagon, Hendecagon, Dodecagon Crown, Tridecagon, Tetradecagon). Multiplayer. MMO events. Ranged weapons. Frequency Bow. Boomerang. Merkaba Wings. Toroidal Field Generator. New Game Plus. Procedural region generation. Resonance type affinity tracking + discovery algorithm. Codex collection. Combination-attack matrix. φ-based damage math (slice uses simple integer math; mark damage/heal methods so the swap to φ is one-line later). Chaos corruption accumulation from 11-sided misuse (no 11-sided in slice). Full accessibility suite (keep standard Godot options only). External 3D/art assets.

Regions, weapons, enemies, bosses are all data-driven custom Resources. Adding content post-slice is `.tres` work, not engine work.

---

## 1. Tech Stack

- **Engine:** Godot **4.6.2** stable. Lock this in `project.godot` (`config_version=5`, `config/features=PackedStringArray("4.6", "Forward Plus")`).
- **Language:** GDScript, **strictly typed**. Every function parameter, return type, and member variable has an explicit type. No `Variant` except in the signal bus and resource loaders. No untyped arrays — use `Array[Type]`.
- **Renderer:** Forward+ (Vulkan).
- **Target platforms:** Windows x86_64 + macOS ARM64 debug builds.
- **Target resolution:** 1920×1080 base, letterboxed. Framerate target: 60 fps.
- **Version control:** git. `.godot/` in `.gitignore`. `.gdignore` in docs folders the editor should not scan.
- **Testing:** lightweight scene-driven asserts under `tests/` run via headless launcher (no external test framework). Focus: damage resolution, save/load roundtrip, boss phase transitions, lens time-dilation correctness.

---

## 2. Project Structure

```
res://
  project.godot
  SPEC.md
  PLAN.md
  geo_quest_lore&mechanics_bible.md
  geometry_quest_game_design.md
  .gitignore
  globals/
    game_state.gd
    signal_bus.gd
    save_manager.gd
    audio_manager.gd
    scene_router.gd
    process_order.gd                # tracks the canonical observe→disrupt→stabilize→integrate sequence
  resources/
    weapon_resource.gd
    enemy_resource.gd
    boss_resource.gd
    boss_phase_resource.gd
    region_resource.gd
    dialogue_line.gd
    dialogue_choice.gd              # split file — one class_name per file
    damage_info.gd
    stats.gd
  player/
    player.tscn
    player.gd
    camera_rig.tscn
    camera_rig.gd
    states/
      player_state.gd
      idle_state.gd
      move_state.gd
      jump_state.gd
      attack_state.gd
      block_state.gd
      lens_state.gd
      inverter_state.gd
      harmonizer_state.gd
      hit_state.gd
      dead_state.gd
  combat/
    hitbox.tscn
    hitbox.gd
    hurtbox.tscn
    hurtbox.gd
    health_component.gd
    lock_on.gd
    slowmo_agent.gd                 # per-node time dilation; see §11.4
  weapons/
    weapon.gd
    weapon.tscn
    tetrahedron_blade/
      tetrahedron_blade.tscn
      tetrahedron_blade.gd
      tetrahedron_blade.tres
    pentagram_inverter/
      pentagram_inverter.tscn
      pentagram_inverter.gd
      pentagram_inverter.tres
      reflected_projectile.tscn     # reflect-attack projectile
    hexagonal_shield/
      hexagonal_shield.tscn
      hexagonal_shield.gd
      hexagonal_shield.tres
    heptagon_lens/
      heptagon_lens.tscn
      heptagon_lens.gd
      heptagon_lens.tres
    octagon_harmonizer/
      octagon_harmonizer.tscn
      octagon_harmonizer.gd
      octagon_harmonizer.tres
  enemies/
    enemy.gd
    enemy.tscn
    states/
      enemy_state.gd
      enemy_patrol.gd
      enemy_chase.gd
      enemy_attack.gd
      enemy_return.gd
      enemy_stagger.gd
    triangle_elemental/
      triangle_elemental.tscn
      triangle_elemental.gd
      triangle_elemental.tres
    anxiety_storm/                  # R7 enemy
      anxiety_storm.tscn
      anxiety_storm.gd
      anxiety_storm.tres
  bosses/
    boss.gd
    boss.tscn
    boss_phase.gd                   # base Node script for phase children
    crystallized_alchemist/
      crystallized_alchemist.tscn
      crystallized_alchemist.gd
      crystallized_alchemist.tres
      phases/
        phase_1_recognition.gd
        phase_2_intervention.gd
        phase_3_vulnerability.gd
        phase_4_integration.gd
    overwhelmed_observer/
      overwhelmed_observer.tscn
      overwhelmed_observer.gd
      overwhelmed_observer.tres
      phases/
        phase_1_recognition.gd
        phase_2_intervention.gd
        phase_3_vulnerability.gd
        phase_4_integration.gd
  world/
    region.gd
    room.gd
    door.tscn
    door.gd
    trigger_volume.tscn
    trigger_volume.gd
    interactable.tscn
    interactable.gd
    pickup.tscn                     # weapon/item pickup
    pickup.gd
    hub_crystal_nexus/
      hub_crystal_nexus.tscn
      hub_crystal_nexus.tres
      rooms/
        room_nexus_main.tscn
        room_nexus_portals.tscn
        room_nexus_tutorial.tscn    # scripted Blade + Lens acquisition
    region_02_triangle_mines/
      region_02.tscn
      region_02.tres
      rooms/
        room_entry.tscn
        room_collapsing_chamber.tscn
        room_gravity_flip.tscn
        room_triangle_lock.tscn
        room_boss_arena.tscn
    region_07_sphere_pulse/
      region_07.tscn
      region_07.tres
      rooms/
        room_entry.tscn
        room_stillness_chamber.tscn
        room_pulse_rhythm.tscn
        room_nested_spheres.tscn
        room_boss_arena.tscn
  puzzles/
    weight_plate.tscn
    weight_plate.gd
    resonance_switch.tscn
    resonance_switch.gd
    lens_target.tscn
    lens_target.gd
    shield_stabilizer.tscn
    shield_stabilizer.gd
    timed_door.tscn
    timed_door.gd
    crystal_pedestal.tscn
    crystal_pedestal.gd
    corruption_volume.tscn          # 4-sided debuff volume — see §15
    corruption_volume.gd
    puzzle_group.gd                 # composite aggregator
    stillness_zone.tscn             # R7 primitive — action = reset
    stillness_zone.gd
  ui/
    hud.tscn
    hud.gd
    pause_menu.tscn
    pause_menu.gd
    inventory.tscn
    inventory.gd
    dialogue_box.tscn
    dialogue_box.gd
    title.tscn
    title.gd
    fade.tscn
    fade.gd
    boss_bar.tscn                   # canonical 4-phase bar, see §17
    boss_bar.gd
  dialogue/
    dialogue_runner.gd
    lines/
      nexus_guide.tres
      nexus_tutorial_lens.tres
      alchemist_intro.tres
      alchemist_phase3_warning.tres
      alchemist_integration.tres
      alchemist_nexus_npc.tres
      observer_intro.tres
      observer_phase3_warning.tres
      observer_integration.tres
      observer_nexus_npc.tres
  meshes/
    procedural_mesh.gd
    polyhedra.gd
  shaders/
    resonance_glow.gdshader
    corruption.gdshader
    dissolve.gdshader
    lens_overlay.gdshader
    sky_nexus.gdshader
    sky_region_02.gdshader
    sky_region_07.gdshader
    inversion_ripple.gdshader       # Pentagram Inverter effect
    completion_wave.gdshader        # Octagon Harmonizer effect
  materials/
    mat_player.tres
    mat_enemy_earth.tres
    mat_enemy_aether.tres
    mat_world_stone.tres
    mat_world_crystal.tres
    mat_boss_alchemist.tres
    mat_boss_observer.tres
    mat_corrupted_4sided.tres       # red/shadow #8B0000
    mat_weapon_blade.tres
    mat_weapon_inverter.tres
    mat_weapon_shield.tres
    mat_weapon_lens.tres
    mat_weapon_harmonizer.tres
  environments/
    env_nexus.tres                  # per-region Environment resource
    env_region_02.tres
    env_region_07.tres
    env_lens_overlay.tres           # swapped in by Heptagon Lens active state
  audio/
    music/
    sfx/
    tones/                          # per-pyramid Hz sine/square tones
  scenes/
    main.tscn
    test_room.tscn                  # M1/M2/M3 development scene
  tests/
    test_damage.gd
    test_save_roundtrip.gd
    test_state_machine.gd
    test_boss_phases.gd
    test_process_order.gd
```

---

## 3. Autoloads

Registered in `project.godot` in this order:

| # | Name         | Path                              | Purpose |
|---|--------------|-----------------------------------|---------|
| 1 | `SignalBus`  | `res://globals/signal_bus.gd`     | Decoupled pub/sub. |
| 2 | `AudioManager` | `res://globals/audio_manager.gd` | Music/SFX bus, per-pyramid tones, 432 Hz world drone, crossfade. |
| 3 | `GameState`  | `res://globals/game_state.gd`     | Runtime data: current region, unlocked weapons, flags, stats. Not persisted directly — see SaveManager. |
| 4 | `ProcessOrder` | `res://globals/process_order.gd` | Tracks the canonical observe→disrupt→stabilize→complete sequence. Queries used by puzzles and bosses to validate order of operations; see §13.1 and §15. |
| 5 | `SaveManager` | `res://globals/save_manager.gd`  | Serialize/deserialize `GameState` to `user://save_N.json`. |
| 6 | `SceneRouter` | `res://globals/scene_router.gd`  | Change scenes with fade, room transitions, spawn-point routing. |

`InputManager` is **not** an autoload — SPEC v1 uses Godot's built-in `Input` + a per-action 6-frame buffer on the `Player` node directly. Fewer autoloads; no input loss.

**Rules:**
- Autoloads never reference each other at load time — only at runtime via methods.
- Game logic never directly references another scene's node — goes through `SignalBus` or a shared autoload.
- `GameState` is the only place ephemeral run data lives. No static state anywhere else.

---

## 4. Input Map

Defined in `project.godot` under `input/`. Every action has keyboard + gamepad bindings. Action buffer (6 frames) applied in player code for `attack`, `jump`, `block`.

| Action         | Keyboard                    | Gamepad (Xbox layout) |
|----------------|-----------------------------|-----------------------|
| `move_up`      | W                           | Left stick up         |
| `move_down`    | S                           | Left stick down       |
| `move_left`    | A                           | Left stick left       |
| `move_right`   | D                           | Left stick right      |
| `jump`         | Space                       | A                     |
| `attack`       | Left mouse / J              | X                     |
| `block`        | Right mouse / K             | RB                    |
| `lens`         | F                           | LB                    |
| `lock_on`      | Middle mouse / Tab          | Click right stick     |
| `interact`     | E                           | Y                     |
| `swap_next`    | Q / mouse wheel up          | D-pad right           |
| `swap_prev`    | Z / mouse wheel down        | D-pad left            |
| `pause`        | Esc                         | Start                 |
| `inventory`    | I                           | Select / Back         |

Camera is driven by mouse motion (relative) + right stick (axis) — not via InputMap actions; read directly from `_input(InputEventMouseMotion)` and `Input.get_vector("cam_left","cam_right","cam_up","cam_down")` respectively. **No modifier-chord bindings.**

---

## 5. Physics Layers & Masks

Layers 1–10 are named in `project.godot`. Each body/area sets `collision_layer` to its identity and `collision_mask` to what it needs to detect.

| Layer | Name              | Used by                              |
|-------|-------------------|--------------------------------------|
| 1     | `world`           | Static level geometry                |
| 2     | `player`          | Player CharacterBody3D               |
| 3     | `enemy`           | Enemy CharacterBody3D                |
| 4     | `player_hitbox`   | Area3D on player weapons             |
| 5     | `enemy_hitbox`    | Area3D on enemy attacks              |
| 6     | `player_hurtbox`  | Area3D on player body                |
| 7     | `enemy_hurtbox`   | Area3D on enemy/boss body            |
| 8     | `interactable`    | NPCs, pickups, pedestals, doors      |
| 9     | `trigger`         | Invisible volumes (incl. corruption) |
| 10    | `projectile`      | Reflected projectiles, boss debris   |

**Mask rules:**
- Player hitbox masks `enemy_hurtbox` only.
- Enemy hitbox masks `player_hurtbox` only.
- Player body masks `world + interactable + enemy`.
- Enemy body masks `world + player`.
- Triggers mask `player`; corruption volumes mask `player + enemy` (enemies inside corruption get their own debuff variant).
- Projectiles mask `world + player_hurtbox + enemy_hurtbox`.

---

## 6. Core Resource Schemas

### 6.1 `DamageInfo` (`res://resources/damage_info.gd`)
```gdscript
class_name DamageInfo extends RefCounted
var amount: int
var type: StringName            # "physical", "resonance", "pierce", "inversion", "completion"
var source: Node3D
var knockback: Vector3
var stagger_seconds: float
var breaks_pattern: bool        # hits on pattern-locked enemies; set by Pentagram
var completes_pattern: bool     # Octagon Harmonizer integrates mechanisms
```

### 6.2 `Stats` (`res://resources/stats.gd`) — bible formulas
```gdscript
class_name Stats extends Resource
@export var field_integrity_max: int = 12     # HP in heart-quarters; 3 hearts at start
@export var coherence: int = 10               # 1..100
@export var resonance: int = 10
@export var stability: int = 10
@export var flow: int = 10

# Bible §7 formulas
func hit_chance() -> float:
    return clamp(0.70 + coherence * 0.003, 0.0, 1.0)

func corruption_resistance_percent() -> float:
    return stability * 0.5   # e.g. stability 10 → 5% resistance

func move_speed_mult() -> float:
    return 1.0 + flow * 0.01

func accessible_pyramids() -> Array[int]:
    # Resonance thresholds gate pyramid access; slice kit is [3,5,6,7,8].
    var access: Array[int] = [3]
    if resonance >= 10: access.append_array([5, 6])
    if resonance >= 30: access.append_array([7, 8])
    return access
```

**Slice note:** stats default to `10`. Coherence, stability, flow are *used* by the slice (hit_chance, corruption resistance, move speed). Resonance gates weapon use — player starts at resonance 10 (gives access to Blade, Pentagram, Shield via bible thresholds) and gains +20 on defeating the Alchemist (unlocking Lens+Harmonizer thresholds at 30). If narrative sequencing requires Lens before resonance 30, have the Alchemist's gift also bump resonance.

**Important:** Stats live on `GameState`, not on a shared `Resource` asset on disk. If the Player holds a `Stats` reference, it's a duplicate instance. Mutating stats mid-run must never write back to the `.tres` file.

### 6.3 `WeaponResource` (`res://resources/weapon_resource.gd`)
```gdscript
class_name WeaponResource extends Resource
@export var id: StringName                    # &"tetrahedron_blade"
@export var pyramid_sides: int                # 3, 5, 6, 7, 8
@export var display_name: String
@export var icon: Texture2D
@export var scene: PackedScene
@export var frequency_hz: float = 432.0       # bible §9 mapping
@export var color_hex: String = "#E0F6FF"
@export var damage: int = 1
@export var damage_type: StringName = &"physical"
@export var attack_windup_s: float = 0.08
@export var attack_active_s: float = 0.18
@export var attack_recovery_s: float = 0.24
@export var resonance_required: int = 10
@export var tags: Array[StringName] = []      # "melee", "pierce", "shield", "observation", "inversion", "completion"
```

### 6.4 `EnemyResource` (`res://resources/enemy_resource.gd`)
```gdscript
class_name EnemyResource extends Resource
@export var id: StringName
@export var display_name: String
@export var scene: PackedScene
@export var stats: Stats
@export var contact_damage: int = 1
@export var detection_radius: float = 8.0
@export var leash_radius: float = 14.0
@export var move_speed: float = 3.0
@export var weak_to: Array[StringName] = []   # damage_type tags
@export var pattern_locked: bool = false      # takes ×2 from Pentagram Inverter
```

### 6.5 `BossResource` extends `EnemyResource` — canonical 4-phase
```gdscript
class_name BossResource extends EnemyResource

# Bible §4: every boss has a core wound and a required process.
@export var core_wound: StringName            # "RIGIDITY", "WITNESS_TRAP", etc.
@export var stuck_geometry_sides: int         # e.g. 4 for corruption, 7 for observation
@export var required_intervention_weapon: StringName   # weapon id for Phase 2
@export var required_integration_weapon: StringName = &"octagon_harmonizer"
@export var observation_duration_s: float = 4.0  # Phase 1 Lens dwell time
@export var vulnerability_window_s: float = 6.0  # Phase 3 window to NOT attack
@export var difficulty_on_violence: float = 0.25 # bible §4 dynamic modifier
@export var intro_dialogue: DialogueLine
@export var phase3_warning_dialogue: DialogueLine
@export var integration_dialogue: DialogueLine
@export var nexus_npc_dialogue: DialogueLine  # post-defeat NPC in Nexus
```

### 6.6 `BossPhaseResource` (`res://resources/boss_phase_resource.gd`)
Metadata for each phase. Scene holds logic; resource holds tunables.
```gdscript
class_name BossPhaseResource extends Resource
@export var phase_index: int                  # 1..4
@export var music_path: String = ""
@export var enter_hud_message: String = ""
@export var duration_cap_s: float = -1.0      # -1 = no cap
```

### 6.7 `RegionResource` (`res://resources/region_resource.gd`)
```gdscript
class_name RegionResource extends Resource
@export var id: StringName
@export var display_name: String
@export var entry_room_scene_path: String
@export var rooms: Array[PackedScene] = []    # flat list — doors own the graph
@export var palette_primary: Color = Color.WHITE
@export var palette_secondary: Color = Color.WHITE
@export var palette_accent: Color = Color.WHITE
@export var sky_shader_path: String = ""
@export var fog_density: float = 0.015
@export var fog_color: Color = Color(0.1, 0.12, 0.16)
@export var music_path: String = ""
@export var ambient_drone_path: String = ""   # per-region Hz drone under 432 Hz world base
@export var boss_id: StringName = &""
```

### 6.8 `DialogueLine` (`res://resources/dialogue_line.gd`)
```gdscript
class_name DialogueLine extends Resource
@export var speaker: String
@export_multiline var text: String
@export_multiline var portrait_description: String = ""
@export var next: DialogueLine = null
@export var choices: Array[DialogueChoice] = []
@export var flag_to_set_on_show: StringName = &""
```

### 6.9 `DialogueChoice` (`res://resources/dialogue_choice.gd`) — **separate file**
```gdscript
class_name DialogueChoice extends Resource
@export var text: String
@export var next: DialogueLine
@export var flag_to_set: StringName = &""
```

---

## 7. Signal Bus

```gdscript
extends Node

# Combat
signal player_damaged(amount: int, source: Node3D)
signal enemy_damaged(enemy: Node3D, info: DamageInfo)
signal enemy_released(enemy: Node3D)        # per bible/creative audit: "release," not "kill"
signal boss_damaged(boss: Node3D, info: DamageInfo)

# Canonical 4-phase boss flow
signal boss_encounter_started(boss: Node3D)
signal boss_phase_entered(boss: Node3D, phase: int)     # phase 1..4
signal boss_observed(boss: Node3D)                      # Phase 1 Lens dwell satisfied
signal boss_intervention_progress(boss: Node3D, progress: float)  # 0..1 during Phase 2
signal boss_vulnerability_started(boss: Node3D)         # Phase 3 window opens
signal boss_vulnerability_ended(boss: Node3D, attacked: bool)
signal boss_re_corrupted(boss: Node3D, new_difficulty: float)   # fight reset
signal boss_integrated(boss_id: StringName)             # Phase 4 complete
signal boss_became_ally(boss_id: StringName)            # NPC unlocked in Nexus

# Player state
signal player_died()
signal player_respawned()
signal player_weapon_changed(weapon: WeaponResource)
signal player_stats_changed(stats: Stats)
signal player_field_integrity_changed(current: int, max: int)
signal player_acquired_weapon(weapon_id: StringName)

# Lock-on
signal lock_on_acquired(target: Node3D)
signal lock_on_released()

# World
signal room_entered(room_id: StringName)
signal region_entered(region_id: StringName)
signal interactable_hovered(interactable: Node3D)
signal interactable_unhovered(interactable: Node3D)
signal door_opened(door_id: StringName)
signal puzzle_solved(puzzle_id: StringName)

# Corruption & process order
signal corruption_entered(volume: Node3D)
signal corruption_exited(volume: Node3D)
signal process_step_completed(step: StringName)  # "observe", "disrupt", "stabilize", "complete", "integrate"

# Time dilation (Lens)
signal slowmo_broadcast(scale: float)   # 1.0 = normal, 0.5 = lens active; SlowmoAgent listens

# Dialogue / UI
signal dialogue_started(root: DialogueLine)
signal dialogue_advanced(line: DialogueLine)
signal dialogue_ended()
signal hud_message(text: String, duration: float)

# Meta
signal game_paused(paused: bool)
signal game_loaded()
signal game_saved()
```

**Hot-path exception:** `player_damaged`, `enemy_damaged`, and `boss_damaged` are emitted by `HealthComponent` locally *and* mirrored to the SignalBus for UI/audio. UI/audio use the bus; component-to-component logic uses the local signal. Keeps the bus from becoming an N-per-frame hot path.

---

## 8. Player Character

### 8.1 Scene tree (`player.tscn`)

```
Player (CharacterBody3D, script: player.gd, layer: player, mask: world+interactable+enemy)
├── Body (MeshInstance3D, merkaba mesh, mat_player)
├── CollisionShape3D (CapsuleShape3D, height=1.8, radius=0.4)
├── Hurtbox (Area3D, layer: player_hurtbox, mask: enemy_hitbox + projectile)
│   └── CollisionShape3D
├── WeaponSlot (Node3D, right-hand offset)
│   └── <current primary weapon>
├── ShieldSlot (Node3D, off-hand offset)
│   └── <Hexagonal Shield when equipped>
├── HeadSlot (Node3D, above head)
│   └── <future Dodecagon Crown / reserved>
├── CameraRig (instance of camera_rig.tscn)
├── StateMachine (Node)
│   ├── Idle (PlayerState)
│   ├── Move
│   ├── Jump
│   ├── Attack
│   ├── Block
│   ├── Lens
│   ├── Inverter     # Pentagram charged shot state
│   ├── Harmonizer   # Octagon completion wave state
│   ├── Hit
│   └── Dead
├── InteractRay (RayCast3D, length 2.0, mask: interactable)
├── LockOn (Node, script: lock_on.gd)
└── SlowmoAgent (Node, script: slowmo_agent.gd; value always 1.0 for player)
```

### 8.2 Movement

- `CharacterBody3D`, `up_direction = Vector3.UP`.
- Gravity: `-24.0 m/s²`. Terminal fall: `-40.0 m/s`.
- Ground speed base: `5.5 * stats.move_speed_mult()` m/s.
- Acceleration: `30 m/s²`. Deceleration: `45 m/s²`. Air control: half.
- Jump: `8.5 m/s`. Coyote 0.12 s. Jump buffer 0.1 s.
- Rotation: yaw lerps to movement direction unless locked on; locked-on = face target + strafe.
- Inverted-gravity rooms: see §14.5 below. Camera up vector is driven from the player's `up_direction`.
- Hitstun: zero input; knockback velocity decays over `DamageInfo.stagger_seconds`.
- **4-sided corruption debuff** (see §15 CorruptionVolume): while inside a CorruptionVolume, multiply `move_speed_mult` by `0.8` and weapon damage by `0.85` until exit. Corruption resistance from `stats.stability` reduces this: effective debuff = raw_debuff * (1 - stats.corruption_resistance_percent() / 100).

### 8.3 State machine

`PlayerState` base with overridable `enter/exit/process/physics_process/handle_input`. `StateMachine.change_state(name)`. Transitions table lives in code, not spec — each state declares legal exits in its own script.

---

## 9. Camera Rig

Unchanged from prior spec, with one addition for inverted gravity: `CameraRig.set_world_up(v: Vector3)` re-orients the yaw pivot so "up" is always the player's current up. Pitch clamps are relative to that up vector.

### 9.3 Lock-on (`combat/lock_on.gd`)

- Targets: any node in group `"lockon_target"`.
- Candidate filter: within 12 m, within 90° cone from camera forward, not occluded (raycast mask: `world`).
- Selection: **nearest to the viewport center** in screen space (project target position to viewport with `Camera3D.unproject_position`; distance in pixels to `viewport.size / 2`). Targets behind the camera are excluded (negative z in camera space).
- Single valid candidate → no switch on re-press (deadzone).
- Multiple candidates → re-press switches to the candidate with next-smallest angle to *camera forward*, measured clockwise around the camera up axis.
- Auto-release: target dies, leaves 20 m, or is occluded for > 0.5 s continuous.
- Emits `SignalBus.lock_on_acquired(target)` / `lock_on_released()`.

---

## 10. Combat System

### 10.1 Hitbox / Hurtbox

Unchanged. Hitbox fires `area_entered` → builds `DamageInfo` → `hurtbox.receive(info)`.

**Stability mitigation formula:** `dealt = max(1, info.amount - floor(target.stats.stability / 5))`. At default stability 10, mitigation = 2 (floor). Minimum damage is always 1 when any damage is dealt, unless `is_blocking` in front cone fully negates (see §11.5).

**Pattern-locked bonus:** if `info.breaks_pattern` is true OR target has `enemy_resource.pattern_locked` AND weapon has tag `"inversion"` or is Tetrahedron Blade, multiply final damage by 2.

### 10.2 I-frames

HealthComponent tracks `invulnerable_until: float`; after any damage received, set `invulnerable_until = now + 0.6`. Blocking does not set i-frames (it negates damage instead).

### 10.3 Vulnerability-window damage rule

During a boss's Phase 3 (vulnerability), any incoming `DamageInfo` with `info.amount > 0` on the boss hurtbox triggers `SignalBus.boss_re_corrupted(boss, new_difficulty)` and resets the fight. `Octagon Harmonizer` emits `DamageInfo` with `amount = 0, type = &"completion"` — this is the only "attack" permitted on a vulnerable boss, and it drives the Phase 4 transition instead of damage.

---

## 11. Weapon Framework

### 11.1 Base scene

```
Weapon (Node3D, script: weapon.gd)
├── Mesh (MeshInstance3D — procedural, per weapon)
└── Hitbox (optional; not all weapons have one)
```

`weapon.gd` base: `resource: WeaponResource`, `attack()`, `on_equip(player)`, `on_unequip()`, `tick(delta)`. Override per-weapon.

### 11.2 Swap pipeline

1. `GameState.equipped_weapon_id = id`.
2. Emit `SignalBus.player_weapon_changed(resource)`.
3. Player frees old child of `WeaponSlot`, instances new, calls `on_equip(self)`.
4. HUD reacts to same signal.

### 11.3 Tetrahedron Blade (3-sided) — §2-default

- **Frequency:** 432 Hz. **Color:** `#E0F6FF`.
- **Mesh:** procedural tetrahedron, edge 0.6, emissive blue-white.
- **Stats:** damage 2 (quarter-hearts), windup 0.08 s, active 0.18 s, recovery 0.24 s.
- **Hitbox:** wedge at tip, BoxShape3D ~0.4×0.2×0.6, active only during active frames.
- **Tags:** `["melee", "pierce"]`.
- **Behavior:** during attack, blade rotates 180° around forward axis. On `pattern_locked` target: ×2 damage (handled in §10.1).

### 11.4 Heptagon Lens (7-sided) — observation

- **Frequency:** 741 Hz. **Color:** `#C0C0C0` silver.
- **Mesh:** flat regular heptagon held in front of face, translucent.
- **Tags:** `["observation"]`. Damage: 0.
- **Behavior (held):**
  - Post-process overlay via `shaders/lens_overlay.gdshader` (dedicated `Environment` override on the Camera3D during active; swap entire Environment, do not stack ColorRects).
  - Enemies in group `"lens_revealed"` toggle `visible = true`.
  - Nodes in group `"lens_telegraph"` reveal their next-attack trajectory (children drawn via `MeshInstance3D` set `visible = true`).
  - `LensTarget` puzzle primitives count dwell time while in camera view.
  - **Time dilation:** **per-node**, not global. The Lens emits `slowmo.broadcast(0.5)` via `SignalBus`; every enemy/boss/projectile has a `SlowmoAgent` component whose `scale` is read by its `_physics_process` to multiply its delta. Player, UI, audio, input, and timers are **not** slowed. This replaces the original `Engine.time_scale = 0.5` approach entirely.
- **Energy:** `lens_energy` on GameState, max 3.0, drain 1.0/s while active, regen 0.75/s idle.
- **Bible requirement:** holding Lens for `boss.observation_duration_s` continuously while framing a boss triggers `SignalBus.boss_observed(boss)` — required Phase 1 → Phase 2 transition trigger.

### 11.5 Pentagram Inverter (5-sided) — disruption + reflection

- **Frequency:** 528 Hz. **Color:** `#50C878` emerald.
- **Mesh:** regular pentagonal star prism (5 points radiating from a central pentagon). Emits rotating inversion-ripple shader (`shaders/inversion_ripple.gdshader`).
- **Stats:** damage 3 on direct melee-range strike, windup 0.12 s, active 0.22 s, recovery 0.38 s.
- **Tags:** `["melee", "inversion"]`. Resonance required: 10 (available from slice start).
- **Behavior:**
  - **Tap attack:** melee strike; `DamageInfo.type = "inversion"`, `breaks_pattern = true`. Pattern-locked enemies take ×2 (stacks with §10.1).
  - **Hold (≥ 0.5 s) to charge — inversion field:** release emits a 5 m radius emerald pulse. Effects inside:
    - Enemy projectiles in flight flip their velocity (reflected at 150% speed, `damage_type = "inversion"`, `source = player`). Projectiles hit their original shooter via `layer: projectile` on `enemy_hurtbox`.
    - Enemy AI state machines in the pulse radius receive `on_inversion_field()` → forced to exit current state into `Stagger` for 2.0 s. This is what "breaks their AI routine" looks like.
    - Any `"pattern_locked"` entity inside is marked `is_vulnerable_to_next_hit = true` for 3 s.
    - `CorruptionVolume` nodes inside the pulse are temporarily disabled for 5 s (the pulse "inverts the 4-sided cage").
  - Charge cost: 1 unit of `inverter_energy` (max 2.0, regen 0.5/s).
- **Boss critical against:** Alchemist's Phase 2 triangle prison (Inverter pulse is the *required* intervention weapon per bible).

### 11.6 Hexagonal Shield (6-sided) — stabilization

- **Frequency:** 432 Hz. **Color:** `#F0FFFF` crystalline.
- **Mesh:** hexagonal prism plate, thin, off-hand.
- **Tags:** `["shield"]`. Damage: 0.
- **Behavior:**
  - Hold `block` → `HealthComponent.is_blocking = true`. Incoming damage from the ±60° front cone:
    - **Physical damage:** reduced by 70% (bible §3 6-sided, "Block: 70%"). Remaining 30% passes through.
    - **Resonance damage:** reduced by 100%; 30% of blocked amount converts to healing (1 HP quarter per 3 amount blocked, min 1).
  - Movement slowed to 60% while blocking.
  - **Parry window:** first 0.18 s of block. On parry of a staggerable enemy: emit `boss_damaged` (if boss) or `enemy_damaged` (else) with `amount = 0, stagger_seconds = 2.0, source = player, type = "parry"`. No `DamageInfo` cheating — team tracked on source.
  - **Stabilizer tile activation:** while `is_blocking` AND standing on a `ShieldStabilizer` tile, tile activates. This is the core R7 verb.
- **Bible process-order:** stabilization is the required step after any disruption (5-sided or 11-sided). `ProcessOrder` autoload enforces this for bosses — a boss cannot transition to Phase 4 if the player has disrupted (Phase 2 Pentagram) but not stabilized within 30 s.

### 11.7 Octagon Harmonizer (8-sided) — integration

- **Frequency:** 852 Hz. **Color:** `#FFD700` gold.
- **Mesh:** regular octagonal prism, held like a bowl. Emits `completion_wave.gdshader` gentle gold pulse.
- **Tags:** `["completion"]`. Damage: 0.
- **Resonance required:** 30 (Alchemist's integration dialogue bumps player resonance by +20, unlocking it).
- **Acquisition:** **granted narratively during Alchemist's Phase 4 integration sequence**. Not a hidden pickup. The Alchemist "passes on the completion geometry" as her final act. Before that moment the player does not have the Octagon Harmonizer; during the Alchemist's Phase 4 the player is prompted to equip it from a UI cue and use it to complete the transformation. See §13.2.
- **Behavior:**
  - **Tap:** aimed completion wave — a 6 m cone forward. Effects inside:
    - Any node in group `"incomplete_mechanism"` receives `complete()` (finishes partial bridges, mechanisms, environmental healing). Emits `SignalBus.process_step_completed(&"complete")`.
    - `"integrating_boss"` group members (a boss in Phase 4) advance their `integration_progress` by +0.33. Three waves finish Phase 4.
    - Corrupted terrain patches (`"corrupted_terrain"`) restore to clean form, particle puff, emit `process_step_completed`.
  - **Charged (hold ≥ 1.0 s):** mass completion pulse, 6 m radius, heals player 2 HP quarters, completes all eligible patterns in radius.
  - Cooldown 4 s on tap, 12 s on charged.
- **Bible requirement:** Phase 4 of every boss requires three successful Harmonizer waves on the boss.

### 11.8 Reserved post-v1
9-sided Nonagon, 10-sided Decagon, 11-sided Hendecagon (+ safety/chaos system), 12-sided Dodecagon Crown, 13-sided Tridecagon, 14-sided Tetradecagon. Also reserved: Pentagram's charged inversion field upgrade to "pentagonal barrier," Harmonizer's "cycle completion" passive for all nearby mechanisms.

---

## 12. Enemy Framework

Unchanged base scene and AI contract. Adds:

- **`SlowmoAgent`** component on every enemy and projectile. Reads `slowmo_scale` from `SignalBus.slowmo_broadcast` during Lens. Default 1.0.
- **`pattern_locked: bool`** on EnemyResource drives the ×2 Blade/Pentagram bonus; visible to player via subtle geometric outline shader when within 10 m (teaches the mechanic visually).

### 12.3 Triangle Elemental (R2)

Unchanged from prior spec. Pattern-locked.

### 12.4 Anxiety Storm (R7) — replaces Construct Guard

- **Mesh:** a small cloud of spinning 4-sided pyramids (procedural) around a dark core. `mat_corrupted_4sided`.
- **Stats:** HP 5, contact damage 1, move speed 3.2.
- **Attack:** pulsing radial burst; damage resonance-type (blocked by shield at 100%).
- **Behavior:**
  - Not defeated by damage alone. Attacking a storm increases its `agitation` (visible as spin speed + particle density); at agitation 3 it splits into two smaller storms.
  - **Correct approach:** stand still (no input) inside its 6 m radius for 3.0 s. Agitation decays to 0. Storm dissolves with gold particles. This is the observe-without-interfering mechanic teachable at enemy scale.
  - Alternatively: Heptagon Lens held on it for 3.0 s dissolves it without the stand-still requirement.
- **Pattern-locked:** false (not a pattern to break — a presence to witness).

---

## 13. Boss Framework — Canonical 4-Phase

### 13.1 Base (`bosses/boss.gd` extends `enemies/enemy.gd`)

Every slice boss (and every post-slice boss) follows the **bible §4 universal structure**.

```gdscript
class_name Boss extends Enemy
@export var boss_resource: BossResource
var phase_index: int = 1                # 1..4
var difficulty_modifier: float = 0.0    # accumulates per bible §4
var observation_dwell_s: float = 0.0    # Phase 1 accumulator
var intervention_progress: float = 0.0  # Phase 2 0..1
var vulnerability_elapsed_s: float = 0.0
var integration_waves: int = 0          # Phase 4, need 3
```

#### Phase 1 — Recognition (required weapon: Heptagon Lens)

- Boss is **invulnerable**. Attempting to damage triggers a dodge + `hud_message("You must see it first.")` on first try only.
- Boss paces / idles / performs a signature non-threatening movement.
- Player must hold Lens with boss in camera frame continuously for `boss_resource.observation_duration_s` (default 4.0 s). On completion: `SignalBus.boss_observed(boss)` → advance to Phase 2; `ProcessOrder.record(&"observe")`.
- HUD shows: "Witness the pattern" + observation progress ring.

#### Phase 2 — Intervention (required weapon: `boss_resource.required_intervention_weapon`)

- Boss is **vulnerable only to the correct tool**; other weapons do nothing (no damage, no stagger) and print `hud_message("The wrong geometry. Observe again.")` once.
- Boss actively tests the player (its attack patterns intensify per bible; for slice, `difficulty_modifier += 0.25` if player uses wrong tool repeatedly, capped at +1.0).
- Each successful intervention hit advances `intervention_progress` by `1.0 / hits_required`. Hits required default: 5.
- At progress == 1.0: Phase 2 → Phase 3.

#### Phase 3 — Vulnerability (critical choice moment)

- Boss kneels / opens / stills. **Totally invulnerable to damage.** Any `DamageInfo.amount > 0` received on the boss hurtbox immediately triggers `boss_re_corrupted(boss, difficulty_modifier + 0.25)`; the fight resets to Phase 1 with the new modifier (boss HP thresholds unchanged but `difficulty_modifier` increases — scales `intervention_progress` gain rate downward and attack telegraphs shorter).
- Player must *not attack*. The window lasts `boss_resource.vulnerability_window_s` (default 6.0 s).
- During this window, `phase3_warning_dialogue` plays overhead (a single DialogueLine rendered as floating text via `hud_message`, not the dialogue box).
- On timer expiry without a damaging attack: `ProcessOrder.record(&"stabilize")` (passing the test = stabilizing the boss's opening) and advance to Phase 4.

#### Phase 4 — Integration (required weapon: Octagon Harmonizer)

- Boss radiates a gold field; UI prompts "Complete the pattern (Octagon Harmonizer)".
- **Special-case for the Alchemist's Phase 4 only:** if the player does not yet own the Octagon Harmonizer (first boss), a ceremonial pickup appears in front of the boss; player picks it up via `interact`, which:
  - Adds `octagon_harmonizer` to `GameState.inventory_weapon_ids`.
  - Bumps `GameState.stats.resonance += 20` (unlocks Lens+Harmonizer thresholds cleanly).
  - Auto-equips the Harmonizer as primary (prior primary goes to inventory).
  - Plays `alchemist_phase3_warning_dialogue` → `alchemist_integration_dialogue`.
- Player aims Harmonizer at boss and fires 3 completion waves (tap or charge). Each wave advances `integration_waves`; at 3: phase complete.
- On Phase 4 completion: boss transforms (dissolve + reform shader sequence), `SignalBus.boss_integrated(boss_id)`, dialogue, fade to Nexus, `boss_became_ally(boss_id)` fires, `GameState.flags["defeated_<boss_id>"] = true`, `GameState.field_integrity_max += 4`, `ProcessOrder.record(&"integrate")`.

**ProcessOrder records by phase transition (summary):**
- Phase 1 → 2: `record(&"observe")`.
- Phase 2 → 3: record a step derived from the boss's intervention weapon tag — `&"disrupt"` if `"inversion"` tag (Alchemist/Pentagram), `&"stabilize"` if `"shield"` tag (Observer/Shield), `&"complete"` if `"completion"` tag, `&"intervene"` otherwise. This is a one-liner in the Phase 2 exit function.
- Phase 3 → 4: `record(&"stabilize")` (the choice to not attack is the stabilization act — even when the intervention step was already stabilize; records are a log, not a set).
- Phase 4 complete: `record(&"integrate")`.

### 13.2 The Crystallized Alchemist (R2) — canonical 4-phase

- **Core wound:** `RIGIDITY` — trapped in the 4-sided prison of her own making. Bible §3 4-sided = corruption.
- **Stuck geometry:** 4 (square pyramid).
- **Required intervention weapon:** Pentagram Inverter (5-sided, 528 Hz matches region frequency, emerald palette).
- **Required integration weapon:** Octagon Harmonizer (granted mid-Phase 4, see §13.1).
- **Observation duration:** 4.0 s.
- **Vulnerability window:** 6.0 s.

**Arena:** inverted triangular pit, ~20 m across, emerald-lit, three corrupted crystal pedestals at the triangle's vertices. A slow gold 432 Hz drone underlies the emerald 528 Hz regional track.

**Phase 1 — Recognition:** Alchemist walks the perimeter of her self-made 4-sided prison (visible as a cage of red-shadow square pyramids, `mat_corrupted_4sided`). Player holds Lens on her for 4.0 s. Lens reveals: her real form (emerald, graceful) through the corruption shell, plus "Stuck at 4. Needs 5." floating text. → Phase 2.

**Phase 2 — Intervention:** Alchemist's prison bars rotate and slam down around the player in attacks (hitboxes on rotating `StaticBody3D`s); player Pentagram-Inverts the bars to break them. Each successful Pentagram tap hit on a prison-bar destroys it and bumps `intervention_progress` by 0.2. At progress == 1.0 the prison shatters. Pentagram's charged inversion-pulse works too (accelerates progress). Other weapons do nothing on the bars.

**Phase 3 — Vulnerability:** Alchemist collapses to the pit's center, emerald light flickering through the red. Overhead floating text: *"She has dropped her guard. Attacking will re-corrupt her. Be still, or stabilize with shield."* 6 seconds. If player attacks: `boss_re_corrupted`, back to Phase 1, `difficulty_modifier += 0.25` (reduces Phase 2 progress gain by 20%). If player waits or blocks: `ProcessOrder.record(&"stabilize")` → Phase 4.

**Phase 4 — Integration:** Alchemist rises. A single Octagon Harmonizer pedestal materializes in front of her (interact to acquire, see §13.1). Player fires 3 completion waves at her. On the third: she transforms into the **Emerald Alchemist**, speaks `alchemist_integration_dialogue`, dissolves in gold. Fade to Nexus Main; she's standing beside the R2 portal pedestal as an interactable NPC (`alchemist_nexus_npc` dialogue). Flags set: `defeated_alchemist = true`, `has_octagon_harmonizer = true`. Field integrity max += 4. Resonance += 20.

### 13.3 The Overwhelmed Observer (R7) — canonical 4-phase

- **Core wound:** `WITNESS_TRAP` — paralyzed by seeing too much, cannot act; the bible's Mirror Sage archetype re-cast.
- **Stuck geometry:** 7 (bound at the suspension threshold).
- **Required intervention weapon:** Hexagonal Shield (stabilization — the observer needs grounding, not disruption). Bible principle: after 7-sided (observation) comes 6-sided (stabilization).
- **Required integration weapon:** Octagon Harmonizer (already owned from R2).
- **Observation duration:** 4.0 s.
- **Vulnerability window:** 8.0 s (longer — the temptation to act is higher here).

**Arena:** a perfectly round white meditation dome, concentric circular tile grid, no ceiling (sky shader visible). Seven stillness pillars arranged in a heptagon around the perimeter. Silence — no music until Phase 2.

**Phase 1 — Recognition:** Observer sits cross-legged in the center, a ring of seven floating mirror-prism fragments orbiting them at head height. Player holds Lens on the Observer for 4.0 s. Lens reveals: the Observer is surrounded by a second, larger ring of 4-sided corruption pyramids feeding back into them (the witness-trap geometry). Text: *"Seeing everything. Doing nothing. Needs 6."* → Phase 2.

**Phase 2 — Intervention:** The seven mirror-fragments extend beams that project illusion phantoms (ghost-enemies) that try to overwhelm the player. Standing on a `ShieldStabilizer` tile at the base of any stillness pillar while blocking collapses that pillar's feed-loop. 7 tiles, 7 pillars. Each stabilized pillar += 0.143 intervention progress. Using any other weapon on the phantoms resets their count (they're not the real obstacle). At progress == 1.0 (all 7 pillars stabilized): Phase 3.

**Phase 3 — Vulnerability:** Observer opens their eyes, looks at the player directly for the first time. 8 seconds. Overhead text: *"They have stopped watching. They are asking. Attacking is a louder noise. Wait with them."* If player attacks or even moves rapidly (velocity > 4 m/s for > 0.5 s): `boss_re_corrupted`. If player stands still: `ProcessOrder.record(&"stabilize")` → Phase 4.

**Phase 4 — Integration:** Observer rises, offers a gesture. Player uses already-owned Harmonizer (3 waves). On the third: Observer transforms into the **Balanced Witness**. Dialogue, fade to Nexus. NPC appears beside R7 portal. Flags set: `defeated_observer = true`. Field integrity max += 4. Resonance += 10.

---

## 14. World Structure

### 14.1 Region scene

```
Region_XX (Node3D, script: region.gd)
├── resource: RegionResource (exported)
├── Rooms (Node3D)                   # only current room instanced
├── WorldEnvironment
│   ├── Environment (per-region palette, fog, glow)
│   └── Sky (uses region.sky_shader_path)
└── AudioAmbient (AudioStreamPlayer, plays region drone mixed under 432 Hz world drone)
```

### 14.2 Room scene

```
Room (Node3D, script: room.gd)
├── Geometry (baked MeshInstance3D + StaticBody3D; CSG is authoring-only, baked before commit — see §20.6)
├── NavigationRegion3D (baked navmesh, .res committed sibling)
├── PlayerSpawns (Node3D; children are Marker3D named per incoming direction or custom key)
├── Enemies (Node3D; children spawned/freed on room enter)
├── Interactables (Node3D)
├── Doors (Node3D; Door nodes with target_room_id + target_spawn)
├── Triggers (Node3D)
├── CorruptionVolumes (Node3D; optional — for regions/rooms with 4-sided corruption debuff)
├── Dressing (Node3D; decorative MeshInstance3Ds — see §20.7 density rule)
└── EnvironmentOverride (WorldEnvironment, optional per-room)
```

### 14.3 Room transitions

- Player enters a Door volume. Door emits `SignalBus.door_opened(door_id)` and calls `SceneRouter.change_room(region_id, room_id, spawn_name)`.
- `SceneRouter`:
  1. Fade to black (0.3 s).
  2. Free current room node.
  3. Threaded-preload new room scene via `ResourceLoader.load_threaded_request` kicked off at fade start; `load_threaded_get` resolves at fade midpoint.
  4. Instance new room as child of `Region.Rooms`.
  5. Position player at matching `PlayerSpawn`.
  6. Navmesh is pre-baked (no runtime rebake).
  7. Fade in (0.3 s).
  8. Emit `SignalBus.room_entered(new_room_id)` after fade-in completes (prevents autosave during load; see §18).

### 14.4 Interactables

`Interactable.gd` exports `on_interact_dialogue: DialogueLine` and/or `on_interact_signal: StringName`. Player's `InteractRay` raycasts → if result is an Interactable, emit `interactable_hovered(interactable)`. HUD shows "[E] ${prompt}". On `interact`, node runs its handler. On raycast miss or different hit, emit `interactable_unhovered(prev)`.

### 14.5 Inverted gravity (R2 gravity_flip room)

- `GravityFlipVolume` Area3D: on body_entered (player only), set `player.up_direction = Vector3.DOWN` and `player.gravity_scale = -1` (implemented as applying +24 m/s² instead of -24). Call `player.camera_rig.set_world_up(Vector3.DOWN)`.
- On body_exited or leaving through a specific exit Marker3D: restore `up_direction = Vector3.UP`, `gravity_scale = 1`, camera up.
- Pitch clamps remain `[-60°, +45°]` relative to current up; math uses `player.up_direction`.
- Lock-on targets that require orientation (e.g. on-ceiling enemies) work because lock-on geometry uses camera basis, not world Y.

---

## 15. Puzzle Primitives

| Primitive              | Trigger                                                   | Used in            |
|------------------------|-----------------------------------------------------------|--------------------|
| `WeightPlate`          | Body in group `"weighted"` on it                          | R2, R7             |
| `ResonanceSwitch`      | Attacked by weapon matching `tags_required` **AND** `pyramid_sides_required` | R2                 |
| `LensTarget`           | In view while player holds Lens for `dwell_s`             | R2, R7             |
| `ShieldStabilizer`     | Player `is_blocking` while standing on it                 | R7 (7 of them)     |
| `TimedDoor`            | Opens on trigger for N seconds, then closes               | R2, R7             |
| `CrystalPedestal`      | Correct weapon tag + correct order                        | R2 boss arena      |
| `CorruptionVolume`     | **4-sided geometry debuff area — see below**              | R2, R7 boss arena  |
| `StillnessZone`        | **R7 primitive: success only if no player input for dwell** | R7               |

### 15.1 CorruptionVolume (4-sided debuff)

- **Scene:** `puzzles/corruption_volume.tscn`. Visual: translucent red-shadow square pyramids (`mat_corrupted_4sided`, emissive `#8B0000`, corruption shader UV warp) embedded in the volume space.
- **Collision:** Area3D on layer `trigger`, mask `player + enemy`.
- **On body_entered (player):** emit `corruption_entered(self)`. Apply debuff state on player (§8.2): -20% move speed multiplier, -15% weapon damage (before stability mitigation reduces the debuff).
- **On body_exited:** restore; emit `corruption_exited(self)`.
- **Visible world-language rule:** every CorruptionVolume's geometry is always 4-sided square pyramids — never any other shape. Teaches Principle 3 visually.
- **Dispellable:** a Pentagram Inverter charged pulse within the volume disables it for 5 s (per §11.5). A permanent dispel is achievable by completing a region-local puzzle per room; this is authored per use.

### 15.2 StillnessZone (R7 specialty)

- Area3D volume. On body_entered (player), start `dwell_s` countdown timer.
- If any movement input arrives during the countdown (non-zero `Input.get_vector("move_left","move_right","move_up","move_down")` or any action just_pressed except `lens`), reset to 0.
- On successful dwell: emit `puzzle_solved(puzzle_id)`.
- Paired visual: silver pulse ring expanding from zone center each second; a dissonant tone plays on reset.

### 15.3 PuzzleGroup

`puzzle_group.gd` aggregates child primitives. Exports `required_puzzle_ids: Array[StringName]`, `completion_window_s: float` (use -1 for no time window, positive for simultaneous requirement). On every child `puzzle_solved`, check group satisfaction and emit group's own `puzzle_solved`. Triangle-lock (R2) uses `completion_window_s = 2.0`.

---

## 16. Dialogue System

Unchanged. Notes:
- Phase 3 warning text during boss fights is rendered via `hud_message` not the dialogue box (no gameplay pause during the vulnerability window).
- Portraits: for the slice, use an `@export var portrait_texture: Texture2D` on `DialogueLine` rather than a live 3D Viewport. Faster to build, indistinguishable at the slice's scope. (Viewport approach deferred to v0.2.)

---

## 17. UI / HUD

- **HUD (`ui/hud.tscn`):**
  - Top-left: field integrity hearts (quarter-heart granularity; start at 3 hearts / 12 quarters).
  - Top-right: current primary weapon icon + name.
  - Bottom-left: shield equipped indicator (if Hex Shield in inventory).
  - Bottom-center: interact prompt (contextual).
  - Bottom-right: lens_energy meter (only when lens equipped) + inverter_energy meter (only when pentagram equipped).
  - Mid-screen: transient `hud_message`.
  - **Boss bar (`ui/boss_bar.tscn`):** bottom-center during encounters. **Four-phase segmented bar**, not HP. Phase 1 fill = observation dwell ratio; Phase 2 = intervention_progress; Phase 3 = vulnerability timer countdown (shown in silver/gold, labeled "Hold — do not attack"); Phase 4 = integration_waves / 3. Bar color-shifts per phase: red (corrupted) → amber (intervening) → silver (vulnerable) → gold (integrating).
  - Stats overlay (pause-only): coherence/resonance/stability/flow with their numeric value and derived effect (e.g. "Flow 10 → +10% move speed").
- **Pause (`ui/pause_menu.tscn`):** Resume / Save / Load / Options / Quit.
- **Inventory (`ui/inventory.tscn`):** grid of owned weapons with descriptions; equip on select. Five slots in slice.
- **Title (`ui/title.tscn`):** New Game / Load / Quit.
- **Fade overlay:** unchanged.

---

## 18. Save System

Format: JSON at `user://save_slot_<N>.json` (N = 0..2). Versioned. Autosave on room transition **after** fade-in completes (not during load). Manual save via pause menu.

### Schema (v1):

```json
{
  "version": 1,
  "timestamp_iso": "2026-04-18T19:00:00Z",
  "player": {
    "current_region": "hub",
    "current_room": "room_nexus_main",
    "spawn_point": "start",
    "field_integrity": 12,
    "field_integrity_max": 12,
    "stats": {"coherence": 10, "resonance": 10, "stability": 10, "flow": 10},
    "lens_energy": 3.0,
    "inverter_energy": 2.0,
    "equipped_weapon": "tetrahedron_blade",
    "inventory_weapon_ids": ["tetrahedron_blade"]
  },
  "flags": {
    "nexus_tutorial_completed": false,
    "met_alchemist": false,
    "defeated_alchemist": false,
    "has_octagon_harmonizer": false,
    "met_observer": false,
    "defeated_observer": false,
    "region_02_unlocked": true,
    "region_07_unlocked": false
  },
  "puzzles_solved": [],
  "process_order_log": []
}
```

Roundtrip test required.

---

## 19. Audio

- **Buses:** Master → (Music, SFX, UI, Ambience, Tones). Tones bus carries the 432 Hz world drone + per-pyramid sine waves triggered on weapon use.
- **World drone:** `AudioManager.play_world_drone()` on game start. Loops `audio/tones/432_drone.ogg` on Tones bus at -24 dB under music. Never stops except at title.
- **Region drone:** played on `region_entered`, crossfade 1.5 s with previous region drone. Per-region path from `RegionResource.ambient_drone_path`. Detunes by `-30% * corruption_level` if the current room has active CorruptionVolumes (uses `AudioEffectPitchShift` on the region drone's bus).
- **Per-pyramid weapon tones:** fired on `attack()` as a one-shot on Tones bus. Frequencies per bible §9:

  | Sides | Hz   | File (placeholder CC0 or `AudioStreamGenerator`) |
  |-------|------|--------------------------------------------------|
  | 3     | 432  | `tones/tone_432.wav`                             |
  | 5     | 528  | `tones/tone_528.wav`                             |
  | 6     | 432  | `tones/tone_432.wav` (shared; layered panning)   |
  | 7     | 741  | `tones/tone_741.wav`                             |
  | 8     | 852  | `tones/tone_852.wav`                             |

- **Music:** `nexus_ambient.ogg`, `region_02_theme.ogg`, `region_02_boss.ogg`, `region_07_theme.ogg` (silence-heavy), `region_07_boss.ogg` (near-silence with single bell tones).
- **SFX:** see PLAN M20 for the full list.

---

## 20. Art & Rendering (Geometric Primitives Aesthetic)

### 20.1 Palette

| Use                        | Color (hex)   | Notes |
|----------------------------|---------------|-------|
| World default stone        | `#2A2F3A`     | Dark cool grey |
| Crystal Nexus accent       | `#8EE3FF`     | Cyan |
| Region 2 primary (earth)   | `#3A6B2F`     |   |
| Region 2 accent (emerald)  | `#50C878`     | matches bible 5-sided |
| Region 7 primary (silver)  | `#E8E8EF`     | near-white, cool |
| Region 7 accent (white)    | `#FFFFFF`     | luminous |
| Corruption (4-sided)       | `#8B0000`     | red/shadow; bible §3 |
| Enemy aether (R7)          | `#C0C0C0`     | silver |
| Player signature           | `#E0F6FF`     | blue-white; matches 3-sided |
| UI primary                 | `#F2F2F7`     |   |
| UI secondary               | `#7A7A88`     |   |

**Palette contrast:** Nexus (cool cyan) → R2 (warm deep emerald) → R7 (stark near-white silver). Three clearly distinct visual identities at a glance.

### 20.2 Mesh library (`meshes/polyhedra.gd`)

Static `ArrayMesh` builders. Needed in slice: `tetrahedron`, `cube`, `square_pyramid` (corruption), `pentagonal_star`, `hexagonal_prism`, `heptagon` (flat), `octagonal_prism`, `merkaba`, `sphere_proc` (for R7). Each returns normals + UV1 + vertex color hook.

### 20.3 Shaders

- **`resonance_glow.gdshader`:** emissive + Fresnel rim. Params: `tint`, `rim_power`, `pulse_hz`, `phase_offset`.
- **`corruption.gdshader`:** UV warp + chromatic fringe + red-shadow tint. Applied to CorruptionVolume geometry.
- **`dissolve.gdshader`:** threshold dissolve. Enemy death, boss transformation.
- **`lens_overlay.gdshader`:** Environment override effect (desaturate + tinted edge detect + silver geometric HUD overlay).
- **`inversion_ripple.gdshader`:** concentric emerald ripple expanding from a point, for Pentagram charged pulse.
- **`completion_wave.gdshader`:** gold bloom pulse, for Octagon tap/charge.
- **`sky_nexus.gdshader`:** concentric hexagonal grid fading into starfield.
- **`sky_region_02.gdshader`:** inverted triangles drifting across deep emerald-black gradient.
- **`sky_region_07.gdshader`:** pure white gradient with slow concentric ripples; minimal features (matches observation theme).

### 20.4 Lighting + Environment (load-bearing)

- Directional key light per region, slightly warm (Nexus: `Color(1.0, 0.96, 0.88)`; R2: `Color(0.9, 1.0, 0.85)`; R7: pure `Color(1.0, 1.0, 1.0)`).
- `WorldEnvironment.environment` settings shipped per region:
  - `glow_enabled = true`, `glow_intensity = 0.8`, `glow_bloom = 0.1`, `glow_hdr_threshold = 1.0`.
  - `tonemap_mode = Environment.TONE_MAPPER_FILMIC`.
  - `tonemap_exposure` tuned per region (Nexus 1.0, R2 0.85, R7 1.15).
  - `fog_enabled = true`, `fog_density = 0.015` (Nexus), 0.03 (R2), 0.008 (R7 — less fog, more space).
  - `fog_light_color = region_resource.fog_color`.
- `CameraAttributesPractical`: `auto_exposure_enabled = false` (manual per-region exposure; prevents the lens/boss flash-blindness).
- **No dynamic shadows in slice.**

### 20.5 Particles

- Weapon swing trails (Blade emissive cyan trail, Pentagram emerald rotating spiral, Harmonizer gold bloom).
- Hit flash: modulate-to-red tween 0.08 s + small spark GPUParticles3D.
- Phase change: large emissive burst + chromatic aberration pulse (2D CanvasItem overlay).
- **Ambient motes:** every decorative emissive mesh emits 1–3 slow-drifting motes (`GPUParticles3D`) matching its tint. Makes rooms feel breathing. Cap: 8 motes per room via LOD culling.

### 20.6 CSG policy

CSG is **authoring-only**. Before merging a room scene to main, run `tools/bake_csg.gd` (editor script, written in the polish milestone) which:
1. Selects each `CSGCombiner3D` under `Room.Geometry`.
2. Gets its baked mesh via `get_meshes()`.
3. Replaces with a `MeshInstance3D` + `StaticBody3D` + `ConcavePolygonShape3D`.
4. Commits the baked `.res` mesh.

Never commit CSG as runtime geometry. This prevents the per-frame CSG re-evaluation and collision-seam bugs the technical auditor flagged.

### 20.7 Set-dressing density

**Every room scene MUST contain ≥ 15 decorative `MeshInstance3D` objects** under `Room.Dressing`, drawn from the per-region decoration pool (procedural crystals, broken platonic fragments, floating glyphs). Each decorative mesh:
- Uses `resonance_glow.gdshader` with `pulse_hz` randomly in `[0.15, 0.6]` and `phase_offset` random in `[0, 2π]` so no two mesh instances pulse in sync.
- Uses region-palette accent color with ±15% value variation.
- Has 1–3 GPUParticles3D motes attached (see §20.5).

Room acceptance criteria in PLAN includes a ≥ 15 count check.

---

## 21. Naming & Style Conventions

Unchanged. Summary:
- snake_case files + scripts. PascalCase class_names. snake_case signals + group names.
- Strict typed GDScript, no `Variant`.
- One class_name per file.
- Commit message areas: `player`, `combat`, `world`, `ui`, `save`, `audio`, `weapons`, `enemies`, `bosses`, `region02`, `region07`, `nexus`, `puzzles`, `shaders`, `chore`.

---

## 22. Performance Budget

- Draw calls ≤ 300/room.
- Active physics bodies ≤ 40/room.
- No per-frame navmesh rebakes.
- ≤ 1 full-screen post-process environment swap at a time (Lens is the only one in slice).
- ≤ 16 concurrent audio voices (drone + region drone + music + up to 13 one-shots).
- GPUParticles3D: ≤ 80 active per room.

---

## 23. Risks & Mitigations

| Risk                                             | Mitigation |
|--------------------------------------------------|------------|
| Lens global time-scale wrecks gameplay feel      | Per-node `SlowmoAgent`; player is never slowed. |
| CSG collision seams                              | Offline bake-CSG pass before merge (§20.6). |
| Runtime navmesh rebakes hitch                    | Pre-bake + commit. |
| Primitives aesthetic looks amateurish            | Sky shader per region + fog + bloom + ≥15 dressing rule + palette contrast (§20). |
| Boss Phase 3 feels like a DPS check              | Hard invulnerability + re-corruption penalty + floating warning text + silver-colored bar. |
| Players attack during vulnerability out of habit | Phase 3 warning dialogue + distinctive silver palette + first-offense HUD message before reset is final. |
| Octagon Harmonizer acquisition feels grafted-on  | Alchemist Phase 4 narratively grants it as her final act; tied to ability by design (not a hidden pickup). |
| Scope creep back toward full design doc          | Every PR cites milestone ID. Non-milestone work requires amended PLAN entry. |

---

## 24. Decisions (locked 2026-04-19)

1. **Movement:** fully analog (Ocarina-like).
2. **Death penalty:** respawn at last room entrance, full HP.
3. **Lock-on:** locks yaw + pitch (gentle downward offset).
4. **Hearts:** 3 full hearts (12 quarters) start; +1 full heart per boss integrated.
5. **No dodge in v1.** Only movement cancels into block.
6. **Region selection:** Region 2 (Collapsing Triangle Mines) + Region 7 (Sphere Pulse Meditation Domes). R5 Cubic Foundries deferred.
7. **Weapon kit (5):** Tetrahedron Blade, Pentagram Inverter, Hexagonal Shield, Heptagon Lens, Octagon Harmonizer. This is the canonical bible process order.
8. **Bosses:** Crystallized Alchemist (R2), Overwhelmed Observer (R7). Both canonical 4-phase.
9. **Weapon acquisition progression:**
   - Nexus tutorial grants Blade + Lens.
   - R2 early-game grants Pentagram Inverter and Hexagonal Shield.
   - Alchemist Phase 4 grants Octagon Harmonizer (+ resonance 20).
   - R7 uses the full kit.
10. **Combat-as-healing:** hard-locked via canonical 4-phase boss framework + vulnerability re-corruption penalty.
11. **Lens time-dilation:** per-node `SlowmoAgent`, never global `Engine.time_scale`.
12. **CSG:** authoring-only, bake before commit.
13. **Navmesh:** pre-baked + committed, never runtime rebake.
14. **Stats:** four-stat bible formulas, all wired into slice.
15. **φ-based damage math:** deferred. Slice uses integer math. Weapon damage methods tagged `# TODO(phi-math)` where a post-slice swap applies.
16. **Octagon Harmonizer:** granted narratively in Alchemist Phase 4. Not hidden. Not purchasable. Not missable.
17. **Accessibility:** Godot standard (volume sliders, key rebinds). Full audio-geometry + haptic + cognitive suites deferred.

**Scope confirmation:** Crystal Nexus hub + R2 + R7. 5 weapons. 2 canonical 4-phase bosses. Everything else in `geometry_quest_game_design.md` and `geo_quest_lore&mechanics_bible.md` is out-of-scope for v1.
