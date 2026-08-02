-- Migration 122: Overwrite WRONG US city populations
-- Migration 112 had a 1:1 name-matching bug that assigned the wrong
-- population to same-name cities (Miami FL got pop=589 from Miami TX).
-- Migration 121 only fixed NULL populations.
-- This migration OVERWRITES the wrong values with correct (name, state) matches.
-- 1,975 cities corrected.

UPDATE cities SET population = CASE id WHEN 113776 THEN 911311 ELSE population END WHERE id IN (113776);

UPDATE cities SET population = CASE id WHEN 111783 THEN 585708 ELSE population END WHERE id IN (111783);

UPDATE cities SET population = CASE id WHEN 111590 THEN 510823 ELSE population END WHERE id IN (111590);

UPDATE cities SET population = CASE id WHEN 121746 THEN 487014 ELSE population END WHERE id IN (121746);

UPDATE cities SET population = CASE id WHEN 115569 THEN 257636 ELSE population END WHERE id IN (115569);

UPDATE cities SET population = CASE id WHEN 122941 THEN 238005 ELSE population END WHERE id IN (122941);

UPDATE cities SET population = CASE id WHEN 117088 THEN 236897 ELSE population END WHERE id IN (117088);

UPDATE cities SET population = CASE id WHEN 119111 THEN 216866 ELSE population END WHERE id IN (119111);

UPDATE cities SET population = CASE id WHEN 118814 THEN 215006 ELSE population END WHERE id IN (118814);

UPDATE cities SET population = CASE id WHEN 115271 THEN 214133 ELSE population END WHERE id IN (115271);

UPDATE cities SET population = CASE id WHEN 129584 THEN 206518 ELSE population END WHERE id IN (129584);

UPDATE cities SET population = CASE id WHEN 120626 THEN 202591 ELSE population END WHERE id IN (120626);

UPDATE cities SET population = CASE id WHEN 114953 THEN 200839 ELSE population END WHERE id IN (114953);

UPDATE cities SET population = CASE id WHEN 112358 THEN 196357 ELSE population END WHERE id IN (112358);

UPDATE cities SET population = CASE id WHEN 122130 THEN 195287 ELSE population END WHERE id IN (122130);

UPDATE cities SET population = CASE id WHEN 113505 THEN 159769 ELSE population END WHERE id IN (113505);

UPDATE cities SET population = CASE id WHEN 116955 THEN 154407 ELSE population END WHERE id IN (116955);

UPDATE cities SET population = CASE id WHEN 119383 THEN 152933 ELSE population END WHERE id IN (119383);

UPDATE cities SET population = CASE id WHEN 118565 THEN 149728 ELSE population END WHERE id IN (118565);

UPDATE cities SET population = CASE id WHEN 128087 THEN 148456 ELSE population END WHERE id IN (128087);

UPDATE cities SET population = CASE id WHEN 125974 THEN 147780 ELSE population END WHERE id IN (125974);

UPDATE cities SET population = CASE id WHEN 117014 THEN 145214 ELSE population END WHERE id IN (117014);

UPDATE cities SET population = CASE id WHEN 121726 THEN 144788 ELSE population END WHERE id IN (121726);

UPDATE cities SET population = CASE id WHEN 123412 THEN 134305 ELSE population END WHERE id IN (123412);

UPDATE cities SET population = CASE id WHEN 111573 THEN 127315 ELSE population END WHERE id IN (111573);

UPDATE cities SET population = CASE id WHEN 125903 THEN 126215 ELSE population END WHERE id IN (125903);

UPDATE cities SET population = CASE id WHEN 127732 THEN 125963 ELSE population END WHERE id IN (127732);

UPDATE cities SET population = CASE id WHEN 116253 THEN 119943 ELSE population END WHERE id IN (116253);

UPDATE cities SET population = CASE id WHEN 114222 THEN 117292 ELSE population END WHERE id IN (114222);

UPDATE cities SET population = CASE id WHEN 111989 THEN 115282 ELSE population END WHERE id IN (111989);

UPDATE cities SET population = CASE id WHEN 124046 THEN 115070 ELSE population END WHERE id IN (124046);

UPDATE cities SET population = CASE id WHEN 113408 THEN 114746 ELSE population END WHERE id IN (113408);

UPDATE cities SET population = CASE id WHEN 121753 THEN 113187 ELSE population END WHERE id IN (121753);

UPDATE cities SET population = CASE id WHEN 118386 THEN 110268 ELSE population END WHERE id IN (118386);

UPDATE cities SET population = CASE id WHEN 114661 THEN 109698 ELSE population END WHERE id IN (114661);

UPDATE cities SET population = CASE id WHEN 128602 THEN 108802 ELSE population END WHERE id IN (128602);

UPDATE cities SET population = CASE id WHEN 112600 THEN 106803 ELSE population END WHERE id IN (112600);

UPDATE cities SET population = CASE id WHEN 120012 THEN 104401 ELSE population END WHERE id IN (120012);

UPDATE cities SET population = CASE id WHEN 114315 THEN 104180 ELSE population END WHERE id IN (114315);

UPDATE cities SET population = CASE id WHEN 127940 THEN 103700 ELSE population END WHERE id IN (127940);

UPDATE cities SET population = CASE id WHEN 112688 THEN 103483 ELSE population END WHERE id IN (112688);

UPDATE cities SET population = CASE id WHEN 126624 THEN 101516 ELSE population END WHERE id IN (126624);

UPDATE cities SET population = CASE id WHEN 113964 THEN 100574 ELSE population END WHERE id IN (113964);

UPDATE cities SET population = CASE id WHEN 126860 THEN 98621 ELSE population END WHERE id IN (126860);

UPDATE cities SET population = CASE id WHEN 120250 THEN 96655 ELSE population END WHERE id IN (120250);

UPDATE cities SET population = CASE id WHEN 124569 THEN 96201 ELSE population END WHERE id IN (124569);

UPDATE cities SET population = CASE id WHEN 129733 THEN 95548 ELSE population END WHERE id IN (129733);

UPDATE cities SET population = CASE id WHEN 125462 THEN 94501 ELSE population END WHERE id IN (125462);

UPDATE cities SET population = CASE id WHEN 116373 THEN 94000 ELSE population END WHERE id IN (116373);

UPDATE cities SET population = CASE id WHEN 113474 THEN 93281 ELSE population END WHERE id IN (113474);

UPDATE cities SET population = CASE id WHEN 113416 THEN 88713 ELSE population END WHERE id IN (113416);

UPDATE cities SET population = CASE id WHEN 111169 THEN 85551 ELSE population END WHERE id IN (111169);

UPDATE cities SET population = CASE id WHEN 112449 THEN 84067 ELSE population END WHERE id IN (112449);

UPDATE cities SET population = CASE id WHEN 114019 THEN 83886 ELSE population END WHERE id IN (114019);

UPDATE cities SET population = CASE id WHEN 112959 THEN 82118 ELSE population END WHERE id IN (112959);

UPDATE cities SET population = CASE id WHEN 120143 THEN 81000 ELSE population END WHERE id IN (120143);

UPDATE cities SET population = CASE id WHEN 118601 THEN 80737 ELSE population END WHERE id IN (118601);

UPDATE cities SET population = CASE id WHEN 126883 THEN 77859 ELSE population END WHERE id IN (126883);

UPDATE cities SET population = CASE id WHEN 111472 THEN 75926 ELSE population END WHERE id IN (111472);

UPDATE cities SET population = CASE id WHEN 128605 THEN 75737 ELSE population END WHERE id IN (128605);

UPDATE cities SET population = CASE id WHEN 116251 THEN 75527 ELSE population END WHERE id IN (116251);

UPDATE cities SET population = CASE id WHEN 111101 THEN 74843 ELSE population END WHERE id IN (111101);

UPDATE cities SET population = CASE id WHEN 119299 THEN 73907 ELSE population END WHERE id IN (119299);

UPDATE cities SET population = CASE id WHEN 120705 THEN 73702 ELSE population END WHERE id IN (120705);

UPDATE cities SET population = CASE id WHEN 122674 THEN 72808 ELSE population END WHERE id IN (122674);

UPDATE cities SET population = CASE id WHEN 125216 THEN 71050 ELSE population END WHERE id IN (125216);

UPDATE cities SET population = CASE id WHEN 124976 THEN 71035 ELSE population END WHERE id IN (124976);

UPDATE cities SET population = CASE id WHEN 129321 THEN 70898 ELSE population END WHERE id IN (129321);

UPDATE cities SET population = CASE id WHEN 113860 THEN 70475 ELSE population END WHERE id IN (113860);

UPDATE cities SET population = CASE id WHEN 129530 THEN 70000 ELSE population END WHERE id IN (129530);

UPDATE cities SET population = CASE id WHEN 129058 THEN 69959 ELSE population END WHERE id IN (129058);

UPDATE cities SET population = CASE id WHEN 116885 THEN 69479 ELSE population END WHERE id IN (116885);

UPDATE cities SET population = CASE id WHEN 120540 THEN 66959 ELSE population END WHERE id IN (120540);

UPDATE cities SET population = CASE id WHEN 123609 THEN 66555 ELSE population END WHERE id IN (123609);

UPDATE cities SET population = CASE id WHEN 111955 THEN 66455 ELSE population END WHERE id IN (111955);

UPDATE cities SET population = CASE id WHEN 119257 THEN 66027 ELSE population END WHERE id IN (119257);

UPDATE cities SET population = CASE id WHEN 126249 THEN 65046 ELSE population END WHERE id IN (126249);

UPDATE cities SET population = CASE id WHEN 114581 THEN 64980 ELSE population END WHERE id IN (114581);

UPDATE cities SET population = CASE id WHEN 125348 THEN 63159 ELSE population END WHERE id IN (125348);

UPDATE cities SET population = CASE id WHEN 128776 THEN 62560 ELSE population END WHERE id IN (128776);

UPDATE cities SET population = CASE id WHEN 122122 THEN 61468 ELSE population END WHERE id IN (122122);

UPDATE cities SET population = CASE id WHEN 112288 THEN 60858 ELSE population END WHERE id IN (112288);

UPDATE cities SET population = CASE id WHEN 127520 THEN 60825 ELSE population END WHERE id IN (127520);

UPDATE cities SET population = CASE id WHEN 128270 THEN 60818 ELSE population END WHERE id IN (128270);

UPDATE cities SET population = CASE id WHEN 128898 THEN 60806 ELSE population END WHERE id IN (128898);

UPDATE cities SET population = CASE id WHEN 125832 THEN 60684 ELSE population END WHERE id IN (125832);

UPDATE cities SET population = CASE id WHEN 124225 THEN 60076 ELSE population END WHERE id IN (124225);

UPDATE cities SET population = CASE id WHEN 113741 THEN 59568 ELSE population END WHERE id IN (113741);

UPDATE cities SET population = CASE id WHEN 121216 THEN 59067 ELSE population END WHERE id IN (121216);

UPDATE cities SET population = CASE id WHEN 112867 THEN 58732 ELSE population END WHERE id IN (112867);

UPDATE cities SET population = CASE id WHEN 111861 THEN 58579 ELSE population END WHERE id IN (111861);

UPDATE cities SET population = CASE id WHEN 129526 THEN 58567 ELSE population END WHERE id IN (129526);

UPDATE cities SET population = CASE id WHEN 125886 THEN 58111 ELSE population END WHERE id IN (125886);

UPDATE cities SET population = CASE id WHEN 112623 THEN 58025 ELSE population END WHERE id IN (112623);

UPDATE cities SET population = CASE id WHEN 112264 THEN 56368 ELSE population END WHERE id IN (112264);

UPDATE cities SET population = CASE id WHEN 121113 THEN 56308 ELSE population END WHERE id IN (121113);

UPDATE cities SET population = CASE id WHEN 125335 THEN 55806 ELSE population END WHERE id IN (125335);

UPDATE cities SET population = CASE id WHEN 113549 THEN 55591 ELSE population END WHERE id IN (113549);

UPDATE cities SET population = CASE id WHEN 115149 THEN 55437 ELSE population END WHERE id IN (115149);

UPDATE cities SET population = CASE id WHEN 128887 THEN 54927 ELSE population END WHERE id IN (128887);

UPDATE cities SET population = CASE id WHEN 112856 THEN 51910 ELSE population END WHERE id IN (112856);

UPDATE cities SET population = CASE id WHEN 120407 THEN 51881 ELSE population END WHERE id IN (120407);

UPDATE cities SET population = CASE id WHEN 111904 THEN 51589 ELSE population END WHERE id IN (111904);

UPDATE cities SET population = CASE id WHEN 117461 THEN 51440 ELSE population END WHERE id IN (117461);

UPDATE cities SET population = CASE id WHEN 111393 THEN 51221 ELSE population END WHERE id IN (111393);

UPDATE cities SET population = CASE id WHEN 117042 THEN 50180 ELSE population END WHERE id IN (117042);

UPDATE cities SET population = CASE id WHEN 129101 THEN 49732 WHEN 129202 THEN 49732 ELSE population END WHERE id IN (129101,129202);

UPDATE cities SET population = CASE id WHEN 129329 THEN 49643 ELSE population END WHERE id IN (129329);

UPDATE cities SET population = CASE id WHEN 127060 THEN 48967 ELSE population END WHERE id IN (127060);

UPDATE cities SET population = CASE id WHEN 114424 THEN 48863 ELSE population END WHERE id IN (114424);

UPDATE cities SET population = CASE id WHEN 121211 THEN 48602 ELSE population END WHERE id IN (121211);

UPDATE cities SET population = CASE id WHEN 129112 THEN 48284 ELSE population END WHERE id IN (129112);

UPDATE cities SET population = CASE id WHEN 113901 THEN 47864 ELSE population END WHERE id IN (113901);

UPDATE cities SET population = CASE id WHEN 125744 THEN 47813 ELSE population END WHERE id IN (125744);

UPDATE cities SET population = CASE id WHEN 120225 THEN 47809 ELSE population END WHERE id IN (120225);

UPDATE cities SET population = CASE id WHEN 125439 THEN 47637 ELSE population END WHERE id IN (125439);

UPDATE cities SET population = CASE id WHEN 114714 THEN 47105 ELSE population END WHERE id IN (114714);

UPDATE cities SET population = CASE id WHEN 120984 THEN 46962 ELSE population END WHERE id IN (120984);

UPDATE cities SET population = CASE id WHEN 114490 THEN 46690 ELSE population END WHERE id IN (114490);

UPDATE cities SET population = CASE id WHEN 119849 THEN 46621 ELSE population END WHERE id IN (119849);

UPDATE cities SET population = CASE id WHEN 116258 THEN 46050 ELSE population END WHERE id IN (116258);

UPDATE cities SET population = CASE id WHEN 116051 THEN 45957 ELSE population END WHERE id IN (116051);

UPDATE cities SET population = CASE id WHEN 128908 THEN 45550 ELSE population END WHERE id IN (128908);

UPDATE cities SET population = CASE id WHEN 127685 THEN 45393 ELSE population END WHERE id IN (127685);

UPDATE cities SET population = CASE id WHEN 127868 THEN 44990 ELSE population END WHERE id IN (127868);

UPDATE cities SET population = CASE id WHEN 128809 THEN 44092 ELSE population END WHERE id IN (128809);

UPDATE cities SET population = CASE id WHEN 119173 THEN 42595 ELSE population END WHERE id IN (119173);

UPDATE cities SET population = CASE id WHEN 119412 THEN 42137 ELSE population END WHERE id IN (119412);

UPDATE cities SET population = CASE id WHEN 112103 THEN 42034 ELSE population END WHERE id IN (112103);

UPDATE cities SET population = CASE id WHEN 129554 THEN 41981 ELSE population END WHERE id IN (129554);

UPDATE cities SET population = CASE id WHEN 118835 THEN 41569 ELSE population END WHERE id IN (118835);

UPDATE cities SET population = CASE id WHEN 118371 THEN 41547 ELSE population END WHERE id IN (118371);

UPDATE cities SET population = CASE id WHEN 129582 THEN 41475 ELSE population END WHERE id IN (129582);

UPDATE cities SET population = CASE id WHEN 126297 THEN 41296 ELSE population END WHERE id IN (126297);

UPDATE cities SET population = CASE id WHEN 113054 THEN 41055 ELSE population END WHERE id IN (113054);

UPDATE cities SET population = CASE id WHEN 111349 THEN 41008 ELSE population END WHERE id IN (111349);

UPDATE cities SET population = CASE id WHEN 122694 THEN 40997 ELSE population END WHERE id IN (122694);

UPDATE cities SET population = CASE id WHEN 118583 THEN 40684 ELSE population END WHERE id IN (118583);

UPDATE cities SET population = CASE id WHEN 116534 THEN 40545 ELSE population END WHERE id IN (116534);

UPDATE cities SET population = CASE id WHEN 121274 THEN 40191 ELSE population END WHERE id IN (121274);

UPDATE cities SET population = CASE id WHEN 116577 THEN 40026 ELSE population END WHERE id IN (116577);

UPDATE cities SET population = CASE id WHEN 123195 THEN 39899 ELSE population END WHERE id IN (123195);

UPDATE cities SET population = CASE id WHEN 123298 THEN 39813 ELSE population END WHERE id IN (123298);

UPDATE cities SET population = CASE id WHEN 121690 THEN 39661 ELSE population END WHERE id IN (121690);

UPDATE cities SET population = CASE id WHEN 124680 THEN 39308 ELSE population END WHERE id IN (124680);

UPDATE cities SET population = CASE id WHEN 116191 THEN 39262 ELSE population END WHERE id IN (116191);

UPDATE cities SET population = CASE id WHEN 129120 THEN 38079 ELSE population END WHERE id IN (129120);

UPDATE cities SET population = CASE id WHEN 123851 THEN 37757 ELSE population END WHERE id IN (123851);

UPDATE cities SET population = CASE id WHEN 127232 THEN 37499 ELSE population END WHERE id IN (127232);

UPDATE cities SET population = CASE id WHEN 124543 THEN 36738 WHEN 129027 THEN 36738 ELSE population END WHERE id IN (124543,129027);

UPDATE cities SET population = CASE id WHEN 122654 THEN 36732 ELSE population END WHERE id IN (122654);

UPDATE cities SET population = CASE id WHEN 116723 THEN 36672 ELSE population END WHERE id IN (116723);

UPDATE cities SET population = CASE id WHEN 125611 THEN 36376 ELSE population END WHERE id IN (125611);

UPDATE cities SET population = CASE id WHEN 125375 THEN 36323 ELSE population END WHERE id IN (125375);

UPDATE cities SET population = CASE id WHEN 125061 THEN 36216 ELSE population END WHERE id IN (125061);

UPDATE cities SET population = CASE id WHEN 120423 THEN 36202 ELSE population END WHERE id IN (120423);

UPDATE cities SET population = CASE id WHEN 123306 THEN 36143 ELSE population END WHERE id IN (123306);

UPDATE cities SET population = CASE id WHEN 117004 THEN 36084 ELSE population END WHERE id IN (117004);

UPDATE cities SET population = CASE id WHEN 120280 THEN 35980 ELSE population END WHERE id IN (120280);

UPDATE cities SET population = CASE id WHEN 114691 THEN 35918 ELSE population END WHERE id IN (114691);

UPDATE cities SET population = CASE id WHEN 125084 THEN 35854 ELSE population END WHERE id IN (125084);

UPDATE cities SET population = CASE id WHEN 121344 THEN 35795 ELSE population END WHERE id IN (121344);

UPDATE cities SET population = CASE id WHEN 118682 THEN 35635 ELSE population END WHERE id IN (118682);

UPDATE cities SET population = CASE id WHEN 123232 THEN 35243 ELSE population END WHERE id IN (123232);

UPDATE cities SET population = CASE id WHEN 125626 THEN 35183 ELSE population END WHERE id IN (125626);

UPDATE cities SET population = CASE id WHEN 119776 THEN 35148 ELSE population END WHERE id IN (119776);

UPDATE cities SET population = CASE id WHEN 128027 THEN 35058 ELSE population END WHERE id IN (128027);

UPDATE cities SET population = CASE id WHEN 127744 THEN 34906 ELSE population END WHERE id IN (127744);

UPDATE cities SET population = CASE id WHEN 112191 THEN 34177 ELSE population END WHERE id IN (112191);

UPDATE cities SET population = CASE id WHEN 125221 THEN 34005 ELSE population END WHERE id IN (125221);

UPDATE cities SET population = CASE id WHEN 115001 THEN 33853 ELSE population END WHERE id IN (115001);

UPDATE cities SET population = CASE id WHEN 122799 THEN 33817 ELSE population END WHERE id IN (122799);

UPDATE cities SET population = CASE id WHEN 115175 THEN 33806 ELSE population END WHERE id IN (115175);

UPDATE cities SET population = CASE id WHEN 125754 THEN 32899 ELSE population END WHERE id IN (125754);

UPDATE cities SET population = CASE id WHEN 128913 THEN 32749 ELSE population END WHERE id IN (128913);

UPDATE cities SET population = CASE id WHEN 114238 THEN 32390 ELSE population END WHERE id IN (114238);

UPDATE cities SET population = CASE id WHEN 127237 THEN 32365 ELSE population END WHERE id IN (127237);

UPDATE cities SET population = CASE id WHEN 124865 THEN 32112 ELSE population END WHERE id IN (124865);

UPDATE cities SET population = CASE id WHEN 123343 THEN 32109 ELSE population END WHERE id IN (123343);

UPDATE cities SET population = CASE id WHEN 125827 THEN 31520 ELSE population END WHERE id IN (125827);

UPDATE cities SET population = CASE id WHEN 122600 THEN 31378 ELSE population END WHERE id IN (122600);

UPDATE cities SET population = CASE id WHEN 117027 THEN 31273 ELSE population END WHERE id IN (117027);

UPDATE cities SET population = CASE id WHEN 125941 THEN 30968 ELSE population END WHERE id IN (125941);

UPDATE cities SET population = CASE id WHEN 120029 THEN 30943 ELSE population END WHERE id IN (120029);

UPDATE cities SET population = CASE id WHEN 123877 THEN 30734 ELSE population END WHERE id IN (123877);

UPDATE cities SET population = CASE id WHEN 124318 THEN 30590 ELSE population END WHERE id IN (124318);

UPDATE cities SET population = CASE id WHEN 126340 THEN 30517 ELSE population END WHERE id IN (126340);

UPDATE cities SET population = CASE id WHEN 120243 THEN 30493 ELSE population END WHERE id IN (120243);

UPDATE cities SET population = CASE id WHEN 127544 THEN 30353 ELSE population END WHERE id IN (127544);

UPDATE cities SET population = CASE id WHEN 123871 THEN 30177 ELSE population END WHERE id IN (123871);

UPDATE cities SET population = CASE id WHEN 122900 THEN 29876 ELSE population END WHERE id IN (122900);

UPDATE cities SET population = CASE id WHEN 129018 THEN 29862 ELSE population END WHERE id IN (129018);

UPDATE cities SET population = CASE id WHEN 126658 THEN 29658 ELSE population END WHERE id IN (126658);

UPDATE cities SET population = CASE id WHEN 119801 THEN 29588 ELSE population END WHERE id IN (119801);

UPDATE cities SET population = CASE id WHEN 116872 THEN 29320 ELSE population END WHERE id IN (116872);

UPDATE cities SET population = CASE id WHEN 115512 THEN 29193 ELSE population END WHERE id IN (115512);

UPDATE cities SET population = CASE id WHEN 113046 THEN 29128 ELSE population END WHERE id IN (113046);

UPDATE cities SET population = CASE id WHEN 116245 THEN 29011 ELSE population END WHERE id IN (116245);

UPDATE cities SET population = CASE id WHEN 123226 THEN 29002 ELSE population END WHERE id IN (123226);

UPDATE cities SET population = CASE id WHEN 114867 THEN 28879 ELSE population END WHERE id IN (114867);

UPDATE cities SET population = CASE id WHEN 124978 THEN 28654 ELSE population END WHERE id IN (124978);

UPDATE cities SET population = CASE id WHEN 123134 THEN 28540 ELSE population END WHERE id IN (123134);

UPDATE cities SET population = CASE id WHEN 116818 THEN 28391 ELSE population END WHERE id IN (116818);

UPDATE cities SET population = CASE id WHEN 113663 THEN 28295 ELSE population END WHERE id IN (113663);

UPDATE cities SET population = CASE id WHEN 121904 THEN 28230 ELSE population END WHERE id IN (121904);

UPDATE cities SET population = CASE id WHEN 127067 THEN 28202 ELSE population END WHERE id IN (127067);

UPDATE cities SET population = CASE id WHEN 114647 THEN 28092 ELSE population END WHERE id IN (114647);

UPDATE cities SET population = CASE id WHEN 117092 THEN 28053 ELSE population END WHERE id IN (117092);

UPDATE cities SET population = CASE id WHEN 112071 THEN 27999 ELSE population END WHERE id IN (112071);

UPDATE cities SET population = CASE id WHEN 121628 THEN 27997 ELSE population END WHERE id IN (121628);

UPDATE cities SET population = CASE id WHEN 116148 THEN 27978 ELSE population END WHERE id IN (116148);

UPDATE cities SET population = CASE id WHEN 125944 THEN 27765 ELSE population END WHERE id IN (125944);

UPDATE cities SET population = CASE id WHEN 121375 THEN 27366 ELSE population END WHERE id IN (121375);

UPDATE cities SET population = CASE id WHEN 111242 THEN 27003 ELSE population END WHERE id IN (111242);

UPDATE cities SET population = CASE id WHEN 128031 THEN 26995 ELSE population END WHERE id IN (128031);

UPDATE cities SET population = CASE id WHEN 127109 THEN 26915 ELSE population END WHERE id IN (127109);

UPDATE cities SET population = CASE id WHEN 118849 THEN 26893 ELSE population END WHERE id IN (118849);

UPDATE cities SET population = CASE id WHEN 117236 THEN 26861 ELSE population END WHERE id IN (117236);

UPDATE cities SET population = CASE id WHEN 112267 THEN 26730 ELSE population END WHERE id IN (112267);

UPDATE cities SET population = CASE id WHEN 111887 THEN 26495 ELSE population END WHERE id IN (111887);

UPDATE cities SET population = CASE id WHEN 118607 THEN 25708 ELSE population END WHERE id IN (118607);

UPDATE cities SET population = CASE id WHEN 118207 THEN 25661 ELSE population END WHERE id IN (118207);

UPDATE cities SET population = CASE id WHEN 125131 THEN 25621 ELSE population END WHERE id IN (125131);

UPDATE cities SET population = CASE id WHEN 113339 THEN 25469 ELSE population END WHERE id IN (113339);

UPDATE cities SET population = CASE id WHEN 112155 THEN 25132 ELSE population END WHERE id IN (112155);

UPDATE cities SET population = CASE id WHEN 129049 THEN 24941 ELSE population END WHERE id IN (129049);

UPDATE cities SET population = CASE id WHEN 128359 THEN 24932 ELSE population END WHERE id IN (128359);

UPDATE cities SET population = CASE id WHEN 125311 THEN 24926 ELSE population END WHERE id IN (125311);

UPDATE cities SET population = CASE id WHEN 123715 THEN 24864 ELSE population END WHERE id IN (123715);

UPDATE cities SET population = CASE id WHEN 116062 THEN 24840 ELSE population END WHERE id IN (116062);

UPDATE cities SET population = CASE id WHEN 120689 THEN 24835 ELSE population END WHERE id IN (120689);

UPDATE cities SET population = CASE id WHEN 123160 THEN 24772 ELSE population END WHERE id IN (123160);

UPDATE cities SET population = CASE id WHEN 124929 THEN 24747 ELSE population END WHERE id IN (124929);

UPDATE cities SET population = CASE id WHEN 115167 THEN 24729 ELSE population END WHERE id IN (115167);

UPDATE cities SET population = CASE id WHEN 116111 THEN 24649 ELSE population END WHERE id IN (116111);

UPDATE cities SET population = CASE id WHEN 125123 THEN 24351 ELSE population END WHERE id IN (125123);

UPDATE cities SET population = CASE id WHEN 123895 THEN 24287 ELSE population END WHERE id IN (123895);

UPDATE cities SET population = CASE id WHEN 114039 THEN 24252 ELSE population END WHERE id IN (114039);

UPDATE cities SET population = CASE id WHEN 129757 THEN 24117 ELSE population END WHERE id IN (129757);

UPDATE cities SET population = CASE id WHEN 119546 THEN 24039 ELSE population END WHERE id IN (119546);

UPDATE cities SET population = CASE id WHEN 121457 THEN 24012 ELSE population END WHERE id IN (121457);

UPDATE cities SET population = CASE id WHEN 126105 THEN 24007 ELSE population END WHERE id IN (126105);

UPDATE cities SET population = CASE id WHEN 122284 THEN 23820 ELSE population END WHERE id IN (122284);

UPDATE cities SET population = CASE id WHEN 116761 THEN 23717 ELSE population END WHERE id IN (116761);

UPDATE cities SET population = CASE id WHEN 116328 THEN 23681 ELSE population END WHERE id IN (116328);

UPDATE cities SET population = CASE id WHEN 112861 THEN 23657 ELSE population END WHERE id IN (112861);

UPDATE cities SET population = CASE id WHEN 115260 THEN 23509 ELSE population END WHERE id IN (115260);

UPDATE cities SET population = CASE id WHEN 127533 THEN 23319 ELSE population END WHERE id IN (127533);

UPDATE cities SET population = CASE id WHEN 115521 THEN 23231 ELSE population END WHERE id IN (115521);

UPDATE cities SET population = CASE id WHEN 112147 THEN 23168 ELSE population END WHERE id IN (112147);

UPDATE cities SET population = CASE id WHEN 115237 THEN 23150 ELSE population END WHERE id IN (115237);

UPDATE cities SET population = CASE id WHEN 128215 THEN 23131 ELSE population END WHERE id IN (128215);

UPDATE cities SET population = CASE id WHEN 129605 THEN 23127 ELSE population END WHERE id IN (129605);

UPDATE cities SET population = CASE id WHEN 128126 THEN 23081 ELSE population END WHERE id IN (128126);

UPDATE cities SET population = CASE id WHEN 129371 THEN 23072 ELSE population END WHERE id IN (129371);

UPDATE cities SET population = CASE id WHEN 125426 THEN 22994 ELSE population END WHERE id IN (125426);

UPDATE cities SET population = CASE id WHEN 123988 THEN 22885 ELSE population END WHERE id IN (123988);

UPDATE cities SET population = CASE id WHEN 123260 THEN 22685 ELSE population END WHERE id IN (123260);

UPDATE cities SET population = CASE id WHEN 128527 THEN 22560 ELSE population END WHERE id IN (128527);

UPDATE cities SET population = CASE id WHEN 117784 THEN 22498 ELSE population END WHERE id IN (117784);

UPDATE cities SET population = CASE id WHEN 128984 THEN 22460 ELSE population END WHERE id IN (128984);

UPDATE cities SET population = CASE id WHEN 122671 THEN 22351 ELSE population END WHERE id IN (122671);

UPDATE cities SET population = CASE id WHEN 123751 THEN 22341 ELSE population END WHERE id IN (123751);

UPDATE cities SET population = CASE id WHEN 121807 THEN 22318 ELSE population END WHERE id IN (121807);

UPDATE cities SET population = CASE id WHEN 128170 THEN 22211 ELSE population END WHERE id IN (128170);

UPDATE cities SET population = CASE id WHEN 125587 THEN 22079 ELSE population END WHERE id IN (125587);

UPDATE cities SET population = CASE id WHEN 115265 THEN 22015 ELSE population END WHERE id IN (115265);

UPDATE cities SET population = CASE id WHEN 114578 THEN 21987 ELSE population END WHERE id IN (114578);

UPDATE cities SET population = CASE id WHEN 128243 THEN 21969 ELSE population END WHERE id IN (128243);

UPDATE cities SET population = CASE id WHEN 115851 THEN 21566 ELSE population END WHERE id IN (115851);

UPDATE cities SET population = CASE id WHEN 122552 THEN 21512 ELSE population END WHERE id IN (122552);

UPDATE cities SET population = CASE id WHEN 111120 THEN 21462 ELSE population END WHERE id IN (111120);

UPDATE cities SET population = CASE id WHEN 111484 THEN 21357 ELSE population END WHERE id IN (111484);

UPDATE cities SET population = CASE id WHEN 117355 THEN 21270 ELSE population END WHERE id IN (117355);

UPDATE cities SET population = CASE id WHEN 113358 THEN 21262 ELSE population END WHERE id IN (113358);

UPDATE cities SET population = CASE id WHEN 123675 THEN 21249 ELSE population END WHERE id IN (123675);

UPDATE cities SET population = CASE id WHEN 111526 THEN 21108 ELSE population END WHERE id IN (111526);

UPDATE cities SET population = CASE id WHEN 118190 THEN 21092 ELSE population END WHERE id IN (118190);

UPDATE cities SET population = CASE id WHEN 110999 THEN 20897 ELSE population END WHERE id IN (110999);

UPDATE cities SET population = CASE id WHEN 117074 THEN 20868 ELSE population END WHERE id IN (117074);

UPDATE cities SET population = CASE id WHEN 127340 THEN 20840 ELSE population END WHERE id IN (127340);

UPDATE cities SET population = CASE id WHEN 127980 THEN 20805 ELSE population END WHERE id IN (127980);

UPDATE cities SET population = CASE id WHEN 124386 THEN 20755 ELSE population END WHERE id IN (124386);

UPDATE cities SET population = CASE id WHEN 111960 THEN 20512 ELSE population END WHERE id IN (111960);

UPDATE cities SET population = CASE id WHEN 117912 THEN 20480 ELSE population END WHERE id IN (117912);

UPDATE cities SET population = CASE id WHEN 124292 THEN 20409 ELSE population END WHERE id IN (124292);

UPDATE cities SET population = CASE id WHEN 121785 THEN 20372 ELSE population END WHERE id IN (121785);

UPDATE cities SET population = CASE id WHEN 118111 THEN 20348 ELSE population END WHERE id IN (118111);

UPDATE cities SET population = CASE id WHEN 112875 THEN 20256 ELSE population END WHERE id IN (112875);

UPDATE cities SET population = CASE id WHEN 127194 THEN 20189 ELSE population END WHERE id IN (127194);

UPDATE cities SET population = CASE id WHEN 123754 THEN 20019 WHEN 125363 THEN 20019 ELSE population END WHERE id IN (123754,125363);

UPDATE cities SET population = CASE id WHEN 112963 THEN 19986 WHEN 128022 THEN 19986 ELSE population END WHERE id IN (112963,128022);

UPDATE cities SET population = CASE id WHEN 122814 THEN 19967 ELSE population END WHERE id IN (122814);

UPDATE cities SET population = CASE id WHEN 115325 THEN 19895 ELSE population END WHERE id IN (115325);

UPDATE cities SET population = CASE id WHEN 122105 THEN 19570 ELSE population END WHERE id IN (122105);

UPDATE cities SET population = CASE id WHEN 121025 THEN 19539 ELSE population END WHERE id IN (121025);

UPDATE cities SET population = CASE id WHEN 126138 THEN 19519 ELSE population END WHERE id IN (126138);

UPDATE cities SET population = CASE id WHEN 126192 THEN 19478 ELSE population END WHERE id IN (126192);

UPDATE cities SET population = CASE id WHEN 119976 THEN 19477 ELSE population END WHERE id IN (119976);

UPDATE cities SET population = CASE id WHEN 116664 THEN 19383 ELSE population END WHERE id IN (116664);

UPDATE cities SET population = CASE id WHEN 123505 THEN 19347 ELSE population END WHERE id IN (123505);

UPDATE cities SET population = CASE id WHEN 125416 THEN 19257 ELSE population END WHERE id IN (125416);

UPDATE cities SET population = CASE id WHEN 126280 THEN 19133 ELSE population END WHERE id IN (126280);

UPDATE cities SET population = CASE id WHEN 116938 THEN 19069 ELSE population END WHERE id IN (116938);

UPDATE cities SET population = CASE id WHEN 115181 THEN 19019 ELSE population END WHERE id IN (115181);

UPDATE cities SET population = CASE id WHEN 122491 THEN 18954 ELSE population END WHERE id IN (122491);

UPDATE cities SET population = CASE id WHEN 127841 THEN 18853 ELSE population END WHERE id IN (127841);

UPDATE cities SET population = CASE id WHEN 116326 THEN 18730 ELSE population END WHERE id IN (116326);

UPDATE cities SET population = CASE id WHEN 129043 THEN 18670 ELSE population END WHERE id IN (129043);

UPDATE cities SET population = CASE id WHEN 126932 THEN 18459 ELSE population END WHERE id IN (126932);

UPDATE cities SET population = CASE id WHEN 129709 THEN 18451 ELSE population END WHERE id IN (129709);

UPDATE cities SET population = CASE id WHEN 126300 THEN 18399 ELSE population END WHERE id IN (126300);

UPDATE cities SET population = CASE id WHEN 115919 THEN 18386 ELSE population END WHERE id IN (115919);

UPDATE cities SET population = CASE id WHEN 114889 THEN 18353 ELSE population END WHERE id IN (114889);

UPDATE cities SET population = CASE id WHEN 116868 THEN 18312 ELSE population END WHERE id IN (116868);

UPDATE cities SET population = CASE id WHEN 114816 THEN 18276 ELSE population END WHERE id IN (114816);

UPDATE cities SET population = CASE id WHEN 118246 THEN 18264 ELSE population END WHERE id IN (118246);

UPDATE cities SET population = CASE id WHEN 112552 THEN 18156 ELSE population END WHERE id IN (112552);

UPDATE cities SET population = CASE id WHEN 126144 THEN 18153 ELSE population END WHERE id IN (126144);

UPDATE cities SET population = CASE id WHEN 114946 THEN 18117 ELSE population END WHERE id IN (114946);

UPDATE cities SET population = CASE id WHEN 129342 THEN 18062 ELSE population END WHERE id IN (129342);

UPDATE cities SET population = CASE id WHEN 113236 THEN 17724 ELSE population END WHERE id IN (113236);

UPDATE cities SET population = CASE id WHEN 121346 THEN 17700 ELSE population END WHERE id IN (121346);

UPDATE cities SET population = CASE id WHEN 111921 THEN 17598 ELSE population END WHERE id IN (111921);

UPDATE cities SET population = CASE id WHEN 125695 THEN 17472 ELSE population END WHERE id IN (125695);

UPDATE cities SET population = CASE id WHEN 129148 THEN 17403 ELSE population END WHERE id IN (129148);

UPDATE cities SET population = CASE id WHEN 111005 THEN 17303 ELSE population END WHERE id IN (111005);

UPDATE cities SET population = CASE id WHEN 126078 THEN 17287 ELSE population END WHERE id IN (126078);

UPDATE cities SET population = CASE id WHEN 124974 THEN 17242 ELSE population END WHERE id IN (124974);

UPDATE cities SET population = CASE id WHEN 116619 THEN 17218 ELSE population END WHERE id IN (116619);

UPDATE cities SET population = CASE id WHEN 122610 THEN 17196 ELSE population END WHERE id IN (122610);

UPDATE cities SET population = CASE id WHEN 123408 THEN 17134 ELSE population END WHERE id IN (123408);

UPDATE cities SET population = CASE id WHEN 111247 THEN 16984 ELSE population END WHERE id IN (111247);

UPDATE cities SET population = CASE id WHEN 111496 THEN 16961 ELSE population END WHERE id IN (111496);

UPDATE cities SET population = CASE id WHEN 120360 THEN 16788 ELSE population END WHERE id IN (120360);

UPDATE cities SET population = CASE id WHEN 126370 THEN 16747 ELSE population END WHERE id IN (126370);

UPDATE cities SET population = CASE id WHEN 116486 THEN 16746 ELSE population END WHERE id IN (116486);

UPDATE cities SET population = CASE id WHEN 112483 THEN 16728 ELSE population END WHERE id IN (112483);

UPDATE cities SET population = CASE id WHEN 113646 THEN 16655 ELSE population END WHERE id IN (113646);

UPDATE cities SET population = CASE id WHEN 129468 THEN 16639 ELSE population END WHERE id IN (129468);

UPDATE cities SET population = CASE id WHEN 115785 THEN 16617 ELSE population END WHERE id IN (115785);

UPDATE cities SET population = CASE id WHEN 119615 THEN 16487 ELSE population END WHERE id IN (119615);

UPDATE cities SET population = CASE id WHEN 127142 THEN 16462 ELSE population END WHERE id IN (127142);

UPDATE cities SET population = CASE id WHEN 111690 THEN 16451 ELSE population END WHERE id IN (111690);

UPDATE cities SET population = CASE id WHEN 127271 THEN 16389 ELSE population END WHERE id IN (127271);

UPDATE cities SET population = CASE id WHEN 113197 THEN 16309 ELSE population END WHERE id IN (113197);

UPDATE cities SET population = CASE id WHEN 128626 THEN 16261 ELSE population END WHERE id IN (128626);

UPDATE cities SET population = CASE id WHEN 123578 THEN 16260 ELSE population END WHERE id IN (123578);

UPDATE cities SET population = CASE id WHEN 125391 THEN 16258 ELSE population END WHERE id IN (125391);

UPDATE cities SET population = CASE id WHEN 115491 THEN 16197 ELSE population END WHERE id IN (115491);

UPDATE cities SET population = CASE id WHEN 112947 THEN 16157 ELSE population END WHERE id IN (112947);

UPDATE cities SET population = CASE id WHEN 124557 THEN 16116 ELSE population END WHERE id IN (124557);

UPDATE cities SET population = CASE id WHEN 128848 THEN 16060 ELSE population END WHERE id IN (128848);

UPDATE cities SET population = CASE id WHEN 125030 THEN 16005 ELSE population END WHERE id IN (125030);

UPDATE cities SET population = CASE id WHEN 125192 THEN 15989 ELSE population END WHERE id IN (125192);

UPDATE cities SET population = CASE id WHEN 110986 THEN 15985 ELSE population END WHERE id IN (110986);

UPDATE cities SET population = CASE id WHEN 123056 THEN 15931 ELSE population END WHERE id IN (123056);

UPDATE cities SET population = CASE id WHEN 122522 THEN 15870 ELSE population END WHERE id IN (122522);

UPDATE cities SET population = CASE id WHEN 124539 THEN 15846 ELSE population END WHERE id IN (124539);

UPDATE cities SET population = CASE id WHEN 124250 THEN 15752 ELSE population END WHERE id IN (124250);

UPDATE cities SET population = CASE id WHEN 116508 THEN 15548 ELSE population END WHERE id IN (116508);

UPDATE cities SET population = CASE id WHEN 111034 THEN 15518 ELSE population END WHERE id IN (111034);

UPDATE cities SET population = CASE id WHEN 127517 THEN 15421 ELSE population END WHERE id IN (127517);

UPDATE cities SET population = CASE id WHEN 115828 THEN 15403 ELSE population END WHERE id IN (115828);

UPDATE cities SET population = CASE id WHEN 119873 THEN 15400 ELSE population END WHERE id IN (119873);

UPDATE cities SET population = CASE id WHEN 118968 THEN 15369 ELSE population END WHERE id IN (118968);

UPDATE cities SET population = CASE id WHEN 121872 THEN 15314 ELSE population END WHERE id IN (121872);

UPDATE cities SET population = CASE id WHEN 112928 THEN 15313 ELSE population END WHERE id IN (112928);

UPDATE cities SET population = CASE id WHEN 115009 THEN 15257 ELSE population END WHERE id IN (115009);

UPDATE cities SET population = CASE id WHEN 119462 THEN 15160 ELSE population END WHERE id IN (119462);

UPDATE cities SET population = CASE id WHEN 128949 THEN 15097 ELSE population END WHERE id IN (128949);

UPDATE cities SET population = CASE id WHEN 127612 THEN 15047 ELSE population END WHERE id IN (127612);

UPDATE cities SET population = CASE id WHEN 111636 THEN 15035 ELSE population END WHERE id IN (111636);

UPDATE cities SET population = CASE id WHEN 112213 THEN 14882 ELSE population END WHERE id IN (112213);

UPDATE cities SET population = CASE id WHEN 114643 THEN 14866 ELSE population END WHERE id IN (114643);

UPDATE cities SET population = CASE id WHEN 116129 THEN 14863 ELSE population END WHERE id IN (116129);

UPDATE cities SET population = CASE id WHEN 121941 THEN 14754 ELSE population END WHERE id IN (121941);

UPDATE cities SET population = CASE id WHEN 123696 THEN 14719 ELSE population END WHERE id IN (123696);

UPDATE cities SET population = CASE id WHEN 117434 THEN 14647 ELSE population END WHERE id IN (117434);

UPDATE cities SET population = CASE id WHEN 116880 THEN 14636 ELSE population END WHERE id IN (116880);

UPDATE cities SET population = CASE id WHEN 114119 THEN 14628 ELSE population END WHERE id IN (114119);

UPDATE cities SET population = CASE id WHEN 114413 THEN 14601 ELSE population END WHERE id IN (114413);

UPDATE cities SET population = CASE id WHEN 128094 THEN 14578 ELSE population END WHERE id IN (128094);

UPDATE cities SET population = CASE id WHEN 120567 THEN 14408 ELSE population END WHERE id IN (120567);

UPDATE cities SET population = CASE id WHEN 112876 THEN 14373 ELSE population END WHERE id IN (112876);

UPDATE cities SET population = CASE id WHEN 111372 THEN 14329 ELSE population END WHERE id IN (111372);

UPDATE cities SET population = CASE id WHEN 113491 THEN 14319 ELSE population END WHERE id IN (113491);

UPDATE cities SET population = CASE id WHEN 117245 THEN 14303 ELSE population END WHERE id IN (117245);

UPDATE cities SET population = CASE id WHEN 118842 THEN 14120 ELSE population END WHERE id IN (118842);

UPDATE cities SET population = CASE id WHEN 119138 THEN 14071 ELSE population END WHERE id IN (119138);

UPDATE cities SET population = CASE id WHEN 122406 THEN 14028 ELSE population END WHERE id IN (122406);

UPDATE cities SET population = CASE id WHEN 121777 THEN 13934 ELSE population END WHERE id IN (121777);

UPDATE cities SET population = CASE id WHEN 114735 THEN 13916 ELSE population END WHERE id IN (114735);

UPDATE cities SET population = CASE id WHEN 116155 THEN 13861 ELSE population END WHERE id IN (116155);

UPDATE cities SET population = CASE id WHEN 116646 THEN 13854 ELSE population END WHERE id IN (116646);

UPDATE cities SET population = CASE id WHEN 118285 THEN 13814 ELSE population END WHERE id IN (118285);

UPDATE cities SET population = CASE id WHEN 114143 THEN 13766 ELSE population END WHERE id IN (114143);

UPDATE cities SET population = CASE id WHEN 121540 THEN 13759 ELSE population END WHERE id IN (121540);

UPDATE cities SET population = CASE id WHEN 125742 THEN 13722 ELSE population END WHERE id IN (125742);

UPDATE cities SET population = CASE id WHEN 117070 THEN 13711 ELSE population END WHERE id IN (117070);

UPDATE cities SET population = CASE id WHEN 111738 THEN 13695 ELSE population END WHERE id IN (111738);

UPDATE cities SET population = CASE id WHEN 122057 THEN 13641 ELSE population END WHERE id IN (122057);

UPDATE cities SET population = CASE id WHEN 121874 THEN 13606 ELSE population END WHERE id IN (121874);

UPDATE cities SET population = CASE id WHEN 119224 THEN 13567 ELSE population END WHERE id IN (119224);

UPDATE cities SET population = CASE id WHEN 127325 THEN 13543 ELSE population END WHERE id IN (127325);

UPDATE cities SET population = CASE id WHEN 118273 THEN 13529 ELSE population END WHERE id IN (118273);

UPDATE cities SET population = CASE id WHEN 123526 THEN 13460 ELSE population END WHERE id IN (123526);

UPDATE cities SET population = CASE id WHEN 112018 THEN 13347 ELSE population END WHERE id IN (112018);

UPDATE cities SET population = CASE id WHEN 118824 THEN 13313 ELSE population END WHERE id IN (118824);

UPDATE cities SET population = CASE id WHEN 123764 THEN 13249 ELSE population END WHERE id IN (123764);

UPDATE cities SET population = CASE id WHEN 126865 THEN 13234 ELSE population END WHERE id IN (126865);

UPDATE cities SET population = CASE id WHEN 124946 THEN 13223 ELSE population END WHERE id IN (124946);

UPDATE cities SET population = CASE id WHEN 113194 THEN 13213 ELSE population END WHERE id IN (113194);

UPDATE cities SET population = CASE id WHEN 111595 THEN 13193 ELSE population END WHERE id IN (111595);

UPDATE cities SET population = CASE id WHEN 114863 THEN 13144 ELSE population END WHERE id IN (114863);

UPDATE cities SET population = CASE id WHEN 118054 THEN 13138 ELSE population END WHERE id IN (118054);

UPDATE cities SET population = CASE id WHEN 120676 THEN 13060 ELSE population END WHERE id IN (120676);

UPDATE cities SET population = CASE id WHEN 121610 THEN 13042 ELSE population END WHERE id IN (121610);

UPDATE cities SET population = CASE id WHEN 125913 THEN 13037 ELSE population END WHERE id IN (125913);

UPDATE cities SET population = CASE id WHEN 121768 THEN 13008 ELSE population END WHERE id IN (121768);

UPDATE cities SET population = CASE id WHEN 129575 THEN 12993 ELSE population END WHERE id IN (129575);

UPDATE cities SET population = CASE id WHEN 128935 THEN 12966 ELSE population END WHERE id IN (128935);

UPDATE cities SET population = CASE id WHEN 126348 THEN 12961 ELSE population END WHERE id IN (126348);

UPDATE cities SET population = CASE id WHEN 122830 THEN 12943 ELSE population END WHERE id IN (122830);

UPDATE cities SET population = CASE id WHEN 117698 THEN 12942 ELSE population END WHERE id IN (117698);

UPDATE cities SET population = CASE id WHEN 114988 THEN 12870 ELSE population END WHERE id IN (114988);

UPDATE cities SET population = CASE id WHEN 119526 THEN 12790 ELSE population END WHERE id IN (119526);

UPDATE cities SET population = CASE id WHEN 121928 THEN 12690 ELSE population END WHERE id IN (121928);

UPDATE cities SET population = CASE id WHEN 121474 THEN 12661 ELSE population END WHERE id IN (121474);

UPDATE cities SET population = CASE id WHEN 113685 THEN 12655 ELSE population END WHERE id IN (113685);

UPDATE cities SET population = CASE id WHEN 115896 THEN 12604 ELSE population END WHERE id IN (115896);

UPDATE cities SET population = CASE id WHEN 116224 THEN 12596 ELSE population END WHERE id IN (116224);

UPDATE cities SET population = CASE id WHEN 122195 THEN 12593 ELSE population END WHERE id IN (122195);

UPDATE cities SET population = CASE id WHEN 124357 THEN 12572 ELSE population END WHERE id IN (124357);

UPDATE cities SET population = CASE id WHEN 129521 THEN 12539 ELSE population END WHERE id IN (129521);

UPDATE cities SET population = CASE id WHEN 129532 THEN 12518 ELSE population END WHERE id IN (129532);

UPDATE cities SET population = CASE id WHEN 111732 THEN 12507 WHEN 113250 THEN 12507 ELSE population END WHERE id IN (111732,113250);

UPDATE cities SET population = CASE id WHEN 129414 THEN 12472 ELSE population END WHERE id IN (129414);

UPDATE cities SET population = CASE id WHEN 123061 THEN 12435 ELSE population END WHERE id IN (123061);

UPDATE cities SET population = CASE id WHEN 118994 THEN 12423 ELSE population END WHERE id IN (118994);

UPDATE cities SET population = CASE id WHEN 123636 THEN 12387 ELSE population END WHERE id IN (123636);

UPDATE cities SET population = CASE id WHEN 116672 THEN 12353 ELSE population END WHERE id IN (116672);

UPDATE cities SET population = CASE id WHEN 122415 THEN 12330 ELSE population END WHERE id IN (122415);

UPDATE cities SET population = CASE id WHEN 117796 THEN 12322 ELSE population END WHERE id IN (117796);

UPDATE cities SET population = CASE id WHEN 117609 THEN 12262 ELSE population END WHERE id IN (117609);

UPDATE cities SET population = CASE id WHEN 119099 THEN 12222 ELSE population END WHERE id IN (119099);

UPDATE cities SET population = CASE id WHEN 114148 THEN 12215 ELSE population END WHERE id IN (114148);

UPDATE cities SET population = CASE id WHEN 119607 THEN 12201 ELSE population END WHERE id IN (119607);

UPDATE cities SET population = CASE id WHEN 118735 THEN 12158 ELSE population END WHERE id IN (118735);

UPDATE cities SET population = CASE id WHEN 128717 THEN 12126 ELSE population END WHERE id IN (128717);

UPDATE cities SET population = CASE id WHEN 120876 THEN 12119 ELSE population END WHERE id IN (120876);

UPDATE cities SET population = CASE id WHEN 129540 THEN 12080 ELSE population END WHERE id IN (129540);

UPDATE cities SET population = CASE id WHEN 113829 THEN 12059 ELSE population END WHERE id IN (113829);

UPDATE cities SET population = CASE id WHEN 126518 THEN 12022 ELSE population END WHERE id IN (126518);

UPDATE cities SET population = CASE id WHEN 129718 THEN 11961 ELSE population END WHERE id IN (129718);

UPDATE cities SET population = CASE id WHEN 118556 THEN 11943 ELSE population END WHERE id IN (118556);

UPDATE cities SET population = CASE id WHEN 120320 THEN 11936 ELSE population END WHERE id IN (120320);

UPDATE cities SET population = CASE id WHEN 125104 THEN 11935 ELSE population END WHERE id IN (125104);

UPDATE cities SET population = CASE id WHEN 124473 THEN 11794 ELSE population END WHERE id IN (124473);

UPDATE cities SET population = CASE id WHEN 112769 THEN 11786 ELSE population END WHERE id IN (112769);

UPDATE cities SET population = CASE id WHEN 120125 THEN 11767 ELSE population END WHERE id IN (120125);

UPDATE cities SET population = CASE id WHEN 113500 THEN 11718 WHEN 115419 THEN 11718 ELSE population END WHERE id IN (113500,115419);

UPDATE cities SET population = CASE id WHEN 121348 THEN 11690 ELSE population END WHERE id IN (121348);

UPDATE cities SET population = CASE id WHEN 121035 THEN 11669 ELSE population END WHERE id IN (121035);

UPDATE cities SET population = CASE id WHEN 121741 THEN 11660 ELSE population END WHERE id IN (121741);

UPDATE cities SET population = CASE id WHEN 120455 THEN 11626 ELSE population END WHERE id IN (120455);

UPDATE cities SET population = CASE id WHEN 128257 THEN 11569 ELSE population END WHERE id IN (128257);

UPDATE cities SET population = CASE id WHEN 117758 THEN 11528 ELSE population END WHERE id IN (117758);

UPDATE cities SET population = CASE id WHEN 113139 THEN 11509 ELSE population END WHERE id IN (113139);

UPDATE cities SET population = CASE id WHEN 120419 THEN 11480 ELSE population END WHERE id IN (120419);

UPDATE cities SET population = CASE id WHEN 126534 THEN 11319 ELSE population END WHERE id IN (126534);

UPDATE cities SET population = CASE id WHEN 121020 THEN 11285 ELSE population END WHERE id IN (121020);

UPDATE cities SET population = CASE id WHEN 120708 THEN 11248 ELSE population END WHERE id IN (120708);

UPDATE cities SET population = CASE id WHEN 111967 THEN 11214 ELSE population END WHERE id IN (111967);

UPDATE cities SET population = CASE id WHEN 123512 THEN 11210 ELSE population END WHERE id IN (123512);

UPDATE cities SET population = CASE id WHEN 125708 THEN 11196 ELSE population END WHERE id IN (125708);

UPDATE cities SET population = CASE id WHEN 120129 THEN 11136 ELSE population END WHERE id IN (120129);

UPDATE cities SET population = CASE id WHEN 128730 THEN 11116 ELSE population END WHERE id IN (128730);

UPDATE cities SET population = CASE id WHEN 127759 THEN 11106 ELSE population END WHERE id IN (127759);

UPDATE cities SET population = CASE id WHEN 116890 THEN 11094 ELSE population END WHERE id IN (116890);

UPDATE cities SET population = CASE id WHEN 120337 THEN 11064 ELSE population END WHERE id IN (120337);

UPDATE cities SET population = CASE id WHEN 125594 THEN 11044 ELSE population END WHERE id IN (125594);

UPDATE cities SET population = CASE id WHEN 120723 THEN 11037 ELSE population END WHERE id IN (120723);

UPDATE cities SET population = CASE id WHEN 121891 THEN 11027 ELSE population END WHERE id IN (121891);

UPDATE cities SET population = CASE id WHEN 122004 THEN 10967 ELSE population END WHERE id IN (122004);

UPDATE cities SET population = CASE id WHEN 121335 THEN 10959 ELSE population END WHERE id IN (121335);

UPDATE cities SET population = CASE id WHEN 116309 THEN 10907 WHEN 127824 THEN 10907 ELSE population END WHERE id IN (116309,127824);

UPDATE cities SET population = CASE id WHEN 127202 THEN 10861 ELSE population END WHERE id IN (127202);

UPDATE cities SET population = CASE id WHEN 122348 THEN 10804 ELSE population END WHERE id IN (122348);

UPDATE cities SET population = CASE id WHEN 118517 THEN 10791 ELSE population END WHERE id IN (118517);

UPDATE cities SET population = CASE id WHEN 118561 THEN 10719 ELSE population END WHERE id IN (118561);

UPDATE cities SET population = CASE id WHEN 112517 THEN 10714 ELSE population END WHERE id IN (112517);

UPDATE cities SET population = CASE id WHEN 111883 THEN 10713 ELSE population END WHERE id IN (111883);

UPDATE cities SET population = CASE id WHEN 128227 THEN 10679 ELSE population END WHERE id IN (128227);

UPDATE cities SET population = CASE id WHEN 117370 THEN 10678 ELSE population END WHERE id IN (117370);

UPDATE cities SET population = CASE id WHEN 111892 THEN 10668 ELSE population END WHERE id IN (111892);

UPDATE cities SET population = CASE id WHEN 126055 THEN 10631 ELSE population END WHERE id IN (126055);

UPDATE cities SET population = CASE id WHEN 125399 THEN 10565 ELSE population END WHERE id IN (125399);

UPDATE cities SET population = CASE id WHEN 116803 THEN 10518 ELSE population END WHERE id IN (116803);

UPDATE cities SET population = CASE id WHEN 126111 THEN 10497 ELSE population END WHERE id IN (126111);

UPDATE cities SET population = CASE id WHEN 113063 THEN 10436 ELSE population END WHERE id IN (113063);

UPDATE cities SET population = CASE id WHEN 117624 THEN 10401 ELSE population END WHERE id IN (117624);

UPDATE cities SET population = CASE id WHEN 112323 THEN 10368 ELSE population END WHERE id IN (112323);

UPDATE cities SET population = CASE id WHEN 116229 THEN 10310 ELSE population END WHERE id IN (116229);

UPDATE cities SET population = CASE id WHEN 129488 THEN 10294 ELSE population END WHERE id IN (129488);

UPDATE cities SET population = CASE id WHEN 124366 THEN 10260 ELSE population END WHERE id IN (124366);

UPDATE cities SET population = CASE id WHEN 121846 THEN 10252 ELSE population END WHERE id IN (121846);

UPDATE cities SET population = CASE id WHEN 128611 THEN 10236 ELSE population END WHERE id IN (128611);

UPDATE cities SET population = CASE id WHEN 128630 THEN 10214 ELSE population END WHERE id IN (128630);

UPDATE cities SET population = CASE id WHEN 128075 THEN 10208 ELSE population END WHERE id IN (128075);

UPDATE cities SET population = CASE id WHEN 119218 THEN 10180 ELSE population END WHERE id IN (119218);

UPDATE cities SET population = CASE id WHEN 116669 THEN 10162 ELSE population END WHERE id IN (116669);

UPDATE cities SET population = CASE id WHEN 123189 THEN 10135 ELSE population END WHERE id IN (123189);

UPDATE cities SET population = CASE id WHEN 123891 THEN 10090 ELSE population END WHERE id IN (123891);

UPDATE cities SET population = CASE id WHEN 121436 THEN 10080 ELSE population END WHERE id IN (121436);

UPDATE cities SET population = CASE id WHEN 114725 THEN 10072 ELSE population END WHERE id IN (114725);

UPDATE cities SET population = CASE id WHEN 129506 THEN 10020 ELSE population END WHERE id IN (129506);

UPDATE cities SET population = CASE id WHEN 120068 THEN 9953 ELSE population END WHERE id IN (120068);

UPDATE cities SET population = CASE id WHEN 124095 THEN 9952 ELSE population END WHERE id IN (124095);

UPDATE cities SET population = CASE id WHEN 118925 THEN 9943 ELSE population END WHERE id IN (118925);

UPDATE cities SET population = CASE id WHEN 119944 THEN 9916 ELSE population END WHERE id IN (119944);

UPDATE cities SET population = CASE id WHEN 118642 THEN 9891 ELSE population END WHERE id IN (118642);

UPDATE cities SET population = CASE id WHEN 111321 THEN 9877 ELSE population END WHERE id IN (111321);

UPDATE cities SET population = CASE id WHEN 121782 THEN 9859 ELSE population END WHERE id IN (121782);

UPDATE cities SET population = CASE id WHEN 125542 THEN 9847 ELSE population END WHERE id IN (125542);

UPDATE cities SET population = CASE id WHEN 113273 THEN 9836 ELSE population END WHERE id IN (113273);

UPDATE cities SET population = CASE id WHEN 122158 THEN 9820 ELSE population END WHERE id IN (122158);

UPDATE cities SET population = CASE id WHEN 128711 THEN 9809 ELSE population END WHERE id IN (128711);

UPDATE cities SET population = CASE id WHEN 125034 THEN 9766 ELSE population END WHERE id IN (125034);

UPDATE cities SET population = CASE id WHEN 113169 THEN 9752 ELSE population END WHERE id IN (113169);

UPDATE cities SET population = CASE id WHEN 112490 THEN 9688 ELSE population END WHERE id IN (112490);

UPDATE cities SET population = CASE id WHEN 114165 THEN 9655 ELSE population END WHERE id IN (114165);

UPDATE cities SET population = CASE id WHEN 119239 THEN 9633 ELSE population END WHERE id IN (119239);

UPDATE cities SET population = CASE id WHEN 122209 THEN 9623 ELSE population END WHERE id IN (122209);

UPDATE cities SET population = CASE id WHEN 124936 THEN 9617 ELSE population END WHERE id IN (124936);

UPDATE cities SET population = CASE id WHEN 119785 THEN 9609 ELSE population END WHERE id IN (119785);

UPDATE cities SET population = CASE id WHEN 117197 THEN 9590 ELSE population END WHERE id IN (117197);

UPDATE cities SET population = CASE id WHEN 121979 THEN 9491 ELSE population END WHERE id IN (121979);

UPDATE cities SET population = CASE id WHEN 113953 THEN 9487 ELSE population END WHERE id IN (113953);

UPDATE cities SET population = CASE id WHEN 128097 THEN 9464 ELSE population END WHERE id IN (128097);

UPDATE cities SET population = CASE id WHEN 126889 THEN 9442 ELSE population END WHERE id IN (126889);

UPDATE cities SET population = CASE id WHEN 122820 THEN 9438 ELSE population END WHERE id IN (122820);

UPDATE cities SET population = CASE id WHEN 114152 THEN 9433 ELSE population END WHERE id IN (114152);

UPDATE cities SET population = CASE id WHEN 119407 THEN 9423 ELSE population END WHERE id IN (119407);

UPDATE cities SET population = CASE id WHEN 127590 THEN 9358 ELSE population END WHERE id IN (127590);

UPDATE cities SET population = CASE id WHEN 129499 THEN 9355 ELSE population END WHERE id IN (129499);

UPDATE cities SET population = CASE id WHEN 112387 THEN 9354 ELSE population END WHERE id IN (112387);

UPDATE cities SET population = CASE id WHEN 122042 THEN 9291 ELSE population END WHERE id IN (122042);

UPDATE cities SET population = CASE id WHEN 116034 THEN 9284 ELSE population END WHERE id IN (116034);

UPDATE cities SET population = CASE id WHEN 116271 THEN 9242 ELSE population END WHERE id IN (116271);

UPDATE cities SET population = CASE id WHEN 117749 THEN 9221 ELSE population END WHERE id IN (117749);

UPDATE cities SET population = CASE id WHEN 125303 THEN 9220 ELSE population END WHERE id IN (125303);

UPDATE cities SET population = CASE id WHEN 128347 THEN 9212 ELSE population END WHERE id IN (128347);

UPDATE cities SET population = CASE id WHEN 118108 THEN 9194 ELSE population END WHERE id IN (118108);

UPDATE cities SET population = CASE id WHEN 118410 THEN 9189 ELSE population END WHERE id IN (118410);

UPDATE cities SET population = CASE id WHEN 128060 THEN 9175 ELSE population END WHERE id IN (128060);

UPDATE cities SET population = CASE id WHEN 120206 THEN 9166 ELSE population END WHERE id IN (120206);

UPDATE cities SET population = CASE id WHEN 119773 THEN 9125 ELSE population END WHERE id IN (119773);

UPDATE cities SET population = CASE id WHEN 126259 THEN 9108 ELSE population END WHERE id IN (126259);

UPDATE cities SET population = CASE id WHEN 112221 THEN 9073 ELSE population END WHERE id IN (112221);

UPDATE cities SET population = CASE id WHEN 118332 THEN 9054 ELSE population END WHERE id IN (118332);

UPDATE cities SET population = CASE id WHEN 129432 THEN 9050 ELSE population END WHERE id IN (129432);

UPDATE cities SET population = CASE id WHEN 127583 THEN 9032 WHEN 141454 THEN 9032 ELSE population END WHERE id IN (127583,141454);

UPDATE cities SET population = CASE id WHEN 121287 THEN 9031 ELSE population END WHERE id IN (121287);

UPDATE cities SET population = CASE id WHEN 111149 THEN 9009 ELSE population END WHERE id IN (111149);

UPDATE cities SET population = CASE id WHEN 123455 THEN 9005 ELSE population END WHERE id IN (123455);

UPDATE cities SET population = CASE id WHEN 117054 THEN 8999 ELSE population END WHERE id IN (117054);

UPDATE cities SET population = CASE id WHEN 127088 THEN 8962 ELSE population END WHERE id IN (127088);

UPDATE cities SET population = CASE id WHEN 118889 THEN 8958 ELSE population END WHERE id IN (118889);

UPDATE cities SET population = CASE id WHEN 114475 THEN 8857 ELSE population END WHERE id IN (114475);

UPDATE cities SET population = CASE id WHEN 114755 THEN 8844 ELSE population END WHERE id IN (114755);

UPDATE cities SET population = CASE id WHEN 117102 THEN 8823 ELSE population END WHERE id IN (117102);

UPDATE cities SET population = CASE id WHEN 115222 THEN 8791 ELSE population END WHERE id IN (115222);

UPDATE cities SET population = CASE id WHEN 116825 THEN 8787 ELSE population END WHERE id IN (116825);

UPDATE cities SET population = CASE id WHEN 129578 THEN 8777 ELSE population END WHERE id IN (129578);

UPDATE cities SET population = CASE id WHEN 121565 THEN 8769 ELSE population END WHERE id IN (121565);

UPDATE cities SET population = CASE id WHEN 121184 THEN 8750 ELSE population END WHERE id IN (121184);

UPDATE cities SET population = CASE id WHEN 111638 THEN 8730 ELSE population END WHERE id IN (111638);

UPDATE cities SET population = CASE id WHEN 126557 THEN 8722 ELSE population END WHERE id IN (126557);

UPDATE cities SET population = CASE id WHEN 121667 THEN 8720 ELSE population END WHERE id IN (121667);

UPDATE cities SET population = CASE id WHEN 122484 THEN 8690 ELSE population END WHERE id IN (122484);

UPDATE cities SET population = CASE id WHEN 114114 THEN 8676 ELSE population END WHERE id IN (114114);

UPDATE cities SET population = CASE id WHEN 115844 THEN 8669 ELSE population END WHERE id IN (115844);

UPDATE cities SET population = CASE id WHEN 120617 THEN 8649 ELSE population END WHERE id IN (120617);

UPDATE cities SET population = CASE id WHEN 111340 THEN 8644 ELSE population END WHERE id IN (111340);

UPDATE cities SET population = CASE id WHEN 119749 THEN 8619 ELSE population END WHERE id IN (119749);

UPDATE cities SET population = CASE id WHEN 127594 THEN 8577 ELSE population END WHERE id IN (127594);

UPDATE cities SET population = CASE id WHEN 126786 THEN 8572 ELSE population END WHERE id IN (126786);

UPDATE cities SET population = CASE id WHEN 120833 THEN 8549 ELSE population END WHERE id IN (120833);

UPDATE cities SET population = CASE id WHEN 114716 THEN 8545 ELSE population END WHERE id IN (114716);

UPDATE cities SET population = CASE id WHEN 125102 THEN 8541 ELSE population END WHERE id IN (125102);

UPDATE cities SET population = CASE id WHEN 119959 THEN 8538 ELSE population END WHERE id IN (119959);

UPDATE cities SET population = CASE id WHEN 127914 THEN 8474 ELSE population END WHERE id IN (127914);

UPDATE cities SET population = CASE id WHEN 125453 THEN 8453 ELSE population END WHERE id IN (125453);

UPDATE cities SET population = CASE id WHEN 112303 THEN 8445 ELSE population END WHERE id IN (112303);

UPDATE cities SET population = CASE id WHEN 120122 THEN 8409 ELSE population END WHERE id IN (120122);

UPDATE cities SET population = CASE id WHEN 117123 THEN 8401 ELSE population END WHERE id IN (117123);

UPDATE cities SET population = CASE id WHEN 119284 THEN 8345 ELSE population END WHERE id IN (119284);

UPDATE cities SET population = CASE id WHEN 113615 THEN 8300 ELSE population END WHERE id IN (113615);

UPDATE cities SET population = CASE id WHEN 124368 THEN 8289 ELSE population END WHERE id IN (124368);

UPDATE cities SET population = CASE id WHEN 122648 THEN 8253 ELSE population END WHERE id IN (122648);

UPDATE cities SET population = CASE id WHEN 116001 THEN 8251 ELSE population END WHERE id IN (116001);

UPDATE cities SET population = CASE id WHEN 125601 THEN 8226 ELSE population END WHERE id IN (125601);

UPDATE cities SET population = CASE id WHEN 116285 THEN 8225 ELSE population END WHERE id IN (116285);

UPDATE cities SET population = CASE id WHEN 118222 THEN 8211 ELSE population END WHERE id IN (118222);

UPDATE cities SET population = CASE id WHEN 121499 THEN 8209 ELSE population END WHERE id IN (121499);

UPDATE cities SET population = CASE id WHEN 114814 THEN 8191 ELSE population END WHERE id IN (114814);

UPDATE cities SET population = CASE id WHEN 129174 THEN 8189 ELSE population END WHERE id IN (129174);

UPDATE cities SET population = CASE id WHEN 117617 THEN 8166 ELSE population END WHERE id IN (117617);

UPDATE cities SET population = CASE id WHEN 112031 THEN 8165 ELSE population END WHERE id IN (112031);

UPDATE cities SET population = CASE id WHEN 118463 THEN 8155 ELSE population END WHERE id IN (118463);

UPDATE cities SET population = CASE id WHEN 116299 THEN 8148 ELSE population END WHERE id IN (116299);

UPDATE cities SET population = CASE id WHEN 110984 THEN 8119 WHEN 122659 THEN 8119 ELSE population END WHERE id IN (110984,122659);

UPDATE cities SET population = CASE id WHEN 113770 THEN 8088 ELSE population END WHERE id IN (113770);

UPDATE cities SET population = CASE id WHEN 112727 THEN 8057 ELSE population END WHERE id IN (112727);

UPDATE cities SET population = CASE id WHEN 122179 THEN 7993 ELSE population END WHERE id IN (122179);

UPDATE cities SET population = CASE id WHEN 115307 THEN 7992 ELSE population END WHERE id IN (115307);

UPDATE cities SET population = CASE id WHEN 123234 THEN 7989 ELSE population END WHERE id IN (123234);

UPDATE cities SET population = CASE id WHEN 126628 THEN 7976 ELSE population END WHERE id IN (126628);

UPDATE cities SET population = CASE id WHEN 112409 THEN 7975 WHEN 128876 THEN 7975 ELSE population END WHERE id IN (112409,128876);

UPDATE cities SET population = CASE id WHEN 118689 THEN 7970 ELSE population END WHERE id IN (118689);

UPDATE cities SET population = CASE id WHEN 116787 THEN 7945 WHEN 121177 THEN 7945 ELSE population END WHERE id IN (116787,121177);

UPDATE cities SET population = CASE id WHEN 116363 THEN 7905 ELSE population END WHERE id IN (116363);

UPDATE cities SET population = CASE id WHEN 121363 THEN 7902 ELSE population END WHERE id IN (121363);

UPDATE cities SET population = CASE id WHEN 114931 THEN 7867 ELSE population END WHERE id IN (114931);

UPDATE cities SET population = CASE id WHEN 112890 THEN 7854 WHEN 114806 THEN 7854 ELSE population END WHERE id IN (112890,114806);

UPDATE cities SET population = CASE id WHEN 111420 THEN 7851 ELSE population END WHERE id IN (111420);

UPDATE cities SET population = CASE id WHEN 121638 THEN 7848 ELSE population END WHERE id IN (121638);

UPDATE cities SET population = CASE id WHEN 117680 THEN 7845 ELSE population END WHERE id IN (117680);

UPDATE cities SET population = CASE id WHEN 124795 THEN 7830 ELSE population END WHERE id IN (124795);

UPDATE cities SET population = CASE id WHEN 118104 THEN 7826 ELSE population END WHERE id IN (118104);

UPDATE cities SET population = CASE id WHEN 129428 THEN 7794 ELSE population END WHERE id IN (129428);

UPDATE cities SET population = CASE id WHEN 125891 THEN 7747 ELSE population END WHERE id IN (125891);

UPDATE cities SET population = CASE id WHEN 120933 THEN 7713 ELSE population END WHERE id IN (120933);

UPDATE cities SET population = CASE id WHEN 129430 THEN 7712 ELSE population END WHERE id IN (129430);

UPDATE cities SET population = CASE id WHEN 123270 THEN 7710 ELSE population END WHERE id IN (123270);

UPDATE cities SET population = CASE id WHEN 112755 THEN 7706 ELSE population END WHERE id IN (112755);

UPDATE cities SET population = CASE id WHEN 125167 THEN 7700 ELSE population END WHERE id IN (125167);

UPDATE cities SET population = CASE id WHEN 125664 THEN 7690 ELSE population END WHERE id IN (125664);

UPDATE cities SET population = CASE id WHEN 129524 THEN 7654 ELSE population END WHERE id IN (129524);

UPDATE cities SET population = CASE id WHEN 129265 THEN 7646 ELSE population END WHERE id IN (129265);

UPDATE cities SET population = CASE id WHEN 125119 THEN 7645 ELSE population END WHERE id IN (125119);

UPDATE cities SET population = CASE id WHEN 125253 THEN 7631 ELSE population END WHERE id IN (125253);

UPDATE cities SET population = CASE id WHEN 122225 THEN 7622 ELSE population END WHERE id IN (122225);

UPDATE cities SET population = CASE id WHEN 123837 THEN 7618 ELSE population END WHERE id IN (123837);

UPDATE cities SET population = CASE id WHEN 124733 THEN 7617 ELSE population END WHERE id IN (124733);

UPDATE cities SET population = CASE id WHEN 117179 THEN 7608 ELSE population END WHERE id IN (117179);

UPDATE cities SET population = CASE id WHEN 115487 THEN 7597 ELSE population END WHERE id IN (115487);

UPDATE cities SET population = CASE id WHEN 114209 THEN 7590 ELSE population END WHERE id IN (114209);

UPDATE cities SET population = CASE id WHEN 121138 THEN 7587 ELSE population END WHERE id IN (121138);

UPDATE cities SET population = CASE id WHEN 126085 THEN 7586 ELSE population END WHERE id IN (126085);

UPDATE cities SET population = CASE id WHEN 116564 THEN 7582 ELSE population END WHERE id IN (116564);

UPDATE cities SET population = CASE id WHEN 113652 THEN 7575 ELSE population END WHERE id IN (113652);

UPDATE cities SET population = CASE id WHEN 129703 THEN 7541 ELSE population END WHERE id IN (129703);

UPDATE cities SET population = CASE id WHEN 111619 THEN 7524 ELSE population END WHERE id IN (111619);

UPDATE cities SET population = CASE id WHEN 118417 THEN 7522 ELSE population END WHERE id IN (118417);

UPDATE cities SET population = CASE id WHEN 121631 THEN 7492 ELSE population END WHERE id IN (121631);

UPDATE cities SET population = CASE id WHEN 121505 THEN 7406 ELSE population END WHERE id IN (121505);

UPDATE cities SET population = CASE id WHEN 124125 THEN 7391 ELSE population END WHERE id IN (124125);

UPDATE cities SET population = CASE id WHEN 114372 THEN 7388 ELSE population END WHERE id IN (114372);

UPDATE cities SET population = CASE id WHEN 125876 THEN 7366 ELSE population END WHERE id IN (125876);

UPDATE cities SET population = CASE id WHEN 122289 THEN 7338 ELSE population END WHERE id IN (122289);

UPDATE cities SET population = CASE id WHEN 125198 THEN 7305 ELSE population END WHERE id IN (125198);

UPDATE cities SET population = CASE id WHEN 122697 THEN 7295 ELSE population END WHERE id IN (122697);

UPDATE cities SET population = CASE id WHEN 116695 THEN 7289 ELSE population END WHERE id IN (116695);

UPDATE cities SET population = CASE id WHEN 118131 THEN 7284 ELSE population END WHERE id IN (118131);

UPDATE cities SET population = CASE id WHEN 123358 THEN 7267 ELSE population END WHERE id IN (123358);

UPDATE cities SET population = CASE id WHEN 127130 THEN 7258 ELSE population END WHERE id IN (127130);

UPDATE cities SET population = CASE id WHEN 126527 THEN 7242 ELSE population END WHERE id IN (126527);

UPDATE cities SET population = CASE id WHEN 125308 THEN 7237 ELSE population END WHERE id IN (125308);

UPDATE cities SET population = CASE id WHEN 123597 THEN 7233 ELSE population END WHERE id IN (123597);

UPDATE cities SET population = CASE id WHEN 128099 THEN 7222 ELSE population END WHERE id IN (128099);

UPDATE cities SET population = CASE id WHEN 125633 THEN 7218 ELSE population END WHERE id IN (125633);

UPDATE cities SET population = CASE id WHEN 120380 THEN 7214 ELSE population END WHERE id IN (120380);

UPDATE cities SET population = CASE id WHEN 121656 THEN 7204 ELSE population END WHERE id IN (121656);

UPDATE cities SET population = CASE id WHEN 127949 THEN 7194 ELSE population END WHERE id IN (127949);

UPDATE cities SET population = CASE id WHEN 118406 THEN 7183 ELSE population END WHERE id IN (118406);

UPDATE cities SET population = CASE id WHEN 119799 THEN 7173 WHEN 126773 THEN 7173 ELSE population END WHERE id IN (119799,126773);

UPDATE cities SET population = CASE id WHEN 126186 THEN 7167 ELSE population END WHERE id IN (126186);

UPDATE cities SET population = CASE id WHEN 123706 THEN 7161 ELSE population END WHERE id IN (123706);

UPDATE cities SET population = CASE id WHEN 121024 THEN 7144 ELSE population END WHERE id IN (121024);

UPDATE cities SET population = CASE id WHEN 121325 THEN 7138 ELSE population END WHERE id IN (121325);

UPDATE cities SET population = CASE id WHEN 119237 THEN 7137 ELSE population END WHERE id IN (119237);

UPDATE cities SET population = CASE id WHEN 121160 THEN 7135 ELSE population END WHERE id IN (121160);

UPDATE cities SET population = CASE id WHEN 124457 THEN 7124 ELSE population END WHERE id IN (124457);

UPDATE cities SET population = CASE id WHEN 128145 THEN 7112 ELSE population END WHERE id IN (128145);

UPDATE cities SET population = CASE id WHEN 118269 THEN 7110 ELSE population END WHERE id IN (118269);

UPDATE cities SET population = CASE id WHEN 119576 THEN 7059 ELSE population END WHERE id IN (119576);

UPDATE cities SET population = CASE id WHEN 124067 THEN 7055 ELSE population END WHERE id IN (124067);

UPDATE cities SET population = CASE id WHEN 125971 THEN 7054 ELSE population END WHERE id IN (125971);

UPDATE cities SET population = CASE id WHEN 117155 THEN 7051 ELSE population END WHERE id IN (117155);

UPDATE cities SET population = CASE id WHEN 122335 THEN 7027 ELSE population END WHERE id IN (122335);

UPDATE cities SET population = CASE id WHEN 127122 THEN 7013 ELSE population END WHERE id IN (127122);

UPDATE cities SET population = CASE id WHEN 124198 THEN 7012 ELSE population END WHERE id IN (124198);

UPDATE cities SET population = CASE id WHEN 115606 THEN 7003 ELSE population END WHERE id IN (115606);

UPDATE cities SET population = CASE id WHEN 113096 THEN 6976 ELSE population END WHERE id IN (113096);

UPDATE cities SET population = CASE id WHEN 121771 THEN 6974 ELSE population END WHERE id IN (121771);

UPDATE cities SET population = CASE id WHEN 120592 THEN 6973 ELSE population END WHERE id IN (120592);

UPDATE cities SET population = CASE id WHEN 116905 THEN 6969 ELSE population END WHERE id IN (116905);

UPDATE cities SET population = CASE id WHEN 113280 THEN 6963 ELSE population END WHERE id IN (113280);

UPDATE cities SET population = CASE id WHEN 116217 THEN 6944 ELSE population END WHERE id IN (116217);

UPDATE cities SET population = CASE id WHEN 114448 THEN 6934 ELSE population END WHERE id IN (114448);

UPDATE cities SET population = CASE id WHEN 120638 THEN 6931 ELSE population END WHERE id IN (120638);

UPDATE cities SET population = CASE id WHEN 125255 THEN 6918 WHEN 127504 THEN 6918 ELSE population END WHERE id IN (125255,127504);

UPDATE cities SET population = CASE id WHEN 111230 THEN 6911 ELSE population END WHERE id IN (111230);

UPDATE cities SET population = CASE id WHEN 120603 THEN 6897 ELSE population END WHERE id IN (120603);

UPDATE cities SET population = CASE id WHEN 117403 THEN 6882 ELSE population END WHERE id IN (117403);

UPDATE cities SET population = CASE id WHEN 128524 THEN 6823 ELSE population END WHERE id IN (128524);

UPDATE cities SET population = CASE id WHEN 111845 THEN 6817 ELSE population END WHERE id IN (111845);

UPDATE cities SET population = CASE id WHEN 127047 THEN 6803 ELSE population END WHERE id IN (127047);

UPDATE cities SET population = CASE id WHEN 117887 THEN 6772 ELSE population END WHERE id IN (117887);

UPDATE cities SET population = CASE id WHEN 116347 THEN 6769 ELSE population END WHERE id IN (116347);

UPDATE cities SET population = CASE id WHEN 114522 THEN 6762 ELSE population END WHERE id IN (114522);

UPDATE cities SET population = CASE id WHEN 121166 THEN 6742 ELSE population END WHERE id IN (121166);

UPDATE cities SET population = CASE id WHEN 114007 THEN 6719 ELSE population END WHERE id IN (114007);

UPDATE cities SET population = CASE id WHEN 128747 THEN 6705 ELSE population END WHERE id IN (128747);

UPDATE cities SET population = CASE id WHEN 116412 THEN 6701 ELSE population END WHERE id IN (116412);

UPDATE cities SET population = CASE id WHEN 112056 THEN 6682 ELSE population END WHERE id IN (112056);

UPDATE cities SET population = CASE id WHEN 115342 THEN 6677 ELSE population END WHERE id IN (115342);

UPDATE cities SET population = CASE id WHEN 117269 THEN 6655 ELSE population END WHERE id IN (117269);

UPDATE cities SET population = CASE id WHEN 127478 THEN 6630 ELSE population END WHERE id IN (127478);

UPDATE cities SET population = CASE id WHEN 111829 THEN 6625 ELSE population END WHERE id IN (111829);

UPDATE cities SET population = CASE id WHEN 123478 THEN 6615 ELSE population END WHERE id IN (123478);

UPDATE cities SET population = CASE id WHEN 129236 THEN 6590 ELSE population END WHERE id IN (129236);

UPDATE cities SET population = CASE id WHEN 110982 THEN 6558 ELSE population END WHERE id IN (110982);

UPDATE cities SET population = CASE id WHEN 114829 THEN 6554 ELSE population END WHERE id IN (114829);

UPDATE cities SET population = CASE id WHEN 117137 THEN 6538 ELSE population END WHERE id IN (117137);

UPDATE cities SET population = CASE id WHEN 120499 THEN 6524 ELSE population END WHERE id IN (120499);

UPDATE cities SET population = CASE id WHEN 122754 THEN 6523 ELSE population END WHERE id IN (122754);

UPDATE cities SET population = CASE id WHEN 118827 THEN 6493 ELSE population END WHERE id IN (118827);

UPDATE cities SET population = CASE id WHEN 121590 THEN 6483 ELSE population END WHERE id IN (121590);

UPDATE cities SET population = CASE id WHEN 124709 THEN 6481 ELSE population END WHERE id IN (124709);

UPDATE cities SET population = CASE id WHEN 124413 THEN 6438 ELSE population END WHERE id IN (124413);

UPDATE cities SET population = CASE id WHEN 118454 THEN 6415 ELSE population END WHERE id IN (118454);

UPDATE cities SET population = CASE id WHEN 118961 THEN 6403 ELSE population END WHERE id IN (118961);

UPDATE cities SET population = CASE id WHEN 117923 THEN 6359 ELSE population END WHERE id IN (117923);

UPDATE cities SET population = CASE id WHEN 112720 THEN 6355 ELSE population END WHERE id IN (112720);

UPDATE cities SET population = CASE id WHEN 112130 THEN 6352 ELSE population END WHERE id IN (112130);

UPDATE cities SET population = CASE id WHEN 123994 THEN 6346 ELSE population END WHERE id IN (123994);

UPDATE cities SET population = CASE id WHEN 117098 THEN 6344 ELSE population END WHERE id IN (117098);

UPDATE cities SET population = CASE id WHEN 129534 THEN 6334 ELSE population END WHERE id IN (129534);

UPDATE cities SET population = CASE id WHEN 120328 THEN 6333 ELSE population END WHERE id IN (120328);

UPDATE cities SET population = CASE id WHEN 128383 THEN 6318 ELSE population END WHERE id IN (128383);

UPDATE cities SET population = CASE id WHEN 128798 THEN 6285 ELSE population END WHERE id IN (128798);

UPDATE cities SET population = CASE id WHEN 115335 THEN 6283 ELSE population END WHERE id IN (115335);

UPDATE cities SET population = CASE id WHEN 126383 THEN 6254 ELSE population END WHERE id IN (126383);

UPDATE cities SET population = CASE id WHEN 115956 THEN 6232 ELSE population END WHERE id IN (115956);

UPDATE cities SET population = CASE id WHEN 118039 THEN 6224 ELSE population END WHERE id IN (118039);

UPDATE cities SET population = CASE id WHEN 119420 THEN 6181 ELSE population END WHERE id IN (119420);

UPDATE cities SET population = CASE id WHEN 112567 THEN 6180 ELSE population END WHERE id IN (112567);

UPDATE cities SET population = CASE id WHEN 117776 THEN 6177 ELSE population END WHERE id IN (117776);

UPDATE cities SET population = CASE id WHEN 114385 THEN 6170 ELSE population END WHERE id IN (114385);

UPDATE cities SET population = CASE id WHEN 115049 THEN 6155 ELSE population END WHERE id IN (115049);

UPDATE cities SET population = CASE id WHEN 116070 THEN 6146 ELSE population END WHERE id IN (116070);

UPDATE cities SET population = CASE id WHEN 120141 THEN 6132 ELSE population END WHERE id IN (120141);

UPDATE cities SET population = CASE id WHEN 122084 THEN 6110 ELSE population END WHERE id IN (122084);

UPDATE cities SET population = CASE id WHEN 123915 THEN 6106 ELSE population END WHERE id IN (123915);

UPDATE cities SET population = CASE id WHEN 125525 THEN 6077 ELSE population END WHERE id IN (125525);

UPDATE cities SET population = CASE id WHEN 117802 THEN 6076 WHEN 119315 THEN 6076 ELSE population END WHERE id IN (117802,119315);

UPDATE cities SET population = CASE id WHEN 115115 THEN 6074 ELSE population END WHERE id IN (115115);

UPDATE cities SET population = CASE id WHEN 127264 THEN 6044 ELSE population END WHERE id IN (127264);

UPDATE cities SET population = CASE id WHEN 114216 THEN 6030 ELSE population END WHERE id IN (114216);

UPDATE cities SET population = CASE id WHEN 116282 THEN 6029 ELSE population END WHERE id IN (116282);

UPDATE cities SET population = CASE id WHEN 123171 THEN 6010 ELSE population END WHERE id IN (123171);

UPDATE cities SET population = CASE id WHEN 125226 THEN 6005 WHEN 127112 THEN 6005 ELSE population END WHERE id IN (125226,127112);

UPDATE cities SET population = CASE id WHEN 116728 THEN 5975 ELSE population END WHERE id IN (116728);

UPDATE cities SET population = CASE id WHEN 113870 THEN 5974 ELSE population END WHERE id IN (113870);

UPDATE cities SET population = CASE id WHEN 120156 THEN 5971 ELSE population END WHERE id IN (120156);

UPDATE cities SET population = CASE id WHEN 118232 THEN 5929 ELSE population END WHERE id IN (118232);

UPDATE cities SET population = CASE id WHEN 117280 THEN 5927 WHEN 125023 THEN 5927 ELSE population END WHERE id IN (117280,125023);

UPDATE cities SET population = CASE id WHEN 112109 THEN 5892 WHEN 113666 THEN 5892 ELSE population END WHERE id IN (112109,113666);

UPDATE cities SET population = CASE id WHEN 112774 THEN 5889 ELSE population END WHERE id IN (112774);

UPDATE cities SET population = CASE id WHEN 115198 THEN 5875 ELSE population END WHERE id IN (115198);

UPDATE cities SET population = CASE id WHEN 112229 THEN 5849 ELSE population END WHERE id IN (112229);

UPDATE cities SET population = CASE id WHEN 112989 THEN 5837 ELSE population END WHERE id IN (112989);

UPDATE cities SET population = CASE id WHEN 113489 THEN 5818 ELSE population END WHERE id IN (113489);

UPDATE cities SET population = CASE id WHEN 128476 THEN 5804 ELSE population END WHERE id IN (128476);

UPDATE cities SET population = CASE id WHEN 126872 THEN 5795 WHEN 127971 THEN 5795 ELSE population END WHERE id IN (126872,127971);

UPDATE cities SET population = CASE id WHEN 112152 THEN 5792 ELSE population END WHERE id IN (112152);

UPDATE cities SET population = CASE id WHEN 120686 THEN 5790 ELSE population END WHERE id IN (120686);

UPDATE cities SET population = CASE id WHEN 128705 THEN 5704 ELSE population END WHERE id IN (128705);

UPDATE cities SET population = CASE id WHEN 116643 THEN 5695 ELSE population END WHERE id IN (116643);

UPDATE cities SET population = CASE id WHEN 125295 THEN 5609 ELSE population END WHERE id IN (125295);

UPDATE cities SET population = CASE id WHEN 128895 THEN 5592 ELSE population END WHERE id IN (128895);

UPDATE cities SET population = CASE id WHEN 112710 THEN 5590 ELSE population END WHERE id IN (112710);

UPDATE cities SET population = CASE id WHEN 129189 THEN 5589 ELSE population END WHERE id IN (129189);

UPDATE cities SET population = CASE id WHEN 111206 THEN 5575 ELSE population END WHERE id IN (111206);

UPDATE cities SET population = CASE id WHEN 122810 THEN 5564 ELSE population END WHERE id IN (122810);

UPDATE cities SET population = CASE id WHEN 114632 THEN 5552 ELSE population END WHERE id IN (114632);

UPDATE cities SET population = CASE id WHEN 123325 THEN 5550 ELSE population END WHERE id IN (123325);

UPDATE cities SET population = CASE id WHEN 119909 THEN 5522 ELSE population END WHERE id IN (119909);

UPDATE cities SET population = CASE id WHEN 111013 THEN 5515 ELSE population END WHERE id IN (111013);

UPDATE cities SET population = CASE id WHEN 114878 THEN 5514 ELSE population END WHERE id IN (114878);

UPDATE cities SET population = CASE id WHEN 113650 THEN 5508 WHEN 129282 THEN 5508 ELSE population END WHERE id IN (113650,129282);

UPDATE cities SET population = CASE id WHEN 126757 THEN 5481 ELSE population END WHERE id IN (126757);

UPDATE cities SET population = CASE id WHEN 111163 THEN 5470 WHEN 118966 THEN 5470 WHEN 127901 THEN 5470 ELSE population END WHERE id IN (111163,118966,127901);

UPDATE cities SET population = CASE id WHEN 114905 THEN 5467 ELSE population END WHERE id IN (114905);

UPDATE cities SET population = CASE id WHEN 129257 THEN 5454 ELSE population END WHERE id IN (129257);

UPDATE cities SET population = CASE id WHEN 123040 THEN 5444 ELSE population END WHERE id IN (123040);

UPDATE cities SET population = CASE id WHEN 115091 THEN 5433 ELSE population END WHERE id IN (115091);

UPDATE cities SET population = CASE id WHEN 125332 THEN 5425 ELSE population END WHERE id IN (125332);

UPDATE cities SET population = CASE id WHEN 127535 THEN 5387 ELSE population END WHERE id IN (127535);

UPDATE cities SET population = CASE id WHEN 122683 THEN 5382 ELSE population END WHERE id IN (122683);

UPDATE cities SET population = CASE id WHEN 121653 THEN 5378 ELSE population END WHERE id IN (121653);

UPDATE cities SET population = CASE id WHEN 112254 THEN 5371 ELSE population END WHERE id IN (112254);

UPDATE cities SET population = CASE id WHEN 126976 THEN 5365 ELSE population END WHERE id IN (126976);

UPDATE cities SET population = CASE id WHEN 125162 THEN 5357 ELSE population END WHERE id IN (125162);

UPDATE cities SET population = CASE id WHEN 111041 THEN 5316 ELSE population END WHERE id IN (111041);

UPDATE cities SET population = CASE id WHEN 124437 THEN 5314 ELSE population END WHERE id IN (124437);

UPDATE cities SET population = CASE id WHEN 117619 THEN 5296 ELSE population END WHERE id IN (117619);

UPDATE cities SET population = CASE id WHEN 120589 THEN 5284 ELSE population END WHERE id IN (120589);

UPDATE cities SET population = CASE id WHEN 126666 THEN 5282 ELSE population END WHERE id IN (126666);

UPDATE cities SET population = CASE id WHEN 112478 THEN 5279 ELSE population END WHERE id IN (112478);

UPDATE cities SET population = CASE id WHEN 125561 THEN 5277 ELSE population END WHERE id IN (125561);

UPDATE cities SET population = CASE id WHEN 117916 THEN 5261 ELSE population END WHERE id IN (117916);

UPDATE cities SET population = CASE id WHEN 123951 THEN 5242 ELSE population END WHERE id IN (123951);

UPDATE cities SET population = CASE id WHEN 118765 THEN 5224 ELSE population END WHERE id IN (118765);

UPDATE cities SET population = CASE id WHEN 114544 THEN 5218 ELSE population END WHERE id IN (114544);

UPDATE cities SET population = CASE id WHEN 116970 THEN 5215 ELSE population END WHERE id IN (116970);

UPDATE cities SET population = CASE id WHEN 113636 THEN 5211 ELSE population END WHERE id IN (113636);

UPDATE cities SET population = CASE id WHEN 123254 THEN 5209 ELSE population END WHERE id IN (123254);

UPDATE cities SET population = CASE id WHEN 117147 THEN 5196 ELSE population END WHERE id IN (117147);

UPDATE cities SET population = CASE id WHEN 124627 THEN 5186 ELSE population END WHERE id IN (124627);

UPDATE cities SET population = CASE id WHEN 129139 THEN 5180 ELSE population END WHERE id IN (129139);

UPDATE cities SET population = CASE id WHEN 117276 THEN 5153 WHEN 127262 THEN 5153 ELSE population END WHERE id IN (117276,127262);

UPDATE cities SET population = CASE id WHEN 117428 THEN 5148 ELSE population END WHERE id IN (117428);

UPDATE cities SET population = CASE id WHEN 114983 THEN 5141 ELSE population END WHERE id IN (114983);

UPDATE cities SET population = CASE id WHEN 115542 THEN 5108 ELSE population END WHERE id IN (115542);

UPDATE cities SET population = CASE id WHEN 113143 THEN 5105 ELSE population END WHERE id IN (113143);

UPDATE cities SET population = CASE id WHEN 126705 THEN 5081 ELSE population END WHERE id IN (126705);

UPDATE cities SET population = CASE id WHEN 123101 THEN 5077 ELSE population END WHERE id IN (123101);

UPDATE cities SET population = CASE id WHEN 112234 THEN 5065 ELSE population END WHERE id IN (112234);

UPDATE cities SET population = CASE id WHEN 116656 THEN 5039 ELSE population END WHERE id IN (116656);

UPDATE cities SET population = CASE id WHEN 128120 THEN 5023 ELSE population END WHERE id IN (128120);

UPDATE cities SET population = CASE id WHEN 126838 THEN 5018 WHEN 127000 THEN 5018 ELSE population END WHERE id IN (126838,127000);

UPDATE cities SET population = CASE id WHEN 115215 THEN 5011 ELSE population END WHERE id IN (115215);

UPDATE cities SET population = CASE id WHEN 115776 THEN 5000 ELSE population END WHERE id IN (115776);

UPDATE cities SET population = CASE id WHEN 126613 THEN 4994 ELSE population END WHERE id IN (126613);

UPDATE cities SET population = CASE id WHEN 122951 THEN 4978 ELSE population END WHERE id IN (122951);

UPDATE cities SET population = CASE id WHEN 119060 THEN 4967 ELSE population END WHERE id IN (119060);

UPDATE cities SET population = CASE id WHEN 120240 THEN 4960 ELSE population END WHERE id IN (120240);

UPDATE cities SET population = CASE id WHEN 111698 THEN 4954 ELSE population END WHERE id IN (111698);

UPDATE cities SET population = CASE id WHEN 116570 THEN 4944 ELSE population END WHERE id IN (116570);

UPDATE cities SET population = CASE id WHEN 124346 THEN 4919 ELSE population END WHERE id IN (124346);

UPDATE cities SET population = CASE id WHEN 112725 THEN 4898 ELSE population END WHERE id IN (112725);

UPDATE cities SET population = CASE id WHEN 124705 THEN 4881 ELSE population END WHERE id IN (124705);

UPDATE cities SET population = CASE id WHEN 124551 THEN 4879 ELSE population END WHERE id IN (124551);

UPDATE cities SET population = CASE id WHEN 117833 THEN 4877 ELSE population END WHERE id IN (117833);

UPDATE cities SET population = CASE id WHEN 112849 THEN 4873 ELSE population END WHERE id IN (112849);

UPDATE cities SET population = CASE id WHEN 129196 THEN 4872 ELSE population END WHERE id IN (129196);

UPDATE cities SET population = CASE id WHEN 112414 THEN 4871 WHEN 120756 THEN 4871 ELSE population END WHERE id IN (112414,120756);

UPDATE cities SET population = CASE id WHEN 112119 THEN 4854 ELSE population END WHERE id IN (112119);

UPDATE cities SET population = CASE id WHEN 114809 THEN 4847 WHEN 114875 THEN 4847 ELSE population END WHERE id IN (114809,114875);

UPDATE cities SET population = CASE id WHEN 120037 THEN 4839 ELSE population END WHERE id IN (120037);

UPDATE cities SET population = CASE id WHEN 114454 THEN 4832 ELSE population END WHERE id IN (114454);

UPDATE cities SET population = CASE id WHEN 126600 THEN 4818 ELSE population END WHERE id IN (126600);

UPDATE cities SET population = CASE id WHEN 126317 THEN 4812 ELSE population END WHERE id IN (126317);

UPDATE cities SET population = CASE id WHEN 125989 THEN 4773 ELSE population END WHERE id IN (125989);

UPDATE cities SET population = CASE id WHEN 112261 THEN 4765 ELSE population END WHERE id IN (112261);

UPDATE cities SET population = CASE id WHEN 129418 THEN 4762 ELSE population END WHERE id IN (129418);

UPDATE cities SET population = CASE id WHEN 116426 THEN 4758 ELSE population END WHERE id IN (116426);

UPDATE cities SET population = CASE id WHEN 117290 THEN 4750 ELSE population END WHERE id IN (117290);

UPDATE cities SET population = CASE id WHEN 125618 THEN 4724 ELSE population END WHERE id IN (125618);

UPDATE cities SET population = CASE id WHEN 117332 THEN 4719 ELSE population END WHERE id IN (117332);

UPDATE cities SET population = CASE id WHEN 124164 THEN 4714 ELSE population END WHERE id IN (124164);

UPDATE cities SET population = CASE id WHEN 118881 THEN 4709 ELSE population END WHERE id IN (118881);

UPDATE cities SET population = CASE id WHEN 122668 THEN 4688 ELSE population END WHERE id IN (122668);

UPDATE cities SET population = CASE id WHEN 116175 THEN 4679 ELSE population END WHERE id IN (116175);

UPDATE cities SET population = CASE id WHEN 112505 THEN 4674 ELSE population END WHERE id IN (112505);

UPDATE cities SET population = CASE id WHEN 117496 THEN 4662 ELSE population END WHERE id IN (117496);

UPDATE cities SET population = CASE id WHEN 111949 THEN 4652 WHEN 122113 THEN 4652 ELSE population END WHERE id IN (111949,122113);

UPDATE cities SET population = CASE id WHEN 125279 THEN 4646 ELSE population END WHERE id IN (125279);

UPDATE cities SET population = CASE id WHEN 114464 THEN 4644 ELSE population END WHERE id IN (114464);

UPDATE cities SET population = CASE id WHEN 116562 THEN 4641 ELSE population END WHERE id IN (116562);

UPDATE cities SET population = CASE id WHEN 116060 THEN 4635 ELSE population END WHERE id IN (116060);

UPDATE cities SET population = CASE id WHEN 121931 THEN 4625 ELSE population END WHERE id IN (121931);

UPDATE cities SET population = CASE id WHEN 129038 THEN 4615 ELSE population END WHERE id IN (129038);

UPDATE cities SET population = CASE id WHEN 126329 THEN 4605 ELSE population END WHERE id IN (126329);

UPDATE cities SET population = CASE id WHEN 123858 THEN 4603 ELSE population END WHERE id IN (123858);

UPDATE cities SET population = CASE id WHEN 117191 THEN 4571 ELSE population END WHERE id IN (117191);

UPDATE cities SET population = CASE id WHEN 129392 THEN 4570 ELSE population END WHERE id IN (129392);

UPDATE cities SET population = CASE id WHEN 120869 THEN 4551 ELSE population END WHERE id IN (120869);

UPDATE cities SET population = CASE id WHEN 126671 THEN 4527 ELSE population END WHERE id IN (126671);

UPDATE cities SET population = CASE id WHEN 126041 THEN 4526 ELSE population END WHERE id IN (126041);

UPDATE cities SET population = CASE id WHEN 118551 THEN 4499 ELSE population END WHERE id IN (118551);

UPDATE cities SET population = CASE id WHEN 127181 THEN 4494 ELSE population END WHERE id IN (127181);

UPDATE cities SET population = CASE id WHEN 116438 THEN 4490 ELSE population END WHERE id IN (116438);

UPDATE cities SET population = CASE id WHEN 124297 THEN 4485 ELSE population END WHERE id IN (124297);

UPDATE cities SET population = CASE id WHEN 118122 THEN 4480 ELSE population END WHERE id IN (118122);

UPDATE cities SET population = CASE id WHEN 122572 THEN 4479 ELSE population END WHERE id IN (122572);

UPDATE cities SET population = CASE id WHEN 121552 THEN 4476 ELSE population END WHERE id IN (121552);

UPDATE cities SET population = CASE id WHEN 120284 THEN 4467 ELSE population END WHERE id IN (120284);

UPDATE cities SET population = CASE id WHEN 117139 THEN 4460 ELSE population END WHERE id IN (117139);

UPDATE cities SET population = CASE id WHEN 127209 THEN 4452 ELSE population END WHERE id IN (127209);

UPDATE cities SET population = CASE id WHEN 112039 THEN 4450 ELSE population END WHERE id IN (112039);

UPDATE cities SET population = CASE id WHEN 129422 THEN 4439 ELSE population END WHERE id IN (129422);

UPDATE cities SET population = CASE id WHEN 117626 THEN 4431 ELSE population END WHERE id IN (117626);

UPDATE cities SET population = CASE id WHEN 126806 THEN 4419 ELSE population END WHERE id IN (126806);

UPDATE cities SET population = CASE id WHEN 120635 THEN 4412 WHEN 127352 THEN 4412 ELSE population END WHERE id IN (120635,127352);

UPDATE cities SET population = CASE id WHEN 119162 THEN 4411 WHEN 126064 THEN 4411 ELSE population END WHERE id IN (119162,126064);

UPDATE cities SET population = CASE id WHEN 120481 THEN 4405 ELSE population END WHERE id IN (120481);

UPDATE cities SET population = CASE id WHEN 113215 THEN 4396 ELSE population END WHERE id IN (113215);

UPDATE cities SET population = CASE id WHEN 114398 THEN 4393 ELSE population END WHERE id IN (114398);

UPDATE cities SET population = CASE id WHEN 115893 THEN 4390 ELSE population END WHERE id IN (115893);

UPDATE cities SET population = CASE id WHEN 120940 THEN 4375 ELSE population END WHERE id IN (120940);

UPDATE cities SET population = CASE id WHEN 125801 THEN 4368 ELSE population END WHERE id IN (125801);

UPDATE cities SET population = CASE id WHEN 112853 THEN 4358 ELSE population END WHERE id IN (112853);

UPDATE cities SET population = CASE id WHEN 123941 THEN 4357 ELSE population END WHERE id IN (123941);

UPDATE cities SET population = CASE id WHEN 115081 THEN 4353 ELSE population END WHERE id IN (115081);

UPDATE cities SET population = CASE id WHEN 113805 THEN 4351 ELSE population END WHERE id IN (113805);

UPDATE cities SET population = CASE id WHEN 115245 THEN 4349 ELSE population END WHERE id IN (115245);

UPDATE cities SET population = CASE id WHEN 118605 THEN 4342 ELSE population END WHERE id IN (118605);

UPDATE cities SET population = CASE id WHEN 124984 THEN 4338 ELSE population END WHERE id IN (124984);

UPDATE cities SET population = CASE id WHEN 124323 THEN 4335 ELSE population END WHERE id IN (124323);

UPDATE cities SET population = CASE id WHEN 119604 THEN 4333 ELSE population END WHERE id IN (119604);

UPDATE cities SET population = CASE id WHEN 128392 THEN 4331 ELSE population END WHERE id IN (128392);

UPDATE cities SET population = CASE id WHEN 114675 THEN 4325 ELSE population END WHERE id IN (114675);

UPDATE cities SET population = CASE id WHEN 129716 THEN 4324 ELSE population END WHERE id IN (129716);

UPDATE cities SET population = CASE id WHEN 115514 THEN 4323 ELSE population END WHERE id IN (115514);

UPDATE cities SET population = CASE id WHEN 111346 THEN 4321 ELSE population END WHERE id IN (111346);

UPDATE cities SET population = CASE id WHEN 119635 THEN 4318 ELSE population END WHERE id IN (119635);

UPDATE cities SET population = CASE id WHEN 127497 THEN 4313 ELSE population END WHERE id IN (127497);

UPDATE cities SET population = CASE id WHEN 124380 THEN 4295 ELSE population END WHERE id IN (124380);

UPDATE cities SET population = CASE id WHEN 120808 THEN 4276 WHEN 124430 THEN 4276 ELSE population END WHERE id IN (120808,124430);

UPDATE cities SET population = CASE id WHEN 112129 THEN 4262 ELSE population END WHERE id IN (112129);

UPDATE cities SET population = CASE id WHEN 125926 THEN 4258 ELSE population END WHERE id IN (125926);

UPDATE cities SET population = CASE id WHEN 112816 THEN 4248 ELSE population END WHERE id IN (112816);

UPDATE cities SET population = CASE id WHEN 114673 THEN 4241 ELSE population END WHERE id IN (114673);

UPDATE cities SET population = CASE id WHEN 120597 THEN 4234 ELSE population END WHERE id IN (120597);

UPDATE cities SET population = CASE id WHEN 118982 THEN 4222 ELSE population END WHERE id IN (118982);

UPDATE cities SET population = CASE id WHEN 124016 THEN 4219 ELSE population END WHERE id IN (124016);

UPDATE cities SET population = CASE id WHEN 112289 THEN 4214 ELSE population END WHERE id IN (112289);

UPDATE cities SET population = CASE id WHEN 111985 THEN 4212 ELSE population END WHERE id IN (111985);

UPDATE cities SET population = CASE id WHEN 113083 THEN 4210 ELSE population END WHERE id IN (113083);

UPDATE cities SET population = CASE id WHEN 125430 THEN 4206 ELSE population END WHERE id IN (125430);

UPDATE cities SET population = CASE id WHEN 128024 THEN 4202 ELSE population END WHERE id IN (128024);

UPDATE cities SET population = CASE id WHEN 126914 THEN 4198 ELSE population END WHERE id IN (126914);

UPDATE cities SET population = CASE id WHEN 118211 THEN 4196 ELSE population END WHERE id IN (118211);

UPDATE cities SET population = CASE id WHEN 120558 THEN 4191 ELSE population END WHERE id IN (120558);

UPDATE cities SET population = CASE id WHEN 120349 THEN 4188 ELSE population END WHERE id IN (120349);

UPDATE cities SET population = CASE id WHEN 111250 THEN 4185 ELSE population END WHERE id IN (111250);

UPDATE cities SET population = CASE id WHEN 124235 THEN 4183 ELSE population END WHERE id IN (124235);

UPDATE cities SET population = CASE id WHEN 113961 THEN 4182 ELSE population END WHERE id IN (113961);

UPDATE cities SET population = CASE id WHEN 114170 THEN 4173 ELSE population END WHERE id IN (114170);

UPDATE cities SET population = CASE id WHEN 114487 THEN 4168 ELSE population END WHERE id IN (114487);

UPDATE cities SET population = CASE id WHEN 128766 THEN 4162 ELSE population END WHERE id IN (128766);

UPDATE cities SET population = CASE id WHEN 117504 THEN 4147 ELSE population END WHERE id IN (117504);

UPDATE cities SET population = CASE id WHEN 117354 THEN 4145 ELSE population END WHERE id IN (117354);

UPDATE cities SET population = CASE id WHEN 112842 THEN 4131 ELSE population END WHERE id IN (112842);

UPDATE cities SET population = CASE id WHEN 121602 THEN 4124 ELSE population END WHERE id IN (121602);

UPDATE cities SET population = CASE id WHEN 121059 THEN 4121 ELSE population END WHERE id IN (121059);

UPDATE cities SET population = CASE id WHEN 118581 THEN 4096 ELSE population END WHERE id IN (118581);

UPDATE cities SET population = CASE id WHEN 121089 THEN 4095 ELSE population END WHERE id IN (121089);

UPDATE cities SET population = CASE id WHEN 115799 THEN 4093 ELSE population END WHERE id IN (115799);

UPDATE cities SET population = CASE id WHEN 115528 THEN 4090 ELSE population END WHERE id IN (115528);

UPDATE cities SET population = CASE id WHEN 112246 THEN 4084 ELSE population END WHERE id IN (112246);

UPDATE cities SET population = CASE id WHEN 122367 THEN 4079 ELSE population END WHERE id IN (122367);

UPDATE cities SET population = CASE id WHEN 116894 THEN 4076 ELSE population END WHERE id IN (116894);

UPDATE cities SET population = CASE id WHEN 120187 THEN 4075 ELSE population END WHERE id IN (120187);

UPDATE cities SET population = CASE id WHEN 115952 THEN 4064 ELSE population END WHERE id IN (115952);

UPDATE cities SET population = CASE id WHEN 116474 THEN 4052 ELSE population END WHERE id IN (116474);

UPDATE cities SET population = CASE id WHEN 127587 THEN 4051 ELSE population END WHERE id IN (127587);

UPDATE cities SET population = CASE id WHEN 121134 THEN 4037 ELSE population END WHERE id IN (121134);

UPDATE cities SET population = CASE id WHEN 125456 THEN 3997 ELSE population END WHERE id IN (125456);

UPDATE cities SET population = CASE id WHEN 125403 THEN 3995 ELSE population END WHERE id IN (125403);

UPDATE cities SET population = CASE id WHEN 123632 THEN 3991 ELSE population END WHERE id IN (123632);

UPDATE cities SET population = CASE id WHEN 120239 THEN 3982 ELSE population END WHERE id IN (120239);

UPDATE cities SET population = CASE id WHEN 122346 THEN 3966 ELSE population END WHERE id IN (122346);

UPDATE cities SET population = CASE id WHEN 129285 THEN 3943 ELSE population END WHERE id IN (129285);

UPDATE cities SET population = CASE id WHEN 128722 THEN 3936 ELSE population END WHERE id IN (128722);

UPDATE cities SET population = CASE id WHEN 112074 THEN 3934 ELSE population END WHERE id IN (112074);

UPDATE cities SET population = CASE id WHEN 119851 THEN 3932 ELSE population END WHERE id IN (119851);

UPDATE cities SET population = CASE id WHEN 118007 THEN 3930 ELSE population END WHERE id IN (118007);

UPDATE cities SET population = CASE id WHEN 118795 THEN 3926 ELSE population END WHERE id IN (118795);

UPDATE cities SET population = CASE id WHEN 128011 THEN 3919 ELSE population END WHERE id IN (128011);

UPDATE cities SET population = CASE id WHEN 118184 THEN 3909 ELSE population END WHERE id IN (118184);

UPDATE cities SET population = CASE id WHEN 128434 THEN 3907 ELSE population END WHERE id IN (128434);

UPDATE cities SET population = CASE id WHEN 112562 THEN 3888 ELSE population END WHERE id IN (112562);

UPDATE cities SET population = CASE id WHEN 124805 THEN 3871 ELSE population END WHERE id IN (124805);

UPDATE cities SET population = CASE id WHEN 116066 THEN 3869 ELSE population END WHERE id IN (116066);

UPDATE cities SET population = CASE id WHEN 120080 THEN 3864 ELSE population END WHERE id IN (120080);

UPDATE cities SET population = CASE id WHEN 114798 THEN 3833 ELSE population END WHERE id IN (114798);

UPDATE cities SET population = CASE id WHEN 122826 THEN 3822 ELSE population END WHERE id IN (122826);

UPDATE cities SET population = CASE id WHEN 111513 THEN 3820 ELSE population END WHERE id IN (111513);

UPDATE cities SET population = CASE id WHEN 118490 THEN 3792 ELSE population END WHERE id IN (118490);

UPDATE cities SET population = CASE id WHEN 112145 THEN 3790 ELSE population END WHERE id IN (112145);

UPDATE cities SET population = CASE id WHEN 116873 THEN 3782 ELSE population END WHERE id IN (116873);

UPDATE cities SET population = CASE id WHEN 125328 THEN 3780 ELSE population END WHERE id IN (125328);

UPDATE cities SET population = CASE id WHEN 112966 THEN 3779 WHEN 125261 THEN 3779 ELSE population END WHERE id IN (112966,125261);

UPDATE cities SET population = CASE id WHEN 128230 THEN 3777 ELSE population END WHERE id IN (128230);

UPDATE cities SET population = CASE id WHEN 116261 THEN 3774 ELSE population END WHERE id IN (116261);

UPDATE cities SET population = CASE id WHEN 121208 THEN 3766 ELSE population END WHERE id IN (121208);

UPDATE cities SET population = CASE id WHEN 111726 THEN 3761 ELSE population END WHERE id IN (111726);

UPDATE cities SET population = CASE id WHEN 128336 THEN 3751 ELSE population END WHERE id IN (128336);

UPDATE cities SET population = CASE id WHEN 123156 THEN 3745 ELSE population END WHERE id IN (123156);

UPDATE cities SET population = CASE id WHEN 128326 THEN 3739 ELSE population END WHERE id IN (128326);

UPDATE cities SET population = CASE id WHEN 121119 THEN 3736 ELSE population END WHERE id IN (121119);

UPDATE cities SET population = CASE id WHEN 129108 THEN 3725 ELSE population END WHERE id IN (129108);

UPDATE cities SET population = CASE id WHEN 123017 THEN 3723 ELSE population END WHERE id IN (123017);

UPDATE cities SET population = CASE id WHEN 129130 THEN 3719 ELSE population END WHERE id IN (129130);

UPDATE cities SET population = CASE id WHEN 111951 THEN 3714 ELSE population END WHERE id IN (111951);

UPDATE cities SET population = CASE id WHEN 123472 THEN 3709 ELSE population END WHERE id IN (123472);

UPDATE cities SET population = CASE id WHEN 114785 THEN 3702 WHEN 127961 THEN 3702 ELSE population END WHERE id IN (114785,127961);

UPDATE cities SET population = CASE id WHEN 111656 THEN 3701 ELSE population END WHERE id IN (111656);

UPDATE cities SET population = CASE id WHEN 125141 THEN 3700 ELSE population END WHERE id IN (125141);

UPDATE cities SET population = CASE id WHEN 127113 THEN 3695 ELSE population END WHERE id IN (127113);

UPDATE cities SET population = CASE id WHEN 126958 THEN 3685 ELSE population END WHERE id IN (126958);

UPDATE cities SET population = CASE id WHEN 126953 THEN 3675 ELSE population END WHERE id IN (126953);

UPDATE cities SET population = CASE id WHEN 127964 THEN 3666 ELSE population END WHERE id IN (127964);

UPDATE cities SET population = CASE id WHEN 117127 THEN 3660 ELSE population END WHERE id IN (117127);

UPDATE cities SET population = CASE id WHEN 124399 THEN 3658 ELSE population END WHERE id IN (124399);

UPDATE cities SET population = CASE id WHEN 118574 THEN 3638 ELSE population END WHERE id IN (118574);

UPDATE cities SET population = CASE id WHEN 119254 THEN 3634 ELSE population END WHERE id IN (119254);

UPDATE cities SET population = CASE id WHEN 116294 THEN 3630 WHEN 118204 THEN 3630 ELSE population END WHERE id IN (116294,118204);

UPDATE cities SET population = CASE id WHEN 123811 THEN 3629 ELSE population END WHERE id IN (123811);

UPDATE cities SET population = CASE id WHEN 118496 THEN 3621 ELSE population END WHERE id IN (118496);

UPDATE cities SET population = CASE id WHEN 112000 THEN 3618 ELSE population END WHERE id IN (112000);

UPDATE cities SET population = CASE id WHEN 123772 THEN 3616 ELSE population END WHERE id IN (123772);

UPDATE cities SET population = CASE id WHEN 126874 THEN 3611 ELSE population END WHERE id IN (126874);

UPDATE cities SET population = CASE id WHEN 121986 THEN 3601 ELSE population END WHERE id IN (121986);

UPDATE cities SET population = CASE id WHEN 119682 THEN 3597 ELSE population END WHERE id IN (119682);

UPDATE cities SET population = CASE id WHEN 125772 THEN 3596 ELSE population END WHERE id IN (125772);

UPDATE cities SET population = CASE id WHEN 127614 THEN 3592 ELSE population END WHERE id IN (127614);

UPDATE cities SET population = CASE id WHEN 112182 THEN 3591 ELSE population END WHERE id IN (112182);

UPDATE cities SET population = CASE id WHEN 116682 THEN 3584 ELSE population END WHERE id IN (116682);

UPDATE cities SET population = CASE id WHEN 120262 THEN 3582 ELSE population END WHERE id IN (120262);

UPDATE cities SET population = CASE id WHEN 117186 THEN 3543 WHEN 117966 THEN 3543 ELSE population END WHERE id IN (117186,117966);

UPDATE cities SET population = CASE id WHEN 115058 THEN 3534 ELSE population END WHERE id IN (115058);

UPDATE cities SET population = CASE id WHEN 125359 THEN 3529 ELSE population END WHERE id IN (125359);

UPDATE cities SET population = CASE id WHEN 114419 THEN 3516 ELSE population END WHERE id IN (114419);

UPDATE cities SET population = CASE id WHEN 120746 THEN 3515 ELSE population END WHERE id IN (120746);

UPDATE cities SET population = CASE id WHEN 126619 THEN 3501 ELSE population END WHERE id IN (126619);

UPDATE cities SET population = CASE id WHEN 112392 THEN 3491 ELSE population END WHERE id IN (112392);

UPDATE cities SET population = CASE id WHEN 125109 THEN 3474 ELSE population END WHERE id IN (125109);

UPDATE cities SET population = CASE id WHEN 122218 THEN 3462 WHEN 125211 THEN 3462 ELSE population END WHERE id IN (122218,125211);

UPDATE cities SET population = CASE id WHEN 128945 THEN 3458 ELSE population END WHERE id IN (128945);

UPDATE cities SET population = CASE id WHEN 116406 THEN 3447 WHEN 121231 THEN 3447 ELSE population END WHERE id IN (116406,121231);

UPDATE cities SET population = CASE id WHEN 123829 THEN 3443 ELSE population END WHERE id IN (123829);

UPDATE cities SET population = CASE id WHEN 122291 THEN 3439 ELSE population END WHERE id IN (122291);

UPDATE cities SET population = CASE id WHEN 112041 THEN 3426 ELSE population END WHERE id IN (112041);

UPDATE cities SET population = CASE id WHEN 124955 THEN 3424 ELSE population END WHERE id IN (124955);

UPDATE cities SET population = CASE id WHEN 116961 THEN 3422 ELSE population END WHERE id IN (116961);

UPDATE cities SET population = CASE id WHEN 120914 THEN 3416 ELSE population END WHERE id IN (120914);

UPDATE cities SET population = CASE id WHEN 120647 THEN 3414 ELSE population END WHERE id IN (120647);

UPDATE cities SET population = CASE id WHEN 111141 THEN 3412 ELSE population END WHERE id IN (111141);

UPDATE cities SET population = CASE id WHEN 127599 THEN 3407 ELSE population END WHERE id IN (127599);

UPDATE cities SET population = CASE id WHEN 112797 THEN 3397 WHEN 113610 THEN 3397 ELSE population END WHERE id IN (112797,113610);

UPDATE cities SET population = CASE id WHEN 113728 THEN 3385 ELSE population END WHERE id IN (113728);

UPDATE cities SET population = CASE id WHEN 111666 THEN 3383 ELSE population END WHERE id IN (111666);

UPDATE cities SET population = CASE id WHEN 121797 THEN 3379 WHEN 123308 THEN 3379 WHEN 124373 THEN 3379 ELSE population END WHERE id IN (121797,123308,124373);

UPDATE cities SET population = CASE id WHEN 127674 THEN 3377 ELSE population END WHERE id IN (127674);

UPDATE cities SET population = CASE id WHEN 114885 THEN 3374 ELSE population END WHERE id IN (114885);

UPDATE cities SET population = CASE id WHEN 128279 THEN 3355 ELSE population END WHERE id IN (128279);

UPDATE cities SET population = CASE id WHEN 126497 THEN 3346 ELSE population END WHERE id IN (126497);

UPDATE cities SET population = CASE id WHEN 111058 THEN 3342 ELSE population END WHERE id IN (111058);

UPDATE cities SET population = CASE id WHEN 111090 THEN 3330 WHEN 128916 THEN 3330 ELSE population END WHERE id IN (111090,128916);

UPDATE cities SET population = CASE id WHEN 121357 THEN 3323 ELSE population END WHERE id IN (121357);

UPDATE cities SET population = CASE id WHEN 115239 THEN 3315 ELSE population END WHERE id IN (115239);

UPDATE cities SET population = CASE id WHEN 113539 THEN 3306 ELSE population END WHERE id IN (113539);

UPDATE cities SET population = CASE id WHEN 115121 THEN 3292 ELSE population END WHERE id IN (115121);

UPDATE cities SET population = CASE id WHEN 111752 THEN 3286 ELSE population END WHERE id IN (111752);

UPDATE cities SET population = CASE id WHEN 122816 THEN 3277 ELSE population END WHERE id IN (122816);

UPDATE cities SET population = CASE id WHEN 117550 THEN 3269 ELSE population END WHERE id IN (117550);

UPDATE cities SET population = CASE id WHEN 128037 THEN 3251 ELSE population END WHERE id IN (128037);

UPDATE cities SET population = CASE id WHEN 118488 THEN 3244 ELSE population END WHERE id IN (118488);

UPDATE cities SET population = CASE id WHEN 128958 THEN 3238 ELSE population END WHERE id IN (128958);

UPDATE cities SET population = CASE id WHEN 124328 THEN 3237 ELSE population END WHERE id IN (124328);

UPDATE cities SET population = CASE id WHEN 124289 THEN 3205 ELSE population END WHERE id IN (124289);

UPDATE cities SET population = CASE id WHEN 128272 THEN 3195 ELSE population END WHERE id IN (128272);

UPDATE cities SET population = CASE id WHEN 122127 THEN 3189 ELSE population END WHERE id IN (122127);

UPDATE cities SET population = CASE id WHEN 127221 THEN 3183 ELSE population END WHERE id IN (127221);

UPDATE cities SET population = CASE id WHEN 122929 THEN 3167 ELSE population END WHERE id IN (122929);

UPDATE cities SET population = CASE id WHEN 114651 THEN 3162 ELSE population END WHERE id IN (114651);

UPDATE cities SET population = CASE id WHEN 118444 THEN 3154 ELSE population END WHERE id IN (118444);

UPDATE cities SET population = CASE id WHEN 112363 THEN 3150 ELSE population END WHERE id IN (112363);

UPDATE cities SET population = CASE id WHEN 117560 THEN 3147 WHEN 120157 THEN 3147 ELSE population END WHERE id IN (117560,120157);

UPDATE cities SET population = CASE id WHEN 114681 THEN 3144 ELSE population END WHERE id IN (114681);

UPDATE cities SET population = CASE id WHEN 124642 THEN 3133 ELSE population END WHERE id IN (124642);

UPDATE cities SET population = CASE id WHEN 125796 THEN 3130 ELSE population END WHERE id IN (125796);

UPDATE cities SET population = CASE id WHEN 111193 THEN 3126 ELSE population END WHERE id IN (111193);

UPDATE cities SET population = CASE id WHEN 129260 THEN 3122 ELSE population END WHERE id IN (129260);

UPDATE cities SET population = CASE id WHEN 111609 THEN 3117 ELSE population END WHERE id IN (111609);

UPDATE cities SET population = CASE id WHEN 118368 THEN 3107 ELSE population END WHERE id IN (118368);

UPDATE cities SET population = CASE id WHEN 113864 THEN 3098 ELSE population END WHERE id IN (113864);

UPDATE cities SET population = CASE id WHEN 112061 THEN 3096 ELSE population END WHERE id IN (112061);

UPDATE cities SET population = CASE id WHEN 118357 THEN 3095 ELSE population END WHERE id IN (118357);

UPDATE cities SET population = CASE id WHEN 126593 THEN 3094 ELSE population END WHERE id IN (126593);

UPDATE cities SET population = CASE id WHEN 129231 THEN 3088 ELSE population END WHERE id IN (129231);

UPDATE cities SET population = CASE id WHEN 119594 THEN 3086 ELSE population END WHERE id IN (119594);

UPDATE cities SET population = CASE id WHEN 124600 THEN 3082 ELSE population END WHERE id IN (124600);

UPDATE cities SET population = CASE id WHEN 125282 THEN 3076 ELSE population END WHERE id IN (125282);

UPDATE cities SET population = CASE id WHEN 122938 THEN 3074 ELSE population END WHERE id IN (122938);

UPDATE cities SET population = CASE id WHEN 119865 THEN 3071 ELSE population END WHERE id IN (119865);

UPDATE cities SET population = CASE id WHEN 120865 THEN 3067 ELSE population END WHERE id IN (120865);

UPDATE cities SET population = CASE id WHEN 111603 THEN 3065 WHEN 124715 THEN 3065 ELSE population END WHERE id IN (111603,124715);

UPDATE cities SET population = CASE id WHEN 116037 THEN 3057 ELSE population END WHERE id IN (116037);

UPDATE cities SET population = CASE id WHEN 124377 THEN 3056 ELSE population END WHERE id IN (124377);

UPDATE cities SET population = CASE id WHEN 111584 THEN 3051 ELSE population END WHERE id IN (111584);

UPDATE cities SET population = CASE id WHEN 113007 THEN 3040 ELSE population END WHERE id IN (113007);

UPDATE cities SET population = CASE id WHEN 120045 THEN 3032 ELSE population END WHERE id IN (120045);

UPDATE cities SET population = CASE id WHEN 118295 THEN 3014 ELSE population END WHERE id IN (118295);

UPDATE cities SET population = CASE id WHEN 128055 THEN 3013 ELSE population END WHERE id IN (128055);

UPDATE cities SET population = CASE id WHEN 129405 THEN 3012 ELSE population END WHERE id IN (129405);

UPDATE cities SET population = CASE id WHEN 129273 THEN 3003 ELSE population END WHERE id IN (129273);

UPDATE cities SET population = CASE id WHEN 113101 THEN 2995 ELSE population END WHERE id IN (113101);

UPDATE cities SET population = CASE id WHEN 129570 THEN 2978 ELSE population END WHERE id IN (129570);

UPDATE cities SET population = CASE id WHEN 112864 THEN 2977 ELSE population END WHERE id IN (112864);

UPDATE cities SET population = CASE id WHEN 126943 THEN 2973 ELSE population END WHERE id IN (126943);

UPDATE cities SET population = CASE id WHEN 114658 THEN 2966 ELSE population END WHERE id IN (114658);

UPDATE cities SET population = CASE id WHEN 118906 THEN 2959 ELSE population END WHERE id IN (118906);

UPDATE cities SET population = CASE id WHEN 125652 THEN 2953 ELSE population END WHERE id IN (125652);

UPDATE cities SET population = CASE id WHEN 112926 THEN 2952 ELSE population END WHERE id IN (112926);

UPDATE cities SET population = CASE id WHEN 116005 THEN 2946 ELSE population END WHERE id IN (116005);

UPDATE cities SET population = CASE id WHEN 112416 THEN 2935 ELSE population END WHERE id IN (112416);

UPDATE cities SET population = CASE id WHEN 113558 THEN 2931 ELSE population END WHERE id IN (113558);

UPDATE cities SET population = CASE id WHEN 114196 THEN 2925 ELSE population END WHERE id IN (114196);

UPDATE cities SET population = CASE id WHEN 112627 THEN 2919 ELSE population END WHERE id IN (112627);

UPDATE cities SET population = CASE id WHEN 120006 THEN 2912 ELSE population END WHERE id IN (120006);

UPDATE cities SET population = CASE id WHEN 127119 THEN 2906 ELSE population END WHERE id IN (127119);

UPDATE cities SET population = CASE id WHEN 115211 THEN 2900 ELSE population END WHERE id IN (115211);

UPDATE cities SET population = CASE id WHEN 115471 THEN 2898 ELSE population END WHERE id IN (115471);

UPDATE cities SET population = CASE id WHEN 119569 THEN 2892 ELSE population END WHERE id IN (119569);

UPDATE cities SET population = CASE id WHEN 111436 THEN 2884 ELSE population END WHERE id IN (111436);

UPDATE cities SET population = CASE id WHEN 118651 THEN 2882 WHEN 129193 THEN 2882 ELSE population END WHERE id IN (118651,129193);

UPDATE cities SET population = CASE id WHEN 116634 THEN 2878 ELSE population END WHERE id IN (116634);

UPDATE cities SET population = CASE id WHEN 122363 THEN 2877 WHEN 127363 THEN 2877 ELSE population END WHERE id IN (122363,127363);

UPDATE cities SET population = CASE id WHEN 125921 THEN 2876 ELSE population END WHERE id IN (125921);

UPDATE cities SET population = CASE id WHEN 118445 THEN 2869 ELSE population END WHERE id IN (118445);

UPDATE cities SET population = CASE id WHEN 112786 THEN 2862 ELSE population END WHERE id IN (112786);

UPDATE cities SET population = CASE id WHEN 122118 THEN 2860 ELSE population END WHERE id IN (122118);

UPDATE cities SET population = CASE id WHEN 119486 THEN 2858 ELSE population END WHERE id IN (119486);

UPDATE cities SET population = CASE id WHEN 123182 THEN 2841 ELSE population END WHERE id IN (123182);

UPDATE cities SET population = CASE id WHEN 122428 THEN 2837 ELSE population END WHERE id IN (122428);

UPDATE cities SET population = CASE id WHEN 119043 THEN 2834 WHEN 120899 THEN 2834 ELSE population END WHERE id IN (119043,120899);

UPDATE cities SET population = CASE id WHEN 120572 THEN 2830 ELSE population END WHERE id IN (120572);

UPDATE cities SET population = CASE id WHEN 123282 THEN 2829 WHEN 128618 THEN 2829 ELSE population END WHERE id IN (123282,128618);

UPDATE cities SET population = CASE id WHEN 121911 THEN 2824 ELSE population END WHERE id IN (121911);

UPDATE cities SET population = CASE id WHEN 119274 THEN 2818 ELSE population END WHERE id IN (119274);

UPDATE cities SET population = CASE id WHEN 126291 THEN 2817 ELSE population END WHERE id IN (126291);

UPDATE cities SET population = CASE id WHEN 110965 THEN 2815 ELSE population END WHERE id IN (110965);

UPDATE cities SET population = CASE id WHEN 123330 THEN 2811 ELSE population END WHERE id IN (123330);

UPDATE cities SET population = CASE id WHEN 122723 THEN 2800 ELSE population END WHERE id IN (122723);

UPDATE cities SET population = CASE id WHEN 115929 THEN 2798 ELSE population END WHERE id IN (115929);

UPDATE cities SET population = CASE id WHEN 115857 THEN 2795 ELSE population END WHERE id IN (115857);

UPDATE cities SET population = CASE id WHEN 115072 THEN 2794 ELSE population END WHERE id IN (115072);

UPDATE cities SET population = CASE id WHEN 117881 THEN 2791 ELSE population END WHERE id IN (117881);

UPDATE cities SET population = CASE id WHEN 118194 THEN 2787 ELSE population END WHERE id IN (118194);

UPDATE cities SET population = CASE id WHEN 114116 THEN 2767 ELSE population END WHERE id IN (114116);

UPDATE cities SET population = CASE id WHEN 112443 THEN 2764 ELSE population END WHERE id IN (112443);

UPDATE cities SET population = CASE id WHEN 128217 THEN 2759 ELSE population END WHERE id IN (128217);

UPDATE cities SET population = CASE id WHEN 123614 THEN 2748 ELSE population END WHERE id IN (123614);

UPDATE cities SET population = CASE id WHEN 129296 THEN 2746 ELSE population END WHERE id IN (129296);

UPDATE cities SET population = CASE id WHEN 120488 THEN 2735 ELSE population END WHERE id IN (120488);

UPDATE cities SET population = CASE id WHEN 125019 THEN 2720 ELSE population END WHERE id IN (125019);

UPDATE cities SET population = CASE id WHEN 124131 THEN 2715 ELSE population END WHERE id IN (124131);

UPDATE cities SET population = CASE id WHEN 123933 THEN 2713 ELSE population END WHERE id IN (123933);

UPDATE cities SET population = CASE id WHEN 129168 THEN 2711 ELSE population END WHERE id IN (129168);

UPDATE cities SET population = CASE id WHEN 125640 THEN 2709 ELSE population END WHERE id IN (125640);

UPDATE cities SET population = CASE id WHEN 113691 THEN 2704 ELSE population END WHERE id IN (113691);

UPDATE cities SET population = CASE id WHEN 126451 THEN 2702 ELSE population END WHERE id IN (126451);

UPDATE cities SET population = CASE id WHEN 116334 THEN 2697 ELSE population END WHERE id IN (116334);

UPDATE cities SET population = CASE id WHEN 119337 THEN 2692 ELSE population END WHERE id IN (119337);

UPDATE cities SET population = CASE id WHEN 115678 THEN 2691 ELSE population END WHERE id IN (115678);

UPDATE cities SET population = CASE id WHEN 129227 THEN 2683 ELSE population END WHERE id IN (129227);

UPDATE cities SET population = CASE id WHEN 118726 THEN 2680 ELSE population END WHERE id IN (118726);

UPDATE cities SET population = CASE id WHEN 110972 THEN 2672 ELSE population END WHERE id IN (110972);

UPDATE cities SET population = CASE id WHEN 126966 THEN 2666 ELSE population END WHERE id IN (126966);

UPDATE cities SET population = CASE id WHEN 114255 THEN 2663 ELSE population END WHERE id IN (114255);

UPDATE cities SET population = CASE id WHEN 118021 THEN 2658 ELSE population END WHERE id IN (118021);

UPDATE cities SET population = CASE id WHEN 127640 THEN 2657 ELSE population END WHERE id IN (127640);

UPDATE cities SET population = CASE id WHEN 129449 THEN 2650 ELSE population END WHERE id IN (129449);

UPDATE cities SET population = CASE id WHEN 124303 THEN 2649 ELSE population END WHERE id IN (124303);

UPDATE cities SET population = CASE id WHEN 118084 THEN 2647 ELSE population END WHERE id IN (118084);

UPDATE cities SET population = CASE id WHEN 124586 THEN 2640 ELSE population END WHERE id IN (124586);

UPDATE cities SET population = CASE id WHEN 113165 THEN 2626 WHEN 127653 THEN 2626 ELSE population END WHERE id IN (113165,127653);

UPDATE cities SET population = CASE id WHEN 125007 THEN 2616 ELSE population END WHERE id IN (125007);

UPDATE cities SET population = CASE id WHEN 113066 THEN 2615 ELSE population END WHERE id IN (113066);

UPDATE cities SET population = CASE id WHEN 117502 THEN 2614 ELSE population END WHERE id IN (117502);

UPDATE cities SET population = CASE id WHEN 115963 THEN 2607 WHEN 125726 THEN 2607 ELSE population END WHERE id IN (115963,125726);

UPDATE cities SET population = CASE id WHEN 116339 THEN 2600 ELSE population END WHERE id IN (116339);

UPDATE cities SET population = CASE id WHEN 123164 THEN 2597 ELSE population END WHERE id IN (123164);

UPDATE cities SET population = CASE id WHEN 111159 THEN 2596 WHEN 111255 THEN 2596 WHEN 125875 THEN 2596 ELSE population END WHERE id IN (111159,111255,125875);

UPDATE cities SET population = CASE id WHEN 115826 THEN 2577 ELSE population END WHERE id IN (115826);

UPDATE cities SET population = CASE id WHEN 111963 THEN 2566 WHEN 112894 THEN 2566 ELSE population END WHERE id IN (111963,112894);

UPDATE cities SET population = CASE id WHEN 129444 THEN 2563 ELSE population END WHERE id IN (129444);

UPDATE cities SET population = CASE id WHEN 125117 THEN 2558 ELSE population END WHERE id IN (125117);

UPDATE cities SET population = CASE id WHEN 119456 THEN 2555 ELSE population END WHERE id IN (119456);

UPDATE cities SET population = CASE id WHEN 117533 THEN 2554 ELSE population END WHERE id IN (117533);

UPDATE cities SET population = CASE id WHEN 118656 THEN 2550 ELSE population END WHERE id IN (118656);

UPDATE cities SET population = CASE id WHEN 125321 THEN 2545 WHEN 126571 THEN 2545 ELSE population END WHERE id IN (125321,126571);

UPDATE cities SET population = CASE id WHEN 114267 THEN 2538 ELSE population END WHERE id IN (114267);

UPDATE cities SET population = CASE id WHEN 121886 THEN 2536 ELSE population END WHERE id IN (121886);

UPDATE cities SET population = CASE id WHEN 116099 THEN 2535 WHEN 123442 THEN 2535 ELSE population END WHERE id IN (116099,123442);

UPDATE cities SET population = CASE id WHEN 120679 THEN 2531 ELSE population END WHERE id IN (120679);

UPDATE cities SET population = CASE id WHEN 123966 THEN 2530 ELSE population END WHERE id IN (123966);

UPDATE cities SET population = CASE id WHEN 124139 THEN 2524 ELSE population END WHERE id IN (124139);

UPDATE cities SET population = CASE id WHEN 128403 THEN 2522 ELSE population END WHERE id IN (128403);

UPDATE cities SET population = CASE id WHEN 121201 THEN 2513 ELSE population END WHERE id IN (121201);

UPDATE cities SET population = CASE id WHEN 115537 THEN 2509 ELSE population END WHERE id IN (115537);

UPDATE cities SET population = CASE id WHEN 127601 THEN 2492 ELSE population END WHERE id IN (127601);

UPDATE cities SET population = CASE id WHEN 115566 THEN 2486 ELSE population END WHERE id IN (115566);

UPDATE cities SET population = CASE id WHEN 113761 THEN 2483 WHEN 119153 THEN 2483 ELSE population END WHERE id IN (113761,119153);

UPDATE cities SET population = CASE id WHEN 113296 THEN 2479 ELSE population END WHERE id IN (113296);

UPDATE cities SET population = CASE id WHEN 122251 THEN 2475 ELSE population END WHERE id IN (122251);

UPDATE cities SET population = CASE id WHEN 115602 THEN 2474 ELSE population END WHERE id IN (115602);

UPDATE cities SET population = CASE id WHEN 122913 THEN 2465 ELSE population END WHERE id IN (122913);

UPDATE cities SET population = CASE id WHEN 111268 THEN 2459 ELSE population END WHERE id IN (111268);

UPDATE cities SET population = CASE id WHEN 120804 THEN 2455 ELSE population END WHERE id IN (120804);

UPDATE cities SET population = CASE id WHEN 116232 THEN 2450 ELSE population END WHERE id IN (116232);

UPDATE cities SET population = CASE id WHEN 112126 THEN 2447 ELSE population END WHERE id IN (112126);

UPDATE cities SET population = CASE id WHEN 124004 THEN 2445 ELSE population END WHERE id IN (124004);

UPDATE cities SET population = CASE id WHEN 119331 THEN 2444 ELSE population END WHERE id IN (119331);

UPDATE cities SET population = CASE id WHEN 129162 THEN 2438 ELSE population END WHERE id IN (129162);

UPDATE cities SET population = CASE id WHEN 116124 THEN 2427 ELSE population END WHERE id IN (116124);

UPDATE cities SET population = CASE id WHEN 111304 THEN 2420 ELSE population END WHERE id IN (111304);

UPDATE cities SET population = CASE id WHEN 126309 THEN 2418 ELSE population END WHERE id IN (126309);

UPDATE cities SET population = CASE id WHEN 119003 THEN 2416 ELSE population END WHERE id IN (119003);

UPDATE cities SET population = CASE id WHEN 128015 THEN 2415 ELSE population END WHERE id IN (128015);

UPDATE cities SET population = CASE id WHEN 112881 THEN 2401 ELSE population END WHERE id IN (112881);

UPDATE cities SET population = CASE id WHEN 117674 THEN 2399 WHEN 127239 THEN 2399 WHEN 129690 THEN 2399 ELSE population END WHERE id IN (117674,127239,129690);

UPDATE cities SET population = CASE id WHEN 123197 THEN 2394 ELSE population END WHERE id IN (123197);

UPDATE cities SET population = CASE id WHEN 124220 THEN 2388 ELSE population END WHERE id IN (124220);

UPDATE cities SET population = CASE id WHEN 117664 THEN 2387 ELSE population END WHERE id IN (117664);

UPDATE cities SET population = CASE id WHEN 121398 THEN 2383 ELSE population END WHERE id IN (121398);

UPDATE cities SET population = CASE id WHEN 111029 THEN 2372 ELSE population END WHERE id IN (111029);

UPDATE cities SET population = CASE id WHEN 116330 THEN 2367 ELSE population END WHERE id IN (116330);

UPDATE cities SET population = CASE id WHEN 129164 THEN 2363 ELSE population END WHERE id IN (129164);

UPDATE cities SET population = CASE id WHEN 127116 THEN 2361 ELSE population END WHERE id IN (127116);

UPDATE cities SET population = CASE id WHEN 120811 THEN 2358 ELSE population END WHERE id IN (120811);

UPDATE cities SET population = CASE id WHEN 111265 THEN 2356 ELSE population END WHERE id IN (111265);

UPDATE cities SET population = CASE id WHEN 112758 THEN 2355 ELSE population END WHERE id IN (112758);

UPDATE cities SET population = CASE id WHEN 115031 THEN 2350 ELSE population END WHERE id IN (115031);

UPDATE cities SET population = CASE id WHEN 119277 THEN 2348 ELSE population END WHERE id IN (119277);

UPDATE cities SET population = CASE id WHEN 124103 THEN 2347 ELSE population END WHERE id IN (124103);

UPDATE cities SET population = CASE id WHEN 119500 THEN 2340 ELSE population END WHERE id IN (119500);

UPDATE cities SET population = CASE id WHEN 121965 THEN 2337 WHEN 128832 THEN 2337 ELSE population END WHERE id IN (121965,128832);

UPDATE cities SET population = CASE id WHEN 125838 THEN 2336 ELSE population END WHERE id IN (125838);

UPDATE cities SET population = CASE id WHEN 123247 THEN 2333 ELSE population END WHERE id IN (123247);

UPDATE cities SET population = CASE id WHEN 119480 THEN 2330 ELSE population END WHERE id IN (119480);

UPDATE cities SET population = CASE id WHEN 120490 THEN 2329 ELSE population END WHERE id IN (120490);

UPDATE cities SET population = CASE id WHEN 116895 THEN 2326 ELSE population END WHERE id IN (116895);

UPDATE cities SET population = CASE id WHEN 119878 THEN 2324 ELSE population END WHERE id IN (119878);

UPDATE cities SET population = CASE id WHEN 128790 THEN 2323 ELSE population END WHERE id IN (128790);

UPDATE cities SET population = CASE id WHEN 115250 THEN 2309 ELSE population END WHERE id IN (115250);

UPDATE cities SET population = CASE id WHEN 111232 THEN 2308 ELSE population END WHERE id IN (111232);

UPDATE cities SET population = CASE id WHEN 118047 THEN 2302 ELSE population END WHERE id IN (118047);

UPDATE cities SET population = CASE id WHEN 125201 THEN 2300 ELSE population END WHERE id IN (125201);

UPDATE cities SET population = CASE id WHEN 114842 THEN 2299 ELSE population END WHERE id IN (114842);

UPDATE cities SET population = CASE id WHEN 118196 THEN 2296 ELSE population END WHERE id IN (118196);

UPDATE cities SET population = CASE id WHEN 127026 THEN 2293 ELSE population END WHERE id IN (127026);

UPDATE cities SET population = CASE id WHEN 125692 THEN 2289 WHEN 127714 THEN 2289 ELSE population END WHERE id IN (125692,127714);

UPDATE cities SET population = CASE id WHEN 111498 THEN 2288 WHEN 127468 THEN 2288 ELSE population END WHERE id IN (111498,127468);

UPDATE cities SET population = CASE id WHEN 123371 THEN 2286 ELSE population END WHERE id IN (123371);

UPDATE cities SET population = CASE id WHEN 119333 THEN 2283 ELSE population END WHERE id IN (119333);

UPDATE cities SET population = CASE id WHEN 117377 THEN 2281 ELSE population END WHERE id IN (117377);

UPDATE cities SET population = CASE id WHEN 115585 THEN 2274 WHEN 116794 THEN 2274 ELSE population END WHERE id IN (115585,116794);

UPDATE cities SET population = CASE id WHEN 120370 THEN 2272 ELSE population END WHERE id IN (120370);

UPDATE cities SET population = CASE id WHEN 113513 THEN 2271 WHEN 115808 THEN 2271 WHEN 126820 THEN 2271 ELSE population END WHERE id IN (113513,115808,126820);

UPDATE cities SET population = CASE id WHEN 123882 THEN 2268 ELSE population END WHERE id IN (123882);

UPDATE cities SET population = CASE id WHEN 111937 THEN 2264 ELSE population END WHERE id IN (111937);

UPDATE cities SET population = CASE id WHEN 118522 THEN 2263 ELSE population END WHERE id IN (118522);

UPDATE cities SET population = CASE id WHEN 120431 THEN 2261 WHEN 122211 THEN 2261 WHEN 126656 THEN 2261 ELSE population END WHERE id IN (120431,122211,126656);

UPDATE cities SET population = CASE id WHEN 129613 THEN 2260 ELSE population END WHERE id IN (129613);

UPDATE cities SET population = CASE id WHEN 112772 THEN 2256 ELSE population END WHERE id IN (112772);

UPDATE cities SET population = CASE id WHEN 119130 THEN 2254 ELSE population END WHERE id IN (119130);

UPDATE cities SET population = CASE id WHEN 128782 THEN 2247 ELSE population END WHERE id IN (128782);

UPDATE cities SET population = CASE id WHEN 118771 THEN 2244 ELSE population END WHERE id IN (118771);

UPDATE cities SET population = CASE id WHEN 118918 THEN 2241 ELSE population END WHERE id IN (118918);

UPDATE cities SET population = CASE id WHEN 111031 THEN 2239 ELSE population END WHERE id IN (111031);

UPDATE cities SET population = CASE id WHEN 116985 THEN 2235 ELSE population END WHERE id IN (116985);

UPDATE cities SET population = CASE id WHEN 111368 THEN 2230 WHEN 113868 THEN 2230 ELSE population END WHERE id IN (111368,113868);

UPDATE cities SET population = CASE id WHEN 124917 THEN 2225 ELSE population END WHERE id IN (124917);

UPDATE cities SET population = CASE id WHEN 120879 THEN 2223 WHEN 125315 THEN 2223 ELSE population END WHERE id IN (120879,125315);

UPDATE cities SET population = CASE id WHEN 122874 THEN 2222 WHEN 124746 THEN 2222 ELSE population END WHERE id IN (122874,124746);

UPDATE cities SET population = CASE id WHEN 123558 THEN 2219 ELSE population END WHERE id IN (123558);

UPDATE cities SET population = CASE id WHEN 111281 THEN 2210 ELSE population END WHERE id IN (111281);

UPDATE cities SET population = CASE id WHEN 121402 THEN 2209 ELSE population END WHERE id IN (121402);

UPDATE cities SET population = CASE id WHEN 113000 THEN 2206 WHEN 123875 THEN 2206 ELSE population END WHERE id IN (113000,123875);

UPDATE cities SET population = CASE id WHEN 115483 THEN 2205 WHEN 125169 THEN 2205 WHEN 127371 THEN 2205 ELSE population END WHERE id IN (115483,125169,127371);

UPDATE cities SET population = CASE id WHEN 118361 THEN 2202 ELSE population END WHERE id IN (118361);

UPDATE cities SET population = CASE id WHEN 118762 THEN 2197 ELSE population END WHERE id IN (118762);

UPDATE cities SET population = CASE id WHEN 127285 THEN 2193 ELSE population END WHERE id IN (127285);

UPDATE cities SET population = CASE id WHEN 121279 THEN 2191 ELSE population END WHERE id IN (121279);

UPDATE cities SET population = CASE id WHEN 122229 THEN 2187 ELSE population END WHERE id IN (122229);

UPDATE cities SET population = CASE id WHEN 123279 THEN 2185 ELSE population END WHERE id IN (123279);

UPDATE cities SET population = CASE id WHEN 113401 THEN 2183 ELSE population END WHERE id IN (113401);

UPDATE cities SET population = CASE id WHEN 119309 THEN 2181 ELSE population END WHERE id IN (119309);

UPDATE cities SET population = CASE id WHEN 114601 THEN 2180 WHEN 126979 THEN 2180 ELSE population END WHERE id IN (114601,126979);

UPDATE cities SET population = CASE id WHEN 118168 THEN 2179 ELSE population END WHERE id IN (118168);

UPDATE cities SET population = CASE id WHEN 122567 THEN 2177 WHEN 127764 THEN 2177 ELSE population END WHERE id IN (122567,127764);

UPDATE cities SET population = CASE id WHEN 116012 THEN 2175 WHEN 127793 THEN 2175 ELSE population END WHERE id IN (116012,127793);

UPDATE cities SET population = CASE id WHEN 122566 THEN 2171 ELSE population END WHERE id IN (122566);

UPDATE cities SET population = CASE id WHEN 126857 THEN 2168 ELSE population END WHERE id IN (126857);

UPDATE cities SET population = CASE id WHEN 119962 THEN 2164 ELSE population END WHERE id IN (119962);

UPDATE cities SET population = CASE id WHEN 112299 THEN 2162 WHEN 129279 THEN 2162 ELSE population END WHERE id IN (112299,129279);

UPDATE cities SET population = CASE id WHEN 120459 THEN 2160 WHEN 123485 THEN 2160 ELSE population END WHERE id IN (120459,123485);

UPDATE cities SET population = CASE id WHEN 113839 THEN 2159 ELSE population END WHERE id IN (113839);

UPDATE cities SET population = CASE id WHEN 111524 THEN 2158 WHEN 117603 THEN 2158 ELSE population END WHERE id IN (111524,117603);

UPDATE cities SET population = CASE id WHEN 128342 THEN 2156 ELSE population END WHERE id IN (128342);

UPDATE cities SET population = CASE id WHEN 129309 THEN 2150 ELSE population END WHERE id IN (129309);

UPDATE cities SET population = CASE id WHEN 121065 THEN 2145 ELSE population END WHERE id IN (121065);

UPDATE cities SET population = CASE id WHEN 124221 THEN 2142 ELSE population END WHERE id IN (124221);

UPDATE cities SET population = CASE id WHEN 117312 THEN 2141 ELSE population END WHERE id IN (117312);

UPDATE cities SET population = CASE id WHEN 118798 THEN 2140 ELSE population END WHERE id IN (118798);

UPDATE cities SET population = CASE id WHEN 129180 THEN 2138 ELSE population END WHERE id IN (129180);

UPDATE cities SET population = CASE id WHEN 119916 THEN 2135 ELSE population END WHERE id IN (119916);

UPDATE cities SET population = CASE id WHEN 115821 THEN 2133 WHEN 121709 THEN 2133 ELSE population END WHERE id IN (115821,121709);

UPDATE cities SET population = CASE id WHEN 123563 THEN 2129 ELSE population END WHERE id IN (123563);

UPDATE cities SET population = CASE id WHEN 111722 THEN 2128 WHEN 117446 THEN 2128 ELSE population END WHERE id IN (111722,117446);

UPDATE cities SET population = CASE id WHEN 116386 THEN 2127 ELSE population END WHERE id IN (116386);

UPDATE cities SET population = CASE id WHEN 117668 THEN 2123 ELSE population END WHERE id IN (117668);

UPDATE cities SET population = CASE id WHEN 128264 THEN 2120 ELSE population END WHERE id IN (128264);

UPDATE cities SET population = CASE id WHEN 127770 THEN 2117 ELSE population END WHERE id IN (127770);

UPDATE cities SET population = CASE id WHEN 119986 THEN 2114 ELSE population END WHERE id IN (119986);

UPDATE cities SET population = CASE id WHEN 125555 THEN 2111 ELSE population END WHERE id IN (125555);

UPDATE cities SET population = CASE id WHEN 123366 THEN 2104 ELSE population END WHERE id IN (123366);

UPDATE cities SET population = CASE id WHEN 116222 THEN 2102 ELSE population END WHERE id IN (116222);

UPDATE cities SET population = CASE id WHEN 129208 THEN 2101 ELSE population END WHERE id IN (129208);

UPDATE cities SET population = CASE id WHEN 128208 THEN 2100 ELSE population END WHERE id IN (128208);

UPDATE cities SET population = CASE id WHEN 118080 THEN 2098 ELSE population END WHERE id IN (118080);

UPDATE cities SET population = CASE id WHEN 113312 THEN 2097 ELSE population END WHERE id IN (113312);

UPDATE cities SET population = CASE id WHEN 117566 THEN 2096 WHEN 122714 THEN 2096 ELSE population END WHERE id IN (117566,122714);

UPDATE cities SET population = CASE id WHEN 117047 THEN 2095 ELSE population END WHERE id IN (117047);

UPDATE cities SET population = CASE id WHEN 127091 THEN 2093 ELSE population END WHERE id IN (127091);

UPDATE cities SET population = CASE id WHEN 114309 THEN 2090 WHEN 124883 THEN 2090 ELSE population END WHERE id IN (114309,124883);

UPDATE cities SET population = CASE id WHEN 122597 THEN 2087 ELSE population END WHERE id IN (122597);

UPDATE cities SET population = CASE id WHEN 126545 THEN 2086 ELSE population END WHERE id IN (126545);

UPDATE cities SET population = CASE id WHEN 111896 THEN 2083 ELSE population END WHERE id IN (111896);

UPDATE cities SET population = CASE id WHEN 118697 THEN 2082 ELSE population END WHERE id IN (118697);

UPDATE cities SET population = CASE id WHEN 129313 THEN 2076 ELSE population END WHERE id IN (129313);

UPDATE cities SET population = CASE id WHEN 116084 THEN 2074 ELSE population END WHERE id IN (116084);

UPDATE cities SET population = CASE id WHEN 127928 THEN 2073 ELSE population END WHERE id IN (127928);

UPDATE cities SET population = CASE id WHEN 127801 THEN 2066 ELSE population END WHERE id IN (127801);

UPDATE cities SET population = CASE id WHEN 128367 THEN 2063 ELSE population END WHERE id IN (128367);

UPDATE cities SET population = CASE id WHEN 119942 THEN 2060 ELSE population END WHERE id IN (119942);

UPDATE cities SET population = CASE id WHEN 118476 THEN 2058 ELSE population END WHERE id IN (118476);

UPDATE cities SET population = CASE id WHEN 123758 THEN 2055 ELSE population END WHERE id IN (123758);

UPDATE cities SET population = CASE id WHEN 116910 THEN 2052 ELSE population END WHERE id IN (116910);

UPDATE cities SET population = CASE id WHEN 111645 THEN 2051 WHEN 120303 THEN 2051 ELSE population END WHERE id IN (111645,120303);

UPDATE cities SET population = CASE id WHEN 120169 THEN 2049 ELSE population END WHERE id IN (120169);

UPDATE cities SET population = CASE id WHEN 113554 THEN 2045 ELSE population END WHERE id IN (113554);

UPDATE cities SET population = CASE id WHEN 112671 THEN 2040 ELSE population END WHERE id IN (112671);

UPDATE cities SET population = CASE id WHEN 112135 THEN 2039 ELSE population END WHERE id IN (112135);

UPDATE cities SET population = CASE id WHEN 126154 THEN 2034 ELSE population END WHERE id IN (126154);

UPDATE cities SET population = CASE id WHEN 114013 THEN 2032 ELSE population END WHERE id IN (114013);

UPDATE cities SET population = CASE id WHEN 117272 THEN 2031 WHEN 117491 THEN 2031 ELSE population END WHERE id IN (117272,117491);

UPDATE cities SET population = CASE id WHEN 114638 THEN 2028 ELSE population END WHERE id IN (114638);

UPDATE cities SET population = CASE id WHEN 117226 THEN 2027 ELSE population END WHERE id IN (117226);

UPDATE cities SET population = CASE id WHEN 118149 THEN 2025 WHEN 120560 THEN 2025 ELSE population END WHERE id IN (118149,120560);

UPDATE cities SET population = CASE id WHEN 126235 THEN 2003 ELSE population END WHERE id IN (126235);

UPDATE cities SET population = CASE id WHEN 121950 THEN 2002 ELSE population END WHERE id IN (121950);

UPDATE cities SET population = CASE id WHEN 112741 THEN 2000 WHEN 126097 THEN 2000 ELSE population END WHERE id IN (112741,126097);

UPDATE cities SET population = CASE id WHEN 123179 THEN 1995 WHEN 126851 THEN 1995 ELSE population END WHERE id IN (123179,126851);

UPDATE cities SET population = CASE id WHEN 117716 THEN 1992 ELSE population END WHERE id IN (117716);

UPDATE cities SET population = CASE id WHEN 124694 THEN 1991 WHEN 127044 THEN 1991 ELSE population END WHERE id IN (124694,127044);

UPDATE cities SET population = CASE id WHEN 126285 THEN 1990 ELSE population END WHERE id IN (126285);

UPDATE cities SET population = CASE id WHEN 111310 THEN 1982 ELSE population END WHERE id IN (111310);

UPDATE cities SET population = CASE id WHEN 129340 THEN 1980 ELSE population END WHERE id IN (129340);

UPDATE cities SET population = CASE id WHEN 114433 THEN 1973 ELSE population END WHERE id IN (114433);

UPDATE cities SET population = CASE id WHEN 127617 THEN 1971 ELSE population END WHERE id IN (127617);

UPDATE cities SET population = CASE id WHEN 116409 THEN 1970 ELSE population END WHERE id IN (116409);

UPDATE cities SET population = CASE id WHEN 122390 THEN 1968 ELSE population END WHERE id IN (122390);

UPDATE cities SET population = CASE id WHEN 118547 THEN 1967 ELSE population END WHERE id IN (118547);

UPDATE cities SET population = CASE id WHEN 122299 THEN 1960 ELSE population END WHERE id IN (122299);

UPDATE cities SET population = CASE id WHEN 124146 THEN 1958 ELSE population END WHERE id IN (124146);

UPDATE cities SET population = CASE id WHEN 117396 THEN 1956 ELSE population END WHERE id IN (117396);

UPDATE cities SET population = CASE id WHEN 119058 THEN 1951 ELSE population END WHERE id IN (119058);

UPDATE cities SET population = CASE id WHEN 127445 THEN 1946 ELSE population END WHERE id IN (127445);

UPDATE cities SET population = CASE id WHEN 122265 THEN 1934 ELSE population END WHERE id IN (122265);

UPDATE cities SET population = CASE id WHEN 111123 THEN 1932 WHEN 117571 THEN 1932 ELSE population END WHERE id IN (111123,117571);

UPDATE cities SET population = CASE id WHEN 113259 THEN 1930 ELSE population END WHERE id IN (113259);

UPDATE cities SET population = CASE id WHEN 124826 THEN 1920 ELSE population END WHERE id IN (124826);

UPDATE cities SET population = CASE id WHEN 124242 THEN 1918 ELSE population END WHERE id IN (124242);

UPDATE cities SET population = CASE id WHEN 111222 THEN 1917 ELSE population END WHERE id IN (111222);

UPDATE cities SET population = CASE id WHEN 127150 THEN 1912 ELSE population END WHERE id IN (127150);

UPDATE cities SET population = CASE id WHEN 124438 THEN 1907 ELSE population END WHERE id IN (124438);

UPDATE cities SET population = CASE id WHEN 118484 THEN 1905 ELSE population END WHERE id IN (118484);

UPDATE cities SET population = CASE id WHEN 121432 THEN 1903 ELSE population END WHERE id IN (121432);

UPDATE cities SET population = CASE id WHEN 124333 THEN 1895 WHEN 128188 THEN 1895 ELSE population END WHERE id IN (124333,128188);

UPDATE cities SET population = CASE id WHEN 120779 THEN 1890 ELSE population END WHERE id IN (120779);

UPDATE cities SET population = CASE id WHEN 121835 THEN 1886 ELSE population END WHERE id IN (121835);

UPDATE cities SET population = CASE id WHEN 127278 THEN 1884 ELSE population END WHERE id IN (127278);

UPDATE cities SET population = CASE id WHEN 112389 THEN 1883 ELSE population END WHERE id IN (112389);

UPDATE cities SET population = CASE id WHEN 126427 THEN 1879 ELSE population END WHERE id IN (126427);

UPDATE cities SET population = CASE id WHEN 118648 THEN 1874 ELSE population END WHERE id IN (118648);

UPDATE cities SET population = CASE id WHEN 113583 THEN 1868 ELSE population END WHERE id IN (113583);

UPDATE cities SET population = CASE id WHEN 112402 THEN 1867 ELSE population END WHERE id IN (112402);

UPDATE cities SET population = CASE id WHEN 114548 THEN 1866 WHEN 115475 THEN 1866 WHEN 121448 THEN 1866 ELSE population END WHERE id IN (114548,115475,121448);

UPDATE cities SET population = CASE id WHEN 117816 THEN 1861 ELSE population END WHERE id IN (117816);

UPDATE cities SET population = CASE id WHEN 115045 THEN 1858 ELSE population END WHERE id IN (115045);

UPDATE cities SET population = CASE id WHEN 118775 THEN 1856 ELSE population END WHERE id IN (118775);

UPDATE cities SET population = CASE id WHEN 118788 THEN 1854 WHEN 127359 THEN 1854 ELSE population END WHERE id IN (118788,127359);

UPDATE cities SET population = CASE id WHEN 116624 THEN 1851 ELSE population END WHERE id IN (116624);

UPDATE cities SET population = CASE id WHEN 111791 THEN 1850 ELSE population END WHERE id IN (111791);

UPDATE cities SET population = CASE id WHEN 122233 THEN 1849 ELSE population END WHERE id IN (122233);

UPDATE cities SET population = CASE id WHEN 114855 THEN 1848 ELSE population END WHERE id IN (114855);

UPDATE cities SET population = CASE id WHEN 118930 THEN 1846 WHEN 123243 THEN 1846 ELSE population END WHERE id IN (118930,123243);

UPDATE cities SET population = CASE id WHEN 128017 THEN 1845 ELSE population END WHERE id IN (128017);

UPDATE cities SET population = CASE id WHEN 114534 THEN 1837 ELSE population END WHERE id IN (114534);

UPDATE cities SET population = CASE id WHEN 126489 THEN 1832 ELSE population END WHERE id IN (126489);

UPDATE cities SET population = CASE id WHEN 121454 THEN 1829 ELSE population END WHERE id IN (121454);

UPDATE cities SET population = CASE id WHEN 114380 THEN 1828 ELSE population END WHERE id IN (114380);

UPDATE cities SET population = CASE id WHEN 111198 THEN 1825 ELSE population END WHERE id IN (111198);

UPDATE cities SET population = CASE id WHEN 116301 THEN 1822 WHEN 118940 THEN 1822 ELSE population END WHERE id IN (116301,118940);

UPDATE cities SET population = CASE id WHEN 120733 THEN 1821 WHEN 122374 THEN 1821 ELSE population END WHERE id IN (120733,122374);

UPDATE cities SET population = CASE id WHEN 117021 THEN 1818 WHEN 128791 THEN 1818 ELSE population END WHERE id IN (117021,128791);

UPDATE cities SET population = CASE id WHEN 114326 THEN 1815 ELSE population END WHERE id IN (114326);

UPDATE cities SET population = CASE id WHEN 128677 THEN 1813 ELSE population END WHERE id IN (128677);

UPDATE cities SET population = CASE id WHEN 128504 THEN 1812 ELSE population END WHERE id IN (128504);

UPDATE cities SET population = CASE id WHEN 117755 THEN 1804 WHEN 119120 THEN 1804 ELSE population END WHERE id IN (117755,119120);

UPDATE cities SET population = CASE id WHEN 113601 THEN 1802 ELSE population END WHERE id IN (113601);

UPDATE cities SET population = CASE id WHEN 111418 THEN 1799 ELSE population END WHERE id IN (111418);

UPDATE cities SET population = CASE id WHEN 113106 THEN 1798 ELSE population END WHERE id IN (113106);

UPDATE cities SET population = CASE id WHEN 114605 THEN 1792 ELSE population END WHERE id IN (114605);

UPDATE cities SET population = CASE id WHEN 126575 THEN 1789 ELSE population END WHERE id IN (126575);

UPDATE cities SET population = CASE id WHEN 121775 THEN 1788 ELSE population END WHERE id IN (121775);

UPDATE cities SET population = CASE id WHEN 128396 THEN 1785 ELSE population END WHERE id IN (128396);

UPDATE cities SET population = CASE id WHEN 118073 THEN 1775 ELSE population END WHERE id IN (118073);

UPDATE cities SET population = CASE id WHEN 127054 THEN 1767 WHEN 128379 THEN 1767 ELSE population END WHERE id IN (127054,128379);

UPDATE cities SET population = CASE id WHEN 123621 THEN 1766 ELSE population END WHERE id IN (123621);

UPDATE cities SET population = CASE id WHEN 123467 THEN 1764 ELSE population END WHERE id IN (123467);

UPDATE cities SET population = CASE id WHEN 123276 THEN 1762 WHEN 124259 THEN 1762 ELSE population END WHERE id IN (123276,124259);

UPDATE cities SET population = CASE id WHEN 126803 THEN 1760 ELSE population END WHERE id IN (126803);

UPDATE cities SET population = CASE id WHEN 111959 THEN 1754 ELSE population END WHERE id IN (111959);

UPDATE cities SET population = CASE id WHEN 111328 THEN 1752 WHEN 123315 THEN 1752 ELSE population END WHERE id IN (111328,123315);

UPDATE cities SET population = CASE id WHEN 115801 THEN 1748 ELSE population END WHERE id IN (115801);

UPDATE cities SET population = CASE id WHEN 120774 THEN 1747 ELSE population END WHERE id IN (120774);

UPDATE cities SET population = CASE id WHEN 117032 THEN 1744 ELSE population END WHERE id IN (117032);

UPDATE cities SET population = CASE id WHEN 115560 THEN 1736 WHEN 115848 THEN 1736 ELSE population END WHERE id IN (115560,115848);

UPDATE cities SET population = CASE id WHEN 122176 THEN 1735 ELSE population END WHERE id IN (122176);

UPDATE cities SET population = CASE id WHEN 119651 THEN 1734 ELSE population END WHERE id IN (119651);

UPDATE cities SET population = CASE id WHEN 115217 THEN 1730 ELSE population END WHERE id IN (115217);

UPDATE cities SET population = CASE id WHEN 117837 THEN 1728 ELSE population END WHERE id IN (117837);

UPDATE cities SET population = CASE id WHEN 118244 THEN 1725 ELSE population END WHERE id IN (118244);

UPDATE cities SET population = CASE id WHEN 114852 THEN 1722 ELSE population END WHERE id IN (114852);

UPDATE cities SET population = CASE id WHEN 113613 THEN 1721 WHEN 127862 THEN 1721 ELSE population END WHERE id IN (113613,127862);

UPDATE cities SET population = CASE id WHEN 116630 THEN 1720 ELSE population END WHERE id IN (116630);

UPDATE cities SET population = CASE id WHEN 129082 THEN 1719 ELSE population END WHERE id IN (129082);

UPDATE cities SET population = CASE id WHEN 122892 THEN 1718 ELSE population END WHERE id IN (122892);

UPDATE cities SET population = CASE id WHEN 113040 THEN 1716 ELSE population END WHERE id IN (113040);

UPDATE cities SET population = CASE id WHEN 126782 THEN 1712 ELSE population END WHERE id IN (126782);

UPDATE cities SET population = CASE id WHEN 113321 THEN 1709 ELSE population END WHERE id IN (113321);

UPDATE cities SET population = CASE id WHEN 126117 THEN 1707 ELSE population END WHERE id IN (126117);

UPDATE cities SET population = CASE id WHEN 119206 THEN 1704 ELSE population END WHERE id IN (119206);

UPDATE cities SET population = CASE id WHEN 113425 THEN 1700 ELSE population END WHERE id IN (113425);

UPDATE cities SET population = CASE id WHEN 114322 THEN 1698 WHEN 117080 THEN 1698 ELSE population END WHERE id IN (114322,117080);

UPDATE cities SET population = CASE id WHEN 128515 THEN 1695 ELSE population END WHERE id IN (128515);

UPDATE cities SET population = CASE id WHEN 116399 THEN 1691 ELSE population END WHERE id IN (116399);

UPDATE cities SET population = CASE id WHEN 125081 THEN 1689 WHEN 128581 THEN 1689 ELSE population END WHERE id IN (125081,128581);

UPDATE cities SET population = CASE id WHEN 118145 THEN 1688 ELSE population END WHERE id IN (118145);

UPDATE cities SET population = CASE id WHEN 127211 THEN 1682 ELSE population END WHERE id IN (127211);

UPDATE cities SET population = CASE id WHEN 111870 THEN 1680 ELSE population END WHERE id IN (111870);

UPDATE cities SET population = CASE id WHEN 112467 THEN 1676 ELSE population END WHERE id IN (112467);

UPDATE cities SET population = CASE id WHEN 128584 THEN 1672 ELSE population END WHERE id IN (128584);

UPDATE cities SET population = CASE id WHEN 112176 THEN 1669 ELSE population END WHERE id IN (112176);

UPDATE cities SET population = CASE id WHEN 120058 THEN 1668 ELSE population END WHERE id IN (120058);

UPDATE cities SET population = CASE id WHEN 117805 THEN 1666 ELSE population END WHERE id IN (117805);

UPDATE cities SET population = CASE id WHEN 113090 THEN 1660 ELSE population END WHERE id IN (113090);

UPDATE cities SET population = CASE id WHEN 116660 THEN 1659 ELSE population END WHERE id IN (116660);

UPDATE cities SET population = CASE id WHEN 126218 THEN 1654 ELSE population END WHERE id IN (126218);

UPDATE cities SET population = CASE id WHEN 119922 THEN 1652 ELSE population END WHERE id IN (119922);

UPDATE cities SET population = CASE id WHEN 119227 THEN 1651 ELSE population END WHERE id IN (119227);

UPDATE cities SET population = CASE id WHEN 120693 THEN 1649 WHEN 124499 THEN 1649 ELSE population END WHERE id IN (120693,124499);

UPDATE cities SET population = CASE id WHEN 118015 THEN 1639 ELSE population END WHERE id IN (118015);

UPDATE cities SET population = CASE id WHEN 122452 THEN 1634 ELSE population END WHERE id IN (122452);

UPDATE cities SET population = CASE id WHEN 115200 THEN 1633 ELSE population END WHERE id IN (115200);

UPDATE cities SET population = CASE id WHEN 118542 THEN 1630 ELSE population END WHERE id IN (118542);

UPDATE cities SET population = CASE id WHEN 114510 THEN 1625 WHEN 119039 THEN 1625 ELSE population END WHERE id IN (114510,119039);

UPDATE cities SET population = CASE id WHEN 111045 THEN 1622 ELSE population END WHERE id IN (111045);

UPDATE cities SET population = CASE id WHEN 112088 THEN 1621 WHEN 112611 THEN 1621 WHEN 118954 THEN 1621 WHEN 122570 THEN 1621 ELSE population END WHERE id IN (112088,112611,118954,122570);

UPDATE cities SET population = CASE id WHEN 112278 THEN 1620 ELSE population END WHERE id IN (112278);

UPDATE cities SET population = CASE id WHEN 116513 THEN 1618 ELSE population END WHERE id IN (116513);

UPDATE cities SET population = CASE id WHEN 118098 THEN 1616 ELSE population END WHERE id IN (118098);

UPDATE cities SET population = CASE id WHEN 121150 THEN 1615 WHEN 125125 THEN 1615 ELSE population END WHERE id IN (121150,125125);

UPDATE cities SET population = CASE id WHEN 129503 THEN 1611 ELSE population END WHERE id IN (129503);

UPDATE cities SET population = CASE id WHEN 115646 THEN 1608 ELSE population END WHERE id IN (115646);

UPDATE cities SET population = CASE id WHEN 125337 THEN 1602 ELSE population END WHERE id IN (125337);

UPDATE cities SET population = CASE id WHEN 112869 THEN 1601 ELSE population END WHERE id IN (112869);

UPDATE cities SET population = CASE id WHEN 121371 THEN 1597 WHEN 122749 THEN 1597 ELSE population END WHERE id IN (121371,122749);

UPDATE cities SET population = CASE id WHEN 126831 THEN 1594 ELSE population END WHERE id IN (126831);

UPDATE cities SET population = CASE id WHEN 117407 THEN 1589 ELSE population END WHERE id IN (117407);

UPDATE cities SET population = CASE id WHEN 128769 THEN 1586 ELSE population END WHERE id IN (128769);

UPDATE cities SET population = CASE id WHEN 122480 THEN 1580 ELSE population END WHERE id IN (122480);

UPDATE cities SET population = CASE id WHEN 120765 THEN 1579 ELSE population END WHERE id IN (120765);

UPDATE cities SET population = CASE id WHEN 113881 THEN 1568 ELSE population END WHERE id IN (113881);

UPDATE cities SET population = CASE id WHEN 120706 THEN 1564 ELSE population END WHERE id IN (120706);

UPDATE cities SET population = CASE id WHEN 116551 THEN 1556 ELSE population END WHERE id IN (116551);

UPDATE cities SET population = CASE id WHEN 117875 THEN 1551 WHEN 118819 THEN 1551 ELSE population END WHERE id IN (117875,118819);

UPDATE cities SET population = CASE id WHEN 117947 THEN 1550 ELSE population END WHERE id IN (117947);

UPDATE cities SET population = CASE id WHEN 129560 THEN 1547 ELSE population END WHERE id IN (129560);

UPDATE cities SET population = CASE id WHEN 114979 THEN 1544 ELSE population END WHERE id IN (114979);

UPDATE cities SET population = CASE id WHEN 117310 THEN 1543 WHEN 125369 THEN 1543 ELSE population END WHERE id IN (117310,125369);

UPDATE cities SET population = CASE id WHEN 124967 THEN 1541 ELSE population END WHERE id IN (124967);

UPDATE cities SET population = CASE id WHEN 114795 THEN 1540 WHEN 122116 THEN 1540 ELSE population END WHERE id IN (114795,122116);

UPDATE cities SET population = CASE id WHEN 116093 THEN 1535 ELSE population END WHERE id IN (116093);

UPDATE cities SET population = CASE id WHEN 122828 THEN 1534 ELSE population END WHERE id IN (122828);

UPDATE cities SET population = CASE id WHEN 114301 THEN 1529 ELSE population END WHERE id IN (114301);

UPDATE cities SET population = CASE id WHEN 112078 THEN 1528 ELSE population END WHERE id IN (112078);

UPDATE cities SET population = CASE id WHEN 120730 THEN 1525 ELSE population END WHERE id IN (120730);

UPDATE cities SET population = CASE id WHEN 114404 THEN 1524 ELSE population END WHERE id IN (114404);

UPDATE cities SET population = CASE id WHEN 122393 THEN 1518 ELSE population END WHERE id IN (122393);

UPDATE cities SET population = CASE id WHEN 117486 THEN 1517 ELSE population END WHERE id IN (117486);

UPDATE cities SET population = CASE id WHEN 128286 THEN 1516 ELSE population END WHERE id IN (128286);

UPDATE cities SET population = CASE id WHEN 122408 THEN 1514 ELSE population END WHERE id IN (122408);

UPDATE cities SET population = CASE id WHEN 118459 THEN 1513 WHEN 129352 THEN 1513 ELSE population END WHERE id IN (118459,129352);

UPDATE cities SET population = CASE id WHEN 111642 THEN 1508 WHEN 121582 THEN 1508 ELSE population END WHERE id IN (111642,121582);

UPDATE cities SET population = CASE id WHEN 111687 THEN 1504 WHEN 114110 THEN 1504 ELSE population END WHERE id IN (111687,114110);

UPDATE cities SET population = CASE id WHEN 112366 THEN 1500 WHEN 122051 THEN 1500 ELSE population END WHERE id IN (112366,122051);

UPDATE cities SET population = CASE id WHEN 125067 THEN 1496 WHEN 129291 THEN 1496 ELSE population END WHERE id IN (125067,129291);

UPDATE cities SET population = CASE id WHEN 117676 THEN 1495 ELSE population END WHERE id IN (117676);

UPDATE cities SET population = CASE id WHEN 113630 THEN 1494 WHEN 129034 THEN 1494 ELSE population END WHERE id IN (113630,129034);

UPDATE cities SET population = CASE id WHEN 120920 THEN 1490 WHEN 126951 THEN 1490 ELSE population END WHERE id IN (120920,126951);

UPDATE cities SET population = CASE id WHEN 128065 THEN 1489 ELSE population END WHERE id IN (128065);

UPDATE cities SET population = CASE id WHEN 121511 THEN 1484 ELSE population END WHERE id IN (121511);

UPDATE cities SET population = CASE id WHEN 113796 THEN 1481 ELSE population END WHERE id IN (113796);

UPDATE cities SET population = CASE id WHEN 120551 THEN 1479 ELSE population END WHERE id IN (120551);

UPDATE cities SET population = CASE id WHEN 115874 THEN 1478 ELSE population END WHERE id IN (115874);

UPDATE cities SET population = CASE id WHEN 118172 THEN 1475 ELSE population END WHERE id IN (118172);

UPDATE cities SET population = CASE id WHEN 111906 THEN 1474 ELSE population END WHERE id IN (111906);

UPDATE cities SET population = CASE id WHEN 113086 THEN 1473 WHEN 129067 THEN 1473 ELSE population END WHERE id IN (113086,129067);

UPDATE cities SET population = CASE id WHEN 122857 THEN 1472 WHEN 125421 THEN 1472 ELSE population END WHERE id IN (122857,125421);

UPDATE cities SET population = CASE id WHEN 126779 THEN 1470 ELSE population END WHERE id IN (126779);

UPDATE cities SET population = CASE id WHEN 129634 THEN 1465 ELSE population END WHERE id IN (129634);

UPDATE cities SET population = CASE id WHEN 123583 THEN 1463 ELSE population END WHERE id IN (123583);

UPDATE cities SET population = CASE id WHEN 125275 THEN 1456 ELSE population END WHERE id IN (125275);

UPDATE cities SET population = CASE id WHEN 128200 THEN 1455 ELSE population END WHERE id IN (128200);

UPDATE cities SET population = CASE id WHEN 111076 THEN 1450 ELSE population END WHERE id IN (111076);

UPDATE cities SET population = CASE id WHEN 120113 THEN 1447 ELSE population END WHERE id IN (120113);

UPDATE cities SET population = CASE id WHEN 121070 THEN 1446 ELSE population END WHERE id IN (121070);

UPDATE cities SET population = CASE id WHEN 126360 THEN 1441 ELSE population END WHERE id IN (126360);

UPDATE cities SET population = CASE id WHEN 117729 THEN 1439 ELSE population END WHERE id IN (117729);

UPDATE cities SET population = CASE id WHEN 117811 THEN 1437 ELSE population END WHERE id IN (117811);

UPDATE cities SET population = CASE id WHEN 124088 THEN 1432 ELSE population END WHERE id IN (124088);

UPDATE cities SET population = CASE id WHEN 125879 THEN 1429 ELSE population END WHERE id IN (125879);

UPDATE cities SET population = CASE id WHEN 127751 THEN 1428 WHEN 129596 THEN 1428 ELSE population END WHERE id IN (127751,129596);

UPDATE cities SET population = CASE id WHEN 117478 THEN 1427 WHEN 122087 THEN 1427 WHEN 124830 THEN 1427 ELSE population END WHERE id IN (117478,122087,124830);

UPDATE cities SET population = CASE id WHEN 129070 THEN 1422 ELSE population END WHERE id IN (129070);

UPDATE cities SET population = CASE id WHEN 126751 THEN 1421 ELSE population END WHERE id IN (126751);

UPDATE cities SET population = CASE id WHEN 120731 THEN 1415 ELSE population END WHERE id IN (120731);

UPDATE cities SET population = CASE id WHEN 120661 THEN 1410 ELSE population END WHERE id IN (120661);

UPDATE cities SET population = CASE id WHEN 115562 THEN 1409 ELSE population END WHERE id IN (115562);

UPDATE cities SET population = CASE id WHEN 123445 THEN 1408 ELSE population END WHERE id IN (123445);

UPDATE cities SET population = CASE id WHEN 111460 THEN 1406 WHEN 126227 THEN 1406 ELSE population END WHERE id IN (111460,126227);

UPDATE cities SET population = CASE id WHEN 119011 THEN 1405 ELSE population END WHERE id IN (119011);

UPDATE cities SET population = CASE id WHEN 118209 THEN 1404 ELSE population END WHERE id IN (118209);

UPDATE cities SET population = CASE id WHEN 116470 THEN 1402 ELSE population END WHERE id IN (116470);

UPDATE cities SET population = CASE id WHEN 119565 THEN 1401 ELSE population END WHERE id IN (119565);

UPDATE cities SET population = CASE id WHEN 122793 THEN 1400 ELSE population END WHERE id IN (122793);

UPDATE cities SET population = CASE id WHEN 115444 THEN 1398 ELSE population END WHERE id IN (115444);

UPDATE cities SET population = CASE id WHEN 118031 THEN 1397 ELSE population END WHERE id IN (118031);

UPDATE cities SET population = CASE id WHEN 113387 THEN 1396 WHEN 114902 THEN 1396 WHEN 119617 THEN 1396 ELSE population END WHERE id IN (113387,114902,119617);

UPDATE cities SET population = CASE id WHEN 118997 THEN 1392 ELSE population END WHERE id IN (118997);

UPDATE cities SET population = CASE id WHEN 116901 THEN 1388 WHEN 117656 THEN 1388 ELSE population END WHERE id IN (116901,117656);

UPDATE cities SET population = CASE id WHEN 116359 THEN 1386 WHEN 116934 THEN 1386 WHEN 117724 THEN 1386 ELSE population END WHERE id IN (116359,116934,117724);

UPDATE cities SET population = CASE id WHEN 120375 THEN 1385 WHEN 125853 THEN 1385 ELSE population END WHERE id IN (120375,125853);

UPDATE cities SET population = CASE id WHEN 111914 THEN 1384 ELSE population END WHERE id IN (111914);

UPDATE cities SET population = CASE id WHEN 128681 THEN 1382 ELSE population END WHERE id IN (128681);

UPDATE cities SET population = CASE id WHEN 128417 THEN 1378 ELSE population END WHERE id IN (128417);

UPDATE cities SET population = CASE id WHEN 125411 THEN 1373 ELSE population END WHERE id IN (125411);

UPDATE cities SET population = CASE id WHEN 118730 THEN 1370 ELSE population END WHERE id IN (118730);

UPDATE cities SET population = CASE id WHEN 113628 THEN 1368 ELSE population END WHERE id IN (113628);

UPDATE cities SET population = CASE id WHEN 111048 THEN 1366 ELSE population END WHERE id IN (111048);

UPDATE cities SET population = CASE id WHEN 114104 THEN 1365 ELSE population END WHERE id IN (114104);

UPDATE cities SET population = CASE id WHEN 118520 THEN 1361 WHEN 118944 THEN 1361 ELSE population END WHERE id IN (118520,118944);

UPDATE cities SET population = CASE id WHEN 122280 THEN 1358 WHEN 124238 THEN 1358 ELSE population END WHERE id IN (122280,124238);

UPDATE cities SET population = CASE id WHEN 121995 THEN 1356 ELSE population END WHERE id IN (121995);

UPDATE cities SET population = CASE id WHEN 120642 THEN 1354 ELSE population END WHERE id IN (120642);

UPDATE cities SET population = CASE id WHEN 114768 THEN 1352 WHEN 124893 THEN 1352 ELSE population END WHERE id IN (114768,124893);

UPDATE cities SET population = CASE id WHEN 122663 THEN 1350 WHEN 128413 THEN 1350 ELSE population END WHERE id IN (122663,128413);

UPDATE cities SET population = CASE id WHEN 122624 THEN 1347 ELSE population END WHERE id IN (122624);

UPDATE cities SET population = CASE id WHEN 126549 THEN 1345 ELSE population END WHERE id IN (126549);

UPDATE cities SET population = CASE id WHEN 112474 THEN 1341 WHEN 118177 THEN 1341 ELSE population END WHERE id IN (112474,118177);

UPDATE cities SET population = CASE id WHEN 114382 THEN 1337 ELSE population END WHERE id IN (114382);

UPDATE cities SET population = CASE id WHEN 123736 THEN 1331 ELSE population END WHERE id IN (123736);

UPDATE cities SET population = CASE id WHEN 112886 THEN 1329 ELSE population END WHERE id IN (112886);

UPDATE cities SET population = CASE id WHEN 114883 THEN 1327 ELSE population END WHERE id IN (114883);

UPDATE cities SET population = CASE id WHEN 119344 THEN 1324 WHEN 123979 THEN 1324 ELSE population END WHERE id IN (119344,123979);

UPDATE cities SET population = CASE id WHEN 112588 THEN 1323 ELSE population END WHERE id IN (112588);

UPDATE cities SET population = CASE id WHEN 112272 THEN 1322 WHEN 127071 THEN 1322 ELSE population END WHERE id IN (112272,127071);

UPDATE cities SET population = CASE id WHEN 111395 THEN 1321 ELSE population END WHERE id IN (111395);

UPDATE cities SET population = CASE id WHEN 118138 THEN 1318 ELSE population END WHERE id IN (118138);

UPDATE cities SET population = CASE id WHEN 115997 THEN 1317 WHEN 127098 THEN 1317 ELSE population END WHERE id IN (115997,127098);

UPDATE cities SET population = CASE id WHEN 114240 THEN 1315 ELSE population END WHERE id IN (114240);

UPDATE cities SET population = CASE id WHEN 112937 THEN 1309 ELSE population END WHERE id IN (112937);

UPDATE cities SET population = CASE id WHEN 111992 THEN 1308 WHEN 123756 THEN 1308 WHEN 125786 THEN 1308 WHEN 128904 THEN 1308 ELSE population END WHERE id IN (111992,123756,125786,128904);

UPDATE cities SET population = CASE id WHEN 127257 THEN 1303 ELSE population END WHERE id IN (127257);

UPDATE cities SET population = CASE id WHEN 112916 THEN 1301 WHEN 128370 THEN 1301 ELSE population END WHERE id IN (112916,128370);

UPDATE cities SET population = CASE id WHEN 121301 THEN 1300 ELSE population END WHERE id IN (121301);

UPDATE cities SET population = CASE id WHEN 125660 THEN 1295 ELSE population END WHERE id IN (125660);

UPDATE cities SET population = CASE id WHEN 122329 THEN 1292 ELSE population END WHERE id IN (122329);

UPDATE cities SET population = CASE id WHEN 122776 THEN 1291 ELSE population END WHERE id IN (122776);

UPDATE cities SET population = CASE id WHEN 126579 THEN 1288 ELSE population END WHERE id IN (126579);

UPDATE cities SET population = CASE id WHEN 117171 THEN 1285 WHEN 123665 THEN 1285 WHEN 129494 THEN 1285 ELSE population END WHERE id IN (117171,123665,129494);

UPDATE cities SET population = CASE id WHEN 116453 THEN 1284 ELSE population END WHERE id IN (116453);

UPDATE cities SET population = CASE id WHEN 111673 THEN 1283 ELSE population END WHERE id IN (111673);

UPDATE cities SET population = CASE id WHEN 117926 THEN 1281 ELSE population END WHERE id IN (117926);

UPDATE cities SET population = CASE id WHEN 116919 THEN 1280 WHEN 118439 THEN 1280 ELSE population END WHERE id IN (116919,118439);

UPDATE cities SET population = CASE id WHEN 120908 THEN 1277 ELSE population END WHERE id IN (120908);

UPDATE cities SET population = CASE id WHEN 120956 THEN 1274 ELSE population END WHERE id IN (120956);

UPDATE cities SET population = CASE id WHEN 113131 THEN 1273 ELSE population END WHERE id IN (113131);

UPDATE cities SET population = CASE id WHEN 114717 THEN 1272 ELSE population END WHERE id IN (114717);

UPDATE cities SET population = CASE id WHEN 116056 THEN 1271 ELSE population END WHERE id IN (116056);

UPDATE cities SET population = CASE id WHEN 115194 THEN 1270 ELSE population END WHERE id IN (115194);

UPDATE cities SET population = CASE id WHEN 114599 THEN 1269 ELSE population END WHERE id IN (114599);

UPDATE cities SET population = CASE id WHEN 123734 THEN 1268 WHEN 128665 THEN 1268 ELSE population END WHERE id IN (123734,128665);

UPDATE cities SET population = CASE id WHEN 115795 THEN 1266 WHEN 116981 THEN 1266 ELSE population END WHERE id IN (115795,116981);

UPDATE cities SET population = CASE id WHEN 113245 THEN 1265 WHEN 116540 THEN 1265 ELSE population END WHERE id IN (113245,116540);

UPDATE cities SET population = CASE id WHEN 112830 THEN 1264 WHEN 114699 THEN 1264 ELSE population END WHERE id IN (112830,114699);

UPDATE cities SET population = CASE id WHEN 119743 THEN 1262 WHEN 128728 THEN 1262 ELSE population END WHERE id IN (119743,128728);

UPDATE cities SET population = CASE id WHEN 117826 THEN 1261 ELSE population END WHERE id IN (117826);

UPDATE cities SET population = CASE id WHEN 122470 THEN 1259 ELSE population END WHERE id IN (122470);

UPDATE cities SET population = CASE id WHEN 112046 THEN 1258 WHEN 122558 THEN 1258 ELSE population END WHERE id IN (112046,122558);

UPDATE cities SET population = CASE id WHEN 114656 THEN 1256 ELSE population END WHERE id IN (114656);

UPDATE cities SET population = CASE id WHEN 120196 THEN 1254 WHEN 123642 THEN 1254 ELSE population END WHERE id IN (120196,123642);

UPDATE cities SET population = CASE id WHEN 115330 THEN 1253 WHEN 116108 THEN 1253 ELSE population END WHERE id IN (115330,116108);

UPDATE cities SET population = CASE id WHEN 116948 THEN 1252 ELSE population END WHERE id IN (116948);

UPDATE cities SET population = CASE id WHEN 117387 THEN 1248 ELSE population END WHERE id IN (117387);

UPDATE cities SET population = CASE id WHEN 114527 THEN 1245 ELSE population END WHERE id IN (114527);

UPDATE cities SET population = CASE id WHEN 114318 THEN 1243 ELSE population END WHERE id IN (114318);

UPDATE cities SET population = CASE id WHEN 111166 THEN 1241 ELSE population END WHERE id IN (111166);

UPDATE cities SET population = CASE id WHEN 121442 THEN 1237 ELSE population END WHERE id IN (121442);

UPDATE cities SET population = CASE id WHEN 117176 THEN 1235 ELSE population END WHERE id IN (117176);

UPDATE cities SET population = CASE id WHEN 122983 THEN 1234 ELSE population END WHERE id IN (122983);

UPDATE cities SET population = CASE id WHEN 128509 THEN 1233 ELSE population END WHERE id IN (128509);

UPDATE cities SET population = CASE id WHEN 125354 THEN 1231 ELSE population END WHERE id IN (125354);

UPDATE cities SET population = CASE id WHEN 125947 THEN 1229 ELSE population END WHERE id IN (125947);

UPDATE cities SET population = CASE id WHEN 128219 THEN 1226 ELSE population END WHERE id IN (128219);

UPDATE cities SET population = CASE id WHEN 122797 THEN 1225 ELSE population END WHERE id IN (122797);

UPDATE cities SET population = CASE id WHEN 119497 THEN 1224 WHEN 119503 THEN 1224 ELSE population END WHERE id IN (119497,119503);

UPDATE cities SET population = CASE id WHEN 129654 THEN 1223 ELSE population END WHERE id IN (129654);

UPDATE cities SET population = CASE id WHEN 127698 THEN 1221 ELSE population END WHERE id IN (127698);

UPDATE cities SET population = CASE id WHEN 116280 THEN 1215 ELSE population END WHERE id IN (116280);

UPDATE cities SET population = CASE id WHEN 119306 THEN 1214 WHEN 121174 THEN 1214 ELSE population END WHERE id IN (119306,121174);

UPDATE cities SET population = CASE id WHEN 111441 THEN 1213 WHEN 124907 THEN 1213 ELSE population END WHERE id IN (111441,124907);

UPDATE cities SET population = CASE id WHEN 120553 THEN 1211 ELSE population END WHERE id IN (120553);

UPDATE cities SET population = CASE id WHEN 115484 THEN 1208 ELSE population END WHERE id IN (115484);

UPDATE cities SET population = CASE id WHEN 112837 THEN 1205 ELSE population END WHERE id IN (112837);

UPDATE cities SET population = CASE id WHEN 117400 THEN 1204 ELSE population END WHERE id IN (117400);

UPDATE cities SET population = CASE id WHEN 125532 THEN 1203 ELSE population END WHERE id IN (125532);

UPDATE cities SET population = CASE id WHEN 124712 THEN 1200 ELSE population END WHERE id IN (124712);

UPDATE cities SET population = CASE id WHEN 129552 THEN 1196 ELSE population END WHERE id IN (129552);

UPDATE cities SET population = CASE id WHEN 112098 THEN 1193 ELSE population END WHERE id IN (112098);

UPDATE cities SET population = CASE id WHEN 111614 THEN 1191 ELSE population END WHERE id IN (111614);

UPDATE cities SET population = CASE id WHEN 116077 THEN 1188 ELSE population END WHERE id IN (116077);

UPDATE cities SET population = CASE id WHEN 119007 THEN 1184 WHEN 125234 THEN 1184 WHEN 126390 THEN 1184 ELSE population END WHERE id IN (119007,125234,126390);

UPDATE cities SET population = CASE id WHEN 120434 THEN 1181 ELSE population END WHERE id IN (120434);

UPDATE cities SET population = CASE id WHEN 122344 THEN 1180 ELSE population END WHERE id IN (122344);

UPDATE cities SET population = CASE id WHEN 125670 THEN 1176 ELSE population END WHERE id IN (125670);

UPDATE cities SET population = CASE id WHEN 113587 THEN 1175 WHEN 124382 THEN 1175 ELSE population END WHERE id IN (113587,124382);

UPDATE cities SET population = CASE id WHEN 121612 THEN 1172 WHEN 129447 THEN 1172 ELSE population END WHERE id IN (121612,129447);

UPDATE cities SET population = CASE id WHEN 111239 THEN 1167 ELSE population END WHERE id IN (111239);

UPDATE cities SET population = CASE id WHEN 125014 THEN 1163 WHEN 128501 THEN 1163 ELSE population END WHERE id IN (125014,128501);

UPDATE cities SET population = CASE id WHEN 129377 THEN 1162 ELSE population END WHERE id IN (129377);

UPDATE cities SET population = CASE id WHEN 121939 THEN 1161 ELSE population END WHERE id IN (121939);

UPDATE cities SET population = CASE id WHEN 116875 THEN 1157 WHEN 121194 THEN 1157 WHEN 128106 THEN 1157 ELSE population END WHERE id IN (116875,121194,128106);

UPDATE cities SET population = CASE id WHEN 112969 THEN 1156 ELSE population END WHERE id IN (112969);

UPDATE cities SET population = CASE id WHEN 129742 THEN 1153 ELSE population END WHERE id IN (129742);

UPDATE cities SET population = CASE id WHEN 121067 THEN 1152 ELSE population END WHERE id IN (121067);

UPDATE cities SET population = CASE id WHEN 118592 THEN 1144 WHEN 123953 THEN 1144 ELSE population END WHERE id IN (118592,123953);

UPDATE cities SET population = CASE id WHEN 125495 THEN 1138 ELSE population END WHERE id IN (125495);

UPDATE cities SET population = CASE id WHEN 127421 THEN 1134 ELSE population END WHERE id IN (127421);

UPDATE cities SET population = CASE id WHEN 120963 THEN 1131 ELSE population END WHERE id IN (120963);

UPDATE cities SET population = CASE id WHEN 113959 THEN 1130 ELSE population END WHERE id IN (113959);

UPDATE cities SET population = CASE id WHEN 118537 THEN 1129 WHEN 123817 THEN 1129 ELSE population END WHERE id IN (118537,123817);

UPDATE cities SET population = CASE id WHEN 128533 THEN 1128 ELSE population END WHERE id IN (128533);

UPDATE cities SET population = CASE id WHEN 111612 THEN 1124 ELSE population END WHERE id IN (111612);

UPDATE cities SET population = CASE id WHEN 117908 THEN 1123 ELSE population END WHERE id IN (117908);

UPDATE cities SET population = CASE id WHEN 117628 THEN 1120 WHEN 125258 THEN 1120 ELSE population END WHERE id IN (117628,125258);

UPDATE cities SET population = CASE id WHEN 128029 THEN 1119 ELSE population END WHERE id IN (128029);

UPDATE cities SET population = CASE id WHEN 124342 THEN 1117 ELSE population END WHERE id IN (124342);

UPDATE cities SET population = CASE id WHEN 117202 THEN 1116 ELSE population END WHERE id IN (117202);

UPDATE cities SET population = CASE id WHEN 112471 THEN 1111 ELSE population END WHERE id IN (112471);

UPDATE cities SET population = CASE id WHEN 112844 THEN 1110 ELSE population END WHERE id IN (112844);

UPDATE cities SET population = CASE id WHEN 125548 THEN 1109 ELSE population END WHERE id IN (125548);

UPDATE cities SET population = CASE id WHEN 115866 THEN 1108 WHEN 120831 THEN 1108 ELSE population END WHERE id IN (115866,120831);

UPDATE cities SET population = CASE id WHEN 116164 THEN 1105 ELSE population END WHERE id IN (116164);

UPDATE cities SET population = CASE id WHEN 124756 THEN 1103 WHEN 127530 THEN 1103 ELSE population END WHERE id IN (124756,127530);

UPDATE cities SET population = CASE id WHEN 112373 THEN 1101 WHEN 126728 THEN 1101 WHEN 127196 THEN 1101 ELSE population END WHERE id IN (112373,126728,127196);

UPDATE cities SET population = CASE id WHEN 111881 THEN 1100 WHEN 114568 THEN 1100 ELSE population END WHERE id IN (111881,114568);

UPDATE cities SET population = CASE id WHEN 121142 THEN 1096 ELSE population END WHERE id IN (121142);

UPDATE cities SET population = CASE id WHEN 111356 THEN 1095 ELSE population END WHERE id IN (111356);

UPDATE cities SET population = CASE id WHEN 113477 THEN 1090 ELSE population END WHERE id IN (113477);

UPDATE cities SET population = CASE id WHEN 111561 THEN 1086 WHEN 123611 THEN 1086 ELSE population END WHERE id IN (111561,123611);

UPDATE cities SET population = CASE id WHEN 128537 THEN 1085 ELSE population END WHERE id IN (128537);

UPDATE cities SET population = CASE id WHEN 121812 THEN 1084 ELSE population END WHERE id IN (121812);

UPDATE cities SET population = CASE id WHEN 112343 THEN 1083 ELSE population END WHERE id IN (112343);

UPDATE cities SET population = CASE id WHEN 121269 THEN 1082 WHEN 122706 THEN 1082 ELSE population END WHERE id IN (121269,122706);

UPDATE cities SET population = CASE id WHEN 127007 THEN 1078 ELSE population END WHERE id IN (127007);

UPDATE cities SET population = CASE id WHEN 121416 THEN 1076 WHEN 124227 THEN 1076 ELSE population END WHERE id IN (121416,124227);

UPDATE cities SET population = CASE id WHEN 120492 THEN 1075 WHEN 124154 THEN 1075 ELSE population END WHERE id IN (120492,124154);

UPDATE cities SET population = CASE id WHEN 129154 THEN 1074 ELSE population END WHERE id IN (129154);

UPDATE cities SET population = CASE id WHEN 114827 THEN 1071 ELSE population END WHERE id IN (114827);

UPDATE cities SET population = CASE id WHEN 113942 THEN 1069 WHEN 129463 THEN 1069 ELSE population END WHERE id IN (113942,129463);

UPDATE cities SET population = CASE id WHEN 117113 THEN 1067 ELSE population END WHERE id IN (117113);

UPDATE cities SET population = CASE id WHEN 117700 THEN 1066 ELSE population END WHERE id IN (117700);

UPDATE cities SET population = CASE id WHEN 111276 THEN 1064 ELSE population END WHERE id IN (111276);

UPDATE cities SET population = CASE id WHEN 122411 THEN 1061 ELSE population END WHERE id IN (122411);

UPDATE cities SET population = CASE id WHEN 122838 THEN 1058 ELSE population END WHERE id IN (122838);

UPDATE cities SET population = CASE id WHEN 115106 THEN 1057 ELSE population END WHERE id IN (115106);

UPDATE cities SET population = CASE id WHEN 120926 THEN 1055 ELSE population END WHERE id IN (120926);

UPDATE cities SET population = CASE id WHEN 118392 THEN 1054 ELSE population END WHERE id IN (118392);

UPDATE cities SET population = CASE id WHEN 112433 THEN 1052 WHEN 116215 THEN 1052 ELSE population END WHERE id IN (112433,116215);

UPDATE cities SET population = CASE id WHEN 115869 THEN 1051 WHEN 123148 THEN 1051 ELSE population END WHERE id IN (115869,123148);

UPDATE cities SET population = CASE id WHEN 111052 THEN 1050 WHEN 121634 THEN 1050 ELSE population END WHERE id IN (111052,121634);

UPDATE cities SET population = CASE id WHEN 112009 THEN 1049 ELSE population END WHERE id IN (112009);

UPDATE cities SET population = CASE id WHEN 113411 THEN 1048 ELSE population END WHERE id IN (113411);

UPDATE cities SET population = CASE id WHEN 111975 THEN 1047 WHEN 115595 THEN 1047 ELSE population END WHERE id IN (111975,115595);

UPDATE cities SET population = CASE id WHEN 120720 THEN 1046 ELSE population END WHERE id IN (120720);

UPDATE cities SET population = CASE id WHEN 126267 THEN 1044 WHEN 126394 THEN 1044 ELSE population END WHERE id IN (126267,126394);

UPDATE cities SET population = CASE id WHEN 125700 THEN 1031 ELSE population END WHERE id IN (125700);

UPDATE cities SET population = CASE id WHEN 113179 THEN 1030 ELSE population END WHERE id IN (113179);

UPDATE cities SET population = CASE id WHEN 122993 THEN 1029 WHEN 125698 THEN 1029 ELSE population END WHERE id IN (122993,125698);

UPDATE cities SET population = CASE id WHEN 122278 THEN 1028 WHEN 127463 THEN 1028 ELSE population END WHERE id IN (122278,127463);

UPDATE cities SET population = CASE id WHEN 124840 THEN 1026 ELSE population END WHERE id IN (124840);

UPDATE cities SET population = CASE id WHEN 127781 THEN 1025 ELSE population END WHERE id IN (127781);

UPDATE cities SET population = CASE id WHEN 117762 THEN 1024 WHEN 123649 THEN 1024 ELSE population END WHERE id IN (117762,123649);

UPDATE cities SET population = CASE id WHEN 120922 THEN 1023 ELSE population END WHERE id IN (120922);

UPDATE cities SET population = CASE id WHEN 117645 THEN 1020 ELSE population END WHERE id IN (117645);

UPDATE cities SET population = CASE id WHEN 115886 THEN 1019 ELSE population END WHERE id IN (115886);

UPDATE cities SET population = CASE id WHEN 115519 THEN 1018 ELSE population END WHERE id IN (115519);

UPDATE cities SET population = CASE id WHEN 113188 THEN 1017 ELSE population END WHERE id IN (113188);

UPDATE cities SET population = CASE id WHEN 113845 THEN 1014 WHEN 117384 THEN 1014 WHEN 120323 THEN 1014 ELSE population END WHERE id IN (113845,117384,120323);

UPDATE cities SET population = CASE id WHEN 120823 THEN 1013 ELSE population END WHERE id IN (120823);

UPDATE cities SET population = CASE id WHEN 112664 THEN 1011 WHEN 117405 THEN 1011 WHEN 119644 THEN 1011 WHEN 123948 THEN 1011 ELSE population END WHERE id IN (112664,117405,119644,123948);

UPDATE cities SET population = CASE id WHEN 111413 THEN 1010 ELSE population END WHERE id IN (111413);

UPDATE cities SET population = CASE id WHEN 111841 THEN 1009 WHEN 123780 THEN 1009 ELSE population END WHERE id IN (111841,123780);

UPDATE cities SET population = CASE id WHEN 119578 THEN 1006 ELSE population END WHERE id IN (119578);

UPDATE cities SET population = CASE id WHEN 119737 THEN 1005 ELSE population END WHERE id IN (119737);

UPDATE cities SET population = CASE id WHEN 113463 THEN 988 ELSE population END WHERE id IN (113463);

UPDATE cities SET population = CASE id WHEN 121591 THEN 987 ELSE population END WHERE id IN (121591);

UPDATE cities SET population = CASE id WHEN 127311 THEN 984 ELSE population END WHERE id IN (127311);

UPDATE cities SET population = CASE id WHEN 112802 THEN 976 ELSE population END WHERE id IN (112802);

UPDATE cities SET population = CASE id WHEN 122740 THEN 969 ELSE population END WHERE id IN (122740);

UPDATE cities SET population = CASE id WHEN 117997 THEN 934 ELSE population END WHERE id IN (117997);

UPDATE cities SET population = CASE id WHEN 115364 THEN 898 ELSE population END WHERE id IN (115364);

UPDATE cities SET population = CASE id WHEN 121129 THEN 840 ELSE population END WHERE id IN (121129);

UPDATE cities SET population = CASE id WHEN 115971 THEN 839 ELSE population END WHERE id IN (115971);

UPDATE cities SET population = CASE id WHEN 113925 THEN 824 ELSE population END WHERE id IN (113925);

UPDATE cities SET population = CASE id WHEN 114974 THEN 813 ELSE population END WHERE id IN (114974);

UPDATE cities SET population = CASE id WHEN 117506 THEN 812 ELSE population END WHERE id IN (117506);

UPDATE cities SET population = CASE id WHEN 114392 THEN 806 ELSE population END WHERE id IN (114392);

UPDATE cities SET population = CASE id WHEN 123545 THEN 776 ELSE population END WHERE id IN (123545);

UPDATE cities SET population = CASE id WHEN 129052 THEN 774 ELSE population END WHERE id IN (129052);

UPDATE cities SET population = CASE id WHEN 129453 THEN 745 ELSE population END WHERE id IN (129453);

UPDATE cities SET population = CASE id WHEN 111543 THEN 726 ELSE population END WHERE id IN (111543);

UPDATE cities SET population = CASE id WHEN 129221 THEN 685 ELSE population END WHERE id IN (129221);

UPDATE cities SET population = CASE id WHEN 118931 THEN 684 ELSE population END WHERE id IN (118931);

UPDATE cities SET population = CASE id WHEN 126441 THEN 637 ELSE population END WHERE id IN (126441);

UPDATE cities SET population = CASE id WHEN 113640 THEN 628 ELSE population END WHERE id IN (113640);

UPDATE cities SET population = CASE id WHEN 118707 THEN 621 ELSE population END WHERE id IN (118707);

UPDATE cities SET population = CASE id WHEN 125237 THEN 598 ELSE population END WHERE id IN (125237);

UPDATE cities SET population = CASE id WHEN 118106 THEN 596 ELSE population END WHERE id IN (118106);

UPDATE cities SET population = CASE id WHEN 112412 THEN 554 ELSE population END WHERE id IN (112412);

UPDATE cities SET population = CASE id WHEN 119048 THEN 550 ELSE population END WHERE id IN (119048);

UPDATE cities SET population = CASE id WHEN 117585 THEN 549 ELSE population END WHERE id IN (117585);

UPDATE cities SET population = CASE id WHEN 117530 THEN 548 ELSE population END WHERE id IN (117530);

UPDATE cities SET population = CASE id WHEN 122320 THEN 544 ELSE population END WHERE id IN (122320);

UPDATE cities SET population = CASE id WHEN 118328 THEN 458 ELSE population END WHERE id IN (118328);

UPDATE cities SET population = CASE id WHEN 125299 THEN 449 ELSE population END WHERE id IN (125299);

UPDATE cities SET population = CASE id WHEN 116516 THEN 437 ELSE population END WHERE id IN (116516);

UPDATE cities SET population = CASE id WHEN 121574 THEN 431 ELSE population END WHERE id IN (121574);

UPDATE cities SET population = CASE id WHEN 124653 THEN 419 ELSE population END WHERE id IN (124653);

UPDATE cities SET population = CASE id WHEN 118182 THEN 364 ELSE population END WHERE id IN (118182);

UPDATE cities SET population = CASE id WHEN 112295 THEN 341 ELSE population END WHERE id IN (112295);

UPDATE cities SET population = CASE id WHEN 119620 THEN 338 ELSE population END WHERE id IN (119620);

UPDATE cities SET population = CASE id WHEN 118069 THEN 337 ELSE population END WHERE id IN (118069);

UPDATE cities SET population = CASE id WHEN 111456 THEN 327 ELSE population END WHERE id IN (111456);

UPDATE cities SET population = CASE id WHEN 113122 THEN 310 ELSE population END WHERE id IN (113122);

UPDATE cities SET population = CASE id WHEN 120135 THEN 307 ELSE population END WHERE id IN (120135);

UPDATE cities SET population = CASE id WHEN 122095 THEN 304 ELSE population END WHERE id IN (122095);

UPDATE cities SET population = CASE id WHEN 117121 THEN 302 ELSE population END WHERE id IN (117121);

UPDATE cities SET population = CASE id WHEN 115977 THEN 287 ELSE population END WHERE id IN (115977);

UPDATE cities SET population = CASE id WHEN 112169 THEN 267 ELSE population END WHERE id IN (112169);

UPDATE cities SET population = CASE id WHEN 127300 THEN 256 ELSE population END WHERE id IN (127300);

UPDATE cities SET population = CASE id WHEN 127292 THEN 232 ELSE population END WHERE id IN (127292);

UPDATE cities SET population = CASE id WHEN 120438 THEN 227 ELSE population END WHERE id IN (120438);

UPDATE cities SET population = CASE id WHEN 117859 THEN 225 ELSE population END WHERE id IN (117859);

UPDATE cities SET population = CASE id WHEN 129705 THEN 195 ELSE population END WHERE id IN (129705);

UPDATE cities SET population = CASE id WHEN 115013 THEN 187 ELSE population END WHERE id IN (115013);

UPDATE cities SET population = CASE id WHEN 120886 THEN 165 ELSE population END WHERE id IN (120886);

UPDATE cities SET population = CASE id WHEN 128469 THEN 123 ELSE population END WHERE id IN (128469);

UPDATE cities SET population = CASE id WHEN 115610 THEN 71 ELSE population END WHERE id IN (115610);

UPDATE cities SET population = CASE id WHEN 119693 THEN 69 ELSE population END WHERE id IN (119693);

