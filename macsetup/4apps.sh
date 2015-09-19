# Apps
apps=(
  dropbox
  google-chrome
  slack
  transmit
  appcleaner
  seil
  spotify
  vagrant
  flash
  iterm2
  sublime-text3
  flux
  mailbox
  tower
  vlc
  skype
  transmission
)

# Install apps to /Applications
# Default is: /Users/$user/Applications
echo "installing apps..."
brew cask install --appdir="/Applications" ${apps[@]}
