# Study Sessions

Lab 1 for Mobile Development, 2026. Made by Ramazan (Rake17).

## My domain

I made an app for study sessions. Students at KBTU often study together
before exams, so I wanted one place to find these sessions. A session can
be in a room at the university or online. Every session has a limited
number of places. In the app you can find a session, join it or leave it,
and add it to favourites. All data is in memory, so it resets when you
restart the app.

How my model matches the lab:

| Part of the lab | In my app |
|---|---|
| title | `title`, from 3 to 60 characters |
| category | `Subject` enum, 6 subjects, each has a label and an icon |
| when | `startsAt`, the app knows if a session is past or upcoming |
| limit | `capacity`, how many places there are |
| the list | `members`, the names of people who joined |
| mode | `isOnline`, if it is on, the place must be a link with `://` |
| optional text | `agenda`, what we will study |
| favourite | `isFavourite` |

## Screenshots

| Phone, light | Phone, dark | Tablet, grid |
|---|---|---|
| ![phone light](screenshots/phone_light.png) | ![phone dark](screenshots/phone_dark.png) | ![tablet grid](screenshots/tablet_grid.png) |

## Decisions

I keep the list of sessions and the profile in the State of the shell,
because all three tabs and the detail screen need the same data. The detail
screen gets callbacks, because when I join, leave or delete a session, the
shell has to update its list. The form only returns a session with `pop`,
because its job is to give one answer, and if I go back without saving it
just returns `null`. I used `LayoutBuilder` for the grid, because I need the
width of the place where the list is, not the width of the whole screen.
`PopScope` in the form compares the current values with the values the form
had when it opened, so the dialog only shows if something really changed.
With the tools from week 9, I would save the sessions on the phone, so they
do not disappear after a restart.
