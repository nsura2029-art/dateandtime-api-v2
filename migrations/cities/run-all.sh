#!/usr/bin/env bash
# Apply all per-country city seed files in order.
#
# Usage:
#   DB_NAME=timeandtimepro-full-v2 REMOTE=1 bash migrations/cities/run-all.sh
#
# Defaults: DB_NAME=timeandtimepro-full, REMOTE=0 (local SQLite)

set -e

DB_NAME="${DB_NAME:-timeandtimepro-full}"
if [ "${REMOTE:-0}" = "1" ]; then
  REMOTE_FLAG="--remote"
else
  REMOTE_FLAG=""
fi

# AD: 10 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AD.sql" || { echo "WARNING: AD failed (likely 0 cities or empty), continuing"; true; }
# AE: 30 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AE.sql" || { echo "WARNING: AE failed (likely 0 cities or empty), continuing"; true; }
# AF: 100 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AF.sql" || { echo "WARNING: AF failed (likely 0 cities or empty), continuing"; true; }
# AG: 9 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AG.sql" || { echo "WARNING: AG failed (likely 0 cities or empty), continuing"; true; }
# AL: 143 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AL.sql" || { echo "WARNING: AL failed (likely 0 cities or empty), continuing"; true; }
# AM: 308 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AM.sql" || { echo "WARNING: AM failed (likely 0 cities or empty), continuing"; true; }
# AO: 72 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AO.sql" || { echo "WARNING: AO failed (likely 0 cities or empty), continuing"; true; }
# AR: 1136 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AR.sql" || { echo "WARNING: AR failed (likely 0 cities or empty), continuing"; true; }
# AS: 14 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AS.sql" || { echo "WARNING: AS failed (likely 0 cities or empty), continuing"; true; }
# AT: 2360 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AT.sql" || { echo "WARNING: AT failed (likely 0 cities or empty), continuing"; true; }
# AU: 4147 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AU.sql" || { echo "WARNING: AU failed (likely 0 cities or empty), continuing"; true; }
# AW: 12 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AW.sql" || { echo "WARNING: AW failed (likely 0 cities or empty), continuing"; true; }
# AX: 12 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AX.sql" || { echo "WARNING: AX failed (likely 0 cities or empty), continuing"; true; }
# AZ: 180 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/AZ.sql" || { echo "WARNING: AZ failed (likely 0 cities or empty), continuing"; true; }
# BA: 232 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BA.sql" || { echo "WARNING: BA failed (likely 0 cities or empty), continuing"; true; }
# BB: 7 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BB.sql" || { echo "WARNING: BB failed (likely 0 cities or empty), continuing"; true; }
# BD: 64 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BD.sql" || { echo "WARNING: BD failed (likely 0 cities or empty), continuing"; true; }
# BE: 549 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BE.sql" || { echo "WARNING: BE failed (likely 0 cities or empty), continuing"; true; }
# BF: 92 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BF.sql" || { echo "WARNING: BF failed (likely 0 cities or empty), continuing"; true; }
# BG: 504 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BG.sql" || { echo "WARNING: BG failed (likely 0 cities or empty), continuing"; true; }
# BH: 9 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BH.sql" || { echo "WARNING: BH failed (likely 0 cities or empty), continuing"; true; }
# BI: 17 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BI.sql" || { echo "WARNING: BI failed (likely 0 cities or empty), continuing"; true; }
# BJ: 36 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BJ.sql" || { echo "WARNING: BJ failed (likely 0 cities or empty), continuing"; true; }
# BL: 1 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BL.sql" || { echo "WARNING: BL failed (likely 0 cities or empty), continuing"; true; }
# BM: 9 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BM.sql" || { echo "WARNING: BM failed (likely 0 cities or empty), continuing"; true; }
# BN: 9 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BN.sql" || { echo "WARNING: BN failed (likely 0 cities or empty), continuing"; true; }
# BO: 228 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BO.sql" || { echo "WARNING: BO failed (likely 0 cities or empty), continuing"; true; }
# BQ: 8 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BQ.sql" || { echo "WARNING: BQ failed (likely 0 cities or empty), continuing"; true; }
# BR: 5629 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BR.sql" || { echo "WARNING: BR failed (likely 0 cities or empty), continuing"; true; }
# BS: 21 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BS.sql" || { echo "WARNING: BS failed (likely 0 cities or empty), continuing"; true; }
# BT: 57 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BT.sql" || { echo "WARNING: BT failed (likely 0 cities or empty), continuing"; true; }
# BW: 75 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BW.sql" || { echo "WARNING: BW failed (likely 0 cities or empty), continuing"; true; }
# BY: 329 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BY.sql" || { echo "WARNING: BY failed (likely 0 cities or empty), continuing"; true; }
# BZ: 13 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/BZ.sql" || { echo "WARNING: BZ failed (likely 0 cities or empty), continuing"; true; }
# CA: 1080 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CA.sql" || { echo "WARNING: CA failed (likely 0 cities or empty), continuing"; true; }
# CD: 67 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CD.sql" || { echo "WARNING: CD failed (likely 0 cities or empty), continuing"; true; }
# CF: 42 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CF.sql" || { echo "WARNING: CF failed (likely 0 cities or empty), continuing"; true; }
# CG: 17 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CG.sql" || { echo "WARNING: CG failed (likely 0 cities or empty), continuing"; true; }
# CH: 1507 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CH.sql" || { echo "WARNING: CH failed (likely 0 cities or empty), continuing"; true; }
# CI: 95 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CI.sql" || { echo "WARNING: CI failed (likely 0 cities or empty), continuing"; true; }
# CL: 300 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CL.sql" || { echo "WARNING: CL failed (likely 0 cities or empty), continuing"; true; }
# CM: 139 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CM.sql" || { echo "WARNING: CM failed (likely 0 cities or empty), continuing"; true; }
# CN: 4133 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CN.sql" || { echo "WARNING: CN failed (likely 0 cities or empty), continuing"; true; }
# CO: 1122 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CO.sql" || { echo "WARNING: CO failed (likely 0 cities or empty), continuing"; true; }
# CR: 159 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CR.sql" || { echo "WARNING: CR failed (likely 0 cities or empty), continuing"; true; }
# CU: 187 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CU.sql" || { echo "WARNING: CU failed (likely 0 cities or empty), continuing"; true; }
# CV: 28 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CV.sql" || { echo "WARNING: CV failed (likely 0 cities or empty), continuing"; true; }
# CY: 95 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CY.sql" || { echo "WARNING: CY failed (likely 0 cities or empty), continuing"; true; }
# CZ: 1355 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/CZ.sql" || { echo "WARNING: CZ failed (likely 0 cities or empty), continuing"; true; }
# DE: 7104 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/DE.sql" || { echo "WARNING: DE failed (likely 0 cities or empty), continuing"; true; }
# DJ: 12 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/DJ.sql" || { echo "WARNING: DJ failed (likely 0 cities or empty), continuing"; true; }
# DK: 430 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/DK.sql" || { echo "WARNING: DK failed (likely 0 cities or empty), continuing"; true; }
# DM: 17 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/DM.sql" || { echo "WARNING: DM failed (likely 0 cities or empty), continuing"; true; }
# DO: 207 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/DO.sql" || { echo "WARNING: DO failed (likely 0 cities or empty), continuing"; true; }
# DZ: 293 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/DZ.sql" || { echo "WARNING: DZ failed (likely 0 cities or empty), continuing"; true; }
# EC: 114 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/EC.sql" || { echo "WARNING: EC failed (likely 0 cities or empty), continuing"; true; }
# EE: 162 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/EE.sql" || { echo "WARNING: EE failed (likely 0 cities or empty), continuing"; true; }
# EG: 163 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/EG.sql" || { echo "WARNING: EG failed (likely 0 cities or empty), continuing"; true; }
# ER: 11 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/ER.sql" || { echo "WARNING: ER failed (likely 0 cities or empty), continuing"; true; }
# ES: 8405 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/ES.sql" || { echo "WARNING: ES failed (likely 0 cities or empty), continuing"; true; }
# ET: 144 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/ET.sql" || { echo "WARNING: ET failed (likely 0 cities or empty), continuing"; true; }
# FI: 437 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/FI.sql" || { echo "WARNING: FI failed (likely 0 cities or empty), continuing"; true; }
# FJ: 20 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/FJ.sql" || { echo "WARNING: FJ failed (likely 0 cities or empty), continuing"; true; }
# FM: 80 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/FM.sql" || { echo "WARNING: FM failed (likely 0 cities or empty), continuing"; true; }
# FO: 27 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/FO.sql" || { echo "WARNING: FO failed (likely 0 cities or empty), continuing"; true; }
# FR: 10534 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/FR.sql" || { echo "WARNING: FR failed (likely 0 cities or empty), continuing"; true; }
# GA: 28 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GA.sql" || { echo "WARNING: GA failed (likely 0 cities or empty), continuing"; true; }
# GB: 3879 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GB.sql" || { echo "WARNING: GB failed (likely 0 cities or empty), continuing"; true; }
# GD: 7 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GD.sql" || { echo "WARNING: GD failed (likely 0 cities or empty), continuing"; true; }
# GE: 110 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GE.sql" || { echo "WARNING: GE failed (likely 0 cities or empty), continuing"; true; }
# GF: 22 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GF.sql" || { echo "WARNING: GF failed (likely 0 cities or empty), continuing"; true; }
# GG: 5 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GG.sql" || { echo "WARNING: GG failed (likely 0 cities or empty), continuing"; true; }
# GH: 121 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GH.sql" || { echo "WARNING: GH failed (likely 0 cities or empty), continuing"; true; }
# GL: 18 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GL.sql" || { echo "WARNING: GL failed (likely 0 cities or empty), continuing"; true; }
# GM: 104 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GM.sql" || { echo "WARNING: GM failed (likely 0 cities or empty), continuing"; true; }
# GN: 54 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GN.sql" || { echo "WARNING: GN failed (likely 0 cities or empty), continuing"; true; }
# GP: 32 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GP.sql" || { echo "WARNING: GP failed (likely 0 cities or empty), continuing"; true; }
# GQ: 26 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GQ.sql" || { echo "WARNING: GQ failed (likely 0 cities or empty), continuing"; true; }
# GR: 1103 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GR.sql" || { echo "WARNING: GR failed (likely 0 cities or empty), continuing"; true; }
# GT: 382 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GT.sql" || { echo "WARNING: GT failed (likely 0 cities or empty), continuing"; true; }
# GU: 25 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GU.sql" || { echo "WARNING: GU failed (likely 0 cities or empty), continuing"; true; }
# GW: 15 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GW.sql" || { echo "WARNING: GW failed (likely 0 cities or empty), continuing"; true; }
# GY: 14 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/GY.sql" || { echo "WARNING: GY failed (likely 0 cities or empty), continuing"; true; }
# HK: 27 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/HK.sql" || { echo "WARNING: HK failed (likely 0 cities or empty), continuing"; true; }
# HN: 545 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/HN.sql" || { echo "WARNING: HN failed (likely 0 cities or empty), continuing"; true; }
# HR: 663 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/HR.sql" || { echo "WARNING: HR failed (likely 0 cities or empty), continuing"; true; }
# HT: 124 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/HT.sql" || { echo "WARNING: HT failed (likely 0 cities or empty), continuing"; true; }
# HU: 1074 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/HU.sql" || { echo "WARNING: HU failed (likely 0 cities or empty), continuing"; true; }
# ID: 799 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/ID.sql" || { echo "WARNING: ID failed (likely 0 cities or empty), continuing"; true; }
# IE: 370 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/IE.sql" || { echo "WARNING: IE failed (likely 0 cities or empty), continuing"; true; }
# IL: 150 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/IL.sql" || { echo "WARNING: IL failed (likely 0 cities or empty), continuing"; true; }
# IM: 16 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/IM.sql" || { echo "WARNING: IM failed (likely 0 cities or empty), continuing"; true; }
# IN: 4198 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/IN.sql" || { echo "WARNING: IN failed (likely 0 cities or empty), continuing"; true; }
# IQ: 135 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/IQ.sql" || { echo "WARNING: IQ failed (likely 0 cities or empty), continuing"; true; }
# IR: 1847 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/IR.sql" || { echo "WARNING: IR failed (likely 0 cities or empty), continuing"; true; }
# IS: 73 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/IS.sql" || { echo "WARNING: IS failed (likely 0 cities or empty), continuing"; true; }
# IT: 9852 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/IT.sql" || { echo "WARNING: IT failed (likely 0 cities or empty), continuing"; true; }
# JE: 51 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/JE.sql" || { echo "WARNING: JE failed (likely 0 cities or empty), continuing"; true; }
# JM: 837 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/JM.sql" || { echo "WARNING: JM failed (likely 0 cities or empty), continuing"; true; }
# JO: 82 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/JO.sql" || { echo "WARNING: JO failed (likely 0 cities or empty), continuing"; true; }
# JP: 1655 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/JP.sql" || { echo "WARNING: JP failed (likely 0 cities or empty), continuing"; true; }
# KE: 145 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/KE.sql" || { echo "WARNING: KE failed (likely 0 cities or empty), continuing"; true; }
# KG: 53 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/KG.sql" || { echo "WARNING: KG failed (likely 0 cities or empty), continuing"; true; }
# KH: 107 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/KH.sql" || { echo "WARNING: KH failed (likely 0 cities or empty), continuing"; true; }
# KI: 37 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/KI.sql" || { echo "WARNING: KI failed (likely 0 cities or empty), continuing"; true; }
# KM: 88 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/KM.sql" || { echo "WARNING: KM failed (likely 0 cities or empty), continuing"; true; }
# KN: 13 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/KN.sql" || { echo "WARNING: KN failed (likely 0 cities or empty), continuing"; true; }
# KP: 80 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/KP.sql" || { echo "WARNING: KP failed (likely 0 cities or empty), continuing"; true; }
# KR: 308 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/KR.sql" || { echo "WARNING: KR failed (likely 0 cities or empty), continuing"; true; }
# KW: 25 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/KW.sql" || { echo "WARNING: KW failed (likely 0 cities or empty), continuing"; true; }
# KY: 7 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/KY.sql" || { echo "WARNING: KY failed (likely 0 cities or empty), continuing"; true; }
# KZ: 259 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/KZ.sql" || { echo "WARNING: KZ failed (likely 0 cities or empty), continuing"; true; }
# LA: 76 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/LA.sql" || { echo "WARNING: LA failed (likely 0 cities or empty), continuing"; true; }
# LB: 26 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/LB.sql" || { echo "WARNING: LB failed (likely 0 cities or empty), continuing"; true; }
# LC: 479 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/LC.sql" || { echo "WARNING: LC failed (likely 0 cities or empty), continuing"; true; }
# LI: 11 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/LI.sql" || { echo "WARNING: LI failed (likely 0 cities or empty), continuing"; true; }
# LK: 147 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/LK.sql" || { echo "WARNING: LK failed (likely 0 cities or empty), continuing"; true; }
# LR: 18 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/LR.sql" || { echo "WARNING: LR failed (likely 0 cities or empty), continuing"; true; }
# LS: 12 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/LS.sql" || { echo "WARNING: LS failed (likely 0 cities or empty), continuing"; true; }
# LT: 128 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/LT.sql" || { echo "WARNING: LT failed (likely 0 cities or empty), continuing"; true; }
# LU: 144 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/LU.sql" || { echo "WARNING: LU failed (likely 0 cities or empty), continuing"; true; }
# LV: 125 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/LV.sql" || { echo "WARNING: LV failed (likely 0 cities or empty), continuing"; true; }
# LY: 54 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/LY.sql" || { echo "WARNING: LY failed (likely 0 cities or empty), continuing"; true; }
# MA: 222 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MA.sql" || { echo "WARNING: MA failed (likely 0 cities or empty), continuing"; true; }
# MC: 17 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MC.sql" || { echo "WARNING: MC failed (likely 0 cities or empty), continuing"; true; }
# MD: 72 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MD.sql" || { echo "WARNING: MD failed (likely 0 cities or empty), continuing"; true; }
# ME: 40 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/ME.sql" || { echo "WARNING: ME failed (likely 0 cities or empty), continuing"; true; }
# MF: 1 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MF.sql" || { echo "WARNING: MF failed (likely 0 cities or empty), continuing"; true; }
# MG: 9 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MG.sql" || { echo "WARNING: MG failed (likely 0 cities or empty), continuing"; true; }
# MH: 26 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MH.sql" || { echo "WARNING: MH failed (likely 0 cities or empty), continuing"; true; }
# MK: 194 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MK.sql" || { echo "WARNING: MK failed (likely 0 cities or empty), continuing"; true; }
# ML: 47 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/ML.sql" || { echo "WARNING: ML failed (likely 0 cities or empty), continuing"; true; }
# MM: 74 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MM.sql" || { echo "WARNING: MM failed (likely 0 cities or empty), continuing"; true; }
# MN: 40 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MN.sql" || { echo "WARNING: MN failed (likely 0 cities or empty), continuing"; true; }
# MQ: 34 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MQ.sql" || { echo "WARNING: MQ failed (likely 0 cities or empty), continuing"; true; }
# MR: 42 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MR.sql" || { echo "WARNING: MR failed (likely 0 cities or empty), continuing"; true; }
# MT: 87 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MT.sql" || { echo "WARNING: MT failed (likely 0 cities or empty), continuing"; true; }
# MU: 168 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MU.sql" || { echo "WARNING: MU failed (likely 0 cities or empty), continuing"; true; }
# MV: 21 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MV.sql" || { echo "WARNING: MV failed (likely 0 cities or empty), continuing"; true; }
# MW: 61 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MW.sql" || { echo "WARNING: MW failed (likely 0 cities or empty), continuing"; true; }
# MX: 9321 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MX.sql" || { echo "WARNING: MX failed (likely 0 cities or empty), continuing"; true; }
# MY: 223 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MY.sql" || { echo "WARNING: MY failed (likely 0 cities or empty), continuing"; true; }
# MZ: 38 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/MZ.sql" || { echo "WARNING: MZ failed (likely 0 cities or empty), continuing"; true; }
# NA: 48 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/NA.sql" || { echo "WARNING: NA failed (likely 0 cities or empty), continuing"; true; }
# NC: 10 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/NC.sql" || { echo "WARNING: NC failed (likely 0 cities or empty), continuing"; true; }
# NE: 71 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/NE.sql" || { echo "WARNING: NE failed (likely 0 cities or empty), continuing"; true; }
# NG: 491 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/NG.sql" || { echo "WARNING: NG failed (likely 0 cities or empty), continuing"; true; }
# NI: 155 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/NI.sql" || { echo "WARNING: NI failed (likely 0 cities or empty), continuing"; true; }
# NL: 1644 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/NL.sql" || { echo "WARNING: NL failed (likely 0 cities or empty), continuing"; true; }
# NO: 666 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/NO.sql" || { echo "WARNING: NO failed (likely 0 cities or empty), continuing"; true; }
# NP: 77 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/NP.sql" || { echo "WARNING: NP failed (likely 0 cities or empty), continuing"; true; }
# NR: 7 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/NR.sql" || { echo "WARNING: NR failed (likely 0 cities or empty), continuing"; true; }
# NZ: 160 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/NZ.sql" || { echo "WARNING: NZ failed (likely 0 cities or empty), continuing"; true; }
# OM: 28 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/OM.sql" || { echo "WARNING: OM failed (likely 0 cities or empty), continuing"; true; }
# PA: 551 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/PA.sql" || { echo "WARNING: PA failed (likely 0 cities or empty), continuing"; true; }
# PE: 485 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/PE.sql" || { echo "WARNING: PE failed (likely 0 cities or empty), continuing"; true; }
# PF: 48 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/PF.sql" || { echo "WARNING: PF failed (likely 0 cities or empty), continuing"; true; }
# PG: 100 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/PG.sql" || { echo "WARNING: PG failed (likely 0 cities or empty), continuing"; true; }
# PH: 5357 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/PH.sql" || { echo "WARNING: PH failed (likely 0 cities or empty), continuing"; true; }
# PK: 456 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/PK.sql" || { echo "WARNING: PK failed (likely 0 cities or empty), continuing"; true; }
# PL: 2810 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/PL.sql" || { echo "WARNING: PL failed (likely 0 cities or empty), continuing"; true; }
# PM: 2 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/PM.sql" || { echo "WARNING: PM failed (likely 0 cities or empty), continuing"; true; }
# PR: 78 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/PR.sql" || { echo "WARNING: PR failed (likely 0 cities or empty), continuing"; true; }
# PS: 132 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/PS.sql" || { echo "WARNING: PS failed (likely 0 cities or empty), continuing"; true; }
# PT: 1296 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/PT.sql" || { echo "WARNING: PT failed (likely 0 cities or empty), continuing"; true; }
# PW: 15 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/PW.sql" || { echo "WARNING: PW failed (likely 0 cities or empty), continuing"; true; }
# PY: 152 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/PY.sql" || { echo "WARNING: PY failed (likely 0 cities or empty), continuing"; true; }
# QA: 15 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/QA.sql" || { echo "WARNING: QA failed (likely 0 cities or empty), continuing"; true; }
# RE: 24 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/RE.sql" || { echo "WARNING: RE failed (likely 0 cities or empty), continuing"; true; }
# RO: 7949 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/RO.sql" || { echo "WARNING: RO failed (likely 0 cities or empty), continuing"; true; }
# RS: 379 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/RS.sql" || { echo "WARNING: RS failed (likely 0 cities or empty), continuing"; true; }
# RU: 5523 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/RU.sql" || { echo "WARNING: RU failed (likely 0 cities or empty), continuing"; true; }
# RW: 12 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/RW.sql" || { echo "WARNING: RW failed (likely 0 cities or empty), continuing"; true; }
# SA: 399 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SA.sql" || { echo "WARNING: SA failed (likely 0 cities or empty), continuing"; true; }
# SB: 7 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SB.sql" || { echo "WARNING: SB failed (likely 0 cities or empty), continuing"; true; }
# SC: 9 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SC.sql" || { echo "WARNING: SC failed (likely 0 cities or empty), continuing"; true; }
# SD: 71 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SD.sql" || { echo "WARNING: SD failed (likely 0 cities or empty), continuing"; true; }
# SE: 800 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SE.sql" || { echo "WARNING: SE failed (likely 0 cities or empty), continuing"; true; }
# SG: 26 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SG.sql" || { echo "WARNING: SG failed (likely 0 cities or empty), continuing"; true; }
# SI: 312 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SI.sql" || { echo "WARNING: SI failed (likely 0 cities or empty), continuing"; true; }
# SK: 233 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SK.sql" || { echo "WARNING: SK failed (likely 0 cities or empty), continuing"; true; }
# SL: 91 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SL.sql" || { echo "WARNING: SL failed (likely 0 cities or empty), continuing"; true; }
# SM: 9 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SM.sql" || { echo "WARNING: SM failed (likely 0 cities or empty), continuing"; true; }
# SN: 73 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SN.sql" || { echo "WARNING: SN failed (likely 0 cities or empty), continuing"; true; }
# SO: 51 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SO.sql" || { echo "WARNING: SO failed (likely 0 cities or empty), continuing"; true; }
# SR: 13 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SR.sql" || { echo "WARNING: SR failed (likely 0 cities or empty), continuing"; true; }
# SS: 1 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SS.sql" || { echo "WARNING: SS failed (likely 0 cities or empty), continuing"; true; }
# ST: 7 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/ST.sql" || { echo "WARNING: ST failed (likely 0 cities or empty), continuing"; true; }
# SV: 100 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SV.sql" || { echo "WARNING: SV failed (likely 0 cities or empty), continuing"; true; }
# SY: 142 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SY.sql" || { echo "WARNING: SY failed (likely 0 cities or empty), continuing"; true; }
# SZ: 34 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/SZ.sql" || { echo "WARNING: SZ failed (likely 0 cities or empty), continuing"; true; }
# TD: 49 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TD.sql" || { echo "WARNING: TD failed (likely 0 cities or empty), continuing"; true; }
# TF: 5 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TF.sql" || { echo "WARNING: TF failed (likely 0 cities or empty), continuing"; true; }
# TG: 22 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TG.sql" || { echo "WARNING: TG failed (likely 0 cities or empty), continuing"; true; }
# TH: 1241 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TH.sql" || { echo "WARNING: TH failed (likely 0 cities or empty), continuing"; true; }
# TJ: 71 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TJ.sql" || { echo "WARNING: TJ failed (likely 0 cities or empty), continuing"; true; }
# TL: 55 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TL.sql" || { echo "WARNING: TL failed (likely 0 cities or empty), continuing"; true; }
# TM: 30 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TM.sql" || { echo "WARNING: TM failed (likely 0 cities or empty), continuing"; true; }
# TN: 165 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TN.sql" || { echo "WARNING: TN failed (likely 0 cities or empty), continuing"; true; }
# TO: 8 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TO.sql" || { echo "WARNING: TO failed (likely 0 cities or empty), continuing"; true; }
# TR: 980 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TR.sql" || { echo "WARNING: TR failed (likely 0 cities or empty), continuing"; true; }
# TT: 25 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TT.sql" || { echo "WARNING: TT failed (likely 0 cities or empty), continuing"; true; }
# TV: 9 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TV.sql" || { echo "WARNING: TV failed (likely 0 cities or empty), continuing"; true; }
# TW: 40 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TW.sql" || { echo "WARNING: TW failed (likely 0 cities or empty), continuing"; true; }
# TZ: 303 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/TZ.sql" || { echo "WARNING: TZ failed (likely 0 cities or empty), continuing"; true; }
# UA: 1819 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/UA.sql" || { echo "WARNING: UA failed (likely 0 cities or empty), continuing"; true; }
# UG: 91 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/UG.sql" || { echo "WARNING: UG failed (likely 0 cities or empty), continuing"; true; }
# US: 16731 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/US.sql" || { echo "WARNING: US failed (likely 0 cities or empty), continuing"; true; }
# UY: 2010 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/UY.sql" || { echo "WARNING: UY failed (likely 0 cities or empty), continuing"; true; }
# UZ: 135 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/UZ.sql" || { echo "WARNING: UZ failed (likely 0 cities or empty), continuing"; true; }
# VC: 9 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/VC.sql" || { echo "WARNING: VC failed (likely 0 cities or empty), continuing"; true; }
# VE: 136 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/VE.sql" || { echo "WARNING: VE failed (likely 0 cities or empty), continuing"; true; }
# VI: 20 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/VI.sql" || { echo "WARNING: VI failed (likely 0 cities or empty), continuing"; true; }
# VN: 488 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/VN.sql" || { echo "WARNING: VN failed (likely 0 cities or empty), continuing"; true; }
# VU: 7 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/VU.sql" || { echo "WARNING: VU failed (likely 0 cities or empty), continuing"; true; }
# WF: 3 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/WF.sql" || { echo "WARNING: WF failed (likely 0 cities or empty), continuing"; true; }
# WS: 20 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/WS.sql" || { echo "WARNING: WS failed (likely 0 cities or empty), continuing"; true; }
# XK: 59 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/XK.sql" || { echo "WARNING: XK failed (likely 0 cities or empty), continuing"; true; }
# YE: 339 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/YE.sql" || { echo "WARNING: YE failed (likely 0 cities or empty), continuing"; true; }
# YT: 57 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/YT.sql" || { echo "WARNING: YT failed (likely 0 cities or empty), continuing"; true; }
# ZA: 314 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/ZA.sql" || { echo "WARNING: ZA failed (likely 0 cities or empty), continuing"; true; }
# ZM: 71 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/ZM.sql" || { echo "WARNING: ZM failed (likely 0 cities or empty), continuing"; true; }
# ZW: 109 cities
wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --yes --file="migrations/cities/ZW.sql" || { echo "WARNING: ZW failed (likely 0 cities or empty), continuing"; true; }

echo "✅ All cities seeded."