# VALO Rank Studio

**Your stream. Your rank.**

A local VALORANT rank overlay for OBS Studio, powered by the [HenrikDev API](https://github.com/Henrik-3/unofficial-valorant-api). Connect your Riot ID, choose your style, and add the overlay as an OBS Browser source.

No build step. No third-party npm dependencies. Your API key stays on your computer and is sent only to HenrikDev to retrieve your stats.

## Features

- Current rank, rank badge, RR, and the most recent RR change.
- Session wins, losses, draws, win rate, and total RR change.
- Recent competitive matches with map, score, and RR change.
- Three layouts: **Arena**, **Compact**, and **Vertical**.
- Custom accent colors, card opacity, animations, and name/history visibility.
- Transparent OBS background and an interactive dashboard preview.
- Automatic updates, rate-limit handling, and cached results during API outages.
- Settings and session history saved locally across restarts.
- A clearly labeled demo before connecting an account.

## Requirements

- **Node.js 22 or newer**, available from [nodejs.org](https://nodejs.org/).
- An active **HenrikDev API key** from the [HenrikDev dashboard](https://api.henrikdev.xyz/dashboard/).
- OBS Studio or another app that supports browser sources.
- Internet access for live game data.

Use an account you own or have permission to access. You do not need to enter your Riot password.

## Quick start

### Windows

1. Download this repository using **Code → Download ZIP**, then extract it.
2. Install Node.js 22 or newer if needed.
3. Double-click **START OVERLAY.cmd**.
4. Enter your Riot ID name, tag, region, and platform.
5. Paste your HenrikDev API key and click **Connect account**.

The dashboard opens at **[http://127.0.0.1:4321](http://127.0.0.1:4321)**. The app runs in the background; you can close the dashboard while streaming. Use **STOP OVERLAY.cmd** to stop it. Run START OVERLAY again after restarting your computer.

The Windows launcher also recognizes the Node.js runtime bundled with Codex when available. Codex is not required if Node.js is installed normally.

### Terminal / other operating systems

From the repository root:

```sh
node overlay/server.mjs
```

Open [http://127.0.0.1:4321](http://127.0.0.1:4321). Keep the terminal running while streaming; press **Ctrl+C** to stop the server. No `npm install` is needed.

## Add the overlay to OBS

1. In the dashboard, choose a layout and copy the URL from **Ready for OBS**.
2. In OBS, select **Sources → + → Browser**.
3. Leave **Local file** unchecked and paste:

   ```text
   http://127.0.0.1:4321/overlay
   ```

4. Set the dimensions for your layout:

   | Layout | Width | Height |
   | --- | ---: | ---: |
   | Arena | 900 | 300 |
   | Compact | 760 | 180 |
   | Vertical | 400 | 540 |

5. Click **OK** and position the source on your scene.

The checkerboard is only part of the dashboard preview. The OBS page is transparent. Appearance changes reach OBS automatically; after switching layouts, update the source dimensions in OBS too.

## How sessions work

- Connecting an account for the first time starts a session at zero. Only competitive matches that **started on or after the session start time** count toward totals.
- **New session** resets the counters without clearing the recent-match list.
- Switching account, region, or platform starts a fresh session.
- Wins and losses come from actual team results, not the sign of an RR change. Draws and unknown results are tracked separately.
- Win rate is wins divided by matches with a known result, including draws. Unknown results are excluded.
- Session RR adds per-match changes. A **~** prefix means some RR changes are not yet available.
- Matches are deduplicated by ID and updated if RR data arrives later.
- The app fetches the latest 10 competitive matches and displays the latest 5. Already-recorded session matches are retained. After a long offline period, older missed matches may fall outside the API response; the app warns when it detects such a gap.

## Update timing

The server checks HenrikDev every **60 seconds**. The dashboard and OBS source read the local server every **3 seconds**, so opening multiple views does not multiply upstream polling.

HenrikDev may cache responses, so a completed match may take several minutes to appear. See its [caching information](https://docs.henrikdev.xyz/general/premium) and [rate-limit documentation](https://docs.henrikdev.xyz/general/rate-limiting). Rate-limit responses pause requests until the retry window ends. During an outage, the overlay keeps the latest valid data and displays **UPDATES PAUSED**.

## Privacy and local files

Runtime data lives in **`overlay/data/`**, which is excluded from Git:

| File | Contents |
| --- | --- |
| `settings.json` | API key, account details, appearance, and saved session |
| `server.log` / `server-error.log` | Windows launcher logs |
| `server.pid` | Process ID used by the Windows stop launcher |

The API key is stored in plain text locally. It is never included in the OBS URL, frontend source, or dashboard API responses. Anyone with access to the settings file can read it. **Do not upload `overlay/data/`, attach it to issues, or include it in shared archives.**

The server binds to `127.0.0.1` and is intended for local use. It is not a hosted multi-user service.

## Publishing your copy on GitHub

Publish the **source files**, not your running app's private data. The root `.gitignore` excludes runtime data, environment files, logs, asset staging files, and generated archives.

### Using Git

If the folder is not already a Git repository:

```sh
git init -b main
```

Review your files before committing:

```sh
git add .
git status
git commit -m "Initial release of VALO Rank Studio"
```

Create an empty repository on GitHub, then use the remote URL it gives you:

```sh
git remote add origin YOUR_GITHUB_REPOSITORY_URL
git push -u origin main
```

Replace `YOUR_GITHUB_REPOSITORY_URL` with your real repository URL. If you already have a remote, use that remote instead.

### Uploading through the GitHub website

Create a clean source archive:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/package-release.ps1
```

Extract **`releases/valo-rank-studio-source.zip`**, then upload the contents of its `valo-rank-studio` folder. The packager uses an explicit source-file list and excludes runtime data. Upload the extracted files, not just the ZIP, so GitHub can display the README and source. Dotfiles such as `.gitignore` and `.github` are included; ensure your upload tool includes them too.

**GitHub Pages cannot run this app.** The local Node.js server is required to fetch data, keep the API key out of the browser, and share settings with OBS. GitHub hosts the code; users run their own copy locally.

## Development

From the repository root:

```sh
# Start the app
node overlay/server.mjs

# Run tests without API keys or live network requests
node --test overlay/test/henrik.test.mjs overlay/test/server.test.mjs
```

Tests cover response normalization, actual match results, partial failures, timeouts, rate limits, session persistence, deduplication, and credential isolation. GitHub Actions is configured to run them on Windows and Linux with Node.js 22 and 24.

The server accepts an optional `PORT` environment variable (1024–65535) when launched manually. The Windows launchers use port **4321**. Refresh the browser after frontend edits and restart the server after backend edits.

```text
.
├── README.md
├── START OVERLAY.cmd / STOP OVERLAY.cmd
├── .github/workflows/test.yml
├── scripts/package-release.ps1
└── overlay/
    ├── server.mjs          # Local server, settings, and sessions
    ├── henrik.mjs          # HenrikDev integration
    ├── start.ps1 / stop.ps1
    ├── public/            # Dashboard, OBS page, styles, and rank icons
    ├── test/              # Tests with synthetic fixtures
    └── data/              # Generated locally; never publish this folder
```

## Troubleshooting

| Problem | What to check |
| --- | --- |
| Player not found | Verify name, tag, region, and platform. The account needs ranked data. |
| Invalid API key | Use an active HenrikDev key without `Bearer`. Leave the field blank when reconnecting to keep a saved key. |
| Delayed stats | Wait for the API cache to update after the match. |
| Rate limit reached | Let the app retry automatically. Avoid repeatedly reconnecting. |
| OBS cannot load the overlay | Keep the app running and use the URL shown in the dashboard. |
| Port already in use | Open the existing app or stop the other program using port 4321. |
| Windows launcher fails | Confirm Node.js 22+ is available and check `overlay/data/server-error.log`. |

## Credits

- Data: [HenrikDev unofficial VALORANT API](https://github.com/Henrik-3/unofficial-valorant-api) and its [documentation](https://docs.henrikdev.xyz/).
- Rank icons: [Valorant-API](https://valorant-api.com/). See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

This project is not affiliated with or endorsed by Riot Games. VALORANT and associated game assets belong to their respective owners. This repository does not grant a license to third-party game assets.
