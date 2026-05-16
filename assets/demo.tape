Output demo.gif
Set Theme "Catppuccin Mocha"
# Make sure this matches your actual Nerd Font name in macOS Font Book
Set FontFamily "FiraCode Nerd Font"
Set FontSize 16
Set Width 1200
Set Height 600
Set Padding 20
Set WindowBar Colorful

# Use a specific socket name (-L) to ensure this tmux session 
# is completely isolated from your daily work session.
Type "tmux -L vhs -f ~/.config/tmux/tmux.conf new-session"
Enter
Sleep 2s

Type "clear"
Enter
Type "# Now using Catppuccin and Nerd Fonts..."
Sleep 500ms
Enter
Type "ls"
Enter
Sleep 3s
