# Example by Nikhil Mittal : http://www.labofapenetrationtester.com/
$outputpath = "C:\PFPT\"
$IPRanges = "192.168.254.0/24", "192.168.1.0/24"
foreach ($range in $IPRanges)
{
    $temp = $range -split "/"
    $file = $temp[0]
    & "nmap.exe" "-nvv" "-PN" "--top-ports" "20" "$range" "-oX" "$Outputpath\$file.xml"
}
