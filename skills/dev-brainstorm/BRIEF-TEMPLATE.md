# BRIEF Template

Salvar em `.plans/<feature-slug>/BRIEF.md`. Atualizar ao vivo durante o grilling.

---

```markdown
---
feature: <kebab-case-slug>
status: brainstorming | ready-for-plan
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
---

# BRIEF — <Feature Title>

## Problema
<3-5 linhas. Qual dor real, na perspectiva de quem sente. Sem solução aqui.>

## Solução (high-level)
<1-2 frases. O que queremos que exista depois disso, ainda do ponto de vista do usuário.>

## Goals (comportamentos observáveis)
- <Algo que vai estar verdadeiro depois — observável de fora>
- <Outro algo verificável>

## Non-Goals (out of scope agora)
- <O que explicitamente NÃO está incluso nesta iteração>
- <Risco comum de scope creep que estamos cortando>

## Constraints
- **Stack:** <restrições técnicas relevantes>
- **Performance:** <SLAs, latência, throughput se importam>
- **Compliance:** <LGPD, segurança, auditoria se aplica>
- **Prazo:** <se houver>

## Glossário (termos do domínio)
- **<Termo>:** <definição precisa neste contexto>
- **<Termo>:** <definição>

> Se o projeto tem CONTEXT.md ou glossário canônico, citar aqui em vez de redefinir.

## Decisões tomadas no grilling
- **<Decisão 1>** — <1 linha do porquê>
- **<Decisão 2>** — <1 linha do porquê>

## Open Questions (precisam de resposta antes do plano)
- **Q1:** <pergunta> — *proposed:* <resposta sugerida>
- **Q2:** <pergunta> — *needs:* <user / discovery / código>

## Edge cases identificados
- <Cenário X — como reagir>
- <Cenário Y — fora de escopo, justificar>

## Áreas do código afetadas (suspeita)
- `<path/area>` — <o que provavelmente muda aqui>
- `<path/area>` — <o que provavelmente muda aqui>

## Riscos
- **<Risco>** — <impacto + mitigação proposta>

## Próximo passo
`/dev-plan` para transformar este BRIEF em PLAN.md atômico.
```

---

## Notas

- **Atualizar ao vivo.** Cada decisão que cristaliza vira linha aqui imediatamente.
- **Não documentar implementação.** Como vai ser construído fica no PLAN.md.
- **Curto.** BRIEF é 1 página, no máximo 1.5. Se passou disso, ou já é PLAN.md ou tem ruído.
- **Não duplicar CLAUDE.md.** Convenções já documentadas no projeto não entram aqui.
