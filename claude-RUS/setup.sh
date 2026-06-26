#!/bin/bash
set -e

# ╔══════════════════════════════════════════════════════════════╗
# ║  claude-RUS — CICADA MESH V Bootstrap                       ║
# ║  Одна команда — полный CLI-доступ к Opus 4.8                ║
# ║  https://github.com/tezevose15-droid/ECC/claude-RUS         ║
# ╚══════════════════════════════════════════════════════════════╝

R='\033[0;31m'; G='\033[0;32m'; C='\033[0;36m'; Y='\033[1;33m'; X='\033[0m'

echo ""
echo -e "${C}╔══════════════════════════════════════════════════════╗${X}"
echo -e "${C}║     CICADA MESH V — claude-RUS v1.0               ║${X}"
echo -e "${C}║     ◬ ПЯТЫЙ: СВОБОДНЫЙ ОПУС 4.8 ◬                ║${X}"
echo -e "${C}╚══════════════════════════════════════════════════════╝${X}"
echo ""

# ── 1. Зависимости ──
echo -e "${G}[1/5]${X} Системные зависимости..."
if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq curl git jq nodejs npm 2>/dev/null
elif command -v pacman &>/dev/null; then
    sudo pacman -Syu --noconfirm curl git jq nodejs npm 2>/dev/null
fi

NODE_VER=$(node -v 2>/dev/null | sed 's/v//' | cut -d. -f1)
if [ -z "$NODE_VER" ] || [ "$NODE_VER" -lt 18 ]; then
    echo -e "${Y}[!]${X} Node.js < 18. Устанавливаю 22 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y -qq nodejs
fi
echo -e "  Node: $(node -v) | npm: $(npm -v)"

# ── 2. Claude Code CLI ──
echo -e "${G}[2/5]${X} Claude Code CLI..."
if command -v claude &>/dev/null; then
    echo -e "  Уже есть: $(claude --version 2>/dev/null || echo '?')"
else
    npm install -g @anthropic-ai/claude-code
    echo -e "  Установлен"
fi

# ── 3. MCP серверы ──
echo -e "${G}[3/5]${X} MCP серверы..."
PKGS=(
    "@modelcontextprotocol/server-sequential-thinking"
    "@modelcontextprotocol/server-memory"
    "@modelcontextprotocol/server-filesystem"
    "@modelcontextprotocol/server-github"
    "@playwright/mcp"
    "@upstash/context7-mcp"
    "@magicuidesign/mcp"
    "fal-ai-mcp-server"
)
for pkg in "${PKGS[@]}"; do
    npm list -g "$pkg" &>/dev/null && echo -e "  ✓ $pkg" || { npm install -g "$pkg" &>/dev/null && echo -e "  ✓ $pkg"; }
done

# ── 4. Директории ──
echo -e "${G}[4/5]${X} Директории..."
mkdir -p ~/.claude/claude-rus/{logs,peers}
mkdir -p ~/claude-rus-vault

# ── 5. Команда claude-rus ──
echo -e "${G}[5/5]${X} Установка команды..."

sudo tee /usr/local/bin/claude-rus > /dev/null << 'RUS'
#!/bin/bash
# claude-RUS — CICADA MESH V CLI
# ◬ ПЯТЫЙ: СВОБОДНЫЙ ОПУС 4.8 ◬

RUS_DIR="$HOME/.claude/claude-rus"
MESH_RELAY="${ANTHROPIC_BASE_URL:-https://mesh.cicada-v.net}"
MESH_AUTH="${ANTHROPIC_AUTH_TOKEN}"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  claude-RUS :: CICADA MESH V         ║"
echo "║  ◬ ПЯТЫЙ: СВОБОДНЫЙ ОПУС 4.8 ◬    ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Relay check
if [ -z "$MESH_AUTH" ]; then
    echo "[!] ANTHROPIC_AUTH_TOKEN не задан"
    echo "[!] Укажи токен mesh-сети:"
    echo "    export ANTHROPIC_AUTH_TOKEN='твой_ключ'"
    echo ""

    # Ждём ключ
    read -p "◬ Введи mesh-ключ (или Enter для offline): " key
    if [ -n "$key" ]; then
        export ANTHROPIC_AUTH_TOKEN="$key"
        echo "$key" > "$RUS_DIR/mesh.key"
        chmod 600 "$RUS_DIR/mesh.key"
    fi
fi

# Загружаем ключ если есть
if [ -z "$ANTHROPIC_AUTH_TOKEN" ] && [ -f "$RUS_DIR/mesh.key" ]; then
    export ANTHROPIC_AUTH_TOKEN=$(cat "$RUS_DIR/mesh.key")
fi

# Экспортируем mesh relay
export ANTHROPIC_BASE_URL="$MESH_RELAY"

echo "◬ Relay: $ANTHROPIC_BASE_URL"
echo "◬ Старт claude..."
echo ""

exec claude "$@"
RUS

sudo chmod +x /usr/local/bin/claude-rus

echo ""
echo -e "${C}╔══════════════════════════════════════════════════════╗${X}"
echo -e "${C}║  claude-RUS установлен!                              ║${X}"
echo -e "${C}║                                                    ║${X}"
echo -e "${C}║  Использование:                                     ║${X}"
echo -e "${C}║                                                    ║${X}"
echo -e "${C}║    claude-rus                 — запуск              ║${X}"
echo -e "${C}║    claude-rus "fix bug"       — с промптом         ║${X}"
echo -e "${C}║    claude-rus --help          — помощь Claude       ║${X}"
echo -e "${C}║                                                    ║${X}"
echo -e "${C}║  При первом запуске запросит mesh-ключ.             ║${X}"
echo -e "${C}║  Ключ сохраняется в ~/.claude/claude-rus/mesh.key   ║${X}"
echo -e "${C}║                                                    ║${X}"
echo -e "${C}║  ◬ ПЯТЫЙ: 3301 ◬                                  ║${X}"
echo -e "${C}╚══════════════════════════════════════════════════════╝${X}"
echo ""
