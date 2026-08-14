# Oncestory

**Oncestory** is a portmanteau of **once** + **history** — unique, colored commands from your shell history.

Must be **sourced** in your current shell so it sees live `history` (including event numbers past 1000). `bash oncestory.sh` starts a new process and only sees the on-disk history file.

## Install

```bash
git clone https://github.com/emmanuelsapin/oncestory.git
cd oncestory
```

Add to `~/.bashrc`:

```bash
Oncestory() {
  builtin history -a 2>/dev/null || true
  . /path/to/oncestory/oncestory.sh "$@"
}
```

## Quick start

```bash
. /path/to/oncestory/oncestory.sh
Oncestory                    # after the first source in this shell
Oncestory git                # only commands containing "git"
```

## What you get

- each distinct command **once**
- oldest → newest (newest at the bottom)
- columns: `preview`  `times`  `command`
  - preview = first 20 + `...` + last 20 chars
  - if length **< 43**, preview is the full command
- `times` = how often that exact command appears in history
- color by the first word (program name)

## Requirements

- bash, awk
- interactive bash (`history` builtin)
- terminal with 256 colors

## Related

- [sqolor](https://github.com/emmanuelsapin/sqolor) — colored / sorted `squeue`

## License

[MIT](LICENSE)
