# 🚀 #30DiasJava - Desafio de Aprendizado Contínuo

![Java](https://img.shields.io/badge/Java-21-orange?logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2+-brightgreen?logo=spring&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue?logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Status](https://img.shields.io/badge/Status-Em%20Andamento-success)

**Início:** 01/11/2025  
**Autor:** [Adelmon Souza](https://github.com/adelmonsouza)

---

## 🎯 Sobre o Desafio

Este repositório contém **30 projetos Java/Spring Boot**, um para cada dia, inspirados em conceitos de **BigTechs** (Netflix, Spotify, Google, X, Facebook) e aplicando as **melhores práticas profissionais** do mercado.

Cada projeto é um **produto completo** com:
- ✅ Código funcional pronto para produção
- ✅ Testes unitários e de integração (≥80% cobertura)
- ✅ Documentação técnica completa
- ✅ Business Plan explicando decisões arquiteturais
- ✅ Docker e CI/CD configurados
- ✅ Deep-dive técnico no blog [The Java Place](https://enouveau.io)

---

## 📚 Blog & Conteúdo

**🌐 Blog:** [The Java Place](https://enouveau.io)  
**📖 Artigos técnicos** explicando o "under the hood" de cada projeto

---

## 📦 Projetos Implementados

### ✅ Dia 1: User-Profile-Service
**Conceito:** Microsserviço de Gerenciamento de Usuários (Inspirado em Facebook/X)

- **Tecnologias:** Java 21, Spring Boot 3.2+, PostgreSQL, JWT, Docker
- **Conceitos:** DTOs, Thin Controllers, Spring Security, JWT Authentication
- **Repositório:** [github.com/adelmonsouza/user-profile-service](https://github.com/adelmonsouza/user-profile-service)
- **Link Local:** [user-profile-service/](./user-profile-service/)
- **Artigo:** [DTOs Under the Hood](https://enouveau.io/blog/2025/11/01/dtos-under-the-hood.html)

---

### ✅ Dia 2-3: Content-Catalog-API
**Conceito:** API de Catálogo de Conteúdo (Inspirado em Netflix/Spotify)

- **Tecnologias:** Java 21, Spring Boot 3.2+, PostgreSQL, Spring Data JPA, Paginação
- **Conceitos:** Paginação Eficiente, Performance, Spring Data JPA, Índices de Banco
- **Repositório:** [github.com/adelmonsouza/30DiasJava-Day02-ContentCatalog](https://github.com/adelmonsouza/30DiasJava-Day02-ContentCatalog)
- **Link Local:** [content-catalog-api/](./content-catalog-api/)
- **Artigo:** [Paginação Eficiente no Spring Boot](https://enouveau.io/blog/2025/11/02/pagination-under-the-hood.html)

---

### ✅ Dia 4-5: Recommendation-Engine
**Conceito:** Sistema de Recomendações (Inspirado em Amazon/Netflix)

- **Tecnologias:** Java 21, Spring Boot 3.2+, PostgreSQL, Algoritmos
- **Conceitos:** Collaborative Filtering, Jaccard Similarity, Estruturas de Dados (HashMap, Set)
- **Repositório:** [github.com/adelmonsouza/30DiasJava-Day03-RecommendationEngine](https://github.com/adelmonsouza/30DiasJava-Day03-RecommendationEngine) 🔒 *Private (liberar 03/11)*
- **Link Local:** [recommendation-engine/](./recommendation-engine/)
- **Artigo:** Em breve

---

## 🗓️ Status dos Projetos

| Dia | Projeto | Conceito BigTech | Status | Repositório |
|-----|---------|------------------|--------|-------------|
| 1 | User-Profile-Service | Facebook/X | ✅ Completo | [30DiasJava-Day01](https://github.com/adelmonsouza/30DiasJava-Day01-UserProfileService) |
| 2-3 | Content-Catalog-API | Netflix/Spotify | ✅ Completo | [30DiasJava-Day02](https://github.com/adelmonsouza/30DiasJava-Day02-ContentCatalog) |
| 4-5 | Recommendation-Engine | Amazon/Netflix | ✅ Completo 🔒 | [30DiasJava-Day03](https://github.com/adelmonsouza/30DiasJava-Day03-RecommendationEngine) |
| 6-30 | Em planejamento | - | 🚧 Aguardando | - |

**Veja o plano completo em:** [PROJETOS_30DIAS.md](./PROJETOS_30DIAS.md)

---

## 🛠️ Stack Tecnológica

### Core
- **Java 21** - Linguagem principal
- **Spring Boot 3.2+** - Framework principal
- **PostgreSQL 15** - Banco de dados

### Arquitetura & Padrões
- **Microsserviços** - Arquitetura distribuída
- **Design Patterns** - Clean Code, SOLID, Repository, DTO
- **RESTful APIs** - Arquitetura de serviços

### Qualidade & Testes
- **JUnit 5** - Testes unitários
- **Mockito** - Mocks e stubs
- **Testcontainers** - Testes de integração com containers reais

### DevOps & Cloud
- **Docker** - Containerização
- **GitHub Actions** - CI/CD
- **Spring Actuator** - Monitoramento

---

## 📋 Estrutura do Repositório

```
30DiasJava/
├── user-profile-service/      # Projeto Dia 1 ✅
│   ├── src/                   # Código fonte
│   ├── Business_Plan.md       # Plano de negócios
│   ├── README.md              # Documentação do projeto
│   ├── Dockerfile             # Containerização
│   └── compose.yaml           # Docker Compose
│
├── content-catalog-api/       # Projeto Dia 2-3 ✅
│   ├── src/                   # Código fonte
│   ├── Business_Plan.md       # Plano de negócios
│   ├── README.md              # Documentação do projeto
│   ├── Dockerfile             # Containerização
│   └── compose.yaml           # Docker Compose
│
├── recommendation-engine/     # Projeto Dia 4-5 ✅
│   ├── src/                   # Código fonte
│   ├── Business_Plan.md       # Plano de negócios
│   ├── README.md              # Documentação do projeto
│   ├── Dockerfile             # Containerização
│   └── compose.yaml           # Docker Compose
│
├── THE_JAVA_PLACE/            # Blog (Jekyll)
│   ├── _posts/                # Artigos técnicos
│   └── _config.yml            # Configuração Jekyll
│
├── TEMPLATES/                 # Templates reutilizáveis
│   ├── Business_Plan_Template.md
│   ├── README_Template.md
│   └── LinkedIn_Post_Template.md
│
├── LINKEDIN_POSTS/            # Posts do LinkedIn
└── PROJETOS_30DIAS.md         # Plano completo dos 30 dias
```

---

## 🚀 Como Usar Este Repositório

### Para Estudar

1. **Explore os projetos** - Cada projeto está em sua própria pasta
2. **Leia o Business Plan** - Entenda as decisões arquiteturais
3. **Veja o código** - Analise a implementação
4. **Leia os artigos** - Deep-dives técnicos no blog

### Para Executar

Cada projeto tem um README próprio com instruções. Exemplo:

```bash
# Entrar no projeto
cd user-profile-service

# Subir banco de dados
docker-compose up -d

# Executar aplicação
./mvnw spring-boot:run
```

---

## 📊 Métricas & Objetivos

### Por Projeto
- ✅ Cobertura de testes ≥ 80%
- ✅ Latência da API < 100ms
- ✅ Documentação completa
- ✅ Docker configurado
- ✅ CI/CD funcional

### Meta do Desafio
- 🎯 30 projetos em 30 dias
- 🎯 1 artigo técnico por projeto
- 🎯 1 post no LinkedIn por dia
- 🎯 Portfólio GitHub consistente

---

## 🔗 Links Importantes

### Social & Blog
- **GitHub:** [@adelmonsouza](https://github.com/adelmonsouza)
- **LinkedIn:** [adelmonsouza](https://www.linkedin.com/in/adelmonsouza/)
- **Blog:** [The Java Place](https://enouveau.io)

### Recursos
- 📖 [Plano Completo dos 30 Dias](./PROJETOS_30DIAS.md)
- 📝 [Templates de Documentação](./TEMPLATES/)
- 💼 [Business Plans dos Projetos](./user-profile-service/Business_Plan.md)

### Repositórios Individuais
- 🚀 [Day 01 - User-Profile-Service](https://github.com/adelmonsouza/30DiasJava-Day01-UserProfileService)
- 🚀 [Day 02 - Content-Catalog-API](https://github.com/adelmonsouza/30DiasJava-Day02-ContentCatalog)
- 🚀 [Day 03 - Recommendation-Engine](https://github.com/adelmonsouza/30DiasJava-Day03-RecommendationEngine) 🔒

---

## 🎓 O Que Você Vai Aprender

### Arquitetura
- Microsserviços e comunicação entre serviços
- Design Patterns aplicados
- Clean Architecture e SOLID
- Event-Driven Architecture

### Spring Boot (Under the Hood)
- Ciclo de vida de Beans
- Auto-configuração
- Spring Security e JWT
- Spring Data JPA avançado

### DevOps & Cloud
- Docker e Docker Compose
- Kubernetes (planejado)
- CI/CD com GitHub Actions
- Deploy na Cloud (AWS/Azure/GCP)

### Qualidade & Testes
- Testes unitários com JUnit 5
- Testes de integração com Testcontainers
- Cobertura de código com JaCoCo
- Mocks e Stubs com Mockito

---

## 💡 Inspiração

Este desafio é inspirado no trabalho de:
- **Karin Prater** ([SwiftyPlace](https://swiftyplace.com)) - Abordagem "under the hood" e foco em qualidade

---

## 📝 Licença

Este repositório é para fins educacionais e demonstração de habilidades técnicas.

---

## 🤝 Contribuições

Sugestões e feedback são bem-vindos! Abra uma issue ou entre em contato.

---

---

## 📈 Estatísticas do Desafio

![Progresso](https://img.shields.io/badge/Progresso-3%2F30%20Projetos-blue)
![Cobertura de Testes](https://img.shields.io/badge/Cobertura%20de%20Testes-%3E80%25-success)
![Build Status](https://img.shields.io/badge/Build-Passing-success)
![Status](https://img.shields.io/badge/Status-10%25%20Completo-success)

---

## 🌟 Contribuições

[![GitHub stars](https://img.shields.io/github/stars/adelmonsouza/30DiasJava?style=social)](https://github.com/adelmonsouza/30DiasJava/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/adelmonsouza/30DiasJava?style=social)](https://github.com/adelmonsouza/30DiasJava/network/members)
[![GitHub watchers](https://img.shields.io/github/watchers/adelmonsouza/30DiasJava?style=social)](https://github.com/adelmonsouza/30DiasJava/watchers)

---

**#30DiasJava | #SpringBoot | #Microsserviços | #CleanCode | #JavaDeveloper**

---

**🚀 Começando em 01/11/2025 - Acompanhe a jornada!**

[![GitHub](https://img.shields.io/badge/GitHub-adelmonsouza-181717?logo=github)](https://github.com/adelmonsouza)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-adelmonsouza-0077B5?logo=linkedin)](https://www.linkedin.com/in/adelmonsouza/)
[![Blog](https://img.shields.io/badge/Blog-The%20Java%20Place-black?logo=rss)](https://enouveau.io)
