# XML template and parsing script
$sample_xml = [xml] @"
<AddressBook>
  <Person contactType="Security">
    <Name>ahhh</Name>
    <Phone type="home">555-1337</Phone>
    <Phone type="work">666-1337</Phone>
  </Person>
  <Person contactType="Business">
    <Name>jim</Name>
    <Phone type="home">555-1234</Phone>
    <Phone type="work">666-1234</Phone>
  </Person>
</AddressBook>
"@

# XPath
$sample_xml | Select-Xml "/AddressBook" | Select -Expand Node
$sample_xml | Select-Xml -XPath "//Person" | foreach {echo "$($_.node.Name): $($_.node.contactType)"}

# Objects
$sample_xml.AddressBook
  foreach ($Person in $sample_xml.AddressBook.Person) {
    $Person.Name
    foreach ($number in $Person.Phone) {
      echo "$($number.type): $($number.InnerXml)"
    }
  }
