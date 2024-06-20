class_name AtmosphereManager extends Node

@export_group("Acceleration")
@export var is_accelerated : bool:
	set(value):
		is_accelerated = value
		parameter_updated.emit()

@export_group("Optical depth texture")
var od_tex: ImageTexture
@export var od_tex_filename : String:
	set(value):
		od_tex_filename = value
		od_tex = _read_od_tex()
		parameter_updated.emit()

@export_group("Radiuses")
@export var planet_radius_scale : float = 0.:
	set(value):
		planet_radius_scale = value
		parameter_updated.emit()
@export var planet_to_atmosphere_scale : float = 16.:
	set(value):
		planet_to_atmosphere_scale = value
		parameter_updated.emit()

@export_group("Sample Sizes")
@export var optical_depth_sample_size : int:
	set(value):
		optical_depth_sample_size = value
		parameter_updated.emit()
@export var in_scattering_sample_size : int:
	set(value):
		in_scattering_sample_size = value
		parameter_updated.emit()

@export_group("Rayleigh")
var r_scattering_coef: Vector3 = Vector3.ZERO
@export var r_density_falloff : float:
	set(value):
		r_density_falloff = value
		parameter_updated.emit()

@export var r_exponent : float:
	set(value):
		r_exponent = value
		r_scattering_coef = _calculate_rayleigh_coefficients()
		parameter_updated.emit()

@export var r_numerator : float:
	set(value):
		r_numerator = value
		r_scattering_coef = _calculate_rayleigh_coefficients()
		parameter_updated.emit()

@export var r_scattering_strength : float:
	set(value):
		r_scattering_strength = value
		r_scattering_coef = _calculate_rayleigh_coefficients()
		parameter_updated.emit()

@export_group("Mie")
var m_scattering_coef: Vector3 = Vector3.ZERO
@export var m_density_falloff : float:
	set(value):
		m_density_falloff = value
		parameter_updated.emit()
@export var m_scattering_strength : float:
	set(value):
		m_scattering_strength = value
		m_scattering_coef = _calculate_mie_coefficients()
		parameter_updated.emit()

@export_group("Light")
@export var density_falloff_strength : float:
	set(value):
		density_falloff_strength = value
		parameter_updated.emit()
@export var optical_depth_strength : float:
	set(value):
		optical_depth_strength = value
		parameter_updated.emit()
@export var wavelengths : Vector3:
	set(value):
		wavelengths = value
		r_scattering_coef = _calculate_rayleigh_coefficients()
		parameter_updated.emit()

@export_group("HDR")
@export var f_exposure : float:
	set(value):
		f_exposure = value
		parameter_updated.emit()

signal parameter_updated

func get_shader_data(level_type: State.LevelType) -> Dictionary:
	var planet_data: Dictionary = State.get_planet_data(level_type)
	var planet_radius: float = planet_data['radius']
	planet_radius = (planet_radius - (planet_radius * planet_radius_scale / 100.))

	return {
		"planet_center": Vector3.ZERO,

		# Acceleration
		"is_accelerated": is_accelerated,
		"optical_depth_texture": od_tex,

		# Radiuses
		"planet_radius": planet_radius,
		"atmosphere_radius": planet_radius * planet_to_atmosphere_scale,

		# Rayleigh
		"r_density_falloff": r_density_falloff,
		"r_scattering_coefficients": r_scattering_coef,

		# Mie
		"m_density_falloff": m_density_falloff,
		"m_scattering_coefficients": m_scattering_coef,

		# In scattering and density falloff
		"in_scattering_sample_size": in_scattering_sample_size,
		"density_falloff_strength": density_falloff_strength,

		# Optical depth
		"optical_depth_sample_size": optical_depth_sample_size,
		"optical_depth_strength": optical_depth_strength,

		# HDR
		"f_exposure": f_exposure,
	}

## Private. Reads the optical depth texture from the provided [od_tex_filename].
func _read_od_tex() -> ImageTexture:
	if od_tex_filename.is_empty(): return

	var img_in: FileAccess = FileAccess.open("res://assets/resources/atmosphere/%s.i" % od_tex_filename, FileAccess.READ)
	var dat_in: FileAccess = FileAccess.open("res://assets/resources/atmosphere/%s.idat" % od_tex_filename, FileAccess.READ)

	var dat: Dictionary = JSON.parse_string(dat_in.get_line())
	var inbytes: PackedByteArray = img_in.get_buffer(dat.blen)

	var od_img: Image = Image.create_from_data(dat.width, dat.height, false, dat.format, inbytes)
	var res_tex: ImageTexture = ImageTexture.create_from_image(od_img)

	return res_tex

func _calculate_rayleigh_coefficients() -> Vector3:
	return Vector3(
		pow(r_numerator / wavelengths.x, r_exponent) * r_scattering_strength,
		pow(r_numerator / wavelengths.y, r_exponent) * r_scattering_strength,
		pow(r_numerator / wavelengths.z, r_exponent) * r_scattering_strength,
	)

func _calculate_mie_coefficients() -> Vector3:
	return Vector3(
		18.0e-6,
		18.0e-6,
		18.0e-6
	) * m_scattering_strength