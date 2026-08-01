-- Migration 121: Fix US city populations (match by name+state)
-- Migration 112 had a 1:1 matching bug: when multiple US cities had the
-- same name (e.g. 4 Phoenix's), only one got a population. This migration
-- re-matches by (name, state_code) and updates 4,614 cities.

UPDATE cities SET population = CASE id WHEN 112872 THEN 2736074 ELSE population END WHERE id IN (112872);

UPDATE cities SET population = CASE id WHEN 118699 THEN 2314157 ELSE population END WHERE id IN (118699);

UPDATE cities SET population = CASE id WHEN 124148 THEN 1650070 ELSE population END WHERE id IN (124148);

UPDATE cities SET population = CASE id WHEN 124126 THEN 1573916 ELSE population END WHERE id IN (124126);

UPDATE cities SET population = CASE id WHEN 125787 THEN 1526656 ELSE population END WHERE id IN (125787);

UPDATE cities SET population = CASE id WHEN 121115 THEN 1487536 ELSE population END WHERE id IN (121115);

UPDATE cities SET population = CASE id WHEN 125802 THEN 1404452 ELSE population END WHERE id IN (125802);

UPDATE cities SET population = CASE id WHEN 114990 THEN 1326087 ELSE population END WHERE id IN (114990);

UPDATE cities SET population = CASE id WHEN 119101 THEN 1009833 ELSE population END WHERE id IN (119101);

UPDATE cities SET population = CASE id WHEN 111668 THEN 974447 ELSE population END WHERE id IN (111668);

UPDATE cities SET population = CASE id WHEN 141234 THEN 913175 ELSE population END WHERE id IN (141234);

UPDATE cities SET population = CASE id WHEN 115253 THEN 729019 ELSE population END WHERE id IN (115253);

UPDATE cities SET population = CASE id WHEN 122577 THEN 689447 ELSE population END WHERE id IN (122577);

UPDATE cities SET population = CASE id WHEN 115930 THEN 678815 ELSE population END WHERE id IN (115930);

UPDATE cities SET population = CASE id WHEN 112589 THEN 653833 ELSE population END WHERE id IN (112589);

UPDATE cities SET population = CASE id WHEN 124565 THEN 652503 ELSE population END WHERE id IN (124565);

UPDATE cities SET population = CASE id WHEN 121639 THEN 633104 ELSE population END WHERE id IN (121639);

UPDATE cities SET population = CASE id WHEN 120813 THEN 624444 ELSE population END WHERE id IN (120813);

UPDATE cities SET population = CASE id WHEN 126629 THEN 571281 ELSE population END WHERE id IN (126629);

UPDATE cities SET population = CASE id WHEN 116939 THEN 542107 ELSE population END WHERE id IN (116939);

UPDATE cities SET population = CASE id WHEN 124831 THEN 482295 ELSE population END WHERE id IN (124831);

UPDATE cities SET population = CASE id WHEN 119384 THEN 475378 ELSE population END WHERE id IN (119384);

UPDATE cities SET population = CASE id WHEN 120738 THEN 474140 ELSE population END WHERE id IN (120738);

UPDATE cities SET population = CASE id WHEN 123293 THEN 419267 ELSE population END WHERE id IN (123293);

UPDATE cities SET population = CASE id WHEN 121951 THEN 410939 ELSE population END WHERE id IN (121951);

UPDATE cities SET population = CASE id WHEN 111464 THEN 388125 ELSE population END WHERE id IN (111464);

UPDATE cities SET population = CASE id WHEN 141223 THEN 365379 ELSE population END WHERE id IN (141223);

UPDATE cities SET population = CASE id WHEN 111662 THEN 359407 ELSE population END WHERE id IN (111662);

UPDATE cities SET population = CASE id WHEN 120439 THEN 320347 ELSE population END WHERE id IN (120439);

UPDATE cities SET population = CASE id WHEN 125209 THEN 317261 ELSE population END WHERE id IN (125209);

UPDATE cities SET population = CASE id WHEN 127074 THEN 305658 ELSE population END WHERE id IN (127074);

UPDATE cities SET population = CASE id WHEN 125703 THEN 303176 ELSE population END WHERE id IN (125703);

UPDATE cities SET population = CASE id WHEN 120506 THEN 294757 ELSE population END WHERE id IN (120506);

UPDATE cities SET population = CASE id WHEN 111305 THEN 289600 ELSE population END WHERE id IN (111305);

UPDATE cities SET population = CASE id WHEN 118278 THEN 285667 ELSE population END WHERE id IN (118278);

UPDATE cities SET population = CASE id WHEN 117667 THEN 285342 ELSE population END WHERE id IN (117667);

UPDATE cities SET population = CASE id WHEN 124343 THEN 283558 ELSE population END WHERE id IN (124343);

UPDATE cities SET population = CASE id WHEN 122803 THEN 281944 ELSE population END WHERE id IN (122803);

UPDATE cities SET population = CASE id WHEN 120999 THEN 280305 ELSE population END WHERE id IN (120999);

UPDATE cities SET population = CASE id WHEN 141756 THEN 265638 ELSE population END WHERE id IN (141756);

UPDATE cities SET population = CASE id WHEN 125020 THEN 264165 ELSE population END WHERE id IN (125020);

UPDATE cities SET population = CASE id WHEN 113731 THEN 260828 ELSE population END WHERE id IN (113731);

UPDATE cities SET population = CASE id WHEN 113014 THEN 258071 ELSE population END WHERE id IN (113014);

UPDATE cities SET population = CASE id WHEN 119004 THEN 256927 ELSE population END WHERE id IN (119004);

UPDATE cities SET population = CASE id WHEN 117204 THEN 247542 ELSE population END WHERE id IN (117204);

UPDATE cities SET population = CASE id WHEN 117285 THEN 240126 ELSE population END WHERE id IN (117285);

UPDATE cities SET population = CASE id WHEN 113874 THEN 235429 ELSE population END WHERE id IN (113874);

UPDATE cities SET population = CASE id WHEN 116924 THEN 232206 ELSE population END WHERE id IN (116924);

UPDATE cities SET population = CASE id WHEN 125088 THEN 226610 ELSE population END WHERE id IN (125088);

UPDATE cities SET population = CASE id WHEN 123819 THEN 223167 ELSE population END WHERE id IN (123819);

UPDATE cities SET population = CASE id WHEN 116631 THEN 212704 ELSE population END WHERE id IN (116631);

UPDATE cities SET population = CASE id WHEN 125267 THEN 209802 ELSE population END WHERE id IN (125267);

UPDATE cities SET population = CASE id WHEN 111463 THEN 207627 ELSE population END WHERE id IN (111463);

UPDATE cities SET population = CASE id WHEN 114491 THEN 206922 ELSE population END WHERE id IN (114491);

UPDATE cities SET population = CASE id WHEN 116456 THEN 201963 ELSE population END WHERE id IN (116456);

UPDATE cities SET population = CASE id WHEN 117286 THEN 201020 ELSE population END WHERE id IN (117286);

UPDATE cities SET population = CASE id WHEN 111659 THEN 200661 ELSE population END WHERE id IN (111659);

UPDATE cities SET population = CASE id WHEN 141098 THEN 197542 ELSE population END WHERE id IN (141098);

UPDATE cities SET population = CASE id WHEN 117473 THEN 195097 ELSE population END WHERE id IN (117473);

UPDATE cities SET population = CASE id WHEN 124047 THEN 190985 ELSE population END WHERE id IN (124047);

UPDATE cities SET population = CASE id WHEN 124716 THEN 190934 ELSE population END WHERE id IN (124716);

UPDATE cities SET population = CASE id WHEN 119694 THEN 190740 ELSE population END WHERE id IN (119694);

UPDATE cities SET population = CASE id WHEN 112932 THEN 186738 ELSE population END WHERE id IN (112932);

UPDATE cities SET population = CASE id WHEN 126881 THEN 178395 ELSE population END WHERE id IN (126881);

UPDATE cities SET population = CASE id WHEN 125922 THEN 178127 ELSE population END WHERE id IN (125922);

UPDATE cities SET population = CASE id WHEN 123344 THEN 175691 ELSE population END WHERE id IN (123344);

UPDATE cities SET population = CASE id WHEN 125740 THEN 175535 ELSE population END WHERE id IN (125740);

UPDATE cities SET population = CASE id WHEN 123486 THEN 171214 ELSE population END WHERE id IN (123486);

UPDATE cities SET population = CASE id WHEN 126893 THEN 170188 ELSE population END WHERE id IN (126893);

UPDATE cities SET population = CASE id WHEN 118567 THEN 167664 ELSE population END WHERE id IN (118567);

UPDATE cities SET population = CASE id WHEN 114154 THEN 166722 ELSE population END WHERE id IN (114154);

UPDATE cities SET population = CASE id WHEN 122482 THEN 165430 ELSE population END WHERE id IN (122482);

UPDATE cities SET population = CASE id WHEN 114662 THEN 164226 ELSE population END WHERE id IN (114662);

UPDATE cities SET population = CASE id WHEN 120089 THEN 161103 ELSE population END WHERE id IN (120089);

UPDATE cities SET population = CASE id WHEN 111151 THEN 159467 ELSE population END WHERE id IN (111151);

UPDATE cities SET population = CASE id WHEN 123757 THEN 158351 ELSE population END WHERE id IN (123757);

UPDATE cities SET population = CASE id WHEN 118197 THEN 158289 ELSE population END WHERE id IN (118197);

UPDATE cities SET population = CASE id WHEN 127265 THEN 155805 ELSE population END WHERE id IN (127265);

UPDATE cities SET population = CASE id WHEN 126897 THEN 154341 ELSE population END WHERE id IN (126897);

UPDATE cities SET population = CASE id WHEN 123896 THEN 153784 ELSE population END WHERE id IN (123896);

UPDATE cities SET population = CASE id WHEN 119065 THEN 153701 ELSE population END WHERE id IN (119065);

UPDATE cities SET population = CASE id WHEN 124459 THEN 153266 ELSE population END WHERE id IN (124459);

UPDATE cities SET population = CASE id WHEN 120050 THEN 152597 ELSE population END WHERE id IN (120050);

UPDATE cities SET population = CASE id WHEN 111562 THEN 150165 ELSE population END WHERE id IN (111562);

UPDATE cities SET population = CASE id WHEN 125300 THEN 148278 ELSE population END WHERE id IN (125300);

UPDATE cities SET population = CASE id WHEN 115679 THEN 147993 ELSE population END WHERE id IN (115679);

UPDATE cities SET population = CASE id WHEN 112766 THEN 147629 ELSE population END WHERE id IN (112766);

UPDATE cities SET population = CASE id WHEN 127365 THEN 144142 ELSE population END WHERE id IN (127365);

UPDATE cities SET population = CASE id WHEN 114471 THEN 142416 ELSE population END WHERE id IN (114471);

UPDATE cities SET population = CASE id WHEN 123897 THEN 142250 ELSE population END WHERE id IN (123897);

UPDATE cities SET population = CASE id WHEN 123510 THEN 140992 ELSE population END WHERE id IN (123510);

UPDATE cities SET population = CASE id WHEN 116983 THEN 140847 ELSE population END WHERE id IN (116983);

UPDATE cities SET population = CASE id WHEN 112117 THEN 139820 ELSE population END WHERE id IN (112117);

UPDATE cities SET population = CASE id WHEN 117931 THEN 137148 ELSE population END WHERE id IN (117931);

UPDATE cities SET population = CASE id WHEN 141260 THEN 135512 ELSE population END WHERE id IN (141260);

UPDATE cities SET population = CASE id WHEN 128481 THEN 134056 ELSE population END WHERE id IN (128481);

UPDATE cities SET population = CASE id WHEN 127603 THEN 133451 ELSE population END WHERE id IN (127603);

UPDATE cities SET population = CASE id WHEN 113470 THEN 133168 ELSE population END WHERE id IN (113470);

UPDATE cities SET population = CASE id WHEN 113765 THEN 132609 ELSE population END WHERE id IN (113765);

UPDATE cities SET population = CASE id WHEN 121800 THEN 132524 ELSE population END WHERE id IN (121800);

UPDATE cities SET population = CASE id WHEN 115247 THEN 131044 ELSE population END WHERE id IN (115247);

UPDATE cities SET population = CASE id WHEN 122716 THEN 130322 ELSE population END WHERE id IN (122716);

UPDATE cities SET population = CASE id WHEN 125441 THEN 130269 ELSE population END WHERE id IN (125441);

UPDATE cities SET population = CASE id WHEN 114468 THEN 129330 ELSE population END WHERE id IN (114468);

UPDATE cities SET population = CASE id WHEN 115972 THEN 129007 ELSE population END WHERE id IN (115972);

UPDATE cities SET population = CASE id WHEN 126944 THEN 128874 ELSE population END WHERE id IN (126944);

UPDATE cities SET population = CASE id WHEN 114543 THEN 128667 ELSE population END WHERE id IN (114543);

UPDATE cities SET population = CASE id WHEN 111170 THEN 127764 ELSE population END WHERE id IN (111170);

UPDATE cities SET population = CASE id WHEN 119487 THEN 126952 ELSE population END WHERE id IN (119487);

UPDATE cities SET population = CASE id WHEN 110983 THEN 125182 ELSE population END WHERE id IN (110983);

UPDATE cities SET population = CASE id WHEN 111283 THEN 122366 ELSE population END WHERE id IN (111283);

UPDATE cities SET population = CASE id WHEN 119832 THEN 121374 ELSE population END WHERE id IN (119832);

UPDATE cities SET population = CASE id WHEN 113943 THEN 121345 ELSE population END WHERE id IN (113943);

UPDATE cities SET population = CASE id WHEN 118087 THEN 121054 ELSE population END WHERE id IN (118087);

UPDATE cities SET population = CASE id WHEN 112223 THEN 120972 ELSE population END WHERE id IN (112223);

UPDATE cities SET population = CASE id WHEN 111199 THEN 120207 ELSE population END WHERE id IN (111199);

UPDATE cities SET population = CASE id WHEN 118892 THEN 117255 ELSE population END WHERE id IN (118892);

UPDATE cities SET population = CASE id WHEN 112344 THEN 117116 ELSE population END WHERE id IN (112344);

UPDATE cities SET population = CASE id WHEN 118023 THEN 116345 ELSE population END WHERE id IN (118023);

UPDATE cities SET population = CASE id WHEN 129047 THEN 116317 ELSE population END WHERE id IN (129047);

UPDATE cities SET population = CASE id WHEN 129322 THEN 115933 ELSE population END WHERE id IN (129322);

UPDATE cities SET population = CASE id WHEN 123360 THEN 114428 ELSE population END WHERE id IN (123360);

UPDATE cities SET population = CASE id WHEN 126890 THEN 114394 ELSE population END WHERE id IN (126890);

UPDATE cities SET population = CASE id WHEN 116052 THEN 113364 ELSE population END WHERE id IN (116052);

UPDATE cities SET population = CASE id WHEN 116316 THEN 112970 ELSE population END WHERE id IN (116316);

UPDATE cities SET population = CASE id WHEN 120127 THEN 112644 ELSE population END WHERE id IN (120127);

UPDATE cities SET population = CASE id WHEN 125266 THEN 112225 ELSE population END WHERE id IN (125266);

UPDATE cities SET population = CASE id WHEN 115966 THEN 112111 ELSE population END WHERE id IN (115966);

UPDATE cities SET population = CASE id WHEN 120836 THEN 110699 ELSE population END WHERE id IN (120836);

UPDATE cities SET population = CASE id WHEN 111373 THEN 110542 ELSE population END WHERE id IN (111373);

UPDATE cities SET population = CASE id WHEN 113252 THEN 110402 ELSE population END WHERE id IN (113252);

UPDATE cities SET population = CASE id WHEN 121098 THEN 110229 ELSE population END WHERE id IN (121098);

UPDATE cities SET population = CASE id WHEN 125096 THEN 109708 ELSE population END WHERE id IN (125096);

UPDATE cities SET population = CASE id WHEN 117586 THEN 108795 ELSE population END WHERE id IN (117586);

UPDATE cities SET population = CASE id WHEN 116149 THEN 108481 ELSE population END WHERE id IN (116149);

UPDATE cities SET population = CASE id WHEN 116260 THEN 108010 ELSE population END WHERE id IN (116260);

UPDATE cities SET population = CASE id WHEN 123191 THEN 107140 ELSE population END WHERE id IN (123191);

UPDATE cities SET population = CASE id WHEN 128023 THEN 105000 ELSE population END WHERE id IN (128023);

UPDATE cities SET population = CASE id WHEN 120436 THEN 104039 ELSE population END WHERE id IN (120436);

UPDATE cities SET population = CASE id WHEN 115059 THEN 102582 ELSE population END WHERE id IN (115059);

UPDATE cities SET population = CASE id WHEN 115875 THEN 102548 ELSE population END WHERE id IN (115875);

UPDATE cities SET population = CASE id WHEN 118452 THEN 102347 ELSE population END WHERE id IN (118452);

UPDATE cities SET population = CASE id WHEN 111108 THEN 101228 ELSE population END WHERE id IN (111108);

UPDATE cities SET population = CASE id WHEN 125228 THEN 100011 ELSE population END WHERE id IN (125228);

UPDATE cities SET population = CASE id WHEN 114467 THEN 99615 ELSE population END WHERE id IN (114467);

UPDATE cities SET population = CASE id WHEN 116166 THEN 99475 ELSE population END WHERE id IN (116166);

UPDATE cities SET population = CASE id WHEN 125105 THEN 98984 ELSE population END WHERE id IN (125105);

UPDATE cities SET population = CASE id WHEN 112010 THEN 96577 ELSE population END WHERE id IN (112010);

UPDATE cities SET population = CASE id WHEN 126659 THEN 96401 ELSE population END WHERE id IN (126659);

UPDATE cities SET population = CASE id WHEN 126805 THEN 96094 ELSE population END WHERE id IN (126805);

UPDATE cities SET population = CASE id WHEN 120662 THEN 94635 ELSE population END WHERE id IN (120662);

UPDATE cities SET population = CASE id WHEN 120226 THEN 93917 ELSE population END WHERE id IN (120226);

UPDATE cities SET population = CASE id WHEN 124797 THEN 93618 ELSE population END WHERE id IN (124797);

UPDATE cities SET population = CASE id WHEN 125833 THEN 92931 ELSE population END WHERE id IN (125833);

UPDATE cities SET population = CASE id WHEN 120927 THEN 92457 ELSE population END WHERE id IN (120927);

UPDATE cities SET population = CASE id WHEN 129048 THEN 92114 ELSE population END WHERE id IN (129048);

UPDATE cities SET population = CASE id WHEN 120964 THEN 91351 ELSE population END WHERE id IN (120964);

UPDATE cities SET population = CASE id WHEN 121695 THEN 90739 ELSE population END WHERE id IN (121695);

UPDATE cities SET population = CASE id WHEN 117687 THEN 90597 ELSE population END WHERE id IN (117687);

UPDATE cities SET population = CASE id WHEN 127808 THEN 89620 ELSE population END WHERE id IN (127808);

UPDATE cities SET population = CASE id WHEN 122865 THEN 88817 ELSE population END WHERE id IN (122865);

UPDATE cities SET population = CASE id WHEN 123190 THEN 88485 ELSE population END WHERE id IN (123190);

UPDATE cities SET population = CASE id WHEN 118175 THEN 88451 ELSE population END WHERE id IN (118175);

UPDATE cities SET population = CASE id WHEN 120644 THEN 88126 ELSE population END WHERE id IN (120644);

UPDATE cities SET population = CASE id WHEN 122571 THEN 87970 ELSE population END WHERE id IN (122571);

UPDATE cities SET population = CASE id WHEN 124931 THEN 87879 ELSE population END WHERE id IN (124931);

UPDATE cities SET population = CASE id WHEN 114536 THEN 87696 ELSE population END WHERE id IN (114536);

UPDATE cities SET population = CASE id WHEN 125914 THEN 87505 ELSE population END WHERE id IN (125914);

UPDATE cities SET population = CASE id WHEN 125881 THEN 87461 ELSE population END WHERE id IN (125881);

UPDATE cities SET population = CASE id WHEN 119652 THEN 87281 ELSE population END WHERE id IN (119652);

UPDATE cities SET population = CASE id WHEN 127771 THEN 87075 ELSE population END WHERE id IN (127771);

UPDATE cities SET population = CASE id WHEN 113345 THEN 86825 ELSE population END WHERE id IN (113345);

UPDATE cities SET population = CASE id WHEN 112452 THEN 86435 ELSE population END WHERE id IN (112452);

UPDATE cities SET population = CASE id WHEN 117172 THEN 86395 ELSE population END WHERE id IN (117172);

UPDATE cities SET population = CASE id WHEN 114259 THEN 86334 ELSE population END WHERE id IN (114259);

UPDATE cities SET population = CASE id WHEN 115513 THEN 86110 ELSE population END WHERE id IN (115513);

UPDATE cities SET population = CASE id WHEN 123369 THEN 85444 ELSE population END WHERE id IN (123369);

UPDATE cities SET population = CASE id WHEN 112120 THEN 85146 ELSE population END WHERE id IN (112120);

UPDATE cities SET population = CASE id WHEN 123227 THEN 85040 ELSE population END WHERE id IN (123227);

UPDATE cities SET population = CASE id WHEN 115015 THEN 84657 ELSE population END WHERE id IN (115015);

UPDATE cities SET population = CASE id WHEN 115870 THEN 84497 ELSE population END WHERE id IN (115870);

UPDATE cities SET population = CASE id WHEN 121980 THEN 83298 ELSE population END WHERE id IN (121980);

UPDATE cities SET population = CASE id WHEN 127848 THEN 83280 ELSE population END WHERE id IN (127848);

UPDATE cities SET population = CASE id WHEN 116454 THEN 82830 ELSE population END WHERE id IN (116454);

UPDATE cities SET population = CASE id WHEN 119911 THEN 82492 ELSE population END WHERE id IN (119911);

UPDATE cities SET population = CASE id WHEN 120757 THEN 82287 ELSE population END WHERE id IN (120757);

UPDATE cities SET population = CASE id WHEN 128525 THEN 81699 ELSE population END WHERE id IN (128525);

UPDATE cities SET population = CASE id WHEN 120051 THEN 81611 ELSE population END WHERE id IN (120051);

UPDATE cities SET population = CASE id WHEN 122376 THEN 81317 ELSE population END WHERE id IN (122376);

UPDATE cities SET population = CASE id WHEN 111701 THEN 80684 ELSE population END WHERE id IN (111701);

UPDATE cities SET population = CASE id WHEN 122431 THEN 80435 ELSE population END WHERE id IN (122431);

UPDATE cities SET population = CASE id WHEN 126595 THEN 80318 ELSE population END WHERE id IN (126595);

UPDATE cities SET population = CASE id WHEN 120227 THEN 80231 ELSE population END WHERE id IN (120227);

UPDATE cities SET population = CASE id WHEN 141623 THEN 79937 ELSE population END WHERE id IN (141623);

UPDATE cities SET population = CASE id WHEN 120916 THEN 79812 ELSE population END WHERE id IN (120916);

UPDATE cities SET population = CASE id WHEN 121596 THEN 79805 ELSE population END WHERE id IN (121596);

UPDATE cities SET population = CASE id WHEN 124384 THEN 79510 ELSE population END WHERE id IN (124384);

UPDATE cities SET population = CASE id WHEN 112877 THEN 79149 ELSE population END WHERE id IN (112877);

UPDATE cities SET population = CASE id WHEN 112451 THEN 78292 ELSE population END WHERE id IN (112451);

UPDATE cities SET population = CASE id WHEN 117913 THEN 77614 ELSE population END WHERE id IN (117913);

UPDATE cities SET population = CASE id WHEN 111632 THEN 77006 ELSE population END WHERE id IN (111632);

UPDATE cities SET population = CASE id WHEN 125671 THEN 76780 ELSE population END WHERE id IN (125671);

UPDATE cities SET population = CASE id WHEN 128039 THEN 76443 ELSE population END WHERE id IN (128039);

UPDATE cities SET population = CASE id WHEN 116626 THEN 76375 ELSE population END WHERE id IN (116626);

UPDATE cities SET population = CASE id WHEN 113263 THEN 76119 ELSE population END WHERE id IN (113263);

UPDATE cities SET population = CASE id WHEN 124405 THEN 75907 ELSE population END WHERE id IN (124405);

UPDATE cities SET population = CASE id WHEN 129636 THEN 75275 ELSE population END WHERE id IN (129636);

UPDATE cities SET population = CASE id WHEN 112367 THEN 75092 ELSE population END WHERE id IN (112367);

UPDATE cities SET population = CASE id WHEN 112291 THEN 74892 ELSE population END WHERE id IN (112291);

UPDATE cities SET population = CASE id WHEN 112933 THEN 74497 ELSE population END WHERE id IN (112933);

UPDATE cities SET population = CASE id WHEN 127987 THEN 74494 ELSE population END WHERE id IN (127987);

UPDATE cities SET population = CASE id WHEN 111397 THEN 74139 ELSE population END WHERE id IN (111397);

UPDATE cities SET population = CASE id WHEN 124894 THEN 73569 ELSE population END WHERE id IN (124894);

UPDATE cities SET population = CASE id WHEN 115151 THEN 73254 ELSE population END WHERE id IN (115151);

UPDATE cities SET population = CASE id WHEN 125644 THEN 72897 ELSE population END WHERE id IN (125644);

UPDATE cities SET population = CASE id WHEN 116829 THEN 72639 ELSE population END WHERE id IN (116829);

UPDATE cities SET population = CASE id WHEN 127498 THEN 72277 ELSE population END WHERE id IN (127498);

UPDATE cities SET population = CASE id WHEN 111394 THEN 72174 ELSE population END WHERE id IN (111394);

UPDATE cities SET population = CASE id WHEN 120934 THEN 71989 ELSE population END WHERE id IN (120934);

UPDATE cities SET population = CASE id WHEN 141196 THEN 71885 ELSE population END WHERE id IN (141196);

UPDATE cities SET population = CASE id WHEN 117797 THEN 71856 ELSE population END WHERE id IN (117797);

UPDATE cities SET population = CASE id WHEN 125280 THEN 71548 ELSE population END WHERE id IN (125280);

UPDATE cities SET population = CASE id WHEN 113695 THEN 71135 ELSE population END WHERE id IN (113695);

UPDATE cities SET population = CASE id WHEN 119834 THEN 71111 ELSE population END WHERE id IN (119834);

UPDATE cities SET population = CASE id WHEN 124294 THEN 69424 ELSE population END WHERE id IN (124294);

UPDATE cities SET population = CASE id WHEN 125132 THEN 69317 ELSE population END WHERE id IN (125132);

UPDATE cities SET population = CASE id WHEN 122402 THEN 68628 ELSE population END WHERE id IN (122402);

UPDATE cities SET population = CASE id WHEN 128612 THEN 68460 ELSE population END WHERE id IN (128612);

UPDATE cities SET population = CASE id WHEN 129509 THEN 67855 ELSE population END WHERE id IN (129509);

UPDATE cities SET population = CASE id WHEN 116658 THEN 67714 ELSE population END WHERE id IN (116658);

UPDATE cities SET population = CASE id WHEN 115073 THEN 67666 ELSE population END WHERE id IN (115073);

UPDATE cities SET population = CASE id WHEN 128220 THEN 67574 ELSE population END WHERE id IN (128220);

UPDATE cities SET population = CASE id WHEN 119103 THEN 67357 ELSE population END WHERE id IN (119103);

UPDATE cities SET population = CASE id WHEN 125322 THEN 66980 ELSE population END WHERE id IN (125322);

UPDATE cities SET population = CASE id WHEN 119068 THEN 66975 ELSE population END WHERE id IN (119068);

UPDATE cities SET population = CASE id WHEN 124562 THEN 66881 ELSE population END WHERE id IN (124562);

UPDATE cities SET population = CASE id WHEN 123781 THEN 66853 ELSE population END WHERE id IN (123781);

UPDATE cities SET population = CASE id WHEN 121361 THEN 66773 ELSE population END WHERE id IN (121361);

UPDATE cities SET population = CASE id WHEN 125627 THEN 65842 ELSE population END WHERE id IN (125627);

UPDATE cities SET population = CASE id WHEN 125612 THEN 65794 ELSE population END WHERE id IN (125612);

UPDATE cities SET population = CASE id WHEN 113926 THEN 65132 ELSE population END WHERE id IN (113926);

UPDATE cities SET population = CASE id WHEN 111277 THEN 65060 ELSE population END WHERE id IN (111277);

UPDATE cities SET population = CASE id WHEN 141850 THEN 64628 ELSE population END WHERE id IN (141850);

UPDATE cities SET population = CASE id WHEN 120691 THEN 64596 ELSE population END WHERE id IN (120691);

UPDATE cities SET population = CASE id WHEN 117688 THEN 64579 ELSE population END WHERE id IN (117688);

UPDATE cities SET population = CASE id WHEN 113631 THEN 64427 ELSE population END WHERE id IN (113631);

UPDATE cities SET population = CASE id WHEN 121145 THEN 64274 ELSE population END WHERE id IN (121145);

UPDATE cities SET population = CASE id WHEN 119131 THEN 64123 ELSE population END WHERE id IN (119131);

UPDATE cities SET population = CASE id WHEN 122114 THEN 63921 ELSE population END WHERE id IN (122114);

UPDATE cities SET population = CASE id WHEN 117160 THEN 63716 ELSE population END WHERE id IN (117160);

UPDATE cities SET population = CASE id WHEN 112628 THEN 63616 ELSE population END WHERE id IN (112628);

UPDATE cities SET population = CASE id WHEN 118150 THEN 62765 ELSE population END WHERE id IN (118150);

UPDATE cities SET population = CASE id WHEN 141377 THEN 62407 ELSE population END WHERE id IN (141377);

UPDATE cities SET population = CASE id WHEN 114600 THEN 62240 ELSE population END WHERE id IN (114600);

UPDATE cities SET population = CASE id WHEN 112403 THEN 62124 ELSE population END WHERE id IN (112403);

UPDATE cities SET population = CASE id WHEN 111623 THEN 62059 ELSE population END WHERE id IN (111623);

UPDATE cities SET population = CASE id WHEN 127447 THEN 61568 ELSE population END WHERE id IN (127447);

UPDATE cities SET population = CASE id WHEN 113091 THEN 61481 ELSE population END WHERE id IN (113091);

UPDATE cities SET population = CASE id WHEN 119009 THEN 61323 ELSE population END WHERE id IN (119009);

UPDATE cities SET population = CASE id WHEN 128067 THEN 61100 ELSE population END WHERE id IN (128067);

UPDATE cities SET population = CASE id WHEN 121060 THEN 61068 ELSE population END WHERE id IN (121060);

UPDATE cities SET population = CASE id WHEN 126907 THEN 60870 ELSE population END WHERE id IN (126907);

UPDATE cities SET population = CASE id WHEN 112731 THEN 60664 ELSE population END WHERE id IN (112731);

UPDATE cities SET population = CASE id WHEN 124979 THEN 60598 ELSE population END WHERE id IN (124979);

UPDATE cities SET population = CASE id WHEN 127466 THEN 60514 ELSE population END WHERE id IN (127466);

UPDATE cities SET population = CASE id WHEN 112809 THEN 60452 ELSE population END WHERE id IN (112809);

UPDATE cities SET population = CASE id WHEN 124474 THEN 59917 ELSE population END WHERE id IN (124474);

UPDATE cities SET population = CASE id WHEN 120052 THEN 59829 ELSE population END WHERE id IN (120052);

UPDATE cities SET population = CASE id WHEN 141731 THEN 59680 ELSE population END WHERE id IN (141731);

UPDATE cities SET population = CASE id WHEN 117573 THEN 59638 ELSE population END WHERE id IN (117573);

UPDATE cities SET population = CASE id WHEN 120087 THEN 59339 ELSE population END WHERE id IN (120087);

UPDATE cities SET population = CASE id WHEN 116312 THEN 59052 ELSE population END WHERE id IN (116312);

UPDATE cities SET population = CASE id WHEN 113478 THEN 58639 ELSE population END WHERE id IN (113478);

UPDATE cities SET population = CASE id WHEN 129155 THEN 58459 ELSE population END WHERE id IN (129155);

UPDATE cities SET population = CASE id WHEN 111425 THEN 58408 ELSE population END WHERE id IN (111425);

UPDATE cities SET population = CASE id WHEN 113672 THEN 58161 ELSE population END WHERE id IN (113672);

UPDATE cities SET population = CASE id WHEN 128685 THEN 57915 ELSE population END WHERE id IN (128685);

UPDATE cities SET population = CASE id WHEN 115496 THEN 57721 ELSE population END WHERE id IN (115496);

UPDATE cities SET population = CASE id WHEN 121592 THEN 57403 ELSE population END WHERE id IN (121592);

UPDATE cities SET population = CASE id WHEN 113641 THEN 57239 ELSE population END WHERE id IN (113641);

UPDATE cities SET population = CASE id WHEN 123041 THEN 56946 ELSE population END WHERE id IN (123041);

UPDATE cities SET population = CASE id WHEN 127977 THEN 56771 ELSE population END WHERE id IN (127977);

UPDATE cities SET population = CASE id WHEN 126535 THEN 56146 ELSE population END WHERE id IN (126535);

UPDATE cities SET population = CASE id WHEN 118286 THEN 56018 ELSE population END WHERE id IN (118286);

UPDATE cities SET population = CASE id WHEN 117702 THEN 55586 ELSE population END WHERE id IN (117702);

UPDATE cities SET population = CASE id WHEN 118270 THEN 55547 ELSE population END WHERE id IN (118270);

UPDATE cities SET population = CASE id WHEN 141425 THEN 55525 ELSE population END WHERE id IN (141425);

UPDATE cities SET population = CASE id WHEN 112113 THEN 55510 ELSE population END WHERE id IN (112113);

UPDATE cities SET population = CASE id WHEN 111313 THEN 55305 ELSE population END WHERE id IN (111313);

UPDATE cities SET population = CASE id WHEN 115853 THEN 54873 ELSE population END WHERE id IN (115853);

UPDATE cities SET population = CASE id WHEN 119066 THEN 54856 ELSE population END WHERE id IN (119066);

UPDATE cities SET population = CASE id WHEN 118398 THEN 54854 ELSE population END WHERE id IN (118398);

UPDATE cities SET population = CASE id WHEN 125072 THEN 54248 ELSE population END WHERE id IN (125072);

UPDATE cities SET population = CASE id WHEN 120048 THEN 53805 ELSE population END WHERE id IN (120048);

UPDATE cities SET population = CASE id WHEN 129113 THEN 53715 ELSE population END WHERE id IN (129113);

UPDATE cities SET population = CASE id WHEN 120408 THEN 52983 ELSE population END WHERE id IN (120408);

UPDATE cities SET population = CASE id WHEN 121847 THEN 52759 ELSE population END WHERE id IN (121847);

UPDATE cities SET population = CASE id WHEN 115199 THEN 52733 ELSE population END WHERE id IN (115199);

UPDATE cities SET population = CASE id WHEN 118070 THEN 52538 ELSE population END WHERE id IN (118070);

UPDATE cities SET population = CASE id WHEN 123954 THEN 52504 ELSE population END WHERE id IN (123954);

UPDATE cities SET population = CASE id WHEN 113068 THEN 52472 ELSE population END WHERE id IN (113068);

UPDATE cities SET population = CASE id WHEN 126673 THEN 52431 ELSE population END WHERE id IN (126673);

UPDATE cities SET population = CASE id WHEN 115998 THEN 52348 ELSE population END WHERE id IN (115998);

UPDATE cities SET population = CASE id WHEN 119744 THEN 52306 ELSE population END WHERE id IN (119744);

UPDATE cities SET population = CASE id WHEN 123255 THEN 52287 ELSE population END WHERE id IN (123255);

UPDATE cities SET population = CASE id WHEN 128363 THEN 52201 ELSE population END WHERE id IN (128363);

UPDATE cities SET population = CASE id WHEN 111111 THEN 52175 ELSE population END WHERE id IN (111111);

UPDATE cities SET population = CASE id WHEN 117291 THEN 52009 ELSE population END WHERE id IN (117291);

UPDATE cities SET population = CASE id WHEN 157017 THEN 52000 ELSE population END WHERE id IN (157017);

UPDATE cities SET population = CASE id WHEN 113182 THEN 51686 ELSE population END WHERE id IN (113182);

UPDATE cities SET population = CASE id WHEN 126729 THEN 51451 ELSE population END WHERE id IN (126729);

UPDATE cities SET population = CASE id WHEN 127124 THEN 51384 ELSE population END WHERE id IN (127124);

UPDATE cities SET population = CASE id WHEN 119501 THEN 51357 ELSE population END WHERE id IN (119501);

UPDATE cities SET population = CASE id WHEN 124321 THEN 51217 ELSE population END WHERE id IN (124321);

UPDATE cities SET population = CASE id WHEN 120326 THEN 51209 ELSE population END WHERE id IN (120326);

UPDATE cities SET population = CASE id WHEN 141438 THEN 50656 ELSE population END WHERE id IN (141438);

UPDATE cities SET population = CASE id WHEN 120695 THEN 50371 ELSE population END WHERE id IN (120695);

UPDATE cities SET population = CASE id WHEN 118050 THEN 50183 ELSE population END WHERE id IN (118050);

UPDATE cities SET population = CASE id WHEN 115867 THEN 50138 ELSE population END WHERE id IN (115867);

UPDATE cities SET population = CASE id WHEN 127851 THEN 49906 ELSE population END WHERE id IN (127851);

UPDATE cities SET population = CASE id WHEN 127258 THEN 49833 ELSE population END WHERE id IN (127258);

UPDATE cities SET population = CASE id WHEN 120509 THEN 49757 ELSE population END WHERE id IN (120509);

UPDATE cities SET population = CASE id WHEN 122058 THEN 49598 ELSE population END WHERE id IN (122058);

UPDATE cities SET population = CASE id WHEN 123863 THEN 49550 ELSE population END WHERE id IN (123863);

UPDATE cities SET population = CASE id WHEN 121966 THEN 49450 ELSE population END WHERE id IN (121966);

UPDATE cities SET population = CASE id WHEN 125588 THEN 49347 ELSE population END WHERE id IN (125588);

UPDATE cities SET population = CASE id WHEN 112021 THEN 49337 ELSE population END WHERE id IN (112021);

UPDATE cities SET population = CASE id WHEN 114954 THEN 49290 ELSE population END WHERE id IN (114954);

UPDATE cities SET population = CASE id WHEN 122492 THEN 49250 ELSE population END WHERE id IN (122492);

UPDATE cities SET population = CASE id WHEN 112437 THEN 49120 ELSE population END WHERE id IN (112437);

UPDATE cities SET population = CASE id WHEN 127210 THEN 48848 ELSE population END WHERE id IN (127210);

UPDATE cities SET population = CASE id WHEN 141518 THEN 48760 ELSE population END WHERE id IN (141518);

UPDATE cities SET population = CASE id WHEN 118800 THEN 48638 ELSE population END WHERE id IN (118800);

UPDATE cities SET population = CASE id WHEN 125463 THEN 48544 ELSE population END WHERE id IN (125463);

UPDATE cities SET population = CASE id WHEN 113614 THEN 48507 ELSE population END WHERE id IN (113614);

UPDATE cities SET population = CASE id WHEN 124544 THEN 48177 ELSE population END WHERE id IN (124544);

UPDATE cities SET population = CASE id WHEN 128946 THEN 48131 ELSE population END WHERE id IN (128946);

UPDATE cities SET population = CASE id WHEN 141577 THEN 47986 ELSE population END WHERE id IN (141577);

UPDATE cities SET population = CASE id WHEN 111150 THEN 47889 ELSE population END WHERE id IN (111150);

UPDATE cities SET population = CASE id WHEN 123752 THEN 47371 ELSE population END WHERE id IN (123752);

UPDATE cities SET population = CASE id WHEN 119208 THEN 46960 ELSE population END WHERE id IN (119208);

UPDATE cities SET population = CASE id WHEN 113766 THEN 46838 ELSE population END WHERE id IN (113766);

UPDATE cities SET population = CASE id WHEN 141484 THEN 46830 ELSE population END WHERE id IN (141484);

UPDATE cities SET population = CASE id WHEN 121788 THEN 46756 ELSE population END WHERE id IN (121788);

UPDATE cities SET population = CASE id WHEN 126536 THEN 46607 ELSE population END WHERE id IN (126536);

UPDATE cities SET population = CASE id WHEN 120636 THEN 46368 ELSE population END WHERE id IN (120636);

UPDATE cities SET population = CASE id WHEN 141136 THEN 46277 ELSE population END WHERE id IN (141136);

UPDATE cities SET population = CASE id WHEN 111248 THEN 45344 ELSE population END WHERE id IN (111248);

UPDATE cities SET population = CASE id WHEN 122805 THEN 45336 ELSE population END WHERE id IN (122805);

UPDATE cities SET population = CASE id WHEN 116125 THEN 45212 ELSE population END WHERE id IN (116125);

UPDATE cities SET population = CASE id WHEN 141282 THEN 45098 ELSE population END WHERE id IN (141282);

UPDATE cities SET population = CASE id WHEN 112777 THEN 44464 ELSE population END WHERE id IN (112777);

UPDATE cities SET population = CASE id WHEN 115038 THEN 44400 ELSE population END WHERE id IN (115038);

UPDATE cities SET population = CASE id WHEN 112390 THEN 44215 ELSE population END WHERE id IN (112390);

UPDATE cities SET population = CASE id WHEN 129692 THEN 43992 ELSE population END WHERE id IN (129692);

UPDATE cities SET population = CASE id WHEN 114541 THEN 43976 ELSE population END WHERE id IN (114541);

UPDATE cities SET population = CASE id WHEN 114244 THEN 43898 ELSE population END WHERE id IN (114244);

UPDATE cities SET population = CASE id WHEN 111990 THEN 43811 ELSE population END WHERE id IN (111990);

UPDATE cities SET population = CASE id WHEN 111514 THEN 43511 ELSE population END WHERE id IN (111514);

UPDATE cities SET population = CASE id WHEN 111646 THEN 43459 ELSE population END WHERE id IN (111646);

UPDATE cities SET population = CASE id WHEN 116914 THEN 43334 ELSE population END WHERE id IN (116914);

UPDATE cities SET population = CASE id WHEN 124298 THEN 43303 ELSE population END WHERE id IN (124298);

UPDATE cities SET population = CASE id WHEN 116421 THEN 42871 ELSE population END WHERE id IN (116421);

UPDATE cities SET population = CASE id WHEN 125735 THEN 42869 ELSE population END WHERE id IN (125735);

UPDATE cities SET population = CASE id WHEN 111465 THEN 42844 ELSE population END WHERE id IN (111465);

UPDATE cities SET population = CASE id WHEN 141305 THEN 42767 ELSE population END WHERE id IN (141305);

UPDATE cities SET population = CASE id WHEN 111515 THEN 42752 ELSE population END WHERE id IN (111515);

UPDATE cities SET population = CASE id WHEN 124320 THEN 42527 ELSE population END WHERE id IN (124320);

UPDATE cities SET population = CASE id WHEN 113072 THEN 42452 ELSE population END WHERE id IN (113072);

UPDATE cities SET population = CASE id WHEN 128062 THEN 42311 ELSE population END WHERE id IN (128062);

UPDATE cities SET population = CASE id WHEN 121798 THEN 42200 ELSE population END WHERE id IN (121798);

UPDATE cities SET population = CASE id WHEN 115039 THEN 42082 ELSE population END WHERE id IN (115039);

UPDATE cities SET population = CASE id WHEN 120564 THEN 42021 ELSE population END WHERE id IN (120564);

UPDATE cities SET population = CASE id WHEN 122212 THEN 42005 ELSE population END WHERE id IN (122212);

UPDATE cities SET population = CASE id WHEN 125215 THEN 41900 ELSE population END WHERE id IN (125215);

UPDATE cities SET population = CASE id WHEN 124643 THEN 41899 ELSE population END WHERE id IN (124643);

UPDATE cities SET population = CASE id WHEN 112729 THEN 41763 ELSE population END WHERE id IN (112729);

UPDATE cities SET population = CASE id WHEN 129028 THEN 41690 ELSE population END WHERE id IN (129028);

UPDATE cities SET population = CASE id WHEN 111863 THEN 41545 ELSE population END WHERE id IN (111863);

UPDATE cities SET population = CASE id WHEN 128897 THEN 41426 ELSE population END WHERE id IN (128897);

UPDATE cities SET population = CASE id WHEN 113807 THEN 41255 ELSE population END WHERE id IN (113807);

UPDATE cities SET population = CASE id WHEN 112300 THEN 41186 ELSE population END WHERE id IN (112300);

UPDATE cities SET population = CASE id WHEN 128025 THEN 41163 ELSE population END WHERE id IN (128025);

UPDATE cities SET population = CASE id WHEN 113298 THEN 41117 ELSE population END WHERE id IN (113298);

UPDATE cities SET population = CASE id WHEN 121130 THEN 41044 ELSE population END WHERE id IN (121130);

UPDATE cities SET population = CASE id WHEN 114736 THEN 40997 ELSE population END WHERE id IN (114736);

UPDATE cities SET population = CASE id WHEN 118818 THEN 40938 ELSE population END WHERE id IN (118818);

UPDATE cities SET population = CASE id WHEN 128172 THEN 40885 ELSE population END WHERE id IN (128172);

UPDATE cities SET population = CASE id WHEN 124796 THEN 40780 ELSE population END WHERE id IN (124796);

UPDATE cities SET population = CASE id WHEN 126330 THEN 40667 ELSE population END WHERE id IN (126330);

UPDATE cities SET population = CASE id WHEN 121178 THEN 40567 ELSE population END WHERE id IN (121178);

UPDATE cities SET population = CASE id WHEN 114880 THEN 40448 ELSE population END WHERE id IN (114880);

UPDATE cities SET population = CASE id WHEN 117838 THEN 40432 ELSE population END WHERE id IN (117838);

UPDATE cities SET population = CASE id WHEN 141790 THEN 40245 ELSE population END WHERE id IN (141790);

UPDATE cities SET population = CASE id WHEN 111282 THEN 39833 ELSE population END WHERE id IN (111282);

UPDATE cities SET population = CASE id WHEN 122664 THEN 39825 ELSE population END WHERE id IN (122664);

UPDATE cities SET population = CASE id WHEN 121280 THEN 39818 ELSE population END WHERE id IN (121280);

UPDATE cities SET population = CASE id WHEN 141439 THEN 39766 ELSE population END WHERE id IN (141439);

UPDATE cities SET population = CASE id WHEN 111700 THEN 39721 ELSE population END WHERE id IN (111700);

UPDATE cities SET population = CASE id WHEN 122106 THEN 39701 ELSE population END WHERE id IN (122106);

UPDATE cities SET population = CASE id WHEN 114316 THEN 39480 ELSE population END WHERE id IN (114316);

UPDATE cities SET population = CASE id WHEN 115445 THEN 39403 ELSE population END WHERE id IN (115445);

UPDATE cities SET population = CASE id WHEN 113831 THEN 39398 ELSE population END WHERE id IN (113831);

UPDATE cities SET population = CASE id WHEN 141374 THEN 39388 ELSE population END WHERE id IN (141374);

UPDATE cities SET population = CASE id WHEN 117173 THEN 39240 ELSE population END WHERE id IN (117173);

UPDATE cities SET population = CASE id WHEN 126969 THEN 38872 ELSE population END WHERE id IN (126969);

UPDATE cities SET population = CASE id WHEN 120082 THEN 38801 ELSE population END WHERE id IN (120082);

UPDATE cities SET population = CASE id WHEN 117015 THEN 38712 ELSE population END WHERE id IN (117015);

UPDATE cities SET population = CASE id WHEN 122107 THEN 38690 ELSE population END WHERE id IN (122107);

UPDATE cities SET population = CASE id WHEN 125283 THEN 38620 ELSE population END WHERE id IN (125283);

UPDATE cities SET population = CASE id WHEN 129209 THEN 38585 ELSE population END WHERE id IN (129209);

UPDATE cities SET population = CASE id WHEN 153288 THEN 38303 ELSE population END WHERE id IN (153288);

UPDATE cities SET population = CASE id WHEN 116580 THEN 38228 ELSE population END WHERE id IN (116580);

UPDATE cities SET population = CASE id WHEN 121345 THEN 38137 ELSE population END WHERE id IN (121345);

UPDATE cities SET population = CASE id WHEN 117967 THEN 38088 ELSE population END WHERE id IN (117967);

UPDATE cities SET population = CASE id WHEN 124367 THEN 38052 ELSE population END WHERE id IN (124367);

UPDATE cities SET population = CASE id WHEN 112855 THEN 38025 ELSE population END WHERE id IN (112855);

UPDATE cities SET population = CASE id WHEN 141452 THEN 37873 ELSE population END WHERE id IN (141452);

UPDATE cities SET population = CASE id WHEN 112791 THEN 37585 ELSE population END WHERE id IN (112791);

UPDATE cities SET population = CASE id WHEN 121920 THEN 37547 ELSE population END WHERE id IN (121920);

UPDATE cities SET population = CASE id WHEN 122088 THEN 37463 ELSE population END WHERE id IN (122088);

UPDATE cities SET population = CASE id WHEN 118552 THEN 37462 ELSE population END WHERE id IN (118552);

UPDATE cities SET population = CASE id WHEN 117653 THEN 37349 ELSE population END WHERE id IN (117653);

UPDATE cities SET population = CASE id WHEN 121240 THEN 37330 ELSE population END WHERE id IN (121240);

UPDATE cities SET population = CASE id WHEN 127545 THEN 37280 ELSE population END WHERE id IN (127545);

UPDATE cities SET population = CASE id WHEN 111035 THEN 37208 ELSE population END WHERE id IN (111035);

UPDATE cities SET population = CASE id WHEN 120541 THEN 37012 ELSE population END WHERE id IN (120541);

UPDATE cities SET population = CASE id WHEN 112146 THEN 36891 ELSE population END WHERE id IN (112146);

UPDATE cities SET population = CASE id WHEN 112106 THEN 36878 ELSE population END WHERE id IN (112106);

UPDATE cities SET population = CASE id WHEN 120758 THEN 36848 ELSE population END WHERE id IN (120758);

UPDATE cities SET population = CASE id WHEN 114472 THEN 36800 ELSE population END WHERE id IN (114472);

UPDATE cities SET population = CASE id WHEN 112790 THEN 36609 ELSE population END WHERE id IN (112790);

UPDATE cities SET population = CASE id WHEN 129522 THEN 36555 ELSE population END WHERE id IN (129522);

UPDATE cities SET population = CASE id WHEN 141489 THEN 36363 ELSE population END WHERE id IN (141489);

UPDATE cities SET population = CASE id WHEN 121583 THEN 36348 ELSE population END WHERE id IN (121583);

UPDATE cities SET population = CASE id WHEN 114106 THEN 36283 ELSE population END WHERE id IN (114106);

UPDATE cities SET population = CASE id WHEN 116841 THEN 36222 WHEN 128899 THEN 36222 ELSE population END WHERE id IN (116841,128899);

UPDATE cities SET population = CASE id WHEN 115195 THEN 36153 ELSE population END WHERE id IN (115195);

UPDATE cities SET population = CASE id WHEN 126862 THEN 36055 ELSE population END WHERE id IN (126862);

UPDATE cities SET population = CASE id WHEN 122210 THEN 36009 ELSE population END WHERE id IN (122210);

UPDATE cities SET population = CASE id WHEN 129315 THEN 35983 ELSE population END WHERE id IN (129315);

UPDATE cities SET population = CASE id WHEN 114272 THEN 35970 ELSE population END WHERE id IN (114272);

UPDATE cities SET population = CASE id WHEN 129237 THEN 35899 ELSE population END WHERE id IN (129237);

UPDATE cities SET population = CASE id WHEN 123872 THEN 35803 ELSE population END WHERE id IN (123872);

UPDATE cities SET population = CASE id WHEN 125440 THEN 35580 ELSE population END WHERE id IN (125440);

UPDATE cities SET population = CASE id WHEN 141157 THEN 35376 ELSE population END WHERE id IN (141157);

UPDATE cities SET population = CASE id WHEN 112306 THEN 34869 ELSE population END WHERE id IN (112306);

UPDATE cities SET population = CASE id WHEN 114909 THEN 34843 ELSE population END WHERE id IN (114909);

UPDATE cities SET population = CASE id WHEN 124372 THEN 34810 ELSE population END WHERE id IN (124372);

UPDATE cities SET population = CASE id WHEN 141735 THEN 34797 ELSE population END WHERE id IN (141735);

UPDATE cities SET population = CASE id WHEN 141179 THEN 34689 ELSE population END WHERE id IN (141179);

UPDATE cities SET population = CASE id WHEN 122059 THEN 34623 ELSE population END WHERE id IN (122059);

UPDATE cities SET population = CASE id WHEN 123509 THEN 34457 ELSE population END WHERE id IN (123509);

UPDATE cities SET population = CASE id WHEN 117283 THEN 34389 ELSE population END WHERE id IN (117283);

UPDATE cities SET population = CASE id WHEN 117033 THEN 34334 ELSE population END WHERE id IN (117033);

UPDATE cities SET population = CASE id WHEN 113123 THEN 34190 ELSE population END WHERE id IN (113123);

UPDATE cities SET population = CASE id WHEN 113884 THEN 34092 ELSE population END WHERE id IN (113884);

UPDATE cities SET population = CASE id WHEN 122403 THEN 34053 ELSE population END WHERE id IN (122403);

UPDATE cities SET population = CASE id WHEN 125756 THEN 34017 ELSE population END WHERE id IN (125756);

UPDATE cities SET population = CASE id WHEN 123622 THEN 33955 ELSE population END WHERE id IN (123622);

UPDATE cities SET population = CASE id WHEN 111922 THEN 33917 ELSE population END WHERE id IN (111922);

UPDATE cities SET population = CASE id WHEN 126385 THEN 33893 ELSE population END WHERE id IN (126385);

UPDATE cities SET population = CASE id WHEN 121541 THEN 33892 ELSE population END WHERE id IN (121541);

UPDATE cities SET population = CASE id WHEN 112761 THEN 33878 ELSE population END WHERE id IN (112761);

UPDATE cities SET population = CASE id WHEN 123456 THEN 33844 ELSE population END WHERE id IN (123456);

UPDATE cities SET population = CASE id WHEN 123246 THEN 33811 ELSE population END WHERE id IN (123246);

UPDATE cities SET population = CASE id WHEN 118539 THEN 33742 ELSE population END WHERE id IN (118539);

UPDATE cities SET population = CASE id WHEN 141394 THEN 33649 ELSE population END WHERE id IN (141394);

UPDATE cities SET population = CASE id WHEN 122695 THEN 33559 ELSE population END WHERE id IN (122695);

UPDATE cities SET population = CASE id WHEN 120737 THEN 33550 ELSE population END WHERE id IN (120737);

UPDATE cities SET population = CASE id WHEN 125085 THEN 33533 ELSE population END WHERE id IN (125085);

UPDATE cities SET population = CASE id WHEN 112733 THEN 33312 ELSE population END WHERE id IN (112733);

UPDATE cities SET population = CASE id WHEN 126558 THEN 33222 ELSE population END WHERE id IN (126558);

UPDATE cities SET population = CASE id WHEN 119071 THEN 33133 ELSE population END WHERE id IN (119071);

UPDATE cities SET population = CASE id WHEN 116133 THEN 33082 ELSE population END WHERE id IN (116133);

UPDATE cities SET population = CASE id WHEN 126099 THEN 33025 ELSE population END WHERE id IN (126099);

UPDATE cities SET population = CASE id WHEN 119408 THEN 33021 ELSE population END WHERE id IN (119408);

UPDATE cities SET population = CASE id WHEN 129270 THEN 33000 ELSE population END WHERE id IN (129270);

UPDATE cities SET population = CASE id WHEN 117408 THEN 32983 ELSE population END WHERE id IN (117408);

UPDATE cities SET population = CASE id WHEN 126431 THEN 32890 ELSE population END WHERE id IN (126431);

UPDATE cities SET population = CASE id WHEN 129387 THEN 32716 ELSE population END WHERE id IN (129387);

UPDATE cities SET population = CASE id WHEN 141493 THEN 32662 ELSE population END WHERE id IN (141493);

UPDATE cities SET population = CASE id WHEN 128121 THEN 32626 ELSE population END WHERE id IN (128121);

UPDATE cities SET population = CASE id WHEN 126877 THEN 32598 ELSE population END WHERE id IN (126877);

UPDATE cities SET population = CASE id WHEN 125378 THEN 32573 ELSE population END WHERE id IN (125378);

UPDATE cities SET population = CASE id WHEN 120428 THEN 32544 ELSE population END WHERE id IN (120428);

UPDATE cities SET population = CASE id WHEN 124105 THEN 32477 ELSE population END WHERE id IN (124105);

UPDATE cities SET population = CASE id WHEN 141816 THEN 32428 ELSE population END WHERE id IN (141816);

UPDATE cities SET population = CASE id WHEN 111792 THEN 32391 ELSE population END WHERE id IN (111792);

UPDATE cities SET population = CASE id WHEN 117157 THEN 32356 ELSE population END WHERE id IN (117157);

UPDATE cities SET population = CASE id WHEN 114414 THEN 32301 ELSE population END WHERE id IN (114414);

UPDATE cities SET population = CASE id WHEN 126918 THEN 32286 ELSE population END WHERE id IN (126918);

UPDATE cities SET population = CASE id WHEN 116578 THEN 32227 ELSE population END WHERE id IN (116578);

UPDATE cities SET population = CASE id WHEN 111324 THEN 32213 ELSE population END WHERE id IN (111324);

UPDATE cities SET population = CASE id WHEN 117686 THEN 32156 ELSE population END WHERE id IN (117686);

UPDATE cities SET population = CASE id WHEN 115035 THEN 32108 ELSE population END WHERE id IN (115035);

UPDATE cities SET population = CASE id WHEN 118251 THEN 32091 ELSE population END WHERE id IN (118251);

UPDATE cities SET population = CASE id WHEN 128621 THEN 31915 ELSE population END WHERE id IN (128621);

UPDATE cities SET population = CASE id WHEN 129051 THEN 31853 ELSE population END WHERE id IN (129051);

UPDATE cities SET population = CASE id WHEN 117081 THEN 31802 ELSE population END WHERE id IN (117081);

UPDATE cities SET population = CASE id WHEN 119338 THEN 31555 ELSE population END WHERE id IN (119338);

UPDATE cities SET population = CASE id WHEN 120448 THEN 31394 ELSE population END WHERE id IN (120448);

UPDATE cities SET population = CASE id WHEN 113797 THEN 31392 ELSE population END WHERE id IN (113797);

UPDATE cities SET population = CASE id WHEN 118562 THEN 31377 ELSE population END WHERE id IN (118562);

UPDATE cities SET population = CASE id WHEN 126250 THEN 31286 ELSE population END WHERE id IN (126250);

UPDATE cities SET population = CASE id WHEN 141161 THEN 31246 ELSE population END WHERE id IN (141161);

UPDATE cities SET population = CASE id WHEN 115272 THEN 31221 ELSE population END WHERE id IN (115272);

UPDATE cities SET population = CASE id WHEN 116583 THEN 31110 ELSE population END WHERE id IN (116583);

UPDATE cities SET population = CASE id WHEN 123868 THEN 30991 ELSE population END WHERE id IN (123868);

UPDATE cities SET population = CASE id WHEN 116286 THEN 30912 ELSE population END WHERE id IN (116286);

UPDATE cities SET population = CASE id WHEN 128687 THEN 30892 ELSE population END WHERE id IN (128687);

UPDATE cities SET population = CASE id WHEN 115450 THEN 30880 ELSE population END WHERE id IN (115450);

UPDATE cities SET population = CASE id WHEN 119044 THEN 30788 ELSE population END WHERE id IN (119044);

UPDATE cities SET population = CASE id WHEN 122253 THEN 30708 ELSE population END WHERE id IN (122253);

UPDATE cities SET population = CASE id WHEN 114217 THEN 30653 ELSE population END WHERE id IN (114217);

UPDATE cities SET population = CASE id WHEN 116834 THEN 30636 ELSE population END WHERE id IN (116834);

UPDATE cities SET population = CASE id WHEN 121094 THEN 30577 ELSE population END WHERE id IN (121094);

UPDATE cities SET population = CASE id WHEN 111167 THEN 30571 ELSE population END WHERE id IN (111167);

UPDATE cities SET population = CASE id WHEN 122831 THEN 30562 ELSE population END WHERE id IN (122831);

UPDATE cities SET population = CASE id WHEN 129029 THEN 30548 ELSE population END WHERE id IN (129029);

UPDATE cities SET population = CASE id WHEN 126896 THEN 30484 ELSE population END WHERE id IN (126896);

UPDATE cities SET population = CASE id WHEN 117488 THEN 30465 ELSE population END WHERE id IN (117488);

UPDATE cities SET population = CASE id WHEN 120461 THEN 30450 ELSE population END WHERE id IN (120461);

UPDATE cities SET population = CASE id WHEN 125972 THEN 30391 ELSE population END WHERE id IN (125972);

UPDATE cities SET population = CASE id WHEN 120287 THEN 30262 ELSE population END WHERE id IN (120287);

UPDATE cities SET population = CASE id WHEN 128414 THEN 30237 ELSE population END WHERE id IN (128414);

UPDATE cities SET population = CASE id WHEN 121021 THEN 30198 ELSE population END WHERE id IN (121021);

UPDATE cities SET population = CASE id WHEN 119124 THEN 30075 ELSE population END WHERE id IN (119124);

UPDATE cities SET population = CASE id WHEN 125265 THEN 30038 ELSE population END WHERE id IN (125265);

UPDATE cities SET population = CASE id WHEN 125798 THEN 29931 ELSE population END WHERE id IN (125798);

UPDATE cities SET population = CASE id WHEN 129561 THEN 29898 ELSE population END WHERE id IN (129561);

UPDATE cities SET population = CASE id WHEN 141422 THEN 29810 ELSE population END WHERE id IN (141422);

UPDATE cities SET population = CASE id WHEN 123256 THEN 29752 ELSE population END WHERE id IN (123256);

UPDATE cities SET population = CASE id WHEN 118411 THEN 29743 ELSE population END WHERE id IN (118411);

UPDATE cities SET population = CASE id WHEN 115978 THEN 29678 ELSE population END WHERE id IN (115978);

UPDATE cities SET population = CASE id WHEN 124689 THEN 29603 ELSE population END WHERE id IN (124689);

UPDATE cities SET population = CASE id WHEN 125736 THEN 29549 ELSE population END WHERE id IN (125736);

UPDATE cities SET population = CASE id WHEN 122281 THEN 29478 ELSE population END WHERE id IN (122281);

UPDATE cities SET population = CASE id WHEN 123262 THEN 29302 ELSE population END WHERE id IN (123262);

UPDATE cities SET population = CASE id WHEN 126775 THEN 29293 ELSE population END WHERE id IN (126775);

UPDATE cities SET population = CASE id WHEN 119279 THEN 29247 ELSE population END WHERE id IN (119279);

UPDATE cities SET population = CASE id WHEN 111613 THEN 29237 ELSE population END WHERE id IN (111613);

UPDATE cities SET population = CASE id WHEN 129281 THEN 29201 ELSE population END WHERE id IN (129281);

UPDATE cities SET population = CASE id WHEN 116696 THEN 29183 ELSE population END WHERE id IN (116696);

UPDATE cities SET population = CASE id WHEN 125543 THEN 29166 ELSE population END WHERE id IN (125543);

UPDATE cities SET population = CASE id WHEN 125887 THEN 29144 ELSE population END WHERE id IN (125887);

UPDATE cities SET population = CASE id WHEN 121243 THEN 29081 ELSE population END WHERE id IN (121243);

UPDATE cities SET population = CASE id WHEN 113409 THEN 28957 ELSE population END WHERE id IN (113409);

UPDATE cities SET population = CASE id WHEN 119595 THEN 28912 ELSE population END WHERE id IN (119595);

UPDATE cities SET population = CASE id WHEN 118274 THEN 28890 ELSE population END WHERE id IN (118274);

UPDATE cities SET population = CASE id WHEN 113097 THEN 28788 ELSE population END WHERE id IN (113097);

UPDATE cities SET population = CASE id WHEN 125118 THEN 28780 ELSE population END WHERE id IN (125118);

UPDATE cities SET population = CASE id WHEN 129382 THEN 28778 ELSE population END WHERE id IN (129382);

UPDATE cities SET population = CASE id WHEN 128718 THEN 28742 ELSE population END WHERE id IN (128718);

UPDATE cities SET population = CASE id WHEN 119100 THEN 28643 ELSE population END WHERE id IN (119100);

UPDATE cities SET population = CASE id WHEN 123199 THEN 28602 ELSE population END WHERE id IN (123199);

UPDATE cities SET population = CASE id WHEN 116132 THEN 28539 ELSE population END WHERE id IN (116132);

UPDATE cities SET population = CASE id WHEN 121364 THEN 28464 ELSE population END WHERE id IN (121364);

UPDATE cities SET population = CASE id WHEN 118497 THEN 28404 ELSE population END WHERE id IN (118497);

UPDATE cities SET population = CASE id WHEN 120126 THEN 28349 ELSE population END WHERE id IN (120126);

UPDATE cities SET population = CASE id WHEN 118059 THEN 28348 ELSE population END WHERE id IN (118059);

UPDATE cities SET population = CASE id WHEN 122120 THEN 28338 ELSE population END WHERE id IN (122120);

UPDATE cities SET population = CASE id WHEN 122817 THEN 28290 ELSE population END WHERE id IN (122817);

UPDATE cities SET population = CASE id WHEN 126880 THEN 28205 ELSE population END WHERE id IN (126880);

UPDATE cities SET population = CASE id WHEN 122086 THEN 28176 ELSE population END WHERE id IN (122086);

UPDATE cities SET population = CASE id WHEN 116891 THEN 28118 ELSE population END WHERE id IN (116891);

UPDATE cities SET population = CASE id WHEN 110977 THEN 28102 ELSE population END WHERE id IN (110977);

UPDATE cities SET population = CASE id WHEN 123271 THEN 28080 ELSE population END WHERE id IN (123271);

UPDATE cities SET population = CASE id WHEN 116535 THEN 27996 ELSE population END WHERE id IN (116535);

UPDATE cities SET population = CASE id WHEN 129361 THEN 27978 ELSE population END WHERE id IN (129361);

UPDATE cities SET population = CASE id WHEN 128030 THEN 27935 ELSE population END WHERE id IN (128030);

UPDATE cities SET population = CASE id WHEN 128985 THEN 27912 ELSE population END WHERE id IN (128985);

UPDATE cities SET population = CASE id WHEN 121459 THEN 27888 ELSE population END WHERE id IN (121459);

UPDATE cities SET population = CASE id WHEN 126361 THEN 27854 ELSE population END WHERE id IN (126361);

UPDATE cities SET population = CASE id WHEN 120651 THEN 27853 ELSE population END WHERE id IN (120651);

UPDATE cities SET population = CASE id WHEN 127027 THEN 27822 ELSE population END WHERE id IN (127027);

UPDATE cities SET population = CASE id WHEN 121791 THEN 27812 ELSE population END WHERE id IN (121791);

UPDATE cities SET population = CASE id WHEN 115177 THEN 27745 ELSE population END WHERE id IN (115177);

UPDATE cities SET population = CASE id WHEN 119836 THEN 27729 ELSE population END WHERE id IN (119836);

UPDATE cities SET population = CASE id WHEN 129121 THEN 27648 ELSE population END WHERE id IN (129121);

UPDATE cities SET population = CASE id WHEN 129386 THEN 27464 ELSE population END WHERE id IN (129386);

UPDATE cities SET population = CASE id WHEN 127367 THEN 27395 ELSE population END WHERE id IN (127367);

UPDATE cities SET population = CASE id WHEN 111311 THEN 27335 WHEN 111317 THEN 27335 ELSE population END WHERE id IN (111311,111317);

UPDATE cities SET population = CASE id WHEN 115607 THEN 27332 ELSE population END WHERE id IN (115607);

UPDATE cities SET population = CASE id WHEN 129356 THEN 27284 ELSE population END WHERE id IN (129356);

UPDATE cities SET population = CASE id WHEN 120568 THEN 27277 ELSE population END WHERE id IN (120568);

UPDATE cities SET population = CASE id WHEN 112142 THEN 27218 ELSE population END WHERE id IN (112142);

UPDATE cities SET population = CASE id WHEN 118518 THEN 27195 ELSE population END WHERE id IN (118518);

UPDATE cities SET population = CASE id WHEN 122741 THEN 27179 ELSE population END WHERE id IN (122741);

UPDATE cities SET population = CASE id WHEN 129424 THEN 27094 ELSE population END WHERE id IN (129424);

UPDATE cities SET population = CASE id WHEN 127589 THEN 27061 ELSE population END WHERE id IN (127589);

UPDATE cities SET population = CASE id WHEN 116235 THEN 27017 ELSE population END WHERE id IN (116235);

UPDATE cities SET population = CASE id WHEN 117059 THEN 27005 ELSE population END WHERE id IN (117059);

UPDATE cities SET population = CASE id WHEN 121915 THEN 27003 ELSE population END WHERE id IN (121915);

UPDATE cities SET population = CASE id WHEN 111628 THEN 26985 ELSE population END WHERE id IN (111628);

UPDATE cities SET population = CASE id WHEN 129299 THEN 26977 ELSE population END WHERE id IN (129299);

UPDATE cities SET population = CASE id WHEN 117057 THEN 26920 ELSE population END WHERE id IN (117057);

UPDATE cities SET population = CASE id WHEN 115789 THEN 26915 ELSE population END WHERE id IN (115789);

UPDATE cities SET population = CASE id WHEN 118890 THEN 26819 ELSE population END WHERE id IN (118890);

UPDATE cities SET population = CASE id WHEN 128623 THEN 26780 ELSE population END WHERE id IN (128623);

UPDATE cities SET population = CASE id WHEN 112803 THEN 26666 ELSE population END WHERE id IN (112803);

UPDATE cities SET population = CASE id WHEN 127279 THEN 26579 ELSE population END WHERE id IN (127279);

UPDATE cities SET population = CASE id WHEN 117689 THEN 26515 ELSE population END WHERE id IN (117689);

UPDATE cities SET population = CASE id WHEN 123818 THEN 26476 ELSE population END WHERE id IN (123818);

UPDATE cities SET population = CASE id WHEN 116923 THEN 26474 ELSE population END WHERE id IN (116923);

UPDATE cities SET population = CASE id WHEN 113388 THEN 26399 ELSE population END WHERE id IN (113388);

UPDATE cities SET population = CASE id WHEN 129072 THEN 26391 ELSE population END WHERE id IN (129072);

UPDATE cities SET population = CASE id WHEN 141505 THEN 26339 ELSE population END WHERE id IN (141505);

UPDATE cities SET population = CASE id WHEN 122939 THEN 26289 ELSE population END WHERE id IN (122939);

UPDATE cities SET population = CASE id WHEN 128528 THEN 26279 ELSE population END WHERE id IN (128528);

UPDATE cities SET population = CASE id WHEN 122382 THEN 26272 ELSE population END WHERE id IN (122382);

UPDATE cities SET population = CASE id WHEN 141130 THEN 26234 ELSE population END WHERE id IN (141130);

UPDATE cities SET population = CASE id WHEN 119636 THEN 26225 ELSE population END WHERE id IN (119636);

UPDATE cities SET population = CASE id WHEN 124330 THEN 26217 ELSE population END WHERE id IN (124330);

UPDATE cities SET population = CASE id WHEN 120189 THEN 26215 ELSE population END WHERE id IN (120189);

UPDATE cities SET population = CASE id WHEN 113464 THEN 26203 ELSE population END WHERE id IN (113464);

UPDATE cities SET population = CASE id WHEN 126706 THEN 26151 ELSE population END WHERE id IN (126706);

UPDATE cities SET population = CASE id WHEN 116131 THEN 26121 ELSE population END WHERE id IN (116131);

UPDATE cities SET population = CASE id WHEN 116791 THEN 26116 ELSE population END WHERE id IN (116791);

UPDATE cities SET population = CASE id WHEN 114278 THEN 26064 ELSE population END WHERE id IN (114278);

UPDATE cities SET population = CASE id WHEN 122379 THEN 26060 ELSE population END WHERE id IN (122379);

UPDATE cities SET population = CASE id WHEN 141363 THEN 25898 ELSE population END WHERE id IN (141363);

UPDATE cities SET population = CASE id WHEN 116657 THEN 25867 ELSE population END WHERE id IN (116657);

UPDATE cities SET population = CASE id WHEN 119835 THEN 25843 ELSE population END WHERE id IN (119835);

UPDATE cities SET population = CASE id WHEN 124841 THEN 25828 ELSE population END WHERE id IN (124841);

UPDATE cities SET population = CASE id WHEN 125418 THEN 25812 ELSE population END WHERE id IN (125418);

UPDATE cities SET population = CASE id WHEN 120989 THEN 25799 ELSE population END WHERE id IN (120989);

UPDATE cities SET population = CASE id WHEN 124871 THEN 25734 ELSE population END WHERE id IN (124871);

UPDATE cities SET population = CASE id WHEN 141760 THEN 25659 ELSE population END WHERE id IN (141760);

UPDATE cities SET population = CASE id WHEN 115859 THEN 25562 ELSE population END WHERE id IN (115859);

UPDATE cities SET population = CASE id WHEN 120293 THEN 25534 ELSE population END WHERE id IN (120293);

UPDATE cities SET population = CASE id WHEN 125734 THEN 25432 ELSE population END WHERE id IN (125734);

UPDATE cities SET population = CASE id WHEN 113069 THEN 25410 ELSE population END WHERE id IN (113069);

UPDATE cities SET population = CASE id WHEN 125945 THEN 25407 ELSE population END WHERE id IN (125945);

UPDATE cities SET population = CASE id WHEN 121632 THEN 25379 ELSE population END WHERE id IN (121632);

UPDATE cities SET population = CASE id WHEN 113555 THEN 25271 ELSE population END WHERE id IN (113555);

UPDATE cities SET population = CASE id WHEN 117479 THEN 25256 ELSE population END WHERE id IN (117479);

UPDATE cities SET population = CASE id WHEN 114274 THEN 25254 ELSE population END WHERE id IN (114274);

UPDATE cities SET population = CASE id WHEN 129667 THEN 25243 ELSE population END WHERE id IN (129667);

UPDATE cities SET population = CASE id WHEN 141691 THEN 25212 ELSE population END WHERE id IN (141691);

UPDATE cities SET population = CASE id WHEN 118112 THEN 25194 ELSE population END WHERE id IN (118112);

UPDATE cities SET population = CASE id WHEN 129563 THEN 25189 ELSE population END WHERE id IN (129563);

UPDATE cities SET population = CASE id WHEN 111442 THEN 25176 ELSE population END WHERE id IN (111442);

UPDATE cities SET population = CASE id WHEN 120680 THEN 25175 ELSE population END WHERE id IN (120680);

UPDATE cities SET population = CASE id WHEN 129504 THEN 25173 ELSE population END WHERE id IN (129504);

UPDATE cities SET population = CASE id WHEN 122300 THEN 25060 ELSE population END WHERE id IN (122300);

UPDATE cities SET population = CASE id WHEN 121850 THEN 25055 ELSE population END WHERE id IN (121850);

UPDATE cities SET population = CASE id WHEN 141119 THEN 25044 ELSE population END WHERE id IN (141119);

UPDATE cities SET population = CASE id WHEN 112770 THEN 25031 ELSE population END WHERE id IN (112770);

UPDATE cities SET population = CASE id WHEN 121179 THEN 25008 ELSE population END WHERE id IN (121179);

UPDATE cities SET population = CASE id WHEN 116415 THEN 25000 ELSE population END WHERE id IN (116415);

UPDATE cities SET population = CASE id WHEN 115894 THEN 24992 ELSE population END WHERE id IN (115894);

UPDATE cities SET population = CASE id WHEN 141671 THEN 24972 ELSE population END WHERE id IN (141671);

UPDATE cities SET population = CASE id WHEN 111577 THEN 24966 WHEN 129502 THEN 24966 ELSE population END WHERE id IN (111577,129502);

UPDATE cities SET population = CASE id WHEN 125892 THEN 24950 ELSE population END WHERE id IN (125892);

UPDATE cities SET population = CASE id WHEN 118133 THEN 24924 ELSE population END WHERE id IN (118133);

UPDATE cities SET population = CASE id WHEN 113588 THEN 24922 ELSE population END WHERE id IN (113588);

UPDATE cities SET population = CASE id WHEN 128273 THEN 24836 ELSE population END WHERE id IN (128273);

UPDATE cities SET population = CASE id WHEN 118465 THEN 24808 ELSE population END WHERE id IN (118465);

UPDATE cities SET population = CASE id WHEN 115612 THEN 24793 ELSE population END WHERE id IN (115612);

UPDATE cities SET population = CASE id WHEN 123834 THEN 24782 ELSE population END WHERE id IN (123834);

UPDATE cities SET population = CASE id WHEN 128033 THEN 24759 ELSE population END WHERE id IN (128033);

UPDATE cities SET population = CASE id WHEN 114434 THEN 24754 ELSE population END WHERE id IN (114434);

UPDATE cities SET population = CASE id WHEN 112138 THEN 24729 ELSE population END WHERE id IN (112138);

UPDATE cities SET population = CASE id WHEN 113192 THEN 24684 ELSE population END WHERE id IN (113192);

UPDATE cities SET population = CASE id WHEN 128384 THEN 24647 ELSE population END WHERE id IN (128384);

UPDATE cities SET population = CASE id WHEN 119334 THEN 24621 ELSE population END WHERE id IN (119334);

UPDATE cities SET population = CASE id WHEN 116833 THEN 24598 ELSE population END WHERE id IN (116833);

UPDATE cities SET population = CASE id WHEN 111669 THEN 24563 ELSE population END WHERE id IN (111669);

UPDATE cities SET population = CASE id WHEN 113070 THEN 24498 ELSE population END WHERE id IN (113070);

UPDATE cities SET population = CASE id WHEN 116912 THEN 24476 ELSE population END WHERE id IN (116912);

UPDATE cities SET population = CASE id WHEN 127001 THEN 24416 ELSE population END WHERE id IN (127001);

UPDATE cities SET population = CASE id WHEN 126141 THEN 24414 ELSE population END WHERE id IN (126141);

UPDATE cities SET population = CASE id WHEN 122943 THEN 24366 ELSE population END WHERE id IN (122943);

UPDATE cities SET population = CASE id WHEN 114890 THEN 24311 ELSE population END WHERE id IN (114890);

UPDATE cities SET population = CASE id WHEN 128551 THEN 24299 ELSE population END WHERE id IN (128551);

UPDATE cities SET population = CASE id WHEN 122849 THEN 24232 ELSE population END WHERE id IN (122849);

UPDATE cities SET population = CASE id WHEN 129536 THEN 24150 ELSE population END WHERE id IN (129536);

UPDATE cities SET population = CASE id WHEN 121594 THEN 24142 ELSE population END WHERE id IN (121594);

UPDATE cities SET population = CASE id WHEN 111756 THEN 24033 ELSE population END WHERE id IN (111756);

UPDATE cities SET population = CASE id WHEN 116303 THEN 24013 ELSE population END WHERE id IN (116303);

UPDATE cities SET population = CASE id WHEN 118575 THEN 23973 ELSE population END WHERE id IN (118575);

UPDATE cities SET population = CASE id WHEN 128669 THEN 23925 ELSE population END WHERE id IN (128669);

UPDATE cities SET population = CASE id WHEN 141205 THEN 23882 ELSE population END WHERE id IN (141205);

UPDATE cities SET population = CASE id WHEN 112453 THEN 23851 ELSE population END WHERE id IN (112453);

UPDATE cities SET population = CASE id WHEN 121305 THEN 23820 ELSE population END WHERE id IN (121305);

UPDATE cities SET population = CASE id WHEN 128624 THEN 23819 ELSE population END WHERE id IN (128624);

UPDATE cities SET population = CASE id WHEN 115326 THEN 23765 ELSE population END WHERE id IN (115326);

UPDATE cities SET population = CASE id WHEN 115598 THEN 23612 ELSE population END WHERE id IN (115598);

UPDATE cities SET population = CASE id WHEN 141353 THEN 23559 ELSE population END WHERE id IN (141353);

UPDATE cities SET population = CASE id WHEN 112689 THEN 23529 ELSE population END WHERE id IN (112689);

UPDATE cities SET population = CASE id WHEN 117436 THEN 23491 ELSE population END WHERE id IN (117436);

UPDATE cities SET population = CASE id WHEN 115787 THEN 23459 ELSE population END WHERE id IN (115787);

UPDATE cities SET population = CASE id WHEN 119627 THEN 23436 ELSE population END WHERE id IN (119627);

UPDATE cities SET population = CASE id WHEN 121146 THEN 23380 ELSE population END WHERE id IN (121146);

UPDATE cities SET population = CASE id WHEN 119852 THEN 23365 ELSE population END WHERE id IN (119852);

UPDATE cities SET population = CASE id WHEN 126894 THEN 23363 ELSE population END WHERE id IN (126894);

UPDATE cities SET population = CASE id WHEN 119421 THEN 23265 ELSE population END WHERE id IN (119421);

UPDATE cities SET population = CASE id WHEN 117706 THEN 23260 ELSE population END WHERE id IN (117706);

UPDATE cities SET population = CASE id WHEN 114494 THEN 23168 ELSE population END WHERE id IN (114494);

UPDATE cities SET population = CASE id WHEN 111485 THEN 23106 ELSE population END WHERE id IN (111485);

UPDATE cities SET population = CASE id WHEN 141717 THEN 23043 ELSE population END WHERE id IN (141717);

UPDATE cities SET population = CASE id WHEN 118396 THEN 22936 ELSE population END WHERE id IN (118396);

UPDATE cities SET population = CASE id WHEN 111627 THEN 22871 ELSE population END WHERE id IN (111627);

UPDATE cities SET population = CASE id WHEN 127795 THEN 22870 ELSE population END WHERE id IN (127795);

UPDATE cities SET population = CASE id WHEN 141492 THEN 22817 ELSE population END WHERE id IN (141492);

UPDATE cities SET population = CASE id WHEN 114496 THEN 22797 ELSE population END WHERE id IN (114496);

UPDATE cities SET population = CASE id WHEN 112812 THEN 22795 ELSE population END WHERE id IN (112812);

UPDATE cities SET population = CASE id WHEN 120371 THEN 22753 ELSE population END WHERE id IN (120371);

UPDATE cities SET population = CASE id WHEN 116419 THEN 22731 ELSE population END WHERE id IN (116419);

UPDATE cities SET population = CASE id WHEN 129341 THEN 22729 ELSE population END WHERE id IN (129341);

UPDATE cities SET population = CASE id WHEN 112445 THEN 22711 ELSE population END WHERE id IN (112445);

UPDATE cities SET population = CASE id WHEN 125431 THEN 22681 ELSE population END WHERE id IN (125431);

UPDATE cities SET population = CASE id WHEN 117058 THEN 22612 ELSE population END WHERE id IN (117058);

UPDATE cities SET population = CASE id WHEN 116422 THEN 22566 ELSE population END WHERE id IN (116422);

UPDATE cities SET population = CASE id WHEN 118132 THEN 22554 ELSE population END WHERE id IN (118132);

UPDATE cities SET population = CASE id WHEN 141124 THEN 22544 ELSE population END WHERE id IN (141124);

UPDATE cities SET population = CASE id WHEN 114633 THEN 22477 ELSE population END WHERE id IN (114633);

UPDATE cities SET population = CASE id WHEN 121630 THEN 22470 ELSE population END WHERE id IN (121630);

UPDATE cities SET population = CASE id WHEN 141407 THEN 22437 ELSE population END WHERE id IN (141407);

UPDATE cities SET population = CASE id WHEN 118649 THEN 22378 ELSE population END WHERE id IN (118649);

UPDATE cities SET population = CASE id WHEN 122688 THEN 22375 ELSE population END WHERE id IN (122688);

UPDATE cities SET population = CASE id WHEN 129324 THEN 22325 ELSE population END WHERE id IN (129324);

UPDATE cities SET population = CASE id WHEN 123678 THEN 22314 ELSE population END WHERE id IN (123678);

UPDATE cities SET population = CASE id WHEN 123274 THEN 22259 ELSE population END WHERE id IN (123274);

UPDATE cities SET population = CASE id WHEN 115047 THEN 22256 ELSE population END WHERE id IN (115047);

UPDATE cities SET population = CASE id WHEN 112447 THEN 22254 ELSE population END WHERE id IN (112447);

UPDATE cities SET population = CASE id WHEN 120870 THEN 22201 ELSE population END WHERE id IN (120870);

UPDATE cities SET population = CASE id WHEN 118464 THEN 22155 ELSE population END WHERE id IN (118464);

UPDATE cities SET population = CASE id WHEN 141619 THEN 22104 ELSE population END WHERE id IN (141619);

UPDATE cities SET population = CASE id WHEN 126583 THEN 22083 ELSE population END WHERE id IN (126583);

UPDATE cities SET population = CASE id WHEN 127213 THEN 22074 ELSE population END WHERE id IN (127213);

UPDATE cities SET population = CASE id WHEN 128625 THEN 22073 ELSE population END WHERE id IN (128625);

UPDATE cities SET population = CASE id WHEN 141100 THEN 22055 ELSE population END WHERE id IN (141100);

UPDATE cities SET population = CASE id WHEN 119463 THEN 22030 ELSE population END WHERE id IN (119463);

UPDATE cities SET population = CASE id WHEN 120324 THEN 21993 ELSE population END WHERE id IN (120324);

UPDATE cities SET population = CASE id WHEN 115152 THEN 21957 ELSE population END WHERE id IN (115152);

UPDATE cities SET population = CASE id WHEN 111538 THEN 21925 ELSE population END WHERE id IN (111538);

UPDATE cities SET population = CASE id WHEN 119777 THEN 21916 ELSE population END WHERE id IN (119777);

UPDATE cities SET population = CASE id WHEN 126520 THEN 21872 ELSE population END WHERE id IN (126520);

UPDATE cities SET population = CASE id WHEN 114153 THEN 21866 ELSE population END WHERE id IN (114153);

UPDATE cities SET population = CASE id WHEN 141785 THEN 21860 ELSE population END WHERE id IN (141785);

UPDATE cities SET population = CASE id WHEN 117142 THEN 21806 ELSE population END WHERE id IN (117142);

UPDATE cities SET population = CASE id WHEN 112726 THEN 21804 ELSE population END WHERE id IN (112726);

UPDATE cities SET population = CASE id WHEN 141214 THEN 21727 ELSE population END WHERE id IN (141214);

UPDATE cities SET population = CASE id WHEN 113344 THEN 21679 ELSE population END WHERE id IN (113344);

UPDATE cities SET population = CASE id WHEN 120513 THEN 21670 WHEN 125427 THEN 21670 ELSE population END WHERE id IN (120513,125427);

UPDATE cities SET population = CASE id WHEN 120880 THEN 21667 ELSE population END WHERE id IN (120880);

UPDATE cities SET population = CASE id WHEN 124570 THEN 21530 ELSE population END WHERE id IN (124570);

UPDATE cities SET population = CASE id WHEN 123916 THEN 21498 ELSE population END WHERE id IN (123916);

UPDATE cities SET population = CASE id WHEN 117646 THEN 21497 ELSE population END WHERE id IN (117646);

UPDATE cities SET population = CASE id WHEN 128709 THEN 21491 ELSE population END WHERE id IN (128709);

UPDATE cities SET population = CASE id WHEN 116167 THEN 21420 ELSE population END WHERE id IN (116167);

UPDATE cities SET population = CASE id WHEN 114288 THEN 21399 ELSE population END WHERE id IN (114288);

UPDATE cities SET population = CASE id WHEN 117610 THEN 21391 ELSE population END WHERE id IN (117610);

UPDATE cities SET population = CASE id WHEN 116246 THEN 21383 ELSE population END WHERE id IN (116246);

UPDATE cities SET population = CASE id WHEN 129358 THEN 21374 ELSE population END WHERE id IN (129358);

UPDATE cities SET population = CASE id WHEN 126284 THEN 21317 ELSE population END WHERE id IN (126284);

UPDATE cities SET population = CASE id WHEN 113762 THEN 21196 ELSE population END WHERE id IN (113762);

UPDATE cities SET population = CASE id WHEN 112024 THEN 21188 ELSE population END WHERE id IN (112024);

UPDATE cities SET population = CASE id WHEN 114583 THEN 21053 ELSE population END WHERE id IN (114583);

UPDATE cities SET population = CASE id WHEN 122726 THEN 21032 ELSE population END WHERE id IN (122726);

UPDATE cities SET population = CASE id WHEN 114644 THEN 20998 ELSE population END WHERE id IN (114644);

UPDATE cities SET population = CASE id WHEN 113886 THEN 20987 ELSE population END WHERE id IN (113886);

UPDATE cities SET population = CASE id WHEN 124331 THEN 20919 ELSE population END WHERE id IN (124331);

UPDATE cities SET population = CASE id WHEN 125888 THEN 20893 ELSE population END WHERE id IN (125888);

UPDATE cities SET population = CASE id WHEN 119278 THEN 20871 ELSE population END WHERE id IN (119278);

UPDATE cities SET population = CASE id WHEN 120170 THEN 20866 ELSE population END WHERE id IN (120170);

UPDATE cities SET population = CASE id WHEN 111540 THEN 20861 ELSE population END WHERE id IN (111540);

UPDATE cities SET population = CASE id WHEN 141711 THEN 20858 ELSE population END WHERE id IN (141711);

UPDATE cities SET population = CASE id WHEN 112359 THEN 20857 ELSE population END WHERE id IN (112359);

UPDATE cities SET population = CASE id WHEN 117462 THEN 20813 ELSE population END WHERE id IN (117462);

UPDATE cities SET population = CASE id WHEN 129535 THEN 20804 ELSE population END WHERE id IN (129535);

UPDATE cities SET population = CASE id WHEN 126452 THEN 20736 ELSE population END WHERE id IN (126452);

UPDATE cities SET population = CASE id WHEN 115046 THEN 20732 ELSE population END WHERE id IN (115046);

UPDATE cities SET population = CASE id WHEN 111046 THEN 20691 ELSE population END WHERE id IN (111046);

UPDATE cities SET population = CASE id WHEN 120032 THEN 20648 ELSE population END WHERE id IN (120032);

UPDATE cities SET population = CASE id WHEN 112276 THEN 20646 ELSE population END WHERE id IN (112276);

UPDATE cities SET population = CASE id WHEN 120681 THEN 20624 ELSE population END WHERE id IN (120681);

UPDATE cities SET population = CASE id WHEN 141443 THEN 20623 ELSE population END WHERE id IN (141443);

UPDATE cities SET population = CASE id WHEN 122486 THEN 20610 ELSE population END WHERE id IN (122486);

UPDATE cities SET population = CASE id WHEN 112149 THEN 20547 ELSE population END WHERE id IN (112149);

UPDATE cities SET population = CASE id WHEN 141653 THEN 20409 ELSE population END WHERE id IN (141653);

UPDATE cities SET population = CASE id WHEN 120817 THEN 20396 ELSE population END WHERE id IN (120817);

UPDATE cities SET population = CASE id WHEN 123152 THEN 20380 ELSE population END WHERE id IN (123152);

UPDATE cities SET population = CASE id WHEN 117075 THEN 20333 ELSE population END WHERE id IN (117075);

UPDATE cities SET population = CASE id WHEN 115420 THEN 20323 ELSE population END WHERE id IN (115420);

UPDATE cities SET population = CASE id WHEN 141113 THEN 20317 ELSE population END WHERE id IN (141113);

UPDATE cities SET population = CASE id WHEN 116063 THEN 20279 ELSE population END WHERE id IN (116063);

UPDATE cities SET population = CASE id WHEN 118549 THEN 20269 ELSE population END WHERE id IN (118549);

UPDATE cities SET population = CASE id WHEN 125405 THEN 20226 ELSE population END WHERE id IN (125405);

UPDATE cities SET population = CASE id WHEN 126268 THEN 20189 ELSE population END WHERE id IN (126268);

UPDATE cities SET population = CASE id WHEN 116487 THEN 20177 ELSE population END WHERE id IN (116487);

UPDATE cities SET population = CASE id WHEN 120443 THEN 20138 WHEN 120453 THEN 20138 ELSE population END WHERE id IN (120443,120453);

UPDATE cities SET population = CASE id WHEN 114907 THEN 20130 ELSE population END WHERE id IN (114907);

UPDATE cities SET population = CASE id WHEN 141613 THEN 20102 ELSE population END WHERE id IN (141613);

UPDATE cities SET population = CASE id WHEN 122061 THEN 20092 ELSE population END WHERE id IN (122061);

UPDATE cities SET population = CASE id WHEN 120921 THEN 19996 ELSE population END WHERE id IN (120921);

UPDATE cities SET population = CASE id WHEN 117174 THEN 19993 ELSE population END WHERE id IN (117174);

UPDATE cities SET population = CASE id WHEN 119285 THEN 19966 ELSE population END WHERE id IN (119285);

UPDATE cities SET population = CASE id WHEN 118183 THEN 19936 ELSE population END WHERE id IN (118183);

UPDATE cities SET population = CASE id WHEN 128502 THEN 19927 ELSE population END WHERE id IN (128502);

UPDATE cities SET population = CASE id WHEN 141604 THEN 19915 ELSE population END WHERE id IN (141604);

UPDATE cities SET population = CASE id WHEN 114261 THEN 19889 ELSE population END WHERE id IN (114261);

UPDATE cities SET population = CASE id WHEN 111757 THEN 19819 ELSE population END WHERE id IN (111757);

UPDATE cities SET population = CASE id WHEN 123184 THEN 19808 ELSE population END WHERE id IN (123184);

UPDATE cities SET population = CASE id WHEN 117650 THEN 19753 ELSE population END WHERE id IN (117650);

UPDATE cities SET population = CASE id WHEN 111110 THEN 19735 ELSE population END WHERE id IN (111110);

UPDATE cities SET population = CASE id WHEN 126812 THEN 19722 ELSE population END WHERE id IN (126812);

UPDATE cities SET population = CASE id WHEN 116661 THEN 19618 ELSE population END WHERE id IN (116661);

UPDATE cities SET population = CASE id WHEN 112273 THEN 19589 ELSE population END WHERE id IN (112273);

UPDATE cities SET population = CASE id WHEN 127233 THEN 19579 ELSE population END WHERE id IN (127233);

UPDATE cities SET population = CASE id WHEN 123950 THEN 19548 ELSE population END WHERE id IN (123950);

UPDATE cities SET population = CASE id WHEN 122133 THEN 19489 ELSE population END WHERE id IN (122133);

UPDATE cities SET population = CASE id WHEN 119910 THEN 19408 ELSE population END WHERE id IN (119910);

UPDATE cities SET population = CASE id WHEN 111907 THEN 19407 ELSE population END WHERE id IN (111907);

UPDATE cities SET population = CASE id WHEN 115367 THEN 19390 ELSE population END WHERE id IN (115367);

UPDATE cities SET population = CASE id WHEN 118608 THEN 19373 ELSE population END WHERE id IN (118608);

UPDATE cities SET population = CASE id WHEN 120442 THEN 19326 ELSE population END WHERE id IN (120442);

UPDATE cities SET population = CASE id WHEN 112131 THEN 19308 ELSE population END WHERE id IN (112131);

UPDATE cities SET population = CASE id WHEN 114200 THEN 19304 ELSE population END WHERE id IN (114200);

UPDATE cities SET population = CASE id WHEN 127242 THEN 19299 ELSE population END WHERE id IN (127242);

UPDATE cities SET population = CASE id WHEN 126342 THEN 19283 ELSE population END WHERE id IN (126342);

UPDATE cities SET population = CASE id WHEN 128610 THEN 19281 ELSE population END WHERE id IN (128610);

UPDATE cities SET population = CASE id WHEN 129501 THEN 19265 ELSE population END WHERE id IN (129501);

UPDATE cities SET population = CASE id WHEN 111236 THEN 19257 ELSE population END WHERE id IN (111236);

UPDATE cities SET population = CASE id WHEN 118708 THEN 19250 ELSE population END WHERE id IN (118708);

UPDATE cities SET population = CASE id WHEN 111092 THEN 19246 ELSE population END WHERE id IN (111092);

UPDATE cities SET population = CASE id WHEN 122858 THEN 19216 ELSE population END WHERE id IN (122858);

UPDATE cities SET population = CASE id WHEN 114741 THEN 19197 ELSE population END WHERE id IN (114741);

UPDATE cities SET population = CASE id WHEN 141820 THEN 19167 ELSE population END WHERE id IN (141820);

UPDATE cities SET population = CASE id WHEN 113405 THEN 19143 ELSE population END WHERE id IN (113405);

UPDATE cities SET population = CASE id WHEN 121932 THEN 19139 ELSE population END WHERE id IN (121932);

UPDATE cities SET population = CASE id WHEN 123698 THEN 19120 ELSE population END WHERE id IN (123698);

UPDATE cities SET population = CASE id WHEN 119102 THEN 19103 ELSE population END WHERE id IN (119102);

UPDATE cities SET population = CASE id WHEN 120992 THEN 19100 ELSE population END WHERE id IN (120992);

UPDATE cities SET population = CASE id WHEN 118173 THEN 19074 ELSE population END WHERE id IN (118173);

UPDATE cities SET population = CASE id WHEN 122184 THEN 19062 ELSE population END WHERE id IN (122184);

UPDATE cities SET population = CASE id WHEN 121635 THEN 18985 ELSE population END WHERE id IN (121635);

UPDATE cities SET population = CASE id WHEN 121783 THEN 18979 ELSE population END WHERE id IN (121783);

UPDATE cities SET population = CASE id WHEN 141747 THEN 18965 ELSE population END WHERE id IN (141747);

UPDATE cities SET population = CASE id WHEN 111470 THEN 18949 ELSE population END WHERE id IN (111470);

UPDATE cities SET population = CASE id WHEN 112854 THEN 18944 ELSE population END WHERE id IN (112854);

UPDATE cities SET population = CASE id WHEN 127061 THEN 18924 ELSE population END WHERE id IN (127061);

UPDATE cities SET population = CASE id WHEN 114676 THEN 18907 ELSE population END WHERE id IN (114676);

UPDATE cities SET population = CASE id WHEN 111649 THEN 18899 ELSE population END WHERE id IN (111649);

UPDATE cities SET population = CASE id WHEN 141148 THEN 18874 ELSE population END WHERE id IN (141148);

UPDATE cities SET population = CASE id WHEN 120190 THEN 18837 ELSE population END WHERE id IN (120190);

UPDATE cities SET population = CASE id WHEN 125461 THEN 18792 ELSE population END WHERE id IN (125461);

UPDATE cities SET population = CASE id WHEN 127588 THEN 18742 ELSE population END WHERE id IN (127588);

UPDATE cities SET population = CASE id WHEN 116335 THEN 18733 ELSE population END WHERE id IN (116335);

UPDATE cities SET population = CASE id WHEN 141821 THEN 18694 ELSE population END WHERE id IN (141821);

UPDATE cities SET population = CASE id WHEN 125549 THEN 18690 ELSE population END WHERE id IN (125549);

UPDATE cities SET population = CASE id WHEN 141318 THEN 18676 ELSE population END WHERE id IN (141318);

UPDATE cities SET population = CASE id WHEN 116819 THEN 18653 ELSE population END WHERE id IN (116819);

UPDATE cities SET population = CASE id WHEN 141583 THEN 18651 ELSE population END WHERE id IN (141583);

UPDATE cities SET population = CASE id WHEN 121327 THEN 18620 ELSE population END WHERE id IN (121327);

UPDATE cities SET population = CASE id WHEN 122282 THEN 18594 ELSE population END WHERE id IN (122282);

UPDATE cities SET population = CASE id WHEN 124431 THEN 18523 ELSE population END WHERE id IN (124431);

UPDATE cities SET population = CASE id WHEN 112075 THEN 18518 ELSE population END WHERE id IN (112075);

UPDATE cities SET population = CASE id WHEN 123468 THEN 18468 ELSE population END WHERE id IN (123468);

UPDATE cities SET population = CASE id WHEN 129353 THEN 18446 ELSE population END WHERE id IN (129353);

UPDATE cities SET population = CASE id WHEN 127806 THEN 18380 ELSE population END WHERE id IN (127806);

UPDATE cities SET population = CASE id WHEN 115449 THEN 18346 ELSE population END WHERE id IN (115449);

UPDATE cities SET population = CASE id WHEN 123637 THEN 18342 ELSE population END WHERE id IN (123637);

UPDATE cities SET population = CASE id WHEN 121566 THEN 18312 ELSE population END WHERE id IN (121566);

UPDATE cities SET population = CASE id WHEN 123737 THEN 18288 ELSE population END WHERE id IN (123737);

UPDATE cities SET population = CASE id WHEN 123759 THEN 18261 ELSE population END WHERE id IN (123759);

UPDATE cities SET population = CASE id WHEN 121092 THEN 18229 ELSE population END WHERE id IN (121092);

UPDATE cities SET population = CASE id WHEN 113281 THEN 18228 ELSE population END WHERE id IN (113281);

UPDATE cities SET population = CASE id WHEN 116413 THEN 18181 ELSE population END WHERE id IN (116413);

UPDATE cities SET population = CASE id WHEN 126582 THEN 18165 ELSE population END WHERE id IN (126582);

UPDATE cities SET population = CASE id WHEN 122065 THEN 18090 ELSE population END WHERE id IN (122065);

UPDATE cities SET population = CASE id WHEN 120491 THEN 18074 ELSE population END WHERE id IN (120491);

UPDATE cities SET population = CASE id WHEN 118802 THEN 18046 ELSE population END WHERE id IN (118802);

UPDATE cities SET population = CASE id WHEN 118400 THEN 17989 ELSE population END WHERE id IN (118400);

UPDATE cities SET population = CASE id WHEN 125309 THEN 17982 ELSE population END WHERE id IN (125309);

UPDATE cities SET population = CASE id WHEN 113506 THEN 17965 ELSE population END WHERE id IN (113506);

UPDATE cities SET population = CASE id WHEN 120350 THEN 17924 ELSE population END WHERE id IN (120350);

UPDATE cities SET population = CASE id WHEN 117725 THEN 17880 ELSE population END WHERE id IN (117725);

UPDATE cities SET population = CASE id WHEN 126323 THEN 17873 ELSE population END WHERE id IN (126323);

UPDATE cities SET population = CASE id WHEN 114449 THEN 17820 ELSE population END WHERE id IN (114449);

UPDATE cities SET population = CASE id WHEN 121233 THEN 17803 ELSE population END WHERE id IN (121233);

UPDATE cities SET population = CASE id WHEN 120707 THEN 17793 ELSE population END WHERE id IN (120707);

UPDATE cities SET population = CASE id WHEN 123623 THEN 17787 ELSE population END WHERE id IN (123623);

UPDATE cities SET population = CASE id WHEN 124571 THEN 17756 ELSE population END WHERE id IN (124571);

UPDATE cities SET population = CASE id WHEN 141753 THEN 17687 ELSE population END WHERE id IN (141753);

UPDATE cities SET population = CASE id WHEN 118485 THEN 17628 ELSE population END WHERE id IN (118485);

UPDATE cities SET population = CASE id WHEN 122684 THEN 17621 ELSE population END WHERE id IN (122684);

UPDATE cities SET population = CASE id WHEN 129450 THEN 17618 ELSE population END WHERE id IN (129450);

UPDATE cities SET population = CASE id WHEN 119504 THEN 17601 ELSE population END WHERE id IN (119504);

UPDATE cities SET population = CASE id WHEN 118652 THEN 17591 ELSE population END WHERE id IN (118652);

UPDATE cities SET population = CASE id WHEN 111194 THEN 17579 ELSE population END WHERE id IN (111194);

UPDATE cities SET population = CASE id WHEN 121727 THEN 17496 ELSE population END WHERE id IN (121727);

UPDATE cities SET population = CASE id WHEN 141573 THEN 17484 ELSE population END WHERE id IN (141573);

UPDATE cities SET population = CASE id WHEN 141285 THEN 17344 ELSE population END WHERE id IN (141285);

UPDATE cities SET population = CASE id WHEN 124334 THEN 17328 ELSE population END WHERE id IN (124334);

UPDATE cities SET population = CASE id WHEN 121793 THEN 17303 ELSE population END WHERE id IN (121793);

UPDATE cities SET population = CASE id WHEN 115567 THEN 17286 ELSE population END WHERE id IN (115567);

UPDATE cities SET population = CASE id WHEN 119605 THEN 17282 ELSE population END WHERE id IN (119605);

UPDATE cities SET population = CASE id WHEN 113322 THEN 17271 ELSE population END WHERE id IN (113322);

UPDATE cities SET population = CASE id WHEN 117654 THEN 17184 ELSE population END WHERE id IN (117654);

UPDATE cities SET population = CASE id WHEN 112804 THEN 17141 ELSE population END WHERE id IN (112804);

UPDATE cities SET population = CASE id WHEN 111957 THEN 17132 ELSE population END WHERE id IN (111957);

UPDATE cities SET population = CASE id WHEN 129541 THEN 17121 ELSE population END WHERE id IN (129541);

UPDATE cities SET population = CASE id WHEN 118801 THEN 17095 WHEN 118883 THEN 17095 ELSE population END WHERE id IN (118801,118883);

UPDATE cities SET population = CASE id WHEN 128683 THEN 17081 ELSE population END WHERE id IN (128683);

UPDATE cities SET population = CASE id WHEN 118523 THEN 17016 ELSE population END WHERE id IN (118523);

UPDATE cities SET population = CASE id WHEN 116455 THEN 16990 ELSE population END WHERE id IN (116455);

UPDATE cities SET population = CASE id WHEN 114384 THEN 16986 ELSE population END WHERE id IN (114384);

UPDATE cities SET population = CASE id WHEN 117970 THEN 16906 ELSE population END WHERE id IN (117970);

UPDATE cities SET population = CASE id WHEN 124018 THEN 16881 ELSE population END WHERE id IN (124018);

UPDATE cities SET population = CASE id WHEN 113662 THEN 16877 ELSE population END WHERE id IN (113662);

UPDATE cities SET population = CASE id WHEN 141603 THEN 16827 ELSE population END WHERE id IN (141603);

UPDATE cities SET population = CASE id WHEN 114538 THEN 16810 ELSE population END WHERE id IN (114538);

UPDATE cities SET population = CASE id WHEN 126895 THEN 16808 ELSE population END WHERE id IN (126895);

UPDATE cities SET population = CASE id WHEN 122755 THEN 16801 ELSE population END WHERE id IN (122755);

UPDATE cities SET population = CASE id WHEN 114718 THEN 16795 ELSE population END WHERE id IN (114718);

UPDATE cities SET population = CASE id WHEN 113687 THEN 16753 ELSE population END WHERE id IN (113687);

UPDATE cities SET population = CASE id WHEN 141551 THEN 16742 ELSE population END WHERE id IN (141551);

UPDATE cities SET population = CASE id WHEN 129019 THEN 16729 ELSE population END WHERE id IN (129019);

UPDATE cities SET population = CASE id WHEN 111624 THEN 16724 ELSE population END WHERE id IN (111624);

UPDATE cities SET population = CASE id WHEN 120191 THEN 16713 ELSE population END WHERE id IN (120191);

UPDATE cities SET population = CASE id WHEN 127446 THEN 16702 ELSE population END WHERE id IN (127446);

UPDATE cities SET population = CASE id WHEN 115033 THEN 16690 ELSE population END WHERE id IN (115033);

UPDATE cities SET population = CASE id WHEN 111848 THEN 16669 ELSE population END WHERE id IN (111848);

UPDATE cities SET population = CASE id WHEN 128546 THEN 16664 ELSE population END WHERE id IN (128546);

UPDATE cities SET population = CASE id WHEN 123240 THEN 16629 ELSE population END WHERE id IN (123240);

UPDATE cities SET population = CASE id WHEN 115423 THEN 16592 ELSE population END WHERE id IN (115423);

UPDATE cities SET population = CASE id WHEN 117429 THEN 16583 ELSE population END WHERE id IN (117429);

UPDATE cities SET population = CASE id WHEN 112001 THEN 16564 ELSE population END WHERE id IN (112001);

UPDATE cities SET population = CASE id WHEN 126196 THEN 16562 ELSE population END WHERE id IN (126196);

UPDATE cities SET population = CASE id WHEN 127326 THEN 16525 ELSE population END WHERE id IN (127326);

UPDATE cities SET population = CASE id WHEN 128234 THEN 16522 ELSE population END WHERE id IN (128234);

UPDATE cities SET population = CASE id WHEN 114535 THEN 16421 ELSE population END WHERE id IN (114535);

UPDATE cities SET population = CASE id WHEN 141310 THEN 16407 ELSE population END WHERE id IN (141310);

UPDATE cities SET population = CASE id WHEN 127260 THEN 16325 ELSE population END WHERE id IN (127260);

UPDATE cities SET population = CASE id WHEN 120294 THEN 16324 ELSE population END WHERE id IN (120294);

UPDATE cities SET population = CASE id WHEN 122293 THEN 16306 ELSE population END WHERE id IN (122293);

UPDATE cities SET population = CASE id WHEN 141331 THEN 16297 ELSE population END WHERE id IN (141331);

UPDATE cities SET population = CASE id WHEN 117017 THEN 16292 ELSE population END WHERE id IN (117017);

UPDATE cities SET population = CASE id WHEN 110979 THEN 16276 ELSE population END WHERE id IN (110979);

UPDATE cities SET population = CASE id WHEN 114144 THEN 16152 ELSE population END WHERE id IN (114144);

UPDATE cities SET population = CASE id WHEN 120998 THEN 16126 ELSE population END WHERE id IN (120998);

UPDATE cities SET population = CASE id WHEN 121820 THEN 16115 ELSE population END WHERE id IN (121820);

UPDATE cities SET population = CASE id WHEN 127197 THEN 16098 ELSE population END WHERE id IN (127197);

UPDATE cities SET population = CASE id WHEN 116820 THEN 16060 ELSE population END WHERE id IN (116820);

UPDATE cities SET population = CASE id WHEN 115586 THEN 16051 WHEN 122377 THEN 16051 ELSE population END WHERE id IN (115586,122377);

UPDATE cities SET population = CASE id WHEN 125562 THEN 16046 ELSE population END WHERE id IN (125562);

UPDATE cities SET population = CASE id WHEN 118329 THEN 16028 ELSE population END WHERE id IN (118329);

UPDATE cities SET population = CASE id WHEN 113013 THEN 16026 ELSE population END WHERE id IN (113013);

UPDATE cities SET population = CASE id WHEN 113861 THEN 16000 ELSE population END WHERE id IN (113861);

UPDATE cities SET population = CASE id WHEN 116789 THEN 15947 ELSE population END WHERE id IN (116789);

UPDATE cities SET population = CASE id WHEN 113067 THEN 15926 ELSE population END WHERE id IN (113067);

UPDATE cities SET population = CASE id WHEN 128265 THEN 15922 ELSE population END WHERE id IN (128265);

UPDATE cities SET population = CASE id WHEN 120289 THEN 15892 ELSE population END WHERE id IN (120289);

UPDATE cities SET population = CASE id WHEN 114199 THEN 15884 ELSE population END WHERE id IN (114199);

UPDATE cities SET population = CASE id WHEN 123968 THEN 15876 ELSE population END WHERE id IN (123968);

UPDATE cities SET population = CASE id WHEN 141122 THEN 15838 ELSE population END WHERE id IN (141122);

UPDATE cities SET population = CASE id WHEN 125557 THEN 15824 ELSE population END WHERE id IN (125557);

UPDATE cities SET population = CASE id WHEN 111534 THEN 15802 ELSE population END WHERE id IN (111534);

UPDATE cities SET population = CASE id WHEN 116013 THEN 15782 ELSE population END WHERE id IN (116013);

UPDATE cities SET population = CASE id WHEN 111244 THEN 15760 ELSE population END WHERE id IN (111244);

UPDATE cities SET population = CASE id WHEN 117122 THEN 15724 ELSE population END WHERE id IN (117122);

UPDATE cities SET population = CASE id WHEN 119752 THEN 15723 ELSE population END WHERE id IN (119752);

UPDATE cities SET population = CASE id WHEN 122717 THEN 15709 ELSE population END WHERE id IN (122717);

UPDATE cities SET population = CASE id WHEN 121997 THEN 15669 ELSE population END WHERE id IN (121997);

UPDATE cities SET population = CASE id WHEN 112672 THEN 15617 ELSE population END WHERE id IN (112672);

UPDATE cities SET population = CASE id WHEN 110973 THEN 15580 ELSE population END WHERE id IN (110973);

UPDATE cities SET population = CASE id WHEN 129286 THEN 15567 ELSE population END WHERE id IN (129286);

UPDATE cities SET population = CASE id WHEN 120735 THEN 15555 ELSE population END WHERE id IN (120735);

UPDATE cities SET population = CASE id WHEN 123633 THEN 15551 ELSE population END WHERE id IN (123633);

UPDATE cities SET population = CASE id WHEN 118333 THEN 15503 ELSE population END WHERE id IN (118333);

UPDATE cities SET population = CASE id WHEN 118828 THEN 15501 ELSE population END WHERE id IN (118828);

UPDATE cities SET population = CASE id WHEN 124319 THEN 15498 ELSE population END WHERE id IN (124319);

UPDATE cities SET population = CASE id WHEN 117968 THEN 15496 ELSE population END WHERE id IN (117968);

UPDATE cities SET population = CASE id WHEN 118058 THEN 15474 ELSE population END WHERE id IN (118058);

UPDATE cities SET population = CASE id WHEN 118926 THEN 15467 ELSE population END WHERE id IN (118926);

UPDATE cities SET population = CASE id WHEN 124068 THEN 15457 ELSE population END WHERE id IN (124068);

UPDATE cities SET population = CASE id WHEN 119141 THEN 15451 ELSE population END WHERE id IN (119141);

UPDATE cities SET population = CASE id WHEN 117705 THEN 15431 ELSE population END WHERE id IN (117705);

UPDATE cities SET population = CASE id WHEN 117572 THEN 15427 ELSE population END WHERE id IN (117572);

UPDATE cities SET population = CASE id WHEN 119123 THEN 15422 ELSE population END WHERE id IN (119123);

UPDATE cities SET population = CASE id WHEN 115331 THEN 15359 ELSE population END WHERE id IN (115331);

UPDATE cities SET population = CASE id WHEN 122841 THEN 15354 ELSE population END WHERE id IN (122841);

UPDATE cities SET population = CASE id WHEN 120639 THEN 15346 ELSE population END WHERE id IN (120639);

UPDATE cities SET population = CASE id WHEN 123949 THEN 15345 ELSE population END WHERE id IN (123949);

UPDATE cities SET population = CASE id WHEN 115366 THEN 15319 ELSE population END WHERE id IN (115366);

UPDATE cities SET population = CASE id WHEN 112115 THEN 15317 ELSE population END WHERE id IN (112115);

UPDATE cities SET population = CASE id WHEN 126086 THEN 15294 ELSE population END WHERE id IN (126086);

UPDATE cities SET population = CASE id WHEN 114992 THEN 15277 ELSE population END WHERE id IN (114992);

UPDATE cities SET population = CASE id WHEN 117503 THEN 15272 ELSE population END WHERE id IN (117503);

UPDATE cities SET population = CASE id WHEN 118276 THEN 15271 ELSE population END WHERE id IN (118276);

UPDATE cities SET population = CASE id WHEN 112230 THEN 15268 ELSE population END WHERE id IN (112230);

UPDATE cities SET population = CASE id WHEN 126282 THEN 15253 ELSE population END WHERE id IN (126282);

UPDATE cities SET population = CASE id WHEN 112950 THEN 15175 ELSE population END WHERE id IN (112950);

UPDATE cities SET population = CASE id WHEN 125168 THEN 15151 ELSE population END WHERE id IN (125168);

UPDATE cities SET population = CASE id WHEN 125458 THEN 15147 ELSE population END WHERE id IN (125458);

UPDATE cities SET population = CASE id WHEN 122863 THEN 15125 ELSE population END WHERE id IN (122863);

UPDATE cities SET population = CASE id WHEN 141780 THEN 15106 ELSE population END WHERE id IN (141780);

UPDATE cities SET population = CASE id WHEN 124842 THEN 15102 ELSE population END WHERE id IN (124842);

UPDATE cities SET population = CASE id WHEN 122396 THEN 15087 ELSE population END WHERE id IN (122396);

UPDATE cities SET population = CASE id WHEN 129063 THEN 15069 ELSE population END WHERE id IN (129063);

UPDATE cities SET population = CASE id WHEN 127029 THEN 15057 ELSE population END WHERE id IN (127029);

UPDATE cities SET population = CASE id WHEN 129268 THEN 15052 ELSE population END WHERE id IN (129268);

UPDATE cities SET population = CASE id WHEN 111888 THEN 15010 ELSE population END WHERE id IN (111888);

UPDATE cities SET population = CASE id WHEN 115515 THEN 15001 ELSE population END WHERE id IN (115515);

UPDATE cities SET population = CASE id WHEN 116982 THEN 14925 ELSE population END WHERE id IN (116982);

UPDATE cities SET population = CASE id WHEN 118740 THEN 14907 ELSE population END WHERE id IN (118740);

UPDATE cities SET population = CASE id WHEN 119286 THEN 14896 ELSE population END WHERE id IN (119286);

UPDATE cities SET population = CASE id WHEN 119104 THEN 14884 ELSE population END WHERE id IN (119104);

UPDATE cities SET population = CASE id WHEN 119064 THEN 14869 ELSE population END WHERE id IN (119064);

UPDATE cities SET population = CASE id WHEN 114864 THEN 14853 ELSE population END WHERE id IN (114864);

UPDATE cities SET population = CASE id WHEN 125662 THEN 14850 ELSE population END WHERE id IN (125662);

UPDATE cities SET population = CASE id WHEN 121808 THEN 14847 ELSE population END WHERE id IN (121808);

UPDATE cities SET population = CASE id WHEN 119219 THEN 14819 ELSE population END WHERE id IN (119219);

UPDATE cities SET population = CASE id WHEN 119259 THEN 14773 ELSE population END WHERE id IN (119259);

UPDATE cities SET population = CASE id WHEN 120286 THEN 14688 ELSE population END WHERE id IN (120286);

UPDATE cities SET population = CASE id WHEN 117763 THEN 14598 ELSE population END WHERE id IN (117763);

UPDATE cities SET population = CASE id WHEN 111093 THEN 14570 ELSE population END WHERE id IN (111093);

UPDATE cities SET population = CASE id WHEN 118049 THEN 14539 ELSE population END WHERE id IN (118049);

UPDATE cities SET population = CASE id WHEN 126885 THEN 14518 ELSE population END WHERE id IN (126885);

UPDATE cities SET population = CASE id WHEN 124140 THEN 14515 ELSE population END WHERE id IN (124140);

UPDATE cities SET population = CASE id WHEN 141843 THEN 14498 ELSE population END WHERE id IN (141843);

UPDATE cities SET population = CASE id WHEN 117672 THEN 14495 WHEN 129203 THEN 14495 ELSE population END WHERE id IN (117672,129203);

UPDATE cities SET population = CASE id WHEN 128520 THEN 14472 ELSE population END WHERE id IN (128520);

UPDATE cities SET population = CASE id WHEN 117246 THEN 14470 ELSE population END WHERE id IN (117246);

UPDATE cities SET population = CASE id WHEN 126900 THEN 14429 ELSE population END WHERE id IN (126900);

UPDATE cities SET population = CASE id WHEN 116870 THEN 14415 ELSE population END WHERE id IN (116870);

UPDATE cities SET population = CASE id WHEN 124260 THEN 14403 ELSE population END WHERE id IN (124260);

UPDATE cities SET population = CASE id WHEN 118766 THEN 14388 ELSE population END WHERE id IN (118766);

UPDATE cities SET population = CASE id WHEN 122267 THEN 14363 ELSE population END WHERE id IN (122267);

UPDATE cities SET population = CASE id WHEN 118091 THEN 14355 ELSE population END WHERE id IN (118091);

UPDATE cities SET population = CASE id WHEN 112887 THEN 14353 ELSE population END WHERE id IN (112887);

UPDATE cities SET population = CASE id WHEN 118413 THEN 14347 ELSE population END WHERE id IN (118413);

UPDATE cities SET population = CASE id WHEN 117627 THEN 14333 ELSE population END WHERE id IN (117627);

UPDATE cities SET population = CASE id WHEN 112214 THEN 14295 ELSE population END WHERE id IN (112214);

UPDATE cities SET population = CASE id WHEN 141565 THEN 14275 ELSE population END WHERE id IN (141565);

UPDATE cities SET population = CASE id WHEN 111223 THEN 14236 ELSE population END WHERE id IN (111223);

UPDATE cities SET population = CASE id WHEN 113343 THEN 14211 ELSE population END WHERE id IN (113343);

UPDATE cities SET population = CASE id WHEN 122349 THEN 14176 ELSE population END WHERE id IN (122349);

UPDATE cities SET population = CASE id WHEN 118179 THEN 14133 ELSE population END WHERE id IN (118179);

UPDATE cities SET population = CASE id WHEN 116666 THEN 14123 ELSE population END WHERE id IN (116666);

UPDATE cities SET population = CASE id WHEN 118369 THEN 14122 ELSE population END WHERE id IN (118369);

UPDATE cities SET population = CASE id WHEN 127030 THEN 14104 ELSE population END WHERE id IN (127030);

UPDATE cities SET population = CASE id WHEN 125008 THEN 14067 ELSE population END WHERE id IN (125008);

UPDATE cities SET population = CASE id WHEN 125419 THEN 14058 ELSE population END WHERE id IN (125419);

UPDATE cities SET population = CASE id WHEN 128540 THEN 14050 ELSE population END WHERE id IN (128540);

UPDATE cities SET population = CASE id WHEN 129085 THEN 14029 ELSE population END WHERE id IN (129085);

UPDATE cities SET population = CASE id WHEN 125338 THEN 14014 ELSE population END WHERE id IN (125338);

UPDATE cities SET population = CASE id WHEN 121500 THEN 13985 ELSE population END WHERE id IN (121500);

UPDATE cities SET population = CASE id WHEN 120503 THEN 13966 ELSE population END WHERE id IN (120503);

UPDATE cities SET population = CASE id WHEN 123507 THEN 13956 ELSE population END WHERE id IN (123507);

UPDATE cities SET population = CASE id WHEN 118836 THEN 13913 ELSE population END WHERE id IN (118836);

UPDATE cities SET population = CASE id WHEN 119579 THEN 13902 WHEN 120652 THEN 13902 ELSE population END WHERE id IN (119579,120652);

UPDATE cities SET population = CASE id WHEN 141488 THEN 13900 ELSE population END WHERE id IN (141488);

UPDATE cities SET population = CASE id WHEN 123479 THEN 13862 ELSE population END WHERE id IN (123479);

UPDATE cities SET population = CASE id WHEN 129170 THEN 13834 ELSE population END WHERE id IN (129170);

UPDATE cities SET population = CASE id WHEN 111331 THEN 13816 ELSE population END WHERE id IN (111331);

UPDATE cities SET population = CASE id WHEN 123257 THEN 13811 ELSE population END WHERE id IN (123257);

UPDATE cities SET population = CASE id WHEN 126954 THEN 13809 ELSE population END WHERE id IN (126954);

UPDATE cities SET population = CASE id WHEN 124601 THEN 13802 ELSE population END WHERE id IN (124601);

UPDATE cities SET population = CASE id WHEN 111631 THEN 13776 ELSE population END WHERE id IN (111631);

UPDATE cities SET population = CASE id WHEN 122417 THEN 13730 ELSE population END WHERE id IN (122417);

UPDATE cities SET population = CASE id WHEN 126079 THEN 13716 ELSE population END WHERE id IN (126079);

UPDATE cities SET population = CASE id WHEN 141475 THEN 13691 ELSE population END WHERE id IN (141475);

UPDATE cities SET population = CASE id WHEN 111575 THEN 13688 ELSE population END WHERE id IN (111575);

UPDATE cities SET population = CASE id WHEN 113340 THEN 13676 ELSE population END WHERE id IN (113340);

UPDATE cities SET population = CASE id WHEN 121308 THEN 13652 ELSE population END WHERE id IN (121308);

UPDATE cities SET population = CASE id WHEN 121350 THEN 13645 ELSE population END WHERE id IN (121350);

UPDATE cities SET population = CASE id WHEN 121747 THEN 13611 ELSE population END WHERE id IN (121747);

UPDATE cities SET population = CASE id WHEN 120291 THEN 13579 ELSE population END WHERE id IN (120291);

UPDATE cities SET population = CASE id WHEN 120435 THEN 13567 ELSE population END WHERE id IN (120435);

UPDATE cities SET population = CASE id WHEN 118746 THEN 13566 ELSE population END WHERE id IN (118746);

UPDATE cities SET population = CASE id WHEN 126229 THEN 13562 ELSE population END WHERE id IN (126229);

UPDATE cities SET population = CASE id WHEN 128203 THEN 13545 ELSE population END WHERE id IN (128203);

UPDATE cities SET population = CASE id WHEN 125193 THEN 13536 ELSE population END WHERE id IN (125193);

UPDATE cities SET population = CASE id WHEN 128549 THEN 13497 ELSE population END WHERE id IN (128549);

UPDATE cities SET population = CASE id WHEN 114582 THEN 13467 ELSE population END WHERE id IN (114582);

UPDATE cities SET population = CASE id WHEN 141297 THEN 13460 ELSE population END WHERE id IN (141297);

UPDATE cities SET population = CASE id WHEN 120677 THEN 13446 ELSE population END WHERE id IN (120677);

UPDATE cities SET population = CASE id WHEN 141531 THEN 13393 ELSE population END WHERE id IN (141531);

UPDATE cities SET population = CASE id WHEN 120164 THEN 13386 ELSE population END WHERE id IN (120164);

UPDATE cities SET population = CASE id WHEN 125656 THEN 13338 ELSE population END WHERE id IN (125656);

UPDATE cities SET population = CASE id WHEN 128510 THEN 13317 ELSE population END WHERE id IN (128510);

UPDATE cities SET population = CASE id WHEN 126372 THEN 13311 ELSE population END WHERE id IN (126372);

UPDATE cities SET population = CASE id WHEN 111986 THEN 13306 ELSE population END WHERE id IN (111986);

UPDATE cities SET population = CASE id WHEN 122167 THEN 13299 ELSE population END WHERE id IN (122167);

UPDATE cities SET population = CASE id WHEN 116869 THEN 13295 ELSE population END WHERE id IN (116869);

UPDATE cities SET population = CASE id WHEN 113111 THEN 13289 ELSE population END WHERE id IN (113111);

UPDATE cities SET population = CASE id WHEN 120574 THEN 13217 ELSE population END WHERE id IN (120574);

UPDATE cities SET population = CASE id WHEN 141771 THEN 13202 ELSE population END WHERE id IN (141771);

UPDATE cities SET population = CASE id WHEN 120732 THEN 13175 ELSE population END WHERE id IN (120732);

UPDATE cities SET population = CASE id WHEN 123290 THEN 13165 ELSE population END WHERE id IN (123290);

UPDATE cities SET population = CASE id WHEN 128678 THEN 13155 ELSE population END WHERE id IN (128678);

UPDATE cities SET population = CASE id WHEN 141221 THEN 13146 ELSE population END WHERE id IN (141221);

UPDATE cities SET population = CASE id WHEN 129372 THEN 13091 ELSE population END WHERE id IN (129372);

UPDATE cities SET population = CASE id WHEN 129598 THEN 13090 ELSE population END WHERE id IN (129598);

UPDATE cities SET population = CASE id WHEN 114525 THEN 13081 ELSE population END WHERE id IN (114525);

UPDATE cities SET population = CASE id WHEN 125694 THEN 13070 ELSE population END WHERE id IN (125694);

UPDATE cities SET population = CASE id WHEN 127110 THEN 13067 ELSE population END WHERE id IN (127110);

UPDATE cities SET population = CASE id WHEN 117144 THEN 13062 ELSE population END WHERE id IN (117144);

UPDATE cities SET population = CASE id WHEN 121575 THEN 13061 ELSE population END WHERE id IN (121575);

UPDATE cities SET population = CASE id WHEN 121303 THEN 13039 ELSE population END WHERE id IN (121303);

UPDATE cities SET population = CASE id WHEN 122861 THEN 13035 ELSE population END WHERE id IN (122861);

UPDATE cities SET population = CASE id WHEN 116490 THEN 13010 ELSE population END WHERE id IN (116490);

UPDATE cities SET population = CASE id WHEN 141371 THEN 13006 ELSE population END WHERE id IN (141371);

UPDATE cities SET population = CASE id WHEN 125264 THEN 12993 ELSE population END WHERE id IN (125264);

UPDATE cities SET population = CASE id WHEN 114105 THEN 12984 ELSE population END WHERE id IN (114105);

UPDATE cities SET population = CASE id WHEN 127281 THEN 12980 ELSE population END WHERE id IN (127281);

UPDATE cities SET population = CASE id WHEN 111625 THEN 12979 ELSE population END WHERE id IN (111625);

UPDATE cities SET population = CASE id WHEN 141654 THEN 12972 ELSE population END WHERE id IN (141654);

UPDATE cities SET population = CASE id WHEN 119345 THEN 12968 ELSE population END WHERE id IN (119345);

UPDATE cities SET population = CASE id WHEN 119628 THEN 12941 ELSE population END WHERE id IN (119628);

UPDATE cities SET population = CASE id WHEN 116986 THEN 12939 ELSE population END WHERE id IN (116986);

UPDATE cities SET population = CASE id WHEN 115920 THEN 12931 ELSE population END WHERE id IN (115920);

UPDATE cities SET population = CASE id WHEN 141276 THEN 12899 ELSE population END WHERE id IN (141276);

UPDATE cities SET population = CASE id WHEN 117973 THEN 12898 ELSE population END WHERE id IN (117973);

UPDATE cities SET population = CASE id WHEN 117284 THEN 12870 ELSE population END WHERE id IN (117284);

UPDATE cities SET population = CASE id WHEN 111576 THEN 12788 ELSE population END WHERE id IN (111576);

UPDATE cities SET population = CASE id WHEN 126098 THEN 12754 ELSE population END WHERE id IN (126098);

UPDATE cities SET population = CASE id WHEN 141138 THEN 12747 ELSE population END WHERE id IN (141138);

UPDATE cities SET population = CASE id WHEN 111322 THEN 12745 ELSE population END WHERE id IN (111322);

UPDATE cities SET population = CASE id WHEN 115261 THEN 12700 ELSE population END WHERE id IN (115261);

UPDATE cities SET population = CASE id WHEN 112553 THEN 12692 ELSE population END WHERE id IN (112553);

UPDATE cities SET population = CASE id WHEN 121270 THEN 12682 ELSE population END WHERE id IN (121270);

UPDATE cities SET population = CASE id WHEN 125222 THEN 12677 ELSE population END WHERE id IN (125222);

UPDATE cities SET population = CASE id WHEN 123991 THEN 12676 ELSE population END WHERE id IN (123991);

UPDATE cities SET population = CASE id WHEN 141468 THEN 12585 ELSE population END WHERE id IN (141468);

UPDATE cities SET population = CASE id WHEN 125350 THEN 12562 ELSE population END WHERE id IN (125350);

UPDATE cities SET population = CASE id WHEN 120014 THEN 12553 ELSE population END WHERE id IN (120014);

UPDATE cities SET population = CASE id WHEN 141823 THEN 12545 ELSE population END WHERE id IN (141823);

UPDATE cities SET population = CASE id WHEN 128205 THEN 12540 ELSE population END WHERE id IN (128205);

UPDATE cities SET population = CASE id WHEN 112023 THEN 12502 ELSE population END WHERE id IN (112023);

UPDATE cities SET population = CASE id WHEN 113611 THEN 12457 ELSE population END WHERE id IN (113611);

UPDATE cities SET population = CASE id WHEN 111443 THEN 12455 ELSE population END WHERE id IN (111443);

UPDATE cities SET population = CASE id WHEN 141832 THEN 12449 ELSE population END WHERE id IN (141832);

UPDATE cities SET population = CASE id WHEN 110966 THEN 12434 ELSE population END WHERE id IN (110966);

UPDATE cities SET population = CASE id WHEN 119866 THEN 12424 ELSE population END WHERE id IN (119866);

UPDATE cities SET population = CASE id WHEN 120881 THEN 12421 ELSE population END WHERE id IN (120881);

UPDATE cities SET population = CASE id WHEN 122404 THEN 12416 ELSE population END WHERE id IN (122404);

UPDATE cities SET population = CASE id WHEN 112857 THEN 12414 ELSE population END WHERE id IN (112857);

UPDATE cities SET population = CASE id WHEN 116788 THEN 12382 ELSE population END WHERE id IN (116788);

UPDATE cities SET population = CASE id WHEN 122660 THEN 12354 ELSE population END WHERE id IN (122660);

UPDATE cities SET population = CASE id WHEN 114243 THEN 12327 ELSE population END WHERE id IN (114243);

UPDATE cities SET population = CASE id WHEN 124558 THEN 12323 ELSE population END WHERE id IN (124558);

UPDATE cities SET population = CASE id WHEN 114648 THEN 12317 ELSE population END WHERE id IN (114648);

UPDATE cities SET population = CASE id WHEN 123158 THEN 12312 ELSE population END WHERE id IN (123158);

UPDATE cities SET population = CASE id WHEN 121232 THEN 12292 ELSE population END WHERE id IN (121232);

UPDATE cities SET population = CASE id WHEN 124400 THEN 12284 ELSE population END WHERE id IN (124400);

UPDATE cities SET population = CASE id WHEN 141758 THEN 12281 ELSE population END WHERE id IN (141758);

UPDATE cities SET population = CASE id WHEN 121360 THEN 12216 ELSE population END WHERE id IN (121360);

UPDATE cities SET population = CASE id WHEN 119623 THEN 12208 ELSE population END WHERE id IN (119623);

UPDATE cities SET population = CASE id WHEN 124938 THEN 12204 WHEN 129393 THEN 12204 ELSE population END WHERE id IN (124938,129393);

UPDATE cities SET population = CASE id WHEN 126596 THEN 12202 ELSE population END WHERE id IN (126596);

UPDATE cities SET population = CASE id WHEN 125219 THEN 12181 ELSE population END WHERE id IN (125219);

UPDATE cities SET population = CASE id WHEN 119879 THEN 12161 ELSE population END WHERE id IN (119879);

UPDATE cities SET population = CASE id WHEN 116911 THEN 12154 ELSE population END WHERE id IN (116911);

UPDATE cities SET population = CASE id WHEN 127100 THEN 12147 ELSE population END WHERE id IN (127100);

UPDATE cities SET population = CASE id WHEN 125087 THEN 12138 ELSE population END WHERE id IN (125087);

UPDATE cities SET population = CASE id WHEN 111457 THEN 12136 ELSE population END WHERE id IN (111457);

UPDATE cities SET population = CASE id WHEN 141103 THEN 12135 ELSE population END WHERE id IN (141103);

UPDATE cities SET population = CASE id WHEN 116252 THEN 12133 ELSE population END WHERE id IN (116252);

UPDATE cities SET population = CASE id WHEN 125759 THEN 12093 ELSE population END WHERE id IN (125759);

UPDATE cities SET population = CASE id WHEN 115539 THEN 12081 ELSE population END WHERE id IN (115539);

UPDATE cities SET population = CASE id WHEN 128538 THEN 12078 ELSE population END WHERE id IN (128538);

UPDATE cities SET population = CASE id WHEN 120988 THEN 12040 ELSE population END WHERE id IN (120988);

UPDATE cities SET population = CASE id WHEN 111497 THEN 12036 WHEN 141602 THEN 12036 ELSE population END WHERE id IN (111497,141602);

UPDATE cities SET population = CASE id WHEN 115854 THEN 12034 ELSE population END WHERE id IN (115854);

UPDATE cities SET population = CASE id WHEN 126934 THEN 12029 ELSE population END WHERE id IN (126934);

UPDATE cities SET population = CASE id WHEN 124956 THEN 12022 ELSE population END WHERE id IN (124956);

UPDATE cities SET population = CASE id WHEN 120780 THEN 12019 ELSE population END WHERE id IN (120780);

UPDATE cities SET population = CASE id WHEN 141688 THEN 12003 ELSE population END WHERE id IN (141688);

UPDATE cities SET population = CASE id WHEN 117273 THEN 11999 ELSE population END WHERE id IN (117273);

UPDATE cities SET population = CASE id WHEN 117239 THEN 11986 ELSE population END WHERE id IN (117239);

UPDATE cities SET population = CASE id WHEN 121351 THEN 11980 ELSE population END WHERE id IN (121351);

UPDATE cities SET population = CASE id WHEN 114810 THEN 11966 ELSE population END WHERE id IN (114810);

UPDATE cities SET population = CASE id WHEN 128888 THEN 11921 ELSE population END WHERE id IN (128888);

UPDATE cities SET population = CASE id WHEN 121365 THEN 11879 ELSE population END WHERE id IN (121365);

UPDATE cities SET population = CASE id WHEN 114203 THEN 11867 ELSE population END WHERE id IN (114203);

UPDATE cities SET population = CASE id WHEN 113216 THEN 11857 ELSE population END WHERE id IN (113216);

UPDATE cities SET population = CASE id WHEN 120031 THEN 11849 WHEN 127536 THEN 11849 ELSE population END WHERE id IN (120031,127536);

UPDATE cities SET population = CASE id WHEN 111154 THEN 11843 ELSE population END WHERE id IN (111154);

UPDATE cities SET population = CASE id WHEN 117669 THEN 11819 ELSE population END WHERE id IN (117669);

UPDATE cities SET population = CASE id WHEN 114701 THEN 11818 ELSE population END WHERE id IN (114701);

UPDATE cities SET population = CASE id WHEN 120832 THEN 11800 ELSE population END WHERE id IN (120832);

UPDATE cities SET population = CASE id WHEN 141326 THEN 11783 ELSE population END WHERE id IN (141326);

UPDATE cities SET population = CASE id WHEN 124937 THEN 11769 ELSE population END WHERE id IN (124937);

UPDATE cities SET population = CASE id WHEN 126550 THEN 11768 ELSE population END WHERE id IN (126550);

UPDATE cities SET population = CASE id WHEN 141135 THEN 11762 ELSE population END WHERE id IN (141135);

UPDATE cities SET population = CASE id WHEN 129061 THEN 11682 ELSE population END WHERE id IN (129061);

UPDATE cities SET population = CASE id WHEN 117817 THEN 11665 ELSE population END WHERE id IN (117817);

UPDATE cities SET population = CASE id WHEN 141357 THEN 11644 ELSE population END WHERE id IN (141357);

UPDATE cities SET population = CASE id WHEN 111462 THEN 11625 ELSE population END WHERE id IN (111462);

UPDATE cities SET population = CASE id WHEN 141659 THEN 11619 ELSE population END WHERE id IN (141659);

UPDATE cities SET population = CASE id WHEN 123612 THEN 11607 ELSE population END WHERE id IN (123612);

UPDATE cities SET population = CASE id WHEN 115981 THEN 11586 ELSE population END WHERE id IN (115981);

UPDATE cities SET population = CASE id WHEN 124540 THEN 11576 ELSE population END WHERE id IN (124540);

UPDATE cities SET population = CASE id WHEN 116991 THEN 11552 ELSE population END WHERE id IN (116991);

UPDATE cities SET population = CASE id WHEN 117061 THEN 11550 ELSE population END WHERE id IN (117061);

UPDATE cities SET population = CASE id WHEN 128108 THEN 11547 WHEN 141774 THEN 11547 ELSE population END WHERE id IN (128108,141774);

UPDATE cities SET population = CASE id WHEN 127844 THEN 11542 ELSE population END WHERE id IN (127844);

UPDATE cities SET population = CASE id WHEN 113840 THEN 11534 ELSE population END WHERE id IN (113840);

UPDATE cities SET population = CASE id WHEN 125062 THEN 11530 ELSE population END WHERE id IN (125062);

UPDATE cities SET population = CASE id WHEN 117432 THEN 11527 ELSE population END WHERE id IN (117432);

UPDATE cities SET population = CASE id WHEN 125254 THEN 11484 ELSE population END WHERE id IN (125254);

UPDATE cities SET population = CASE id WHEN 117018 THEN 11481 ELSE population END WHERE id IN (117018);

UPDATE cities SET population = CASE id WHEN 111347 THEN 11463 ELSE population END WHERE id IN (111347);

UPDATE cities SET population = CASE id WHEN 118455 THEN 11451 ELSE population END WHERE id IN (118455);

UPDATE cities SET population = CASE id WHEN 116475 THEN 11442 ELSE population END WHERE id IN (116475);

UPDATE cities SET population = CASE id WHEN 126580 THEN 11439 ELSE population END WHERE id IN (126580);

UPDATE cities SET population = CASE id WHEN 123859 THEN 11431 ELSE population END WHERE id IN (123859);

UPDATE cities SET population = CASE id WHEN 121657 THEN 11430 ELSE population END WHERE id IN (121657);

UPDATE cities SET population = CASE id WHEN 125738 THEN 11416 ELSE population END WHERE id IN (125738);

UPDATE cities SET population = CASE id WHEN 116887 THEN 11413 ELSE population END WHERE id IN (116887);

UPDATE cities SET population = CASE id WHEN 128731 THEN 11412 ELSE population END WHERE id IN (128731);

UPDATE cities SET population = CASE id WHEN 114856 THEN 11411 ELSE population END WHERE id IN (114856);

UPDATE cities SET population = CASE id WHEN 127212 THEN 11389 ELSE population END WHERE id IN (127212);

UPDATE cities SET population = CASE id WHEN 124168 THEN 11376 ELSE population END WHERE id IN (124168);

UPDATE cities SET population = CASE id WHEN 125120 THEN 11373 ELSE population END WHERE id IN (125120);

UPDATE cities SET population = CASE id WHEN 120923 THEN 11372 ELSE population END WHERE id IN (120923);

UPDATE cities SET population = CASE id WHEN 122823 THEN 11370 ELSE population END WHERE id IN (122823);

UPDATE cities SET population = CASE id WHEN 123327 THEN 11355 ELSE population END WHERE id IN (123327);

UPDATE cities SET population = CASE id WHEN 113260 THEN 11347 ELSE population END WHERE id IN (113260);

UPDATE cities SET population = CASE id WHEN 123681 THEN 11345 ELSE population END WHERE id IN (123681);

UPDATE cities SET population = CASE id WHEN 122901 THEN 11333 WHEN 123249 THEN 11333 ELSE population END WHERE id IN (122901,123249);

UPDATE cities SET population = CASE id WHEN 124344 THEN 11282 ELSE population END WHERE id IN (124344);

UPDATE cities SET population = CASE id WHEN 128484 THEN 11280 ELSE population END WHERE id IN (128484);

UPDATE cities SET population = CASE id WHEN 141709 THEN 11272 ELSE population END WHERE id IN (141709);

UPDATE cities SET population = CASE id WHEN 117812 THEN 11270 ELSE population END WHERE id IN (117812);

UPDATE cities SET population = CASE id WHEN 118799 THEN 11267 ELSE population END WHERE id IN (118799);

UPDATE cities SET population = CASE id WHEN 129086 THEN 11247 ELSE population END WHERE id IN (129086);

UPDATE cities SET population = CASE id WHEN 129707 THEN 11231 ELSE population END WHERE id IN (129707);

UPDATE cities SET population = CASE id WHEN 126349 THEN 11217 ELSE population END WHERE id IN (126349);

UPDATE cities SET population = CASE id WHEN 126825 THEN 11212 ELSE population END WHERE id IN (126825);

UPDATE cities SET population = CASE id WHEN 112231 THEN 11207 ELSE population END WHERE id IN (112231);

UPDATE cities SET population = CASE id WHEN 119163 THEN 11193 ELSE population END WHERE id IN (119163);

UPDATE cities SET population = CASE id WHEN 119229 THEN 11184 ELSE population END WHERE id IN (119229);

UPDATE cities SET population = CASE id WHEN 141730 THEN 11182 ELSE population END WHERE id IN (141730);

UPDATE cities SET population = CASE id WHEN 116082 THEN 11177 ELSE population END WHERE id IN (116082);

UPDATE cities SET population = CASE id WHEN 117481 THEN 11176 ELSE population END WHERE id IN (117481);

UPDATE cities SET population = CASE id WHEN 123102 THEN 11171 ELSE population END WHERE id IN (123102);

UPDATE cities SET population = CASE id WHEN 123310 THEN 11148 ELSE population END WHERE id IN (123310);

UPDATE cities SET population = CASE id WHEN 123473 THEN 11134 ELSE population END WHERE id IN (123473);

UPDATE cities SET population = CASE id WHEN 120241 THEN 11103 ELSE population END WHERE id IN (120241);

UPDATE cities SET population = CASE id WHEN 113359 THEN 11080 ELSE population END WHERE id IN (113359);

UPDATE cities SET population = CASE id WHEN 124096 THEN 11060 ELSE population END WHERE id IN (124096);

UPDATE cities SET population = CASE id WHEN 123487 THEN 10999 ELSE population END WHERE id IN (123487);

UPDATE cities SET population = CASE id WHEN 128959 THEN 10990 ELSE population END WHERE id IN (128959);

UPDATE cities SET population = CASE id WHEN 114811 THEN 10984 ELSE population END WHERE id IN (114811);

UPDATE cities SET population = CASE id WHEN 127973 THEN 10957 ELSE population END WHERE id IN (127973);

UPDATE cities SET population = CASE id WHEN 115010 THEN 10952 ELSE population END WHERE id IN (115010);

UPDATE cities SET population = CASE id WHEN 118412 THEN 10949 ELSE population END WHERE id IN (118412);

UPDATE cities SET population = CASE id WHEN 121071 THEN 10928 ELSE population END WHERE id IN (121071);

UPDATE cities SET population = CASE id WHEN 126194 THEN 10919 ELSE population END WHERE id IN (126194);

UPDATE cities SET population = CASE id WHEN 120552 THEN 10900 WHEN 141412 THEN 10900 ELSE population END WHERE id IN (120552,141412);

UPDATE cities SET population = CASE id WHEN 141175 THEN 10899 ELSE population END WHERE id IN (141175);

UPDATE cities SET population = CASE id WHEN 127203 THEN 10898 ELSE population END WHERE id IN (127203);

UPDATE cities SET population = CASE id WHEN 114653 THEN 10897 ELSE population END WHERE id IN (114653);

UPDATE cities SET population = CASE id WHEN 127151 THEN 10896 ELSE population END WHERE id IN (127151);

UPDATE cities SET population = CASE id WHEN 123372 THEN 10883 ELSE population END WHERE id IN (123372);

UPDATE cities SET population = CASE id WHEN 129510 THEN 10879 ELSE population END WHERE id IN (129510);

UPDATE cities SET population = CASE id WHEN 125214 THEN 10873 ELSE population END WHERE id IN (125214);

UPDATE cities SET population = CASE id WHEN 128707 THEN 10848 ELSE population END WHERE id IN (128707);

UPDATE cities SET population = CASE id WHEN 114394 THEN 10844 ELSE population END WHERE id IN (114394);

UPDATE cities SET population = CASE id WHEN 127342 THEN 10809 ELSE population END WHERE id IN (127342);

UPDATE cities SET population = CASE id WHEN 122063 THEN 10796 ELSE population END WHERE id IN (122063);

UPDATE cities SET population = CASE id WHEN 126521 THEN 10782 ELSE population END WHERE id IN (126521);

UPDATE cities SET population = CASE id WHEN 116407 THEN 10774 ELSE population END WHERE id IN (116407);

UPDATE cities SET population = CASE id WHEN 115213 THEN 10755 ELSE population END WHERE id IN (115213);

UPDATE cities SET population = CASE id WHEN 127302 THEN 10753 ELSE population END WHERE id IN (127302);

UPDATE cities SET population = CASE id WHEN 120942 THEN 10722 ELSE population END WHERE id IN (120942);

UPDATE cities SET population = CASE id WHEN 120144 THEN 10709 ELSE population END WHERE id IN (120144);

UPDATE cities SET population = CASE id WHEN 116896 THEN 10705 ELSE population END WHERE id IN (116896);

UPDATE cities SET population = CASE id WHEN 120618 THEN 10688 ELSE population END WHERE id IN (120618);

UPDATE cities SET population = CASE id WHEN 141597 THEN 10668 ELSE population END WHERE id IN (141597);

UPDATE cities SET population = CASE id WHEN 113073 THEN 10650 ELSE population END WHERE id IN (113073);

UPDATE cities SET population = CASE id WHEN 125880 THEN 10644 ELSE population END WHERE id IN (125880);

UPDATE cities SET population = CASE id WHEN 120123 THEN 10639 ELSE population END WHERE id IN (120123);

UPDATE cities SET population = CASE id WHEN 129454 THEN 10613 ELSE population END WHERE id IN (129454);

UPDATE cities SET population = CASE id WHEN 116233 THEN 10602 ELSE population END WHERE id IN (116233);

UPDATE cities SET population = CASE id WHEN 127982 THEN 10573 WHEN 128189 THEN 10573 WHEN 128233 THEN 10573 ELSE population END WHERE id IN (127982,128189,128233);

UPDATE cities SET population = CASE id WHEN 120242 THEN 10569 ELSE population END WHERE id IN (120242);

UPDATE cities SET population = CASE id WHEN 118461 THEN 10559 ELSE population END WHERE id IN (118461);

UPDATE cities SET population = CASE id WHEN 116274 THEN 10548 ELSE population END WHERE id IN (116274);

UPDATE cities SET population = CASE id WHEN 112136 THEN 10533 ELSE population END WHERE id IN (112136);

UPDATE cities SET population = CASE id WHEN 141319 THEN 10532 ELSE population END WHERE id IN (141319);

UPDATE cities SET population = CASE id WHEN 116417 THEN 10523 WHEN 119074 THEN 10523 ELSE population END WHERE id IN (116417,119074);

UPDATE cities SET population = CASE id WHEN 121093 THEN 10517 ELSE population END WHERE id IN (121093);

UPDATE cities SET population = CASE id WHEN 141534 THEN 10506 ELSE population END WHERE id IN (141534);

UPDATE cities SET population = CASE id WHEN 125316 THEN 10490 ELSE population END WHERE id IN (125316);

UPDATE cities SET population = CASE id WHEN 141387 THEN 10489 ELSE population END WHERE id IN (141387);

UPDATE cities SET population = CASE id WHEN 141666 THEN 10469 ELSE population END WHERE id IN (141666);

UPDATE cities SET population = CASE id WHEN 120542 THEN 10405 ELSE population END WHERE id IN (120542);

UPDATE cities SET population = CASE id WHEN 141190 THEN 10402 ELSE population END WHERE id IN (141190);

UPDATE cities SET population = CASE id WHEN 114473 THEN 10388 ELSE population END WHERE id IN (114473);

UPDATE cities SET population = CASE id WHEN 141203 THEN 10387 ELSE population END WHERE id IN (141203);

UPDATE cities SET population = CASE id WHEN 122942 THEN 10386 ELSE population END WHERE id IN (122942);

UPDATE cities SET population = CASE id WHEN 124546 THEN 10382 ELSE population END WHERE id IN (124546);

UPDATE cities SET population = CASE id WHEN 122331 THEN 10354 ELSE population END WHERE id IN (122331);

UPDATE cities SET population = CASE id WHEN 111846 THEN 10353 ELSE population END WHERE id IN (111846);

UPDATE cities SET population = CASE id WHEN 115571 THEN 10345 WHEN 128963 THEN 10345 ELSE population END WHERE id IN (115571,128963);

UPDATE cities SET population = CASE id WHEN 126436 THEN 10334 ELSE population END WHERE id IN (126436);

UPDATE cities SET population = CASE id WHEN 122811 THEN 10331 ELSE population END WHERE id IN (122811);

UPDATE cities SET population = CASE id WHEN 141660 THEN 10324 ELSE population END WHERE id IN (141660);

UPDATE cities SET population = CASE id WHEN 112479 THEN 10323 ELSE population END WHERE id IN (112479);

UPDATE cities SET population = CASE id WHEN 118772 THEN 10293 ELSE population END WHERE id IN (118772);

UPDATE cities SET population = CASE id WHEN 123241 THEN 10291 ELSE population END WHERE id IN (123241);

UPDATE cities SET population = CASE id WHEN 122851 THEN 10268 ELSE population END WHERE id IN (122851);

UPDATE cities SET population = CASE id WHEN 112305 THEN 10267 ELSE population END WHERE id IN (112305);

UPDATE cities SET population = CASE id WHEN 115887 THEN 10266 ELSE population END WHERE id IN (115887);

UPDATE cities SET population = CASE id WHEN 113616 THEN 10265 ELSE population END WHERE id IN (113616);

UPDATE cities SET population = CASE id WHEN 120086 THEN 10258 ELSE population END WHERE id IN (120086);

UPDATE cities SET population = CASE id WHEN 125455 THEN 10244 ELSE population END WHERE id IN (125455);

UPDATE cities SET population = CASE id WHEN 126498 THEN 10242 ELSE population END WHERE id IN (126498);

UPDATE cities SET population = CASE id WHEN 111225 THEN 10235 ELSE population END WHERE id IN (111225);

UPDATE cities SET population = CASE id WHEN 112040 THEN 10232 ELSE population END WHERE id IN (112040);

UPDATE cities SET population = CASE id WHEN 116341 THEN 10224 ELSE population END WHERE id IN (116341);

UPDATE cities SET population = CASE id WHEN 112263 THEN 10223 ELSE population END WHERE id IN (112263);

UPDATE cities SET population = CASE id WHEN 116337 THEN 10221 ELSE population END WHERE id IN (116337);

UPDATE cities SET population = CASE id WHEN 111314 THEN 10217 ELSE population END WHERE id IN (111314);

UPDATE cities SET population = CASE id WHEN 122994 THEN 10215 ELSE population END WHERE id IN (122994);

UPDATE cities SET population = CASE id WHEN 114465 THEN 10191 ELSE population END WHERE id IN (114465);

UPDATE cities SET population = CASE id WHEN 123833 THEN 10150 ELSE population END WHERE id IN (123833);

UPDATE cities SET population = CASE id WHEN 121288 THEN 10133 ELSE population END WHERE id IN (121288);

UPDATE cities SET population = CASE id WHEN 118963 THEN 10082 ELSE population END WHERE id IN (118963);

UPDATE cities SET population = CASE id WHEN 120452 THEN 10075 ELSE population END WHERE id IN (120452);

UPDATE cities SET population = CASE id WHEN 128668 THEN 10066 ELSE population END WHERE id IN (128668);

UPDATE cities SET population = CASE id WHEN 141462 THEN 10060 ELSE population END WHERE id IN (141462);

UPDATE cities SET population = CASE id WHEN 114275 THEN 10049 ELSE population END WHERE id IN (114275);

UPDATE cities SET population = CASE id WHEN 123547 THEN 10043 ELSE population END WHERE id IN (123547);

UPDATE cities SET population = CASE id WHEN 127843 THEN 10036 ELSE population END WHERE id IN (127843);

UPDATE cities SET population = CASE id WHEN 124401 THEN 10035 ELSE population END WHERE id IN (124401);

UPDATE cities SET population = CASE id WHEN 122044 THEN 10032 ELSE population END WHERE id IN (122044);

UPDATE cities SET population = CASE id WHEN 117531 THEN 10027 ELSE population END WHERE id IN (117531);

UPDATE cities SET population = CASE id WHEN 112484 THEN 10005 ELSE population END WHERE id IN (112484);

UPDATE cities SET population = CASE id WHEN 116355 THEN 10003 ELSE population END WHERE id IN (116355);

UPDATE cities SET population = CASE id WHEN 128016 THEN 9990 ELSE population END WHERE id IN (128016);

UPDATE cities SET population = CASE id WHEN 114693 THEN 9969 ELSE population END WHERE id IN (114693);

UPDATE cities SET population = CASE id WHEN 114737 THEN 9928 ELSE population END WHERE id IN (114737);

UPDATE cities SET population = CASE id WHEN 116552 THEN 9914 ELSE population END WHERE id IN (116552);

UPDATE cities SET population = CASE id WHEN 128507 THEN 9897 WHEN 141383 THEN 9897 ELSE population END WHERE id IN (128507,141383);

UPDATE cities SET population = CASE id WHEN 116002 THEN 9895 ELSE population END WHERE id IN (116002);

UPDATE cities SET population = CASE id WHEN 116313 THEN 9892 ELSE population END WHERE id IN (116313);

UPDATE cities SET population = CASE id WHEN 112446 THEN 9888 ELSE population END WHERE id IN (112446);

UPDATE cities SET population = CASE id WHEN 141558 THEN 9879 ELSE population END WHERE id IN (141558);

UPDATE cities SET population = CASE id WHEN 112931 THEN 9876 ELSE population END WHERE id IN (112931);

UPDATE cities SET population = CASE id WHEN 116724 THEN 9874 ELSE population END WHERE id IN (116724);

UPDATE cities SET population = CASE id WHEN 123831 THEN 9870 ELSE population END WHERE id IN (123831);

UPDATE cities SET population = CASE id WHEN 123135 THEN 9860 ELSE population END WHERE id IN (123135);

UPDATE cities SET population = CASE id WHEN 112691 THEN 9856 ELSE population END WHERE id IN (112691);

UPDATE cities SET population = CASE id WHEN 118393 THEN 9848 ELSE population END WHERE id IN (118393);

UPDATE cities SET population = CASE id WHEN 126299 THEN 9834 ELSE population END WHERE id IN (126299);

UPDATE cities SET population = CASE id WHEN 124383 THEN 9829 ELSE population END WHERE id IN (124383);

UPDATE cities SET population = CASE id WHEN 115864 THEN 9826 ELSE population END WHERE id IN (115864);

UPDATE cities SET population = CASE id WHEN 113071 THEN 9808 ELSE population END WHERE id IN (113071);

UPDATE cities SET population = CASE id WHEN 121458 THEN 9805 ELSE population END WHERE id IN (121458);

UPDATE cities SET population = CASE id WHEN 128420 THEN 9790 ELSE population END WHERE id IN (128420);

UPDATE cities SET population = CASE id WHEN 128541 THEN 9788 ELSE population END WHERE id IN (128541);

UPDATE cities SET population = CASE id WHEN 118092 THEN 9779 ELSE population END WHERE id IN (118092);

UPDATE cities SET population = CASE id WHEN 121358 THEN 9757 ELSE population END WHERE id IN (121358);

UPDATE cities SET population = CASE id WHEN 129508 THEN 9755 ELSE population END WHERE id IN (129508);

UPDATE cities SET population = CASE id WHEN 126442 THEN 9753 ELSE population END WHERE id IN (126442);

UPDATE cities SET population = CASE id WHEN 112917 THEN 9736 ELSE population END WHERE id IN (112917);

UPDATE cities SET population = CASE id WHEN 127223 THEN 9700 ELSE population END WHERE id IN (127223);

UPDATE cities SET population = CASE id WHEN 126813 THEN 9679 ELSE population END WHERE id IN (126813);

UPDATE cities SET population = CASE id WHEN 122984 THEN 9673 ELSE population END WHERE id IN (122984);

UPDATE cities SET population = CASE id WHEN 129397 THEN 9657 ELSE population END WHERE id IN (129397);

UPDATE cities SET population = CASE id WHEN 117934 THEN 9656 ELSE population END WHERE id IN (117934);

UPDATE cities SET population = CASE id WHEN 115845 THEN 9646 ELSE population END WHERE id IN (115845);

UPDATE cities SET population = CASE id WHEN 121912 THEN 9628 ELSE population END WHERE id IN (121912);

UPDATE cities SET population = CASE id WHEN 111563 THEN 9626 ELSE population END WHERE id IN (111563);

UPDATE cities SET population = CASE id WHEN 115034 THEN 9614 ELSE population END WHERE id IN (115034);

UPDATE cities SET population = CASE id WHEN 129429 THEN 9600 ELSE population END WHERE id IN (129429);

UPDATE cities SET population = CASE id WHEN 141349 THEN 9599 ELSE population END WHERE id IN (141349);

UPDATE cities SET population = CASE id WHEN 117884 THEN 9576 ELSE population END WHERE id IN (117884);

UPDATE cities SET population = CASE id WHEN 112808 THEN 9569 ELSE population END WHERE id IN (112808);

UPDATE cities SET population = CASE id WHEN 114276 THEN 9565 ELSE population END WHERE id IN (114276);

UPDATE cities SET population = CASE id WHEN 112280 THEN 9549 ELSE population END WHERE id IN (112280);

UPDATE cities SET population = CASE id WHEN 113921 THEN 9545 ELSE population END WHERE id IN (113921);

UPDATE cities SET population = CASE id WHEN 114258 THEN 9519 ELSE population END WHERE id IN (114258);

UPDATE cities SET population = CASE id WHEN 123980 THEN 9517 ELSE population END WHERE id IN (123980);

UPDATE cities SET population = CASE id WHEN 112732 THEN 9512 ELSE population END WHERE id IN (112732);

UPDATE cities SET population = CASE id WHEN 127373 THEN 9495 ELSE population END WHERE id IN (127373);

UPDATE cities SET population = CASE id WHEN 128258 THEN 9483 ELSE population END WHERE id IN (128258);

UPDATE cities SET population = CASE id WHEN 124706 THEN 9476 ELSE population END WHERE id IN (124706);

UPDATE cities SET population = CASE id WHEN 123574 THEN 9474 ELSE population END WHERE id IN (123574);

UPDATE cities SET population = CASE id WHEN 115156 THEN 9465 ELSE population END WHERE id IN (115156);

UPDATE cities SET population = CASE id WHEN 129448 THEN 9464 ELSE population END WHERE id IN (129448);

UPDATE cities SET population = CASE id WHEN 126576 THEN 9454 ELSE population END WHERE id IN (126576);

UPDATE cities SET population = CASE id WHEN 120835 THEN 9450 ELSE population END WHERE id IN (120835);

UPDATE cities SET population = CASE id WHEN 125024 THEN 9433 ELSE population END WHERE id IN (125024);

UPDATE cities SET population = CASE id WHEN 120599 THEN 9392 ELSE population END WHERE id IN (120599);

UPDATE cities SET population = CASE id WHEN 122330 THEN 9380 ELSE population END WHERE id IN (122330);

UPDATE cities SET population = CASE id WHEN 114715 THEN 9379 ELSE population END WHERE id IN (114715);

UPDATE cities SET population = CASE id WHEN 112238 THEN 9367 ELSE population END WHERE id IN (112238);

UPDATE cities SET population = CASE id WHEN 125634 THEN 9365 ELSE population END WHERE id IN (125634);

UPDATE cities SET population = CASE id WHEN 128483 THEN 9334 ELSE population END WHERE id IN (128483);

UPDATE cities SET population = CASE id WHEN 116729 THEN 9327 ELSE population END WHERE id IN (116729);

UPDATE cities SET population = CASE id WHEN 117701 THEN 9322 ELSE population END WHERE id IN (117701);

UPDATE cities SET population = CASE id WHEN 124370 THEN 9314 ELSE population END WHERE id IN (124370);

UPDATE cities SET population = CASE id WHEN 125259 THEN 9309 ELSE population END WHERE id IN (125259);

UPDATE cities SET population = CASE id WHEN 111647 THEN 9299 ELSE population END WHERE id IN (111647);

UPDATE cities SET population = CASE id WHEN 118234 THEN 9298 ELSE population END WHERE id IN (118234);

UPDATE cities SET population = CASE id WHEN 111369 THEN 9293 ELSE population END WHERE id IN (111369);

UPDATE cities SET population = CASE id WHEN 116356 THEN 9280 ELSE population END WHERE id IN (116356);

UPDATE cities SET population = CASE id WHEN 128100 THEN 9277 ELSE population END WHERE id IN (128100);

UPDATE cities SET population = CASE id WHEN 124381 THEN 9273 ELSE population END WHERE id IN (124381);

UPDATE cities SET population = CASE id WHEN 112850 THEN 9239 ELSE population END WHERE id IN (112850);

UPDATE cities SET population = CASE id WHEN 126528 THEN 9233 ELSE population END WHERE id IN (126528);

UPDATE cities SET population = CASE id WHEN 121176 THEN 9232 ELSE population END WHERE id IN (121176);

UPDATE cities SET population = CASE id WHEN 118897 THEN 9227 ELSE population END WHERE id IN (118897);

UPDATE cities SET population = CASE id WHEN 127312 THEN 9215 ELSE population END WHERE id IN (127312);

UPDATE cities SET population = CASE id WHEN 117056 THEN 9209 ELSE population END WHERE id IN (117056);

UPDATE cities SET population = CASE id WHEN 111209 THEN 9193 ELSE population END WHERE id IN (111209);

UPDATE cities SET population = CASE id WHEN 117378 THEN 9192 ELSE population END WHERE id IN (117378);

UPDATE cities SET population = CASE id WHEN 113659 THEN 9190 ELSE population END WHERE id IN (113659);

UPDATE cities SET population = CASE id WHEN 125195 THEN 9174 ELSE population END WHERE id IN (125195);

UPDATE cities SET population = CASE id WHEN 120209 THEN 9166 ELSE population END WHERE id IN (120209);

UPDATE cities SET population = CASE id WHEN 112393 THEN 9163 ELSE population END WHERE id IN (112393);

UPDATE cities SET population = CASE id WHEN 128209 THEN 9146 ELSE population END WHERE id IN (128209);

UPDATE cities SET population = CASE id WHEN 141467 THEN 9126 ELSE population END WHERE id IN (141467);

UPDATE cities SET population = CASE id WHEN 126140 THEN 9108 ELSE population END WHERE id IN (126140);

UPDATE cities SET population = CASE id WHEN 116644 THEN 9106 ELSE population END WHERE id IN (116644);

UPDATE cities SET population = CASE id WHEN 121209 THEN 9100 ELSE population END WHERE id IN (121209);

UPDATE cities SET population = CASE id WHEN 112177 THEN 9074 ELSE population END WHERE id IN (112177);

UPDATE cities SET population = CASE id WHEN 111604 THEN 9064 ELSE population END WHERE id IN (111604);

UPDATE cities SET population = CASE id WHEN 111309 THEN 9063 ELSE population END WHERE id IN (111309);

UPDATE cities SET population = CASE id WHEN 117159 THEN 9062 ELSE population END WHERE id IN (117159);

UPDATE cities SET population = CASE id WHEN 141706 THEN 9058 ELSE population END WHERE id IN (141706);

UPDATE cities SET population = CASE id WHEN 113779 THEN 9054 ELSE population END WHERE id IN (113779);

UPDATE cities SET population = CASE id WHEN 123307 THEN 9047 ELSE population END WHERE id IN (123307);

UPDATE cities SET population = CASE id WHEN 115965 THEN 9039 WHEN 120465 THEN 9039 ELSE population END WHERE id IN (115965,120465);

UPDATE cities SET population = CASE id WHEN 116263 THEN 9038 ELSE population END WHERE id IN (116263);

UPDATE cities SET population = CASE id WHEN 114738 THEN 9036 ELSE population END WHERE id IN (114738);

UPDATE cities SET population = CASE id WHEN 115852 THEN 9023 ELSE population END WHERE id IN (115852);

UPDATE cities SET population = CASE id WHEN 117314 THEN 8996 ELSE population END WHERE id IN (117314);

UPDATE cities SET population = CASE id WHEN 113800 THEN 8993 ELSE population END WHERE id IN (113800);

UPDATE cities SET population = CASE id WHEN 115098 THEN 8964 ELSE population END WHERE id IN (115098);

UPDATE cities SET population = CASE id WHEN 121801 THEN 8962 ELSE population END WHERE id IN (121801);

UPDATE cities SET population = CASE id WHEN 120081 THEN 8956 WHEN 120090 THEN 8956 ELSE population END WHERE id IN (120081,120090);

UPDATE cities SET population = CASE id WHEN 117278 THEN 8945 ELSE population END WHERE id IN (117278);

UPDATE cities SET population = CASE id WHEN 124684 THEN 8939 ELSE population END WHERE id IN (124684);

UPDATE cities SET population = CASE id WHEN 122794 THEN 8922 ELSE population END WHERE id IN (122794);

UPDATE cities SET population = CASE id WHEN 123852 THEN 8919 ELSE population END WHERE id IN (123852);

UPDATE cities SET population = CASE id WHEN 124403 THEN 8905 ELSE population END WHERE id IN (124403);

UPDATE cities SET population = CASE id WHEN 114271 THEN 8899 ELSE population END WHERE id IN (114271);

UPDATE cities SET population = CASE id WHEN 111952 THEN 8896 ELSE population END WHERE id IN (111952);

UPDATE cities SET population = CASE id WHEN 114524 THEN 8892 ELSE population END WHERE id IN (114524);

UPDATE cities SET population = CASE id WHEN 118048 THEN 8891 ELSE population END WHERE id IN (118048);

UPDATE cities SET population = CASE id WHEN 124734 THEN 8890 ELSE population END WHERE id IN (124734);

UPDATE cities SET population = CASE id WHEN 123248 THEN 8879 ELSE population END WHERE id IN (123248);

UPDATE cities SET population = CASE id WHEN 122523 THEN 8875 ELSE population END WHERE id IN (122523);

UPDATE cities SET population = CASE id WHEN 117435 THEN 8865 ELSE population END WHERE id IN (117435);

UPDATE cities SET population = CASE id WHEN 114540 THEN 8857 ELSE population END WHERE id IN (114540);

UPDATE cities SET population = CASE id WHEN 122804 THEN 8843 ELSE population END WHERE id IN (122804);

UPDATE cities SET population = CASE id WHEN 121856 THEN 8835 WHEN 125206 THEN 8835 ELSE population END WHERE id IN (121856,125206);

UPDATE cities SET population = CASE id WHEN 122655 THEN 8830 ELSE population END WHERE id IN (122655);

UPDATE cities SET population = CASE id WHEN 128609 THEN 8824 ELSE population END WHERE id IN (128609);

UPDATE cities SET population = CASE id WHEN 121450 THEN 8819 ELSE population END WHERE id IN (121450);

UPDATE cities SET population = CASE id WHEN 112564 THEN 8816 ELSE population END WHERE id IN (112564);

UPDATE cities SET population = CASE id WHEN 114311 THEN 8811 ELSE population END WHERE id IN (114311);

UPDATE cities SET population = CASE id WHEN 119040 THEN 8798 ELSE population END WHERE id IN (119040);

UPDATE cities SET population = CASE id WHEN 115858 THEN 8769 ELSE population END WHERE id IN (115858);

UPDATE cities SET population = CASE id WHEN 114273 THEN 8767 ELSE population END WHERE id IN (114273);

UPDATE cities SET population = CASE id WHEN 111323 THEN 8762 ELSE population END WHERE id IN (111323);

UPDATE cities SET population = CASE id WHEN 111842 THEN 8746 ELSE population END WHERE id IN (111842);

UPDATE cities SET population = CASE id WHEN 123679 THEN 8742 ELSE population END WHERE id IN (123679);

UPDATE cities SET population = CASE id WHEN 129102 THEN 8726 ELSE population END WHERE id IN (129102);

UPDATE cities SET population = CASE id WHEN 114674 THEN 8715 ELSE population END WHERE id IN (114674);

UPDATE cities SET population = CASE id WHEN 121921 THEN 8697 ELSE population END WHERE id IN (121921);

UPDATE cities SET population = CASE id WHEN 116411 THEN 8688 ELSE population END WHERE id IN (116411);

UPDATE cities SET population = CASE id WHEN 124977 THEN 8685 ELSE population END WHERE id IN (124977);

UPDATE cities SET population = CASE id WHEN 126080 THEN 8679 ELSE population END WHERE id IN (126080);

UPDATE cities SET population = CASE id WHEN 128222 THEN 8676 ELSE population END WHERE id IN (128222);

UPDATE cities SET population = CASE id WHEN 125197 THEN 8666 ELSE population END WHERE id IN (125197);

UPDATE cities SET population = CASE id WHEN 117695 THEN 8658 ELSE population END WHERE id IN (117695);

UPDATE cities SET population = CASE id WHEN 129084 THEN 8653 ELSE population END WHERE id IN (129084);

UPDATE cities SET population = CASE id WHEN 117925 THEN 8650 ELSE population END WHERE id IN (117925);

UPDATE cities SET population = CASE id WHEN 116586 THEN 8649 ELSE population END WHERE id IN (116586);

UPDATE cities SET population = CASE id WHEN 114277 THEN 8637 WHEN 122096 THEN 8637 ELSE population END WHERE id IN (114277,122096);

UPDATE cities SET population = CASE id WHEN 117972 THEN 8636 ELSE population END WHERE id IN (117972);

UPDATE cities SET population = CASE id WHEN 113076 THEN 8633 ELSE population END WHERE id IN (113076);

UPDATE cities SET population = CASE id WHEN 122062 THEN 8632 ELSE population END WHERE id IN (122062);

UPDATE cities SET population = CASE id WHEN 124681 THEN 8626 ELSE population END WHERE id IN (124681);

UPDATE cities SET population = CASE id WHEN 122286 THEN 8605 ELSE population END WHERE id IN (122286);

UPDATE cities SET population = CASE id WHEN 141555 THEN 8595 ELSE population END WHERE id IN (141555);

UPDATE cities SET population = CASE id WHEN 113882 THEN 8588 ELSE population END WHERE id IN (113882);

UPDATE cities SET population = CASE id WHEN 128287 THEN 8587 ELSE population END WHERE id IN (128287);

UPDATE cities SET population = CASE id WHEN 113389 THEN 8566 ELSE population END WHERE id IN (113389);

UPDATE cities SET population = CASE id WHEN 141591 THEN 8547 ELSE population END WHERE id IN (141591);

UPDATE cities SET population = CASE id WHEN 129355 THEN 8539 ELSE population END WHERE id IN (129355);

UPDATE cities SET population = CASE id WHEN 116071 THEN 8536 ELSE population END WHERE id IN (116071);

UPDATE cities SET population = CASE id WHEN 120640 THEN 8531 ELSE population END WHERE id IN (120640);

UPDATE cities SET population = CASE id WHEN 112666 THEN 8507 ELSE population END WHERE id IN (112666);

UPDATE cities SET population = CASE id WHEN 124408 THEN 8505 ELSE population END WHERE id IN (124408);

UPDATE cities SET population = CASE id WHEN 119174 THEN 8504 ELSE population END WHERE id IN (119174);

UPDATE cities SET population = CASE id WHEN 114201 THEN 8493 ELSE population END WHERE id IN (114201);

UPDATE cities SET population = CASE id WHEN 116831 THEN 8490 ELSE population END WHERE id IN (116831);

UPDATE cities SET population = CASE id WHEN 141600 THEN 8487 ELSE population END WHERE id IN (141600);

UPDATE cities SET population = CASE id WHEN 125103 THEN 8481 ELSE population END WHERE id IN (125103);

UPDATE cities SET population = CASE id WHEN 129505 THEN 8480 ELSE population END WHERE id IN (129505);

UPDATE cities SET population = CASE id WHEN 117372 THEN 8473 ELSE population END WHERE id IN (117372);

UPDATE cities SET population = CASE id WHEN 119481 THEN 8459 ELSE population END WHERE id IN (119481);

UPDATE cities SET population = CASE id WHEN 116079 THEN 8455 ELSE population END WHERE id IN (116079);

UPDATE cities SET population = CASE id WHEN 113253 THEN 8451 ELSE population END WHERE id IN (113253);

UPDATE cities SET population = CASE id WHEN 116837 THEN 8450 ELSE population END WHERE id IN (116837);

UPDATE cities SET population = CASE id WHEN 117690 THEN 8444 ELSE population END WHERE id IN (117690);

UPDATE cities SET population = CASE id WHEN 123239 THEN 8439 ELSE population END WHERE id IN (123239);

UPDATE cities SET population = CASE id WHEN 141180 THEN 8436 ELSE population END WHERE id IN (141180);

UPDATE cities SET population = CASE id WHEN 111640 THEN 8433 WHEN 122378 THEN 8433 ELSE population END WHERE id IN (111640,122378);

UPDATE cities SET population = CASE id WHEN 123830 THEN 8432 ELSE population END WHERE id IN (123830);

UPDATE cities SET population = CASE id WHEN 124262 THEN 8429 ELSE population END WHERE id IN (124262);

UPDATE cities SET population = CASE id WHEN 121373 THEN 8427 ELSE population END WHERE id IN (121373);

UPDATE cities SET population = CASE id WHEN 113773 THEN 8421 ELSE population END WHERE id IN (113773);

UPDATE cities SET population = CASE id WHEN 121889 THEN 8420 ELSE population END WHERE id IN (121889);

UPDATE cities SET population = CASE id WHEN 111847 THEN 8417 ELSE population END WHERE id IN (111847);

UPDATE cities SET population = CASE id WHEN 125204 THEN 8416 ELSE population END WHERE id IN (125204);

UPDATE cities SET population = CASE id WHEN 141846 THEN 8411 ELSE population END WHERE id IN (141846);

UPDATE cities SET population = CASE id WHEN 112568 THEN 8403 ELSE population END WHERE id IN (112568);

UPDATE cities SET population = CASE id WHEN 112032 THEN 8402 ELSE population END WHERE id IN (112032);

UPDATE cities SET population = CASE id WHEN 124089 THEN 8398 ELSE population END WHERE id IN (124089);

UPDATE cities SET population = CASE id WHEN 141392 THEN 8396 ELSE population END WHERE id IN (141392);

UPDATE cities SET population = CASE id WHEN 115201 THEN 8389 ELSE population END WHERE id IN (115201);

UPDATE cities SET population = CASE id WHEN 127479 THEN 8372 ELSE population END WHERE id IN (127479);

UPDATE cities SET population = CASE id WHEN 117356 THEN 8370 ELSE population END WHERE id IN (117356);

UPDATE cities SET population = CASE id WHEN 125673 THEN 8365 ELSE population END WHERE id IN (125673);

UPDATE cities SET population = CASE id WHEN 126519 THEN 8364 ELSE population END WHERE id IN (126519);

UPDATE cities SET population = CASE id WHEN 112760 THEN 8359 ELSE population END WHERE id IN (112760);

UPDATE cities SET population = CASE id WHEN 128810 THEN 8355 ELSE population END WHERE id IN (128810);

UPDATE cities SET population = CASE id WHEN 141608 THEN 8350 ELSE population END WHERE id IN (141608);

UPDATE cities SET population = CASE id WHEN 127715 THEN 8343 ELSE population END WHERE id IN (127715);

UPDATE cities SET population = CASE id WHEN 115238 THEN 8334 ELSE population END WHERE id IN (115238);

UPDATE cities SET population = CASE id WHEN 141686 THEN 8332 ELSE population END WHERE id IN (141686);

UPDATE cities SET population = CASE id WHEN 116349 THEN 8331 ELSE population END WHERE id IN (116349);

UPDATE cities SET population = CASE id WHEN 116625 THEN 8323 ELSE population END WHERE id IN (116625);

UPDATE cities SET population = CASE id WHEN 118449 THEN 8321 ELSE population END WHERE id IN (118449);

UPDATE cities SET population = CASE id WHEN 129298 THEN 8314 ELSE population END WHERE id IN (129298);

UPDATE cities SET population = CASE id WHEN 118776 THEN 8313 ELSE population END WHERE id IN (118776);

UPDATE cities SET population = CASE id WHEN 120607 THEN 8307 ELSE population END WHERE id IN (120607);

UPDATE cities SET population = CASE id WHEN 111897 THEN 8305 ELSE population END WHERE id IN (111897);

UPDATE cities SET population = CASE id WHEN 111531 THEN 8302 ELSE population END WHERE id IN (111531);

UPDATE cities SET population = CASE id WHEN 121443 THEN 8298 ELSE population END WHERE id IN (121443);

UPDATE cities SET population = CASE id WHEN 118499 THEN 8283 ELSE population END WHERE id IN (118499);

UPDATE cities SET population = CASE id WHEN 112417 THEN 8280 ELSE population END WHERE id IN (112417);

UPDATE cities SET population = CASE id WHEN 126156 THEN 8279 ELSE population END WHERE id IN (126156);

UPDATE cities SET population = CASE id WHEN 120432 THEN 8271 ELSE population END WHERE id IN (120432);

UPDATE cities SET population = CASE id WHEN 118658 THEN 8261 ELSE population END WHERE id IN (118658);

UPDATE cities SET population = CASE id WHEN 112114 THEN 8252 WHEN 124374 THEN 8252 ELSE population END WHERE id IN (112114,124374);

UPDATE cities SET population = CASE id WHEN 111884 THEN 8231 WHEN 128281 THEN 8231 ELSE population END WHERE id IN (111884,128281);

UPDATE cities SET population = CASE id WHEN 111126 THEN 8229 ELSE population END WHERE id IN (111126);

UPDATE cities SET population = CASE id WHEN 112506 THEN 8219 ELSE population END WHERE id IN (112506);

UPDATE cities SET population = CASE id WHEN 141289 THEN 8217 ELSE population END WHERE id IN (141289);

UPDATE cities SET population = CASE id WHEN 119457 THEN 8215 ELSE population END WHERE id IN (119457);

UPDATE cities SET population = CASE id WHEN 141423 THEN 8211 ELSE population END WHERE id IN (141423);

UPDATE cities SET population = CASE id WHEN 120504 THEN 8197 ELSE population END WHERE id IN (120504);

UPDATE cities SET population = CASE id WHEN 115218 THEN 8195 ELSE population END WHERE id IN (115218);

UPDATE cities SET population = CASE id WHEN 117756 THEN 8193 ELSE population END WHERE id IN (117756);

UPDATE cities SET population = CASE id WHEN 125163 THEN 8176 ELSE population END WHERE id IN (125163);

UPDATE cities SET population = CASE id WHEN 117138 THEN 8173 ELSE population END WHERE id IN (117138);

UPDATE cities SET population = CASE id WHEN 120188 THEN 8171 ELSE population END WHERE id IN (120188);

UPDATE cities SET population = CASE id WHEN 116427 THEN 8169 ELSE population END WHERE id IN (116427);

UPDATE cities SET population = CASE id WHEN 122052 THEN 8164 ELSE population END WHERE id IN (122052);

UPDATE cities SET population = CASE id WHEN 118460 THEN 8163 ELSE population END WHERE id IN (118460);

UPDATE cities SET population = CASE id WHEN 123245 THEN 8140 ELSE population END WHERE id IN (123245);

UPDATE cities SET population = CASE id WHEN 113132 THEN 8136 ELSE population END WHERE id IN (113132);

UPDATE cities SET population = CASE id WHEN 123840 THEN 8128 ELSE population END WHERE id IN (123840);

UPDATE cities SET population = CASE id WHEN 120721 THEN 8126 ELSE population END WHERE id IN (120721);

UPDATE cities SET population = CASE id WHEN 128505 THEN 8106 ELSE population END WHERE id IN (128505);

UPDATE cities SET population = CASE id WHEN 124070 THEN 8089 ELSE population END WHERE id IN (124070);

UPDATE cities SET population = CASE id WHEN 112858 THEN 8078 ELSE population END WHERE id IN (112858);

UPDATE cities SET population = CASE id WHEN 122177 THEN 8074 ELSE population END WHERE id IN (122177);

UPDATE cities SET population = CASE id WHEN 123149 THEN 8070 ELSE population END WHERE id IN (123149);

UPDATE cities SET population = CASE id WHEN 112590 THEN 8049 ELSE population END WHERE id IN (112590);

UPDATE cities SET population = CASE id WHEN 116156 THEN 8047 ELSE population END WHERE id IN (116156);

UPDATE cities SET population = CASE id WHEN 128877 THEN 8046 ELSE population END WHERE id IN (128877);

UPDATE cities SET population = CASE id WHEN 127974 THEN 8045 ELSE population END WHERE id IN (127974);

UPDATE cities SET population = CASE id WHEN 111539 THEN 8040 ELSE population END WHERE id IN (111539);

UPDATE cities SET population = CASE id WHEN 112062 THEN 8029 WHEN 126620 THEN 8029 ELSE population END WHERE id IN (112062,126620);

UPDATE cities SET population = CASE id WHEN 129691 THEN 8009 ELSE population END WHERE id IN (129691);

UPDATE cities SET population = CASE id WHEN 141144 THEN 8005 ELSE population END WHERE id IN (141144);

UPDATE cities SET population = CASE id WHEN 128777 THEN 7987 ELSE population END WHERE id IN (128777);

UPDATE cities SET population = CASE id WHEN 127215 THEN 7985 ELSE population END WHERE id IN (127215);

UPDATE cities SET population = CASE id WHEN 141192 THEN 7982 ELSE population END WHERE id IN (141192);

UPDATE cities SET population = CASE id WHEN 122867 THEN 7979 ELSE population END WHERE id IN (122867);

UPDATE cities SET population = CASE id WHEN 129131 THEN 7975 ELSE population END WHERE id IN (129131);

UPDATE cities SET population = CASE id WHEN 123272 THEN 7974 ELSE population END WHERE id IN (123272);

UPDATE cities SET population = CASE id WHEN 113181 THEN 7948 ELSE population END WHERE id IN (113181);

UPDATE cities SET population = CASE id WHEN 112756 THEN 7941 WHEN 119171 THEN 7941 ELSE population END WHERE id IN (112756,119171);

UPDATE cities SET population = CASE id WHEN 123236 THEN 7937 ELSE population END WHERE id IN (123236);

UPDATE cities SET population = CASE id WHEN 111916 THEN 7934 ELSE population END WHERE id IN (111916);

UPDATE cities SET population = CASE id WHEN 113426 THEN 7931 ELSE population END WHERE id IN (113426);

UPDATE cities SET population = CASE id WHEN 128404 THEN 7922 ELSE population END WHERE id IN (128404);

UPDATE cities SET population = CASE id WHEN 121787 THEN 7874 ELSE population END WHERE id IN (121787);

UPDATE cities SET population = CASE id WHEN 125665 THEN 7865 ELSE population END WHERE id IN (125665);

UPDATE cities SET population = CASE id WHEN 129693 THEN 7864 ELSE population END WHERE id IN (129693);

UPDATE cities SET population = CASE id WHEN 121236 THEN 7861 ELSE population END WHERE id IN (121236);

UPDATE cities SET population = CASE id WHEN 114246 THEN 7858 ELSE population END WHERE id IN (114246);

UPDATE cities SET population = CASE id WHEN 116038 THEN 7857 ELSE population END WHERE id IN (116038);

UPDATE cities SET population = CASE id WHEN 112775 THEN 7841 ELSE population END WHERE id IN (112775);

UPDATE cities SET population = CASE id WHEN 120444 THEN 7822 ELSE population END WHERE id IN (120444);

UPDATE cities SET population = CASE id WHEN 124335 THEN 7817 ELSE population END WHERE id IN (124335);

UPDATE cities SET population = CASE id WHEN 121836 THEN 7813 WHEN 129637 THEN 7813 ELSE population END WHERE id IN (121836,129637);

UPDATE cities SET population = CASE id WHEN 128778 THEN 7807 ELSE population END WHERE id IN (128778);

UPDATE cities SET population = CASE id WHEN 129332 THEN 7781 ELSE population END WHERE id IN (129332);

UPDATE cities SET population = CASE id WHEN 129150 THEN 7775 ELSE population END WHERE id IN (129150);

UPDATE cities SET population = CASE id WHEN 118055 THEN 7769 ELSE population END WHERE id IN (118055);

UPDATE cities SET population = CASE id WHEN 122839 THEN 7767 ELSE population END WHERE id IN (122839);

UPDATE cities SET population = CASE id WHEN 127618 THEN 7752 ELSE population END WHERE id IN (127618);

UPDATE cities SET population = CASE id WHEN 112448 THEN 7714 ELSE population END WHERE id IN (112448);

UPDATE cities SET population = CASE id WHEN 118548 THEN 7711 ELSE population END WHERE id IN (118548);

UPDATE cities SET population = CASE id WHEN 113110 THEN 7701 ELSE population END WHERE id IN (113110);

UPDATE cities SET population = CASE id WHEN 116094 THEN 7697 ELSE population END WHERE id IN (116094);

UPDATE cities SET population = CASE id WHEN 115262 THEN 7685 ELSE population END WHERE id IN (115262);

UPDATE cities SET population = CASE id WHEN 127505 THEN 7674 ELSE population END WHERE id IN (127505);

UPDATE cities SET population = CASE id WHEN 115520 THEN 7659 ELSE population END WHERE id IN (115520);

UPDATE cities SET population = CASE id WHEN 124304 THEN 7651 ELSE population END WHERE id IN (124304);

UPDATE cities SET population = CASE id WHEN 141404 THEN 7650 ELSE population END WHERE id IN (141404);

UPDATE cities SET population = CASE id WHEN 117861 THEN 7631 ELSE population END WHERE id IN (117861);

UPDATE cities SET population = CASE id WHEN 116306 THEN 7626 ELSE population END WHERE id IN (116306);

UPDATE cities SET population = CASE id WHEN 115786 THEN 7625 ELSE population END WHERE id IN (115786);

UPDATE cities SET population = CASE id WHEN 119144 THEN 7619 ELSE population END WHERE id IN (119144);

UPDATE cities SET population = CASE id WHEN 116264 THEN 7616 ELSE population END WHERE id IN (116264);

UPDATE cities SET population = CASE id WHEN 126371 THEN 7614 ELSE population END WHERE id IN (126371);

UPDATE cities SET population = CASE id WHEN 118563 THEN 7610 ELSE population END WHERE id IN (118563);

UPDATE cities SET population = CASE id WHEN 112789 THEN 7609 ELSE population END WHERE id IN (112789);

UPDATE cities SET population = CASE id WHEN 111001 THEN 7596 ELSE population END WHERE id IN (111001);

UPDATE cities SET population = CASE id WHEN 124686 THEN 7594 ELSE population END WHERE id IN (124686);

UPDATE cities SET population = CASE id WHEN 125063 THEN 7592 ELSE population END WHERE id IN (125063);

UPDATE cities SET population = CASE id WHEN 112235 THEN 7590 ELSE population END WHERE id IN (112235);

UPDATE cities SET population = CASE id WHEN 118956 THEN 7583 ELSE population END WHERE id IN (118956);

UPDATE cities SET population = CASE id WHEN 115093 THEN 7575 ELSE population END WHERE id IN (115093);

UPDATE cities SET population = CASE id WHEN 118440 THEN 7558 ELSE population END WHERE id IN (118440);

UPDATE cities SET population = CASE id WHEN 120060 THEN 7555 ELSE population END WHERE id IN (120060);

UPDATE cities SET population = CASE id WHEN 123559 THEN 7550 ELSE population END WHERE id IN (123559);

UPDATE cities SET population = CASE id WHEN 114654 THEN 7548 ELSE population END WHERE id IN (114654);

UPDATE cities SET population = CASE id WHEN 117371 THEN 7544 ELSE population END WHERE id IN (117371);

UPDATE cities SET population = CASE id WHEN 126145 THEN 7522 ELSE population END WHERE id IN (126145);

UPDATE cities SET population = CASE id WHEN 120083 THEN 7509 ELSE population END WHERE id IN (120083);

UPDATE cities SET population = CASE id WHEN 111532 THEN 7503 WHEN 121202 THEN 7503 ELSE population END WHERE id IN (111532,121202);

UPDATE cities SET population = CASE id WHEN 114876 THEN 7496 ELSE population END WHERE id IN (114876);

UPDATE cities SET population = CASE id WHEN 124402 THEN 7494 ELSE population END WHERE id IN (124402);

UPDATE cities SET population = CASE id WHEN 123285 THEN 7488 ELSE population END WHERE id IN (123285);

UPDATE cities SET population = CASE id WHEN 111657 THEN 7477 ELSE population END WHERE id IN (111657);

UPDATE cities SET population = CASE id WHEN 125739 THEN 7475 ELSE population END WHERE id IN (125739);

UPDATE cities SET population = CASE id WHEN 125323 THEN 7474 ELSE population END WHERE id IN (125323);

UPDATE cities SET population = CASE id WHEN 124007 THEN 7461 ELSE population END WHERE id IN (124007);

UPDATE cities SET population = CASE id WHEN 123777 THEN 7451 ELSE population END WHERE id IN (123777);

UPDATE cities SET population = CASE id WHEN 126146 THEN 7448 ELSE population END WHERE id IN (126146);

UPDATE cities SET population = CASE id WHEN 118995 THEN 7446 ELSE population END WHERE id IN (118995);

UPDATE cities SET population = CASE id WHEN 121792 THEN 7441 ELSE population END WHERE id IN (121792);

UPDATE cities SET population = CASE id WHEN 141308 THEN 7413 ELSE population END WHERE id IN (141308);

UPDATE cities SET population = CASE id WHEN 128542 THEN 7408 ELSE population END WHERE id IN (128542);

UPDATE cities SET population = CASE id WHEN 121114 THEN 7400 WHEN 125227 THEN 7400 ELSE population END WHERE id IN (121114,125227);

UPDATE cities SET population = CASE id WHEN 123839 THEN 7392 ELSE population END WHERE id IN (123839);

UPDATE cities SET population = CASE id WHEN 123162 THEN 7390 ELSE population END WHERE id IN (123162);

UPDATE cities SET population = CASE id WHEN 114280 THEN 7389 ELSE population END WHERE id IN (114280);

UPDATE cities SET population = CASE id WHEN 111894 THEN 7385 ELSE population END WHERE id IN (111894);

UPDATE cities SET population = CASE id WHEN 115092 THEN 7384 WHEN 127028 THEN 7384 ELSE population END WHERE id IN (115092,127028);

UPDATE cities SET population = CASE id WHEN 117927 THEN 7372 ELSE population END WHERE id IN (117927);

UPDATE cities SET population = CASE id WHEN 124800 THEN 7365 ELSE population END WHERE id IN (124800);

UPDATE cities SET population = CASE id WHEN 111121 THEN 7345 ELSE population END WHERE id IN (111121);

UPDATE cities SET population = CASE id WHEN 110975 THEN 7343 ELSE population END WHERE id IN (110975);

UPDATE cities SET population = CASE id WHEN 118743 THEN 7336 ELSE population END WHERE id IN (118743);

UPDATE cities SET population = CASE id WHEN 114438 THEN 7335 ELSE population END WHERE id IN (114438);

UPDATE cities SET population = CASE id WHEN 111249 THEN 7321 ELSE population END WHERE id IN (111249);

UPDATE cities SET population = CASE id WHEN 129525 THEN 7319 ELSE population END WHERE id IN (129525);

UPDATE cities SET population = CASE id WHEN 117777 THEN 7318 ELSE population END WHERE id IN (117777);

UPDATE cities SET population = CASE id WHEN 114150 THEN 7317 WHEN 129537 THEN 7317 ELSE population END WHERE id IN (114150,129537);

UPDATE cities SET population = CASE id WHEN 112440 THEN 7314 WHEN 123775 THEN 7314 ELSE population END WHERE id IN (112440,123775);

UPDATE cities SET population = CASE id WHEN 116827 THEN 7302 WHEN 118061 THEN 7302 WHEN 120653 THEN 7302 ELSE population END WHERE id IN (116827,118061,120653);

UPDATE cities SET population = CASE id WHEN 125728 THEN 7287 ELSE population END WHERE id IN (125728);

UPDATE cities SET population = CASE id WHEN 116647 THEN 7282 ELSE population END WHERE id IN (116647);

UPDATE cities SET population = CASE id WHEN 121553 THEN 7275 ELSE population END WHERE id IN (121553);

UPDATE cities SET population = CASE id WHEN 120447 THEN 7262 ELSE population END WHERE id IN (120447);

UPDATE cities SET population = CASE id WHEN 121000 THEN 7258 ELSE population END WHERE id IN (121000);

UPDATE cities SET population = CASE id WHEN 119695 THEN 7248 ELSE population END WHERE id IN (119695);

UPDATE cities SET population = CASE id WHEN 126785 THEN 7238 ELSE population END WHERE id IN (126785);

UPDATE cities SET population = CASE id WHEN 118955 THEN 7233 ELSE population END WHERE id IN (118955);

UPDATE cities SET population = CASE id WHEN 116006 THEN 7226 ELSE population END WHERE id IN (116006);

UPDATE cities SET population = CASE id WHEN 129533 THEN 7222 ELSE population END WHERE id IN (129533);

UPDATE cities SET population = CASE id WHEN 122391 THEN 7208 WHEN 122394 THEN 7208 ELSE population END WHERE id IN (122391,122394);

UPDATE cities SET population = CASE id WHEN 118358 THEN 7199 ELSE population END WHERE id IN (118358);

UPDATE cities SET population = CASE id WHEN 124388 THEN 7173 ELSE population END WHERE id IN (124388);

UPDATE cities SET population = CASE id WHEN 122745 THEN 7172 ELSE population END WHERE id IN (122745);

UPDATE cities SET population = CASE id WHEN 115421 THEN 7168 ELSE population END WHERE id IN (115421);

UPDATE cities SET population = CASE id WHEN 124252 THEN 7152 ELSE population END WHERE id IN (124252);

UPDATE cities SET population = CASE id WHEN 127183 THEN 7135 WHEN 141411 THEN 7135 ELSE population END WHERE id IN (127183,141411);

UPDATE cities SET population = CASE id WHEN 123883 THEN 7126 ELSE population END WHERE id IN (123883);

UPDATE cities SET population = CASE id WHEN 124717 THEN 7124 ELSE population END WHERE id IN (124717);

UPDATE cities SET population = CASE id WHEN 123707 THEN 7123 ELSE population END WHERE id IN (123707);

UPDATE cities SET population = CASE id WHEN 116457 THEN 7121 ELSE population END WHERE id IN (116457);

UPDATE cities SET population = CASE id WHEN 124167 THEN 7118 ELSE population END WHERE id IN (124167);

UPDATE cities SET population = CASE id WHEN 141459 THEN 7117 ELSE population END WHERE id IN (141459);

UPDATE cities SET population = CASE id WHEN 117693 THEN 7116 ELSE population END WHERE id IN (117693);

UPDATE cities SET population = CASE id WHEN 125069 THEN 7087 ELSE population END WHERE id IN (125069);

UPDATE cities SET population = CASE id WHEN 113264 THEN 7085 ELSE population END WHERE id IN (113264);

UPDATE cities SET population = CASE id WHEN 128035 THEN 7070 ELSE population END WHERE id IN (128035);

UPDATE cities SET population = CASE id WHEN 115097 THEN 7063 WHEN 116315 THEN 7063 ELSE population END WHERE id IN (115097,116315);

UPDATE cities SET population = CASE id WHEN 125544 THEN 7056 ELSE population END WHERE id IN (125544);

UPDATE cities SET population = CASE id WHEN 123326 THEN 7055 ELSE population END WHERE id IN (123326);

UPDATE cities SET population = CASE id WHEN 114279 THEN 7048 WHEN 123992 THEN 7048 ELSE population END WHERE id IN (114279,123992);

UPDATE cities SET population = CASE id WHEN 121307 THEN 7045 ELSE population END WHERE id IN (121307);

UPDATE cities SET population = CASE id WHEN 112193 THEN 7041 ELSE population END WHERE id IN (112193);

UPDATE cities SET population = CASE id WHEN 114815 THEN 7037 ELSE population END WHERE id IN (114815);

UPDATE cities SET population = CASE id WHEN 129445 THEN 7034 ELSE population END WHERE id IN (129445);

UPDATE cities SET population = CASE id WHEN 118796 THEN 7029 ELSE population END WHERE id IN (118796);

UPDATE cities SET population = CASE id WHEN 129046 THEN 7028 ELSE population END WHERE id IN (129046);

UPDATE cities SET population = CASE id WHEN 125976 THEN 7027 ELSE population END WHERE id IN (125976);

UPDATE cities SET population = CASE id WHEN 141409 THEN 7022 ELSE population END WHERE id IN (141409);

UPDATE cities SET population = CASE id WHEN 115002 THEN 7012 ELSE population END WHERE id IN (115002);

UPDATE cities SET population = CASE id WHEN 127962 THEN 7009 ELSE population END WHERE id IN (127962);

UPDATE cities SET population = CASE id WHEN 119498 THEN 7000 ELSE population END WHERE id IN (119498);

UPDATE cities SET population = CASE id WHEN 141424 THEN 6981 ELSE population END WHERE id IN (141424);

UPDATE cities SET population = CASE id WHEN 125392 THEN 6980 ELSE population END WHERE id IN (125392);

UPDATE cities SET population = CASE id WHEN 119629 THEN 6974 ELSE population END WHERE id IN (119629);

UPDATE cities SET population = CASE id WHEN 123196 THEN 6968 ELSE population END WHERE id IN (123196);

UPDATE cities SET population = CASE id WHEN 112762 THEN 6950 ELSE population END WHERE id IN (112762);

UPDATE cities SET population = CASE id WHEN 120193 THEN 6943 ELSE population END WHERE id IN (120193);

UPDATE cities SET population = CASE id WHEN 126398 THEN 6942 ELSE population END WHERE id IN (126398);

UPDATE cities SET population = CASE id WHEN 127518 THEN 6937 ELSE population END WHERE id IN (127518);

UPDATE cities SET population = CASE id WHEN 121917 THEN 6928 ELSE population END WHERE id IN (121917);

UPDATE cities SET population = CASE id WHEN 141241 THEN 6927 ELSE population END WHERE id IN (141241);

UPDATE cities SET population = CASE id WHEN 112090 THEN 6918 WHEN 125596 THEN 6918 ELSE population END WHERE id IN (112090,125596);

UPDATE cities SET population = CASE id WHEN 141520 THEN 6876 ELSE population END WHERE id IN (141520);

UPDATE cities SET population = CASE id WHEN 120130 THEN 6874 ELSE population END WHERE id IN (120130);

UPDATE cities SET population = CASE id WHEN 119072 THEN 6859 ELSE population END WHERE id IN (119072);

UPDATE cities SET population = CASE id WHEN 120197 THEN 6855 ELSE population END WHERE id IN (120197);

UPDATE cities SET population = CASE id WHEN 114692 THEN 6854 ELSE population END WHERE id IN (114692);

UPDATE cities SET population = CASE id WHEN 113495 THEN 6844 ELSE population END WHERE id IN (113495);

UPDATE cities SET population = CASE id WHEN 125905 THEN 6841 ELSE population END WHERE id IN (125905);

UPDATE cities SET population = CASE id WHEN 128368 THEN 6839 ELSE population END WHERE id IN (128368);

UPDATE cities SET population = CASE id WHEN 118825 THEN 6836 ELSE population END WHERE id IN (118825);

UPDATE cities SET population = CASE id WHEN 122843 THEN 6834 ELSE population END WHERE id IN (122843);

UPDATE cities SET population = CASE id WHEN 122650 THEN 6831 ELSE population END WHERE id IN (122650);

UPDATE cities SET population = CASE id WHEN 121784 THEN 6828 WHEN 126399 THEN 6828 ELSE population END WHERE id IN (121784,126399);

UPDATE cities SET population = CASE id WHEN 111195 THEN 6822 ELSE population END WHERE id IN (111195);

UPDATE cities SET population = CASE id WHEN 113002 THEN 6816 ELSE population END WHERE id IN (113002);

UPDATE cities SET population = CASE id WHEN 141428 THEN 6793 ELSE population END WHERE id IN (141428);

UPDATE cities SET population = CASE id WHEN 123760 THEN 6788 WHEN 141373 THEN 6788 ELSE population END WHERE id IN (123760,141373);

UPDATE cities SET population = CASE id WHEN 114796 THEN 6774 ELSE population END WHERE id IN (114796);

UPDATE cities SET population = CASE id WHEN 123367 THEN 6766 ELSE population END WHERE id IN (123367);

UPDATE cities SET population = CASE id WHEN 111961 THEN 6764 ELSE population END WHERE id IN (111961);

UPDATE cities SET population = CASE id WHEN 128962 THEN 6763 ELSE population END WHERE id IN (128962);

UPDATE cities SET population = CASE id WHEN 117620 THEN 6745 ELSE population END WHERE id IN (117620);

UPDATE cities SET population = CASE id WHEN 119570 THEN 6744 ELSE population END WHERE id IN (119570);

UPDATE cities SET population = CASE id WHEN 121238 THEN 6714 ELSE population END WHERE id IN (121238);

UPDATE cities SET population = CASE id WHEN 123879 THEN 6706 ELSE population END WHERE id IN (123879);

UPDATE cities SET population = CASE id WHEN 127152 THEN 6688 ELSE population END WHERE id IN (127152);

UPDATE cities SET population = CASE id WHEN 122985 THEN 6679 ELSE population END WHERE id IN (122985);

UPDATE cities SET population = CASE id WHEN 115597 THEN 6678 ELSE population END WHERE id IN (115597);

UPDATE cities SET population = CASE id WHEN 126672 THEN 6673 ELSE population END WHERE id IN (126672);

UPDATE cities SET population = CASE id WHEN 123261 THEN 6671 ELSE population END WHERE id IN (123261);

UPDATE cities SET population = CASE id WHEN 113390 THEN 6670 ELSE population END WHERE id IN (113390);

UPDATE cities SET population = CASE id WHEN 127745 THEN 6669 WHEN 127826 THEN 6669 ELSE population END WHERE id IN (127745,127826);

UPDATE cities SET population = CASE id WHEN 128767 THEN 6668 ELSE population END WHERE id IN (128767);

UPDATE cities SET population = CASE id WHEN 117683 THEN 6666 ELSE population END WHERE id IN (117683);

UPDATE cities SET population = CASE id WHEN 120605 THEN 6657 ELSE population END WHERE id IN (120605);

UPDATE cities SET population = CASE id WHEN 123952 THEN 6650 ELSE population END WHERE id IN (123952);

UPDATE cities SET population = CASE id WHEN 127869 THEN 6643 ELSE population END WHERE id IN (127869);

UPDATE cities SET population = CASE id WHEN 113001 THEN 6618 ELSE population END WHERE id IN (113001);

UPDATE cities SET population = CASE id WHEN 129103 THEN 6613 ELSE population END WHERE id IN (129103);

UPDATE cities SET population = CASE id WHEN 111893 THEN 6611 ELSE population END WHERE id IN (111893);

UPDATE cities SET population = CASE id WHEN 113217 THEN 6608 ELSE population END WHERE id IN (113217);

UPDATE cities SET population = CASE id WHEN 119010 THEN 6607 ELSE population END WHERE id IN (119010);

UPDATE cities SET population = CASE id WHEN 127120 THEN 6586 ELSE population END WHERE id IN (127120);

UPDATE cities SET population = CASE id WHEN 125661 THEN 6584 ELSE population END WHERE id IN (125661);

UPDATE cities SET population = CASE id WHEN 113471 THEN 6583 ELSE population END WHERE id IN (113471);

UPDATE cities SET population = CASE id WHEN 117730 THEN 6582 ELSE population END WHERE id IN (117730);

UPDATE cities SET population = CASE id WHEN 119978 THEN 6571 ELSE population END WHERE id IN (119978);

UPDATE cities SET population = CASE id WHEN 113347 THEN 6570 ELSE population END WHERE id IN (113347);

UPDATE cities SET population = CASE id WHEN 112020 THEN 6561 ELSE population END WHERE id IN (112020);

UPDATE cities SET population = CASE id WHEN 120228 THEN 6559 ELSE population END WHERE id IN (120228);

UPDATE cities SET population = CASE id WHEN 141395 THEN 6557 ELSE population END WHERE id IN (141395);

UPDATE cities SET population = CASE id WHEN 118277 THEN 6552 ELSE population END WHERE id IN (118277);

UPDATE cities SET population = CASE id WHEN 128018 THEN 6547 ELSE population END WHERE id IN (128018);

UPDATE cities SET population = CASE id WHEN 126100 THEN 6540 ELSE population END WHERE id IN (126100);

UPDATE cities SET population = CASE id WHEN 125674 THEN 6534 ELSE population END WHERE id IN (125674);

UPDATE cities SET population = CASE id WHEN 115424 THEN 6531 ELSE population END WHERE id IN (115424);

UPDATE cities SET population = CASE id WHEN 125202 THEN 6523 ELSE population END WHERE id IN (125202);

UPDATE cities SET population = CASE id WHEN 115155 THEN 6521 ELSE population END WHERE id IN (115155);

UPDATE cities SET population = CASE id WHEN 113237 THEN 6510 ELSE population END WHERE id IN (113237);

UPDATE cities SET population = CASE id WHEN 111695 THEN 6505 WHEN 122169 THEN 6505 ELSE population END WHERE id IN (111695,122169);

UPDATE cities SET population = CASE id WHEN 128548 THEN 6498 ELSE population END WHERE id IN (128548);

UPDATE cities SET population = CASE id WHEN 115117 THEN 6495 ELSE population END WHERE id IN (115117);

UPDATE cities SET population = CASE id WHEN 114436 THEN 6492 ELSE population END WHERE id IN (114436);

UPDATE cities SET population = CASE id WHEN 113559 THEN 6481 ELSE population END WHERE id IN (113559);

UPDATE cities SET population = CASE id WHEN 112862 THEN 6476 ELSE population END WHERE id IN (112862);

UPDATE cities SET population = CASE id WHEN 121852 THEN 6472 ELSE population END WHERE id IN (121852);

UPDATE cities SET population = CASE id WHEN 141767 THEN 6461 ELSE population END WHERE id IN (141767);

UPDATE cities SET population = CASE id WHEN 125121 THEN 6455 ELSE population END WHERE id IN (125121);

UPDATE cities SET population = CASE id WHEN 112281 THEN 6450 ELSE population END WHERE id IN (112281);

UPDATE cities SET population = CASE id WHEN 116659 THEN 6443 ELSE population END WHERE id IN (116659);

UPDATE cities SET population = CASE id WHEN 118744 THEN 6436 ELSE population END WHERE id IN (118744);

UPDATE cities SET population = CASE id WHEN 116273 THEN 6426 ELSE population END WHERE id IN (116273);

UPDATE cities SET population = CASE id WHEN 125213 THEN 6407 ELSE population END WHERE id IN (125213);

UPDATE cities SET population = CASE id WHEN 118582 THEN 6404 ELSE population END WHERE id IN (118582);

UPDATE cities SET population = CASE id WHEN 111871 THEN 6382 ELSE population END WHERE id IN (111871);

UPDATE cities SET population = CASE id WHEN 112759 THEN 6381 ELSE population END WHERE id IN (112759);

UPDATE cities SET population = CASE id WHEN 116223 THEN 6378 ELSE population END WHERE id IN (116223);

UPDATE cities SET population = CASE id WHEN 113865 THEN 6362 ELSE population END WHERE id IN (113865);

UPDATE cities SET population = CASE id WHEN 129149 THEN 6345 ELSE population END WHERE id IN (129149);

UPDATE cities SET population = CASE id WHEN 115800 THEN 6340 ELSE population END WHERE id IN (115800);

UPDATE cities SET population = CASE id WHEN 122292 THEN 6338 ELSE population END WHERE id IN (122292);

UPDATE cities SET population = CASE id WHEN 112415 THEN 6334 ELSE population END WHERE id IN (112415);

UPDATE cities SET population = CASE id WHEN 111473 THEN 6333 ELSE population END WHERE id IN (111473);

UPDATE cities SET population = CASE id WHEN 125424 THEN 6325 ELSE population END WHERE id IN (125424);

UPDATE cities SET population = CASE id WHEN 120814 THEN 6314 ELSE population END WHERE id IN (120814);

UPDATE cities SET population = CASE id WHEN 126139 THEN 6307 ELSE population END WHERE id IN (126139);

UPDATE cities SET population = CASE id WHEN 116840 THEN 6302 ELSE population END WHERE id IN (116840);

UPDATE cities SET population = CASE id WHEN 128107 THEN 6299 ELSE population END WHERE id IN (128107);

UPDATE cities SET population = CASE id WHEN 123878 THEN 6296 ELSE population END WHERE id IN (123878);

UPDATE cities SET population = CASE id WHEN 141232 THEN 6291 ELSE population END WHERE id IN (141232);

UPDATE cities SET population = CASE id WHEN 116797 THEN 6266 ELSE population END WHERE id IN (116797);

UPDATE cities SET population = CASE id WHEN 141228 THEN 6260 ELSE population END WHERE id IN (141228);

UPDATE cities SET population = CASE id WHEN 112099 THEN 6248 ELSE population END WHERE id IN (112099);

UPDATE cities SET population = CASE id WHEN 121710 THEN 6245 ELSE population END WHERE id IN (121710);

UPDATE cities SET population = CASE id WHEN 141413 THEN 6243 ELSE population END WHERE id IN (141413);

UPDATE cities SET population = CASE id WHEN 115032 THEN 6242 ELSE population END WHERE id IN (115032);

UPDATE cities SET population = CASE id WHEN 115543 THEN 6235 ELSE population END WHERE id IN (115543);

UPDATE cities SET population = CASE id WHEN 114469 THEN 6229 ELSE population END WHERE id IN (114469);

UPDATE cities SET population = CASE id WHEN 113954 THEN 6226 ELSE population END WHERE id IN (113954);

UPDATE cities SET population = CASE id WHEN 119625 THEN 6225 ELSE population END WHERE id IN (119625);

UPDATE cities SET population = CASE id WHEN 118077 THEN 6221 WHEN 118498 THEN 6221 ELSE population END WHERE id IN (118077,118498);

UPDATE cities SET population = CASE id WHEN 125727 THEN 6217 ELSE population END WHERE id IN (125727);

UPDATE cities SET population = CASE id WHEN 123513 THEN 6198 ELSE population END WHERE id IN (123513);

UPDATE cities SET population = CASE id WHEN 124560 THEN 6186 ELSE population END WHERE id IN (124560);

UPDATE cities SET population = CASE id WHEN 117333 THEN 6177 ELSE population END WHERE id IN (117333);

UPDATE cities SET population = CASE id WHEN 124682 THEN 6174 ELSE population END WHERE id IN (124682);

UPDATE cities SET population = CASE id WHEN 141358 THEN 6165 ELSE population END WHERE id IN (141358);

UPDATE cities SET population = CASE id WHEN 117759 THEN 6143 ELSE population END WHERE id IN (117759);

UPDATE cities SET population = CASE id WHEN 125301 THEN 6134 ELSE population END WHERE id IN (125301);

UPDATE cities SET population = CASE id WHEN 120915 THEN 6132 ELSE population END WHERE id IN (120915);

UPDATE cities SET population = CASE id WHEN 112948 THEN 6116 ELSE population END WHERE id IN (112948);

UPDATE cities SET population = CASE id WHEN 141611 THEN 6111 ELSE population END WHERE id IN (141611);

UPDATE cities SET population = CASE id WHEN 122471 THEN 6108 ELSE population END WHERE id IN (122471);

UPDATE cities SET population = CASE id WHEN 123683 THEN 6103 ELSE population END WHERE id IN (123683);

UPDATE cities SET population = CASE id WHEN 127931 THEN 6101 ELSE population END WHERE id IN (127931);

UPDATE cities SET population = CASE id WHEN 126322 THEN 6094 WHEN 127929 THEN 6094 ELSE population END WHERE id IN (126322,127929);

UPDATE cities SET population = CASE id WHEN 122162 THEN 6090 ELSE population END WHERE id IN (122162);

UPDATE cities SET population = CASE id WHEN 114117 THEN 6089 ELSE population END WHERE id IN (114117);

UPDATE cities SET population = CASE id WHEN 118109 THEN 6085 ELSE population END WHERE id IN (118109);

UPDATE cities SET population = CASE id WHEN 125263 THEN 6065 ELSE population END WHERE id IN (125263);

UPDATE cities SET population = CASE id WHEN 141825 THEN 6063 ELSE population END WHERE id IN (141825);

UPDATE cities SET population = CASE id WHEN 141343 THEN 6051 ELSE population END WHERE id IN (141343);

UPDATE cities SET population = CASE id WHEN 126320 THEN 6039 ELSE population END WHERE id IN (126320);

UPDATE cities SET population = CASE id WHEN 127055 THEN 6037 ELSE population END WHERE id IN (127055);

UPDATE cities SET population = CASE id WHEN 124685 THEN 6035 ELSE population END WHERE id IN (124685);

UPDATE cities SET population = CASE id WHEN 113246 THEN 6032 WHEN 126584 THEN 6032 ELSE population END WHERE id IN (113246,126584);

UPDATE cities SET population = CASE id WHEN 119616 THEN 6030 ELSE population END WHERE id IN (119616);

UPDATE cities SET population = CASE id WHEN 118893 THEN 6028 ELSE population END WHERE id IN (118893);

UPDATE cities SET population = CASE id WHEN 127449 THEN 6025 ELSE population END WHERE id IN (127449);

UPDATE cities SET population = CASE id WHEN 116517 THEN 6012 ELSE population END WHERE id IN (116517);

UPDATE cities SET population = CASE id WHEN 128889 THEN 6009 ELSE population END WHERE id IN (128889);

UPDATE cities SET population = CASE id WHEN 114726 THEN 6002 ELSE population END WHERE id IN (114726);

UPDATE cities SET population = CASE id WHEN 111128 THEN 5998 ELSE population END WHERE id IN (111128);

UPDATE cities SET population = CASE id WHEN 121838 THEN 5983 ELSE population END WHERE id IN (121838);

UPDATE cities SET population = CASE id WHEN 126861 THEN 5981 ELSE population END WHERE id IN (126861);

UPDATE cities SET population = CASE id WHEN 116176 THEN 5979 ELSE population END WHERE id IN (116176);

UPDATE cities SET population = CASE id WHEN 121604 THEN 5973 ELSE population END WHERE id IN (121604);

UPDATE cities SET population = CASE id WHEN 112137 THEN 5966 ELSE population END WHERE id IN (112137);

UPDATE cities SET population = CASE id WHEN 128244 THEN 5964 ELSE population END WHERE id IN (128244);

UPDATE cities SET population = CASE id WHEN 121241 THEN 5957 ELSE population END WHERE id IN (121241);

UPDATE cities SET population = CASE id WHEN 124710 THEN 5953 ELSE population END WHERE id IN (124710);

UPDATE cities SET population = CASE id WHEN 111224 THEN 5952 ELSE population END WHERE id IN (111224);

UPDATE cities SET population = CASE id WHEN 127341 THEN 5931 ELSE population END WHERE id IN (127341);

UPDATE cities SET population = CASE id WHEN 141177 THEN 5900 ELSE population END WHERE id IN (141177);

UPDATE cities SET population = CASE id WHEN 123198 THEN 5898 ELSE population END WHERE id IN (123198);

UPDATE cities SET population = CASE id WHEN 127809 THEN 5896 ELSE population END WHERE id IN (127809);

UPDATE cities SET population = CASE id WHEN 122673 THEN 5891 ELSE population END WHERE id IN (122673);

UPDATE cities SET population = CASE id WHEN 125423 THEN 5876 ELSE population END WHERE id IN (125423);

UPDATE cities SET population = CASE id WHEN 120433 THEN 5874 ELSE population END WHERE id IN (120433);

UPDATE cities SET population = CASE id WHEN 123200 THEN 5869 ELSE population END WHERE id IN (123200);

UPDATE cities SET population = CASE id WHEN 125092 THEN 5864 ELSE population END WHERE id IN (125092);

UPDATE cities SET population = CASE id WHEN 122409 THEN 5862 WHEN 124559 THEN 5862 ELSE population END WHERE id IN (122409,124559);

UPDATE cities SET population = CASE id WHEN 119621 THEN 5846 ELSE population END WHERE id IN (119621);

UPDATE cities SET population = CASE id WHEN 119335 THEN 5842 WHEN 129527 THEN 5842 ELSE population END WHERE id IN (119335,129527);

UPDATE cities SET population = CASE id WHEN 124407 THEN 5832 ELSE population END WHERE id IN (124407);

UPDATE cities SET population = CASE id WHEN 121605 THEN 5827 ELSE population END WHERE id IN (121605);

UPDATE cities SET population = CASE id WHEN 117694 THEN 5819 ELSE population END WHERE id IN (117694);

UPDATE cities SET population = CASE id WHEN 113763 THEN 5815 ELSE population END WHERE id IN (113763);

UPDATE cities SET population = CASE id WHEN 141096 THEN 5811 ELSE population END WHERE id IN (141096);

UPDATE cities SET population = CASE id WHEN 119943 THEN 5798 ELSE population END WHERE id IN (119943);

UPDATE cities SET population = CASE id WHEN 120421 THEN 5774 ELSE population END WHERE id IN (120421);

UPDATE cities SET population = CASE id WHEN 120877 THEN 5764 ELSE population END WHERE id IN (120877);

UPDATE cities SET population = CASE id WHEN 121066 THEN 5756 ELSE population END WHERE id IN (121066);

UPDATE cities SET population = CASE id WHEN 119125 THEN 5755 ELSE population END WHERE id IN (119125);

UPDATE cities SET population = CASE id WHEN 141361 THEN 5747 ELSE population END WHERE id IN (141361);

UPDATE cities SET population = CASE id WHEN 113658 THEN 5745 ELSE population END WHERE id IN (113658);

UPDATE cities SET population = CASE id WHEN 127422 THEN 5740 ELSE population END WHERE id IN (127422);

UPDATE cities SET population = CASE id WHEN 122337 THEN 5728 ELSE population END WHERE id IN (122337);

UPDATE cities SET population = CASE id WHEN 118446 THEN 5726 ELSE population END WHERE id IN (118446);

UPDATE cities SET population = CASE id WHEN 126858 THEN 5711 ELSE population END WHERE id IN (126858);

UPDATE cities SET population = CASE id WHEN 126826 THEN 5700 ELSE population END WHERE id IN (126826);

UPDATE cities SET population = CASE id WHEN 129310 THEN 5695 ELSE population END WHERE id IN (129310);

UPDATE cities SET population = CASE id WHEN 129323 THEN 5694 ELSE population END WHERE id IN (129323);

UPDATE cities SET population = CASE id WHEN 141563 THEN 5693 ELSE population END WHERE id IN (141563);

UPDATE cities SET population = CASE id WHEN 120559 THEN 5692 ELSE population END WHERE id IN (120559);

UPDATE cities SET population = CASE id WHEN 141262 THEN 5682 ELSE population END WHERE id IN (141262);

UPDATE cities SET population = CASE id WHEN 120285 THEN 5680 ELSE population END WHERE id IN (120285);

UPDATE cities SET population = CASE id WHEN 118657 THEN 5676 ELSE population END WHERE id IN (118657);

UPDATE cities SET population = CASE id WHEN 129079 THEN 5662 ELSE population END WHERE id IN (129079);

UPDATE cities SET population = CASE id WHEN 125070 THEN 5661 ELSE population END WHERE id IN (125070);

UPDATE cities SET population = CASE id WHEN 114739 THEN 5658 WHEN 126228 THEN 5658 ELSE population END WHERE id IN (114739,126228);

UPDATE cities SET population = CASE id WHEN 122283 THEN 5653 ELSE population END WHERE id IN (122283);

UPDATE cities SET population = CASE id WHEN 118397 THEN 5647 ELSE population END WHERE id IN (118397);

UPDATE cities SET population = CASE id WHEN 111898 THEN 5635 ELSE population END WHERE id IN (111898);

UPDATE cities SET population = CASE id WHEN 118909 THEN 5627 ELSE population END WHERE id IN (118909);

UPDATE cities SET population = CASE id WHEN 120734 THEN 5618 ELSE population END WHERE id IN (120734);

UPDATE cities SET population = CASE id WHEN 127031 THEN 5617 ELSE population END WHERE id IN (127031);

UPDATE cities SET population = CASE id WHEN 120039 THEN 5615 ELSE population END WHERE id IN (120039);

UPDATE cities SET population = CASE id WHEN 112077 THEN 5610 ELSE population END WHERE id IN (112077);

UPDATE cities SET population = CASE id WHEN 111591 THEN 5605 ELSE population END WHERE id IN (111591);

UPDATE cities SET population = CASE id WHEN 126429 THEN 5598 ELSE population END WHERE id IN (126429);

UPDATE cities SET population = CASE id WHEN 116272 THEN 5596 ELSE population END WHERE id IN (116272);

UPDATE cities SET population = CASE id WHEN 125086 THEN 5595 ELSE population END WHERE id IN (125086);

UPDATE cities SET population = CASE id WHEN 121918 THEN 5593 ELSE population END WHERE id IN (121918);

UPDATE cities SET population = CASE id WHEN 117551 THEN 5584 ELSE population END WHERE id IN (117551);

UPDATE cities SET population = CASE id WHEN 123812 THEN 5575 ELSE population END WHERE id IN (123812);

UPDATE cities SET population = CASE id WHEN 117703 THEN 5569 WHEN 128686 THEN 5569 ELSE population END WHERE id IN (117703,128686);

UPDATE cities SET population = CASE id WHEN 129556 THEN 5561 ELSE population END WHERE id IN (129556);

UPDATE cities SET population = CASE id WHEN 117124 THEN 5552 ELSE population END WHERE id IN (117124);

UPDATE cities SET population = CASE id WHEN 118247 THEN 5548 ELSE population END WHERE id IN (118247);

UPDATE cities SET population = CASE id WHEN 115561 THEN 5535 ELSE population END WHERE id IN (115561);

UPDATE cities SET population = CASE id WHEN 128733 THEN 5534 ELSE population END WHERE id IN (128733);

UPDATE cities SET population = CASE id WHEN 115850 THEN 5532 ELSE population END WHERE id IN (115850);

UPDATE cities SET population = CASE id WHEN 117279 THEN 5521 WHEN 117909 THEN 5521 ELSE population END WHERE id IN (117279,117909);

UPDATE cities SET population = CASE id WHEN 115573 THEN 5518 ELSE population END WHERE id IN (115573);

UPDATE cities SET population = CASE id WHEN 111370 THEN 5517 ELSE population END WHERE id IN (111370);

UPDATE cities SET population = CASE id WHEN 118597 THEN 5515 ELSE population END WHERE id IN (118597);

UPDATE cities SET population = CASE id WHEN 141795 THEN 5514 ELSE population END WHERE id IN (141795);

UPDATE cities SET population = CASE id WHEN 122166 THEN 5509 ELSE population END WHERE id IN (122166);

UPDATE cities SET population = CASE id WHEN 125082 THEN 5504 ELSE population END WHERE id IN (125082);

UPDATE cities SET population = CASE id WHEN 141347 THEN 5503 ELSE population END WHERE id IN (141347);

UPDATE cities SET population = CASE id WHEN 118051 THEN 5498 ELSE population END WHERE id IN (118051);

UPDATE cities SET population = CASE id WHEN 116112 THEN 5496 WHEN 120924 THEN 5496 ELSE population END WHERE id IN (116112,120924);

UPDATE cities SET population = CASE id WHEN 141801 THEN 5494 ELSE population END WHERE id IN (141801);

UPDATE cities SET population = CASE id WHEN 114327 THEN 5489 ELSE population END WHERE id IN (114327);

UPDATE cities SET population = CASE id WHEN 113885 THEN 5486 ELSE population END WHERE id IN (113885);

UPDATE cities SET population = CASE id WHEN 125619 THEN 5485 ELSE population END WHERE id IN (125619);

UPDATE cities SET population = CASE id WHEN 123151 THEN 5484 ELSE population END WHERE id IN (123151);

UPDATE cities SET population = CASE id WHEN 125235 THEN 5480 ELSE population END WHERE id IN (125235);

UPDATE cities SET population = CASE id WHEN 124957 THEN 5472 ELSE population END WHERE id IN (124957);

UPDATE cities SET population = CASE id WHEN 125743 THEN 5467 ELSE population END WHERE id IN (125743);

UPDATE cities SET population = CASE id WHEN 128076 THEN 5461 ELSE population END WHERE id IN (128076);

UPDATE cities SET population = CASE id WHEN 113275 THEN 5460 WHEN 122576 THEN 5460 ELSE population END WHERE id IN (113275,122576);

UPDATE cities SET population = CASE id WHEN 116762 THEN 5446 WHEN 120290 THEN 5446 ELSE population END WHERE id IN (116762,120290);

UPDATE cities SET population = CASE id WHEN 129275 THEN 5438 ELSE population END WHERE id IN (129275);

UPDATE cities SET population = CASE id WHEN 120965 THEN 5436 ELSE population END WHERE id IN (120965);

UPDATE cities SET population = CASE id WHEN 122336 THEN 5425 ELSE population END WHERE id IN (122336);

UPDATE cities SET population = CASE id WHEN 125990 THEN 5424 ELSE population END WHERE id IN (125990);

UPDATE cities SET population = CASE id WHEN 112239 THEN 5420 ELSE population END WHERE id IN (112239);

UPDATE cities SET population = CASE id WHEN 114381 THEN 5417 ELSE population END WHERE id IN (114381);

UPDATE cities SET population = CASE id WHEN 121102 THEN 5413 ELSE population END WHERE id IN (121102);

UPDATE cities SET population = CASE id WHEN 121090 THEN 5408 ELSE population END WHERE id IN (121090);

UPDATE cities SET population = CASE id WHEN 129132 THEN 5407 ELSE population END WHERE id IN (129132);

UPDATE cities SET population = CASE id WHEN 129398 THEN 5406 ELSE population END WHERE id IN (129398);

UPDATE cities SET population = CASE id WHEN 110974 THEN 5397 WHEN 117409 THEN 5397 ELSE population END WHERE id IN (110974,117409);

UPDATE cities SET population = CASE id WHEN 129433 THEN 5393 ELSE population END WHERE id IN (129433);

UPDATE cities SET population = CASE id WHEN 127686 THEN 5389 ELSE population END WHERE id IN (127686);

UPDATE cities SET population = CASE id WHEN 112630 THEN 5388 ELSE population END WHERE id IN (112630);

UPDATE cities SET population = CASE id WHEN 123680 THEN 5385 ELSE population END WHERE id IN (123680);

UPDATE cities SET population = CASE id WHEN 123735 THEN 5382 ELSE population END WHERE id IN (123735);

UPDATE cities SET population = CASE id WHEN 116234 THEN 5377 ELSE population END WHERE id IN (116234);

UPDATE cities SET population = CASE id WHEN 128712 THEN 5374 ELSE population END WHERE id IN (128712);

UPDATE cities SET population = CASE id WHEN 127214 THEN 5372 ELSE population END WHERE id IN (127214);

UPDATE cities SET population = CASE id WHEN 129346 THEN 5363 ELSE population END WHERE id IN (129346);

UPDATE cities SET population = CASE id WHEN 128608 THEN 5358 ELSE population END WHERE id IN (128608);

UPDATE cities SET population = CASE id WHEN 127950 THEN 5353 ELSE population END WHERE id IN (127950);

UPDATE cities SET population = CASE id WHEN 122268 THEN 5352 ELSE population END WHERE id IN (122268);

UPDATE cities SET population = CASE id WHEN 141601 THEN 5350 ELSE population END WHERE id IN (141601);

UPDATE cities SET population = CASE id WHEN 113145 THEN 5328 ELSE population END WHERE id IN (113145);

UPDATE cities SET population = CASE id WHEN 122165 THEN 5322 ELSE population END WHERE id IN (122165);

UPDATE cities SET population = CASE id WHEN 126875 THEN 5314 ELSE population END WHERE id IN (126875);

UPDATE cities SET population = CASE id WHEN 115855 THEN 5302 ELSE population END WHERE id IN (115855);

UPDATE cities SET population = CASE id WHEN 129266 THEN 5293 ELSE population END WHERE id IN (129266);

UPDATE cities SET population = CASE id WHEN 113656 THEN 5288 ELSE population END WHERE id IN (113656);

UPDATE cities SET population = CASE id WHEN 114420 THEN 5287 ELSE population END WHERE id IN (114420);

UPDATE cities SET population = CASE id WHEN 128508 THEN 5282 ELSE population END WHERE id IN (128508);

UPDATE cities SET population = CASE id WHEN 114817 THEN 5272 ELSE population END WHERE id IN (114817);

UPDATE cities SET population = CASE id WHEN 141199 THEN 5259 ELSE population END WHERE id IN (141199);

UPDATE cities SET population = CASE id WHEN 116310 THEN 5255 ELSE population END WHERE id IN (116310);

UPDATE cities SET population = CASE id WHEN 129292 THEN 5254 ELSE population END WHERE id IN (129292);

UPDATE cities SET population = CASE id WHEN 117313 THEN 5253 ELSE population END WHERE id IN (117313);

UPDATE cities SET population = CASE id WHEN 129562 THEN 5248 ELSE population END WHERE id IN (129562);

UPDATE cities SET population = CASE id WHEN 115122 THEN 5242 ELSE population END WHERE id IN (115122);

UPDATE cities SET population = CASE id WHEN 113887 THEN 5236 ELSE population END WHERE id IN (113887);

UPDATE cities SET population = CASE id WHEN 116254 THEN 5228 ELSE population END WHERE id IN (116254);

UPDATE cities SET population = CASE id WHEN 121242 THEN 5213 ELSE population END WHERE id IN (121242);

UPDATE cities SET population = CASE id WHEN 124657 THEN 5212 ELSE population END WHERE id IN (124657);

UPDATE cities SET population = CASE id WHEN 113833 THEN 5205 ELSE population END WHERE id IN (113833);

UPDATE cities SET population = CASE id WHEN 111793 THEN 5203 WHEN 112222 THEN 5203 ELSE population END WHERE id IN (111793,112222);

UPDATE cities SET population = CASE id WHEN 117287 THEN 5198 WHEN 125304 THEN 5198 ELSE population END WHERE id IN (117287,125304);

UPDATE cities SET population = CASE id WHEN 129261 THEN 5196 ELSE population END WHERE id IN (129261);

UPDATE cities SET population = CASE id WHEN 126898 THEN 5192 ELSE population END WHERE id IN (126898);

UPDATE cities SET population = CASE id WHEN 110967 THEN 5191 WHEN 110969 THEN 5191 ELSE population END WHERE id IN (110967,110969);

UPDATE cities SET population = CASE id WHEN 127273 THEN 5183 ELSE population END WHERE id IN (127273);

UPDATE cities SET population = CASE id WHEN 111256 THEN 5180 ELSE population END WHERE id IN (111256);

UPDATE cities SET population = CASE id WHEN 123359 THEN 5178 ELSE population END WHERE id IN (123359);

UPDATE cities SET population = CASE id WHEN 120650 THEN 5172 WHEN 122161 THEN 5172 ELSE population END WHERE id IN (120650,122161);

UPDATE cities SET population = CASE id WHEN 112859 THEN 5171 ELSE population END WHERE id IN (112859);

UPDATE cities SET population = CASE id WHEN 113665 THEN 5167 ELSE population END WHERE id IN (113665);

UPDATE cities SET population = CASE id WHEN 123165 THEN 5159 ELSE population END WHERE id IN (123165);

UPDATE cities SET population = CASE id WHEN 129238 THEN 5149 ELSE population END WHERE id IN (129238);

UPDATE cities SET population = CASE id WHEN 128280 THEN 5148 ELSE population END WHERE id IN (128280);

UPDATE cities SET population = CASE id WHEN 127676 THEN 5144 ELSE population END WHERE id IN (127676);

UPDATE cities SET population = CASE id WHEN 121180 THEN 5138 ELSE population END WHERE id IN (121180);

UPDATE cities SET population = CASE id WHEN 119608 THEN 5131 ELSE population END WHERE id IN (119608);

UPDATE cities SET population = CASE id WHEN 112624 THEN 5126 ELSE population END WHERE id IN (112624);

UPDATE cities SET population = CASE id WHEN 122718 THEN 5123 ELSE population END WHERE id IN (122718);

UPDATE cities SET population = CASE id WHEN 125975 THEN 5108 ELSE population END WHERE id IN (125975);

UPDATE cities SET population = CASE id WHEN 124166 THEN 5103 ELSE population END WHERE id IN (124166);

UPDATE cities SET population = CASE id WHEN 124069 THEN 5097 WHEN 127195 THEN 5097 WHEN 141745 THEN 5097 ELSE population END WHERE id IN (124069,127195,141745);

UPDATE cities SET population = CASE id WHEN 115096 THEN 5096 WHEN 121837 THEN 5096 WHEN 126810 THEN 5096 ELSE population END WHERE id IN (115096,121837,126810);

UPDATE cities SET population = CASE id WHEN 112518 THEN 5093 ELSE population END WHERE id IN (112518);

UPDATE cities SET population = CASE id WHEN 112773 THEN 5092 ELSE population END WHERE id IN (112773);

UPDATE cities SET population = CASE id WHEN 111629 THEN 5089 ELSE population END WHERE id IN (111629);

UPDATE cities SET population = CASE id WHEN 126286 THEN 5088 ELSE population END WHERE id IN (126286);

UPDATE cities SET population = CASE id WHEN 116972 THEN 5087 ELSE population END WHERE id IN (116972);

UPDATE cities SET population = CASE id WHEN 119484 THEN 5077 ELSE population END WHERE id IN (119484);

UPDATE cities SET population = CASE id WHEN 121095 THEN 5073 WHEN 123835 THEN 5073 ELSE population END WHERE id IN (121095,123835);

UPDATE cities SET population = CASE id WHEN 121506 THEN 5064 ELSE population END WHERE id IN (121506);

UPDATE cities SET population = CASE id WHEN 141109 THEN 5058 ELSE population END WHERE id IN (141109);

UPDATE cities SET population = CASE id WHEN 112404 THEN 5056 ELSE population END WHERE id IN (112404);

UPDATE cities SET population = CASE id WHEN 117928 THEN 5052 ELSE population END WHERE id IN (117928);

UPDATE cities SET population = CASE id WHEN 123153 THEN 5049 ELSE population END WHERE id IN (123153);

UPDATE cities SET population = CASE id WHEN 111153 THEN 5047 ELSE population END WHERE id IN (111153);

UPDATE cities SET population = CASE id WHEN 117727 THEN 5046 ELSE population END WHERE id IN (117727);

UPDATE cities SET population = CASE id WHEN 128615 THEN 5036 ELSE population END WHERE id IN (128615);

UPDATE cities SET population = CASE id WHEN 116364 THEN 5031 ELSE population END WHERE id IN (116364);

UPDATE cities SET population = CASE id WHEN 113848 THEN 5030 ELSE population END WHERE id IN (113848);

UPDATE cities SET population = CASE id WHEN 113692 THEN 5027 WHEN 119883 THEN 5027 ELSE population END WHERE id IN (113692,119883);

UPDATE cities SET population = CASE id WHEN 126302 THEN 5021 ELSE population END WHERE id IN (126302);

UPDATE cities SET population = CASE id WHEN 118519 THEN 5019 ELSE population END WHERE id IN (118519);

UPDATE cities SET population = CASE id WHEN 118016 THEN 5002 ELSE population END WHERE id IN (118016);

UPDATE cities SET population = CASE id WHEN 114947 THEN 5000 ELSE population END WHERE id IN (114947);

UPDATE cities SET population = CASE id WHEN 114497 THEN 4996 ELSE population END WHERE id IN (114497);

UPDATE cities SET population = CASE id WHEN 125730 THEN 4992 ELSE population END WHERE id IN (125730);

UPDATE cities SET population = CASE id WHEN 121456 THEN 4989 ELSE population END WHERE id IN (121456);

UPDATE cities SET population = CASE id WHEN 111487 THEN 4988 WHEN 119154 THEN 4988 ELSE population END WHERE id IN (111487,119154);

UPDATE cities SET population = CASE id WHEN 119061 THEN 4983 ELSE population END WHERE id IN (119061);

UPDATE cities SET population = CASE id WHEN 112444 THEN 4980 ELSE population END WHERE id IN (112444);

UPDATE cities SET population = CASE id WHEN 128706 THEN 4975 ELSE population END WHERE id IN (128706);

UPDATE cities SET population = CASE id WHEN 123599 THEN 4972 ELSE population END WHERE id IN (123599);

UPDATE cities SET population = CASE id WHEN 125317 THEN 4966 ELSE population END WHERE id IN (125317);

UPDATE cities SET population = CASE id WHEN 129743 THEN 4964 ELSE population END WHERE id IN (129743);

UPDATE cities SET population = CASE id WHEN 118566 THEN 4962 ELSE population END WHERE id IN (118566);

UPDATE cities SET population = CASE id WHEN 112811 THEN 4951 ELSE population END WHERE id IN (112811);

UPDATE cities SET population = CASE id WHEN 123506 THEN 4947 ELSE population END WHERE id IN (123506);

UPDATE cities SET population = CASE id WHEN 121144 THEN 4946 ELSE population END WHERE id IN (121144);

UPDATE cities SET population = CASE id WHEN 128066 THEN 4942 ELSE population END WHERE id IN (128066);

UPDATE cities SET population = CASE id WHEN 114884 THEN 4939 ELSE population END WHERE id IN (114884);

UPDATE cities SET population = CASE id WHEN 129050 THEN 4938 ELSE population END WHERE id IN (129050);

UPDATE cities SET population = CASE id WHEN 122669 THEN 4934 ELSE population END WHERE id IN (122669);

UPDATE cities SET population = CASE id WHEN 141102 THEN 4932 ELSE population END WHERE id IN (141102);

UPDATE cities SET population = CASE id WHEN 115802 THEN 4928 ELSE population END WHERE id IN (115802);

UPDATE cities SET population = CASE id WHEN 113047 THEN 4926 ELSE population END WHERE id IN (113047);

UPDATE cities SET population = CASE id WHEN 141420 THEN 4918 ELSE population END WHERE id IN (141420);

UPDATE cities SET population = CASE id WHEN 127930 THEN 4917 ELSE population END WHERE id IN (127930);

UPDATE cities SET population = CASE id WHEN 113492 THEN 4899 ELSE population END WHERE id IN (113492);

UPDATE cities SET population = CASE id WHEN 112713 THEN 4896 ELSE population END WHERE id IN (112713);

UPDATE cities SET population = CASE id WHEN 125729 THEN 4894 ELSE population END WHERE id IN (125729);

UPDATE cities SET population = CASE id WHEN 114020 THEN 4891 ELSE population END WHERE id IN (114020);

UPDATE cities SET population = CASE id WHEN 112184 THEN 4888 ELSE population END WHERE id IN (112184);

UPDATE cities SET population = CASE id WHEN 126304 THEN 4873 ELSE population END WHERE id IN (126304);

UPDATE cities SET population = CASE id WHEN 125757 THEN 4869 ELSE population END WHERE id IN (125757);

UPDATE cities SET population = CASE id WHEN 118418 THEN 4867 ELSE population END WHERE id IN (118418);

UPDATE cities SET population = CASE id WHEN 127760 THEN 4857 ELSE population END WHERE id IN (127760);

UPDATE cities SET population = CASE id WHEN 116838 THEN 4855 ELSE population END WHERE id IN (116838);

UPDATE cities SET population = CASE id WHEN 122575 THEN 4854 ELSE population END WHERE id IN (122575);

UPDATE cities SET population = CASE id WHEN 141800 THEN 4852 ELSE population END WHERE id IN (141800);

UPDATE cities SET population = CASE id WHEN 117237 THEN 4830 ELSE population END WHERE id IN (117237);

UPDATE cities SET population = CASE id WHEN 119998 THEN 4822 ELSE population END WHERE id IN (119998);

UPDATE cities SET population = CASE id WHEN 114268 THEN 4811 ELSE population END WHERE id IN (114268);

UPDATE cities SET population = CASE id WHEN 113417 THEN 4800 ELSE population END WHERE id IN (113417);

UPDATE cities SET population = CASE id WHEN 113404 THEN 4799 WHEN 125336 THEN 4799 ELSE population END WHERE id IN (113404,125336);

UPDATE cities SET population = CASE id WHEN 111621 THEN 4793 ELSE population END WHERE id IN (111621);

UPDATE cities SET population = CASE id WHEN 122375 THEN 4790 ELSE population END WHERE id IN (122375);

UPDATE cities SET population = CASE id WHEN 120619 THEN 4787 ELSE population END WHERE id IN (120619);

UPDATE cities SET population = CASE id WHEN 121026 THEN 4783 ELSE population END WHERE id IN (121026);

UPDATE cities SET population = CASE id WHEN 114383 THEN 4781 ELSE population END WHERE id IN (114383);

UPDATE cities SET population = CASE id WHEN 122847 THEN 4769 WHEN 129357 THEN 4769 ELSE population END WHERE id IN (122847,129357);

UPDATE cities SET population = CASE id WHEN 111357 THEN 4767 ELSE population END WHERE id IN (111357);

UPDATE cities SET population = CASE id WHEN 141713 THEN 4764 ELSE population END WHERE id IN (141713);

UPDATE cities SET population = CASE id WHEN 128793 THEN 4753 ELSE population END WHERE id IN (128793);

UPDATE cities SET population = CASE id WHEN 119300 THEN 4746 WHEN 129083 THEN 4746 ELSE population END WHERE id IN (119300,129083);

UPDATE cities SET population = CASE id WHEN 121816 THEN 4742 ELSE population END WHERE id IN (121816);

UPDATE cities SET population = CASE id WHEN 123765 THEN 4733 WHEN 129194 THEN 4733 ELSE population END WHERE id IN (123765,129194);

UPDATE cities SET population = CASE id WHEN 115895 THEN 4732 ELSE population END WHERE id IN (115895);

UPDATE cities SET population = CASE id WHEN 141449 THEN 4731 ELSE population END WHERE id IN (141449);

UPDATE cities SET population = CASE id WHEN 122369 THEN 4728 ELSE population END WHERE id IN (122369);

UPDATE cities SET population = CASE id WHEN 122842 THEN 4723 ELSE population END WHERE id IN (122842);

UPDATE cities SET population = CASE id WHEN 119751 THEN 4712 ELSE population END WHERE id IN (119751);

UPDATE cities SET population = CASE id WHEN 128361 THEN 4705 ELSE population END WHERE id IN (128361);

UPDATE cities SET population = CASE id WHEN 124073 THEN 4702 ELSE population END WHERE id IN (124073);

UPDATE cities SET population = CASE id WHEN 116400 THEN 4701 ELSE population END WHERE id IN (116400);

UPDATE cities SET population = CASE id WHEN 123244 THEN 4700 ELSE population END WHERE id IN (123244);

UPDATE cities SET population = CASE id WHEN 124563 THEN 4694 ELSE population END WHERE id IN (124563);

UPDATE cities SET population = CASE id WHEN 115037 THEN 4689 ELSE population END WHERE id IN (115037);

UPDATE cities SET population = CASE id WHEN 124688 THEN 4680 ELSE population END WHERE id IN (124688);

UPDATE cities SET population = CASE id WHEN 120900 THEN 4677 ELSE population END WHERE id IN (120900);

UPDATE cities SET population = CASE id WHEN 122689 THEN 4669 ELSE population END WHERE id IN (122689);

UPDATE cities SET population = CASE id WHEN 125262 THEN 4661 ELSE population END WHERE id IN (125262);

UPDATE cities SET population = CASE id WHEN 112868 THEN 4650 ELSE population END WHERE id IN (112868);

UPDATE cities SET population = CASE id WHEN 119073 THEN 4649 WHEN 124918 THEN 4649 ELSE population END WHERE id IN (119073,124918);

UPDATE cities SET population = CASE id WHEN 121819 THEN 4646 ELSE population END WHERE id IN (121819);

UPDATE cities SET population = CASE id WHEN 111674 THEN 4642 ELSE population END WHERE id IN (111674);

UPDATE cities SET population = CASE id WHEN 126530 THEN 4640 ELSE population END WHERE id IN (126530);

UPDATE cities SET population = CASE id WHEN 121027 THEN 4637 ELSE population END WHERE id IN (121027);

UPDATE cities SET population = CASE id WHEN 113016 THEN 4632 ELSE population END WHERE id IN (113016);

UPDATE cities SET population = CASE id WHEN 113693 THEN 4627 ELSE population END WHERE id IN (113693);

UPDATE cities SET population = CASE id WHEN 114989 THEN 4622 ELSE population END WHERE id IN (114989);

UPDATE cities SET population = CASE id WHEN 122135 THEN 4609 ELSE population END WHERE id IN (122135);

UPDATE cities SET population = CASE id WHEN 125655 THEN 4605 ELSE population END WHERE id IN (125655);

UPDATE cities SET population = CASE id WHEN 117894 THEN 4602 WHEN 124293 THEN 4602 ELSE population END WHERE id IN (117894,124293);

UPDATE cities SET population = CASE id WHEN 126281 THEN 4599 ELSE population END WHERE id IN (126281);

UPDATE cities SET population = CASE id WHEN 120440 THEN 4598 ELSE population END WHERE id IN (120440);

UPDATE cities SET population = CASE id WHEN 118777 THEN 4596 ELSE population END WHERE id IN (118777);

UPDATE cities SET population = CASE id WHEN 117507 THEN 4594 ELSE population END WHERE id IN (117507);

UPDATE cities SET population = CASE id WHEN 111839 THEN 4592 ELSE population END WHERE id IN (111839);

UPDATE cities SET population = CASE id WHEN 119302 THEN 4587 ELSE population END WHERE id IN (119302);

UPDATE cities SET population = CASE id WHEN 118174 THEN 4586 ELSE population END WHERE id IN (118174);

UPDATE cities SET population = CASE id WHEN 113469 THEN 4574 ELSE population END WHERE id IN (113469);

UPDATE cities SET population = CASE id WHEN 116035 THEN 4573 ELSE population END WHERE id IN (116035);

UPDATE cities SET population = CASE id WHEN 141367 THEN 4572 ELSE population END WHERE id IN (141367);

UPDATE cities SET population = CASE id WHEN 123527 THEN 4568 ELSE population END WHERE id IN (123527);

UPDATE cities SET population = CASE id WHEN 112721 THEN 4565 ELSE population END WHERE id IN (112721);

UPDATE cities SET population = CASE id WHEN 112764 THEN 4564 ELSE population END WHERE id IN (112764);

UPDATE cities SET population = CASE id WHEN 117949 THEN 4555 ELSE population END WHERE id IN (117949);

UPDATE cities SET population = CASE id WHEN 124149 THEN 4553 ELSE population END WHERE id IN (124149);

UPDATE cities SET population = CASE id WHEN 119008 THEN 4548 ELSE population END WHERE id IN (119008);

UPDATE cities SET population = CASE id WHEN 115036 THEN 4537 WHEN 122398 THEN 4537 ELSE population END WHERE id IN (115036,122398);

UPDATE cities SET population = CASE id WHEN 125533 THEN 4534 ELSE population END WHERE id IN (125533);

UPDATE cities SET population = CASE id WHEN 118151 THEN 4532 ELSE population END WHERE id IN (118151);

UPDATE cities SET population = CASE id WHEN 126804 THEN 4529 ELSE population END WHERE id IN (126804);

UPDATE cities SET population = CASE id WHEN 122131 THEN 4523 WHEN 129190 THEN 4523 ELSE population END WHERE id IN (122131,129190);

UPDATE cities SET population = CASE id WHEN 111691 THEN 4521 ELSE population END WHERE id IN (111691);

UPDATE cities SET population = CASE id WHEN 122866 THEN 4513 ELSE population END WHERE id IN (122866);

UPDATE cities SET population = CASE id WHEN 120304 THEN 4500 ELSE population END WHERE id IN (120304);

UPDATE cities SET population = CASE id WHEN 117163 THEN 4497 ELSE population END WHERE id IN (117163);

UPDATE cities SET population = CASE id WHEN 111661 THEN 4496 ELSE population END WHERE id IN (111661);

UPDATE cities SET population = CASE id WHEN 119049 THEN 4495 WHEN 119238 THEN 4495 ELSE population END WHERE id IN (119049,119238);

UPDATE cities SET population = CASE id WHEN 141230 THEN 4487 ELSE population END WHERE id IN (141230);

UPDATE cities SET population = CASE id WHEN 122400 THEN 4486 ELSE population END WHERE id IN (122400);

UPDATE cities SET population = CASE id WHEN 121786 THEN 4469 ELSE population END WHERE id IN (121786);

UPDATE cities SET population = CASE id WHEN 123942 THEN 4463 ELSE population END WHERE id IN (123942);

UPDATE cities SET population = CASE id WHEN 141822 THEN 4462 ELSE population END WHERE id IN (141822);

UPDATE cities SET population = CASE id WHEN 117385 THEN 4457 ELSE population END WHERE id IN (117385);

UPDATE cities SET population = CASE id WHEN 124406 THEN 4456 ELSE population END WHERE id IN (124406);

UPDATE cities SET population = CASE id WHEN 141346 THEN 4447 ELSE population END WHERE id IN (141346);

UPDATE cities SET population = CASE id WHEN 122850 THEN 4442 ELSE population END WHERE id IN (122850);

UPDATE cities SET population = CASE id WHEN 141248 THEN 4438 ELSE population END WHERE id IN (141248);

UPDATE cities SET population = CASE id WHEN 124090 THEN 4437 ELSE population END WHERE id IN (124090);

UPDATE cities SET population = CASE id WHEN 141292 THEN 4432 ELSE population END WHERE id IN (141292);

UPDATE cities SET population = CASE id WHEN 120244 THEN 4427 ELSE population END WHERE id IN (120244);

UPDATE cities SET population = CASE id WHEN 116582 THEN 4426 ELSE population END WHERE id IN (116582);

UPDATE cities SET population = CASE id WHEN 123237 THEN 4425 ELSE population END WHERE id IN (123237);

UPDATE cities SET population = CASE id WHEN 119059 THEN 4424 ELSE population END WHERE id IN (119059);

UPDATE cities SET population = CASE id WHEN 127469 THEN 4421 ELSE population END WHERE id IN (127469);

UPDATE cities SET population = CASE id WHEN 111993 THEN 4420 ELSE population END WHERE id IN (111993);

UPDATE cities SET population = CASE id WHEN 111956 THEN 4419 ELSE population END WHERE id IN (111956);

UPDATE cities SET population = CASE id WHEN 111032 THEN 4400 ELSE population END WHERE id IN (111032);

UPDATE cities SET population = CASE id WHEN 117885 THEN 4398 WHEN 141616 THEN 4398 ELSE population END WHERE id IN (117885,141616);

UPDATE cities SET population = CASE id WHEN 117682 THEN 4395 ELSE population END WHERE id IN (117682);

UPDATE cities SET population = CASE id WHEN 125356 THEN 4383 ELSE population END WHERE id IN (125356);

UPDATE cities SET population = CASE id WHEN 112374 THEN 4376 ELSE population END WHERE id IN (112374);

UPDATE cities SET population = CASE id WHEN 118853 THEN 4375 ELSE population END WHERE id IN (118853);

UPDATE cities SET population = CASE id WHEN 114224 THEN 4370 ELSE population END WHERE id IN (114224);

UPDATE cities SET population = CASE id WHEN 116579 THEN 4363 WHEN 122380 THEN 4363 ELSE population END WHERE id IN (116579,122380);

UPDATE cities SET population = CASE id WHEN 112971 THEN 4362 ELSE population END WHERE id IN (112971);

UPDATE cities SET population = CASE id WHEN 120059 THEN 4361 ELSE population END WHERE id IN (120059);

UPDATE cities SET population = CASE id WHEN 126667 THEN 4359 ELSE population END WHERE id IN (126667);

UPDATE cities SET population = CASE id WHEN 125302 THEN 4358 ELSE population END WHERE id IN (125302);

UPDATE cities SET population = CASE id WHEN 112192 THEN 4357 ELSE population END WHERE id IN (112192);

UPDATE cities SET population = CASE id WHEN 123860 THEN 4352 ELSE population END WHERE id IN (123860);

UPDATE cities SET population = CASE id WHEN 128146 THEN 4348 ELSE population END WHERE id IN (128146);

UPDATE cities SET population = CASE id WHEN 141724 THEN 4346 ELSE population END WHERE id IN (141724);

UPDATE cities SET population = CASE id WHEN 117917 THEN 4343 ELSE population END WHERE id IN (117917);

UPDATE cities SET population = CASE id WHEN 126917 THEN 4339 ELSE population END WHERE id IN (126917);

UPDATE cities SET population = CASE id WHEN 121595 THEN 4338 ELSE population END WHERE id IN (121595);

UPDATE cities SET population = CASE id WHEN 112148 THEN 4336 ELSE population END WHERE id IN (112148);

UPDATE cities SET population = CASE id WHEN 121326 THEN 4335 ELSE population END WHERE id IN (121326);

UPDATE cities SET population = CASE id WHEN 129288 THEN 4325 ELSE population END WHERE id IN (129288);

UPDATE cities SET population = CASE id WHEN 124439 THEN 4323 ELSE population END WHERE id IN (124439);

UPDATE cities SET population = CASE id WHEN 126933 THEN 4320 ELSE population END WHERE id IN (126933);

UPDATE cities SET population = CASE id WHEN 112930 THEN 4317 ELSE population END WHERE id IN (112930);

UPDATE cities SET population = CASE id WHEN 115182 THEN 4315 ELSE population END WHERE id IN (115182);

UPDATE cities SET population = CASE id WHEN 127114 THEN 4314 ELSE population END WHERE id IN (127114);

UPDATE cities SET population = CASE id WHEN 113501 THEN 4311 WHEN 126811 THEN 4311 ELSE population END WHERE id IN (113501,126811);

UPDATE cities SET population = CASE id WHEN 125550 THEN 4303 ELSE population END WHERE id IN (125550);

UPDATE cities SET population = CASE id WHEN 141642 THEN 4302 ELSE population END WHERE id IN (141642);

UPDATE cities SET population = CASE id WHEN 112255 THEN 4300 ELSE population END WHERE id IN (112255);

UPDATE cities SET population = CASE id WHEN 121037 THEN 4298 ELSE population END WHERE id IN (121037);

UPDATE cities SET population = CASE id WHEN 111667 THEN 4295 ELSE population END WHERE id IN (111667);

UPDATE cities SET population = CASE id WHEN 117930 THEN 4290 ELSE population END WHERE id IN (117930);

UPDATE cities SET population = CASE id WHEN 128622 THEN 4289 ELSE population END WHERE id IN (128622);

UPDATE cities SET population = CASE id WHEN 116418 THEN 4288 WHEN 120263 THEN 4288 ELSE population END WHERE id IN (116418,120263);

UPDATE cities SET population = CASE id WHEN 113180 THEN 4283 ELSE population END WHERE id IN (113180);

UPDATE cities SET population = CASE id WHEN 141806 THEN 4279 ELSE population END WHERE id IN (141806);

UPDATE cities SET population = CASE id WHEN 116635 THEN 4278 ELSE population END WHERE id IN (116635);

UPDATE cities SET population = CASE id WHEN 116387 THEN 4274 WHEN 141797 THEN 4274 ELSE population END WHERE id IN (116387,141797);

UPDATE cities SET population = CASE id WHEN 125194 THEN 4273 ELSE population END WHERE id IN (125194);

UPDATE cities SET population = CASE id WHEN 113960 THEN 4269 ELSE population END WHERE id IN (113960);

UPDATE cities SET population = CASE id WHEN 141696 THEN 4266 ELSE population END WHERE id IN (141696);

UPDATE cities SET population = CASE id WHEN 128672 THEN 4264 ELSE population END WHERE id IN (128672);

UPDATE cities SET population = CASE id WHEN 121996 THEN 4252 ELSE population END WHERE id IN (121996);

UPDATE cities SET population = CASE id WHEN 126056 THEN 4251 ELSE population END WHERE id IN (126056);

UPDATE cities SET population = CASE id WHEN 111042 THEN 4245 ELSE population END WHERE id IN (111042);

UPDATE cities SET population = CASE id WHEN 117431 THEN 4243 ELSE population END WHERE id IN (117431);

UPDATE cities SET population = CASE id WHEN 128202 THEN 4239 ELSE population END WHERE id IN (128202);

UPDATE cities SET population = CASE id WHEN 127259 THEN 4235 ELSE population END WHERE id IN (127259);

UPDATE cities SET population = CASE id WHEN 114659 THEN 4226 ELSE population END WHERE id IN (114659);

UPDATE cities SET population = CASE id WHEN 129068 THEN 4223 ELSE population END WHERE id IN (129068);

UPDATE cities SET population = CASE id WHEN 125653 THEN 4216 ELSE population END WHERE id IN (125653);

UPDATE cities SET population = CASE id WHEN 115343 THEN 4210 ELSE population END WHERE id IN (115343);

UPDATE cities SET population = CASE id WHEN 124644 THEN 4208 ELSE population END WHERE id IN (124644);

UPDATE cities SET population = CASE id WHEN 119168 THEN 4204 ELSE population END WHERE id IN (119168);

UPDATE cities SET population = CASE id WHEN 124291 THEN 4198 ELSE population END WHERE id IN (124291);

UPDATE cities SET population = CASE id WHEN 114511 THEN 4197 ELSE population END WHERE id IN (114511);

UPDATE cities SET population = CASE id WHEN 141544 THEN 4195 ELSE population END WHERE id IN (141544);

UPDATE cities SET population = CASE id WHEN 113686 THEN 4194 ELSE population END WHERE id IN (113686);

UPDATE cities SET population = CASE id WHEN 128034 THEN 4192 ELSE population END WHERE id IN (128034);

UPDATE cities SET population = CASE id WHEN 113341 THEN 4190 WHEN 141118 THEN 4190 ELSE population END WHERE id IN (113341,141118);

UPDATE cities SET population = CASE id WHEN 141141 THEN 4189 ELSE population END WHERE id IN (141141);

UPDATE cities SET population = CASE id WHEN 125732 THEN 4183 ELSE population END WHERE id IN (125732);

UPDATE cities SET population = CASE id WHEN 116460 THEN 4180 ELSE population END WHERE id IN (116460);

UPDATE cities SET population = CASE id WHEN 141202 THEN 4177 ELSE population END WHERE id IN (141202);

UPDATE cities SET population = CASE id WHEN 117893 THEN 4176 ELSE population END WHERE id IN (117893);

UPDATE cities SET population = CASE id WHEN 123018 THEN 4172 ELSE population END WHERE id IN (123018);

UPDATE cities SET population = CASE id WHEN 113403 THEN 4168 ELSE population END WHERE id IN (113403);

UPDATE cities SET population = CASE id WHEN 113883 THEN 4167 ELSE population END WHERE id IN (113883);

UPDATE cities SET population = CASE id WHEN 128679 THEN 4166 ELSE population END WHERE id IN (128679);

UPDATE cities SET population = CASE id WHEN 141156 THEN 4161 ELSE population END WHERE id IN (141156);

UPDATE cities SET population = CASE id WHEN 119140 THEN 4155 WHEN 127182 THEN 4155 ELSE population END WHERE id IN (119140,127182);

UPDATE cities SET population = CASE id WHEN 127450 THEN 4151 ELSE population END WHERE id IN (127450);

UPDATE cities SET population = CASE id WHEN 113140 THEN 4146 ELSE population END WHERE id IN (113140);

UPDATE cities SET population = CASE id WHEN 122844 THEN 4136 ELSE population END WHERE id IN (122844);

UPDATE cities SET population = CASE id WHEN 116086 THEN 4134 WHEN 120466 THEN 4134 WHEN 127805 THEN 4134 ELSE population END WHERE id IN (116086,120466,127805);

UPDATE cities SET population = CASE id WHEN 126386 THEN 4131 ELSE population END WHERE id IN (126386);

UPDATE cities SET population = CASE id WHEN 114014 THEN 4128 ELSE population END WHERE id IN (114014);

UPDATE cities SET population = CASE id WHEN 141131 THEN 4125 ELSE population END WHERE id IN (141131);

UPDATE cities SET population = CASE id WHEN 129283 THEN 4124 ELSE population END WHERE id IN (129283);

UPDATE cities SET population = CASE id WHEN 114456 THEN 4117 ELSE population END WHERE id IN (114456);

UPDATE cities SET population = CASE id WHEN 128228 THEN 4112 ELSE population END WHERE id IN (128228);

UPDATE cities SET population = CASE id WHEN 125797 THEN 4103 ELSE population END WHERE id IN (125797);

UPDATE cities SET population = CASE id WHEN 126529 THEN 4101 ELSE population END WHERE id IN (126529);

UPDATE cities SET population = CASE id WHEN 116670 THEN 4099 ELSE population END WHERE id IN (116670);

UPDATE cities SET population = CASE id WHEN 114386 THEN 4094 WHEN 120007 THEN 4094 ELSE population END WHERE id IN (114386,120007);

UPDATE cities SET population = CASE id WHEN 120815 THEN 4092 ELSE population END WHERE id IN (120815);

UPDATE cities SET population = CASE id WHEN 113108 THEN 4091 ELSE population END WHERE id IN (113108);

UPDATE cities SET population = CASE id WHEN 128666 THEN 4090 ELSE population END WHERE id IN (128666);

UPDATE cities SET population = CASE id WHEN 117924 THEN 4083 ELSE population END WHERE id IN (117924);

UPDATE cities SET population = CASE id WHEN 129060 THEN 4082 ELSE population END WHERE id IN (129060);

UPDATE cities SET population = CASE id WHEN 119833 THEN 4078 ELSE population END WHERE id IN (119833);

UPDATE cities SET population = CASE id WHEN 116988 THEN 4077 ELSE population END WHERE id IN (116988);

UPDATE cities SET population = CASE id WHEN 120649 THEN 4071 ELSE population END WHERE id IN (120649);

UPDATE cities SET population = CASE id WHEN 115309 THEN 4067 ELSE population END WHERE id IN (115309);

UPDATE cities SET population = CASE id WHEN 117876 THEN 4065 ELSE population END WHERE id IN (117876);

UPDATE cities SET population = CASE id WHEN 111160 THEN 4061 WHEN 111468 THEN 4061 ELSE population END WHERE id IN (111160,111468);

UPDATE cities SET population = CASE id WHEN 117561 THEN 4058 WHEN 118737 THEN 4058 ELSE population END WHERE id IN (117561,118737);

UPDATE cities SET population = CASE id WHEN 116471 THEN 4057 ELSE population END WHERE id IN (116471);

UPDATE cities SET population = CASE id WHEN 129500 THEN 4055 ELSE population END WHERE id IN (129500);

UPDATE cities SET population = CASE id WHEN 122234 THEN 4049 ELSE population END WHERE id IN (122234);

UPDATE cities SET population = CASE id WHEN 125420 THEN 4044 ELSE population END WHERE id IN (125420);

UPDATE cities SET population = CASE id WHEN 117625 THEN 4043 ELSE population END WHERE id IN (117625);

UPDATE cities SET population = CASE id WHEN 111723 THEN 4037 ELSE population END WHERE id IN (111723);

UPDATE cities SET population = CASE id WHEN 116921 THEN 4036 ELSE population END WHERE id IN (116921);

UPDATE cities SET population = CASE id WHEN 114040 THEN 4028 ELSE population END WHERE id IN (114040);

UPDATE cities SET population = CASE id WHEN 126822 THEN 4027 ELSE population END WHERE id IN (126822);

UPDATE cities SET population = CASE id WHEN 120986 THEN 4026 WHEN 129071 THEN 4026 ELSE population END WHERE id IN (120986,129071);

UPDATE cities SET population = CASE id WHEN 116648 THEN 4018 WHEN 123508 THEN 4018 ELSE population END WHERE id IN (116648,123508);

UPDATE cities SET population = CASE id WHEN 116683 THEN 4013 ELSE population END WHERE id IN (116683);

UPDATE cities SET population = CASE id WHEN 114500 THEN 4007 ELSE population END WHERE id IN (114500);

UPDATE cities SET population = CASE id WHEN 114853 THEN 4000 ELSE population END WHERE id IN (114853);

UPDATE cities SET population = CASE id WHEN 125124 THEN 3999 ELSE population END WHERE id IN (125124);

UPDATE cities SET population = CASE id WHEN 123280 THEN 3995 ELSE population END WHERE id IN (123280);

UPDATE cities SET population = CASE id WHEN 115529 THEN 3994 ELSE population END WHERE id IN (115529);

UPDATE cities SET population = CASE id WHEN 111079 THEN 3993 WHEN 141536 THEN 3993 ELSE population END WHERE id IN (111079,141536);

UPDATE cities SET population = CASE id WHEN 128585 THEN 3990 ELSE population END WHERE id IN (128585);

UPDATE cities SET population = CASE id WHEN 141704 THEN 3982 ELSE population END WHERE id IN (141704);

UPDATE cities SET population = CASE id WHEN 128539 THEN 3981 ELSE population END WHERE id IN (128539);

UPDATE cities SET population = CASE id WHEN 126904 THEN 3979 ELSE population END WHERE id IN (126904);

UPDATE cities SET population = CASE id WHEN 122453 THEN 3976 ELSE population END WHERE id IN (122453);

UPDATE cities SET population = CASE id WHEN 111758 THEN 3972 ELSE population END WHERE id IN (111758);

UPDATE cities SET population = CASE id WHEN 119837 THEN 3969 ELSE population END WHERE id IN (119837);

UPDATE cities SET population = CASE id WHEN 125672 THEN 3967 ELSE population END WHERE id IN (125672);

UPDATE cities SET population = CASE id WHEN 128397 THEN 3964 ELSE population END WHERE id IN (128397);

UPDATE cities SET population = CASE id WHEN 120420 THEN 3949 ELSE population END WHERE id IN (120420);

UPDATE cities SET population = CASE id WHEN 128480 THEN 3945 ELSE population END WHERE id IN (128480);

UPDATE cities SET population = CASE id WHEN 115179 THEN 3941 ELSE population END WHERE id IN (115179);

UPDATE cities SET population = CASE id WHEN 123183 THEN 3939 ELSE population END WHERE id IN (123183);

UPDATE cities SET population = CASE id WHEN 121603 THEN 3935 WHEN 122043 THEN 3935 WHEN 128849 THEN 3935 ELSE population END WHERE id IN (121603,122043,128849);

UPDATE cities SET population = CASE id WHEN 113660 THEN 3930 ELSE population END WHERE id IN (113660);

UPDATE cities SET population = CASE id WHEN 121309 THEN 3927 ELSE population END WHERE id IN (121309);

UPDATE cities SET population = CASE id WHEN 118212 THEN 3924 WHEN 122432 THEN 3924 WHEN 141725 THEN 3924 ELSE population END WHERE id IN (118212,122432,141725);

UPDATE cities SET population = CASE id WHEN 124561 THEN 3923 ELSE population END WHERE id IN (124561);

UPDATE cities SET population = CASE id WHEN 113888 THEN 3918 ELSE population END WHERE id IN (113888);

UPDATE cities SET population = CASE id WHEN 111152 THEN 3917 ELSE population END WHERE id IN (111152);

UPDATE cities SET population = CASE id WHEN 129182 THEN 3909 ELSE population END WHERE id IN (129182);

UPDATE cities SET population = CASE id WHEN 120837 THEN 3906 ELSE population END WHERE id IN (120837);

UPDATE cities SET population = CASE id WHEN 114769 THEN 3895 ELSE population END WHERE id IN (114769);

UPDATE cities SET population = CASE id WHEN 120246 THEN 3887 ELSE population END WHERE id IN (120246);

UPDATE cities SET population = CASE id WHEN 113466 THEN 3886 WHEN 141746 THEN 3886 ELSE population END WHERE id IN (113466,141746);

UPDATE cities SET population = CASE id WHEN 116420 THEN 3885 ELSE population END WHERE id IN (116420);

UPDATE cities SET population = CASE id WHEN 129284 THEN 3883 ELSE population END WHERE id IN (129284);

UPDATE cities SET population = CASE id WHEN 121693 THEN 3881 ELSE population END WHERE id IN (121693);

UPDATE cities SET population = CASE id WHEN 112105 THEN 3880 WHEN 121302 THEN 3880 ELSE population END WHERE id IN (112105,121302);

UPDATE cities SET population = CASE id WHEN 123180 THEN 3877 ELSE population END WHERE id IN (123180);

UPDATE cities SET population = CASE id WHEN 115252 THEN 3875 ELSE population END WHERE id IN (115252);

UPDATE cities SET population = CASE id WHEN 112896 THEN 3868 WHEN 120987 THEN 3868 ELSE population END WHERE id IN (112896,120987);

UPDATE cities SET population = CASE id WHEN 111529 THEN 3865 WHEN 116585 THEN 3865 ELSE population END WHERE id IN (111529,116585);

UPDATE cities SET population = CASE id WHEN 126384 THEN 3863 ELSE population END WHERE id IN (126384);

UPDATE cities SET population = CASE id WHEN 127117 THEN 3862 ELSE population END WHERE id IN (127117);

UPDATE cities SET population = CASE id WHEN 113780 THEN 3861 ELSE population END WHERE id IN (113780);

UPDATE cities SET population = CASE id WHEN 119012 THEN 3859 ELSE population END WHERE id IN (119012);

UPDATE cities SET population = CASE id WHEN 126774 THEN 3856 ELSE population END WHERE id IN (126774);

UPDATE cities SET population = CASE id WHEN 111488 THEN 3843 WHEN 120047 THEN 3843 ELSE population END WHERE id IN (111488,120047);

UPDATE cities SET population = CASE id WHEN 120563 THEN 3839 ELSE population END WHERE id IN (120563);

UPDATE cities SET population = CASE id WHEN 126042 THEN 3838 ELSE population END WHERE id IN (126042);

UPDATE cities SET population = CASE id WHEN 120069 THEN 3833 ELSE population END WHERE id IN (120069);

UPDATE cities SET population = CASE id WHEN 125111 THEN 3830 ELSE population END WHERE id IN (125111);

UPDATE cities SET population = CASE id WHEN 126331 THEN 3827 ELSE population END WHERE id IN (126331);

UPDATE cities SET population = CASE id WHEN 122164 THEN 3825 ELSE population END WHERE id IN (122164);

UPDATE cities SET population = CASE id WHEN 112831 THEN 3807 ELSE population END WHERE id IN (112831);

UPDATE cities SET population = CASE id WHEN 112364 THEN 3806 WHEN 115830 THEN 3806 WHEN 116352 THEN 3806 ELSE population END WHERE id IN (112364,115830,116352);

UPDATE cities SET population = CASE id WHEN 115863 THEN 3805 ELSE population END WHERE id IN (115863);

UPDATE cities SET population = CASE id WHEN 141370 THEN 3804 ELSE population END WHERE id IN (141370);

UPDATE cities SET population = CASE id WHEN 117998 THEN 3800 ELSE population END WHERE id IN (117998);

UPDATE cities SET population = CASE id WHEN 111675 THEN 3799 WHEN 116388 THEN 3799 ELSE population END WHERE id IN (111675,116388);

UPDATE cities SET population = CASE id WHEN 119960 THEN 3789 ELSE population END WHERE id IN (119960);

UPDATE cities SET population = CASE id WHEN 119063 THEN 3788 ELSE population END WHERE id IN (119063);

UPDATE cities SET population = CASE id WHEN 128038 THEN 3785 ELSE population END WHERE id IN (128038);

UPDATE cities SET population = CASE id WHEN 120088 THEN 3778 ELSE population END WHERE id IN (120088);

UPDATE cities SET population = CASE id WHEN 113905 THEN 3773 WHEN 114242 THEN 3773 ELSE population END WHERE id IN (113905,114242);

UPDATE cities SET population = CASE id WHEN 114319 THEN 3771 ELSE population END WHERE id IN (114319);

UPDATE cities SET population = CASE id WHEN 125269 THEN 3765 ELSE population END WHERE id IN (125269);

UPDATE cities SET population = CASE id WHEN 119142 THEN 3762 ELSE population END WHERE id IN (119142);

UPDATE cities SET population = CASE id WHEN 115176 THEN 3759 ELSE population END WHERE id IN (115176);

UPDATE cities SET population = CASE id WHEN 126397 THEN 3755 ELSE population END WHERE id IN (126397);

UPDATE cities SET population = CASE id WHEN 113342 THEN 3752 ELSE population END WHERE id IN (113342);

UPDATE cities SET population = CASE id WHEN 116295 THEN 3751 ELSE population END WHERE id IN (116295);

UPDATE cities SET population = CASE id WHEN 114439 THEN 3746 ELSE population END WHERE id IN (114439);

UPDATE cities SET population = CASE id WHEN 118895 THEN 3741 ELSE population END WHERE id IN (118895);

UPDATE cities SET population = CASE id WHEN 128671 THEN 3739 ELSE population END WHERE id IN (128671);

UPDATE cities SET population = CASE id WHEN 116922 THEN 3738 ELSE population END WHERE id IN (116922);

UPDATE cities SET population = CASE id WHEN 119121 THEN 3737 ELSE population END WHERE id IN (119121);

UPDATE cities SET population = CASE id WHEN 125615 THEN 3735 ELSE population END WHERE id IN (125615);

UPDATE cities SET population = CASE id WHEN 123166 THEN 3728 WHEN 128917 THEN 3728 ELSE population END WHERE id IN (123166,128917);

UPDATE cities SET population = CASE id WHEN 120941 THEN 3725 ELSE population END WHERE id IN (120941);

UPDATE cities SET population = CASE id WHEN 118736 THEN 3721 ELSE population END WHERE id IN (118736);

UPDATE cities SET population = CASE id WHEN 113074 THEN 3720 ELSE population END WHERE id IN (113074);

UPDATE cities SET population = CASE id WHEN 141708 THEN 3719 ELSE population END WHERE id IN (141708);

UPDATE cities SET population = CASE id WHEN 112282 THEN 3713 ELSE population END WHERE id IN (112282);

UPDATE cities SET population = CASE id WHEN 123989 THEN 3708 ELSE population END WHERE id IN (123989);

UPDATE cities SET population = CASE id WHEN 118053 THEN 3704 WHEN 118235 THEN 3704 ELSE population END WHERE id IN (118053,118235);

UPDATE cities SET population = CASE id WHEN 115446 THEN 3702 WHEN 141664 THEN 3702 ELSE population END WHERE id IN (115446,141664);

UPDATE cities SET population = CASE id WHEN 117489 THEN 3695 ELSE population END WHERE id IN (117489);

UPDATE cities SET population = CASE id WHEN 129183 THEN 3694 ELSE population END WHERE id IN (129183);

UPDATE cities SET population = CASE id WHEN 116886 THEN 3692 ELSE population END WHERE id IN (116886);

UPDATE cities SET population = CASE id WHEN 118387 THEN 3686 ELSE population END WHERE id IN (118387);

UPDATE cities SET population = CASE id WHEN 114260 THEN 3685 ELSE population END WHERE id IN (114260);

UPDATE cities SET population = CASE id WHEN 116348 THEN 3684 ELSE population END WHERE id IN (116348);

UPDATE cities SET population = CASE id WHEN 141607 THEN 3681 ELSE population END WHERE id IN (141607);

UPDATE cities SET population = CASE id WHEN 119580 THEN 3680 ELSE population END WHERE id IN (119580);

UPDATE cities SET population = CASE id WHEN 116262 THEN 3669 WHEN 121275 THEN 3669 ELSE population END WHERE id IN (116262,121275);

UPDATE cities SET population = CASE id WHEN 115492 THEN 3664 ELSE population END WHERE id IN (115492);

UPDATE cities SET population = CASE id WHEN 129109 THEN 3659 ELSE population END WHERE id IN (129109);

UPDATE cities SET population = CASE id WHEN 126396 THEN 3653 WHEN 141545 THEN 3653 ELSE population END WHERE id IN (126396,141545);

UPDATE cities SET population = CASE id WHEN 115603 THEN 3650 WHEN 128794 THEN 3650 ELSE population END WHERE id IN (115603,128794);

UPDATE cities SET population = CASE id WHEN 120128 THEN 3649 WHEN 120834 THEN 3649 ELSE population END WHERE id IN (120128,120834);

UPDATE cities SET population = CASE id WHEN 113144 THEN 3648 ELSE population END WHERE id IN (113144);

UPDATE cities SET population = CASE id WHEN 120511 THEN 3647 ELSE population END WHERE id IN (120511);

UPDATE cities SET population = CASE id WHEN 129614 THEN 3642 ELSE population END WHERE id IN (129614);

UPDATE cities SET population = CASE id WHEN 113467 THEN 3638 ELSE population END WHERE id IN (113467);

UPDATE cities SET population = CASE id WHEN 141598 THEN 3637 ELSE population END WHERE id IN (141598);

UPDATE cities SET population = CASE id WHEN 112265 THEN 3631 ELSE population END WHERE id IN (112265);

UPDATE cities SET population = CASE id WHEN 114495 THEN 3629 ELSE population END WHERE id IN (114495);

UPDATE cities SET population = CASE id WHEN 122416 THEN 3622 ELSE population END WHERE id IN (122416);

UPDATE cities SET population = CASE id WHEN 116828 THEN 3619 WHEN 120943 THEN 3619 ELSE population END WHERE id IN (116828,120943);

UPDATE cities SET population = CASE id WHEN 121629 THEN 3616 ELSE population END WHERE id IN (121629);

UPDATE cities SET population = CASE id WHEN 127654 THEN 3612 ELSE population END WHERE id IN (127654);

UPDATE cities SET population = CASE id WHEN 119571 THEN 3610 ELSE population END WHERE id IN (119571);

UPDATE cities SET population = CASE id WHEN 123967 THEN 3601 ELSE population END WHERE id IN (123967);

UPDATE cities SET population = CASE id WHEN 128723 THEN 3600 ELSE population END WHERE id IN (128723);

UPDATE cities SET population = CASE id WHEN 129734 THEN 3596 ELSE population END WHERE id IN (129734);

UPDATE cities SET population = CASE id WHEN 113497 THEN 3591 ELSE population END WHERE id IN (113497);

UPDATE cities SET population = CASE id WHEN 123697 THEN 3590 ELSE population END WHERE id IN (123697);

UPDATE cities SET population = CASE id WHEN 115979 THEN 3586 ELSE population END WHERE id IN (115979);

UPDATE cities SET population = CASE id WHEN 113655 THEN 3584 ELSE population END WHERE id IN (113655);

UPDATE cities SET population = CASE id WHEN 123546 THEN 3580 ELSE population END WHERE id IN (123546);

UPDATE cities SET population = CASE id WHEN 121987 THEN 3576 ELSE population END WHERE id IN (121987);

UPDATE cities SET population = CASE id WHEN 113265 THEN 3575 ELSE population END WHERE id IN (113265);

UPDATE cities SET population = CASE id WHEN 116962 THEN 3574 WHEN 128620 THEN 3574 ELSE population END WHERE id IN (116962,128620);

UPDATE cities SET population = CASE id WHEN 129385 THEN 3573 ELSE population END WHERE id IN (129385);

UPDATE cities SET population = CASE id WHEN 113266 THEN 3570 ELSE population END WHERE id IN (113266);

UPDATE cities SET population = CASE id WHEN 125268 THEN 3569 WHEN 126960 THEN 3569 ELSE population END WHERE id IN (125268,126960);

UPDATE cities SET population = CASE id WHEN 112895 THEN 3566 ELSE population END WHERE id IN (112895);

UPDATE cities SET population = CASE id WHEN 111142 THEN 3564 ELSE population END WHERE id IN (111142);

UPDATE cities SET population = CASE id WHEN 121772 THEN 3562 ELSE population END WHERE id IN (121772);

UPDATE cities SET population = CASE id WHEN 120809 THEN 3553 WHEN 127782 THEN 3553 ELSE population END WHERE id IN (120809,127782);

UPDATE cities SET population = CASE id WHEN 122430 THEN 3552 ELSE population END WHERE id IN (122430);

UPDATE cities SET population = CASE id WHEN 112843 THEN 3551 ELSE population END WHERE id IN (112843);

UPDATE cities SET population = CASE id WHEN 124736 THEN 3550 ELSE population END WHERE id IN (124736);

UPDATE cities SET population = CASE id WHEN 120545 THEN 3546 ELSE population END WHERE id IN (120545);

UPDATE cities SET population = CASE id WHEN 118698 THEN 3544 ELSE population END WHERE id IN (118698);

UPDATE cities SET population = CASE id WHEN 125602 THEN 3542 ELSE population END WHERE id IN (125602);

UPDATE cities SET population = CASE id WHEN 111207 THEN 3536 ELSE population END WHERE id IN (111207);

UPDATE cities SET population = CASE id WHEN 122822 THEN 3534 WHEN 123685 THEN 3534 ELSE population END WHERE id IN (122822,123685);

UPDATE cities SET population = CASE id WHEN 118683 THEN 3532 ELSE population END WHERE id IN (118683);

UPDATE cities SET population = CASE id WHEN 127595 THEN 3520 ELSE population END WHERE id IN (127595);

UPDATE cities SET population = CASE id WHEN 120510 THEN 3519 ELSE population END WHERE id IN (120510);

UPDATE cities SET population = CASE id WHEN 124072 THEN 3516 ELSE population END WHERE id IN (124072);

UPDATE cities SET population = CASE id WHEN 127700 THEN 3511 ELSE population END WHERE id IN (127700);

UPDATE cities SET population = CASE id WHEN 113261 THEN 3505 ELSE population END WHERE id IN (113261);

UPDATE cities SET population = CASE id WHEN 128936 THEN 3503 ELSE population END WHERE id IN (128936);

UPDATE cities SET population = CASE id WHEN 116218 THEN 3500 WHEN 118927 THEN 3500 ELSE population END WHERE id IN (116218,118927);

UPDATE cities SET population = CASE id WHEN 117162 THEN 3493 WHEN 117498 THEN 3493 ELSE population END WHERE id IN (117162,117498);

UPDATE cities SET population = CASE id WHEN 115223 THEN 3482 ELSE population END WHERE id IN (115223);

UPDATE cities SET population = CASE id WHEN 122845 THEN 3480 WHEN 125666 THEN 3480 ELSE population END WHERE id IN (122845,125666);

UPDATE cities SET population = CASE id WHEN 126783 THEN 3475 ELSE population END WHERE id IN (126783);

UPDATE cities SET population = CASE id WHEN 119923 THEN 3466 WHEN 128545 THEN 3466 ELSE population END WHERE id IN (119923,128545);

UPDATE cities SET population = CASE id WHEN 116906 THEN 3460 ELSE population END WHERE id IN (116906);

UPDATE cities SET population = CASE id WHEN 125110 THEN 3459 ELSE population END WHERE id IN (125110);

UPDATE cities SET population = CASE id WHEN 118820 THEN 3458 ELSE population END WHERE id IN (118820);

UPDATE cities SET population = CASE id WHEN 141390 THEN 3457 ELSE population END WHERE id IN (141390);

UPDATE cities SET population = CASE id WHEN 112860 THEN 3451 ELSE population END WHERE id IN (112860);

UPDATE cities SET population = CASE id WHEN 125095 THEN 3449 ELSE population END WHERE id IN (125095);

UPDATE cities SET population = CASE id WHEN 127983 THEN 3447 ELSE population END WHERE id IN (127983);

UPDATE cities SET population = CASE id WHEN 126197 THEN 3440 ELSE population END WHERE id IN (126197);

UPDATE cities SET population = CASE id WHEN 111038 THEN 3439 ELSE population END WHERE id IN (111038);

UPDATE cities SET population = CASE id WHEN 119126 THEN 3433 ELSE population END WHERE id IN (119126);

UPDATE cities SET population = CASE id WHEN 121147 THEN 3432 ELSE population END WHERE id IN (121147);

UPDATE cities SET population = CASE id WHEN 121073 THEN 3430 ELSE population END WHERE id IN (121073);

UPDATE cities SET population = CASE id WHEN 127845 THEN 3427 ELSE population END WHERE id IN (127845);

UPDATE cities SET population = CASE id WHEN 120909 THEN 3423 ELSE population END WHERE id IN (120909);

UPDATE cities SET population = CASE id WHEN 122672 THEN 3421 ELSE population END WHERE id IN (122672);

UPDATE cities SET population = CASE id WHEN 117657 THEN 3417 WHEN 141677 THEN 3417 ELSE population END WHERE id IN (117657,141677);

UPDATE cities SET population = CASE id WHEN 117249 THEN 3414 ELSE population END WHERE id IN (117249);

UPDATE cities SET population = CASE id WHEN 123776 THEN 3413 ELSE population END WHERE id IN (123776);

UPDATE cities SET population = CASE id WHEN 124687 THEN 3412 ELSE population END WHERE id IN (124687);

UPDATE cities SET population = CASE id WHEN 141802 THEN 3410 ELSE population END WHERE id IN (141802);

UPDATE cities SET population = CASE id WHEN 116085 THEN 3408 ELSE population END WHERE id IN (116085);

UPDATE cities SET population = CASE id WHEN 112730 THEN 3405 ELSE population END WHERE id IN (112730);

UPDATE cities SET population = CASE id WHEN 117665 THEN 3403 WHEN 141497 THEN 3403 ELSE population END WHERE id IN (117665,141497);

UPDATE cities SET population = CASE id WHEN 116216 THEN 3401 ELSE population END WHERE id IN (116216);

UPDATE cities SET population = CASE id WHEN 126236 THEN 3398 ELSE population END WHERE id IN (126236);

UPDATE cities SET population = CASE id WHEN 112296 THEN 3393 WHEN 126262 THEN 3393 ELSE population END WHERE id IN (112296,126262);

UPDATE cities SET population = CASE id WHEN 111787 THEN 3383 ELSE population END WHERE id IN (111787);

UPDATE cities SET population = CASE id WHEN 128521 THEN 3376 ELSE population END WHERE id IN (128521);

UPDATE cities SET population = CASE id WHEN 126887 THEN 3375 ELSE population END WHERE id IN (126887);

UPDATE cities SET population = CASE id WHEN 125355 THEN 3374 ELSE population END WHERE id IN (125355);

UPDATE cities SET population = CASE id WHEN 116990 THEN 3369 ELSE population END WHERE id IN (116990);

UPDATE cities SET population = CASE id WHEN 114285 THEN 3368 WHEN 128961 THEN 3368 ELSE population END WHERE id IN (114285,128961);

UPDATE cities SET population = CASE id WHEN 114256 THEN 3361 ELSE population END WHERE id IN (114256);

UPDATE cities SET population = CASE id WHEN 122860 THEN 3356 ELSE population END WHERE id IN (122860);

UPDATE cities SET population = CASE id WHEN 129419 THEN 3351 ELSE population END WHERE id IN (129419);

UPDATE cities SET population = CASE id WHEN 112325 THEN 3350 ELSE population END WHERE id IN (112325);

UPDATE cities SET population = CASE id WHEN 128616 THEN 3343 WHEN 141171 THEN 3343 ELSE population END WHERE id IN (128616,141171);

UPDATE cities SET population = CASE id WHEN 120288 THEN 3342 WHEN 123331 THEN 3342 ELSE population END WHERE id IN (120288,123331);

UPDATE cities SET population = CASE id WHEN 129420 THEN 3340 ELSE population END WHERE id IN (129420);

UPDATE cities SET population = CASE id WHEN 111630 THEN 3339 ELSE population END WHERE id IN (111630);

UPDATE cities SET population = CASE id WHEN 115563 THEN 3338 ELSE population END WHERE id IN (115563);

UPDATE cities SET population = CASE id WHEN 124228 THEN 3337 ELSE population END WHERE id IN (124228);

UPDATE cities SET population = CASE id WHEN 125318 THEN 3336 ELSE population END WHERE id IN (125318);

UPDATE cities SET population = CASE id WHEN 128960 THEN 3333 ELSE population END WHERE id IN (128960);

UPDATE cities SET population = CASE id WHEN 113350 THEN 3331 ELSE population END WHERE id IN (113350);

UPDATE cities SET population = CASE id WHEN 141552 THEN 3323 ELSE population END WHERE id IN (141552);

UPDATE cities SET population = CASE id WHEN 120013 THEN 3322 WHEN 126852 THEN 3322 ELSE population END WHERE id IN (120013,126852);

UPDATE cities SET population = CASE id WHEN 112413 THEN 3321 ELSE population END WHERE id IN (112413);

UPDATE cities SET population = CASE id WHEN 111693 THEN 3319 ELSE population END WHERE id IN (111693);

UPDATE cities SET population = CASE id WHEN 125977 THEN 3318 ELSE population END WHERE id IN (125977);

UPDATE cities SET population = CASE id WHEN 115522 THEN 3317 ELSE population END WHERE id IN (115522);

UPDATE cities SET population = CASE id WHEN 114702 THEN 3316 ELSE population END WHERE id IN (114702);

UPDATE cities SET population = CASE id WHEN 112324 THEN 3315 ELSE population END WHERE id IN (112324);

UPDATE cities SET population = CASE id WHEN 119143 THEN 3312 ELSE population END WHERE id IN (119143);

UPDATE cities SET population = CASE id WHEN 141770 THEN 3309 ELSE population END WHERE id IN (141770);

UPDATE cities SET population = CASE id WHEN 122798 THEN 3308 WHEN 124243 THEN 3308 ELSE population END WHERE id IN (122798,124243);

UPDATE cities SET population = CASE id WHEN 118139 THEN 3306 WHEN 141369 THEN 3306 ELSE population END WHERE id IN (118139,141369);

UPDATE cities SET population = CASE id WHEN 111350 THEN 3304 ELSE population END WHERE id IN (111350);

UPDATE cities SET population = CASE id WHEN 117024 THEN 3299 WHEN 118731 THEN 3299 WHEN 121139 THEN 3299 WHEN 122381 THEN 3299 ELSE population END WHERE id IN (117024,118731,121139,122381);

UPDATE cities SET population = CASE id WHEN 116673 THEN 3293 ELSE population END WHERE id IN (116673);

UPDATE cities SET population = CASE id WHEN 141839 THEN 3292 ELSE population END WHERE id IN (141839);

UPDATE cities SET population = CASE id WHEN 112838 THEN 3291 WHEN 113048 THEN 3291 WHEN 126821 THEN 3291 ELSE population END WHERE id IN (112838,113048,126821);

UPDATE cities SET population = CASE id WHEN 112712 THEN 3290 ELSE population END WHERE id IN (112712);

UPDATE cities SET population = CASE id WHEN 117971 THEN 3289 ELSE population END WHERE id IN (117971);

UPDATE cities SET population = CASE id WHEN 118941 THEN 3281 WHEN 120593 THEN 3281 ELSE population END WHERE id IN (118941,120593);

UPDATE cities SET population = CASE id WHEN 114657 THEN 3280 ELSE population END WHERE id IN (114657);

UPDATE cities SET population = CASE id WHEN 141612 THEN 3277 ELSE population END WHERE id IN (141612);

UPDATE cities SET population = CASE id WHEN 141187 THEN 3271 ELSE population END WHERE id IN (141187);

UPDATE cities SET population = CASE id WHEN 118176 THEN 3269 ELSE population END WHERE id IN (118176);

UPDATE cities SET population = CASE id WHEN 126271 THEN 3268 ELSE population END WHERE id IN (126271);

UPDATE cities SET population = CASE id WHEN 141127 THEN 3267 ELSE population END WHERE id IN (141127);

UPDATE cities SET population = CASE id WHEN 126758 THEN 3265 ELSE population END WHERE id IN (126758);

UPDATE cities SET population = CASE id WHEN 125534 THEN 3260 ELSE population END WHERE id IN (125534);

UPDATE cities SET population = CASE id WHEN 111580 THEN 3255 WHEN 125164 THEN 3255 ELSE population END WHERE id IN (111580,125164);

UPDATE cities SET population = CASE id WHEN 127263 THEN 3252 ELSE population END WHERE id IN (127263);

UPDATE cities SET population = CASE id WHEN 121841 THEN 3250 ELSE population END WHERE id IN (121841);

UPDATE cities SET population = CASE id WHEN 119172 THEN 3247 ELSE population END WHERE id IN (119172);

UPDATE cities SET population = CASE id WHEN 113124 THEN 3246 WHEN 120464 THEN 3246 ELSE population END WHERE id IN (113124,120464);

UPDATE cities SET population = CASE id WHEN 112183 THEN 3240 ELSE population END WHERE id IN (112183);

UPDATE cities SET population = CASE id WHEN 117803 THEN 3238 ELSE population END WHERE id IN (117803);

UPDATE cities SET population = CASE id WHEN 116836 THEN 3237 ELSE population END WHERE id IN (116836);

UPDATE cities SET population = CASE id WHEN 119070 THEN 3234 ELSE population END WHERE id IN (119070);

UPDATE cities SET population = CASE id WHEN 128216 THEN 3230 ELSE population END WHERE id IN (128216);

UPDATE cities SET population = CASE id WHEN 118124 THEN 3226 WHEN 121606 THEN 3226 ELSE population END WHERE id IN (118124,121606);

UPDATE cities SET population = CASE id WHEN 112507 THEN 3225 ELSE population END WHERE id IN (112507);

UPDATE cities SET population = CASE id WHEN 127986 THEN 3217 ELSE population END WHERE id IN (127986);

UPDATE cities SET population = CASE id WHEN 114245 THEN 3216 ELSE population END WHERE id IN (114245);

UPDATE cities SET population = CASE id WHEN 115531 THEN 3200 WHEN 127675 THEN 3200 ELSE population END WHERE id IN (115531,127675);

UPDATE cities SET population = CASE id WHEN 125333 THEN 3199 ELSE population END WHERE id IN (125333);

UPDATE cities SET population = CASE id WHEN 116039 THEN 3197 WHEN 118399 THEN 3197 ELSE population END WHERE id IN (116039,118399);

UPDATE cities SET population = CASE id WHEN 124378 THEN 3196 ELSE population END WHERE id IN (124378);

UPDATE cities SET population = CASE id WHEN 129267 THEN 3195 ELSE population END WHERE id IN (129267);

UPDATE cities SET population = CASE id WHEN 122724 THEN 3193 ELSE population END WHERE id IN (122724);

UPDATE cities SET population = CASE id WHEN 112728 THEN 3191 WHEN 113661 THEN 3191 ELSE population END WHERE id IN (112728,113661);

UPDATE cities SET population = CASE id WHEN 114155 THEN 3187 ELSE population END WHERE id IN (114155);

UPDATE cities SET population = CASE id WHEN 121567 THEN 3185 ELSE population END WHERE id IN (121567);

UPDATE cities SET population = CASE id WHEN 127613 THEN 3184 ELSE population END WHERE id IN (127613);

UPDATE cities SET population = CASE id WHEN 118596 THEN 3183 ELSE population END WHERE id IN (118596);

UPDATE cities SET population = CASE id WHEN 110985 THEN 3182 WHEN 141479 THEN 3182 ELSE population END WHERE id IN (110985,141479);

UPDATE cities SET population = CASE id WHEN 123457 THEN 3179 WHEN 141812 THEN 3179 ELSE population END WHERE id IN (123457,141812);

UPDATE cities SET population = CASE id WHEN 113729 THEN 3175 WHEN 128516 THEN 3175 ELSE population END WHERE id IN (113729,128516);

UPDATE cities SET population = CASE id WHEN 124155 THEN 3173 ELSE population END WHERE id IN (124155);

UPDATE cities SET population = CASE id WHEN 125654 THEN 3165 ELSE population END WHERE id IN (125654);

UPDATE cities SET population = CASE id WHEN 115212 THEN 3157 ELSE population END WHERE id IN (115212);

UPDATE cities SET population = CASE id WHEN 117883 THEN 3155 ELSE population END WHERE id IN (117883);

UPDATE cities SET population = CASE id WHEN 125196 THEN 3153 ELSE population END WHERE id IN (125196);

UPDATE cities SET population = CASE id WHEN 124017 THEN 3152 WHEN 141502 THEN 3152 ELSE population END WHERE id IN (124017,141502);

UPDATE cities SET population = CASE id WHEN 141522 THEN 3151 ELSE population END WHERE id IN (141522);

UPDATE cities SET population = CASE id WHEN 124299 THEN 3150 WHEN 125203 THEN 3150 ELSE population END WHERE id IN (124299,125203);

UPDATE cities SET population = CASE id WHEN 112274 THEN 3149 ELSE population END WHERE id IN (112274);

UPDATE cities SET population = CASE id WHEN 114492 THEN 3146 WHEN 116790 THEN 3146 ELSE population END WHERE id IN (114492,116790);

UPDATE cities SET population = CASE id WHEN 111164 THEN 3144 ELSE population END WHERE id IN (111164);

UPDATE cities SET population = CASE id WHEN 141201 THEN 3137 ELSE population END WHERE id IN (141201);

UPDATE cities SET population = CASE id WHEN 116230 THEN 3136 ELSE population END WHERE id IN (116230);

UPDATE cities SET population = CASE id WHEN 122574 THEN 3132 ELSE population END WHERE id IN (122574);

UPDATE cities SET population = CASE id WHEN 124226 THEN 3131 ELSE population END WHERE id IN (124226);

UPDATE cities SET population = CASE id WHEN 116458 THEN 3128 ELSE population END WHERE id IN (116458);

UPDATE cities SET population = CASE id WHEN 111197 THEN 3126 ELSE population END WHERE id IN (111197);

UPDATE cities SET population = CASE id WHEN 119738 THEN 3125 ELSE population END WHERE id IN (119738);

UPDATE cities SET population = CASE id WHEN 114197 THEN 3123 ELSE population END WHERE id IN (114197);

UPDATE cities SET population = CASE id WHEN 141269 THEN 3121 ELSE population END WHERE id IN (141269);

UPDATE cities SET population = CASE id WHEN 114310 THEN 3119 ELSE population END WHERE id IN (114310);

UPDATE cities SET population = CASE id WHEN 118602 THEN 3114 ELSE population END WHERE id IN (118602);

UPDATE cities SET population = CASE id WHEN 117093 THEN 3107 ELSE population END WHERE id IN (117093);

UPDATE cities SET population = CASE id WHEN 129078 THEN 3105 ELSE population END WHERE id IN (129078);

UPDATE cities SET population = CASE id WHEN 124458 THEN 3103 WHEN 128503 THEN 3103 ELSE population END WHERE id IN (124458,128503);

UPDATE cities SET population = CASE id WHEN 116353 THEN 3099 WHEN 121585 THEN 3099 ELSE population END WHERE id IN (116353,121585);

UPDATE cities SET population = CASE id WHEN 114830 THEN 3094 ELSE population END WHERE id IN (114830);

UPDATE cities SET population = CASE id WHEN 114546 THEN 3092 WHEN 122893 THEN 3092 ELSE population END WHERE id IN (114546,122893);

UPDATE cities SET population = CASE id WHEN 127372 THEN 3091 ELSE population END WHERE id IN (127372);

UPDATE cities SET population = CASE id WHEN 129030 THEN 3090 ELSE population END WHERE id IN (129030);

UPDATE cities SET population = CASE id WHEN 112476 THEN 3084 ELSE population END WHERE id IN (112476);

UPDATE cities SET population = CASE id WHEN 122180 THEN 3079 WHEN 129035 THEN 3079 ELSE population END WHERE id IN (122180,129035);

UPDATE cities SET population = CASE id WHEN 118146 THEN 3076 WHEN 118447 THEN 3076 ELSE population END WHERE id IN (118146,118447);

UPDATE cities SET population = CASE id WHEN 141277 THEN 3075 ELSE population END WHERE id IN (141277);

UPDATE cities SET population = CASE id WHEN 116903 THEN 3070 ELSE population END WHERE id IN (116903);

UPDATE cities SET population = CASE id WHEN 112990 THEN 3067 ELSE population END WHERE id IN (112990);

UPDATE cities SET population = CASE id WHEN 111461 THEN 3065 ELSE population END WHERE id IN (111461);

UPDATE cities SET population = CASE id WHEN 126892 THEN 3055 ELSE population END WHERE id IN (126892);

UPDATE cities SET population = CASE id WHEN 128201 THEN 3054 ELSE population END WHERE id IN (128201);

UPDATE cities SET population = CASE id WHEN 120690 THEN 3052 ELSE population END WHERE id IN (120690);

UPDATE cities SET population = CASE id WHEN 123861 THEN 3046 ELSE population END WHERE id IN (123861);

UPDATE cities SET population = CASE id WHEN 129638 THEN 3044 ELSE population END WHERE id IN (129638);

UPDATE cities SET population = CASE id WHEN 125238 THEN 3041 WHEN 141417 THEN 3041 ELSE population END WHERE id IN (125238,141417);

UPDATE cities SET population = CASE id WHEN 116956 THEN 3035 ELSE population END WHERE id IN (116956);

UPDATE cities SET population = CASE id WHEN 121913 THEN 3030 ELSE population END WHERE id IN (121913);

UPDATE cities SET population = CASE id WHEN 129297 THEN 3028 ELSE population END WHERE id IN (129297);

UPDATE cities SET population = CASE id WHEN 118093 THEN 3025 ELSE population END WHERE id IN (118093);

UPDATE cities SET population = CASE id WHEN 120158 THEN 3024 ELSE population END WHERE id IN (120158);

UPDATE cities SET population = CASE id WHEN 117228 THEN 3023 ELSE population END WHERE id IN (117228);

UPDATE cities SET population = CASE id WHEN 121848 THEN 3018 ELSE population END WHERE id IN (121848);

UPDATE cities SET population = CASE id WHEN 122675 THEN 3017 ELSE population END WHERE id IN (122675);

UPDATE cities SET population = CASE id WHEN 112042 THEN 3015 ELSE population END WHERE id IN (112042);

UPDATE cities SET population = CASE id WHEN 111059 THEN 3014 WHEN 127621 THEN 3014 ELSE population END WHERE id IN (111059,127621);

UPDATE cities SET population = CASE id WHEN 129044 THEN 3008 ELSE population END WHERE id IN (129044);

UPDATE cities SET population = CASE id WHEN 111995 THEN 3007 WHEN 123849 THEN 3007 ELSE population END WHERE id IN (111995,123849);

UPDATE cities SET population = CASE id WHEN 117410 THEN 3006 WHEN 121929 THEN 3006 ELSE population END WHERE id IN (117410,121929);

UPDATE cities SET population = CASE id WHEN 118593 THEN 3005 ELSE population END WHERE id IN (118593);

UPDATE cities SET population = CASE id WHEN 124005 THEN 3004 WHEN 125620 THEN 3004 ELSE population END WHERE id IN (124005,125620);

UPDATE cities SET population = CASE id WHEN 119831 THEN 3003 ELSE population END WHERE id IN (119831);

UPDATE cities SET population = CASE id WHEN 122481 THEN 3002 ELSE population END WHERE id IN (122481);

UPDATE cities SET population = CASE id WHEN 121930 THEN 3001 ELSE population END WHERE id IN (121930);

UPDATE cities SET population = CASE id WHEN 128470 THEN 3000 ELSE population END WHERE id IN (128470);

UPDATE cities SET population = CASE id WHEN 141799 THEN 2999 ELSE population END WHERE id IN (141799);

UPDATE cities SET population = CASE id WHEN 112788 THEN 2996 ELSE population END WHERE id IN (112788);

UPDATE cities SET population = CASE id WHEN 113891 THEN 2994 WHEN 126884 THEN 2994 ELSE population END WHERE id IN (113891,126884);

UPDATE cities SET population = CASE id WHEN 111424 THEN 2991 WHEN 124587 THEN 2991 ELSE population END WHERE id IN (111424,124587);

UPDATE cities SET population = CASE id WHEN 114241 THEN 2990 ELSE population END WHERE id IN (114241);

UPDATE cities SET population = CASE id WHEN 121235 THEN 2986 ELSE population END WHERE id IN (121235);

UPDATE cities SET population = CASE id WHEN 120325 THEN 2983 ELSE population END WHERE id IN (120325);

UPDATE cities SET population = CASE id WHEN 113102 THEN 2976 ELSE population END WHERE id IN (113102);

UPDATE cities SET population = CASE id WHEN 125526 THEN 2972 ELSE population END WHERE id IN (125526);

UPDATE cities SET population = CASE id WHEN 121694 THEN 2970 WHEN 141129 THEN 2970 ELSE population END WHERE id IN (121694,141129);

UPDATE cities SET population = CASE id WHEN 115964 THEN 2969 WHEN 125370 THEN 2969 ELSE population END WHERE id IN (115964,125370);

UPDATE cities SET population = CASE id WHEN 141385 THEN 2968 ELSE population END WHERE id IN (141385);

UPDATE cities SET population = CASE id WHEN 118022 THEN 2967 WHEN 127272 THEN 2967 ELSE population END WHERE id IN (118022,127272);

UPDATE cities SET population = CASE id WHEN 111053 THEN 2966 ELSE population END WHERE id IN (111053);

UPDATE cities SET population = CASE id WHEN 119885 THEN 2965 WHEN 126867 THEN 2965 WHEN 129287 THEN 2965 ELSE population END WHERE id IN (119885,126867,129287);

UPDATE cities SET population = CASE id WHEN 122364 THEN 2964 ELSE population END WHERE id IN (122364);

UPDATE cities SET population = CASE id WHEN 125877 THEN 2962 ELSE population END WHERE id IN (125877);

UPDATE cities SET population = CASE id WHEN 111486 THEN 2960 ELSE population END WHERE id IN (111486);

UPDATE cities SET population = CASE id WHEN 118962 THEN 2954 ELSE population END WHERE id IN (118962);

UPDATE cities SET population = CASE id WHEN 113834 THEN 2953 ELSE population END WHERE id IN (113834);

UPDATE cities SET population = CASE id WHEN 113730 THEN 2949 ELSE population END WHERE id IN (113730);

UPDATE cities SET population = CASE id WHEN 124108 THEN 2948 ELSE population END WHERE id IN (124108);

UPDATE cities SET population = CASE id WHEN 128471 THEN 2945 ELSE population END WHERE id IN (128471);

UPDATE cities SET population = CASE id WHEN 121799 THEN 2944 ELSE population END WHERE id IN (121799);

UPDATE cities SET population = CASE id WHEN 127280 THEN 2943 ELSE population END WHERE id IN (127280);

UPDATE cities SET population = CASE id WHEN 117140 THEN 2940 ELSE population END WHERE id IN (117140);

UPDATE cities SET population = CASE id WHEN 118524 THEN 2939 ELSE population END WHERE id IN (118524);

UPDATE cities SET population = CASE id WHEN 117890 THEN 2937 ELSE population END WHERE id IN (117890);

UPDATE cities SET population = CASE id WHEN 116225 THEN 2936 WHEN 126971 THEN 2936 ELSE population END WHERE id IN (116225,126971);

UPDATE cities SET population = CASE id WHEN 126318 THEN 2934 ELSE population END WHERE id IN (126318);

UPDATE cities SET population = CASE id WHEN 115570 THEN 2933 ELSE population END WHERE id IN (115570);

UPDATE cities SET population = CASE id WHEN 116255 THEN 2931 ELSE population END WHERE id IN (116255);

UPDATE cities SET population = CASE id WHEN 117022 THEN 2930 WHEN 128436 THEN 2930 WHEN 129314 THEN 2930 ELSE population END WHERE id IN (117022,128436,129314);

UPDATE cities SET population = CASE id WHEN 120993 THEN 2929 ELSE population END WHERE id IN (120993);

UPDATE cities SET population = CASE id WHEN 117651 THEN 2919 ELSE population END WHERE id IN (117651);

UPDATE cities SET population = CASE id WHEN 122134 THEN 2915 ELSE population END WHERE id IN (122134);

UPDATE cities SET population = CASE id WHEN 120049 THEN 2914 ELSE population END WHERE id IN (120049);

UPDATE cities SET population = CASE id WHEN 116311 THEN 2912 ELSE population END WHERE id IN (116311);

UPDATE cities SET population = CASE id WHEN 125207 THEN 2911 ELSE population END WHERE id IN (125207);

UPDATE cities SET population = CASE id WHEN 121940 THEN 2908 ELSE population END WHERE id IN (121940);

UPDATE cities SET population = CASE id WHEN 115809 THEN 2900 ELSE population END WHERE id IN (115809);

UPDATE cities SET population = CASE id WHEN 122365 THEN 2899 ELSE population END WHERE id IN (122365);

UPDATE cities SET population = CASE id WHEN 112388 THEN 2892 WHEN 116459 THEN 2892 ELSE population END WHERE id IN (112388,116459);

UPDATE cities SET population = CASE id WHEN 127619 THEN 2890 ELSE population END WHERE id IN (127619);

UPDATE cities SET population = CASE id WHEN 126891 THEN 2889 ELSE population END WHERE id IN (126891);

UPDATE cities SET population = CASE id WHEN 111329 THEN 2888 ELSE population END WHERE id IN (111329);

UPDATE cities SET population = CASE id WHEN 113669 THEN 2886 ELSE population END WHERE id IN (113669);

UPDATE cities SET population = CASE id WHEN 120505 THEN 2884 ELSE population END WHERE id IN (120505);

UPDATE cities SET population = CASE id WHEN 118248 THEN 2883 WHEN 119105 THEN 2883 ELSE population END WHERE id IN (118248,119105);

UPDATE cities SET population = CASE id WHEN 118320 THEN 2880 WHEN 120985 THEN 2880 ELSE population END WHERE id IN (118320,120985);

UPDATE cities SET population = CASE id WHEN 114409 THEN 2870 ELSE population END WHERE id IN (114409);

UPDATE cities SET population = CASE id WHEN 126341 THEN 2865 ELSE population END WHERE id IN (126341);

UPDATE cities SET population = CASE id WHEN 126601 THEN 2863 ELSE population END WHERE id IN (126601);

UPDATE cities SET population = CASE id WHEN 111421 THEN 2861 ELSE population END WHERE id IN (111421);

UPDATE cities SET population = CASE id WHEN 125170 THEN 2859 ELSE population END WHERE id IN (125170);

UPDATE cities SET population = CASE id WHEN 124919 THEN 2855 ELSE population END WHERE id IN (124919);

UPDATE cities SET population = CASE id WHEN 117892 THEN 2853 ELSE population END WHERE id IN (117892);

UPDATE cities SET population = CASE id WHEN 116340 THEN 2851 ELSE population END WHERE id IN (116340);

UPDATE cities SET population = CASE id WHEN 111078 THEN 2845 ELSE population END WHERE id IN (111078);

UPDATE cities SET population = CASE id WHEN 115604 THEN 2841 ELSE population END WHERE id IN (115604);

UPDATE cities SET population = CASE id WHEN 119696 THEN 2836 ELSE population END WHERE id IN (119696);

UPDATE cities SET population = CASE id WHEN 125218 THEN 2835 ELSE population END WHERE id IN (125218);

UPDATE cities SET population = CASE id WHEN 123281 THEN 2829 ELSE population END WHERE id IN (123281);

UPDATE cities SET population = CASE id WHEN 127131 THEN 2819 ELSE population END WHERE id IN (127131);

UPDATE cities SET population = CASE id WHEN 112927 THEN 2816 ELSE population END WHERE id IN (112927);

UPDATE cities SET population = CASE id WHEN 124920 THEN 2815 ELSE population END WHERE id IN (124920);

UPDATE cities SET population = CASE id WHEN 122864 THEN 2814 ELSE population END WHERE id IN (122864);

UPDATE cities SET population = CASE id WHEN 127752 THEN 2812 ELSE population END WHERE id IN (127752);

UPDATE cities SET population = CASE id WHEN 116014 THEN 2809 ELSE population END WHERE id IN (116014);

UPDATE cities SET population = CASE id WHEN 129379 THEN 2808 ELSE population END WHERE id IN (129379);

UPDATE cities SET population = CASE id WHEN 129343 THEN 2805 ELSE population END WHERE id IN (129343);

UPDATE cities SET population = CASE id WHEN 119750 THEN 2804 ELSE population END WHERE id IN (119750);

UPDATE cities SET population = CASE id WHEN 126187 THEN 2790 ELSE population END WHERE id IN (126187);

UPDATE cities SET population = CASE id WHEN 113190 THEN 2787 ELSE population END WHERE id IN (113190);

UPDATE cities SET population = CASE id WHEN 115829 THEN 2786 WHEN 120016 THEN 2786 ELSE population END WHERE id IN (115829,120016);

UPDATE cities SET population = CASE id WHEN 112141 THEN 2784 ELSE population END WHERE id IN (112141);

UPDATE cities SET population = CASE id WHEN 114991 THEN 2783 WHEN 126886 THEN 2783 ELSE population END WHERE id IN (114991,126886);

UPDATE cities SET population = CASE id WHEN 141280 THEN 2782 ELSE population END WHERE id IN (141280);

UPDATE cities SET population = CASE id WHEN 112072 THEN 2781 ELSE population END WHERE id IN (112072);

UPDATE cities SET population = CASE id WHEN 114204 THEN 2774 ELSE population END WHERE id IN (114204);

UPDATE cities SET population = CASE id WHEN 121905 THEN 2772 ELSE population END WHERE id IN (121905);

UPDATE cities SET population = CASE id WHEN 126301 THEN 2770 ELSE population END WHERE id IN (126301);

UPDATE cities SET population = CASE id WHEN 141458 THEN 2768 ELSE population END WHERE id IN (141458);

UPDATE cities SET population = CASE id WHEN 121219 THEN 2766 ELSE population END WHERE id IN (121219);

UPDATE cities SET population = CASE id WHEN 129507 THEN 2762 ELSE population END WHERE id IN (129507);

UPDATE cities SET population = CASE id WHEN 111862 THEN 2761 ELSE population END WHERE id IN (111862);

UPDATE cities SET population = CASE id WHEN 113004 THEN 2760 WHEN 117227 THEN 2760 ELSE population END WHERE id IN (113004,117227);

UPDATE cities SET population = CASE id WHEN 113087 THEN 2757 ELSE population END WHERE id IN (113087);

UPDATE cities SET population = CASE id WHEN 121100 THEN 2753 WHEN 122399 THEN 2753 ELSE population END WHERE id IN (121100,122399);

UPDATE cities SET population = CASE id WHEN 127827 THEN 2752 ELSE population END WHERE id IN (127827);

UPDATE cities SET population = CASE id WHEN 118086 THEN 2750 ELSE population END WHERE id IN (118086);

UPDATE cities SET population = CASE id WHEN 112806 THEN 2749 ELSE population END WHERE id IN (112806);

UPDATE cities SET population = CASE id WHEN 123193 THEN 2748 WHEN 125212 THEN 2748 ELSE population END WHERE id IN (123193,125212);

UPDATE cities SET population = CASE id WHEN 117497 THEN 2747 ELSE population END WHERE id IN (117497);

UPDATE cities SET population = CASE id WHEN 114373 THEN 2745 ELSE population END WHERE id IN (114373);

UPDATE cities SET population = CASE id WHEN 128800 THEN 2744 ELSE population END WHERE id IN (128800);

UPDATE cities SET population = CASE id WHEN 126319 THEN 2743 ELSE population END WHERE id IN (126319);

UPDATE cities SET population = CASE id WHEN 112026 THEN 2742 ELSE population END WHERE id IN (112026);

UPDATE cities SET population = CASE id WHEN 111537 THEN 2734 ELSE population END WHERE id IN (111537);

UPDATE cities SET population = CASE id WHEN 117192 THEN 2733 ELSE population END WHERE id IN (117192);

UPDATE cities SET population = CASE id WHEN 122182 THEN 2731 ELSE population END WHERE id IN (122182);

UPDATE cities SET population = CASE id WHEN 121217 THEN 2729 ELSE population END WHERE id IN (121217);

UPDATE cities SET population = CASE id WHEN 119880 THEN 2727 WHEN 141455 THEN 2727 ELSE population END WHERE id IN (119880,141455);

UPDATE cities SET population = CASE id WHEN 111544 THEN 2726 ELSE population END WHERE id IN (111544);

UPDATE cities SET population = CASE id WHEN 126961 THEN 2721 ELSE population END WHERE id IN (126961);

UPDATE cities SET population = CASE id WHEN 119848 THEN 2715 WHEN 141605 THEN 2715 ELSE population END WHERE id IN (119848,141605);

UPDATE cities SET population = CASE id WHEN 115558 THEN 2714 ELSE population END WHERE id IN (115558);

UPDATE cities SET population = CASE id WHEN 124244 THEN 2707 ELSE population END WHERE id IN (124244);

UPDATE cities SET population = CASE id WHEN 124301 THEN 2704 ELSE population END WHERE id IN (124301);

UPDATE cities SET population = CASE id WHEN 116439 THEN 2702 ELSE population END WHERE id IN (116439);

UPDATE cities SET population = CASE id WHEN 113109 THEN 2701 ELSE population END WHERE id IN (113109);

UPDATE cities SET population = CASE id WHEN 125379 THEN 2697 ELSE population END WHERE id IN (125379);

UPDATE cities SET population = CASE id WHEN 126585 THEN 2693 ELSE population END WHERE id IN (126585);

UPDATE cities SET population = CASE id WHEN 113664 THEN 2686 WHEN 115493 THEN 2686 ELSE population END WHERE id IN (113664,115493);

UPDATE cities SET population = CASE id WHEN 120462 THEN 2683 ELSE population END WHERE id IN (120462);

UPDATE cities SET population = CASE id WHEN 125643 THEN 2682 ELSE population END WHERE id IN (125643);

UPDATE cities SET population = CASE id WHEN 141736 THEN 2679 ELSE population END WHERE id IN (141736);

UPDATE cities SET population = CASE id WHEN 125923 THEN 2675 ELSE population END WHERE id IN (125923);

UPDATE cities SET population = CASE id WHEN 141183 THEN 2674 ELSE population END WHERE id IN (141183);

UPDATE cities SET population = CASE id WHEN 122429 THEN 2673 ELSE population END WHERE id IN (122429);

UPDATE cities SET population = CASE id WHEN 119240 THEN 2671 WHEN 129381 THEN 2671 ELSE population END WHERE id IN (119240,129381);

UPDATE cities SET population = CASE id WHEN 115572 THEN 2670 ELSE population END WHERE id IN (115572);

UPDATE cities SET population = CASE id WHEN 120033 THEN 2669 ELSE population END WHERE id IN (120033);

UPDATE cities SET population = CASE id WHEN 118008 THEN 2668 WHEN 126391 THEN 2668 ELSE population END WHERE id IN (118008,126391);

UPDATE cities SET population = CASE id WHEN 111899 THEN 2667 WHEN 127803 THEN 2667 ELSE population END WHERE id IN (111899,127803);

UPDATE cities SET population = CASE id WHEN 125454 THEN 2666 ELSE population END WHERE id IN (125454);

UPDATE cities SET population = CASE id WHEN 128032 THEN 2665 ELSE population END WHERE id IN (128032);

UPDATE cities SET population = CASE id WHEN 117929 THEN 2664 WHEN 141582 THEN 2664 ELSE population END WHERE id IN (117929,141582);

UPDATE cities SET population = CASE id WHEN 111688 THEN 2661 WHEN 113832 THEN 2661 ELSE population END WHERE id IN (111688,113832);

UPDATE cities SET population = CASE id WHEN 112197 THEN 2658 ELSE population END WHERE id IN (112197);

UPDATE cities SET population = CASE id WHEN 114284 THEN 2657 ELSE population END WHERE id IN (114284);

UPDATE cities SET population = CASE id WHEN 116620 THEN 2656 ELSE population END WHERE id IN (116620);

UPDATE cities SET population = CASE id WHEN 116350 THEN 2655 ELSE population END WHERE id IN (116350);

UPDATE cities SET population = CASE id WHEN 126195 THEN 2652 ELSE population END WHERE id IN (126195);

UPDATE cities SET population = CASE id WHEN 111106 THEN 2647 ELSE population END WHERE id IN (111106);

UPDATE cities SET population = CASE id WHEN 124371 THEN 2643 WHEN 141783 THEN 2643 ELSE population END WHERE id IN (124371,141783);

UPDATE cities SET population = CASE id WHEN 128770 THEN 2642 WHEN 141574 THEN 2642 ELSE population END WHERE id IN (128770,141574);

UPDATE cities SET population = CASE id WHEN 127586 THEN 2639 ELSE population END WHERE id IN (127586);

UPDATE cities SET population = CASE id WHEN 116314 THEN 2638 WHEN 123409 THEN 2638 ELSE population END WHERE id IN (116314,123409);

UPDATE cities SET population = CASE id WHEN 121914 THEN 2637 ELSE population END WHERE id IN (121914);

UPDATE cities SET population = CASE id WHEN 111422 THEN 2634 WHEN 129710 THEN 2634 ELSE population END WHERE id IN (111422,129710);

UPDATE cities SET population = CASE id WHEN 114528 THEN 2631 ELSE population END WHERE id IN (114528);

UPDATE cities SET population = CASE id WHEN 120995 THEN 2630 ELSE population END WHERE id IN (120995);

UPDATE cities SET population = CASE id WHEN 123666 THEN 2627 WHEN 124985 THEN 2627 ELSE population END WHERE id IN (123666,124985);

UPDATE cities SET population = CASE id WHEN 141245 THEN 2625 ELSE population END WHERE id IN (141245);

UPDATE cities SET population = CASE id WHEN 110968 THEN 2620 ELSE population END WHERE id IN (110968);

UPDATE cities SET population = CASE id WHEN 124358 THEN 2619 ELSE population END WHERE id IN (124358);

UPDATE cities SET population = CASE id WHEN 112436 THEN 2617 WHEN 118088 THEN 2617 ELSE population END WHERE id IN (112436,118088);

UPDATE cities SET population = CASE id WHEN 120966 THEN 2616 ELSE population END WHERE id IN (120966);

UPDATE cities SET population = CASE id WHEN 122160 THEN 2615 ELSE population END WHERE id IN (122160);

UPDATE cities SET population = CASE id WHEN 121218 THEN 2608 ELSE population END WHERE id IN (121218);

UPDATE cities SET population = CASE id WHEN 112156 THEN 2607 ELSE population END WHERE id IN (112156);

UPDATE cities SET population = CASE id WHEN 123289 THEN 2602 ELSE population END WHERE id IN (123289);

UPDATE cities SET population = CASE id WHEN 120565 THEN 2597 ELSE population END WHERE id IN (120565);

UPDATE cities SET population = CASE id WHEN 120426 THEN 2596 ELSE population END WHERE id IN (120426);

UPDATE cities SET population = CASE id WHEN 111251 THEN 2594 WHEN 115266 THEN 2594 ELSE population END WHERE id IN (111251,115266);

UPDATE cities SET population = CASE id WHEN 114569 THEN 2593 ELSE population END WHERE id IN (114569);

UPDATE cities SET population = CASE id WHEN 118907 THEN 2591 ELSE population END WHERE id IN (118907);

UPDATE cities SET population = CASE id WHEN 117277 THEN 2582 WHEN 129169 THEN 2582 ELSE population END WHERE id IN (117277,129169);

UPDATE cities SET population = CASE id WHEN 125097 THEN 2580 ELSE population END WHERE id IN (125097);

UPDATE cities SET population = CASE id WHEN 111830 THEN 2577 ELSE population END WHERE id IN (111830);

UPDATE cities SET population = CASE id WHEN 113653 THEN 2576 ELSE population END WHERE id IN (113653);

UPDATE cities SET population = CASE id WHEN 115099 THEN 2575 ELSE population END WHERE id IN (115099);

UPDATE cities SET population = CASE id WHEN 128380 THEN 2573 ELSE population END WHERE id IN (128380);

UPDATE cities SET population = CASE id WHEN 114740 THEN 2568 WHEN 117315 THEN 2568 ELSE population END WHERE id IN (114740,117315);

UPDATE cities SET population = CASE id WHEN 121097 THEN 2563 ELSE population END WHERE id IN (121097);

UPDATE cities SET population = CASE id WHEN 112301 THEN 2559 ELSE population END WHERE id IN (112301);

UPDATE cities SET population = CASE id WHEN 111536 THEN 2558 ELSE population END WHERE id IN (111536);

UPDATE cities SET population = CASE id WHEN 114984 THEN 2557 ELSE population END WHERE id IN (114984);

UPDATE cities SET population = CASE id WHEN 141827 THEN 2549 ELSE population END WHERE id IN (141827);

UPDATE cities SET population = CASE id WHEN 127678 THEN 2543 ELSE population END WHERE id IN (127678);

UPDATE cities SET population = CASE id WHEN 118882 THEN 2541 WHEN 125312 THEN 2541 ELSE population END WHERE id IN (118882,125312);

UPDATE cities SET population = CASE id WHEN 127360 THEN 2538 ELSE population END WHERE id IN (127360);

UPDATE cities SET population = CASE id WHEN 114223 THEN 2537 ELSE population END WHERE id IN (114223);

UPDATE cities SET population = CASE id WHEN 114302 THEN 2536 ELSE population END WHERE id IN (114302);

UPDATE cities SET population = CASE id WHEN 121359 THEN 2535 ELSE population END WHERE id IN (121359);

UPDATE cities SET population = CASE id WHEN 129360 THEN 2534 ELSE population END WHERE id IN (129360);

UPDATE cities SET population = CASE id WHEN 141149 THEN 2530 ELSE population END WHERE id IN (141149);

UPDATE cities SET population = CASE id WHEN 118489 THEN 2528 WHEN 118851 THEN 2528 ELSE population END WHERE id IN (118489,118851);

UPDATE cities SET population = CASE id WHEN 115101 THEN 2526 ELSE population END WHERE id IN (115101);

UPDATE cities SET population = CASE id WHEN 123880 THEN 2525 ELSE population END WHERE id IN (123880);

UPDATE cities SET population = CASE id WHEN 141712 THEN 2523 ELSE population END WHERE id IN (141712);

UPDATE cities SET population = CASE id WHEN 113647 THEN 2521 WHEN 125746 THEN 2521 ELSE population END WHERE id IN (113647,125746);

UPDATE cities SET population = CASE id WHEN 120467 THEN 2520 WHEN 124104 THEN 2520 ELSE population END WHERE id IN (120467,124104);

UPDATE cities SET population = CASE id WHEN 114645 THEN 2516 ELSE population END WHERE id IN (114645);

UPDATE cities SET population = CASE id WHEN 125324 THEN 2514 ELSE population END WHERE id IN (125324);

UPDATE cities SET population = CASE id WHEN 113418 THEN 2512 ELSE population END WHERE id IN (113418);

UPDATE cities SET population = CASE id WHEN 123602 THEN 2511 ELSE population END WHERE id IN (123602);

UPDATE cities SET population = CASE id WHEN 118099 THEN 2510 WHEN 122727 THEN 2510 ELSE population END WHERE id IN (118099,122727);

UPDATE cities SET population = CASE id WHEN 122178 THEN 2509 ELSE population END WHERE id IN (122178);

UPDATE cities SET population = CASE id WHEN 117704 THEN 2508 WHEN 124545 THEN 2508 ELSE population END WHERE id IN (117704,124545);

UPDATE cities SET population = CASE id WHEN 112279 THEN 2507 WHEN 116823 THEN 2507 ELSE population END WHERE id IN (112279,116823);

UPDATE cities SET population = CASE id WHEN 117618 THEN 2502 ELSE population END WHERE id IN (117618);

UPDATE cities SET population = CASE id WHEN 113496 THEN 2500 ELSE population END WHERE id IN (113496);

UPDATE cities SET population = CASE id WHEN 115183 THEN 2499 WHEN 122397 THEN 2499 ELSE population END WHERE id IN (115183,122397);

UPDATE cities SET population = CASE id WHEN 113890 THEN 2498 ELSE population END WHERE id IN (113890);

UPDATE cities SET population = CASE id WHEN 116304 THEN 2497 ELSE population END WHERE id IN (116304);

UPDATE cities SET population = CASE id WHEN 113869 THEN 2496 ELSE population END WHERE id IN (113869);

UPDATE cities SET population = CASE id WHEN 113903 THEN 2495 WHEN 129274 THEN 2495 ELSE population END WHERE id IN (113903,129274);

UPDATE cities SET population = CASE id WHEN 121817 THEN 2491 ELSE population END WHERE id IN (121817);

UPDATE cities SET population = CASE id WHEN 112472 THEN 2490 ELSE population END WHERE id IN (112472);

UPDATE cities SET population = CASE id WHEN 114111 THEN 2489 WHEN 116509 THEN 2489 ELSE population END WHERE id IN (114111,116509);

UPDATE cities SET population = CASE id WHEN 118210 THEN 2488 WHEN 141330 THEN 2488 ELSE population END WHERE id IN (118210,141330);

UPDATE cities SET population = CASE id WHEN 111091 THEN 2487 ELSE population END WHERE id IN (111091);

UPDATE cities SET population = CASE id WHEN 129045 THEN 2484 WHEN 141648 THEN 2484 ELSE population END WHERE id IN (129045,141648);

UPDATE cities SET population = CASE id WHEN 114523 THEN 2483 WHEN 119169 THEN 2483 ELSE population END WHERE id IN (114523,119169);

UPDATE cities SET population = CASE id WHEN 129495 THEN 2482 ELSE population END WHERE id IN (129495);

UPDATE cities SET population = CASE id WHEN 126430 THEN 2480 WHEN 126866 THEN 2480 ELSE population END WHERE id IN (126430,126866);

UPDATE cities SET population = CASE id WHEN 129572 THEN 2478 ELSE population END WHERE id IN (129572);

UPDATE cities SET population = CASE id WHEN 123600 THEN 2477 ELSE population END WHERE id IN (123600);

UPDATE cities SET population = CASE id WHEN 118040 THEN 2476 ELSE population END WHERE id IN (118040);

UPDATE cities SET population = CASE id WHEN 112089 THEN 2475 WHEN 122412 THEN 2475 ELSE population END WHERE id IN (112089,122412);

UPDATE cities SET population = CASE id WHEN 141517 THEN 2474 ELSE population END WHERE id IN (141517);

UPDATE cities SET population = CASE id WHEN 111610 THEN 2470 ELSE population END WHERE id IN (111610);

UPDATE cities SET population = CASE id WHEN 129269 THEN 2469 ELSE population END WHERE id IN (129269);

UPDATE cities SET population = CASE id WHEN 117536 THEN 2467 ELSE population END WHERE id IN (117536);

UPDATE cities SET population = CASE id WHEN 119963 THEN 2465 ELSE population END WHERE id IN (119963);

UPDATE cities SET population = CASE id WHEN 116416 THEN 2460 ELSE population END WHERE id IN (116416);

UPDATE cities SET population = CASE id WHEN 112450 THEN 2459 WHEN 116336 THEN 2459 ELSE population END WHERE id IN (112450,116336);

UPDATE cities SET population = CASE id WHEN 117707 THEN 2458 ELSE population END WHERE id IN (117707);

UPDATE cities SET population = CASE id WHEN 112768 THEN 2457 ELSE population END WHERE id IN (112768);

UPDATE cities SET population = CASE id WHEN 125217 THEN 2456 ELSE population END WHERE id IN (125217);

UPDATE cities SET population = CASE id WHEN 120136 THEN 2450 ELSE population END WHERE id IN (120136);

UPDATE cities SET population = CASE id WHEN 117090 THEN 2448 ELSE population END WHERE id IN (117090);

UPDATE cities SET population = CASE id WHEN 127121 THEN 2447 ELSE population END WHERE id IN (127121);

UPDATE cities SET population = CASE id WHEN 128682 THEN 2444 ELSE population END WHERE id IN (128682);

UPDATE cities SET population = CASE id WHEN 123838 THEN 2442 WHEN 128204 THEN 2442 ELSE population END WHERE id IN (123838,128204);

UPDATE cities SET population = CASE id WHEN 128210 THEN 2440 ELSE population END WHERE id IN (128210);

UPDATE cities SET population = CASE id WHEN 118105 THEN 2435 ELSE population END WHERE id IN (118105);

UPDATE cities SET population = CASE id WHEN 116684 THEN 2431 WHEN 120500 THEN 2431 ELSE population END WHERE id IN (116684,120500);

UPDATE cities SET population = CASE id WHEN 113465 THEN 2429 ELSE population END WHERE id IN (113465);

UPDATE cities SET population = CASE id WHEN 112108 THEN 2425 WHEN 112290 THEN 2425 WHEN 129555 THEN 2425 ELSE population END WHERE id IN (112108,112290,129555);

UPDATE cities SET population = CASE id WHEN 112237 THEN 2422 WHEN 120824 THEN 2422 ELSE population END WHERE id IN (112237,120824);

UPDATE cities SET population = CASE id WHEN 126876 THEN 2413 ELSE population END WHERE id IN (126876);

UPDATE cities SET population = CASE id WHEN 122159 THEN 2411 ELSE population END WHERE id IN (122159);

UPDATE cities SET population = CASE id WHEN 129140 THEN 2410 ELSE population END WHERE id IN (129140);

UPDATE cities SET population = CASE id WHEN 141388 THEN 2409 ELSE population END WHERE id IN (141388);

UPDATE cities SET population = CASE id WHEN 118056 THEN 2407 ELSE population END WHERE id IN (118056);

UPDATE cities SET population = CASE id WHEN 115050 THEN 2405 WHEN 119566 THEN 2405 ELSE population END WHERE id IN (115050,119566);

UPDATE cities SET population = CASE id WHEN 122862 THEN 2403 ELSE population END WHERE id IN (122862);

UPDATE cities SET population = CASE id WHEN 126155 THEN 2397 ELSE population END WHERE id IN (126155);

UPDATE cities SET population = CASE id WHEN 117750 THEN 2396 ELSE population END WHERE id IN (117750);

UPDATE cities SET population = CASE id WHEN 113493 THEN 2395 ELSE population END WHERE id IN (113493);

UPDATE cities SET population = CASE id WHEN 113584 THEN 2394 ELSE population END WHERE id IN (113584);

UPDATE cities SET population = CASE id WHEN 141298 THEN 2393 ELSE population END WHERE id IN (141298);

UPDATE cities SET population = CASE id WHEN 114545 THEN 2390 WHEN 128708 THEN 2390 ELSE population END WHERE id IN (114545,128708);

UPDATE cities SET population = CASE id WHEN 125270 THEN 2388 ELSE population END WHERE id IN (125270);

UPDATE cities SET population = CASE id WHEN 124812 THEN 2387 ELSE population END WHERE id IN (124812);

UPDATE cities SET population = CASE id WHEN 115862 THEN 2384 WHEN 126499 THEN 2384 ELSE population END WHERE id IN (115862,126499);

UPDATE cities SET population = CASE id WHEN 112939 THEN 2383 WHEN 124947 THEN 2383 ELSE population END WHERE id IN (112939,124947);

UPDATE cities SET population = CASE id WHEN 118738 THEN 2381 WHEN 141568 THEN 2381 ELSE population END WHERE id IN (118738,141568);

UPDATE cities SET population = CASE id WHEN 124968 THEN 2379 ELSE population END WHERE id IN (124968);

UPDATE cities SET population = CASE id WHEN 118815 THEN 2378 ELSE population END WHERE id IN (118815);

UPDATE cities SET population = CASE id WHEN 113348 THEN 2377 ELSE population END WHERE id IN (113348);

UPDATE cities SET population = CASE id WHEN 120997 THEN 2371 WHEN 121036 THEN 2371 ELSE population END WHERE id IN (120997,121036);

UPDATE cities SET population = CASE id WHEN 117165 THEN 2367 ELSE population END WHERE id IN (117165);

UPDATE cities SET population = CASE id WHEN 120543 THEN 2366 ELSE population END WHERE id IN (120543);

UPDATE cities SET population = CASE id WHEN 121613 THEN 2362 WHEN 122097 THEN 2362 ELSE population END WHERE id IN (121613,122097);

UPDATE cities SET population = CASE id WHEN 119062 THEN 2356 ELSE population END WHERE id IN (119062);

UPDATE cities SET population = CASE id WHEN 112744 THEN 2354 WHEN 129396 THEN 2354 ELSE population END WHERE id IN (112744,129396);

UPDATE cities SET population = CASE id WHEN 116354 THEN 2348 ELSE population END WHERE id IN (116354);

UPDATE cities SET population = CASE id WHEN 111754 THEN 2345 WHEN 114843 THEN 2345 ELSE population END WHERE id IN (111754,114843);

UPDATE cities SET population = CASE id WHEN 126303 THEN 2340 ELSE population END WHERE id IN (126303);

UPDATE cities SET population = CASE id WHEN 115538 THEN 2339 ELSE population END WHERE id IN (115538);

UPDATE cities SET population = CASE id WHEN 123892 THEN 2337 ELSE population END WHERE id IN (123892);

UPDATE cities SET population = CASE id WHEN 112434 THEN 2336 ELSE population END WHERE id IN (112434);

UPDATE cities SET population = CASE id WHEN 112845 THEN 2335 ELSE population END WHERE id IN (112845);

UPDATE cities SET population = CASE id WHEN 112743 THEN 2332 WHEN 122454 THEN 2332 ELSE population END WHERE id IN (112743,122454);

UPDATE cities SET population = CASE id WHEN 141345 THEN 2331 ELSE population END WHERE id IN (141345);

UPDATE cities SET population = CASE id WHEN 117311 THEN 2327 ELSE population END WHERE id IN (117311);

UPDATE cities SET population = CASE id WHEN 117681 THEN 2326 ELSE population END WHERE id IN (117681);

UPDATE cities SET population = CASE id WHEN 111124 THEN 2325 ELSE population END WHERE id IN (111124);

UPDATE cities SET population = CASE id WHEN 117145 THEN 2321 ELSE population END WHERE id IN (117145);

UPDATE cities SET population = CASE id WHEN 127521 THEN 2320 ELSE population END WHERE id IN (127521);

UPDATE cities SET population = CASE id WHEN 127068 THEN 2316 ELSE population END WHERE id IN (127068);

UPDATE cities SET population = CASE id WHEN 124147 THEN 2311 ELSE population END WHERE id IN (124147);

UPDATE cities SET population = CASE id WHEN 124735 THEN 2310 ELSE population END WHERE id IN (124735);

UPDATE cities SET population = CASE id WHEN 122005 THEN 2304 ELSE population END WHERE id IN (122005);

UPDATE cities SET population = CASE id WHEN 120046 THEN 2302 ELSE population END WHERE id IN (120046);

UPDATE cities SET population = CASE id WHEN 112116 THEN 2300 ELSE population END WHERE id IN (112116);

UPDATE cities SET population = CASE id WHEN 114474 THEN 2297 WHEN 127975 THEN 2297 ELSE population END WHERE id IN (114474,127975);

UPDATE cities SET population = CASE id WHEN 120041 THEN 2296 WHEN 129431 THEN 2296 ELSE population END WHERE id IN (120041,129431);

UPDATE cities SET population = CASE id WHEN 121633 THEN 2294 ELSE population END WHERE id IN (121633);

UPDATE cities SET population = CASE id WHEN 122064 THEN 2293 ELSE population END WHERE id IN (122064);

UPDATE cities SET population = CASE id WHEN 112934 THEN 2292 WHEN 126157 THEN 2292 ELSE population END WHERE id IN (112934,126157);

UPDATE cities SET population = CASE id WHEN 129053 THEN 2291 WHEN 129383 THEN 2291 ELSE population END WHERE id IN (129053,129383);

UPDATE cities SET population = CASE id WHEN 125704 THEN 2290 WHEN 129615 THEN 2290 ELSE population END WHERE id IN (125704,129615);

UPDATE cities SET population = CASE id WHEN 141807 THEN 2286 ELSE population END WHERE id IN (141807);

UPDATE cities SET population = CASE id WHEN 111474 THEN 2284 ELSE population END WHERE id IN (111474);

UPDATE cities SET population = CASE id WHEN 141191 THEN 2281 WHEN 141668 THEN 2281 ELSE population END WHERE id IN (141191,141668);

UPDATE cities SET population = CASE id WHEN 113476 THEN 2279 ELSE population END WHERE id IN (113476);

UPDATE cities SET population = CASE id WHEN 113494 THEN 2278 ELSE population END WHERE id IN (113494);

UPDATE cities SET population = CASE id WHEN 122395 THEN 2276 ELSE population END WHERE id IN (122395);

UPDATE cities SET population = CASE id WHEN 118945 THEN 2273 ELSE population END WHERE id IN (118945);

UPDATE cities SET population = CASE id WHEN 114282 THEN 2272 ELSE population END WHERE id IN (114282);

UPDATE cities SET population = CASE id WHEN 120361 THEN 2270 WHEN 123311 THEN 2270 ELSE population END WHERE id IN (120361,123311);

UPDATE cities SET population = CASE id WHEN 116283 THEN 2269 ELSE population END WHERE id IN (116283);

UPDATE cities SET population = CASE id WHEN 112972 THEN 2268 ELSE population END WHERE id IN (112972);

UPDATE cities SET population = CASE id WHEN 115448 THEN 2265 ELSE population END WHERE id IN (115448);

UPDATE cities SET population = CASE id WHEN 121790 THEN 2260 ELSE population END WHERE id IN (121790);

UPDATE cities SET population = CASE id WHEN 113944 THEN 2259 ELSE population END WHERE id IN (113944);

UPDATE cities SET population = CASE id WHEN 116080 THEN 2258 ELSE population END WHERE id IN (116080);

UPDATE cities SET population = CASE id WHEN 119310 THEN 2257 ELSE population END WHERE id IN (119310);

UPDATE cities SET population = CASE id WHEN 118584 THEN 2251 ELSE population END WHERE id IN (118584);

UPDATE cities SET population = CASE id WHEN 128613 THEN 2248 ELSE population END WHERE id IN (128613);

UPDATE cities SET population = CASE id WHEN 113195 THEN 2247 ELSE population END WHERE id IN (113195);

UPDATE cities SET population = CASE id WHEN 111326 THEN 2246 ELSE population END WHERE id IN (111326);

UPDATE cities SET population = CASE id WHEN 117128 THEN 2245 ELSE population END WHERE id IN (117128);

UPDATE cities SET population = CASE id WHEN 118741 THEN 2241 ELSE population END WHERE id IN (118741);

UPDATE cities SET population = CASE id WHEN 118090 THEN 2240 ELSE population END WHERE id IN (118090);

UPDATE cities SET population = CASE id WHEN 127802 THEN 2238 ELSE population END WHERE id IN (127802);

UPDATE cities SET population = CASE id WHEN 123157 THEN 2237 ELSE population END WHERE id IN (123157);

UPDATE cities SET population = CASE id WHEN 120329 THEN 2235 ELSE population END WHERE id IN (120329);

UPDATE cities SET population = CASE id WHEN 114198 THEN 2234 WHEN 141741 THEN 2234 ELSE population END WHERE id IN (114198,141741);

UPDATE cities SET population = CASE id WHEN 121853 THEN 2233 ELSE population END WHERE id IN (121853);

UPDATE cities SET population = CASE id WHEN 117948 THEN 2232 ELSE population END WHERE id IN (117948);

UPDATE cities SET population = CASE id WHEN 126787 THEN 2231 ELSE population END WHERE id IN (126787);

UPDATE cities SET population = CASE id WHEN 111000 THEN 2230 ELSE population END WHERE id IN (111000);

UPDATE cities SET population = CASE id WHEN 116897 THEN 2222 ELSE population END WHERE id IN (116897);

UPDATE cities SET population = CASE id WHEN 119312 THEN 2220 ELSE population END WHERE id IN (119312);

UPDATE cities SET population = CASE id WHEN 124222 THEN 2219 ELSE population END WHERE id IN (124222);

UPDATE cities SET population = CASE id WHEN 125731 THEN 2218 ELSE population END WHERE id IN (125731);

UPDATE cities SET population = CASE id WHEN 122555 THEN 2212 ELSE population END WHERE id IN (122555);

UPDATE cities SET population = CASE id WHEN 124806 THEN 2209 ELSE population END WHERE id IN (124806);

UPDATE cities SET population = CASE id WHEN 122751 THEN 2208 ELSE population END WHERE id IN (122751);

UPDATE cities SET population = CASE id WHEN 118701 THEN 2206 ELSE population END WHERE id IN (118701);

UPDATE cities SET population = CASE id WHEN 129181 THEN 2205 WHEN 141834 THEN 2205 ELSE population END WHERE id IN (129181,141834);

UPDATE cities SET population = CASE id WHEN 113638 THEN 2204 ELSE population END WHERE id IN (113638);

UPDATE cities SET population = CASE id WHEN 113267 THEN 2202 WHEN 120598 THEN 2202 WHEN 127699 THEN 2202 ELSE population END WHERE id IN (113267,120598,127699);

UPDATE cities SET population = CASE id WHEN 141728 THEN 2200 ELSE population END WHERE id IN (141728);

UPDATE cities SET population = CASE id WHEN 112787 THEN 2198 WHEN 129344 THEN 2198 ELSE population END WHERE id IN (112787,129344);

UPDATE cities SET population = CASE id WHEN 120990 THEN 2197 WHEN 123676 THEN 2197 ELSE population END WHERE id IN (120990,123676);

UPDATE cities SET population = CASE id WHEN 114640 THEN 2196 WHEN 141776 THEN 2196 ELSE population END WHERE id IN (114640,141776);

UPDATE cities SET population = CASE id WHEN 126824 THEN 2195 ELSE population END WHERE id IN (126824);

UPDATE cities SET population = CASE id WHEN 116414 THEN 2194 ELSE population END WHERE id IN (116414);

UPDATE cities SET population = CASE id WHEN 114455 THEN 2193 WHEN 115241 THEN 2193 ELSE population END WHERE id IN (114455,115241);

UPDATE cities SET population = CASE id WHEN 128088 THEN 2192 WHEN 129378 THEN 2192 ELSE population END WHERE id IN (128088,129378);

UPDATE cities SET population = CASE id WHEN 120643 THEN 2190 WHEN 124106 THEN 2190 ELSE population END WHERE id IN (120643,124106);

UPDATE cities SET population = CASE id WHEN 112262 THEN 2187 ELSE population END WHERE id IN (112262);

UPDATE cities SET population = CASE id WHEN 122930 THEN 2185 ELSE population END WHERE id IN (122930);

UPDATE cities SET population = CASE id WHEN 113550 THEN 2184 ELSE population END WHERE id IN (113550);

UPDATE cities SET population = CASE id WHEN 127620 THEN 2182 ELSE population END WHERE id IN (127620);

UPDATE cities SET population = CASE id WHEN 141249 THEN 2181 ELSE population END WHERE id IN (141249);

UPDATE cities SET population = CASE id WHEN 121376 THEN 2180 ELSE population END WHERE id IN (121376);

UPDATE cities SET population = CASE id WHEN 112111 THEN 2176 ELSE population END WHERE id IN (112111);

UPDATE cities SET population = CASE id WHEN 126780 THEN 2175 ELSE population END WHERE id IN (126780);

UPDATE cities SET population = CASE id WHEN 128780 THEN 2174 WHEN 141559 THEN 2174 ELSE population END WHERE id IN (128780,141559);

UPDATE cities SET population = CASE id WHEN 111466 THEN 2169 WHEN 115495 THEN 2169 WHEN 141167 THEN 2169 ELSE population END WHERE id IN (111466,115495,141167);

UPDATE cities SET population = CASE id WHEN 118643 THEN 2167 ELSE population END WHERE id IN (118643);

UPDATE cities SET population = CASE id WHEN 141351 THEN 2164 ELSE population END WHERE id IN (141351);

UPDATE cities SET population = CASE id WHEN 118521 THEN 2163 ELSE population END WHERE id IN (118521);

UPDATE cities SET population = CASE id WHEN 120445 THEN 2161 ELSE population END WHERE id IN (120445);

UPDATE cities SET population = CASE id WHEN 123934 THEN 2160 ELSE population END WHERE id IN (123934);

UPDATE cities SET population = CASE id WHEN 115308 THEN 2158 WHEN 124696 THEN 2158 ELSE population END WHERE id IN (115308,124696);

UPDATE cities SET population = CASE id WHEN 127825 THEN 2157 ELSE population END WHERE id IN (127825);

UPDATE cities SET population = CASE id WHEN 116920 THEN 2153 ELSE population END WHERE id IN (116920);

UPDATE cities SET population = CASE id WHEN 114586 THEN 2150 ELSE population END WHERE id IN (114586);

UPDATE cities SET population = CASE id WHEN 141216 THEN 2149 ELSE population END WHERE id IN (141216);

UPDATE cities SET population = CASE id WHEN 120945 THEN 2147 ELSE population END WHERE id IN (120945);

UPDATE cities SET population = CASE id WHEN 113191 THEN 2146 WHEN 114910 THEN 2146 ELSE population END WHERE id IN (113191,114910);

UPDATE cities SET population = CASE id WHEN 120600 THEN 2145 WHEN 129706 THEN 2145 ELSE population END WHERE id IN (120600,129706);

UPDATE cities SET population = CASE id WHEN 113892 THEN 2144 WHEN 125329 THEN 2144 ELSE population END WHERE id IN (113892,125329);

UPDATE cities SET population = CASE id WHEN 121096 THEN 2143 ELSE population END WHERE id IN (121096);

UPDATE cities SET population = CASE id WHEN 114286 THEN 2140 ELSE population END WHERE id IN (114286);

UPDATE cities SET population = CASE id WHEN 121372 THEN 2139 ELSE population END WHERE id IN (121372);

UPDATE cities SET population = CASE id WHEN 113846 THEN 2138 WHEN 117785 THEN 2138 WHEN 121642 THEN 2138 ELSE population END WHERE id IN (113846,117785,121642);

UPDATE cities SET population = CASE id WHEN 122852 THEN 2137 ELSE population END WHERE id IN (122852);

UPDATE cities SET population = CASE id WHEN 116874 THEN 2135 ELSE population END WHERE id IN (116874);

UPDATE cities SET population = CASE id WHEN 117143 THEN 2131 ELSE population END WHERE id IN (117143);

UPDATE cities SET population = CASE id WHEN 121818 THEN 2125 ELSE population END WHERE id IN (121818);

UPDATE cities SET population = CASE id WHEN 120554 THEN 2123 WHEN 126269 THEN 2123 ELSE population END WHERE id IN (120554,126269);

UPDATE cities SET population = CASE id WHEN 112153 THEN 2121 ELSE population END WHERE id IN (112153);

UPDATE cities SET population = CASE id WHEN 117648 THEN 2120 WHEN 127978 THEN 2120 ELSE population END WHERE id IN (117648,127978);

UPDATE cities SET population = CASE id WHEN 111105 THEN 2119 ELSE population END WHERE id IN (111105);

UPDATE cities SET population = CASE id WHEN 128098 THEN 2117 ELSE population END WHERE id IN (128098);

UPDATE cities SET population = CASE id WHEN 111341 THEN 2114 ELSE population END WHERE id IN (111341);

UPDATE cities SET population = CASE id WHEN 111626 THEN 2113 WHEN 113251 THEN 2113 WHEN 120996 THEN 2113 ELSE population END WHERE id IN (111626,113251,120996);

UPDATE cities SET population = CASE id WHEN 113612 THEN 2112 WHEN 141675 THEN 2112 ELSE population END WHERE id IN (113612,141675);

UPDATE cities SET population = CASE id WHEN 119164 THEN 2111 ELSE population END WHERE id IN (119164);

UPDATE cities SET population = CASE id WHEN 118057 THEN 2107 WHEN 121855 THEN 2107 ELSE population END WHERE id IN (118057,121855);

UPDATE cities SET population = CASE id WHEN 120040 THEN 2104 ELSE population END WHERE id IN (120040);

UPDATE cities SET population = CASE id WHEN 114906 THEN 2103 WHEN 127008 THEN 2103 WHEN 141431 THEN 2103 ELSE population END WHERE id IN (114906,127008,141431);

UPDATE cities SET population = CASE id WHEN 123154 THEN 2101 ELSE population END WHERE id IN (123154);

UPDATE cities SET population = CASE id WHEN 124071 THEN 2100 WHEN 128517 THEN 2100 WHEN 141408 THEN 2100 ELSE population END WHERE id IN (124071,128517,141408);

UPDATE cities SET population = CASE id WHEN 118763 THEN 2099 WHEN 119630 THEN 2099 ELSE population END WHERE id IN (118763,119630);

UPDATE cities SET population = CASE id WHEN 118932 THEN 2098 ELSE population END WHERE id IN (118932);

UPDATE cities SET population = CASE id WHEN 124654 THEN 2096 ELSE population END WHERE id IN (124654);

UPDATE cities SET population = CASE id WHEN 120489 THEN 2095 ELSE population END WHERE id IN (120489);

UPDATE cities SET population = CASE id WHEN 115485 THEN 2094 ELSE population END WHERE id IN (115485);

UPDATE cities SET population = CASE id WHEN 116061 THEN 2089 ELSE population END WHERE id IN (116061);

UPDATE cities SET population = CASE id WHEN 129565 THEN 2088 ELSE population END WHERE id IN (129565);

UPDATE cities SET population = CASE id WHEN 117238 THEN 2086 WHEN 126839 THEN 2086 ELSE population END WHERE id IN (117238,126839);

UPDATE cities SET population = CASE id WHEN 125642 THEN 2084 ELSE population END WHERE id IN (125642);

UPDATE cities SET population = CASE id WHEN 115791 THEN 2083 WHEN 141841 THEN 2083 ELSE population END WHERE id IN (115791,141841);

UPDATE cities SET population = CASE id WHEN 126952 THEN 2082 ELSE population END WHERE id IN (126952);

UPDATE cities SET population = CASE id WHEN 124251 THEN 2081 ELSE population END WHERE id IN (124251);

UPDATE cities SET population = CASE id WHEN 120321 THEN 2080 ELSE population END WHERE id IN (120321);

UPDATE cities SET population = CASE id WHEN 118362 THEN 2079 ELSE population END WHERE id IN (118362);

UPDATE cities SET population = CASE id WHEN 127465 THEN 2078 ELSE population END WHERE id IN (127465);

UPDATE cities SET population = CASE id WHEN 141279 THEN 2076 ELSE population END WHERE id IN (141279);

UPDATE cities SET population = CASE id WHEN 120910 THEN 2074 ELSE population END WHERE id IN (120910);

UPDATE cities SET population = CASE id WHEN 125229 THEN 2073 WHEN 127128 THEN 2073 WHEN 128667 THEN 2073 ELSE population END WHERE id IN (125229,127128,128667);

UPDATE cities SET population = CASE id WHEN 114542 THEN 2070 ELSE population END WHERE id IN (114542);

UPDATE cities SET population = CASE id WHEN 122171 THEN 2069 ELSE population END WHERE id IN (122171);

UPDATE cities SET population = CASE id WHEN 126902 THEN 2068 ELSE population END WHERE id IN (126902);

UPDATE cities SET population = CASE id WHEN 113412 THEN 2067 WHEN 128833 THEN 2067 ELSE population END WHERE id IN (113412,128833);

UPDATE cities SET population = CASE id WHEN 129384 THEN 2066 ELSE population END WHERE id IN (129384);

UPDATE cities SET population = CASE id WHEN 124332 THEN 2061 ELSE population END WHERE id IN (124332);

UPDATE cities SET population = CASE id WHEN 125556 THEN 2060 ELSE population END WHERE id IN (125556);

UPDATE cities SET population = CASE id WHEN 116300 THEN 2059 WHEN 120449 THEN 2059 ELSE population END WHERE id IN (116300,120449);

UPDATE cities SET population = CASE id WHEN 113064 THEN 2057 ELSE population END WHERE id IN (113064);

UPDATE cities SET population = CASE id WHEN 118884 THEN 2056 WHEN 118969 THEN 2056 ELSE population END WHERE id IN (118884,118969);

UPDATE cities SET population = CASE id WHEN 128534 THEN 2055 ELSE population END WHERE id IN (128534);

UPDATE cities SET population = CASE id WHEN 125614 THEN 2054 ELSE population END WHERE id IN (125614);

UPDATE cities SET population = CASE id WHEN 119521 THEN 2052 WHEN 119786 THEN 2052 ELSE population END WHERE id IN (119521,119786);

UPDATE cities SET population = CASE id WHEN 114405 THEN 2051 ELSE population END WHERE id IN (114405);

UPDATE cities SET population = CASE id WHEN 116987 THEN 2049 WHEN 120450 THEN 2049 ELSE population END WHERE id IN (116987,120450);

UPDATE cities SET population = CASE id WHEN 113764 THEN 2048 WHEN 119166 THEN 2048 WHEN 141483 THEN 2048 ELSE population END WHERE id IN (113764,119166,141483);

UPDATE cities SET population = CASE id WHEN 116907 THEN 2045 WHEN 123299 THEN 2045 ELSE population END WHERE id IN (116907,123299);

UPDATE cities SET population = CASE id WHEN 117028 THEN 2043 WHEN 127301 THEN 2043 ELSE population END WHERE id IN (117028,127301);

UPDATE cities SET population = CASE id WHEN 114499 THEN 2042 WHEN 115999 THEN 2042 WHEN 117910 THEN 2042 ELSE population END WHERE id IN (114499,115999,117910);

UPDATE cities SET population = CASE id WHEN 111650 THEN 2041 WHEN 123368 THEN 2041 ELSE population END WHERE id IN (111650,123368);

UPDATE cities SET population = CASE id WHEN 112570 THEN 2040 WHEN 122287 THEN 2040 ELSE population END WHERE id IN (112570,122287);

UPDATE cities SET population = CASE id WHEN 119413 THEN 2038 WHEN 120460 THEN 2038 ELSE population END WHERE id IN (119413,120460);

UPDATE cities SET population = CASE id WHEN 128606 THEN 2037 ELSE population END WHERE id IN (128606);

UPDATE cities SET population = CASE id WHEN 112304 THEN 2033 WHEN 119307 THEN 2033 ELSE population END WHERE id IN (112304,119307);

UPDATE cities SET population = CASE id WHEN 116971 THEN 2031 WHEN 123774 THEN 2031 ELSE population END WHERE id IN (116971,123774);

UPDATE cities SET population = CASE id WHEN 112810 THEN 2030 WHEN 129758 THEN 2030 ELSE population END WHERE id IN (112810,129758);

UPDATE cities SET population = CASE id WHEN 141416 THEN 2027 ELSE population END WHERE id IN (141416);

UPDATE cities SET population = CASE id WHEN 111125 THEN 2023 WHEN 129073 THEN 2023 ELSE population END WHERE id IN (111125,129073);

UPDATE cities SET population = CASE id WHEN 125696 THEN 2021 ELSE population END WHERE id IN (125696);

UPDATE cities SET population = CASE id WHEN 112236 THEN 2019 ELSE population END WHERE id IN (112236);

UPDATE cities SET population = CASE id WHEN 113085 THEN 2018 WHEN 126270 THEN 2018 ELSE population END WHERE id IN (113085,126270);

UPDATE cities SET population = CASE id WHEN 111639 THEN 2017 ELSE population END WHERE id IN (111639);

UPDATE cities SET population = CASE id WHEN 119482 THEN 2016 ELSE population END WHERE id IN (119482);

UPDATE cities SET population = CASE id WHEN 112194 THEN 2015 ELSE population END WHERE id IN (112194);

UPDATE cities SET population = CASE id WHEN 111104 THEN 2014 WHEN 126980 THEN 2014 ELSE population END WHERE id IN (111104,126980);

UPDATE cities SET population = CASE id WHEN 122368 THEN 2013 ELSE population END WHERE id IN (122368);

UPDATE cities SET population = CASE id WHEN 111102 THEN 2012 WHEN 141777 THEN 2012 ELSE population END WHERE id IN (111102,141777);

UPDATE cities SET population = CASE id WHEN 111739 THEN 2011 ELSE population END WHERE id IN (111739);

UPDATE cities SET population = CASE id WHEN 113402 THEN 2010 ELSE population END WHERE id IN (113402);

UPDATE cities SET population = CASE id WHEN 127222 THEN 2009 ELSE population END WHERE id IN (127222);

UPDATE cities SET population = CASE id WHEN 121813 THEN 2007 ELSE population END WHERE id IN (121813);

UPDATE cities SET population = CASE id WHEN 114320 THEN 2006 ELSE population END WHERE id IN (114320);

UPDATE cities SET population = CASE id WHEN 118803 THEN 2004 ELSE population END WHERE id IN (118803);

UPDATE cities SET population = CASE id WHEN 120281 THEN 2002 ELSE population END WHERE id IN (120281);

UPDATE cities SET population = CASE id WHEN 114408 THEN 1995 ELSE population END WHERE id IN (114408);

UPDATE cities SET population = CASE id WHEN 127364 THEN 1993 ELSE population END WHERE id IN (127364);

UPDATE cities SET population = CASE id WHEN 112851 THEN 1991 WHEN 115451 THEN 1991 ELSE population END WHERE id IN (112851,115451);

UPDATE cities SET population = CASE id WHEN 127972 THEN 1987 ELSE population END WHERE id IN (127972);

UPDATE cities SET population = CASE id WHEN 111419 THEN 1986 ELSE population END WHERE id IN (111419);

UPDATE cities SET population = CASE id WHEN 116572 THEN 1985 WHEN 124827 THEN 1985 ELSE population END WHERE id IN (116572,124827);

UPDATE cities SET population = CASE id WHEN 127902 THEN 1984 ELSE population END WHERE id IN (127902);

UPDATE cities SET population = CASE id WHEN 111533 THEN 1983 ELSE population END WHERE id IN (111533);

UPDATE cities SET population = CASE id WHEN 141291 THEN 1982 ELSE population END WHERE id IN (141291);

UPDATE cities SET population = CASE id WHEN 125112 THEN 1980 ELSE population END WHERE id IN (125112);

UPDATE cities SET population = CASE id WHEN 118123 THEN 1979 WHEN 120562 THEN 1979 ELSE population END WHERE id IN (118123,120562);

UPDATE cities SET population = CASE id WHEN 124165 THEN 1977 WHEN 126065 THEN 1977 ELSE population END WHERE id IN (124165,126065);

UPDATE cities SET population = CASE id WHEN 118456 THEN 1976 ELSE population END WHERE id IN (118456);

UPDATE cities SET population = CASE id WHEN 115596 THEN 1974 WHEN 124868 THEN 1974 ELSE population END WHERE id IN (115596,124868);

UPDATE cities SET population = CASE id WHEN 128282 THEN 1973 ELSE population END WHERE id IN (128282);

UPDATE cities SET population = CASE id WHEN 111054 THEN 1972 ELSE population END WHERE id IN (111054);

UPDATE cities SET population = CASE id WHEN 121906 THEN 1970 ELSE population END WHERE id IN (121906);

UPDATE cities SET population = CASE id WHEN 113830 THEN 1969 ELSE population END WHERE id IN (113830);

UPDATE cities SET population = CASE id WHEN 122875 THEN 1967 WHEN 126193 THEN 1967 ELSE population END WHERE id IN (122875,126193);

UPDATE cities SET population = CASE id WHEN 114387 THEN 1964 ELSE population END WHERE id IN (114387);

UPDATE cities SET population = CASE id WHEN 121068 THEN 1963 WHEN 127602 THEN 1963 ELSE population END WHERE id IN (121068,127602);

UPDATE cities SET population = CASE id WHEN 112002 THEN 1962 ELSE population END WHERE id IN (112002);

UPDATE cities SET population = CASE id WHEN 128218 THEN 1961 ELSE population END WHERE id IN (128218);

UPDATE cities SET population = CASE id WHEN 119258 THEN 1959 WHEN 127766 THEN 1959 ELSE population END WHERE id IN (119258,127766);

UPDATE cities SET population = CASE id WHEN 114476 THEN 1958 WHEN 119308 THEN 1958 ELSE population END WHERE id IN (114476,119308);

UPDATE cities SET population = CASE id WHEN 111976 THEN 1956 WHEN 114202 THEN 1956 ELSE population END WHERE id IN (111976,114202);

UPDATE cities SET population = CASE id WHEN 112110 THEN 1954 ELSE population END WHERE id IN (112110);

UPDATE cities SET population = CASE id WHEN 126905 THEN 1953 ELSE population END WHERE id IN (126905);

UPDATE cities SET population = CASE id WHEN 121942 THEN 1950 ELSE population END WHERE id IN (121942);

UPDATE cities SET population = CASE id WHEN 114435 THEN 1948 WHEN 125296 THEN 1948 ELSE population END WHERE id IN (114435,125296);

UPDATE cities SET population = CASE id WHEN 119122 THEN 1947 ELSE population END WHERE id IN (119122);

UPDATE cities SET population = CASE id WHEN 114879 THEN 1945 ELSE population END WHERE id IN (114879);

UPDATE cities SET population = CASE id WHEN 114112 THEN 1944 ELSE population END WHERE id IN (114112);

UPDATE cities SET population = CASE id WHEN 127981 THEN 1942 ELSE population END WHERE id IN (127981);

UPDATE cities SET population = CASE id WHEN 111574 THEN 1938 WHEN 115574 THEN 1938 ELSE population END WHERE id IN (111574,115574);

UPDATE cities SET population = CASE id WHEN 128128 THEN 1937 ELSE population END WHERE id IN (128128);

UPDATE cities SET population = CASE id WHEN 114425 THEN 1934 ELSE population END WHERE id IN (114425);

UPDATE cities SET population = CASE id WHEN 117492 THEN 1932 ELSE population END WHERE id IN (117492);

UPDATE cities SET population = CASE id WHEN 110978 THEN 1929 WHEN 118650 THEN 1929 ELSE population END WHERE id IN (110978,118650);

UPDATE cities SET population = CASE id WHEN 113297 THEN 1922 WHEN 127049 THEN 1922 WHEN 141556 THEN 1922 ELSE population END WHERE id IN (113297,127049,141556);

UPDATE cities SET population = CASE id WHEN 126827 THEN 1921 WHEN 129717 THEN 1921 ELSE population END WHERE id IN (126827,129717);

UPDATE cities SET population = CASE id WHEN 113349 THEN 1920 ELSE population END WHERE id IN (113349);

UPDATE cities SET population = CASE id WHEN 123057 THEN 1919 ELSE population END WHERE id IN (123057);

UPDATE cities SET population = CASE id WHEN 120648 THEN 1917 WHEN 126106 THEN 1917 ELSE population END WHERE id IN (120648,126106);

UPDATE cities SET population = CASE id WHEN 128171 THEN 1915 ELSE population END WHERE id IN (128171);

UPDATE cities SET population = CASE id WHEN 111597 THEN 1914 ELSE population END WHERE id IN (111597);

UPDATE cities SET population = CASE id WHEN 125208 THEN 1912 ELSE population END WHERE id IN (125208);

UPDATE cities SET population = CASE id WHEN 121347 THEN 1911 ELSE population END WHERE id IN (121347);

UPDATE cities SET population = CASE id WHEN 127584 THEN 1910 ELSE population END WHERE id IN (127584);

UPDATE cities SET population = CASE id WHEN 125595 THEN 1909 ELSE population END WHERE id IN (125595);

UPDATE cities SET population = CASE id WHEN 118850 THEN 1908 ELSE population END WHERE id IN (118850);

UPDATE cities SET population = CASE id WHEN 112104 THEN 1907 WHEN 119458 THEN 1907 ELSE population END WHERE id IN (112104,119458);

UPDATE cities SET population = CASE id WHEN 114975 THEN 1906 WHEN 115822 THEN 1906 ELSE population END WHERE id IN (114975,115822);

UPDATE cities SET population = CASE id WHEN 129655 THEN 1905 ELSE population END WHERE id IN (129655);

UPDATE cities SET population = CASE id WHEN 112435 THEN 1903 ELSE population END WHERE id IN (112435);

UPDATE cities SET population = CASE id WHEN 117914 THEN 1898 ELSE population END WHERE id IN (117914);

UPDATE cities SET population = CASE id WHEN 111015 THEN 1893 WHEN 116150 THEN 1893 ELSE population END WHERE id IN (111015,116150);

UPDATE cities SET population = CASE id WHEN 116685 THEN 1892 WHEN 122294 THEN 1892 ELSE population END WHERE id IN (116685,122294);

UPDATE cities SET population = CASE id WHEN 114283 THEN 1891 ELSE population END WHERE id IN (114283);

UPDATE cities SET population = CASE id WHEN 113010 THEN 1887 ELSE population END WHERE id IN (113010);

UPDATE cities SET population = CASE id WHEN 116571 THEN 1886 ELSE population END WHERE id IN (116571);

UPDATE cities SET population = CASE id WHEN 113107 THEN 1885 ELSE population END WHERE id IN (113107);

UPDATE cities SET population = CASE id WHEN 120766 THEN 1884 ELSE population END WHERE id IN (120766);

UPDATE cities SET population = CASE id WHEN 117649 THEN 1883 ELSE population END WHERE id IN (117649);

UPDATE cities SET population = CASE id WHEN 122742 THEN 1882 ELSE population END WHERE id IN (122742);

UPDATE cities SET population = CASE id WHEN 115861 THEN 1878 ELSE population END WHERE id IN (115861);

UPDATE cities SET population = CASE id WHEN 117448 THEN 1877 WHEN 127500 THEN 1877 ELSE population END WHERE id IN (117448,127500);

UPDATE cities SET population = CASE id WHEN 111727 THEN 1876 ELSE population END WHERE id IN (111727);

UPDATE cities SET population = CASE id WHEN 110976 THEN 1875 WHEN 123284 THEN 1875 WHEN 127585 THEN 1875 ELSE population END WHERE id IN (110976,123284,127585);

UPDATE cities SET population = CASE id WHEN 117666 THEN 1873 ELSE population END WHERE id IN (117666);

UPDATE cities SET population = CASE id WHEN 141145 THEN 1871 ELSE population END WHERE id IN (141145);

UPDATE cities SET population = CASE id WHEN 112964 THEN 1870 ELSE population END WHERE id IN (112964);

UPDATE cities SET population = CASE id WHEN 120722 THEN 1869 WHEN 124628 THEN 1869 ELSE population END WHERE id IN (120722,124628);

UPDATE cities SET population = CASE id WHEN 120251 THEN 1866 ELSE population END WHERE id IN (120251);

UPDATE cities SET population = CASE id WHEN 129606 THEN 1862 ELSE population END WHERE id IN (129606);

UPDATE cities SET population = CASE id WHEN 121919 THEN 1861 WHEN 124236 THEN 1861 WHEN 129054 THEN 1861 ELSE population END WHERE id IN (121919,124236,129054);

UPDATE cities SET population = CASE id WHEN 125693 THEN 1860 ELSE population END WHERE id IN (125693);

UPDATE cities SET population = CASE id WHEN 127072 THEN 1859 ELSE population END WHERE id IN (127072);

UPDATE cities SET population = CASE id WHEN 116389 THEN 1855 ELSE population END WHERE id IN (116389);

UPDATE cities SET population = CASE id WHEN 141676 THEN 1853 ELSE population END WHERE id IN (141676);

UPDATE cities SET population = CASE id WHEN 113490 THEN 1852 WHEN 121839 THEN 1852 ELSE population END WHERE id IN (113490,121839);

UPDATE cities SET population = CASE id WHEN 118191 THEN 1851 ELSE population END WHERE id IN (118191);

UPDATE cities SET population = CASE id WHEN 141256 THEN 1850 ELSE population END WHERE id IN (141256);

UPDATE cities SET population = CASE id WHEN 128627 THEN 1849 ELSE population END WHERE id IN (128627);

UPDATE cities SET population = CASE id WHEN 129280 THEN 1848 ELSE population END WHERE id IN (129280);

UPDATE cities SET population = CASE id WHEN 115564 THEN 1847 WHEN 141162 THEN 1847 ELSE population END WHERE id IN (115564,141162);

UPDATE cities SET population = CASE id WHEN 112091 THEN 1846 WHEN 118739 THEN 1846 ELSE population END WHERE id IN (112091,118739);

UPDATE cities SET population = CASE id WHEN 127846 THEN 1843 ELSE population END WHERE id IN (127846);

UPDATE cities SET population = CASE id WHEN 121234 THEN 1842 ELSE population END WHERE id IN (121234);

UPDATE cities SET population = CASE id WHEN 114584 THEN 1841 ELSE population END WHERE id IN (114584);

UPDATE cities SET population = CASE id WHEN 111030 THEN 1840 WHEN 117932 THEN 1840 ELSE population END WHERE id IN (111030,117932);

UPDATE cities SET population = CASE id WHEN 118178 THEN 1839 WHEN 120015 THEN 1839 ELSE population END WHERE id IN (118178,120015);

UPDATE cities SET population = CASE id WHEN 112326 THEN 1835 WHEN 115251 THEN 1835 ELSE population END WHERE id IN (112326,115251);

UPDATE cities SET population = CASE id WHEN 112025 THEN 1834 ELSE population END WHERE id IN (112025);

UPDATE cities SET population = CASE id WHEN 115796 THEN 1831 WHEN 122060 THEN 1831 ELSE population END WHERE id IN (115796,122060);

UPDATE cities SET population = CASE id WHEN 113254 THEN 1830 ELSE population END WHERE id IN (113254);

UPDATE cities SET population = CASE id WHEN 111014 THEN 1829 WHEN 121641 THEN 1829 WHEN 125701 THEN 1829 ELSE population END WHERE id IN (111014,121641,125701);

UPDATE cities SET population = CASE id WHEN 112132 THEN 1828 WHEN 121038 THEN 1828 ELSE population END WHERE id IN (112132,121038);

UPDATE cities SET population = CASE id WHEN 112107 THEN 1827 WHEN 124807 THEN 1827 ELSE population END WHERE id IN (112107,124807);

UPDATE cities SET population = CASE id WHEN 125068 THEN 1826 ELSE population END WHERE id IN (125068);

UPDATE cities SET population = CASE id WHEN 113112 THEN 1825 WHEN 116935 THEN 1825 ELSE population END WHERE id IN (113112,116935);

UPDATE cities SET population = CASE id WHEN 141316 THEN 1824 ELSE population END WHERE id IN (141316);

UPDATE cities SET population = CASE id WHEN 114585 THEN 1823 ELSE population END WHERE id IN (114585);

UPDATE cities SET population = CASE id WHEN 128603 THEN 1821 WHEN 141649 THEN 1821 ELSE population END WHERE id IN (128603,141649);

UPDATE cities SET population = CASE id WHEN 115568 THEN 1816 ELSE population END WHERE id IN (115568);

UPDATE cities SET population = CASE id WHEN 113778 THEN 1815 WHEN 123584 THEN 1815 WHEN 128020 THEN 1815 ELSE population END WHERE id IN (113778,123584,128020);

UPDATE cities SET population = CASE id WHEN 115954 THEN 1810 WHEN 118891 THEN 1810 ELSE population END WHERE id IN (115954,118891);

UPDATE cities SET population = CASE id WHEN 116649 THEN 1809 ELSE population END WHERE id IN (116649);

UPDATE cities SET population = CASE id WHEN 118477 THEN 1806 ELSE population END WHERE id IN (118477);

UPDATE cities SET population = CASE id WHEN 115100 THEN 1805 WHEN 117161 THEN 1805 ELSE population END WHERE id IN (115100,117161);

UPDATE cities SET population = CASE id WHEN 115158 THEN 1803 ELSE population END WHERE id IN (115158);

UPDATE cities SET population = CASE id WHEN 128734 THEN 1802 WHEN 141647 THEN 1802 ELSE population END WHERE id IN (128734,141647);

UPDATE cities SET population = CASE id WHEN 120747 THEN 1800 ELSE population END WHERE id IN (120747);

UPDATE cities SET population = CASE id WHEN 116151 THEN 1799 ELSE population END WHERE id IN (116151);

UPDATE cities SET population = CASE id WHEN 123413 THEN 1798 ELSE population END WHERE id IN (123413);

UPDATE cities SET population = CASE id WHEN 115153 THEN 1797 ELSE population END WHERE id IN (115153);

UPDATE cities SET population = CASE id WHEN 111586 THEN 1795 WHEN 113276 THEN 1795 ELSE population END WHERE id IN (111586,113276);

UPDATE cities SET population = CASE id WHEN 141168 THEN 1794 ELSE population END WHERE id IN (141168);

UPDATE cities SET population = CASE id WHEN 117203 THEN 1792 WHEN 126809 THEN 1792 WHEN 127073 THEN 1792 ELSE population END WHERE id IN (117203,126809,127073);

UPDATE cities SET population = CASE id WHEN 128485 THEN 1787 WHEN 129258 THEN 1787 ELSE population END WHERE id IN (128485,129258);

UPDATE cities SET population = CASE id WHEN 120566 THEN 1784 ELSE population END WHERE id IN (120566);

UPDATE cities SET population = CASE id WHEN 114225 THEN 1783 WHEN 121748 THEN 1783 WHEN 126581 THEN 1783 ELSE population END WHERE id IN (114225,121748,126581);

UPDATE cities SET population = CASE id WHEN 112612 THEN 1781 ELSE population END WHERE id IN (112612);

UPDATE cities SET population = CASE id WHEN 118114 THEN 1779 WHEN 121621 THEN 1779 ELSE population END WHERE id IN (118114,121621);

UPDATE cities SET population = CASE id WHEN 123238 THEN 1777 ELSE population END WHERE id IN (123238);

UPDATE cities SET population = CASE id WHEN 115014 THEN 1776 WHEN 122846 THEN 1776 WHEN 123778 THEN 1776 ELSE population END WHERE id IN (115014,122846,123778);

UPDATE cities SET population = CASE id WHEN 114639 THEN 1775 WHEN 141808 THEN 1775 ELSE population END WHERE id IN (114639,141808);

UPDATE cities SET population = CASE id WHEN 115150 THEN 1773 WHEN 121195 THEN 1773 ELSE population END WHERE id IN (115150,121195);

UPDATE cities SET population = CASE id WHEN 124866 THEN 1772 ELSE population END WHERE id IN (124866);

UPDATE cities SET population = CASE id WHEN 126219 THEN 1771 ELSE population END WHERE id IN (126219);

UPDATE cities SET population = CASE id WHEN 112268 THEN 1770 WHEN 124869 THEN 1770 WHEN 141448 THEN 1770 ELSE population END WHERE id IN (112268,124869,141448);

UPDATE cities SET population = CASE id WHEN 119301 THEN 1768 WHEN 120429 THEN 1768 ELSE population END WHERE id IN (119301,120429);

UPDATE cities SET population = CASE id WHEN 115157 THEN 1767 ELSE population END WHERE id IN (115157);

UPDATE cities SET population = CASE id WHEN 117652 THEN 1765 ELSE population END WHERE id IN (117652);

UPDATE cities SET population = CASE id WHEN 122285 THEN 1764 ELSE population END WHERE id IN (122285);

UPDATE cities SET population = CASE id WHEN 119069 THEN 1762 ELSE population END WHERE id IN (119069);

UPDATE cities SET population = CASE id WHEN 123316 THEN 1761 ELSE population END WHERE id IN (123316);

UPDATE cities SET population = CASE id WHEN 120887 THEN 1760 WHEN 125091 THEN 1760 ELSE population END WHERE id IN (120887,125091);

UPDATE cities SET population = CASE id WHEN 116259 THEN 1759 ELSE population END WHERE id IN (116259);

UPDATE cities SET population = CASE id WHEN 125417 THEN 1756 ELSE population END WHERE id IN (125417);

UPDATE cities SET population = CASE id WHEN 127240 THEN 1755 ELSE population END WHERE id IN (127240);

UPDATE cities SET population = CASE id WHEN 119577 THEN 1750 ELSE population END WHERE id IN (119577);

UPDATE cities SET population = CASE id WHEN 141550 THEN 1745 ELSE population END WHERE id IN (141550);

UPDATE cities SET population = CASE id WHEN 117699 THEN 1744 ELSE population END WHERE id IN (117699);

UPDATE cities SET population = CASE id WHEN 116915 THEN 1743 WHEN 121742 THEN 1743 ELSE population END WHERE id IN (116915,121742);

UPDATE cities SET population = CASE id WHEN 120724 THEN 1742 WHEN 125281 THEN 1742 WHEN 141643 THEN 1742 ELSE population END WHERE id IN (120724,125281,141643);

UPDATE cities SET population = CASE id WHEN 118275 THEN 1740 WHEN 124414 THEN 1740 WHEN 129574 THEN 1740 ELSE population END WHERE id IN (118275,124414,129574);

UPDATE cities SET population = CASE id WHEN 112935 THEN 1738 WHEN 125376 THEN 1738 ELSE population END WHERE id IN (112935,125376);

UPDATE cities SET population = CASE id WHEN 120034 THEN 1737 ELSE population END WHERE id IN (120034);

UPDATE cities SET population = CASE id WHEN 118543 THEN 1735 ELSE population END WHERE id IN (118543);

UPDATE cities SET population = CASE id WHEN 113170 THEN 1733 WHEN 129359 THEN 1733 ELSE population END WHERE id IN (113170,129359);

UPDATE cities SET population = CASE id WHEN 115968 THEN 1732 WHEN 127062 THEN 1732 ELSE population END WHERE id IN (115968,127062);

UPDATE cities SET population = CASE id WHEN 121175 THEN 1731 ELSE population END WHERE id IN (121175);

UPDATE cities SET population = CASE id WHEN 124799 THEN 1728 ELSE population END WHERE id IN (124799);

UPDATE cities SET population = CASE id WHEN 129197 THEN 1727 ELSE population END WHERE id IN (129197);

UPDATE cities SET population = CASE id WHEN 124695 THEN 1726 WHEN 126808 THEN 1726 ELSE population END WHERE id IN (124695,126808);

UPDATE cities SET population = CASE id WHEN 111525 THEN 1725 WHEN 120084 THEN 1725 WHEN 128360 THEN 1725 ELSE population END WHERE id IN (111525,120084,128360);

UPDATE cities SET population = CASE id WHEN 111080 THEN 1724 WHEN 127099 THEN 1724 WHEN 129059 THEN 1724 ELSE population END WHERE id IN (111080,127099,129059);

UPDATE cities SET population = CASE id WHEN 120437 THEN 1722 ELSE population END WHERE id IN (120437);

UPDATE cities SET population = CASE id WHEN 141669 THEN 1721 ELSE population END WHERE id IN (141669);

UPDATE cities SET population = CASE id WHEN 111235 THEN 1720 ELSE population END WHERE id IN (111235);

UPDATE cities SET population = CASE id WHEN 141283 THEN 1719 ELSE population END WHERE id IN (141283);

UPDATE cities SET population = CASE id WHEN 121437 THEN 1717 ELSE population END WHERE id IN (121437);

UPDATE cities SET population = CASE id WHEN 111037 THEN 1716 WHEN 127796 THEN 1716 ELSE population END WHERE id IN (111037,127796);

UPDATE cities SET population = CASE id WHEN 128914 THEN 1715 ELSE population END WHERE id IN (128914);

UPDATE cities SET population = CASE id WHEN 117889 THEN 1711 ELSE population END WHERE id IN (117889);

UPDATE cities SET population = CASE id WHEN 111107 THEN 1710 ELSE population END WHERE id IN (111107);

UPDATE cities SET population = CASE id WHEN 125126 THEN 1706 WHEN 141278 THEN 1706 ELSE population END WHERE id IN (125126,141278);

UPDATE cities SET population = CASE id WHEN 113003 THEN 1704 ELSE population END WHERE id IN (113003);

UPDATE cities SET population = CASE id WHEN 123615 THEN 1703 WHEN 141304 THEN 1703 ELSE population END WHERE id IN (123615,141304);

UPDATE cities SET population = CASE id WHEN 121814 THEN 1701 WHEN 125230 THEN 1701 ELSE population END WHERE id IN (121814,125230);

UPDATE cities SET population = CASE id WHEN 141400 THEN 1699 ELSE population END WHERE id IN (141400);

UPDATE cities SET population = CASE id WHEN 113799 THEN 1696 ELSE population END WHERE id IN (113799);

UPDATE cities SET population = CASE id WHEN 111351 THEN 1695 ELSE population END WHERE id IN (111351);

UPDATE cities SET population = CASE id WHEN 118690 THEN 1693 WHEN 119303 THEN 1693 ELSE population END WHERE id IN (118690,119303);

UPDATE cities SET population = CASE id WHEN 128631 THEN 1692 ELSE population END WHERE id IN (128631);

UPDATE cities SET population = CASE id WHEN 129232 THEN 1690 WHEN 141189 THEN 1690 ELSE population END WHERE id IN (129232,141189);

UPDATE cities SET population = CASE id WHEN 112807 THEN 1688 ELSE population END WHERE id IN (112807);

UPDATE cities SET population = CASE id WHEN 114437 THEN 1687 ELSE population END WHERE id IN (114437);

UPDATE cities SET population = CASE id WHEN 116374 THEN 1682 WHEN 128732 THEN 1682 ELSE population END WHERE id IN (116374,128732);

UPDATE cities SET population = CASE id WHEN 116876 THEN 1681 ELSE population END WHERE id IN (116876);

UPDATE cities SET population = CASE id WHEN 116126 THEN 1680 ELSE population END WHERE id IN (116126);

UPDATE cities SET population = CASE id WHEN 123579 THEN 1677 WHEN 125942 THEN 1677 WHEN 128221 THEN 1677 ELSE population END WHERE id IN (123579,125942,128221);

UPDATE cities SET population = CASE id WHEN 113889 THEN 1675 WHEN 120376 THEN 1675 ELSE population END WHERE id IN (113889,120376);

UPDATE cities SET population = CASE id WHEN 115060 THEN 1672 ELSE population END WHERE id IN (115060);

UPDATE cities SET population = CASE id WHEN 120292 THEN 1671 ELSE population END WHERE id IN (120292);

UPDATE cities SET population = CASE id WHEN 119882 THEN 1670 ELSE population END WHERE id IN (119882);

UPDATE cities SET population = CASE id WHEN 121455 THEN 1669 WHEN 124387 THEN 1669 ELSE population END WHERE id IN (121455,124387);

UPDATE cities SET population = CASE id WHEN 111437 THEN 1668 WHEN 141719 THEN 1668 ELSE population END WHERE id IN (111437,141719);

UPDATE cities SET population = CASE id WHEN 111694 THEN 1667 WHEN 112805 THEN 1667 ELSE population END WHERE id IN (111694,112805);

UPDATE cities SET population = CASE id WHEN 111423 THEN 1666 WHEN 111660 THEN 1666 WHEN 121998 THEN 1666 ELSE population END WHERE id IN (111423,111660,121998);

UPDATE cities SET population = CASE id WHEN 115530 THEN 1665 WHEN 125404 THEN 1665 WHEN 129720 THEN 1665 ELSE population END WHERE id IN (115530,125404,129720);

UPDATE cities SET population = CASE id WHEN 127366 THEN 1663 ELSE population END WHERE id IN (127366);

UPDATE cities SET population = CASE id WHEN 123235 THEN 1662 ELSE population END WHERE id IN (123235);

UPDATE cities SET population = CASE id WHEN 121099 THEN 1661 WHEN 125948 THEN 1661 WHEN 141722 THEN 1661 ELSE population END WHERE id IN (121099,125948,141722);

UPDATE cities SET population = CASE id WHEN 128095 THEN 1659 ELSE population END WHERE id IN (128095);

UPDATE cities SET population = CASE id WHEN 117114 THEN 1658 ELSE population END WHERE id IN (117114);

UPDATE cities SET population = CASE id WHEN 115107 THEN 1657 WHEN 115246 THEN 1657 WHEN 117281 THEN 1657 ELSE population END WHERE id IN (115107,115246,117281);

UPDATE cities SET population = CASE id WHEN 111006 THEN 1656 WHEN 111414 THEN 1656 ELSE population END WHERE id IN (111006,111414);

UPDATE cities SET population = CASE id WHEN 118208 THEN 1655 ELSE population END WHERE id IN (118208);

UPDATE cities SET population = CASE id WHEN 126959 THEN 1654 ELSE population END WHERE id IN (126959);

UPDATE cities SET population = CASE id WHEN 141435 THEN 1652 ELSE population END WHERE id IN (141435);

UPDATE cities SET population = CASE id WHEN 111592 THEN 1648 WHEN 112690 THEN 1648 WHEN 141132 THEN 1648 ELSE population END WHERE id IN (111592,112690,141132);

UPDATE cities SET population = CASE id WHEN 118279 THEN 1647 WHEN 127933 THEN 1647 WHEN 128231 THEN 1647 WHEN 129087 THEN 1647 ELSE population END WHERE id IN (118279,127933,128231,129087);

UPDATE cities SET population = CASE id WHEN 125854 THEN 1645 WHEN 129469 THEN 1645 ELSE population END WHERE id IN (125854,129469);

UPDATE cities SET population = CASE id WHEN 127313 THEN 1644 WHEN 141500 THEN 1644 ELSE population END WHERE id IN (127313,141500);

UPDATE cities SET population = CASE id WHEN 129597 THEN 1643 ELSE population END WHERE id IN (129597);

UPDATE cities SET population = CASE id WHEN 141606 THEN 1642 ELSE population END WHERE id IN (141606);

UPDATE cities SET population = CASE id WHEN 117158 THEN 1640 WHEN 124798 THEN 1640 ELSE population END WHERE id IN (117158,124798);

UPDATE cities SET population = CASE id WHEN 125904 THEN 1638 WHEN 141817 THEN 1638 ELSE population END WHERE id IN (125904,141817);

UPDATE cities SET population = CASE id WHEN 124199 THEN 1636 ELSE population END WHERE id IN (124199);

UPDATE cities SET population = CASE id WHEN 123995 THEN 1635 ELSE population END WHERE id IN (123995);

UPDATE cities SET population = CASE id WHEN 118017 THEN 1634 WHEN 126823 THEN 1634 ELSE population END WHERE id IN (118017,126823);

UPDATE cities SET population = CASE id WHEN 122578 THEN 1633 ELSE population END WHERE id IN (122578);

UPDATE cities SET population = CASE id WHEN 117005 THEN 1632 WHEN 119622 THEN 1632 WHEN 125090 THEN 1632 ELSE population END WHERE id IN (117005,119622,125090);

UPDATE cities SET population = CASE id WHEN 121116 THEN 1631 WHEN 125460 THEN 1631 ELSE population END WHERE id IN (121116,125460);

UPDATE cities SET population = CASE id WHEN 118595 THEN 1630 WHEN 127238 THEN 1630 ELSE population END WHERE id IN (118595,127238);

UPDATE cities SET population = CASE id WHEN 114008 THEN 1627 WHEN 141632 THEN 1627 ELSE population END WHERE id IN (114008,141632);

UPDATE cities SET population = CASE id WHEN 127480 THEN 1626 ELSE population END WHERE id IN (127480);

UPDATE cities SET population = CASE id WHEN 114498 THEN 1625 WHEN 117055 THEN 1625 WHEN 117611 THEN 1625 ELSE population END WHERE id IN (114498,117055,117611);

UPDATE cities SET population = CASE id WHEN 129233 THEN 1622 ELSE population END WHERE id IN (129233);

UPDATE cities SET population = CASE id WHEN 120805 THEN 1621 WHEN 123564 THEN 1621 WHEN 128779 THEN 1621 ELSE population END WHERE id IN (120805,123564,128779);

UPDATE cities SET population = CASE id WHEN 128418 THEN 1619 ELSE population END WHERE id IN (128418);

UPDATE cities SET population = CASE id WHEN 111579 THEN 1617 ELSE population END WHERE id IN (111579);

UPDATE cities SET population = CASE id WHEN 124324 THEN 1616 ELSE population END WHERE id IN (124324);

UPDATE cities SET population = CASE id WHEN 117480 THEN 1615 WHEN 120544 THEN 1615 WHEN 122485 THEN 1615 WHEN 128748 THEN 1615 ELSE population END WHERE id IN (117480,120544,122485,128748);

UPDATE cities SET population = CASE id WHEN 123201 THEN 1614 ELSE population END WHERE id IN (123201);

UPDATE cities SET population = CASE id WHEN 129330 THEN 1613 ELSE population END WHERE id IN (129330);

UPDATE cities SET population = CASE id WHEN 126625 THEN 1612 ELSE population END WHERE id IN (126625);

UPDATE cities SET population = CASE id WHEN 116130 THEN 1611 ELSE population END WHERE id IN (116130);

UPDATE cities SET population = CASE id WHEN 115048 THEN 1610 WHEN 116830 THEN 1610 WHEN 123447 THEN 1610 ELSE population END WHERE id IN (115048,116830,123447);

UPDATE cities SET population = CASE id WHEN 120441 THEN 1609 ELSE population END WHERE id IN (120441);

UPDATE cities SET population = CASE id WHEN 111266 THEN 1608 WHEN 114985 THEN 1608 ELSE population END WHERE id IN (111266,114985);

UPDATE cities SET population = CASE id WHEN 119165 THEN 1606 ELSE population END WHERE id IN (119165);

UPDATE cities SET population = CASE id WHEN 118076 THEN 1605 ELSE population END WHERE id IN (118076);

UPDATE cities SET population = CASE id WHEN 114393 THEN 1603 ELSE population END WHERE id IN (114393);

UPDATE cities SET population = CASE id WHEN 127143 THEN 1602 ELSE population END WHERE id IN (127143);

UPDATE cities SET population = CASE id WHEN 117404 THEN 1600 WHEN 125276 THEN 1600 ELSE population END WHERE id IN (117404,125276);

UPDATE cities SET population = CASE id WHEN 141504 THEN 1599 ELSE population END WHERE id IN (141504);

UPDATE cities SET population = CASE id WHEN 122132 THEN 1596 ELSE population END WHERE id IN (122132);

UPDATE cities SET population = CASE id WHEN 111950 THEN 1592 WHEN 121444 THEN 1592 ELSE population END WHERE id IN (111950,121444);

UPDATE cities SET population = CASE id WHEN 123300 THEN 1591 ELSE population END WHERE id IN (123300);

UPDATE cities SET population = CASE id WHEN 113189 THEN 1590 WHEN 127794 THEN 1590 WHEN 128918 THEN 1590 ELSE population END WHERE id IN (113189,127794,128918);

UPDATE cities SET population = CASE id WHEN 111127 THEN 1589 WHEN 114682 THEN 1589 ELSE population END WHERE id IN (111127,114682);

UPDATE cities SET population = CASE id WHEN 115094 THEN 1588 ELSE population END WHERE id IN (115094);

UPDATE cities SET population = CASE id WHEN 122181 THEN 1587 WHEN 125412 THEN 1587 ELSE population END WHERE id IN (122181,125412);

UPDATE cities SET population = CASE id WHEN 126230 THEN 1586 ELSE population END WHERE id IN (126230);

UPDATE cities SET population = CASE id WHEN 126784 THEN 1585 ELSE population END WHERE id IN (126784);

UPDATE cities SET population = CASE id WHEN 122401 THEN 1584 WHEN 126899 THEN 1584 WHEN 127984 THEN 1584 ELSE population END WHERE id IN (122401,126899,127984);

UPDATE cities SET population = CASE id WHEN 113871 THEN 1580 WHEN 118450 THEN 1580 WHEN 124253 THEN 1580 WHEN 141572 THEN 1580 ELSE population END WHERE id IN (113871,118450,124253,141572);

UPDATE cities SET population = CASE id WHEN 127615 THEN 1579 ELSE population END WHERE id IN (127615);

UPDATE cities SET population = CASE id WHEN 115095 THEN 1578 ELSE population END WHERE id IN (115095);

UPDATE cities SET population = CASE id WHEN 114270 THEN 1577 WHEN 116440 THEN 1577 WHEN 117401 THEN 1577 WHEN 126935 THEN 1577 WHEN 127126 THEN 1577 ELSE population END WHERE id IN (114270,116440,117401,126935,127126);

UPDATE cities SET population = CASE id WHEN 124300 THEN 1576 ELSE population END WHERE id IN (124300);

UPDATE cities SET population = CASE id WHEN 115116 THEN 1575 WHEN 115154 THEN 1575 WHEN 124097 THEN 1575 ELSE population END WHERE id IN (115116,115154,124097);

UPDATE cities SET population = CASE id WHEN 117071 THEN 1574 WHEN 121237 THEN 1574 WHEN 121743 THEN 1574 WHEN 126546 THEN 1574 ELSE population END WHERE id IN (117071,121237,121743,126546);

UPDATE cities SET population = CASE id WHEN 115494 THEN 1572 ELSE population END WHERE id IN (115494);

UPDATE cities SET population = CASE id WHEN 118747 THEN 1571 WHEN 120425 THEN 1571 ELSE population END WHERE id IN (118747,120425);

UPDATE cities SET population = CASE id WHEN 123292 THEN 1569 ELSE population END WHERE id IN (123292);

UPDATE cities SET population = CASE id WHEN 129171 THEN 1568 ELSE population END WHERE id IN (129171);

UPDATE cities SET population = CASE id WHEN 113768 THEN 1567 WHEN 122123 THEN 1567 WHEN 129077 THEN 1567 ELSE population END WHERE id IN (113768,122123,129077);

UPDATE cities SET population = CASE id WHEN 122848 THEN 1566 ELSE population END WHERE id IN (122848);

UPDATE cities SET population = CASE id WHEN 116003 THEN 1565 ELSE population END WHERE id IN (116003);

UPDATE cities SET population = CASE id WHEN 125339 THEN 1564 ELSE population END WHERE id IN (125339);

UPDATE cities SET population = CASE id WHEN 120493 THEN 1563 WHEN 128482 THEN 1563 ELSE population END WHERE id IN (120493,128482);

UPDATE cities SET population = CASE id WHEN 121849 THEN 1562 ELSE population END WHERE id IN (121849);

UPDATE cities SET population = CASE id WHEN 125755 THEN 1561 ELSE population END WHERE id IN (125755);

UPDATE cities SET population = CASE id WHEN 113694 THEN 1560 WHEN 113847 THEN 1560 WHEN 125071 THEN 1560 ELSE population END WHERE id IN (113694,113847,125071);

UPDATE cities SET population = CASE id WHEN 114168 THEN 1559 WHEN 119618 THEN 1559 ELSE population END WHERE id IN (114168,119618);

UPDATE cities SET population = CASE id WHEN 116488 THEN 1558 WHEN 122136 THEN 1558 ELSE population END WHERE id IN (116488,122136);

UPDATE cities SET population = CASE id WHEN 125089 THEN 1557 ELSE population END WHERE id IN (125089);

UPDATE cities SET population = CASE id WHEN 117357 THEN 1556 ELSE population END WHERE id IN (117357);

UPDATE cities SET population = CASE id WHEN 111129 THEN 1553 WHEN 116165 THEN 1553 ELSE population END WHERE id IN (111129,116165);

UPDATE cities SET population = CASE id WHEN 125733 THEN 1551 WHEN 128519 THEN 1551 WHEN 128628 THEN 1551 ELSE population END WHERE id IN (125733,128519,128628);

UPDATE cities SET population = CASE id WHEN 117534 THEN 1548 WHEN 118486 THEN 1548 WHEN 121611 THEN 1548 ELSE population END WHERE id IN (117534,118486,121611);

UPDATE cities SET population = CASE id WHEN 122279 THEN 1545 WHEN 141105 THEN 1545 ELSE population END WHERE id IN (122279,141105);

UPDATE cities SET population = CASE id WHEN 117891 THEN 1544 WHEN 124757 THEN 1544 ELSE population END WHERE id IN (117891,124757);

UPDATE cities SET population = CASE id WHEN 118238 THEN 1543 WHEN 141176 THEN 1543 ELSE population END WHERE id IN (118238,141176);

UPDATE cities SET population = CASE id WHEN 128419 THEN 1542 ELSE population END WHERE id IN (128419);

UPDATE cities SET population = CASE id WHEN 116989 THEN 1541 WHEN 122163 THEN 1541 ELSE population END WHERE id IN (116989,122163);

UPDATE cities SET population = CASE id WHEN 116127 THEN 1540 WHEN 120482 THEN 1540 WHEN 129354 THEN 1540 ELSE population END WHERE id IN (116127,120482,129354);

UPDATE cities SET population = CASE id WHEN 121887 THEN 1539 ELSE population END WHERE id IN (121887);

UPDATE cities SET population = CASE id WHEN 117103 THEN 1538 ELSE population END WHERE id IN (117103);

UPDATE cities SET population = CASE id WHEN 114652 THEN 1537 ELSE population END WHERE id IN (114652);

UPDATE cities SET population = CASE id WHEN 127123 THEN 1535 ELSE population END WHERE id IN (127123);

UPDATE cities SET population = CASE id WHEN 111651 THEN 1532 WHEN 118958 THEN 1532 WHEN 122715 THEN 1532 WHEN 123309 THEN 1532 ELSE population END WHERE id IN (111651,118958,122715,123309);

UPDATE cities SET population = CASE id WHEN 117397 THEN 1531 ELSE population END WHERE id IN (117397);

UPDATE cities SET population = CASE id WHEN 114887 THEN 1529 WHEN 116902 THEN 1529 ELSE population END WHERE id IN (114887,116902);

UPDATE cities SET population = CASE id WHEN 122183 THEN 1527 ELSE population END WHERE id IN (122183);

UPDATE cities SET population = CASE id WHEN 117282 THEN 1526 ELSE population END WHERE id IN (117282);

UPDATE cities SET population = CASE id WHEN 118816 THEN 1524 WHEN 121185 THEN 1524 ELSE population END WHERE id IN (118816,121185);

UPDATE cities SET population = CASE id WHEN 112767 THEN 1521 ELSE population END WHERE id IN (112767);

UPDATE cities SET population = CASE id WHEN 122611 THEN 1520 ELSE population END WHERE id IN (122611);

UPDATE cities SET population = CASE id WHEN 126968 THEN 1519 ELSE population END WHERE id IN (126968);

UPDATE cities SET population = CASE id WHEN 128619 THEN 1517 ELSE population END WHERE id IN (128619);

UPDATE cities SET population = CASE id WHEN 117567 THEN 1515 WHEN 122728 THEN 1515 ELSE population END WHERE id IN (117567,122728);

UPDATE cities SET population = CASE id WHEN 129399 THEN 1514 ELSE population END WHERE id IN (129399);

UPDATE cities SET population = CASE id WHEN 121244 THEN 1511 ELSE population END WHERE id IN (121244);

UPDATE cities SET population = CASE id WHEN 117751 THEN 1508 ELSE population END WHERE id IN (117751);

UPDATE cities SET population = CASE id WHEN 123288 THEN 1507 WHEN 126310 THEN 1507 ELSE population END WHERE id IN (123288,126310);

UPDATE cities SET population = CASE id WHEN 111196 THEN 1506 WHEN 113777 THEN 1506 WHEN 126490 THEN 1506 ELSE population END WHERE id IN (111196,113777,126490);

UPDATE cities SET population = CASE id WHEN 119276 THEN 1504 ELSE population END WHERE id IN (119276);

UPDATE cities SET population = CASE id WHEN 129576 THEN 1503 ELSE population END WHERE id IN (129576);

UPDATE cities SET population = CASE id WHEN 111596 THEN 1502 WHEN 117630 THEN 1502 ELSE population END WHERE id IN (111596,117630);

UPDATE cities SET population = CASE id WHEN 115365 THEN 1499 WHEN 115973 THEN 1499 ELSE population END WHERE id IN (115365,115973);

UPDATE cities SET population = CASE id WHEN 124713 THEN 1498 ELSE population END WHERE id IN (124713);

UPDATE cities SET population = CASE id WHEN 121433 THEN 1497 WHEN 127045 THEN 1497 ELSE population END WHERE id IN (121433,127045);

UPDATE cities SET population = CASE id WHEN 128211 THEN 1496 ELSE population END WHERE id IN (128211);

UPDATE cities SET population = CASE id WHEN 124552 THEN 1495 WHEN 128518 THEN 1495 ELSE population END WHERE id IN (124552,128518);

UPDATE cities SET population = CASE id WHEN 113255 THEN 1494 ELSE population END WHERE id IN (113255);

UPDATE cities SET population = CASE id WHEN 118821 THEN 1493 WHEN 119626 THEN 1493 WHEN 121691 THEN 1493 ELSE population END WHERE id IN (118821,119626,121691);

UPDATE cities SET population = CASE id WHEN 111794 THEN 1492 ELSE population END WHERE id IN (111794);

UPDATE cities SET population = CASE id WHEN 116441 THEN 1491 ELSE population END WHERE id IN (116441);

UPDATE cities SET population = CASE id WHEN 122230 THEN 1489 WHEN 125709 THEN 1489 ELSE population END WHERE id IN (122230,125709);

UPDATE cities SET population = CASE id WHEN 141474 THEN 1487 WHEN 141811 THEN 1487 ELSE population END WHERE id IN (141474,141811);

UPDATE cities SET population = CASE id WHEN 112185 THEN 1485 WHEN 116913 THEN 1485 ELSE population END WHERE id IN (112185,116913);

UPDATE cities SET population = CASE id WHEN 129553 THEN 1483 ELSE population END WHERE id IN (129553);

UPDATE cities SET population = CASE id WHEN 129333 THEN 1482 WHEN 129531 THEN 1482 ELSE population END WHERE id IN (129333,129531);

UPDATE cities SET population = CASE id WHEN 121306 THEN 1480 WHEN 129380 THEN 1480 ELSE population END WHERE id IN (121306,129380);

UPDATE cities SET population = CASE id WHEN 112763 THEN 1479 WHEN 118491 THEN 1479 WHEN 124098 THEN 1479 ELSE population END WHERE id IN (112763,118491,124098);

UPDATE cities SET population = CASE id WHEN 115168 THEN 1478 WHEN 116804 THEN 1478 ELSE population END WHERE id IN (115168,116804);

UPDATE cities SET population = CASE id WHEN 121135 THEN 1472 ELSE population END WHERE id IN (121135);

UPDATE cities SET population = CASE id WHEN 116192 THEN 1471 ELSE population END WHERE id IN (116192);

UPDATE cities SET population = CASE id WHEN 123273 THEN 1469 ELSE population END WHERE id IN (123273);

UPDATE cities SET population = CASE id WHEN 114247 THEN 1468 WHEN 121151 THEN 1468 ELSE population END WHERE id IN (114247,121151);

UPDATE cities SET population = CASE id WHEN 113742 THEN 1467 ELSE population END WHERE id IN (113742);

UPDATE cities SET population = CASE id WHEN 111692 THEN 1466 WHEN 141359 THEN 1466 ELSE population END WHERE id IN (111692,141359);

UPDATE cities SET population = CASE id WHEN 120694 THEN 1465 ELSE population END WHERE id IN (120694);

UPDATE cities SET population = CASE id WHEN 118009 THEN 1464 WHEN 118538 THEN 1464 WHEN 141718 THEN 1464 ELSE population END WHERE id IN (118009,118538,141718);

UPDATE cities SET population = CASE id WHEN 120994 THEN 1462 WHEN 122266 THEN 1462 ELSE population END WHERE id IN (120994,122266);

UPDATE cities SET population = CASE id WHEN 141184 THEN 1461 ELSE population END WHERE id IN (141184);

UPDATE cities SET population = CASE id WHEN 128607 THEN 1460 ELSE population END WHERE id IN (128607);

UPDATE cities SET population = CASE id WHEN 128061 THEN 1459 ELSE population END WHERE id IN (128061);

UPDATE cities SET population = CASE id WHEN 114537 THEN 1458 ELSE population END WHERE id IN (114537);

UPDATE cities SET population = CASE id WHEN 115447 THEN 1457 ELSE population END WHERE id IN (115447);

UPDATE cities SET population = CASE id WHEN 122812 THEN 1455 ELSE population END WHERE id IN (122812);

UPDATE cities SET population = CASE id WHEN 111994 THEN 1454 WHEN 127852 THEN 1454 ELSE population END WHERE id IN (111994,127852);

UPDATE cities SET population = CASE id WHEN 111753 THEN 1453 WHEN 141112 THEN 1453 ELSE population END WHERE id IN (111753,141112);

UPDATE cities SET population = CASE id WHEN 113767 THEN 1452 WHEN 113902 THEN 1452 ELSE population END WHERE id IN (113767,113902);

UPDATE cities SET population = CASE id WHEN 119255 THEN 1451 ELSE population END WHERE id IN (119255);

UPDATE cities SET population = CASE id WHEN 115860 THEN 1450 ELSE population END WHERE id IN (115860);

UPDATE cities SET population = CASE id WHEN 112873 THEN 1449 ELSE population END WHERE id IN (112873);

UPDATE cities SET population = CASE id WHEN 118742 THEN 1448 ELSE population END WHERE id IN (118742);

UPDATE cities SET population = CASE id WHEN 115953 THEN 1445 ELSE population END WHERE id IN (115953);

UPDATE cities SET population = CASE id WHEN 113041 THEN 1444 WHEN 115082 THEN 1444 ELSE population END WHERE id IN (113041,115082);

UPDATE cities SET population = CASE id WHEN 118745 THEN 1443 WHEN 125699 THEN 1443 ELSE population END WHERE id IN (118745,125699);

UPDATE cities SET population = CASE id WHEN 114903 THEN 1442 WHEN 127144 THEN 1442 ELSE population END WHERE id IN (114903,127144);

UPDATE cities SET population = CASE id WHEN 141317 THEN 1441 ELSE population END WHERE id IN (141317);

UPDATE cities SET population = CASE id WHEN 127314 THEN 1440 ELSE population END WHERE id IN (127314);

UPDATE cities SET population = CASE id WHEN 115452 THEN 1437 WHEN 116078 THEN 1437 WHEN 141166 THEN 1437 ELSE population END WHERE id IN (115452,116078,141166);

UPDATE cities SET population = CASE id WHEN 125094 THEN 1435 ELSE population END WHERE id IN (125094);

UPDATE cities SET population = CASE id WHEN 117076 THEN 1434 WHEN 129394 THEN 1434 ELSE population END WHERE id IN (117076,129394);

UPDATE cities SET population = CASE id WHEN 125142 THEN 1432 ELSE population END WHERE id IN (125142);

UPDATE cities SET population = CASE id WHEN 117487 THEN 1431 WHEN 123893 THEN 1431 ELSE population END WHERE id IN (117487,123893);

UPDATE cities SET population = CASE id WHEN 126428 THEN 1430 ELSE population END WHERE id IN (126428);

UPDATE cities SET population = CASE id WHEN 141372 THEN 1429 ELSE population END WHERE id IN (141372);

UPDATE cities SET population = CASE id WHEN 123990 THEN 1428 ELSE population END WHERE id IN (123990);

UPDATE cities SET population = CASE id WHEN 121692 THEN 1427 ELSE population END WHERE id IN (121692);

UPDATE cities SET population = CASE id WHEN 112127 THEN 1426 WHEN 118250 THEN 1426 ELSE population END WHERE id IN (112127,118250);

UPDATE cities SET population = CASE id WHEN 121873 THEN 1425 ELSE population END WHERE id IN (121873);

UPDATE cities SET population = CASE id WHEN 116835 THEN 1424 WHEN 127807 THEN 1424 ELSE population END WHERE id IN (116835,127807);

UPDATE cities SET population = CASE id WHEN 127241 THEN 1422 WHEN 129496 THEN 1422 ELSE population END WHERE id IN (127241,129496);

UPDATE cities SET population = CASE id WHEN 113798 THEN 1421 ELSE population END WHERE id IN (113798);

UPDATE cities SET population = CASE id WHEN 112870 THEN 1420 WHEN 118451 THEN 1420 ELSE population END WHERE id IN (112870,118451);

UPDATE cities SET population = CASE id WHEN 114281 THEN 1419 WHEN 117099 THEN 1419 ELSE population END WHERE id IN (114281,117099);

UPDATE cities SET population = CASE id WHEN 121840 THEN 1418 ELSE population END WHERE id IN (121840);

UPDATE cities SET population = CASE id WHEN 115544 THEN 1417 ELSE population END WHERE id IN (115544);

UPDATE cities SET population = CASE id WHEN 111155 THEN 1415 WHEN 112022 THEN 1415 WHEN 113696 THEN 1415 WHEN 122744 THEN 1415 WHEN 127293 THEN 1415 ELSE population END WHERE id IN (111155,112022,113696,122744,127293);

UPDATE cities SET population = CASE id WHEN 126967 THEN 1414 ELSE population END WHERE id IN (126967);

UPDATE cities SET population = CASE id WHEN 122252 THEN 1412 ELSE population END WHERE id IN (122252);

UPDATE cities SET population = CASE id WHEN 122128 THEN 1411 WHEN 123687 THEN 1411 ELSE population END WHERE id IN (122128,123687);

UPDATE cities SET population = CASE id WHEN 114257 THEN 1410 ELSE population END WHERE id IN (114257);

UPDATE cities SET population = CASE id WHEN 114156 THEN 1409 ELSE population END WHERE id IN (114156);

UPDATE cities SET population = CASE id WHEN 114239 THEN 1408 WHEN 114844 THEN 1408 WHEN 119132 THEN 1408 WHEN 125535 THEN 1408 ELSE population END WHERE id IN (114239,114844,119132,125535);

UPDATE cities SET population = CASE id WHEN 112667 THEN 1406 WHEN 120687 THEN 1406 ELSE population END WHERE id IN (112667,120687);

UPDATE cities SET population = CASE id WHEN 128478 THEN 1405 ELSE population END WHERE id IN (128478);

UPDATE cities SET population = CASE id WHEN 121916 THEN 1403 WHEN 128362 THEN 1403 ELSE population END WHERE id IN (121916,128362);

UPDATE cities SET population = CASE id WHEN 113171 THEN 1402 WHEN 115974 THEN 1402 ELSE population END WHERE id IN (113171,115974);

UPDATE cities SET population = CASE id WHEN 121091 THEN 1401 WHEN 141640 THEN 1401 ELSE population END WHERE id IN (121091,141640);

UPDATE cities SET population = CASE id WHEN 111699 THEN 1399 WHEN 122098 THEN 1399 ELSE population END WHERE id IN (111699,122098);

UPDATE cities SET population = CASE id WHEN 128547 THEN 1398 ELSE population END WHERE id IN (128547);

UPDATE cities SET population = CASE id WHEN 126906 THEN 1396 WHEN 128670 THEN 1396 ELSE population END WHERE id IN (126906,128670);

UPDATE cities SET population = CASE id WHEN 120192 THEN 1394 ELSE population END WHERE id IN (120192);

UPDATE cities SET population = CASE id WHEN 118113 THEN 1393 WHEN 141294 THEN 1393 ELSE population END WHERE id IN (118113,141294);

UPDATE cities SET population = CASE id WHEN 120424 THEN 1392 ELSE population END WHERE id IN (120424);

UPDATE cities SET population = CASE id WHEN 124134 THEN 1388 ELSE population END WHERE id IN (124134);

UPDATE cities SET population = CASE id WHEN 120030 THEN 1385 ELSE population END WHERE id IN (120030);

UPDATE cities SET population = CASE id WHEN 123161 THEN 1384 WHEN 125745 THEN 1384 ELSE population END WHERE id IN (123161,125745);

UPDATE cities SET population = CASE id WHEN 126594 THEN 1383 ELSE population END WHERE id IN (126594);

UPDATE cities SET population = CASE id WHEN 118085 THEN 1382 WHEN 123283 THEN 1382 ELSE population END WHERE id IN (118085,123283);

UPDATE cities SET population = CASE id WHEN 122829 THEN 1381 WHEN 127499 THEN 1381 ELSE population END WHERE id IN (122829,127499);

UPDATE cities SET population = CASE id WHEN 113980 THEN 1380 WHEN 118414 THEN 1380 WHEN 122196 THEN 1380 ELSE population END WHERE id IN (113980,118414,122196);

UPDATE cities SET population = CASE id WHEN 129406 THEN 1378 ELSE population END WHERE id IN (129406);

UPDATE cities SET population = CASE id WHEN 120775 THEN 1376 WHEN 128479 THEN 1376 WHEN 129635 THEN 1376 ELSE population END WHERE id IN (120775,128479,129635);

UPDATE cities SET population = CASE id WHEN 129290 THEN 1375 ELSE population END WHERE id IN (129290);

UPDATE cities SET population = CASE id WHEN 114932 THEN 1374 WHEN 126752 THEN 1374 ELSE population END WHERE id IN (114932,126752);

UPDATE cities SET population = CASE id WHEN 122914 THEN 1373 WHEN 124908 THEN 1373 ELSE population END WHERE id IN (122914,124908);

UPDATE cities SET population = CASE id WHEN 116067 THEN 1372 ELSE population END WHERE id IN (116067);

UPDATE cities SET population = CASE id WHEN 126916 THEN 1371 ELSE population END WHERE id IN (126916);

UPDATE cities SET population = CASE id WHEN 125878 THEN 1370 WHEN 141533 THEN 1370 ELSE population END WHERE id IN (125878,141533);

UPDATE cities SET population = CASE id WHEN 116489 THEN 1369 ELSE population END WHERE id IN (116489);

UPDATE cities SET population = CASE id WHEN 117447 THEN 1368 WHEN 128019 THEN 1368 ELSE population END WHERE id IN (117447,128019);

UPDATE cities SET population = CASE id WHEN 129489 THEN 1367 ELSE population END WHERE id IN (129489);

UPDATE cities SET population = CASE id WHEN 122750 THEN 1365 ELSE population END WHERE id IN (122750);

UPDATE cities SET population = CASE id WHEN 120739 THEN 1364 WHEN 129579 THEN 1364 ELSE population END WHERE id IN (120739,129579);

UPDATE cities SET population = CASE id WHEN 115611 THEN 1363 WHEN 129451 THEN 1363 ELSE population END WHERE id IN (115611,129451);

UPDATE cities SET population = CASE id WHEN 118644 THEN 1362 WHEN 129114 THEN 1362 ELSE population END WHERE id IN (118644,129114);

UPDATE cities SET population = CASE id WHEN 111039 THEN 1361 WHEN 114886 THEN 1361 WHEN 117933 THEN 1361 WHEN 141115 THEN 1361 ELSE population END WHERE id IN (111039,114886,117933,141115);

UPDATE cities SET population = CASE id WHEN 113667 THEN 1359 ELSE population END WHERE id IN (113667);

UPDATE cities SET population = CASE id WHEN 116892 THEN 1357 ELSE population END WHERE id IN (116892);

UPDATE cities SET population = CASE id WHEN 115897 THEN 1356 ELSE population END WHERE id IN (115897);

UPDATE cities SET population = CASE id WHEN 111734 THEN 1355 ELSE population END WHERE id IN (111734);

UPDATE cities SET population = CASE id WHEN 111620 THEN 1352 WHEN 129567 THEN 1352 ELSE population END WHERE id IN (111620,129567);

UPDATE cities SET population = CASE id WHEN 112410 THEN 1351 WHEN 120663 THEN 1351 ELSE population END WHERE id IN (112410,120663);

UPDATE cities SET population = CASE id WHEN 123446 THEN 1350 ELSE population END WHERE id IN (123446);

UPDATE cities SET population = CASE id WHEN 116302 THEN 1349 WHEN 118606 THEN 1349 ELSE population END WHERE id IN (116302,118606);

UPDATE cities SET population = CASE id WHEN 121655 THEN 1348 WHEN 122777 THEN 1348 ELSE population END WHERE id IN (121655,122777);

UPDATE cities SET population = CASE id WHEN 120606 THEN 1347 WHEN 141519 THEN 1347 ELSE population END WHERE id IN (120606,141519);

UPDATE cities SET population = CASE id WHEN 119917 THEN 1346 ELSE population END WHERE id IN (119917);

UPDATE cities SET population = CASE id WHEN 118010 THEN 1345 ELSE population END WHERE id IN (118010);

UPDATE cities SET population = CASE id WHEN 126879 THEN 1342 ELSE population END WHERE id IN (126879);

UPDATE cities SET population = CASE id WHEN 111396 THEN 1341 WHEN 118896 THEN 1341 ELSE population END WHERE id IN (111396,118896);

UPDATE cities SET population = CASE id WHEN 123172 THEN 1340 ELSE population END WHERE id IN (123172);

UPDATE cities SET population = CASE id WHEN 116563 THEN 1339 WHEN 122553 THEN 1339 WHEN 129573 THEN 1339 ELSE population END WHERE id IN (116563,122553,129573);

UPDATE cities SET population = CASE id WHEN 125641 THEN 1337 ELSE population END WHERE id IN (125641);

UPDATE cities SET population = CASE id WHEN 119774 THEN 1336 ELSE population END WHERE id IN (119774);

UPDATE cities SET population = CASE id WHEN 119316 THEN 1333 ELSE population END WHERE id IN (119316);

UPDATE cities SET population = CASE id WHEN 111923 THEN 1332 ELSE population END WHERE id IN (111923);

UPDATE cities SET population = CASE id WHEN 121859 THEN 1331 ELSE population END WHERE id IN (121859);

UPDATE cities SET population = CASE id WHEN 117388 THEN 1330 ELSE population END WHERE id IN (117388);

UPDATE cities SET population = CASE id WHEN 119225 THEN 1329 WHEN 125635 THEN 1329 ELSE population END WHERE id IN (119225,125635);

UPDATE cities SET population = CASE id WHEN 122743 THEN 1328 ELSE population END WHERE id IN (122743);

UPDATE cities SET population = CASE id WHEN 119256 THEN 1327 WHEN 122944 THEN 1327 ELSE population END WHERE id IN (119256,122944);

UPDATE cities SET population = CASE id WHEN 111733 THEN 1325 WHEN 125364 THEN 1325 WHEN 125400 THEN 1325 WHEN 125737 THEN 1325 ELSE population END WHERE id IN (111733,125364,125400,125737);

UPDATE cities SET population = CASE id WHEN 122085 THEN 1324 ELSE population END WHERE id IN (122085);

UPDATE cities SET population = CASE id WHEN 121794 THEN 1323 ELSE population END WHERE id IN (121794);

UPDATE cities SET population = CASE id WHEN 116898 THEN 1322 ELSE population END WHERE id IN (116898);

UPDATE cities SET population = CASE id WHEN 117141 THEN 1320 WHEN 118185 THEN 1320 WHEN 121636 THEN 1320 ELSE population END WHERE id IN (117141,118185,121636);

UPDATE cities SET population = CASE id WHEN 114269 THEN 1318 WHEN 117535 THEN 1318 WHEN 127847 THEN 1318 ELSE population END WHERE id IN (114269,117535,127847);

UPDATE cities SET population = CASE id WHEN 117647 THEN 1316 WHEN 127600 THEN 1316 ELSE population END WHERE id IN (117647,127600);

UPDATE cities SET population = CASE id WHEN 114323 THEN 1315 WHEN 121789 THEN 1315 ELSE population END WHERE id IN (114323,121789);

UPDATE cities SET population = CASE id WHEN 121769 THEN 1314 ELSE population END WHERE id IN (121769);

UPDATE cities SET population = CASE id WHEN 126903 THEN 1312 ELSE population END WHERE id IN (126903);

UPDATE cities SET population = CASE id WHEN 113008 THEN 1311 ELSE population END WHERE id IN (113008);

UPDATE cities SET population = CASE id WHEN 129423 THEN 1310 ELSE population END WHERE id IN (129423);

UPDATE cities SET population = CASE id WHEN 128535 THEN 1309 ELSE population END WHERE id IN (128535);

UPDATE cities SET population = CASE id WHEN 126500 THEN 1308 WHEN 141151 THEN 1308 ELSE population END WHERE id IN (126500,141151);

UPDATE cities SET population = CASE id WHEN 111658 THEN 1307 WHEN 124404 THEN 1307 ELSE population END WHERE id IN (111658,124404);

UPDATE cities SET population = CASE id WHEN 116410 THEN 1306 ELSE population END WHERE id IN (116410);

UPDATE cities SET population = CASE id WHEN 112711 THEN 1305 WHEN 118239 THEN 1305 ELSE population END WHERE id IN (112711,118239);

UPDATE cities SET population = CASE id WHEN 118957 THEN 1304 WHEN 125360 THEN 1304 ELSE population END WHERE id IN (118957,125360);

UPDATE cities SET population = CASE id WHEN 127464 THEN 1302 ELSE population END WHERE id IN (127464);

UPDATE cities SET population = CASE id WHEN 112139 THEN 1301 ELSE population END WHERE id IN (112139);

UPDATE cities SET population = CASE id WHEN 113012 THEN 1299 WHEN 115788 THEN 1299 WHEN 124656 THEN 1299 ELSE population END WHERE id IN (113012,115788,124656);

UPDATE cities SET population = CASE id WHEN 112491 THEN 1297 ELSE population END WHERE id IN (112491);

UPDATE cities SET population = CASE id WHEN 122433 THEN 1294 WHEN 123755 THEN 1294 WHEN 141444 THEN 1294 ELSE population END WHERE id IN (122433,123755,141444);

UPDATE cities SET population = CASE id WHEN 126807 THEN 1293 WHEN 126859 THEN 1293 WHEN 141662 THEN 1293 ELSE population END WHERE id IN (126807,126859,141662);

UPDATE cities SET population = CASE id WHEN 112196 THEN 1292 ELSE population END WHERE id IN (112196);

UPDATE cities SET population = CASE id WHEN 112673 THEN 1291 WHEN 113962 THEN 1291 WHEN 121815 THEN 1291 ELSE population END WHERE id IN (112673,113962,121815);

UPDATE cities SET population = CASE id WHEN 112475 THEN 1286 WHEN 124867 THEN 1286 ELSE population END WHERE id IN (112475,124867);

UPDATE cities SET population = CASE id WHEN 115422 THEN 1284 WHEN 124683 THEN 1284 ELSE population END WHERE id IN (115422,124683);

UPDATE cities SET population = CASE id WHEN 116821 THEN 1283 ELSE population END WHERE id IN (116821);

UPDATE cities SET population = CASE id WHEN 125459 THEN 1282 ELSE population END WHERE id IN (125459);

UPDATE cities SET population = CASE id WHEN 120888 THEN 1281 ELSE population END WHERE id IN (120888);

UPDATE cities SET population = CASE id WHEN 118908 THEN 1280 ELSE population END WHERE id IN (118908);

UPDATE cities SET population = CASE id WHEN 112112 THEN 1278 WHEN 114607 THEN 1278 ELSE population END WHERE id IN (112112,114607);

UPDATE cities SET population = CASE id WHEN 113146 THEN 1277 WHEN 127127 THEN 1277 ELSE population END WHERE id IN (113146,127127);

UPDATE cities SET population = CASE id WHEN 120501 THEN 1274 ELSE population END WHERE id IN (120501);

UPDATE cities SET population = CASE id WHEN 114210 THEN 1273 WHEN 118967 THEN 1273 ELSE population END WHERE id IN (114210,118967);

UPDATE cities SET population = CASE id WHEN 115311 THEN 1272 WHEN 141542 THEN 1272 ELSE population END WHERE id IN (115311,141542);

UPDATE cities SET population = CASE id WHEN 117043 THEN 1271 ELSE population END WHERE id IN (117043);

UPDATE cities SET population = CASE id WHEN 113668 THEN 1269 WHEN 141716 THEN 1269 ELSE population END WHERE id IN (113668,141716);

UPDATE cities SET population = CASE id WHEN 114828 THEN 1268 WHEN 120508 THEN 1268 WHEN 141312 THEN 1268 ELSE population END WHERE id IN (114828,120508,141312);

UPDATE cities SET population = CASE id WHEN 115178 THEN 1267 ELSE population END WHERE id IN (115178);

UPDATE cities SET population = CASE id WHEN 113009 THEN 1266 WHEN 118700 THEN 1266 ELSE population END WHERE id IN (113009,118700);

UPDATE cities SET population = CASE id WHEN 111245 THEN 1264 WHEN 129039 THEN 1264 ELSE population END WHERE id IN (111245,129039);

UPDATE cities SET population = CASE id WHEN 123684 THEN 1263 WHEN 128896 THEN 1263 WHEN 141396 THEN 1263 ELSE population END WHERE id IN (123684,128896,141396);

UPDATE cities SET population = CASE id WHEN 116357 THEN 1261 WHEN 121143 THEN 1261 WHEN 128783 THEN 1261 ELSE population END WHERE id IN (116357,121143,128783);

UPDATE cities SET population = CASE id WHEN 116351 THEN 1258 WHEN 126832 THEN 1258 ELSE population END WHERE id IN (116351,126832);

UPDATE cities SET population = CASE id WHEN 111036 THEN 1257 WHEN 112057 THEN 1257 WHEN 117691 THEN 1257 WHEN 120468 THEN 1257 ELSE population END WHERE id IN (111036,112057,117691,120468);

UPDATE cities SET population = CASE id WHEN 111528 THEN 1256 WHEN 118822 THEN 1256 ELSE population END WHERE id IN (111528,118822);

UPDATE cities SET population = CASE id WHEN 117717 THEN 1254 ELSE population END WHERE id IN (117717);

UPDATE cities SET population = CASE id WHEN 113011 THEN 1253 ELSE population END WHERE id IN (113011);

UPDATE cities SET population = CASE id WHEN 116109 THEN 1251 ELSE population END WHERE id IN (116109);

UPDATE cities SET population = CASE id WHEN 117860 THEN 1249 WHEN 121593 THEN 1249 WHEN 141521 THEN 1249 ELSE population END WHERE id IN (117860,121593,141521);

UPDATE cities SET population = CASE id WHEN 112438 THEN 1248 WHEN 114756 THEN 1248 WHEN 117726 THEN 1248 ELSE population END WHERE id IN (112438,114756,117726);

UPDATE cities SET population = CASE id WHEN 118205 THEN 1247 ELSE population END WHERE id IN (118205);

UPDATE cities SET population = CASE id WHEN 111467 THEN 1246 ELSE population END WHERE id IN (111467);

UPDATE cities SET population = CASE id WHEN 141150 THEN 1245 ELSE population END WHERE id IN (141150);

UPDATE cities SET population = CASE id WHEN 111535 THEN 1244 ELSE population END WHERE id IN (111535);

UPDATE cities SET population = CASE id WHEN 124500 THEN 1243 ELSE population END WHERE id IN (124500);

UPDATE cities SET population = CASE id WHEN 113835 THEN 1242 WHEN 121851 THEN 1242 WHEN 122455 THEN 1242 ELSE population END WHERE id IN (113835,121851,122455);

UPDATE cities SET population = CASE id WHEN 111588 THEN 1241 WHEN 119850 THEN 1241 ELSE population END WHERE id IN (111588,119850);

UPDATE cities SET population = CASE id WHEN 126321 THEN 1238 ELSE population END WHERE id IN (126321);

UPDATE cities SET population = CASE id WHEN 118557 THEN 1237 ELSE population END WHERE id IN (118557);

UPDATE cities SET population = CASE id WHEN 129062 THEN 1235 WHEN 129240 THEN 1235 ELSE population END WHERE id IN (129062,129240);

UPDATE cities SET population = CASE id WHEN 112665 THEN 1233 WHEN 115957 THEN 1233 WHEN 118817 THEN 1233 WHEN 122815 THEN 1233 ELSE population END WHERE id IN (112665,115957,118817,122815);

UPDATE cities SET population = CASE id WHEN 120709 THEN 1232 WHEN 123286 THEN 1232 WHEN 126395 THEN 1232 WHEN 127069 THEN 1232 WHEN 127184 THEN 1232 ELSE population END WHERE id IN (120709,123286,126395,127069,127184);

UPDATE cities SET population = CASE id WHEN 114579 THEN 1231 WHEN 116581 THEN 1231 WHEN 118245 THEN 1231 WHEN 121452 THEN 1231 WHEN 129331 THEN 1231 ELSE population END WHERE id IN (114579,116581,118245,121452,129331);

UPDATE cities SET population = CASE id WHEN 122170 THEN 1227 ELSE population END WHERE id IN (122170);

UPDATE cities SET population = CASE id WHEN 129032 THEN 1226 ELSE population END WHERE id IN (129032);

UPDATE cities SET population = CASE id WHEN 116795 THEN 1225 ELSE population END WHERE id IN (116795);

UPDATE cities SET population = CASE id WHEN 118134 THEN 1224 WHEN 122821 THEN 1224 ELSE population END WHERE id IN (118134,122821);

UPDATE cities SET population = CASE id WHEN 111240 THEN 1223 WHEN 124127 THEN 1223 WHEN 128477 THEN 1223 ELSE population END WHERE id IN (111240,124127,128477);

UPDATE cities SET population = CASE id WHEN 113904 THEN 1222 WHEN 117552 THEN 1222 WHEN 121374 THEN 1222 WHEN 129271 THEN 1222 ELSE population END WHERE id IN (113904,117552,121374,129271);

UPDATE cities SET population = CASE id WHEN 122350 THEN 1221 WHEN 124329 THEN 1221 WHEN 127850 THEN 1221 ELSE population END WHERE id IN (122350,124329,127850);

UPDATE cities SET population = CASE id WHEN 111047 THEN 1220 WHEN 115872 THEN 1220 WHEN 121245 THEN 1220 ELSE population END WHERE id IN (111047,115872,121245);

UPDATE cities SET population = CASE id WHEN 141644 THEN 1219 ELSE population END WHERE id IN (141644);

UPDATE cities SET population = CASE id WHEN 111622 THEN 1218 WHEN 116949 THEN 1218 ELSE population END WHERE id IN (111622,116949);

UPDATE cities SET population = CASE id WHEN 129719 THEN 1217 ELSE population END WHERE id IN (129719);

UPDATE cities SET population = CASE id WHEN 120604 THEN 1215 WHEN 121982 THEN 1215 WHEN 125496 THEN 1215 WHEN 141300 THEN 1215 ELSE population END WHERE id IN (120604,121982,125496,141300);

UPDATE cities SET population = CASE id WHEN 141226 THEN 1214 ELSE population END WHERE id IN (141226);

UPDATE cities SET population = CASE id WHEN 111469 THEN 1213 WHEN 116881 THEN 1213 WHEN 129564 THEN 1213 ELSE population END WHERE id IN (111469,116881,129564);

UPDATE cities SET population = CASE id WHEN 113313 THEN 1212 WHEN 114700 THEN 1212 WHEN 117430 THEN 1212 ELSE population END WHERE id IN (113313,114700,117430);

UPDATE cities SET population = CASE id WHEN 112079 THEN 1211 WHEN 125349 THEN 1211 WHEN 125758 THEN 1211 ELSE population END WHERE id IN (112079,125349,125758);

UPDATE cities SET population = CASE id WHEN 117048 THEN 1210 WHEN 123474 THEN 1210 ELSE population END WHERE id IN (117048,123474);

UPDATE cities SET population = CASE id WHEN 115003 THEN 1209 ELSE population END WHERE id IN (115003);

UPDATE cities SET population = CASE id WHEN 120627 THEN 1208 ELSE population END WHERE id IN (120627);

UPDATE cities SET population = CASE id WHEN 112569 THEN 1207 WHEN 112601 THEN 1207 ELSE population END WHERE id IN (112569,112601);

UPDATE cities SET population = CASE id WHEN 118540 THEN 1206 ELSE population END WHERE id IN (118540);

UPDATE cities SET population = CASE id WHEN 114399 THEN 1205 ELSE population END WHERE id IN (114399);

UPDATE cities SET population = CASE id WHEN 114157 THEN 1204 WHEN 121854 THEN 1204 WHEN 127286 THEN 1204 ELSE population END WHERE id IN (114157,121854,127286);

UPDATE cities SET population = CASE id WHEN 125422 THEN 1203 ELSE population END WHERE id IN (125422);

UPDATE cities SET population = CASE id WHEN 118236 THEN 1202 WHEN 123291 THEN 1202 ELSE population END WHERE id IN (118236,123291);

UPDATE cities SET population = CASE id WHEN 127733 THEN 1200 ELSE population END WHERE id IN (127733);

UPDATE cities SET population = CASE id WHEN 112871 THEN 1198 WHEN 113771 THEN 1198 WHEN 118594 THEN 1198 ELSE population END WHERE id IN (112871,113771,118594);

UPDATE cities SET population = CASE id WHEN 114169 THEN 1195 WHEN 122137 THEN 1195 ELSE population END WHERE id IN (114169,122137);

UPDATE cities SET population = CASE id WHEN 111905 THEN 1193 WHEN 120427 THEN 1193 ELSE population END WHERE id IN (111905,120427);

UPDATE cities SET population = CASE id WHEN 115605 THEN 1192 WHEN 118032 THEN 1192 WHEN 121212 THEN 1192 WHEN 141419 THEN 1192 ELSE population END WHERE id IN (115605,118032,121212,141419);

UPDATE cities SET population = CASE id WHEN 111615 THEN 1187 WHEN 113084 THEN 1187 WHEN 120944 THEN 1187 ELSE population END WHERE id IN (111615,113084,120944);

UPDATE cities SET population = CASE id WHEN 119483 THEN 1185 WHEN 124691 THEN 1185 ELSE population END WHERE id IN (119483,124691);

UPDATE cities SET population = CASE id WHEN 118249 THEN 1184 ELSE population END WHERE id IN (118249);

UPDATE cities SET population = CASE id WHEN 121640 THEN 1182 ELSE population END WHERE id IN (121640);

UPDATE cities SET population = CASE id WHEN 113075 THEN 1181 WHEN 120446 THEN 1181 ELSE population END WHERE id IN (113075,120446);

UPDATE cities SET population = CASE id WHEN 120207 THEN 1180 WHEN 129704 THEN 1180 ELSE population END WHERE id IN (120207,129704);

UPDATE cities SET population = CASE id WHEN 112970 THEN 1178 WHEN 120957 THEN 1178 ELSE population END WHERE id IN (112970,120957);

UPDATE cities SET population = CASE id WHEN 122800 THEN 1177 ELSE population END WHERE id IN (122800);

UPDATE cities SET population = CASE id WHEN 118727 THEN 1176 WHEN 123832 THEN 1176 ELSE population END WHERE id IN (118727,123832);

UPDATE cities SET population = CASE id WHEN 128012 THEN 1175 WHEN 128544 THEN 1175 ELSE population END WHERE id IN (128012,128544);

UPDATE cities SET population = CASE id WHEN 120816 THEN 1174 ELSE population END WHERE id IN (120816);

UPDATE cities SET population = CASE id WHEN 112892 THEN 1173 WHEN 120502 THEN 1173 ELSE population END WHERE id IN (112892,120502);

UPDATE cities SET population = CASE id WHEN 116305 THEN 1172 WHEN 127534 THEN 1172 ELSE population END WHERE id IN (116305,127534);

UPDATE cities SET population = CASE id WHEN 113999 THEN 1171 WHEN 128629 THEN 1171 ELSE population END WHERE id IN (113999,128629);

UPDATE cities SET population = CASE id WHEN 116565 THEN 1169 ELSE population END WHERE id IN (116565);

UPDATE cities SET population = CASE id WHEN 113346 THEN 1165 ELSE population END WHERE id IN (113346);

UPDATE cities SET population = CASE id WHEN 117180 THEN 1164 ELSE population END WHERE id IN (117180);

UPDATE cities SET population = CASE id WHEN 111648 THEN 1163 WHEN 129345 THEN 1163 ELSE population END WHERE id IN (111648,129345);

UPDATE cities SET population = CASE id WHEN 120736 THEN 1162 WHEN 129289 THEN 1162 ELSE population END WHERE id IN (120736,129289);

UPDATE cities SET population = CASE id WHEN 114407 THEN 1161 ELSE population END WHERE id IN (114407);

UPDATE cities SET population = CASE id WHEN 112631 THEN 1160 ELSE population END WHERE id IN (112631);

UPDATE cities SET population = CASE id WHEN 111755 THEN 1159 ELSE population END WHERE id IN (111755);

UPDATE cities SET population = CASE id WHEN 117888 THEN 1158 ELSE population END WHERE id IN (117888);

UPDATE cities SET population = CASE id WHEN 117677 THEN 1157 WHEN 128190 THEN 1157 WHEN 128950 THEN 1157 ELSE population END WHERE id IN (117677,128190,128950);

UPDATE cities SET population = CASE id WHEN 128684 THEN 1156 ELSE population END WHERE id IN (128684);

UPDATE cities SET population = CASE id WHEN 119624 THEN 1155 WHEN 141482 THEN 1155 ELSE population END WHERE id IN (119624,141482);

UPDATE cities SET population = CASE id WHEN 125839 THEN 1153 ELSE population END WHERE id IN (125839);

UPDATE cities SET population = CASE id WHEN 113772 THEN 1152 WHEN 118169 THEN 1152 ELSE population END WHERE id IN (113772,118169);

UPDATE cities SET population = CASE id WHEN 113806 THEN 1151 WHEN 116327 THEN 1151 WHEN 128792 THEN 1151 ELSE population END WHERE id IN (113806,116327,128792);

UPDATE cities SET population = CASE id WHEN 141106 THEN 1150 ELSE population END WHERE id IN (141106);

UPDATE cities SET population = CASE id WHEN 111938 THEN 1148 WHEN 116796 THEN 1148 WHEN 126878 THEN 1148 ELSE population END WHERE id IN (111938,116796,126878);

UPDATE cities SET population = CASE id WHEN 125093 THEN 1147 ELSE population END WHERE id IN (125093);

UPDATE cities SET population = CASE id WHEN 111210 THEN 1146 WHEN 126118 THEN 1146 ELSE population END WHERE id IN (111210,126118);

UPDATE cities SET population = CASE id WHEN 112170 THEN 1145 WHEN 118075 THEN 1145 WHEN 124379 THEN 1145 ELSE population END WHERE id IN (112170,118075,124379);

UPDATE cities SET population = CASE id WHEN 111585 THEN 1143 ELSE population END WHERE id IN (111585);

UPDATE cities SET population = CASE id WHEN 129165 THEN 1142 WHEN 129395 THEN 1142 ELSE population END WHERE id IN (129165,129395);

UPDATE cities SET population = CASE id WHEN 114166 THEN 1141 WHEN 115016 THEN 1141 WHEN 123682 THEN 1141 ELSE population END WHERE id IN (114166,115016,123682);

UPDATE cities SET population = CASE id WHEN 126260 THEN 1140 ELSE population END WHERE id IN (126260);

UPDATE cities SET population = CASE id WHEN 115849 THEN 1139 WHEN 126915 THEN 1139 ELSE population END WHERE id IN (115849,126915);

UPDATE cities SET population = CASE id WHEN 111049 THEN 1138 WHEN 112520 THEN 1138 ELSE population END WHERE id IN (111049,112520);

UPDATE cities SET population = CASE id WHEN 115030 THEN 1137 WHEN 119961 THEN 1137 WHEN 125457 THEN 1137 ELSE population END WHERE id IN (115030,119961,125457);

UPDATE cities SET population = CASE id WHEN 121349 THEN 1135 WHEN 124707 THEN 1135 WHEN 127353 THEN 1135 ELSE population END WHERE id IN (121349,124707,127353);

UPDATE cities SET population = CASE id WHEN 111077 THEN 1133 WHEN 111330 THEN 1133 WHEN 117505 THEN 1133 WHEN 124690 THEN 1133 ELSE population END WHERE id IN (111077,111330,117505,124690);

UPDATE cities SET population = CASE id WHEN 111782 THEN 1132 WHEN 126261 THEN 1132 ELSE population END WHERE id IN (111782,126261);

UPDATE cities SET population = CASE id WHEN 112949 THEN 1131 WHEN 124107 THEN 1131 WHEN 124109 THEN 1131 WHEN 125760 THEN 1131 WHEN 127604 THEN 1131 WHEN 141380 THEN 1131 ELSE population END WHERE id IN (112949,124107,124109,125760,127604,141380);

UPDATE cities SET population = CASE id WHEN 118448 THEN 1130 ELSE population END WHERE id IN (118448);

UPDATE cities SET population = CASE id WHEN 117696 THEN 1129 ELSE population END WHERE id IN (117696);

UPDATE cities SET population = CASE id WHEN 120451 THEN 1128 WHEN 122295 THEN 1128 WHEN 125199 THEN 1128 WHEN 127765 THEN 1128 ELSE population END WHERE id IN (120451,122295,125199,127765);

UPDATE cities SET population = CASE id WHEN 119987 THEN 1125 ELSE population END WHERE id IN (119987);

UPDATE cities SET population = CASE id WHEN 117752 THEN 1124 ELSE population END WHERE id IN (117752);

UPDATE cities SET population = CASE id WHEN 115680 THEN 1122 WHEN 123716 THEN 1122 ELSE population END WHERE id IN (115680,123716);

UPDATE cities SET population = CASE id WHEN 127048 THEN 1119 WHEN 141104 THEN 1119 ELSE population END WHERE id IN (127048,141104);

UPDATE cities SET population = CASE id WHEN 117764 THEN 1118 ELSE population END WHERE id IN (117764);

UPDATE cities SET population = CASE id WHEN 121072 THEN 1117 ELSE population END WHERE id IN (121072);

UPDATE cities SET population = CASE id WHEN 120812 THEN 1116 WHEN 121858 THEN 1116 ELSE population END WHERE id IN (120812,121858);

UPDATE cities SET population = CASE id WHEN 117248 THEN 1115 ELSE population END WHERE id IN (117248);

UPDATE cities SET population = CASE id WHEN 120338 THEN 1114 ELSE population END WHERE id IN (120338);

UPDATE cities SET population = CASE id WHEN 129585 THEN 1113 ELSE population END WHERE id IN (129585);

UPDATE cities SET population = CASE id WHEN 121728 THEN 1112 ELSE population END WHERE id IN (121728);

UPDATE cities SET population = CASE id WHEN 121239 THEN 1111 ELSE population END WHERE id IN (121239);

UPDATE cities SET population = CASE id WHEN 127941 THEN 1110 ELSE population END WHERE id IN (127941);

UPDATE cities SET population = CASE id WHEN 126577 THEN 1109 WHEN 128056 THEN 1109 ELSE population END WHERE id IN (126577,128056);

UPDATE cities SET population = CASE id WHEN 117692 THEN 1108 WHEN 121584 THEN 1108 ELSE population END WHERE id IN (117692,121584);

UPDATE cities SET population = CASE id WHEN 111103 THEN 1104 ELSE population END WHERE id IN (111103);

UPDATE cities SET population = CASE id WHEN 111915 THEN 1103 WHEN 117247 THEN 1103 ELSE population END WHERE id IN (111915,117247);

UPDATE cities SET population = CASE id WHEN 119683 THEN 1100 WHEN 141673 THEN 1100 ELSE population END WHERE id IN (119683,141673);

UPDATE cities SET population = CASE id WHEN 129239 THEN 1098 ELSE population END WHERE id IN (129239);

UPDATE cities SET population = CASE id WHEN 111581 THEN 1096 WHEN 125031 THEN 1096 ELSE population END WHERE id IN (111581,125031);

UPDATE cities SET population = CASE id WHEN 112439 THEN 1095 WHEN 118237 THEN 1095 ELSE population END WHERE id IN (112439,118237);

UPDATE cities SET population = CASE id WHEN 115216 THEN 1094 WHEN 121281 THEN 1094 WHEN 121449 THEN 1094 WHEN 129172 THEN 1094 ELSE population END WHERE id IN (115216,121281,121449,129172);

UPDATE cities SET population = CASE id WHEN 117198 THEN 1092 WHEN 118233 THEN 1092 ELSE population END WHERE id IN (117198,118233);

UPDATE cities SET population = CASE id WHEN 123686 THEN 1090 ELSE population END WHERE id IN (123686);

UPDATE cities SET population = CASE id WHEN 115118 THEN 1089 WHEN 123150 THEN 1089 ELSE population END WHERE id IN (115118,123150);

UPDATE cities SET population = CASE id WHEN 124325 THEN 1088 WHEN 127965 THEN 1088 ELSE population END WHERE id IN (124325,127965);

UPDATE cities SET population = CASE id WHEN 120838 THEN 1087 WHEN 124369 THEN 1087 ELSE population END WHERE id IN (120838,124369);

UPDATE cities SET population = CASE id WHEN 115310 THEN 1086 ELSE population END WHERE id IN (115310);

UPDATE cities SET population = CASE id WHEN 111094 THEN 1085 WHEN 115790 THEN 1085 WHEN 122366 THEN 1085 ELSE population END WHERE id IN (111094,115790,122366);

UPDATE cities SET population = CASE id WHEN 127677 THEN 1083 ELSE population END WHERE id IN (127677);

UPDATE cities SET population = CASE id WHEN 116822 THEN 1082 WHEN 117882 THEN 1082 ELSE population END WHERE id IN (116822,117882);

UPDATE cities SET population = CASE id WHEN 116442 THEN 1081 WHEN 124006 THEN 1081 ELSE population END WHERE id IN (116442,124006);

UPDATE cities SET population = CASE id WHEN 111095 THEN 1080 ELSE population END WHERE id IN (111095);

UPDATE cities SET population = CASE id WHEN 119547 THEN 1079 ELSE population END WHERE id IN (119547);

UPDATE cities SET population = CASE id WHEN 120245 THEN 1078 WHEN 120573 THEN 1078 ELSE population END WHERE id IN (120245,120573);

UPDATE cities SET population = CASE id WHEN 111605 THEN 1077 WHEN 112629 THEN 1077 WHEN 120114 THEN 1077 WHEN 122573 THEN 1077 ELSE population END WHERE id IN (111605,112629,120114,122573);

UPDATE cities SET population = CASE id WHEN 113602 THEN 1076 WHEN 122687 THEN 1076 ELSE population END WHERE id IN (113602,122687);

UPDATE cities SET population = CASE id WHEN 116236 THEN 1074 WHEN 116665 THEN 1074 ELSE population END WHERE id IN (116236,116665);

UPDATE cities SET population = CASE id WHEN 113670 THEN 1073 WHEN 123277 THEN 1073 WHEN 123287 THEN 1073 ELSE population END WHERE id IN (113670,123277,123287);

UPDATE cities SET population = CASE id WHEN 112269 THEN 1072 WHEN 125032 THEN 1072 WHEN 129262 THEN 1072 ELSE population END WHERE id IN (112269,125032,129262);

UPDATE cities SET population = CASE id WHEN 119170 THEN 1071 WHEN 121417 THEN 1071 WHEN 126945 THEN 1071 ELSE population END WHERE id IN (119170,121417,126945);

UPDATE cities SET population = CASE id WHEN 116083 THEN 1070 WHEN 141657 THEN 1070 ELSE population END WHERE id IN (116083,141657);

UPDATE cities SET population = CASE id WHEN 115871 THEN 1069 ELSE population END WHERE id IN (115871);

UPDATE cities SET population = CASE id WHEN 111895 THEN 1068 ELSE population END WHERE id IN (111895);

UPDATE cities SET population = CASE id WHEN 122725 THEN 1067 ELSE population END WHERE id IN (122725);

UPDATE cities SET population = CASE id WHEN 125702 THEN 1066 ELSE population END WHERE id IN (125702);

UPDATE cities SET population = CASE id WHEN 112076 THEN 1065 WHEN 124564 THEN 1065 WHEN 126158 THEN 1065 WHEN 141325 THEN 1065 ELSE population END WHERE id IN (112076,124564,126158,141325);

UPDATE cities SET population = CASE id WHEN 126298 THEN 1064 ELSE population END WHERE id IN (126298);

UPDATE cities SET population = CASE id WHEN 112882 THEN 1063 WHEN 122698 THEN 1063 ELSE population END WHERE id IN (112882,122698);

UPDATE cities SET population = CASE id WHEN 116329 THEN 1062 ELSE population END WHERE id IN (116329);

UPDATE cities SET population = CASE id WHEN 120507 THEN 1061 WHEN 121336 THEN 1061 WHEN 122801 THEN 1061 ELSE population END WHERE id IN (120507,121336,122801);

UPDATE cities SET population = CASE id WHEN 112519 THEN 1060 ELSE population END WHERE id IN (112519);

UPDATE cities SET population = CASE id WHEN 122322 THEN 1059 ELSE population END WHERE id IN (122322);

UPDATE cities SET population = CASE id WHEN 124930 THEN 1056 ELSE population END WHERE id IN (124930);

UPDATE cities SET population = CASE id WHEN 115967 THEN 1055 ELSE population END WHERE id IN (115967);

UPDATE cities SET population = CASE id WHEN 114287 THEN 1052 WHEN 127932 THEN 1052 WHEN 129031 THEN 1052 ELSE population END WHERE id IN (114287,127932,129031);

UPDATE cities SET population = CASE id WHEN 113256 THEN 1051 WHEN 117406 THEN 1051 WHEN 124326 THEN 1051 WHEN 141828 THEN 1051 ELSE population END WHERE id IN (113256,117406,124326,141828);

UPDATE cities SET population = CASE id WHEN 114120 THEN 1050 WHEN 114539 THEN 1050 WHEN 119207 THEN 1050 ELSE population END WHERE id IN (114120,114539,119207);

UPDATE cities SET population = CASE id WHEN 117164 THEN 1049 ELSE population END WHERE id IN (117164);

UPDATE cities SET population = CASE id WHEN 111241 THEN 1048 ELSE population END WHERE id IN (111241);

UPDATE cities SET population = CASE id WHEN 111233 THEN 1047 WHEN 124975 THEN 1047 WHEN 141437 THEN 1047 ELSE population END WHERE id IN (111233,124975,141437);

UPDATE cities SET population = CASE id WHEN 114406 THEN 1046 ELSE population END WHERE id IN (114406);

UPDATE cities SET population = CASE id WHEN 125205 THEN 1045 ELSE population END WHERE id IN (125205);

UPDATE cities SET population = CASE id WHEN 115240 THEN 1044 WHEN 118081 THEN 1044 WHEN 128614 THEN 1044 WHEN 141849 THEN 1044 ELSE population END WHERE id IN (115240,118081,128614,141849);

UPDATE cities SET population = CASE id WHEN 114211 THEN 1040 ELSE population END WHERE id IN (114211);

UPDATE cities SET population = CASE id WHEN 120590 THEN 1039 ELSE population END WHERE id IN (120590);

UPDATE cities SET population = CASE id WHEN 111284 THEN 1038 ELSE population END WHERE id IN (111284);

UPDATE cities SET population = CASE id WHEN 112776 THEN 1037 WHEN 117827 THEN 1037 WHEN 121892 THEN 1037 WHEN 121981 THEN 1037 WHEN 122347 THEN 1037 WHEN 122579 THEN 1037 ELSE population END WHERE id IN (112776,117827,121892,121981,122347,122579);

UPDATE cities SET population = CASE id WHEN 112571 THEN 1035 WHEN 114149 THEN 1035 WHEN 128550 THEN 1035 WHEN 141833 THEN 1035 ELSE population END WHERE id IN (112571,114149,128550,141833);

UPDATE cities SET population = CASE id WHEN 118395 THEN 1034 ELSE population END WHERE id IN (118395);

UPDATE cities SET population = CASE id WHEN 121654 THEN 1033 ELSE population END WHERE id IN (121654);

UPDATE cities SET population = CASE id WHEN 117177 THEN 1032 ELSE population END WHERE id IN (117177);

UPDATE cities SET population = CASE id WHEN 127092 THEN 1031 ELSE population END WHERE id IN (127092);

UPDATE cities SET population = CASE id WHEN 128371 THEN 1030 ELSE population END WHERE id IN (128371);

UPDATE cities SET population = CASE id WHEN 111663 THEN 1029 WHEN 112275 THEN 1029 WHEN 117089 THEN 1029 ELSE population END WHERE id IN (111663,112275,117089);

UPDATE cities SET population = CASE id WHEN 119505 THEN 1028 ELSE population END WHERE id IN (119505);

UPDATE cities SET population = CASE id WHEN 111234 THEN 1027 ELSE population END WHERE id IN (111234);

UPDATE cities SET population = CASE id WHEN 122802 THEN 1025 ELSE population END WHERE id IN (122802);

UPDATE cities SET population = CASE id WHEN 123677 THEN 1024 WHEN 126287 THEN 1024 WHEN 141427 THEN 1024 ELSE population END WHERE id IN (123677,126287,141427);

UPDATE cities SET population = CASE id WHEN 112938 THEN 1023 WHEN 119977 THEN 1023 WHEN 125497 THEN 1023 ELSE population END WHERE id IN (112938,119977,125497);

UPDATE cities SET population = CASE id WHEN 128435 THEN 1022 ELSE population END WHERE id IN (128435);

UPDATE cities SET population = CASE id WHEN 141485 THEN 1021 ELSE population END WHERE id IN (141485);

UPDATE cities SET population = CASE id WHEN 121101 THEN 1020 ELSE population END WHERE id IN (121101);

UPDATE cities SET population = CASE id WHEN 122554 THEN 1019 WHEN 125330 THEN 1019 WHEN 125377 THEN 1019 ELSE population END WHERE id IN (122554,125330,125377);

UPDATE cities SET population = CASE id WHEN 111109 THEN 1018 WHEN 141257 THEN 1018 ELSE population END WHERE id IN (111109,141257);

UPDATE cities SET population = CASE id WHEN 119228 THEN 1017 ELSE population END WHERE id IN (119228);

UPDATE cities SET population = CASE id WHEN 112256 THEN 1014 ELSE population END WHERE id IN (112256);

UPDATE cities SET population = CASE id WHEN 117708 THEN 1013 WHEN 120512 THEN 1013 ELSE population END WHERE id IN (117708,120512);

UPDATE cities SET population = CASE id WHEN 115827 THEN 1012 WHEN 124655 THEN 1012 ELSE population END WHERE id IN (115827,124655);

UPDATE cities SET population = CASE id WHEN 111643 THEN 1011 WHEN 119112 THEN 1011 WHEN 141134 THEN 1011 ELSE population END WHERE id IN (111643,119112,141134);

UPDATE cities SET population = CASE id WHEN 118394 THEN 1010 WHEN 120038 THEN 1010 ELSE population END WHERE id IN (118394,120038);

UPDATE cities SET population = CASE id WHEN 117834 THEN 1009 ELSE population END WHERE id IN (117834);

UPDATE cities SET population = CASE id WHEN 111325 THEN 1008 WHEN 122649 THEN 1008 ELSE population END WHERE id IN (111325,122649);

UPDATE cities SET population = CASE id WHEN 111578 THEN 1007 WHEN 126901 THEN 1007 ELSE population END WHERE id IN (111578,126901);

UPDATE cities SET population = CASE id WHEN 141311 THEN 1006 ELSE population END WHERE id IN (141311);

UPDATE cities SET population = CASE id WHEN 127591 THEN 1005 ELSE population END WHERE id IN (127591);

UPDATE cities SET population = CASE id WHEN 121451 THEN 1004 ELSE population END WHERE id IN (121451);

UPDATE cities SET population = CASE id WHEN 126873 THEN 1003 WHEN 127125 THEN 1003 WHEN 128799 THEN 1003 WHEN 141580 THEN 1003 ELSE population END WHERE id IN (126873,127125,128799,141580);

UPDATE cities SET population = CASE id WHEN 114212 THEN 1002 WHEN 126853 THEN 1002 ELSE population END WHERE id IN (114212,126853);

UPDATE cities SET population = CASE id WHEN 118089 THEN 1001 WHEN 127849 THEN 1001 WHEN 128271 THEN 1001 ELSE population END WHERE id IN (118089,127849,128271);

UPDATE cities SET population = CASE id WHEN 129571 THEN 995 ELSE population END WHERE id IN (129571);

UPDATE cities SET population = CASE id WHEN 114493 THEN 994 ELSE population END WHERE id IN (114493);

UPDATE cities SET population = CASE id WHEN 123862 THEN 993 ELSE population END WHERE id IN (123862);

UPDATE cities SET population = CASE id WHEN 115336 THEN 990 ELSE population END WHERE id IN (115336);

UPDATE cities SET population = CASE id WHEN 127842 THEN 988 ELSE population END WHERE id IN (127842);

UPDATE cities SET population = CASE id WHEN 121857 THEN 980 ELSE population END WHERE id IN (121857);

UPDATE cities SET population = CASE id WHEN 119311 THEN 974 ELSE population END WHERE id IN (119311);

UPDATE cities SET population = CASE id WHEN 117156 THEN 973 ELSE population END WHERE id IN (117156);

UPDATE cities SET population = CASE id WHEN 116826 THEN 969 ELSE population END WHERE id IN (116826);

UPDATE cities SET population = CASE id WHEN 118983 THEN 959 ELSE population END WHERE id IN (118983);

UPDATE cities SET population = CASE id WHEN 114606 THEN 945 ELSE population END WHERE id IN (114606);

UPDATE cities SET population = CASE id WHEN 112140 THEN 939 ELSE population END WHERE id IN (112140);

UPDATE cities SET population = CASE id WHEN 113514 THEN 938 ELSE population END WHERE id IN (113514);

UPDATE cities SET population = CASE id WHEN 128385 THEN 928 ELSE population END WHERE id IN (128385);

UPDATE cities SET population = CASE id WHEN 118894 THEN 927 ELSE population END WHERE id IN (118894);

UPDATE cities SET population = CASE id WHEN 122685 THEN 926 ELSE population END WHERE id IN (122685);

UPDATE cities SET population = CASE id WHEN 116839 THEN 920 ELSE population END WHERE id IN (116839);

UPDATE cities SET population = CASE id WHEN 123598 THEN 915 ELSE population END WHERE id IN (123598);

UPDATE cities SET population = CASE id WHEN 129163 THEN 910 ELSE population END WHERE id IN (129163);

UPDATE cities SET population = CASE id WHEN 120561 THEN 908 ELSE population END WHERE id IN (120561);

UPDATE cities SET population = CASE id WHEN 113657 THEN 903 ELSE population END WHERE id IN (113657);

UPDATE cities SET population = CASE id WHEN 124132 THEN 884 ELSE population END WHERE id IN (124132);

UPDATE cities SET population = CASE id WHEN 113893 THEN 883 ELSE population END WHERE id IN (113893);

UPDATE cities SET population = CASE id WHEN 111243 THEN 877 ELSE population END WHERE id IN (111243);

UPDATE cities SET population = CASE id WHEN 121304 THEN 876 ELSE population END WHERE id IN (121304);

UPDATE cities SET population = CASE id WHEN 129566 THEN 871 ELSE population END WHERE id IN (129566);

UPDATE cities SET population = CASE id WHEN 128506 THEN 866 ELSE population END WHERE id IN (128506);

UPDATE cities SET population = CASE id WHEN 112195 THEN 863 ELSE population END WHERE id IN (112195);

UPDATE cities SET population = CASE id WHEN 117684 THEN 862 ELSE population END WHERE id IN (117684);

UPDATE cities SET population = CASE id WHEN 128290 THEN 855 ELSE population END WHERE id IN (128290);

UPDATE cities SET population = CASE id WHEN 123601 THEN 850 WHEN 125527 THEN 850 ELSE population END WHERE id IN (123601,125527);

UPDATE cities SET population = CASE id WHEN 124884 THEN 844 ELSE population END WHERE id IN (124884);

UPDATE cities SET population = CASE id WHEN 119884 THEN 843 ELSE population END WHERE id IN (119884);

UPDATE cities SET population = CASE id WHEN 127282 THEN 839 ELSE population END WHERE id IN (127282);

UPDATE cities SET population = CASE id WHEN 128127 THEN 834 ELSE population END WHERE id IN (128127);

UPDATE cities SET population = CASE id WHEN 114470 THEN 832 ELSE population END WHERE id IN (114470);

UPDATE cities SET population = CASE id WHEN 128994 THEN 831 ELSE population END WHERE id IN (128994);

UPDATE cities SET population = CASE id WHEN 123610 THEN 828 ELSE population END WHERE id IN (123610);

UPDATE cities SET population = CASE id WHEN 111593 THEN 827 ELSE population END WHERE id IN (111593);

UPDATE cities SET population = CASE id WHEN 112929 THEN 826 ELSE population END WHERE id IN (112929);

UPDATE cities SET population = CASE id WHEN 111527 THEN 816 ELSE population END WHERE id IN (111527);

UPDATE cities SET population = CASE id WHEN 111208 THEN 802 ELSE population END WHERE id IN (111208);

UPDATE cities SET population = CASE id WHEN 117670 THEN 798 ELSE population END WHERE id IN (117670);

UPDATE cities SET population = CASE id WHEN 118709 THEN 790 ELSE population END WHERE id IN (118709);

UPDATE cities SET population = CASE id WHEN 122559 THEN 787 ELSE population END WHERE id IN (122559);

UPDATE cities SET population = CASE id WHEN 124261 THEN 786 ELSE population END WHERE id IN (124261);

UPDATE cities SET population = CASE id WHEN 125773 THEN 769 ELSE population END WHERE id IN (125773);

UPDATE cities SET population = CASE id WHEN 113198 THEN 762 ELSE population END WHERE id IN (113198);

UPDATE cities SET population = CASE id WHEN 128398 THEN 761 ELSE population END WHERE id IN (128398);

UPDATE cities SET population = CASE id WHEN 117016 THEN 760 ELSE population END WHERE id IN (117016);

UPDATE cities SET population = CASE id WHEN 115980 THEN 754 ELSE population END WHERE id IN (115980);

UPDATE cities SET population = CASE id WHEN 111211 THEN 748 WHEN 119645 THEN 748 ELSE population END WHERE id IN (111211,119645);

UPDATE cities SET population = CASE id WHEN 118767 THEN 736 ELSE population END WHERE id IN (118767);

UPDATE cities SET population = CASE id WHEN 114171 THEN 730 ELSE population END WHERE id IN (114171);

UPDATE cities SET population = CASE id WHEN 113671 THEN 724 WHEN 120085 THEN 724 ELSE population END WHERE id IN (113671,120085);

UPDATE cities SET population = CASE id WHEN 127009 THEN 709 ELSE population END WHERE id IN (127009);

UPDATE cities SET population = CASE id WHEN 120463 THEN 694 ELSE population END WHERE id IN (120463);

UPDATE cities SET population = CASE id WHEN 117671 THEN 685 ELSE population END WHERE id IN (117671);

UPDATE cities SET population = CASE id WHEN 116081 THEN 682 ELSE population END WHERE id IN (116081);

UPDATE cities SET population = CASE id WHEN 114549 THEN 681 ELSE population END WHERE id IN (114549);

UPDATE cities SET population = CASE id WHEN 122321 THEN 680 ELSE population END WHERE id IN (122321);

UPDATE cities SET population = CASE id WHEN 116832 THEN 677 ELSE population END WHERE id IN (116832);

UPDATE cities SET population = CASE id WHEN 126443 THEN 672 ELSE population END WHERE id IN (126443);

UPDATE cities SET population = CASE id WHEN 116950 THEN 670 ELSE population END WHERE id IN (116950);

UPDATE cities SET population = CASE id WHEN 129583 THEN 659 ELSE population END WHERE id IN (129583);

UPDATE cities SET population = CASE id WHEN 117187 THEN 657 ELSE population END WHERE id IN (117187);

UPDATE cities SET population = CASE id WHEN 122219 THEN 656 ELSE population END WHERE id IN (122219);

UPDATE cities SET population = CASE id WHEN 112891 THEN 638 ELSE population END WHERE id IN (112891);

UPDATE cities SET population = CASE id WHEN 124263 THEN 628 ELSE population END WHERE id IN (124263);

UPDATE cities SET population = CASE id WHEN 111156 THEN 623 ELSE population END WHERE id IN (111156);

UPDATE cities SET population = CASE id WHEN 125828 THEN 618 ELSE population END WHERE id IN (125828);

UPDATE cities SET population = CASE id WHEN 116237 THEN 610 ELSE population END WHERE id IN (116237);

UPDATE cities SET population = CASE id WHEN 112019 THEN 608 ELSE population END WHERE id IN (112019);

UPDATE cities SET population = CASE id WHEN 115497 THEN 606 ELSE population END WHERE id IN (115497);

UPDATE cities SET population = CASE id WHEN 113262 THEN 599 ELSE population END WHERE id IN (113262);

UPDATE cities SET population = CASE id WHEN 127531 THEN 597 WHEN 128232 THEN 597 ELSE population END WHERE id IN (127531,128232);

UPDATE cities SET population = CASE id WHEN 122859 THEN 594 ELSE population END WHERE id IN (122859);

UPDATE cities SET population = CASE id WHEN 116584 THEN 592 ELSE population END WHERE id IN (116584);

UPDATE cities SET population = CASE id WHEN 113055 THEN 589 WHEN 121749 THEN 589 ELSE population END WHERE id IN (113055,121749);

UPDATE cities SET population = CASE id WHEN 116100 THEN 587 ELSE population END WHERE id IN (116100);

UPDATE cities SET population = CASE id WHEN 128369 THEN 584 ELSE population END WHERE id IN (128369);

UPDATE cities SET population = CASE id WHEN 112765 THEN 575 ELSE population END WHERE id IN (112765);

UPDATE cities SET population = CASE id WHEN 113639 THEN 564 ELSE population END WHERE id IN (113639);

UPDATE cities SET population = CASE id WHEN 127810 THEN 561 ELSE population END WHERE id IN (127810);

UPDATE cities SET population = CASE id WHEN 127976 THEN 559 ELSE population END WHERE id IN (127976);

UPDATE cities SET population = CASE id WHEN 111882 THEN 557 ELSE population END WHERE id IN (111882);

UPDATE cities SET population = CASE id WHEN 121403 THEN 555 ELSE population END WHERE id IN (121403);

UPDATE cities SET population = CASE id WHEN 111530 THEN 538 ELSE population END WHERE id IN (111530);

UPDATE cities SET population = CASE id WHEN 126283 THEN 526 ELSE population END WHERE id IN (126283);

UPDATE cities SET population = CASE id WHEN 114786 THEN 508 ELSE population END WHERE id IN (114786);

UPDATE cities SET population = CASE id WHEN 123836 THEN 506 ELSE population END WHERE id IN (123836);

UPDATE cities SET population = CASE id WHEN 118852 THEN 492 ELSE population END WHERE id IN (118852);

UPDATE cities SET population = CASE id WHEN 117685 THEN 490 ELSE population END WHERE id IN (117685);

UPDATE cities SET population = CASE id WHEN 122840 THEN 489 ELSE population END WHERE id IN (122840);

UPDATE cities SET population = CASE id WHEN 119067 THEN 481 ELSE population END WHERE id IN (119067);

UPDATE cities SET population = CASE id WHEN 118074 THEN 470 ELSE population END WHERE id IN (118074);

UPDATE cities SET population = CASE id WHEN 114167 THEN 467 ELSE population END WHERE id IN (114167);

UPDATE cities SET population = CASE id WHEN 122625 THEN 466 ELSE population END WHERE id IN (122625);

UPDATE cities SET population = CASE id WHEN 124870 THEN 462 ELSE population END WHERE id IN (124870);

UPDATE cities SET population = CASE id WHEN 119139 THEN 449 ELSE population END WHERE id IN (119139);

UPDATE cities SET population = CASE id WHEN 120381 THEN 440 ELSE population END WHERE id IN (120381);

UPDATE cities SET population = CASE id WHEN 117023 THEN 409 ELSE population END WHERE id IN (117023);

UPDATE cities SET population = CASE id WHEN 113274 THEN 406 ELSE population END WHERE id IN (113274);

UPDATE cities SET population = CASE id WHEN 119317 THEN 399 ELSE population END WHERE id IN (119317);

UPDATE cities SET population = CASE id WHEN 114908 THEN 393 ELSE population END WHERE id IN (114908);

UPDATE cities SET population = CASE id WHEN 116317 THEN 389 ELSE population END WHERE id IN (116317);

UPDATE cities SET population = CASE id WHEN 114466 THEN 382 ELSE population END WHERE id IN (114466);

UPDATE cities SET population = CASE id WHEN 118195 THEN 381 WHEN 126955 THEN 381 ELSE population END WHERE id IN (118195,126955);

UPDATE cities SET population = CASE id WHEN 120351 THEN 377 ELSE population END WHERE id IN (120351);

UPDATE cities SET population = CASE id WHEN 126970 THEN 370 ELSE population END WHERE id IN (126970);

UPDATE cities SET population = CASE id WHEN 119886 THEN 367 ELSE population END WHERE id IN (119886);

UPDATE cities SET population = CASE id WHEN 113015 THEN 345 ELSE population END WHERE id IN (113015);

UPDATE cities SET population = CASE id WHEN 116514 THEN 341 ELSE population END WHERE id IN (116514);

UPDATE cities SET population = CASE id WHEN 117060 THEN 334 ELSE population END WHERE id IN (117060);

UPDATE cities SET population = CASE id WHEN 121120 THEN 331 ELSE population END WHERE id IN (121120);

UPDATE cities SET population = CASE id WHEN 126977 THEN 311 ELSE population END WHERE id IN (126977);

UPDATE cities SET population = CASE id WHEN 113475 THEN 290 ELSE population END WHERE id IN (113475);

UPDATE cities SET population = CASE id WHEN 127804 THEN 287 ELSE population END WHERE id IN (127804);

UPDATE cities SET population = CASE id WHEN 125035 THEN 272 ELSE population END WHERE id IN (125035);

UPDATE cities SET population = CASE id WHEN 117969 THEN 252 ELSE population END WHERE id IN (117969);

UPDATE cities SET population = CASE id WHEN 118060 THEN 238 ELSE population END WHERE id IN (118060);

UPDATE cities SET population = CASE id WHEN 111312 THEN 229 ELSE population END WHERE id IN (111312);

UPDATE cities SET population = CASE id WHEN 120991 THEN 220 ELSE population END WHERE id IN (120991);

UPDATE cities SET population = CASE id WHEN 127915 THEN 205 ELSE population END WHERE id IN (127915);

UPDATE cities SET population = CASE id WHEN 124290 THEN 199 ELSE population END WHERE id IN (124290);

UPDATE cities SET population = CASE id WHEN 118843 THEN 192 ELSE population END WHERE id IN (118843);

UPDATE cities SET population = CASE id WHEN 113654 THEN 188 ELSE population END WHERE id IN (113654);

UPDATE cities SET population = CASE id WHEN 119332 THEN 183 ELSE population END WHERE id IN (119332);

UPDATE cities SET population = CASE id WHEN 113468 THEN 182 ELSE population END WHERE id IN (113468);

UPDATE cities SET population = CASE id WHEN 127448 THEN 177 ELSE population END WHERE id IN (127448);

UPDATE cities SET population = CASE id WHEN 121512 THEN 175 ELSE population END WHERE id IN (121512);

UPDATE cities SET population = CASE id WHEN 117813 THEN 160 ELSE population END WHERE id IN (117813);

UPDATE cities SET population = CASE id WHEN 127863 THEN 157 ELSE population END WHERE id IN (127863);

UPDATE cities SET population = CASE id WHEN 122686 THEN 152 ELSE population END WHERE id IN (122686);

UPDATE cities SET population = CASE id WHEN 122119 THEN 136 ELSE population END WHERE id IN (122119);

UPDATE cities SET population = CASE id WHEN 113755 THEN 133 ELSE population END WHERE id IN (113755);

UPDATE cities SET population = CASE id WHEN 128543 THEN 128 ELSE population END WHERE id IN (128543);

UPDATE cities SET population = CASE id WHEN 126288 THEN 124 ELSE population END WHERE id IN (126288);

UPDATE cities SET population = CASE id WHEN 111499 THEN 117 ELSE population END WHERE id IN (111499);

UPDATE cities SET population = CASE id WHEN 122827 THEN 114 ELSE population END WHERE id IN (122827);

UPDATE cities SET population = CASE id WHEN 111864 THEN 109 ELSE population END WHERE id IN (111864);

UPDATE cities SET population = CASE id WHEN 123773 THEN 104 ELSE population END WHERE id IN (123773);

UPDATE cities SET population = CASE id WHEN 118052 THEN 100 ELSE population END WHERE id IN (118052);

UPDATE cities SET population = CASE id WHEN 122168 THEN 99 ELSE population END WHERE id IN (122168);

UPDATE cities SET population = CASE id WHEN 122487 THEN 97 ELSE population END WHERE id IN (122487);

UPDATE cities SET population = CASE id WHEN 113637 THEN 93 ELSE population END WHERE id IN (113637);

UPDATE cities SET population = CASE id WHEN 112563 THEN 76 ELSE population END WHERE id IN (112563);

UPDATE cities SET population = CASE id WHEN 121136 THEN 74 ELSE population END WHERE id IN (121136);

UPDATE cities SET population = CASE id WHEN 123448 THEN 73 ELSE population END WHERE id IN (123448);

UPDATE cities SET population = CASE id WHEN 122323 THEN 68 ELSE population END WHERE id IN (122323);

UPDATE cities SET population = CASE id WHEN 121668 THEN 19 ELSE population END WHERE id IN (121668);

UPDATE cities SET population = CASE id WHEN 112742 THEN 18 ELSE population END WHERE id IN (112742);

