#!/usr/bin/env bash

SCRIPT_DIR="$(dirname -- "${BASH_SOURCE[0]:-${0}}")"
OBSIDIAN_PATH=/home/fritz/Sync

# FABRIC

# queries
alias ai-setup="fabric --setup"
alias ai="$SCRIPT_DIR/fabric/fabric.sh"
alias aik="$SCRIPT_DIR/fabric/fabric.sh -k"
alias {aig,ai-general-question}="$SCRIPT_DIR/fabric/fabric.sh -p general"
alias {aiq,ai-devops-question}="$SCRIPT_DIR/fabric/fabric.sh -p devops_question"
alias {aic,ai-chat}="$SCRIPT_DIR/fabric/fabric.sh -c"
alias {aicc,ai-chat-command}="$SCRIPT_DIR/fabric/fabric.sh -x -c -p devops_cmd"
alias {aicmd,ai-cmd}="$SCRIPT_DIR/fabric/fabric.sh -x -p devops_cmd"
alias ai-filename="ai -p general_filename"

# generate code single file
alias {ais,ai-script}="$SCRIPT_DIR/fabric/fabric.sh -p devops_script"
alias {aia,ai-amend}="$SCRIPT_DIR/fabric/fabric.sh -p devops_amend -o"
alias {aii,ai-improve}="$SCRIPT_DIR/fabric/fabric.sh -p devops_improve -o"
alias {aiic,ai-improve-continue}="$SCRIPT_DIR/fabric/fabric.sh -p devops_improve -c -o"
alias {aid,ai-doc}="$SCRIPT_DIR/fabric/fabric.sh -p devops_document"
alias ai-sleep="ffo sleep | ai -p private_sleep"
alias ai-people="ai -p private_people"
alias ai-calys="ffo calys | ai -p private_calys"
alias ai-food="ffo recipes | ai -p private_recipes"
alias ai-hair="ffo hair | ai -p private_hair"
alias {aip,ai-people}="ai -p private_people"

# generate code multiple files
fbrc_multi() {
  local pattern="$1"
  shift 1
  "$SCRIPT_DIR"/fabric/data_generators.sh generate_from_filelist < <("$SCRIPT_DIR"/fabric/fabric.sh -p "$pattern" "$@")
}
alias {aicd,ai-create-dir}="fbrc_multi devops_script_multi"
alias {aiid,ai-improve-dir}="fbrc_multi devops_improve_multi"
alias {aiad,ai-amend-dir}="fbrc_multi devops_amend_multi"

# git
alias {aigit,ai-git}="$SCRIPT_DIR/fabric/fabric.sh -p devops_gitcommit"

alias {aio,ai-obsidian}="fbrc_multi obsidian_author"
alias {aiop,ai-obsidian-path}="fffr "$OBSIDIAN_PATH" | ai -p obsidian_structure"
alias {aioc,ai-obsidian-create}="$SCRIPT_DIR/fabric/data_generators.sh create_file"
alias {aios,ai-obsidian-store}="$SCRIPT_DIR/fabric/data_generators.sh store_result"

# data collectors
alias fff="$SCRIPT_DIR/fabric/data_collectors.sh find_for_fabric"
alias fffr="$SCRIPT_DIR/fabric/data_collectors.sh find_for_fabric_recursive"
alias cff="$SCRIPT_DIR/fabric/data_collectors.sh concat_for_fabric"
alias cffr="$SCRIPT_DIR/fabric/data_collectors.sh concat_for_fabric_recursive"
alias iff="$SCRIPT_DIR/fabric/data_collectors.sh internet_for_fabric"
alias ffo="$SCRIPT_DIR/fabric/data_collectors.sh find_for_obsidian $OBSIDIAN_PATH"

# data generators
alias gff="$SCRIPT_DIR/fabric/data_generators.sh generate_from_filelist"

# pattern generator
alias {ai-generate-patterns,aigp}="$SCRIPT_DIR/fabric/gomplate.sh"

# configuration
alias {model-ollama-qwem,moq}="export DEFAULT_MODEL=qwen2.5-coder:7b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS="
alias {model-ollama-codestral,moc}="export DEFAULT_MODEL=codestral:22b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS="
alias {model-ollama-deepseek,mod}="export DEFAULT_MODEL=deepseek-r1:14b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS="
alias {model-ollama-gemma,mog}="export DEFAULT_MODEL=gemma3:12b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS="
alias {model-ollama-mistral,mom}="export DEFAULT_MODEL=mistral-small:22b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS="
alias {model-claude,mc}="export DEFAULT_MODEL=claude-3-7-sonnet-latest DEFAULT_MODEL_CONTEXT_LENGTH=100000 DEFAULT_VENDOR=Anthropic EXTRA_AI_OPTS="
alias {model-chatgpt,mg}="export DEFAULT_MODEL=o4-mini DEFAULT_MODEL_CONTEXT_LENGTH=100000 DEFAULT_VENDOR=OpenAI EXTRA_AI_OPTS=-r"
alias {model-deepseek,md}="export DEFAULT_MODEL=deepseek-reasoner DEFAULT_VENDOR=DeepSeek EXTRA_AI_OPTS="
alias model="env | grep DEFAULT_MODEL"
