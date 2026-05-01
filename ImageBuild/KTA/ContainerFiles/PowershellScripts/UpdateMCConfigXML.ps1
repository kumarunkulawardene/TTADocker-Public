# Set parameters for SolutionConfig.xml

$StorageSizeMBNode = "//StorageSizeMB"
$StorageSizeMB = "5120"

$StorageFileNode = "//StorageFile"
$StorageFile = "C:\Kofax\KIC-ED\MC\Storage.bin"

$PrefetchMaxNode = "//PrefetchMax"
$PrefetchMax = "40"

$EnableDecompressionNode = "//EnableDecompression"
$EnableDecompression = "1"

$HandleNestedBodyAsNode = "//HandleNestedBodyAs"
$HandleNestedBodyAs = "Body"

$TraceLocationNode = "//TraceLocation"
$TraceLocation = "C:\Kofax\KIC-ED"

$TempBaseFolderNode = "//TempBaseFolder"
$TempBaseFolder = "C:\Kofax\KIC-ED"


#update SolutionConfig.xml 

$xmlfile = "C:\Program Files (x86)\Kofax\KIC-ED\MC\config\SolutionConfig.xml"

Copy-Item -Path $xmlfile -Destination "C:\Program Files (x86)\Kofax\KIC-ED\MC\config\SolutionConfig_buildtime_backup.xml"

$xmlcontent = New-Object XML
$xmlcontent.Load($xmlfile)

$targetnode = $xmlcontent.SelectSingleNode($StorageSizeMBNode)
$targetnode.InnerText = $StorageSizeMB

$targetnode = $xmlcontent.SelectSingleNode($StorageFileNode)
$targetnode.InnerText = $StorageFile

$targetnode = $xmlcontent.SelectSingleNode($PrefetchMaxNode)
$targetnode.InnerText = $PrefetchMax

$targetnode = $xmlcontent.SelectSingleNode($EnableDecompressionNode)
if ($null -ne $targetnode)
{
    $targetnode.InnerText = $EnableDecompression
}

$targetnode = $xmlcontent.SelectSingleNode($HandleNestedBodyAsNode)
$targetnode.InnerText = $HandleNestedBodyAs

$targetnode = $xmlcontent.SelectSingleNode($TraceLocationNode)
$targetnode.InnerText = $TraceLocation

$targetnode = $xmlcontent.SelectSingleNode($TempBaseFolderNode)
$targetnode.InnerText = $TempBaseFolder


#Write updated file
$xmlcontent.Save($xmlfile)

# Set parameters for InternalConfig.xml

$PathNameNode = "//Trace/File/PathName"
$PathName = "C:\Kofax\KIC-ED\MC\Log\MC_"

$LicenseCacheFileNode = "//LicenseCacheFile"
$LicenseCacheFile = "C:\Kofax\KIC-ED\MC\Storage.bin\..\KIC-ED-MC-FeatureCache.xml"

$DirectoryNode = "//Blob/Directory"
$Directory = "C:\Kofax\KIC-ED\MC\Blobs"

$PrefetchMaxNode = "//Code/TncAlbin/PrefetchMax"
$PrefetchMax = "40"

$TempPathNode = "//Code/TncDocConv/TempPath"
$TempPath = "C:\Kofax\KIC-ED\MC\Temp"

$TraceLocationNode = "//TraceLocation"
$TraceLocation = "C:\Kofax\KIC-ED"

$BtrTracePathNameNode = "//Trace/BtrTracePathName"
$BtrTracePathName = "C:\Kofax\KIC-ED\MC\Log\Fax_%04i"

$FilePathNode = "//ComponentList/Component/Code/TncStore/FilePath"
$FilePath = "C:\Kofax\KIC-ED\MC\Storage.bin"

$FileSizeMBNode = "//ComponentList/Component/Code/TncStore/FileSizeMB"
$FileSizeMB = "5120"

$ObjectMaxNode = "//ComponentList/Component/Code/TncStore/ObjectMax"
$ObjectMax = "256000"


#update SolutionConfig.xml 

$xmlfile = "C:\Program Files (x86)\Kofax\KIC-ED\MC\config\InternalConfig.xml"


Copy-Item -Path $xmlfile -Destination "C:\Program Files (x86)\Kofax\KIC-ED\MC\config\InternalConfig_buildtime_backup.xml"

$xmlcontent = New-Object XML
$xmlcontent.Load($xmlfile)

$targetnode = $xmlcontent.SelectSingleNode($PathNameNode)
if ($null -ne $targetnode)
{
    $targetnode.InnerText = $PathName
}
$targetnode = $xmlcontent.SelectSingleNode($LicenseCacheFileNode)
if ($null -ne $targetnode)
{
    $targetnode.InnerText = $LicenseCacheFile
}
$targetnode = $xmlcontent.SelectSingleNode($DirectoryNode)
if ($null -ne $targetnode)
{
    $targetnode.InnerText = $Directory
}
$targetnode = $xmlcontent.SelectSingleNode($PrefetchMaxNode)
if ($null -ne $targetnode)
{
    $targetnode.InnerText = $PrefetchMax
}
$targetnode = $xmlcontent.SelectSingleNode($TempPathNode)
if ($null -ne $targetnode)
{
    $targetnode.InnerText = $TempPath
}
$targetnode = $xmlcontent.SelectSingleNode($TraceLocationNode)
if ($null -ne $targetnode)
{
    $targetnode.InnerText = $TraceLocation
}
$targetnode = $xmlcontent.SelectSingleNode($BtrTracePathNameNode)
if ($null -ne $targetnode)
{
    $targetnode.InnerText = $BtrTracePathName
}
$targetnode = $xmlcontent.SelectSingleNode($FilePathNode)
if ($null -ne $targetnode)
{
    $targetnode.InnerText = $FilePath
}
$targetnode = $xmlcontent.SelectSingleNode($FileSizeMBNode)
if ($null -ne $targetnode)
{
    $targetnode.InnerText = $FileSizeMB
}
$targetnode = $xmlcontent.SelectSingleNode($ObjectMaxNode)
if ($null -ne $targetnode)
{
    $targetnode.InnerText = $ObjectMax
}


#Write updated file
$xmlcontent.Save($xmlfile)

#restart MC
cmd.exe /c "C:\Program Files (x86)\Kofax\KIC-ED\MC\restart.bat"

