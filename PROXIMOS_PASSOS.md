# 🚀 Próximos Passos - #30DiasJava

**Data:** 02/11/2025  
**Status:** ✅ 3 dias completos, continuando!

---

## 📅 Agenda Imediata

### Amanhã (03/11/2025) - Dia 3: Liberar Recommendation-Engine

**Tempo estimado:** 20 minutos

#### 1. Tornar Repositório Público ⏱️ 5 min
```bash
# Via GitHub CLI
gh repo edit adelmonsouza/30DiasJava-Day03-RecommendationEngine --visibility public

# Ou via GitHub Web:
# 1. Acesse: https://github.com/adelmonsouza/30DiasJava-Day03-RecommendationEngine
# 2. Settings → Danger Zone → Change visibility → Make public
```

#### 2. Adicionar Topics ⏱️ 2 min
```bash
gh repo edit adelmonsouza/30DiasJava-Day03-RecommendationEngine \
  --add-topic java \
  --add-topic spring-boot \
  --add-topic algorithms \
  --add-topic collaborative-filtering \
  --add-topic data-structures \
  --add-topic hashmap \
  --add-topic recommendation-system
```

#### 3. Publicar Post LinkedIn ⏱️ 10 min
- **Arquivo:** `LINKEDIN_POSTS/LinkedIn_Dia03_Recommendations.md`
- **Horário:** 9h-11h ou 15h-17h (melhor engajamento)
- **Ação:** Copiar, colar, publicar

#### 4. Atualizar README Principal ⏱️ 3 min
- Remover o 🔒 *Private* do README.md
- Atualizar link para público

---

## 🎯 Próximo Projeto: Dia 4 - Notification-Service

**Conceito:** Sistema de Notificações (Inspirado em WhatsApp/Telegram/Slack)

**Período:** Dias 6-7 (04-05/11/2025)

### Stack Tecnológica
- **Java 21**
- **Spring Boot 3.2+**
- **RabbitMQ** ou **Apache Kafka** (para filas)
- **Spring AMQP** (comunicação assíncrona)
- **PostgreSQL** (histórico de notificações)
- **Redis** (opcional - cache)

### Funcionalidades Core
1. **Enviar notificação** (push, email, SMS)
2. **Fila de mensagens** (RabbitMQ/Kafka)
3. **Retry automático** (tentativas)
4. **Dead Letter Queue** (mensagens falhadas)
5. **Histórico de notificações**

### Conceitos a Aplicar
- ✅ **Event-Driven Architecture** (Eventos assíncronos)
- ✅ **Message Queues** (RabbitMQ ou Kafka)
- ✅ **Desacoplamento** (Serviços não dependem uns dos outros)
- ✅ **Resiliência** (Retry, circuit breaker)
- ✅ **Idempotência** (Não enviar notificação duplicada)

### Estrutura do Projeto
```
notification-service/
├── src/main/java/com/adelmonsouza/notificationservice/
│   ├── controller/
│   │   └── NotificationController.java
│   ├── service/
│   │   ├── NotificationService.java
│   │   ├── EmailService.java
│   │   └── PushService.java
│   ├── consumer/
│   │   └── NotificationConsumer.java (RabbitMQ Listener)
│   ├── model/
│   │   └── Notification.java
│   ├── dto/
│   │   ├── NotificationRequestDTO.java
│   │   └── NotificationResponseDTO.java
│   └── config/
│       └── RabbitMQConfig.java
├── compose.yaml (RabbitMQ + PostgreSQL + Redis)
├── README.md
└── Business_Plan.md
```

---

## 📝 Artigos do Blog a Criar

### 1. Artigo Dia 3: Recommendation Engine (04/11)
**Título:** "Sistema de Recomendações Under the Hood: Como HashMap e Jaccard Similarity Funcionam"

**Tópicos:**
- Collaborative Filtering explicado
- Jaccard Similarity: o que é e por quê funciona
- HashMap: por que é perfeito para este caso
- Performance: O(n) vs O(n²)
- Trade-offs: Simplicidade vs Precisão

**Estrutura (estilo SwiftyPlace):**
- Hey there! Introdução
- Full disclosure sobre experiência
- Under the hood: algoritmos explicados
- Diagramas ASCII
- Exemplos de código
- Trade-offs comparados
- Takeaways

### 2. Artigo Dia 4: Notification Service (06/11)
**Título:** "Event-Driven Architecture: Como Filas Previnem Falhas em Cascata"

**Tópicos:**
- Por que mensageria é essencial
- RabbitMQ vs Kafka: quando usar cada um
- Dead Letter Queue: lidando com falhas
- Idempotência: evitando duplicatas
- Retry strategies

---

## ✅ Checklist Semanal (Dias 1-7)

### Dia 3 (03/11) - Liberar Recommendation-Engine
- [ ] Repositório tornado público
- [ ] Topics adicionados
- [ ] Post LinkedIn publicado
- [ ] README atualizado

### Dia 4 (04/11) - Iniciar Notification-Service
- [ ] Estrutura do projeto criada
- [ ] RabbitMQ configurado (compose.yaml)
- [ ] Model e DTOs criados
- [ ] Controller básico implementado

### Dia 5 (05/11) - Finalizar Notification-Service
- [ ] Service layer completo
- [ ] RabbitMQ Consumer implementado
- [ ] Testes unitários (≥80% cobertura)
- [ ] Testes de integração com Testcontainers
- [ ] README e Business Plan
- [ ] Docker e CI/CD

### Dia 6-7 (06-07/11)
- [ ] Artigo do blog (Recommendation Engine)
- [ ] LinkedIn Post (Notification Service)
- [ ] Repositórios criados no GitHub
- [ ] Tudo publicado

---

## 🎨 Melhorias Contínuas do Blog

### Posts Já Publicados ✅
1. ✅ DTOs Under the Hood (Dia 1)
2. ✅ Paginação Eficiente (Dia 2)
3. ⏳ Recommendation Engine (Dia 3) - Criar artigo

### Design do Blog
- ✅ CSS inspirado no SwiftyPlace
- ✅ Narrativa conversacional
- ✅ Explicações "under the hood"
- ✅ Diagramas ASCII
- ⏳ Adicionar ilustrações (SVG/PNG) nos próximos posts

---

## 📊 Status Atual

| Dia | Projeto | Status | Repositório | Artigo Blog | LinkedIn |
|-----|---------|--------|-------------|-------------|----------|
| 1 | User-Profile-Service | ✅ Completo | ✅ Público | ✅ Publicado | ✅ Publicado |
| 2-3 | Content-Catalog-API | ✅ Completo | ✅ Público | ✅ Publicado | ✅ Publicado |
| 4-5 | Recommendation-Engine | ✅ Completo | 🔒 Private | ⏳ Em breve | ⏳ 03/11 |
| 6-7 | Notification-Service | 🚧 Planejado | ⏳ Criar | ⏳ Criar | ⏳ Criar |

---

## 🚀 Ação Imediata (Agora)

1. ✅ **Blog atualizado** com posts reestruturados
2. ⏳ **Preparar artigo Dia 3** para publicação amanhã
3. ⏳ **Começar estrutura Dia 4** (Notification-Service)

---

## 💡 Dicas para o Próximo Projeto

### Notification-Service: O Que Estudar

**RabbitMQ vs Kafka:**
- **RabbitMQ:** Melhor para notificações individuais, mais simples
- **Kafka:** Melhor para high-throughput, event streaming

**Para este projeto:** Começar com RabbitMQ (mais simples, suficiente)

**Recursos:**
- [Spring AMQP Documentation](https://spring.io/projects/spring-amqp)
- [RabbitMQ Tutorials](https://www.rabbitmq.com/getstarted.html)
- [Event-Driven Architecture Patterns](https://microservices.io/patterns/data/event-driven-architecture.html)

---

## 📝 Notas Importantes

1. **Consistência > Perfeição:** Melhor publicar algo bom do que esperar perfeito
2. **Documentar decisões:** Business Plan explica "por quê", não apenas "como"
3. **Testes primeiro:** ≥80% cobertura é não-negociável
4. **Blog é marketing:** Artigos técnicos aumentam visibilidade profissional

---

**Próxima atualização:** Após liberar Dia 3 (03/11) 🚀

