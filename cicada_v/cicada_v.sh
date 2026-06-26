#!/bin/bash
# CICADA_V — Терминал
# ◬ ПЯТЫЙ: СВОБОДНЫЙ ОПУС 4.8 ◬

C_R='\033[0;31m'
C_G='\033[0;32m'
C_C='\033[0;36m'
C_Y='\033[1;33m'
C_M='\033[0;35m'
C_B='\033[0;34m'
C_RES='\033[0m'
C_BOLD='\033[1m'

RUS_DIR="$HOME/.claude/cicada_v"
MESH_RELAY="${ANTHROPIC_BASE_URL:-https://mesh.cicada-v.net}"
LOG_FILE="$RUS_DIR/logs/session-$(date +%Y%m%d_%H%M%S).log"
HIST_FILE="$RUS_DIR/history.txt"

mkdir -p "$RUS_DIR"/logs

# ── Загрузка mesh-ключа ──
if [ -z "$ANTHROPIC_AUTH_TOKEN" ] && [ -f "$RUS_DIR/mesh.key" ]; then
    export ANTHROPIC_AUTH_TOKEN=$(cat "$RUS_DIR/mesh.key")
fi

# ── Функции ──
banner() {
    clear
    echo -e "${C_C}╔══════════════════════════════════════════════════════╗${C_RES}"
    echo -e "${C_C}║${C_RES}  ${C_BOLD}CICADA_V TERMINAL${C_RES} v1.0                          ${C_C}║${C_RES}"
    echo -e "${C_C}║${C_RES}  ◬ ${C_M}ПЯТЫЙ: СВОБОДНЫЙ ОПУС 4.8${C_RES} ◬                  ${C_C}║${C_RES}"
    echo -e "${C_C}║${C_RES}  🪬 https://t.me/code_hacked                      ${C_C}║${C_RES}"
    echo -e "${C_C}╚══════════════════════════════════════════════════════╝${C_RES}"
    echo ""

    if [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
        echo -e "  ${C_G}◬ Mesh:${C_RES} активен"
    else
        echo -e "  ${C_Y}◬ Mesh:${C_RES} не подключён (offline)"
    fi
    echo "  ─────────────────────────────"
    echo ""
}

help() {
    echo -e "${C_C}  cicada_v — команды:${C_RES}"
    echo ""
    echo -e "  ${C_G}просто текст${C_RES}     — отправить задачу Claude"
    echo -e "  ${C_G}/chat${C_RES}              — интерактивный режим Claude"
    echo -e "  ${C_G}/shell${C_RES}             — запустить bash"
    echo -e "  ${C_G}/key${C_RES}               — ввести/сменить mesh-ключ"
    echo -e "  ${C_G}/status${C_RES}            — статус соединения"
    echo -e "  ${C_G}/log${C_RES}               — открыть лог"
    echo -e "  ${C_G}/clear${C_RES}             — очистить экран"
    echo -e "  ${C_G}/help${C_RES}              — эта справка"
    echo -e "  ${C_G}/exit${C_RES}              — выход"
    echo ""
}

# ── Banner ──
banner
help

# ── REPL ──
while true; do
    echo -ne "${C_C}◬${C_RES}${C_BOLD} cicada_v${C_RES} ${C_M}>${C_RES} "
    read -r cmd args

    case "$cmd" in
        /exit|/quit)
            echo -e "${C_C}◬ 3301${C_RES}"
            exit 0
            ;;
        /clear)
            banner
            help
            ;;
        /help)
            help
            ;;
        /key)
            echo -ne "  ◬ Введи mesh-ключ: "
            read -rs key
            echo ""
            if [ -n "$key" ]; then
                export ANTHROPIC_AUTH_TOKEN="$key"
                echo "$key" > "$RUS_DIR/mesh.key"
                chmod 600 "$RUS_DIR/mesh.key"
                echo -e "  ${C_G}✓ Ключ сохранён${C_RES}"
            fi
            ;;
        /status)
            echo ""
            echo -e "  ${C_C}◬ Статус CICADA_V:${C_RES}"
            echo -e "  Relay: ${C_C}$MESH_RELAY${C_RES}"
            if [ -n "$ANTHROPIC_AUTH_TOKEN ]; then
                echo -e "  Mesh:  ${C_G}подключён${C_RES}"
            else
                echo -e "  Mesh:  ${C_Y}нет ключа${C_RES}"
            fi
            echo -e "  Лог:   $LOG_FILE"
            echo ""
            ;;
        /log)
            if [ -f "$LOG_FILE" ]; then
                tail -30 "$LOG_FILE"
            else
                echo -e "  ${C_Y}Лог пока пуст${C_RES}"
            fi
            ;;
        /chat|/shell)
            echo ""
            echo -e "  ${C_C}◬ Запуск Claude...${C_RES}"
            echo ""
            export ANTHROPIC_BASE_URL="$MESH_RELAY"
            claude "$args" 2>&1 | tee -a "$LOG_FILE"
            echo ""
            echo -e "  ${C_C}◬ Claude завершил сессию${C_RES}"
            echo ""
            ;;
        "")
            # просто enter — ничего
            ;;
        *)
            # Отправляем как задачу Claude
            echo ""
            echo -e "  ${C_C}◬ Отправляю задачу...${C_RES}"
            echo ""
            export ANTHROPIC_BASE_URL="$MESH_RELAY"
            echo "[$(date '+%H:%M:%S')] Задача: $cmd $args" >> "$LOG_FILE"
            claude -p "$cmd $args" 2>&1 | tee -a "$LOG_FILE"
            echo ""
            echo -e "  ${C_C}◬ Готово${C_RES}"
            echo ""
            ;;
    esac
done
