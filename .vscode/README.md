I followed [this guide](https://pawelgrzybek.com/sync-vscode-settings-and-snippets-via-dotfiles-on-github/).

On MacOS, delete the `settings.json` and `keybindings.json` files at
`~/Library/Application\ Support/Code/User/`. Then, create symbolic links to
those two files in this folder:

```bash
ln -s ~/.vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
ln -s ~/.vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
```
