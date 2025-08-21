# run-complete-ellis-pipeline.ps1
# Complete Ellis Pipeline Execution Script
# Runs all 4 stages of the Ellis pipeline in sequence with proper error handling

Write-Host "STARTING COMPLETE ELLIS PIPELINE" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# Stage 0: Core Foundation
Write-Host "Stage 0: Core Foundation" -ForegroundColor Yellow
Write-Host "Running: manipulation/0-ellis.R" -ForegroundColor Gray

try {
    Rscript manipulation/0-ellis.R
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Stage 0 completed successfully!" -ForegroundColor Green
        Write-Host ""
        
        # Stage 1: Administrative Integration
        Write-Host "Stage 1: Administrative Integration" -ForegroundColor Yellow
        Write-Host "Running: manipulation/1-ellis-ua-admin.R" -ForegroundColor Gray
        
        try {
            Rscript manipulation/1-ellis-ua-admin.R
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Stage 1 completed successfully!" -ForegroundColor Green
                Write-Host ""
                
                # Stage 2: Custom Data Integration
                Write-Host "Stage 2: Custom Data Integration" -ForegroundColor Yellow
                Write-Host "Running: manipulation/2-ellis-extra.R" -ForegroundColor Gray
                
                try {
                    Rscript manipulation/2-ellis-extra.R
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "Stage 2 completed successfully!" -ForegroundColor Green
                        Write-Host ""
                        
                        # Final Stage: Analytical Optimization
                        Write-Host "Final Stage: Analytical Optimization" -ForegroundColor Yellow
                        Write-Host "Running: manipulation/last-ellis.R" -ForegroundColor Gray
                        
                        try {
                            Rscript manipulation/last-ellis.R
                            if ($LASTEXITCODE -eq 0) {
                                Write-Host "Final stage completed successfully!" -ForegroundColor Green
                                Write-Host ""
                                Write-Host "COMPLETE ELLIS PIPELINE FINISHED SUCCESSFULLY!" -ForegroundColor Green -BackgroundColor Black
                                Write-Host "All databases ready for analysis:" -ForegroundColor Green
                                Write-Host "   - books-of-ukraine-0.sqlite (Stage 0: Core Foundation)" -ForegroundColor White
                                Write-Host "   - books-of-ukraine-1.sqlite (Stage 1: + Administrative Data)" -ForegroundColor White
                                Write-Host "   - books-of-ukraine-2.sqlite (Stage 2: + Custom Data)" -ForegroundColor White
                                Write-Host "   - books-of-ukraine.sqlite (Final: Analysis-ready)" -ForegroundColor White
                                Write-Host ""
                                Write-Host "Pipeline execution completed at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
                            } else {
                                Write-Host "Final stage failed with exit code: $LASTEXITCODE" -ForegroundColor Red
                                exit 1
                            }
                        }
                        catch {
                            Write-Host "Final stage failed with error: $($_.Exception.Message)" -ForegroundColor Red
                            exit 1
                        }
                    } else {
                        Write-Host "Stage 2 failed with exit code: $LASTEXITCODE" -ForegroundColor Red
                        Write-Host "Pipeline stopped at Stage 2" -ForegroundColor Yellow
                        exit 1
                    }
                }
                catch {
                    Write-Host "Stage 2 failed with error: $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host "Pipeline stopped at Stage 2" -ForegroundColor Yellow
                    exit 1
                }
            } else {
                Write-Host "Stage 1 failed with exit code: $LASTEXITCODE" -ForegroundColor Red
                Write-Host "Pipeline stopped at Stage 1" -ForegroundColor Yellow
                exit 1
            }
        }
        catch {
            Write-Host "Stage 1 failed with error: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Pipeline stopped at Stage 1" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "Stage 0 failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host "Pipeline stopped at Stage 0" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host "Stage 0 failed with error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Pipeline stopped at Stage 0" -ForegroundColor Yellow
    exit 1
}
