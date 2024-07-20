class_name RenderStack extends Node

@export_group("Parameters")
@export var noise_tex: Texture2D
@export_group("References")
@export var level_viewport: Viewport
@export_subgroup("Shaders")
@export var blur_1_shader: Shader
@export var blur_2_shader: Shader
@export var kuwahara_1_shader: Shader
@export var kuwahara_2_shader: Shader
@export var kuwahara_3_shader: Shader
@export var kuwahara_4_shader: Shader
@export var grain_shader: Shader
@export_subgroup("Packed scenes")
@export var pp_pass_pscn: PackedScene

func _ready() -> void:
	assert(level_viewport)
	assert(pp_pass_pscn)
	assert(blur_1_shader)
	assert(blur_2_shader)
	assert(kuwahara_1_shader)
	assert(kuwahara_2_shader)
	assert(kuwahara_3_shader)
	assert(kuwahara_4_shader)
	assert(grain_shader)

	# blur 1 
	var blur_1_pass: PostProcessingPass = pp_pass_pscn.instantiate()
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = blur_1_shader
	mat.resource_local_to_scene = true
	mat.set_shader_parameter("main_tex", level_viewport.get_texture())
	(blur_1_pass as PostProcessingPass).game_texture.material = mat
	add_child.call_deferred(blur_1_pass)
	await blur_1_pass.ready

	# blur 2
	var blur_2_pass: PostProcessingPass = pp_pass_pscn.instantiate()
	mat = ShaderMaterial.new()
	mat.shader = blur_2_shader
	mat.resource_local_to_scene = true
	mat.set_shader_parameter("main_tex", (blur_1_pass as PostProcessingPass).viewport.get_texture())
	(blur_2_pass as PostProcessingPass).game_texture.material = mat
	add_child.call_deferred(blur_2_pass)
	await blur_2_pass.ready

	# Kuwahara 1
	var kwh_1_pass: PostProcessingPass = pp_pass_pscn.instantiate()
	mat = ShaderMaterial.new()
	mat.shader = kuwahara_1_shader
	mat.resource_local_to_scene = true
	mat.set_shader_parameter("main_tex", level_viewport.get_texture())
	(kwh_1_pass as PostProcessingPass).game_texture.material = mat
	add_child.call_deferred(kwh_1_pass)
	await kwh_1_pass.ready

	# Kuwahara 2
	var kwh_2_pass: PostProcessingPass = pp_pass_pscn.instantiate()
	mat = ShaderMaterial.new()
	mat.shader = kuwahara_2_shader
	mat.resource_local_to_scene = true
	mat.set_shader_parameter("blurred_tex", (blur_2_pass as PostProcessingPass).viewport.get_texture())
	mat.set_shader_parameter("kuwahara_1", (kwh_1_pass as PostProcessingPass).viewport.get_texture())
	(kwh_2_pass as PostProcessingPass).game_texture.material = mat
	add_child.call_deferred(kwh_2_pass)
	await kwh_2_pass.ready

	# Kuwahara 3
	var kwh_3_pass: PostProcessingPass = pp_pass_pscn.instantiate()
	mat = ShaderMaterial.new()
	mat.shader = kuwahara_3_shader
	mat.resource_local_to_scene = true
	mat.set_shader_parameter("radius", 6.)
	mat.set_shader_parameter("main_tex", level_viewport.get_texture())
	(kwh_3_pass as PostProcessingPass).game_texture.material = mat
	add_child.call_deferred(kwh_3_pass)
	await kwh_3_pass.ready

	# Kuwahara 4
	var kwh_4_pass: PostProcessingPass = pp_pass_pscn.instantiate()
	mat = ShaderMaterial.new()
	mat.shader = kuwahara_4_shader
	mat.resource_local_to_scene = true
	mat.set_shader_parameter("kuwahara_2", (kwh_2_pass as PostProcessingPass).viewport.get_texture())
	mat.set_shader_parameter("kuwahara_3", (kwh_3_pass as PostProcessingPass).viewport.get_texture())
	(kwh_4_pass as PostProcessingPass).game_texture.material = mat
	add_child.call_deferred(kwh_4_pass)
	await kwh_4_pass.ready

	# grain
	var grain_pass: PostProcessingPass = pp_pass_pscn.instantiate()
	Group.add("final_viewport", (grain_pass as PostProcessingPass).viewport)
	mat = ShaderMaterial.new()
	mat.shader = grain_shader
	mat.resource_local_to_scene = true
	mat.set_shader_parameter("noise_amount", 2.5)
	mat.set_shader_parameter("blend_opacity", .2)
	mat.set_shader_parameter("noise_tex", noise_tex)
	mat.set_shader_parameter("main_tex", (kwh_4_pass as PostProcessingPass).viewport.get_texture())
	(grain_pass as PostProcessingPass).game_texture.material = mat
	add_child.call_deferred(grain_pass)
	await grain_pass.ready