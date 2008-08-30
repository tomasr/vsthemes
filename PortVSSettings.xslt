<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">
    <xsl:output method="xml" indent="yes"/>

   <xsl:template match="//ApplicationIdentity">
      <ApplicationIdentity version="9.0"/>
   </xsl:template>

   <!-- 
      deal with items whose name has changed in simple ways
   -->
   <xsl:template name="remove-space-before-parens">
      <Item>
         <xsl:apply-templates select="@*"/>
         <xsl:attribute name="Name">
            <xsl:value-of select="concat(substring-before(@Name, ' ('), concat('(', substring-after(@Name, ' (')))"/>
         </xsl:attribute>
      </Item>
   </xsl:template>
   <xsl:template match="//Item[starts-with(@Name, 'User Types ')]">
      <xsl:call-template name="remove-space-before-parens"/>
   </xsl:template>
   <xsl:template match="//Item[starts-with(@Name, 'String ')]">
      <xsl:call-template name="remove-space-before-parens"/>
   </xsl:template>
   
   <!-- 
      Copy the normal XML colors to
      support the new XAML settings
   -->

   <xsl:template mode="copy" match="//Item">
      <xsl:param name="new-name"/>
      <Item>
         <xsl:apply-templates select="@*"/>
         <xsl:attribute name="Name"><xsl:value-of select="$new-name"/></xsl:attribute>
      </Item>
   </xsl:template>
   
   <xsl:template match="//Category[@GUID='{A27B4E24-A735-4D1D-B8E7-9716E1E3D8E0}']/Items">
      <Items>
         <xsl:apply-templates select="@* | node()"/>

         <xsl:apply-templates select="Item[@Name='XML Attribute']" mode="copy">
            <xsl:with-param name="new-name">XAML Attribute</xsl:with-param>
         </xsl:apply-templates>
         <xsl:apply-templates select="Item[@Name='XML Attribute Quotes']" mode="copy">
            <xsl:with-param name="new-name">XAML Attribute Quotes</xsl:with-param>
         </xsl:apply-templates>
         <xsl:apply-templates select="Item[@Name='XML Attribute Value']" mode="copy">
            <xsl:with-param name="new-name">XAML Attribute Value</xsl:with-param>
         </xsl:apply-templates>
         <xsl:apply-templates select="Item[@Name='XML CData Section']" mode="copy">
            <xsl:with-param name="new-name">XAML CData Section</xsl:with-param>
         </xsl:apply-templates>
         <xsl:apply-templates select="Item[@Name='XML Comment']" mode="copy">
            <xsl:with-param name="new-name">XAML Comment</xsl:with-param>
         </xsl:apply-templates>
         <xsl:apply-templates select="Item[@Name='XML Delimiter']" mode="copy">
            <xsl:with-param name="new-name">XAML Delimiter</xsl:with-param>
         </xsl:apply-templates>
         <xsl:apply-templates select="Item[@Name='XML Keyword']" mode="copy">
            <xsl:with-param name="new-name">XAML Keyword</xsl:with-param>
         </xsl:apply-templates>
         <xsl:apply-templates select="Item[@Name='XML Name']" mode="copy">
            <xsl:with-param name="new-name">XAML Name</xsl:with-param>
         </xsl:apply-templates>
         <xsl:apply-templates select="Item[@Name='XML Processing Instruction']" mode="copy">
            <xsl:with-param name="new-name">XAML Processing Instruction</xsl:with-param>
         </xsl:apply-templates>
         <xsl:apply-templates select="Item[@Name='XML Text']" mode="copy">
            <xsl:with-param name="new-name">XAML Text</xsl:with-param>
         </xsl:apply-templates>

         <!-- 
         create "reasonable" values for the new items that 
         don't map anywhere else:
            XAML Markup Extension Class
            XAML Markup Extension Parameter Name
            XAML Markup Extension Parameter Value
         -->
         <xsl:apply-templates select="Item[@Name='Number']" mode="copy">
            <xsl:with-param name="new-name">XAML Markup Extension Class</xsl:with-param>
         </xsl:apply-templates>
         <xsl:apply-templates select="Item[@Name='HTML Entity']" mode="copy">
            <xsl:with-param name="new-name">XAML Markup Extension Parameter Name</xsl:with-param>
         </xsl:apply-templates>
         <xsl:apply-templates select="Item[@Name='XML Text']" mode="copy">
            <xsl:with-param name="new-name">XAML Markup Extension Parameter Value</xsl:with-param>
         </xsl:apply-templates>
      </Items>
   </xsl:template>

   <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
