#!/bin/bash
day=$(date +%e | sed 's/^ //')
echo "<tt>"
cal | sed "s/\b$day\b/<span background=\"#0abdc6\" foreground=\"black\">$day<\/span>/"
echo "</tt>"
