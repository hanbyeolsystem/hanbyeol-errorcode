@echo off
REM ===============================================
REM  한별시스템 에러코드 동기화 스크립트
REM  로컬 repo -> NAS + GitHub 동시 반영
REM  실행 전 로컬 파일이 최신 상태인지 확인하세요
REM ===============================================

setlocal enabledelayedexpansion

set REPO=%~dp0
set NAS=\\192.168.0.249\ErrorCode
set STAMP=%date:~0,4%%date:~5,2%%date:~8,2%
set STAMP=%STAMP: =0%

echo.
echo [1/4] NAS 기존 파일 백업 (같은 날 백업 있으면 덮어씀)
if exist "%NAS%\index.html"       copy /Y "%NAS%\index.html"       "%NAS%\index.backup_%STAMP%.html"       >nul
if exist "%NAS%\errors_v2.json"   copy /Y "%NAS%\errors_v2.json"   "%NAS%\errors_v2.backup_%STAMP%.json"  >nul

echo [2/4] 로컬 -> NAS 복사
copy /Y "%REPO%index.html"        "%NAS%\index.html"        >nul
copy /Y "%REPO%errors_v2.json"    "%NAS%\errors_v2.json"    >nul
if not exist "%NAS%\ECC" mkdir "%NAS%\ECC"
xcopy /Y /E /I /Q "%REPO%ECC\*" "%NAS%\ECC\" >nul

echo [3/4] Git 커밋
pushd "%REPO%"
git add -A
git diff --cached --quiet
if errorlevel 1 (
  set /p MSG="커밋 메시지 (엔터시 'Update errors'): "
  if "!MSG!"=="" set MSG=Update errors
  git commit -m "!MSG!"
) else (
  echo   변경사항 없음 - 커밋 건너뜀
)

echo [4/4] Git push (GitHub Pages 자동 재배포 1~2분)
git push
popd

echo.
echo ===============================================
echo  동기화 완료
echo  URL: https://hanbyeolsystem.github.io/hanbyeol-errorcode/
echo ===============================================
pause
