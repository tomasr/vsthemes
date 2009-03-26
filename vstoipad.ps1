
param([string]$vsfile, [string]$outdir, [bool]$boldAsItalics = $true)

$ns_x = 'http://schemas.microsoft.com/winfx/2006/xaml'
$ns_act = 'clr-namespace:System.ComponentModel.Activation;assembly=Activation'
$ns_ls = 'clr-namespace:Microsoft.Intellipad.LanguageServices;assembly=Microsoft.Intellipad.Core'

function color($vscolor) {
   if ( $vscolor.StartsWith('0x02') ) {
      return $null
   } else {
      $rgb = $vscolor.substring(4,6)
      $red = $rgb.substring(4,2)
      $green = $rgb.substring(2,2)
      $blue = $rgb.substring(0,2)
      return "#FF$red$green$blue"
   }
}
function write-color($writer, $where, $color) {
   if ( $color -ne $null ) {
      $writer.WriteAttributeString($where, $color)
   }
}
function fix-font([int]$fontSize) {
   # font size in VS is in pts
   # but intellipad uses px right now, more or less
   return [int]($fontSize * 4 / 3.25)
}
function convertto-ipad($item, $name, $writer) {
   $writer.WriteStartElement('act', 'Export', $ns_act)
   $writer.WriteAttributeString('Name', '{}{Microsoft.Intellipad}ClassificationFormat')
   $item
   $writer.WriteStartElement('ls', 'ClassificationFormat', $ns_ls)
   $writer.WriteAttributeString('Name', $name)
   $writer.WriteAttributeString('FontSize', $fontSize)
   $writer.WriteAttributeString('FontFamily', $fontFamily)
   write-color $writer 'Foreground' (color $item.Foreground)
   write-color $writer 'Background' (color $item.Background)
   if ( $item.BoldFont -eq 'yes' ) {
      if ( $boldAsItalics ) {
         $writer.WriteAttributeString('FontStyle', 'Italic')
      } else {
         $writer.WriteAttributeString('FontWeight', 'Bold')
      }
   }
   $writer.WriteEndElement()
   $writer.WriteEndElement()
}
function find($items, $name) {
   foreach ( $item in $items ) {
      if ( $item.Name -eq $name ) {
         return $item
         break
      }
   }
}

$xml = [xml](gc $vsfile);
$cat = $xml.SelectSingleNode("//Category[@GUID='{A27B4E24-A735-4D1D-B8E7-9716E1E3D8E0}']")
$fontSize = fix-font($cat.FontSize)
$fontFamily = $cat.FontName
if ( $fontFamily.EndsWith('VS') ) {
   $fontFamily = $fontFamily.Substring(0, $fontFamily.Length - 3)
}
$items = $cat.SelectNodes("Items/Item")

$ipadfile = "$(resolve-path $outdir)\ClassificationFormats.xcml"
$writer = [xml.xmlwriter]::Create($ipadfile);

trap {
   if ( $writer -ne $null ) {
      $writer.Close()
      throw $error
   }
}

$writer.WriteStartElement('act', 'Exports', $ns_act)
$writer.WriteAttributeString('xmlns', 'ls', '', $ns_ls)
convertto-ipad (find $items 'Plain Text') 'text' $writer
convertto-ipad (find $items 'Plain Text') 'Unknown' $writer
convertto-ipad (find $items 'Number') 'Numeric' $writer
convertto-ipad (find $items 'Keyword') 'Keyword' $writer
convertto-ipad (find $items 'Comment') 'Comment' $writer
convertto-ipad (find $items 'String') 'String' $writer
convertto-ipad (find $items 'XML Delimiter') 'Delimiter' $writer
convertto-ipad (find $items 'User Types') 'Type' $writer
convertto-ipad (find $items 'Operator') 'Operator' $writer
convertto-ipad (find $items 'XSLT Keyword') 'Hyperlink' $writer
convertto-ipad (find $items 'Line Numbers') 'line number' $writer
$writer.WriteEndElement()
$writer.Close()
