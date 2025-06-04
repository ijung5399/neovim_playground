CloudDevBox PS Setup

# Install Oh-My-Posh
>```powershell
>winget install JanDeDobbeleer.OhMyPosh -s winget
>oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\paradox.omp.json" | Invoke-Expression
>```

# Nvim-related
winget install neovim
winget install fzf
winget install sharkdp.bat
winget install sharkdp.fd

# Terminal-Icons
Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser


# nerd-fonts (Terminal Icon Working NF)
https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaMono.zip

