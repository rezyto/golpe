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
	{"id": "pardal", "name": "Pardal", "price": 0, "spd": 20.0, "hp": 100, "col": "#d9a441", "model": "car_hatchback", "lvl": 1, "d": "Pequeno e fiável"},
	{"id": "mula", "name": "Furgão Mula", "price": 4000, "spd": 18.0, "hp": 190, "col": "#7d8a96", "model": "car_stationwagon", "lvl": 2, "d": "Lento mas aguenta pancada"},
	{"id": "lince", "name": "Lince GT", "price": 12000, "spd": 27.0, "hp": 120, "col": "#c0392b", "model": "car_sedan", "lvl": 4, "d": "O mais rápido da cidade"},
	{"id": "touro", "name": "Touro 4x4", "price": 25000, "spd": 23.5, "hp": 280, "col": "#2e6b4f", "model": "car_taxi", "lvl": 6, "d": "Rápido e blindado"},
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

## ---------------------------------------------------------------------------
## v0.3 — cidade única, região e interiores (conteúdo original)
## ---------------------------------------------------------------------------

## mapa da região: onde se escolhe para onde ir (posições em %)
const REGION := [
	{"id": "home", "name": "Esconderijo", "x": 20, "y": 64, "desc": "A tua casa. Descansa, repara o carro e recolhe as rendas."},
	{"id": "bar", "name": "Bar O Farol", "x": 44, "y": 82, "desc": "O Zé Faísca compra o teu saque sem perguntas e tem sempre contratos."},
	{"id": "city", "name": "Vila Rubra", "x": 72, "y": 36, "desc": "A cidade. Assaltos, lojas, territórios… e polícia."},
]

## célula da grelha de ruas da cidade -> ponto de interesse
const CITY_CELLS := {
	"2,1": "cafe", "1,2": "hotel", "2,2": "museu", "4,1": "bomba", "1,3": "armeiro",
	"5,1": "stand", "4,2": "imob", "2,3": "t_velho", "5,3": "t_docas", "5,2": "t_ind",
}

const DISTRICTS := [
	{"name": "CENTRO", "x": 95, "y": 62}, {"name": "BAIRRO VELHO", "x": 95, "y": 192},
	{"name": "ZONA INDUSTRIAL", "x": 330, "y": 62}, {"name": "DOCAS", "x": 330, "y": 192},
]

## letra e cor de cada ícone nos mapas
const ICONS := {
	"cafe": ["C", "#e0483e"], "bomba": ["B", "#e0483e"], "hotel": ["H", "#e0483e"], "museu": ["M", "#e0483e"],
	"armeiro": ["A", "#e8b931"], "stand": ["S", "#e8b931"], "imob": ["I", "#e8b931"],
	"t_docas": ["T", "#9a6ad0"], "t_velho": ["T", "#9a6ad0"], "t_ind": ["T", "#9a6ad0"],
}

## interiores: tamanho, cores, contentores para vasculhar (loot), adereços e refém
const INTERIORS := {
	"cafe": {"w": 16.0, "d": 12.0, "wall": "#e2d6c2", "stripe": "#7a4a2a", "floor": "#5a4535", "hostage": [5.0, 1.2],
		"conts": [
			{"n": "Caixa registadora", "x": 3.0, "y": 2.2, "w": 1.6, "h": 0.8, "hh": 1.2, "time": 3.0, "col": "#2b2b2b", "alarm": false, "loot": [{"cash": [80, 220]}]},
			{"n": "Montra de bolos", "x": 6.5, "y": 2.2, "w": 3.0, "h": 0.8, "hh": 1.2, "time": 2.5, "col": "#c9d6dc", "alarm": false, "loot": [{"n": "Bolo de aniversário", "kg": 1.0, "v": 40, "ch": 0.8, "q": [1, 2]}, {"n": "Garrafa de licor", "kg": 1.0, "v": 60, "ch": 0.7, "q": [1, 3]}]},
			{"n": "Armário do pessoal", "x": 13.2, "y": 0.3, "w": 2.2, "h": 0.7, "hh": 2.1, "time": 4.0, "col": "#8a6a4a", "alarm": false, "loot": [{"n": "Telemóvel do balcão", "kg": 0.3, "v": 120, "ch": 0.8, "q": [1, 1]}, {"n": "Tablet das encomendas", "kg": 0.6, "v": 300, "ch": 0.5, "q": [1, 1]}]},
			{"n": "Máquina de café", "x": 0.4, "y": 0.3, "w": 1.4, "h": 0.8, "hh": 1.5, "time": 5.0, "col": "#9aa0a6", "alarm": false, "loot": [{"n": "Máquina de café", "kg": 6.0, "v": 250, "ch": 1.0, "q": [1, 1]}]},
		],
		"props": [
			{"x": 2.5, "y": 3.0, "w": 8.5, "h": 0.6, "hh": 1.0, "col": "#6b4a32"},
			{"x": 3.0, "y": 7.0, "w": 1.4, "h": 1.4, "hh": 0.75, "col": "#8a6a4a"},
			{"x": 7.0, "y": 7.6, "w": 1.4, "h": 1.4, "hh": 0.75, "col": "#8a6a4a"},
			{"x": 11.0, "y": 6.6, "w": 1.4, "h": 1.4, "hh": 0.75, "col": "#8a6a4a"},
		]},
	"bomba": {"w": 14.0, "d": 10.0, "wall": "#dfe3e6", "stripe": "#b23b2e", "floor": "#7a7d80", "hostage": [3.2, 1.4],
		"conts": [
			{"n": "Caixa registadora", "x": 2.0, "y": 2.0, "w": 1.6, "h": 0.8, "hh": 1.2, "time": 3.0, "col": "#2b2b2b", "alarm": true, "loot": [{"cash": [150, 380]}]},
			{"n": "Prateleira de tabaco", "x": 0.3, "y": 0.3, "w": 4.0, "h": 0.6, "hh": 2.2, "time": 4.0, "col": "#a33a2c", "alarm": false, "loot": [{"n": "Maço de tabaco", "kg": 0.2, "v": 35, "ch": 0.95, "q": [3, 8]}, {"n": "Raspadinhas", "kg": 0.1, "v": 50, "ch": 0.6, "q": [2, 6]}]},
			{"n": "Armário de ferramentas", "x": 10.5, "y": 0.3, "w": 3.0, "h": 0.7, "hh": 1.1, "time": 4.0, "col": "#b8452f", "alarm": false, "loot": [{"n": "Bateria de carro", "kg": 8.0, "v": 180, "ch": 0.6, "q": [1, 1]}, {"n": "Caixa de ferramentas", "kg": 4.0, "v": 220, "ch": 0.6, "q": [1, 1]}]},
			{"n": "Arca frigorífica", "x": 10.8, "y": 5.0, "w": 2.6, "h": 1.2, "hh": 1.0, "time": 3.0, "col": "#e9eef2", "alarm": false, "loot": [{"n": "Bebidas energéticas", "kg": 0.5, "v": 15, "ch": 0.9, "q": [2, 6]}]},
		],
		"props": [
			{"x": 1.5, "y": 2.8, "w": 4.5, "h": 0.6, "hh": 1.0, "col": "#5d6066"},
			{"x": 5.2, "y": 5.0, "w": 0.6, "h": 3.0, "hh": 1.8, "col": "#8a8f96"},
			{"x": 7.6, "y": 5.0, "w": 0.6, "h": 3.0, "hh": 1.8, "col": "#8a8f96"},
		]},
	"hotel": {"w": 22.0, "d": 14.0, "wall": "#efe6d4", "stripe": "#3d5f8a", "floor": "#6e3434", "hostage": [10.5, 1.0],
		"conts": [
			{"n": "Balcão da receção", "x": 8.0, "y": 2.0, "w": 5.0, "h": 0.9, "hh": 1.2, "time": 4.0, "col": "#5a3a24", "alarm": true, "loot": [{"cash": [400, 900]}]},
			{"n": "Cofre dos hóspedes", "x": 0.3, "y": 0.3, "w": 1.4, "h": 1.0, "hh": 1.6, "time": 8.0, "col": "#4a4f57", "alarm": true, "loot": [{"n": "Joias", "kg": 0.2, "v": 1200, "ch": 0.7, "q": [1, 2]}, {"n": "Relógio de pulso", "kg": 0.3, "v": 600, "ch": 0.8, "q": [1, 2]}]},
			{"n": "Mini-bar", "x": 20.3, "y": 6.0, "w": 1.4, "h": 1.0, "hh": 1.0, "time": 3.0, "col": "#2d2d33", "alarm": false, "loot": [{"n": "Garrafa de champanhe", "kg": 1.5, "v": 200, "ch": 0.9, "q": [1, 3]}]},
			{"n": "Carrinho da bagagem", "x": 16.0, "y": 10.0, "w": 2.2, "h": 1.2, "hh": 1.4, "time": 4.0, "col": "#b8962e", "alarm": false, "loot": [{"n": "Portátil", "kg": 2.0, "v": 900, "ch": 0.6, "q": [1, 1]}, {"n": "Mala de marca", "kg": 3.0, "v": 700, "ch": 0.5, "q": [1, 1]}]},
			{"n": "Secretária do gerente", "x": 1.0, "y": 9.0, "w": 2.5, "h": 1.2, "hh": 0.8, "time": 5.0, "col": "#6b4a32", "alarm": false, "loot": [{"n": "Portátil", "kg": 2.0, "v": 900, "ch": 0.7, "q": [1, 1]}, {"cash": [100, 300]}]},
		],
		"props": [
			{"x": 5.0, "y": 9.0, "w": 3.0, "h": 1.0, "hh": 0.8, "col": "#3d5f8a"},
			{"x": 10.0, "y": 9.0, "w": 3.0, "h": 1.0, "hh": 0.8, "col": "#3d5f8a"},
			{"x": 7.4, "y": 2.9, "w": 6.2, "h": 0.4, "hh": 1.0, "col": "#4a3020"},
		]},
	"museu": {"w": 28.0, "d": 18.0, "wall": "#f1efe8", "stripe": "#8a7a52", "floor": "#c7c2b5", "hostage": [14.0, 3.0],
		"conts": [
			{"n": "Vitrine das moedas", "x": 4.0, "y": 6.0, "w": 2.0, "h": 1.2, "hh": 1.1, "time": 5.0, "col": "#a9c4d1", "alarm": true, "loot": [{"n": "Moeda rara", "kg": 0.1, "v": 1500, "ch": 1.0, "q": [1, 3]}]},
			{"n": "Vitrine das estatuetas", "x": 13.0, "y": 6.0, "w": 2.0, "h": 1.2, "hh": 1.1, "time": 6.0, "col": "#a9c4d1", "alarm": true, "loot": [{"n": "Estatueta de bronze", "kg": 7.0, "v": 3500, "ch": 1.0, "q": [1, 1]}]},
			{"n": "Vitrine dos vasos", "x": 22.0, "y": 6.0, "w": 2.0, "h": 1.2, "hh": 1.1, "time": 6.0, "col": "#a9c4d1", "alarm": true, "loot": [{"n": "Vaso cerâmico", "kg": 5.0, "v": 2500, "ch": 1.0, "q": [1, 1]}]},
			{"n": "Parede dos quadros", "x": 9.0, "y": 0.3, "w": 10.0, "h": 0.4, "hh": 2.8, "time": 9.0, "col": "#7a5a3a", "alarm": true, "loot": [{"n": "Pintura antiga", "kg": 4.0, "v": 6000, "ch": 1.0, "q": [1, 2]}]},
			{"n": "Cofre do curador", "x": 25.5, "y": 0.3, "w": 2.2, "h": 1.2, "hh": 1.8, "time": 10.0, "col": "#3c4148", "alarm": true, "loot": [{"cash": [800, 2000]}]},
		],
		"props": [
			{"x": 6.0, "y": 12.0, "w": 3.0, "h": 0.8, "hh": 0.5, "col": "#6b4a32"},
			{"x": 18.0, "y": 12.0, "w": 3.0, "h": 0.8, "hh": 0.5, "col": "#6b4a32"},
			{"x": 9.0, "y": 9.0, "w": 1.0, "h": 1.0, "hh": 3.4, "col": "#e4e0d6"},
			{"x": 18.0, "y": 9.0, "w": 1.0, "h": 1.0, "hh": 3.4, "col": "#e4e0d6"},
		]},
}
