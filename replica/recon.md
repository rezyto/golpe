# Recon — ROB RUN (estudo funcional clean-room para GOLPE)

Data: 18-11-2026. Só usei fontes públicas. Descrevo mecânicas por palavras nossas. Não copiei texto, nomes de locais ou itens, traçados de mapa nem arte. Os valores numéricos servem só como **ordem de grandeza** para equilibrar o jogo. Não são para copiar.

## Fontes

- Página Steam (app 4262460): https://store.steampowered.com/app/4262460/
- Resumo de reviews Steam (agregador): https://vaporlens.app/app/4262460/rob_run
- Notícia sobre picos de jogadores e queixas: https://www.tamindir.com/haber/rob-run-es-zamanli-oyuncu-sayisi_112807/
- Notícia de lançamento/top Steam: https://wnhub.io/news/stores-and-publishing/item-52708
- Guia de principiante (KeenGamer): https://www.keengamer.com/articles/guides/rob-run-beginners-guide-best-tips-for-a-perfect-start/
- Guia de dinheiro (KeenGamer): https://www.keengamer.com/articles/guides/rob-run-best-ways-to-farm-money-fast/
- Descodificadores e rusgas a bases (KeenGamer): https://www.keengamer.com/articles/guides/rob-run-how-to-get-decoders-and-raid-bases/
- Rusgas offline (GamesFuze): https://gamesfuze.com/guides/rob-run-how-to-protect-your-base-from-offline-raids/
- Golpes grandes (wikily): https://wikily.gg/rob-run/heists
- Terrenos e povoações (wikily): https://wikily.gg/rob-run/plots-and-settlements
- Passe de temporada (wikily): https://wikily.gg/rob-run/battle-pass
- Mapa interativo (wikily): https://wikily.gg/rob-run/interactive-map
- Povoações, clãs e impostos (TPose): https://tposegaming.com/rob-run-settlement/
- Saque (GrindNStrat): https://grindnstrat.com/?p=9890
- Polícia (ProdigyGamers): https://prodigygamers.com/?p=37784
- Polícia, detalhado (Timesaver): https://timesaver.gg/blog/rob-run-cop-guide
- Polícia (GamerBlurb): https://gamerblurb.com/articles/rob-run-how-to-be-a-cop
- Prisão (GamerBlurb): https://gamerblurb.com/articles/rob-run-jail-time-guide
- Veículos (PowerUp Gaming): https://powerupgaming.co.uk/2026/11/06/rob-run-vehicle-guide-best-getaway-cars/
- Armas e equipamento (PowerUp Gaming): https://powerupgaming.co.uk/2026/11/06/best-weapons-gear-for-heists-in-rob-run/
- Dinheiro a solo (PowerUp Gaming): https://powerupgaming.co.uk/2026/11/05/how-to-make-money-fast-in-rob-run-solo-play/
- Não carregaram (erro do site): games.gg, metaforge.app, mobalytics, destructoid, iggm. Os temas destes sites (prisão, *wipe*, cofre-forte) foram cobertos por outras fontes.

**Contexto:** é *free-to-play*, está em acesso antecipado desde 4-11-2026 e é só para PC.
- Cada servidor tem milhares de jogadores.
- Reviews "Mistas": cerca de 48% positivas em ~25 mil reviews em inglês.
- Pico de ~418 mil jogadores em simultâneo nas primeiras 24 h.
- A monetização é cosmética: passe de temporada e moeda premium.

## Ciclo principal

1. Começa-se pobre numa **base inicial fora da cidade**: um motel onde se guarda dinheiro, se compra no mercado negro e se faz troca direta.
2. Vai-se para a cidade e escolhe-se o papel: **civil**, **criminoso** (pôr a máscara) ou **polícia** (se houver vaga).
3. Assalta-se um alvo:
   - corta-se a caixa elétrica e destroem-se as câmaras;
   - mantém-se o funcionário sob a mira para não dar o alarme;
   - revistam-se cofres e armários;
   - sai-se antes de a polícia chegar.
4. Foge-se de carro e **vende-se a um receptador**. O dinheiro fica no balcão e tem de ser apanhado, por isso há risco de emboscada.
5. **Protege-se o dinheiro:** primeiro guarda-se na base inicial, depois **branqueia-se** e passa para a conta bancária.
6. Investe-se nos patamares seguintes:
   - ferramentas e armas melhores;
   - documentos (pesquisa) para alugar um terreno, construir a base e produzir bens;
   - comprar uma povoação inteira e cobrar impostos;
   - o clã dominar um distrito.
7. Ao fim de 7 dias há um **reinício total**: dinheiro, armas e propriedade desaparecem. O valor perdido converte-se em estatísticas permanentes (tempo de prisão / autoridade) que desbloqueiam conteúdo no ciclo seguinte. A cosmética mantém-se.

## Sistemas

### Assaltos e tipos de alvos
- **Lojas pequenas** (loja de conveniência, farmácia, garrafeira, bombas):
  - fáceis, ideais para começar;
  - têm funcionário, caixa registadora, armários, cofre pequeno, computadores e câmaras.
- **Casas e moradias** num bairro rico: melhor saque, mas podem exigir equipamento extra.
- **Joalharia:** valor alto, mais polícia.
- **Banco**, em duas camadas:
  - cofres de depósito que se arrombam e vão "enchendo" uma chave de nível superior;
  - essa chave troca-se por um cartão que abre o cofre-forte;
  - o cofre-forte precisa de um berbequim muito lento e barulhento e avisa a cidade toda;
  - dentro há várias pilhas de barras de ouro de valor muito alto.
- **4 golpes grandes**, cada um com uma ferramenta exótica obtida por cadeias de troca:
  - cofre de ouro do banco;
  - arsenal da esquadra;
  - carro em exposição num hotel;
  - peça de uma galeria de arte (exige cortador de vidro).
- **Avisos à cidade:** todos os golpes grandes enviam um aviso a todo o servidor, no início e no fim. É isto que cria o "evento" emergente.
- **Fontes de baixo risco:** contentores do lixo dão dinheiro solto; bagageiras de carros (incluindo de polícia) abrem-se com gazua; há helicópteros raros com saque.
- **Itens de objetivo:** câmaras de ação ou ferramentas USB "carregam" com crimes feitos a certo nível de notoriedade. Depois vendem-se ou trocam-se.
- **Pequenos objetos de rua:** há multibancos (13 no mapa), mas as fontes só os descrevem como **pontos de levantamento**, não como alvos. **Não encontrei** máquinas de venda assaltáveis. A disputa pelo saque acontece sobretudo **no balcão do receptador** e nos **pontos de venda**, onde outros jogadores montam emboscadas.

### Ferramentas
- **Ferramentas base:** gazua, berbequim mecânico e descodificadores (consumíveis de 12 s que retiram pontos de defesa a uma base).
- **Ferramentas especiais:** cortador de vidro, cartões de acesso e bloqueador silencioso.
- **Combate:** granadas de fumo e de atordoamento.
- **Veículos:** kit de reparação.
- **Muitas ferramentas vêm de troca direta**, num comerciante escondido na base inicial. Paga-se com itens "cheios" e dinheiro. Isto cria cadeias de objetivos.
- **Mesas:**
  - **bancada de trabalho:** fabricar e desmontar carga;
  - **portátil de comércio:** pesquisar e comprar documentos ("títulos") e distintivos.

### Inventário e mochilas
- **Mochila separada do equipamento vestido.** Ao render-se perde-se a mochila mas mantém-se o equipamento. Morrer como criminoso perde tudo.
- **Sacos de desporto** em 3 escalões de preço, que acrescentam espaço.
- **Raridades** visíveis por cor: comum, incomum, épico, lendário, exótico.
- **Armas e armadura:**
  - armas com estatísticas de dano/cadência/alcance;
  - armadura em 5 níveis com **placas** que absorvem dano antes da vida;
  - placas trocáveis por arrastar ou por slot rápido.
- **Consumíveis médicos:** ligaduras, analgésicos, kit.
- **Silenciador:** evita alertas.
- **Saque com variedade:** relógios, brincos, portáteis, chaves de salas escondidas, plantas de edifícios, escrituras de terreno, chaves de veículo, modificações de arma.

### Veículos e malas
- **Frota:** cerca de 12 carros e 1 helicóptero (precisa de heliporto).
- **Carro de aluguer grátis** em terminais de estacionamento, para quem não tem veículo.
- **Compromisso entre fuga e carga:**
  - carro de fuga rápido com bagageira pequena (2×6, expansível);
  - carrinha lenta com bagageira grande e **espaços de carga** à parte.
- **Melhorias:** turbo, centralina, direção, extensão de bagageira e grelhas de carga.
- **Encomendas/carga:** só cabem em certos veículos. Podem vender-se inteiras ou desmontar-se na base por mais lucro.
- **Bagageiras não são seguras:** qualquer jogador as pode arrombar onde o carro estiver estacionado.

### Polícia jogável e procurado
- **Duas camadas de estado:**
  - civil/criminoso: a máscara ativa o estado criminoso; tirá-la não limpa o estado, só sair da cidade o faz;
  - **notoriedade** em 5 níveis: mais procurado, mas melhor preço de venda.
- **Polícia jogável:**
  - inscreve-se na esquadra se houver vaga (máx. ~4 por cidade);
  - recebe arma, equipamento e viatura grátis;
  - os assaltos ativos aparecem como marcadores vermelhos.
- **Prisão de um criminoso:**
  - abatê-lo ou fazê-lo render-se e algemá-lo;
  - o criminoso perde a mochila, que é apreendida e conta para o salário;
  - outros criminosos podem interromper a detenção e ganham notoriedade com isso.
- **Salário:**
  - acumula pontos por detenção, abate e apreensão;
  - há bónus por sirene ligada, por ordem de rendição e por responder a **chamadas de reforço**;
  - recebe-se **no fim do turno, na esquadra**;
  - paga menos do que o crime, de propósito;
  - o polícia só perde o equipamento do Estado ao morrer.
- **Distintivos de patente** (3 níveis, comprados ou pesquisados):
  - cada um vale **um turno** com equipamento melhor;
  - têm de se desbloquear por ordem.
- **Regras para o polícia:** só pode abater criminosos; abater um rendido não paga; há tempo de reaparecimento crescente.
- **Subornos:** o criminoso oferece de 10 mil a 200 mil, pagos da **conta bancária** (dinheiro limpo), e o polícia decide se aceita.
- **Prisão e infrações:**
  - render-se envia o criminoso para a prisão, que é um mapa próprio;
  - o "tempo de prisão" é uma **estatística acumulada permanente**, não uma contagem decrescente;
  - há infrações de trânsito por níveis; ao 10.º nível vai-se diretamente para a cela.

### Venda de saque
- **Receptadores** em carrinhas assinaladas no mapa (6). O dinheiro aparece no balcão e pode ser roubado.
- **Carrinhas de contrabando** compram carga.
- **Centros de venda distritais** pagam melhor, mas só a residentes desse distrito.
- O preço depende da notoriedade: +10% a +50%.

### Economia
- **3 formas de dinheiro:** dinheiro físico (rouba-se), dinheiro guardado na base inicial e conta bancária.
- **Branqueamento:** a conta bancária só recebe dinheiro passado por uma **mesa de branqueamento na base**. O dinheiro sujo não pode ir direto para o banco. Os multibancos servem para levantar.
- **Mercado negro e documentos:** o mercado negro desbloqueia itens à medida que se sobe de nível de distrito. Os "títulos" (documentos) compram-se depois de pesquisados.
- **Produção:** estufas e laboratórios químicos produzem bens repetidamente.
- **Topo da economia:** impostos de povoação e de distrito.
- **Moeda premium** só para cosmética e passe. Há também uma roleta com moeda virtual.

### Clãs/famílias e territórios
- **Clãs:** cria-se ou junta-se a uma família, com cargos, rusgas organizadas, guerras de gangues, tréguas e traição possível.
- **Distritos:** o clã que controla um distrito recebe uma parte dos impostos das povoações desse distrito.
- **Alarmes de base** podem avisar o dono, o clã ou toda a zona.

### Esconderijos/propriedades
- **Base inicial partilhada:** guarda só dinheiro, não bens roubados.
- **Terrenos e povoações:**
  - um **terreno** aluga-se dentro de uma **povoação** que tenha dono;
  - quem compra a povoação inteira tem um lote grátis e recebe 5% do branqueamento e das compras dos residentes;
  - essa receita recolhe-se em pessoa e deixa de acumular até ser recolhida.
- **3 níveis de distrito**, com documentos progressivamente mais caros:
  - grosso modo, 100 mil → 800 mil → 2 milhões por terreno;
  - 200 mil → 2 milhões → 6 milhões por povoação.
- **Base modular:**
  - edifícios: roulote, casa, mansão, garagens, armazém, oficina, estufa, laboratório, vedações;
  - cada edifício tem um **painel de segurança** com pontos de defesa;
  - **fusíveis** aumentam a defesa;
  - **alarmes** avisam, mas não defendem.
- **Rusgas:**
  - **descodificadores** gastam a defesa do painel até chegar a zero e dão acesso temporário;
  - os cofres lá dentro exigem uma chave-mestra;
  - o dono pode reparar o painel, mas só se estiver online;
  - **não há proteção contra rusgas offline**.
- **Despejo:** juntando muitos descodificadores troca-se por um "direito de despejo" que tira o lote ao ocupante.
- **A base é ponto de reaparecimento.**

### Progressão/níveis/skills
- **Sem árvore de skills clássica.** A progressão faz-se por:
  - notoriedade (1–5);
  - pesquisa de documentos e ferramentas;
  - nível de distrito onde se vive;
  - distintivos de polícia;
  - estatísticas permanentes (tempo de prisão / autoridade) que desbloqueiam encomendas.
- **Missões introdutórias** ensinam as atividades e desbloqueiam o mercado negro.
- **Conquistas** ligadas aos golpes grandes.

### Wipes/temporadas
- **Rusga federal semanal:** apaga dinheiro (incluindo o do banco), armas, propriedades e bases.
- **O que se mantém:** cosmética, nome, tutorial, definições, tempo de prisão e autoridade.
- **Mudar de servidor** equivale a perder a propriedade.
- **Passe de temporada** (~5 semanas): moeda de temporada ganha com trabalhos, gasta em páginas de recompensas.
  - **Faixa grátis:** consumíveis e ferramentas.
  - **Faixa premium:** só cosmética (pinturas de armas, roupas, máscaras, porta-chaves).

### Multijogador/servidores
- **Servidores:** abrem servidores novos todos os dias por região, cada um com o seu ciclo. Os servidores antigos têm jogadores mais fortes.
- **Social:** grupos até 3, com papéis divididos (assalto / condutor).
- **Técnica:** anti-batota a nível de kernel; temporizador de saída que deixa a personagem vulnerável; sair da cidade como criminoso = morte.

### Eventos
- **Avisos globais** de golpes grandes, a decorrer ou concluídos.
- **Chamadas de reforço** para a polícia.
- **Nos primeiros 30 min** de um servidor novo, a polícia só tem pistolas.
- **Bónus de lançamento a solo:** notoriedade inicial mais alta e bónus de venda.
- **Locais de lazer:** discoteca/clube.
- **Atividades secundárias:** roleta, produção, impostos, polícia.

### Estilo do mapa (só a estrutura, nunca o traçado)
- **Uma cidade costeira compacta** com frente de mar, cais e hotéis virados para o oceano.
- **Bairros com papel claro:**
  - zona balnear/turística, com alvos fáceis e muitos peões;
  - centro com a esquadra, ou seja, polícia perto;
  - bairro de negócios com bancos e joalharias, alvos de alto valor;
  - bairro de elite com moradias, para assaltos residenciais.
- **Pontes como gargalos** usados pela polícia para armadilhas.
- **Água:** dá para fugir por ela, com risco de afogamento.
- **Edifícios:**
  - cerca de 28 edifícios assaltáveis, muitos **em pares nos dois lados da cidade** (há sempre uma alternativa perto);
  - cada edifício tem os mesmos tipos de contentor: cofre, armário, computador, caixa, câmara.
- **Serviços espalhados:**
  - cerca de 13 multibancos;
  - cerca de 21 terminais de aluguer de carro;
  - 6 receptadores;
  - 2 carrinhas de contrabando.
- **Filtros no mapa** (locais / serviços / segurança e clãs / contentores). Os contentores estão escondidos por defeito.
- **Mapas à parte**, fora da cidade: base inicial, hangar, povoações (2 traçados), prisão.
- **Deslocação:** sobretudo de carro, com helicóptero para os ricos.
- Dimensão física não publicada.

## Ecrãs

| ID | Ecrã | Propósito |
|---|---|---|
| S01 | Login / escolha de servidor | entrar e escolher região/servidor (muda o progresso) |
| S02 | Base inicial (hub) | guardar dinheiro, mercado negro, troca direta, reclamar recompensas |
| S03 | Escolha de papel ao entrar na cidade | civil / criminoso / polícia |
| S04 | HUD em jogo | estado civil/criminoso, notoriedade, vida/placas, slots rápidos, avisos globais |
| S05 | Inventário (mochila + equipamento vestido) | grelha, arrastar placas, separar o que se perde |
| S06 | Bagageira / carga do veículo | grelha mais espaços de carga |
| S07 | Mapa da cidade com filtros | serviços, alvos, contentores, assaltos ativos (polícia) |
| S08 | Mapa global | povoações livres/ocupadas por nível de distrito |
| S09 | Receptador / balcão | vender e recolher dinheiro |
| S10 | Mercado negro | comprar armas/equipamento por nível de distrito |
| S11 | Troca direta | trocar itens "cheios" por ferramentas raras |
| S12 | Portátil de comércio / pesquisa | pesquisar e comprar documentos e distintivos |
| S13 | Encomendas (atalho próprio) | requisitos e desbloqueios de carga |
| S14 | Banco / multibanco | abrir conta, levantar |
| S15 | Mesa de branqueamento | converter sujo em limpo |
| S16 | Construção de base | colocar edifícios, mobília, bancadas, fusíveis, alarmes |
| S17 | Painel de segurança | ver defesa, reparar, ser hackeado |
| S18 | Esquadra (polícia) | iniciar turno, receber salário |
| S19 | Suborno | criminoso propõe valor, polícia aceita/recusa |
| S20 | Prisão | estatística de tempo de prisão |
| S21 | Clã | membros, cargos, território, tréguas |
| S22 | Passe de temporada | páginas, faixa grátis/premium |
| S23 | Loja premium / cosmética | moeda premium, skins |
| S24 | Recolha de impostos (carrinha de cobrança) | dono da povoação recolhe |

## Fluxos

**F01 Primeiro assalto**
1. Sair da base inicial.
2. Alugar um carro grátis.
3. Escolher uma loja pequena.
4. Pôr a máscara.
5. Cortar a caixa elétrica.
6. Destruir as câmaras.
7. Apontar ao funcionário.
8. Revistar.
9. Fugir.
10. Vender.
11. Recolher do balcão.
12. Voltar à base.

Casos-limite:
- sem arma, não se consegue controlar o funcionário e ele dá o alarme;
- outro jogador rouba o dinheiro do balcão;
- tirar a máscara não limpa o estado criminoso.

**F02 Rendição/detenção**
1. A polícia encurrala o criminoso.
2. O criminoso rende-se ou é derrubado.
3. É algemado.
4. Perde a mochila e mantém o equipamento vestido.
5. Vai para a prisão e sobe o tempo de prisão.

Casos-limite:
- um cúmplice interrompe a detenção;
- o criminoso oferece suborno;
- abater um rendido não dá recompensa ao polícia.

**F03 Turno de polícia**
1. Ir à esquadra (só se houver vaga).
2. Opcionalmente, gastar um distintivo.
3. Receber equipamento e viatura.
4. Responder a marcadores de assalto.
5. Prender e apreender.
6. Responder a reforços.
7. Voltar à esquadra.
8. Receber o salário.

Casos-limite:
- morrer só tira o equipamento do Estado;
- fuga pela água com risco de afogamento;
- vários assaltantes numa só cena.

**F04 Proteger dinheiro**
1. Abrir conta no banco, como civil.
2. Ter um terreno com mesa de branqueamento.
3. Branquear.
4. O dinheiro limpo vai para a conta.
5. Levantar no multibanco quando for preciso.

Casos-limite:
- o dono da povoação cobra 5%;
- o banco também é apagado na rusga semanal.

**F05 Ter base**
1. Pesquisar o documento de terreno.
2. Comprar o documento.
3. Encontrar uma povoação com dono e um lote livre.
4. Aplicar o documento.
5. Construir.
6. Pôr fusíveis e alarmes.

Casos-limite:
- o documento não reserva terreno;
- o nível do documento tem de coincidir com o do distrito;
- mudar de servidor faz perder tudo.

**F06 Rusga a base rival**
1. Juntar descodificadores.
2. Ir à base rival.
3. Hackear cada painel, 12 s por descodificador.
4. Ter acesso temporário.
5. Abrir os cofres com a chave-mestra.
6. Sair antes de o dono reparar o painel.

Casos-limite:
- o alarme avisa o clã do dono;
- morrer na rusga perde tudo.

**F07 Golpe grande (cofre-forte do banco)**
1. Arrombar cofres de depósito até encher a chave.
2. Trocar a chave pelo cartão.
3. Juntar materiais e trocá-los pelo berbequim.
4. Abrir o cofre-forte.
5. Montar o berbequim, o que dispara um aviso a toda a cidade.
6. Defender a posição até o berbequim acabar.
7. Carregar o ouro.
8. Fugir num veículo com espaço.

Casos-limite:
- vários grupos e a polícia convergem no local;
- o carro rápido tem pouco espaço.

**F08 Carga/encomenda**
1. Encontrar carga.
2. Carregá-la num veículo compatível.
3. Vender a uma carrinha de contrabando, ou levar à base e desmontar para ganhar mais.

Caso-limite: alguns veículos não aceitam carga.

**F09 Ciclo semanal**
1. Acumular durante a semana.
2. Acontece a rusga federal.
3. O valor perdido converte-se em estatísticas permanentes.
4. Recomeçar com desbloqueios.

Caso-limite: compras caras perto do fim da semana são desperdício.

**F10 Passe de temporada**
1. Fazer trabalhos.
2. Ganhar moeda de temporada.
3. Gastá-la em recompensas (só na base ou na povoação).
4. Desbloquear a página seguinte pelo total gasto.

## Queixas recorrentes dos jogadores nas reviews

Frequência aproximada, por número de menções no agregador. A notícia turca confirma as 4 primeiras.

1. **Polícia demasiado forte, numerosa e agressiva** (~19 menções). É a queixa mais frequente.
2. **Jogar a solo é inviável**: grupos esmagam jogadores sozinhos (~19).
3. **Comunidade tóxica:** emboscadas nos receptadores e pontos de venda, mortes gratuitas (~16).
4. **Equilíbrio fraco:** polícia e grupos dominam (~16).
5. **Servidores com lag e desconexões; problemas de login no lançamento** (~14).
6. **Otimização fraca, quebras de FPS e crashes** (~14 / 13 / 12).
7. **Perda total semanal e rusgas offline sem proteção**: frustração implícita nos guias. Há relatos de itens perdidos ao sair do jogo.

Pontos positivos: o ciclo é viciante, tem muito potencial, é melhor com amigos e é grátis.

## Ângulo

Onde um jogo de telemóvel pode fazer melhor do que o ROB RUN:

- **Solo que funciona.** A maior queixa é ser obrigatório ter grupo e haver jogadores tóxicos. O GOLPE já é single-player, por isso a polícia e as gangues IA podem ser **justas e legíveis**: aviso antes da rusga, níveis de resposta previsíveis, rendição como opção válida.
- **Sessões curtas com risco real.** Um assalto deve durar 3–8 min. A perda deve ser parcial e compreensível: mochila vs equipamento vestido, dinheiro sujo vs limpo.
- **Progressão que não se apaga sem aviso.** As "temporadas" devem ser **opcionais**, com prestígio e cosmética, e nunca obrigatórias.
- **Sem rusgas offline injustas.** As bases são atacadas por IA só quando o jogador está presente, ou com aviso e defesa automática.
- **Emergência sem multijogador.** Avisos globais e eventos de cidade dão a sensação de "mundo vivo": a gangue rival tenta o cofre ao mesmo tempo, carrinha blindada, rusga policial a um distrito.
- **Polícia jogável como modo próprio offline.** Turnos curtos contra criminosos IA dão variedade sem os problemas de equilíbrio entre pessoas.
- **Desempenho em telemóvel modesto.** É uma queixa do original, por isso é uma vantagem directa para o GOLPE.

## Versão telemóvel

Como cada sistema deve adaptar-se a um telemóvel:

| Sistema | Adaptação para telemóvel |
|---|---|
| Controlo a pé | Joystick esquerdo e arrasto direito para câmara. Botão contextual grande (revistar/ameaçar/amarrar/arrombar). Mira assistida com bloqueio suave. |
| Condução | Botões acelerar/travar/travão de mão, ou inclinação opcional. A direção pode ser assistida. |
| Assaltos | Interações por "manter premido" com anel de progresso. Os minijogos (caixa elétrica, cofre) devem ser de toque e tempo, em menos de 10 s. Um assalto pequeno em 3–5 min, um grande em 10–15 min com checkpoints. |
| Inventário em grelha | Grelha maior com rotação por toque duplo. Botão "auto-arrumar" e "largar tudo o que é de valor baixo". Vibração ao encaixar. |
| Mapa | Filtros por ícone, *waypoint* com um toque, rota desenhada no minimapa. O mapa deve ser legível num ecrã de 6". |
| Polícia (IA e jogável) | Níveis de procurado com tempo de reação visível. No modo polícia, turnos de 10 min com salário no fim. |
| Economia / branqueamento | Fila de branqueamento que corre em segundo plano (*idle*) e notifica quando acaba. |
| Bases | Construção em grelha por toque, de cima. Defesas automáticas. As rusgas de IA só acontecem com aviso prévio. |
| Temporadas / passe | Temporadas de 4–6 semanas. A faixa grátis tem de ser generosa e a premium só cosmética. Nada de apagar o progresso principal. |
| Servidores | Hoje é single-player. Se houver online no futuro: salas pequenas (8–16), cooperação de 2–3, receptadores protegidos para evitar emboscadas. |
| Sessões | Gravação automática ao sair, ao esconder a app e ao entrar no esconderijo. Retomar a meio de uma fuga é arriscado, por isso faz-se retorno seguro ao último ponto. |
| Desempenho | Alvo de 30–60 fps em gama média: LOD agressivo, tráfego limitado e sombras simples. |
