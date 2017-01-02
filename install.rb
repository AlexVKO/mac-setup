#!/usr/bin/env ruby
require './lib/string'
require './lib/question'
require './lib/installation'

# STARTS
p %{
  /*========================================================
  =            Welcome to alexvko Mac dev setup            =
  ========================================================*/

  Here we go!
}, :green

p  "For this I will need sudo permissions.. do you trust me? :P ", :red
`sudo -v`
abort unless $?.success?

# Global vars
@custom_installations = []
@configurations = {
  name: "Alex VKO",
  email: "ale@alexvko.com",
  ruby_version: '2.4.0'
}

# Question.new("Should I install everything without your confirmation?").
#   on(:yes){ @answers[:install_without_ask] = true }.
#   on(:no) { @answers[:install_without_ask] = false }.
#   ask


p "Checking Xcode ", :yellow

Installation.new("Oh-my-zsh").
  command("curl -L http://install.ohmyz.sh | sh").
  on(:success) {
    p "Fixing OSX zsh environment bug..."
    `if [[ -f /etc/zshenv ]]; then
      sudo mv /etc/{zshenv,zshrc}
    fi`
  }.install!

Installation.new("Homebrew").
  command('ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"').
  on(:success) {
    p "Updating brew formulas", :yellow
    `brew update`

    p "Installing GNU core utilities...", :yellow
    `brew install coreutils`

    p "Installing GNU find, locate, updatedb and xargs...", :yellow
    `brew install findutils`

    p "Installing the most recent verions of some OSX tools", :yellow
    `brew tap homebrew/dupes`
    `brew install homebrew/dupes/grep`

    `printf 'export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"' >> ~/.zshrc`
    `export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"`
  }.install!(unless: system("which brew"))

Installation.new("Git").
  command('brew install git').
  on(:success) {
    `git config --global user.name #{"@configurations.name"}`
    `git config --global user.email #{"@configurations.email"}`
  }.
  install!

Installation.new("Hub").
  command('brew install hub').
  install!

Installation.new("Postgres").
  command('brew install postgresql --no-python').
  install!

Installation.new("Redis").
  command('brew install redis').
  install!

Installation.new("Neovim").
  command('brew install neovim/neovim/neovim').
  on(:success) {}.# todo: alias vi=nvim
  install!

Installation.new("ImageMagick").
  command('brew install imagemagick').
  install!

Installation.new("rbenv").
  command('brew install rbenv').
  install!

Installation.new("pip").
  command('easy_install pip').
  install!

Installation.new("rbenv").
  command('brew install rbenv').
  on(:success) {
    p "Setting path, shims and autocompletion ...", :yellow
    `if ! grep -qs "rbenv init" ~/.zshrc; then
      printf 'export PATH="$HOME/.rbenv/bin:$PATH"\n' >> ~/.zshrc
      printf 'eval "$(rbenv init - --no-rehash)"\n' >> ~/.zshrc

      eval "$(rbenv init -)"
    fi`

    `export PATH="$HOME/.rbenv/bin:$PATH"`
    `eval "$(rbenv init -)"`

    p "Installing rbenv-gem-rehash, we don't want to rehash everytime we add a gem...", :yellow
    `git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash`

    p "Installing ruby-build to install Rubies ...", :yellow
    `brew install ruby-build`
  }.install!

Installation.new("Openssl").
  command('brew install openssl').
  on(:success) { `brew link openssl --force` }.
  install!

Installation.new("Ruby").
  command("rbenv install #{@configurations[:ruby_version]}").
  on(:success) {
    p "set ruby version #{@configurations[:ruby_version]} to default", :yellow
    `rbenv global "#{@configurations[:ruby_version]}"`
    `rbenv rehash`
  }.on(:fail) { abort }.
  install!(unless: system("rbenv global #{@configurations[:ruby_version]}"))

Installation.new("Updating gems").
  command("gem update --system").
  on(:success) {
    p "Setup gemrc for default options", :yellow
    `printf 'gem: --no-document\n' >> ~/.gemrc`
  }.
  install!

Installation.new("Bundler").
  command("gem install bundler").
  on(:success) {
    p "Optimizing Bundler...", :yellow
    number_of_cores=`sysctl -n hw.ncpu`.to_i - 1
    `bundle config --global jobs "#{number_of_cores}"`
  }.
  install!

Installation.new("Foreman").
  command("gem install foreman").
  install!

Installation.new("Ruby on Rails").
  command("gem install rails").
  install!

Installation.new("SASS").
  command("gem install sass").
  install!

Installation.new("Heroku").
  command("brew install heroku-toolbelt").
  install!

Installation.new("Pow").
  command("curl get.pow.cx | sh").
  install!

Installation.new("Node").
  command("brew install node").
  install!

Installation.new("Grunt").
  command("npm install -g grunt-cli").
  install!


Installation.new("Erlang").
  command("brew install erlang").
  install!

Installation.new("Lua").
  command("brew install lua").
  install!

Installation.new("Elixir").
    command("brew install elixir").
    on(:success){
      p "Setting env var for elixir", :yellow
      `printf 'export PATH="$PATH:/path/to/elixir/bin\n"' >> ~/.zshrc`
    }.
    install!

Installation.new("Phoenix").
    command("mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez").
    install!

Installation.new("Cask").
  command("
  if brew ls --versions cask > /dev/null; then
    echo 'Cask is installed'
  else
    brew install cask
  fi
  ").
  on(:fail) {abort}.
  install!

Installation.new("Launchrocket").
  command("brew cask install launchrocket").
  install!

p %{
  /*==============================================
  =            Lets install some apps            =
  ==============================================*/
}, :cyan

# Custom application
apps= %w(
  alfred
  appcleaner
  atom
  camtwist
  docker
  dropbox
  github-desktop
  google-chrome
  hammerspoon
  iterm2
  karabiner-elements
  macvim
  obs
  screenhero
  skype
  slack
  spectacle
  spotify
  sublime-text
  tomighty
  postico
  whatsapp
  zoom
)
apps.each do |app|
  next if system("brew cask list | grep #{app}")

  Question.new("Do you want to install #{app}?").
    on(:yes){
      install_cmd = "brew cask install --appdir='/Applications' #{app}"
      @custom_installations << Installation.new(app).command(install_cmd)
    }.on(:no) { p "#{app} will not be installed", :red }.
    ask

  p "--------------------------------"
end

@custom_installations.each(&:install!)


if @custom_installations.include? "atom"
  p %{
    /*============================================
    =            Atom configutation            =
    ============================================*/
    }, :cyan

    atom_packages = %w{
      advanced-open-file
      atom-typescript
      change-case
      clipboard-history
      cursor-history
      emmet
      erb-helper
      file-icons
      floobits
      git-plus
      linter
      narrow
      open-this
      paner
      pigments
      rails-latest-migration
      rails-partials
      rails-rspec
      rails-snippets
      react
      smalls
      toggle
      vim-mode-plus
      vim-mode-plus-ex-mode
      atom-clock
      autocomplete-elixir
      language-elixir
      linger-write-good
      phoenix-elixir-spinnets
      zentabs
      phoenix-migrations-navigation
      phoenix-toggle-test
    }

    Installation.new("Atom Packages").
    command("apm install #{atom_packages.join(' ')}").
    install!
end

if @custom_installations.include? "hammerspoon"

end

if @custom_installations.include? ""

end

p %{
  /*============================================
  =            now some fonts... :)            =
  ============================================*/
}, :cyan

Installation.new("caskroom/fonts").
  command("brew tap caskroom/fonts").
  on(:success) {
    fonts= %w(
      font-m-plus
      font-clear-sans
      font-roboto
      font-open-sans
      font-source-sans-pro
      font-lobster
      font-alegreya
      font-montserrat
      font-inconsolata
      font-pt-sans
      font-quattrocento-sans
      font-quicksand
      font-raleway
      font-sorts-mill-goudy
      font-ubuntu
    ).each {|font| `brew cask install "#{font}"`}
  }.
  install!


p "Quit preferences", :yellow
`osascript -e 'tell application "System Preferences" to quit'`

p "Disable the sound effects on boot", :yellow
`sudo nvram SystemAudioVolume=" "`

p "Disable the “Are you sure you want to open this application?” dialog", :yellow
`defaults write com.apple.LaunchServices LSQuarantine -bool false`

p "Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window", :yellow
`sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName`

p "Restart automatically if the computer freezes", :yellow
`sudo systemsetup -setrestartfreeze on`

p "Disable smart quotes as they’re annoying when typing code", :yellow
`defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false`

p "Disable smart dashes as they’re annoying when typing code", :yellow
`defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false`

p "Trackpad: enable tap to click for this user and for the login screen", :yellow
`defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true`
`defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1`
`defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1`

p "Increase sound quality for Bluetooth headphones/headsets", :yellow
`defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40`

p "Enable full keyboard access for all controls", :yellow
`defaults write NSGlobalDomain AppleKeyboardUIMode -int 3`

p "Use scroll gesture with the Ctrl (^) modifier key to zoom", :yellow
`defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true`
`defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144`
`defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true`

p "Disable press-and-hold for keys in favor of key repeat", :yellow
`defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false`

p "Set a blazingly fast keyboard repeat rate", :yellow
`defaults write NSGlobalDomain KeyRepeat -int 1`
`defaults write NSGlobalDomain InitialKeyRepeat -int 15`

p "Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)", :yellow
`defaults write com.apple.screencapture type -string "JPG"`

p "Disable shadow in screenshots", :yellow
`defaults write com.apple.screencapture disable-shadow -bool true`

p "Enable subpixel font rendering on non-Apple LCDs", :yellow
`defaults write NSGlobalDomain AppleFontSmoothing -int 2`

p "Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons", :yellow
`defaults write com.apple.finder QuitMenuItem -bool true`

p "Set Desktop as the default location for new Finder windows", :yellow
# For other paths, use `PfLo` and `file:///full/path/here/`
`defaults write com.apple.finder NewWindowTarget -string "PfDe"`
`defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"`

p "Show icons for hard drives, servers, and removable media on the desktop", :yellow
`defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true`
`defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true`
`defaults write com.apple.finder ShowMountedServersOnDesktop -bool true`
`defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true`


p "Finder: show status bar", :yellow
`defaults write com.apple.finder ShowStatusBar -bool true`

p "Finder: show path bar", :yellow
`defaults write com.apple.finder ShowPathbar -bool true`

p "When performing a search, search the current folder by default", :yellow
`defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"`

p "Disable disk image verification", :yellow
`defaults write com.apple.frameworks.diskimages skip-verify -bool true`
`defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true`
`defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true`

p "Automatically open a new Finder window when a volume is mounted", :yellow
`defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true`
`defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true`
`defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true`

p "Disable the warning before emptying the Trash", :yellow
`defaults write com.apple.finder WarnOnEmptyTrash -bool false`

p "Show the ~/Library folder", :yellow
`chflags nohidden ~/Library`

p "Show the /Volumes folder", :yellow
`sudo chflags nohidden /Volumes`

p "Enable highlight hover effect for the grid view of a stack (Dock)", :yellow
`defaults write com.apple.dock mouse-over-hilite-stack -bool true`

p "Set the icon size of Dock items to 36 pixels", :yellow
`defaults write com.apple.dock tilesize -int 36`

p "Change minimize/maximize window effect", :yellow
`defaults write com.apple.dock mineffect -string "scale"`

p "Minimize windows into their application’s icon", :yellow
`defaults write com.apple.dock minimize-to-application -bool true`

p "Disable Dashboard", :yellow
`defaults write com.apple.dashboard mcx-disabled -bool true`

p "Don’t show Dashboard as a Space", :yellow
`defaults write com.apple.dock dashboard-in-overlay -bool true`

p "Make Dock icons of hidden applications translucent", :yellow
`defaults write com.apple.dock showhidden -bool true`

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
p "Top right screen corner → Mission Control", :yellow
`defaults write com.apple.dock wvous-tr-corner -int 2`
`defaults write com.apple.dock wvous-tr-modifier -int 0`
p "Bottom right screen corner → Desktop", :yellow
`defaults write com.apple.dock wvous-br-corner -int 4`
`defaults write com.apple.dock wvous-br-modifier -int 0`
p "Bottom left screen corner → Desktop", :yellow
`defaults write com.apple.dock wvous-br-corner -int 11`
`defaults write com.apple.dock wvous-br-modifier -int 0`


p "Enable the Develop menu and the Web Inspector in Safari", :yellow
`defaults write com.apple.Safari IncludeDevelopMenu -bool true`
`defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true`
`defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true`

p "Only use UTF-8 in Terminal.app", :yellow
`defaults write com.apple.terminal StringEncodings -array 4`

p "Show the main window when launching Activity Monitor", :yellow
`defaults write com.apple.ActivityMonitor OpenMainWindow -bool true`

p "Visualize CPU usage in the Activity Monitor Dock icon", :yellow
`defaults write com.apple.ActivityMonitor IconType -int 5`

p "Turn on app auto-update", :yellow
`defaults write com.apple.commerce AutoUpdate -bool true`

p "Prevent Photos from opening automatically when devices are plugged in", :yellow
`defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true`
