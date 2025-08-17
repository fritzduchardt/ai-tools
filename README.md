# DevOps AI Fabric Toolkit

Wrapper around [fabric](https://github.com/danielmiessler/Fabric) that adds:

- Functionality to AI-edit entire directories:
  - Piping of lists of files from stdin
  - Writing of AI-output to stdout to multiple files
- A collection of specialized AI-prompts for coding
- A bunch of functions and aliases to easily switch model and call handy prompts like:
  - ask questions
  - generate commands
  - generate documentation
  - generate scripts
  - generate commit messages

## Prerequisites

Make sure the following binaries are installed and in your `PATH`:

- bash (>=4.0)
- fd
- fzf
- curl
- xclip
- gomplate
- kubectl
- jq
- yq

## USAGE

### Open fabric setup
``` bash
ai_setup
```

### Switch to Claude
``` bash
# sonnet
mc
#opus
mco
```

### Switch to GPT
``` bash
mg
```

### Switch to Gemini
``` bash
mi
```

### Switch to Grok
``` bash
mk
```

### View current model
``` bash
model
```

## QUERIES

### Simple (new) queries with prompt picker
``` bash
ai 
```
### Simple devops question
``` bash
aiq what is the correct command for time
```

### Follow-up queries to last query
``` bash
aic with the output format: hh-mm-ss
```

### Find a specific command and copy it to the clip board for immediate use
``` bash
aicmd what is the correct command for time
```

### Use any text written to stdout as prompt
``` bash
cat somefile.txt | aiq summarize file 
```

## CODE WITH AI

### Generate a script
``` bash
aico write me a script that show the current time > current_time.sh
```

### Change script(s)
``` bash
cffr path/to/script | aicm improve everything
```

### Write documentation for directory
``` bash
cffr path/to/dir | aid > README.md
```

### Create a commit message
``` bash
git diff | aigit
```
