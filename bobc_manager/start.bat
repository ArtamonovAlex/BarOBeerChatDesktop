
set LIB_PATH=%CD%\_build\default\lib
set PROJECT_BEAMS=%LIB_PATH%\bobc_manager\ebin
set COWBOY_BEAMS=%LIB_PATH%\cowboy\ebin
set COWLIB_BEAMS=%LIB_PATH%\cowlib\ebin
set RANCH_BEAMS=%LIB_PATH%\ranch\ebin
set JSONE_BEAMS=%LIB_PATH%\jsone\ebin
erl -sname manager -bobc_manager port %1 -pa "%PROJECT_BEAMS%" -pa "%COWBOY_BEAMS%" -pa "%COWLIB_BEAMS%" -pa "%RANCH_BEAMS%" -pa "%JSONE_BEAMS%" -s starter start