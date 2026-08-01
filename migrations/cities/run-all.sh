#!/usr/bin/env bash
# Apply all 250 country-city seed files in order.
#
# Usage:
#   bash migrations/cities/run-all.sh
#   bash migrations/cities/run-all.sh timeandtimepro-full-v2    # use a different DB name
#   bash migrations/cities/run-all.sh timeandtimepro-full       # default
#
# Set DB env var instead of arg to use a remote DB:
#   DB_NAME=timeandtimepro-full-v2 bash migrations/cities/run-all.sh
#
# Default: applies to the local D1. Use --remote flag (in wrangler cmd) to apply to remote.

set -e

DB_NAME="${1:-${DB_NAME:-timeandtimepro-full}}"
REMOTE_FLAG=""
if [ "${REMOTE:-0}" = "1" ]; then
  REMOTE_FLAG="--remote"
fi

echo "🌍 Applying all cities to D1: $DB_NAME (remote=${REMOTE:-local})"
echo ""

AD: 10 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AD.sql"
AE: 30 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AE.sql"
AF: 100 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AF.sql"
AG: 9 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AG.sql"
AL: 143 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AL.sql"
AM: 308 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AM.sql"
AO: 72 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AO.sql"
AR: 1136 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AR.sql"
AS: 14 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AS.sql"
AT: 2360 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AT.sql"
AU: 2264 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AU.sql"
AW: 6 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AW.sql"
AX: 18 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AX.sql"
AZ: 281 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/AZ.sql"
BA: 409 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BA.sql"
BB: 24 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BB.sql"
BD: 1444 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BD.sql"
BE: 2610 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BE.sql"
BF: 215 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BF.sql"
BG: 530 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BG.sql"
BH: 30 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BH.sql"
BI: 8 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BI.sql"
BJ: 86 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BJ.sql"
BL: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BL.sql" || true
BM: 2 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BM.sql"
BN: 38 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BN.sql"
BO: 498 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BO.sql"
BQ: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BQ.sql" || true
BR: 8603 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BR.sql"
BS: 37 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BS.sql"
BT: 50 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BT.sql"
BV: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BV.sql" || true
BW: 79 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BW.sql"
BY: 240 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BY.sql"
BZ: 47 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/BZ.sql"
CA: 1080 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CA.sql"
CC: 2 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CC.sql"
CD: 478 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CD.sql"
CF: 28 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CF.sql"
CG: 60 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CG.sql"
CH: 4885 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CH.sql"
CI: 70 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CI.sql"
CK: 5 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CK.sql"
CL: 435 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CL.sql"
CM: 312 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CM.sql"
CN: 6972 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CN.sql"
CO: 1259 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CO.sql"
CR: 284 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CR.sql"
CU: 501 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CU.sql"
CV: 24 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CV.sql"
CW: 6 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CW.sql"
CX: 1 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CX.sql"
CY: 143 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CY.sql"
CZ: 2688 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/CZ.sql"
DE: 7104 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/DE.sql"
DJ: 10 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/DJ.sql"
DK: 1040 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/DK.sql"
DM: 14 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/DM.sql"
DO: 156 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/DO.sql"
DZ: 588 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/DZ.sql"
EC: 397 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/EC.sql"
EE: 138 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/EE.sql"
EG: 379 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/EG.sql"
EH: 10 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/EH.sql"
ER: 25 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/ER.sql"
ES: 8394 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/ES.sql"
ET: 187 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/ET.sql"
FI: 2271 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/FI.sql"
FJ: 22 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/FJ.sql"
FK: 3 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/FK.sql"
FM: 13 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/FM.sql"
FO: 25 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/FO.sql"
FR: 21349 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/FR.sql"
GA: 36 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GA.sql"
GB: 16045 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GB.sql"
GD: 9 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GD.sql"
GE: 89 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GE.sql"
GF: 28 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GF.sql"
GG: 13 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GG.sql"
GH: 252 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GH.sql"
GI: 1 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GI.sql"
GL: 49 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GL.sql"
GM: 22 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GM.sql"
GN: 73 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GN.sql"
GP: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GP.sql" || true
GQ: 8 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GQ.sql"
GR: 1094 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GR.sql"
GS: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GS.sql" || true
GT: 470 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GT.sql"
GU: 20 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GU.sql"
GW: 27 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GW.sql"
GY: 58 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/GY.sql"
HK: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/HK.sql" || true
HM: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/HM.sql" || true
HN: 481 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/HN.sql"
HR: 1131 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/HR.sql"
HT: 134 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/HT.sql"
HU: 1390 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/HU.sql"
ID: 6449 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/ID.sql"
IE: 1013 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/IE.sql"
IL: 469 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/IL.sql"
IM: 19 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/IM.sql"
IN: 6991 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/IN.sql"
IO: 2 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/IO.sql"
IQ: 192 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/IQ.sql"
IR: 2428 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/IR.sql"
IS: 51 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/IS.sql"
IT: 13676 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/IT.sql"
JE: 22 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/JE.sql"
JM: 47 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/JM.sql"
JO: 81 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/JO.sql"
JP: 1317 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/JP.sql"
KE: 583 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/KE.sql"
KG: 132 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/KG.sql"
KH: 132 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/KH.sql"
KI: 9 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/KI.sql"
KM: 12 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/KM.sql"
KN: 14 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/KN.sql"
KP: 137 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/KP.sql"
KR: 651 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/KR.sql"
KW: 19 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/KW.sql"
KY: 12 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/KY.sql"
KZ: 248 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/KZ.sql"
LA: 89 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/LA.sql"
LB: 240 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/LB.sql"
LC: 7 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/LC.sql"
LI: 13 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/LI.sql"
LK: 362 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/LK.sql"
LR: 54 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/LR.sql"
LS: 17 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/LS.sql"
LT: 423 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/LT.sql"
LU: 83 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/LU.sql"
LV: 351 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/LV.sql"
LY: 72 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/LY.sql"
MA: 360 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MA.sql"
MC: 10 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MC.sql"
MD: 240 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MD.sql"
ME: 129 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/ME.sql"
MF: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MF.sql" || true
MG: 311 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MG.sql"
MH: 22 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MH.sql"
MK: 261 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MK.sql"
ML: 87 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/ML.sql"
MM: 1040 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MM.sql"
MN: 27 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MN.sql"
MO: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MO.sql" || true
MP: 16 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MP.sql"
MQ: 1 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MQ.sql"
MR: 30 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MR.sql"
MS: 1 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MS.sql"
MT: 68 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MT.sql"
MU: 29 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MU.sql"
MV: 21 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MV.sql"
MW: 66 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MW.sql"
MX: 2902 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MX.sql"
MY: 1604 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MY.sql"
MZ: 56 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/MZ.sql"
NA: 71 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/NA.sql"
NC: 21 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/NC.sql"
NE: 65 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/NE.sql"
NF: 2 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/NF.sql"
NG: 1092 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/NG.sql"
NI: 152 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/NI.sql"
NL: 2062 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/NL.sql"
NO: 1296 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/NO.sql"
NP: 377 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/NP.sql"
NR: 1 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/NR.sql"
NU: 1 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/NU.sql"
NZ: 332 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/NZ.sql"
OM: 113 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/OM.sql"
PA: 297 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PA.sql"
PE: 1203 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PE.sql"
PF: 22 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PF.sql"
PG: 37 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PG.sql"
PH: 1643 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PH.sql"
PK: 2291 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PK.sql"
PL: 2934 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PL.sql"
PM: 2 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PM.sql"
PN: 1 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PN.sql"
PR: 253 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PR.sql"
PS: 109 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PS.sql"
PT: 4051 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PT.sql"
PW: 8 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PW.sql"
PY: 612 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/PY.sql"
QA: 27 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/QA.sql"
RE: 1 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/RE.sql"
RO: 2056 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/RO.sql"
RS: 509 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/RS.sql"
RU: 5792 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/RU.sql"
RW: 32 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/RW.sql"
SA: 209 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SA.sql"
SB: 14 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SB.sql"
SC: 2 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SC.sql"
SD: 76 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SD.sql"
SE: 4061 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SE.sql"
SG: 1 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SG.sql"
SH: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SH.sql" || true
SI: 269 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SI.sql"
SJ: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SJ.sql" || true
SK: 580 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SK.sql"
SL: 30 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SL.sql"
SM: 10 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SM.sql"
SN: 71 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SN.sql"
SO: 41 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SO.sql"
SR: 27 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SR.sql"
SS: 13 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SS.sql"
ST: 4 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/ST.sql"
SV: 192 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SV.sql"
SX: 1 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SX.sql"
SY: 124 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SY.sql"
SZ: 21 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/SZ.sql"
TC: 5 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TC.sql"
TD: 25 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TD.sql"
TF: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TF.sql" || true
TG: 21 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TG.sql"
TH: 1100 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TH.sql"
TJ: 56 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TJ.sql"
TK: 2 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TK.sql"
TL: 18 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TL.sql"
TM: 28 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TM.sql"
TN: 124 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TN.sql"
TO: 8 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TO.sql"
TR: 1681 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TR.sql"
TT: 18 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TT.sql"
TV: 1 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TV.sql"
TW: 92 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TW.sql"
TZ: 186 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/TZ.sql"
UA: 2870 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/UA.sql"
UG: 137 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/UG.sql"
UM: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/UM.sql" || true
US: 16731 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/US.sql"
UY: 290 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/UY.sql"
UZ: 162 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/UZ.sql"
VA: 1 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/VA.sql"
VC: 9 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/VC.sql"
VE: 622 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/VE.sql"
VG: 4 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/VG.sql"
VI: 4 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/VI.sql"
VN: 1741 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/VV.sql" || true
VU: 8 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/VU.sql"
WF: 0 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/WF.sql" || true
WS: 7 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/WS.sql"
YE: 111 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/YE.sql"
YT: 1 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/YT.sql"
ZA: 1128 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/ZA.sql"
ZM: 119 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/ZM.sql"
ZW: 90 cities
wrangler d1 execute "$DB_NAME" $REMOTE_FLAG --env dev --file="migrations/cities/ZW.sql"

echo "✅ All cities seeded."
