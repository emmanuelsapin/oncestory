# oncestory

**oncestory** is a portmanteau of **once** + **history** — unique, colored commands from your shell history.

## Install

```bash
git clone https://github.com/emmanuelsapin/oncestory.git
cd oncestory
chmod +x oncestory.sh
```

## Quick start

```bash
bash oncestory.sh
bash oncestory.sh -h
bash oncestory.sh git              # only commands containing "git"
ONCESTORY_LIMIT=100 bash oncestory.sh
```

## What you get

- each distinct command **once**
- oldest → newest (newest at the bottom)
- columns: `preview`  `times`  `command`
  - preview = first 20 + `...` + last 20 chars
  - if length **< 43**, preview is the full command
- `times` = how often that exact command appears in history
- color by the first word (program name)
- progress messages while loading a big history file

## Requirements

- bash, awk  
- a history file (`$HISTFILE`, `~/.bash_history`, or `~/.zsh_history`)  
- terminal with 256 colors  

## Related

- [sqolor](https://github.com/emmanuelsapin/sqolor) — colored / sorted `squeue`

## License

[MIT](LICENSE)
