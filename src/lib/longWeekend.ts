/**
 * src/lib/longWeekend.ts
 *
 * Long weekend calculator — given a set of holidays for a year + a country,
 * compute all "long weekend" blocks (3+ consecutive non-working days).
 *
 * Supports:
 * - Multi-day holidays (e.g., Diwali 5-day festival in India)
 * - Optional holidays (Restricted Holidays in IN, Boxing Day in some provinces)
 * - Subdivision filtering (e.g., only CA-ON)
 * - Custom work day schedules (default: Mon-Fri off, Sat-Sun = weekend)
 *   - Future: Sun-Thu (Saudi, UAE), Fri-Sat (Israel)
 * - PTO extension strategy computation
 *
 * Pure functions, no external deps. Uses native Date for UTC math.
 */

// ============================================================================
// Types
// ============================================================================

export type WorkDays = "mon-fri" | "sun-thu" | "fri-sat" | "sat-wed";

export interface Holiday {
  date: string;             // YYYY-MM-DD
  endDate?: string | null;  // YYYY-MM-DD, null for single-day
  name: string;
  filterCode: string;       // PUBLIC_NATIONAL, PUBLIC_LOCAL, OPTIONAL_HOLIDAY, etc.
  subdivisionCode?: string | null;
}

export interface LongWeekend {
  start: string;            // YYYY-MM-DD
  end: string;              // YYYY-MM-DD
  days: number;             // total days off
  type: "3-day" | "4-day" | "5-day" | "6-day" | "7-day" | "extended";
  trigger: string;          // which holiday caused this
  holidays: string[];       // list of "Holiday (date)" strings
  includesOptional: boolean;// any of the days is OPTIONAL_HOLIDAY
}

export interface PTOExtension {
  ptoDays: string[];        // YYYY-MM-DD dates user must take off
  totalOff: number;         // total days off including the natural break
  efficiency: number;       // totalOff / ptoDays.length
  extendsTo: string;        // end date after taking PTO
  direction: "before" | "after";
}

export interface LongWeekendOptions {
  workDays?: WorkDays;          // default: mon-fri
  minDays?: number;             // default: 3
  includeOptional?: boolean;    // default: true
  subdivisions?: string[];      // default: all (no filter)
}

// ============================================================================
// Date utilities (no external deps)
// ============================================================================

/**
 * Parse YYYY-MM-DD to a UTC Date at noon (avoids DST issues).
 */
function parseDate(s: string): Date {
  return new Date(s + "T12:00:00Z");
}

function formatDate(d: Date): string {
  return d.toISOString().slice(0, 10);
}

function addDays(d: Date, n: number): Date {
  return new Date(d.getTime() + n * 86400000);
}

function diffDays(a: Date, b: Date): number {
  return Math.round((a.getTime() - b.getTime()) / 86400000);
}

/**
 * 0=Sun, 1=Mon, ..., 6=Sat (consistent with Date.getUTCDay())
 */
function getUTCDayOfWeek(d: Date): number {
  return d.getUTCDay();
}

const WEEKEND_BY_SCHEDULE: Record<WorkDays, Set<number>> = {
  // Date.getUTCDay(): 0=Sun, 1=Mon, ..., 6=Sat
  "mon-fri":  new Set([0, 6]),     // Sat=6, Sun=0
  "sun-thu":  new Set([5, 6]),     // Fri=5, Sat=6 (Middle East)
  "fri-sat":  new Set([4, 5]),     // Thu=4, Fri=5 (Israel)
  "sat-wed":  new Set([3, 4]),     // Wed=3, Thu=4
};

function isWeekendDay(date: string, schedule: WorkDays): boolean {
  return WEEKEND_BY_SCHEDULE[schedule].has(getUTCDayOfWeek(parseDate(date)));
}

// ============================================================================
// Holiday expansion
// ============================================================================

/**
 * Expand multi-day holidays into individual day records.
 * E.g., Diwali Oct 18-22 → 5 records for Oct 18, 19, 20, 21, 22.
 */
function expandHolidays(holidays: Holiday[]): Map<string, Holiday[]> {
  const dayMap = new Map<string, Holiday[]>();
  for (const h of holidays) {
    const start = parseDate(h.date);
    const end = h.endDate ? parseDate(h.endDate) : start;
    let cur = start;
    while (cur <= end) {
      const dayKey = formatDate(cur);
      if (!dayMap.has(dayKey)) dayMap.set(dayKey, []);
      dayMap.get(dayKey)!.push(h);
      cur = addDays(cur, 1);
    }
  }
  return dayMap;
}

// ============================================================================
// Core algorithm: find all "off blocks" of N+ days
// ============================================================================

interface DayMark {
  date: string;
  off: boolean;
  holiday: Holiday | null;
  isOptional: boolean;
}

function findOffBlocks(
  yearDays: Date[],
  holidayMap: Map<string, Holiday[]>,
  schedule: WorkDays,
  minDays: number,
  includeOptional: boolean,
): LongWeekend[] {
  const marks: DayMark[] = yearDays.map((d) => {
    const dateKey = formatDate(d);
    const holidays = holidayMap.get(dateKey) || [];
    const weekendDay = isWeekendDay(dateKey, schedule);
    const validHolidays = holidays.filter((h) => {
      if (includeOptional) return true;
      return h.filterCode === "PUBLIC_NATIONAL" || h.filterCode === "PUBLIC_LOCAL";
    });
    const off = weekendDay || validHolidays.length > 0;
    const trigger = validHolidays.find((h) => h.filterCode !== "OPTIONAL_HOLIDAY") || validHolidays[0] || null;
    const isOptional = trigger?.filterCode === "OPTIONAL_HOLIDAY" || false;
    return { date: dateKey, off, holiday: trigger, isOptional };
  });

  const blocks: LongWeekend[] = [];
  let cur: DayMark[] = [];
  for (const m of marks) {
    if (m.off) {
      cur.push(m);
    } else {
      if (cur.length >= minDays) {
        blocks.push(buildLongWeekend(cur));
      }
      cur = [];
    }
  }
  if (cur.length >= minDays) {
    blocks.push(buildLongWeekend(cur));
  }
  return blocks;
}

function buildLongWeekend(days: DayMark[]): LongWeekend {
  if (days.length === 0) {
    return { start: "", end: "", days: 0, type: "3-day", trigger: "", holidays: [], includesOptional: false };
  }
  const start = days[0]!.date;
  const end = days[days.length - 1]!.date;
  const len = days.length;
  let type: LongWeekend["type"];
  if (len === 3) type = "3-day";
  else if (len === 4) type = "4-day";
  else if (len === 5) type = "5-day";
  else if (len === 6) type = "6-day";
  else if (len === 7) type = "7-day";
  else type = "extended";

  const holidaySet = new Map<string, Holiday>();
  for (const d of days) {
    if (d.holiday) {
      holidaySet.set(d.holiday.date, d.holiday);
    }
  }
  const holidayList = Array.from(holidaySet.values()).sort((a, b) => a.date.localeCompare(b.date));
  const trigger = holidayList[0]?.name || "weekend";
  const holidays = holidayList.map((h) => `${h.name} (${h.date})`);
  const includesOptional = days.some((d) => d.isOptional);

  return { start, end, days: len, type, trigger, holidays, includesOptional };
}

// ============================================================================
// PTO extension analysis
// ============================================================================

/**
 * For a given long weekend, compute the optimal PTO strategies:
 * - Take 1, 2, or 3 days off before/after the natural break
 * - Return strategies sorted by efficiency (days off per PTO day)
 */
export function computePTOExtensions(
  weekend: LongWeekend,
  yearDays: Date[],
  holidayMap: Map<string, Holiday[]>,
  schedule: WorkDays,
  maxPto: number = 3,
): PTOExtension[] {
  const startDt = parseDate(weekend.start);
  const endDt = parseDate(weekend.end);
  const naturalDays = weekend.days;
  const extensions: PTOExtension[] = [];

  for (let n = 1; n <= maxPto; n++) {
    // BEFORE: extend n calendar days back, counting only workdays as PTO
    // (weekends and holidays in the way don't require PTO)
    const beforePto: string[] = [];
    let cur = addDays(startDt, -1);
    let stepCount = 0;
    while (stepCount < n * 3) {  // safety: walk up to 3n days back
      const key = formatDate(cur);
      if (isWeekendDay(key, schedule) || (holidayMap.get(key) || []).length > 0) {
        cur = addDays(cur, -1);
        continue;
      }
      beforePto.push(key);
      cur = addDays(cur, -1);
      if (beforePto.length >= n) break;
      stepCount++;
    }
    if (beforePto.length === n && beforePto[0]) {
      const newStart = parseDate(beforePto[0]);
      const blockDays = diffDays(endDt, newStart) + 1;
      extensions.push({
        ptoDays: beforePto,
        totalOff: blockDays,
        efficiency: blockDays / n,
        extendsTo: weekend.end,
        direction: "before",
      });
    }

    // AFTER: extend n calendar days forward
    const afterPto: string[] = [];
    cur = addDays(endDt, 1);
    stepCount = 0;
    while (stepCount < n * 3) {
      const key = formatDate(cur);
      if (isWeekendDay(key, schedule) || (holidayMap.get(key) || []).length > 0) {
        cur = addDays(cur, 1);
        continue;
      }
      afterPto.push(key);
      cur = addDays(cur, 1);
      if (afterPto.length >= n) break;
      stepCount++;
    }
    if (afterPto.length === n && afterPto[afterPto.length - 1]) {
      const newEnd = parseDate(afterPto[afterPto.length - 1]!);
      const blockDays = diffDays(newEnd, startDt) + 1;
      extensions.push({
        ptoDays: afterPto,
        totalOff: blockDays,
        efficiency: blockDays / n,
        extendsTo: formatDate(newEnd),
        direction: "after",
      });
    }
  }

  // Sort by efficiency (best ROI first), then by totalOff
  extensions.sort((a, b) => b.efficiency - a.efficiency || b.totalOff - a.totalOff);
  // Dedupe by ptoDays + direction
  const seen = new Set<string>();
  return extensions.filter((e) => {
    const key = e.direction + "|" + e.ptoDays.join(",");
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

// ============================================================================
// Public API
// ============================================================================

export interface LongWeekendResult {
  countryCode: string;
  year: number;
  workDays: WorkDays;
  minDays: number;
  includeOptional: boolean;
  longWeekends: LongWeekend[];
  ptoStrategies?: Record<string, PTOExtension[]>;
  totalLongWeekends: number;
  totalDaysOff: number;
  summary: {
    "3-day": number;
    "4-day": number;
    "5-day": number;
    "6-day+": number;
  };
}

/**
 * Main entry point: compute all long weekends for a country + year.
 */
export function computeLongWeekends(
  holidays: Holiday[],
  year: number,
  options: LongWeekendOptions = {},
): LongWeekendResult {
  const {
    workDays = "mon-fri",
    minDays = 3,
    includeOptional = true,
    subdivisions,
  } = options;

  // Filter by subdivision if specified
  let filtered = holidays;
  if (subdivisions && subdivisions.length > 0) {
    filtered = filtered.filter(
      (h) => !h.subdivisionCode || subdivisions.includes(h.subdivisionCode)
    );
  }

  const holidayMap = expandHolidays(filtered);
  const yearDays = buildYearDays(year);

  const longWeekends = findOffBlocks(yearDays, holidayMap, workDays, minDays, includeOptional);

  // Compute PTO strategies for each
  const ptoStrategies: Record<string, PTOExtension[]> = {};
  for (const w of longWeekends) {
    const exts = computePTOExtensions(w, yearDays, holidayMap, workDays, 3);
    if (exts.length > 0) {
      ptoStrategies[w.start] = exts;
    }
  }

  // Summary
  const summary = { "3-day": 0, "4-day": 0, "5-day": 0, "6-day+": 0 };
  let totalDaysOff = 0;
  for (const w of longWeekends) {
    totalDaysOff += w.days;
    if (w.type === "3-day") summary["3-day"]++;
    else if (w.type === "4-day") summary["4-day"]++;
    else if (w.type === "5-day") summary["5-day"]++;
    else summary["6-day+"]++;
  }

  return {
    countryCode: "",
    year,
    workDays,
    minDays,
    includeOptional,
    longWeekends,
    ptoStrategies: Object.keys(ptoStrategies).length > 0 ? ptoStrategies : undefined,
    totalLongWeekends: longWeekends.length,
    totalDaysOff,
    summary,
  };
}

function buildYearDays(year: number): Date[] {
  // Build all days in the year + 1 day overlap on each side (for cross-year breaks)
  const start = new Date(Date.UTC(year - 1, 11, 31, 12));
  const end = new Date(Date.UTC(year + 1, 0, 1, 12));
  const days: Date[] = [];
  let cur = start;
  while (cur <= end) {
    days.push(cur);
    cur = addDays(cur, 1);
  }
  return days;
}

// ============================================================================
// PTO strategy for a year — "what's the best way to use N PTO days?"
// ============================================================================

export interface YearPTOStrategy {
  totalPtoUsed: number;
  totalDaysOff: number;
  strategies: Array<{
    ptoDays: string[];
    longWeekendStart: string;
    longWeekendEnd: string;
    naturalDays: number;
    extendedDays: number;
    efficiency: number;
  }>;
  coverage: string;
}

/**
 * Given a list of long weekends and PTO extensions, find the best N-PTO-day strategy.
 * Uses greedy selection: pick non-overlapping options that maximize total days off.
 */
export function planYearPTO(
  longWeekends: LongWeekend[],
  ptoStrategies: Record<string, PTOExtension[]>,
  availablePto: number,
): YearPTOStrategy {
  type Strategy = {
    ptoDays: string[];
    longWeekendStart: string;
    longWeekendEnd: string;
    naturalDays: number;
    extendedDays: number;
    efficiency: number;
  };

  const allOptions: Strategy[] = [];
  for (const w of longWeekends) {
    const exts = ptoStrategies[w.start] || [];
    for (const ext of exts) {
      allOptions.push({
        ptoDays: ext.ptoDays,
        longWeekendStart: w.start,
        longWeekendEnd: w.end,
        naturalDays: w.days,
        extendedDays: ext.totalOff,
        efficiency: ext.efficiency,
      });
    }
  }

  // Sort by efficiency
  allOptions.sort((a, b) => b.efficiency - a.efficiency);

  // Greedy selection
  const usedPtoDates = new Set<string>();
  const selected: Strategy[] = [];
  for (const opt of allOptions) {
    const conflict = opt.ptoDays.some((d) => usedPtoDates.has(d));
    if (conflict) continue;
    if (opt.ptoDays.length > availablePto - usedPtoDates.size) continue;
    for (const d of opt.ptoDays) usedPtoDates.add(d);
    selected.push(opt);
  }

  const totalPtoUsed = usedPtoDates.size;
  const baseDays = longWeekends.reduce((sum, w) => sum + w.days, 0);
  const extraDays = selected.reduce((sum, s) => sum + (s.extendedDays - s.naturalDays), 0);
  const totalDaysOff = baseDays + extraDays;

  return {
    totalPtoUsed,
    totalDaysOff,
    strategies: selected,
    coverage: `${Math.round(totalDaysOff / 7)} weeks off out of 52 (${((totalDaysOff / 7) / 52 * 100).toFixed(1)}%)`,
  };
}
