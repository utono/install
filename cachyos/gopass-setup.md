# Gopass Setup on a New Machine with Git Sync

This guide explains how to set up `gopass` on a new machine using an existing Git-based password store hosted at:

```
git@github.com:<your-username>/<your-gopass-repo>.git
```

It also covers how to push changes (e.g. new or updated secrets) to the remote repository.

---

## Prerequisites

1. `gopass` installed (`pacman -S gopass` or equivalent)
2. `git` installed and configured with SSH access to GitHub
3. GPG key (private + public) from the original machine **imported**

---

## What Are GPG and GnuPG?

- **GnuPG** (GNU Privacy Guard) is the complete open-source encryption suite used to encrypt, sign, and manage secure messages and files.
- **`gpg`** is the command-line tool used to interact with GnuPG.

In short:
- **GnuPG** = the encryption framework
- **`gpg`** = the interface to use it

---

## Step 1: Export GPG Keys from Original Machine

### Recommended Backup and Restore with `.asc` Files

Retrieve your key ID:

```bash
gpg --list-secret-keys --keyid-format LONG
```

Example output:
```
sec   rsa2048/YOURKEYID 2025-07-02 [SCEAR]
      BA37FA54FE51C5D30101D069YOURKEYID
uid                 [ultimate] Your Name <your@email.com>
ssb   rsa2048/SUBKEYID 2025-07-02 [SEA]
```

To copy the key ID to the clipboard:

```bash
gpg --list-secret-keys --keyid-format LONG | grep '^sec' | awk '{print $2}' | cut -d'/' -f2 | wl-copy
```

> Use `wl-copy` (Wayland) or `xclip -selection clipboard` on X11

Export to an external drive:

```bash
gpg --export-secret-keys YOURKEYID > /run/media/mlj/8C8E-606F/gpg-backup/private-key.asc
gpg --export YOURKEYID > /run/media/mlj/8C8E-606F/gpg-backup/public-key.asc
```

Or copy raw key files:

```bash
cp -r ~/.gnupg /run/media/mlj/8C8E-606F/gpg-backup/
```

> ⚠️ Never store `.gnupg` in a public or synced Git repository like `tty-dotfiles`

---

## Step 2: Import GPG Keys on New Machine

Manually create the `.gnupg` directory if not present:

```bash
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
```

Restore from `.asc` files:

```bash
gpg --import /run/media/mlj/8C8E-606F/gpg-backup/private-key.asc
gpg --import /run/media/mlj/8C8E-606F/gpg-backup/public-key.asc
```

Restore from raw key files:

```bash
cp -r /run/media/mlj/8C8E-606F/gpg-backup/.gnupg/* ~/.gnupg/
chmod 700 ~/.gnupg
chmod 600 ~/.gnupg/*
chmod 700 ~/.gnupg/private-keys-v1.d
chmod 600 ~/.gnupg/private-keys-v1.d/*
```

Ensure `.gnupg` looks like this:

```
~/.gnupg
├── common.conf
├── crls.d/
├── openpgp-revocs.d/
├── private-keys-v1.d/
├── public-keys.d/
├── random_seed
└── trustdb.gpg
```

---

## Step 3: Clone the Git Repository

```bash
mkdir -p ~/utono

# Automatically clone if missing
git -C ~/utono/gopass-secrets rev-parse --is-inside-work-tree 2>/dev/null || \
  git clone git@github.com:<your-username>/<your-gopass-repo>.git ~/utono/gopass-secrets

gopass clone ~/utono/gopass-secrets
```

---

## Step 4: Initialize Gopass

Use your GPG email or key ID:

```bash
gopass init your@email.com
# or
gopass init YOURKEYID
```

---

## Step 5: Add, Remove, and Push a Secret

Add:
```bash
gopass insert instagram/yourusername
```

Show:
```bash
gopass show instagram/yourusername
gopass show -c instagram/yourusername
```

Remove:
```bash
gopass rm instagram/yourusername
```

Push:
```bash
gopass git push
```

Pull:
```bash
gopass git pull
```

> Encrypted secrets are versioned via Git

---

## Disable GPG GUI Passphrase Prompt

Use the correct file: `gpg.conf` (not `gpg-agent.conf`):

```bash
echo 'pinentry-mode loopback' >> ~/.gnupg/gpg.conf
chmod 600 ~/.gnupg/gpg.conf
```

Then restart the agent:

```bash
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

> ⚠️ Do **not** add this to `gpg-agent.conf`, or you'll get a config error.

---

## What’s Stored Remotely vs. Locally

### Remote (Git Repository: `gopass-secrets`)

- Encrypted secrets (`*.gpg` files)
- Git history and optionally `.gopass.yaml`

### Local

- GPG private key: `~/.gnupg`
- Git repo clone (e.g. `~/utono/gopass-secrets`)
- Decrypted secrets: only in memory at runtime

> ✅ The Git repo contains everything except your GPG key.

---

## Optional: Automate Gopass Setup

You may use a stowable wrapper script in:

```
~/tty-dotfiles/bin-mlj/.local/bin/bin-mlj/gopass/gopass-setup.sh
```

That script should:
- Ensure ~/utono exists
- Clone your Gopass repo if not already cloned
- Optionally import GPG key files from `/run/media/mlj/8C8E-606F/gpg-backup/*.asc` if found
- Write `pinentry-mode loopback` to `~/.gnupg/gpg.conf`
- Run `gopass init` with your key ID
- Run `gopass git pull`

> This provides fast, repeatable setup for new machines
