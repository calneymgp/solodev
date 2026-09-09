---
name: dev-plan
description: Transforma um BRIEF (ou ideia já discutida) em PLAN.md atômico — tasks com critério verificável, vertical slices, must-haves observáveis, esforço estimado e pontos de reset de contexto. Sem código no plano. Auto-suficiente para reset — uma nova sessão consegue retomar lendo só o PLAN.md. Use quando o usuário disser "/dev-plan", "monta o plano", "transforma em plano", "vamos planejar", "quero plano atômico", "preciso resetar contexto e ter o plano pronto", ou pedir para estruturar tasks/subtasks após brainstorming.
---

# /dev-plan — Plano atômico, reset-friendly, sem código

Esta skill produz `.plans/<feature>/PLAN.md` — um documento auto-suficiente. Uma sessão nova de Claude Code, lendo só esse arquivo + o CLAUDE.md do projeto, deve conseguir executar a feature inteira via `/dev-coding`.

## Princípios não-negociáveis

1. **Sem código no plano.** Sem snippets de implementação, sem TypeScript, sem SQL. Apenas: decisões, áreas afetadas, contratos de interface (prose), critérios de aceite verificáveis. Exceção rara: snippet de tipo/schema/state-machine quando isso encoda a decisão de forma mais precisa que prosa.

2. **Tasks atômicas com critério verificável.** Cada task tem `acceptance` que pode ser checada via grep / build / test, não "feito quando funcionar".

3. **Vertical slices preferidos.** Cada task corta TODAS as camadas (schema → API → UI → test) em uma fatia fina, NÃO uma camada inteira por vez. Antipadrão: task-01 = todos os models, task-02 = todas as APIs, task-03 = toda UI.

4. **Reset protocol embutido.** O plano contém a seção `## Reset Protocol` no fim — instruções para sessão nova retomar do zero.

5. **Karpathy mínimo necessário.** Não invente fases, milestones, OKRs, riscos especulativos. Se a feature cabe em 5 tasks, são 5 tasks — não invente sub-sprints.

6. **Decisão sem evidência é chute.** Toda decisão material registra escolha + alternativa descartada + motivo em 1 linha. Por quê: o executor (você pós-`/clear`, ou outra sessão) não deve reinventar tradeoffs já feitos — nem descobrir tarde que havia uma opção melhor.

7. **Nada executa sem Approve.** O plano é apresentado uma vez, o usuário responde `Approve` / `Changes` / `Cancel`, e só então alguém executa. Por quê: corrigir granularidade no plano custa 1 turn; corrigir no meio do `/dev-coding` custa a sessão.

## Processo

### 1. Carregue contexto

Em ordem:
1. **Read** `.plans/<feature>/BRIEF.md` se existir → fonte primária
2. **Read** `CLAUDE.md` do projeto + sub-CLAUDEs relevantes (ex.: `src/app/CLAUDE.md`)
3. **Read** glossário/schema/CONTEXT do projeto se aplicável
4. Se não houver BRIEF, faça grilling rápido (3-5 perguntas críticas) — modo `/dev-brainstorm` condensado

Antes de explorar, **mapeie as decisões materiais**: quais escolhas (lib, API, approach, contrato, estratégia de migração) este plano precisa fechar? Só essas entram em `## Decisions` / `## Discovery`. Todo o resto é padrão do projeto — não documente o óbvio.

### 2. Explore o codebase (read-only)

Grep + Read das áreas afetadas. Não escreva nada de código ainda — só entenda:
- Padrões atuais (convenções, estilo, testes)
- Pontos de extensão naturais
- Dependências que vão ser tocadas
- Riscos de quebra (migrations, contratos públicos, schemas)

Trate um BRIEF ou plano anterior como navegação, não evidência: verifique no código atual o que eles afirmam antes de assumir como fato.

### 3. Discovery (quando há unknown)

Se há decisão pendente sobre lib / API / approach que o BRIEF não fechou, ativar **discovery curto**:
- 1-3 fontes: docs oficiais > Context7 > web search
- **Fonte conta só se inspecionada.** Resumo de busca, índice ou lista de candidatos localiza a fonte, não completa o research. Abra o conteúdo (doc oficial, repo, spec) e guarde a URL exata.
- Saída na seção `## Discovery` do PLAN com: recomendação + 1-2 alternativas descartadas (com motivo) + nível de confiança (high/medium/low) + URLs inspecionadas
- **Se o conteúdo estiver indisponível** (paywall, 404, fetch falhou): marque a recomendação como `⚠️ condicional` e registre o gap — não invente versão, API ou comportamento

**Quando NÃO fazer discovery:** padrão já estabelecido no projeto, decisão trivial, ou o BRIEF já fechou.

### 4. Quebra em tasks (vertical slices)

Heurísticas de granularidade:
- **2-5 subtasks por task.** Se passou disso, divida.
- **1 task = 1 vertical slice demoável.** Após completar, algo observável melhorou (mesmo que feature flag).
- **Tasks independentes em paralelo** se não compartilham arquivos.
- **Tasks com dependência genuína** marcam `depends_on`.

Tipos de task:
- `auto` — Claude consegue executar fim-a-fim sozinho
- `tdd` — vale red-green-refactor (heurística: dá pra escrever `expect(fn(in)).toBe(out)` antes de `fn`?)
- `checkpoint:decision` — pausa para o user escolher entre opções
- `checkpoint:human-verify` — pausa para o user testar visualmente / em produção

Campos novos por task:
- **effort:** `S` (minutos) | `M` (até ~1h) | `L` (1 sessão). Se alguma task é L, provavelmente deve ser dividida.
- **rollback:** OBRIGATÓRIO para task que toca migration, contrato público, dado de produção ou config de deploy. 1 linha: como desfazer. Tasks sem risco: omitir o campo.

### 5. Pontos de reset de contexto

Contexto é recurso finito. Marque no plano onde vale resetar:

- Após tasks que geram muito ruído de exploração (discovery, leitura de schema grande), insira a linha `> 🔄 bom ponto de /clear — o plano carrega o resto` entre tasks.
- Heurística: feature com 6+ tasks → pelo menos 1 ponto de reset no meio.
- O PLAN.md é a memória externa; a sessão é descartável. É isso que torna o reset barato.

### 6. Defina Must-Haves (goal-backward)

Após listar tasks, escreva o que precisa ser VERDADE quando tudo acabar. 3 categorias enxutas:
- **Truths:** behaviors observáveis (ex.: *"user consegue criar X via UI"*)
- **Artifacts:** arquivos que devem existir com substância real (ex.: `src/foo/bar.ts` > 30 linhas, exporta `[X, Y]`)
- **Key Links:** conexões críticas via regex (ex.: `src/api/route.ts` faz `fetch('/api/x')` — regex `fetch\(['"]/api/x`)

Mais uma, nova:
- **Demo script:** 3-6 passos para demonstrar a feature funcionando em até 60 segundos (comando + o que observar). Se você não consegue escrever o demo script, a feature não tem critério de pronto observável — volte aos Goals.

Por que isso importa: task ✅ ≠ goal ✅. Uma task "criar componente Chat" pode "completar" criando um placeholder vazio. Must-Haves capturam o que precisa funcionar de verdade.

### 7. Riscos globais (curto, 3-5 linhas)

Além do `rollback` por task, o plano tem UMA seção `## Risks` global:
- Impacto de compatibilidade (o que quebra fora da feature, se algo)
- Condição de abort (quando parar em vez de improvisar — ex.: "se a migration X falhar em staging, abortar, não tentar reparo manual")

Se não há risco sistêmico, escreva `Nenhum — risco isolado por task (ver rollbacks)`. Não invente riscos especulativos.

### 8. Escreva o PLAN.md

Use [PLAN-TEMPLATE.md](PLAN-TEMPLATE.md) como esqueleto. Resultado final em `.plans/<feature>/PLAN.md`, salvo com `status: draft`.

Antes de apresentar, **releia o arquivo salvo** e cheque: tasks cobrem os Goals? Cada task tem `acceptance` verificável? Tasks de risco têm `rollback`? `## Decisions` tem alternativa descartada? Não apresente um plano que você não auditou.

### 9. Quiz + aprovação (1 turn)

Apresente ao usuário em 1 mensagem:
- Lista numerada de tasks (título + tipo + effort + 1 linha do que faz)
- Esforço total estimado (soma dos S/M/L)
- Decisões materiais fechadas (1 linha cada)
- Pergunta: *"Granularidade ok? Alguma task deveria ser dividida ou fundida? Algum critério de aceite que vai falhar como `must_pass`?"*

E finalize pedindo explicitamente: **`Approve` / `Request changes` / `Cancel`**.

Depois pare. Não execute nenhuma task, não edite código, não rode comandos de implementação até o Approve explícito. Em `Request changes`, revise, re-audite e apresente de novo. Em `Cancel`, pare. No Approve, vire o frontmatter para `status: ready`.

## Variantes (quando não é feature)

O template default é implementação. Para os dois casos abaixo, adapte as seções — sem criar cerimônia nova:

**Debug** (`type: debug` no frontmatter): troque `## Tasks` por hipóteses falsificáveis — cada item tem hipótese / observação necessária / evidência que confirma ou refuta. Must-Haves viram "reprodução + evidência de causa". O resto (Discovery, Risks, Reset Protocol) continua igual.

**Migração/rollout** (`type: migration` no frontmatter): tasks viram fases com gates (fase N só começa se `<condição>`); `## Risks` ganha monitoramento + impacto visível ao usuário; cada fase tem `rollback` obrigatório.

Se não é nenhum dos três (feature, debug, migração), o default de feature provavelmente serve — não invente um quarto template sem motivo real.

## Estrutura recomendada do diretório

```
.plans/<feature>/
├── BRIEF.md          (output de /dev-brainstorm — opcional)
├── PLAN.md           (output desta skill — source of truth)
├── DISCOVERY.md      (opcional, quando lib choice precisa de research)
└── SUMMARY.md        (output de /dev-ship ao terminar)
```

## Critérios de aceite (escrever bem)

Bom critério de aceite:
- ✅ `src/foo/bar.ts` exporta `someFn` (grep verificável)
- ✅ `<test runner> test foo` passa (`npm test`, `pytest tests/foo`, `cargo test foo`, etc.)
- ✅ Endpoint `POST /api/x` retorna 201 com body válido em smoke
- ✅ Migration `2026XX_foo.sql` cria tabela `foo` com PK `id uuid`

Mau critério de aceite:
- ❌ "Funciona corretamente"
- ❌ "Está bem implementado"
- ❌ "Sem regressão"
- ❌ "User pode usar a feature"

## Anti-padrões

- ❌ **Snippets de implementação no PLAN.md** (vai stale rápido — código vive em código)
- ❌ **Tasks horizontais** (task-01 = "todos os models" → mata paralelismo, esconde bugs de integração)
- ❌ **Critério vago** ("funciona", "está ok", "user consegue usar")
- ❌ **Reflexive chaining** (task-03 `depends_on: [02]` só porque vem depois)
- ❌ **Sem `read_first`** (executor modifica arquivo sem ler estado atual)
- ❌ **Fases/sprints/epics inventados** (solo dev — chama de task e subtask)
- ❌ **Documentar coisa que CLAUDE.md já documenta** (DRY com o repo)
- ❌ **Must-Haves de mais** (3-5 truths, não 20 — caso contrário não testamos no fim)
- ❌ **Task com migration sem `rollback`** (o campo existe para te salvar às 23h de uma sexta)
- ❌ **Decisão sem alternativa descartada** ("usamos X" sem dizer por que não Y — o tradeoff volta pra te morder no meio da execução)
- ❌ **Discovery por resumo de busca** (listar fonte que você não abriu — recomendação vira chute com link bonito)
- ❌ **Executar antes do Approve** (começar a task-01 "enquanto isso" — o gate existe porque replan é mais barato que rework)

## Plan Mode interaction

Esta skill funciona bem dentro do Plan Mode do Claude Code. Se você está em plan mode:
1. Faça toda exploração e discovery
2. Escreva o PLAN.md (`status: draft`), re-audite, apresente via `ExitPlanMode`
3. Após aprovação, vire para `status: ready` em `.plans/<feature>/PLAN.md` e sugira `/dev-coding`

Se NÃO está em plan mode: escreva o arquivo (`status: draft`), re-audite, apresente o quiz + gate de aprovação — e só considere fechado após o Approve explícito.

## Próximo passo

Após Approve (com `status: ready` já virado):

> *"PLAN.md aprovado e salvo em `.plans/<feature>/PLAN.md`. Pronto pra `/dev-coding` executar task-01? Você pode resetar contexto agora — o plano é auto-suficiente."*
