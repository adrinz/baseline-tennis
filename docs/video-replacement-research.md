# Human video replacement research

Research date: 2026-10-18

## Current mobile catalog

The mobile app now bundles **101 offline video clips**, including **31 new
Pexels additions**. The catalog combines licensed player/human footage with
Baseline diagrams. The clips are useful context and support for the written
coaching, but not every clip is an exact demonstration of the named technique.

## Decision context

At the start of this research, the mobile app bundled 29 Baseline-original
diagram clips. The goal is
to replace technique and pattern diagrams with real-player footage where the
footage actually demonstrates the named skill, without weakening the licensing
rules in `docs/content-licensing.md`.

The current mobile architecture expects local assets under
`apps/mobile/assets/videos/`, with license and attribution metadata in
`apps/mobile/lib/data/videos.dart`. Raw-file hotlinks and unverified downloads
are not acceptable replacements.

## Diagram inventory at research start

The 29 Baseline originals present at research start were:

```text
serve-plus-one-diagram       inside-out-forehand-diagram
crossover-step-diagram      kick-serve-diagram
angle-shot-diagram          neutral-ball-diagram
flat-serve-diagram          slice-serve-diagram
return-positioning-diagram  backhand-slice-diagram
forehand-down-the-line-diagram
cross-court-forehand-diagram
swing-volley-diagram        drop-volley-diagram
serve-and-volley-diagram    doubles-formation-diagram
poaching-diagram             tiebreak-strategy-diagram
serve-phases-diagram         return-footwork-diagram
net-positioning-diagram      doubles-signals-diagram
defensive-net-diagram        tiebreak-scoreboard-diagram
grips-diagram                court-diagram
scoring-diagram               approach-diagram
passing-diagram
```

The most important mappings at research start were:

| Lesson | Current diagram | Existing non-diagram videos already attached |
| --- | --- | --- |
| Kick serve | `kick-serve-diagram` | `serve-toss`, `serve-aerial` |
| Angle shot | `angle-shot-diagram` | `rally-aerial`, `approach-diagram` |
| Neutral ball | `neutral-ball-diagram` | `rally-baseline`, `ball-over-net` |
| Serve plus one | `serve-plus-one-diagram` | `serve-wide`, `forehand-live` |
| Inside-out forehand | `inside-out-forehand-diagram` | `forehand-live`, `footwork-baseline` |
| Crossover step | `crossover-step-diagram` | `split-step-feet`, `footwork-baseline` |
| Serve and volley | `serve-and-volley-diagram` | `serve-wide`, `volley-shadow` |
| Doubles/poaching | `doubles-formation-diagram`, `poaching-diagram` | no exact live demonstration |
| Tiebreak | `tiebreak-strategy-diagram`, `tiebreak-scoreboard-diagram` | `match-rally` only |

## What can be replaced credibly with footage already in the app

These are reasonable first-pass mapping replacements, although they are not
all exact technique demonstrations:

| Diagram | Human footage to evaluate first | Assessment |
| --- | --- | --- |
| `serve-phases-diagram` | `serve-trophy`, `serve-toss`, `serve-side`, `serve-shadow` | Strong coverage of stance, toss, trophy position, contact, and follow-through. |
| `return-positioning-diagram` | `return-stance`, `ready-live`, `split-step-feet` | Good live stance and movement coverage; no exact return-contact clip. |
| `return-footwork-diagram` | `return-stance`, `split-step-feet`, `footwork-baseline` | Good movement coverage; narration must not claim a full return sequence. |
| `backhand-slice-diagram` | `slice-shadow`, `backhand-one-shadow` | Human demonstrations exist in the Commons set; they are controlled/shadow clips rather than match play. |
| `net-positioning-diagram` | `volley-shadow`, `rally-contact` | Good for racket-up and compact volley mechanics, subject to the license issue noted below. |
| `cross-court-forehand-diagram` | `forehand-live`, `rally-aerial` | Shows a live forehand and court geometry, but does not prove a cross-court target. |
| `forehand-down-the-line-diagram` | `forehand-live`, `rally-baseline` | Shows a live forehand and recovery, but not a clearly identifiable down-the-line ball. |
| `neutral-ball-diagram` | `rally-baseline`, `rally-aerial` | Good for height, depth, and recovery; not a deliberately labeled neutral-ball pattern. |
| `angle-shot-diagram` | `rally-aerial` | Court-level pattern is visible, but a short cross-court angle is not guaranteed. |
| `court-diagram` | `courts-overhead` | Good real-court replacement, but it cannot teach all court lines as reliably as the diagram. |
| `grips-diagram` | `grip-closeup`, `ball-control` | Useful human close-ups; a complete bevel-by-bevel grip lesson still needs overlays or a controlled shoot. |

These should be described honestly in the metadata and narration. A generic
serve must not be labeled as a kick serve, and a generic rally must not be
labeled as an angle or neutral-ball pattern merely because it contains a
tennis ball.

## External candidates reviewed

### Pexels

Pexels states that its photos and videos can be downloaded and used for free,
attribution is not required, and the media may be modified. Restrictions include
not showing identifiable people in a bad or offensive light, not implying
endorsement, not selling unmodified copies, and not redistributing the media as
stock. The project should still store creator, source, page URL, license URL,
and attribution in its own metadata.

| Candidate | Creator | Published details | Potential use | Status |
| --- | --- | --- | --- | --- |
| [4902151](https://www.pexels.com/video/a-tennis-player-changing-a-serve-into-volley-4902151/) | Antoni Shkraba | 1920x1080, 9 sec, outdoor clay court; page title describes changing a serve into a volley | Best candidate found for `serve-and-volley` | Candidate; inspect the full action before approval |
| [4902771](https://www.pexels.com/video/a-tennis-player-serving-the-ball-4902771/) | Antoni Shkraba | 1920x1080, 9 sec, outdoor serve practice | General serve, flat-serve, or serve-phases supporting clip | Candidate; not spin-specific |
| [4902143](https://www.pexels.com/video/a-tennis-player-serving-the-ball-4902143/) | Antoni Shkraba | 1920x1080, 8 sec, outdoor clay-court serve practice | General serve supporting clip | Candidate; not spin-specific |
| [4902146](https://www.pexels.com/video/a-tennis-player-serving-from-the-baseline-4902146/) | Antoni Shkraba | 1920x1080, 15 sec, athlete practicing tennis skills | Serve-from-behind or baseline context | Candidate; description is broad |
| [4902165](https://www.pexels.com/video/a-man-practicing-his-serving-game-in-tennis-4902165/) | Antoni Shkraba | 1920x1080, 8 sec, outdoor clay-court serve practice | Serve routine or serve phases | Candidate; not spin-specific |
| [4902164](https://www.pexels.com/video/a-tennis-player-serving-ball-from-the-baseline-4902164/) | Antoni Shkraba | 1920x1080, 8 sec; page description currently describes an intense match | Match/rally atmosphere only | Do not treat as a serve tutorial without inspecting the clip |
| [10340699](https://www.pexels.com/video/man-hitting-tennis-ball-10340699/) | cottonbro studio | 2160x4096, vertical, 16 sec; indoor racket-and-ball practice | Grip, ball-control, or app promo footage | Poor fit for court patterns because it is vertical and indoors |
| [5730499](https://www.pexels.com/video/young-man-playing-tennis-5730499/) | cottonbro studio | 2160x4096, vertical, 21 sec; silhouette on a clay court | Atmosphere only | Poor fit for technique instruction |

Pexels candidates are not automatically approved. The editor still needs to
confirm the exact clip, screen for visible brands/logos and misleading context,
and retain a record of the page and license reviewed.

### Mixkit

Mixkit labels each item with either a Stock Video Free License or a Stock Video
Restricted License. The distinction matters: the restricted pages reviewed
offer the free 720p file for personal use only, while commercial use is routed
to a paid Envato version.

Good candidates currently marked **Free License**:

| Candidate | Creator | Published details | Potential use |
| --- | --- | --- | --- |
| [873](https://mixkit.co/free-stock-video/tennis-player-serving-873/) | @marcolopez | 1920x1080 option, 10 sec, 24 fps; slow-motion player serving | Serve phases or serve setup |
| [878](https://mixkit.co/free-stock-video/man-serving-tennis-ball-878/) | @marcolopez | 1920x1080 option, 12 sec, 24 fps; close-up serve | Serve contact/toss support |
| [879](https://mixkit.co/free-stock-video/tennis-serve-aerial-view-879/) | @marcolopez | 1920x1080 option, 10 sec, 24 fps; aerial court view | Serve target/court geometry |
| [876](https://mixkit.co/free-stock-video/tennis-player-during-a-match-876/) | @marcolopez | 1920x1080 option, 13 sec, 24 fps; woman playing a match | Rally and recovery context |
| [877](https://mixkit.co/free-stock-video/man-playing-tennis-877/) | @marcolopez | 1920x1080 option, 15 sec, 24 fps; player moving and swinging | General rally/footwork context |
| [880](https://mixkit.co/free-stock-video/two-people-playing-tennis-aerial-view-880/) | @marcolopez | 1920x1080 option, 18 sec, 24 fps; two players from above | Rally geometry and recovery |
| [869](https://mixkit.co/free-stock-video/tennis-players-at-an-outdoor-court-869/) | @marcolopez | 1920x1080 option, 20 sec, 24 fps; two players practicing | General live-court context |
| [875](https://mixkit.co/free-stock-video/tennis-players-feet-875/) | @marcolopez | 1920x1080 option, 11 sec, 24 fps; feet beginning to move | Footwork support |
| [5014](https://mixkit.co/free-stock-video/tennis-courts-filmed-from-the-air-5014/) | @vreel | 1920x1080 option, 11 sec, 25 fps; courts and players from the air | Court overview |

The following existing Mixkit entries in `videos.dart` were observed as
**Restricted License / personal use only** and should not be treated as
commercial-app-safe under the current `_mixkit` metadata helper:

| Existing video ID | Mixkit page | Current use |
| --- | --- | --- |
| `rally-contact` | [47278](https://mixkit.co/free-stock-video/tennis-player-hitting-the-ball-during-a-game-47278/) | Volley/contact clip |
| `grip-on-court` | [47279](https://mixkit.co/free-stock-video/tennis-player-hitting-the-ball-47279/) | Grip clip |
| `serve-bounce` | [45496](https://mixkit.co/free-stock-video/tennis-player-bounces-tennis-ball-before-serving-45496/) | Serve routine |
| `wall-rally-live` | [13999](https://mixkit.co/free-stock-video/tennis-player-bouncing-the-ball-on-the-wall-13999/) | Wall drill |
| `basket-balls` | [23946](https://mixkit.co/free-stock-video/a-man-takes-a-tennis-ball-out-of-the-basket-23946/) | Serve drill setup |
| `ball-over-net` | [23639](https://mixkit.co/free-stock-video/tennis-ball-flying-over-the-net-23639/) | Rally/net overview |

This is a licensing discrepancy, not just a replacement decision: the current
helper records all Mixkit clips as `Mixkit Stock Video Free License`, but the
pages above currently advertise the restricted license. They need an editor
decision before the app ships or before these clips are reused as replacements.

## Recommended replacement strategy

Do not attempt a one-for-one replacement of all 29 diagrams with generic stock
footage. Use three buckets:

1. **Replace now with existing human clips.** Remove diagram IDs from mappings
   where the existing footage is honest enough: serve phases, return position/
   footwork, backhand slice support, net-positioning support, court overview,
   and basic grip support.
2. **Use verified external footage for general live action.** Pexels and the
   Mixkit Free-License candidates can improve serve, rally, court, and
   serve-and-volley coverage after clip inspection and license recording.
3. **Commission or film controlled demonstrations for exact techniques.** A
   real stock clip is not sufficient evidence for kick serve, slice serve,
   inside-out forehand, angle shot, neutral-ball pattern, down-the-line,
   swing/drop volley, approach/passing, doubles formation/poaching, or tiebreak
   strategy. These need visible targets, player movement, and a shot sequence
   that matches the narration. A Baseline-filmed clip gives the cleanest rights
   and makes it possible to add the same English narration and overlays.

Keep diagrams for information that footage cannot teach reliably: scoring,
tiebreak score-switching, and possibly the detailed court-line lesson. A hybrid
lesson can show a live player first and retain a short explanatory overlay or
diagram where the visual is inherently spatial or rule-based.

## Phase 1 implementation status

The first safe reuse batch is now implemented. Five diagrams were removed from
the mobile catalog and replaced by existing human footage already bundled in
the app:

| Removed diagram | Lesson now leads with |
| --- | --- |
| `serve-phases-diagram` | `serve-shadow`, `serve-side`, `serve-trophy` |
| `return-positioning-diagram` | `return-stance`, `ready-live`, `split-step-feet` |
| `return-footwork-diagram` | `return-stance`, `split-step-feet`, `footwork-baseline` |
| `backhand-slice-diagram` | `slice-shadow`, `backhand-one-shadow` |
| `net-positioning-diagram` | `volley-shadow` |

The removed assets are no longer referenced or bundled. The remaining diagrams
are intentionally retained for now: the available human clips do not visibly
prove the exact shot target, spin, sequence, doubles formation, or tiebreak
state described by those lessons. Replacing them with generic tennis footage
would make the narration misleading.

## Proposed production acceptance criteria

Before any replacement is added to the repository:

- The clip visibly demonstrates the named technique or is labeled as general
  supporting footage rather than a specific technique.
- The source page, creator, exact license, license URL, attribution, duration,
  category, level, and technique are recorded in `videos.dart`.
- The editor records the date and URL reviewed; a restricted or ambiguous item
  is excluded.
- The local asset is re-encoded to the app's supported format, receives
  Baseline narration only after the rights check, and is included in the asset
  manifest.
- `apps/mobile/test/videos_test.dart` continues to pass, including local asset,
  transcript, license metadata, and URL checks.
- Any stale restricted Mixkit entries are corrected or removed in the same
  content pass rather than copied into new mappings.

This paragraph records the research-only snapshot; the implementation status
below supersedes it.

## Licensing-cleanup implementation status

After this research, the restricted Mixkit entries were removed from the mobile
catalog and their local assets were deleted:

```text
rally-contact   grip-on-court   serve-bounce
wall-rally-live basket-balls    ball-over-net
```

Their lesson/drill references now use already-present, verified catalog clips
where a supporting demonstration remains useful. This cleanup reduced the
catalog from 81 to 75 entries; the Phase 1 reuse batch reduced it again from 75
to 70. No new external footage had been downloaded or approved at that stage.

## Expanded catalog implementation

The catalog has now been expanded to **101 videos** by adding 31 new Pexels
clips. Each clip was downloaded from its Pexels page URL, stored locally under
`apps/mobile/assets/videos/`, and given a Baseline English voiceover, transcript,
source-page URL, creator, license metadata, and lesson/drill mappings. The raw
Pexels source audio was replaced by the generated Baseline narration so the
catalog metadata remains accurate. The new local alternatives were normalized
to H.264/AAC at 1280x720 to limit the offline bundle size and avoid adding more
4K/portrait codec variance.

The new IDs are:

```text
wall-rally-pexels              basket-setup-pexels
serve-toss-pexels              serve-to-volley-pexels
serve-close-pexels             serve-baseline-pexels
serve-routine-pexels           serve-clay-pexels
serve-prep-pexels              serve-practice-pexels
serve-repeat-pexels             serve-game-pexels
ball-control-pexels             racket-handling-pexels
player-practice-pexels          match-aerial-pexels
court-aerial-pexels             girls-practice-pexels
rally-live-pexels               match-rally-pexels
ball-bounce-pexels              clay-rally-pexels
racket-bounce-pexels             racket-ball-setup-pexels
racket-control-pexels            vertical-toss-pexels
vertical-court-practice-pexels   junior-practice-pexels
grip-close-pexels                grip-tape-pexels
racket-hold-pexels
```

The six deleted restricted Mixkit uses now have local alternatives:

| Former use | Current local alternative |
| --- | --- |
| Wall rally | `wall-rally-pexels` |
| Balls from a basket | `basket-setup-pexels` |
| Serve-bounce/routine support | `serve-toss-pexels`, `vertical-toss-pexels`, `serve-routine-pexels` |
| Grip on court | `racket-hold-pexels`, `racket-handling-pexels`, `grip-close-pexels` |
| Rally/contact support | `rally-live-pexels`, `match-rally-pexels` |
| Ball/net and court geometry | `match-aerial-pexels`, `court-aerial-pexels`, `clay-rally-pexels` |

The new clips improve human/player coverage, but they are not all exact
technique proofs. Generic rally clips remain labeled as rally or groundstroke
support rather than being presented as kick serve, slice serve, angle shot, or
another specific technique without visible evidence.

## Human-first catalog update

The remaining 24 Baseline diagram clips have now been removed from the visible
mobile video catalog and replaced with local human/player clips from Coverr and
Pexels. This includes the former pattern clips for serve plus one, inside-out
forehand, crossover movement, kick/flat/slice serve, angle and neutral balls,
down-the-line and cross-court forehands, swing/drop volley, serve-and-volley,
doubles, poaching, tiebreak support, grips, court, scoring, approach, and
passing.

The replacement titles and transcripts deliberately say “support” where a
generic player clip cannot prove the exact target, spin, score state, or tactical
sequence. The app no longer presents the old animated court diagrams as playable
videos. The written lesson remains the authority for the exact coaching details.
