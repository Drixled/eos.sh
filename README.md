# **eos.sh**

*A small ritual for new machines.*

**eos** is a bootstrap script for macOS development environments.  
It prepares a clean system for real work: clear tools, intentional defaults, and a predictable setup you can trust across machines.

Named after **Ἠώς (Eos)**, the goddess of dawn, it is meant to mark the beginning of a new workspace. Quiet, minimal, repeatable.

---

## **What it does**

eos installs and configures a focused development environment built around clarity and speed:

- Installs **Homebrew**
- Sets **Fish** as the default shell
- Installs essential developer tools (git, fzf, ripgrep, etc.)
- Configures **nvm** for Node.js version management
- Sets up **yadm** for dotfile management
- Installs **Fisher** and a few helpful Fish plugins

No fluff. Only tools you will actually use.

---

## **Usage**

Run directly:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/dotfiles/main/eos.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
bash eos.sh
```

---

## **After running**

1. Restart your terminal  
2. Install Node.js

   ```bash
   nvm install --lts
   ```

3. Set the default Node version

   ```bash
   nvm alias default lts/*
   ```

4. Check your dotfiles

   ```bash
   yadm status
   ```

---

## **Customization**

Personal additions live in `~/.setup.local`.

This file runs automatically at the end of the script, so you can keep your core setup clean while extending locally:

```bash
# ~/.setup.local
brew install --cask figma
npm install -g typescript
```

Think of it as your personal appendix to the ritual.

---

## **What gets installed**

### **Shell**

- Fish shell  
- Fisher plugin manager  
- nvm.fish and fzf.fish plugins  

### **Developer tools**

- git, gh (GitHub CLI)  
- nvm (Node version manager)  
- fzf, ripgrep, fd  
- bat, eza, tree  
- jq, wget, curl  
- yadm (dotfile manager)

### **System**

- Homebrew  
- Xcode Command Line Tools (via Homebrew)

---

## **Philosophy**

This script is built on a simple idea:

- Tools should feel **considered**, not chaotic  
- Environments should be **repeatable**, not mysterious  
- Craft deserves **good foundations**

A machine is another studio, another lab, another small world. eos opens the blinds and lets the light in.

---

### **eos**  
Ἠώς  
*Dawn, and new beginnings.*
