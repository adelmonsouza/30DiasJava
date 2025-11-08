# 📝 Template de Post LinkedIn

## Formato Base (Inspirado em Karin Prater)

```
🚀 [Título Impactante] - Dia X/30 do #30DiasJava

[Contexto pessoal + O que aprendi hoje]

**O que construí hoje:**
[Resumo do projeto/feature]

**Por que isso importa:**
[Ligação com problema real ou conceito importante]

**Under the Hood:**
[Explicação técnica breve do "como funciona por dentro"]

**Próximos passos:**
[O que vem depois ou call to action]

🔗 Link do projeto: [GitHub link]
📖 Deep-dive completo: [Link do artigo/blog] (se houver)

---

Qual conceito de BigTech vocês gostariam de ver replicado?
Qual é o maior desafio de vocês em Java/Spring Boot?

Deixem nos comentários! 👇

#Java #SpringBoot #30DiasJava #Developer #Tech #Microsserviços #CleanCode #AdelmoDev
```

---

## Exemplo: Dia 1 - User-Profile-Service

```
🚀 Dia 1/30 do #30DiasJava: O que aprendi criando um Microsserviço de Usuários

Assim como a excelente Karin Prater ensina sobre iOS "under the hood", decidi aplicar a mesma abordagem em Java/Spring Boot.

**O que construí hoje:**
User-Profile-Service: um microsserviço completo inspirado em Facebook/X com Spring Boot 3.2, Java 21, JWT Security e PostgreSQL.

**Por que isso importa:**
DTOs não são opcionais! Aprender a separar Entidades de DTOs foi a diferença entre código inseguro e código profissional. Muitos devs expõem entidades JPA diretamente no Controller - isso é um risco de segurança (Mass Assignment).

**Under the Hood:**
O Spring Security + JWT funciona assim: quando você faz login, o servidor valida credenciais e gera um token JWT assinado. Esse token vai no header "Authorization: Bearer [token]" de cada requisição. O Spring intercepta isso, valida a assinatura e extrai as claims (roles, username) sem precisar consultar o banco a cada request.

**Próximos passos:**
Dia 2-3: Content Catalog API (Netflix/Spotify) com paginação eficiente e cache.

🔗 Projeto completo: github.com/adelmonsouza/user-profile-service
📖 Business Plan e README: Documentação completa no repositório

---

Qual funcionalidade de BigTech (Netflix, Spotify, Google) vocês gostariam de ver replicada?

#Java #SpringBoot #30DiasJava #Developer #Tech #Microsserviços #CleanCode #JWT #AdelmoDev
```

---

## Estrutura de Post por Tipo

### 🎯 Post de Lançamento (Dia 1)

**Foco:** Apresentar o desafio, mostrar ambição e convidar a comunidade

### 📚 Post Educacional (Dias 2-29)

**Foco:** Ensinar algo específico aprendido, compartilhar código/insight

### 🎉 Post de Celebração (Dia 30)

**Foco:** Retrospectiva, aprendizados, métricas, próximos passos

---

## 💡 Dicas para Maximizar Engajamento

1. **Horários ideais:** 9h-11h ou 15h-17h (horário de trabalho)
2. **Responda rápido:** Nos primeiros 30 minutos após publicação
3. **Hashtags:** 5-7 hashtags estratégicas (não exagere)
4. **Imagens:** Se possível, adicione screenshot do código ou diagrama
5. **Storytelling:** Conte uma pequena história (o problema que enfrentou, como resolveu)
6. **CTA claro:** Sempre termine com uma pergunta ou chamada para ação

---

## 📊 Calendário de Posts (7 primeiros dias)

### Dia 1 - Lançamento
**Tema:** Apresentação do desafio + User-Profile-Service

### Dia 2 - Foco Técnico
**Tema:** DTOs e por que são essenciais

### Dia 3 - Performance
**Tema:** Paginação e como evitar OOM

### Dia 4 - Arquitetura
**Tema:** Design Patterns aplicados

### Dia 5 - Testes
**Tema:** Testcontainers e testes de integração

### Dia 6 - DevOps
**Tema:** CI/CD com GitHub Actions

### Dia 7 - Retrospectiva Semanal
**Tema:** O que aprendi na primeira semana

---

**Crie consistência e valor. O segredo não é ser o melhor, é ser consistente! 🚀**


