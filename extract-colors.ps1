#
# extract colors used in a vs colorscheme
#
param([string]$vsfile)

function get-color($color) {
   if ( $color.StartsWith('0x02') ) {
      return $null
   } else {
      $rgb = $color.substring(4,6)
      $red = $rgb.substring(4,2)
      $green = $rgb.substring(2,2)
      $blue = $rgb.substring(0,2)
      return "#$red$green$blue"
   }
}

$xml = [xml](gc $vsfile);
$cat = $xml.SelectSingleNode("//Category[@GUID='{A27B4E24-A735-4D1D-B8E7-9716E1E3D8E0}']")
$items = $cat.SelectNodes("Items/Item")

$items | % {
   $cols = @{}
} {
   $fg = (get-color $_.Foreground)
   $bg = (get-color $_.Background)
   if ( $fg -and (-not $cols.Contains($fg)) ) {
      $cols.$fg = $_.Name
   }
   if ( $bg -and (-not $cols.Contains($bg)) ) {
      $cols.$bg = $_.Name
   }
} {
   $cols
}
