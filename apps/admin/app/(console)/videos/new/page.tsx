"use client";

import { FormEvent, useState } from "react";

const LICENSES = [
  { value: "original", label: "Original" },
  { value: "licensed", label: "Licensed" },
  { value: "public_domain", label: "Public domain" },
  { value: "creative_commons", label: "Creative Commons" },
  { value: "provider_embed", label: "Provider embed" },
] as const;

const CATEGORIES = [
  "rules",
  "technique",
  "strategy",
  "fitness",
  "etiquette",
  "mental",
] as const;

const LEVELS = [
  { value: "1", label: "1 · Complete Beginner" },
  { value: "2", label: "2 · Beginner" },
  { value: "3", label: "3 · Advanced Beginner" },
  { value: "4", label: "4 · Intermediate" },
  { value: "5", label: "5 · Advanced" },
] as const;

type License = (typeof LICENSES)[number]["value"] | "";

type VideoDraft = {
  title: string;
  source: string;
  creator: string;
  license: License;
  attribution: string;
  url: string;
  category: string;
  level: string;
  technique: string;
  duration: string;
};

const EMPTY: VideoDraft = {
  title: "",
  source: "",
  creator: "",
  license: "",
  attribution: "",
  url: "",
  category: "",
  level: "",
  technique: "",
  duration: "",
};

function canPublish(draft: VideoDraft): boolean {
  const duration = Number(draft.duration);
  return (
    draft.title.trim() !== "" &&
    draft.source.trim() !== "" &&
    draft.creator.trim() !== "" &&
    draft.license !== "" &&
    draft.attribution.trim() !== "" &&
    draft.url.trim() !== "" &&
    draft.category !== "" &&
    draft.level !== "" &&
    draft.technique.trim() !== "" &&
    Number.isFinite(duration) &&
    duration > 0
  );
}

export default function NewVideoPage() {
  const [draft, setDraft] = useState<VideoDraft>(EMPTY);
  const [published, setPublished] = useState(false);
  const ready = canPublish(draft);

  function update<K extends keyof VideoDraft>(key: K, value: VideoDraft[K]) {
    setPublished(false);
    setDraft((current) => ({ ...current, [key]: value }));
  }

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!canPublish(draft)) {
      return;
    }
    setPublished(true);
  }

  return (
    <>
      <header className="page-head">
        <h1>New video</h1>
        <p>
          Publish stays off until title, source, creator, license, attribution,
          URL, category, level, technique, and duration are filled.
        </p>
      </header>
      <form className="video-form" onSubmit={onSubmit}>
        <div className="form-grid">
          <label className="field wide">
            <span>Title</span>
            <input
              name="title"
              value={draft.title}
              onChange={(event) => update("title", event.target.value)}
              required
            />
          </label>
          <fieldset className="wide">
            <legend>License record</legend>
            <label className="field">
              <span>Source</span>
              <input
                name="source"
                value={draft.source}
                onChange={(event) => update("source", event.target.value)}
                required
              />
            </label>
            <label className="field">
              <span>Creator</span>
              <input
                name="creator"
                value={draft.creator}
                onChange={(event) => update("creator", event.target.value)}
                required
              />
            </label>
            <label className="field">
              <span>License</span>
              <select
                name="license"
                value={draft.license}
                onChange={(event) => update("license", event.target.value as License)}
                required
              >
                <option value="">Select a license</option>
                {LICENSES.map((license) => (
                  <option key={license.value} value={license.value}>
                    {license.label}
                  </option>
                ))}
              </select>
            </label>
            <label className="field">
              <span>Attribution</span>
              <input
                name="attribution"
                value={draft.attribution}
                onChange={(event) => update("attribution", event.target.value)}
                required
              />
            </label>
            <label className="field wide">
              <span>URL</span>
              <input
                name="url"
                type="text"
                value={draft.url}
                onChange={(event) => update("url", event.target.value)}
                placeholder="Embed URL or owned file key"
                required
              />
            </label>
            <p className="helper">
              Third-party files must not be uploaded; store an embed or an owned
              file only.
            </p>
          </fieldset>
          <label className="field">
            <span>Category</span>
            <select
              name="category"
              value={draft.category}
              onChange={(event) => update("category", event.target.value)}
              required
            >
              <option value="">Select a category</option>
              {CATEGORIES.map((category) => (
                <option key={category} value={category}>
                  {category}
                </option>
              ))}
            </select>
          </label>
          <label className="field">
            <span>Level</span>
            <select
              name="level"
              value={draft.level}
              onChange={(event) => update("level", event.target.value)}
              required
            >
              <option value="">Select a level</option>
              {LEVELS.map((level) => (
                <option key={level.value} value={level.value}>
                  {level.label}
                </option>
              ))}
            </select>
          </label>
          <label className="field">
            <span>Technique</span>
            <input
              name="technique"
              value={draft.technique}
              onChange={(event) => update("technique", event.target.value)}
              placeholder="forehand, rally, or general"
              required
            />
          </label>
          <label className="field">
            <span>Duration (seconds)</span>
            <input
              name="duration"
              type="number"
              min={1}
              step={1}
              value={draft.duration}
              onChange={(event) => update("duration", event.target.value)}
              required
            />
          </label>
        </div>
        <div className="form-actions">
          <button className="primary" type="submit" disabled={!ready}>
            Publish
          </button>
          {published ? (
            <p className="success">Marked published in this session.</p>
          ) : (
            <p className="action-note">
              {ready
                ? "License record is complete."
                : "Publish stays disabled until the required license fields are filled."}
            </p>
          )}
        </div>
      </form>
    </>
  );
}
