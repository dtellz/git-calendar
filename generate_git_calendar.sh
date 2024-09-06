#!/bin/bash

# This script generates an HTML file with Git commit history and displays commit messages on a calendar.

# Output HTML file
OUTPUT_FILE="git_commit_calendar.html"

# Get git log and extract commit date, author name, and message
# Format: Full date and time in ISO format, followed by the author name and the commit message
commit_log=$(git log --pretty=format:'%ad|%an|%s' --date=iso)

# Create the HTML file
cat <<EOF > $OUTPUT_FILE
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Git Commit Calendar</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.10.2/fullcalendar.min.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.1/moment.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.10.2/fullcalendar.min.js"></script>
</head>
<body>
    <h1>Git Commit History Calendar</h1>

    <div id="commit-message" style="margin-bottom: 20px; padding: 10px; border: 1px solid #ddd; display: none;">
        <h2>Commit Message</h2>
        <p id="message"></p>
    </div>

    <div id="calendar"></div>

    <script>
        \$(document).ready(function() {
            // Initialize FullCalendar
            \$('#calendar').fullCalendar({
                defaultView: 'month',
                editable: false,
                events: [
EOF

# Loop through the commit log and extract dates, authors, and messages for the calendar events
while IFS='|' read -r commit_date commit_author commit_message; do
    # Remove timezone information (which is after the last part of the date)
    commit_date=$(echo "$commit_date" | awk '{print $1"T"$2}')

    # Escape double quotes and backslashes in commit message to avoid breaking JavaScript
    commit_message=$(echo "$commit_message" | sed 's/["\\]/\\&/g')

    # Escape double quotes and backslashes in commit author to avoid breaking JavaScript
    commit_author=$(echo "$commit_author" | sed 's/["\\]/\\&/g')

    cat <<EOF >> $OUTPUT_FILE
                    {
                        title: '$commit_author',
                        start: '$commit_date',
                        color: '#4CAF50',
                        description: "$commit_message"
                    },
EOF
done <<< "$commit_log"

# Complete the HTML with the event click functionality
cat <<EOF >> $OUTPUT_FILE
                ],
                eventClick: function(event) {
                    \$('#commit-message').show();  // Show the commit message container
                    \$('#message').text(event.description);  // Display the commit message in the container
                }
            });
        });
    </script>
</body>
</html>
EOF

# Output success message
echo "HTML file generated: $OUTPUT_FILE"

# Detect the operating system and open the file
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "$OUTPUT_FILE"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    xdg-open "$OUTPUT_FILE"
else
    echo "Unsupported OS. Please open the file manually: $OUTPUT_FILE"
fi
