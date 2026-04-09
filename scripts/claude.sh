#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Claude Proxy Wrapper
# -----------------------------------------------------------------------------
# This script ensures the local SSH tunnel to your LiteLLM gateway is active
# before launching Claude with the specified model.
# -----------------------------------------------------------------------------

MODEL_ALIAS=$1
SELECTED_MODEL=""

case "$MODEL_ALIAS" in
    # Anthropic
    "sonnet")       SELECTED_MODEL="claude-sonnet-4-6" ;;
    "opus")         SELECTED_MODEL="claude-opus-4-6" ;;
    "haiku")        SELECTED_MODEL="claude-haiku-4-5" ;;
    
    # OpenAI
    "gpt5.4")       SELECTED_MODEL="gpt-5.4" ;;
    "gpt4o"|"gpt4") SELECTED_MODEL="gpt-4o" ;;
    "gpt-mini")     SELECTED_MODEL="gpt-5.4-mini" ;;
    "codex")        SELECTED_MODEL="gpt-5-codex" ;;
    
    # Google Gemini
    "gemini-pro")   SELECTED_MODEL="gemini-3.1-pro-preview" ;;
    "gemini-flash") SELECTED_MODEL="gemini-3-flash-preview" ;;
    
    # DeepSeek
    "deepseek-chat")     SELECTED_MODEL="deepseek-chat" ;;
    "deepseek-reasoner")     SELECTED_MODEL="deepseek-reasoner" ;;
    
    # Local (Ollama)
    "coder7b")      SELECTED_MODEL="qwen2.5-coder:7b" ;;
    "coder14b"|"coder") SELECTED_MODEL="qwen2.5-coder:14b" ;;
    
    *)
        # If the first argument is a flag (e.g., ai --version), pass everything directly to claude
        if [[ "$MODEL_ALIAS" == -* ]]; then
            exec claude "$@"
        fi

        # If empty or invalid alias, show help and exit
        if [[ -z "$MODEL_ALIAS" ]]; then
            echo "❌ Error: No model alias provided."
        else
            echo "❌ Error: Invalid model alias: '$MODEL_ALIAS'"
        fi
        echo ""
        echo "Usage: ai <alias> [args...]"
        echo "Available aliases:"
        echo "  sonnet, opus, haiku, gpt5.4, gpt4o, gpt-mini, codex, gemini-pro, gemini-flash, deepseek-chat, deepseek-reasoner, coder, coder7b"
        exit 1
        ;;
esac

# Shift to remove the model alias from arguments
shift

# 1. Connectivity Check (Is the tunnel running?)
if ! lsof -Pi :4000 -sTCP:LISTEN -t >/dev/null; then
    echo "⚠️  AI Tunnel (Port 4000) is NOT running."
    echo "👉 Run the Raycast 'Connect AI Gateway' script first."
    exit 1
fi

# 2. Run Claude
echo "🚀 Launching Claude with model: $SELECTED_MODEL via LiteLLM..."
exec claude --model "$SELECTED_MODEL" "$@"
