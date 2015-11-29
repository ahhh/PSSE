# sample JSON manipulation script
# Taken from: http://stackoverflow.com/questions/16575419/powershell-retrieve-json-object-by-field-value

$json = @"
{
"Stuffs": 
    [
        {
            "Name": "Computers",
            "Type": "Fun Stuff"
        },

        {
            "Name": "Cleaning",
            "Type": "Boring Stuff"
        }
    ]
}
"@

$x = $json | ConvertFrom-Json

$x.Stuffs[0]
$x.Stuffs[1]

