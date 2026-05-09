extends Node2D

var game_manager: Node
var notification_label: Label
var notification_timer: float = 0.0

var content_dialog: Panel
var live_dialog: Panel
var upgrade_dialog: Panel
var life_dialog: Panel
var video_result_dialog: Panel

var is_livestreaming: bool = false
var live_duration: float = 0.0
var live_viewers: int = 0
var live_earnings: float = 0.0

func _ready() -> void:
	game_manager = $GameManager
	notification_label = $CanvasLayer/UI/NotificationLabel
	content_dialog = $CanvasLayer/UI/ContentDialog
	live_dialog = $CanvasLayer/UI/LiveDialog
	upgrade_dialog = $CanvasLayer/UI/UpgradeDialog
	life_dialog = $CanvasLayer/UI/LifeDialog
	video_result_dialog = $CanvasLayer/UI/VideoResultDialog
	
	# Apply theme
	var ui_theme_script = load("res://ui_theme.gd")
	var custom_theme = ui_theme_script.create_theme()
	$CanvasLayer/UI.theme = custom_theme
	
	_setup_content_genres()
	_setup_upgrade_items()
	_setup_life_actions()
	_update_ui()
	
	show_notification("🎬 Selamat datang di Youtuber Simulator Indonesia!\n💡 Mulai dari nol, jadi sultan YouTube!")

func _process(delta: float) -> void:
	if notification_timer > 0:
		notification_timer -= delta
		if notification_timer <= 0:
			notification_label.text = ""
	
	if is_livestreaming:
		live_duration += delta
		var minutes = int(live_duration / 60)
		var seconds = int(live_duration) % 60
		$CanvasLayer/UI/LiveDialog/LiveStats.text = "💰 Rp %s | ⏱️ %02d:%02d" % [game_manager.format_number(live_earnings), minutes, seconds]

func _update_ui() -> void:
	$CanvasLayer/UI/TopBar/Stats/SubsLabel.text = "📺 " + game_manager.format_number(game_manager.subscribers)
	$CanvasLayer/UI/TopBar/Stats/MoneyLabel.text = "💰 Rp " + game_manager.format_number(game_manager.money)
	$CanvasLayer/UI/TopBar/Stats/EnergyLabel.text = "⚡ %d%%" % game_manager.energy
	
	var day_name = game_manager.DAY_NAMES[game_manager.current_day]
	$CanvasLayer/UI/TopBar/Stats/TimeLabel.text = "🕐 %s, %02d:00" % [day_name, game_manager.current_hour]

func show_notification(text: String) -> void:
	notification_label.text = text
	notification_timer = 4.0

func _setup_content_genres() -> void:
	var genre_list = $CanvasLayer/UI/ContentDialog/GenreList
	for child in genre_list.get_children():
		child.queue_free()
	
	for genre_data in game_manager.CONTENT_GENRES:
		var btn = Button.new()
		var cost = genre_data.cost
		var energy_cost = genre_data.energy
		btn.text = "%s %s\n💰 Rp %s | ⚡ %d%%" % [genre_data.icon, genre_data.name, game_manager.format_number(cost), energy_cost]
		btn.custom_minimum_size = Vector2(0, 50)
		
		if game_manager.money < cost or game_manager.energy < energy_cost:
			btn.disabled = true
		
		btn.pressed.connect(_on_genre_selected.bind(genre_data))
		genre_list.add_child(btn)

func _setup_upgrade_items() -> void:
	var upgrade_list = $CanvasLayer/UI/UpgradeDialog/UpgradeScroll/UpgradeList
	for child in upgrade_list.get_children():
		child.queue_free()
	
	for upgrade_key in game_manager.UPGRADES.keys():
		var upgrade = game_manager.UPGRADES[upgrade_key]
		var current_level = game_manager.upgrades[upgrade_key]
		
		if current_level >= upgrade.max_level:
			var label = Label.new()
			label.text = "%s %s\n✅ MAX LEVEL" % [upgrade.icon, upgrade.name]
			upgrade_list.add_child(label)
		else:
			var next_cost = upgrade.base_cost * pow(upgrade.cost_multiplier, current_level)
			var btn = Button.new()
			btn.text = "%s %s (Lv %d)\n💰 Rp %s\n%s" % [
				upgrade.icon, 
				upgrade.name, 
				current_level + 1,
				game_manager.format_number(next_cost),
				upgrade.description
			]
			btn.custom_minimum_size = Vector2(0, 70)
			
			if game_manager.money < next_cost:
				btn.disabled = true
			
			btn.pressed.connect(_on_upgrade_selected.bind(upgrade_key))
			upgrade_list.add_child(btn)

func _setup_life_actions() -> void:
	var life_actions = $CanvasLayer/UI/LifeDialog/LifeActions
	for child in life_actions.get_children():
		child.queue_free()
	
	var actions = [
		{"name": "🍜 Makan Warmindo", "cost": 15000, "energy": 20, "time": 1},
		{"name": "☕ Ngopi Santai", "cost": 10000, "energy": 10, "time": 1},
		{"name": "🏖️ Healing ke Mall", "cost": 50000, "energy": 40, "time": 3},
		{"name": "🎮 Nongkrong Warnet", "cost": 20000, "energy": 15, "time": 2},
		{"name": "😴 Rebahan (Gratis)", "cost": 0, "energy": 30, "time": 2},
		{"name": "💤 Tidur Malam", "cost": 0, "energy": 100, "time": 8},
	]
	
	for action in actions:
		var btn = Button.new()
		if action.cost > 0:
			btn.text = "%s\n💰 Rp %s | ⚡ +%d%% | ⏱️ %d jam" % [
				action.name,
				game_manager.format_number(action.cost),
				action.energy,
				action.time
			]
		else:
			btn.text = "%s\n⚡ +%d%% | ⏱️ %d jam" % [
				action.name,
				action.energy,
				action.time
			]
		
		btn.custom_minimum_size = Vector2(0, 50)
		
		if game_manager.money < action.cost:
			btn.disabled = true
		
		btn.pressed.connect(_on_life_action_selected.bind(action))
		life_actions.add_child(btn)

func _on_content_btn_pressed() -> void:
	content_dialog.visible = true
	_setup_content_genres()

func _on_close_content_pressed() -> void:
	content_dialog.visible = false

func _on_genre_selected(genre_data: Dictionary) -> void:
	if game_manager.money < genre_data.cost or game_manager.energy < genre_data.energy:
		return
	
	game_manager.money -= genre_data.cost
	game_manager.energy -= genre_data.energy
	
	content_dialog.visible = false
	
	# Generate video result
	var result = game_manager.create_video(genre_data)
	_show_video_result(result, genre_data)
	
	game_manager.advance_time(3)
	_update_ui()

func _show_video_result(result: Dictionary, genre_data: Dictionary) -> void:
	video_result_dialog.visible = true
	
	$CanvasLayer/UI/VideoResultDialog/VideoTitle.text = result.title
	$CanvasLayer/UI/VideoResultDialog/ViewsLabel.text = "👁️ %s views" % game_manager.format_number(result.views)
	$CanvasLayer/UI/VideoResultDialog/SubsGainLabel.text = "📺 +%s subscribers" % game_manager.format_number(result.subs_gain)
	$CanvasLayer/UI/VideoResultDialog/MoneyGainLabel.text = "💰 +Rp %s" % game_manager.format_number(result.earnings)
	
	var status_text = ""
	var status_color = Color.WHITE
	
	if result.views >= 1000000:
		status_text = "🔥🔥🔥 VIRAL BESAR!!!"
		status_color = Color(1, 0.2, 0.2)
	elif result.views >= 100000:
		status_text = "🔥 TRENDING!"
		status_color = Color(1, 0.5, 0)
	elif result.views >= 10000:
		status_text = "📈 Lumayan!"
		status_color = Color(0.2, 1, 0.2)
	else:
		status_text = "😅 Flop..."
		status_color = Color(0.5, 0.5, 0.5)
	
	$CanvasLayer/UI/VideoResultDialog/StatusLabel.text = status_text
	$CanvasLayer/UI/VideoResultDialog/StatusLabel.add_theme_color_override("font_color", status_color)
	
	# Generate comments
	var comments_box = $CanvasLayer/UI/VideoResultDialog/CommentsScroll/CommentsBox
	for child in comments_box.get_children():
		child.queue_free()
	
	var comment_count = mini(8, maxi(3, int(result.views / 10000)))
	for i in range(comment_count):
		var comment = game_manager.generate_comment(result, genre_data)
		var label = Label.new()
		label.text = comment
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.add_theme_font_size_override("font_size", 12)
		comments_box.add_child(label)

func _on_close_result_pressed() -> void:
	video_result_dialog.visible = false
	_check_milestones()

func _check_milestones() -> void:
	if game_manager.subscribers >= 1000 and not game_manager.milestones_reached.has(1000):
		game_manager.milestones_reached.append(1000)
		show_notification("🎉 SELAMAT! 1K SUBSCRIBERS!\n🏆 Achievement Unlocked: Bocah Naik Daun")
	elif game_manager.subscribers >= 10000 and not game_manager.milestones_reached.has(10000):
		game_manager.milestones_reached.append(10000)
		show_notification("🎉 SELAMAT! 10K SUBSCRIBERS!\n🏆 Achievement Unlocked: Konten Kreator Sejati")
	elif game_manager.subscribers >= 100000 and not game_manager.milestones_reached.has(100000):
		game_manager.milestones_reached.append(100000)
		show_notification("🎉 SELAMAT! 100K SUBSCRIBERS!\n🏆 Silver Play Button! Kamu terkenal!")
	elif game_manager.subscribers >= 1000000 and not game_manager.milestones_reached.has(1000000):
		game_manager.milestones_reached.append(1000000)
		show_notification("🎉🎉🎉 SELAMAT! 1 JUTA SUBSCRIBERS!!!\n🏆 GOLD PLAY BUTTON! SULTAN YOUTUBE INDONESIA!")

func _on_live_btn_pressed() -> void:
	if game_manager.energy < 30:
		show_notification("⚡ Energi kurang! Istirahat dulu bang!")
		return
	
	is_livestreaming = true
	live_duration = 0.0
	live_viewers = randi_range(5, 50 + game_manager.subscribers / 100)
	live_earnings = 0.0
	
	live_dialog.visible = true
	$LiveTimer.start()
	
	var chat_box = $CanvasLayer/UI/LiveDialog/ChatScroll/ChatBox
	for child in chat_box.get_children():
		child.queue_free()
	
	$CanvasLayer/UI/LiveDialog/LiveTitle.text = "🔴 LIVESTREAM - %d viewers" % live_viewers
	
	_add_live_chat("🎮 Stream dimulai!")
	_add_live_chat("💬 Halo semuanya!")

func _on_end_live_pressed() -> void:
	is_livestreaming = false
	$LiveTimer.stop()
	live_dialog.visible = false
	
	game_manager.money += live_earnings
	var subs_gain = randi_range(1, maxi(1, live_viewers / 10))
	game_manager.subscribers += subs_gain
	
	var duration_minutes = int(live_duration / 60)
	game_manager.energy -= mini(50, duration_minutes * 5)
	game_manager.advance_time(maxi(1, duration_minutes / 60))
	
	_update_ui()
	show_notification("🔴 Livestream selesai!\n💰 +Rp %s | 📺 +%d subs" % [game_manager.format_number(live_earnings), subs_gain])

func _on_live_timer_timeout() -> void:
	if not is_livestreaming:
		return
	
	# Random viewer change
	live_viewers += randi_range(-5, 10)
	live_viewers = maxi(1, live_viewers)
	
	$CanvasLayer/UI/LiveDialog/LiveTitle.text = "🔴 LIVESTREAM - %d viewers" % live_viewers
	
	# Random chat
	var chat_types = [
		"💬 %s: %s",
		"😂 %s: %s",
		"🔥 %s: %s",
		"💰 %s donate Rp %s",
	]
	
	if randf() < 0.3: # 30% chance of chat
		var chat_messages = [
			"bang main game apa?",
			"wkwkwk lucu bang",
			"pertama bang!",
			"salam dari Bandung!",
			"giveaway dong bang",
			"kapan collab sama %s?" % game_manager.get_random_name(),
			"kontennya keren!",
			"subscribe balik dong",
			"bacot",
			"🔥🔥🔥",
			"gas terus bang!",
			"kentang bet ni stream",
		]
		
		if randf() < 0.2: # 20% chance of donation
			var donation = randi_range(1, 20) * 1000
			live_earnings += donation
			_add_live_chat("💰 %s donate Rp %s" % [game_manager.get_random_name(), game_manager.format_number(donation)])
		else:
			var username = game_manager.get_random_name()
			var message = chat_messages[randi() % chat_messages.size()]
			_add_live_chat("💬 %s: %s" % [username, message])

func _add_live_chat(text: String) -> void:
	var chat_box = $CanvasLayer/UI/LiveDialog/ChatScroll/ChatBox
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.add_theme_font_size_override("font_size", 12)
	chat_box.add_child(label)
	
	# Auto scroll to bottom
	await get_tree().process_frame
	var scroll = $CanvasLayer/UI/LiveDialog/ChatScroll
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

func _on_upgrade_btn_pressed() -> void:
	upgrade_dialog.visible = true
	_setup_upgrade_items()

func _on_close_upgrade_pressed() -> void:
	upgrade_dialog.visible = false

func _on_upgrade_selected(upgrade_key: String) -> void:
	var upgrade = game_manager.UPGRADES[upgrade_key]
	var current_level = game_manager.upgrades[upgrade_key]
	var cost = upgrade.base_cost * pow(upgrade.cost_multiplier, current_level)
	
	if game_manager.money < cost:
		return
	
	game_manager.money -= cost
	game_manager.upgrades[upgrade_key] += 1
	
	_update_ui()
	_setup_upgrade_items()
	
	show_notification("✅ %s upgraded ke level %d!" % [upgrade.name, game_manager.upgrades[upgrade_key]])

func _on_life_btn_pressed() -> void:
	life_dialog.visible = true
	_setup_life_actions()

func _on_close_life_pressed() -> void:
	life_dialog.visible = false

func _on_life_action_selected(action: Dictionary) -> void:
	if game_manager.money < action.cost:
		return
	
	game_manager.money -= action.cost
	game_manager.energy = mini(100, game_manager.energy + action.energy)
	game_manager.advance_time(action.time)
	
	life_dialog.visible = false
	_update_ui()
	
	show_notification("%s\n⚡ +%d%% energy" % [action.name, action.energy])

func _on_event_timer_timeout() -> void:
	# Random events
	var events = [
		"🔊 Tetangga marah: 'Berisik banget sih!'",
		"🍜 Tukang bakso lewat: 'BAKSOOO~'",
		"⚡ Mati lampu sebentar!",
		"📶 Wifi lemot banget hari ini...",
		"📱 Notif: Video kamu trending!",
		"🎮 Ada turnamen warnet, ikut gak?",
		"🌧️ Hujan deras, vibes ngonten makin enak",
		"☀️ Cuaca cerah, cocok buat vlog outdoor",
	]
	
	if randf() < 0.4: # 40% chance
		var event = events[randi() % events.size()]
		show_notification(event)
