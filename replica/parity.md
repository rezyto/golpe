# Paridade — GOLPE (v0.4–0.6) face às mecânicas do ROB RUN

Base de cálculo: `features.csv`, com 93 funcionalidades.

- **Pesos por prioridade:** must = 3, should = 2, could = 1.
- **Pontuação de cada funcionalidade:** yes = 100% do peso, partial = 50%, no = 0.

## Pontuação global

**86,5 / 187 = 46%**

## Must-haves

- **16 / 24 completos**
- 6 parciais
- 2 em falta

Os 2 em falta:
- áudio;
- dinheiro sujo/limpo com branqueamento.

Os 6 parciais:
- estado civil/criminoso pela máscara;
- rendição vs morte;
- separar mochila de equipamento vestido;
- variedade de armas;
- cidade costeira com bairros de papel distinto;
- mapa com filtros.

## Por área (da mais fraca para a mais forte)

| Área | Pontos | % |
|---|---|---|
| Personagem | 0 / 2 | 0% |
| Temporadas | 0 / 5 | 0% |
| UX (áudio) | 0 / 3 | 0% |
| Clãs | 1 / 6 | 17% |
| Combate | 3,5 / 13 | 27% |
| Eventos | 2 / 6 | 33% |
| Ferramentas | 4 / 11 | 36% |
| Bases | 6 / 16 | 38% |
| Veículos | 6 / 15 | 40% |
| Polícia | 6 / 15 | 40% |
| Economia | 7 / 15 | 47% |
| Mapa | 8 / 17 | 47% |
| Multijogador | 3 / 6 | 50% (*) |
| Progressão | 6 / 11 | 55% |
| Assaltos | 21,5 / 31 | 69% |
| Inventário | 12,5 / 15 | 83% |

(*) O multijogador está fora do âmbito do GOLPE single-player. Se retirarmos as 3 linhas "could" de multijogador, a pontuação global sobe para cerca de 47%.

## O que falta, por ordem de construção recomendada

1. **Áudio base:** tiros, sirenes, alarmes, motores e música de tensão. É must e multiplica a sensação de risco de tudo o resto.
2. **Estado civil/criminoso + rendição + perda separada.**
   - A máscara ativa o estado criminoso, que só se limpa a sair da cidade.
   - Render-se faz perder a mochila e manter o equipamento vestido.
   - Morrer como criminoso faz perder tudo.
   - Assenta em sistemas que já existem (inventário, procurado).
3. **Dinheiro sujo vs limpo.**
   - Mesa de branqueamento no esconderijo, com fila *idle*.
   - Conta bancária e multibancos espalhados pelo mapa.
   - Bónus de venda por notoriedade.
4. **Combate de sobrevivência:** armadura com placas, consumíveis médicos, munição, silenciador e slots rápidos.
5. **Mapa:**
   - filtros de marcadores;
   - frente de mar ou zona balnear;
   - bairro de elite com **moradias assaltáveis**;
   - contentores do lixo como saque de entrada;
   - carro de aluguer grátis em terminais.
6. **Golpes grandes em cadeia.**
   - Os cofres de depósito enchem uma chave, a chave dá um cartão e o cartão abre o cofre-forte.
   - Os outros alvos únicos usam ferramentas especiais.
   - **Avisos à cidade** que fazem convergir polícia e gangues IA.
   - Inclui **troca direta** de itens "cheios" por ferramentas raras.
7. **Veículos utilitários:** carrinha com espaços de carga, **encomendas/carga** para vender ou desmontar, e melhorias (turbo, direção, bagageira).
8. **Polícia mais rica:**
   - subornos pagos com dinheiro limpo;
   - prisão com estatística persistente;
   - infrações de trânsito;
   - bloqueios nas pontes;
   - depois, **modo polícia jogável offline**: turno curto, salário, distintivos.
9. **Ciclo dia/noite:** a noite deve ter menos peões e mais risco ou recompensa.
10. **Base modular:** edifícios, painéis de defesa com fusíveis e alarmes, **rusgas de gangues IA com aviso**, produção (estufa/laboratório) e bancada para desmontar e fabricar.
11. **Pesquisa / documentos:** desbloqueios de ferramentas e de terrenos por patamar e níveis de distrito.
12. **Clã IA:** recrutar membros com cargos, impostos de território, guerras e tréguas com as gangues.
13. **Personalização da personagem e cosmética.** Depois disto: passe de temporada cosmético e temporadas opcionais com prestígio.
14. **Extras "could":** casino/roleta, discoteca, helicóptero, granadas, fuga pela água, conquistas.

## Veredicto honesto

**Onde o GOLPE está forte:** na **metade "assalto"** do género. Tem interiores com camadas de segurança, inventário em grelha, raridade, receptadores com balcão arriscado, bagageiras e territórios básicos. Está ao nível do original, ou acima em polimento de alvos (amarrar, sensores, contagem da rusga).

**Onde está fraco:** falta-lhe quase toda a **metade "o que fazer com o dinheiro e porque é arriscado guardá-lo"**. Em concreto:
- não há branqueamento nem banco;
- não há base que se constrói e se defende;
- não há produção;
- não há cadeias de ferramentas;
- não há meta-ciclo de temporadas.

É essa metade que, no ROB RUN, dá objetivos para dias.

**O vazio mais grave é o som.** Um jogo de crime sem sirenes nem tiros audíveis não transmite tensão, e é must.

**O GOLPE não precisa (nem deve) copiar:**
- o multijogador massivo;
- os *wipes* semanais obrigatórios;
- as rusgas offline.

Estas são precisamente as fontes das queixas mais frequentes, a par da polícia esmagadora e do solo inviável.

**Com os passos 1–6 feitos**, a paridade ponderada sobe para cerca de 65–70%, e o GOLPE passa a ter um ciclo completo para solo em telemóvel. Isso é um ângulo melhor do que perseguir 100% de paridade.
