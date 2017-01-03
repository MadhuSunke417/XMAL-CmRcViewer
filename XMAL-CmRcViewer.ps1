﻿function XMAL-CmRCViewer
{

#==============================================================================================
# XAML Code – Imported from Visual Studio Express WPF Application
#==============================================================================================
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @'
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="CmRcViewer" Height="157.453" Width="282.182" ResizeMode="NoResize" Background="{DynamicResource {x:Static SystemColors.GrayTextBrushKey}}" WindowStartupLocation="CenterScreen">
    <Grid>
        <TextBox Name="textBox" HorizontalAlignment="Left" Height="23" Margin="114,22,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <Button Name="button" Content="Connect" HorizontalAlignment="Left" Margin="29,72,0,0" VerticalAlignment="Top" Width="96" RenderTransformOrigin="0.12,-0.478"/>
        <Button Name="button1" Content="History" HorizontalAlignment="Left" Margin="138,72,0,0" VerticalAlignment="Top" Width="96"/>
        <TextBlock Name="textBlock" HorizontalAlignment="Left" Margin="10,22,0,0" TextWrapping="Wrap" Text="Computer Name" VerticalAlignment="Top" Width="95" Height="23"/>

    </Grid>
</Window>

'@

#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}

#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

$log_path = 'C:\WBG\Logs\CmRcViewer.log'

$date = Get-Date 

#===========================================================================
# Invoke Connect
#===========================================================================

$button.Add_Click(

{
if($textBox.Text)
{

$compName = ($textBox.Text).Trim()

if(Test-Connection -ComputerName $compName -Count 2 -Quiet)
{
[System.Windows.Forms.MessageBox]::Show("Online",'Status')

if (Test-Path 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\i386\CmRcViewer.exe')
{

& 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\i386\CmRcViewer.exe' $compName


Out-File -FilePath $log_path -InputObject "$date - $compName" -Append

}
else
{
[System.Windows.Forms.MessageBox]::Show("There is no such CmRcViewer.exe exists, please check and try again",'Status','OK','Error')
}
}
else
{
[System.Windows.Forms.MessageBox]::Show("Seems machine is offline or not accessible, please check and try again",'Status','OK','Error')

Out-File -FilePath $log_path -InputObject "$date - $compName" -Append

}
}
else
{
[System.Windows.Forms.MessageBox]::Show("Please enter the Machine Name and try again",'Status','OK','Error')
}
})

#===========================================================================
# Invoke History
#===========================================================================
$button1.Add_Click(

{
Invoke-Item -Path $log_path 
}
)

#===========================================================================
# Shows the form
#===========================================================================
$Form.ShowDialog() | out-null
}

XMAL-CmRCViewer