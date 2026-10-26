# Baseline human-footage filming brief

Status: planning brief; no Baseline-owned footage has been commissioned. The
catalog now includes verified Pexels alternatives, but exact advanced technique
coverage still benefits from controlled filming.

Related files:

- `docs/content-licensing.md` — required rights and metadata policy.
- `docs/video-replacement-research.md` — research, cleanup history, and the
  current replacement boundary.
- `apps/mobile/lib/data/videos.dart` — current lesson/video IDs and narration.

## Goal

Create a small, controlled library of Baseline-owned tennis demonstrations for
the remaining lessons where generic stock footage cannot prove the exact shot,
target, spin, sequence, formation, or score state.

The footage should support the existing English narration without forcing the
editor to overstate what a clip shows. It should work offline as bundled local
video, with one short clip per teachable action or pattern.

## Rights and production requirements

The preferred route is Baseline-filmed footage or a written commissioning
agreement that grants Baseline the right to edit, add narration and overlays,
bundle, stream, distribute, and sublicense the resulting clips inside the app
and its promotional previews. Obtain signed releases from every identifiable
player, coach, and camera operator, plus permission from the court/location.

Do not record copyrighted music, branded instructional material, broadcast
footage, or visible third-party logos that could imply endorsement. Keep the
raw footage, signed agreements, release dates, creator names, and final clip
hashes with the project’s private production records; commit only the stable
license summary and metadata needed by the app.

## Capture specification

- Landscape 16:9, preferably 4K capture so the editor can crop to 1920x1080.
- Final masters: H.264 MP4, 1920x1080, 24 or 30 fps, no embedded music.
- Record a clean take with no spoken instruction; Baseline adds the existing
  English voiceover in post.
- Use a locked or gently tracked camera. Keep the whole player, racket, ball,
  net, baseline, and target area in frame when the action depends on court
  geometry.
- Capture a wide coach-facing angle and a second angle only when it clarifies
  contact, spin, or movement. Do not use a dramatic crop as the only teaching
  view.
- Mark targets with removable, non-branded cones or flat court-safe markers.
- Record at least two clean takes per shot: one normal speed and one controlled
  slow-motion take when contact or bounce is the lesson point.
- Leave a short handle before and after each action for editing and narration.
- Use a slate or production log for clip ID, take number, player handedness,
  camera angle, and target. Do not burn the slate into the final master.

## General shot pattern

For each technique, capture these three forms when practical:

1. **Context:** one wide take showing starting position, target, and recovery.
2. **Mechanics:** a closer side or rear take showing preparation, contact, and
   finish without hiding the ball or racket.
3. **Repeat:** two or three consecutive examples so the editor can choose a
   clean action and demonstrate that the pattern is repeatable.

Each final clip should answer “what should the learner see?” in its first few
seconds. If the clip only provides atmosphere or a generic stroke, catalog it as
supporting footage instead of assigning it to the exact technique.

## Exact-technique shot list

The IDs below match the current mobile catalog. The requested action is the
minimum visible evidence needed before replacing its diagram.

### Baseline patterns and movement

| Clip ID | Capture the action | Required visual evidence |
| --- | --- | --- |
| `serve-plus-one-live` | Serve to a marked target, recover toward the middle, receive a return, then attack the first playable ball into open court. | One continuous sequence plus an elevated view showing serve target, recovery, and first-ball direction. |
| `inside-out-forehand-live` | Start on the backhand side, move around the ball, load outside the ball, and drive a forehand cross-court. | Wide baseline view must show the player moving around the backhand corner and recovering. |
| `crossover-step-live` | Move wide, turn the hips, cross the outside foot over the inside foot, finish with adjustment steps, and split step. | Full-body side/wide view; include a reset and repeat in both directions if possible. |
| `angle-shot-live` | Use a short cross-court swing to send the ball toward a marked short-angle target. | Elevated or rear view must make the diagonal path and short landing area obvious. |
| `neutral-ball-live` | Play several safe, high, deep cross-court balls while neither player attacks; both players recover toward the middle. | At least three consecutive balls with no misleading winner or attack; elevated view preferred. |
| `forehand-down-the-line-live` | Start with a controllable forehand and send the ball down the same sideline to a marked deep target. | Camera behind the hitter or elevated enough to distinguish down-the-line from cross-court. |
| `cross-court-forehand-live` | Hit a forehand diagonally over the lower part of the net to a generous cross-court target. | Elevated view or two court-side angles must show the intended diagonal lane. |

### Serve family

| Clip ID | Capture the action | Required visual evidence |
| --- | --- | --- |
| `kick-serve-live` | Show the toss, upward-and-across brushing action, high net clearance, and a high/away bounce in the service box. | Side/rear slow motion at contact plus a receiver-side view of the bounce. Do not label a serve “kick” if the bounce is not visible. |
| `flat-serve-live` | Show a sideways stance, forward toss, high contact, direct drive through the box, and balanced landing. | Side/rear view with a marked target; ball flight should be visible enough to distinguish the direct path. |
| `slice-serve-live` | Show the hitting-side toss, brushing around the outside of the ball, wide target, and curve away from the receiver. | Rear/elevated view of the wide service-box target plus contact close-up. |
| `serve-and-volley-live` | Serve to a predictable target, move forward behind the serve, split step as the returner contacts, and volley into open court. | One continuous serve-to-volley sequence; include a wide view with both players and the net. |

### Net and transition shots

| Clip ID | Capture the action | Required visual evidence |
| --- | --- | --- |
| `approach-live` | Move in behind a short ball, hit deep cross-court or down the line, continue forward, split step, and prepare for the volley. | Wide view must show the short feed, forward movement, service-line split step, and next position. |
| `passing-shot-live` | Put a player at the net, then show a low cross-court or down-the-line pass after the net player commits. | Both players and the target lane must remain visible; include a lob alternative only as a separate take. |
| `swing-volley-live` | Move forward behind a short ball and strike a controlled forehand before it drops too low. | Side/wide view shows forward momentum, contact in front, and continued movement to the net. |
| `drop-volley-live` | Receive a firm ball near the net, soften the hands, absorb pace, and land the ball just over the net. | Close contact view and a net-side view of the short landing; avoid calling a normal volley a drop volley. |
| `defensive-net-live` | Receive a hard ball at the feet, lower the center of gravity, block with a firm face, clear the net, and recover. | Feed must visibly arrive at the feet; capture the block and the recovery position in one wide take. |

### Doubles patterns

| Clip ID | Capture the action | Required visual evidence |
| --- | --- | --- |
| `doubles-formation-live` | Show the server behind the baseline and the partner near the service line; both players shift together as the ball changes direction. | Wide full-court view with both teams or a clearly marked opposing side; preserve the middle lane in frame. |
| `doubles-signals-live` | Before the serve, show a stay/cross signal, server confirmation, starting positions, and the resulting first movement. | Camera must show the signal without exposing private production notes; record stay and cross as separate takes. |
| `poaching-live` | Net player reads a strong cross-court ball, closes across the middle, intercepts, and recovers with the partner. | Wide view shows the partner’s feed, the crossing path, interception point, and recovery. |

### Rules and information visuals

These clips are better treated as controlled inserts or overlays than as stock
action footage. The existing diagrams may remain the primary visual if a filmed
version would be less clear.

| Clip ID | Optional controlled capture | Keep the diagram when |
| --- | --- | --- |
| `grips-live` | Close-up of a racket handle with numbered bevel overlays and separate continental, eastern forehand, semi-western, one-handed, and two-handed positions. | The camera cannot keep the bevels, knuckles, and labels legible at the same time. |
| `court-live` | Locked top-down court plate with temporary line labels, singles/doubles alley markers, and service-box overlays. | The shot cannot clearly show all lines and the narration needs exact court terminology. |
| `scoring-live` | Coach hands a point card to a simple physical scoreboard for love/15/30/40/deuce/advantage, then games and sets. | A filmed board is slower or less legible than a clean animated diagram. |
| `tiebreak-scoreboard-live` | Film a close scoreboard insert showing server-first calling, end changes after one point and every six points, and the two-point margin. | The score state cannot be verified frame by frame. |
| `tiebreak-strategy-live` | Two or three short points with a clear target, middle protection, one-extra-ball pattern, and reset routine between points. | The camera cannot prove the intended tactical choice rather than a random rally. |

## Production log and edit deliverables

For every captured take, record:

- clip ID and take number;
- date, location, camera operator, editor, and players;
- player handedness and whether the take is normal speed or slow motion;
- camera angle, target location, feed type, and whether the intended result was
  achieved;
- release/agreement reference and any visible logo or location exception;
- final duration, frame rate, dimensions, codec, and checksum after export.

For each accepted clip, deliver:

1. A clean local MP4 master with no slate, music, or burned-in production notes.
2. A short transcript matching the final Baseline narration.
3. A source record with title, source, creator, license, attribution, license
   URL or contract URL, page/source URL, category, level, technique, and
   duration.
4. A note explaining any crop, slow motion, held frame, overlay, or other
   adaptation.
5. A preview still that makes the teaching action recognizable in the video
   credits/admin tooling.

Use stable IDs that make the relationship to the lesson obvious, for example
`kick-serve-live` or `poaching-live`. Do not reuse a diagram ID for a different
asset: the catalog and old release notes need to remain auditable.

## Acceptance checklist before cataloging

- [ ] Rights agreement and releases are stored in the private production record.
- [ ] The action is visibly the named technique, not merely a generic tennis
      stroke.
- [ ] The shot target, sequence, or score state required by the narration is
      visible and repeatable.
- [ ] The final clip has clean audio or no production audio and can receive the
      existing English voiceover.
- [ ] The export is a supported local MP4 and is added to the mobile asset
      manifest.
- [ ] `LicensedVideo` metadata includes every required field and a source URL.
- [ ] The transcript describes only what the final clip shows.
- [ ] `flutter test test/videos_test.dart` passes after the catalog change.
- [ ] An editor reviews the clip and signs off before a diagram is removed from
      a lesson mapping.

## Recommended filming order

1. Film the serve family and serve-plus-one while the court, camera, and
   receiver setup are already in place.
2. Film baseline patterns and crossover movement with the same two players and
   elevated court camera.
3. Film approach, passing, swing/drop volley, serve-and-volley, and defensive
   net sequences while the net setup is active.
4. Film doubles formation, signals, and poaching with four players.
5. Treat grips, court, scoring, and tiebreak scoreboard as optional inserts;
   retain the existing diagrams unless the filmed version is clearer.
