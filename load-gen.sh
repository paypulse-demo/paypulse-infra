# Save as load-gen.sh
while true; do
  curl -s https://api.beleaderinnohub.com/notifications/test > /dev/null
  curl -s https://api.beleaderinnohub.com/notifications/eur-test > /dev/null
  curl -s https://api.beleaderinnohub.com/notifications/usd-test > /dev/null
  sleep 2
done