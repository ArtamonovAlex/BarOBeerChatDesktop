
set LIB_PATH=%CD%\_build\default\lib
set PROJECT_BEAMS=%LIB_PATH%\bobc\ebin
set COWBOY_BEAMS=%LIB_PATH%\cowboy\ebin
set COWLIB_BEAMS=%LIB_PATH%\cowlib\ebin
set RANCH_BEAMS=%LIB_PATH%\ranch\ebin
set JSONE_BEAMS=%LIB_PATH%\jsone\ebin
erl -sname %1 -bobc internal %2 -bobc external %3 -bobc remote %4 -pa "%PROJECT_BEAMS%" -pa "%COWBOY_BEAMS%" -pa "%COWLIB_BEAMS%" -pa "%RANCH_BEAMS%" -pa "%JSONE_BEAMS%" -s test main