bash$ awk  --re-interval '!(/^[0-9]{4}-[0-9]{2}-[0-9]{2}([ \t]+[-]?[0-9]+\.[0-9]+[\t ]+[-]?[0-9]+){24}+$/ )' readings.txt
bash$
