#!/usr/bin/env bash

SCRIPT_DIR="$(dirname -- "${BASH_SOURCE[0]:-${0}}")"
source "$SCRIPT_DIR/fabric/lib/data_collectors.sh"
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/utils.sh"
OBSIDIAN_PATH=/home/fritz/Sync

lib::exec_linux_tool() {
  local dir="$1" script="$2"
  shift 2
  "$dir/$script" "$@"
}

# FABRIC

# queries
alias ai-setup="fabric --setup"
alias ai="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh"
alias aik="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -k"
alias {aig,ai-general-question}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -p general"
alias {aiq,ai-devops-question}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -p devops_question"
alias {aic,ai-chat}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -c"
alias {aicc,ai-chat-command}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -x -c -p devops_cmd"
alias {aicmd,ai-cmd}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -x -p devops_cmd"
alias ai-filename="ai-stdin -p general_filename"

# generate code single file
alias {aiio,ai-stdin}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric_stdin.sh"
alias {ais,ai-script}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -p devops_script"
alias {aia,ai-amend}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -p devops_amend -o"
alias {aim,ai-multi}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric_multi.sh"
alias {aii,ai-improve}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -p devops_improve -o"
alias {aiic,ai-improve-continue}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -p devops_improve -c -o"
alias {aid,ai-doc}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric_stdin.sh -p devops_document"
alias ai-sleep="ffo sleep | ai-stdin -p private_sleep"
alias ai-people="ai-stdin -p private_people"
alias ai-calys="ffo calys | ai-stdin -p private_calys"
alias ai-recipes="ffo recipes | ai-stdin -p private_recipes"
alias {aip,ai-people}="ai-stdin -p private_people"

# generate code multiple files
fbrc_multi() {
  local pattern="$1"
  shift 1
  generate_from_filelist < <("$SCRIPT_DIR"/fabric/fabric.sh -p "$pattern" "$@")
}
fbrc_multi_stdin() {
  local pattern="$1"
  shift 1
  generate_from_filelist < <("$SCRIPT_DIR"/fabric/fabric_stdin.sh -p "$pattern" "$@")
}
alias {aicd,ai-create-dir}="fbrc_multi devops_script_multi"
alias {aiid,ai-improve-dir}="fbrc_multi_stdin devops_improve_multi"
alias {aiad,ai-amend-dir}="fbrc_multi_stdin devops_amend_multi"

# git
alias {aigit,ai-git}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric_stdin.sh -p devops_gitcommit"

# obsidian
fbrc_create_file() {
  local -r file="$(aiop "$@")"
  if [[ -e "$file" ]]; then
    log::info "$file already exists"
    exit 2
  fi
  lib::exec mkdir -p "$(dirname "$file")"
  lib::exec touch "$file"
  log::info "$file created"
}
fbrc_store_result() {
  local last_result file_name file_path
  log::info "Getting last AI result"
  if ! last_result="$(aic print last result again)"; then
    log::error "Could not recall output"
    exit 1
  fi
  log::info "Figuring out file name..."
  if ! file_name="$(echo "$last_result" | ai-filename)"; then
    exit 1
  fi
  log::info "Figuring out path.."
  if ! file_path="$(fffr "$OBSIDIAN_PATH" | aiop figure out path for "$file_name")"; then
    log::error "Could find path"
    exit 1
  fi
  if [[ ! "$file_path" =~ ^(/|/([^/]+)(/[^/]+)*/?)$ ]]; then
    log::error "No file path found: $file_path"
    exit 2
  fi
  log::info "Storing last result away in $file_path"
  lib::exec mkdir -p "$(dirname "$file_path")"
  cat > "$file_path" <<<"$last_result"
}
alias {aio,ai-obsidian}="fbrc_multi_stdin obsidian_author"
alias {aiop,ai-obsidian-path}="fffr "$OBSIDIAN_PATH" | ai-stdin -p obsidian_structure"
alias {aioc,ai-obsidian-create}="fbrc_create_file"
alias {aios,ai-obsidian-store}="fbrc_store_result"

# data collectors
alias fff="find_for_fabric"
alias fffr="find_for_fabric_recursive"
alias cff="concat_for_fabric"
alias cffr="concat_for_fabric_recursive"
alias iff="internet_for_fabric"
alias ffo="find_for_obsidian $OBSIDIAN_PATH"

# data generators
source "$SCRIPT_DIR/fabric/lib/data_generators.sh"
alias gff="generate_from_filelist"

# pattern generator
alias {ai-generate-patterns,aigp}="$SCRIPT_DIR/fabric/gomplate.sh"

# configuration
alias {model-ollama-qwem,moq}="export DEFAULT_MODEL=qwen2.5-coder:7b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS="
alias {model-ollama-codestral,moc}="export DEFAULT_MODEL=codestral:22b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS="
alias {model-ollama-deepseek,mod}="export DEFAULT_MODEL=deepseek-r1:14b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS="
alias {model-ollama-gemma,mog}="export DEFAULT_MODEL=gemma3:12b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS="
alias {model-ollama-mistral,mom}="export DEFAULT_MODEL=mistral-small:22b DEFAULT_VENDOR=Ollama EXTRA_AI_OPTS?"
alias {model-claude,mc}="export DEFAULT_MODEL=claude-3-7-sonnet-latest DEFAULT_VENDOR=Anthropic EXTRA_AI_OPTS="
alias {model-chatgpt,mg}="export DEFAULT_MODEL=o3-mini DEFAULT_MODEL_CONTEXT_LENGTH=100000 DEFAULT_VENDOR=OpenAI EXTRA_AI_OPTS=-r"
alias {model-deepseek,md}="export DEFAULT_MODEL=deepseek-reasoner DEFAULT_VENDOR=DeepSeek EXTRA_AI_OPTS="
alias model="env | grep DEFAULT_MODEL"
