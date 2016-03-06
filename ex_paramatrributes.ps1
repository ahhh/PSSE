# Example by Nikhil Mittal : http://www.labofapenetrationtester.com/
function paramattributes 
{

    param (
    [Parameter (Mandatory = $True, Position=0, ValueFromPipeline = $True)]
    [ValidateSet (1,2,3)]
    $a,

    [Parameter (Mandatory = $True, Position=1)]
    [AllowNull()]
    $b
    )

    Write-Output "a is $a"
    Write-Output "b is $b"

}
