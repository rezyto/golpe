extends RefCounted
## Dados do jogo (conteúdo original de GOLPE / Vila Rubra). Unidades em metros e m/s.

const WEAPONS := [
	{"id": "p22", "name": "Pistola Rato .22", "price": 0, "dmg": 10, "rate": 0.45, "range": 18.0, "pel": 1, "spr": 0.04, "lvl": 1},
	{"id": "p9", "name": "Pistola Vigia 9mm", "price": 1500, "dmg": 16, "rate": 0.35, "range": 21.0, "pel": 1, "spr": 0.03, "lvl": 2},
	{"id": "smg", "name": "SMG Vespa", "price": 6000, "dmg": 9, "rate": 0.11, "range": 20.0, "pel": 1, "spr": 0.09, "lvl": 3},
	{"id": "sg", "name": "Caçadeira Tróia", "price": 9000, "dmg": 9, "rate": 0.8, "range": 13.5, "pel": 6, "spr": 0.25, "lvl": 4},
	{"id": "rf", "name": "Espingarda Falcão", "price": 20000, "dmg": 45, "rate": 0.9, "range": 32.0, "pel": 1, "spr": 0.01, "lvl": 6},
]

const CARS := [
	{"id": "pardal", "name": "Pardal", "price": 0, "spd": 20.0, "hp": 100, "col": "#d9a441", "lvl": 1, "d": "Pequeno e fiável"},
	{"id": "mula", "name": "Furgão Mula", "price": 4000, "spd": 18.0, "hp": 190, "col": "#7d8a96", "lvl": 2, "d": "Lento mas aguenta pancada"},
	{"id": "lince", "name": "Lince GT", "price": 12000, "spd": 27.0, "hp": 120, "col": "#c0392b", "lvl": 4, "d": "O mais rápido da cidade"},
	{"id": "touro", "name": "Touro 4x4", "price": 25000, "spd": 23.5, "hp": 280, "col": "#2e6b4f", "lvl": 6, "d": "Rápido e blindado"},
]

const BAGS := [
	{"id": "b10", "name": "Mochila", "price": 0, "cap": 10, "lvl": 1},
	{"id": "b20", "name": "Saco desportivo", "price": 1200, "cap": 20, "lvl": 1},
	{"id": "b35", "name": "Mala de viagem", "price": 5000, "cap": 35, "lvl": 3},
	{"id": "b60", "name": "Saco de lona XL", "price": 15000, "cap": 60, "lvl": 5},
]

const PROPS := [
	{"id": "quiosque", "name": "Quiosque da Praça", "price": 3000, "rent": 40, "lvl": 1},
	{"id": "t1", "name": "Apartamento T1", "price": 10000, "rent": 150, "lvl": 2},
	{"id": "loja", "name": "Loja de rua", "price": 25000, "rent": 400, "lvl": 4},
	{"id": "predio", "name": "Prédio inteiro", "price": 80000, "rent": 1400, "lvl": 6},
]

const HEISTS := {
	"cafe": {"name": "Café Central", "lvl": 1, "time": 6.0, "cd": 120, "stars": 1, "xp": 25, "col": "#8a5a34", "alarm": 0.2, "cash": [80, 200],
		"loot": [{"n": "Máquina de café", "kg": 6.0, "v": 250, "ch": 0.45, "q": [1, 1]}, {"n": "Garrafa de licor", "kg": 1.0, "v": 60, "ch": 0.8, "q": [1, 3]}, {"n": "Telemóvel do balcão", "kg": 0.3, "v": 120, "ch": 0.4, "q": [1, 1]}]},
	"bomba": {"name": "Bomba Estrela", "lvl": 1, "time": 8.0, "cd": 180, "stars": 2, "xp": 40, "col": "#b23b2e", "alarm": 0.35, "cash": [150, 350],
		"loot": [{"n": "Maço de tabaco", "kg": 0.2, "v": 35, "ch": 0.9, "q": [3, 8]}, {"n": "Bateria de carro", "kg": 8.0, "v": 180, "ch": 0.4, "q": [1, 1]}, {"n": "Raspadinhas", "kg": 0.1, "v": 50, "ch": 0.6, "q": [2, 6]}]},
	"hotel": {"name": "Hotel Atlântida", "lvl": 3, "time": 12.0, "cd": 300, "stars": 3, "xp": 90, "col": "#3d5f8a", "alarm": 0.5, "cash": [400, 900],
		"loot": [{"n": "Relógio de pulso", "kg": 0.3, "v": 600, "ch": 0.7, "q": [1, 2]}, {"n": "Portátil", "kg": 2.0, "v": 900, "ch": 0.6, "q": [1, 1]}, {"n": "Joias", "kg": 0.2, "v": 1200, "ch": 0.45, "q": [1, 1]}, {"n": "Garrafa de champanhe", "kg": 1.5, "v": 200, "ch": 0.6, "q": [1, 3]}]},
	"museu": {"name": "Museu da Cidade", "lvl": 5, "time": 18.0, "cd": 480, "stars": 4, "xp": 200, "col": "#c9b98f", "alarm": 0.8, "cash": [0, 0],
		"loot": [{"n": "Estatueta de bronze", "kg": 7.0, "v": 3500, "ch": 0.6, "q": [1, 1]}, {"n": "Pintura antiga", "kg": 4.0, "v": 6000, "ch": 0.5, "q": [1, 1]}, {"n": "Vaso cerâmico", "kg": 5.0, "v": 2500, "ch": 0.6, "q": [1, 1]}, {"n": "Moeda rara", "kg": 0.1, "v": 1500, "ch": 0.8, "q": [1, 3]}]},
}

const TERRS := {
	"t_docas": {"name": "Docas", "lvl": 2, "gang": 4, "income": 60, "col": "#5b4a7a"},
	"t_velho": {"name": "Bairro Velho", "lvl": 4, "gang": 6, "income": 140, "col": "#7a4a4a"},
	"t_ind": {"name": "Zona Industrial", "lvl": 6, "gang": 9, "income": 300, "col": "#4a6a7a"},
}

const SHOPS := {
	"home": {"name": "Esconderijo", "col": "#5a5f48", "lvl": 1},
	"bar": {"name": "Bar O Farol", "col": "#2f6d5c", "lvl": 1},
	"armeiro": {"name": "Armeiro do Lima", "col": "#5d5862", "lvl": 1},
	"stand": {"name": "Stand Rodas Livres", "col": "#a8742c", "lvl": 1},
	"imob": {"name": "Imobiliária Chave d'Ouro", "col": "#7c6a3a", "lvl": 1},
}

## posição no mapa da cidade, em % do ecrã
const MAPNODES := [
	{"id": "home", "x": 12, "y": 50}, {"id": "bar", "x": 26, "y": 80}, {"id": "cafe", "x": 30, "y": 26},
	{"id": "armeiro", "x": 44, "y": 63}, {"id": "bomba", "x": 52, "y": 16}, {"id": "stand", "x": 62, "y": 84},
	{"id": "hotel", "x": 66, "y": 44}, {"id": "imob", "x": 80, "y": 20}, {"id": "museu", "x": 88, "y": 60},
	{"id": "t_docas", "x": 13, "y": 14}, {"id": "t_velho", "x": 43, "y": 38}, {"id": "t_ind", "x": 86, "y": 87},
]

const BPAL := ["#6b6f7a", "#7a6a5a", "#5d6b78", "#8a7f6a", "#6a5a6e", "#5f7466", "#857066", "#6e7580", "#9a8b74", "#71808a"]
