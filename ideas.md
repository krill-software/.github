# krill — ideas

App ideas surfaced in conversation but not yet started. Each entry is
the one-sentence pitch, the krill-fit assessment, and the open
scoping questions that need answering before drafting a SPEC.

This list is for *unstarted* ideas. Apps that have a SPEC and a
directory under `krill-software/` graduate out of this file.

---

## moodboard *(working name — needs a real one)*

**Pitch.** A flat scrapbook for design inspiration — drag images, paste
links, jot notes, sorted by when you added them. Like a private Are.na
board minus the social, or a smarter folder of screenshots.

**Shape.** Shell-family: sidebar = list of projects (+ add project) /
main = chronological feed of blocks (image / text / link). User
explicitly called it out as a shell-family candidate.

**Why it fits krill.** Single job, calm list, no AI summarization, no
auto-tagging, no social layer. Solves the "screenshots folder is now
chaos" problem most designers and engineers have.

**Open scoping questions:**
- One library file with many projects (Shape B, file-drop-style) vs
  one file per project (Shape A, pdf-reader-style). Leans Shape B
  because the user described projects-in-sidebar as the primary nav.
- Embedded base64 blobs (portable but huge) vs folder-as-document
  bundle (`my-inspiration.kboard/` = `manifest.json` + `images/<sha>.png`,
  Apple-bundle style — recommended).
- Naming: moodboard / scrapbook / inspo / board / `kboard`?
- File / bundle extension.
- Manipulation-style controls (add block button, drop hint) — confirmed.

---

## bookmarks — "read it later" for a single machine

**Pitch.** Paste URLs you mean to read; the list reminds you they're
waiting. Local-only, no cross-device. *(Discussed at length; user was
still mulling.)*

**Shape.** Likely three-column reader if archived bodies are included
(feeds-style: tags → items → article). Two-column shell otherwise.

**Why it fits krill.** Pocket-shaped without the cloud / accounts.
Solves the "I have 47 Chrome tabs I'll never read" problem.

**Open scoping questions:**
- Link-only catalog (URL + auto-fetched title + your note + tags) vs
  link + local archive (download page contents for offline + link-rot
  resistance). Pocket did the second; it's ~3× the scope.
- Capture flow: paste-only? CLI? Clipboard watcher? Browser extension
  as a separate project?
- Reader mode (Readability extraction) yes/no.
- Future sync via "point at a git remote" — krill-shaped, deferred.

---

*(iphone-photos graduated → [photo-importer](https://github.com/krill-software/photo-importer) with SPEC + M1 landed.)*

---
