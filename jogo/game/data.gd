extends RefCounted
## Dados do jogo (conteúdo original de GOLPE / Vila Rubra). Metros, m/s, dólares do jogo.

const WEAPONS := [
	{"id": "p22", "name": "Pistola Rato .22", "price": 0, "dmg": 10, "rate": 0.45, "range": 18.0, "pel": 1, "spr": 0.04, "lvl": 1},
	{"id": "p9", "name": "Pistola Vigia 9mm", "price": 15000, "dmg": 16, "rate": 0.35, "range": 21.0, "pel": 1, "spr": 0.03, "lvl": 2},
	{"id": "smg", "name": "SMG Vespa", "price": 60000, "dmg": 9, "rate": 0.11, "range": 20.0, "pel": 1, "spr": 0.09, "lvl": 3},
	{"id": "sg", "name": "Caçadeira Tróia", "price": 90000, "dmg": 9, "rate": 0.8, "range": 13.5, "pel": 6, "spr": 0.25, "lvl": 4},
	{"id": "rf", "name": "Espingarda Falcão", "price": 200000, "dmg": 45, "rate": 0.9, "range": 32.0, "pel": 1, "spr": 0.01, "lvl": 6},
]

const CARS := [
	{"id": "pardal", "name": "Pardal", "price": 0, "spd": 20.0, "hp": 100, "col": "#d9a441", "model": "car_hatchback", "lvl": 1, "d": "Pequeno e fiável"},
	{"id": "mula", "name": "Carrinha Mula", "price": 40000, "spd": 18.0, "hp": 190, "col": "#7d8a96", "model": "car_stationwagon", "lvl": 2, "d": "Lenta mas aguenta pancada"},
	{"id": "lince", "name": "Lince GT", "price": 120000, "spd": 27.0, "hp": 120, "col": "#c0392b", "model": "car_sedan", "lvl": 4, "d": "O mais rápido da cidade"},
	{"id": "touro", "name": "Touro", "price": 250000, "spd": 23.5, "hp": 280, "col": "#2e6b4f", "model": "car_taxi", "lvl": 6, "d": "Rápido e resistente"},
]

const BAGS := [
	{"id": "b10", "name": "Mochila escolar", "price": 0, "cap": 10, "lvl": 1, "g": [5, 3]},
	{"id": "b20", "name": "Mochila desportiva", "price": 12000, "cap": 20, "lvl": 1, "g": [6, 4]},
	{"id": "b35", "name": "Mochila tática", "price": 50000, "cap": 35, "lvl": 3, "g": [7, 5]},
	{"id": "b60", "name": "Mochila de expedição", "price": 150000, "cap": 60, "lvl": 5, "story": 2, "g": [8, 6]},
]

## ferramentas e equipamento (Armeiro)
const TOOLS := [
	{"id": "pe_cabra", "name": "Pé-de-cabra", "price": 8000, "d": "Arromba portas em metade do tempo"},
	{"id": "mascara", "name": "Máscara", "price": 12000, "d": "As câmaras deixam de te identificar"},
	{"id": "berbequim", "name": "Berbequim", "price": 40000, "d": "Necessário para abrir cofres"},
	{"id": "gazuas", "name": "Kit de gazuas", "price": 25000, "d": "Abre portas sem fazer barulho", "story": 1},
	{"id": "abracadeiras", "name": "Abraçadeiras ×5", "price": 3000, "d": "Amarra o funcionário de vez", "count": 5},
	{"id": "kit_medico", "name": "Kit médico", "price": 5000, "d": "Recupera 60 de vida (usa no inventário)", "item": true},
]

const PROPS := [
	{"id": "quiosque", "name": "Quiosque da Praça", "price": 30000, "rent": 400, "lvl": 1},
	{"id": "t1", "name": "Apartamento T1", "price": 100000, "rent": 1500, "lvl": 2},
	{"id": "loja", "name": "Loja de rua", "price": 250000, "rent": 4000, "lvl": 4},
	{"id": "predio", "name": "Prédio inteiro", "price": 800000, "rent": 14000, "lvl": 6},
]

## catálogo de itens: nome, categoria, peso (kg), valor. O ícone é res://game/icons/<id>.png
const ITEMS := {
	"cash": {"n": "Dinheiro", "cat": "dinheiro", "kg": 0.0, "v": 0, "sz": [1, 1], "max": 25000},
	"relogio": {"n": "Relógio de ouro", "cat": "joias", "kg": 0.2, "v": 6000, "sz": [1, 1], "max": 3},
	"anel": {"n": "Anel de diamante", "cat": "joias", "kg": 0.05, "v": 12000, "sz": [1, 1], "max": 5},
	"colar": {"n": "Colar de pérolas", "cat": "joias", "kg": 0.1, "v": 8000, "sz": [1, 1], "max": 2},
	"brincos": {"n": "Brincos de safira", "cat": "joias", "kg": 0.05, "v": 5000, "sz": [1, 1], "max": 5},
	"lingote": {"n": "Lingote de ouro", "cat": "joias", "kg": 1.0, "v": 25000, "sz": [2, 1], "max": 1},
	"mala": {"n": "Mala de marca", "cat": "joias", "kg": 1.5, "v": 7000, "sz": [2, 2], "max": 1},
	"portatil": {"n": "Portátil", "cat": "eletronica", "kg": 2.0, "v": 4500, "sz": [2, 2], "max": 1},
	"telemovel": {"n": "Telemóvel", "cat": "eletronica", "kg": 0.3, "v": 1200, "sz": [1, 1], "max": 3},
	"tablet": {"n": "Tablet", "cat": "eletronica", "kg": 0.6, "v": 2000, "sz": [1, 2], "max": 1},
	"maquina_cafe": {"n": "Máquina de café", "cat": "eletronica", "kg": 6.0, "v": 2000, "sz": [2, 2], "max": 1},
	"whisky": {"n": "Whisky velho", "cat": "bebidas", "kg": 1.2, "v": 1800, "sz": [1, 2], "max": 1},
	"vinho": {"n": "Vinho do Porto vintage", "cat": "bebidas", "kg": 1.4, "v": 2500, "sz": [1, 2], "max": 1},
	"champanhe": {"n": "Champanhe", "cat": "bebidas", "kg": 1.5, "v": 1500, "sz": [1, 2], "max": 1},
	"licor": {"n": "Garrafa de licor", "cat": "bebidas", "kg": 1.0, "v": 400, "sz": [1, 2], "max": 1},
	"energeticas": {"n": "Bebida energética", "cat": "bebidas", "kg": 0.5, "v": 120, "sz": [1, 1], "max": 6},
	"tabaco": {"n": "Volume de tabaco", "cat": "diversos", "kg": 0.5, "v": 350, "sz": [1, 1], "max": 5},
	"raspadinhas": {"n": "Raspadinhas", "cat": "diversos", "kg": 0.1, "v": 200, "sz": [1, 1], "max": 10},
	"bolo": {"n": "Bolo de aniversário", "cat": "diversos", "kg": 1.0, "v": 150, "sz": [2, 1], "max": 1},
	"bateria": {"n": "Bateria de carro", "cat": "diversos", "kg": 8.0, "v": 1200, "sz": [2, 2], "max": 1},
	"ferramentas": {"n": "Caixa de ferramentas", "cat": "diversos", "kg": 4.0, "v": 1500, "sz": [2, 1], "max": 1},
	"medicamentos": {"n": "Caixa de medicamentos", "cat": "farmacia", "kg": 0.4, "v": 900, "sz": [1, 1], "max": 4},
	"analgesicos": {"n": "Analgésicos fortes", "cat": "farmacia", "kg": 0.2, "v": 1600, "sz": [1, 1], "max": 5},
	"kit_medico": {"n": "Kit médico", "cat": "farmacia", "kg": 1.0, "v": 2500, "use": "heal", "sz": [2, 1], "max": 1},
	"pintura": {"n": "Pintura antiga", "cat": "arte", "kg": 4.0, "v": 60000, "sz": [2, 3], "max": 1},
	"estatueta": {"n": "Estatueta de bronze", "cat": "arte", "kg": 7.0, "v": 35000, "sz": [2, 2], "max": 1},
	"vaso": {"n": "Vaso cerâmico", "cat": "arte", "kg": 5.0, "v": 25000, "sz": [2, 2], "max": 1},
	"moeda": {"n": "Moeda rara", "cat": "arte", "kg": 0.1, "v": 15000, "sz": [1, 1], "max": 5},
	"foto": {"n": "Fotografia antiga", "cat": "historia", "kg": 0.0, "v": 0, "sz": [1, 1], "max": 1},
	"livro": {"n": "Livro de contas", "cat": "historia", "kg": 0.0, "v": 0, "sz": [1, 1], "max": 1},
}

const CAT_NAMES := {"joias": "Joias", "eletronica": "Eletrónica", "bebidas": "Bebidas", "arte": "Arte", "farmacia": "Farmácia", "diversos": "Diversos"}

const HEISTS := {
	"cafe": {"name": "Café Central", "lvl": 1, "cd": 120, "stars": 1, "xp": 25, "col": "#8a5a34"},
	"bomba": {"name": "Bomba Estrela", "lvl": 1, "cd": 180, "stars": 2, "xp": 40, "col": "#b23b2e", "rear": false},
	"farmacia": {"name": "Farmácia Sol", "lvl": 2, "cd": 200, "stars": 2, "xp": 50, "col": "#3f9a6a", "alarm": true},
	"garrafeira": {"name": "Garrafeira Tonel", "lvl": 2, "cd": 220, "stars": 2, "xp": 55, "col": "#6a2a3a", "alarm": true},
	"hotel": {"name": "Hotel Atlântida", "lvl": 3, "cd": 300, "stars": 3, "xp": 90, "col": "#3d5f8a", "alarm": true},
	"joalharia": {"name": "Joalharia Aurora", "lvl": 4, "cd": 360, "stars": 3, "xp": 140, "col": "#2f3a5a", "story": 1, "alarm": true},
	"museu": {"name": "Museu da Cidade", "lvl": 5, "cd": 480, "stars": 4, "xp": 200, "col": "#c9b98f", "alarm": true},
	"banco": {"name": "Banco de Vila Rubra", "lvl": 6, "cd": 600, "stars": 5, "xp": 350, "col": "#5a6068", "story": 2, "alarm": true},
}

const TERRS := {
	"t_docas": {"name": "Docas", "lvl": 2, "gang": 4, "income": 600, "col": "#5b4a7a"},
	"t_velho": {"name": "Bairro Velho", "lvl": 4, "gang": 6, "income": 1400, "col": "#7a4a4a"},
	"t_ind": {"name": "Zona Industrial", "lvl": 6, "gang": 9, "income": 3000, "col": "#4a6a7a"},
}

const SHOPS := {
	"home": {"name": "Esconderijo", "col": "#5a5f48", "lvl": 1},
	"bar": {"name": "Bar O Farol", "col": "#2f6d5c", "lvl": 1},
	"armeiro": {"name": "Armeiro do Lima", "col": "#5d5862", "lvl": 1},
	"stand": {"name": "Stand Rodas Livres", "col": "#a8742c", "lvl": 1},
	"imob": {"name": "Imobiliária Chave d'Ouro", "col": "#7c6a3a", "lvl": 1},
}

const BPAL := ["#6b6f7a", "#7a6a5a", "#5d6b78", "#8a7f6a", "#6a5a6e", "#5f7466", "#857066", "#6e7580", "#9a8b74", "#71808a"]

## mapa da região (posições em %)
const REGION := [
	{"id": "home", "name": "Esconderijo", "x": 20, "y": 64, "desc": "Cofre, descanso e oficina."},
	{"id": "bar", "name": "Bar O Farol", "x": 44, "y": 82, "desc": "Zé Faísca: história e contratos."},
	{"id": "city", "name": "Vila Rubra", "x": 72, "y": 36, "desc": "Assaltos, lojas, carrinhas e territórios."},
]

## célula da grelha de ruas da cidade -> ponto de interesse
const CITY_CELLS := {
	"2,1": "cafe", "1,2": "hotel", "2,2": "museu", "4,1": "bomba", "1,3": "armeiro",
	"5,1": "stand", "4,2": "imob", "2,3": "t_velho", "5,3": "t_docas", "5,2": "t_ind",
	"1,1": "joalharia", "4,3": "farmacia", "6,1": "garrafeira", "6,2": "banco",
}

const DISTRICTS := [
	{"name": "CENTRO", "x": 95, "y": 62}, {"name": "BAIRRO VELHO", "x": 95, "y": 192},
	{"name": "ZONA INDUSTRIAL", "x": 330, "y": 62}, {"name": "DOCAS", "x": 330, "y": 192},
]

const ICONS := {
	"cafe": ["C", "#e0483e"], "bomba": ["B", "#e0483e"], "hotel": ["H", "#e0483e"], "museu": ["M", "#e0483e"],
	"farmacia": ["F", "#e0483e"], "garrafeira": ["G", "#e0483e"], "joalharia": ["J", "#e0483e"], "banco": ["$", "#e0483e"],
	"armeiro": ["A", "#e8b931"], "stand": ["S", "#e8b931"], "imob": ["I", "#e8b931"],
	"t_docas": ["T", "#9a6ad0"], "t_velho": ["T", "#9a6ad0"], "t_ind": ["T", "#9a6ad0"],
	"van": ["V", "#3cc48a"],
}

## carrinhas de receptação: sítios possíveis [x, rua (y), lado] e tipos
const VAN_SPOTS := [[60.0, 95.0, -1.0], [130.0, 160.0, 1.0], [285.0, 95.0, 1.0], [350.0, 160.0, -1.0], [120.0, 225.0, 1.0], [300.0, 225.0, 1.0], [60.0, 30.0, 1.0], [340.0, 30.0, 1.0]]
const VAN_TYPES := [
	{"name": "Tó Ferrugem", "cat": "eletronica", "col": "#4a5a6a"},
	{"name": "Dona Aurora", "cat": "joias", "col": "#6a4a5a"},
	{"name": "O Mudo", "cat": "bebidas", "col": "#4a6a4a"},
	{"name": "O Antiquário", "cat": "arte", "col": "#6a5a3a"},
]

## história do Zé Faísca (Bar O Farol)
const STORY := [
	{"t": "A fotografia", "txt": "«Há uma fotografia antiga no cofre dos hóspedes do Hotel Atlântida. Traz-ma.»", "item": "foto", "pay": 0, "cash": 50000, "reward": "Joalharia Aurora + kit de gazuas"},
	{"t": "A dívida", "txt": "«A foto confirmou tudo. Quem sabe o resto quer um milhão. Paga e abrimos o banco.»", "item": "", "pay": 1000000, "cash": 0, "reward": "Banco de Vila Rubra + Mochila de expedição"},
	{"t": "O livro de contas", "txt": "«O cofre principal do banco guarda um livro de contas. Com ele, Vila Rubra é nossa.»", "item": "livro", "pay": 0, "cash": 250000, "reward": "Contratos de elite (a dobrar)"},
]

## interiores. back = parede dos fundos (y), bdoor = x da porta trancada, counter = [x0, x1, y]
## conts: kind = caixa | cofre | vitrine | armario | armario_p | estante | frigo | secretaria | quadros | maquina
const INTERIORS := {
	"cafe": {"w": 16.0, "d": 12.0, "wall": "#e8dcc6", "stripe": "#7a4a2a", "floor": "#6a4f3a", "back": 3.2, "bdoor": 13.0,
		"counter": [2.0, 10.2, 5.0], "clerk": [6.0, 4.1], "cams": [[0.6, 3.8], [15.4, 11.4]],
		"conts": [
			{"n": "Caixa registadora", "kind": "caixa", "x": 8.8, "y": 5.0, "w": 1.0, "h": 0.9, "time": 3.0, "loot": [{"cash": [800, 2200]}]},
			{"n": "Montra de bolos", "kind": "vitrine", "x": 11.6, "y": 5.0, "w": 2.0, "h": 1.0, "time": 2.5, "loot": [{"id": "bolo", "ch": 0.9, "q": [1, 2]}, {"id": "licor", "ch": 0.6, "q": [1, 2]}]},
			{"n": "Cacifos do pessoal", "kind": "armario", "x": 1.0, "y": 0.3, "w": 1.7, "h": 0.85, "time": 4.0, "loot": [{"id": "telemovel", "ch": 0.8, "q": [1, 2]}, {"id": "tablet", "ch": 0.4, "q": [1, 1]}]},
			{"n": "Máquina de café", "kind": "maquina", "x": 5.0, "y": 0.3, "w": 1.2, "h": 0.8, "time": 5.0, "loot": [{"id": "maquina_cafe", "ch": 1.0, "q": [1, 1]}]},
			{"n": "Cofre do gerente", "kind": "cofre", "x": 9.0, "y": 0.3, "w": 1.2, "h": 1.0, "time": 8.0, "loot": [{"cash": [6000, 14000]}]},
		],
		"decor": [["rest/table_round_A_decorated", 3.5, 9.0, 0.0, 0.5, 0.0], ["rest/table_round_A_decorated", 8.0, 9.6, 0.0, 0.5, 0.0], ["rest/table_round_A_decorated", 12.6, 9.0, 0.0, 0.5, 0.0], ["furn/cactus_medium_A", 15.0, 6.6, 0.0, 0.82, 0.0], ["furn/lamp_standing", 0.9, 11.0, 0.0, 0.82, 0.0], ["rest/menu", 4.0, 5.3, 0.0, 0.82, 0.85]],
		"blocks": [[2.75, 8.25, 1.5, 1.5, 0.8], [7.25, 8.85, 1.5, 1.5, 0.8], [11.85, 8.25, 1.5, 1.5, 0.8]], "shelves": []},
	"bomba": {"w": 14.0, "d": 10.0, "wall": "#e3e6e8", "stripe": "#b23b2e", "floor": "#84878a", "back": 2.8, "bdoor": 11.5,
		"counter": [1.5, 6.5, 4.6], "clerk": [4.0, 3.7], "cams": [[13.4, 3.4], [0.6, 9.4]],
		"conts": [
			{"n": "Caixa registadora", "kind": "caixa", "x": 5.2, "y": 4.6, "w": 1.0, "h": 0.9, "time": 3.0, "loot": [{"cash": [1500, 3800]}]},
			{"n": "Expositor de tabaco", "kind": "estante", "st": "caixas", "x": 1.5, "y": 2.95, "w": 3.0, "h": 0.5, "time": 4.0, "loot": [{"id": "tabaco", "ch": 0.95, "q": [2, 5]}, {"id": "raspadinhas", "ch": 0.7, "q": [2, 6]}]},
			{"n": "Arca das bebidas", "kind": "frigo", "x": 11.9, "y": 5.6, "w": 1.7, "h": 1.9, "time": 3.0, "loot": [{"id": "energeticas", "ch": 1.0, "q": [2, 6]}]},
			{"n": "Armário de ferramentas", "kind": "armario", "x": 1.0, "y": 0.3, "w": 1.7, "h": 0.85, "time": 4.0, "loot": [{"id": "bateria", "ch": 0.6, "q": [1, 1]}, {"id": "ferramentas", "ch": 0.7, "q": [1, 1]}]},
			{"n": "Cofre", "kind": "cofre", "x": 7.0, "y": 0.3, "w": 1.2, "h": 1.0, "time": 8.0, "loot": [{"cash": [5000, 12000]}]},
		],
		"decor": [["furn/cactus_medium_A", 13.2, 9.2, 0.0, 0.7, 0.0]],
		"blocks": [], "shelves": [[8.0, 5.2, 0.6, 3.2, "caixas"], [9.9, 5.2, 0.6, 3.2, "caixas"]]},
	"farmacia": {"w": 14.0, "d": 10.0, "wall": "#eef3f0", "stripe": "#3f9a6a", "floor": "#c9d2cd", "back": 2.8, "bdoor": 2.5,
		"counter": [4.5, 12.5, 4.6], "clerk": [8.5, 3.7], "cams": [[0.6, 3.4], [13.4, 9.4]],
		"conts": [
			{"n": "Caixa registadora", "kind": "caixa", "x": 11.0, "y": 4.6, "w": 1.0, "h": 0.9, "time": 3.0, "loot": [{"cash": [1200, 3000]}]},
			{"n": "Prateleira de medicamentos", "kind": "estante", "st": "caixas", "x": 5.5, "y": 2.95, "w": 4.0, "h": 0.5, "time": 4.0, "loot": [{"id": "medicamentos", "ch": 1.0, "q": [2, 4]}, {"id": "kit_medico", "ch": 0.5, "q": [1, 1]}]},
			{"n": "Armário de controlados", "kind": "armario", "x": 6.0, "y": 0.3, "w": 1.7, "h": 0.85, "time": 5.0, "loot": [{"id": "analgesicos", "ch": 1.0, "q": [2, 5]}]},
			{"n": "Cofre", "kind": "cofre", "x": 11.5, "y": 0.3, "w": 1.2, "h": 1.0, "time": 8.0, "loot": [{"cash": [4000, 9000]}]},
		],
		"decor": [["furn/cactus_medium_A", 0.9, 9.2, 0.0, 0.7, 0.0], ["furn/chair_A", 13.0, 7.0, -1.57, 0.82, 0.0]],
		"blocks": [], "shelves": [[1.6, 5.6, 0.6, 3.0, "caixas"], [4.6, 6.6, 2.8, 0.6, "caixas"], [9.0, 6.6, 2.8, 0.6, "caixas"]]},
	"garrafeira": {"w": 14.0, "d": 11.0, "wall": "#eadfd2", "stripe": "#6a2a3a", "floor": "#5b4636", "back": 3.0, "bdoor": 11.5,
		"counter": [8.6, 12.6, 5.0], "clerk": [10.5, 4.1], "cams": [[0.6, 3.6], [13.4, 10.4]],
		"conts": [
			{"n": "Caixa registadora", "kind": "caixa", "x": 11.3, "y": 5.0, "w": 1.0, "h": 0.9, "time": 3.0, "loot": [{"cash": [1500, 3500]}]},
			{"n": "Vinhos do Porto", "kind": "estante", "st": "garrafas", "x": 0.3, "y": 4.2, "w": 0.6, "h": 5.0, "time": 4.0, "loot": [{"id": "vinho", "ch": 1.0, "q": [1, 3]}, {"id": "licor", "ch": 0.7, "q": [1, 3]}]},
			{"n": "Whiskies", "kind": "estante", "st": "garrafas", "x": 3.0, "y": 6.2, "w": 2.8, "h": 0.6, "time": 4.0, "loot": [{"id": "whisky", "ch": 1.0, "q": [1, 3]}]},
			{"n": "Champanhes", "kind": "estante", "st": "garrafas", "x": 3.0, "y": 8.8, "w": 2.8, "h": 0.6, "time": 4.0, "loot": [{"id": "champanhe", "ch": 1.0, "q": [1, 3]}]},
			{"n": "Reserva privada", "kind": "armario", "x": 1.0, "y": 0.3, "w": 1.7, "h": 0.85, "time": 5.0, "loot": [{"id": "vinho", "ch": 1.0, "q": [2, 4]}, {"id": "whisky", "ch": 0.8, "q": [1, 2]}]},
			{"n": "Cofre", "kind": "cofre", "x": 7.0, "y": 0.3, "w": 1.2, "h": 1.0, "time": 8.0, "loot": [{"cash": [5000, 11000]}]},
		],
		"decor": [["rest/crate", 7.6, 9.6, 0.3, 0.5, 0.0], ["rest/jar_A_large", 9.2, 5.3, 0.0, 0.82, 0.85]],
		"blocks": [[7.1, 9.1, 1.0, 1.0, 0.4]], "shelves": []},
	"hotel": {"w": 22.0, "d": 14.0, "wall": "#efe6d4", "stripe": "#3d5f8a", "floor": "#6e3434", "back": 3.2, "bdoor": 3.0,
		"counter": [7.0, 15.2, 5.2], "clerk": [11.0, 4.3], "cams": [[0.6, 3.8], [21.4, 3.8], [21.4, 13.4]],
		"conts": [
			{"n": "Caixa da receção", "kind": "caixa", "x": 13.6, "y": 5.2, "w": 1.0, "h": 0.9, "time": 3.5, "loot": [{"cash": [4000, 9000]}]},
			{"n": "Mini-bar", "kind": "frigo", "x": 19.9, "y": 6.4, "w": 1.7, "h": 1.9, "time": 3.0, "loot": [{"id": "champanhe", "ch": 0.9, "q": [1, 3]}, {"id": "whisky", "ch": 0.5, "q": [1, 1]}]},
			{"n": "Bagagem", "kind": "armario_p", "x": 16.0, "y": 10.6, "w": 0.9, "h": 0.9, "time": 4.0, "loot": [{"id": "mala", "ch": 0.8, "q": [1, 1]}, {"id": "portatil", "ch": 0.6, "q": [1, 1]}]},
			{"n": "Secretária do gerente", "kind": "secretaria", "x": 1.2, "y": 9.4, "w": 1.64, "h": 1.64, "time": 5.0, "loot": [{"id": "portatil", "ch": 0.8, "q": [1, 1]}, {"id": "tablet", "ch": 0.6, "q": [1, 1]}, {"id": "telemovel", "ch": 0.6, "q": [1, 2]}]},
			{"n": "Cofre dos hóspedes", "kind": "cofre", "x": 10.0, "y": 0.3, "w": 1.2, "h": 1.0, "time": 9.0, "loot": [{"id": "relogio", "ch": 0.9, "q": [1, 2]}, {"id": "colar", "ch": 0.6, "q": [1, 1]}, {"cash": [5000, 15000]}, {"story_item": "foto", "chapter": 0}]},
			{"n": "Arquivo", "kind": "armario", "x": 16.0, "y": 0.3, "w": 1.7, "h": 0.85, "time": 4.0, "loot": [{"id": "telemovel", "ch": 0.7, "q": [1, 2]}, {"cash": [1000, 3000]}]},
		],
		"decor": [["furn/couch", 5.0, 10.8, 3.14, 0.82, 0.0], ["furn/armchair", 9.4, 10.8, 3.14, 0.82, 0.0], ["furn/rug_rectangle_A", 7.0, 12.4, 0.0, 1.2, 0.0], ["furn/lamp_standing", 20.8, 13.0, 0.0, 0.82, 0.0], ["furn/cactus_medium_A", 0.9, 13.0, 0.0, 0.82, 0.0], ["furn/book_set", 2.0, 10.0, 0.3, 0.82, 0.85]],
		"blocks": [[3.8, 10.2, 2.5, 1.3, 0.9], [8.7, 10.2, 1.5, 1.3, 0.9]], "shelves": []},
	"joalharia": {"w": 16.0, "d": 11.0, "wall": "#eceef2", "stripe": "#2f3a5a", "floor": "#3a3f4c", "back": 3.0, "bdoor": 13.5,
		"counter": [3.0, 9.0, 5.0], "clerk": [6.0, 4.1], "cams": [[0.6, 3.6], [15.4, 3.6], [8.0, 10.5]],
		"conts": [
			{"n": "Vitrine dos anéis", "kind": "vitrine", "x": 2.6, "y": 7.6, "w": 2.0, "h": 1.0, "time": 5.0, "loot": [{"id": "anel", "ch": 1.0, "q": [1, 3]}]},
			{"n": "Vitrine dos relógios", "kind": "vitrine", "x": 7.0, "y": 7.6, "w": 2.0, "h": 1.0, "time": 5.0, "loot": [{"id": "relogio", "ch": 1.0, "q": [1, 3]}]},
			{"n": "Vitrine dos colares", "kind": "vitrine", "x": 11.4, "y": 7.6, "w": 2.0, "h": 1.0, "time": 5.0, "loot": [{"id": "colar", "ch": 1.0, "q": [1, 2]}, {"id": "brincos", "ch": 0.8, "q": [1, 3]}]},
			{"n": "Caixa registadora", "kind": "caixa", "x": 7.8, "y": 5.0, "w": 1.0, "h": 0.9, "time": 3.0, "loot": [{"cash": [3000, 8000]}]},
			{"n": "Cofre da joalharia", "kind": "cofre", "x": 2.0, "y": 0.3, "w": 1.2, "h": 1.0, "time": 10.0, "loot": [{"id": "lingote", "ch": 1.0, "q": [1, 3]}, {"id": "anel", "ch": 0.8, "q": [1, 2]}, {"cash": [10000, 30000]}]},
		],
		"decor": [["furn/rug_rectangle_A", 8.0, 9.6, 0.0, 1.4, 0.0], ["furn/lamp_standing", 15.0, 10.0, 0.0, 0.82, 0.0], ["furn/cactus_medium_A", 0.9, 10.0, 0.0, 0.82, 0.0]],
		"blocks": [], "shelves": []},
	"museu": {"w": 28.0, "d": 18.0, "wall": "#f1efe8", "stripe": "#8a7a52", "floor": "#c7c2b5", "back": 3.4, "bdoor": 24.0,
		"counter": [2.0, 6.0, 14.6], "clerk": [4.0, 13.7], "cams": [[0.6, 4.0], [27.4, 4.0], [0.6, 17.4], [27.4, 17.4]],
		"conts": [
			{"n": "Vitrine das moedas", "kind": "vitrine", "x": 5.0, "y": 8.0, "w": 2.0, "h": 1.2, "time": 5.0, "loot": [{"id": "moeda", "ch": 1.0, "q": [1, 3]}]},
			{"n": "Vitrine das estatuetas", "kind": "vitrine", "x": 13.0, "y": 8.0, "w": 2.0, "h": 1.2, "time": 6.0, "loot": [{"id": "estatueta", "ch": 1.0, "q": [1, 1]}]},
			{"n": "Vitrine dos vasos", "kind": "vitrine", "x": 21.0, "y": 8.0, "w": 2.0, "h": 1.2, "time": 6.0, "loot": [{"id": "vaso", "ch": 1.0, "q": [1, 1]}]},
			{"n": "Galeria de pintura", "kind": "quadros", "x": 8.0, "y": 3.55, "w": 10.0, "h": 0.3, "time": 9.0, "loot": [{"id": "pintura", "ch": 1.0, "q": [1, 2]}]},
			{"n": "Bilheteira", "kind": "caixa", "x": 4.6, "y": 14.6, "w": 1.0, "h": 0.9, "time": 3.0, "loot": [{"cash": [2000, 5000]}]},
			{"n": "Cofre do curador", "kind": "cofre", "x": 4.0, "y": 0.3, "w": 1.2, "h": 1.0, "time": 10.0, "loot": [{"cash": [30000, 80000]}, {"id": "moeda", "ch": 0.8, "q": [1, 2]}]},
		],
		"decor": [["rest/pillar_A", 9.5, 12.0, 0.0, 0.82, 0.0], ["rest/pillar_A", 18.5, 12.0, 0.0, 0.82, 0.0], ["furn/couch", 14.0, 14.5, 0.0, 0.82, 0.0], ["furn/rug_rectangle_A", 14.0, 11.5, 0.0, 1.6, 0.0]],
		"blocks": [[9.2, 11.7, 0.6, 0.6, 3.4], [18.2, 11.7, 0.6, 0.6, 3.4], [12.8, 13.9, 2.5, 1.3, 0.9]], "shelves": []},
	"banco": {"w": 24.0, "d": 16.0, "wall": "#e6e8ea", "stripe": "#5a6068", "floor": "#9aa0a6", "back": 4.0, "bdoor": 12.0,
		"counter": [5.0, 19.0, 6.4], "clerk": [12.0, 5.4], "cams": [[0.6, 4.6], [23.4, 4.6], [0.6, 15.4], [23.4, 15.4]],
		"conts": [
			{"n": "Caixa 1", "kind": "caixa", "x": 7.0, "y": 6.4, "w": 1.0, "h": 0.9, "time": 4.0, "loot": [{"cash": [15000, 30000]}]},
			{"n": "Caixa 2", "kind": "caixa", "x": 16.0, "y": 6.4, "w": 1.0, "h": 0.9, "time": 4.0, "loot": [{"cash": [15000, 30000]}]},
			{"n": "Gabinete do gerente", "kind": "secretaria", "x": 1.2, "y": 10.5, "w": 1.64, "h": 1.64, "time": 5.0, "loot": [{"id": "portatil", "ch": 0.9, "q": [1, 1]}, {"cash": [5000, 10000]}]},
			{"n": "Cofre principal", "kind": "cofre", "x": 4.0, "y": 0.3, "w": 2.4, "h": 1.2, "time": 14.0, "loot": [{"cash": [150000, 300000]}, {"id": "lingote", "ch": 1.0, "q": [2, 5]}, {"story_item": "livro", "chapter": 2}]},
			{"n": "Cofres de aluguer", "kind": "cofre", "x": 16.0, "y": 0.3, "w": 2.4, "h": 1.2, "time": 12.0, "loot": [{"id": "relogio", "ch": 0.9, "q": [1, 3]}, {"id": "colar", "ch": 0.8, "q": [1, 2]}, {"id": "anel", "ch": 0.8, "q": [1, 3]}]},
		],
		"decor": [["furn/couch", 6.0, 13.0, 3.14, 0.82, 0.0], ["furn/couch", 17.0, 13.0, 3.14, 0.82, 0.0], ["furn/rug_rectangle_A", 12.0, 12.0, 0.0, 1.8, 0.0], ["furn/cactus_medium_A", 0.9, 15.0, 0.0, 0.82, 0.0], ["furn/cactus_medium_A", 23.0, 15.0, 0.0, 0.82, 0.0]],
		"blocks": [[4.8, 12.4, 2.5, 1.3, 0.9], [15.8, 12.4, 2.5, 1.3, 0.9]], "shelves": []},
}
