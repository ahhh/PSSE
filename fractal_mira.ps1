# Super cool script for messing with Mira Fracatal and .NET form
# https://adminscache.wordpress.com/2013/11/27/powershell-plot-and-save-mira-orbital-fractal/

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
 
# Main Form
$mainForm = New-Object Windows.Forms.Form
$mainForm.BackColor = "White"
$mainForm.Font = "Comic Sans MS,8.25"
$mainForm.Text = "Mira Orbital Fractal"
$mainForm.size = "500,260"
 
# Global Values
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$global:colorsValue = 1000
$global:iterationsValue = 5000

# Iterations TrackBar
$iterationsTrackBar = New-Object Windows.Forms.TrackBar
$iterationsTrackBar.Location = "70,15"
$iterationsTrackBar.Orientation = "Horizontal"
$iterationsTrackBar.Width = 350
$iterationsTrackBar.Height = 40
$iterationsTrackBar.LargeChange = 25000
$iterationsTrackBar.SmallChange = 5000
$iterationsTrackBar.TickFrequency = 5000
$iterationsTrackBar.TickStyle = "TopLeft"
$iterationsTrackBar.SetRange(5000, 150000)
$iterationsTrackBar.Value = 30000
$iterTrackBarValue = 30000
#Iterations TrackBar Event Handler
$iterationsTrackBar.add_ValueChanged({
    $iterTrackBarValue = $iterationsTrackBar.Value
    $iterationsLabel.Text = "Iterations ($iterTrackBarValue)"
    $global:iterationsValue = $iterTrackBarValue
})
$mainForm.Controls.add($iterationsTrackBar)
 
# Colors Change TrackBar
$colorsTrackBar = New-Object Windows.Forms.TrackBar
$colorsTrackBar.Location = "70,130"
$colorsTrackBar.Orientation = "Horizontal"
$colorsTrackBar.Width = 350
$colorsTrackBar.Height = 40
$colorsTrackBar.LargeChange = 5000
$colorsTrackBar.SmallChange = 1000
$colorsTrackBar.TickFrequency = 1000
$colorsTrackBar.TickStyle = "BottomRight"
$colorsTrackBar.SetRange(1000, 20000)
$colorsTrackBarValue = 3000
$colorsTrackBar.Value = 3000
#Colors TrackBar Event Handler
$colorsTrackBar.add_ValueChanged({
$colorsTrackBarValue = $colorsTrackBar.Value
    $colorsLabel.Text = "Color Change ($colorsTrackBarValue)"
    $global:colorsValue = $colorsTrackBarValue
})
$mainForm.Controls.add($colorsTrackBar)

# Iterations Label
$iterationsLabel = New-Object System.Windows.Forms.Label
$iterationsLabel.Location = "170,60"
$iterationsLabel.Size = "120,23"
$iterationsLabel.Text = "Iterations ($iterTrackBarValue)"
$mainForm.Controls.Add($iterationsLabel)
 
# Colors Label
$colorsLabel = New-Object System.Windows.Forms.Label
$colorsLabel.Location = "170,100"
$colorsLabel.Size = "160,23"
$colorsLabel.Text = "Color Change Point ($colorsTrackBarValue)"
$mainForm.Controls.Add($colorsLabel)
 
# Line Label
$lineLabel = New-Object System.Windows.Forms.Label
$lineLabel.Location = "170,75"
$lineLabel.Size = "150,20"
$lineLabel.Text = "______________________________________"
$mainForm.Controls.Add($lineLabel)

# Plot Button
$plotButton = New-Object System.Windows.Forms.Button
$plotButton.Location = "120,185"
$plotButton.Size = "75,23"
$plotButton.Text = "Plot"
$plotButton.add_Click({PlotIt})
$mainForm.Controls.Add($plotButton)

# Plot the Fractal
Function PlotIt {
    Write-Host "Running . . ."
 
    # Output Bitmap Image
    $bitmap = New-Object System.Drawing.Bitmap(1024, 768)
    $bitmapGraphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $bitmapGraphics.Clear("black")
	$a = (Get-Random -minimum .0001 -maximum .9999)
	$b = .9998
	$c = 2-(2*$a)
	$x = 0
	$y = 12.1
	$w = (($a*$x)+($c*$x*$x))/(1+($x*$x))
	$multiplier = 25
	$colorChange = $global:colorsValue
	$maxIterations = $global:iterationsValue
	$counter = 1
	$xCentering = 470
	$yCentering = 380
	$red =   (Get-Random -minimum 0 -maximum 255)
	$green = (Get-Random -minimum 0 -maximum 255)
	$blue =  (Get-Random -minimum 0 -maximum 255)
	while ($counter -le $maxIterations) { 
		$counter++
		if (($counter % $colorChange) -eq 0) {
			Write-Host $counter "Cycles"
			$red =   (Get-Random -minimum 0 -maximum 255)
			$green = (Get-Random -minimum 0 -maximum 255)
			$blue =  (Get-Random -minimum 0 -maximum 255)
		}
		$xPixel = ($x * $multiplier) + $xCentering
		$yPixel = ($y * $multiplier) + $yCentering
		if ($xPixel -ge 0) {
			if ($yPixel -ge 0) {
				if ($xPixel -le 1023) {
					if ($yPixel -le 767) {
						$bitmap.SetPixel($xPixel, $yPixel, [System.Drawing.Color]::FromArgb($red, $green, $blue))
					}
				}
			}
		}
		$z = $x
		$x = ($b*$y)+$w
		$u = $x*$x
		$w = ($a*$x)+($c*$u)/(1+$u)
		$y = $w-$z
		}
	$outFile = $scriptPath + "\"  + "Mira_" + (Get-Date -UFormat %Y%m%d_%H%M%S) + ".bmp"
    $bitmap.Save($outFile)
    Invoke-Item $outFile
    $bitmap.Dispose()
    $bitmapGraphics.Dispose()
    Write-Host "Complete"
}

# Exit Button
$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Location = "300,185"
$exitButton.Size = "75,23"
$exitButton.Text = "Exit"
$exitButton.add_Click({$mainForm.close()})
$mainForm.Controls.Add($exitButton)

# Launch main form
$mainForm.ShowDialog()| Out-Null
