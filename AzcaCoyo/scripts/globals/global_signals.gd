extends Node

signal on_update_app

#region interaccion UI <-> navegacion
signal on_camera_leave_initial_position()
signal on_camera_reset_position()
signal on_mini_site_clicked(_id:int)
signal on_go_to_poi(_tipo:TIPO_POI.ENUM_POI)
signal on_agregar_poi_perfil(_id_estacion:int, _transform: Transform3D)
signal on_desactivar_eventos(_desactivar: bool)
#endregion

#region UI <-> escenas
signal on_unload_perfil()
signal on_unload_particular()
signal on_tarjeta_mosaico_clicked(_id_estacion:int)
signal on_ui_change(tipo_modulo: TIPO_MODULO.UI)
signal on_particular_loaded(id_estacion: int)
#region

#region 3D
signal on_persistent_scene_loaded(last_scene: Node3D)
#endregion

var isTransitioning: bool = false;

func connect_on_update_app(callback:Callable,do_connect:bool) -> void:
	if do_connect :
		on_update_app.connect(callback)
	elif on_update_app.is_connected(callback):
		on_update_app.disconnect(callback)

func connect_on_camera_leave_initial_position(callback:Callable,do_connect:bool) -> void:
	if do_connect :
		on_camera_leave_initial_position.connect(callback)
	elif on_camera_leave_initial_position.is_connected(callback):
		on_camera_leave_initial_position.disconnect(callback)

func connect_on_camera_reset_position(callback:Callable,do_connect:bool) -> void:
	if do_connect :
		on_camera_reset_position.connect(callback)
	elif on_camera_reset_position.is_connected(callback):
		on_camera_reset_position.disconnect(callback)

func connect_on_mini_site_clicked(callback:Callable,do_connect:bool) -> void:
	if do_connect :
		on_mini_site_clicked.connect(callback)
	elif on_mini_site_clicked.is_connected(callback):
		on_mini_site_clicked.disconnect(callback)

func connect_on_go_to_poi(callback:Callable,do_connect:bool) -> void:
	if do_connect :
		on_go_to_poi.connect(callback)
	elif on_go_to_poi.is_connected(callback):
		on_go_to_poi.disconnect(callback)

func connect_on_agregar_poi_perfil(callback:Callable,do_connect:bool) -> void:
	if do_connect :
		on_agregar_poi_perfil.connect(callback)
	elif on_agregar_poi_perfil.is_connected(callback):
		on_agregar_poi_perfil.disconnect(callback)

func connect_on_unload_perfil(callback:Callable,do_connect:bool) -> void:
	if do_connect :
		on_unload_perfil.connect(callback)
	elif on_unload_perfil.is_connected(callback):
		on_unload_perfil.disconnect(callback)
		
func connect_on_unload_particular(callback:Callable,do_connect:bool) -> void:
	if do_connect :
		on_unload_particular.connect(callback)
	elif on_unload_particular.is_connected(callback):
		on_unload_particular.disconnect(callback)
		
func connect_on_tarjeta_mosaico_clicked(callback:Callable,do_connect:bool) -> void:
	if do_connect :
		on_tarjeta_mosaico_clicked.connect(callback)
	elif on_tarjeta_mosaico_clicked.is_connected(callback):
		on_tarjeta_mosaico_clicked.disconnect(callback)

func connect_on_ui_change(callback:Callable,do_connect:bool) -> void:
	if do_connect :
		on_ui_change.connect(callback)
	elif on_ui_change.is_connected(callback):
		on_ui_change.disconnect(callback)

func connect_on_persistent_scene_loaded(callback:Callable,do_connect:bool) -> void:
	if do_connect :
		on_persistent_scene_loaded.connect(callback)
	elif on_persistent_scene_loaded.is_connected(callback):
		on_persistent_scene_loaded.disconnect(callback)

func connect_on_particular_loaded(callback:Callable,do_connect:bool) -> void:
	if do_connect :
		on_particular_loaded.connect(callback)
	elif on_particular_loaded.is_connected(callback):
		on_particular_loaded.disconnect(callback)

func connect_on_desactivar_eventos(callback:Callable,do_connect:bool) -> void:
	if do_connect :
		on_desactivar_eventos.connect(callback)
	elif on_desactivar_eventos.is_connected(callback):
		on_desactivar_eventos.disconnect(callback)
