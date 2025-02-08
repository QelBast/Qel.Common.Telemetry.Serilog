

$sourcePath = Get-Location

#Получаем имя проекта
$dirs = $sourcePath.Path.Split('\')
$targetProj = $dirs[$dirs.Count-1]
Write-Host $targetProj

$destination = Join-Path $sourcePath $targetProj

# Создаём новую вложенную папку
New-Item -ItemType Directory -Path $destination -Force

# Перемещаем файлы и папки, кроме ".git"
Get-ChildItem -Path $sourcePath -Exclude ".git" | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $destination -Force
}

# Берём зависимости dotnet проекта
$xml = [Xml](Get-Content .\$targetProj\$targetProj.csproj)
$nodes = $xml.SelectNodes("/Project/ItemGroup/ProjectReference/@Include")
foreach ($node in $nodes) {
    $loc = Split-Path -Path (Resolve-Path $node.'#text') -Parent
    # Переносим папки зависимостей
    Copy-Item -Path $loc.Path -Destination $destination -Force
    Write-Host $loc.Path
}

