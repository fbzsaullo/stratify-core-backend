# stratify-core-backend

Rails 7 API — Core da plataforma Stratify. Responsável por autenticação, persistência de feedbacks e orquestração.

## Stack
- Ruby on Rails 7 (API Mode)
- PostgreSQL 16
- Redis (Event Bus no MVP)
- Docker Compose (Ubuntu + Windows)

## Quick Start

```bash
docker compose up -d
```

A API estará disponível em `http://localhost:3000`.

## Lembre-se
- Leia `docs/` antes de implementar qualquer feature
- Este serviço NUNCA analisa eventos brutos
- Apenas persiste `FeedbackGenerated` e serve dados ao Desktop Client
