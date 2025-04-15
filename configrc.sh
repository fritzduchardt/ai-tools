#!/usr/bin/env bash

SCRIPT_DIR="$(dirname -- "${BASH_SOURCE[0]:-${0}}")"

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

# generate code single file
alias {aiio,ai-stdin}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric_stdin.sh"
alias {ais,ai-script}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -p devops_script"
alias {aia,ai-amend}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -p devops_amend -o"
alias {aim,ai-multi}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric_multi.sh"
alias {aii,ai-improve}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -p devops_improve -o"
alias {aiic,ai-improve-continue}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -p devops_improve -c -o"
alias {aid,ai-doc}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric_stdin.sh -p devops_document"
alias {ait,ai-track}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -s auto -t"
alias {aits,ai-track-sleep}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -s auto -t -p private_sleep"
alias {aips,ai-sleep}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -s auto -p private_sleep"
alias {aitc,ai-track-calys}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -s auto -t -p private_calys"
alias {aipc,ai-calys}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -s auto -p private_calys"
alias {aitp,ai-track-people}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -s auto -t -p private_people"
alias {aipp,ai-people}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric.sh -s auto -p private_people"

# generate code multiple files
devops_script_multi() {
  local pattern="$1"
  shift 1
  generate_from_filelist < <("$SCRIPT_DIR"/fabric/fabric.sh -s auto -p "$pattern" "$@")
}
devops_script_multi_stdin() {
  local pattern="$1"
  shift 1
  generate_from_filelist < <("$SCRIPT_DIR"/fabric/fabric_stdin.sh -s auto -p "$pattern" "$@")
}
alias {aicd,ai-create-dir}="devops_script_multi devops_script_multi"
alias {aiid,ai-improve-dir}="devops_script_multi_stdin devops_improve_multi"
alias {aiad,ai-amend-dir}="devops_script_multi_stdin devops_amend_multi"

# git
alias {aigit,ai-git}="lib::exec_linux_tool $SCRIPT_DIR/fabric fabric_stdin.sh -p devops_gitcommit"

# data collectors
source "$SCRIPT_DIR/fabric/lib/data_collectors.sh"
alias fff="find_for_fabric"
alias cff="concat_for_fabric"
alias cffr="concat_for_fabric_recursive"
alias iff="internet_for_fabric"

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
