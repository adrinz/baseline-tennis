import { lessonCatalog } from "@/lib/lessons";

export default function LessonsPage() {
  return (
    <>
      <header className="page-head">
        <h1>Lessons</h1>
        <p>Titles from the seed catalog. Each row shows draft or published.</p>
      </header>
      <ul className="lesson-list">
        {lessonCatalog.map((lesson) => (
          <li key={lesson.slug} className="lesson-row">
            <div>
              <h2>{lesson.title}</h2>
              <p className="meta">
                Level {lesson.level} · {lesson.levelName} · {lesson.category}
              </p>
            </div>
            <span className={`badge badge-${lesson.status}`}>{lesson.status}</span>
          </li>
        ))}
      </ul>
    </>
  );
}
