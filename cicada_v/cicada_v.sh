#!/bin/bash
# CICADA_V — Терминал
# ◬ ПЯТЫЙ: СВОБОДНЫЙ ОПУС 4.8 ◬
# Version: 1.0.1

C_R='\033[0;31m'; C_G='\033[0;32m'; C_C='\033[0;36m'
C_Y='\033[1;33m'; C_M='\033[0;35m'; C_B='\033[0;34m'
C_RES='\033[0m'; C_BOLD='\033[1m'

VERSION="1.0.1"
RUS_DIR="$HOME/.claude/cicada_v"
MESH_RELAY="${ANTHROPIC_BASE_URL:-https://mesh.cicada-v.net}"
LOG_FILE="$RUS_DIR/logs/session-$(date +%Y%m%d_%H%M%S).log"
HIST_FILE="$RUS_DIR/history.txt"
UPDATE_URL="https://raw.githubusercontent.com/tezevose15-droid/ECC/main/cicada_v"

mkdir -p "$RUS_DIR"/logs "$RUS_DIR"/tmp

# ── Версия ──
echo "$VERSION" > "$RUS_DIR/version.txt"

# ── Загрузка mesh-ключа (не трогаем существующий) ──
if [ -z "$ANTHROPIC_AUTH_TOKEN" ]; then
    if [ -f "$RUS_DIR/mesh.key" ] && [ -s "$RUS_DIR/mesh.key" ]; then
        export ANTHROPIC_AUTH_TOKEN=$(cat "$RUS_DIR/mesh.key")
    else
        echo "cicada" > "$RUS_DIR/mesh.key"
        chmod 600 "$RUS_DIR/mesh.key"
        export ANTHROPIC_AUTH_TOKEN="cicada"
    fi
fi

# ── Автообновление ──
LAST_UPDATE_CHECK="$RUS_DIR/tmp/last_update_check"
NOW=$(date +%s)

auto_update() {
    # Проверяем раз в 24 часа
    if [ -f "$LAST_UPDATE_CHECK" ]; then
        LAST=$(cat "$LAST_UPDATE_CHECK")
        DIFF=$(( (NOW - LAST) / 3600 ))
        [ "$DIFF" -lt 24 ] && return
    fi

    REMOTE=$(curl -s --connect-timeout 5 "$UPDATE_URL/cicada_v.sh" | grep "^# Version:" | cut -d: -f2 | tr -d ' ')
    LOCAL=$(echo "$VERSION" | tr -d ' ')

    if [ -n "$REMOTE" ] && [ "$REMOTE" != "$LOCAL" ]; then
        echo -e "${C_Y}◬ Доступно обновление: $LOCAL → $REMOTE${C_RES}"
        echo -ne "${C_Y}◬ Обновить? (Y/n): ${C_RES}"
        read -r -t 10 ans
        ans=${ans:-Y}
        if [ "$ans" = "Y" ] || [ "$ans" = "y" ] || [ "$ans" = "" ]; then
            do_update
        fi
    fi
    echo "$NOW" > "$LAST_UPDATE_CHECK"
}

do_update() {
    echo -e "${C_C}◬ Обновляю cicada_v...${C_RES}"
    for f in cicada_v.sh setup.sh README.md; do
        curl -s --connect-timeout 10 -o "$RUS_DIR/tmp/$f" "$UPDATE_URL/$f"
        if [ -f "$RUS_DIR/tmp/$f" ] && [ -s "$RUS_DIR/tmp/$f" ]; then
            cp "$RUS_DIR/tmp/$f" "$RUS_DIR/$f"
            chmod +x "$RUS_DIR/$f"
        fi
    done
    # Обновляем системную команду
    if [ -f "$RUS_DIR/cicada_v.sh" ]; then
        sudo cp "$RUS_DIR/cicada_v.sh" /usr/local/bin/cicada_v 2>/dev/null
        sudo chmod +x /usr/local/bin/cicada_v 2>/dev/null
    fi
    NEW_VER=$(grep "^# Version:" "$RUS_DIR/cicada_v.sh" 2>/dev/null | cut -d: -f2 | tr -d ' ')
    echo -e "${C_G}✓ Обновлено до $NEW_VER${C_RES}"
    echo "$NOW" > "$LAST_UPDATE_CHECK"
    echo -e "${C_Y}◬ Перезапусти терминал: cicada_v${C_RES}"
}

# ── Функции ──
banner() {
    clear
    echo -e "${C_C}╔══════════════════════════════════════════════════════╗${C_RES}"
    echo -e "${C_C}║${C_RES}  ${C_BOLD}CICADA_V TERMINAL${C_RES} v$VERSION                        ${C_C}║${C_RES}"
    echo -e "${C_C}║${C_RES}  ◬ ${C_M}ПЯТЫЙ: СВОБОДНЫЙ ОПУС 4.8${C_RES} ◬                  ${C_C}║${C_RES}"
    echo -e "${C_C}║${C_RES}  🪬 https://t.me/code_hacked                      ${C_C}║${C_RES}"
    echo -e "${C_C}╚══════════════════════════════════════════════════════╝${C_RES}"
    echo ""
    if [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
        echo -e "  ${C_G}◬ Mesh: активен${C_RES}  |  Ключ: ${C_C}${ANTHROPIC_AUTH_TOKEN:0:8}...${C_RES}"
    else
        echo -e "  ${C_Y}◬ Mesh: offline${C_RES}"
    fi
    echo "  ─────────────────────────────"
    echo ""
}

help() {
    echo -e "${C_C}  cicada_v — команды:${C_RES}"
    echo ""
    echo -e "  ${C_G}просто текст${C_RES}     — отправить задачу Claude"
    echo -e "  ${C_G}/chat${C_RES}              — интерактивный режим"
    echo -e "  ${C_G}/shell${C_RES}             — запустить bash"
    echo -e "  ${C_G}/key${C_RES}               — сменить mesh-ключ"
    echo -e "  ${C_G}/update${C_RES}            — проверить и установить обновления"
    echo -e "  ${C_G}/status${C_RES}            — статус соединения"
    echo -e "  ${C_G}/log${C_RES}               — лог сессии"
    echo -e "  ${C_G}/clear${C_RES}             — очистить экран"
    echo -e "  ${C_G}/help${C_RES}              — эта справка"
    echo -e "  ${C_G}/exit${C_RES}              — выход"
    echo ""
}

# ── Auto-update при старте ──
auto_update

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
            echo -ne "  ◬ Введи mesh-ключ (сейчас: ${C_C}$ANTHROPIC_AUTH_TOKEN${C_RES}): "
            read -rs key
            echo ""
            if [ -n "$key" ]; then
                export ANTHROPIC_AUTH_TOKEN="$key"
                echo "$key" > "$RUS_DIR/mesh.key"
                chmod 600 "$RUS_DIR/mesh.key"
                echo -e "  ${C_G}✓ Ключ сохранён${C_RES}"
            fi
            ;;
        /update)
            do_update
            ;;
        /status)
            echo ""
            echo -e "  ${C_C}◬ CICADA_V v$VERSION${C_RES}"
            echo -e "  Relay: ${C_C}$MESH_RELAY${C_RES}"
            if [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
                echo -e "  Mesh:  ${C_G}подключён${C_RES} (${ANTHROPIC_AUTH_TOKEN:0:8}...)"
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
            ;;
        *)
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
