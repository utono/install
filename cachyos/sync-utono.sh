#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/source_directory"
    exit 1
fi

source_dir="$1"
logfile="$(mktemp)"
errors=()

log_success() {
    echo "SUCCESS: $1" | tee -a "$logfile"
}

log_error() {
    echo "ERROR: $1" | tee -a "$logfile" >&2
    errors+=("$1")
}

# Rsync all subdirectories to the current user's ($HOME) utano folder
rsync -avh --progress "$source_dir"/ "$HOME/utono" && log_success "Synced all subdirectories to $HOME/utono" || log_error "Failed syncing subdirectories to $HOME/utono"
rsync -avh --progress "$source_dir"/tty-dotfiles "$HOME" && log_success "Synced tty-dotfiles to $HOME" || log_error "Failed syncing tty-dotfiles to $HOME"
rsync -avh --progress "$source_dir"/kickstart-modular "$HOME/.config/nvim" && log_success "Synced kickstart-modular to $HOME/.config/nvim" || log_error "Failed syncing kickstart-modular to $HOME/.config/nvim"
rsync -avh --progress "$source_dir"/mpv-utono "$HOME/.config/mpv" && log_success "Synced mpv-utono to $HOME/.config/mpv" || log_error "Failed syncing mpv-utono to $HOME/.config/mpv"

# Prepare destination directory for user 'mlj' explicitly
mkdir -p -m 755 /home/mlj/utono && chown mlj:mlj /home/mlj/utono && chattr -V +C /home/mlj/utono && log_success "Prepared directory /home/mlj/utono" || log_error "Failed preparing /home/mlj/utono"

# Rsync all subdirectories to /home/mlj with ownership set to mlj
rsync -avh --progress --chown=mlj:mlj "$source_dir"/ /home/mlj/utono && log_success "Synced all subdirectories to /home/mlj/utono" || log_error "Failed syncing subdirectories to /home/mlj/utono"
rsync -avh --progress --chown=mlj:mlj "$source_dir"/tty-dotfiles /home/mlj && log_success "Synced tty-dotfiles to /home/mlj" || log_error "Failed syncing tty-dotfiles to /home/mlj"
rsync -avh --progress --chown=mlj:mlj "$source_dir"/kickstart-modular /home/mlj/.config/nvim && log_success "Synced kickstart-modular to /home/mlj/.config/nvim" || log_error "Failed syncing kickstart-modular to /home/mlj/.config/nvim"
rsync -avh --progress --chown=mlj:mlj "$source_dir"/mpv-utono /home/mlj/.config/mpv && log_success "Synced mpv-utono to /home/mlj/.config/mpv" || log_error "Failed syncing mpv-utono to /home/mlj/.config/mpv"

# Print summary
echo -e "\nOperation summary:"
cat "$logfile"

if [ ${#errors[@]} -ne 0 ]; then
    echo -e "\nEncountered errors in the following operations:" >&2
    for err in "${errors[@]}"; do
        echo " - $err" >&2
    done
    exit 1
else
    echo -e "\nAll operations completed successfully."
fi
