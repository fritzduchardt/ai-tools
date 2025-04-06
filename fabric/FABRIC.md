# Usecases

## CONFIG

### Open fabric setup 
``` bash
ai-setup
```

### Switch to Claude 
``` bash
mc
```

### Switch to GPT 
``` bash
mg
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

### Follow-up queries to last query
``` bash
aic for at the output format: hh-mm-ss
```

### Simple generic question
``` bash
aiq what is the correct command for time
```

### Simple devops question
``` bash
aiq what is the correct command for time
```

### Find a specific command and copy it to the clip board for immediate use
``` bash
aicmd what is the correct command for time
```

### Use any text written to stdout as prompt 
``` bash
cat somefile.txt | aiio 
```

### GENERATE CODE FOR SINGULAR FILE

## Generate a script
``` bash
ai-script write me a script that show the current time > current_time.sh
```

## Amend a script
``` bash
ai-amend -i current_time.sh -o add a usage function
```

## Improve script
``` bash
ai-improve -i current_time.sh make script safer
```

## Continue improving a script on same session
``` bash
ai-improve-continue -i current_time.sh and even safer still
```

# Write documentation for directory
``` bash
cff | ai-doc > README.md
```

### GENERATE CODE FOR MULTIPLE FILES

# Create an entirely new directory content, e.g. for a new project from scratch
``` bash
ai-create-dir code to provision ec2 on aw
```

# Improve an existing directory content
``` bash
cff | ai-improve-dir
```

# Amend an existing directory content
``` bash
cff | ai-amend-dir
```
