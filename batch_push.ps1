$repoPath = "C:\email_solutions-images"
cd $repoPath

# Reset completely
if (Test-Path .git) {
    # Remove index and HEAD
    git read-tree --empty
    git update-ref -d HEAD
} else {
    git init
}

# Add index files first
git add public/index.html public/_headers public/_redirects
git commit -m "Initial commit: redirects and headers [skip ci]"
git push -u origin main --force

# Get all images
$images = Get-ChildItem public/images/calendar -File

$batchSize = 300
$total = $images.Count
for ($i = 0; $i -lt $total; $i += $batchSize) {
    $end = [Math]::Min($i + $batchSize - 1, $total - 1)
    $batch = $images[$i..$end]
    foreach ($file in $batch) {
        if ($file) {
            git add $file.FullName
        }
    }
    $batchNum = ($i / $batchSize) + 1
    $totalBatches = [Math]::Ceiling($total / $batchSize)
    # Use [skip ci] to prevent Cloudflare from building until we are ready
    git commit -m "Batch $batchNum of $totalBatches images [skip ci]"
    Write-Host "Pushing batch $batchNum of $totalBatches..."
    git push origin main
}
