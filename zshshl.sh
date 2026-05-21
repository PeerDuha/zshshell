#!/usr/bin/env bash
set -e

# ==== Параметры ====
NERD_FONT_ZIP="./0xProto.zip"  # сюда положи свой архив 0xProto Nerd Font (или поправь путь)

echo "[*] Обновление пакетов и установка зависимостей..."
sudo apt update
sudo apt install -y zsh git curl unzip fonts-powerline
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/0xProto.zip

# ==== Установка Nerd Font (0xProto) для текущего пользователя ====
if [ -f "$NERD_FONT_ZIP" ]; then
  echo "[*] Установка 0xProto Nerd Font из $NERD_FONT_ZIP..."
  mkdir -p "$HOME/.local/share/fonts/0xProtoNerd"
  tmpdir=$(mktemp -d)
  unzip -qq "$NERD_FONT_ZIP" -d "$tmpdir"
  find "$tmpdir" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$HOME/.local/share/fonts/0xProtoNerd/" \;
  fc-cache -f -v >/dev/null 2>&1 || true
  rm -rf "$tmpdir"
else
  echo "[!] Архив шрифта $NERD_FONT_ZIP не найден, шаг установки Nerd Font пропущен."
  echo "    Положи архив 0xProto.zip рядом со скриптом или измени переменную NERD_FONT_ZIP."
fi

# ==== Установка Oh My Zsh ====
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "[*] Установка Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "[*] Oh My Zsh уже установлен, пропускаю."
fi

# ==== Установка тем и плагинов ====
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "[*] Установка Powerlevel10k..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
else
  echo "    Powerlevel10k уже установлен."
fi

echo "[*] Установка плагина zsh-syntax-highlighting..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "    zsh-syntax-highlighting уже установлен."
fi

echo "[*] Установка плагина zsh-autosuggestions..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "    zsh-autosuggestions уже установлен."
fi

# ==== Конфиг ~/.zshrc ====
ZSHRC="$HOME/.zshrc"

echo "[*] Генерация ~/.zshrc..."

cat > "$ZSHRC" <<"EOF"
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# --- История и редактор ---
HISTSIZE=2000
SAVEHIST=2000
export VISUAL=nvim
export EDITOR="$VISUAL"

# --- Подсветка и автодополнение ---
source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- Настройки Powerlevel10k ---
# Если хочешь отключить правый prompt полностью - раскомментируй:
# POWERLEVEL9K_DISABLE_RPROMPT=true

# Загружаем настройки из ~/.p10k.zsh если есть
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
EOF

# ==== Конфиг ~/.p10k.zsh ====
P10K="$HOME/.p10k.zsh"

echo "[*] Генерация ~/.p10k.zsh (минимальный конфиг)..."

cat > "$P10K" <<"EOF"
# ОЧЕНЬ компактная конфигурация Powerlevel10k — минимальные блоки
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)

typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{3}╭─%f "
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{3}╰─%f "

# укоротить путь
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=3

# цвета (пример)
typeset -g POWERLEVEL9K_DIR_FOREGROUND=250
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=34
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=220
EOF

# ==== Сделать zsh шеллом по умолчанию ====
if command -v zsh >/dev/null 2>&1; then
  if [ "$SHELL" != "$(command -v zsh)" ]; then
    echo "[*] Делаю zsh шеллом по умолчанию (потребуется пароль)..."
    chsh -s "$(command -v zsh)"
  else
    echo "[*] zsh уже является шеллом по умолчанию."
  fi
fi

echo
echo "==============================================="
echo "Готово!"
echo "1) Перезапусти терминал ИЛИ выполни: exec zsh"
echo "2) В настройках терминала выбери шрифт \"0xProto Nerd Font\"."
echo "3) Если захочешь — запусти p10k configure для интерактивной настройки."
echo "==============================================="
