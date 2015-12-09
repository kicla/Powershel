#========================================================================
# Created with: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.1.35
# Created on:   16.01.2015 13:17
# Created by:   Kim Clausen
# Organization: Keystep
# Filename:     
#========================================================================

[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
$chart1 = New-object System.Windows.Forms.DataVisualization.Charting.Chart
$chart1.Width = 1200
$chart1.Height = 500
$chart1.BackColor = [System.Drawing.Color]::White

# title
   [void]$chart1.Titles.Add("Active ICA per server")
   $chart1.Titles[0].Font = "Arial,13pt"
   $chart1.Titles[0].Alignment = "topLeft"
# chart area
   $chartarea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
   $chartarea.Name = "ChartArea1"
   $chartarea.AxisY.Title = "Connections"
   $chartarea.AxisX.Title = "Servers"
   $chartarea.AxisY.Interval = 1
   $chartarea.AxisX.Interval = 1
   $chart1.ChartAreas.Add($chartarea)
# legend
   $legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
   $legend.name = "Legend1"
   $chart1.Legends.Add($legend)

# data source    $datasource = Get-ActiveSyncDevice | select devicemodel | Group-Object devicemodel

$datasource = Get-XASession | ? { $_.Protocol -eq "ICA" -and $_.State -eq "Active"}|select Servername,Appname |group ServerName |sort name |select count,name 

# data series
   [void]$chart1.Series.Add("Connections")
   $chart1.Series["Connections"].ChartType = "Column"
   $chart1.Series["Connections"].BorderWidth  = 3
   $chart1.Series["Connections"].IsVisibleInLegend = $true
   $chart1.Series["Connections"].chartarea = "ChartArea1"
   $chart1.Series["Connections"].Legend = "Legend1"
   $chart1.Series["Connections"].color = "#62B5CC"
   $datasource | ForEach-Object {$chart1.Series["Connections"].Points.addxy( $_.name , $_.count) } 

$chart1.SaveImage("P:\kicla\powershell\AS_graph.png","png") 
