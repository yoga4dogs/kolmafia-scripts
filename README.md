# kolmafia-scripts

Small KoLmafia ASH and relay-browser utilities.

The Bounty Hunter Hunter page marks each known bounty with a green square when
its adventure location is currently accessible, or a red square when it is not.

## Login scripts

- `raffle_login.ash` adds a browser notice for the day's raffle prize.
- `daily_reminders.ash` adds notices for useful unfinished daily actions:
  available free rests when HP or MP is missing, garden growth, the Daily
  Dungeon, the Neverending Party quest, permanent-unlock progress, specific
  Clan VIP facilities, workshed actions, voting, Campaway buffs, selected daily
  item generators, and available bounty
  assignments. The bounty notice tracks filthy lucre toward `Transcendent
  Olfaction`, including lucre in Hagnk's during Hardcore or Ronin. Progression
  notices cover LT&T, Gingerbread City, Spacegate vaccines, Snojo reward tracks,
  and Witchess puzzles. The new clan and item-generator notices name their
  exact source and avoid resources already represented by KoLmafia's default
  Daily Deeds. The party notice is suppressed after learning
  `Drinking to Drink`. The script only reports; it never accepts a quest,
  spends a turn, uses an item, or harvests anything.

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
set dailyRemindersProgression = false
set dailyRemindersClan = false
set dailyRemindersWorkshed = false
set dailyRemindersVoting = false
set dailyRemindersCampaway = false
set dailyRemindersItemGenerators = false
```

The notices are displayed by `relay/main.ash`. It reruns `daily_reminders.ash`
whenever the main map loads, so disabled or newly completed reminders disappear
as soon as the main pane is refreshed. The map also refreshes automatically when
you return to the relay browser after using a KoLmafia Daily Deed, so deeds that
cast a skill update or remove the corresponding reminder immediately.

The main map also links to a standalone **Long-Term Goals** page. It organizes
important permanent unlocks, useful class skills, Sea progress, clan-dungeon
skills, Hardcore perms, and curated historical rewards. Entries use native KoL
icons and expand on click to show their unlock criteria. Completion is derived
from KoLmafia state; the page has a non-persistent **Show completed** toggle.
