# Geometry Quest — Vertical Slice Build Plan

Ordered milestones M0 → M21 for the v1 vertical slice defined in `SPEC.md`.
Each milestone has files, key notes, and **acceptance criteria**. Every PR
cites a milestone ID.

See `SPEC.md §0` for scope and `SPEC.md §24` for locked decisions. This plan
reflects Path 3: **bible-compliant slice with 5 weapons + canonical 4-phase
bosses + R2 + R7**.

---

## How to read this

Each milestone contains:
- **Goal:** one-sentence outcome.
- **Depends on:** prior milestones.
- **Files created / modified:** paths from `SPEC.md §2`.
- **Key notes:** the non-obvious bits.
- **Acceptance criteria:** must all pass before the next milestone starts.
- **Est. complexity:** S / M / L (sessions).

---

## Milestone 0 — Project Scaffolding

**Goal:** Empty but well-structured Godot 4.3 project that opens, runs `scenes/main.tscn`, passes a scaffolding self-test.
**Depends on:** none. **Est:** S.

**Files:**
- `project.godot` — Forward+ renderer, input map per SPEC §4 (no Shift+Q), autoloads per SPEC §3 (six, no InputManager), 10 physics layers per §5.
- `.gitignore` — standard Godot + OS.
- `globals/signal_bus.gd` — all signals from §7 declared, no logic.
- `globals/audio_manager.gd` — stub (`play_music`, `play_sfx`, `play_world_drone`, `stop_music`).
- `globals/game_state.gd` — runtime state fields matching §18 save schema.
- `globals/save_manager.gd` — stub (`save(slot)`, `load(slot)`, `has_save(slot)`).
- `globals/scene_router.gd` — stub (`change_region`, `change_room`, `fade_out`, `fade_in`).
- `globals/process_order.gd` — stub (`record(step: StringName)`, `query(step: StringName) -> float` returns seconds since last record, `clear()`).
- `resources/*.gd` — nine resource class files per §6 (weapon, enemy, boss, boss_phase, region, dialogue_line, dialogue_choice, damage_info, stats). `DialogueChoice` in its own file. Stats includes bible formula methods (`hit_chance`, `corruption_resistance_percent`, `move_speed_mult`, `accessible_pyramids`).
- `scenes/main.tscn` — minimal "Geometry Quest" label.
- `scenes/test_room.tscn` — 30×30 m plane with a few cube props for M1+.
- `ui/fade.tscn` + `fade.gd` — full-screen ColorRect with `fade_out(t)` / `fade_in(t)` tween.
- `tests/test_scaffolding.gd` — asserts all autoloads present + all resource classes load + Stats formulas return expected values at default.

**Acceptance:**
- [ ] `godot --headless --quit` exits 0.
- [ ] Running project shows title label.
- [ ] `tests/test_scaffolding.gd` passes headless.
- [ ] No editor console errors on open.
- [ ] All 10 physics layers named; 14 input actions bound; 6 autoloads registered in order.
- [ ] `Stats.new().hit_chance()` returns ~0.73; `move_speed_mult()` returns 1.10; `accessible_pyramids()` returns `[3, 5, 6]`.

---

## Milestone 1 — Player Controller & Camera

**Goal:** Drive a player capsule through `test_room.tscn` with Ocarina-style 3rd-person camera, jump, smooth follow.
**Depends on:** M0. **Est:** M.

**Files:**
- `player/player.tscn` + `.gd` — movement per §8.2, state machine with Idle/Move/Jump (others stubbed).
- `player/camera_rig.tscn` + `.gd` — Follow mode, `set_world_up(Vector3)` supported.
- `player/states/player_state.gd` (base) + `idle_state.gd`, `move_state.gd`, `jump_state.gd`, `state_machine.gd`.
- `meshes/polyhedra.gd` — implement `tetrahedron`, `cube`, `square_pyramid`, `pentagonal_star`, `hexagonal_prism`, `heptagon`, `octagonal_prism`, `merkaba`, `sphere_proc`.
- `materials/mat_player.tres`, `mat_world_stone.tres`.
- `environments/env_debug.tres` — minimum Environment (glow + Filmic + fog) so emissive shaders actually glow.
- `shaders/resonance_glow.gdshader`.
- `world/room.gd` base.
- `scenes/debug_hud.gd` — dev overlay for vibes-based acceptance (toggle F1).

**Key notes:**
- Player body mesh: merkaba. Slow Y-rotation while idle. `pulse_hz=0.2` (meditative).
- Player scene includes `DirectionHint` tetrahedron child so the 4-fold-symmetric merkaba has a clear forward axis.
- Camera: soft-follow with `lerp_angle` on yaw/pitch, SpringArm3D for wall pull-in. Realign behind player after 1.5 s of no camera input + forward speed > 1.0 (forward speed = `-velocity.dot(basis.z)` — handles backpedal).
- Gamepad + mouse both working. `cam_up/cam_down/cam_left/cam_right` input actions added in M1.
- **Dev-only:** During M1 iteration, `project.godot` `run/main_scene` swapped from `scenes/main.tscn` to `scenes/test_room.tscn`. **Revert before shipping M13** (reminder also at M13).

**Acceptance:**
- [ ] WASD + Space + mouse/gamepad all drive movement/camera without jitter.
- [ ] Walking off a 3 m ledge and back feels grounded.
- [ ] SpringArm prevents camera clipping.
- [ ] 30 s of free play: no errors, no hitches.

---

## Milestone 2 — Combat Framework (weapon-agnostic)

**Goal:** Hitbox/Hurtbox/HealthComponent working; damage signals wired; i-frames; stagger; validated against a dummy enemy.
**Depends on:** M1. **Est:** M.

**Files:**
- `combat/hitbox.tscn` + `.gd`.
- `combat/hurtbox.tscn` + `.gd`.
- `combat/health_component.gd` (includes §10.1 stability mitigation formula).
- `resources/damage_info.gd` full implementation.
- `player/states/attack_state.gd` (uses a placeholder "test weapon" attached at M3).
- `player/states/hit_state.gd`.
- `enemies/enemy.gd` + `enemy.tscn` base (no AI yet; static target with hurtbox).
- `combat/slowmo_agent.gd` — per-node scale, default 1.0.
- `tests/test_damage.gd` — instantiate Hitbox + Hurtbox + HealthComponent, overlap, assert stability-mitigated damage + signals.

**Key notes:**
- HealthComponent applies stability mitigation: `dealt = max(1, info.amount - floor(stats.stability / 5))`.
- I-frames 0.6 s post-hit.
- Knockback: apply to CharacterBody3D velocity for one tick then decay via stagger duration.

**Acceptance:**
- [ ] `test_damage.gd` passes.
- [ ] Dummy enemy in test_room takes damage from a test-weapon hitbox, flashes red, dies on HP 0.
- [ ] Player hit by a test-hitbox loses HP, enters Hit state, respects i-frames (no second hit in 0.6 s).
- [ ] No cross-team self-damage.

---

## Milestone 3 — Tetrahedron Blade + Weapon Swap Pipeline

**Goal:** Weapon as swappable data-driven module. Blade works end-to-end. Inventory size 1.
**Depends on:** M2. **Est:** M.

**Files:**
- `weapons/weapon.gd` + `weapon.tscn`.
- `weapons/tetrahedron_blade/` — scene, script, `.tres`.
- `resources/weapon_resource.gd` full.
- `player/player.gd`: `equip_weapon(resource: WeaponResource)`.
- `ui/hud.tscn` + `.gd` — minimal HUD (weapon icon + name + hearts).
- `materials/mat_weapon_blade.tres`.

**Key notes:**
- Inventory in `GameState.inventory_weapon_ids: Array[StringName]`.
- `SignalBus.player_weapon_changed` drives HUD + player swap.
- Blade attack per SPEC §11.3.

**Acceptance:**
- [ ] Player starts equipped with Blade; HUD shows it.
- [ ] Attack sequence plays at correct timings; hitbox active window matches `attack_active_s`.
- [ ] Pattern-locked dummy takes ×2; regular dummy takes ×1.
- [ ] Swap to a stub second weapon (debug key) works without error.

---

## Milestone 4 — Lock-On Camera

**Goal:** OoT-style Z-target. Target acquisition, switching, auto-release all working.
**Depends on:** M3. **Est:** M.

**Files:**
- `combat/lock_on.gd` per §9.3.
- `player/camera_rig.gd`: lock-on mode, strafe flag.
- `player/states/move_state.gd`: strafe when locked on.
- HUD: reticle (small procedural dodecagon outline projected to screen).

**Acceptance:**
- [ ] Pressing lock-on near a dummy snaps camera behind player with target framed.
- [ ] Strafing keeps target centered.
- [ ] Re-press switches with multiple candidates; no switch with single candidate (deadzone).
- [ ] Killing / walking > 20 m from target auto-releases; occlusion > 0.5 s auto-releases.

---

## Milestone 5 — Enemy Framework + Triangle Elemental

**Goal:** Patrol/chase/attack/return AI on one enemy type, baked navmesh.
**Depends on:** M4. **Est:** M.

**Files:**
- `enemies/states/*.gd` (patrol/chase/attack/return/stagger).
- `enemies/triangle_elemental/` — scene, script, `.tres`.
- `resources/enemy_resource.gd` full.
- `materials/mat_enemy_earth.tres` (emerald emissive).
- `shaders/dissolve.gdshader`.
- `scenes/test_room.tscn` — bake navmesh into a `NavigationRegion3D`, commit baked `.res`.

**Key notes:**
- LOS via raycast from enemy Eye Marker3D.
- Triangle Elemental per §12.3.
- On death: dissolve shader over 0.7 s, emit `enemy_released` (bible vocab).
- Add `SlowmoAgent` to enemy root; default scale 1.0.

**Acceptance:**
- [ ] Enemy patrols between two Markers; chases on LOS; attacks with 0.4 s red-flash telegraph.
- [ ] Returns and heals to full on leash.
- [ ] Dies with dissolve; emits `enemy_released`; navmesh unchanged.

---

## Milestone 6 — HUD + Bible-Formula Stats + Death/Respawn

**Goal:** Full HUD wired to stats + room-entrance respawn loop.
**Depends on:** M5. **Est:** S–M.

**Files:**
- `ui/hud.tscn` + `.gd` full (hearts, weapon, interact prompt, mid-screen message). Stats overlay behind pause.
- `player/states/dead_state.gd`.
- `scenes/main.tscn` — boots into test_room with player.
- `resources/stats.gd` full (already in M0 but now wired into HealthComponent + Player).
- `player/player.gd`: death → fade → respawn at last room's entry spawn, full HP.

**Key notes:**
- Hearts render as 4-tile procedural hearts (12 quarters = 3 hearts at start).
- Stats overlay shows coherence/resonance/stability/flow + computed effects (e.g. "Flow 10 → +10% speed").

**Acceptance:**
- [ ] Hearts reflect field integrity at quarter granularity.
- [ ] Pause → stats overlay displays bible formulas correctly.
- [ ] `hud_message("Geometry Quest", 2.0)` shows and fades.
- [ ] Dying → respawn at test_room entry with full HP, no errors.

---

## Milestone 7 — Save / Load

**Goal:** Save schema v1 persists and round-trips. Autosave after room-transition fade-in. Pause-menu save/load.
**Depends on:** M6. **Est:** M.

**Files:**
- `globals/save_manager.gd` full (serialize GameState per §18; version check; FileAccess JSON).
- `tests/test_save_roundtrip.gd` — mutate GameState, save, zero, load, deep-equal.
- `ui/pause_menu.tscn` + `.gd` (Resume / Save / Load / Options stub / Quit).
- `ui/title.tscn` + `.gd` (New Game / Load / Quit).

**Key notes:**
- Never serialize Node references.
- Autosave fires **after** fade-in completes on room transition (see SPEC §14.3 step 8 — prevents load-time reentrancy).
- Corrupt/incompatible version → graceful `hud_message("Save incompatible")`.

**Acceptance:**
- [ ] `test_save_roundtrip.gd` passes (including new fields: `lens_energy`, `inverter_energy`, stats).
- [ ] Quit + relaunch + Load returns to same room, HP, inventory, flags, stats.
- [ ] Corrupted save loads gracefully.

---

## Milestone 8 — Dialogue System + NPC Base

**Goal:** Interact with NPC, see portrait + text, advance, set flags via choices.
**Depends on:** M7. **Est:** M.

**Files:**
- `resources/dialogue_line.gd` + `dialogue_choice.gd` full.
- `dialogue/dialogue_runner.gd`.
- `ui/dialogue_box.tscn` + `.gd` (portrait texture + text label + advance indicator).
- `world/interactable.tscn` + `.gd` (`on_interact_dialogue: DialogueLine`).
- `dialogue/lines/nexus_guide.tres` (4 lines; one with a choice that sets a flag).
- Place a test NPC (spinning dodecahedron) in test_room.

**Key notes:**
- During dialogue, player state machine switches to Idle, input re-routed to DialogueRunner.
- Text reveal at 60 cps; interact finishes or advances.
- Portraits: Texture2D (deferred Viewport).

**Acceptance:**
- [ ] Prompt appears when hovering NPC.
- [ ] Dialogue box opens, text reveals, advances, closes; control returns cleanly.
- [ ] Choice that sets a flag updates `GameState.flags` (verify in debug overlay).

---

## Milestone 9 — Heptagon Lens + Per-Node SlowmoAgent

**Goal:** Lens active/idle loop, lens_revealed toggle, lens_telegraph reveal, `slowmo.broadcast` wired to enemy/projectile SlowmoAgents. Lens time dilation is **per-node**, never global.
**Depends on:** M8. **Est:** M.

**Files:**
- `weapons/heptagon_lens/` — scene, script, `.tres`.
- `player/states/lens_state.gd`.
- `shaders/lens_overlay.gdshader` — Environment override (not ColorRect).
- `globals/game_state.gd`: `lens_energy: float = 3.0`.
- HUD: enable lens_energy meter when lens equipped.
- `SignalBus` gains `slowmo_broadcast(scale: float)` (add to §7 if not already).
- Extend `combat/slowmo_agent.gd`: subscribe to `slowmo_broadcast` on enter tree.

**Key notes:**
- Hold `lens` → drop time on enemies+projectiles to 0.5×. Player unchanged. UI, audio, input, physics all normal.
- Environment override: save previous `camera.environment`, swap in `lens_environment.tres`, restore on release.
- `lens_energy` drains 1/s, regens 0.75/s idle.

**Acceptance:**
- [ ] Hold lens: Triangle Elemental (M5) visibly slows to half; player movement feel unchanged.
- [ ] Post-process shader applies and removes cleanly.
- [ ] Nodes in group `"lens_revealed"` toggle visibility.
- [ ] lens_energy drains/regens correctly.
- [ ] **Regression:** attack windup, i-frames, input buffer all measured identical with and without lens held (per-node slowmo isolation test).

---

## Milestone 10 — Pentagram Inverter + Reflection

**Goal:** Pentagram tap attack + charged inversion pulse. Projectile reflection. Pattern-locked ×2 stacking. Inversion field breaks enemy state machines.
**Depends on:** M9. **Est:** M.

**Files:**
- `weapons/pentagram_inverter/` — scene, script, `.tres`, `reflected_projectile.tscn`.
- `player/states/inverter_state.gd` — charged-hold release.
- `shaders/inversion_ripple.gdshader`.
- `globals/game_state.gd`: `inverter_energy: float = 2.0`.
- `materials/mat_weapon_inverter.tres`.
- Test enemy (new Probability Wraith stub in test_room) that fires a simple projectile → used to validate reflection.

**Key notes:**
- Tap: melee hit, `DamageInfo.type = "inversion"`, `breaks_pattern = true`. Pattern-locked damage stacking per §10.1.
- Charge ≥ 0.5 s then release → emerald ripple pulse (5 m radius):
  - Projectiles in radius: reverse velocity, ×1.5 speed, set team to player, layer `projectile`.
  - Enemies in radius: `on_inversion_field()` forces Stagger 2 s.
  - Pattern-locked in radius: flagged vulnerable for 3 s.
  - CorruptionVolumes disabled 5 s (volume not in slice yet; stub a no-op that logs).
- HUD: add inverter_energy meter when pentagram equipped.

**Acceptance:**
- [ ] Test projectile enemy + charged pulse → projectile reverses direction and damages the wraith.
- [ ] Enemy caught in pulse staggers for 2 s.
- [ ] Pattern-locked Triangle Elemental + tap = ×2 damage via stacking path.
- [ ] inverter_energy drains/regens correctly.

---

## Milestone 11 — Hexagonal Shield + Parry + Stabilizer

**Goal:** Block (70% phys / 100% resonance with heal), parry window, ShieldStabilizer puzzle primitive.
**Depends on:** M10. **Est:** M.

**Files:**
- `weapons/hexagonal_shield/` — scene, script, `.tres`.
- `player/states/block_state.gd`.
- `puzzles/shield_stabilizer.tscn` + `.gd`.
- `materials/mat_weapon_shield.tres`.
- `player/player.tscn`: add `ShieldSlot` Marker3D.

**Key notes:**
- Block semantics per §11.6. Parry signal emission per §11.6 (no fake DamageInfo; `type = "parry"`, source = player).
- Stabilizer: tracks "activated" while player blocking on it; emits `puzzle_solved(self.id)` on satisfy; deactivates on step-off or release.

**Acceptance:**
- [ ] Shield grant via debug key adds to inventory, usable.
- [ ] Frontal physical hit while blocking = 70% reduced. Frontal resonance hit = 100% negated + heal 1 quarter per 3 blocked.
- [ ] Rear hit while blocking = full damage (not blocked).
- [ ] Parry-window block on a scripted "parryable" dummy staggers it 2 s.
- [ ] Stabilizer activates under block, deactivates off.

---

## Milestone 12 — CorruptionVolume Primitive + 4-Sided Debuff

**Goal:** Walking into a 4-sided corruption volume applies the bible debuff (-20% move, -15% damage, scaled by stability). Leaving restores. Visible as red-shadow square pyramids. Pentagram pulse disables volume for 5 s.
**Depends on:** M11. **Est:** S–M.

**Files:**
- `puzzles/corruption_volume.tscn` + `.gd`.
- `shaders/corruption.gdshader`.
- `materials/mat_corrupted_4sided.tres`.
- Update `player.gd` to apply/remove corruption debuff state on `corruption_entered/exited` (already in signals from M0).
- Update `weapons/pentagram_inverter/pentagram_inverter.gd`: charged pulse disables overlapping CorruptionVolumes (was stubbed in M10).

**Key notes:**
- Volume Area3D contains red-shadow square-pyramid MeshInstance3Ds using `mat_corrupted_4sided` + corruption shader.
- Debuff math: `effective = raw * (1 - stability.corruption_resistance_percent() / 100)`. With default stability 10, 5% reduction of the raw debuff.

**Acceptance:**
- [ ] Entering a CorruptionVolume in test_room slows player and reduces damage visibly (run the math; assert via test harness).
- [ ] Exiting restores.
- [ ] Pentagram charged pulse disables the volume for 5 s; visual dims during disable.
- [ ] Corruption volumes visually always and only use 4-sided pyramids.

---

## Milestone 13 — World/Room Framework + Crystal Nexus + Tutorial

**Goal:** Region + Room scaffolding with fade transitions, threaded preload, pre-baked navmesh. Nexus playable with scripted tutorial that grants Blade + Lens.
**Depends on:** M12. **Est:** L.

**Files:**
- **First:** Revert `project.godot` `run/main_scene` from `res://scenes/test_room.tscn` back to `res://scenes/main.tscn`. This was swapped for M1 dev iteration (see M1 Key notes).
- `world/region.gd` + `world/room.gd` full.
- `world/door.tscn` + `.gd`, `world/trigger_volume.tscn` + `.gd`, `world/pickup.tscn` + `.gd`.
- `globals/scene_router.gd` full: `change_room(region_id, room_id, spawn_name)` with threaded preload + fade + navmesh-already-baked skip.
- `world/hub_crystal_nexus/hub_crystal_nexus.tscn` + `.tres`.
- `world/hub_crystal_nexus/rooms/room_nexus_main.tscn` — central hall with 4 portal pedestals (R2 + R7 active; R1 and R3 inert with in-fiction "Resonance distorted — this region sleeps" prompt).
- `world/hub_crystal_nexus/rooms/room_nexus_portals.tscn` — antechamber.
- `world/hub_crystal_nexus/rooms/room_nexus_tutorial.tscn` — scripted sequence:
  1. Player spawns, Elder NPC (dodecahedron) speaks via `nexus_guide.tres`.
  2. Pickup appears: Tetrahedron Blade. Player interacts, equips.
  3. Elder walks player to a glyph wall; player must attack with Blade to shatter it (teaches attack).
  4. Elder places a Lens on a pedestal; player interacts to acquire.
  5. Hidden phantom reveals only via Lens; player looks through Lens to reveal a door (teaches observation).
  6. Door opens into Nexus Main. Flag `nexus_tutorial_completed = true`.
- `dialogue/lines/nexus_guide.tres`, `nexus_tutorial_lens.tres`.
- `shaders/sky_nexus.gdshader`. Sky applied via Region's WorldEnvironment.
- `materials/mat_world_crystal.tres`.

**Key notes:**
- Hub floor: hexagonal tile grid. Pillars: elongated octahedra with `resonance_glow.gdshader`, randomized `pulse_hz` and `phase_offset` per SPEC §20.7.
- Threaded preload: kicked off at fade start, resolved at midpoint.
- Navmesh: bake in the editor, commit the `.res`. Do not call `bake_navigation_mesh()` at runtime.
- ≥ 15 Dressing mesh instances per room (Nexus rooms hit this easily given pillar count).

**Acceptance:**
- [ ] Boot → title → New Game → tutorial room. Full tutorial flow completes without soft-lock.
- [ ] Blade + Lens in inventory after tutorial; `nexus_tutorial_completed = true`.
- [ ] Nexus Main accessible; R2 pedestal shows prompt, R1/R3 show sleep text, R7 locked until Alchemist defeated.
- [ ] Walking between rooms fades + transitions smoothly; no navmesh rebake log line.
- [ ] Set-dressing density check passes (≥ 15 decorative meshes per room).
- [ ] Autosave fires after fade-in completes on transition.

---

## Milestone 14 — Region 2: Collapsing Triangle Mines

**Goal:** Fully playable R2 from entry through boss door. Player acquires Pentagram Inverter and Hexagonal Shield en route. Boss door sealed until M16.
**Depends on:** M13. **Est:** L.

**Files:**
- `world/region_02_triangle_mines/region_02.tscn` + `.tres` (palette per §20, emerald fog, sky shader `sky_region_02.gdshader`, `ambient_drone_path = audio/tones/528_drone.ogg`).
- Five rooms:
  - `room_entry.tscn` — descends into the mine; emerald glow; first Triangle Elemental encounter; **Pentagram Inverter pickup** on a corrupted pedestal that requires Blade to shatter the 4-sided cage around it.
  - `room_collapsing_chamber.tscn` — walls advance; must break a `ResonanceSwitch` with Pentagram (`tags_required = ["inversion"]`, `pyramid_sides_required = 5`) to halt and open north door. Teaches Pentagram as regional weapon.
  - `room_gravity_flip.tscn` — inverted gravity apex. Solve by falling up into the triangular apex; **Hexagonal Shield pickup** at the apex (shield needed for next room).
  - `room_triangle_lock.tscn` — three `ResonanceSwitch`es arranged in a triangle. Composite `PuzzleGroup` with 2 s window. Also contains a `LensTarget` that reveals a side nook with a heart container.
  - `room_boss_arena.tscn` — inverted triangular pit, three corrupted crystal pedestals with CorruptionVolumes around them. Door sealed until M16.
- `shaders/sky_region_02.gdshader`.
- Music: `audio/music/region_02_theme.ogg` (placeholder CC0 ok).
- Scatter: Triangle Elementals in rooms 2–4.

**Key notes:**
- Entry room has CorruptionVolumes gating the Pentagram pickup — demonstrates the debuff before the player has the tool to mitigate it.
- Gravity flip uses `GravityFlipVolume` from SPEC §14.5.
- ≥ 15 decorative meshes per room.
- R7 portal in Nexus remains sealed until boss 1 cleared.

**Acceptance:**
- [ ] Enter region via Nexus pedestal. Flow: entry → collapsing → gravity-flip → triangle-lock → boss-arena door (sealed).
- [ ] Pentagram picked up, demonstrable on triangle elementals (×2 pattern-locked hits).
- [ ] Shield picked up, usable.
- [ ] Lens-target in triangle-lock room reveals heart container.
- [ ] CorruptionVolumes measurably debuff player.
- [ ] Autosave per transition; loading at any point respawns correctly.
- [ ] Region playtests to 10–14 minutes for a first-time player.

---

## Milestone 15 — Canonical 4-Phase Boss Framework + Octagon Harmonizer

**Goal:** Phase-driven Boss base with bible 4-phase structure (Recognition / Intervention / Vulnerability / Integration). Octagon Harmonizer weapon authored (acquired in M16 narratively; weapon itself lives in codebase from M15). Vulnerability re-corruption mechanic. ProcessOrder autoload wired. Validated by a "training dummy boss" in test_room.
**Depends on:** M14. **Est:** M–L.

**Files:**
- `bosses/boss.gd` + `boss.tscn` (extends enemy).
- `bosses/boss_phase.gd` (base class for phase children).
- `resources/boss_resource.gd` + `boss_phase_resource.gd`.
- `weapons/octagon_harmonizer/` — scene, script, `.tres`, `completion_wave.gdshader`, `mat_weapon_harmonizer.tres`.
- `player/states/harmonizer_state.gd`.
- `ui/boss_bar.tscn` + `.gd` — 4-phase segmented bar per §17.
- `globals/process_order.gd` full (record/query/clear; used by Boss framework and puzzles).
- `tests/test_boss_phases.gd` — dummy boss; scripted fire through all four phases; assert signals emit in order; assert Phase 3 attack-reset triggers `boss_re_corrupted`.
- Training dummy boss in test_room: stubbed dialogues, required_intervention = `pentagram_inverter`, observation 3 s, vulnerability 5 s.

**Key notes:**
- Phase transitions per §13.1. Phase 1 invulnerable; Phase 2 only correct tool damages; Phase 3 total invuln + attack penalty; Phase 4 integration via Harmonizer.
- HUD `boss_bar` phase color per §17 (red → amber → silver → gold).
- Octagon Harmonizer weapon: tap = 6 m completion cone; charge = 6 m completion pulse + self heal 2 quarters. See §11.7.
- The `boss_vulnerability_started` signal starts a countdown to `boss_vulnerability_ended(attacked: bool)` — if attacked=false → Phase 4, else re-corrupt.

**Acceptance:**
- [ ] Training dummy in test_room: hold Lens 3 s → Phase 2 enters; hit with Pentagram 5 times → Phase 3; wait 5 s without attack → Phase 4; use Harmonizer 3 times → integrated.
- [ ] Attacking during Phase 3 resets to Phase 1 with visible difficulty modifier (slower Phase 2 progress gain).
- [ ] Boss bar renders correctly per phase with color shift.
- [ ] `test_boss_phases.gd` passes (including re-corruption path).
- [ ] ProcessOrder logs: `observe`, `disrupt`, `stabilize`, `complete`, `integrate`.

---

## Milestone 16 — Boss 1: The Crystallized Alchemist

**Goal:** R2 boss fully playable, canonical 4-phase, grants Octagon Harmonizer in Phase 4, unlocks R7 and spawns NPC in Nexus post-victory.
**Depends on:** M15. **Est:** L.

**Files:**
- `bosses/crystallized_alchemist/` — scene + script + `.tres` + four phase scripts.
- `dialogue/lines/alchemist_intro.tres`, `alchemist_phase3_warning.tres`, `alchemist_integration.tres`, `alchemist_nexus_npc.tres`.
- Build out `world/region_02_triangle_mines/rooms/room_boss_arena.tscn` — inverted triangular pit, 3 corrupted crystal pedestals with CorruptionVolumes, four 4-sided corruption prison cages (Phase 2 props).
- `materials/mat_boss_alchemist.tres` (emerald emissive w/ red-shadow corruption layer shader).
- `audio/music/region_02_boss.ogg`.
- Post-victory: scripted insertion of Emerald Alchemist NPC in Nexus Main beside R2 portal; dialogue hooked.
- Boss-door unlock: add puzzle-id enumeration under `region_02.required_puzzles` (solved-set check).

**Key notes:**
- **Phase 1:** Alchemist paces her 4-sided prison cage; Lens hold for 4.0 s reveals real form + "Stuck at 4. Needs 5." → `boss_observed`.
- **Phase 2:** 4 prison bars rotate + slam as attacks; Pentagram tap destroys each on hit (1/5 progress each); charged pulse destroys all bars in radius (counts as +0.4 progress).
- **Phase 3:** 6 s silver vulnerability. Floating text warning. Attack → re-corrupt + difficulty bump.
- **Phase 4:** Octagon Harmonizer pedestal materializes; player picks up (adds to inventory, resonance +20, auto-equip). 3 waves → transform. `alchemist_integration_dialogue` plays.
- Victory hook: `GameState.flags["defeated_alchemist"] = true`, `has_octagon_harmonizer = true`, `field_integrity_max += 4`, `region_07_unlocked = true`; scene routes to Nexus Main spawn `"from_region_02"`.

**Acceptance:**
- [ ] Boss door in R2 opens once all R2 puzzles solved (enumerated list).
- [ ] Phase 1: cannot damage boss; Lens dwell progresses; transition fires at 4 s.
- [ ] Phase 2: only Pentagram damages; other weapons print hint; at progress 1.0 transition.
- [ ] Phase 3: silver bar + warning; attacking resets to Phase 1 with difficulty bump; waiting transitions to Phase 4.
- [ ] Phase 4: Harmonizer pickup works; 3 waves complete; transform plays; fade → Nexus.
- [ ] Nexus: Emerald Alchemist NPC is interactable with `alchemist_nexus_npc` dialogue. Extra heart visible on HUD. R7 portal now active.
- [ ] Save + reload at any phase resumes correctly.

---

## Milestone 17 — Region 7: Sphere Pulse Meditation Domes

**Goal:** R7 fully playable from entry to boss door. Silence-heavy, observation-forward. StillnessZone primitive introduced. Anxiety Storm enemy.
**Depends on:** M16. **Est:** L.

**Files:**
- `world/region_07_sphere_pulse/region_07.tscn` + `.tres` (palette silver/white, minimal fog `0.008`, sky `sky_region_07.gdshader`, music `region_07_theme.ogg` near-silent).
- Five rooms:
  - `room_entry.tscn` — wide white space, a single stillness pillar, entry ritual (tutorial for StillnessZone primitive).
  - `room_stillness_chamber.tscn` — 3 StillnessZones; solving all 3 opens north door. First puzzle room taught via NPC sign.
  - `room_pulse_rhythm.tscn` — rhythmic expanding spheres; stand in sync with pulse at specific phase points (a timing puzzle using Lens to reveal correct phase).
  - `room_nested_spheres.tscn` — 3 concentric sphere shells; each shell's surface has a different LensTarget; solving in order (innermost outward) reveals path.
  - `room_boss_arena.tscn` — round meditation dome; empty until M18.
- `puzzles/stillness_zone.tscn` + `.gd`.
- `enemies/anxiety_storm/` — scene, script, `.tres`, `materials/mat_enemy_aether.tres`.
- `shaders/sky_region_07.gdshader`.
- Scatter: 2–3 Anxiety Storms across rooms.

**Key notes:**
- R7 accessible only if `defeated_alchemist = true`.
- StillnessZones require no movement input for `dwell_s`; dissonant tone on reset; harmonic tone on solve.
- Anxiety Storm agitation mechanic: stand still 3 s or hold Lens 3 s to dissolve.
- Palette strongly contrasts with R2 (near-white vs emerald).
- ≥ 15 dressing meshes per room (floating crystals, silver mote clouds).

**Acceptance:**
- [ ] Region accessible from Nexus only after R2 cleared.
- [ ] Stillness puzzles solvable and teach the mechanic.
- [ ] Pulse rhythm room requires Lens + timing.
- [ ] Anxiety Storm dissolves correctly via both stand-still and Lens.
- [ ] Region playtests to 10–14 minutes first time.

---

## Milestone 18 — Boss 2: The Overwhelmed Observer

**Goal:** R7 boss fully playable, canonical 4-phase, all gates pass.
**Depends on:** M17. **Est:** L.

**Files:**
- `bosses/overwhelmed_observer/` — scene + script + `.tres` + four phase scripts.
- `dialogue/lines/observer_intro.tres`, `observer_phase3_warning.tres`, `observer_integration.tres`, `observer_nexus_npc.tres`.
- Build out `world/region_07_sphere_pulse/rooms/room_boss_arena.tscn` — round white dome, 7 stillness pillars in heptagon arrangement, 7 ShieldStabilizer plates at pillar bases, outer ring of 4-sided corruption pyramids (Phase 1 visual, destroyed by Phase 2 stabilization).
- `materials/mat_boss_observer.tres` (silver emissive with 4-sided corruption layer).
- `audio/music/region_07_boss.ogg` (near-silent with single bell tones).
- Post-victory: Balanced Witness NPC in Nexus Main beside R7 portal.

**Key notes:**
- **Phase 1:** Observer sits, ring of 7 mirror fragments. Lens dwell 4 s → reveal witness-trap geometry → `boss_observed`.
- **Phase 2:** Mirror fragments project illusion phantoms. 7 ShieldStabilizer tiles at pillar bases; block on each to stabilize; 7 stabilizations = progress 1.0.
- **Phase 3:** 8 s vulnerability (longer than Alchemist). **Rule:** any movement velocity > 4 m/s for > 0.5 s counts as "aggressive," triggers re-corrupt. Attacking of any kind also re-corrupts. Standing still or walking slowly = pass.
- **Phase 4:** Harmonizer (already owned) 3 waves → transform. Integration dialogue.
- Victory hook: `defeated_observer = true`, `field_integrity_max += 4`, resonance +10; fade to Nexus spawn `"from_region_07"`; NPC spawned.

**Acceptance:**
- [ ] Boss door unlocks with all R7 puzzles solved.
- [ ] Phase 1/2/3/4 each gate behave per §13.3.
- [ ] Phase 3 aggressive-movement rule fires re-corrupt correctly (test with a sprinted run through vulnerability → assert reset).
- [ ] Phase 4 Harmonizer completes fight; transform plays.
- [ ] Balanced Witness NPC in Nexus, dialogue works.
- [ ] Save + reload at any phase resumes correctly.

---

## Milestone 19 — Inventory + Weapon Switching Polish

**Goal:** Full inventory screen for 5 weapons; hotkey swap UX; equip feedback.
**Depends on:** M18. **Est:** S–M.

**Files:**
- `ui/inventory.tscn` + `.gd` (grid + descriptions + equip button).
- HUD: hotkey cycle feedback toast ("Equipped: Pentagram Inverter").
- Handle 5-weapon inventory edge cases (missing entries for weapons player hasn't acquired yet).

**Key notes:**
- Inventory pauses game.
- Tooltip reads from WeaponResource fields + bible frequency/color display.
- No radial menu (explicitly cut per audit).

**Acceptance:**
- [ ] Open/close inventory without errors.
- [ ] Equipping updates player + HUD immediately.
- [ ] Quick-swap (`swap_next`/`swap_prev`) cycles deterministically.
- [ ] Inventory only shows owned weapons.

---

## Milestone 20 — Audio Pass

**Goal:** World 432 Hz drone, per-region drones, per-pyramid weapon tones, all SFX populated, music crossfades clean at region + boss boundaries. Corruption detunes drone.
**Depends on:** M19. **Est:** M.

**Files:**
- `globals/audio_manager.gd` full.
- `audio/tones/tone_432.wav`, `tone_528.wav`, `tone_741.wav`, `tone_852.wav`, `432_drone.ogg`, `528_drone.ogg`, `741_drone.ogg`.
- SFX full set: blade swing, blade hit, pentagram tap, pentagram charge, pentagram release, shield block, shield parry, lens on, lens off, harmonizer tap, harmonizer charge, harmonizer integrate, enemy hit, enemy release, corruption enter, corruption exit, boss phase 1→2, boss phase 2→3, boss phase 3→4, boss recorrupt, boss integrated, puzzle solve, stillness solve, door open, pickup, menu move, menu confirm.
- Music: `nexus_ambient.ogg`, `region_02_theme.ogg`, `region_02_boss.ogg`, `region_07_theme.ogg`, `region_07_boss.ogg`.

**Key notes:**
- World drone never stops except at title.
- Boss music triggered on `boss_encounter_started` (fires from Boss `_ready`), fades on `boss_integrated`.
- `AudioEffectPitchShift` on region drone bus, modulated by active corruption level (per §19 formula).
- All CC0/generated placeholders acceptable.

**Acceptance:**
- [ ] All listed SFX play at correct events, no silence in combat.
- [ ] Region drone audibly detunes within CorruptionVolumes.
- [ ] Boss music crossfades clean at start/end; world drone audible underneath music.
- [ ] Volume sliders in pause menu work per-bus.
- [ ] Pentagram attack triggers 528 Hz tone one-shot; Lens enter plays 741 Hz; Harmonizer plays 852 Hz.

---

## Milestone 21 — Polish + Vertical Slice Review

**Goal:** End-to-end playthrough smooth, bible-faithful, save-safe.
**Depends on:** M20. **Est:** M.

**Work:**
- `tools/bake_csg.gd` editor script per SPEC §20.6; apply to every committed Room scene.
- Tune: camera FOV/follow, enemy HP/damage, boss Phase 2 hit counts, Phase 3 window durations, Phase 4 wave count.
- Particles + screen shake pass on hits, parries, phase changes, boss defeat.
- Fix one-shot bugs from full-playthrough log.
- Verify: Nexus tutorial → R2 → Alchemist → Nexus (talk to Emerald Alchemist) → R7 → Observer → Nexus (talk to Balanced Witness) → "Vertical slice complete" card.
- Add end-of-slice title card + credits stub.

**Acceptance:**
- [ ] One full playthrough (≥ 50 min estimated) completes without crash or soft-lock.
- [ ] All 21 prior milestones' acceptance criteria still pass.
- [ ] Save/load at any point in the slice returns to correct state.
- [ ] Every committed Room scene has baked (non-CSG) geometry + baked navmesh.
- [ ] Both healed bosses are talkable NPCs in the Nexus with unique dialogue.
- [ ] Tag git commit `v0.1-vertical-slice`.

---

## Post-slice: What unlocks what

**Pure content work (no engine changes required):**
- Regions 1, 3, 4, 5, 6, 8–16: author rooms + puzzles using existing primitives + CorruptionVolume + StillnessZone.
- Canonical 4-phase bosses for remaining regions: author `BossResource` + four phase scripts.
- New enemies: author `EnemyResource` variants.

**Engine work remaining for the full game:**
- φ-based damage math swap (one-line per weapon + global flag).
- Resonance type affinity discovery + tracking (bible §7).
- Combination attack matrix (bible §6).
- Nonagon Absorber (vortex attraction — extends Area3D impulse logic).
- Decagon Resetter (buff/debuff clear + environment restore — world-state snapshot system).
- Hendecagon Disruptor + chaos corruption accumulation + 30 s stabilization timer.
- Dodecagon Crown (multi-weapon simultaneous use — extends WeaponSlot to N).
- Tridecagon Catalyst (dimensional gateway; enemy-to-ally evolution).
- Tetradecagon Harmonizer (dual stabilization equilibrium field).
- Merkaba Wings (flight controller; extends player state machine).
- Toroidal Field Generator (massive particle + area healing; final-boss tech).
- Multiplayer / co-op (separate project boundary).
- Full accessibility suite (audio-geometry, haptic patterns, cognitive options).

---

## Estimated pacing

Builder: Claude Opus 4.7.

| Milestones | Session count (rough) |
|------------|------------------------|
| M0–M3      | 2 sessions             |
| M4–M8      | 3 sessions             |
| M9–M12     | 3 sessions             |
| M13–M14    | 2 sessions             |
| M15–M16    | 2–3 sessions           |
| M17–M18    | 2–3 sessions           |
| M19–M21    | 2 sessions             |

Total: ~16–18 focused sessions to v0.1-vertical-slice. Assumes no art pipeline detour beyond primitives + shaders, and that the bible's canonical loop is committed to.
