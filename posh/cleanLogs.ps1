$root  = '.'
$limit = (Get-Date).AddDays(-5)

Get-ChildItem $root -Include "*.log" | ? {
  -not $_.PSIsContainer -and $_.CreationTime -lt $limit
} | Remove-Item -WhatIf