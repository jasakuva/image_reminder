param(
    [string]$Source
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

function Save-ResizedPng {
    param(
        [Parameter(Mandatory = $true)] [System.Drawing.Image]$SourceImage,
        [Parameter(Mandatory = $true)] [int]$Size,
        [Parameter(Mandatory = $true)] [string]$OutputPath
    )

    $directory = Split-Path -Parent $OutputPath
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory | Out-Null
    }

    $bitmap = New-Object System.Drawing.Bitmap $Size, $Size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.Clear([System.Drawing.Color]::FromArgb(255, 16, 17, 20))

    $sourceSize = [Math]::Min($SourceImage.Width, $SourceImage.Height)
    $sourceX = [Math]::Floor(($SourceImage.Width - $sourceSize) / 2)
    $sourceY = [Math]::Floor(($SourceImage.Height - $sourceSize) / 2)
    $sourceRect = New-Object System.Drawing.Rectangle $sourceX, $sourceY, $sourceSize, $sourceSize
    $targetRect = New-Object System.Drawing.Rectangle 0, 0, $Size, $Size

    $graphics.DrawImage($SourceImage, $targetRect, $sourceRect, [System.Drawing.GraphicsUnit]::Pixel)
    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
}

if ([string]::IsNullOrWhiteSpace($Source)) {
    $rootPngs = @(Get-ChildItem -Path . -Filter '*.png')
    if ($rootPngs.Count -ne 1) {
        throw "Expected exactly one PNG in the project root, found $($rootPngs.Count). Pass -Source explicitly."
    }
    $Source = $rootPngs[0].FullName
}

$sourcePath = Resolve-Path $Source
$image = [System.Drawing.Image]::FromFile($sourcePath)
try {
    Write-Output "Source icon: $sourcePath"
    Write-Output "Source size: $($image.Width)x$($image.Height)"

    $androidIcons = @(
        @{ Size = 48; Path = 'android/app/src/main/res/mipmap-mdpi/ic_launcher.png' },
        @{ Size = 72; Path = 'android/app/src/main/res/mipmap-hdpi/ic_launcher.png' },
        @{ Size = 96; Path = 'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png' },
        @{ Size = 144; Path = 'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png' },
        @{ Size = 192; Path = 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png' }
    )

    foreach ($icon in $androidIcons) {
        Save-ResizedPng -SourceImage $image -Size $icon.Size -OutputPath $icon.Path
        Write-Output "Generated $($icon.Path)"
    }

    $iosIcons = @(
        @{ Size = 40; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png' },
        @{ Size = 60; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png' },
        @{ Size = 29; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png' },
        @{ Size = 58; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png' },
        @{ Size = 87; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png' },
        @{ Size = 80; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png' },
        @{ Size = 120; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png' },
        @{ Size = 120; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png' },
        @{ Size = 180; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png' },
        @{ Size = 20; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png' },
        @{ Size = 76; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png' },
        @{ Size = 152; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png' },
        @{ Size = 167; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png' },
        @{ Size = 1024; Path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png' }
    )

    foreach ($icon in $iosIcons) {
        Save-ResizedPng -SourceImage $image -Size $icon.Size -OutputPath $icon.Path
        Write-Output "Generated $($icon.Path)"
    }
}
finally {
    $image.Dispose()
}
