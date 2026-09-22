# My personal dotfiles

My personal dotfiles for a Mac with Apple Silicon.

It contains the installation of some basic tools, some handy aliases and functions. Backups of settings are done via [Mackup](https://github.com/lra/mackup).

You can install them by cloning the repository as `.dotfiles` in your home directory and running the bootstrap script.

```
git clone git@github.com:jimping/dotfiles.git .dotfiles
cd .dotfiles
./bootstrap
```

The bootstrap script can be run by cd-ing into the `.dotfiles` directory and performing this command:

```bash
./bootstrap
```

## Herdr + Radar (iTerm2)

`installscript` runs `scripts/setup-herdr.sh`, which:

1. Installs [Herdr](https://herdr.dev) into `~/.local/bin`
2. Installs the [herdr-radar](https://github.com/hhdebb/herdr-radar) plugin
3. Runs radar `configure` + `install-font`
4. Installs `JetBrainsMonoHerdr-Regular.ttf` into `~/Library/Fonts` (required for iTerm sidebar icons)
5. Sets iTerm2 profile font to `JetBrainsMonoHerdr-Regular 13` (dotfiles plist + `~/Documents/Work/iTerm` when present)

Re-run anytime:

```bash
~/.dotfiles/scripts/setup-herdr.sh
```

Open a **new** iTerm2 window after changing the font. Secrets and machine-local env go in `~/.dotfiles-custom/shell/` (already sourced by `.zshrc`).

Feel free to create an issue on this repo if you have any questions about them.

![screenshot](https://jimping.github.io/dotfiles/screenshot.png)
