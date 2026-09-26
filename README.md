# kolmafia-scripts

Small KoLmafia ASH and relay-browser utilities.

## Login scripts

- `raffle_login.ash` adds a browser notice for the day's raffle prize.
- `daily_reminders.ash` adds notices for useful unfinished daily actions:
  available free rests when HP or MP is missing, garden growth, the Daily
  Dungeon, the Neverending Party quest, and available bounty assignments. The
  party notice is suppressed after learning `Drinking to Drink`. The script
  only reports; it never accepts a quest, spends a turn, or harvests anything.

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
set dailyRemindersNeverendingParty = false
set dailyRemindersBounties = false
```

The notices are displayed by `relay/main.ash` when the main pane loads.
Running `daily_reminders.ash` again rebuilds its notices, so disabled or newly
completed reminders disappear after the main pane is refreshed.
