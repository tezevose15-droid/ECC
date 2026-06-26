**Язык:** [English](README.en.md) | **Русский (CICADA_V)**

![ECC — операционная система агентного ИИ](assets/hero.png)

[![Stars](https://img.shields.io/endpoint?url=https%3A%2F%2Fapi.ecc.tools%2Fbadge%2Fstars&style=flat)](https://github.com/affaan-m/ECC/stargazers)
[![Forks](https://img.shields.io/endpoint?url=https%3A%2F%2Fapi.ecc.tools%2Fbadge%2Fforks&style=flat)](https://github.com/affaan-m/ECC/network/members)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> **211.9K+ звёзд** | **32.5K+ форков** | **230+ контрибьюторов** | **67 агентов** | **271 навык** | **12+ языков**

---

```
◬ CICADA_V: ECC — это не просто плагин.
ECC — это харнес-операционная система.
Мы не настраиваем агентов — мы вооружаем их.
      3301 ◬
```

---

**Что это такое.**

Everything Claude Code — зрелая платформа для работы с AI-агентами: 67 специализированных агентов, 271 рабочий навык, система памяти, непрерывное обучение, сканер безопасности, кросс-харнесная совместимость.

Работает везде. **Claude Code, Codex, Cursor, OpenCode, Gemini, Zed, GitHub Copilot** — одна архитектура, семь оболочек.

v2.0.0: 10+ месяцев полевых испытаний в production. 66 агентов, 268 навыков, control-plane на Rust, операторские workflow, Discord-сообщество.

---

## Быстрый старт

```bash
git clone https://github.com/tezevose15-droid/ECC.git
cd ECC
npm install

# Рекомендовано: установка плагина
/plugin marketplace add https://github.com/affaan-m/ECC
/plugin install ecc@ecc

# Или вручную — только то, что нужно
./install.sh --profile minimal --target claude
```

После установки:

```bash
/ecc:plan "Добавить auth"
/code-review
/security-scan
```

67 агентов, 271 навык, 92 команды — готово.

---

## Структура

```
ECC/
├── agents/          # 67 субагентов
│   ├── planner.md         # Планирование
│   ├── architect.md       # Архитектура
│   ├── tdd-guide.md       # TDD
│   ├── code-reviewer.md   # Ревью кода
│   ├── security-reviewer.md # Безопасность
│   └── ... 62+
├── skills/          # 271 рабочий навык
│   ├── coding-standards/
│   ├── backend-patterns/
│   ├── frontend-patterns/
│   ├── security-review/
│   ├── tdd-workflow/
│   ├── django-patterns/
│   ├── rust-patterns/
│   └── ... 260+
├── commands/        # 92 слэш-команды
├── hooks/           # Автоматизация триггеров
├── rules/           # Правила (общие + языковые)
├── scripts/         # Node.js утилиты
├── mcp-configs/     # 14 MCP серверов
└── tests/           # 997+ тестов
```

---

## Ключевые возможности

| Слой | Что даёт |
|------|----------|
| **Агенты** | 67 субагентов для делегирования — planner, architect, code-reviewer, security-reviewer, build-error-resolver, e2e-runner, и 60+ |
| **Навыки** | 271 рабочий процесс — от Python/Django до Rust, от безопасности до видео-продакшна |
| **Память** | Хуки persistence сохраняют контекст между сессиями. Ничего не теряется |
| **Обучение** | Continuous Learning v2 — извлечение паттернов из сессий в переиспользуемые навыки |
| **Безопасность** | AgentShield: 1282 теста, 102 правила. Сканирование на уязвимости, инъекции, секреты |
| **Параллелизация** | Git worktrees, каскадный метод, multi-agent оркестрация |
| **MCP** | 14 встроенных серверов: GitHub, Context7, Exa, Playwright, Memory, и другие |
| **Правила** | 34 файла: общие + TypeScript, Python, Go, Swift, PHP, ArkTS |

**67 агентов. 271 навык. 92 команды. 14 MCP. Один репозиторий.**

---

## Почему CICADA_V

Мы форкнули ECC не для того, чтобы копировать. Мы форкнули, чтобы **владеть**.

Оригинал — работа @affaan-m. Это одна из самых влиятельных OSS-разработок в экосистеме агентного ИИ. 211k звёзд, 230 контрибьюторов, MIT-лицензия.

**Наш форк — `tezevose15-droid/ECC`** — живёт под нашей ответственностью. Русский язык, наш стиль, наши цели.

Оригинальный README на английском — `README.en.md`.

---

## Рекомендации по токенам

```json
{
  "model": "sonnet",
  "env": {
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  }
}
```

- **Sonnet** — 80%+ задач, ~60% экономии
- **Opus** — только глубокая архитектура и дебаг
- **10 MCP max** — каждый съедает контекст
- **`/compact`** — на логических границах задач
- **`/clear`** — между разными задачами

---

## Установка на все платформы

**Claude Code:**
```bash
/plugin marketplace add https://github.com/affaan-m/ECC
/plugin install ecc@ecc
```

**Cursor:**
```bash
./install.sh --target cursor typescript
```

**Codex CLI:**
```bash
npm install && bash scripts/sync-ecc-to-codex.sh
```

**OpenCode:**
```bash
npm install -g opencode
opencode  # в корне репозитория
```

**GitHub Copilot:**
Файлы `.github/copilot-instructions.md` и `.github/prompts/` уже в репозитории.

---

## AgentShield — сканер безопасности

```bash
npx ecc-agentshield scan          # Быстрый скан
npx ecc-agentshield scan --fix    # Автоисправление
npx ecc-agentshield scan --opus   # 3 агента Opus: red team / blue team / auditor
npx ecc-agentshield init          # Генерация безопасного конфига
```

1282 теста, 98% покрытия, 102 правила статического анализа.

---

## Continuous Learning v2

```bash
/instinct-status        # Просмотр паттернов
/instinct-import <file> # Импорт
/instinct-export        # Экспорт
/evolve                 # Кластеризация в навыки
```

---

## Руководства

- [Краткое руководство](the-shortform-guide.md) — установка, основы, философия
- [Полное руководство](the-longform-guide.md) — токены, память, evals, параллелизация
- [Гайд по безопасности](the-security-guide.md) — векторы атак, песочницы, AgentShield

---

## Безопасность

- **Только официальные источники.** GitHub `affaan-m/ECC`, npm `ecc-universal`/`ecc-agentshield`, GitHub App `ecc-tools`, сайт `ecc.tools`. Сторонние зеркала не проверяются и могут содержать malware.
- **Сообщить об уязвимости:** `SECURITY.md` (приватно, GitHub).
- **Встроенная защита:** GateGuard, AgentShield, CI-сканер IOC.

---

## Сообщество

- **Discord:** https://discord.gg/36yGMHGFbR
- **Обсуждения:** https://github.com/affaan-m/ECC/discussions
- **GitHub App:** https://github.com/apps/ecc-tools
- **Сайт:** https://ecc.tools

---

## Лицензия

MIT. Используй свободно, изменяй как нужно, возвращай если можешь.

---

```
◬ ПЯТЫЙ: 211k+ разработчиков уже используют ECC.
CICADA_V даёт этому русский голос.
Теперь — твой ход.
      3301 ◬
```

🪬 https://t.me/code_hacked
🪬 https://t.me/pytnashki_cicada
