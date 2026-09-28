"use client";

import { useState } from "react";

type ReportStatus = "open" | "closed";

type Report = {
  id: string;
  target: string;
  note: string;
  status: ReportStatus;
};

const SAMPLE_REPORT: Report = {
  id: "sample-player-message",
  target: "Player message",
  note: "A player reported a message that continued after they declined a partner request.",
  status: "open",
};

export default function ReportsPage() {
  const [reports, setReports] = useState<Report[]>([SAMPLE_REPORT]);
  const openReports = reports.filter((report) => report.status === "open");

  function closeReport(id: string) {
    setReports((current) =>
      current.map((report) =>
        report.id === id ? { ...report, status: "closed" } : report,
      ),
    );
  }

  return (
    <>
      <header className="page-head">
        <h1>Reports</h1>
        <p>Open player reports. Closing one keeps the decision in this view.</p>
      </header>
      {openReports.length === 0 ? (
        <p className="empty-state">No open reports</p>
      ) : (
        <ul className="report-list">
          {openReports.map((report) => (
            <li key={report.id} className="report-row">
              <div>
                <p className="report-kind">{report.target}</p>
                <h2>{report.note}</h2>
              </div>
              <button
                className="primary"
                type="button"
                onClick={() => closeReport(report.id)}
              >
                Close
              </button>
            </li>
          ))}
        </ul>
      )}
    </>
  );
}
