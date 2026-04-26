# Group by instance instead of database
for db in $(srvctl config database); do
  echo "Database: $db"
  for inst in $(srvctl status database -d $db | grep "is running" | awk '{print $2}'); do
    echo "  Instance: $inst"
    srvctl status service -d $db | grep $inst | awk '{print "    - "$2}'
  done
  echo ""
done
