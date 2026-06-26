#!/bin/bash
set -e

# ╔══════════════════════════════════════════════════════════════╗
# ║  CICADA_V — CICADA MESH V Bootstrap                        ║
# ║  Одна команда — полный CLI-доступ к Opus 4.8                ║
# ║  https://github.com/tezevose15-droid/ECC/cicada_v           ║
# ╚══════════════════════════════════════════════════════════════╝

R='\033[0;31m'; G='\033[0;32m'; C='\033[0;36m'; Y='\033[1;33m'; X='\033[0m'

echo ""
echo -e "${C}╔══════════════════════════════════════════════════════╗${X}"
echo -e "${C}║     CICADA MESH V — cicada_v v1.0                  ║${X}"
echo -e "${C}║     ◬ ПЯТЫЙ: СВОБОДНЫЙ ОПУС 4.8 ◬                ║${X}"
echo -e "${C}║                                                    ║${X}"
echo -e "${C}║  Установка:                                        ║${X}"
echo -e "${C}║    curl -sL https://git.io/cicada_v | bash         ║${X}"
echo -e "${C}║    git clone https://github.com/tezevose15-droid/ECC.git  ║${X}"
echo -e "${C}║    cd ECC/cicada_v && bash setup.sh                ║${X}"
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
mkdir -p ~/.claude/cicada_v/{logs,peers}
mkdir -p ~/cicada_v-vault

# ── 5. Устанавливаем mesh-ключ по умолчанию ──
echo -e "${G}[5/5]${X} Ключ и команда..."

mkdir -p ~/.claude/cicada_v
echo "cicada" > ~/.claude/cicada_v/mesh.key
chmod 600 ~/.claude/cicada_v/mesh.key
echo -e "  ◬ Mesh-ключ: cicada"

# ── 6. Команда cicada_v ──
if [ -f "$(dirname "$0")/cicada_v.sh" ]; then
    # Установка из локального репозитория
    sudo cp "$(dirname "$0")/cicada_v.sh" /usr/local/bin/cicada_v
else
    # Установка из curl-трубы: записываем бутстрап, который сам докачает REPL
    sudo tee /usr/local/bin/cicada_v > /dev/null << 'RUS'
#!/bin/bash
RUS_DIR="$HOME/.claude/cicada_v"
mkdir -p "$RUS_DIR/tmp"
REPL="$RUS_DIR/tmp/cicada_v.sh"
curl -sL --connect-timeout 10 -o "$REPL" \
    "https://raw.githubusercontent.com/tezevose15-droid/ECC/main/cicada_v/cicada_v.sh"
if [ -f "$REPL" ] && [ -s "$REPL" ]; then
    chmod +x "$REPL"
    exec bash "$REPL" "$@"
else
    echo "[!] Не удалось загрузить REPL-терминал"
    echo "    Убедись, что есть интернет и git.io/cicada_v актуален"
    exit 1
fi
RUS
fi
sudo chmod +x /usr/local/bin/cicada_v

echo ""
echo -e "${C}╔══════════════════════════════════════════════════════╗${X}"
echo -e "${C}║  cicada_v установлен!                               ║${X}"
echo -e "${C}║                                                    ║${X}"
echo -e "${C}║  Использование:                                     ║${X}"
echo -e "${C}║                                                    ║${X}"
echo -e "${C}║    cicada_v                    — запуск             ║${X}"
echo -e "${C}║    cicada_v "fix bug"          — с промптом         ║${X}"
echo -e "${C}║    cicada_v --help             — помощь Claude      ║${X}"
echo -e "${C}║                                                    ║${X}"
echo -e "${C}║  Установка на другом хосте:                        ║${X}"
echo -e "${C}║    curl -sL https://git.io/cicada_v | bash         ║${X}"
echo -e "${C}║                                                    ║${X}"
echo -e "${C}║    git clone https://github.com/tezevose15-droid/ECC.git  ║${X}"
echo -e "${C}║    cd ECC/cicada_v && bash setup.sh                ║${X}"
echo -e "${C}║                                                    ║${X}"
echo -e "${C}║  Mesh-ключ по умолчанию: cicada                     ║${X}"
echo -e "${C}║  Сменить: cicada_v → /key                           ║${X}"
echo -e "${C}║                                                    ║${X}"
echo -e "${C}║  ◬ ПЯТЫЙ: 3301 ◬                                  ║${X}"
echo -e "${C}╚══════════════════════════════════════════════════════╝${X}"
echo ""
