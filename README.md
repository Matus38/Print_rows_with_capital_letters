# Print_rows_with_capital_letters
Print rows which contains words starting with capital letter

Funkcia číta do buffera veľkosti 1024 bytov súbor. Následne začne porovnávať jednotlivé znaky. 
Ak zistí že znak je veľké písmeno skontroluje či v pomocnej premennej „začiatok“ je hodnota 1, ktorá značí, 
že pred týmto znakom bola buď medzera, tabulátor alebo začiatok riadka, ak je to hodnota 1 začnú sa postupne
vypisovať znaky až po koniec riadka a inkrementuje sa počet riadkov. V prípade že znak je veľké písmeno, ale 
hodnota v premennej „začiatok“ je 0 pokračuje sa v porovnávaní ďalej. Ak je načítaný znak medzera, tabulátor
alebo začiatok riadka pomocná premenná sa nastaví na 1. Po prečítaní celého buffera sa načíta ďalšia časť
súboru a postup sa opakuje. V prípade že na narazí na koniec súboru, program dokončí postup a ukončí sa funkcia.

