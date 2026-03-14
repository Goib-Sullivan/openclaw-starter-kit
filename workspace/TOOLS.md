# TOOLS.md — Your Setup Notes

This file is for notes about your specific environment — things that are unique to your computer and setup. Skills are shared; this is yours.

---

## What Goes Here

- Device names and descriptions
- SSH hosts you connect to
- Preferred settings
- Any environment-specific details your assistant needs

---

## Examples of What to Add

```markdown
### My Devices
- Main laptop: Dell XPS 15, Windows 11 with WSL2
- Work computer: MacBook Pro (separate, not connected to this assistant)
- Phone: iPhone 14, Telegram installed

### Preferred Tone
- Keep responses concise
- Use bullet points for lists
- No need to explain basic concepts I already know

### Common Tasks
- I frequently ask for help with Excel formulas
- I often need help drafting professional emails
- I like weekly summary reminders on Fridays

### File Locations
- My projects folder: ~/projects/
- My notes: ~/notes/
- Downloads: /mnt/c/Users/[yourname]/Downloads/ (Windows side)
```

---

## Accessing Windows Files From WSL2

Your Windows files are accessible in WSL2 at:
```
/mnt/c/Users/YourWindowsUsername/
```

For example:
- Windows Desktop: `/mnt/c/Users/YourWindowsUsername/Desktop/`
- Windows Downloads: `/mnt/c/Users/YourWindowsUsername/Downloads/`
- Windows Documents: `/mnt/c/Users/YourWindowsUsername/Documents/`

Add your actual Windows username here so your assistant can help you navigate files:
```
My Windows username: [YOUR WINDOWS USERNAME]
My Windows Desktop: /mnt/c/Users/[YOUR WINDOWS USERNAME]/Desktop/
```

---

*Fill this in as you discover what your assistant needs to know about your setup.*
