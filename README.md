# First Time Work Env Setup on Windows
## [Admin]
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
winget install --id Git.Git -e --source winget
Install-Module posh-git -Scope CurrentUser -Force

## [Regular]
winget install neovim
cd ~\AppData\Local\
git clone https://github.com/ijung5399/neovim_playground.git
mv neovim_playground nvim
cd nvim

## [nerd font]
Step 1: download https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaMono.zip
Step 2: Install the Font
- Find the font file (.ttf or .otf).
- Double-click the file and click Install.
Step 3: Set the Font in Windows Terminal
- Open Windows Terminal.
- Click the dropdown arrow (top-right) and select Settings.
- Choose Default from the left panel.
- Go to Appearance.
- Under Font face, select your installed font (e.g., CaskaydiaMono Nerd Font Mono).
- Click Save.

## [Others]
winget install fzf
winget install sharkdp.bat
winget install sharkdp.fd

// preview works with bat(text), glow(markdown), and viu(image)
// markdown
winget install  charmbracelet.glow

// viu (for image preview)
winget install --id Rustlang.Rustup -e --source winget
cargo install viu
/* viu requires `linker.exe` from Visual Studio's for:
- C++ Build Tools
- Windows SDK
*/
