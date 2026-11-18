# GOLPE: revisão visual (direção de arte e UI)

Âmbito: as 41 capturas em `screens-golpe/` (1280x720). Objetivo: aspeto profissional, de tendência realista (na linha dos *sandboxes* de crime comerciais), com identidade própria e portuguesa. Limites: só recursos gratuitos (CC0 ou licença permissiva), nenhum artista, renderizador GL Compatibility em Android.

Diagnóstico em uma frase: **a UI de painéis já está a meio caminho de parecer profissional; o mundo 3D não.** O que mais denuncia o amadorismo, por ordem: (1) a exposição, com chão e passeios quase brancos e céu lavado; (2) a personagem, que é um manequim cinzento sem roupa, com uma caixa às costas; (3) os interiores em cores pastel de brinquedo, cobertos por triângulos vermelhos translúcidos; (4) o HUD, com demasiados blocos soltos, texto miúdo e um registo de eventos sem fundo por cima de um chão branco.

---

## 1. Ecrã a ecrã

### 01_login
- **Amador:** ecrã vazio, com um campo e um botão num fundo liso #15161A. O campo "Teste" não tem rótulo nem *placeholder* explicativo. O logótipo usa a mesma família tipográfica da UI, com uma sombra vermelha desfasada que parece um efeito de WordArt. Não há marca, ambiente, versão nem créditos.
- **Correção:** fundo com uma cena 3D do próprio jogo, de noite, desfocada e escurecida em 60 % (rua com candeeiros acesos, câmara em *dolly* lento), ou uma ilustração procedimental de silhuetas de prédios com janelas acesas. Logótipo numa tipografia de exibição própria (ver §3), com textura de stencil ou de "fita adesiva" gerada por *shader*. Campo com rótulo "Nome do teu bando" acima, em 14 px e cor secundária. Versão e "créditos CC0" no canto inferior em 12 px a 40 % de opacidade.

### 02_casa (exterior do esconderijo)
- **Amador:** o letreiro 3D "Esconderijo" é enorme e invade o HUD: a bússola e as estrelas ficam por cima das letras, e o resultado é ilegível. A fachada é uma caixa escura com um retângulo castanho no lugar da porta. O anel de interação amarelo, com 2,5 m de diâmetro, é mais chamativo do que a própria porta. O passeio branco está queimado e as faixas de asfalto têm um azul-claro saturado.
- **Correção:** a escala do letreiro deve ser proporcional à fachada (altura das letras ≈ 0,6 m) e ele deve estar recuado da câmara; a câmara não pode encostar-se à fachada. A porta precisa de moldura, de uma ombreira com 5 cm de relevo e de um material metálico. Substituir o anel por um marcador discreto (decal de chão a 40 % ou um losango pequeno a flutuar sobre a porta) e confiar o destaque ao botão contextual.

### 03_cofre (painel do esconderijo)
- **Amador:** a metade inferior do painel fica vazia. A hierarquia dos botões é confusa: "GUARDAR $0" aparece em amarelo esbatido (desativado? ativo?), "LEVANTAR" mostra "$50 000" como rótulo do botão, e "DESCANSAR E REPARAR O CARRO" desativado confunde-se com o fundo. As estatísticas finais são uma linha corrida sem estrutura. O ícone do dinheiro tem 24 px ao lado de um título de 20 px.
- **Correção:** dar ao painel a altura do conteúdo (com animação de abertura), ou usar o espaço para uma ilustração/vista do cofre. Pôr sempre o verbo no botão ("Guardar tudo", "Levantar $50 000") e o valor no texto ao lado. Os estados desativados devem ter fundo a 40 %, texto a 35 % e um cadeado ou motivo ("Carro sem danos"). As estatísticas passam a uma grelha de 4 cartões (número grande de 28 px e rótulo de 12 px).

### 04_regiao (mapa regional)
- **Amador:** o mapa é feito de círculos verdes planos sobre verde e de quadrados cinzentos no lugar da cidade, o que parece um protótipo. A estrada passa por cima da etiqueta "Vila Rubra". O cartão inferior tapa outra etiqueta (há uma caixa escura escondida por trás dele, na zona x 470–660, y 630) e tem 60 px de vazio por baixo do botão. O título mistura uma parte em maiúsculas com outra em minúsculas ("— para onde vais?").
- **Correção:** estilo de "mapa de papel" procedimental: fundo em tom de papel, relevo com um *noise* suave em 2–3 tons, costa com contorno duplo, estradas com contorno escuro e preenchimento claro, e a cidade desenhada como um bloco compacto de quarteirões. Etiquetas com *leader line*, nunca por cima das estradas. Cartão de destino ancorado à direita (painel lateral de 360 px) e não por cima do mapa. Título numa só caixa: "REGIÃO DE VILA RUBRA" grande e "Para onde vais?" pequeno por baixo.

### 05_cidade_carro / 18_conducao_curva / 18b_carros
- **Amador:** sobre-exposição geral: passeios brancos puros e prédios ao fundo absorvidos pelo nevoeiro claro. As marcações das passadeiras e das faixas são de um azul-claro saturado, sem razão aparente. Os carros parecem plástico de cor sólida, sem reflexos, com rodas de 8–10 lados visíveis e faróis que são retângulos brancos. Os "rabiscos" ondulados no chão (marcas de pneu ou sombras de cabos) têm degraus de *aliasing* e parecem um *bug*. "35 km/h" aparece em branco gigante, sem fundo. O semáforo está no meio do passeio.
- **Correção:** ver §3 (*tonemap*, exposição, albedo máximo). Marcações rodoviárias em branco-sujo #D8D4C8 a 85 %, sem azul. Carros: rodas com 20–24 segmentos, pneu com flanco escuro e jante metálica, vidros escuros com fresnel e pintura metálica 0,4 / rugosidade 0,3, refletindo o céu. Velocímetro num mostrador semicircular com fundo #000 a 50 %, número em tabular de 40 px e unidades em 14 px. Marcas de pneu: textura com alfa suave e desvanecimento, nunca geometria ou sombra serrilhada.

### 05b_rua_150 (praça)
- **Amador:** a praça está vazia. Os bancos e floreiras são caixas castanhas lisas, sem textura nem chanfro. O chão é uma grelha de azulejos brancos de casa de banho. O nevoeiro branco come a linha do horizonte. O círculo lilás do território é quase invisível.
- **Correção:** calçada portuguesa procedimental (ondas pretas sobre calcário, ver §3), que é ao mesmo tempo identidade e textura. Mobiliário urbano com chanfro de 2 cm, madeira e metal separados. Nevoeiro com a cor do céu ao nível do horizonte (não branco) e densidade 30 % menor. Zona de território marcada por uma faixa tracejada no chão e por bandeirolas/grafitos do gangue, não só por um anel.

### 05b_rua_205 (ponte)
- **Amador:** a água é um plano azul-bebé liso. As montras do rés-do-chão repetem a mesma caixa laranja em todos os vãos. A linha central da estrada desaparece debaixo do jogador e, com a sombra, cria uma confusão visual.
- **Correção:** água com *shader* simples (duas normais em *scroll*, fresnel para a cor do céu, cor funda #1E3A44). Montras com 4–6 variantes de produto/iluminação escolhidas por *seed*, vidro escuro com reflexo do céu e estores metálicos meio corridos em algumas.

### 05b_rua_300 / 05b_rua_60
- **Amador:** a sombra do candeeiro é serrilhada e estende-se 15 m. Os prédios são bons de silhueta, mas planos: sem cornija, sem varandas em relevo, sem telhado visível. As portadas são de um verde-lima saturado. O letreiro "Joalharia Aurora" é bom, mas todos os letreiros usam o mesmo estilo.
- **Correção:** resolução da sombra direcional e *split* (ver §3), com distância máxima de 40 m. Prédios: cornija extrudida, peitoris e varandas com 15–25 cm de profundidade, platibanda e telhado de telha em tom terracota. Portadas num verde-garrafa #2F4A3A ou em castanho. Letreiros com 4 estilos (caixa iluminada, letras soltas em latão, painel pintado, néon) escolhidos pelo tipo de loja.

### 07_rua_a_pe / 08_personagem_frente / 09_personagem_costas
- **Amador:** este é o maior problema de credibilidade. O jogador é um manequim de teste cinzento-escuro, com uma faixa bege nos olhos e uma caixa cúbica a servir de mochila. Em grande plano (08) vê-se a geometria simplificada das mãos e a falta de roupa. Há um círculo escuro sobre a barra de armas (o *joystick* fantasma?) a sobrepor-se a ela.
- **Correção:** substituir o modelo por personagens modulares CC0 com roupa (Quaternius "Ultimate Modular Men/Women" ou "Universal Base Characters", com as animações CC0 do mesmo autor) e cores atribuídas por material: casaco, calças, gorro/passa-montanhas e luvas. Mochila com forma arredondada (cápsula achatada), alças e um tom de lona. Afastar o *joystick* da barra de armas (ver §2).

### 06_mapa_cidade
- **Amador:** a etiqueta "Bomba Estrela" fica tapada pelo marcador "V Dona Aurora". Os marcadores são todos círculos vermelhos com uma letra, pelo que não se distingue um banco de um café. O mar inferior (x 64–1216) é mais largo do que o mapa (x 192–1088): erro de enquadramento. Os nomes dos bairros têm contraste baixo, não há legenda, e o HUD do jogo vê-se por trás num véu de 70 %.
- **Correção:** ícones pictográficos por categoria (cofre, garrafa, diamante, cruz de farmácia, bomba de gasolina) dentro de *pins* coloridos por função (alvo, loja, contacto, território). Evitar colisões de etiquetas com um *offset* automático e esconder as etiquetas de menor prioridade quando há sobreposição. O mar deve preencher o retângulo completo do mapa. Legenda recolhível à direita. Fundo 100 % opaco ou com desfoque.

### 10_interior_* (banco, bomba, café, farmácia, garrafeira, hotel, joalharia, museu) e 11_cafe_balcao
- **Amador:**
  - Paleta de brinquedo: sofás azul-bebé, frigorífico menta brilhante, paredes salmão/verde-alface, mesas laranja. A farmácia e a bomba são uma explosão de cubos pastel nas prateleiras.
  - Os cones das câmaras são triângulos vermelhos/rosa translúcidos que cobrem metade do ecrã e tingem tudo de rosa.
  - As paredes cortadas da frente são lajes cinzentas lisas a ocupar 40 % do ecrã.
  - O anel verde de saída, com 200 px, fica sempre no centro inferior.
  - Escalas incoerentes: os hambúrgueres são do tamanho de pratos e a máquina registadora parece um cubo.
  - Os empregados são manequins brancos.
  - A iluminação é chapada, sem fontes de luz no teto nem sombras de contacto. O hotel e o museu são um chão branco queimado.
  - O aviso "Uma câmara está a filmar-te" aparece duplicado e sobreposto (garrafeira) ou meio desvanecido atrás da bússola (hotel, museu).
- **Correção:**
  - Paleta por tipo de loja, dessaturada e com um acento apenas (joalharia: madeira escura + latão + veludo bordeaux; farmácia: branco-sujo + verde-cruz; banco: mármore cinzento + madeira; café: azulejo + madeira + inox).
  - Chão com textura CC0 (ambientCG: azulejo, madeira, mármore).
  - 2–3 luzes *omni* quentes no teto, com *pools* de luz e uma luz de preenchimento ambiente fraca.
  - Cones de câmara desenhados só no chão, como leque com contorno de 2 px e preenchimento a 12 %; vermelhos quando te veem, brancos quando não.
  - Paredes da frente baixadas a 30 cm (estilo maqueta) e com o topo pintado em escuro.
  - Saída marcada por um decal no chão junto à porta (seta + "SAÍDA"), com 1/3 do tamanho atual.
  - Uma escala real por *prop* (prato ≈ 25 cm) verificada num teste automático.
  - Toasts numa fila única, sem duplicados.

### 12_a_vasculhar
- **Amador:** a barra "A VASCULHAR" fica no centro inferior, por cima de uma mesa, e o botão de ação passa a "..." sem significado. A etiqueta "Funcionário rendido" tem um contorno verde e a "Câmara" um vermelho: dois estilos de toast diferentes.
- **Correção:** mostrar o progresso dentro do próprio botão de ação, como um anel que se preenche à volta dele com a percentagem, e manter o nome do alvo por cima do objeto. Um único componente de toast com variantes de cor apenas numa barra lateral de 4 px.

### 13_janela_saque / 13a_a_revelar / 14_inventario / 22_vender
- **Amador:** dois painéis de 590 px cada, com grelhas de 360x270 centradas, o que deixa ~55 % de espaço morto por painel. Há uma fenda de 14 px entre os painéis por onde se vê o jogo. "PEGAR TUDO" desativado aparece em castanho-mostarda, que não se percebe se é um estado ou uma cor. Em 14, o botão "OPÇÕES" é o elemento mais chamativo do ecrã sem ser a ação principal. "LARGAR" (vermelho) e "Relógio de ouro" flutuam sem relação visual com o item selecionado. Em 22, o painel esquerdo fica totalmente vazio. Os preços estão em 12 px.
- **Correção:** um único contentor de largura total com duas colunas; células de 96–112 px (a grelha deve ocupar ≥70 % da altura útil). Um painel de detalhe do item selecionado (ícone grande, nome, raridade, valor, botões "Largar/Usar/Vender") por baixo da grelha ou numa terceira coluna estreita. Raridade como faixa inferior de cor e brilho suave no fundo, não só como contorno. Estados desativados normalizados (ver §3). No ecrã de venda, o painel esquerdo deve mostrar o comprador (retrato/ícone, bónus "+30 % Arte" em destaque, total a receber).

### 15_sala_dos_fundos
- **Amador:** a câmara corta a parede e mostra um corredor estreito, com o jogador encostado à parede do fundo. O cofre é um cubo cinzento com um círculo amarelo. O NPC branco no chão, em primeiro plano, parece um erro (pose de rendição deitado e mal visível). Os quadros são molduras vazias.
- **Correção:** cofre com porta em relevo, roda de manípulo (*torus*) e dobradiças, num material metálico escuro com rugosidade 0,4. Quadros com "pinturas" procedimentais (gradiente + *noise*). Câmara com ajuste de *pitch* em salas estreitas.

### 16_traseiras_alarme / 17_minijogo_alarme
- **Amador:** a parede das traseiras é uma fachada de janelas repetida, sem portas, contentores ou escadas de incêndio. A calçada azulada fica saturada e escurecida. A caixa do alarme é uma placa branca num poste. O minijogo está bem resolvido; falta-lhe só personalidade (parece um formulário).
- **Correção:** módulo de "traseiras" com porta de serviço, contentores do lixo, tubagens e luz de presença laranja. A caixa do alarme vai para a parede, com uma luz LED a piscar. No minijogo, desenhar fios reais (3 curvas Bézier coloridas) e uma agulha de galvanómetro; manter a mesma mecânica.

### 18c_superdesportivo
- **Amador:** o carro verde-lima é plástico puro, com a asa como uma tábua e polígonos visíveis nas rodas. O jogador atravessa o capô (sem colisão ou sem animação de saída).
- **Correção:** paleta automóvel realista (pratas, pretos, brancos, um vermelho, um azul-escuro; cores vivas só em ≤10 % dos carros). Chanfros nas arestas do *mesh* procedimental (*bevel* de 1 segmento), luzes traseiras emissivas e matrícula portuguesa procedimental (faixa azul da UE e texto em fonte mono).

### 19_stand
- **Amador:** a pré-visualização é pequena (290 px) sobre um meio-disco cinzento cortado em baixo. A lista de separadores duplica a lista vertical de baixo. "Tens $413 100" tem pouco peso. As especificações vêm numa linha corrida ("104 km/h · resistência 170 · mala 4×3").
- **Correção:** ecrã de stand em largura total: carro grande (50 % do ecrã) num estrado iluminado por três luzes de estúdio, a rodar devagar; à direita, nome, preço e 3 barras de estatística (velocidade, resistência, mala) com comparação com o carro atual. Escolher o carro com setas ou um carrossel em baixo, e eliminar a lista duplicada.

### 20_armeiro
- **Amador:** é a lista mais sólida, mas os ícones variam de tamanho e estilo (o pé-de-cabra é uma linha diagonal fina, a máscara um blob). O último botão verde fica cortado no fundo do painel. "EM USO" a cinzento escuro sobre fundo escuro tem contraste < 3:1.
- **Correção:** ícones num conjunto único, todos com a mesma caixa de 48 px, traço de 3 px e preenchimento duo-tom. "EM USO" passa a uma *tag* com contorno verde e visto. Desvanecimento no fundo do *scroll* para indicar que há mais conteúdo.

### 21_carrinha / 23_dinheiro_na_mesa
- **Amador:** o chão é um plano creme queimado (#FFFFE8) que ocupa meio ecrã e parece um vazio. A carrinha é uma caixa com rodas octogonais e um toldo amarelo chapado. A etiqueta "O Antiquário +30% Arte" flutua em texto branco sem fundo. O dinheiro na mesa são três placas verdes.
- **Correção:** o chão do parque passa a asfalto/terra batida com textura. Carrinha com cabine chanfrada, rodas de 20 segmentos, porta lateral aberta com luz interior quente e mercadoria visível (molduras, caixas). Etiqueta num cartão 3D pequeno (fundo escuro a 70 %, nome e bónus num chip amarelo). Maços de notas com faixa de papel e uma pilha irregular.

### 24_bar_historia
- **Amador:** o painel tem 2/3 de vazio. "ENTREGAR" parece disponível sem teres o item. A citação da missão tem o mesmo peso do resto.
- **Correção:** layout de "ficha de missão": retrato/silhueta do contacto à esquerda, citação em itálico de 18 px entre aspas angulares, objetivo com caixa de verificação e recompensa num chip. "ENTREGAR" desativado (ver regra de estados) e "Ainda não a tens" com ícone de cadeado.

### 25_territorio / 26_policia
- **Amador:** os membros do gangue são manequins lilases idênticos e parecem bonecos de teste. Uma caixa castanha gigante em primeiro plano tapa 30 % do ecrã (falta colisão da câmara). O anel lilás é fraco. Em 26, a vinheta vermelha/branca da polícia lava o ecrã todo em rosa em vez de criar tensão. O carro da polícia, minúsculo, mal se lê.
- **Correção:** o gangue usa as mesmas personagens modulares com um "uniforme" de cor (bandana/casaco) e variação de cabelo e tons de pele. Câmara com *raycast* e *fade* de oclusores (*dither* de transparência em objetos entre a câmara e o jogador). A vinheta da polícia deve ficar só nos 8 % das bordas, pulsar azul/vermelho de forma alternada e com alfa ≤ 0,35. Carro da polícia com barra de luzes emissiva e um ícone sobre ele no minimapa.

---

## 2. Problemas transversais

### HUD num telemóvel
- **Demasiados blocos soltos no topo** (minimapa, dinheiro, nível, bússola, estrelas, mochila, MAPA, menu): oito caixas com estilos ligeiramente diferentes. Agrupar em três zonas:
  - **canto superior esquerdo**: minimapa circular de 160 px, com o dinheiro e o nível colados por baixo;
  - **centro superior**: estrelas de procurado e, só quando relevante, a bússola fina de 24 px;
  - **canto superior direito**: vida/colete e mochila num só bloco, com o menu.
  Tirar "MAPA" como botão separado: o toque no minimapa abre o mapa.
- **Barras sem rótulo:** a verde e a azul dentro da caixa "Mochila" não dizem o que são. Pôr ícones (coração, escudo) e separá-las da mochila.
- **"Nivel"** está sem acento em todas as capturas, e a barra de XP aparece vazia "0/600" no nível 6. Corrigir para "Nível" e mostrar o progresso real.
- **Margens de segurança:** os elementos estão a 12 px da borda. Em telemóveis com *notch* ou ilha são precisos ≥ 32–44 px nas laterais. Usar `DisplayServer.get_display_safe_area()`.
- **Registo de eventos:** até 6 linhas de texto amarelo/lilás/verde com sombra, sem fundo, sobre um chão branco, e o carimbo horário repete-se em todas. Mostrar no máximo 3 linhas, num cartão com fundo #000 a 45 %, que desaparecem depois de 5 s. Sem hora (ou hora a 50 %). Ícone de categoria em vez de cor de texto.
- **Toasts** ("Uma câmara está a filmar-te"): duplicam-se, sobrepõem-se e ficam por baixo da bússola e das estrelas. Fila única, posição fixa abaixo das estrelas, sem repetir a mesma mensagem.
- **Barra de armas:** 3 caixas de 95x70 com texto de 12 px, sempre visíveis, mesmo dentro do carro e das lojas. Passar a um seletor compacto junto ao botão DISPARAR (ícone da arma em silhueta e munições), que se expande ao tocar.
- **Botões de ação:** o tamanho é bom (≈116 px), mas o texto amarelo de 14 px num botão de contorno amarelo tem pouca leitura. Pôr um ícone (mão, porta, alicate, berbequim) de 40 px e um rótulo de 13 px por baixo. DISPARAR deve ter um ícone de mira, não a palavra.
- **Joystick:** não se vê na maioria das capturas e, em 07, aparece um círculo escuro sobre a barra de armas. Mostrar uma base de *joystick* discreta (anel a 20 %) no quadrante inferior esquerdo, onde está agora o velocímetro e o registo de eventos.

### Tamanhos e alvos de toque
- Mínimo de 48 dp (≈ 64 px a 720p) para qualquer alvo. Os separadores do stand (≈ 40 px de altura) e o "?" da grelha estão no limite.
- Distância ≥ 16 px entre alvos adjacentes ("FECHAR" e o menu hambúrguer quase se tocam por trás dos painéis).

### Tipografia
- A família condensada (tipo Barlow Condensed) é coerente e apropriada, mas há demasiados tamanhos (12/13/14/16/18/20/24/40/60…) e o *body* de 12–13 px é pequeno num telemóvel. Definir uma escala fixa (ver §3) e um mínimo de 14 px para texto de leitura.
- O texto no mundo (letreiros, "Caixa registadora", "Champanhes") usa contorno preto grosso, num estilo diferente da UI. Normalizar.
- Os números de dinheiro devem usar algarismos tabulares, para não "dançarem" quando o valor muda.
- Moeda: o jogo é português mas usa "$". Se for intencional, assumir uma unidade própria (por exemplo "₲" ou "pilim" estilizado) e não o dólar, por coerência de identidade; se não, usar "€" com espaço fino ("13 100 €").

### Paleta
- Hoje há três paletas que não conversam entre si: UI escura com amarelo (boa), mundo exterior lavado e pastel, interiores de brinquedo (menta, salmão, azul-bebé). Não há nenhuma regra de saturação.
- Regra a adotar: o mundo com saturação média ≤ 45 % e acentos saturados reservados para a jogabilidade (alvos, perigo, interação).

### Iluminação e exposição
- **Sobre-exposição**: os passeios e o chão dos interiores chegam a RGB 250+. Causas prováveis: *tonemap* linear, albedos próximos de 1,0, luz ambiente forte e nevoeiro claro.
- **Sombras** serrilhadas e com *shadow acne*/degraus nas sombras longas dos candeeiros.
- **Sem oclusão de ambiente**: os objetos "flutuam" (carros e prédios não assentam no chão).
- **Sem luzes locais**: os interiores e as montras parecem estúdios de luz chapada.

### Materiais
- Tudo parece plástico mate ou cerâmica lisa: as mesmas rugosidade e especular em carros, paredes, sofás e personagens.
- Asfalto com salpicos brancos de alto contraste (parece terrazzo).
- O azulejo branco dos passeios tem uma escala de 50 cm e parece uma casa de banho.

### Personagens, carros e edifícios
- **Personagens:** manequins sem roupa (jogador cinzento, civis brancos, gangue lilás, um civil azul): é o maior sinal de "protótipo".
- **Carros:** silhueta razoável, mas faltam chanfros, rodas redondas, vidros e luzes; as cores são de brinquedo.
- **Edifícios:** a geração procedimental é a parte mais madura (cores de fachada, janelas, montras), mas falta-lhe profundidade (cornijas, varandas, telhados), variação do rés-do-chão e sujidade (gradiente vertical, manchas). As portadas verde-lima e as fachadas lilases puxam para o *cartoon*.

---

## 3. Proposta de direção de arte: "Vila Rubra, calor e calcário"

Identidade: uma cidade costeira portuguesa ao fim da tarde. A fachada tem azulejo, calçada portuguesa e cal, e o crime acontece à luz do sol baixo e dos néons das lojas. Isto distingue o GOLPE dos *sandboxes* americanos sem copiar nenhum.

### Paleta (hex)
- **Mundo, base:**
  - calcário #CFC7B8, cal #E6E0D3 (albedo máximo; nada acima disto);
  - asfalto #3A3C40, pedra escura da calçada #2B2D30;
  - terracota #A65A3C, ocre #C79A55, azul-azulejo #2F5D8A, verde-garrafa #2F4A3A, rosa-velho #B98A84.
- **Mundo, noite e luzes:** sódio #FFB45A, néon de loja #FF4E5B / #47D1C4 (só em letreiros).
- **UI:**
  - fundo do painel #111317 a 94 %, cartão #1B1E24, linha #2A2E36;
  - texto principal #EDEAE3, secundário #9A9EA6, desativado #5A5E66;
  - acento primário "amarelo-golpe" #E9B730 (já usado; manter);
  - perigo #D9443A, sucesso #3FBF7F, informação #4A90D9;
  - raridades: comum #8A9099, invulgar #3FBF7F, raro #4A90D9, épico #9B6BDB, lendário #E9B730.
- **Regras:** acentos saturados só em elementos interativos ou de perigo; o mundo com saturação ≤ 45 %; contraste de texto ≥ 4,5:1.

### Tipografia (todas com licença SIL OFL, gratuitas)
- **Títulos e logótipo:** "Big Shoulders Stencil Display" (Black). O stencil comunica caixotes, cofres e crime, e não é a fonte de nenhum jogo conhecido do género.
- **UI (botões, rótulos, números):** "Barlow Condensed" SemiBold/Bold, com algarismos tabulares (`font_features` "tnum").
- **Texto corrido:** "Barlow" (não condensada) Medium.
- **Escala (a 720p de altura):** 12 (micro, raro) / 14 (*body*) / 16 (rótulo) / 20 (subtítulo) / 28 (título de painel) / 40 (número de destaque) / 64 (logótipo/ecrã de título). Maiúsculas só em títulos e botões, com espaçamento de +2 %.

### Regras de estilo de UI
- **Painéis:**
  - um único `StyleBoxFlat`: cantos de 6 px, fundo #111317 a 94 %, borda de 1 px #2A2E36 e uma **barra superior de 3 px na cor de contexto** (amarelo neutro, vermelho para perigo/polícia, verde para venda). Já existe em parte; generalizar.
  - Sombra projetada de 24 px a 40 %. Padding fixo de 24 px e grelha de 8 px para todos os espaçamentos.
- **Botões:** três níveis apenas.
  - **Primário:** preenchido a amarelo, texto #111.
  - **Secundário:** preenchido #2A2E36, texto claro.
  - **Perigo:** contorno vermelho e texto vermelho, preenchido só no *hover*/pressão.
  - Altura mínima de 56 px.
  - **Desativado:** sempre o mesmo, com fundo #1B1E24, texto #5A5E66 e ícone de cadeado opcional, nunca uma versão "esbatida" da cor primária.
  - Pressão: escala 0,96 durante 80 ms e escurecimento de 10 %.
- **Ícones:**
  - um único conjunto em silhueta, monocromático, desenhado em código (`draw_*` / SVG gerado), com a mesma caixa de 48 px, traço de 3 px e cantos arredondados.
  - Em alternativa, usar o game-icons.net (CC BY 3.0, exige crédito) ou os ícones do Kenney (CC0), recoloridos para a paleta. Nunca misturar estilos.
- **Células de inventário:** fundo #1B1E24, faixa inferior de 4 px na cor da raridade, brilho radial a 15 % na mesma cor, preço em 14 px tabular numa pílula escura.
- **Texto no mundo:** um só estilo, com cartão escuro a 70 %, cantos de 4 px e texto de 16 px, de forma a ficar legível sobre o céu ou o chão; nada de contorno preto grosso.
- **Animação:** painéis entram com *fade* e um deslize de 12 px em 150 ms (*ease-out*); toasts em 200 ms. Nada de saltos.

### Iluminação (GL Compatibility, Godot 4.3)
- **WorldEnvironment:**
  - *tonemap* **Filmic** (ou ACES), exposição 0,85–0,95, *white* 6;
  - `adjustment` ligado, com contraste 1,08 e saturação 0,9;
  - nevoeiro com a cor do horizonte do céu, densidade baixa, apenas de profundidade.
  - Confirmar na versão em uso se o *glow* está disponível no Compatibility. Se estiver, usar *glow* fraco só para emissivos (limiar 1,0); se não, dar halos aos néons e faróis com *sprites* aditivos (*billboards*).
- **Sol (DirectionalLight3D):**
  - cor #FFE2C0, energia 1,1–1,3, inclinação de 30–40°, para ter sombras longas e cara de fim de tarde.
  - Sombras PSSM com 2 *splits*, distância máxima de 40–50 m, 2048 px em gama média e 4096 em gama alta (opção de qualidade), *blur* de 1,5 e *normal bias* ajustado para eliminar os degraus.
- **Ambiente:** a partir do céu, com energia 0,35–0,5 e um *sky* procedimental com horizonte quente e zénite #5D86B5.
- **Oclusão falsa (o SSAO não existe no Compatibility):**
  - escurecer por *vertex color* a base das paredes (gradiente de 0,6 m);
  - pôr um *blob shadow* (quad com textura radial) por baixo dos carros, das personagens e do mobiliário;
  - gerar AO nas arestas dos *meshes* procedimentais.
  - Para os interiores estáticos, considerar *lightmaps* em *bake*, depois de confirmar o suporte no Compatibility na versão usada.
- **Interiores:** um preset por loja, com 2–3 OmniLight sem sombra (respeitar o limite de luzes por objeto do Compatibility), ambiente mais escuro (0,25) e sol desligado ou muito fraco.
- **Noite (opcional, de grande impacto):** sol desligado, lua azul fraca, candeeiros com luz de sódio em *billboards* aditivos, montras emissivas. A identidade "Vila Rubra à noite" vende-se muito melhor nas capturas da loja.

### Materiais procedimentais
- **Texturas:** usar texturas CC0 de ambientCG/Poly Haven para asfalto, betão, reboco, mármore, madeira e azulejo, a 512–1024 px, comprimidas em ETC2.
- **Albedo:** máximo de 0,8 (calçada de calcário 0,65) e mínimo de 0,04.
- **Calçada portuguesa:** *shader* com padrão de ondas (seno em UV) a misturar pedra clara e pedra escura, com *noise* por célula para simular pedras individuais. É barato, é original e é imediatamente português.
- **Fachadas:** gradiente vertical de sujidade (mais escuro nos 1,5 m de baixo), *noise* de manchas de 5–10 % e, opcionalmente, um painel de azulejo procedimental (padrão geométrico em *shader*) no rés-do-chão de 1 em cada 4 prédios.
- **Carros:**
  - pintura metálica 0,4–0,6 / rugosidade 0,25–0,35, refletindo o céu radiante;
  - borracha a rugosidade 0,9, cromados a metálico 1 / rugosidade 0,15;
  - vidro escuro #0C1014 com fresnel por *rim*.
- **Personagens:** tecido a rugosidade 0,85, pele com 3–5 tons, nada a metálico.

### Recursos gratuitos recomendados
- **Personagens e animações:** Quaternius (CC0).
- **Texturas:** ambientCG, Poly Haven (CC0).
- **Props de interior:** Kenney Furniture Kit (CC0), recolorido para a paleta e com texturas por cima. A escala tem de ser validada.
- **Fontes:** Google Fonts (OFL).
- **Ícones:** Kenney (CC0) ou game-icons.net (CC BY, com crédito).

---

## 4. Top 12 correções (por relação impacto/esforço)

| # | Correção | Impacto | Esforço |
|---|---|---|---|
| 1 | **Exposição e *tonemap*:** Filmic/ACES, exposição ≈ 0,9, albedos ≤ 0,8 (passeios a 0,65), nevoeiro com a cor do horizonte, marcações da estrada em branco-sujo. Muda todas as capturas de exterior. | Muito alto | **S** |
| 2 | **Sombras:** 2 *splits*, distância máxima de 40–50 m, mais resolução e *blur*, *bias* ajustado; remover ou suavizar os "rabiscos" serrilhados no chão. | Alto | **S** |
| 3 | **HUD arrumado:** margens de segurança, agrupamento em 3 zonas, minimapa circular que abre o mapa, rótulos/ícones nas barras de vida, "Nível" com acento, registo de eventos com fundo e no máximo 3 linhas, fila única de toasts. | Muito alto | **M** |
| 4 | **Personagens com roupa:** substituir os manequins por personagens modulares CC0 (Quaternius), com cores por material e variantes para civil, empregado, gangue e polícia; mochila com forma real. | Muito alto | **M** |
| 5 | **Interiores:** paleta dessaturada por tipo de loja, chão com textura, 2–3 luzes no teto, cones de câmara só no chão (12 % de alfa), paredes frontais baixas, marcador de saída pequeno. | Muito alto | **M** |
| 6 | **Calçada portuguesa e asfalto texturado:** *shader* de ondas para os passeios e textura CC0 de asfalto sem salpicos. Dá identidade imediata e tira o aspeto de "azulejo de casa de banho". | Alto | **S** |
| 7 | **Sistema de UI unificado:** *theme* Godot único (painel, 3 níveis de botão, estado desativado, escala tipográfica, grelha de 8 px) aplicado a todos os painéis; botões com verbo e valor separados. | Alto | **M** |
| 8 | **Inventário/saque em ecrã inteiro:** células de 96–112 px, painel de detalhe do item, raridade em faixa e brilho, painel do comprador no ecrã de venda. | Alto | **M** |
| 9 | **Carros credíveis:** rodas de 20–24 segmentos com jante, chanfros, vidros escuros com fresnel, pintura metálica, faróis e farolins emissivos, paleta de cores realista, *blob shadow*, matrícula PT. | Alto | **M** |
| 10 | **Oclusão falsa e assentamento:** gradiente de AO na base das paredes, *blob shadows* em tudo o que se move, AO por *vertex color* nos *meshes* procedimentais. | Médio-alto | **S** |
| 11 | **Profundidade dos edifícios:** cornijas, varandas, peitoris, telhado de telha, variação de montras/estores no rés-do-chão, sujidade vertical, portadas em tons sóbrios, 4 estilos de letreiro (e letreiros que não invadem o HUD). | Médio-alto | **L** |
| 12 | **Mapas estilizados:** mapa regional em "papel" procedimental e mapa da cidade com ícones por categoria, anti-colisão de etiquetas, legenda e o mar alinhado; ecrã de título com cena 3D noturna e logótipo em stencil. | Médio | **L** |

Sequência sugerida: as correções 1, 2, 6 e 10 numa única iteração de 1–2 dias (só ambiente, materiais e *shaders*, com risco baixo); depois a 3 e a 7 (UI); depois a 4, a 5 e a 9 (*assets*); por fim a 11 e a 12.
