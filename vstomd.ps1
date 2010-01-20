#
# extract colors used in a vs colorscheme into a monodevelop one
#
param([string]$vsfile, [string]$mdfile)

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

function write-colorDef($writer, $name, $value) {
   $writer.WriteStartElement('Color')
   $writer.WriteAttributeString('name', $name)
   $writer.WriteAttributeString('value', $value)
   $writer.WriteEndElement()
}
function fgname($name) {
   "$name.fg"
}
function bgname($name) {
   "$name.bg"
}
function find($items, $name) {
   foreach ( $item in $items ) {
      if ( $item.Name -eq $name ) {
         return $item
         break
      }
   }
}
function write-style($writer, $name, $fg, $bg) {
   $writer.WriteStartElement('Style')
   $writer.WriteAttributeString('name', $name)
   $writer.WriteAttributeString('color', $(if ( $fg ) { $fg } else { '' }) )
   if ( $bg ) {
      $writer.WriteAttributeString('bgColor', $bg)
   }
   $writer.WriteEndElement()
}

function add-style($writer, $fgcols, $bgcols, $items, $vsname, $mdname) {
   $item = find $items $vsname
   if ( -not $item ) {
      "$vsname doesn't exist. You sure you got it right?"
   } else {
      $fg = (get-color $item.Foreground)
      $bg = (get-color $item.Background)
      if ( $fg ) {
         write-colorDef $writer (fgname $mdname) $fg
         $fgcols.$mdname = (fgname $mdname)
      } else {
         $fgcols.$mdname = ''
      }
      if ( $bg ) {
         write-colorDef $writer (bgname $mdname) $bg
         $bgcols.$mdname = (bgname $mdname)
      } else {
         $bgcols.$mdname = ''
      }
   }
}

$xml = [xml](gc $vsfile);
$schemeName = [io.Path]::GetFileNameWithoutExtension($vsfile)
$cat = $xml.SelectSingleNode("//Category[@GUID='{A27B4E24-A735-4D1D-B8E7-9716E1E3D8E0}']")
$items = $cat.SelectNodes("Items/Item")

$wset = new-object xml.xmlwritersettings
$wset.Indent = $true
$writer = [xml.xmlwriter]::Create($mdfile, $wset);

trap {
   if ( $writer -ne $null ) {
      $writer.Close()
      throw $error
   }
}

$writer.WriteStartElement('EditorStyle')
$writer.WriteAttributeString('name', $schemeName)
$writer.WriteAttributeString('_description', '')

$fgcols = @{}
$bgcols = @{}

$mapping = @{
   'Identifier' = 'text';
   'Selected Text' = 'text.selection';
   'ViEmu hlsearch' = 'text.background.searchresult';
   #'' = 'text.link'; ??
   'Visible White Space' = 'marker.whitespace';
   'Brace Matching (Rectangle)' = 'marker.bracket';
   'Line Numbers' = 'linenumber';
   'Collapsible Text' = 'fold.togglemarker';
   'Indicator Margin' = 'iconbar';
   'Comment' = 'comment';
   'XML Doc Tag' = 'comment.keyword';
   #'' = 'comment.tag'; ???
   'Plain Text' = 'text.punctuation';
   'Preprocessor Keyword' = @('text.preprocessor', 'text.preprocessor.keyword');
   #'XML Delimiter' = 'text.markup';
   'XML Name' = @('text.markup', 'text.markup.tag');
   'Number' = @('constant', 'constant.digit', 'constant.language', 'constant.language.void');
   'String' = @('string', 'string.single', 'string.double', 'string.other');
   'Operator' = 'keyword.operator';
   'Keyword' = @('keyword.access', 'keyword.iteration', 'keyword.jump', 
                 'keyword.context', 'keyword.exceptions', 'keyword.modifier',
                 'keyword.namespace', 'keyword.type', 'keyword.property',
                 'keyword.selection', 'keyword.operator.declaration', 'keyword.declaration'
                 );
}

# bit of a hack, but I want to use the bg for Plain Text for all text
# so force it
$defbg = get-color (find $items 'Plain Text').Background
write-colorDef $writer (bgname 'text') $defbg

$mapping.Keys | sort | %{
   $k = $_
   $mapping.$_ | %{
      add-style $writer $fgcols $bgcols $items $k $_
   }
   $k
}

$fgcols.Keys | sort | %{
   if ( $_ -eq 'text' ) {
      write-style $writer $_ $fgcols.$_ (bgname 'text')
   } else {
      write-style $writer $_ $fgcols.$_ $bgcols.$_
   }
}

$writer.WriteEndElement()
$writer.Close()

