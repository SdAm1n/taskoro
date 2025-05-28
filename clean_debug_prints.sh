#!/bin/bash

# Script to clean up debug print statements in Flutter project

echo "Cleaning up debug print statements..."

# Remove print statements but keep important ones by replacing with debugPrint
find lib -name "*.dart" -type f -exec sed -i 's/print(/debugPrint(/g' {} \;

echo "Print statements cleanup completed!"

# Count remaining print instances
remaining=$(find lib -name "*.dart" -exec grep -c "print(" {} \; | awk '{sum += $1} END {print sum}')
echo "Remaining print instances: $remaining"

# Show debugPrint instances
debugs=$(find lib -name "*.dart" -exec grep -c "debugPrint(" {} \; | awk '{sum += $1} END {print sum}')
echo "DebugPrint instances: $debugs"
