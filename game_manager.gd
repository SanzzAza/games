extends Node

var subscribers: int = 0
var money: float = 50000.0
var energy: int = 100
var current_day: int = 0 # 0 = Senin
var current_hour: int = 8

var upgrades: Dictionary = {
	"phone": 0,
	"mic": 0,
	"camera": 0,
	"pc": 0,
	"editing": 0,
	"lighting": 0,
	"internet": 0,
	"room": 0,
}

var milestones_reached: Array = []

const DAY_NAMES = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"]

const CONTENT_GENRES = [
	{
		"name": "Gaming",
		"icon": "🎮",
		"cost": 5000,
		"energy": 20,
		"base_views": 500,
		"viral_chance": 0.15,
	},
	{
		"name": "Vlog Sekolah",
		"icon": "🎒",
		"cost": 3000,
		"energy": 15,
		"base_views": 300,
		"viral_chance": 0.1,
	},
	{
		"name": "Prank",
		"icon": "😂",
		"cost": 10000,
		"energy": 30,
		"base_views": 1000,
		"viral_chance": 0.25,
	},
	{
		"name": "Horror",
		"icon": "👻",
		"cost": 8000,
		"energy": 25,
		"base_views": 800,
		"viral_chance": 0.2,
	},
	{
		"name": "Reaction",
		"icon": "😱",
		"cost": 4000,
		"energy": 15,
		"base_views": 400,
		"viral_chance": 0.12,
	},
	{
		"name": "Tutorial",
		"icon": "📚",
		"cost": 6000,
		"energy": 25,
		"base_views": 600,
		"viral_chance": 0.08,
	},
	{
		"name": "Podcast",
		"icon": "🎙️",
		"cost": 7000,
		"energy": 30,
		"base_views": 700,
		"viral_chance": 0.1,
	},
	{
		"name": "Review Makanan",
		"icon": "🍔",
		"cost": 15000,
		"energy": 20,
		"base_views": 900,
		"viral_chance": 0.18,
	},
	{
		"name": "Short Video",
		"icon": "📱",
		"cost": 2000,
		"energy": 10,
		"base_views": 1500,
		"viral_chance": 0.3,
	},
]

const UPGRADES = {
	"phone": {
		"name": "HP",
		"icon": "📱",
		"description": "Kualitas video lebih bagus",
		"base_cost": 100000,
		"cost_multiplier": 2.0,
		"max_level": 5,
		"bonus": 0.15,
	},
	"mic": {
		"name": "Microphone",
		"icon": "🎤",
		"description": "Audio lebih jernih",
		"base_cost": 80000,
		"cost_multiplier": 2.0,
		"max_level": 5,
		"bonus": 0.12,
	},
	"camera": {
		"name": "Kamera",
		"icon": "📷",
		"description": "Kualitas cinematic",
		"base_cost": 500000,
		"cost_multiplier": 2.5,
		"max_level": 4,
		"bonus": 0.25,
	},
	"pc": {
		"name": "PC Gaming",
		"icon": "💻",
		"description": "Editing & gaming lancar",
		"base_cost": 1000000,
		"cost_multiplier": 3.0,
		"max_level": 4,
		"bonus": 0.3,
	},
	"editing": {
		"name": "Software Editing",
		"icon": "✂️",
		"description": "Efek keren & transisi smooth",
		"base_cost": 200000,
		"cost_multiplier": 2.0,
		"max_level": 5,
		"bonus": 0.2,
	},
	"lighting": {
		"name": "Lampu RGB",
		"icon": "💡",
		"description": "Setup aesthetic banget",
		"base_cost": 150000,
		"cost_multiplier": 2.0,
		"max_level": 3,
		"bonus": 0.1,
	},
	"internet": {
		"name": "Internet",
		"icon": "📶",
		"description": "Upload cepat, livestream lancar",
		"base_cost": 300000,
		"cost_multiplier": 1.5,
		"max_level": 5,
		"bonus": 0.15,
	},
	"room": {
		"name": "Studio",
		"icon": "🏠",
		"description": "Ruangan lebih luas & keren",
		"base_cost": 2000000,
		"cost_multiplier": 3.0,
		"max_level": 3,
		"bonus": 0.35,
	},
}

func create_video(genre_data: Dictionary) -> Dictionary:
	var base_views = genre_data.base_views
	var viral_chance = genre_data.viral_chance
	
	# Calculate quality multiplier from upgrades
	var quality_multiplier = 1.0
	for upgrade_key in upgrades.keys():
		var level = upgrades[upgrade_key]
		var bonus = UPGRADES[upgrade_key].bonus
		quality_multiplier += level * bonus
	
	# Subscriber bonus
	var subscriber_bonus = 1.0 + (subscribers / 10000.0)
	
	# Random factor
	var random_factor = randf_range(0.5, 2.0)
	
	# Calculate views
	var views = int(base_views * quality_multiplier * subscriber_bonus * random_factor)
	
	# Viral check
	if randf() < viral_chance:
		views *= randi_range(5, 20) # VIRAL!
	
	# Calculate earnings (Rp 1000 per 1000 views base)
	var earnings = (views / 1000.0) * 1000.0
	
	# Calculate subscriber gain
	var subs_gain = maxi(1, int(views / 100.0))
	
	subscribers += subs_gain
	money += earnings
	
	# Generate title
	var title = generate_video_title(genre_data)
	
	return {
		"title": title,
		"views": views,
		"earnings": earnings,
		"subs_gain": subs_gain,
	}

func generate_video_title(genre_data: Dictionary) -> String:
	var titles = {
		"Gaming": [
			"NGAKAK! MABAR SAMA BOCIL TOXIC!",
			"GG ABIS! RANKED PUSH SAMPE PAGI!",
			"AUTO SULTAN! BUKA 100 CRATE!",
			"KETEMU PRO PLAYER! LANGSUNG DIHAJAR!",
			"NGEGAME PAKAI HP KENTANG WKWK",
		],
		"Vlog Sekolah": [
			"VLOG: HARI PERTAMA MASUK SEKOLAH!",
			"BOLOS SEKOLAH BUAT NGONTEN?!",
			"KETAHUAN GURU MAIN HP DI KELAS!",
			"NGERJAIN TEMEN SAMPAI MARAH!",
			"MAKAN BEKAL TEMEN DIAM-DIAM WKWK",
		],
		"Prank": [
			"PRANK JADI POCONG! TEMEN PINGSAN!",
			"PRANK PACAR SAMPAI NANGIS! (GONE WRONG)",
			"PRANK ORTU NILAI MERAH! DIMARAHIN!",
			"PRANK TUKANG BAKSO! NGAKAK ABIS!",
			"PRANK TELEPON MANTAN! AWKWARD BET!",
		],
		"Horror": [
			"HANTU DI KAMAR MANDI SEKOLAH! (REAL)",
			"MAIN JELANGKUNG MALAM JUMAT!",
			"KESURUPAN SAAT LIVESTREAM?!",
			"RUMAH ANGKER! BERANI MASUK?",
			"SUARA ANEH DI RUMAH! MERINDING!",
		],
		"Reaction": [
			"REACTION VIDEO VIRAL! NGAKAK!",
			"REACT KOMENTAR HATERS! ROASTING!",
			"REACT MEME INDONESIA! KOCAK ABIS!",
			"REACT VIDEO CRINGE! NAHAN TAWA!",
			"REACT DRAMA ARTIS! TEA TIME!",
		],
		"Tutorial": [
			"CARA EDIT VIDEO DI HP! GAMPANG!",
			"TUTORIAL JADI YOUTUBER PEMULA!",
			"TIPS BIKIN THUMBNAIL KEREN!",
			"CARA VIRAL DI TIKTOK! 100% WORK!",
			"RAHASIA ALGORITMA YOUTUBE 2024!",
		],
		"Podcast": [
			"PODCAST: CURHAT TENTANG KEHIDUPAN",
			"NGOBROL SANTAI BARENG TEMEN!",
			"PODCAST: TIPS SUKSES JADI KREATOR",
			"BAHAS DRAMA INTERNET TERBARU!",
			"PODCAST MALAM: CERITA HOROR!",
		],
		"Review Makanan": [
			"REVIEW WARTEG LANGGANAN! ENAK!",
			"NYOBAIN MAKANAN VIRAL! WORTH IT?",
			"REVIEW MCDONALD'S VS KFC!",
			"MAKAN DI WARTEG SULTAN! MAHAL!",
			"REVIEW GORENGAN PINGGIR JALAN!",
		],
		"Short Video": [
			"KETIKA LAGI MALES NGONTEN...",
			"RELATABLE BANGET! PART 127",
			"POV: KAMU LAGI REBAHAN",
			"TIPE-TIPE ANAK TONGKRONGAN",
			"EKSPEKTASI VS REALITA YOUTUBER",
		],
	}
	
	var genre_name = genre_data.name
	if titles.has(genre_name):
		var title_list = titles[genre_name]
		return title_list[randi() % title_list.size()]
	else:
		return "VIDEO KEREN! WAJIB NONTON!"

func generate_comment(result: Dictionary, genre_data: Dictionary) -> String:
	var positive_comments = [
		"pertama bang!",
		"keren banget kontennya!",
		"ngakak abis wkwkwk",
		"mantap jiwa!",
		"gas terus bang!",
		"subscribe balik dong",
		"salam dari %s!" % get_random_city(),
		"giveaway dong bang",
		"collab yuk bang",
		"semangat ngontennya!",
		"akhirnya upload lagi",
		"ditunggu part selanjutnya",
		"🔥🔥🔥",
		"anjir kocak",
		"relate banget sih",
	]
	
	var negative_comments = [
		"cringe",
		"garing bang",
		"clickbait",
		"konten receh",
		"ga lucu",
		"skip",
		"dislike",
		"mending nonton %s" % get_random_name(),
		"konten gitu doang viral?",
		"overrated",
	]
	
	var neutral_comments = [
		"siapa yang nonton tahun 2024?",
		"yang setuju like!",
		"jangan lupa subscribe!",
		"hadir!",
		"komen ke-%d" % randi_range(1, 100),
		"yang nonton sambil rebahan",
		"notif squad!",
		"early!",
	]
	
	# More positive if viral
	var comment_pool = []
	if result.views > 100000:
		comment_pool = positive_comments + positive_comments + neutral_comments
	elif result.views < 5000:
		comment_pool = negative_comments + neutral_comments
	else:
		comment_pool = positive_comments + negative_comments + neutral_comments
	
	return comment_pool[randi() % comment_pool.size()]

func get_random_name() -> String:
	var names = [
		"Rizky", "Budi", "Andi", "Doni", "Reza", "Fajar", "Yoga", "Dimas",
		"Siti", "Dewi", "Putri", "Ayu", "Rina", "Maya", "Tari", "Novi",
		"GamerPro123", "BocahGaming", "KontenKreator", "YouTuberPemula",
		"MLBBPro", "FFMaster", "VloggerCilik", "PodcasterMuda"
	]
	return names[randi() % names.size()]

func get_random_city() -> String:
	var cities = [
		"Jakarta", "Bandung", "Surabaya", "Medan", "Semarang",
		"Yogyakarta", "Makassar", "Palembang", "Tangerang", "Depok",
		"Bekasi", "Bogor", "Malang", "Solo", "Bali"
	]
	return cities[randi() % cities.size()]

func advance_time(hours: int) -> void:
	current_hour += hours
	while current_hour >= 24:
		current_hour -= 24
		current_day = (current_day + 1) % 7

func format_number(num: float) -> String:
	if num >= 1000000:
		return "%.1fM" % (num / 1000000.0)
	elif num >= 1000:
		return "%.1fK" % (num / 1000.0)
	else:
		return str(int(num))
