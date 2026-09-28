export const VIDEO_LICENSES = [
  'original',
  'licensed',
  'public_domain',
  'creative_commons',
  'provider_embed',
] as const;

export type VideoLicense = (typeof VIDEO_LICENSES)[number];

export type VideoRecord = {
  title?: string;
  sourceName?: string;
  creatorName?: string;
  license?: string;
  licenseUrl?: string;
  attribution?: string;
  url?: string;
  category?: string;
  level?: number;
  technique?: string;
  durationSeconds?: number;
  playback?: 'embed' | 'owned_file';
};

export type PlaybackDescriptor =
  | { mode: 'embed'; url: string; attribution: string }
  | { mode: 'owned'; url: string };

const RAW_MEDIA = /\.(mp4|m4v|mov|webm)(\?.*)?$/i;

function filled(value: string | undefined): string | null {
  const trimmed = value?.trim() ?? '';
  return trimmed.length > 0 ? trimmed : null;
}

function isKnownLicense(license: string | undefined): license is VideoLicense {
  return VIDEO_LICENSES.includes(license as VideoLicense);
}

/** A raw media file is third-party unless Baseline owns the object and the license says so. */
export function isThirdPartyMediaFile(record: VideoRecord): boolean {
  const url = filled(record.url);
  if (!url || !RAW_MEDIA.test(url)) return false;
  if (record.playback !== 'owned_file') return true;
  return record.license !== 'original' && record.license !== 'licensed';
}

/**
 * Publish gate for a video row. Attribution must be non-blank.
 * Embeds may not point at a downloadable media file.
 * `owned_file` is only valid for footage Baseline filmed or licensed.
 */
export function isVideoPublishable(record: VideoRecord): boolean {
  if (!filled(record.title)) return false;
  if (!filled(record.sourceName)) return false;
  if (!filled(record.creatorName)) return false;
  if (!isKnownLicense(record.license)) return false;
  if (!filled(record.attribution)) return false;
  if (!filled(record.url)) return false;
  if (!filled(record.category)) return false;
  if (!filled(record.technique)) return false;
  if (record.level == null || !Number.isInteger(record.level) || record.level < 1 || record.level > 5) {
    return false;
  }
  if (record.durationSeconds == null || !(record.durationSeconds > 0)) return false;
  if (record.playback !== 'embed' && record.playback !== 'owned_file') return false;
  if (record.playback === 'owned_file' && record.license !== 'original' && record.license !== 'licensed') {
    return false;
  }
  if (record.license === 'creative_commons' && !filled(record.licenseUrl)) return false;
  if (isThirdPartyMediaFile(record)) return false;
  return true;
}

/** Playback payload for the app. Returns null instead of a third-party mp4. */
export function toPlaybackDescriptor(record: VideoRecord): PlaybackDescriptor | null {
  if (!isVideoPublishable(record) || isThirdPartyMediaFile(record)) return null;
  const url = filled(record.url);
  if (!url) return null;
  if (record.playback === 'owned_file') {
    return { mode: 'owned', url };
  }
  const attribution = filled(record.attribution);
  if (!attribution) return null;
  return { mode: 'embed', url, attribution };
}
