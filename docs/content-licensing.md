# Content and video licensing

## Writing

Lesson text, drill instructions, glossary definitions, and coach-rule answers are **original Baseline copy**. Do not paste rulebooks, coach blogs, or video transcripts. Facts (a ball is out if it misses the line) can be restated. The ITF Rules of Tennis document itself is not copied.

Each lesson in the CMS is the content model from the product brief: title, summary, level, category, technique, blocks, images, videos, tips, mistakes, drills, equipment, minutes, prerequisite, next lesson.

## Video rules

Allowed

- Video Baseline filmed or commissioned (`license = original`)
- A contract that allows this app to stream or embed (`licensed`), with the contract URL stored
- Public domain
- Creative Commons only when the license allows an app to show it. Note the exact license (for example CC BY). NoShare-alike and non-commercial limits must be checked before use.
- An official embed (YouTube or Vimeo) when the creator’s settings and the platform terms allow embedding. Store the watch URL and show attribution.

Not allowed

- Downloading, ripping, or re-uploading someone else’s video
- Hotlinking a raw file from another site
- “Found on the internet” with no license record

## Required fields before publish

Title, source, creator, license, attribution, URL, category, level, technique (or “general”), duration.

The admin publish action and the database check both enforce this. A lesson can publish with text only. A video block with a missing license is dropped, not shipped.

## Seed content

`content/seed/` holds original starter lessons, drills, glossary terms, and coach rules so the app runs without third-party video. Videos can be attached later by an editor.

Technique families to cover over time:

- Ready position, grips, preparation, contact, follow-through, recovery, split step, shuffle, crossover
- Forehand, one- and two-handed backhand, topspin, slice, flat, cross-court, down the line
- Volleys, overhead, approach, swing volley notes at higher levels
- Serve phases and serve types, return patterns
- Lob, drop shot, passing shot, angle, and rallying fundamentals

MVP seed priority: every Level 1 topic has a lesson. Level 2 and 3 have a published lesson for each main stroke plus rallying, serve, and a strategy article. The rest of the catalog exists as draft titles editors can fill.

## Recommendations vs ads

Equipment rows have `sponsored`. The UI prints “Sponsored” on those cards and keeps them out of the “Baseline pick” list. Affiliate URLs are stored on the product and disclosed in the guide footer.
