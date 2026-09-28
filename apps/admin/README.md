# Baseline Admin

Development console for editors. Sign-in is a local gate for this shell. It does not call the API and it does not upload video.

## Run

```bash
npm install
npm run dev
```

Open http://localhost:3000.

## Routes

| Route | Page |
|---|---|
| `/` | Development gate (email + dev password) |
| `/lessons` | Seed lesson titles with draft or published badges |
| `/videos/new` | Video form. Publish stays disabled until the license fields are filled |
| `/reports` | Report queue with one sample player message |
