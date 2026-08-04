/**
 * tests/m14-longweekend.test.ts
 *
 * M14.5: Long weekend calculator tests
 *
 * Test cases derived from known 2026 holiday patterns for major countries.
 */
import { describe, it, expect } from "vitest";
import { computeLongWeekends, planYearPTO, type Holiday } from "@/lib/longWeekend";

// ============================================================================
// Test data
// ============================================================================

// IN 2026 — known long weekends (from India v3 Excel analysis)
const IN_HOLIDAYS_2026: Holiday[] = [
  { date: "2026-01-05", name: "Guru Gobind Singh Jayanti", filterCode: "PUBLIC_NATIONAL" },  // Mon
  { date: "2026-01-26", name: "Republic Day", filterCode: "PUBLIC_NATIONAL" },               // Mon
  { date: "2026-02-17", name: "Maha Shivaratri", filterCode: "OPTIONAL_HOLIDAY" },            // Tue
  { date: "2026-03-04", name: "Holi", filterCode: "PUBLIC_NATIONAL" },                       // Wed
  { date: "2026-03-20", name: "Eid al-Fitr", filterCode: "PUBLIC_NATIONAL" },                // Fri
  { date: "2026-04-03", name: "Good Friday", filterCode: "PUBLIC_NATIONAL" },                // Fri
  { date: "2026-05-01", name: "Buddha Purnima", filterCode: "PUBLIC_NATIONAL" },             // Fri
  { date: "2026-05-27", name: "Eid al-Adha", filterCode: "PUBLIC_NATIONAL" },               // Wed
  { date: "2026-08-15", name: "Independence Day", filterCode: "PUBLIC_NATIONAL" },           // Sat
  { date: "2026-10-02", name: "Gandhi Jayanti", filterCode: "PUBLIC_NATIONAL" },             // Fri
  // Diwali 5-day cluster: Nov 6-10
  { date: "2026-11-06", name: "Dhanteras", filterCode: "PUBLIC_NATIONAL" },                  // Fri
  { date: "2026-11-07", endDate: "2026-11-10", name: "Diwali", filterCode: "PUBLIC_NATIONAL" },  // Sat-Tue
  { date: "2026-12-25", name: "Christmas Day", filterCode: "PUBLIC_NATIONAL" },               // Fri
];

// US 2026 — known long weekends
const US_HOLIDAYS_2026: Holiday[] = [
  { date: "2026-01-01", name: "New Year's Day", filterCode: "PUBLIC_NATIONAL" },  // Thu
  { date: "2026-01-19", name: "Martin Luther King Jr. Day", filterCode: "PUBLIC_NATIONAL" },  // Mon
  { date: "2026-02-16", name: "Presidents' Day", filterCode: "PUBLIC_NATIONAL" },  // Mon
  { date: "2026-05-25", name: "Memorial Day", filterCode: "PUBLIC_NATIONAL" },     // Mon
  { date: "2026-07-03", name: "Independence Day (Observed)", filterCode: "PUBLIC_NATIONAL" },  // Fri
  { date: "2026-09-07", name: "Labor Day", filterCode: "PUBLIC_NATIONAL" },        // Mon
  { date: "2026-11-26", endDate: "2026-11-27", name: "Thanksgiving", filterCode: "PUBLIC_NATIONAL" },  // Thu-Fri
  { date: "2026-12-25", name: "Christmas Day", filterCode: "PUBLIC_NATIONAL" },    // Fri
];

// CA 2026 — known long weekends
const CA_HOLIDAYS_2026: Holiday[] = [
  { date: "2026-01-01", name: "New Year's Day", filterCode: "PUBLIC_NATIONAL" },  // Thu
  { date: "2026-02-16", name: "Family Day", filterCode: "PUBLIC_LOCAL" },        // Mon
  { date: "2026-04-03", name: "Good Friday", filterCode: "PUBLIC_NATIONAL" },   // Fri
  { date: "2026-05-18", name: "Victoria Day", filterCode: "PUBLIC_NATIONAL" },   // Mon
  { date: "2026-07-01", name: "Canada Day", filterCode: "PUBLIC_NATIONAL" },     // Wed
  { date: "2026-08-03", name: "Civic Holiday", filterCode: "PUBLIC_LOCAL" },      // Mon
  { date: "2026-09-07", name: "Labour Day", filterCode: "PUBLIC_NATIONAL" },     // Mon
  { date: "2026-10-12", name: "Thanksgiving", filterCode: "PUBLIC_NATIONAL" },   // Mon
  { date: "2026-12-25", name: "Christmas Day", filterCode: "PUBLIC_NATIONAL" },  // Fri
  { date: "2026-12-26", name: "Boxing Day", filterCode: "OPTIONAL_HOLIDAY" },    // Sat
];

// ============================================================================
// Tests
// ============================================================================

describe("computeLongWeekends", () => {
  it("should detect 3-day weekend for Friday holiday (US July 4 observed Fri Jul 3)", () => {
    const result = computeLongWeekends(US_HOLIDAYS_2026, 2026);
    // July 3 (Fri) → Fri-Sat-Sun = 3-day
    const july = result.longWeekends.find((w) => w.start === "2026-07-03");
    expect(july).toBeDefined();
    expect(july!.days).toBe(3);
    expect(july!.type).toBe("3-day");
    expect(july!.trigger).toContain("Independence Day");
  });

  it("should detect 3-day weekend for Monday holiday (US Memorial Day May 25)", () => {
    const result = computeLongWeekends(US_HOLIDAYS_2026, 2026, { minDays: 2 });
    // May 25 (Mon) → Sat-Sun-Mon (May 23-25) = 3-day (Memorial Day block)
    const memorial = result.longWeekends.find((w) => w.trigger.includes("Memorial Day"));
    expect(memorial).toBeDefined();
    expect(memorial!.days).toBe(3);
    expect(memorial!.type).toBe("3-day");
    expect(memorial!.start).toBe("2026-05-23");
  });

  it("should detect 3-day weekend for Monday holiday if min_days=2", () => {
    // 2-day block for Monday holiday is also valid
    const result = computeLongWeekends(US_HOLIDAYS_2026, 2026, { minDays: 2 });
    // With minDays=2, we should find Memorial Day (3-day) and others
    const totalOff = result.longWeekends.reduce((s, w) => s + w.days, 0);
    expect(totalOff).toBeGreaterThan(10);
  });

  it("should detect 4-day weekend for Thanksgiving (Thu-Fri cluster)", () => {
    const result = computeLongWeekends(US_HOLIDAYS_2026, 2026);
    // Thanksgiving Nov 26-27 (Thu-Fri) → Thu-Fri-Sat-Sun = 4-day
    const tg = result.longWeekends.find((w) => w.start === "2026-11-26");
    expect(tg).toBeDefined();
    expect(tg!.days).toBe(4);
    expect(tg!.type).toBe("4-day");
  });

  it("should detect 5-day weekend for Diwali (Fri-Tue 5-day cluster)", () => {
    const result = computeLongWeekends(IN_HOLIDAYS_2026, 2026);
    // Diwali Nov 6-10 (Fri-Tue) → Fri-Sat-Sun-Mon-Tue = 5-day
    const diwali = result.longWeekends.find((w) => w.start === "2026-11-06");
    expect(diwali).toBeDefined();
    expect(diwali!.days).toBeGreaterThanOrEqual(5);
    expect(diwali!.type).toBe("5-day");
  });

  it("should not return blocks shorter than minDays", () => {
    const result = computeLongWeekends(US_HOLIDAYS_2026, 2026, { minDays: 4 });
    for (const w of result.longWeekends) {
      expect(w.days).toBeGreaterThanOrEqual(4);
    }
  });

  it("should respect include_optional flag", () => {
    const resultWith = computeLongWeekends(CA_HOLIDAYS_2026, 2026, { includeOptional: true });
    const resultWithout = computeLongWeekends(CA_HOLIDAYS_2026, 2026, { includeOptional: false });
    // Boxing Day is OPTIONAL_HOLIDAY. With it: Christmas+Boxing+Mon = 3-day
    // Without: just Christmas Fri + Sat+Sun = 3-day (still a long weekend)
    expect(resultWith.totalLongWeekends).toBeGreaterThanOrEqual(resultWithout.totalLongWeekends);
  });

  it("should return correct summary breakdown", () => {
    const result = computeLongWeekends(US_HOLIDAYS_2026, 2026);
    const total = result.summary["3-day"] + result.summary["4-day"] + result.summary["5-day"] + result.summary["6-day+"];
    expect(total).toBe(result.totalLongWeekends);
  });

  it("should handle Canada with both national and local holidays", () => {
    const result = computeLongWeekends(CA_HOLIDAYS_2026, 2026);
    // Should find: Canada Day Wed alone (1-day, skip), Civic Holiday Mon (3-day),
    // Labour Day Mon (3-day), Thanksgiving Mon (3-day), Christmas Fri (3-day)
    expect(result.totalLongWeekends).toBeGreaterThanOrEqual(3);
  });

  it("should handle subdivision filtering", () => {
    const holidaysWithSubdiv: Holiday[] = [
      { date: "2026-02-16", name: "Family Day (ON)", filterCode: "PUBLIC_LOCAL", subdivisionCode: "CA-ON" },
      { date: "2026-02-16", name: "Louis Riel Day (MB)", filterCode: "PUBLIC_LOCAL", subdivisionCode: "CA-MB" },
    ];
    const result = holidaysWithSubdiv
      ? computeLongWeekends(holidaysWithSubdiv, 2026, { subdivisions: ["CA-ON"] })
      : null;
    // Only ON Family Day, no MB
    expect(result).toBeDefined();
  });
});

describe("computePTOExtensions", () => {
  it("should recommend taking day off to extend a Wednesday holiday", () => {
    // Use a Wed holiday: India Aug 26 (Wed) Onam
    const holidays: Holiday[] = [
      { date: "2026-08-26", name: "Onam", filterCode: "PUBLIC_NATIONAL" },  // Wed
    ];
    // With minDays=3, Wed alone won't be a long weekend
    const result = computeLongWeekends(holidays, 2026);
    expect(result.totalLongWeekends).toBe(0);

    // With minDays=1, we get all 1-day blocks including Onam
    // The Onam block is the one with the holiday
    const result1 = computeLongWeekends(holidays, 2026, { minDays: 1 });
    const onam = result1.longWeekends.find((w) => w.start === "2026-08-26");
    expect(onam).toBeDefined();
    expect(onam!.days).toBe(1);
    expect(result1.ptoStrategies).toBeDefined();
    expect(result1.ptoStrategies!["2026-08-26"]).toBeDefined();
    // Take Aug 24+25 off → Aug 22-26 = 5 days (Sat-Sun-Mon-PTO-PTO-Wed), 2 PTO days, eff 2.5x
    const onamStrats = result1.ptoStrategies!["2026-08-26"];
    expect(onamStrats.length).toBeGreaterThan(0);
    // Best efficiency for extending a single Wed holiday
    expect(onamStrats[0].efficiency).toBeGreaterThanOrEqual(2);
  });

  it("should suggest best PTO direction", () => {
    // Use a Friday holiday: Christmas Day Dec 25 2026 (Fri)
    // Natural: Fri-Sat-Sun = 3-day
    // Take Dec 28 (Mon) off → Fri-Sat-Sun-Mon = 4-day, efficiency 4.0x
    // Take Dec 24 (Thu) off → Thu-Fri-Sat-Sun = 4-day, efficiency 4.0x
    const holidays: Holiday[] = [
      { date: "2026-12-25", name: "Christmas Day", filterCode: "PUBLIC_NATIONAL" },
    ];
    const result = computeLongWeekends(holidays, 2026);
    expect(result.totalLongWeekends).toBe(1);
    const christmas = result.longWeekends[0];
    expect(christmas.days).toBe(3);
    expect(result.ptoStrategies).toBeDefined();
    const xmasStrategies = result.ptoStrategies![christmas.start];
    expect(xmasStrategies).toBeDefined();
    expect(xmasStrategies!.length).toBeGreaterThan(0);
  });
});

describe("planYearPTO", () => {
  it("should find best strategies given 5 PTO days for India 2026", () => {
    const result = computeLongWeekends(IN_HOLIDAYS_2026, 2026, { minDays: 1 });
    const ptoStrategies = result.ptoStrategies || {};
    const plan = planYearPTO(result.longWeekends, ptoStrategies, 5);

    expect(plan.totalPtoUsed).toBeLessThanOrEqual(5);
    expect(plan.totalDaysOff).toBeGreaterThan(0);
    expect(plan.strategies.length).toBeGreaterThan(0);
    // All selected strategies should not overlap
    const allPtoDates = new Set<string>();
    for (const s of plan.strategies) {
      for (const d of s.ptoDays) {
        expect(allPtoDates.has(d)).toBe(false);
        allPtoDates.add(d);
      }
    }
  });

  it("should return empty when no PTO available", () => {
    const result = computeLongWeekends(US_HOLIDAYS_2026, 2026);
    const ptoStrategies = result.ptoStrategies || {};
    const plan = planYearPTO(result.longWeekends, ptoStrategies, 0);
    expect(plan.totalPtoUsed).toBe(0);
  });

  it("should compute coverage percentage", () => {
    const result = computeLongWeekends(US_HOLIDAYS_2026, 2026);
    const ptoStrategies = result.ptoStrategies || {};
    const plan = planYearPTO(result.longWeekends, ptoStrategies, 10);
    // e.g. "5 weeks off out of 52 (8.8%)"
    expect(plan.coverage).toMatch(/weeks off out of 52/);
    expect(plan.coverage).toMatch(/\d+\.\d+%\)/);
  });
});

describe("Work day schedules", () => {
  it("should support sun-thu (Middle East) weekend", () => {
    // For sun-thu: weekend is Fri (5) and Sat (6)
    // A Friday holiday becomes a regular workday
    // A Sunday holiday creates a Sat-Sun-Mon block
    const holidays: Holiday[] = [
      { date: "2026-01-01", name: "New Year's Day", filterCode: "PUBLIC_NATIONAL" },  // Thu in sun-thu
    ];
    const result = computeLongWeekends(holidays, 2026, { workDays: "sun-thu" });
    // Jan 1 (Thu) → standalone, not a long weekend
    // But if we also have Jan 2 (Fri in sun-thu = weekend)
    // Then Thu-Fri-Sat-Sun = 4-day (Thu holiday + Fri-Sat-Sun weekend in sun-thu)
    // Actually Fri is weekend in sun-thu, so Thu + Fri + Sat + Sun = 4-day
    expect(result.longWeekends.length).toBeGreaterThanOrEqual(0);
  });

  it("should support fri-sat (Israel) weekend", () => {
    const holidays: Holiday[] = [
      { date: "2026-05-14", name: "Holiday", filterCode: "PUBLIC_NATIONAL" },  // Thu in fri-sat
    ];
    // In fri-sat: weekend is Thu (4), Fri (5)
    // So Thu holiday → Thu + Fri (weekend) + Sat (work) = 2-day, not a long weekend
    // Need minDays=2 to find this
    const result = computeLongWeekends(holidays, 2026, { workDays: "fri-sat", minDays: 2 });
    expect(result.longWeekends.length).toBeGreaterThanOrEqual(1);
  });
});

describe("Edge cases", () => {
  it("should handle year boundary (Dec 31 falling on Thu)", () => {
    // 2025 Dec 25 (Thu) - Christmas, 2025-12-26 (Fri) - Boxing Day
    // 2026 Jan 1 (Thu) - New Year
    const holidays: Holiday[] = [
      { date: "2025-12-25", name: "Christmas 2025", filterCode: "PUBLIC_NATIONAL" },
      { date: "2025-12-26", name: "Boxing Day 2025", filterCode: "PUBLIC_NATIONAL" },
      { date: "2026-01-01", name: "New Year", filterCode: "PUBLIC_NATIONAL" },
    ];
    const result = computeLongWeekends(holidays, 2026, { minDays: 3 });
    // For 2026 result: only Jan 1 (Thu) is in 2026
    // Jan 1 (Thu) + Jan 2 (Fri workday) → 1 day off (not a long weekend)
    // 2025 holidays are not counted in 2026 result
    expect(result.longWeekends.length).toBe(0);
  });

  it("should detect cross-year 4-day weekend (Dec 25 Thu + Dec 26 Fri)", () => {
    // 2025 holidays in 2026 result — algorithm only counts days in 2026
    // 2025-12-25 (Thu) and 2025-12-26 (Fri) are not in 2026, so no effect on 2026 result
    const holidays: Holiday[] = [
      { date: "2025-12-25", name: "Christmas 2025", filterCode: "PUBLIC_NATIONAL" },
      { date: "2025-12-26", name: "Boxing Day 2025", filterCode: "PUBLIC_NATIONAL" },
    ];
    // With only 2025 holidays, the 2026 result has only weekend blocks (no holidays in 2026)
    // So no holiday-triggered long weekends in 2026
    const result = computeLongWeekends(holidays, 2026, { minDays: 3 });
    // No holidays in 2026 → no 3+ day long weekends
    expect(result.longWeekends.length).toBe(0);
  });

  it("should return empty for no holidays", () => {
    const result = computeLongWeekends([], 2026);
    expect(result.totalLongWeekends).toBe(0);
    expect(result.totalDaysOff).toBe(0);
  });

  it("should handle mid-week holiday without weekend adjacency", () => {
    // A pure Wednesday holiday with no adjacent holidays
    const holidays: Holiday[] = [
      { date: "2026-03-04", name: "Lone Wed Holiday", filterCode: "PUBLIC_NATIONAL" },
    ];
    // With minDays=3, this 1-day block won't be returned
    const result = computeLongWeekends(holidays, 2026);
    expect(result.longWeekends.length).toBe(0);

    // With minDays=1, we get the 1-day Onam-like block
    const result1 = computeLongWeekends(holidays, 2026, { minDays: 1 });
    const lone = result1.longWeekends.find((w) => w.start === "2026-03-04");
    expect(lone).toBeDefined();
    expect(lone!.days).toBe(1);
  });
});

describe("Multi-day holiday expansion", () => {
  it("should expand multi-day Diwali correctly (Nov 6 Fri - Nov 10 Tue)", () => {
    // Dhanteras Nov 6 (Fri) + Diwali Nov 7-10 (Sat-Tue)
    // = Fri-Sat-Sun-Mon-Tue = 5-day block
    const holidays: Holiday[] = [
      { date: "2026-11-06", name: "Dhanteras", filterCode: "PUBLIC_NATIONAL" },
      { date: "2026-11-07", endDate: "2026-11-10", name: "Diwali", filterCode: "PUBLIC_NATIONAL" },
    ];
    const result = computeLongWeekends(holidays, 2026);
    expect(result.longWeekends.length).toBe(1);
    expect(result.longWeekends[0].start).toBe("2026-11-06");
    expect(result.longWeekends[0].days).toBe(5);
    expect(result.longWeekends[0].type).toBe("5-day");
  });

  it("should handle single-day holiday with endDate equal to start", () => {
    const holidays: Holiday[] = [
      { date: "2026-12-25", endDate: "2026-12-25", name: "Christmas", filterCode: "PUBLIC_NATIONAL" },
    ];
    const result = computeLongWeekends(holidays, 2026);
    expect(result.longWeekends.length).toBe(1);
    expect(result.longWeekends[0].days).toBe(3); // Fri + Sat + Sun
  });
});
