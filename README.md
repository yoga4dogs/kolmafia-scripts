# kolmafia-scripts

Small KoLmafia ASH and relay-browser utilities.

## Login scripts

- `raffle_login.ash` adds a browser notice for the day's raffle prize.
- `daily_reminders.ash` adds notices for useful unfinished daily actions:
  available free rests when HP or MP is missing, garden growth, and the Daily
  Dungeon. It only reports; it never performs the actions.

To run both after login, add them to KoLmafia's **Login Script** setting, or
call them from your existing login script:

```ash
cli_execute("raffle_login.ash");
cli_execute("daily_reminders.ash");
```

Each daily reminder can be disabled from the gCLI:

```text
set dailyRemindersFreeRests = false
set dailyRemindersGarden = false
set dailyRemindersDailyDungeon = false
```

The notices are displayed by `relay/main.ash` when the main pane loads.
