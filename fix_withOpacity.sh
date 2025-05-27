#!/bin/bash

# Script to fix deprecated withOpacity calls in Flutter project

echo "Fixing withOpacity deprecated calls..."

# Find all Dart files and replace withOpacity with withValues
find lib -name "*.dart" -type f -exec sed -i 's/\.withOpacity(\([^)]*\))/\.withValues(alpha: \1)/g' {} \;

echo "withOpacity replacements completed!"

# Count remaining instances
remaining=$(find lib -name "*.dart" -exec grep -c "withOpacity(" {} \; | awk '{sum += $1} END {print sum}')
echo "Remaining withOpacity instances: $remaining"
