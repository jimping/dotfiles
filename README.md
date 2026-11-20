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

Secrets and machine-local env go in `~/.dotfiles-custom/shell/` (already sourced by `.zshrc`).

Feel free to create an issue on this repo if you have any questions about them.

![screenshot](https://jimping.github.io/dotfiles/screenshot.png)
