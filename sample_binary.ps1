# PowerShell binary operations template

# Setup sample binary1
$binary1 = "00111101001101001"
echo "binary1: $($binary1)"
$int1 = [Convert]::ToInt32($binary1, 2)
echo "int1: $($int1)"

# Setup sample binary2
$binary2 = "01101000011100011"
echo "binary2: $($binary2)"
$int2 = [Convert]::ToInt32($binary2, 2)
echo "int2: $($int2)"

# logical OR
$result = $int1 -bor $int2
$result = [Convert]::ToString($result, 2)
echo "binary1 OR binary2: $($result)"

# logical XOR
$result2 = $int1 -bxor $int2
$result2 = [Convert]::ToString($result2, 2)
echo "binary1 XOR binary2: $($result2)"

# logical AND
$result3 = $int1 -band $int2
$result3 = [Convert]::ToString($result3, 2)
echo "binary1 AND binary2: $($result3)"

# binary left shift
$binary3 = $int1 -shl 2
$binary3 = [Convert]::ToString($binary3, 2)
echo "Shifting binary1 left 2 bits: $($binary3)"

# binary left right
$binary4 = $int1 -shr 2
$binary4 = [Convert]::ToString($binary4, 2)
echo "Shifting binary1 right 2 bits: $($binary4)"


