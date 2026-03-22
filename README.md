# One More Room (Prototype)

A top-down 2D roguelite starter prototype for Godot 4.

## Included

- Data-driven room/reward/power-up JSON schemas
- `WeightedPicker.gd` utility for weighted random selection
- `RunDirector.gd` for room and reward orchestration
- `GameState.gd` for run stats and player state
- `RewardChoice.gd` UI script for 2-choice rewards

## Suggested next steps

1. Add these scripts as autoloads in Godot:
   - `autoload/GameState.gd` as `GameState`
   - `autoload/RunDirector.gd` as `RunDirector`
2. Create room scenes matching IDs in `data/rooms.json`
3. Connect room clear events to:
   - `RunDirector.on_room_cleared(room_data)`
   - reward UI `show_choices(choices)`
4. Apply picked rewards into `GameState`

## Minimal wiring example

```gdscript
var room_data = RunDirector.get_next_room(GameState.depth)
var choices = RunDirector.on_room_cleared(room_data)
$CanvasLayer/RewardChoice.show_choices(choices)
```

```gdscript
$CanvasLayer/RewardChoice.reward_picked.connect(func(reward):
	apply_reward(reward)
	GameState.depth += 1
	start_next_room()
)
```

## License

MIT
