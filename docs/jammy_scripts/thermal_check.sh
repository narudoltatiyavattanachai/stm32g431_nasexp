# Show type and temp for all zones:
for z in /sys/class/thermal/thermal_zone*; do
  echo -n "$z : "
  cat $z/type
  echo -n "  Temp: "
  cat $z/temp
done

