#!/usr/bin/env node

import { spawn, execSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { existsSync } from "node:fs";
import { platform } from "node:os";

const useProfile = process.argv[2] === "--profile";

if (process.argv[2] && process.argv[2] !== "--profile") {
  console.log("Usage: start.js [--profile]");
  console.log("\nOptions:");
  console.log(
    "  --profile  Copy your default Chrome/Chromium profile (cookies, logins)"
  );
  console.log("\nExamples:");
  console.log("  start.js            # Start with fresh profile");
  console.log("  start.js --profile  # Start with your browser profile");
  process.exit(1);
}

// Detect browser and profile paths based on platform
function getBrowserConfig() {
  const isMac = platform() === "darwin";
  const isLinux = platform() === "linux";
  const home = process.env["HOME"];

  if (isMac) {
    return {
      executable:
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
      profileSource: `${home}/Library/Application Support/Google/Chrome/`,
      killCommand: "killall 'Google Chrome'",
    };
  }

  if (isLinux) {
    // Try to find a browser in order of preference
    const browsers = [
      { exe: "/usr/bin/chromium", profile: `${home}/.config/chromium/` },
      {
        exe: "/usr/bin/chromium-browser",
        profile: `${home}/.config/chromium/`,
      },
      {
        exe: "/usr/bin/google-chrome",
        profile: `${home}/.config/google-chrome/`,
      },
      {
        exe: "/usr/bin/google-chrome-stable",
        profile: `${home}/.config/google-chrome/`,
      },
    ];

    for (const browser of browsers) {
      if (existsSync(browser.exe)) {
        return {
          executable: browser.exe,
          profileSource: browser.profile,
          killCommand: `pkill -f "${browser.exe}"`,
        };
      }
    }

    console.error(
      "✗ No supported browser found. Install chromium or google-chrome."
    );
    process.exit(1);
  }

  console.error("✗ Unsupported platform:", platform());
  process.exit(1);
}

const config = getBrowserConfig();
const cacheDir = `${process.env["HOME"]}/.cache/agent-web`;
const userDataDir = `${cacheDir}/profile`;

// Kill existing browser
try {
  execSync(config.killCommand, { stdio: "ignore" });
} catch {}

// Wait a bit for processes to fully die
await new Promise((r) => setTimeout(r, 1000));

// Setup profile directory
execSync(`mkdir -p ${userDataDir}`, { stdio: "ignore" });

if (useProfile && existsSync(config.profileSource)) {
  // Sync profile with rsync (much faster on subsequent runs)
  execSync(`rsync -a --delete "${config.profileSource}" "${userDataDir}/"`, {
    stdio: "pipe",
  });
}

// Start browser in background (detached so Node can exit)
spawn(
  config.executable,
  [
    "--remote-debugging-port=9222",
    `--user-data-dir=${userDataDir}`,
    "--profile-directory=Default",
    "--disable-search-engine-choice-screen",
    "--no-first-run",
    "--disable-features=ProfilePicker",
  ],
  { detached: true, stdio: "ignore" }
).unref();

// Wait for browser to be ready by checking the debugging endpoint
let connected = false;
for (let i = 0; i < 30; i++) {
  try {
    const response = await fetch("http://localhost:9222/json/version");
    if (response.ok) {
      connected = true;
      break;
    }
  } catch {
    await new Promise((r) => setTimeout(r, 500));
  }
}

if (!connected) {
  console.error("✗ Failed to connect to browser");
  process.exit(1);
}

// Start background watcher for logs/network (detached)
const scriptDir = dirname(fileURLToPath(import.meta.url));
const watcherPath = join(scriptDir, "watch.js");
spawn(process.execPath, [watcherPath], {
  detached: true,
  stdio: "ignore",
}).unref();

console.log(
  `✓ Browser started on :9222${useProfile ? " with your profile" : ""}`
);
