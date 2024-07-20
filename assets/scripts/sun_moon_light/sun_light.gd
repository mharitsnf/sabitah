class_name SunLight extends SunMoonLight

enum DayOrNight {
	START, DAY, NIGHT
}

signal sunrise_started
signal sunset_started

var day_or_night: DayOrNight = DayOrNight.START
var ndotl: float = 1.

func _enter_tree() -> void:
	if !is_node_ready(): await ready

	match level_type:
		State.LevelType.MAIN:
			if !State.game_sun: State.game_sun = self
		State.LevelType.GLOBE:
			if !State.globe_sun: State.globe_sun = self

func _process(delta: float) -> void:
	super(delta)
	_calculate_player_dot_sun()

func _calculate_player_dot_sun() -> void:
	if level_type != State.LevelType.MAIN: return

	var actor: Node3D = (State.actor_im as ActorInputManager).get_current_instance()
	
	var a_normal: Vector3 = (actor as Node3D).global_position.normalized()
	var light: Vector3 = (global_position - (actor as Node3D).global_position).normalized()
	ndotl = a_normal.dot(light)

	if ndotl < State.SUNSET_ANGLE and day_or_night != DayOrNight.NIGHT:
		day_or_night = DayOrNight.NIGHT
		sunset_started.emit()
		print('night')

	if ndotl > State.SUNSET_ANGLE and day_or_night != DayOrNight.DAY:
		day_or_night = DayOrNight.DAY
		sunrise_started.emit()
		print('day')

func get_star_intensity() -> float:
	return 1. - ndotl

