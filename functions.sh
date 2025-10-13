#!/usr/bin/env bash

SCRIPT_DIR="$(dirname -- "${BASH_SOURCE[0]:-${0}}")"
OBSIDIAN_PATH=/home/fritz/Sync

# FABRIC

# queries
ai_setup() {
  fabric --setup
}

ai() {
  "$SCRIPT_DIR"/fabric/fabric.sh "$@"
}

ai_general_question() {
  "$SCRIPT_DIR"/fabric/fabric.sh -p general "$@"
}

ai_general_prompt() {
  "$SCRIPT_DIR"/fabric/fabric.sh -p general_prompt "$@"
}

ai_devops_question() {
  "$SCRIPT_DIR"/fabric/fabric.sh -p devops_question "$@"
}

ai_chat() {
  "$SCRIPT_DIR"/fabric/fabric.sh -c "$@"
}

ai_chat_command() {
  "$SCRIPT_DIR"/fabric/fabric.sh -x -c -p devops_cmd "$@"
}

ai_cmd() {
  "$SCRIPT_DIR"/fabric/fabric.sh -x -p devops_cmd "$@"
}

# generate code single file
ai_code_bash() {
  "$SCRIPT_DIR"/fabric/fabric.sh -p devops_code_bash "$@"
}

ai_code() {
  "$SCRIPT_DIR"/fabric/fabric.sh -p devops_code "$@"
}

ai_code_continue() {
  "$SCRIPT_DIR"/fabric/fabric.sh -p devops_code -c -o "$@"
}

ai_doc() {
  "$SCRIPT_DIR"/fabric/fabric.sh -p devops_document "$@"
}

# generate code multiple files
ai_multi() {
  local pattern="$1"
  shift 1
  "$SCRIPT_DIR"/fabric/data_generators.sh generate_from_filelist < <(ai -p "$pattern" "$@")
}

ai_code_multi() {
  "$SCRIPT_DIR"/fabric/data_generators.sh generate_from_filelist true < <(ai -p "devops_code" "$@")
}

ai_code_multi_bash() {
  "$SCRIPT_DIR"/fabric/data_generators.sh generate_from_filelist true < <(ai -p "devops_code_bash" "$@")
}

ai_code_multi_chat() {
  "$SCRIPT_DIR"/fabric/data_generators.sh generate_from_filelist true < <(ai -c "$@")
}

# git
ai_git() {
  "$SCRIPT_DIR"/fabric/fabric.sh -p devops_gitcommit "$@"
}

ai_git_check() {
  gd origin/master | ai -p devops_git_check
}

# data collectors
fff() {
  "$SCRIPT_DIR"/fabric/data_collectors.sh find_for_fabric "$@"
}

fffr() {
  "$SCRIPT_DIR"/fabric/data_collectors.sh find_for_fabric_recursive "$@"
}

cff() {
  "$SCRIPT_DIR"/fabric/data_collectors.sh concat_for_fabric "$@"
}

cffr() {
  "$SCRIPT_DIR"/fabric/data_collectors.sh concat_for_fabric_recursive "$@"
}

iff() {
  "$SCRIPT_DIR"/fabric/data_collectors.sh internet_for_fabric "$@"
}

cfo() {
  "$SCRIPT_DIR"/fabric/data_collectors.sh concat_for_obsidian "$OBSIDIAN_PATH" "$@"
}

# data generators
gff() {
  "$SCRIPT_DIR"/fabric/data_generators.sh generate_from_filelist "$@"
}

# pattern generator
ai_generate_patterns() {
  "$SCRIPT_DIR"/fabric/gomplate.sh "$@"
}

# configuration
model_ollama_qwem() {
  export DEFAULT_MODEL=qwen2.5-coder:7b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS=
}

model_ollama_codestral() {
  export DEFAULT_MODEL=codestral:22b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS=
}

model_ollama_deepseek() {
  export DEFAULT_MODEL=deepseek-r1:14b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS=
}

model_ollama_gemma() {
  export DEFAULT_MODEL=gemma3:12b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS=
}

model_ollama_mistral() {
  export DEFAULT_MODEL=mistral-small:22b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS=
}

model_claude() {
  export DEFAULT_MODEL=claude-sonnet-4-20250514 DEFAULT_MODEL_CONTEXT_LENGTH=100000 DEFAULT_VENDOR=Anthropic EXTRA_AI_OPTS=
}

model_claude_opus() {
  export DEFAULT_MODEL=claude-opus-4-1-20250805 DEFAULT_MODEL_CONTEXT_LENGTH=100000 DEFAULT_VENDOR=Anthropic EXTRA_AI_OPTS=
}

model_chatgpt() {
  export DEFAULT_MODEL=o4-mini DEFAULT_MODEL_CONTEXT_LENGTH=100000 DEFAULT_VENDOR=OpenAI EXTRA_AI_OPTS=-r
}

model_chatgpt5() {
  export DEFAULT_MODEL=gpt-5-mini-2025-08-07 DEFAULT_MODEL_CONTEXT_LENGTH=100000 DEFAULT_VENDOR=OpenAI EXTRA_AI_OPTS=-r
}

model_deepseek() {
  export DEFAULT_MODEL=deepseek-reasoner DEFAULT_VENDOR=DeepSeek DEFAULT_MODEL_CONTEXT_LENGTH=100000 EXTRA_AI_OPTS=
}

model_grok() {
  export DEFAULT_MODEL=grok-4-fast-reasoning DEFAULT_VENDOR=GrokAI EXTRA_AI_OPTS=
}

model_mistral() {
  export DEFAULT_MODEL=mistral-large-latest DEFAULT_VENDOR=Mistral DEFAULT_MODEL_CONTEXT_LENGTH=100000 EXTRA_AI_OPTS=
}

model_gemini() {
  export DEFAULT_VENDOR=Gemini DEFAULT_MODEL=gemini-pro-latest DEFAULT_MODEL_CONTEXT_LENGTH=100000 EXTRA_AI_OPTS=
}

model() {
  env | grep DEFAULT_MODEL
}

# load current favorite model
model_chatgpt5
