# Claude Code project context — Geometry Quest

This file auto-loads into every Claude Code session in this directory.
Everything below is load-bearing context for building Geometry Quest without
re-discovering what prior sessions already learned.

---

## Stack + paths

- **Engine:** Godot 4.6.2 stable. Binary at `/Applications/Godot.app/Contents/MacOS/Godot`.
- **Language:** strictly-typed GDScript.
- **Repo root:** this directory (`/Users/Charrison/Desktop/Geometry Quest/`).
- **Remote:** `https://github.com/sly-the-fox/geometry-quest.git` (branch `main`).
- **Never commit** `.claude/settings.local.json` (user's local settings).

## Docs — authoritative order

When the docs conflict, **the bible wins**. Raise a PR to reconcile.

1. `geo_quest_lore&mechanics_bible.md` — lore + mechanics bible (design authority).
2. `SPEC.md` — technical spec for the v1 vertical slice.
3. `PLAN.md` — 22 milestones M0–M21 with file lists + acceptance criteria.
4. `geometry_quest_game_design.md` — original sprawling creative doc; mostly out-of-scope for v1.

## Locked scope (SPEC §24)

Path 3 canonical slice: **Crystal Nexus hub + Region 2 (Collapsing Triangle Mines) + Region 7 (Sphere Pulse Meditation Domes)**. Five weapons that *are* the bible's process order:

| # sides | Weapon | Role |
|---------|--------|------|
| 3 | Tetrahedron Blade | universal default verb |
| 5 | Pentagram Inverter | R2 regional; disruption + reflection |
| 6 | Hexagonal Shield | stabilization, parry |
| 7 | Heptagon Lens | R7 regional; required for every boss Phase 1 |
| 8 | Octagon Harmonizer | required for every boss Phase 4; gifted by Alchemist |

Two canonical 4-phase bosses: **Crystallized Alchemist** (R2), **Overwhelmed Observer** (R7). Healed bosses reappear as NPCs in the Nexus.

Everything else in the design doc is out-of-scope for v1.

## Workflow

For each milestone:
1. **Plan mode** → draft execution plan to `/Users/Charrison/.claude/plans/okay-lets-scope-m0-vectorized-sedgewick.md` (carry-over filename; overwrite per new task).
2. **Spawn 3 parallel audit agents** — implementation-gap / features / technical-creative — against the draft plan.
3. **Revise** the plan from audit findings. Must-fix items surface at the bottom.
4. **ExitPlanMode** → user approves.
5. **Execute** in auto mode. Use TaskCreate/TaskUpdate for per-milestone progress.
6. **Verify:** headless `--quit` with zero ERRORs, then any milestone-specific tests, then F5 smoke test with user sign-off.
7. **Commit:** `mN: short summary` header + detailed body + `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>`.
8. **Push** only on user request.

## Milestone state

- **M0** scaffolding — committed `a11bdcd`, pushed.
- **M1** player + 3rd-person camera + test room — committed `0097b95`, pushed.
- **Next: M2** Combat Framework (Hitbox/Hurtbox/HealthComponent, DamageInfo full, i-frames, stagger, dummy enemy, slowmo_agent, test_damage.gd).

## Dev-only flag

`project.godot run/main_scene` is currently `res://scenes/test_room.tscn` for M1+ dev iteration. **M13 reverts it to `res://scenes/main.tscn`.** Reminder notes exist in `PLAN.md` under both M1 Key notes and M13 Files.

---

## Godot 4.6.2 gotchas — do not re-discover

These cost time on M0/M1. Save the tokens.

### Autoloads

- **Never declare `class_name X` on an autoload script when X equals the autoload registration name.** Godot 4.6 parse-errors with `"Class X hides an autoload singleton"`. Access autoloads by their registration name directly (e.g. `SignalBus.player_damaged.emit(...)`, `GameState.stats.move_speed_mult()`).
- **Do not write `var bus: SignalBus = SignalBus`** — there's no `class_name SignalBus` to reference. Use `var bus: Node = SignalBus` if you need typed variable, or just use the autoload name directly.
- **Resource classes DO use `class_name`.** Only autoload scripts skip it.
- Autoload order in `project.godot` is defensive — M0 autoloads don't reference each other at `_ready`, but later milestones may. Don't reorder.

### Class cache priming

- Fresh checkout needs `godot --editor --quit --path <proj>` **once** to populate `.godot/global_script_class_cache.cfg`. Without this, `class_name` cross-references fail at parse time with `Could not find type "X" in the current scope`.
- `--headless --quit` alone does NOT prime the cache on first run.
- After adding new `class_name` declarations, re-run `--editor --quit` before launching or running tests.

### Test harness

- `godot --headless -s <script.gd>` loads the script as the MainLoop. **Autoloads are not loaded.** Test scripts that use `-s` must be pure-function only (no `SignalBus.*`, no `GameState.*`).
- Autoload correctness is verified implicitly by `godot --headless --quit` returning zero ERROR lines.
- Test scripts extend `SceneTree`; call `quit(0)` on success, `quit(1)` on failure. Emit via `print` / `printerr`.

### Input mapping

- `Input.get_vector("move_left","move_right","move_up","move_down")` returns `y = -1` when W is pressed (`move_up` is the *negative_y* argument). Godot 3D forward is `-Z`.
- **When building camera-relative motion, negate `input.y`** so W produces +forward. This is the #1 source of "WASD feels reversed" bugs.
- `Input.get_vector` clamps magnitude ≤ 1, preserves analog < 1 — do not re-normalize.
- Camera has no keyboard InputMap actions; read mouse via `_input(InputEventMouseMotion)` relative motion. Gamepad camera is via `cam_up/down/left/right` actions on right-stick axes 2/3.
- No modifier chords in the input map (Godot InputMap can't represent `Shift+Q` as a single event).

### Physics

- Physics layer keys live under `[layer_names]` section as `3d_physics/layer_N="name"` — not `physics_3d/...`.
- Layer values (bit N = value 2^(N-1)):
  - world=1, player=2, enemy=4, player_hitbox=8, enemy_hitbox=16, player_hurtbox=32, enemy_hurtbox=64, interactable=128, trigger=256, projectile=512.
- Player body: `collision_layer=2`, `collision_mask=133` (world + enemy + interactable).
- Player hurtbox: `collision_layer=32`, `collision_mask=528` (enemy_hitbox + projectile).
- **Set `velocity` before `move_and_slide()`** — Godot 4 slide resolution consumes pre-set velocity. Setting velocity after slide overwrites collision resolution.
- `CharacterBody3D.floor_snap_length` default 0.1 causes edge-stutter when walking off ledges. Set to `0.0` on Player.

### State machine (Player)

- StateMachine dict keys are **StringName**. Use `_states[c.name] = c` directly — `Node.name` is StringName in Godot 4. **Do NOT use `c.name.to_lower()`** — that returns String, and `Dictionary.get(StringName)` does not match String keys in 4.6.
- Child state nodes named lowercase (`idle`, `move`, `jump`) to match `change_state(&"idle")` lookups.
- In Player `_ready`, use `state_machine.call_deferred("change_state", &"idle")` — children's `_ready` fires after the parent's; defer to end of frame.

### Jump buffer / coyote

- **Coyote timer must NOT refill while airborne post-jump.** Guard with `is_on_floor() AND velocity.y <= 0 AND not _suppress_coyote_refill`. `JumpState.enter()` sets `_suppress_coyote_refill = true`; Player clears it on the landing tick. Without this guard, first airborne tick refills coyote and tapping jump again double-jumps.
- Player owns `_unhandled_input` for jump buffering; states don't also consume jump input.

### Camera

- `CameraRig` needs `top_level = true` — otherwise Player's yaw-follow rotation drags the camera into spinning.
- Split `_process` (rotation — reads fresh input) from `_physics_process` (position follow — reads post-integration Player pos). Prevents one-frame lag.
- `SpringArm3D.collision_mask = 1` (world only). Default mask includes Player hurtbox and snags.
- `SpringArm3D.margin = 0.2` — `0.1` clips at 90° wall corners.
- Clamp pitch in radians before writing `PitchPivot.rotation.x`. Never round-trip through `rotation_degrees`.
- Auto-realign behind player: `-velocity.dot(basis.z) > 1.0` ("forward speed"), NOT `velocity.length() > 1.0`. Backpedal produces negative forward speed and naturally suppresses realign.
- Headless safety: guard `Input.set_mouse_mode(MOUSE_MODE_CAPTURED)` behind `DisplayServer.get_name() != "headless"` to keep `--headless --quit` clean.

### Geometry / art

- **CSG is authoring-only per SPEC §24.12.** For shipped geometry use `MeshInstance3D` + `StaticBody3D` + `BoxShape3D` (or baked meshes). A `tools/bake_csg.gd` editor script lands in M21 for any CSG-authored rooms.
- `WorldEnvironment` needs `glow_enabled=true`, `tonemap_mode=FILMIC`, and `glow_hdr_threshold=1.0` for the emissive/primitives aesthetic to read as glowing. See `environments/env_debug.tres`. Without this, `resonance_glow.gdshader` clips to LDR and looks dull.
- Set-dressing rule (SPEC §20.7): every room scene ≥ 15 decorative meshes under `Dressing/`, each with random `pulse_hz` in `[0.15, 0.6]` and unique `phase_offset`.
- Player's `pulse_hz = 0.2` specifically (meditative 5s cycle), not the 0.5 default used for dressing.

### SaveManager naming

- Use `save(slot)` and **`load_slot(slot)`** — NOT `load()`. `SaveManager.load(path)` is ambiguous at call sites (resource loader? save loader?). `load_slot` is unambiguous.

### Tweens

- `create_tween()` requires the node to be in the scene tree at call time. If a Fade/UI widget is instanced but not yet parented, fade calls error. M13 must parent Fade under the active region's CanvasLayer before first transition.

### Godot project file

- `project.godot` first non-comment line must be `config_version=5`. Missing it triggers silent upgrade/mutation on first open (diff noise).
- Do not commit `config/icon="res://icon.svg"` pointing at a missing file — emits ERROR under `--headless --quit` and fails acceptance. Let the editor auto-create the icon on first open, then commit it.

### Engine.time_scale

- **Do not use `Engine.time_scale` for the Lens.** SPEC §24.11 mandates per-node `SlowmoAgent` pattern (enemies/projectiles subscribe to `SignalBus.slowmo_broadcast`; player stays at 1.0). Global time scale breaks input buffers, i-frames, AnimationPlayer, audio pitch, NavigationAgent sampling.

---

## Commit messages

Existing style:
```
mN: short summary (imperative, ≤70 chars)

One or two paragraphs on the why and the what. Include the audit
blockers that were caught pre-execution. Reference SPEC/PLAN
sections when a design decision is non-obvious.

Verified on Godot 4.6.2: <what was run, what passed>.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

Commit areas (use in summary): `player`, `combat`, `world`, `ui`, `save`, `audio`, `weapons`, `enemies`, `bosses`, `region02`, `region07`, `nexus`, `puzzles`, `shaders`, `chore`, or a milestone tag `mN`.
