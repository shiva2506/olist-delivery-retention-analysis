from statsmodels.stats.proportion import proportions_ztest, proportion_confint

late_returned, late_total = 115, 5690
ontime_returned, ontime_total = 1618, 69650

z, p = proportions_ztest(
    [late_returned, ontime_returned],
    [late_total, ontime_total],
)
print("z =", round(z, 3), " p-value =", round(p, 4))

for name, c, n in [("late first order", late_returned, late_total),
                   ("on-time first order", ontime_returned, ontime_total)]:
    low, high = proportion_confint(c, n, method="wilson")
    print(name, ":", round(100 * c / n, 2), "%  (95% range:",
          round(100 * low, 2), "to", round(100 * high, 2), "%)")
