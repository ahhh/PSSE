# Powershell Mandlebrot Set
# http://poshcode.org/5845

    $i=[float]-16;
    $j=[float]-16;
    $r=[float]-16;
    $x=[float]-16;
    $y=[float]-16;
     
    #Color Array
    $colors="Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta","DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White"
     
    while(($y++) -lt 15)
    {
        for($x=0; ($x++) -lt 70; Write-Host " " -BackgroundColor ($colors[$k -band 15]) -NoNewline)
            {
                $i=[float]0;
                $k=[float]0;
                $r=[float]0;
            do{ 
				$j=$r*$r-$i*$i-2+$x/25; $i=2*$r*$i+$y/10; $r=$j
            } while (($j*$j+$i*$i) -lt 10 -band ($k++) -lt 25)
        }
        Write-Host " "
    }
