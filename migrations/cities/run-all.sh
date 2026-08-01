#!/usr/bin/env bash
# Apply all 250 country-city seed files in order.
# Usage: bash migrations/cities/run-all.sh

set -e

# AD: 10 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AD.sql"
# AE: 30 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AE.sql"
# AF: 100 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AF.sql"
# AG: 9 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AG.sql"
# AL: 143 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AL.sql"
# AM: 308 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AM.sql"
# AO: 72 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AO.sql"
# AR: 1136 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AR.sql"
# AS: 14 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AS.sql"
# AT: 2360 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AT.sql"
# AU: 4147 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AU.sql"
# AW: 12 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AW.sql"
# AX: 12 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AX.sql"
# AZ: 180 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/AZ.sql"
# BA: 232 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BA.sql"
# BB: 7 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BB.sql"
# BD: 64 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BD.sql"
# BE: 549 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BE.sql"
# BF: 92 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BF.sql"
# BG: 504 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BG.sql"
# BH: 9 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BH.sql"
# BI: 17 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BI.sql"
# BJ: 36 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BJ.sql"
# BL: 1 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BL.sql"
# BM: 9 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BM.sql"
# BN: 9 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BN.sql"
# BO: 228 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BO.sql"
# BQ: 8 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BQ.sql"
# BR: 5629 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BR.sql"
# BS: 21 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BS.sql"
# BT: 57 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BT.sql"
# BW: 75 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BW.sql"
# BY: 329 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BY.sql"
# BZ: 13 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/BZ.sql"
# CA: 1080 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CA.sql"
# CD: 67 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CD.sql"
# CF: 42 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CF.sql"
# CG: 17 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CG.sql"
# CH: 1507 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CH.sql"
# CI: 95 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CI.sql"
# CL: 300 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CL.sql"
# CM: 139 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CM.sql"
# CN: 4133 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CN.sql"
# CO: 1122 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CO.sql"
# CR: 159 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CR.sql"
# CU: 187 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CU.sql"
# CV: 28 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CV.sql"
# CY: 95 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CY.sql"
# CZ: 1355 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/CZ.sql"
# DE: 7104 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/DE.sql"
# DJ: 12 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/DJ.sql"
# DK: 430 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/DK.sql"
# DM: 17 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/DM.sql"
# DO: 207 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/DO.sql"
# DZ: 293 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/DZ.sql"
# EC: 114 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/EC.sql"
# EE: 162 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/EE.sql"
# EG: 163 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/EG.sql"
# ER: 11 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/ER.sql"
# ES: 8405 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/ES.sql"
# ET: 144 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/ET.sql"
# FI: 437 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/FI.sql"
# FJ: 20 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/FJ.sql"
# FM: 80 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/FM.sql"
# FO: 27 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/FO.sql"
# FR: 10534 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/FR.sql"
# GA: 28 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GA.sql"
# GB: 3879 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GB.sql"
# GD: 7 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GD.sql"
# GE: 110 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GE.sql"
# GF: 22 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GF.sql"
# GG: 5 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GG.sql"
# GH: 121 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GH.sql"
# GL: 18 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GL.sql"
# GM: 104 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GM.sql"
# GN: 54 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GN.sql"
# GP: 32 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GP.sql"
# GQ: 26 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GQ.sql"
# GR: 1103 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GR.sql"
# GT: 382 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GT.sql"
# GU: 25 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GU.sql"
# GW: 15 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GW.sql"
# GY: 14 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/GY.sql"
# HK: 27 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/HK.sql"
# HN: 545 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/HN.sql"
# HR: 663 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/HR.sql"
# HT: 124 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/HT.sql"
# HU: 1074 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/HU.sql"
# ID: 799 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/ID.sql"
# IE: 370 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/IE.sql"
# IL: 150 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/IL.sql"
# IM: 16 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/IM.sql"
# IN: 4198 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/IN.sql"
# IQ: 135 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/IQ.sql"
# IR: 1847 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/IR.sql"
# IS: 73 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/IS.sql"
# IT: 9852 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/IT.sql"
# JE: 51 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/JE.sql"
# JM: 837 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/JM.sql"
# JO: 82 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/JO.sql"
# JP: 1655 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/JP.sql"
# KE: 145 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/KE.sql"
# KG: 53 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/KG.sql"
# KH: 107 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/KH.sql"
# KI: 37 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/KI.sql"
# KM: 88 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/KM.sql"
# KN: 13 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/KN.sql"
# KP: 80 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/KP.sql"
# KR: 308 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/KR.sql"
# KW: 25 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/KW.sql"
# KY: 7 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/KY.sql"
# KZ: 259 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/KZ.sql"
# LA: 76 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/LA.sql"
# LB: 26 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/LB.sql"
# LC: 479 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/LC.sql"
# LI: 11 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/LI.sql"
# LK: 147 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/LK.sql"
# LR: 18 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/LR.sql"
# LS: 12 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/LS.sql"
# LT: 128 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/LT.sql"
# LU: 144 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/LU.sql"
# LV: 125 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/LV.sql"
# LY: 54 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/LY.sql"
# MA: 222 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MA.sql"
# MC: 17 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MC.sql"
# MD: 72 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MD.sql"
# ME: 40 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/ME.sql"
# MF: 1 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MF.sql"
# MG: 9 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MG.sql"
# MH: 26 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MH.sql"
# MK: 194 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MK.sql"
# ML: 47 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/ML.sql"
# MM: 74 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MM.sql"
# MN: 40 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MN.sql"
# MQ: 34 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MQ.sql"
# MR: 42 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MR.sql"
# MT: 87 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MT.sql"
# MU: 168 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MU.sql"
# MV: 21 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MV.sql"
# MW: 61 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MW.sql"
# MX: 9321 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MX.sql"
# MY: 223 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MY.sql"
# MZ: 38 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/MZ.sql"
# NA: 48 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/NA.sql"
# NC: 10 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/NC.sql"
# NE: 71 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/NE.sql"
# NG: 491 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/NG.sql"
# NI: 155 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/NI.sql"
# NL: 1644 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/NL.sql"
# NO: 666 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/NO.sql"
# NP: 77 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/NP.sql"
# NR: 7 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/NR.sql"
# NZ: 160 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/NZ.sql"
# OM: 28 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/OM.sql"
# PA: 551 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/PA.sql"
# PE: 485 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/PE.sql"
# PF: 48 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/PF.sql"
# PG: 100 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/PG.sql"
# PH: 5357 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/PH.sql"
# PK: 456 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/PK.sql"
# PL: 2810 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/PL.sql"
# PM: 2 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/PM.sql"
# PR: 78 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/PR.sql"
# PS: 132 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/PS.sql"
# PT: 1296 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/PT.sql"
# PW: 15 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/PW.sql"
# PY: 152 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/PY.sql"
# QA: 15 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/QA.sql"
# RE: 24 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/RE.sql"
# RO: 7949 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/RO.sql"
# RS: 379 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/RS.sql"
# RU: 5523 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/RU.sql"
# RW: 12 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/RW.sql"
# SA: 399 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SA.sql"
# SB: 7 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SB.sql"
# SC: 9 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SC.sql"
# SD: 71 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SD.sql"
# SE: 800 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SE.sql"
# SG: 26 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SG.sql"
# SI: 312 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SI.sql"
# SK: 233 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SK.sql"
# SL: 91 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SL.sql"
# SM: 9 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SM.sql"
# SN: 73 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SN.sql"
# SO: 51 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SO.sql"
# SR: 13 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SR.sql"
# SS: 1 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SS.sql"
# ST: 7 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/ST.sql"
# SV: 100 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SV.sql"
# SY: 142 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SY.sql"
# SZ: 34 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/SZ.sql"
# TD: 49 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TD.sql"
# TF: 5 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TF.sql"
# TG: 22 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TG.sql"
# TH: 1241 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TH.sql"
# TJ: 71 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TJ.sql"
# TL: 55 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TL.sql"
# TM: 30 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TM.sql"
# TN: 165 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TN.sql"
# TO: 8 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TO.sql"
# TR: 980 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TR.sql"
# TT: 25 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TT.sql"
# TV: 9 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TV.sql"
# TW: 40 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TW.sql"
# TZ: 303 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/TZ.sql"
# UA: 1819 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/UA.sql"
# UG: 91 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/UG.sql"
# US: 16731 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/US.sql"
# UY: 2010 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/UY.sql"
# UZ: 135 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/UZ.sql"
# VC: 9 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/VC.sql"
# VE: 136 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/VE.sql"
# VI: 20 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/VI.sql"
# VN: 488 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/VN.sql"
# VU: 7 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/VU.sql"
# WF: 3 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/WF.sql"
# WS: 20 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/WS.sql"
# XK: 59 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/XK.sql"
# YE: 339 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/YE.sql"
# YT: 57 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/YT.sql"
# ZA: 314 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/ZA.sql"
# ZM: 71 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/ZM.sql"
# ZW: 109 cities
wrangler d1 execute timeandtimepro-full --env dev --remote --file="migrations/cities/ZW.sql"

echo "✅ All cities seeded."