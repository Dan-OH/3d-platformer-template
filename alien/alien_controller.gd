extends CharacterBody3D

@export var follow_speed: float = 3.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var target: Node3D

var _gravity := -30.0

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	#velocity = Vector3.ZERO
	#set_physics_process(true)
	nav_agent.velocity_computed.connect(_on_velocity_computed)

func _physics_process(delta: float) -> void:
	var y_velocity := velocity.y
	velocity.y = 0.0
	
	if not is_on_floor():
		velocity.y = y_velocity + _gravity * delta
	
	move_and_slide()
	
	_on_follow_state_physics_processing(true)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z
	
func _on_follow_state_physics_processing(delta: float) -> void:
	if not target:
		print("no target")
		return
		
	nav_agent.target_position = target.global_position
	
	if nav_agent.is_navigation_finished():
		nav_agent.velocity = Vector3.ZERO
		return
		
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	
	nav_agent.velocity = direction * follow_speed
	
	if direction.length() > 0.01:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 1.0 * delta)
